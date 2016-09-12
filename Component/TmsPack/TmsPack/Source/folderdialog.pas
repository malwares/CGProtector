{*********************************************************************}
{ TFolderDialog                                                       }
{ for Delphi & C++Builder                                             }
{                                                                     }
{ written by                                                          }
{  TMS Software                                                       }
{  copyright © 2005 - 2009                                            }
{  Email : info@tmssoftware.com                                       }
{  Web : http://www.tmssoftware.com                                   }
{                                                                     }
{ The source code is given as is. The author is not responsible       }
{ for any possible damage done due to the use of this code.           }
{ The component can be freely used in any application. The source     }
{ code remains property of the author and may not be distributed      }
{ freely as such.                                                     }
{*********************************************************************}

unit FolderDialog;
{$I TMSDEFS.INC}
interface

uses
  SysUtils, Classes, Windows;

const
  MAJ_VER = 1; // Major version nr.
  MIN_VER = 1; // Minor version nr.
  REL_VER = 0; // Release nr.
  BLD_VER = 1; // Build nr.

  // Folderdialog
  // v1.0.0.0 : first release
  // v1.0.1.0 : improved positioning of directory select dialog on multimonitor machines
  // v1.0.1.1 : fix for initializing directory
  // v1.0.2.0 : added Caption property
  // v1.1.0.0 : Added the fdoEditBox capability
  // v1.1.0.1 : Fixed issue with setting parent window handle

type

  TOptions = (fdoBrowseForComputer, fdoBrowseForPrinter, fdoDontgoBelowDomain,
           fdoReturnFSAncestors, fdoReturnOnlyFSDirs, fdoStatusText,
           fdoNewDialogStyle, fdoNoNewFolderButton, fdoEditBox);
  TFolderOptions = set of TOptions;
  TDialogPosition = (fdpDefault, fdpScreenCenter, fdpXY);

  TFolderDialog = class(TComponent)
  private
    FTitle: string;
    FDirectory: string;
    FOptions: TFolderOptions;
    FImageIndex: Integer;
    FDialogX: Integer;
    FDialogY: Integer;
    FDialogPosition: TDialogPosition;
    FCaption: string; 
    procedure SetTitle(const Value: string);
    procedure SetDirectory(const Value: string);
    procedure SetOptions(const Value: TFolderOptions);
    procedure SetDialogPosition(const Value: TDialogPosition);
    procedure SetDialogX(const Value: Integer);
    procedure SetDialogY(const Value: Integer);
    function GetVersion: string;
    procedure SetVersion(const Value: string);
    { Private declarations }
  protected
    { Protected declarations }
    function GetVersionNr: Integer;
  public
    { Public declarations }
    constructor Create(Aowner: TComponent); override;
    function Execute: boolean;
  published
    { Published declarations }
    property Caption: string read FCaption write FCaption;
    property Title: string read FTitle write SetTitle;
    property Directory: string read FDirectory write SetDirectory;
    property ImageIndex: Integer read FImageIndex;
    property Options: TFolderOptions read FOptions write SetOptions default [fdoNewDialogStyle];
    property DialogPosition: TDialogPosition read FDialogPosition write SetDialogPosition default fdpDefault;
    property DialogX: Integer read FDialogX write SetDialogX;
    property DialogY: Integer read FDialogY write SetDialogY;
    property Version: string read GetVersion write SetVersion;
  end;

implementation

uses
  ShlObj, Forms, ActiveX, Messages, Dialogs;

const
   bif_NoNewFolderButton = $0200;
   BIF_NEWDIALOGSTYLE    = $0040;


function DirectoryExists(const Directory: string): Boolean;
var
  Code: Integer;
begin
  Code := GetFileAttributes(PChar(Directory));
  Result := (Code <> -1) and (FILE_ATTRIBUTE_DIRECTORY and Code <> 0);
end;

{ TFolderDialog }

function FolderDialogCallBack(Wnd: HWND; uMsg: UINT; lParam, lpData: LPARAM): Integer; stdcall;
var
  r: TRect;
  x,y : Integer;
begin
  if (uMsg = BFFM_INITIALIZED) then
  begin
    with TFolderDialog (lpData) Do
    begin
      SendMessage (Wnd, BFFM_SETSELECTION, 1, Integer(PChar(Directory)));
      x := 0;
      y := 0;
      case DialogPosition of
        fdpDefault:
          begin
            GetWindowRect(Wnd,r);
            x := r.Left;
            y := r.Top;
          end;
        fdpScreenCenter:
          begin
            GetWindowRect(Wnd,r);
            //outputdebugstring(pchar('size init:'+inttostr(r.Right-r.Left)));
            x := Screen.DesktopWidth div 2 - ((r.Right - r.Left) div 2);
            y := Screen.DesktopHeight div 2 - ((r.Bottom - r.Top) div 2);
          end;
        fdpXY:
          begin
            if DialogX < 0 then
              x := 0
            else
              x := DialogX;
            if DialogY < 0 then
              y := 0
            else
              y := DialogY;
          end;
      end;
      SetWindowPos(Wnd, HWND_NOTOPMOST, x, y, 0, 0, SWP_NOSIZE or SWP_NOZORDER);
      if FCaption <> '' then 
        SendMessage(Wnd, WM_SETTEXT, 0, Integer(PChar(FCaption)));    
    end;
  end;
  Result := 0;
end;

constructor TFolderDialog.Create(Aowner: TComponent);
begin
  inherited Create(AOwner);
  if not (csDesigning in ComponentState) then
    Directory := GetCurrentDir;
  DialogPosition := fdpDefault;
  Options := [fdoNewDialogStyle];
  FCaption := '';
end;

function TFolderDialog.Execute: boolean;
const
  FolderOptions: array [TOptions] of DWORD = (
    bif_BrowseForComputer, bif_BrowseForPrinter, bif_DontgoBelowDomain,
    bif_ReturnFSAncestors, bif_ReturnOnlyFSDirs, bif_StatusText,
    bif_NewDialogStyle, bif_NoNewFolderButton, bif_EditBox);

var
  bi: TBrowseInfo;
  iIdList: PItemIDList;
  ResStr: array[0..MAX_PATH] of char;
  MAlloc: IMalloc;
  O: TOptions;
  
begin
  FillChar(bi, sizeof(bi), #0);
  
  if (Owner is TCustomForm) then
    bi.hwndOwner := (Owner as TCustomForm).Handle
  else
    bi.hwndOwner := Application.Handle;

  bi.lpszTitle := PChar(Title);
  If not DirectoryExists(Directory) then
     Directory := GetCurrentDir;
     
  for O  := Low(O) to High(O) do
  begin
    if O in FOptions then
      bi.ulFlags := bi.ulFlags or FolderOptions[O];
  end;
  
  bi.lpfn := FolderDialogCallBack;
  bi.lParam := Integer(Self);
  iIdList := Nil;
  Result := false;
  try
    iIdList := SHBrowseForFolder(bi);
  except
  end;

  if iIdList <> Nil then
  begin
    try
      FillChar(ResStr,sizeof(ResStr),#0);
      if SHGetPathFromIDList (iIdList, ResStr) then
      begin
        Directory := StrPas(ResStr);
        FImageIndex := bi.iImage;
        Result := true;
      end;
    finally
      SHGetMalloc(MAlloc);
      Malloc.Free(iIdList);
    end;
  end;
end;

function TFolderDialog.GetVersion: string;
var
  vn: Integer;
begin
  vn := GetVersionNr;
  Result := IntToStr(Hi(Hiword(vn)))+'.'+IntToStr(Lo(Hiword(vn)))+'.'+IntToStr(Hi(Loword(vn)))+'.'+IntToStr(Lo(Loword(vn)));
end;

function TFolderDialog.GetVersionNr: Integer;
begin
  Result := MakeLong(MakeWord(BLD_VER,REL_VER),MakeWord(MIN_VER,MAJ_VER));
end;

procedure TFolderDialog.SetDialogPosition(const Value: TDialogPosition);
begin
  FDialogPosition := Value;
end;

procedure TFolderDialog.SetDialogX(const Value: Integer);
begin
  FDialogX := Value;
end;

procedure TFolderDialog.SetDialogY(const Value: Integer);
begin
  FDialogY := Value;
end;

procedure TFolderDialog.SetDirectory(const Value: string);
begin
  FDirectory := Value;
end;

procedure TFolderDialog.SetOptions(const Value: TFolderOptions);
begin
  FOptions := Value;
end;

procedure TFolderDialog.SetTitle(const Value: string);
begin
  FTitle := Value;
end;

procedure TFolderDialog.SetVersion(const Value: string);
begin

end;

end.
