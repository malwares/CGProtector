{*************************************************************************}
{ TMS TAdvFormStyler & TAdvAppStyler component                            }
{ for Delphi & C++Builder                                                 }
{                                                                         }
{ written by TMS Software                                                 }
{           copyright ©  2006 - 2010                                      }
{           Email : info@tmssoftware.com                                  }
{           Web : http://www.tmssoftware.com                              }
{                                                                         }
{ The source code is given as is. The author is not responsible           }
{ for any possible damage done due to the use of this code.               }
{ The component can be freely used in any application. The complete       }
{ source code remains property of the author and may not be distributed,  }
{ published, given or sold in any form as such. No parts of the source    }
{ code can be included in any other component or application without      }
{ written authorization of the author.                                    }
{*************************************************************************}

unit AdvAppStyler;

interface

uses
  Classes, AdvStyleIF, Forms, Windows, SysUtils, Controls, Messages,
  Dialogs, StdCtrls;

const
  MAJ_VER = 1; // Major version nr.
  MIN_VER = 2; // Minor version nr.
  REL_VER = 3; // Release nr.
  BLD_VER = 0; // Build nr.

  // version history
  // 1.0.1.0 : added OnChange event
  // 1.1.0.0 : Added AutoThemeAdapt capability
  // 1.1.1.0 : Added capability to handle frames in TAdvFormStyler
  // 1.1.2.0 : Added OnChange event for TAdvAppStyler
  // 1.1.3.0 : Added capability to adapt theme programmatically at runtime by setting AutoThemeAdapt
  // 1.1.4.0 : Added support to handle frames in frames
  // 1.1.4.1 : Fixed issue with AutoThemeAdapt
  // 1.2.0.0 : New : Added event OnApplyStyle in TAdvFormStyler to allow excluding components from being styled
  // 1.2.0.1 : Fixed : issue with form inheritance
  // 1.2.1.0 : Improved : handling of components that should not be styled at runtime & designtime
  // 1.2.2.0 : New : ComboBox property added to enable style selection form combobox
  //         : New : public function GetStyles: TStringList added
  // 1.2.3.0 : New : Can scan for and use style defined on form level too

type
  TAdvFormStyler = class;

  TThemeNotifierWindow = class(TWinControl)
  private
    FOnThemeChange: TNotifyEvent;
  protected
    procedure WndProc(var Msg: TMessage); override;
  published
    property OnThemeChange: TNotifyEvent read FOnThemeChange write FOnThemeChange;
  end;

  TAdvAppStyler = class(TComponent)
  public
    FForms: TList;
    FStyle: TTMSStyle;
    FAutoThemeAdapt: boolean;
    FNotifier: TThemeNotifierWindow;
    FOnChange: TNotifyEvent;
  private
    procedure SetStyle(const Value: TTMSStyle);
    function GetVersion: string;
    procedure SetVersion(const Value: string);
    procedure ThemeChanged(Sender: TObject);
    procedure SetAutoThemeAdapt(const Value: boolean);
  protected
    procedure Loaded; override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure Assign(Source: TPersistent); override;
    procedure RegisterFormStyler(AFormStyler: TAdvFormStyler);
    procedure UnRegisterFormStyler(AFormStyler: TAdvFormStyler);
    function GetVersionNr: integer;
  published
    property AutoThemeAdapt: boolean read FAutoThemeAdapt write SetAutoThemeAdapt default false;
    property Style: TTMSStyle read FStyle write SetStyle default tsCustom;
    property Version: string read GetVersion write SetVersion stored false;
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
  end;

  TApplyStyleEvent = procedure(Sender: TObject; AComponent: TComponent; var Allow:boolean) of object;

  TAdvFormStyler = class(TComponent)
  private
    FStyle: TTMSStyle;
    FAppStyle: TAdvAppStyler;
    FOnChange: TNotifyEvent;
    FAutoThemeAdapt: boolean;
    FNotifier: TThemeNotifierWindow;
    FOnApplyStyle: TApplyStyleEvent;
    {$IFDEF DELPHI6_LVL}
    FComboBox: TComboBox;
    {$ENDIF}
    procedure SetStyle(const Value: TTMSStyle);
    procedure SetAppStyle(const Value: TAdvAppStyler);
    function GetVersion: string;
    procedure SetVersion(const Value: string);
    procedure ThemeChanged(Sender: TObject);
    procedure SetAutoThemeAdapt(const Value: boolean);
    {$IFDEF DELPHI6_LVL}
    procedure SetComboBox(const Value: TComboBox);
    {$ENDIF}
  protected
    procedure Notification(AComponent: TComponent; AOperation: TOperation); override;
  public
    procedure Loaded; override;
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure Assign(Source: TPersistent); override;
    procedure ApplyStyle;
    procedure ApplyStyleToForm(Form: TCustomForm; AStyle:TTMSStyle);
    procedure ApplyStyleToFrame(Frame: TCustomFrame; AStyle:TTMSStyle);
    function GetVersionNr: integer;
    function GetStyles: TStringList;
    {$IFDEF DELPHI6_LVL}
    procedure HandleStyleSelect(Sender: TObject);
    {$ENDIF}
  published
    property AutoThemeAdapt: boolean read FAutoThemeAdapt write SetAutoThemeAdapt default false;
    property Style: TTMSStyle read FStyle write SetStyle default tsCustom;
    property AppStyle: TAdvAppStyler read FAppStyle write SetAppStyle;
    {$IFDEF DELPHI6_LVL}
    property ComboBox: TComboBox read FComboBox write SetComboBox;
    {$ENDIF}
    property OnApplyStyle: TApplyStyleEvent read FOnApplyStyle write FOnApplyStyle;
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
    property Version: string read GetVersion write SetVersion stored false;
  end;


procedure Register;


implementation

const
  // theme changed notifier
  WM_THEMECHANGED = $031A;

type
  XPColorScheme = (xpNone, xpBlue, xpGreen, xpGray);

{$IFNDEF TMSDOTNET}
var
  GetCurrentThemeName: function(pszThemeFileName: PWideChar;
    cchMaxNameChars: Integer;
    pszColorBuff: PWideChar;
    cchMaxColorChars: Integer;
    pszSizeBuff: PWideChar;
    cchMaxSizeChars: Integer): THandle cdecl stdcall;

  IsThemeActive: function: BOOL cdecl stdcall;
{$ENDIF}


function IsWinXP: Boolean;
var
  VerInfo: TOSVersioninfo;
begin
{$IFNDEF TMSDOTNET}
  VerInfo.dwOSVersionInfoSize := SizeOf(TOSVersionInfo);
{$ENDIF}
{$IFDEF TMSDOTNET}
  VerInfo.dwOSVersionInfoSize := Marshal.SizeOf(TypeOf(OSVersionInfo));
{$ENDIF}
  GetVersionEx(verinfo);
  Result := (verinfo.dwMajorVersion > 5) OR
    ((verinfo.dwMajorVersion = 5) AND (verinfo.dwMinorVersion >= 1));
end;

{$IFDEF TMSDOTNET}
function CurrentXPTheme: XPColorScheme;
var
  FileName, ColorScheme, SizeName: StringBuilder;
begin
  Result := xpNone;

  if IsWinXP then
  begin
    if IsThemeActive then
    begin
      FileName := StringBuilder.Create(255);
      SizeName := StringBuilder.Create(255);
      ColorScheme := StringBuilder.Create(255);
      GetCurrentThemeName(FileName, 255, ColorScheme, 255, SizeName, 255);
      if(ColorScheme.ToString = 'NormalColor') then
        Result := xpBlue
      else if (ColorScheme.ToString = 'HomeStead') then
        Result := xpGreen
      else if (ColorScheme.ToString = 'Metallic') then
        Result := xpGray
    end;
  end;
end;
{$ENDIF}

{$IFNDEF TMSDOTNET}
function CurrentXPTheme: XPColorScheme;
var
  FileName, ColorScheme, SizeName: WideString;
  hThemeLib: THandle;
begin
  hThemeLib := 0;
  Result := xpNone;

  if not IsWinXP then
    Exit;

  try
    hThemeLib := LoadLibrary('uxtheme.dll');

    if hThemeLib > 0 then
    begin
      IsThemeActive := GetProcAddress(hThemeLib,'IsThemeActive');

      if Assigned(IsThemeActive) then
        if IsThemeActive then
        begin
          GetCurrentThemeName := GetProcAddress(hThemeLib,'GetCurrentThemeName');
          if Assigned(GetCurrentThemeName) then
          begin
            SetLength(FileName, 255);
            SetLength(ColorScheme, 255);
            SetLength(SizeName, 255);
            GetCurrentThemeName(PWideChar(FileName), 255,
              PWideChar(ColorScheme), 255, PWideChar(SizeName), 255);
            if (PWideChar(ColorScheme) = 'NormalColor') then
              Result := xpBlue
            else if (PWideChar(ColorScheme) = 'HomeStead') then
              Result := xpGreen
            else if (PWideChar(ColorScheme) = 'Metallic') then
              Result := xpGray
            else
              Result := xpNone;
          end;
        end;
    end;
  finally
    if hThemeLib <> 0 then
      FreeLibrary(hThemeLib);
  end;
end;
{$ENDIF}

//------------------------------------------------------------------------------

{ TNotifierWindow }

procedure TThemeNotifierWindow.WndProc(var Msg: TMessage);
begin
  if Msg.Msg = WM_THEMECHANGED  then
  begin
    if Assigned(FOnThemeChange) then
    begin
      FOnThemeChange(Self);
    end;
  end;
  inherited;
end;


{ TAdvFormStyler }

procedure TAdvFormStyler.ApplyStyleToForm(Form: TCustomForm; AStyle: TTMSStyle);
var
  i: integer;
  tmsif: ITMSStyle;
  Allow: boolean;

begin
  if Form.GetInterface(ITMSStyle, tmsif) then
  begin
    Allow := true;
    if Assigned(FOnApplyStyle) then
      FOnApplyStyle(Self, Form, Allow);

    if Allow then
      tmsif.SetComponentStyle(AStyle);
  end;

  for i := 0 to Form.ComponentCount - 1 do
  begin
    if Form.Components[i].GetInterface(ITMSStyle, tmsif) then
    begin
      Allow := true;
      if Assigned(FOnApplyStyle) then
        FOnApplyStyle(Self, Form.Components[i], Allow);

      if Allow then
        tmsif.SetComponentStyle(AStyle);
    end;
  end;
end;

procedure TAdvFormStyler.ApplyStyleToFrame(Frame: TCustomFrame; AStyle: TTMSStyle);
var
  i: integer;
  tmsif: ITMSStyle;
  allow: boolean;
begin
  for i := 0 to Frame.ComponentCount - 1 do
  begin
    if Frame.Components[i].GetInterface(ITMSStyle, tmsif) then
    begin
      allow := true;
      if Assigned(FOnApplyStyle) then
        FOnApplyStyle(Self, Frame.Components[i],allow);

      if allow then
        tmsif.SetComponentStyle(AStyle);
    end;

    if Frame.Components[i] is TCustomFrame then
    begin
      ApplyStyleToFrame(TCustomFrame(Frame.Components[i]), AStyle);
    end;
  end;
end;

procedure TAdvFormStyler.Assign(Source: TPersistent);
begin
  if (Source is TAdvFormStyler) then
  begin
    AutoThemeAdapt := (Source as TAdvFormStyler).AutoThemeAdapt;
    Style := (Source as TAdvFormStyler).Style;
  end;
end;

constructor TAdvFormStyler.Create(AOwner: TComponent);
var
  ctrl: TComponent;
begin
  inherited;

  FStyle := tsCustom;

  if not (csDesigning in ComponentState) then
  begin
    FNotifier := TThemeNotifierWindow.Create(self);

    // find first owning TWinControl owner
    ctrl := AOwner;
    while Assigned(ctrl) and not (ctrl is TWinControl) do
    begin
      ctrl := ctrl.Owner;
    end;

    if Assigned(ctrl) then
      if (ctrl is TWinControl) then
        FNotifier.Parent := TWinControl(ctrl);

    FNotifier.OnThemeChange := ThemeChanged;
  end;
end;

destructor TAdvFormStyler.Destroy;
begin
  if Assigned(FAppStyle) and not (csDesigning in ComponentState) then
    FAppStyle.UnRegisterFormStyler(Self);

  inherited;
end;

function TAdvFormStyler.GetStyles: TStringList;
begin
  Result := TStringList.Create;
  Result.AddObject('Office 2003 Blue', TObject(tsOffice2003Blue));
  Result.AddObject('Office 2003 Silver', TObject(tsOffice2003Silver));
  Result.AddObject('Office 2003 Olive', TObject(tsOffice2003Olive));
  Result.AddObject('Office 2007 Blue', TObject(tsOffice2007Luna));
  Result.AddObject('Office 2007 Silver', TObject(tsOffice2007Silver));
  Result.AddObject('Office 2007 Black', TObject(tsOffice2007Obsidian));
  Result.AddObject('Windows XP', TObject(tsWindowsXP));
  Result.AddObject('Windows Vista', TObject(tsWindowsVista));
  Result.AddObject('Windows 7', TObject(tsWindows7));
  Result.AddObject('Terminal', TObject(tsTerminal));
end;

function TAdvFormStyler.GetVersion: string;
var
  vn: Integer;
begin
  vn := GetVersionNr;
  Result := IntToStr(Hi(Hiword(vn)))+'.'+IntToStr(Lo(Hiword(vn)))+'.'+IntToStr(Hi(Loword(vn)))+'.'+IntToStr(Lo(Loword(vn)));
end;

function TAdvFormStyler.GetVersionNr: integer;
begin
  Result := MakeLong(MakeWord(BLD_VER,REL_VER),MakeWord(MIN_VER,MAJ_VER));
end;

{$IFDEF DELPHI6_LVL}
procedure TAdvFormStyler.HandleStyleSelect(Sender: TObject);
begin
  with (Sender as TComboBox) do
  begin
    if ItemIndex >= 0 then
      self.Style := TTMSStyle(integer(Items.Objects[ItemIndex]));
  end;
end;
{$ENDIF}

procedure TAdvFormStyler.Loaded;
var
  AStyle: TTMSStyle;
begin
  inherited;

  if not (csDesigning in ComponentState) then
  begin
    if Assigned(FAppStyle) then
    begin
      Style := FAppStyle.Style;
    end
    else
    begin
      AStyle := Style;
      Style := tsCustom;
      Style := AStyle;
    end;
  end;

  if not (csDesigning in ComponentState) then
    ThemeChanged(Self);
end;

procedure TAdvFormStyler.Notification(AComponent: TComponent;
  AOperation: TOperation);
begin
  inherited;
  if (AOperation = opRemove) and (FAppStyle = AComponent) then
  begin
    FAppStyle := nil;
  end;

  if (AOperation = opInsert) then
  begin
  end;
end;

procedure TAdvFormStyler.SetAppStyle(const Value: TAdvAppStyler);
begin
  FAppStyle := Value;
  if not (csLoading in ComponentState) then
  begin
    if Assigned(FAppStyle) then
      Style := FAppStyle.Style;
  end;

  if Assigned(FAppStyle) and not (csDesigning in ComponentState) then
  begin
    FAppStyle.RegisterFormStyler(self);
  end;
end;

procedure TAdvFormStyler.SetAutoThemeAdapt(const Value: boolean);
begin
  FAutoThemeAdapt := value;
  ThemeChanged(self);
end;

{$IFDEF DELPHI6_LVL}
procedure TAdvFormStyler.SetComboBox(const Value: TComboBox);
var
  sl: TStringList;
  i: integer;
begin
  FComboBox := Value;
  if Assigned(FComboBox) then
  begin
    sl := GetStyles;
    FComboBox.Items.Assign(sl);
    sl.Free;
    FComboBox.OnSelect := HandleStyleSelect;
    FComboBox.Style := csDropDownList;

    for i := 0 to FComboBox.Items.Count - 1 do
    begin
      if FComboBox.Items.Objects[i] = TObject(self.Style) then
      begin
        FComboBox.ItemIndex := i;
        break;
      end;
    end;
  end;
end;
{$ENDIF}

procedure TAdvFormStyler.ApplyStyle;
var
  AForm: TCustomForm;
  AFrame: TCustomFrame;
begin
  // apply style to form
  if Owner is TCustomForm then
  begin
    AForm := Owner as TCustomForm;
    ApplyStyleToForm(AForm, FStyle);
  end;

  if Owner is TCustomFrame then
  begin
    AFrame := Owner as TCustomFrame;
    ApplyStyleToFrame(AFrame, FStyle);
  end;
end;


procedure TAdvFormStyler.SetStyle(const Value: TTMSStyle);
begin
  if (FStyle <> Value) then
  begin
    FStyle := Value;

    if (Value <> tsCustom) and not (csLoading in ComponentState) then
    begin
      ApplyStyle;
    end;
    
    if Assigned(OnChange) then
      OnChange(Self);
  end;
end;

procedure TAdvFormStyler.SetVersion(const Value: string);
begin

end;

procedure TAdvFormStyler.ThemeChanged(Sender: TObject);
var
  eTheme: XPColorScheme;
begin
  if not AutoThemeAdapt then
    Exit;

  eTheme := CurrentXPTheme();
  case eTheme of
    xpBlue: Style := tsOffice2003Blue;
    xpGreen: Style := tsOffice2003Olive;
    xpGray: Style := tsOffice2003Silver;
  else
    Style := tsOffice2003Classic;
  end;
end;


procedure Register;
begin
  RegisterComponents('TMS Menus',[TAdvFormStyler, TAdvAppStyler]);
end;


{ TAdvAppStyler }

procedure TAdvAppStyler.Assign(Source: TPersistent);
begin
  if (Source is TAdvAppStyler) then
  begin
    Style := (Source as TAdvAppStyler).Style;
    AutoThemeAdapt := (Source as TAdvAppStyler).AutoThemeAdapt;
  end;
end;

constructor TAdvAppStyler.Create(AOwner: TComponent);
begin
  inherited;
  FForms := TList.Create;
  FStyle := tsCustom;
  if not (csDesigning in ComponentState) then
  begin
    FNotifier := TThemeNotifierWindow.Create(self);
    FNotifier.Parent := Application.MainForm;
    FNotifier.OnThemeChange := ThemeChanged;
  end;
end;

destructor TAdvAppStyler.Destroy;
var
  i: integer;
begin
  for i := 0 to FForms.Count - 1 do
  begin
    if Assigned(FForms[i]) then
    begin
      TAdvFormStyler(FForms[i]).AppStyle := nil; //Unregister from the form to avoid AV
    end;
  end;

  FForms.Free;
  inherited;
end;

function TAdvAppStyler.GetVersion: string;
var
  vn: Integer;
begin
  vn := GetVersionNr;
  Result := IntToStr(Hi(Hiword(vn)))+'.'+IntToStr(Lo(Hiword(vn)))+'.'+IntToStr(Hi(Loword(vn)))+'.'+IntToStr(Lo(Loword(vn)));
end;

function TAdvAppStyler.GetVersionNr: integer;
begin
  Result := MakeLong(MakeWord(BLD_VER,REL_VER),MakeWord(MIN_VER,MAJ_VER));
end;

procedure TAdvAppStyler.Loaded;
begin
  inherited;
  if FAutoThemeAdapt then
  begin
    ThemeChanged(Self);
  end;
end;

procedure TAdvAppStyler.RegisterFormStyler(AFormStyler: TAdvFormStyler);
begin
  if FForms.IndexOf(Pointer(AFormStyler)) = -1 then
    FForms.Add(Pointer(AFormStyler));
end;

procedure TAdvAppStyler.SetAutoThemeAdapt(const Value: boolean);
begin
  FAutoThemeAdapt := Value;
  ThemeChanged(Self);
end;

procedure TAdvAppStyler.SetStyle(const Value: TTMSStyle);
var
  i: integer;
begin
  if (FStyle <> Value) then
  begin

    FStyle := Value;

    if not (csLoading in ComponentState) and not (csDesigning in ComponentState) then
    begin
      for i := 0 to FForms.Count - 1 do
      begin
        TAdvFormStyler(FForms[i]).Style := Value;
      end;
    end;
    if Assigned(FOnChange) then
      FOnChange(Self);
  end;
end;

procedure TAdvAppStyler.SetVersion(const Value: string);
begin

end;

procedure TAdvAppStyler.ThemeChanged(Sender: TObject);
var
  eTheme: XPColorScheme;
begin
  if not AutoThemeAdapt then
    Exit;

  eTheme := CurrentXPTheme();
  case eTheme of
    xpBlue: Style := tsOffice2003Blue;
    xpGreen: Style := tsOffice2003Olive;
    xpGray: Style := tsOffice2003Silver;
  else
    Style := tsOffice2003Classic;
  end;
end;

procedure TAdvAppStyler.UnRegisterFormStyler(AFormStyler: TAdvFormStyler);
var
  idx: integer;
begin
  idx := FForms.IndexOf(Pointer(AFormStyler));
  if idx <> -1 then
    FForms.Delete(idx);
end;

end.
