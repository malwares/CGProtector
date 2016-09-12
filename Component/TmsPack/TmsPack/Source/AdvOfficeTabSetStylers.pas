{***************************************************************************}
{ TAdvOfficeTabSetStyler component                                          }
{ for Delphi & C++Builder                                                   }
{                                                                           }
{ written by TMS Software                                                   }
{            copyright © 2006 - 2010                                        }
{            Email : info@tmssoftware.com                                   }
{            Web : http://www.tmssoftware.com                               }
{                                                                           }
{ The source code is given as is. The author is not responsible             }
{ for any possible damage done due to the use of this code.                 }
{ The component can be freely used in any application. The complete         }
{ source code remains property of the author and may not be distributed,    }
{ published, given or sold in any form as such. No parts of the source      }
{ code can be included in any other component or application without        }
{ written authorization of the author.                                      }
{***************************************************************************}

unit AdvOfficeTabSetStylers;

interface

uses
  AdvOfficeTabSet, Graphics, Windows, Forms, Messages, Controls, Classes, SysUtils,
  AdvStyleIF, AdvGlowButton;

type
  TOfficeTabSetFantasyStyle = (tsArctic, tsAquaBlue, tsChocolate, tsMacOS, tsSilverFox,
    tsSoftSand, tsTerminalGreen, tsTextured, tsWindowsClassic, tsUser);

  TOfficeTabSetStyle = (tsOffice2003Blue, tsOffice2003Silver, tsOffice2003Olive, tsOffice2003Classic, tsOffice2007Luna, tsOffice2007Obsidian, tsWindowsXP, tsWhidbey, tsCustom,tsOffice2007Silver, tsWindowsVista, tsWindows7, tsTerminal, tsOffice2010Blue, tsOffice2010Silver, tsOffice2010Black);

  TNotifierWindow = class(TWinControl)
  private
    FOnThemeChange: TNotifyEvent;
  protected
    procedure WndProc(var Msg: TMessage); override;
  published
    property OnThemeChange: TNotifyEvent read FOnThemeChange write FOnThemeChange;
  end;

  TAdvOfficeTabSetOfficeStyler = class(TCustomAdvOfficeTabSetStyler, ITMSStyle)
  private
    FNotifierWnd: TNotifierWindow;
    FOfficeTabSetStyle: TOfficeTabSetStyle;
  protected
    procedure SetOfficeTabSetStyle(const Value: TOfficeTabSetStyle);
    procedure ThemeChanged(Sender: TObject);
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure Loaded; override;
    procedure SetComponentStyle(AStyle: TTMSStyle);
  published
    property AutoThemeAdapt;
    property ButtonBorderColor;
    property GlowButtonAppearance;
    property Style: TOfficeTabSetStyle read FOfficeTabSetStyle write SetOfficeTabSetStyle default tsOffice2003Blue;
    property TabAppearance;
  end;

  TAdvOfficeTabSetFantasyStyler = class(TCustomAdvOfficeTabSetStyler)
  private
    FOfficeTabSetStyle: TOfficeTabSetFantasyStyle;
  protected
    procedure SetOfficeTabSetStyle(const Value: TOfficeTabSetFantasyStyle);
  public
    constructor Create(AOwner: TComponent); override;
  published
    property ButtonBorderColor;
    property GlowButtonAppearance;
    property Style: TOfficeTabSetFantasyStyle read FOfficeTabSetStyle write SetOfficeTabSetStyle default tsChocolate;
    property TabAppearance;
  end;



implementation


const
  // theme changed notifier
  {$IFDEF DELPHI2007_LVL}
  {$EXTERNALSYM WM_THEMECHANGED}
  {$ENDIF}
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

procedure TNotifierWindow.WndProc(var Msg: TMessage);
begin
  if Msg.Msg = WM_THEMECHANGED  then
  begin
    if Assigned(FOnThemeChange) then
      FOnThemeChange(Self);
  end;
  inherited;
end;


function HTMLToRgb(color: tcolor): tcolor;
var
  r,g,b: integer;
begin
  r := (Color and $0000FF);
  g := (Color and $00FF00);
  b := (Color and $FF0000) shr 16;
  Result := b or g or (r shl 16);
end;

//------------------------------------------------------------------------------

constructor TAdvOfficeTabSetOfficeStyler.Create(AOwner: TComponent);
var
  ctrl: TComponent;
begin
  inherited;
  FNotifierWnd := TNotifierWindow.Create(Self);

  // find first owning TWinControl owner
  ctrl := AOwner;
  while Assigned(ctrl) and not (ctrl is TWinControl) do
  begin
    ctrl := ctrl.Owner;
  end;

  if Assigned(ctrl) then
    if (ctrl is TWinControl) then
      FNotifierWnd.Parent := TWinControl(ctrl);
  
  FNotifierWnd.OnThemeChange := ThemeChanged;

  Style := tsWindowsXP;
  Style := tsOffice2003Blue;
end;

destructor TAdvOfficeTabSetOfficeStyler.Destroy;
begin
  //FNotifierWnd.Free;
  inherited;
end;

procedure TAdvOfficeTabSetOfficeStyler.Loaded;
begin
  inherited;
  if not (csDesigning in ComponentState) then
    ThemeChanged(Self);
end;

procedure TAdvOfficeTabSetOfficeStyler.ThemeChanged(Sender: TObject);
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
    Style := tsWindowsXP;
  end;
end;

procedure TAdvOfficeTabSetOfficeStyler.SetComponentStyle(AStyle: TTMSStyle);
begin
  Style := TOfficeTabSetStyle(AStyle);
end;

procedure TAdvOfficeTabSetOfficeStyler.SetOfficeTabSetStyle(
  const Value: TOfficeTabSetStyle);
begin
  if FOfficeTabSetStyle <> Value then
  begin
    FOfficeTabSetStyle := Value;
    BlendFactor := 50;
    case FOfficeTabSetStyle of
    tsWindowsXP:
      begin
        RoundEdges := false;

        { TabAppearance }

        TabAppearance.BackGround.Color := clBtnFace;
        TabAppearance.BackGround.ColorTo := clBtnFace;
        TabAppearance.BorderColor := clNone;
        TabAppearance.BorderColorDisabled := clNone;
        TabAppearance.BorderColorHot := clHighlight;
        TabAppearance.BorderColorSelected := clBlack;
        TabAppearance.BorderColorSelectedHot := clHighlight;

        TabAppearance.TextColor := clBlack;
        TabAppearance.TextColorHot := clBlack;
        TabAppearance.TextColorSelected := clBlack;
        TabAppearance.TextColorDisabled := clGray;

        TabAppearance.ColorSelected := $EFD3C6;
        TabAppearance.ColorSelectedTo := clBtnFace;
        TabAppearance.ColorMirrorSelected := clBtnFace;
        TabAppearance.ColorMirrorSelectedTo := clBtnFace;

        TabAppearance.ColorDisabled := clWhite;
        TabAppearance.ColorDisabledTo := clBtnFace;
        TabAppearance.ColorMirrorDisabled := clWhite;
        TabAppearance.ColorMirrorDisabledTo := clBtnFace;

        TabAppearance.ColorHot := $EFD3C6;
        TabAppearance.ColorHotTo := $EFD3C6;
        TabAppearance.ColorMirrorHot := $EFD3C6;
        TabAppearance.ColorMirrorHotTo := $EFD3C6;

        TabAppearance.Gradient := ggVertical;
        TabAppearance.GradientDisabled := ggVertical;
        TabAppearance.GradientHot := ggVertical;
        TabAppearance.GradientMirrorDisabled := ggVertical;
        TabAppearance.GradientMirrorHot := ggVertical;
        TabAppearance.GradientMirrorSelected := ggVertical;
        TabAppearance.GradientSelected := ggVertical;

        TabAppearance.ShadowColor := RGB(158, 169, 191);
        TabAppearance.HighLightColorSelected := $00FFFABF;
        //TabAppearance.HighLightColorSelected := $0063CCF8;
        TabAppearance.HighLightColorSelectedHot := $00BDFFFF;
        TabAppearance.HighLightColorDown := $00FFFBD0;
        TabAppearance.HighLightColorHot := $00FDF4ED;

        { GlowButtonAppearance}
        GlowButtonAppearance.Color := clWhite;
        GlowButtonAppearance.ColorTo := HTMLToRgb($DCD8B9);
        GlowButtonAppearance.ColorMirror := HTMLToRgb($DCD8B9);
        GlowButtonAppearance.ColorMirrorTo := HTMLToRgb($DCD8B9);
        GlowButtonAppearance.BorderColor := HTMLToRgb($DCD8B9);
        GlowButtonAppearance.Gradient := ggVertical;
        GlowButtonAppearance.GradientMirror := ggVertical;

        GlowButtonAppearance.ColorHot := $EFD3C6;
        GlowButtonAppearance.ColorHotTo := $EFD3C6;               
        GlowButtonAppearance.ColorMirrorHot := $EFD3C6;
        GlowButtonAppearance.ColorMirrorHotTo := $EFD3C6;
        GlowButtonAppearance.BorderColorHot := clHighlight;
        GlowButtonAppearance.GradientHot := ggVertical;
        GlowButtonAppearance.GradientMirrorHot := ggVertical;

        GlowButtonAppearance.ColorDown := $B59284;
        GlowButtonAppearance.ColorDownTo := $B59284;
        GlowButtonAppearance.ColorMirrorDown := $B59284;
        GlowButtonAppearance.ColorMirrorDownTo := $B59284;
        GlowButtonAppearance.BorderColorDown := clHighlight;
        GlowButtonAppearance.GradientDown := ggVertical;
        GlowButtonAppearance.GradientMirrorDown := ggVertical;


        GlowButtonAppearance.ColorChecked := HTMLToRgb($DCD8B9);
        GlowButtonAppearance.ColorCheckedTo := HTMLToRgb($DCD8B9);
        GlowButtonAppearance.ColorMirrorChecked := HTMLToRgb($DCD8B9);
        GlowButtonAppearance.ColorMirrorCheckedTo := HTMLToRgb($DCD8B9);
        GlowButtonAppearance.BorderColorChecked := clBlack;
        GlowButtonAppearance.GradientChecked := ggVertical;
        GlowButtonAppearance.GradientMirrorChecked := ggVertical;
      end;
    tsOffice2003Blue:
      begin
        RoundEdges:= true;
        { TabAppearance }

        TabAppearance.BackGround.Color := $E4AE88;
        TabAppearance.BackGround.ColorTo := HTMLToRgb($C4DAFA);
        TabAppearance.BorderColor := clNone;
        TabAppearance.BorderColorDisabled := clNone;
        TabAppearance.BorderColorHot := clHighlight;
        TabAppearance.BorderColorSelected := $E3B28D;
        TabAppearance.BorderColorSelectedHot := $60CCF9;

        TabAppearance.TextColor := clBlack;
        TabAppearance.TextColorHot := clBlack;
        TabAppearance.TextColorSelected := clBlack;
        TabAppearance.TextColorDisabled := clGray;

        TabAppearance.ColorSelected := $FEF6F0;
        TabAppearance.ColorSelectedTo := $FAF1E9;
        TabAppearance.ColorMirrorSelected := $FAF1E9;
        TabAppearance.ColorMirrorSelectedTo := $F6EAE0;

        TabAppearance.ColorDisabled := clWhite;
        TabAppearance.ColorDisabledTo := clSilver;
        TabAppearance.ColorMirrorDisabled := clWhite;
        TabAppearance.ColorMirrorDisabledTo := clSilver;

        TabAppearance.ColorHot := $CCF4FF;
        TabAppearance.ColorHotTo := $CCF4FF;
        TabAppearance.ColorMirrorHot := $CCF4FF;
        TabAppearance.ColorMirrorHotTo := $91D0FF;

        TabAppearance.Gradient := ggVertical;
        TabAppearance.GradientDisabled := ggVertical;
        TabAppearance.GradientHot := ggVertical;
        TabAppearance.GradientMirrorDisabled := ggVertical;
        TabAppearance.GradientMirrorHot := ggVertical;
        TabAppearance.GradientMirrorSelected := ggVertical;
        TabAppearance.GradientSelected := ggVertical;

        TabAppearance.ShadowColor := RGB(164, 191, 235);
        TabAppearance.HighLightColorSelected := $00FFFABF;
        //TabAppearance.HighLightColorSelected := $0063CCF8;
        TabAppearance.HighLightColorSelectedHot := $00BDFFFF;
        TabAppearance.HighLightColorDown := $00FFFBD0;
        TabAppearance.HighLightColorHot := $00FDF4ED;

        { GlowButtonAppearance }
        GlowButtonAppearance.Color := $EEDBC8;
        GlowButtonAppearance.ColorTo := $F6DDC9;
        GlowButtonAppearance.ColorMirror := $EDD4C0;
        GlowButtonAppearance.ColorMirrorTo := $F7E1D0;
        GlowButtonAppearance.BorderColor := $E0B99B;
        GlowButtonAppearance.Gradient := ggVertical;
        GlowButtonAppearance.GradientMirror := ggVertical;

        GlowButtonAppearance.ColorHot := $EBFDFF;
        GlowButtonAppearance.ColorHotTo := $ACECFF;
        GlowButtonAppearance.ColorMirrorHot := $59DAFF;
        GlowButtonAppearance.ColorMirrorHotTo := $A4E9FF;
        GlowButtonAppearance.BorderColorHot := $99CEDB;
        GlowButtonAppearance.GradientHot := ggVertical;
        GlowButtonAppearance.GradientMirrorHot := ggVertical;

        GlowButtonAppearance.ColorDown := $76AFF1;
        GlowButtonAppearance.ColorDownTo := $4190F3;
        GlowButtonAppearance.ColorMirrorDown := $0E72F1;
        GlowButtonAppearance.ColorMirrorDownTo := $4C9FFD;
        GlowButtonAppearance.BorderColorDown := $45667B;
        GlowButtonAppearance.GradientDown := ggVertical;
        GlowButtonAppearance.GradientMirrorDown := ggVertical;

        GlowButtonAppearance.ColorChecked := $B5DBFB;
        GlowButtonAppearance.ColorCheckedTo := $78C7FE;
        GlowButtonAppearance.ColorMirrorChecked := $9FEBFD;
        GlowButtonAppearance.ColorMirrorCheckedTo := $56B4FE;
        GlowButtonAppearance.GradientChecked := ggVertical;
        GlowButtonAppearance.GradientMirrorChecked := ggVertical;

      end;
    tsOffice2003Olive:
      begin
        RoundEdges:= true;
        { TabAppearance }

        TabAppearance.BackGround.Color := $8CC0B1;
        TabAppearance.BackGround.ColorTo := $CFF0EA;
        TabAppearance.BorderColor := clNone;
        TabAppearance.BorderColorDisabled := clNone;
        TabAppearance.BorderColorHot := clBlack;
        TabAppearance.BorderColorSelected := clBlack;
        TabAppearance.BorderColorSelectedHot := $60CCF9;

        TabAppearance.TextColor := clBlack;
        TabAppearance.TextColorHot := clBlack;
        TabAppearance.TextColorSelected := clBlack;
        TabAppearance.TextColorDisabled := clGray;

        TabAppearance.ColorSelected := $8CC0B1;
        TabAppearance.ColorSelectedTo := $CFF0EA;
        TabAppearance.ColorMirrorSelected := $CFF0EA;
        TabAppearance.ColorMirrorSelectedTo := $CFF0EA;

        TabAppearance.ColorDisabled := clWhite;
        TabAppearance.ColorDisabledTo := clSilver;
        TabAppearance.ColorMirrorDisabled := clWhite;
        TabAppearance.ColorMirrorDisabledTo := clSilver;

        TabAppearance.ColorHot := $CCF4FF;
        TabAppearance.ColorHotTo := $CCF4FF;
        TabAppearance.ColorMirrorHot := $CCF4FF;
        TabAppearance.ColorMirrorHotTo := $91D0FF;

        TabAppearance.Gradient := ggVertical;
        TabAppearance.GradientDisabled := ggVertical;
        TabAppearance.GradientHot := ggVertical;
        TabAppearance.GradientMirrorDisabled := ggVertical;
        TabAppearance.GradientMirrorHot := ggVertical;
        TabAppearance.GradientMirrorSelected := ggVertical;
        TabAppearance.GradientSelected := ggVertical;

        TabAppearance.ShadowColor := RGB(130, 140, 100);
        TabAppearance.HighLightColorSelected := $00FFFABF;
        //TabAppearance.HighLightColorSelected := $0063CCF8;
        TabAppearance.HighLightColorSelectedHot := $00BDFFFF;
        TabAppearance.HighLightColorDown := $00FFFBD0;
        TabAppearance.HighLightColorHot := $00FDF4ED;

        { GlowButtonAppearance }
        GlowButtonAppearance.Color := $CFF0EA;
        GlowButtonAppearance.ColorTo := $CFF0EA;
        GlowButtonAppearance.ColorMirror := $CFF0EA;
        GlowButtonAppearance.ColorMirrorTo := $8CC0B1;
        GlowButtonAppearance.BorderColor := $8CC0B1;
        GlowButtonAppearance.Gradient := ggVertical;
        GlowButtonAppearance.GradientMirror := ggVertical;

        GlowButtonAppearance.ColorHot := $CCF4FF;
        GlowButtonAppearance.ColorHotTo := $CCF4FF;
        GlowButtonAppearance.ColorMirrorHot := $CCF4FF;
        GlowButtonAppearance.ColorMirrorHotTo := $91D0FF;
        GlowButtonAppearance.BorderColorHot := $99CEDB;
        GlowButtonAppearance.GradientHot := ggVertical;
        GlowButtonAppearance.GradientMirrorHot := ggVertical;

        GlowButtonAppearance.ColorDown := $4E91FE;
        GlowButtonAppearance.ColorDownTo := $4E91FE;
        GlowButtonAppearance.ColorMirrorDown := $4E91FE;
        GlowButtonAppearance.ColorMirrorDownTo := $91D3FF;
        GlowButtonAppearance.BorderColorDown := $45667B;
        GlowButtonAppearance.GradientDown := ggVertical;
        GlowButtonAppearance.GradientMirrorDown := ggVertical;

        GlowButtonAppearance.ColorChecked := $4E91FE;
        GlowButtonAppearance.ColorCheckedTo := $4E91FE;
        GlowButtonAppearance.ColorMirrorChecked := $4E91FE;
        GlowButtonAppearance.ColorMirrorCheckedTo := $91D3FF;
        GlowButtonAppearance.GradientChecked := ggVertical;
        GlowButtonAppearance.GradientMirrorChecked := ggVertical;

      end;
    tsOffice2003Silver:
      begin
        RoundEdges:= true;
        { TabAppearance }

        TabAppearance.BackGround.Color := $00E6D8D8;
        TabAppearance.BackGround.ColorTo := $00E6D8D8;
        TabAppearance.BorderColor := clNone;
        TabAppearance.BorderColorDisabled := clNone;
        TabAppearance.BorderColorHot := $927476;
        TabAppearance.BorderColorSelected := $927476;
        TabAppearance.BorderColorSelectedHot := $60CCF9;

        TabAppearance.TextColor := clBlack;
        TabAppearance.TextColorHot := clBlack;
        TabAppearance.TextColorSelected := clBlack;
        TabAppearance.TextColorDisabled := clGray;

        TabAppearance.ColorSelected := $927476;
        TabAppearance.ColorSelectedTo := $00F7F3F3;
        TabAppearance.ColorMirrorSelected := $00E6D8D8;
        TabAppearance.ColorMirrorSelectedTo := $00F7F3F3;

        TabAppearance.ColorDisabled := clWhite;
        TabAppearance.ColorDisabledTo := clSilver;
        TabAppearance.ColorMirrorDisabled := clWhite;
        TabAppearance.ColorMirrorDisabledTo := clSilver;

        TabAppearance.ColorHot := $CCF4FF;
        TabAppearance.ColorHotTo := $CCF4FF;
        TabAppearance.ColorMirrorHot := $CCF4FF;
        TabAppearance.ColorMirrorHotTo := $91D0FF;

        TabAppearance.Gradient := ggVertical;
        TabAppearance.GradientDisabled := ggVertical;
        TabAppearance.GradientHot := ggVertical;
        TabAppearance.GradientMirrorDisabled := ggVertical;
        TabAppearance.GradientMirrorHot := ggVertical;
        TabAppearance.GradientMirrorSelected := ggVertical;
        TabAppearance.GradientSelected := ggVertical;

        TabAppearance.ShadowColor := RGB(167, 173, 188);
        TabAppearance.HighLightColorSelected := RGB(234, 234, 240);
        //TabAppearance.HighLightColorSelected := $0063CCF8;
        TabAppearance.HighLightColorSelectedHot := $00BDFFFF;
        TabAppearance.HighLightColorDown := $00FFFBD0;
        TabAppearance.HighLightColorHot := $00F7F4F3;

        { GlowButtonAppearance }
        GlowButtonAppearance.Color := $EDD4C0;
        GlowButtonAppearance.ColorTo := $00E6D8D8;
        GlowButtonAppearance.ColorMirror := $EDD4C0;
        GlowButtonAppearance.ColorMirrorTo := $C8B2B3;
        GlowButtonAppearance.BorderColor := $927476;
        GlowButtonAppearance.Gradient := ggVertical;
        GlowButtonAppearance.GradientMirror := ggVertical;

        GlowButtonAppearance.ColorHot := $CCF4FF;
        GlowButtonAppearance.ColorHotTo := $CCF4FF;
        GlowButtonAppearance.ColorMirrorHot := $CCF4FF;
        GlowButtonAppearance.ColorMirrorHotTo := $91D0FF;
        GlowButtonAppearance.BorderColorHot := $99CEDB;
        GlowButtonAppearance.GradientHot := ggVertical;
        GlowButtonAppearance.GradientMirrorHot := ggVertical;

        GlowButtonAppearance.ColorDown := $4E91FE;
        GlowButtonAppearance.ColorDownTo := $4E91FE;
        GlowButtonAppearance.ColorMirrorDown := $4E91FE;
        GlowButtonAppearance.ColorMirrorDownTo := $91D3FF;
        GlowButtonAppearance.BorderColorDown := $45667B;
        GlowButtonAppearance.GradientDown := ggVertical;
        GlowButtonAppearance.GradientMirrorDown := ggVertical;


        GlowButtonAppearance.ColorChecked := $4E91FE;
        GlowButtonAppearance.ColorCheckedTo := $4E91FE;
        GlowButtonAppearance.ColorMirrorChecked := $4E91FE;
        GlowButtonAppearance.ColorMirrorCheckedTo := $91D3FF;
        GlowButtonAppearance.GradientChecked := ggVertical;
        GlowButtonAppearance.GradientMirrorChecked := ggVertical;

      end;
    tsOffice2007Luna:
      begin
        { TabAppearance }

        TabAppearance.BackGround.Color := $FFDBBF;
        TabAppearance.BackGround.ColorTo := clNone;
        TabAppearance.BorderColor := clNone;
        TabAppearance.BorderColorDisabled := clNone;
        TabAppearance.BorderColorHot := $EABC99;
        TabAppearance.BorderColorSelected := $E3B28D;
        TabAppearance.BorderColorSelectedHot := $60CCF9;

        TabAppearance.TextColor := $8B4215;
        TabAppearance.TextColorHot := $8B4215;
        TabAppearance.TextColorSelected := $8B4215;
        TabAppearance.TextColorDisabled := clGray;

        TabAppearance.ColorSelected := $FEF6F0;
        TabAppearance.ColorSelectedTo := $FAF1E9;
        TabAppearance.ColorMirrorSelected := $FAF1E9;
        TabAppearance.ColorMirrorSelectedTo := $F6EAE0;

        TabAppearance.ColorDisabled := clWhite;
        TabAppearance.ColorDisabledTo := clSilver;
        TabAppearance.ColorMirrorDisabled := clWhite;
        TabAppearance.ColorMirrorDisabledTo := clSilver;

        TabAppearance.ColorHot := $DDE5E4;
        TabAppearance.ColorHotTo := $FFDEC5;
        TabAppearance.ColorMirrorHot := $D5DFDD;
        TabAppearance.ColorMirrorHotTo := $A3D3E1;

        TabAppearance.Gradient := ggVertical;
        TabAppearance.GradientDisabled := ggVertical;
        TabAppearance.GradientHot := ggRadial;
        TabAppearance.GradientMirrorDisabled := ggVertical;
        TabAppearance.GradientMirrorHot := ggVertical;
        TabAppearance.GradientMirrorSelected := ggVertical;
        TabAppearance.GradientSelected := ggVertical;

        TabAppearance.ShadowColor := $00E8C7AE;
        TabAppearance.HighLightColorSelected := $00FFFABF;
        //TabAppearance.HighLightColorSelected := $0063CCF8;
        TabAppearance.HighLightColorSelectedHot := $00BDFFFF;
        TabAppearance.HighLightColorDown := $00FFFBD0;
        TabAppearance.HighLightColorHot := $00FDF4ED;

        RoundEdges := True;
        { GlowButtonAppearance }
        GlowButtonAppearance.Color := $EEDBC8;
        GlowButtonAppearance.ColorTo := $F6DDC9;
        GlowButtonAppearance.ColorMirror := $EDD4C0;
        GlowButtonAppearance.ColorMirrorTo := $F7E1D0;
        GlowButtonAppearance.BorderColor := $E0B99B;
        GlowButtonAppearance.Gradient := ggVertical;
        GlowButtonAppearance.GradientMirror := ggVertical;

        GlowButtonAppearance.ColorHot := $EBFDFF;
        GlowButtonAppearance.ColorHotTo := $ACECFF;
        GlowButtonAppearance.ColorMirrorHot := $59DAFF;
        GlowButtonAppearance.ColorMirrorHotTo := $A4E9FF;
        GlowButtonAppearance.BorderColorHot := $99CEDB;
        GlowButtonAppearance.GradientHot := ggVertical;
        GlowButtonAppearance.GradientMirrorHot := ggVertical;

        GlowButtonAppearance.ColorDown := $76AFF1;
        GlowButtonAppearance.ColorDownTo := $4190F3;
        GlowButtonAppearance.ColorMirrorDown := $0E72F1;
        GlowButtonAppearance.ColorMirrorDownTo := $4C9FFD;
        GlowButtonAppearance.BorderColorDown := $45667B;
        GlowButtonAppearance.GradientDown := ggVertical;
        GlowButtonAppearance.GradientMirrorDown := ggVertical;

        GlowButtonAppearance.ColorChecked := $B5DBFB;
        GlowButtonAppearance.ColorCheckedTo := $78C7FE;
        GlowButtonAppearance.ColorMirrorChecked := $9FEBFD;
        GlowButtonAppearance.ColorMirrorCheckedTo := $56B4FE;
        GlowButtonAppearance.BorderColorChecked := $45667B;
        GlowButtonAppearance.GradientChecked := ggVertical;
        GlowButtonAppearance.GradientMirrorChecked := ggVertical;

      end;

    tsOffice2007Obsidian:
      begin
        { TabAppearance }

        TabAppearance.BackGround.Color := HTMLToRgb($535353);
        TabAppearance.BackGround.ColorTo := HTMLToRgb($3A3A3A);
        TabAppearance.BackGround.Direction := gdVertical;

        TabAppearance.BorderColor := clNone;
        TabAppearance.BorderColorDisabled := clNone;
        TabAppearance.BorderColorHot := HTMLToRgb($9E9C96);
        TabAppearance.BorderColorSelected := $E3B28D;
        TabAppearance.BorderColorSelectedHot := $60CCF9;

        TabAppearance.TextColor := clWhite;
        TabAppearance.TextColorHot := clWhite;
        TabAppearance.TextColorSelected := clBlack;
        TabAppearance.TextColorDisabled := clGray;

        TabAppearance.ColorSelected := HTMLToRgb($EDEEEF);
        TabAppearance.ColorSelectedTo := HTMLToRgb($EDEEEF);
        TabAppearance.ColorMirrorSelected := HTMLToRgb($CED2D2);
        TabAppearance.ColorMirrorSelectedTo := HTMLToRgb($CED2D2);

        TabAppearance.ColorDisabled := clWhite;
        TabAppearance.ColorDisabledTo := clSilver;
        TabAppearance.ColorMirrorDisabled := clWhite;
        TabAppearance.ColorMirrorDisabledTo := clSilver;

        TabAppearance.ColorHot := HTMLToRgb($78705B);
        TabAppearance.ColorHotTo := HTMLToRgb($979695);
        TabAppearance.ColorMirrorHot := HTMLToRgb($5F5743);
        TabAppearance.ColorMirrorHotTo := HTMLToRgb($EDAE18);

        TabAppearance.Gradient := ggVertical;
        TabAppearance.GradientDisabled := ggVertical;
        TabAppearance.GradientHot := ggRadial;
        TabAppearance.GradientMirrorDisabled := ggVertical;
        TabAppearance.GradientMirrorHot := ggRadial;
        TabAppearance.GradientMirrorSelected := ggVertical;
        TabAppearance.GradientSelected := ggVertical;

        TabAppearance.ShadowColor := clBlack;
        TabAppearance.HighLightColorSelected := $00959899; //$00FFFABF;
        //TabAppearance.HighLightColorSelected := $0063CCF8;
        TabAppearance.HighLightColorSelectedHot := $00BDFFFF;
        TabAppearance.HighLightColorDown := $00FFFBD0;
        TabAppearance.HighLightColorHot := $00959899;

        RoundEdges := True;

        { GlowButtonAppearance }
        GlowButtonAppearance.Color := HTMLToRgb($D6DEDF);
        GlowButtonAppearance.ColorTo := HTMLToRgb($DBE2E4);
        GlowButtonAppearance.ColorMirror := HTMLToRgb($CED5D7);
        GlowButtonAppearance.ColorMirrorTo := HTMLToRgb($E0E5E7);
        GlowButtonAppearance.BorderColor := HTMLToRgb($B2BCC0);
        GlowButtonAppearance.Gradient := ggVertical;
        GlowButtonAppearance.GradientMirror := ggVertical;

        GlowButtonAppearance.ColorHot := $EBFDFF;
        GlowButtonAppearance.ColorHotTo := $ACECFF;
        GlowButtonAppearance.ColorMirrorHot := $59DAFF;
        GlowButtonAppearance.ColorMirrorHotTo := $A4E9FF;
        GlowButtonAppearance.BorderColorHot := $99CEDB;
        GlowButtonAppearance.GradientHot := ggVertical;
        GlowButtonAppearance.GradientMirrorHot := ggVertical;

        GlowButtonAppearance.ColorDown := $76AFF1;
        GlowButtonAppearance.ColorDownTo := $4190F3;
        GlowButtonAppearance.ColorMirrorDown := $0E72F1;
        GlowButtonAppearance.ColorMirrorDownTo := $4C9FFD;
        GlowButtonAppearance.BorderColorDown := $45667B;
        GlowButtonAppearance.GradientDown := ggVertical;
        GlowButtonAppearance.GradientMirrorDown := ggVertical;

        GlowButtonAppearance.ColorChecked := $B5DBFB;
        GlowButtonAppearance.ColorCheckedTo := $78C7FE;
        GlowButtonAppearance.ColorMirrorChecked := $9FEBFD;
        GlowButtonAppearance.ColorMirrorCheckedTo := $56B4FE;
        GlowButtonAppearance.BorderColorChecked := $45667B;
        GlowButtonAppearance.GradientChecked := ggVertical;
        GlowButtonAppearance.GradientMirrorChecked := ggVertical;

      end;
    tsOffice2007Silver:
      begin
        TabAppearance.BackGround.Color := $DDD4D0;
        TabAppearance.BackGround.ColorTo := clNone;
        TabAppearance.BorderColor := clNone;
        TabAppearance.BorderColorDisabled := clNone;
        TabAppearance.BorderColorHot := $C1BEBD;
        TabAppearance.BorderColorSelected := $FFFAC1;
        TabAppearance.BorderColorSelectedHot := $60CCF9;

        TabAppearance.TextColor := $5C534C;
        TabAppearance.TextColorHot := $5C534C;
        TabAppearance.TextColorSelected := $5C534C;
        TabAppearance.TextColorDisabled := clGray;

        TabAppearance.ColorSelected := $F6F6F6;
        TabAppearance.ColorSelectedTo := $F6F6F6;
        TabAppearance.ColorMirrorSelected := $F6F6F6;
        TabAppearance.ColorMirrorSelectedTo := $EFE6E1;

        TabAppearance.ColorDisabled := clWhite;
        TabAppearance.ColorDisabledTo := clSilver;
        TabAppearance.ColorMirrorDisabled := clWhite;
        TabAppearance.ColorMirrorDisabledTo := clSilver;

        TabAppearance.ColorHot := $DDE5E4;
        TabAppearance.ColorHotTo := $FFDEC5;
        TabAppearance.ColorMirrorHot := $D5DFDD;
        TabAppearance.ColorMirrorHotTo := $A3D3E1;

        TabAppearance.Gradient := ggVertical;
        TabAppearance.GradientDisabled := ggVertical;
        TabAppearance.GradientHot := ggRadial;
        TabAppearance.GradientMirrorDisabled := ggVertical;
        TabAppearance.GradientMirrorHot := ggVertical;
        TabAppearance.GradientMirrorSelected := ggVertical;
        TabAppearance.GradientSelected := ggVertical;

        TabAppearance.ShadowColor := $00D6CDC9;
        TabAppearance.HighLightColorSelected := $00FFFABF;
        //TabAppearance.HighLightColorSelected := $0063CCF8;
        TabAppearance.HighLightColorSelectedHot := $00BDFFFF;
        TabAppearance.HighLightColorDown := $00FFFBD0;
        TabAppearance.HighLightColorHot := $00F7F4F3;

        RoundEdges := True;
        
        GlowButtonAppearance.Color := $F3F3F1;
        GlowButtonAppearance.ColorTo := $F2F2F0;
        GlowButtonAppearance.ColorMirror := $F8F7F6;
        GlowButtonAppearance.ColorMirrorTo := $EEEAE7;
        GlowButtonAppearance.BorderColor := $CAC7C6;
        GlowButtonAppearance.Gradient := ggVertical;
        GlowButtonAppearance.GradientMirror := ggVertical;

        GlowButtonAppearance.ColorHot := $EBFDFF;
        GlowButtonAppearance.ColorHotTo := $ACECFF;
        GlowButtonAppearance.ColorMirrorHot := $59DAFF;
        GlowButtonAppearance.ColorMirrorHotTo := $A4E9FF;
        GlowButtonAppearance.BorderColorHot := $99CEDB;
        GlowButtonAppearance.GradientHot := ggVertical;
        GlowButtonAppearance.GradientMirrorHot := ggVertical;

        GlowButtonAppearance.ColorDown := $76AFF1;
        GlowButtonAppearance.ColorDownTo := $4190F3;
        GlowButtonAppearance.ColorMirrorDown := $0E72F1;
        GlowButtonAppearance.ColorMirrorDownTo := $4C9FFD;
        GlowButtonAppearance.BorderColorDown := $45667B;
        GlowButtonAppearance.GradientDown := ggVertical;
        GlowButtonAppearance.GradientMirrorDown := ggVertical;

        GlowButtonAppearance.ColorChecked := $B5DBFB;
        GlowButtonAppearance.ColorCheckedTo := $78C7FE;
        GlowButtonAppearance.ColorMirrorChecked := $9FEBFD;
        GlowButtonAppearance.ColorMirrorCheckedTo := $56B4FE;
        GlowButtonAppearance.BorderColorChecked := $45667B;
        GlowButtonAppearance.GradientChecked := ggVertical;
        GlowButtonAppearance.GradientMirrorChecked := ggVertical;

      end;

    tsWhidbey:
      begin
        RoundEdges := true;

        { TabAppearance }

        TabAppearance.BackGround.Color := $859D9D;
        TabAppearance.BackGround.ColorTo := $ADC4C4;
        TabAppearance.BorderColor := clNone;
        TabAppearance.BorderColorDisabled := clNone;
        TabAppearance.BorderColorHot := $E3B28D;
        TabAppearance.BorderColorSelected := clBlack;
        TabAppearance.BorderColorSelectedHot := $60CCF9;

        TabAppearance.TextColor := clWhite;
        TabAppearance.TextColorHot := clBlack;
        TabAppearance.TextColorSelected := clBlack;
        TabAppearance.TextColorDisabled := clGray;

        TabAppearance.ColorSelected := $ADC4C4;
        TabAppearance.ColorSelectedTo := clWhite;
        TabAppearance.ColorMirrorSelected := clWhite;
        TabAppearance.ColorMirrorSelectedTo := clWhite;

        TabAppearance.ColorDisabled := clWhite;
        TabAppearance.ColorDisabledTo := clSilver;
        TabAppearance.ColorMirrorDisabled := clWhite;
        TabAppearance.ColorMirrorDisabledTo := clSilver;

        TabAppearance.ColorHot := $CCF4FF;
        TabAppearance.ColorHotTo := $CCF4FF;
        TabAppearance.ColorMirrorHot := $CCF4FF;
        TabAppearance.ColorMirrorHotTo := $91D0FF;

        TabAppearance.Gradient := ggVertical;
        TabAppearance.GradientDisabled := ggVertical;
        TabAppearance.GradientHot := ggVertical;
        TabAppearance.GradientMirrorDisabled := ggVertical;
        TabAppearance.GradientMirrorHot := ggVertical;
        TabAppearance.GradientMirrorSelected := ggVertical;
        TabAppearance.GradientSelected := ggVertical;

        TabAppearance.ShadowColor := RGB(130, 140, 100);
        TabAppearance.HighLightColorSelected := $00FFFABF;
        //TabAppearance.HighLightColorSelected := $0063CCF8;
        TabAppearance.HighLightColorSelectedHot := $00BDFFFF;
        TabAppearance.HighLightColorDown := $00FFFBD0;
        TabAppearance.HighLightColorHot := $00FDF4ED;

        { GlowButtonAppearance }
        GlowButtonAppearance.Color := clWhite;
        GlowButtonAppearance.ColorTo := $DFEDF0;
        GlowButtonAppearance.ColorMirror := $DFEDF0;
        GlowButtonAppearance.ColorMirrorTo := $DFEDF0;
        GlowButtonAppearance.BorderColor := $99A8AC;
        GlowButtonAppearance.Gradient := ggVertical;
        GlowButtonAppearance.GradientMirror := ggVertical;

        GlowButtonAppearance.ColorHot := $EBFDFF;
        GlowButtonAppearance.ColorHotTo := $ACECFF;
        GlowButtonAppearance.ColorMirrorHot := $59DAFF;
        GlowButtonAppearance.ColorMirrorHotTo := $A4E9FF;
        GlowButtonAppearance.BorderColorHot := $99CEDB;
        GlowButtonAppearance.GradientHot := ggVertical;
        GlowButtonAppearance.GradientMirrorHot := ggVertical;

        GlowButtonAppearance.ColorDown := $76AFF1;
        GlowButtonAppearance.ColorDownTo := $4190F3;
        GlowButtonAppearance.ColorMirrorDown := $0E72F1;
        GlowButtonAppearance.ColorMirrorDownTo := $4C9FFD;
        GlowButtonAppearance.BorderColorDown := $45667B;
        GlowButtonAppearance.GradientDown := ggVertical;
        GlowButtonAppearance.GradientMirrorDown := ggVertical;

        GlowButtonAppearance.ColorChecked := $B5DBFB;
        GlowButtonAppearance.ColorCheckedTo := $78C7FE;
        GlowButtonAppearance.ColorMirrorChecked := $9FEBFD;
        GlowButtonAppearance.ColorMirrorCheckedTo := $56B4FE;
        GlowButtonAppearance.GradientChecked := ggVertical;
        GlowButtonAppearance.GradientMirrorChecked := ggVertical;
        
      end;

   tsOffice2003Classic:
      begin
        BlendFactor := 80;
        RoundEdges := true;
        { TabAppearance }

        TabAppearance.BackGround.Color := $C9D1D5;
        TabAppearance.BackGround.ColorTo := clWhite;
        TabAppearance.BorderColor := clNone;
        TabAppearance.BorderColorDisabled := clNone;
        TabAppearance.BorderColorHot := $E3B28D;
        TabAppearance.BorderColorSelected := clBlack;
        TabAppearance.BorderColorSelectedHot := $60CCF9;

        TabAppearance.TextColor := clBlack;
        TabAppearance.TextColorHot := clBlack;
        TabAppearance.TextColorSelected := clBlack;
        TabAppearance.TextColorDisabled := clGray;

        TabAppearance.ColorSelected := $C9D1D5;
        TabAppearance.ColorSelectedTo := clWhite;
        TabAppearance.ColorMirrorSelected := clWhite;
        TabAppearance.ColorMirrorSelectedTo := clWhite;

        TabAppearance.ColorDisabled := clWhite;
        TabAppearance.ColorDisabledTo := clSilver;
        TabAppearance.ColorMirrorDisabled := clWhite;
        TabAppearance.ColorMirrorDisabledTo := clSilver;

        TabAppearance.ColorHot := $CCF4FF;
        TabAppearance.ColorHotTo := $CCF4FF;
        TabAppearance.ColorMirrorHot := $CCF4FF;
        TabAppearance.ColorMirrorHotTo := $91D0FF;

        TabAppearance.Gradient := ggVertical;
        TabAppearance.GradientDisabled := ggVertical;
        TabAppearance.GradientHot := ggVertical;
        TabAppearance.GradientMirrorDisabled := ggVertical;
        TabAppearance.GradientMirrorHot := ggVertical;
        TabAppearance.GradientMirrorSelected := ggVertical;
        TabAppearance.GradientSelected := ggVertical;

        TabAppearance.ShadowColor := RGB(170, 167, 161);
        TabAppearance.HighLightColorSelected := $00FFFABF;
        //TabAppearance.HighLightColorSelected := $0063CCF8;
        TabAppearance.HighLightColorSelectedHot := $00BDFFFF;
        TabAppearance.HighLightColorDown := $00FFFBD0;
        TabAppearance.HighLightColorHot := $00F7F4F3;

        { GlowButtonAppearance }
        GlowButtonAppearance.Color := clWhite;
        GlowButtonAppearance.ColorTo := $C9D1D5;
        GlowButtonAppearance.ColorMirror := clWhite;
        GlowButtonAppearance.ColorMirrorTo := $C9D1D5;
        GlowButtonAppearance.BorderColor := clBlack;
        GlowButtonAppearance.Gradient := ggVertical;
        GlowButtonAppearance.GradientMirror := ggVertical;

        GlowButtonAppearance.ColorHot := $EBFDFF;
        GlowButtonAppearance.ColorHotTo := $ACECFF;
        GlowButtonAppearance.ColorMirrorHot := $59DAFF;
        GlowButtonAppearance.ColorMirrorHotTo := $A4E9FF;
        GlowButtonAppearance.BorderColorHot := $99CEDB;
        GlowButtonAppearance.GradientHot := ggVertical;
        GlowButtonAppearance.GradientMirrorHot := ggVertical;

        GlowButtonAppearance.ColorDown := $76AFF1;
        GlowButtonAppearance.ColorDownTo := $4190F3;
        GlowButtonAppearance.ColorMirrorDown := $0E72F1;
        GlowButtonAppearance.ColorMirrorDownTo := $4C9FFD;
        GlowButtonAppearance.BorderColorDown := $45667B;
        GlowButtonAppearance.GradientDown := ggVertical;
        GlowButtonAppearance.GradientMirrorDown := ggVertical;

        GlowButtonAppearance.ColorChecked := $B5DBFB;
        GlowButtonAppearance.ColorCheckedTo := $78C7FE;
        GlowButtonAppearance.ColorMirrorChecked := $9FEBFD;
        GlowButtonAppearance.ColorMirrorCheckedTo := $56B4FE;
        GlowButtonAppearance.GradientChecked := ggVertical;
        GlowButtonAppearance.GradientMirrorChecked := ggVertical;

      end;
      tsWindowsVista:
      begin
        BlendFactor := 80;
        RoundEdges := true;
        { TabAppearance }

        TabAppearance.BackGround.Color := $FFFDF9;
        TabAppearance.BackGround.ColorTo := $FFFAF0;
        TabAppearance.BorderColor := $FCF2DA;
        TabAppearance.BorderColorDisabled := clNone;
        TabAppearance.BorderColorHot := $FEDF9A;
        TabAppearance.BorderColorSelected := $FEDF9A;
        TabAppearance.BorderColorSelectedHot := clHighlight;

        TabAppearance.TextColor := clBlack;
        TabAppearance.TextColorHot := clBlack;
        TabAppearance.TextColorSelected := clBlack;
        TabAppearance.TextColorDisabled := clGray;

        TabAppearance.ColorSelected := $FEF9F0;
        TabAppearance.ColorSelectedTo := $FDF0D7;
        TabAppearance.ColorMirrorSelected := $FDF0D7;
        TabAppearance.ColorMirrorSelectedTo := $FEF9F0;

        TabAppearance.ColorDisabled := clWhite;
        TabAppearance.ColorDisabledTo := clSilver;
        TabAppearance.ColorMirrorDisabled := clWhite;
        TabAppearance.ColorMirrorDisabledTo := clSilver;

        TabAppearance.ColorHot := $FFFDF9;
        TabAppearance.ColorHotTo := $FFFAF0;
        TabAppearance.ColorMirrorHot := $FFFAF0;
        TabAppearance.ColorMirrorHotTo := $FFFDF9;

        TabAppearance.Gradient := ggVertical;
        TabAppearance.GradientDisabled := ggVertical;
        TabAppearance.GradientHot := ggVertical;
        TabAppearance.GradientMirrorDisabled := ggVertical;
        TabAppearance.GradientMirrorHot := ggVertical;
        TabAppearance.GradientMirrorSelected := ggVertical;
        TabAppearance.GradientSelected := ggVertical;

        TabAppearance.ShadowColor := $FBEDD3;
        TabAppearance.HighLightColorSelected := $FAE9C6;
        TabAppearance.HighLightColorSelectedHot :=  $FCF2DA;
        TabAppearance.HighLightColorDown := $FEF8EC;
        TabAppearance.HighLightColorHot := $FEDF9A;

        { GlowButtonAppearance }
        GlowButtonAppearance.Color := $FDF8F1;
        GlowButtonAppearance.ColorTo := $FDF8F1;
        GlowButtonAppearance.ColorMirror := $FCEFD5;
        GlowButtonAppearance.ColorMirrorTo := $FDF8F1;
        GlowButtonAppearance.BorderColor := $FDDE99;
        GlowButtonAppearance.Gradient := ggVertical;
        GlowButtonAppearance.GradientMirror := ggVertical;

        GlowButtonAppearance.ColorHot := clNone;
        GlowButtonAppearance.ColorHotTo := $FFFAF0;
        GlowButtonAppearance.ColorMirrorHot := $FFFAF0;
        GlowButtonAppearance.ColorMirrorHotTo := $FFFAF0;
        GlowButtonAppearance.BorderColorHot := $FCF2DA;
        GlowButtonAppearance.GradientHot := ggVertical;
        GlowButtonAppearance.GradientMirrorHot := ggVertical;

        GlowButtonAppearance.ColorDown := $FCEFD5;
        GlowButtonAppearance.ColorDownTo := $FCEFD5;
        GlowButtonAppearance.ColorMirrorDown := $FDF4E3;
        GlowButtonAppearance.ColorMirrorDownTo := $FDF4E3;
        GlowButtonAppearance.BorderColorDown := $FEDF9A;
        GlowButtonAppearance.GradientDown := ggVertical;
        GlowButtonAppearance.GradientMirrorDown := ggVertical;

        GlowButtonAppearance.ColorChecked := $FCEFD5;
        GlowButtonAppearance.ColorCheckedTo := $FAE9C6;
        GlowButtonAppearance.ColorMirrorChecked := $F7DAA2;
        GlowButtonAppearance.ColorMirrorCheckedTo := $FBEDD3;
        GlowButtonAppearance.GradientChecked := ggVertical;
        GlowButtonAppearance.GradientMirrorChecked := ggVertical;

      end;
      tsWindows7:
      begin
        BlendFactor := 80;
        RoundEdges := true;
        { TabAppearance }

        TabAppearance.BackGround.Color := $FCEBDC;
        TabAppearance.BackGround.ColorTo := $FCDBC1;
        TabAppearance.BorderColor := $CEA27D;
        TabAppearance.BorderColorDisabled := clNone;
        TabAppearance.BorderColorHot := $E3B28D;
        TabAppearance.BorderColorSelected := $CEA27D;
        TabAppearance.BorderColorSelectedHot := clHighlight;

        TabAppearance.TextColor := clBlack;
        TabAppearance.TextColorHot := clBlack;
        TabAppearance.TextColorSelected := clBlack;
        TabAppearance.TextColorDisabled := clGray;

        TabAppearance.ColorSelected := $FCEBDC;
        TabAppearance.ColorSelectedTo := $FCDBC1;
        TabAppearance.ColorMirrorSelected := $FCDBC1;
        TabAppearance.ColorMirrorSelectedTo := $FCEBDC;

        TabAppearance.ColorDisabled := clWhite;
        TabAppearance.ColorDisabledTo := clSilver;
        TabAppearance.ColorMirrorDisabled := clWhite;
        TabAppearance.ColorMirrorDisabledTo := clSilver;

        TabAppearance.ColorHot := $FDFBFA;
        TabAppearance.ColorHotTo := $FDF3EB;
        TabAppearance.ColorMirrorHot := $FDF3EB;
        TabAppearance.ColorMirrorHotTo := $FDFBFA;

        TabAppearance.Gradient := ggVertical;
        TabAppearance.GradientDisabled := ggVertical;
        TabAppearance.GradientHot := ggVertical;
        TabAppearance.GradientMirrorDisabled := ggVertical;
        TabAppearance.GradientMirrorHot := ggVertical;
        TabAppearance.GradientMirrorSelected := ggVertical;
        TabAppearance.GradientSelected := ggVertical;

        TabAppearance.ShadowColor := $FAE9C6;
        TabAppearance.HighLightColorSelected := $FDF3EB;
        TabAppearance.HighLightColorSelectedHot := $FBD6B8;
        TabAppearance.HighLightColorDown := $FDEFE3;
        TabAppearance.HighLightColorHot := $CEA27D;

        { GlowButtonAppearance }
        GlowButtonAppearance.Color := $FCEBDC;
        GlowButtonAppearance.ColorTo := $FCDBC1;
        GlowButtonAppearance.ColorMirror := $FCDBC1;
        GlowButtonAppearance.ColorMirrorTo := $FCDBC1;
        GlowButtonAppearance.BorderColor := $CEA27D;
        GlowButtonAppearance.Gradient := ggVertical;
        GlowButtonAppearance.GradientMirror := ggVertical;

        GlowButtonAppearance.ColorHot := $FDFBFA;
        GlowButtonAppearance.ColorHotTo := $FDF3EB;
        GlowButtonAppearance.ColorMirrorHot := $FDF3EB;
        GlowButtonAppearance.ColorMirrorHotTo := $FDFBFA;
        GlowButtonAppearance.BorderColorHot := $FBD6B8;
        GlowButtonAppearance.GradientHot := ggVertical;
        GlowButtonAppearance.GradientMirrorHot := ggVertical;

        GlowButtonAppearance.ColorDown := $FCEBDC;
        GlowButtonAppearance.ColorDownTo := $FCDBC1;
        GlowButtonAppearance.ColorMirrorDown := $FCDBC1;
        GlowButtonAppearance.ColorMirrorDownTo := $FCEBDC;
        GlowButtonAppearance.BorderColorDown := $CEA27D;
        GlowButtonAppearance.GradientDown := ggVertical;
        GlowButtonAppearance.GradientMirrorDown := ggVertical;

        GlowButtonAppearance.ColorChecked := $FDFBFA;
        GlowButtonAppearance.ColorCheckedTo := $FDF3EB;
        GlowButtonAppearance.ColorMirrorChecked := $FCEBDC;
        GlowButtonAppearance.ColorMirrorCheckedTo := $FCEBDC;
        GlowButtonAppearance.GradientChecked := ggVertical;
        GlowButtonAppearance.GradientMirrorChecked := ggVertical;

      end;
      tsTerminal:
      begin
        BlendFactor := 80;
        RoundEdges := true;
        { TabAppearance }

        TabAppearance.BackGround.Color := clBtnFace;
        TabAppearance.BackGround.ColorTo := clBtnFace;
        TabAppearance.BorderColor := clGray;
        TabAppearance.BorderColorDisabled := clNone;
        TabAppearance.BorderColorHot := clGray;
        TabAppearance.BorderColorSelected := clHighlight;
        TabAppearance.BorderColorSelectedHot := clGray;

        TabAppearance.TextColor := clBlack;
        TabAppearance.TextColorHot := clBlack;
        TabAppearance.TextColorSelected := clWhite;
        TabAppearance.TextColorDisabled := clGray;

        TabAppearance.ColorSelected := clHighlight;
        TabAppearance.ColorSelectedTo := clHighlight;
        TabAppearance.ColorMirrorSelected := clHighlight;
        TabAppearance.ColorMirrorSelectedTo := clHighlight;

        TabAppearance.ColorDisabled := clGray;
        TabAppearance.ColorDisabledTo := clGray;
        TabAppearance.ColorMirrorDisabled := clGray;
        TabAppearance.ColorMirrorDisabledTo := clGray;

        TabAppearance.ColorHot := clSilver;
        TabAppearance.ColorHotTo := clSilver;
        TabAppearance.ColorMirrorHot := clSilver;
        TabAppearance.ColorMirrorHotTo := clSilver;

        TabAppearance.Gradient := ggVertical;
        TabAppearance.GradientDisabled := ggVertical;
        TabAppearance.GradientHot := ggVertical;
        TabAppearance.GradientMirrorDisabled := ggVertical;
        TabAppearance.GradientMirrorHot := ggVertical;
        TabAppearance.GradientMirrorSelected := ggVertical;
        TabAppearance.GradientSelected := ggVertical;

        TabAppearance.ShadowColor := clGray;
        TabAppearance.HighLightColorSelected := clBtnFace;
        TabAppearance.HighLightColorSelectedHot := clHighLight;
        TabAppearance.HighLightColorDown := clHighLight;
        TabAppearance.HighLightColorHot := clGray;

        { GlowButtonAppearance }
        GlowButtonAppearance.Color := clbtnFace;
        GlowButtonAppearance.ColorTo := clbtnFace;
        GlowButtonAppearance.ColorMirror := clbtnFace;
        GlowButtonAppearance.ColorMirrorTo := clbtnFace;
        GlowButtonAppearance.BorderColor := clGray;
        GlowButtonAppearance.Gradient := ggVertical;
        GlowButtonAppearance.GradientMirror := ggVertical;

        GlowButtonAppearance.ColorHot := clSilver;
        GlowButtonAppearance.ColorHotTo := clSilver;
        GlowButtonAppearance.ColorMirrorHot := clSilver;
        GlowButtonAppearance.ColorMirrorHotTo := clSilver;
        GlowButtonAppearance.BorderColorHot := clGray;
        GlowButtonAppearance.GradientHot := ggVertical;
        GlowButtonAppearance.GradientMirrorHot := ggVertical;

        GlowButtonAppearance.ColorDown := clHighlight;
        GlowButtonAppearance.ColorDownTo := clHighlight;
        GlowButtonAppearance.ColorMirrorDown := clHighlight;
        GlowButtonAppearance.ColorMirrorDownTo := clHighlight;
        GlowButtonAppearance.BorderColorDown := clHighlight;
        GlowButtonAppearance.GradientDown := ggVertical;
        GlowButtonAppearance.GradientMirrorDown := ggVertical;

        GlowButtonAppearance.ColorChecked := clGray;
        GlowButtonAppearance.ColorCheckedTo := clGray;
        GlowButtonAppearance.ColorMirrorChecked := clGray;
        GlowButtonAppearance.ColorMirrorCheckedTo := clGray;
        GlowButtonAppearance.GradientChecked := ggVertical;
        GlowButtonAppearance.GradientMirrorChecked := ggVertical;

      end;
    tsOffice2010Blue:
      begin
        BlendFactor := 80;
        RoundEdges := true;
        { TabAppearance }

        TabAppearance.BackGround.Color :=  $F0DAC7;
        TabAppearance.BackGround.ColorTo := $FDF6EF;
        TabAppearance.BorderColor := $C7B29F;
        TabAppearance.BorderColorDisabled := clNone;
        TabAppearance.BorderColorHot := $BAB5B1;
        TabAppearance.BorderColorSelected := $C7B29F;
        TabAppearance.BorderColorSelectedHot := $C7B29F;

        TabAppearance.TextColor := clBlack;
        TabAppearance.TextColorHot := clBlack;
        TabAppearance.TextColorSelected := clBlack;
        TabAppearance.TextColorDisabled := clGray;

        TabAppearance.ColorSelected := $F0DAC7;
        TabAppearance.ColorSelectedTo := $F0DAC7;
        TabAppearance.ColorMirrorSelected := $F0DAC7;
        TabAppearance.ColorMirrorSelectedTo := $F0DAC7;

        TabAppearance.ColorDisabled := $00F2F2F2;
        TabAppearance.ColorDisabledTo := $00F2F2F2;
        TabAppearance.ColorMirrorDisabled := $00F2F2F2;
        TabAppearance.ColorMirrorDisabledTo := $00F2F2F2;

        TabAppearance.ColorHot := $F2EBE4;
        TabAppearance.ColorHotTo := $F2EBE4;
        TabAppearance.ColorMirrorHot := $F2EBE4;
        TabAppearance.ColorMirrorHotTo := $F2EBE4;

        TabAppearance.Gradient := ggVertical;
        TabAppearance.GradientDisabled := ggVertical;
        TabAppearance.GradientHot := ggVertical;
        TabAppearance.GradientMirrorDisabled := ggVertical;
        TabAppearance.GradientMirrorHot := ggVertical;
        TabAppearance.GradientMirrorSelected := ggVertical;
        TabAppearance.GradientSelected := ggVertical;

        TabAppearance.ShadowColor := $C7B29F;
        TabAppearance.HighLightColorSelected := $C7B29F;
        TabAppearance.HighLightColorSelectedHot := $F0DAC7;
        TabAppearance.HighLightColorDown := $F6E7D9;
        TabAppearance.HighLightColorHot := $FDF6EF;

        { GlowButtonAppearance }
        GlowButtonAppearance.Color := $FDF6EF;
        GlowButtonAppearance.ColorTo := $F0DAC7;
        GlowButtonAppearance.ColorMirror := $F0DAC7;
        GlowButtonAppearance.ColorMirrorTo := $F0DAC7;
        GlowButtonAppearance.BorderColor := $C7B29F;
        GlowButtonAppearance.Gradient := ggVertical;
        GlowButtonAppearance.GradientMirror := ggVertical;

        GlowButtonAppearance.ColorHot := $8AE3FD;
        GlowButtonAppearance.ColorHotTo := $D9F9FD;
        GlowButtonAppearance.ColorMirrorHot := $D9F9FD;
        GlowButtonAppearance.ColorMirrorHotTo := $8AE3FD;
        GlowButtonAppearance.BorderColorHot := $58CAF1;
        GlowButtonAppearance.GradientHot := ggVertical;
        GlowButtonAppearance.GradientMirrorHot := ggVertical;

        GlowButtonAppearance.ColorDown := $6CD0FF;
        GlowButtonAppearance.ColorDownTo := $7BEEFF;
        GlowButtonAppearance.ColorMirrorDown := $7BEEFF;
        GlowButtonAppearance.ColorMirrorDownTo := $6CD0FF;
        GlowButtonAppearance.BorderColorDown := $308AC2;
        GlowButtonAppearance.GradientDown := ggVertical;
        GlowButtonAppearance.GradientMirrorDown := ggVertical;

        GlowButtonAppearance.ColorChecked := $D9F9FD;
        GlowButtonAppearance.ColorCheckedTo := $6CD0FF;
        GlowButtonAppearance.ColorMirrorChecked := $6CD0FF;
        GlowButtonAppearance.ColorMirrorCheckedTo := $6CD0FF;
        GlowButtonAppearance.BorderColorChecked := $308AC2;
        GlowButtonAppearance.GradientChecked := ggVertical;
        GlowButtonAppearance.GradientMirrorChecked := ggVertical;



      end;
    tsOffice2010Silver:
      begin
        BlendFactor := 80;
        RoundEdges := true;
        { TabAppearance }

        TabAppearance.BackGround.Color := $EDE5E0;
        TabAppearance.BackGround.ColorTo := $FFFFFF;
        TabAppearance.BorderColor := $D2CDC8;
        TabAppearance.BorderColorDisabled := clNone;
        TabAppearance.BorderColorHot := $F8F5F3;
        TabAppearance.BorderColorSelected := $D2CDC8;
        TabAppearance.BorderColorSelectedHot := $D0D0D0;

        TabAppearance.TextColor := clBlack;
        TabAppearance.TextColorHot := clBlack;
        TabAppearance.TextColorSelected := clBlack;
        TabAppearance.TextColorDisabled := clGray;

        TabAppearance.ColorSelected := $FFFFFF;
        TabAppearance.ColorSelectedTo := $FFFFFF;
        TabAppearance.ColorMirrorSelected := $FFFFFF;
        TabAppearance.ColorMirrorSelectedTo := $FFFFFF;

        TabAppearance.ColorDisabled := $00F2F2F2;
        TabAppearance.ColorDisabledTo := $00F2F2F2;
        TabAppearance.ColorMirrorDisabled := $00F2F2F2;
        TabAppearance.ColorMirrorDisabledTo := $00F2F2F2;

        TabAppearance.ColorHot := $FDFBFA;
        TabAppearance.ColorHotTo := $FDF3EB;
        TabAppearance.ColorMirrorHot := $FDF3EB;
        TabAppearance.ColorMirrorHotTo := $FDFBFA;

        TabAppearance.Gradient := ggVertical;
        TabAppearance.GradientDisabled := ggVertical;
        TabAppearance.GradientHot := ggVertical;
        TabAppearance.GradientMirrorDisabled := ggVertical;
        TabAppearance.GradientMirrorHot := ggVertical;
        TabAppearance.GradientMirrorSelected := ggVertical;
        TabAppearance.GradientSelected := ggVertical;

        TabAppearance.ShadowColor := $BFBAB6;
        TabAppearance.HighLightColorSelected := $D2CDC8;
        TabAppearance.HighLightColorSelectedHot := $EDE5E0;
        TabAppearance.HighLightColorDown := $F5F4F2;
        TabAppearance.HighLightColorHot := $FFFFFF;

        { GlowButtonAppearance }
        GlowButtonAppearance.Color := $FFFFFF;
        GlowButtonAppearance.ColorTo := $EDE5E0;
        GlowButtonAppearance.ColorMirror := $EDE5E0;
        GlowButtonAppearance.ColorMirrorTo := $EDE5E0;
        GlowButtonAppearance.BorderColor := $D2CDC8;
        GlowButtonAppearance.Gradient := ggVertical;
        GlowButtonAppearance.GradientMirror := ggVertical;

        GlowButtonAppearance.ColorHot := $8AE3FD;
        GlowButtonAppearance.ColorHotTo := $D9F9FD;
        GlowButtonAppearance.ColorMirrorHot := $D9F9FD;
        GlowButtonAppearance.ColorMirrorHotTo := $8AE3FD;
        GlowButtonAppearance.BorderColorHot := $58CAF1;
        GlowButtonAppearance.GradientHot := ggVertical;
        GlowButtonAppearance.GradientMirrorHot := ggVertical;

        GlowButtonAppearance.ColorDown := $6CD0FF;
        GlowButtonAppearance.ColorDownTo := $7BEEFF;
        GlowButtonAppearance.ColorMirrorDown := $7BEEFF;
        GlowButtonAppearance.ColorMirrorDownTo := $6CD0FF;
        GlowButtonAppearance.BorderColorDown := $308AC2;
        GlowButtonAppearance.GradientDown := ggVertical;
        GlowButtonAppearance.GradientMirrorDown := ggVertical;

        GlowButtonAppearance.ColorChecked := $D9F9FD;
        GlowButtonAppearance.ColorCheckedTo := $6CD0FF;
        GlowButtonAppearance.ColorMirrorChecked := $6CD0FF;
        GlowButtonAppearance.ColorMirrorCheckedTo := $6CD0FF;
        GlowButtonAppearance.BorderColorChecked := $308AC2;
        GlowButtonAppearance.GradientChecked := ggVertical;
        GlowButtonAppearance.GradientMirrorChecked := ggVertical;
      end;
    tsOffice2010Black:
      begin
        BlendFactor := 80;
        RoundEdges := true;
        { TabAppearance }

        TabAppearance.BackGround.Color := $919191;
        TabAppearance.BackGround.ColorTo := $BFBFBF;
        TabAppearance.BorderColor := $6D6D6D;
        TabAppearance.BorderColorDisabled := clNone;
        TabAppearance.BorderColorHot := $BAB5B1;
        TabAppearance.BorderColorSelected := $6D6D6D;
        TabAppearance.BorderColorSelectedHot := $D7D7D6;

        TabAppearance.TextColor := clBlack;
        TabAppearance.TextColorHot := clBlack;
        TabAppearance.TextColorSelected := clBlack;
        TabAppearance.TextColorDisabled := clGray;

        TabAppearance.ColorSelected := $C9C9C9;
        TabAppearance.ColorSelectedTo := $C9C9C9;
        TabAppearance.ColorMirrorSelected := $C9C9C9;
        TabAppearance.ColorMirrorSelectedTo := $C9C9C9;

        TabAppearance.ColorDisabled := $00F2F2F2;
        TabAppearance.ColorDisabledTo := $00F2F2F2;
        TabAppearance.ColorMirrorDisabled := $00F2F2F2;
        TabAppearance.ColorMirrorDisabledTo := $00F2F2F2;

        TabAppearance.ColorHot := $949494;
        TabAppearance.ColorHotTo := $949494;
        TabAppearance.ColorMirrorHot := $949494;
        TabAppearance.ColorMirrorHotTo := $949494;

        TabAppearance.Gradient := ggVertical;
        TabAppearance.GradientDisabled := ggVertical;
        TabAppearance.GradientHot := ggVertical;
        TabAppearance.GradientMirrorDisabled := ggVertical;
        TabAppearance.GradientMirrorHot := ggVertical;
        TabAppearance.GradientMirrorSelected := ggVertical;
        TabAppearance.GradientSelected := ggVertical;

        TabAppearance.ShadowColor := $BEBEBE;
        TabAppearance.HighLightColorSelected := $6D6D6D;
        TabAppearance.HighLightColorSelectedHot := $919191;
        TabAppearance.HighLightColorDown := $A5A5A5;
        TabAppearance.HighLightColorHot := $BFBFBF;

        { GlowButtonAppearance }
        GlowButtonAppearance.Color := $BFBFBF;
        GlowButtonAppearance.ColorTo := $919191;
        GlowButtonAppearance.ColorMirror := $919191;
        GlowButtonAppearance.ColorMirrorTo := $919191;
        GlowButtonAppearance.BorderColor := $6D6D6D;
        GlowButtonAppearance.Gradient := ggVertical;
        GlowButtonAppearance.GradientMirror := ggVertical;

        GlowButtonAppearance.ColorHot := $8AE3FD;
        GlowButtonAppearance.ColorHotTo := $D9F9FD;
        GlowButtonAppearance.ColorMirrorHot := $D9F9FD;
        GlowButtonAppearance.ColorMirrorHotTo := $8AE3FD;
        GlowButtonAppearance.BorderColorHot := $58CAF1;
        GlowButtonAppearance.GradientHot := ggVertical;
        GlowButtonAppearance.GradientMirrorHot := ggVertical;

        GlowButtonAppearance.ColorDown := $6CD0FF;
        GlowButtonAppearance.ColorDownTo := $7BEEFF;
        GlowButtonAppearance.ColorMirrorDown := $7BEEFF;
        GlowButtonAppearance.ColorMirrorDownTo := $6CD0FF;
        GlowButtonAppearance.BorderColorDown := $308AC2;
        GlowButtonAppearance.GradientDown := ggVertical;
        GlowButtonAppearance.GradientMirrorDown := ggVertical;

        GlowButtonAppearance.ColorChecked := $D9F9FD;
        GlowButtonAppearance.ColorCheckedTo := $6CD0FF;
        GlowButtonAppearance.ColorMirrorChecked := $6CD0FF;
        GlowButtonAppearance.ColorMirrorCheckedTo := $6CD0FF;
        GlowButtonAppearance.BorderColorChecked := $308AC2;
        GlowButtonAppearance.GradientChecked := ggVertical;
        GlowButtonAppearance.GradientMirrorChecked := ggVertical;

      end;
    end;
    Change(2);
  end;
end;

{ TAdvOfficeTabSetFantasyStyler }

constructor TAdvOfficeTabSetFantasyStyler.Create(AOwner: TComponent);
begin
  inherited;
  Style := tsChocolate;
end;

procedure TAdvOfficeTabSetFantasyStyler.SetOfficeTabSetStyle(
  const Value: TOfficeTabSetFantasyStyle);
begin
  FOfficeTabSetStyle := Value;
  BlendFactor := 50;

  case FOfficeTabSetStyle of
  tsChocolate:
    begin
      RoundEdges:= true;
    end;

  tsArctic :
    begin
      RoundEdges:= true;
    end;

  tsWindowsClassic :
    begin
      RoundEdges:= false;
    end;

  tsTerminalGreen :
    begin
      RoundEdges:= false;
  end;

  tsAquaBlue :
    begin
      RoundEdges:= true;
    end;

  tsSilverFox :
    begin
      RoundEdges:= true;
    end;

  tsTextured :
    begin
      RoundEdges:= false;
    end;

  tsMacOS :
    begin
      RoundEdges:= true;
    end;

  tsSoftSand :
    begin
      RoundEdges:= true;
    end;
 { tsWhidbey:
    begin
      RoundEdges := true;
    end; }
  end;

end;

end.
