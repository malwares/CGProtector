{***************************************************************************}
{ TAdvShapeButton component                                                 }
{ for Delphi & C++Builder                                                   }
{                                                                           }
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

unit AdvShapeButton;

{$I TMSDEFS.INC}

{$DEFINE TMS_DWM}

interface

uses
  Classes, Windows, Forms, Dialogs, Controls, Graphics, Messages, ExtCtrls,
  SysUtils, Math, GDIPicture, ActnList, AdvHintInfo, AdvPreviewMenu, AdvGlowButton,
  AdvToolBar, AdvGDIP, AdvDWM, AdvTBXPVS;


const

  MAJ_VER = 5; // Major version nr.
  MIN_VER = 0; // Minor version nr.
  REL_VER = 0; // Release nr.
  BLD_VER = 0; // Build nr.

  // version history:
  // 1.0.0.0 : first release
  // 1.0.0.1 : fixed issue with menu positioning on multimonitor screens
  // 1.0.1.0 : TabOrder, TabStop capability added & keyboard support
  // 1.0.1.1 : Fixed : painting for Windows Vista when TAdvToolBarPager is directly on TForm
  // 1.0.1.2 : Fixed : issue with compiling for C++Builder
  // 1.1.0.0 : New : Text property to put text on top of the shapebutton image
  // 1.1.0.1 : Fixed : issue with shortcut hints on TAdvPreviewMenu
  // 1.1.1.0 : Improved : do not paint dotted line when no image is assigned at runtime
  // 1.2.0.0 : New : Windows 7 Scenic Ribbon
  //         : New : Office Orb / Windows 7 square drawing
  // 1.2.0.1 : Fixed : picture position in Windows 7 scenic ribbon mode
  // 1.3.0.0 : New : Layout property added
  // 1.4.0.0 : New : property AntiAlias added

  // 5.0.0.0 : New : Office 2010 Ribbon & Application menu support

type
  TAdvCustomShapeButton = class;
  TInternalAdvPreviewMenu = class(TAdvPreviewMenu);

  TAdvToolButtonStyle = (tasButton, tasCheck);
  TAdvButtonState = (absUp, absDisabled, absDown, absDropDown, absExclusive);
  TShapeButtonLayout = (plPictureCenter, plPictureOnTop, plPictureAtBottom);

{$IFDEF DELPHI6_LVL}
  TAdvShapeButtonActionLink = class(TControlActionLink)
  protected
    FClient: TAdvCustomShapeButton;
    procedure AssignClient(AClient: TObject); override;
    function IsCheckedLinked: Boolean; override;
    function IsGroupIndexLinked: Boolean; override;
    procedure SetGroupIndex(Value: Integer); override;
    procedure SetChecked(Value: Boolean); override;
  end;
{$ENDIF}

  TAdvButtonShape = (bsCustom, bsRectangle, bsOrb);

  TShapeRoundingType = (srtNone, srtTop, srtBottom, srtBoth, srtLeft, srtRight);

  TAdvShapeButtonAppearance = class(TPersistent)
  private
    FOwner: TAdvCustomShapeButton;
    FColorHotMirrorTo: TColor;
    FBorderColor: TColor;
    FBorderColorHot: TColor;
    FShape: TAdvButtonShape;
    FColor: TColor;
    FColorDownMirror: TColor;
    FColorTo: TColor;
    FInnerBorderColor: TColor;
    FColorDownMirrorTo: TColor;
    FColorHot: TColor;
    FColorHotTo: TColor;
    FInnerBorderColorHot: TColor;
    FBorderColorDown: TColor;
    FColorDown: TColor;
    FColorDownTo: TColor;
    FColorMirror: TColor;
    FInnerBorderColorDown: TColor;
    FColorMirrorTo: TColor;
    FColorHotMirror: TColor;
    FColorDisabled: TColor;
    FColorDisabledTo: TColor;
    FInnerBorderColorDisabled: TColor;
    FColorDisabledMirror: TColor;
    FColorDisabledMirrorTo: TColor;
    FBorderColorDisabled: TColor;
    FShowMenuShape: Boolean;
    FMenuShapeColorDisabled: TColor;
    FMenuShapeColor: TColor;
    FMenuShapeColorHot: TColor;
    FMenuShapeColorDown: TColor;
    FShowPicture: Boolean;
    procedure SetBorderColor(const Value: TColor);
    procedure SetBorderColorDown(const Value: TColor);
    procedure SetBorderColorHot(const Value: TColor);
    procedure SetColor(const Value: TColor);
    procedure SetColorDown(const Value: TColor);
    procedure SetColorDownMirror(const Value: TColor);
    procedure SetColorDownMirrorTo(const Value: TColor);
    procedure SetColorDownTo(const Value: TColor);
    procedure SetColorHot(const Value: TColor);
    procedure SetColorHotMirror(const Value: TColor);
    procedure SetColorHotMirrorTo(const Value: TColor);
    procedure SetColorHotTo(const Value: TColor);
    procedure SetColorMirror(const Value: TColor);
    procedure SetColorMirrorTo(const Value: TColor);
    procedure SetColorTo(const Value: TColor);
    procedure SetInnerBorderColor(const Value: TColor);
    procedure SetInnerBorderColorDown(const Value: TColor);
    procedure SetInnerBorderColorHot(const Value: TColor);
    procedure SetShape(const Value: TAdvButtonShape);
    procedure SetBorderColorDisabled(const Value: TColor);
    procedure SetColorDisabled(const Value: TColor);
    procedure SetColorDisabledMirror(const Value: TColor);
    procedure SetColorDisabledMirrorTo(const Value: TColor);
    procedure SetColorDisabledTo(const Value: TColor);
    procedure SetInnerBorderColorDisabled(const Value: TColor);
    procedure SetShowMenuShape(const Value: Boolean);
    procedure SetMenuShapeColor(const Value: TColor);
    procedure SetMenuShapeColorDisabled(const Value: TColor);
    procedure SetMenuShapeColorDown(const Value: TColor);
    procedure SetMenuShapeColorHot(const Value: TColor);
    procedure SetShowPicture(const Value: Boolean);
  protected
    procedure Changed;
  public
    procedure AssignColors(Source: TPersistent);
    constructor Create(AOwner: TAdvCustomShapeButton);
    destructor Destroy; override;
    procedure UpdateButtonColor(AColor: TColor);
  published
    property Shape: TAdvButtonShape read FShape write SetShape default bsCustom;

    property BorderColor: TColor read FBorderColor write SetBorderColor default $00BD6A41;
    property BorderColorHot: TColor read FBorderColorHot write SetBorderColorHot default $00D58744;
    property BorderColorDown: TColor read FBorderColorDown write SetBorderColorDown default $00BD6A41;
    property BorderColorDisabled: TColor read FBorderColorDisabled write SetBorderColorDisabled default clGray;

    property InnerBorderColor: TColor read FInnerBorderColor write SetInnerBorderColor default $00CFA079;
    property InnerBorderColorHot: TColor read FInnerBorderColorHot write SetInnerBorderColorHot default $00F3CE9F;
    property InnerBorderColorDown: TColor read FInnerBorderColorDown write SetInnerBorderColorDown default $00CFA079;
    property InnerBorderColorDisabled: TColor read FInnerBorderColorDisabled write SetInnerBorderColorDisabled default clSilver;

    property Color: TColor read FColor write SetColor default $00C68B49;
    property ColorTo: TColor read FColorTo write SetColorTo default $00B3692F;
    property ColorMirror: TColor read FColorMirror write SetColorMirror default $0088411A;
    property ColorMirrorTo: TColor read FColorMirrorTo write SetColorMirrorTo default $00CE9B40;

    property ColorHot: TColor read FColorHot write SetColorHot default $00EFB978;
    property ColorHotTo: TColor read FColorHotTo write SetColorHotTo default $00D28448;
    property ColorHotMirror: TColor read FColorHotMirror write SetColorHotMirror default $00AF4E11;
    property ColorHotMirrorTo: TColor read FColorHotMirrorTo write SetColorHotMirrorTo default $00FFFF96;

    property ColorDown: TColor read FColorDown write SetColorDown default $00C68B49;
    property ColorDownTo: TColor read FColorDownTo write SetColorDownTo default $00B3692F;
    property ColorDownMirror: TColor read FColorDownMirror write SetColorDownMirror default $0088411A;
    property ColorDownMirrorTo: TColor read FColorDownMirrorTo write SetColorDownMirrorTo default $00CE9B40;

    property ColorDisabled: TColor read FColorDisabled write SetColorDisabled default $00DBDBDB;
    property ColorDisabledTo: TColor read FColorDisabledTo write SetColorDisabledTo default $00C4C4C4;
    property ColorDisabledMirror: TColor read FColorDisabledMirror write SetColorDisabledMirror default $00AAAAAA;
    property ColorDisabledMirrorTo: TColor read FColorDisabledMirrorTo write SetColorDisabledMirrorTo default clSilver;

    property ShowMenuShape: Boolean read FShowMenuShape write SetShowMenuShape default false;
    property MenuShapeColor: TColor read FMenuShapeColor write SetMenuShapeColor default clwhite;
    property MenuShapeColorHot: TColor read FMenuShapeColorHot write SetMenuShapeColorHot default clwhite;
    property MenuShapeColorDown: TColor read FMenuShapeColorDown write SetMenuShapeColorDown default clwhite;
    property MenuShapeColorDisabled: TColor read FMenuShapeColorDisabled write SetMenuShapeColorDisabled default clwhite;
    property ShowPicture: Boolean read FShowPicture write SetShowPicture default true;
  end;

  TFrameWindow = class(TCustomForm)
  private
    FHideOnDeActivate: Boolean;
    FOwner: TComponent;
    FShowBorder: Boolean;
    FHideTimer: TTimer;
    FBorderColor: TColor;
    procedure WMActivate(var Message: TWMActivate); message WM_ACTIVATE;
    procedure WMMouseActivate(var Message: TWMMouseActivate); message WM_MOUSEACTIVATE;
    procedure WMNCHitTest(var Message: TWMNCHitTest); message WM_NCHITTEST;
    procedure WMKeyDown(var Message: TWMKeyDown); message WM_KEYDOWN;
    procedure WMGetDlgCode(var Message: TMessage); message WM_GETDLGCODE;
    procedure CMDialogChar(var Message: TCMDialogChar); message CM_DIALOGCHAR;
    procedure WMEraseBkGnd(var Msg: TMessage); message WM_ERASEBKGND;
    procedure HideTimerOnTime(Sender: TObject);
  protected
    procedure Loaded; override;
    procedure Paint; override;
    function GetParentWnd: HWnd;
    procedure CreateParams(var Params: TCreateParams); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;

    procedure SetRegion;

    property HideOnDeActivate: Boolean read FHideOnDeActivate write FHideOnDeActivate;
    property ShowBorder: Boolean read FShowBorder write FShowBorder;
    property BorderColor: TColor read FBorderColor write FBorderColor;
  public
    constructor Create(AOwner: TComponent); override;
    constructor CreateNew(AOwner: TComponent; Dummy: Integer = 0); override;
    destructor Destroy; override;
    procedure SetBounds(ALeft, ATop, AWidth, AHeight: Integer); override;
  published
{$IFDEF TMSDOTNET}
    property AutoScroll;
    property BorderIcons;
    property BorderWidth;
    property Ctl3D;
    property FormStyle;
    property OnHide;
{$ENDIF}
  end;

  TAdvCustomShapeButton = class(TCustomControl, IWinStyle)
  private
    FMenuFrame: TFrameWindow;
    FGroupIndex: Integer;
    FDown: Boolean;
    FAllowAllUp: Boolean;
    FOffSet: integer;
    FMouseInControl: Boolean;
    FHot: Boolean;
    FOnMouseLeave: TNotifyEvent;
    FOnMouseEnter: TNotifyEvent;
    FStyle: TAdvToolButtonStyle;
    FState: TAdvButtonState;
    FMouseDownInControl: Boolean;
    FGrouped: Boolean;
    FDragging: Boolean;
    FPropHot: Boolean;
    FUnHotTimer: TTimer;
    FInitialDown: Boolean;
    FOfficeHint: TAdvHintInfo;
    FIPictureDown: TGDIPPicture;
    FIPictureDisabled: TGDIPPicture;
    FIPicture: TGDIPPicture;
    FIPictureHot: TGDIPPicture;
    FAdvPreviewMenu: TAdvPreviewMenu;
    FShortCutHint: TShortCutHintWindow;
    FShortCutHintPos: TShortCutHintPos;
    FShortCutHintText: string;
    FPreviewMenuOffSet: Integer;
    FInternalClick: Boolean;
    FIsAeroVista: Boolean;
{$IFDEF DELPHI_UNICODE}
    FRef: Boolean;
    FRefGlowButton: TAdvGlowButton;
{$ENDIF}
    FShowMenuTimer: TTimer;
    FCanShowMenu: Boolean;
    FMenuBeingShown: Boolean;
    FDoShowMenuHint: Boolean;
    FAppearance: TAdvShapeButtonAppearance;
    FLayout: TShapeButtonLayout;
    FAntiAlias: TAntiAlias;
    FFrame: TFrame;
    FUseGlobalColor: Boolean;
    procedure OnShowMenuTime(Sender: TObject);
    procedure UnHotTimerOnTime(Sender: TObject);
    procedure UpdateExclusive;
    procedure UpdateTracking;
    procedure ButtonDown;
    procedure InitializeFrame;
    procedure ShowMenu;
    procedure OnPictureChanged(Sender: TObject);
    procedure CMHintShow(var Message: TMessage); message CM_HINTSHOW;
    procedure WMLButtonDblClk(var Message: TWMLButtonDown); message WM_LBUTTONDBLCLK;
    procedure CMEnabledChanged(var Message: TMessage); message CM_ENABLEDCHANGED;
    procedure CMDialogChar(var Message: TCMDialogChar); message CM_DIALOGCHAR;
    procedure CMFontChanged(var Message: TMessage); message CM_FONTCHANGED;
    procedure CMTextChanged(var Message: TMessage); message CM_TEXTCHANGED;
    procedure CMSysColorChange(var Message: TMessage); message CM_SYSCOLORCHANGE;
    procedure CMMouseEnter(var Message: TMessage); message CM_MOUSEENTER;
    procedure CMMouseLeave(var Message: TMessage); message CM_MOUSELEAVE;
    procedure WMEraseBkGnd(var Message: TWMEraseBkGnd); message WM_ERASEBKGND;
    procedure WMPaint(var Message: TWMPaint); message WM_PAINT;
    procedure CMFocusChanged(var Message: TCMFocusChanged); message CM_FOCUSCHANGED;
    procedure WMKeyDown(var Message: TWMKeyDown); message WM_KEYDOWN;
{$IFNDEF TMSDOTNET}
    procedure CMButtonPressed(var Message: TMessage); message CM_BUTTONPRESSED;
{$ENDIF}
    procedure ShapePaint(Sender: TObject; Canvas: TCanvas; R: TRect);
    procedure OnPreviewMenuHide(Sender: TObject);
    procedure SetDown(Value: Boolean);
    procedure SetAllowAllUp(Value: Boolean);
    procedure SetGroupIndex(Value: Integer);
    procedure SetStyle(const Value: TAdvToolButtonStyle);
    procedure SetState(const Value: TAdvButtonState);
    procedure SetGrouped(const Value: Boolean);
    function GetVersion: string;
    procedure SetVersion(const Value: string);
    function GetHot: Boolean;
    procedure SetHot(const Value: Boolean);
    procedure SetOfficeHint(const Value: TAdvHintInfo);
    procedure SetIPicture(const Value: TGDIPPicture);
    procedure SetIPictureDisabled(const Value: TGDIPPicture);
    procedure SetIPictureDown(const Value: TGDIPPicture);
    procedure SetIPictureHot(const Value: TGDIPPicture);
    procedure SetAdvPreviewMenu(const Value: TAdvPreviewMenu);
    procedure SetAppearance(const Value: TAdvShapeButtonAppearance);
    procedure SetLayout(const Value: TShapeButtonLayout);
    procedure SetAntiAlias(const Value: TAntiAlias);
    procedure SetFrame(const Value: TFrame);
    procedure SetUseGlobalColor(const Value: Boolean);
    procedure HideMenuFrame(Sender: TObject);
  protected
    procedure Changed;
    procedure SetParent(AParent: TWinControl); override;
{$IFDEF DELPHI6_LVL}
    function GetActionLinkClass: TControlActionLinkClass; override;
    procedure ActionChange(Sender: TObject; CheckDefaults: Boolean); override;
{$ENDIF}
    procedure Loaded; override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure DrawButton(ACanvas: TCanvas); virtual;
    procedure DrawImage(ACanvas: TCanvas); virtual;
    procedure DrawShape(ACanvas: TCanvas; R: TRect);
    procedure ChangeStyle(AWin7: Boolean; AStyle: integer);
    procedure ChangeMenu(AColor: TColor);
    procedure UpdateMenu;
    procedure HideMenu;
    procedure ShowMenuShortCuts;
    procedure HideMenuShortCuts;
    procedure Paint; override;
    procedure WndProc(var Message: TMessage); override;
    procedure Notification(AComponent: TComponent; AOperation: TOperation); override;
    procedure DblClick; override;
    procedure SetAeroVista(Value: Boolean);

    procedure InvalidateMe;
    property MouseInControl: Boolean read FMouseInControl;
    property State: TAdvButtonState read FState write SetState;

    // published
    property Action;
    property AllowAllUp: Boolean read FAllowAllUp write SetAllowAllUp default False;
    property Anchors;
    property AntiAlias: TAntiAlias read FAntiAlias write SetAntiAlias default aaClearType;
    property BiDiMode;

    property Constraints;
    property Grouped: Boolean read FGrouped write SetGrouped default False;
    property GroupIndex: Integer read FGroupIndex write SetGroupIndex default 0;
    property Down: Boolean read FDown write SetDown default False;
    property Enabled;
    property Font;
    property Hot: Boolean read GetHot write SetHot default false;
    property Appearance: TAdvShapeButtonAppearance read FAppearance write SetAppearance;

    property Layout: TShapeButtonLayout read FLayout write SetLayout default plPictureCenter;
    property Picture: TGDIPPicture read FIPicture write SetIPicture;
    property PictureHot: TGDIPPicture read FIPictureHot write SetIPictureHot;
    property PictureDown: TGDIPPicture read FIPictureDown write SetIPictureDown;
    property PictureDisabled: TGDIPPicture read FIPictureDisabled write SetIPictureDisabled;

    property AdvPreviewMenu: TAdvPreviewMenu read FAdvPreviewMenu write SetAdvPreviewMenu;
    property Frame: TFrame read FFrame write SetFrame;

    property ParentFont;
    property ParentShowHint;
    property ParentBiDiMode;
    property PopupMenu;
    property ShowHint;
    property OfficeHint: TAdvHintInfo read FOfficeHint write SetOfficeHint;
    property Style: TAdvToolButtonStyle read FStyle write SetStyle default tasButton;
    property ShortCutHint: string read FShortCutHintText write FShortCutHintText;
    property ShortCutHintPos: TShortCutHintPos read FShortCutHintPos write FShortCutHintPos default shpCenter;
    property Version: string read GetVersion write SetVersion;
    property Visible;
    property OnClick;
    property OnDblClick;
    property OnMouseDown;
    property OnMouseMove;
    property OnMouseUp;
    property OnMouseEnter: TNotifyEvent read FOnMouseEnter write FOnMouseEnter;
    property OnMouseLeave: TNotifyEvent read FOnMouseLeave write FOnMouseLeave;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure Click; override;
{$IFDEF TMSDOTNET}
    procedure ButtonPressed(Group: Integer; Button: TAdvCustomShapeButton);
{$ENDIF}
    procedure SetBounds(ALeft, ATop, AWidth, AHeight: Integer); override;
    function GetVersionNr: Integer; virtual;

    procedure ShowShortCutHint;
    procedure HideShortCutHint;
    procedure InitializeStyle;
    procedure InitializeColors;
    property UseGlobalColor: Boolean read FUseGlobalColor write SetUseGlobalColor default false;
    procedure HideFrame;
    function GetFrameHeight: integer;
  end;

  TAdvShapeButton = class(TAdvCustomShapeButton)
  private
  public
  published
    property Appearance;
    property Action;
    property AdvPreviewMenu;
    property AllowAllUp;
    property AntiAlias;
    property Constraints;
    property GroupIndex;
    property Down;
    property Enabled;
    property Font;
    property Layout;
    property Picture;
    property PictureHot;
    property PictureDown;
    property PictureDisabled;
    property ParentFont;
    property ParentShowHint;
    property ParentBiDiMode;
    property PopupMenu;
    property OfficeHint;
    property ShowHint;
    property ShortCutHint;
    property ShortCutHintPos;
    property TabStop;
    property TabOrder;
    property Text;
    property Style;
    property Version;
    property Visible;
    property OnClick;
    property OnDblClick;
    property OnMouseDown;
    property OnMouseMove;
    property OnMouseUp;
    property OnMouseEnter;
    property OnMouseLeave;
    property Frame;
  end;

implementation

uses
  ActiveX
  {$IFDEF DELPHI7_LVL}
  , Themes
  {$ELSE}
  , AdvThemes
  {$ENDIF};

var
  WM_SBDRAWIMAGE, WM_SBDRAWBUTTON: Word;

type
  TVAlignment = (vtaTop,vtaCenter,vtaBottom);


//------------------------------------------------------------------------------

function Lighter(Color:TColor; Percent:Byte):TColor;
var
  r, g, b:Byte;
begin
  Color := ColorToRGB(Color);
  r := GetRValue(Color);
  g := GetGValue(Color);
  b := GetBValue(Color);
  r := r + muldiv(255 - r, Percent, 100); //Percent% closer to white
  g := g + muldiv(255 - g, Percent, 100);
  b := b + muldiv(255 - b, Percent, 100);
  result := RGB(r, g, b);
end;

function Darker(Color:TColor; Percent:Byte):TColor;
var
  r, g, b:Byte;
begin
  Color := ColorToRGB(Color);
  r := GetRValue(Color);
  g := GetGValue(Color);
  b := GetBValue(Color);
  r := r - muldiv(r, Percent, 100);  //Percent% closer to black
  g := g - muldiv(g, Percent, 100);
  b := b - muldiv(b, Percent, 100);
  result := RGB(r, g, b);
end;

function IsVista: boolean;
var
  hKernel32: HMODULE;
begin
  hKernel32 := GetModuleHandle('kernel32');
  if (hKernel32 > 0) then
  begin
    Result := GetProcAddress(hKernel32, 'GetLocaleInfoEx') <> nil;
  end
  else
    Result := false;
end;

//------------------------------------------------------------------------------

function IsComCtl6: Boolean;
var
  i: Integer;
begin
  i := GetFileVersion('COMCTL32.DLL');
  i := (i shr 16) and $FF;

  Result := (i > 5);
end;

//------------------------------------------------------------------------------

function AeroIsEnabled: boolean;
var
  enabled: bool;
begin
  Result := False;
  //if (DWMlibrary = 0) then
  begin
    if (@DwmIsCompositionEnabled <> nil) then
    begin
      DwmIsCompositionEnabled(enabled);
      Result := enabled;
    end;
  end;
end;

//------------------------------------------------------------------------------

procedure DrawGDIPImage(graphics: TGPGraphics; P: TPoint; Pic: TGDIPPicture);
var
  Img: TGPImage;
  pstm: IStream;
  hGlobal: THandle;
  pcbWrite: Longint;
  ms: TMemoryStream;
  ImageAttributes: TGPImageAttributes;
  r, g, b: byte;
  GPBmp: TGPBitmap;
  Aclr: TGPColor;
begin
  ms := TMemoryStream.Create;
  pic.SaveToStream(ms);
  hGlobal := GlobalAlloc(GMEM_MOVEABLE, ms.Size);
  if (hGlobal = 0) then
  begin
    ms.Free;
    raise Exception.Create('Could not allocate memory for image');
  end;

  try
    pstm := nil;

    // Create IStream* from global memory
    CreateStreamOnHGlobal(hGlobal, TRUE, pstm);
    pstm.Write(ms.Memory, ms.Size,@pcbWrite);

    Img := TGPImage.Create(pstm);

    if (Img.GetFormat = ifBMP) then
    begin

      GPBmp := TGPBitmap.Create(pstm);
      GPBmp.GetPixel(0, Img.GetHeight - 1, AClr);
      GPBmp.Free;

      r := ADVGDIP.GetRed(AClr);
      g := ADVGDIP.GetGreen(AClr);
      b := ADVGDIP.GetBlue(AClr);

      ImageAttributes := TGPImageAttributes.Create;
      ImageAttributes.SetColorKey(MakeColor(r, g, b), MakeColor(r, g, b), ColorAdjustTypeDefault);
      graphics.DrawImage(Img, MakeRect(P.X, P.Y, Img.GetWidth, Img.Getheight),  // destination rectangle
       0, 0,        // upper-left corner of source rectangle
       Img.GetWidth,       // width of source rectangle
       Img.GetHeight,      // height of source rectangle
       UnitPixel,
       ImageAttributes);

      //graphics.DrawImage(Img, P.X, P.y);

      ImageAttributes.Free;
    end
    else
      graphics.DrawImageRect(Img, p.X, p.Y, Img.GetWidth, Img.GetHeight);

    Img.Free;
    ms.Free;
  finally
    GlobalFree(hGlobal);
  end;
end;

//------------------------------------------------------------------------------

function DrawGDIPText(Canvas: TCanvas; g: TGPGraphics; Alignment: TAlignment; VAlign: TVAlignment; r: TRect; Caption:string; WideCaption: widestring; AFont: TFont; Enabled: Boolean; RealDraw: Boolean; AntiAlias: TAntiAlias): TRect;
var
  graphics : TGPGraphics;
  w,h: Integer;
  fontFamily: TGPFontFamily;
  font: TGPFont;
  rectf: TGPRectF;
  stringFormat: TGPStringFormat;
  solidBrush: TGPSolidBrush;
  x1,y1,x2,y2: single;
  fs: integer;
  sizerect: TGPRectF;
  szRect: TRect;
  DTFLAG: DWORD;
begin
  Result := Rect(0, 0, 0, 0);
  if not Assigned(g) and not Assigned(Canvas) then
    Exit;

  if (Caption <> '') or (WideCaption <> '') then
  begin
    graphics := g;
    if not Assigned(graphics) then
      graphics := TGPGraphics.Create(Canvas.Handle);
    fontFamily:= TGPFontFamily.Create(AFont.Name);

    if (fontFamily.Status in [FontFamilyNotFound, FontStyleNotFound]) then
    begin
      fontFamily.Free;
      fontFamily := TGPFontFamily.Create('Arial');
    end;


    fs := 0;

    if (fsBold in AFont.Style) then
      fs := fs + 1;

    if (fsItalic in AFont.Style) then
      fs := fs + 2;

    if (fsUnderline in AFont.Style) then
      fs := fs + 4;

    font := TGPFont.Create(fontFamily, AFont.Size , fs, UnitPoint);

    graphics.SetSmoothingMode(SmoothingModeAntiAlias);

    w := R.Right - R.Left;
    h := R.Bottom - R.Top;

    x1 := r.Left;
    y1 := r.Top;
    x2 := w;
    y2 := h;

    rectf := MakeRect(x1,y1,x2,y2);

    stringFormat := TGPStringFormat.Create;

    if Enabled then
      solidBrush := TGPSolidBrush.Create(ColorToARGB(AFont.Color))
    else
      solidBrush := TGPSolidBrush.Create(ColorToARGB(clGray));

    if not RealDraw then
    begin
      stringFormat.SetAlignment(StringAlignmentNear);
      stringFormat.SetLineAlignment(StringAlignmentNear);
    end
    else
    begin
    case Alignment of
      taLeftJustify: stringFormat.SetAlignment(StringAlignmentNear);
      taCenter:
      begin
        // Center-justify each line of text.
        stringFormat.SetAlignment(StringAlignmentCenter);
      end;
      taRightJustify: stringFormat.SetAlignment(StringAlignmentFar);
    end;

      case VAlign of
        vtaTop: stringFormat.SetLineAlignment(StringAlignmentNear);
        vtaBottom: stringFormat.SetLineAlignment(StringAlignmentFar);
        vtaCenter:
        begin
    // Center the block of text (top to bottom) in the rectangle.

    stringFormat.SetLineAlignment(StringAlignmentCenter);
        end;
      end;
    end;
    stringFormat.SetHotkeyPrefix(HotkeyPrefixShow);
    stringFormat.SetTrimming(StringTrimmingNone);


    case AntiAlias of
    aaClearType:graphics.SetTextRenderingHint(TextRenderingHintClearTypeGridFit);
    aaAntiAlias:graphics.SetTextRenderingHint(TextRenderingHintAntiAlias);
    end;

    // graphics.SetTextRenderingHint(TextRenderingHintClearTypeGridFit);

    if (AntiAlias = aaNone) then
    begin
      szRect.Left := round(rectf.X);
      szRect.Top := round(rectf.Y);

      szRect.Right := szRect.Left + 2;

      if (Caption <> '') then
        szRect.Bottom := DrawText(Canvas.Handle,PChar(Caption),Length(Caption), szrect, DT_CALCRECT or DT_LEFT or DT_WORDBREAK)
      else
        szRect.Bottom := DrawTextW(Canvas.Handle,PWideChar(WideCaption),Length(WideCaption), szrect, DT_CALCRECT or DT_LEFT or DT_WORDBREAK);

      sizeRect.X := szRect.Left;
      sizeRect.Y := szRect.Top;
      sizeRect.Width := szRect.Right - szRect.Left;
      sizeRect.Height := szRect.Bottom - szRect.Top;
    end
    else
    begin
      fillchar(sizerect,sizeof(sizerect),0);

      if (Caption <> '') then
        graphics.MeasureString(Caption, Length(Caption), font, rectf, stringFormat, sizerect)
      else
        graphics.MeasureString(WideCaption, Length(WideCaption), font, rectf, stringFormat, sizerect)
    end;

    Result := Rect(round(sizerect.X), Round(sizerect.Y), Round(sizerect.X + sizerect.Width), Round(sizerect.Y + sizerect.Height));
    rectf := MakeRect(x1,y1,x2,y2);

    if RealDraw then
    begin
      if (AntiAlias = aaNone) then
      begin
        szRect.Left := round(rectf.X);
        szRect.Top := round(rectf.Y);
        szRect.Right := szRect.Left + round(rectf.Width);
        szRect.Bottom := szRect.Top + round(rectf.Height);
        Canvas.Brush.Style := bsClear;

        DTFLAG := DT_LEFT;
        case Alignment of
        taRightJustify: DTFLAG := DT_RIGHT;
        taCenter: DTFLAG := DT_CENTER;
        end;
        if Caption <> '' then
          DrawText(Canvas.Handle,PChar(Caption),Length(Caption), szrect, DTFLAG or DT_VCENTER or DT_SINGLELINE)
        else
          DrawTextW(Canvas.Handle,PWideChar(WideCaption),Length(WideCaption), szrect, DTFLAG or DT_VCENTER or DT_SINGLELINE)
      end
      else
      begin
        if (Caption <> '') then
          graphics.DrawString(Caption, Length(Caption), font, rectf, stringFormat, solidBrush)
        else
          graphics.DrawString(WideCaption, Length(WideCaption), font, rectf, stringFormat, solidBrush)
      end;
    end;
    stringformat.Free;
    solidBrush.Free;
    font.Free;
    fontfamily.Free;
    if not Assigned(g) then
      graphics.Free;
  end;
end;

//------------------------------------------------------------------------------

procedure DrawBlurredText(WinCtrl: TWinControl; Canvas: TCanvas; Text: string; R: TRect; Align: TAlignment; Pic: TGDIPPicture);
{$IFDEF DELPHI2006_LVL}
  procedure DoDrawThemeTextEx(DC: HDC; const Text: string; TextLen: Integer;
    var TextRect: TRect; HTheme: THandle; TextFlags: Cardinal);
  var
    Options: TDTTOpts;
  begin
    FillChar(Options, SizeOf(Options), 0);
    Options.dwSize := SizeOf(Options);
    Options.dwFlags := DTT_TEXTCOLOR or DTT_COMPOSITED or DTT_GLOWSIZE {or DTT_SHADOWTYPE};
    Options.iGlowSize := 12;
    with ThemeServices.GetElementDetails(teEditTextNormal) do
      DrawThemeTextEx(HTheme{ThemeServices.Theme[teEdit]}, DC, Part, State,
        PWideChar(WideString(Text)), TextLen, TextFlags, @TextRect, Options);
  end;
{$ENDIF}
var
  HTheme: THandle;
  dc, hdcPaint: HDC;
  {$IFDEF DELPHI2006_LVL}
  dt: DTTOPTS;
  {$ENDIF}
  cx, cy: Integer;
  CR: TRect;
  dib: BITMAPINFO;
  hbm, hbmOld: HBITMAP;
  pr: Pointer;
  lgFont: LOGFONT;
  hFontOld, hFont: LongWord;
  R2: TRect;
begin
  HTheme := OpenThemeData(WinCtrl.Handle,'CompositedWindow::Window');
  if (HTheme > 0) then
  begin
    dc := GetDC(WinCtrl.Handle);
    hdcPaint := CreateCompatibleDC(dc);
    if (hdcPaint > 0) then
    begin
      CR := WinCtrl.ClientRect;
      cx := R.Right - R.Left;
      cy := R.Bottom - R.Top;

      dib.bmiHeader.biSize            := sizeof(BITMAPINFOHEADER);
      dib.bmiHeader.biWidth           := cx;
      dib.bmiHeader.biHeight          := -cy;
      dib.bmiHeader.biPlanes          := 1;
      dib.bmiHeader.biBitCount        := 32;{BIT_COUNT};
      dib.bmiHeader.biCompression     := BI_RGB;

      pr := nil;
      hbm := CreateDIBSection(dc, dib, DIB_RGB_COLORS, pr, 0, 0);
      if (hbm > 0) then
      begin
        hbmOld := HBITMAP(SelectObject(hdcPaint, hbm));

        {$IFDEF DELPHI2006_LVL}
        // Setup the theme drawing options.
        //dt := sizeof(DTTOPTS);
        dt.dwFlags := DTT_COMPOSITED or DTT_GLOWSIZE;
        dt.iGlowSize := 15;
        {$ENDIF}

        // Select a font.
        hFontOld := 0;
        hFont := 0;
        if (SUCCEEDED(GetThemeSysFont(hTheme, TMT_CAPTIONFONT, lgFont))) then
        begin
          hFont := CreateFontIndirect(lgFont);
          hFontOld := LongWord(SelectObject(hdcPaint, hFont));
        end;

        PostMessage(WinCtrl.Handle, WM_SBDRAWBUTTON, 0, 0);

        if Assigned(Pic) and not Pic.Empty then
        begin
          PostMessage(WinCtrl.Handle, WM_SBDRAWIMAGE, 0, 0);
        end;

        // Draw the title.
        R2 := Rect(4, R.Top + 6, cx, cy);
        {$IFDEF DELPHI2006_LVL}
        DoDrawThemeTextEx(hdcPaint, Text, Length(Text), R2, HTheme, DT_EXPANDTABS or DT_LEFT or DT_VCENTER or DT_END_ELLIPSIS);
        {$ENDIF}

        // Blit text to the frame.
        BitBlt(dc, R.Left, R.Top, cx, cy, hdcPaint, 0, 0, SRCCOPY);

        SelectObject(hdcPaint, hbmOld);
        if (hFontOld > 0) then
        begin
          SelectObject(hdcPaint, hFontOld);
          if (hFont > 0) then
            DeleteObject(hFont);
        end;

        DeleteObject(hbm);
      end;
      DeleteDC(hdcPaint);
    end;
    ReleaseDC(WinCtrl.Handle, dc);
    CloseThemeData(hTheme);
  end;
end;

//------------------------------------------------------------------------------
procedure DrawWin7Menu(Canvas: TCanvas; R: TGPRectF; c: TColor);
var
  g: TGPGraphics;
  l, t, w, h: Double;
  rl: TGPRectF;
  p: TGPPen;
  b: TGPBrush;
  path: TGPGraphicsPath;
begin
  g := TGPGraphics.Create(Canvas.Handle);
  h := r.Height;
  w := r.Width;
  l := r.X;
  t := r.Y;
  t := t + 1 + (h - 12) / 2;
  l := l + (w - 28) / 2;

  rl := MakeRect(l, t, 16, 12);
  p := TGPPEN.Create(MakeColor(40, clBlack));
  g.DrawRectangle(p, rl);
  p.Free;

  rl := MakeRect(l + 1, t, 4, 11);
  b := TGPSolidBrush.Create(MakeColor(255, c));
  g.FillRectangle(b, rl);
  b.Free;

  rl := MakeRect(l + 2, t + 2, 2, 9);
  b := TGPLinearGradientBrush.Create(MakeRect(rl.X - 1, rl.Y - 1, rl.Width + 2, rl.Height + 2),
    MakeColor(0, clWhite), MakeColor(50, clGray), LinearGradientModeVertical);
  g.FillRectangle(b, rl);
  b.Free;

  rl := MakeRect(l + 5, t, 1, 11);
  b := TGPSolidBrush.Create(MakeColor(200, c));
  g.FillRectangle(b, rl);
  b.Free;

  rl := MakeRect(l + 6, t, 2, 11);
  b := TGPSolidBrush.Create(MakeColor(255, c));
  g.FillRectangle(b, rl);
  b.Free;

  rl := MakeRect(l + 14, t, 2, 11);
  b := TGPSolidBrush.Create(MakeColor(255, c));
  g.FillRectangle(b, rl);
  b.Free;

  p := TGPPen.Create(MakeColor(255, c), 2);
  g.DrawLine(p, l + 6, t + 1, l + 14, t + 1);
  p.Free;

  p := TGPPen.Create(MakeColor(255, c));
  g.DrawLine(p, l + 6, t + 4, l + 14, t + 4);
  p.Free;

  p := TGPPen.Create(MakeColor(255, c));
  g.DrawLine(p, l + 6, t + 6, l + 14, t + 6);
  p.Free;

  p := TGPPen.Create(MakeColor(255, c));
  g.DrawLine(p, l + 6, t + 8, l + 14, t + 8);
  p.Free;

  p := TGPPen.Create(MakeColor(255, c), 2);
  g.DrawLine(p, l + 6, t + 10, l + 14, t + 10);
  p.Free;

  path := TGPGraphicsPath.Create;
  path.AddLine(l + 20, t + 5, l + 27, t + 5);
  path.AddLine(l + 23.5, t + 9, l + 23.5, t + 9);
  path.CloseFigure;
  b := TGPSolidBrush.Create(MakeColor(255, c));
  g.FillPath(b, path);
  b.Free;
  path.Free;

  path := TGPGraphicsPath.Create;
  path.AddLine(l + 19, t + 4, l + 28, t + 4);
  path.AddLine(l + 23.5, t + 10, l + 23.5, t + 10);
  path.CloseFigure;
  p := TGPPen.Create(MakeColor(40, clBlack));
  g.DrawPath(p, path);
  p.Free;
  path.Free;


  g.Free;
end;

procedure DrawWinVOrb(Canvas: TCanvas; R: TGPRectF; b, bin, c, cto, cm, cmto: TColor);
var
  g: TGPGraphics;
  bl: TGPBrush;
  ri, rl: TGPRectF;
  bp: TGPPathGradientBrush;
  pth: TGPGraphicsPath;
  count: integer;
  colors : array[0..1] of TGPColor;
  points : array[0..2] of TGPPointF;
  pn: TGPPen;
begin
  g := TGPGraphics.Create(Canvas.Handle);
  g.SetSmoothingMode(SmoothingModeAntiAlias);
  bl := TGPSolidBrush.Create(MakeColor(80, b));
  g.FillEllipse(bl, R);
  bl.Free;

  ri := MakeRect(R.X + 1, r.Y + 1, r.Width - 3, R.Height - 3);
  bl := TGPLinearGradientBrush.Create(Makerect(ri.X - 1, ri.Y - 1, ri.Width + 2, ri.Height + 2),
    MakeColor(220, c), MakeColor(220, cTo), LinearGradientModeVertical);

  g.FillEllipse(bl, ri);
  bl.Free;


  pth := TGPGraphicsPath.Create;
  pth.AddEllipse(ri.X + ri.Width / 8, ri.Y + ri.Height / 3, ri.Width - (ri.Width / 8) * 2, ri.Height - ri.Height / 3);
  bp := TGPPathGradientBrush.Create(pth);
  bp.SetCenterColor(MakeColor(120, clWhite));
  colors[0] := MakeColor(0, clWhite);
  count := 1;
  bp.SetSurroundColors(@colors, count);
  g.FillPath(bp, pth);
  bp.Free;
  pth.Free;


  pth := TGPGraphicsPath.Create;
  pth.AddEllipse(ri.X + ri.Width / 4, ri.Y, ri.Width - (ri.Width / 4) * 2, ri.Height / 5);
  bp := TGPPathGradientBrush.Create(pth);
  bp.SetCenterColor(MakeColor(50, clWhite));
  colors[0] := MakeColor(0, clWhite);
  count := 1;
  bp.SetSurroundColors(@colors, count);
  g.FillPath(bp, pth);
  bp.Free;
  pth.Free;


  pth := TGPGraphicsPath.Create;
  rl := MakeRect(ri.X + 2, ri.Y + 2, ri.Width - 4, ri.Height - 4);
  pth.AddArc(rl, 200, 140);
  points[0] := MakePoint(rl.X + rl.Width, rl.Y + 4 + ri.Height / 3);
  points[1] := MakePoint(rl.X + rl.Width / 2, rl.Y + 4 + ri.Height / 4);
  points[2] := MakePoint(rl.X, rl.Y + 4 + ri.Height / 3);
  count := 3;
  pth.AddCurve(PGPPointF(@points), count);
  bl := TGPSolidBrush.Create(MakeColor(70, clWhite));
  g.FillPath(bl, pth);
  bl.Free;
  pth.Free;

  pn := TGPPen.Create(MakeColor(100, bin));
  g.DrawEllipse(pn, ri);
  pn.Free;


  g.Free;
end;

//------------------------------------------------------------------------------

procedure DrawWin7Button(Canvas: TCanvas; R: TGPRectF; b, bin, c, cto, cm, cmto: TColor);
var
  path: TGPGraphicsPath;
  d, l, t, w, h: Double;
  g: TGPGraphics;
  bl: TGPLinearGradientBrush;
  rl, rr, rb, ro, rt: TGPRectF;
  p: TGPPen;
const
  rd: integer = 3;
begin
  g := TGPGraphics.Create(Canvas.Handle);
  g.SetSmoothingMode(SmoothingModeAntiAlias);
  l := R.X;
  t := R.Y;
  w := r.Width;
  h := r.Height;
  d := rd shl 1;
  path := TGPGraphicsPath.Create;
  path.AddLine(l, t, l + w - rd, t); // top
  path.AddArc(l + w - d, t, d, d, 270, 90); // topright
  path.AddLine(l + w, t + rd, l + w, t + h); // right
  path.AddLine(l + w, t + h, l, t + h); // bottom
  path.AddLine(l, t + h, l, t); // left

  p := TGPPEN.Create(MakeColor(255, b));
  g.DrawPath(p, path);
  p.free;
  path.Free;

  Rb := MakeRect(r.X + 1, r.Y + 1, r.Width - 2, r.Height - 2);

  rt := MakeRect(rb.X - 0.5, rb.Y, rb.Width + 1 , rb.Height / 2);
  ro := MakeRect(rb.X - 0.5, rb.Y + (rb.Height / 2), rb.Width + 1, (rb.Height / 2) + 1);

  bl := TGPLinearGradientBrush.Create(MakeRect(rt.X - 1, rt.Y - 1, rt.Width + 2, rt.Height + 2), MakeColor(255, c), Makecolor(255, cto), LinearGradientModeVertical);
  g.FillRectangle(bl, rt);
  bl.Free;

  bl := TGPLinearGradientBrush.Create(MakeRect(ro.X - 1, ro.Y - 1, ro.Width + 2, ro.Height + 2), MakeColor(255, cm), Makecolor(255, cmto), LinearGradientModeVertical);
  g.FillRectangle(bl, ro);
  bl.Free;

  l := Rb.X;
  t := Rb.Y;
  w := rb.Width;
  h := rb.Height;


  path := TGPGraphicsPath.Create;
  path.AddLine(l, t, l + w - rd, t); // top
  path.AddArc(l + w - d, t, d, d, 270, 90); // topright

  p := TGPPEN.Create(MakeColor(255, bin));
  g.DrawPath(p, path);
  p.Free;
  path.Free;

  rl := MakeRect(l - 0.5, t, 1, h / 3 * 2);
  rr := MakeRect(l + w, t + rd, 1, h / 3 * 2);
  bl := TGPLinearGradientBrush.Create(MakeRect(rl.X - 1, rl.Y - 1, rl.Width + 2, rl.Height + 2), MakeColor(255, bin), Makecolor(0, clWhite), LinearGradientModeVertical);
  g.FillRectangle(bl, rl);
  bl.Free;

  bl := TGPLinearGradientBrush.Create(MakeRect(rr.X - 1, rr.Y - 1, rr.Width + 2, rr.Height + 2), MakeColor(255, bin), Makecolor(0, clWhite), LinearGradientModeVertical);
  g.FillRectangle(bl, rr);
  bl.Free;

  g.Free;
end;

//------------------------------------------------------------------------------

procedure DrawOff2010Button(Canvas: TCanvas; R: TGPRectF; b, bin, c, cto, cm, cmto: TColor; GlowClr: Cardinal);
var
  path: TGPGraphicsPath;
  d, l, t, w, h: Double;
  g: TGPGraphics;
  bl: TGPLinearGradientBrush;
  rb, rm, rt: TGPRectF;
  p: TGPPen;
  pthGrBrush: TGPPathGradientBrush;
  colors : array[0..0] of TGPColor;
  Count: Integer;
  rgn: TGPRegion;
const
  rd: integer = 3;
begin

  g := TGPGraphics.Create(Canvas.Handle);
  g.SetSmoothingMode(SmoothingModeHighQuality);

  l := R.X;
  t := R.Y;
  w := r.Width;
  h := r.Height;
  d := rd shl 1;

  rt := MakeRect(l + 1, t + 1, w - 2, 1 + Round(h / 3));
  rm := MakeRect(l + 1, t + h / 3, w - 2, h / 3);
  Rb := MakeRect(l + 1, t + h - (h / 3), w - 2, h / 3);

  path := TGPGraphicsPath.Create;
  path.AddArc(l + 1, t + 1, d, d, 180, 90); // topleft
  path.AddLine(l + rd + 1, t + 1, l + w - rd - 1, t + 1); // top
  path.AddArc(l + w - d - 1, t + 1, d, d, 270, 90); // topright
  path.AddLine(l + w - 1, t + rd + 1, l + w -  1, t + h - 1); // right
  path.AddLine(l + w - 1, t + h - 1, l + 1, t + h - 1); // bottom
  path.AddLine(l + 1, t + h - 1, l + 1, t + rd + 1); // left

  rgn := TGPRegion.Create(path);
  g.SetClip(path);

  bl := TGPLinearGradientBrush.Create(rm, MakeColor(255, cto), Makecolor(255, cto), LinearGradientModeVertical);
  g.FillRectangle(bl, rm);
  bl.Free;

  bl := TGPLinearGradientBrush.Create(rt, ColorToARGB(c), ColorToARGB(cto){Makecolor(255, cto)}, LinearGradientModeVertical);
  g.FillRectangle(bl, rt);
  bl.Free;

  bl := TGPLinearGradientBrush.Create(rb, MakeColor(255, cto), Makecolor(255, c), LinearGradientModeVertical);
  g.FillRectangle(bl, rb);
  bl.Free;

  g.ResetClip;
  rgn.Free;

  path.Free;

  path := TGPGraphicsPath.Create;
  path.AddArc(l + 1, t + 1, d, d, 180, 90); // topleft
  path.AddLine(l + rd + 1, t + 1, l + w - rd - 1, t + 1); // top
  path.AddArc(l + w - d - 1, t + 1, d, d, 270, 90); // topright
  path.AddLine(l + w - 1, t + rd + 1, l + w -  1, t + h - 1); // right
  path.AddLine(l + w - 1, t + h - 1, l + 1, t + h - 1); // bottom
  path.AddLine(l + 1, t + h - 1, l + 1, t + rd + 1); // left

  p := TGPPen.Create(MakeColor(255, bin));
  g.DrawPath(p, path);
  path.Free;

  path := TGPGraphicsPath.Create;
  path.AddArc(l, t, d, d, 180, 90); // topleft
  path.AddLine(l + rd, t, l + w - rd, t); // top
  path.AddArc(l + w - d, t, d, d, 270, 90); // topright
  path.AddLine(l + w, t + rd, l + w, t + h); // right
  path.AddLine(l + w, t + h, l, t + h); // bottom
  path.AddLine(l, t + h, l, t + rd); // left

  p := TGPPEN.Create(MakeColor(255, b));
  g.DrawPath(p, path);
  p.free;

  path.Free;


  path := TGPGraphicsPath.Create;
  path.AddEllipse(l + 4, t + h / 2, w - 6, h);
  pthGrBrush := TGPPathGradientBrush.Create(path);
  pthGrBrush.SetCenterPoint(MakePoint(l + (w - 8) / 2, t + h + 3));
  pthGrBrush.SetCenterColor(GlowClr{ColorToARGB(bin)});
  colors[0] := MakeColor(0, bin);
  count := 1;
  pthGrBrush.SetSurroundColors(@colors, count);
  g.FillRectangle(pthGrBrush, l + 4, t + h / 2, w - 4, h);
  pthGrBrush.Free;
  path.Free;




  g.Free;





end;

//------------------------------------------------------------------------------

{$IFDEF DELPHI6_LVL}

{ TAdvShapeButtonActionLink }

procedure TAdvShapeButtonActionLink.AssignClient(AClient: TObject);
begin
  inherited AssignClient(AClient);
  FClient := AClient as TAdvCustomShapeButton;
end;

//------------------------------------------------------------------------------

function TAdvShapeButtonActionLink.IsCheckedLinked: Boolean;
begin
  Result := inherited IsCheckedLinked {and (FClient.GroupIndex <> 0) and
    FClient.AllowAllUp} and (FClient.Down = (Action as TCustomAction).Checked);
end;

//------------------------------------------------------------------------------

function TAdvShapeButtonActionLink.IsGroupIndexLinked: Boolean;
begin
  Result := (FClient is TAdvCustomShapeButton) and
    (TAdvCustomShapeButton(FClient).GroupIndex = (Action as TCustomAction).GroupIndex);
end;

//------------------------------------------------------------------------------

procedure TAdvShapeButtonActionLink.SetChecked(Value: Boolean);
begin
  if IsCheckedLinked then TAdvCustomShapeButton(FClient).Down := Value;
end;

//------------------------------------------------------------------------------

procedure TAdvShapeButtonActionLink.SetGroupIndex(Value: Integer);
begin
  if IsGroupIndexLinked then TAdvCustomShapeButton(FClient).GroupIndex := Value;
end;

{$ENDIF}

//------------------------------------------------------------------------------

{ TAdvCustomShapeButton }

constructor TAdvCustomShapeButton.Create(AOwner: TComponent);
begin
{$IFNDEF DELPHI6_LVL}
  FIsAeroVista := False;
{$ELSE}
  FIsAeroVista := IsComCtl6 and IsVista and ThemeServices.ThemesEnabled and AeroIsEnabled and not (csDesigning in ComponentState);
{$ENDIF}

{$IFNDEF TMS_DWM}
  FIsAeroVista := False;
{$ENDIF}
  inherited Create(AOwner);

  if (csDesigning in ComponentState) then
    FIsAeroVista := False;

  //ControlStyle := [csCaptureMouse, csDoubleClicks, csClickEvents];
  ControlStyle := ControlStyle + [csCaptureMouse, csDoubleClicks, csClickEvents];
  {$IFDEF DELPHI7_LVL}
  if FIsAeroVista then
    ControlStyle := ControlStyle + [csParentBackground] - [csOpaque];
  {$ENDIF}

  FAppearance := TAdvShapeButtonAppearance.Create(Self);
  FLayout := plPictureCenter;
  FAntiAlias := aaClearType;

  FIPicture := TGDIPPicture.Create;
  FIPicture.OnChange := OnPictureChanged;

  FIPictureHot := TGDIPPicture.Create;
  FIPictureDown := TGDIPPicture.Create;

  FIPictureDisabled := TGDIPPicture.Create;
  FIPictureDisabled.OnChange := OnPictureChanged;

  SetBounds(0, 0, 23, 22);
  ControlStyle := [csCaptureMouse, csDoubleClicks, csClickEvents];
  ParentFont := True;

  // make sure to use a Truetype font
  Font.Name := 'Tahoma';

  FUseGlobalColor := false;

  FOffSet := 4;

  FStyle := tasButton;
  FGroupIndex := 0;
  FGrouped := true;

  FUnHotTimer := TTimer.Create(self);
  FUnHotTimer.Interval := 1;
  FUnHotTimer.Enabled := false;
  FUnHotTimer.OnTimer := UnHotTimerOnTime;

  FOfficeHint := TAdvHintInfo.Create;
  FShortCutHint := nil;
  FShortCutHintPos := shpCenter;
  FShortCutHintText := '';

  ShowHint := False;
  if not FIsAeroVista then
    DoubleBuffered := True;

  {$IFDEF DELPHI7_LVL}
  if FIsAeroVista then
    ParentBackground := True;
  {$ENDIF}

{$IFDEF DELPHI_UNICODE}
  if FIsAeroVista then
  begin
    FRefGlowButton := TAdvGlowButton.Create(Self);
    with FRefGlowButton do
    begin
      Parent := Self;
      Align := alNone;
      Left := 1;
      Top := 1;
      Height := 1;
      Width := 1;
      TabStop := False;
      Transparent := true;
    end;
  end;
{$ENDIF}
  //Width := 32;
  //Height := 32;
  FShowMenuTimer := TTimer.Create(Self);
  FShowMenuTimer.Enabled := False;
  FShowMenuTimer.Interval := 100;
  FShowMenuTimer.OnTimer := OnShowMenuTime;
end;

//------------------------------------------------------------------------------

destructor TAdvCustomShapeButton.Destroy;
begin
  if Assigned(FMenuFrame) then
  begin
    if FMenuFrame.Visible then
      FMenuFrame.Hide;
  end;

  if Assigned(FShortCutHint) then
    FShortCutHint.Free;

  FAppearance.Free;
  FIPicture.Free;
  FIPictureHot.Free;
  FIPictureDown.Free;
  FIPictureDisabled.Free;
  FUnHotTimer.Free;
  FOfficeHint.Free;
  inherited;
end;

//------------------------------------------------------------------------------

procedure TAdvCustomShapeButton.CMDialogChar(var Message: TCMDialogChar);
begin
  inherited;

end;

//------------------------------------------------------------------------------

procedure TAdvCustomShapeButton.CMEnabledChanged(var Message: TMessage);
begin
  inherited;
  Invalidate;
end;

//------------------------------------------------------------------------------

procedure TAdvCustomShapeButton.CMFontChanged(var Message: TMessage);
begin
  inherited;
end;

//------------------------------------------------------------------------------

procedure TAdvCustomShapeButton.CMMouseEnter(var Message: TMessage);
begin
  inherited;
  if (csDesigning in ComponentState) then
    Exit;

  FMouseInControl := true;
  if Enabled then
  begin
    //if Assigned(FAdvToolBar) then
    begin
      //Hot := True;
    end;
    //Invalidate;
    DrawButton(Canvas);
    if Parent is TAdvToolBarPager then
      (Parent as TAdvToolBarPager).ShapeButtonRefreshed;
    //InvalidateMe;
  end;
  FUnHotTimer.Enabled := True;

  if Assigned(FOnMouseEnter) then
     FOnMouseEnter(Self);
end;

//------------------------------------------------------------------------------

procedure TAdvCustomShapeButton.CMMouseLeave(var Message: TMessage);
begin
  inherited;

  if (csDesigning in ComponentState) then
    exit;

  FUnHotTimer.Enabled := False;
  FMouseInControl := false;
  FHot := false;

  //if Assigned(FAdvToolBar) then
    //if not (FAdvToolBar.FInMenuLoop and FAdvToolBar.FMenuFocused) then
      //Hot := False;

  if Enabled then
  begin
    //Invalidate;
    DrawButton(Canvas);
    if Parent is TAdvToolBarPager then
      (Parent as TAdvToolBarPager).ShapeButtonRefreshed;
    //InvalidateMe;
  end;

  if Assigned(FOnMouseLeave) then
     FOnMouseLeave(Self);
end;

//------------------------------------------------------------------------------

procedure TAdvCustomShapeButton.CMSysColorChange(var Message: TMessage);
begin
  inherited;

end;

//------------------------------------------------------------------------------

procedure TAdvCustomShapeButton.CMTextChanged(var Message: TMessage);
begin
  inherited;
end;

//------------------------------------------------------------------------------

procedure TAdvCustomShapeButton.Loaded;
begin
  inherited;
  if (Down <> FInitialDown) then
    Down := FInitialDown;
end;

//------------------------------------------------------------------------------

procedure TAdvCustomShapeButton.MouseDown(Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  inherited;

  if (Button <> mbLeft) or not Enabled or (csDesigning in ComponentState) then
    Exit;

  FMouseDownInControl := true;

  ButtonDown;

  if not FDown then
  begin
    FState := absDown;
    Invalidate;
  end;

  if Style = tasCheck then
  begin
    FState := absDown;
    Repaint;
  end;

  FDragging := True;
end;

//------------------------------------------------------------------------------

procedure TAdvCustomShapeButton.MouseMove(Shift: TShiftState; X,
  Y: Integer);
var
  NewState: TAdvButtonState;
begin
  inherited;

  if (csDesigning in ComponentState) then
    Exit;

  if FDragging then
  begin
    if (not FDown) then NewState := absUp
    else NewState := absExclusive;

    if (X >= 0) and (X < ClientWidth) and (Y >= 0) and (Y <= ClientHeight) then
      if FDown then NewState := absExclusive else NewState := absDown;

    if (Style = tasCheck) and FDown then
    begin
      NewState := absDown;
    end;

    if NewState <> FState then
    begin
      FState := NewState;
      Invalidate;
    end;
  end
  else if not FMouseInControl then
    UpdateTracking;
end;

//------------------------------------------------------------------------------

procedure TAdvCustomShapeButton.MouseUp(Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
  DoClick: Boolean;
begin
  inherited;

  if (csDesigning in ComponentState) then
    exit;

  FMouseDownInControl := false;
  InvalidateMe;

  if FDragging then
  begin
    FDragging := False;
    DoClick := (X >= 0) and (X < ClientWidth) and (Y >= 0) and (Y <= ClientHeight);
    if FGroupIndex = 0 then
    begin
      // Redraw face in-case mouse is captured
      FState := absUp;
      FMouseInControl := False;
      FHot := false;

      if Style = tasCheck then
      begin
        SetDown(not FDown);
        FState := absUp;
      end;

      if DoClick and not (FState in [absExclusive, absDown]) then
        Invalidate;
    end
    else
      if DoClick then
      begin
        SetDown(not FDown);
        if FDown then Repaint;
      end
      else
      begin
        if FDown then
          FState := absExclusive;
        Repaint;
      end;
    //if DoClick then Click;
    UpdateTracking;
  end;
end;

//------------------------------------------------------------------------------

procedure TAdvCustomShapeButton.Notification(AComponent: TComponent;
  AOperation: TOperation);
begin
  inherited;

  if not (csDestroying in ComponentState) and (AOperation = opRemove) then
  begin
    if (AComponent = AdvPreviewMenu) then
      AdvPreviewMenu := nil;
  end;
end;

//------------------------------------------------------------------------------

procedure TAdvCustomShapeButton.WMLButtonDblClk(var Message: TWMLButtonDown);
begin
  FCanShowMenu := False;
  FMenuBeingShown := False;
  FMouseDownInControl := False;
  inherited;
  FMouseDownInControl := False;
end;

procedure TAdvCustomShapeButton.WMPaint(var Message: TWMPaint);
var
  DC, MemDC: HDC;
  MemBitmap, OldBitmap: HBITMAP;
  PS: TPaintStruct;
  {$IFNDEF DELPHI_UNICODE}
  dbl: boolean;
  {$ENDIF}
  p: TPoint;
  i: integer;
begin
  if Assigned(Parent) {and (Fill.ShadowOffset > 0) ?} then
  begin
    {$IFNDEF DELPHI_UNICODE}
    dbl := Parent.DoubleBuffered;
    Parent.DoubleBuffered := false;
    {$ENDIF}
    DC := Message.DC;
    i := SaveDC(DC);
    p := ClientOrigin;
    Windows.ScreenToClient(Parent.Handle, p);
    p.x := -p.x;
    p.y := -p.y;
    MoveWindowOrg(DC, p.x, p.y);
    SendMessage(Parent.Handle, WM_ERASEBKGND, DC, 0);
    SendMessage(Parent.Handle, WM_PAINT, DC, 0);
    if (Parent is TWinCtrl) then
      (Parent as TWinCtrl).PaintCtrls(DC, nil);
    RestoreDC(DC, i);
    {$IFNDEF DELPHI_UNICODE}
    Parent.DoubleBuffered := dbl;
    {$ENDIF}
  end;

  if not FDoubleBuffered or (Message.DC <> 0) then
  begin
    if not (csCustomPaint in ControlState) and (ControlCount = 0) then
      inherited
    else
      PaintHandler(Message);
  end
  else
  begin
    DC := GetDC(0);
    MemBitmap := CreateCompatibleBitmap(DC, ClientRect.Right, ClientRect.Bottom);
    ReleaseDC(0, DC);
    MemDC := CreateCompatibleDC(0);
    OldBitmap := SelectObject(MemDC, MemBitmap);
    try
      DC := BeginPaint(Handle, PS);
      Perform(WM_ERASEBKGND, MemDC, MemDC);
      Message.DC := MemDC;
      WMPaint(Message);
      Message.DC := 0;
      BitBlt(DC, 0, 0, ClientRect.Right, ClientRect.Bottom, MemDC, 0, 0, SRCCOPY);
      EndPaint(Handle, PS);
    finally
      SelectObject(MemDC, OldBitmap);
      DeleteDC(MemDC);
      DeleteObject(MemBitmap);
    end;
  end;
end;

//------------------------------------------------------------------------------

procedure TAdvCustomShapeButton.DblClick;
begin
  inherited;
end;

//------------------------------------------------------------------------------

procedure TAdvCustomShapeButton.SetAeroVista(Value: Boolean);
begin
  if (csDesigning in ComponentState) and Value then
    Exit;

  if (FIsAeroVista <> Value) then
  begin
    FIsAeroVista := Value;
    if FIsAeroVista then
    begin
      {$IFDEF DELPHI7_LVL}
        ControlStyle := ControlStyle + [csParentBackground] - [csOpaque];
      {$ENDIF}

      DoubleBuffered := False;

      {$IFDEF DELPHI7_LVL}
        ParentBackground := True;
      {$ENDIF}
    end
    else
    begin
      {$IFDEF DELPHI7_LVL}
      ControlStyle := ControlStyle - [csParentBackground] + [csOpaque];
      {$ENDIF}

      DoubleBuffered := True;

      {$IFDEF DELPHI7_LVL}
      ParentBackground := False;
      {$ENDIF}            
    end;
  end;
end;

//------------------------------------------------------------------------------

procedure TAdvCustomShapeButton.WndProc(var Message: TMessage);
begin
  inherited;

  if (Message.Msg = WM_TBSETAEROVISTA) then
  begin
    SetAeroVista(Bool(Message.WParam));
  end;

  if Message.Msg = WM_SBDRAWBUTTON then
  begin
    DrawShape(Canvas, Bounds(0, 0, Width - 1, Height - 1));
    DrawImage(Canvas);
  end;

  if (Message.Msg = WM_SBDRAWIMAGE) then
  begin
    DrawImage(Canvas);
  end;


  if (Message.Msg = WM_SETTEXT) then
    Invalidate;
end;

//------------------------------------------------------------------------------

procedure TAdvCustomShapeButton.Paint;
var
  Rgn1: HRGN;
  R: TRect;
  i: Integer;
  p: TPoint;
begin
  if not Enabled then
  begin
    FState := absDisabled;
    FDragging := False;
  end
  else
  begin
    if (FState = absDisabled) then
      if FDown and (GroupIndex <> 0) then
        FState := absExclusive
      else
        FState := absUp;
  end;

  if (Style = tasCheck) and (Down) then
  begin
    FState := absDown;
  end;

  if True and not FIsAeroVista then
  begin
    // TRANSPARENCY CODE

    R := ClientRect;
    rgn1 :=  CreateRectRgn(R.Left, R.Top, R.Right, R.Bottom);
    SelectClipRgn(Canvas.Handle, rgn1);

    i := SaveDC(Canvas.Handle);
    p := ClientOrigin;
    Windows.ScreenToClient(Parent.Handle, p);
    p.x := -p.x;
    p.y := -p.y;
    MoveWindowOrg(Canvas.Handle, p.x, p.y);

    SendMessage(Parent.Handle, WM_ERASEBKGND, Canvas.Handle, 0);
    // transparency ?
    SendMessage(Parent.Handle, WM_PAINT, Canvas.Handle, 0);

    if (Parent is TWinCtrl) then
     (Parent as TWinCtrl).PaintCtrls(Canvas.Handle, nil);

    RestoreDC(Canvas.Handle, i);

    SelectClipRgn(Canvas.Handle, 0);
    DeleteObject(rgn1);
  end;

  //inherited;

  DrawButton(Canvas);
end;

//------------------------------------------------------------------------------

procedure TAdvCustomShapeButton.DrawButton(ACanvas: TCanvas);
var
  Pic: TGDIPPicture;
  x, y: Integer;
  graphics: TGPGraphics;
  R, TextR: TRect;
  VAlign: TVAlignment;
  //bmp: TBitmap;
begin

  R := ClientRect;
  if FIsAeroVista and not (IsGlass and IsWin7) then
  begin
    DrawBlurredText(Self, Self.Canvas, '', Rect(R.Left, R.Top, R.Right, 27 - Top), taLeftJustify, Picture);
    Canvas.Brush.Color := Color; //$00FFDBBF;
    Canvas.FillRect(Rect(R.Left, 27 - Top, R.Right, R.Bottom));
    Canvas.Pen.Color := clBlack;
    Canvas.MoveTo(R.Left, 28 - Top);
    Canvas.LineTo(R.Right, 28 - Top);
  end;

  DrawShape(Canvas, Bounds(0, 0, Width - 1, Height - 1));

  Pic := Picture;
  if not Enabled and not PictureDisabled.Empty then
    Pic := PictureDisabled
  else if ((FMouseDownInControl and FMouseInControl) or (Down) or ((Assigned(AdvPreviewMenu) and (TInternalAdvPreviewMenu(AdvPreviewMenu).visible))) or FMenuBeingShown) and not PictureDown.Empty then
    Pic := PictureDown
  else if (FMouseInControl or Self.Focused) and not PictureHot.Empty then
    Pic := PictureHot;

  TextR := R;
  VAlign := vtaCenter;
  if Assigned(Pic) and not Pic.Empty then
  begin
    Pic.GetImageSizes;
    x := (Width - Pic.Width) div 2;
    y := (Height - Pic.Height) div 2;

    case Layout of
      plPictureCenter: ;  // do nothing
      plPictureOnTop:
      begin
        TextR := Rect(0, 0, 1000, 500);
        TextR := DrawGDIPText(ACanvas, nil, taCenter, vtaTop, TextR, Text, '', Font, Enabled, False, AntiAlias);
        y := Max(2, (Height - Pic.Height - TextR.Bottom) div 2);
        TextR.Top := y + Pic.Height - 2;
        TextR.Bottom := R.Bottom;
        TextR.Right := R.Right;
        VAlign := vtaTop;
      end;
      plPictureAtBottom:
      begin
        TextR := Rect(0, 0, 1000, 500);
        TextR := DrawGDIPText(ACanvas, nil, taCenter, vtaTop, TextR, Text, '', Font, Enabled, False, AntiAlias);

        TextR.Top := Max(2, (Height - Pic.Height - TextR.Bottom) div 2);
        y := TextR.Top + TextR.Bottom;
        TextR.Left := R.Left;
        TextR.Right := R.Right;
        TextR.Bottom := y - 1;
        VAlign := vtaTop;
      end;
    end;

    if not FIsAeroVista then
    begin
      if Appearance.ShowPicture then
        ACanvas.Draw(x, y, Pic);
    end
    else
    begin
      graphics := TGPGraphics.Create(Canvas.Handle);
      graphics.SetSmoothingMode(SmoothingModeAntiAlias);
      if Appearance.ShowPicture then
        DrawGDIPImage(graphics, Point(x, y), Pic);
      graphics.Free;
    end;
  end
  else
  begin
    if (csDesigning in ComponentState) then
    begin
      if (Assigned(Pic) and (Pic.Empty)) and (Appearance.Shape = bsCustom) then
      begin
        ACanvas.Pen.Style := psDot;
        ACanvas.Pen.Color := clBlue;
        ACanvas.Brush.Style := bsClear;
        ACanvas.Rectangle(ClientRect);
      end;
    end;
  end;

  if not FIsAeroVista then
  begin
    DrawGDIPText(ACanvas, nil, taCenter, VAlign, TextR, Text, '', Font, Enabled, True, AntiAlias);
  end
  else
  begin
    graphics := TGPGraphics.Create(Canvas.Handle);
    graphics.SetSmoothingMode(SmoothingModeAntiAlias);
    DrawGDIPText(nil, graphics, taCenter, VAlign, TextR, Text, '', Font, Enabled, True, AntiAlias);
    graphics.Free;
  end;

{$IFDEF DELPHI_UNICODE}
  if FIsAeroVista then
  begin
    if FRef then
    begin
      FRef := False;
      if Assigned(FRefGlowButton) then
        FRefGlowButton.Invalidate;
    end
    else
      FRef := True;
  end;
{$ENDIF}
end;

//------------------------------------------------------------------------------

procedure TAdvCustomShapeButton.DrawImage(ACanvas: TCanvas);
var
  Pic: TGDIPPicture;
  x, y: Integer;
  graphics: TGPGraphics;
  R, TextR: TRect;
  VAlign: TVAlignment;
begin
  R := ClientRect;
  Pic := Picture;
  if not Enabled and not PictureDisabled.Empty then
    Pic := PictureDisabled
  else if ((FMouseDownInControl and FMouseInControl) or (Down) or ((Assigned(AdvPreviewMenu) and (TInternalAdvPreviewMenu(AdvPreviewMenu).visible))) or FMenuBeingShown) and not PictureDown.Empty then
    Pic := PictureDown
  else if (FMouseInControl or Self.Focused) and not PictureHot.Empty then
    Pic := PictureHot;

  TextR := R;
  VAlign := vtaCenter;
  if Assigned(Pic) and not Pic.Empty then
  begin
    Pic.GetImageSizes;
    x := (Width - Pic.Width) div 2;
    y := (Height - Pic.Height) div 2;

    case Layout of
      plPictureCenter: ;  // do nothing
      plPictureOnTop:
      begin
        TextR := Rect(0, 0, 1000, 500);
        TextR := DrawGDIPText(ACanvas, nil, taCenter, vtaTop, TextR, Text, '', Font, Enabled, False, AntiAlias);
        y := Max(2, (Height - Pic.Height - TextR.Bottom) div 2);
        TextR.Top := y + Pic.Height - 2;
        TextR.Bottom := R.Bottom;
        TextR.Right := R.Right;
        VAlign := vtaTop;
      end;
      plPictureAtBottom:
      begin
        TextR := Rect(0, 0, 1000, 500);
        TextR := DrawGDIPText(ACanvas, nil, taCenter, vtaTop, TextR, Text, '', Font, Enabled, False, AntiAlias);

        TextR.Top := Max(2, (Height - Pic.Height - TextR.Bottom) div 2);
        y := TextR.Top + TextR.Bottom;
        TextR.Left := R.Left;
        TextR.Right := R.Right;
        TextR.Bottom := y - 1;
        VAlign := vtaTop;
      end;
    end;


    if not FIsAeroVista then
    begin
      if Appearance.ShowPicture then
        ACanvas.Draw(x, y, Pic);
    end
    else
    begin
      graphics := TGPGraphics.Create(Canvas.Handle);
      graphics.SetSmoothingMode(SmoothingModeAntiAlias);
      if Appearance.ShowPicture then
        DrawGDIPImage(graphics, Point(x, y), Pic);
      graphics.Free;
    end;
  end
  else
  if (Text = '') and (csDesigning in ComponentState) then
  begin
    ACanvas.Pen.Style := psDot;
    ACanvas.Pen.Color := clBlue;
    ACanvas.Brush.Style := bsClear;
    ACanvas.Rectangle(ClientRect);
  end;

  if not FIsAeroVista then
  begin
    DrawGDIPText(ACanvas, nil, taCenter, VAlign, TextR, Text, '', Font, Enabled, True, AntiAlias);
  end
  else
  begin
    graphics := TGPGraphics.Create(Canvas.Handle);
    graphics.SetSmoothingMode(SmoothingModeAntiAlias);
    DrawGDIPText(nil, graphics, taCenter, VAlign, TextR, Text, '', Font, Enabled, True, AntiAlias);
    graphics.Free;
  end;
end;

//------------------------------------------------------------------------------

procedure TAdvCustomShapeButton.DrawShape(ACanvas: TCanvas; R: TRect);
var
  rg: TGPRectF;
  //g: TGPGraphics;
begin
  rg := MakeRect(r.Left, r.Top, r.Right - R.Left, r.Bottom - r.Top);
  if Appearance.Shape = bsRectangle then
  begin
    if {FIsAeroVista and }IsWIn7 and IsGlass then
    begin
      if not Enabled then
        DrawOff2010Button(ACanvas, Rg, Appearance.BorderColorDisabled, Appearance.InnerBorderColorDisabled, Appearance.ColorDisabled, Appearance.ColorDisabledTo,
          Appearance.ColorDisabledMirror, Appearance.ColorDisabledMirrorTo, MakeColor(60, clWhite))
      else if ((FMouseDownInControl and FMouseInControl) or (Down) or ((Assigned(AdvPreviewMenu) and (TInternalAdvPreviewMenu(AdvPreviewMenu).visible))) or FMenuBeingShown) then
        DrawOff2010Button(ACanvas, Rg, Appearance.BorderColorDown, Appearance.InnerBorderColorDown, Appearance.ColorDown, Appearance.ColorDownTo,
          Appearance.ColorDownMirror, Appearance.ColorDownMirrorTo, 0)
      else if (FMouseInControl or Self.Focused) then
        DrawOff2010Button(ACanvas, Rg, Appearance.BorderColorHot, Appearance.InnerBorderColorHot, Appearance.ColorHot, Appearance.ColorHotTo,
          Appearance.ColorHotMirror, Appearance.ColorHotMirrorTo, MakeColor(110, clWhite))
      else
        DrawOff2010Button(ACanvas, Rg, Appearance.BorderColor, Appearance.InnerBorderColor, Appearance.Color, Appearance.ColorTo,
          Appearance.ColorMirror, Appearance.ColorMirrorTo, MakeColor(60, clWhite));
    end
    else
    begin
      if not Enabled then
        DrawWin7Button(ACanvas, Rg, Appearance.BorderColorDisabled, Appearance.InnerBorderColorDisabled, Appearance.ColorDisabled, Appearance.ColorDisabledTo,
          Appearance.ColorDisabledMirror, Appearance.ColorDisabledMirrorTo)
      else if ((FMouseDownInControl and FMouseInControl) or (Down) or ((Assigned(AdvPreviewMenu) and (TInternalAdvPreviewMenu(AdvPreviewMenu).visible))) or FMenuBeingShown) then
        DrawWin7Button(ACanvas, Rg, Appearance.BorderColorDown, Appearance.InnerBorderColorDown, Appearance.ColorDown, Appearance.ColorDownTo,
          Appearance.ColorDownMirror, Appearance.ColorDownMirrorTo)
      else if (FMouseInControl or Self.Focused) then
        DrawWin7Button(ACanvas, Rg, Appearance.BorderColorHot, Appearance.InnerBorderColorHot, Appearance.ColorHot, Appearance.ColorHotTo,
          Appearance.ColorHotMirror, Appearance.ColorHotMirrorTo)
      else
        DrawWin7Button(ACanvas, Rg, Appearance.BorderColor, Appearance.InnerBorderColor, Appearance.Color, Appearance.ColorTo,
          Appearance.ColorMirror, Appearance.ColorMirrorTo);
    end;
  end
  else if Appearance.Shape = bsOrb then
  begin
    if not Enabled then
      DrawWinVOrb(ACanvas, Rg, Appearance.BorderColorDisabled, Appearance.InnerBorderColorDisabled, Appearance.ColorDisabled, Appearance.ColorDisabledTo,
        Appearance.ColorDisabledMirror, Appearance.ColorDisabledMirrorTo)
    else if ((FMouseDownInControl and FMouseInControl) or (Down) or ((Assigned(AdvPreviewMenu) and (TInternalAdvPreviewMenu(AdvPreviewMenu).visible))) or FMenuBeingShown) then
      DrawWinVOrb(ACanvas, Rg, Appearance.BorderColorDown, Appearance.InnerBorderColorDown, Appearance.ColorDown, Appearance.ColorDownTo,
        Appearance.ColorDownMirror, Appearance.ColorDownMirrorTo)
    else if (FMouseInControl or Self.Focused) then
      DrawWinVOrb(ACanvas, Rg, Appearance.BorderColorHot, Appearance.InnerBorderColorHot, Appearance.ColorHot, Appearance.ColorHotTo,
        Appearance.ColorHotMirror, Appearance.ColorHotMirrorTo)
    else
      DrawWinVOrb(ACanvas, Rg, Appearance.BorderColor, Appearance.InnerBorderColor, Appearance.Color, Appearance.ColorTo,
        Appearance.ColorMirror, Appearance.ColorMirrorTo)
  end;

  if Appearance.ShowMenuShape then
  begin
    if not Enabled then
      DrawWin7Menu(ACanvas, Rg, Appearance.MenuShapeColorDisabled)
    else if ((FMouseDownInControl and FMouseInControl) or (Down) or ((Assigned(AdvPreviewMenu) and (TInternalAdvPreviewMenu(AdvPreviewMenu).visible))) or FMenuBeingShown) then
      DrawWin7Menu(ACanvas, Rg, Appearance.MenuShapeColorDown)
    else if (FMouseInControl or Self.Focused) then
      DrawWin7Menu(ACanvas, Rg, Appearance.MenuShapeColorHot)
    else
      DrawWin7Menu(ACanvas, Rg, Appearance.MenuShapeColor)
  end;

  {
  g := TGPGraphics.Create(Canvas.Handle);
  g.SetSmoothingMode(SmoothingModeAntiAlias);
  DrawGDIPText(nil, g, taCenter, taAlignTop, R, Text, '', Font, Enabled, True, aaAntiAlias);
  g.free;
  }
end;

//------------------------------------------------------------------------------

{$IFNDEF TMSDOTNET}

procedure TAdvCustomShapeButton.UpdateExclusive;
var
  Msg: TMessage;
begin
  if (FGroupIndex <> 0) and (Parent <> nil) then
  begin
    Msg.Msg := CM_BUTTONPRESSED;
    Msg.WParam := FGroupIndex;
    Msg.LParam := Longint(Self);
    Msg.Result := 0;
    Parent.Broadcast(Msg);

    {if Assigned(FAdvToolBar) and not (Parent is TAdvCustomToolBar) then
      FAdvToolBar.Broadcast(Msg)
    else if Assigned(AdvToolBar) and (Parent is TAdvCustomToolBar) and Assigned(AdvToolBar.FOptionWindowPanel) then
      FAdvToolBar.FOptionWindowPanel.Broadcast(Msg);}
  end;
end;


procedure TAdvCustomShapeButton.UpdateMenu;
var
  pt: TPoint;
begin
  if Assigned(FMenuFrame) and (FMenuFrame.Visible) then
  begin
    Pt.X := 0;
    Pt.Y := Height;
    pt := ClientToScreen(pt);
    FMenuFrame.SetBounds(pt.X, pt.Y - 1, (Parent as TAdvToolBarPager).Width, GetFrameHeight);
    FFrame.SetBounds(0, 3, FMenuFrame.Width, FMenuFrame.Height - 3);
    FMenuFrame.SetRegion;
  end;
end;

{$ENDIF}

//------------------------------------------------------------------------------

{$IFDEF TMSDOTNET}

procedure TAdvCustomShapeButton.ButtonPressed(Group: Integer; Button: TAdvCustomShapeButton);
begin
  if (Group = FGroupIndex) and (Button <> Self) then
  begin
    if Button.Down and FDown then
    begin
      FDown := False;
      FState := absUp;
      if (Action is TCustomAction) then
        TCustomAction(Action).Checked := False;
      Invalidate;
    end;
    FAllowAllUp := Button.AllowAllUp;
  end;
end;

procedure TAdvCustomShapeButton.UpdateExclusive;
var
  I: Integer;
begin
  if (FGroupIndex <> 0) and (Parent <> nil) then
  begin
    for I := 0 to Parent.ControlCount - 1 do
      if Parent.Controls[I] is TSpeedButton then
        TAdvToolButton(Parent.Controls[I]).ButtonPressed(FGroupIndex, Self);
  end;
end;
{$ENDIF}

//------------------------------------------------------------------------------

procedure TAdvCustomShapeButton.UpdateTracking;
var
  P: TPoint;
begin
  if Enabled then
  begin
    GetCursorPos(P);
    FMouseInControl := not (FindDragTarget(P, True) = Self);
    if FMouseInControl then
      Perform(CM_MOUSELEAVE, 0, 0)
    else
      Perform(CM_MOUSEENTER, 0, 0);
  end;
end;

//------------------------------------------------------------------------------

procedure TAdvCustomShapeButton.SetAllowAllUp(Value: Boolean);
begin
  if FAllowAllUp <> Value then
  begin
    FAllowAllUp := Value;
    UpdateExclusive;
  end;
end;

//------------------------------------------------------------------------------

procedure TAdvCustomShapeButton.SetAntiAlias(const Value: TAntiAlias);
begin
  if (FAntiAlias <> Value) then
  begin
    FAntiAlias := Value;
    Invalidate;
  end;
end;

//------------------------------------------------------------------------------

procedure TAdvCustomShapeButton.SetAppearance(
  const Value: TAdvShapeButtonAppearance);
begin
  if FAppearance <> value then
  begin
    FAppearance.Assign(Value);
    Changed;
  end;
end;

//------------------------------------------------------------------------------

procedure TAdvCustomShapeButton.SetDown(Value: Boolean);
begin
  if (csLoading in ComponentState) then
    FInitialDown := Value;

  if (FGroupIndex = 0) and (Style = tasButton) then
    Value := False;

  if (Style = tasCheck) then
  begin
    FDown := Value;
    if FDown then
      FState := absDown
    else
      FState := absUp;
    Repaint;
    Exit;
  end;

  if Value <> FDown then
  begin
    if FDown and (not FAllowAllUp) then Exit;
    FDown := Value;
    if Value then
    begin
      if FState = absUp then Invalidate;
      FState := absExclusive
    end
    else
    begin
      FState := absUp;
      Repaint;
    end;
    if Value then UpdateExclusive;
  end;
end;

procedure TAdvCustomShapeButton.SetFrame(const Value: TFrame);
begin
  if Assigned(Value) then
  begin
    Value.Visible := false;
  end
  else
  begin
    if Assigned(FFrame) then
    begin
      FFrame.Visible := true;
    end;
  end;
  FFrame := Value;
end;

//------------------------------------------------------------------------------

procedure TAdvCustomShapeButton.SetGroupIndex(Value: Integer);
begin
  if FGroupIndex <> Value then
  begin
    FGroupIndex := Value;
    UpdateExclusive;
  end;
end;

//------------------------------------------------------------------------------

procedure TAdvCustomShapeButton.SetState(const Value: TAdvButtonState);
begin
  if FState <> Value then
  begin
    FState := Value;
    Changed;
  end;
end;

//------------------------------------------------------------------------------

procedure TAdvCustomShapeButton.SetStyle(const Value: TAdvToolButtonStyle);
begin
  if FStyle <> Value then
  begin
    FStyle := Value;
    Changed;
  end;
end;

procedure TAdvCustomShapeButton.SetUseGlobalColor(const Value: Boolean);
begin
  if FUseGlobalColor <> Value then
  begin
    FUseGlobalColor := Value;
    Changed;
  end;
end;

//------------------------------------------------------------------------------

procedure TAdvCustomShapeButton.InitializeColors;
var
  i: integer;
  tmsif: IWinStyle;
begin
  if IsWin7 then
  begin
    with Appearance do
    begin
      FBorderColor := $00BD6A41;
      FBorderColorHot := $00D58744;
      FBorderColorDown := $00BD6A41;
      FBorderColorDisabled := clGray;
      FInnerBorderColor := $00CFA079;
      FInnerBorderColorHot := $00F3CE9F;
      FInnerBorderColorDown := $00CFA079;
      FInnerBorderColorDisabled := clSilver;
      FColor := $00C68B49;
      FColorTo := $00B3692F;
      FColorMirror := $0088411A;
      FColorMirrorTo := $00CE9B40;

      FColorHot := $00EFB978;
      FColorHotTo := $00D28448;
      FColorHotMirror := $00AF4E11;
      FColorHotMirrorTo := $00FFFF96;

      FColorDown := $00C68B49;
      FColorDownTo := $00B3692F;
      FColorDownMirror := $0088411A;
      FColorDownMirrorTo := $00CE9B40;

      FColorDisabled := $00DBDBDB;
      FColorDisabledTo := $00C4C4C4;
      FColorDisabledMirror := $00AAAAAA;
      FColorDisabledMirrorTo := clSilver;

      if not IsGlass then
      begin
        FMenuShapeColorDisabled := clWhite;
        FMenuShapeColor := clWhite;
        FMenuShapeColorHot := clWhite;
        FMenuShapeColorDown := clWhite;
      end
      else
      begin
        FBorderColor := RGB(31, 72, 161);
        FInnerBorderColor := RGB(68, 135, 229);
        FColor := RGB(62, 125, 218);
        FColorTo := RGB(40, 96, 178);

        FInnerBorderColorHot := RGB(85, 161, 243);
        FColorHot := RGB(67, 126, 221);
        FColorHotTo := RGB(50, 103, 188);

        FBorderColorDown := RGB(31, 72, 161);
        FInnerBorderColorDown := RGB(68, 135, 229);
        FColorDown := RGB(62, 125, 218);
        FColorDownTo := RGB(40, 96, 178);
      end;
    end;
    if Assigned(Frame) then
    begin
      for I := 0 to Frame.ControlCount - 1 do
      begin
        if Frame.Controls[i].GetInterface(IWinStyle, tmsif) then
          tmsif.ChangeMenu(Color);
      end;
    end;
    Changed;
  end
  else
  begin
    with Appearance do
    begin
      FBorderColor := clWhite;
      FBorderColorHot := clWhite;
      FBorderColorDown := clWhite;
      FBorderColorDisabled := clWhite;
      FInnerBorderColor := clGray;
      FInnerBorderColorHot := clGray;
      FInnerBorderColorDown := clGray;
      FColor := RGB(152, 169, 197);
      FColorTo := RGB(228, 233, 239);
      FColorHot := 14408667;
      FColorHotTo := 14408667;
      FColorDown := 10724259;
      FColorDownTo := 10724259;
      FColorDisabled := clGray;
      FColorDisabledTo := clGray;
    end;
    Changed;
  end;
end;

procedure TAdvCustomShapeButton.InitializeFrame;
begin
  if (FMenuFrame = nil) then
  begin
    FMenuFrame := TFrameWindow.CreateNew(Self);
    FMenuFrame.BorderIcons := [];
    FMenuFrame.BorderStyle := bsNone;
    FMenuFrame.Ctl3D := false;
    FMenuFrame.FormStyle := fsStayOnTop;
    FMenuFrame.Visible := False;
    FMenuFrame.AutoScroll := False;
    FMenuFrame.BorderWidth := 0;
    FMenuFrame.ShowBorder := False;
    FMenuFrame.DoubleBuffered := True;
    FMenuFrame.OnHide := HideMenuFrame;
    {$IFDEF DELPHI6_LVL}
    FMenuFrame.DefaultMonitor := dmDesktop;
    {$ENDIF}
  end;
end;

procedure TAdvCustomShapeButton.InitializeStyle;
var
  hasCaption:boolean;
begin
  //in case embedded in AdvToolBar
  if (csDesigning in ComponentState) and not ((csReading in Owner.ComponentState)
    or (csLoading in Owner.ComponentState)) then
      InitializeColors;

  if IsWin7 then
  begin
    with Appearance do
    begin
      FShape := bsRectangle;

      if not IsGlass then
      begin
        FShowMenuShape := true;
      end
      else
      begin
        FShowMenuShape := false;
      end;
    end;

    hasCaption := true;

    if Parent is TAdvToolBarPager then
      if not (Parent as TAdvToolBarPager).Caption.Visible then
        hasCaption := false;

    if hasCaption then
      SetBounds(0, 30, 55, 24)
    else
      SetBounds(0, 3, 55, 24);

    Changed;
  end
  else
  begin
    with Appearance do
    begin
      FShape := bsOrb;
      FShowMenuShape := false;
    end;
    SetBounds(5, 6, 45, 45);
    Changed;
  end;
end;

procedure TAdvCustomShapeButton.InvalidateMe;
begin
  invalidate;
end;

//------------------------------------------------------------------------------

procedure TAdvCustomShapeButton.SetBounds(ALeft, ATop, AWidth,
  AHeight: Integer);
begin
  inherited;

end;

//------------------------------------------------------------------------------

procedure TAdvCustomShapeButton.SetGrouped(const Value: Boolean);
begin
  FGrouped := Value;
end;

//------------------------------------------------------------------------------

procedure TAdvCustomShapeButton.ButtonDown;
begin
  //State:= absDown;
//InvalidateMe;
end;

//------------------------------------------------------------------------------

{$IFNDEF TMSDOTNET}

procedure TAdvCustomShapeButton.CMButtonPressed(var Message: TMessage);
var
  Sender: TAdvCustomShapeButton;
begin
  if Message.WParam = FGroupIndex then
  begin
    Sender := TAdvCustomShapeButton(Message.LParam);
    if Sender <> Self then
    begin
      if Sender.Down and FDown then
      begin
        FDown := False;
        FState := absUp;
        if (Action is TCustomAction) then
          TCustomAction(Action).Checked := False;
        Invalidate;
      end;
      FAllowAllUp := Sender.AllowAllUp;
    end;
  end;
end;
{$ENDIF}

//------------------------------------------------------------------------------

{$IFDEF DELPHI6_LVL}

procedure TAdvCustomShapeButton.ActionChange(Sender: TObject; CheckDefaults: Boolean);
begin
  inherited ActionChange(Sender, CheckDefaults);
  if Sender is TCustomAction then
    with TCustomAction(Sender) do
    begin
      if CheckDefaults or (Self.GroupIndex = 0) then
        Self.GroupIndex := GroupIndex;
      //Self.ImageIndex := ImageIndex;
    end;
end;

//------------------------------------------------------------------------------

function TAdvCustomShapeButton.GetActionLinkClass: TControlActionLinkClass;
begin
  Result := TAdvShapeButtonActionLink;
end;
{$ENDIF}

//------------------------------------------------------------------------------

function TAdvCustomShapeButton.GetVersionNr: integer;
begin
  Result := MakeLong(MakeWord(BLD_VER,REL_VER),MakeWord(MIN_VER,MAJ_VER));
end;

//------------------------------------------------------------------------------

function TAdvCustomShapeButton.GetVersion: string;
var
  vn: Integer;
begin
  vn := GetVersionNr;
  Result := IntToStr(Hi(Hiword(vn)))+'.'+IntToStr(Lo(Hiword(vn)))+'.'+IntToStr(Hi(Loword(vn)))+'.'+IntToStr(Lo(Loword(vn)));
end;

//------------------------------------------------------------------------------

procedure TAdvCustomShapeButton.SetVersion(const Value: string);
begin

end;

//------------------------------------------------------------------------------

function TAdvCustomShapeButton.GetFrameHeight: integer;
var
  c: Integer;
begin
  c := 0;
  if ((Parent as TAdvToolBarPager).Parent is TForm) then
    if ((Parent as TAdvToolBarPager).Parent as TForm).WindowState = wsMaximized then
      c := GetSystemMetrics(SM_CYSIZEFRAME);

  if FIsAeroVista then
    Result := (Parent as TAdvToolBarPager).Parent.Height - (Height + c + GetSystemMetrics(SM_CYCAPTION) + GetSystemMetrics(SM_CXSIZEFRAME) * 2)
  else
    Result := (Parent as TAdvToolBarPager).Parent.Height - (Height + c + Top {GetSystemMetrics(SM_CYCAPTION)} + GetSystemMetrics(SM_CXSIZEFRAME) * 2)
end;

function TAdvCustomShapeButton.GetHot: Boolean;
begin
  Result := FPropHot;
end;

//------------------------------------------------------------------------------

procedure TAdvCustomShapeButton.SetHot(const Value: Boolean);
var
  OldV: Boolean;
begin
  OldV := FPropHot;
  FPropHot := Value;
  if (State <> absUp) then
    FPropHot := false;

  {if Assigned(FAdvToolBar) then
    FAdvToolBar.UpdateButtonHot(self)
  else }
    FPropHot := false;
  if OldV <> FPropHot then
    InvalidateMe;
end;

//------------------------------------------------------------------------------

procedure TAdvCustomShapeButton.UnHotTimerOnTime(Sender: TObject);
var
  CurP: TPoint;
begin
  GetCursorPos(CurP);
  CurP := ScreenToClient(CurP);
  if (not PtInRect(ClientRect, CurP)) then
  begin
    FUnHotTimer.Enabled := False;
    FMouseInControl := false;
    FHot := false;

    {if Assigned(FAdvToolBar) then
      if not (FAdvToolBar.FInMenuLoop and FAdvToolBar.FMenuFocused) then
        Hot := False; }

    if Enabled then
      InvalidateMe;
  end;
end;

//------------------------------------------------------------------------------

procedure TAdvCustomShapeButton.SetParent(AParent: TWinControl);
begin
  inherited;
  if FIsAeroVista and not (csDesigning in ComponentState) then
  begin
    if Assigned(Parent) and not (AParent.Parent is TAdvToolBarForm) then
    begin
      FIsAeroVista := False;
    {$IFDEF DELPHI7_LVL}
      ControlStyle := ControlStyle - [csParentBackground];
    {$ENDIF}
    DoubleBuffered := True;
    end;
  end;
end;

//------------------------------------------------------------------------------

procedure TAdvCustomShapeButton.SetOfficeHint(const Value: TAdvHintInfo);
begin
  FOfficeHint.Assign(Value);
end;

//------------------------------------------------------------------------------

procedure TAdvCustomShapeButton.SetIPicture(const Value: TGDIPPicture);
begin
  FIPicture.Assign(Value);
  Invalidate;
end;

//------------------------------------------------------------------------------

procedure TAdvCustomShapeButton.SetIPictureDisabled(const Value: TGDIPPicture);
begin
  FIPictureDisabled.Assign(Value);
  Invalidate;
end;

//------------------------------------------------------------------------------

procedure TAdvCustomShapeButton.SetIPictureDown(const Value: TGDIPPicture);
begin
  FIPictureDown.Assign(Value);
end;

//------------------------------------------------------------------------------

procedure TAdvCustomShapeButton.SetIPictureHot(const Value: TGDIPPicture);
begin
  FIPictureHot.Assign(Value);
end;

//------------------------------------------------------------------------------

procedure TAdvCustomShapeButton.SetLayout(const Value: TShapeButtonLayout);
begin
  if (FLayout <> Value) then
  begin
    FLayout := Value;
    Changed;
  end;
end;

//------------------------------------------------------------------------------

procedure TAdvCustomShapeButton.OnPictureChanged(Sender: TObject);
begin
  Invalidate;
end;

//------------------------------------------------------------------------------

procedure TAdvCustomShapeButton.SetAdvPreviewMenu(
  const Value: TAdvPreviewMenu);
begin
  if (FAdvPreviewMenu <> nil) then
  begin
    FAdvPreviewMenu.OnDrawButtonFrameTop := nil;
    TInternalAdvPreviewMenu(AdvPreviewMenu).OnPreviewHide := nil;
  end;

  FAdvPreviewMenu := Value;

  if Assigned(FAdvPreviewMenu) then
  begin
    FAdvPreviewMenu.OnDrawButtonFrameTop := ShapePaint;
    TInternalAdvPreviewMenu(AdvPreviewMenu).OnPreviewHide := OnPreviewMenuHide;
  end;
end;

//------------------------------------------------------------------------------

procedure TAdvCustomShapeButton.OnShowMenuTime(Sender: TObject);
begin
  FShowMenuTimer.Enabled := False;
  ShowMenu;
end;

//------------------------------------------------------------------------------

procedure TAdvCustomShapeButton.ShowMenu;
var
  Pt: TPoint;
  DoShowMenuHint: Boolean;
  W, H: Integer;
  R: TRect;
  chkpreview, chkframe: Boolean;
  I: Integer;
  tmsif: IWinStyle;
begin
  if not FCanShowMenu or (csDestroying in ComponentState) or (csDesigning in ComponentState) then
    Exit;

  DoShowMenuHint := (Assigned(FShortCutHint) and FShortCutHint.Visible and not FInternalClick) or FDoShowMenuHint;
  FDoShowMenuHint := False;

  chkframe := Assigned(Frame) and IsWin7 and IsGlass;
  chkpreview := (Assigned(AdvPreviewMenu) and not IsGlass) or (not chkframe);

  if chkpreview and Assigned(AdvPreviewMenu) then
  begin
    W := 0;
    H := 0;
    FPreviewMenuOffSet := 0;
    TInternalAdvPreviewMenu(AdvPreviewMenu).GetMenuSize(W, H);

    Pt.X := 0;
    if IsWin7 then
      pt.Y := -1
    else
      Pt.Y := Height - TInternalAdvPreviewMenu(AdvPreviewMenu).TopFrameHeight+2;

    pt := ClientToScreen(pt);

    {$IFDEF DELPHI7_LVL}
    r := Screen.MonitorFromPoint(pt).WorkareaRect;
    {$ELSE}
    SystemParametersInfo(SPI_GETWORKAREA, 0, @R, 0);
    {$ENDIF}

    if not IsWin7 then
      pt.X := pt.X - 3;

    if (pt.X + w) > R.Right then
    begin
      FPreviewMenuOffSet := (R.Right - (pt.X + w));
      pt.X := pt.X + FPreviewMenuOffSet; {-ve vlaue}
      FAdvPreviewMenu.OnDrawButtonFrameTop := ShapePaint;
      TInternalAdvPreviewMenu(AdvPreviewMenu).OnPreviewHide := OnPreviewMenuHide;
    end;

    //Apply button settings
    if IsWin7 then
    begin
      AdvPreviewMenu.SetMenuButtonAppearance(Appearance.BorderColorDown, Appearance.InnerBorderColorDown,
        Appearance.ColorDown, Appearance.ColorDownTo, Appearance.ColorDownMirror, Appearance.ColorDownMirrorTo,
        Appearance.MenuShapeColorDown, Appearance.ShowMenuShape, PictureDown, Text, Font);
    end;

    AdvPreviewMenu.ShowMenu(Pt.X, Pt.Y);
    if DoShowMenuHint then
      AdvPreviewMenu.ShowShortCutHints;
    FMenuBeingShown := False;
  end
  else if chkframe then
  begin

    Pt.X := 0;
    Pt.Y := Height;

    pt := ClientToScreen(pt);

    {$IFDEF DELPHI7_LVL}
    r := Screen.MonitorFromPoint(pt).WorkareaRect;
    {$ELSE}
    SystemParametersInfo(SPI_GETWORKAREA, 0, @R, 0);
    {$ENDIF}

    InitializeFrame;

    if Assigned(FMenuFrame) then
    begin
      if not FMenuFrame.Visible then
      begin
        FMenuFrame.Show;
        FMenuFrame.Visible := false;
        FMenuFrame.Left := pt.X;
        FMenuFrame.Top := pt.Y - 1;
        FMenuFrame.Width := (Parent as TAdvToolBarPager).Width;
        FMenuFrame.Height := GetFrameHeight;
        FMenuFrame.SetRegion;
        FMenuFrame.Visible := True;
        FFrame.Parent := FMenuFrame;
        FFrame.Visible := true;
        FFrame.Width := Width;
        FFrame.Left := 0;
        FFrame.Top := 3;
        FFrame.Width := FMenuFrame.Width;
        FFrame.Height := FMenuFrame.Height - 3;

        if DoShowMenuHint then
        begin
          for I := 0 to FFrame.ControlCount - 1 do
          begin
            if FFrame.Controls[I].GetInterface(IWinStyle, tmsif) then
              tmsif.ShowMenuShortCuts;
          end;
        end;

        FMenuBeingShown := False;
      end
      else
      begin
        FMenuFrame.Hide;
        for I := 0 to FFrame.ControlCount - 1 do
        begin
          if FFrame.Controls[I].GetInterface(IWinStyle, tmsif) then
            tmsif.HideMenuShortCuts;
        end;
      end;

      if FMenuFrame.Visible then
      begin
        if FFrame.ControlCount > 0 then
        begin
          if FFrame.Controls[0] is TWinControl then
          begin
            if FFrame.Controls[0].Visible then
              TWinControl(FFrame.Controls[0]).SetFocus;
          end;
        end;
      end;
    end;
  end;
end;

procedure TAdvCustomShapeButton.ShowMenuShortCuts;
begin
//
end;

//------------------------------------------------------------------------------

procedure TAdvCustomShapeButton.Changed;
begin
  InvalidateMe;
end;

procedure TAdvCustomShapeButton.ChangeMenu(AColor: TColor);
begin
//
end;

//------------------------------------------------------------------------------

procedure TAdvCustomShapeButton.ChangeStyle(AWin7: Boolean; AStyle: integer);
var
  tmsif: IWinStyle;
  i: integer;
  hasCaption: boolean;
begin
  //in case embedded in AdvToolBar
  if AWin7 then
  begin
    InitializeStyle;

    hasCaption := true;

    if Parent is TAdvToolBarPager then
      if not (Parent as TAdvToolBarPager).Caption.Visible then
        hasCaption := false;

    if hasCaption then
      SetBounds(0, 30, 55, 24)
    else
      SetBounds(0, 3, 55, 24);

    Changed;
  end
  else
  begin
    InitializeStyle;
    SetBounds(5, 6, 45, 45);
    Changed;
  end;

  //previewmenu
  if Assigned(AdvPreviewMenu) then
      AdvPreviewMenu.ChangeStyle(AWin7, AStyle);

  if Assigned(Frame) then
  begin
    for I := 0 to Frame.ControlCount - 1 do
    begin
      if Frame.Controls[i].GetInterface(IWinStyle, tmsif) then
        tmsif.ChangeStyle(AWin7, AStyle);
    end;
  end;
end;

procedure TAdvCustomShapeButton.Click;
begin
  if not FInternalClick then
    inherited;
  if (Assigned(AdvPreviewMenu) or Assigned(Frame)) and Enabled and not (csDestroying in ComponentState) and not (csDesigning in ComponentState) then
  begin
    FCanShowMenu := True;
    FDoShowMenuHint := Assigned(FShortCutHint) and FShortCutHint.Visible and not FInternalClick;
    FShowMenuTimer.Enabled := True;
    FMenuBeingShown := True;
    InvalidateMe;
  end;
end;

//------------------------------------------------------------------------------

procedure TAdvCustomShapeButton.ShapePaint(Sender: TObject;
  Canvas: TCanvas; R: TRect);
var
  Pic: TGDIPPicture;
  x, y: Integer;
  R1: TRect;
  VAlign: TVAlignment;
  Rgn: HRGN;
begin
  x := 0;
  y := 0;
  if (Appearance.Shape = bsOrb) and not IsWin7 then
    DrawShape(Canvas, Bounds(r.Left + 3 + X - FPreviewMenuOffset, R.top - (Height - TInternalAdvPreviewMenu(AdvPreviewMenu).TopFrameHeight+2 - y), Width - 1, Height - 1));

  VAlign := vtaCenter;
  if Appearance.ShowPicture then
  begin
    if IsWin7 then
      R1 := Rect(R.Left, R.top + 2, 0, 0)
    else
      R1 := Rect(R.Left + 3, R.top - (Height - TInternalAdvPreviewMenu(AdvPreviewMenu).TopFrameHeight+2 - y), 0, 0);

    Pic := Picture;
    if not Enabled and not PictureDisabled.Empty then
      Pic := PictureDisabled
    else if ((FMouseDownInControl and FMouseInControl) or (Assigned(AdvPreviewMenu) and (TInternalAdvPreviewMenu(AdvPreviewMenu).visible))) and not PictureDown.Empty then
      Pic := PictureDown
    else if FMouseInControl and not PictureHot.Empty then
      Pic := PictureHot;

    Rgn := CreateRectRgn(R.Left, R.Top, R.Right, R.Bottom - 1);
    SelectClipRgn(Canvas.Handle, Rgn);

    if Assigned(Pic) and not Pic.Empty then
    begin
      Pic.GetImageSizes;
      x := (Width - Pic.Width) div 2;
      y := (Height - Pic.Height) div 2;
      if IsWin7 then
      begin
        x := R.Left + x;
        y := R.top + 2 + y;

        case Layout of
          plPictureCenter: ;  // do nothing
          plPictureOnTop:
          begin
            y := R.top + 3;
            R1.Top := y + Pic.Height - 2;
            R1.Bottom := R1.Top + (R.Bottom - R1.Top) - 2;
            VAlign := vtaTop;
          end;
          plPictureAtBottom:
          begin
            R1 := Rect(0, 0, 1000, 500);
            R1 := DrawGDIPText(Canvas, nil, taCenter, vtaTop, R1, Text, '', Font, Enabled, False, aaAntiAlias);
            R1 := Rect(R.Left, R.top + 3, 0, R1.Bottom);
            R1.Bottom := R1.Top + R1.Bottom;
            y := R1.Bottom;
            VAlign := vtaTop;
          end;
        end;

        Canvas.Draw(x, y, Pic);
      end
      else
      begin
        x := x - FPreviewMenuOffSet;
        x := R.Left + 3 + x;
        y := R.top - (Height - TInternalAdvPreviewMenu(AdvPreviewMenu).TopFrameHeight + 2 - y);

        case Layout of
          plPictureCenter: ;  // do nothing
          plPictureOnTop:
          begin
            R1 := Rect(0, 0, 1000, 500);
            R1 := DrawGDIPText(Canvas, nil, taCenter, vtaTop, R1, Text, '', Font, Enabled, False, aaAntiAlias);
            y := R.Top - (Height - TInternalAdvPreviewMenu(AdvPreviewMenu).TopFrameHeight + 5 - (Height - Pic.Height - R1.Bottom) div 2);
            R1.Left := R.Left + 3;
            R1.Top := y + Pic.Height + 1;
            R1.Bottom := R1.Top + (R.Bottom - R1.Top);
            VAlign := vtaTop;
          end;
          plPictureAtBottom:
          begin
            R1 := Rect(0, 0, 1000, 500);
            R1 := DrawGDIPText(Canvas, nil, taCenter, vtaTop, R1, Text, '', Font, Enabled, False, aaAntiAlias);
            R1.Left := R.Left + 3;
            R1.Top := R.Top - (Height - TInternalAdvPreviewMenu(AdvPreviewMenu).TopFrameHeight + 5 - (Height - Pic.Height - R1.Bottom) div 2);
            R1.Bottom := R1.Top + R1.Bottom;
            y := R1.Bottom + 3;
            VAlign := vtaTop;
      end;
    end;

        Canvas.Draw(x, y, Pic);
      end;
    end;

    SelectClipRgn(Canvas.Handle, 0);
    DeleteObject(Rgn);

    R1.Right := R1.Left + ClientWidth;
    if VAlign = vtaCenter then
    R1.Bottom := R1.Top + ClientHeight;
    DrawGDIPText(Canvas, nil, taCenter, VAlign, R1, Text, '', Font, Enabled, True, aaAntiAlias);
  end;
end;

//------------------------------------------------------------------------------

procedure TAdvCustomShapeButton.OnPreviewMenuHide(Sender: TObject);
begin
  Invalidate;
end;

//------------------------------------------------------------------------------

procedure TAdvCustomShapeButton.HideFrame;
begin
  if Assigned(FMenuFrame) then
    FMenuFrame.Hide;
end;

procedure TAdvCustomShapeButton.HideMenu;
begin
  HideFrame;
end;

procedure TAdvCustomShapeButton.HideMenuFrame(Sender: TObject);
var
  i: integer;
  tmsif: IWinStyle;
begin
  if Assigned(Frame) then
  begin
    for I := 0 to Frame.ControlCount - 1 do
    begin
      if Frame.Controls[i].GetInterface(IWinStyle, tmsif) then
        tmsif.HideMenuShortCuts;
    end;
  end;
end;

procedure TAdvCustomShapeButton.HideMenuShortCuts;
begin
//
end;

procedure TAdvCustomShapeButton.HideShortCutHint;
begin
  if Assigned(FShortCutHint) then
  begin
    FShortCutHint.Visible := false;
    FShortCutHint.Free;
    FShortCutHint := nil;
  end;
end;

//------------------------------------------------------------------------------

procedure TAdvCustomShapeButton.ShowShortCutHint;
var
  pt: TPoint;
begin
  if not Assigned(Parent) then
    Exit;

  if not Assigned(FShortCutHint) then
  begin
    FShortCutHint := TShortCutHintWindow.Create(Self);
    FShortCutHint.Visible := False;
    FShortCutHint.Parent := nil;
    FShortCutHint.ParentWindow := Parent.Handle;

    FShortCutHint.Color := clWhite;
    FShortCutHint.ColorTo := clSilver;

    if (Parent is TAdvToolBarPager) then
    begin
      if Assigned( (Parent as TAdvToolBarPager).ToolBarStyler) then
        FShortCutHint.ColorTo := (Parent as TAdvToolBarPager).ToolBarStyler.GlowButtonAppearance.Color;
    end;
  end;

  FShortCutHint.Caption := FShortCutHintText;

  pt := ClientToScreen(Point(0,0));

  case ShortCutHintPos of
  shpLeft:
    begin
      FShortCutHint.Left := pt.X - (FShortCutHint.Width div 2);
      FShortCutHint.Top := pt.Y + (self.Height - FShortCutHint.Height) div 2;
    end;
  shpTop:
    begin
      FShortCutHint.Left := pt.X + (self.Width - FShortCutHint.Width) div 2;
      FShortCutHint.Top := pt.Y - (FShortCutHint.Height div 2);
    end;
  shpRight:
    begin
      FShortCutHint.Left := pt.X + self.Width - (FShortCutHint.Width div 2);
      FShortCutHint.Top := pt.Y + (self.Height - FShortCutHint.Height) div 2;
    end;
  shpBottom:
    begin
      FShortCutHint.Left := pt.X + (self.Width - FShortCutHint.Width) div 2;
      FShortCutHint.Top := pt.Y + self.Height - (FShortCutHint.Height div 2);
    end;
  shpCenter:
    begin
      FShortCutHint.Left  := pt.X + (self.Width - FShortCutHint.Width) div 2;
      FShortCutHint.Top := pt.Y + (self.Height - FShortCutHint.Height) div 2;
    end;

  end;

  FShortCutHint.Visible := true;
end;

//------------------------------------------------------------------------------

procedure TAdvCustomShapeButton.CMHintShow(var Message: TMessage);
begin
  if (Message.WParam = 1) then
  begin
    if (Message.LParam = 0) then
    //if Assigned(FShortCutHint) and FShortCutHint.Visible then
    begin
      HideShortCutHint;
    end
    else if (Message.LParam = 1) then
    begin
      ShowShortCutHint;
    end;
    Message.Result := 1;
  end;

  inherited;
end;

//------------------------------------------------------------------------------

procedure TAdvCustomShapeButton.WMEraseBkGnd(var Message: TWMEraseBkGnd);
begin
  inherited;
  Exit;
  Message.Result := 1;
  if not FIsAeroVista then
    inherited;
end;

//------------------------------------------------------------------------------

procedure TAdvCustomShapeButton.CMFocusChanged(
  var Message: TCMFocusChanged);
begin
  inherited;
  Invalidate;
end;

//------------------------------------------------------------------------------

procedure TAdvCustomShapeButton.WMKeyDown(var Message: TWMKeyDown);
begin
  case Message.CharCode of
    VK_RETURN, VK_SPACE:
    begin
      if not FDown then
      begin
        FState := absDown;
        Invalidate;
      end;

      if Style = tasCheck then
      begin
        FState := absDown;
        Repaint;
      end;

      FInternalClick := True;
      Click;
      FInternalClick := False;
    end;
  end;
  inherited;

end;


{ TAdvShapeButtonAppearance }

procedure TAdvShapeButtonAppearance.AssignColors(Source: TPersistent);
begin
  if Source is TAdvShapeButtonAppearance then
  begin
    FBorderColor := (Source as TAdvShapeButtonAppearance).BorderColor;
    FBorderColorHot := (Source as TAdvShapeButtonAppearance).BorderColorHot;
    FBorderColorDown := (Source as TAdvShapeButtonAppearance).BorderColorDown;
    FBorderColorDisabled := (Source as TAdvShapeButtonAppearance).BorderColorDisabled;
    FInnerBorderColor := (Source as TAdvShapeButtonAppearance).InnerBorderColor;
    FInnerBorderColorHot := (Source as TAdvShapeButtonAppearance).InnerBorderColorHot;
    FInnerBorderColorDown := (Source as TAdvShapeButtonAppearance).InnerBorderColorDown;
    FInnerBorderColorDisabled := (Source as TAdvShapeButtonAppearance).InnerBorderColorDisabled;
    FColor := (Source as TAdvShapeButtonAppearance).Color;
    FColorTo := (Source as TAdvShapeButtonAppearance).ColorTo;
    FColorMirror := (Source as TAdvShapeButtonAppearance).ColorMirror;
    FColorMirrorTo := (Source as TAdvShapeButtonAppearance).ColorMirrorTo;

    FColorHot := (Source as TAdvShapeButtonAppearance).ColorHot;
    FColorHotTo := (Source as TAdvShapeButtonAppearance).ColorHotTo;
    FColorHotMirror := (Source as TAdvShapeButtonAppearance).ColorHotMirror;
    FColorHotMirrorTo := (Source as TAdvShapeButtonAppearance).ColorHotMirrorTo;

    FColorDown := (Source as TAdvShapeButtonAppearance).ColorDown;
    FColorDownTo := (Source as TAdvShapeButtonAppearance).ColorDownTo;
    FColorDownMirror := (Source as TAdvShapeButtonAppearance).ColorDownMirror;
    FColorDownMirrorTo := (Source as TAdvShapeButtonAppearance).ColorDownMirrorTo;

    FColorDisabled := (Source as TAdvShapeButtonAppearance).ColorDisabled;
    FColorDisabledTo := (Source as TAdvShapeButtonAppearance).ColorDisabledTo;
    FColorDisabledMirror := (Source as TAdvShapeButtonAppearance).ColorDisabledMirror;
    FColorDisabledMirrorTo := (Source as TAdvShapeButtonAppearance).ColorDisabledMirrorTo;

    FMenuShapeColorDisabled := (Source as TAdvShapeButtonAppearance).MenuShapeColorDisabled;
    FMenuShapeColor := (Source as TAdvShapeButtonAppearance).MenuShapeColor;
    FMenuShapeColorHot := (Source as TAdvShapeButtonAppearance).MenuShapeColorHot;
    FMenuShapeColorDown := (Source as TAdvShapeButtonAppearance).MenuShapeColorDown;
  end;
end;

procedure TAdvShapeButtonAppearance.Changed;
begin
  FOwner.Changed;
end;

constructor TAdvShapeButtonAppearance.Create(AOwner: TAdvCustomShapeButton);
begin
  FOwner := AOwner;
  FShape := bsCustom;
  FBorderColor := $00BD6A41;
  FBorderColorHot := $00D58744;
  FBorderColorDown := $00BD6A41;
  FBorderColorDisabled := clGray;
  FInnerBorderColor := $00CFA079;
  FInnerBorderColorHot := $00F3CE9F;
  FInnerBorderColorDown := $00CFA079;
  FInnerBorderColorDisabled := clSilver;
  FColor := $00C68B49;
  FColorTo := $00B3692F;
  FColorMirror := $0088411A;
  FColorMirrorTo := $00CE9B40;

  FColorHot := $00EFB978;
  FColorHotTo := $00D28448;
  FColorHotMirror := $00AF4E11;
  FColorHotMirrorTo := $00FFFF96;

  FColorDown := $00C68B49;
  FColorDownTo := $00B3692F;
  FColorDownMirror := $0088411A;
  FColorDownMirrorTo := $00CE9B40;

  FColorDisabled := $00DBDBDB;
  FColorDisabledTo := $00C4C4C4;
  FColorDisabledMirror := $00AAAAAA;
  FColorDisabledMirrorTo := clSilver;

  FShowMenuShape := false;
  FMenuShapeColorDisabled := clWhite;
  FMenuShapeColor := clWhite;
  FMenuShapeColorHot := clWhite;
  FMenuShapeColorDown := clWhite;
  FShowPicture := true;
end;

destructor TAdvShapeButtonAppearance.Destroy;
begin
  inherited;
end;

procedure TAdvShapeButtonAppearance.SetBorderColor(const Value: TColor);
begin
  if FBorderColor <> value then
  begin
    FBorderColor := Value;
    Changed;
  end;
end;

procedure TAdvShapeButtonAppearance.SetBorderColorDisabled(const Value: TColor);
begin
  if FBorderColorDisabled <> value then
  begin
    FBorderColorDisabled := Value;
    Changed;
  end;
end;

procedure TAdvShapeButtonAppearance.SetBorderColorDown(const Value: TColor);
begin
  if FBorderColorDown <> value then
  begin
    FBorderColorDown := Value;
    Changed;
  end;
end;

procedure TAdvShapeButtonAppearance.SetBorderColorHot(const Value: TColor);
begin
  if FBorderColorHot <> value then
  begin
    FBorderColorHot := Value;
    Changed;
  end;
end;

procedure TAdvShapeButtonAppearance.SetColor(const Value: TColor);
begin
  if FColor <> value then
  begin
    FColor := Value;
    UpdateButtonColor(FColor);
    Changed;
  end;
end;

procedure TAdvShapeButtonAppearance.SetColorDisabled(const Value: TColor);
begin
  if FColorDisabled <> value then
  begin
    FColorDisabled := Value;
    Changed;
  end;
end;

procedure TAdvShapeButtonAppearance.SetColorDisabledMirror(const Value: TColor);
begin
  if FColorDisabledMirror <> value then
  begin
    FColorDisabledMirror := Value;
    Changed;
  end;
end;

procedure TAdvShapeButtonAppearance.SetColorDisabledMirrorTo(
  const Value: TColor);
begin
  if FColorDisabledMirrorTo <> value then
  begin
    FColorDisabledMirrorTo := Value;
    Changed;
  end;
end;

procedure TAdvShapeButtonAppearance.SetColorDisabledTo(const Value: TColor);
begin
  if FColorDisabledTo <> Value then
  begin
    FColorDisabledTo := Value;
    Changed;
  end;
end;

procedure TAdvShapeButtonAppearance.SetColorDown(const Value: TColor);
begin
  if FColorDown <> Value then
  begin
    FColorDown := Value;
    Changed;
  end;
end;

procedure TAdvShapeButtonAppearance.SetColorDownMirror(const Value: TColor);
begin
  if FColorDownMirror <> Value then
  begin
    FColorDownMirror := Value;
    Changed;
  end;
end;

procedure TAdvShapeButtonAppearance.SetColorDownMirrorTo(const Value: TColor);
begin
  if FColorDownMirrorTo <> value then
  begin
    FColorDownMirrorTo := Value;
    Changed;
  end;
end;

procedure TAdvShapeButtonAppearance.SetColorDownTo(const Value: TColor);
begin
  if FColorDownTo <> value then
  begin
    FColorDownTo := Value;
    Changed;
  end;
end;

procedure TAdvShapeButtonAppearance.SetColorHot(const Value: TColor);
begin
  if FColorHot <> value then
  begin
    FColorHot := Value;
    Changed;
  end;
end;

procedure TAdvShapeButtonAppearance.SetColorHotMirror(const Value: TColor);
begin
  if FColorHotMirror <> Value then
  begin
    FColorHotMirror := Value;
    Changed;
  end;
end;

procedure TAdvShapeButtonAppearance.SetColorHotMirrorTo(const Value: TColor);
begin
  if FColorHotMirrorTo <> value then
  begin
    FColorHotMirrorTo := Value;
    Changed;
  end;
end;

procedure TAdvShapeButtonAppearance.SetColorHotTo(const Value: TColor);
begin
  if FColorHotTo <> Value then
  begin
    FColorHotTo := Value;
    Changed;
  end;
end;

procedure TAdvShapeButtonAppearance.SetColorMirror(const Value: TColor);
begin
  if FColorMirror <> Value then
  begin
    FColorMirror := Value;
    Changed;
  end;
end;

procedure TAdvShapeButtonAppearance.SetColorMirrorTo(const Value: TColor);
begin
  if FColorMirrorTo <> Value then
  begin
    FColorMirrorTo := Value;
    Changed;
  end;
end;

procedure TAdvShapeButtonAppearance.SetColorTo(const Value: TColor);
begin
  if FColorTo <> Value then
  begin
    FColorTo := Value;
    Changed;
  end;
end;

procedure TAdvShapeButtonAppearance.SetInnerBorderColor(const Value: TColor);
begin
  if FInnerBorderColor <> value then
  begin
    FInnerBorderColor := Value;
    Changed;
  end;
end;

procedure TAdvShapeButtonAppearance.SetInnerBorderColorDisabled(
  const Value: TColor);
begin
  if FInnerBorderColorDisabled <> value then
  begin
    FInnerBorderColorDisabled := Value;
    Changed;
  end;
end;

procedure TAdvShapeButtonAppearance.SetInnerBorderColorDown(
  const Value: TColor);
begin
  if FInnerBorderColorDown <> Value then
  begin
    FInnerBorderColorDown := Value;
    Changed;
  end;
end;

procedure TAdvShapeButtonAppearance.SetInnerBorderColorHot(const Value: TColor);
begin
  if FInnerBorderColorHot <> Value then
  begin
    FInnerBorderColorHot := Value;
    Changed;
  end;
end;

procedure TAdvShapeButtonAppearance.SetMenuShapeColor(const Value: TColor);
begin
  if FMenuShapeColor <> Value then
  begin
    FMenuShapeColor := Value;
    Changed;
  end;
end;

procedure TAdvShapeButtonAppearance.SetMenuShapeColorDisabled(
  const Value: TColor);
begin
  if FMenuShapeColorDisabled <> value then
  begin
    FMenuShapeColorDisabled := Value;
    Changed;
  end;
end;

procedure TAdvShapeButtonAppearance.SetMenuShapeColorDown(const Value: TColor);
begin
  if FMenuShapeColorDown <> value then
  begin
    FMenuShapeColorDown := Value;
    Changed;
  end;
end;

procedure TAdvShapeButtonAppearance.SetMenuShapeColorHot(const Value: TColor);
begin
  if FMenuShapeColorHot <> value then
  begin
    FMenuShapeColorHot := Value;
    Changed;
  end;
end;

procedure TAdvShapeButtonAppearance.SetShape(const Value: TAdvButtonShape);
begin
  if FShape <> value then
  begin
    FShape := Value;
    Changed;
  end;
end;

procedure TAdvShapeButtonAppearance.SetShowMenuShape(const Value: Boolean);
begin
  if FShowMenuShape <> value then
  begin
    FShowMenuShape := Value;
    Changed;
  end;
end;

procedure TAdvShapeButtonAppearance.SetShowPicture(const Value: Boolean);
begin
  if FShowPicture <> value then
  begin
    FShowPicture := Value;
    Changed;
  end;
end;


procedure TAdvShapeButtonAppearance.UpdateButtonColor(AColor: TColor);
var
  tmsif: IWinStyle;
  i: integer;
begin
  if FOwner.UseGlobalColor then
  begin
    FBorderColor := Darker(Acolor, 40);
    FInnerBorderColor := Lighter(AColor, 40);
    FColor := Lighter(AColor, 30);
    FColorTo := Lighter(AColor, 10);
    FcolorMirror := AColor;
    FColorMirrorTo := AColor;

    FborderColorHot := Lighter(FBorderColor, 10);
    FInnerBorderColorHot := Lighter(FInnerBorderColor, 10);
    FColorHot := Lighter(FColor, 10);
    FColorHotTo := Lighter(FColorTo, 10);
    FColorHotMirror := Lighter(FcolorMirror, 10);
    FColorHotMirrorTo := Lighter(FcolorMirrorTo, 10);

    FBorderColorDown := Fbordercolor;
    FInnerBorderColorDown := FInnerBorderColor;
    FColorDown := FColor;
    FColorDownTo := FColorTo;
    FColorDownMirror := FColorMirror;
    FColorDownMirrorTo := FColorMirrorTo;

    if Assigned(FOwner.Frame) then
    begin
      for I := 0 to FOwner.Frame.ControlCount - 1 do
      begin
        if FOwner.Frame.Controls[i].GetInterface(IWinStyle, tmsif) then
          tmsif.ChangeMenu(AColor);
      end;
    end;

    Changed;
  end;
end;

{ TFrameWindow }

constructor TFrameWindow.Create(AOwner: TComponent);
begin
  inherited;
  FHideOnDeActivate := true;
  FHideTimer := TTimer.Create(self);
  FHideTimer.Interval := 1;
  FHideTimer.Enabled := false;
  FHideTimer.OnTimer := HideTimerOnTime;
  Font.Name := 'Tahoma';
  DoubleBuffered := true;
end;

//------------------------------------------------------------------------------

constructor TFrameWindow.CreateNew(AOwner: TComponent; Dummy: Integer);
begin
  inherited;
  FOwner := AOwner;
  FHideOnDeActivate := true;
  FHideTimer := TTimer.Create(self);
  FHideTimer.Interval := 1;
  FHideTimer.Enabled := false;
  FHideTimer.OnTimer := HideTimerOnTime;
  FBorderColor := clNone;
  Font.Name := 'Tahoma';
  DoubleBuffered := True;
end;

//------------------------------------------------------------------------------

procedure TFrameWindow.CreateParams(var Params: TCreateParams);
const
  CS_DROPSHADOW = $00020000;
begin
  inherited CreateParams(Params);
  //Params.Style := Params.Style - WS_BORDER;
  {
  Params.ExStyle := Params.ExStyle or WS_EX_TOPMOST; }

  if (Win32Platform = VER_PLATFORM_WIN32_NT) and
     ((Win32MajorVersion > 5) or
      ((Win32MajorVersion = 5) and (Win32MinorVersion >= 1))) then
//    Params.WindowClass.Style := Params.WindowClass.Style or CS_DROPSHADOW;
end;

//------------------------------------------------------------------------------

destructor TFrameWindow.Destroy;
begin
  FHideTimer.Enabled := false;
  FHideTimer.Free;
  inherited;
end;

//------------------------------------------------------------------------------

function TFrameWindow.GetParentWnd: HWnd;
var
  Last, P: HWnd;
begin
  P := {GetParent}((Owner as TWinControl).Handle);
  Last := P;
  while P <> 0 do
  begin
    Last := P;
    P := GetParent(P);
  end;
  Result := Last;
end;

//------------------------------------------------------------------------------

procedure TFrameWindow.HideTimerOnTime(Sender: TObject);
begin
  Hide;
  FHideTimer.Enabled := false;
end;


//------------------------------------------------------------------------------

procedure TFrameWindow.Loaded;
begin
  inherited;
end;

//------------------------------------------------------------------------------

procedure TFrameWindow.MouseDown(Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  inherited;
end;

//------------------------------------------------------------------------------

procedure TFrameWindow.MouseMove(Shift: TShiftState; X,
  Y: Integer);
begin
  inherited;
end;

//------------------------------------------------------------------------------

procedure TFrameWindow.MouseUp(Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  inherited;
end;

//------------------------------------------------------------------------------

procedure TFrameWindow.Paint;
var
  R: TGPRectF;
  g: TGPGraphics;
  b: TGPLinearGradientBrush;
  c: TColor;
  p: TGPPen;
  l: integer;
begin
  c := clWhite;
  l := 0;
  if Assigned(FOwner) then
  begin
    if FOwner is TAdvShapeButton then
    begin
      c := (FOwner as TAdvShapeButton).Appearance.Color;
      l := (FOwner as TAdvShapeButton).Left;
    end;
  end;

  R := MakeRect(l, 0, Width / 5 * 4.5, 3);
  g := TGPGraphics.Create(Canvas.Handle);
  b := TGPLinearGradientBrush.Create(R, Makecolor(255, c), MakeColor(0, c), LinearGradientModeHorizontal);
  g.FillRectangle(b, r);

  c := GetSysColor(COLOR_ACTIVEBORDER);

  p := TGPPen.Create(Makecolor(255, c));
  l := 0;
  if Assigned(FOwner) then
  begin
    if FOwner is TAdvShapeButton then
      l := (FOwner as TAdvShapeButton).Left + (FOwner as TAdvShapeButton).Width;
  end;
  g.DrawLine(p, l,0, Width, 0);
  p.Free;

  g.Free;

end;

//------------------------------------------------------------------------------

procedure TFrameWindow.SetBounds(ALeft, ATop, AWidth,
  AHeight: Integer);
begin
  inherited;
end;

//------------------------------------------------------------------------------

procedure TFrameWindow.WMActivate(var Message: TWMActivate);
begin
  inherited;
  if not (csDestroying in ComponentState) then
  begin
    SendMessage(GetParentWnd, WM_NCACTIVATE, 1, 0);
    SetRegion;
  end
end;

//------------------------------------------------------------------------------

procedure TFrameWindow.WMEraseBkGnd(var Msg: TMessage);
begin
  inherited;
end;

//------------------------------------------------------------------------------

procedure TFrameWindow.SetRegion;
var
  rgn: THandle;
  R: TRect;
begin
  if (Width > 10) then
  begin
    R := ClientRect;
    if IsWin7 then
      rgn := CreateRectRgn(0,0,R.Right-R.Left,R.Bottom-R.Top)
    else
    rgn := CreateRoundRectRgn(0,0,R.Right-R.Left,R.Bottom-R.Top, 4, 4);
    if rgn > 0 then
    begin
      try
        SetWindowRgn(Handle,rgn,true);
      finally
        DeleteObject(rgn);
      end;
    end;
  end;
end;

//------------------------------------------------------------------------------

procedure TFrameWindow.WMNCHitTest(var Message: TWMNCHitTest);
begin
  inherited;
end;

//------------------------------------------------------------------------------

procedure TFrameWindow.WMKeyDown(var Message: TWMKeyDown);
begin
  inherited;
  case Message.CharCode of
    VK_ESCAPE: Hide;
  end;
end;

procedure TFrameWindow.WMMouseActivate(var Message: TWMMouseActivate);
begin
  Message.Result := MA_NOACTIVATE;
end;

//------------------------------------------------------------------------------

procedure TFrameWindow.CMDialogChar(var Message: TCMDialogChar);
begin
  inherited;
  case Message.CharCode of
    VK_ESCAPE: Hide;
  end;
end;

//------------------------------------------------------------------------------

procedure TFrameWindow.WMGetDlgCode(var Message: TMessage);
begin
  Message.Result := DLGC_WANTARROWS + DLGC_WANTCHARS + DLGC_WANTTAB;
end;


{ TWinCtrl }

initialization
  WM_SBDRAWIMAGE := RegisterWindowMessage('SBDRAWIMAGE');

end.
