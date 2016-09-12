{********************************************************************}
{ TWEBDATA component                                                 }
{ for Delphi & C++Builder                                            }
{                                                                    }
{ written by                                                         }
{     TMS Software                                                   }
{     copyright © 1999-2010                                          }
{     Email: info@tmssoftware.com                                    }
{     Web: http://www.tmssoftware.com                                }
{                                                                    }
{ The source code is given as is. The author is not responsible      }
{ for any possible damage done due to the use of this code.          }
{ The component can be freely used in any application. The source    }
{ code remains property of the writer and may not be distributed     }
{ freely as such.                                                    }
{********************************************************************}

unit WebData;

{$HPPEMIT ''}
{$HPPEMIT '#pragma link "wininet.lib"'}
{$HPPEMIT ''}


interface

{$I TMSDEFS.INC}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, ShellApi, IniFiles, WinInet
  {$IFDEF TMSDOTNET}
  , System.IO, System.Runtime.InteropServices, System.Text
  {$ENDIF}
  ;

const
  MAJ_VER = 1; // Major version nr.
  MIN_VER = 3; // Minor version nr.
  REL_VER = 0; // Release nr.
  BLD_VER = 0; // Build nr.

  // version history
  // 1.1.0.1 : fix in using WebDataItem.FileName
  // 1.2.0.0 : New VCL.NET support
  // 1.2.1.0 : Agent property added
  // 1.2.2.0 : Improved : when ScanFirst = '', the entire page is returned
  // 1.2.2.1 : Fixed : issue with saving temporary file under app folder
  // 1.2.3.0 : New : public property FullPageCode in TWebDataItem to access full page content
  // 1.3.0.0 : New : can work fully in memory, without temporary file use

type
  TWebDataProgressEvent = procedure(Sender:TObject;iItem: Integer) of object;
  TWebDataDataEvent = procedure(Sender:TObject;iItem: Integer;data:string) of object;
  TThreadCollectDoneEvent = procedure(Sender:TObject) of object;
  TCollectErrorEvent = procedure(Sender:TObject;iItem,errcode: Integer) of object;

  TWebData = class;

  TWDInetThread = class(TThread)
  private
    Webdata: TWebData;
  protected
    procedure Execute; override;
  public
    constructor Create(awebdata:TWebData);
  end;

  TWebDataItem = class(TCollectionItem)
  private
    FURL: string;
    FScanFirst: string;
    FScanFrom: string;
    FScanTo: string;
    FData: string;
    FSuccess: Boolean;
    FFileName: string;
    FAutoDelete: Boolean;
    FEnable: Boolean;
    FTag: Integer;
    FFullPageCode: string;
  protected
    function GetDisplayName: string; override;
  public
    constructor Create(Collection:TCollection); override;
    destructor Destroy; override;
    property Data: string read FData write FData;
    property FullPageCode: string read FFullPageCode;
    property Success: Boolean read FSuccess;
    property FileName: string read FFileName write FFileName;
  published
    property AutoDelete: Boolean read FAutoDelete write FAutoDelete default True;
    property Enable: Boolean read FEnable write FEnable default True;
    property URL: string read FURL write FURL;
    property ScanFirst: string read FScanFirst write FScanFirst;
    property ScanFrom: string read FScanFrom write FScanFrom;
    property ScanTo: string read FScanTo write FScanTo;
    property Tag: Integer read FTag write FTag;
  end;

  TWebDataCollection = class(TCollection)
  private
    FOwner: TWebData;
    function GetItem(Index: Integer): TWebDataItem;
    procedure SetItem(Index: Integer; Value: TWebDataItem);
  public
    constructor Create(aOwner: TWebData);
    function Add:TWebDataItem;
    property Items[Index: Integer]: TWebDataItem read GetItem write SetItem; default;
  protected
    procedure Update(Item: TCollectionItem); override;
    function GetOwner: TPersistent; override;
  end;

  TImageType = (itAll,itGIF,itJPG,itPNG);

  TWebData = class(TComponent)
  private
    FAgent: string;
    FImageType: TImageType;
    FImageRefs: TStrings;
    FHyperLinks: TStrings;
    FHyperLinkType: string;
    FProxy: string;
    FProxyUserID: string;
    FProxyPassword: string;
    FSaveToFile: boolean;
    FWebDataCollection: TWebDataCollection;
    FOnData: TWebDataDataEvent;
    FOnProgress: TWebDataProgressEvent;
    FOnCollectDone: TThreadCollectDoneEvent;
    FOnCollectError: TCollectErrorEvent;
    procedure SetWebDataCollection(const Value: TWebDataCollection);
    function MakeProxyUrl(url,proxyuser,proxypwd: string):string;
    function URLGetFile(hfile:hinternet;url,tgt: string;idx:integer):boolean;
    function URLGetStream(hfile:hinternet;url:string;idx:integer;ms: TMemoryStream):boolean;
    procedure ThreadDone(Sender: TObject);
    function GetVersion: string;
    procedure SetVersion(const Value: string);
    function GetVersionNr: Integer;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure CollectData;
    function Execute: Boolean;
    procedure ThreadCollectData;
    function ImageRefs: TStrings;
    function Hyperlinks: TStrings;
    property SaveToFile: boolean read FSaveToFile write FSaveToFile;
  published
    property Agent: string read FAgent write FAgent;
    property Proxy: string read FProxy write FProxy;
    property ProxyUserID: string read FProxyUserID write FProxyUserID;
    property ProxyPassword: string read FProxyPassword write FProxyPassword;
    property Data: TWebDataCollection read FWebDataCollection write SetWebDataCollection;
    property ImageType: TImageType read FImageType write FImageType;
    property HyperLinkType: string read FHyperLinkType write FHyperLinkType;
    property OnProgress: TWebDataProgressEvent read FOnProgress write FOnProgress;
    property OnData: TWebDataDataEvent read FOnData write FOnData;
    property OnCollectDone: TThreadCollectDoneEvent read FOnCollectDone write FOnCollectDone;
    property OnCollectError: TCollectErrorEvent read FOnCollectError write FOnCollectError;
    property Version: string read GetVersion write SetVersion;
  end;

implementation

const
  READBUFFERSIZE = 4096;

function IPos(su,s:string):integer;
begin
  Result := Pos(UpperCase(su),UpperCase(s));
end;

function MergeURL(host,resource: string): string;
var
  srvr: string;
begin
  srvr := '';

  if IPos('HTTP://',host) > 0 then
  begin
    srvr := 'HTTP://';
    delete(host,1,7);
  end;

  while (Length(host) > 0) and not ((host[1] ='/') or (host[1] ='\')) do
  begin
    srvr := srvr + host[1];
    delete(host,1,1);
  end;

  if IPos('HTTP:',resource) > 0 then
    Result := resource
  else
  begin
    if  (Length(resource) > 0) and ((Resource[1] = '\') or (Resource[1] = '/')) then
      Result := srvr + resource
    else
    begin
      while (Length(host) > 0) and not ( (host[Length(host)] = '/') or (host[Length(host)] = '\')) do
        Delete(host,length(host),1);
      if host = '' then
        host := '/';

      Result := srvr + host + resource;
    end
  end;
end;

procedure TWDInetThread.Execute;
begin
  WebData.CollectData;
end;

constructor TWDInetThread.Create(AWebData:TWebData);
begin
  inherited Create(False);
  WebData := AWebData;
  FreeOnTerminate := True;
end;

{ TWebDataItem }

constructor TWebDataItem.Create(Collection: TCollection);
begin
  inherited Create(Collection);
  FAutoDelete := True;
  FEnable := True;
  FTag := 0;
end;

destructor TWebDataItem.Destroy;
begin
  inherited Destroy;
end;

function TWebDataItem.GetDisplayName: string;
begin
  Result := FURL;
end;


{ TWebDataCollection }

function TWebDataCollection.Add: TWebDataItem;
begin
  Result := TWebDataItem(inherited Add);
end;


constructor TWebDataCollection.Create(aOwner: TWebData);
begin
  inherited Create(TWebDataItem);
  FOwner := AOwner;
end;

function TWebDataCollection.GetItem(Index: Integer): TWebDataItem;
begin
  Result := TWebDataItem(inherited GetItem(Index));
end;

function TWebDataCollection.GetOwner: tPersistent;
begin
  Result := FOwner;
end;

procedure TWebDataCollection.SetItem(Index: Integer; Value: TWebDataItem);
begin
  inherited SetItem(Index, Value);
end;

procedure TWebDataCollection.Update(Item: TCollectionItem);
begin
  inherited Update(Item);
end;


{ TWebData }
function TWebData.MakeProxyUrl(url,proxyuser,proxypwd:string):string;
begin
  Result := url;
  if (pos('HTTP://',uppercase(url))>0) and (proxyuser<>'') then
  begin
    Delete(url,1,7);
    Result := 'http://' + proxyuser + ':' + proxypwd + '@' + url;
  end;
end;

function TWebData.URLGetStream(hfile:hinternet;url:string;idx:integer;ms: TMemoryStream):boolean;
var
  {$IFNDEF TMSDOTNET}
  buf: array[0..READBUFFERSIZE-1] of char;
  {$ENDIF}
  {$IFDEF TMSDOTNET}
  buf: TBytes;
  {$ENDIF}
  bufsize: dword;
  hintfile: hinternet;
  lpdwlen,lpdwidx,lpdword: dword;

begin
  Result := False;
  url := MakeProxyURL(url,FProxyUserID,FProxyPassword);

  {$IFDEF TMSDEBUG}
  outputdebugstring(pchar(url));
  {$ENDIF}

  {$IFNDEF TMSDOTNET}
  hintfile := InternetOpenURL(hfile,pchar(url),nil,0,INTERNET_FLAG_RELOAD or INTERNET_FLAG_NO_CACHE_WRITE,0);
  {$ENDIF}
  {$IFDEF TMSDOTNET}
  hintfile := InternetOpenURL(hfile,url,nil,0,INTERNET_FLAG_RELOAD or INTERNET_FLAG_NO_CACHE_WRITE,0);
  {$ENDIF}

  if (hintfile = nil) then
  begin
    if Assigned(FOnCollectError) then
      FOnCollectError(self,idx,-1);
    Exit;
  end;

  lpdwlen := 4;
  lpdwidx := 0;

  if (hintfile <> nil) then
  begin
    {$IFNDEF TMSDOTNET}
    HttpQueryInfo(hintfile,HTTP_QUERY_STATUS_CODE or HTTP_QUERY_FLAG_NUMBER ,@lpdword,lpdwlen,lpdwidx);
    {$ENDIF}
    {$IFDEF TMSDOTNET}
    HttpQueryInfo(hintfile,HTTP_QUERY_STATUS_CODE or HTTP_QUERY_FLAG_NUMBER ,Intptr(lpdword),lpdwlen,lpdwidx);
    {$ENDIF}
    if (lpdword >= 300) and (lpdword <> 500) then
    begin
      if Assigned(FOnCollectError) then
        FOnCollectError(self,idx,lpdword);
      Exit;
     end;
  end;

  while (bufsize > 0) do
  begin
    Application.ProcessMessages;

    {$IFNDEF TMSDOTNET}
    if not InternetReadFile(hintfile,@buf,READBUFFERSIZE,bufsize) then break;
    {$ENDIF}
    {$IFDEF TMSDOTNET}
    if not InternetReadFile(hintfile,buf,READBUFFERSIZE,bufsize) then break;
    {$ENDIF}
    {$IFDEF TMSDEBUG}
    outputdebugstring(pchar('read from http = '+inttostr(bufsize)));
    {$ENDIF}
    if (bufsize>0) and (bufsize<=READBUFFERSIZE) then
      ms.WriteBuffer(buf,bufsize);

    if (bufsize > 0) then Result := True;
  end;

  InternetCloseHandle(hintfile);
end;


function TWebData.URLGetFile(hfile:hinternet;url,tgt:string;idx:integer):boolean;
var
  {$IFNDEF TMSDOTNET}
  buf: array[0..READBUFFERSIZE-1] of char;
  {$ENDIF}
  {$IFDEF TMSDOTNET}
  buf: TBytes;
  {$ENDIF}
  bufsize: dword;
  {$IFNDEF TMSDOTNET}
  lf: file;
  {$ENDIF}
  {$IFDEF TMSDOTNET}
  FS: FileStream;
  {$ENDIF}
  hintfile: hinternet;
  lpdwlen,lpdwidx,lpdword: dword;

begin
  Result := False;
  url := MakeProxyURL(url,FProxyUserID,FProxyPassword);

  {$IFDEF TMSDEBUG}
  outputdebugstring(pchar(url));
  {$ENDIF}

  {$IFNDEF TMSDOTNET}
  hintfile := InternetOpenURL(hfile,pchar(url),nil,0,INTERNET_FLAG_RELOAD or INTERNET_FLAG_NO_CACHE_WRITE,0);
  {$ENDIF}
  {$IFDEF TMSDOTNET}
  hintfile := InternetOpenURL(hfile,url,nil,0,INTERNET_FLAG_RELOAD or INTERNET_FLAG_NO_CACHE_WRITE,0);
  {$ENDIF}

  if (hintfile = nil) then
  begin
    if Assigned(FOnCollectError) then
      FOnCollectError(self,idx,-1);
    Exit;
  end;

  lpdwlen := 4;
  lpdwidx := 0;

  if (hintfile <> nil) then
  begin
    {$IFNDEF TMSDOTNET}
    HttpQueryInfo(hintfile,HTTP_QUERY_STATUS_CODE or HTTP_QUERY_FLAG_NUMBER ,@lpdword,lpdwlen,lpdwidx);
    {$ENDIF}
    {$IFDEF TMSDOTNET}
    HttpQueryInfo(hintfile,HTTP_QUERY_STATUS_CODE or HTTP_QUERY_FLAG_NUMBER ,Intptr(lpdword),lpdwlen,lpdwidx);
    {$ENDIF}
    if (lpdword >= 300) and (lpdword <> 500) then
    begin
      if Assigned(FOnCollectError) then
        FOnCollectError(self,idx,lpdword);
      Exit;
     end;
  end;
  {$IFNDEF TMSDOTNET}
  AssignFile(lf,tgt);
  Rewrite(lf,1);
  {$ENDIF}

  bufsize := READBUFFERSIZE;
  {$IFDEF TMSDOTNET}
  SetLength(buf, READBUFFERSIZE);
  FS := FileStream.Create(tgt,FileMode.OpenOrCreate);
  {$ENDIF}

  while (bufsize > 0) do
  begin
    Application.ProcessMessages;

    {$IFNDEF TMSDOTNET}
    if not InternetReadFile(hintfile,@buf,READBUFFERSIZE,bufsize) then break;
    {$ENDIF}
    {$IFDEF TMSDOTNET}
    if not InternetReadFile(hintfile,buf,READBUFFERSIZE,bufsize) then break;
    {$ENDIF}
    {$IFDEF TMSDEBUG}
    outputdebugstring(pchar('read from http = '+inttostr(bufsize)));
    {$ENDIF}
    if (bufsize>0) and (bufsize<=READBUFFERSIZE) then
    begin
      {$IFNDEF TMSDOTNET}
      blockwrite(lf,buf,bufsize);
      {$ENDIF}
      {$IFDEF TMSDOTNET}
      FS.Write(buf,0,READBUFFERSIZE);
      {$ENDIF}
    end;

    if (bufsize > 0) then Result := True;
  end;

  {$IFNDEF TMSDOTNET}
  CloseFile(lf);
  {$ENDIF}
  {$IFDEF TMSDOTNET}
  FS.Free;
  {$ENDIF}
  InternetCloseHandle(hintfile);
end;

procedure TWebData.ThreadCollectData;
begin
  with TWDInetThread.Create(self) do
    OnTerminate := ThreadDone;
end;

procedure TWebData.ThreadDone(Sender: TObject);
begin
  if Assigned(FOnCollectDone) then
    FOnCollectDone(self);
end;

function AddBackslash(const s: string): string;
begin
  if (Length(s) >= 1) and (s[Length(s)]<>'\') then
    Result := s + '\'
  else
    Result := s;
end;

function WinTempDir: string;
var
  buf:string;
  i: integer;
begin
  SetLength(buf, MAX_PATH);
  i := GetTempPath(Length(buf), PChar(buf));
  SetLength(buf, i);
  Result := AddBackslash(buf);
end;

procedure TWebData.CollectData;
var
  hint: hinternet;
  i,j: integer;
  wd: TWebDataItem;
  s,ir,hr,su: string;
  ch: Char;
  f: TMemorystream;
  prevurl: string;
  res: Boolean;
  hpos,tpos: Integer;
  {$IFNDEF TMSDOTNET}
  szTempName: array[0..255] of char;
  {$ENDIF}
  {$IFDEF TMSDOTNET}
  szTempName: StringBuilder;
  {$ENDIF}
  FileName:string;

begin
  if Data.Count = 0 then
    Exit;

  FImageRefs.Clear;
  FHyperLinks.Clear;

  // http
  if FProxy = '' then
    hint := InternetOpen(PChar(Agent),INTERNET_OPEN_TYPE_PRECONFIG {or INTERNET_FLAG_ASYNC},nil,nil,0)
  else
    {$IFNDEF TMSDOTNET}
    hint := InternetOpen(PChar(Agent),INTERNET_OPEN_TYPE_PROXY {or INTERNET_FLAG_ASYNC},PChar(FProxy),nil,0);
    {$ENDIF}
    {$IFDEF TMSDOTNET}
    hint := InternetOpen(Agent,INTERNET_OPEN_TYPE_PROXY {or INTERNET_FLAG_ASYNC},FProxy,nil,0);
    {$ENDIF}

  if hint = nil then
    Exit;

  f := TMemoryStream.Create;
  prevURL := '';
  FileName := '';

  for i := 1 to Data.Count do
  begin
    wd := Data.Items[i - 1];
    wd.FSuccess := False;

    if (wd.Enable) then
    begin
      if prevURL <> wd.URL then
      begin
        if (FileName <> '') and (i > 1) then
        begin
          if Data.Items[i - 2].AutoDelete then
            DeleteFile(FileName);
        end;

        FileName := wd.FileName;

        if FileName = '' then
        begin
          {$IFNDEF TMSDOTNET}
          GetTempFileName(pchar(WinTempDir),'WD',0,szTempName);
          FileName := strpas(szTempName);
          {$ENDIF}
          {$IFDEF TMSDOTNET}
          szTempName := StringBuilder.Create(READBUFFERSIZE);
          GetTempFileName(WinTempDir,'WD',0,szTempName);
          FileName := szTempName.ToString;
          {$ENDIF}
        end;

        if FSaveToFile then
          res := URLGetFile(hint,wd.URL,FileName,i - 1)
        else
        begin
          f.Clear;
          res := URLGetStream(hint, wd.URL, i - 1,f);
        end;
      end
      else
        res := true;

      Data.Items[i - 1].FileName := FileName;

      if not res then
        prevurl := ''
      else
        prevurl := wd.URL;

      if not res and (prevURL <> wd.URL) then
        Continue;

      if FSaveToFile then
      begin
        if not FileExists(FileName) then
          Continue;

        f.Clear;
        f.LoadFromfile(FileName);
      end;

      f.Position := 0;
      s := '';
      wd.Data := '';

      if Assigned(FOnProgress) then
        FOnProgress(self,i - 1);

      for j := 1 to f.size do
      begin
        f.Read(ch,1);
        s := s + ch;
      end;

      wd.FFullPageCode := s;

      ir := s;
      hr := s;
      if Pos(wd.ScanFirst,s) > 0 then
      begin
        Delete(s,1,pos(wd.ScanFirst,s) + Length(wd.ScanFirst) - 1);
        if Pos(wd.ScanFrom,s) > 0 then
        begin
          Delete(s,1,Pos(wd.ScanFrom,s) + Length(wd.ScanFrom) - 1);
          if Pos(wd.ScanTo,s) > 0 then
          begin
            wd.Data := Copy(s,1,Pos(wd.ScanTo,s) - 1);
            wd.FSuccess := True;
            if Assigned(FOnData) then
              FOnData(Self,i - 1,wd.Data);
          end;
        end;
      end
      else
      if wd.ScanFirst = '' then
      begin
        wd.Data := s;
        wd.FSuccess := True;
        if Assigned(FOnData) then
          FOnData(Self,i - 1,wd.Data);
      end;


      while IPos('<IMG',ir) > 0 do
      begin
        Delete(ir,1,ipos('<IMG',ir));
        su := Copy(ir,1,ipos('>',ir));
        if IPos('SRC="',ir) > 0 then
        begin
          Delete(ir,1,ipos('SRC="',ir)+4);
          if Pos('"',ir) > 0 then
          begin
            su := Copy(ir,1,pos('"',ir)-1);
            su := MergeURL(wd.URL,su);
            case FImageType of
            itAll:FImageRefs.Add(su);
            itGIF:if IPos('.GIF',su) > 0 then FImageRefs.Add(su);
            itJPG:if IPos('.JPG',su) > 0 then FImageRefs.Add(su);
            itPNG:if IPos('.PNG',su) > 0 then FImageRefs.Add(su);
            end;
          end;
        end;
      end;

      while IPos('<A',hr) > 0 do
      begin
        Delete(hr,1,ipos('<A',hr));
        su := Copy(hr,1,pos('>',hr));

        if IPos('HREF=',hr) > 0 then
        begin
          Delete(hr,1,ipos('HREF=',hr)+4);

          if pos('"',hr) = 1 then
           delete(hr,1,1);

          hpos := pos('"',hr);
          tpos := pos('>',hr);

          if (hpos > 0) and (tpos > hpos) then
          begin
            su := Copy(hr,1,pos('"',hr)-1);

            if Pos('://',su) = 0 then
              su := MergeURL(wd.URL,su);

            if FHyperLinkType <> '' then
            begin
              if IPos(FHyperLinkType,su) > 0 then
                FHyperLinks.Add(su);
            end
            else
            begin
              {$IFDEF TMSDEBUG}
              outputdebugstring(pchar('anchor : '+su));
              {$ENDIF}
              FHyperLinks.Add(su);
            end;
          end;

          if (tpos > 0) and (tpos < hpos) then
          begin
            su := Copy(hr,1,tpos-1);

            if Pos('://',su) = 0 then
              su := MergeURL(wd.URL,su);

            if FHyperLinkType <> '' then
            begin
              if IPos(FHyperLinkType,su) > 0 then
                FHyperLinks.Add(su);
            end
            else
            begin
              {$IFDEF TMSDEBUG}
              outputdebugstring(pchar('anchor : '+su));
              {$ENDIF}
              FHyperLinks.Add(su);
            end;
          end;

        end;
      end;
    end;  
  end;

  f.free;

  if FileExists(FileName) and Data.Items[Data.Count - 1].AutoDelete then
  begin
    DeleteFile(FileName);
  end;

  InternetCloseHandle(hint);
end;

constructor TWebData.Create(AOwner: TComponent);
begin
  inherited Create(aOwner);
  FWebDataCollection := TWebDataCollection.Create(Self);
  FImageRefs := TStringlist.Create;
  FHyperlinks := TStringlist.Create;
  FAgent := 'WebData';
  FSaveToFile := false;
end;

destructor TWebData.Destroy;
begin
  FWebDatacollection.Free;
  FimageRefs.Free;
  FHyperlinks.Free;
  inherited Destroy;
end;

procedure TWebData.SetWebDataCollection(const Value: TWebDataCollection);
begin
  FWebDataCollection := Value;
end;

function TWebData.Hyperlinks: TStrings;
begin
  Result := FHyperlinks;
end;

function TWebData.ImageRefs: TStrings;
begin
  Result := FImageRefs;
end;

function TWebData.Execute: Boolean;
var
  i: Integer;
begin
  for i := 1 to Data.Count do
    Data.Items[i - 1].FSuccess := False;
  CollectData;

  Result := True;
  for i := 1 to Data.Count do
    if Data.Items[i - 1].Success = False then
      Result := False;
end;

function TWebData.GetVersion: string;
var
  vn: Integer;
begin
  vn := GetVersionNr;
  Result := IntToStr(Hi(Hiword(vn)))+'.'+IntToStr(Lo(Hiword(vn)))+'.'+IntToStr(Hi(Loword(vn)))+'.'+IntToStr(Lo(Loword(vn)));
end;

function TWebData.GetVersionNr: Integer;
begin
  Result := MakeLong(MakeWord(BLD_VER,REL_VER),MakeWord(MIN_VER,MAJ_VER));
end;

procedure TWebData.SetVersion(const Value: string);
begin

end;


{$IFDEF FREEWARE}
{$I TRIAL.INC}
{$ENDIF}


end.
