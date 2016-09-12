{**************************************************************************}
{ TAdvSmoothPanel component                                                }
{ for Delphi & C++Builder                                                  }
{                                                                          }
{ written                                                                  }
{   TMS Software                                                           }
{   copyright © 2010                                                       }
{   Email : info@tmssoftware.com                                           }
{   Web : http://www.tmssoftware.com                                       }
{                                                                          }
{ The source code is given as is. The author is not responsible            }
{ for any possible damage done due to the use of this code.                }
{ The component can be freely used in any application. The complete        }
{ source code remains property of the author and may not be distributed,   }
{ published, given or sold in any form as such. No parts of the source     }
{ code can be included in any other component or application without       }
{ written authorization of the author.                                     }
{**************************************************************************}

unit AdvSmoothPanel;

{$I TMSDEFS.inc}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, StdCtrls, forms,
  Comobj, Activex, Math, AdvStyleIF, ImgList,
  GDIPPictureContainer, GDIPFill, IniFiles,
  AdvGDIP
  {$IFDEF TMSDOTNET}
  , Types
  {$ENDIF}
  ;

const
  MAJ_VER = 1; // Major version nr.
  MIN_VER = 0; // Minor version nr.
  REL_VER = 9; // Release nr.
  BLD_VER = 2; // Build nr.

  WM_USERPAINT = WM_USER + 102;

  // version history
  // v1.0.0.0 : first release
  // v1.0.0.1 : Improved : html rendering
  //          : Fixed : position of line for bottom caption
  // v1.0.0.2 : Fixed : memory leak
  // v1.0.0.3 : Fixed : Issue with component initialization during reparenting
  // v1.0.0.4 : New : Exposed Properties TabOrder and TabStop
  // v1.0.0.5 : Fixed issue with background and Border color = clNone
  // v1.0.1.0 : New : OnMouseLeave and OnMouseEnter events for Delphi 7
  //          : Improved : Cursor
  // v1.0.2.0 : New : OnDraw Event to draw on the panel canvas
  //          : Fixed : WMWindowPosChanged invalidate
  // v1.0.2.1 : Fixed : issue with cursor on controls inside panel
  // v1.0.2.2 : Fixed : Issue with cursor changing on controls
  // v1.0.2.3 : Fixed : Issue with client aligned panel repaint
  // v1.0.3.0 : New : Support for Windows Vista and Windows Seven Style
  // v1.0.4.0 : New : Built-in support for reduced color set for use with terminal servers
  // v1.0.4.1 : Fixed : issue with redrawing child controls on resizing panel
  // v1.0.4.2 : Fixed : issue with drawing child controls on first display
  // v1.0.4.3 : Fixed : issue with expand collaps in advsmoothexpanderpanel
  // v1.0.5.0 : New : Delphi 2010 Touch Support
  //          : Fixed : issue with HTML when collapsing
  // v1.0.6.0 : New : Exposed property Padding
  // v1.0.6.1 : Improved : Cached drawing and Transparent property to control performance
  // v1.0.7.0 : New : Property TextRendering to control text quality with transparency of control
  // v1.0.7.1 : Fixed : Issue with GDIPFill default values
  // v1.0.8.0 : New : Built-in support for Office 2010 colors
  // v1.0.9.0 : New : PictureAlignment in Button
  // v1.0.9.1 : Improved : Only draw buttons in view
  // v1.0.9.2 : Fixed : Border issue


type
  TAdvSmoothPanelLocation = (plTopLeft, plTopCenter, plTopRight, plCenterLeft, plCenterCenter, plCenterRight, plBottomLeft, plBottomCenter, plBottomRight, plCustom);

  TWinCtrl = class(TWinControl)
  public
    procedure PaintCtrls(DC: HDC; First: TControl);
  end;

  TAdvSmoothPanelTextRenderingHint = (tAntiAlias, tAntiAliasGridFit, tClearType);

  TAdvSmoothPanel = class;

  TAdvSmoothPanelCaption = class(TPersistent)
  private
    FCache: TGPBitmap;
    FOwner: TAdvSmoothPanel;
    FGradientType: TAdvGradientType;
    FLocation: TAdvSmoothPanelLocation;
    FPicture: TAdvGDIPPicture;
    FEndColor: TColor;
    FHatchStyle: THatchStyle;
    FFont: TFont;
    FStartOpacity: Byte;
    FText: String;
    FTop: integer;
    FLeft: integer;
    FEndOpacity: Byte;
    FStartColor: TColor;
    FOnChange: TNotifyEvent;
    FHTMLText: string;
    FHTMLLocation: TAdvSmoothPanelLocation;
    FHTMLTop: integer;
    FHTMLLeft: integer;
    FHTMLShadowColor: TColor;
    FHTMLURLColor: TColor;
    FHTMLShadowOffset: integer;
    FHTMLFont: TFont;
    FLineColor: TColor;
    FLine: Boolean;
    FTextRendering: TAdvSmoothPanelTextRenderingHint;
    procedure SetEndColor(const Value: TColor);
    procedure SetEndOpacity(const Value: Byte);
    procedure SetFont(const Value: TFont);
    procedure SetGradientType(const Value: TAdvGradientType);
    procedure SetHatchStyle(const Value: THatchStyle);
    procedure SetLeft(const Value: integer);
    procedure SetLocation(const Value: TAdvSmoothPanelLocation);
    procedure SetPicture(const Value: TAdvGDIPPicture);
    procedure SetStartColor(const Value: TColor);
    procedure SetStartOpacity(const Value: Byte);
    procedure SetText(const Value: String);
    procedure SetTop(const Value: integer);
    procedure SetHTMLText(const Value: string);
    procedure SetHTMLLocation(const Value: TAdvSmoothPanelLocation);
    procedure SetHTMLLeft(const Value: integer);
    procedure SetHTMLTop(const Value: integer);
    procedure SetHTMLShadowColor(const Value: TColor);
    procedure SetHTMLShadowOffset(const Value: integer);
    procedure SetHTMLURLColor(const Value: TColor);
    procedure SetHTMLFont(const Value: TFont);
    procedure SetLine(const Value: Boolean);
    procedure SetTextRendering(const Value: TAdvSmoothPanelTextRenderingHint);
  protected
    procedure Changed;
    procedure FontChanged(Sender: TObject);
    procedure PictureChanged(Sender: TObject);
    procedure SetLineColor(const Value: TColor); virtual;
  public
    constructor Create(AOwner: TAdvSmoothPanel);
    destructor Destroy; override;
    procedure Assign(Source: TPersistent); override;
    procedure SaveToFile(ini: TIniFile; Section: String);
    procedure LoadFromfile(ini: TIniFile; Section: String);
  published
    property Text: String read FText write SetText;
    property Location: TAdvSmoothPanelLocation read FLocation write SetLocation default plTopLeft;
    property HatchStyle: THatchStyle read FHatchStyle write SetHatchStyle default HatchStyleHorizontal;
    property HTMLFont: TFont read FHTMLFont write SetHTMLFont;
    property HTMLText: string read FHTMLText write SetHTMLText;
    property HTMLLocation: TAdvSmoothPanelLocation read FHTMLLocation write SetHTMLLocation default plCenterCenter;
    property HTMLLeft: integer read FHTMLLeft write SetHTMLLeft default 0;
    property HTMLTop: integer read FHTMLTop write SetHTMLTop default 0;
    property HTMLURLColor: TColor read FHTMLURLColor write SetHTMLURLColor default clBlue;
    property HTMLShadowColor: TColor read FHTMLShadowColor write SetHTMLShadowColor default clGray;
    property HTMLShadowOffset: integer read FHTMLShadowOffset write SetHTMLShadowOffset default 5;
    property Font: TFont read FFont write SetFont;
    property Left: integer read FLeft write SetLeft default 0;
    property Top: integer read FTop write SetTop default 0;
    property Picture: TAdvGDIPPicture read FPicture write SetPicture;
    property ColorStart: TColor read FStartColor write SetStartColor default clWhite;
    property ColorEnd: TColor read FEndColor write SetEndColor default clSilver;
    property OpacityStart: Byte read FStartOpacity write SetStartOpacity default 255;
    property OpacityEnd: Byte read FEndOpacity write SetEndOpacity default 255;
    property GradientType: TAdvGradientType read FGradientType write SetGradientType default gtVertical;
    property LineColor: TColor read FLineColor write SetLineColor default $00B0721C;
    property Line: Boolean read FLine write SetLine default true;
    property TextRendering: TAdvSmoothPanelTextRenderingHint read FTextRendering write SetTextRendering default tAntiAliasGridFit;
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
  end;

  TAdvSmoothPanelAnchorClickEvent = procedure(Sender: TObject; Anchor: String) of object;

  TAdvSmoothPanelDrawEvent = procedure(Sender: TObject; Canvas: TCanvas; Rect: TRect) of object;

  TAdvSmoothPanel = class(TCustomControl, ITMSStyle)
  private
    refreshcache: Boolean;
    FCache: TGPBitmap;
    FoldCursor: TCursor;
    FDesignTime, FOnAnchor: Boolean;
    FHtmlr: TRect;
    FCaption: TAdvSmoothPanelCaption;
    FOnAnchorClick: TAdvSmoothPanelAnchorClickEvent;
    FContainer: TGDIPPictureContainer;
    FImages: TCustomImageList;
    FFill: TGDIPFill;
    FConstructed: boolean;
    FOnMouseEnter: TNotifyEvent;
    FOnMouseLeave: TNotifyEvent;
    FOnDraw: TAdvSmoothPanelDrawEvent;
    FTransparent: Boolean;
    function GetVersion: String;
    procedure SetVersion(const Value: String);
    procedure SetCaption(const Value: TAdvSmoothPanelCaption);
    procedure SetFill(const Value: TGDIPFill);
    procedure WMWindowPosChanged(var Message: TWMWindowPosChanged); message WM_WINDOWPOSCHANGED;
    procedure WMSize(var Message: TWMSize); message WM_SIZE;
    procedure WMEraseBkgnd(var Message: TWmEraseBkgnd); message WM_ERASEBKGND;
    procedure WMPaint(var Message: TWMPaint); message WM_PAINT;
    procedure CMMouseEnter(var Message: TMessage); message CM_MOUSEENTER;
    procedure CMMouseLeave(var Message: TMessage); message CM_MOUSELEAVE;
    function GetCursorEx: TCursor;
    procedure SetCursorEx(const Value: TCursor);
    function GetDrawingCanvas: TCanvas;
    procedure SetTransparent(const Value: Boolean);
  protected
    procedure Changed;
    procedure PictureChanged(Sender: TObject);
    procedure CaptionChanged(Sender: TObject);
    procedure FillChanged(Sender: TObject);
    procedure DoAnchorClick(Sender: TObject; Anchor: String);
    procedure CreateParams(var Params: TCreateParams); override;
    procedure CreateWnd; override;
    procedure Notification(AComponent: TComponent; AOperation: TOperation); override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    procedure GetRoundPath(var gp: TGPGraphicsPath; r: TGPRectF; depth: Integer);
    procedure GetPosition(var x, y: integer; rectangle: TGPRectF; objectwidth, objectheight: integer; location: TAdvSmoothPanelLocation);
    procedure InitPreview;
    procedure GDIPPaint(g: TGPGraphics); virtual;
    function GetVersionNr: integer; virtual;
    function GetShadowSize: integer;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure Assign(Source: TPersistent); override;
    procedure Paint; override;
    function GetAnchorAt(X, Y: integer): String;
    procedure SetComponentStyle(AStyle: TTMSStyle);
    property ACanvas: TCanvas read GetDrawingCanvas;
    procedure SaveToTheme(FileName: String);
    procedure LoadFromTheme(FileName: String);
    function GetThemeId: String;
  published
    property Transparent: Boolean read FTransparent write SetTransparent default true;
    property Caption: TAdvSmoothPanelCaption read FCaption write SetCaption;
    property Fill: TGDIPFill read FFill write SetFill;
    property Images: TCustomImageList read FImages write FImages;
    property PictureContainer: TGDIPPictureContainer read FContainer write FContainer;
    property Version: String read GetVersion write SetVersion;
    property OnAnchorClick: TAdvSmoothPanelAnchorClickEvent read FOnAnchorClick write FOnAnchorClick;
    property OnDraw: TAdvSmoothPanelDrawEvent read FOnDraw write FOnDraw;
    property Cursor: TCursor read GetCursorEx write SetCursorEx;

    procedure Resize; override;

    property OnMouseEnter: TNotifyEvent read FOnMouseEnter write FOnMouseEnter;
    property OnMouseLeave: TNotifyEvent read FOnMouseLeave write FOnMouseLeave;

    property Align;
    property Anchors;
    property Constraints;
    property DragMode;
    property DragCursor;
    property DragKind;
    property OnCanResize;
    property OnContextPopup;
    property OnDblClick;
    property OnDockDrop;
    property OnDockOver;
    property OnDragDrop;
    property OnDragOver;
    property OnEndDock;
    property OnEndDrag;
    property OnEnter;
    property OnExit;
    property OnGetSiteInfo;
    {$IFDEF DELPHI2006_LVL}
    property OnMouseActivate;
    {$ENDIF}
    property OnResize;
    property OnStartDock;
    property OnStartDrag;
    property OnUnDock;
    property PopupMenu;
    property OnMouseMove;
    property OnMouseUp;
    property OnMouseDown;
    property OnClick;
    property OnKeyDown;
    property OnKeyUp;
    property OnKeyPress;
    property Visible;
    property ShowHint;
    property TabOrder;
    property TabStop;
    {$IFDEF DELPHI2006_LVL}
    property Padding;
    {$ENDIF}
  end;

implementation

uses
  CommCtrl, ShellApi;

{$IFNDEF DELPHI7_LVL}

const
  CS_DROPSHADOW = $00020000;

{$ENDIF}
{$i GDIPHTMLEngine.pas}

procedure TAdvSmoothPanel.Assign(Source: TPersistent);
begin
  if (Source is TAdvSmoothPanel) then
  begin
    FCaption := (Source as TAdvSmoothPanel).Caption;
    FFill.Assign((Source as TAdvSmoothPanel).Fill);
    FTransparent := (Source as TAdvSmoothPanel).Transparent;
    Changed;
  end;
end;

procedure TAdvSmoothPanel.CaptionChanged(Sender: TObject);
begin
  Changed;
end;

procedure TAdvSmoothPanel.Changed;
begin
  RefreshCache := true;
  Invalidate;
end;

procedure TAdvSmoothPanel.CMMouseEnter(var Message: TMessage);
begin
  inherited;
  if Assigned(FOnMouseEnter) then
    FOnMouseEnter(Self);
end;

procedure TAdvSmoothPanel.CMMouseLeave(var Message: TMessage);
begin
  inherited;
  if Assigned(FOnMouseLeave) then
    FOnMouseLeave(Self);
end;

constructor TAdvSmoothPanel.Create(AOwner: TComponent);
begin
  FConstructed := false;
  inherited;
  FTransparent := true;
  refreshcache := true;
  ControlStyle := ControlStyle + [csAcceptsControls];
  
  FFill := TGDIPFill.Create;
  FFill.OnChange := FillChanged;
  DoubleBuffered := true;
  Cursor := crDefault;
  Width := 256;
  Height := 128;
  FCaption := TAdvSmoothPanelCaption.Create(self);
  FCaption.OnChange := CaptionChanged;
  FDesignTime := (csDesigning in ComponentState) and not
    ((csReading in Owner.ComponentState) or (csLoading in Owner.ComponentState));
  if FDesignTime then
    SetComponentStyle(tsOffice2007Luna);

end;

procedure TAdvSmoothPanel.CreateParams(var Params: TCreateParams);
begin
  { call the create of the params }
  inherited CreateParams(Params);

  with Params do
  begin
    Style := Style and not WS_BORDER;
      //ExStyle := ExStyle or WS_EX_CLIENTEDGE;
  end;

  //with Params do
  //  WindowClass.style := WindowClass.style and not (CS_HREDRAW or CS_VREDRAW);
{
  if (Win32Platform = VER_PLATFORM_WIN32_NT) and
     ((Win32MajorVersion > 5) or
      ((Win32MajorVersion = 5) and (Win32MinorVersion >= 1))) then
        if Params.WindowClass.Style and CS_DROPSHADOW <> 0 then
          Params.WindowClass.Style := Params.WindowClass.Style - CS_DROPSHADOW;
}
end;

procedure TAdvSmoothPanel.CreateWnd;
begin
  inherited;
  if FConstructed then
    Exit;
    
  if FDesignTime then
    InitPreview;

  FConstructed := true;    
end;

destructor TAdvSmoothPanel.Destroy;
begin
  FFill.Free;
  FCaption.Free;
  inherited;
end;

procedure TAdvSmoothPanel.DoAnchorClick(Sender: TObject; Anchor: String);
begin
  if Assigned(FOnAnchorClick) then
    FOnAnchorClick(Sender, Anchor);
end;

function Choose(A,B: integer; choice: boolean): integer;
begin
  if choice then
    Result := B
  else
    Result := A;
end;

procedure TAdvSmoothPanel.FillChanged(Sender: TObject);
begin
  Changed;
end;

procedure TAdvSmoothPanel.Paint;
var
  g, gbmp: TGPGraphics;
begin
  if ((Self.Width > 1) and (Self.Height > 1)) then
  begin
    if refreshcache then
    begin
      refreshcache := false;
      if Assigned(FCache) then
        FCache.Free;

      FCache := TGPBitmap.Create(Width, Height, PixelFormat32bppARGB);
      gbmp := TGPGraphics.Create(FCache);
      gbmp.SetSmoothingMode(SmoothingModeAntiAlias);
      case Caption.TextRendering of
        tAntiAlias: gbmp.SetTextRenderingHint(TextRenderingHintAntiAlias);
        tAntiAliasGridFit: gbmp.SetTextRenderingHint(TextRenderingHintAntiAliasGridFit);
        tClearType: gbmp.SetTextRenderingHint(TextRenderingHintClearTypeGridFit);
      end;
      GDIPPaint(gbmp);
      gbmp.Free;
    end;

    g := TGPGraphics.Create(Canvas.Handle);
    g.SetSmoothingMode(SmoothingModeAntiAlias);
    g.DrawImage(FCache, 0, 0);
    g.free;
  end;
  if Assigned(FOnDraw) then
    FOnDraw(Self, Canvas, ClientRect);
end;

//fix for StreamAdapter with PNG
type
  TFixedStreamAdapter = class(TStreamAdapter)
  public
    function Stat(out statstg: TStatStg; grfStatFlag: Longint): HResult; override; stdcall;
  end;

function TFixedStreamAdapter.Stat(out statstg: TStatStg; grfStatFlag: Integer): HResult;
begin
  Result := inherited Stat(statstg, grfStatFlag);
  statstg.pwcsName := nil;
end;
//fix for StreamAdapter with PNG

procedure TAdvSmoothPanel.GDIPPaint(g: TGPGraphics);
var
  r,tr: TGPRectF;
  th, tw, x, y: Integer;
  htmlr, hr: TRect;
  a, s, k: String;
  XSize, YSize, l, m: integer;
  ff: TGPFontFamily;
  f: TGPFont;
  p: TGPPen;
  fs, pw: integer;
  sf: TGPStringFormat;
  sizeRect: TGPRectF;
  xs, ys, texth, textw: Single;
  textb: TGPBrush;
  start, stop: TGPColor;
  gppointf: TGPPointF;
  gpimg: TGPImage;
  st: TStream;
  sta: TFixedStreamAdapter;
  ch: integer;
begin
  ////Panel Background///
  if (Fill.BorderColor = clNone) or (Fill.BorderWidth = 0) then
    r := Fill.Fill(g, MakeRect(-1, -1, Width+1, Height+1))
  else
    r := Fill.Fill(g, MakeRect(0, 0, Width - 1, Height - 1));


  ///////////////////////
  ///
  texth := 0;
  ////Panel Caption///
  if Caption.Text <> '' then
  begin
    ff := TGPFontFamily.Create(Caption.Font.Name);
    if (ff.Status in [FontFamilyNotFound, FontStyleNotFound]) then
    begin
      ff.Free;
      ff := TGPFontFamily.Create('Arial');
    end;

    fs := 0;
    if (fsBold in Caption.Font.Style) then
      fs := fs + 1;
    if (fsItalic in Caption.Font.Style) then
      fs := fs + 2;
    if (fsUnderline in Caption.Font.Style) then
      fs := fs + 4;

    tr := r;
    pw := 0;

    if Assigned(Fill.Picture) and not Fill.Picture.Empty then
    begin
      case Fill.PicturePosition of
      ppTopLeft:
        if (Caption.Location in [plTopLeft, plTopRight]) then
        begin
          tr.X := tr.X + Choose(Fill.PictureWidth, Fill.Picture.Width, Fill.PictureSize = psOriginal);
          pw := Choose(Fill.PictureWidth, Fill.Picture.Width, Fill.PictureSize = psOriginal);
        end;
      ppTopRight:
        if (Caption.Location in [plTopRight, plTopLeft]) then
        begin
          tr.Width := tr.Width - Choose(Fill.PictureWidth, Fill.Picture.Width, Fill.PictureSize = psOriginal);
        end;
      ppBottomLeft:
        if (Caption.Location in [plBottomLeft, plBottomRight]) then
        begin
          tr.X := tr.X + Choose(Fill.PictureWidth, Fill.Picture.Width, Fill.PictureSize = psOriginal);
          pw := Choose(Fill.PictureWidth, Fill.Picture.Width, Fill.PictureSize = psOriginal)
        end;
      ppBottomRight:
        if (Caption.Location in [plBottomRight, plBottomLeft]) then
          tr.Width := tr.Width - Choose(Fill.PictureWidth, Fill.Picture.Width, Fill.PictureSize = psOriginal);
      end;
    end;

    sf := TGPStringFormat.Create;
    f := TGPFont.Create(ff, Caption.Font.Size , fs, UnitPoint);
    g.MeasureString(Caption.Text, Length(Caption.Text), f, MakeRect(tr.x, tr.y, tr.Width - pw, tr.Height), sf, sizerect);

    tw := Round(sizerect.Width);
    th := Round(sizerect.Height);

    if Caption.Location <> plCustom then
      GetPosition(x, y, MakeRect(tr.X, tr.Y, tr.Width, tr.Height), tw, th, Caption.Location)
    else
    begin
      x := Caption.Left;
      y := Caption.Top;
    end;

    xs := x;
    ys := y;
    textw := sizeRect.Width;
    texth := sizeRect.Height;
    textb := nil;
    start := MakeColor(Caption.OpacityStart, Caption.ColorStart);
    if Caption.ColorEnd = clNone then
      stop := start
    else
      stop := MakeColor(Caption.OpacityEnd, Caption.ColorEnd);


    gppointf := MakePoint(xs, ys);
    sizeRect.X := gppointf.X;
    sizeRect.Y := gppointf.Y;

    case Caption.GradientType of
      gtSolid: textb := TGPSolidBrush.Create(start);
      gtVertical: textb := TGPLinearGradientBrush.Create(MakePoint(xs, ys), MakePoint(xs, ys + texth), start, stop);
      gtHorizontal: textb := TGPLinearGradientBrush.Create(MakePoint(xs, ys), MakePoint(xs + textw, ys), start, stop);
      gtForwardDiagonal: textb := TGPLinearGradientBrush.Create(MakePoint(xs, ys), MakePoint(xs + textw, ys + texth), start, stop);
      gtBackwardDiagonal: textb := TGPLinearGradientBrush.Create(MakePoint(xs, ys + texth), MakePoint(xs + textw, ys), stop, start);
      gtHatch: textb := TGPHatchBrush.Create(Caption.HatchStyle, start, stop);
      gtTexture:
      begin
        if not Caption.Picture.Empty then
        begin
          st := TMemoryStream.Create;
          Caption.Picture.SaveToStream(st);
          sta := TFixedStreamAdapter.Create(st);
          gpimg := TGPImage.Create(sta);
          textb := TGPTextureBrush.Create(gpimg, WrapModeTile);
          g.DrawString(Caption.Text, Length(Caption.Text), f, MakeRect(gppointf.X, gppointf.Y, Round(tr.Width - 2 - pw), Height - 1 - GetShadowSize), sf, textb);
          st.free;
          gpimg.free;
        end;
      end;
      gtNone: ;
    end;

    if Caption.GradientType <> gtTexture then
      g.DrawString(Caption.Text, Length(Caption.Text), f, MakeRect(gppointf.X, gppointf.Y, Round(tr.Width - 2 - pw), Height - 1 - GetShadowSize), sf, textb);

    if textb <> nil then
      textb.free;

    if (Caption.LineColor <> clNone) and Caption.Line then
    begin
      //g.SetSmoothingMode(SmoothingModeNone);
      p := TGPPen.Create(ColorToARGB(Caption.LineColor), 1);

      if Caption.Location in [plBottomCenter, plBottomLeft, plBottomRight] then
        g.DrawLine(p, Round(tr.X + 2), gpPointf.Y - 2, Round(tr.Width - 2), gpPointf.Y - 2)
      else
        g.DrawLine(p, Round(tr.X + 2), gpPointf.Y + texth, Round(tr.Width - 2), gpPointf.Y + texth);
      p.Free;

      //g.SetSmoothingMode(SmoothingModeAntiAlias);
    end;

    sf.Free;
    ff.Free;
    f.Free;
  end;

  ////////////////////
  //Panel HTML Text//
  ////////////////////
  if Caption.HTMLText <> '' then
  begin
    ch := Round(texth);
    if Caption.HTMLLocation = plCustom then
      htmlr := Rect(0, ch, Width - GetShadowSize - (2 * Fill.BorderWidth) - Caption.HTMLLeft, 10000)
    else
      htmlr := Rect(Caption.HTMLLeft, ch, Width - GetShadowSize - (Fill.BorderWidth * 2), 10000);

    //HTMLDrawEx(Canvas,Caption.HTMLText,htmlr,nil, 0,0,-1,-1,Caption.HTMLShadowOffset,False,true,false,false,
    //  False,False,true,1.0,Caption.HTMLURLColor,clNone,clNone,Caption.HTMLShadowColor,a,s,k,XSize,YSize,l,m,hr,nil, FContainer,2);

    HTMLDrawGDIP(g, Caption.HTMLFont, Caption.HTMLText, htmlr, FImages, 0, 0, -1, -1, Caption.HTMLShadowOffset, False, True, False, False,
      False, False, True, 1.0, Caption.HTMLURLColor, clNone, clNone, Caption.HTMLShadowColor, a, s, k, XSize, YSize, l, m, hr, nil, FContainer, 2);

    r.Height := r.Height - ch;
    if Caption.HTMLLocation <> plCustom then
      GetPosition(x, y, r, XSize, YSize, Caption.HTMLLocation)
    else
    begin
      x := Caption.HTMLLeft;
      y := Caption.HTMLTop;
      if (x + XSize > Width - GetShadowSize - Fill.BorderWidth * 2) then
        XSize := Width - GetShadowSize - Fill.BorderWidth * 2 - X;
    end;

    if Caption.HTMLLocation <> plCustom then
      htmlr := Bounds(x, y + ch, XSize, YSize)
    else
      htmlr := Bounds(x, y, Width - GetShadowSize - 2 * Fill.BorderWidth - Caption.HTMLLeft , YSize);
//        htmlr := Bounds(x, y, XSize, YSize);


    //HTMLDrawEx(Canvas,Caption.HTMLText,htmlr,nil, 0,0,-1,-1,Caption.HTMLShadowOffset,False,false,false,false,
    //  False,False,true,1.0,Caption.HTMLURLColor,clNone,clNone,Caption.HTMLShadowColor,a,s,k,XSize,YSize,l,m,hr,nil, FContainer,2);

    if YSize < Height then
    begin
      HTMLDrawGDIP(g, Caption.HTMLFont, Caption.HTMLText,htmlr, FImages, 0, 0, -1, -1,Caption.HTMLShadowOffset, False, False, False, False,
        False, False, True,1.0,Caption.HTMLURLColor,clNone,clNone,Caption.HTMLShadowColor,a,s,k,XSize,YSize,l,m,hr,nil, FContainer,2);
    end;

    Fhtmlr := htmlr;
  end;
end;

function TAdvSmoothPanel.GetAnchorAt(X, Y: integer): String;
var
  a, s, k: String;
  XSize, YSize: integer;
  l, m: integer;
  hr: TRect;
  g: TGPGraphics;
begin
  if PtInRect(FHtmlr, Point(X, Y)) then
  begin

    g := TGPGraphics.Create(Canvas.Handle);

    HTMLDrawGDIP(g,Caption.HTMLFont, Caption.HTMLText,Fhtmlr,FImages, X,Y,-1,-1,Caption.HTMLShadowOffset,true,false,false,false,
      False,False,true,1.0,Caption.HTMLURLColor,clNone,clNone,Caption.HTMLShadowColor,a,s,k,XSize,YSize,l,m,hr,nil, FContainer,2);

    g.Free;
  end;

  Result :=  a;
end;

function TAdvSmoothPanel.GetDrawingCanvas: TCanvas;
begin
  Result := Self.Canvas;
end;

function TAdvSmoothPanel.GetCursorEx: TCursor;
begin
  Result := inherited Cursor;
end;

procedure TAdvSmoothPanel.GetPosition(var x, y: integer; rectangle: TGPRectF; objectwidth, objectheight: integer; location: TAdvSmoothPanelLocation);
var
  w, h, tw, th: integer;
begin
  tw := objectwidth;
  th := objectheight;
  w := Round(rectangle.Width);
  h := Round(rectangle.Height);

  case location of
    plTopLeft:
    begin
      x := Round(rectangle.X);
      y := Round(rectangle.Y);
    end;
    plTopRight:
    begin
      x := Max(Round(rectangle.X), w - tw);
      y := Round(rectangle.Y);
    end;
    plBottomLeft:
    begin
      x := Round(rectangle.X);
      y := h - th;
    end;
    plBottomRight:
    begin
      x := Max(Round(rectangle.X), w - tw);
      y := h - th;
    end;
    plTopCenter:
    begin
      x := Max(Round(rectangle.X), w - tw) div 2;
      y := Round(rectangle.Y);
    end;
    plBottomCenter:
    begin
      x := Max(Round(rectangle.X), w - tw) div 2;
      y := h - th;
    end;
    plCenterCenter:
    begin
      x := Max(Round(rectangle.X), w - tw) div 2;
      y := (h - th) div 2;
    end;
    plCenterLeft:
    begin
      x := Round(rectangle.x);
      y := (h - th) div 2;
    end;
    plCenterRight:
    begin
      x := Max(Round(rectangle.X), w - tw);;
      y := (h - th) div 2;
    end;
  end;
end;

procedure TAdvSmoothPanel.GetRoundPath(var gp: TGPGraphicsPath; r: TGPRectF; depth: Integer);
begin
  gp.AddArc(r.X, r.Y, depth, depth, 180, 90);
  gp.AddArc(((r.X + r.Width) - depth), r.Y, depth, depth, 270, 90);
  gp.AddArc(((r.X + r.Width) - depth), ((r.Y + r.Height) - depth), depth, depth, 0, 90);
  gp.AddArc(r.X, ((r.Y + r.Height) - depth), depth, depth, 90, 90);
  gp.AddLine(r.X, ((r.Y + r.Height) - depth), r.X, (r.Y + (depth / 2)));
end;

function TAdvSmoothPanel.GetShadowSize: integer;
begin
  Result := 0;
  if Fill.ShadowColor <> clNone then
    Result := Fill.ShadowOffset;
end;

function TAdvSmoothPanel.GetThemeId: String;
begin
  Result := ClassName;
end;

function TAdvSmoothPanel.GetVersion: String;
var
  vn: Integer;
begin
  vn := GetVersionNr;
  Result := IntToStr(Hi(Hiword(vn)))+'.'+IntToStr(Lo(Hiword(vn)))+'.'+IntToStr(Hi(Loword(vn)))+'.'+IntToStr(Lo(Loword(vn)));
end;

function TAdvSmoothPanel.GetVersionNr: integer;
begin
  Result := MakeLong(MakeWord(BLD_VER,REL_VER),MakeWord(MIN_VER,MAJ_VER));
end;

procedure TAdvSmoothPanel.InitPreview;
begin
  (*
  FFill.GradientType := gtBackwardDiagonal;
  FFill.BorderColor := clBlack;
  *)
  FFill.ShadowOffset := 10;
  FFill.Rounding := 10;
  FCaption.Text := self.Name;
end;

procedure TAdvSmoothPanel.LoadFromTheme(FileName: String);
var
  ini: TIniFile;
begin
  ini := TIniFile.Create(FileName);
  FFill.LoadFromFile(ini, GetThemeId + '.Fill');
  FCaption.LoadFromFile(ini, GetThemeId + '.Caption');
  ini.free;
end;

procedure TAdvSmoothPanel.MouseDown(Button: TMouseButton; Shift: TShiftState; X,
  Y: Integer);
var
  a: String;
begin
  inherited;
  if FOnAnchor then
  begin
    a := GetAnchorAt(X, Y);
    if a <> '' then
      DoAnchorClick(Self, a);
  end;
end;

procedure TAdvSmoothPanel.MouseMove(Shift: TShiftState; X, Y: Integer);
var
  a: String;
begin
  inherited;
  a := GetAnchorAt(X, Y);
  FOnAnchor := a <> '';
  if FOnAnchor then
    inherited Cursor := crHandPoint
  else
    inherited Cursor := FoldCursor;
end;

procedure TAdvSmoothPanel.Notification(AComponent: TComponent;
  AOperation: TOperation);
begin
  if not (csDestroying in ComponentState) then
  begin
    if (AOperation = opRemove) and (AComponent = FContainer) then
      FContainer := nil;

    if (AOperation = opRemove) and (AComponent = FImages) then
      FImages := nil;
  end;
  inherited;    
end;

procedure TAdvSmoothPanel.PictureChanged(Sender: TObject);
begin
  Changed;
end;

procedure TAdvSmoothPanel.Resize;
begin
  inherited;
  Changed;
end;

procedure TAdvSmoothPanel.SaveToTheme(FileName: String);
var
  ini: TIniFile;
begin
  ini := TIniFile.Create(FileName);
  FFill.SaveToFile(ini, GetThemeId + '.Fill');
  FCaption.SaveToFile(ini, GetThemeId + '.Caption');
  ini.free;
end;

procedure TAdvSmoothPanel.SetCaption(const Value: TAdvSmoothPanelCaption);
begin
  if FCaption <> value then
  begin
    FCaption.Assign(Value);
    CaptionChanged(Self);
  end;
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

procedure TAdvSmoothPanel.SetComponentStyle(AStyle: TTMSStyle);
begin
  Fill.GradientType := gtVertical;
  fill.Glow := gmNone;

  case AStyle of
    tsOffice2003Blue:
      begin
        Caption.ColorStart := clBlack;
        Caption.ColorEnd := clBlack;
        Caption.LineColor := clBlack;

        Fill.Color := $00FDEADA;
        Fill.ColorTo := $00E4AE88;
        Fill.ColorMirror := clNone;
        Fill.ColorMirrorTo := clNone;
        Fill.BorderColor := $DFD2C5;
      end;
    tsOffice2003Silver:
      begin
        Caption.ColorStart := clBlack;
        Caption.ColorEnd := clBlack;
        Caption.LineColor := clBlack;
        
        Fill.Color := $00F7F3F3;
        Fill.ColorTo := $00E6D8D8;
        Fill.ColorMirror := clNone;
        Fill.ColorMirrorTo := clNone;
        Fill.BorderColor := $00927476;
      end;
    tsOffice2003Olive:
      begin
        Caption.ColorStart := clBlack;
        Caption.ColorEnd := clBlack;
        Caption.LineColor := clBlack;

        Fill.Color := $00CFF0EA;
        Fill.ColorTo := $008CC0B1;
        Fill.ColorMirror := clNone;
        Fill.ColorMirrorTo := clNone;
        Fill.BorderColor := $006B7760;

      end;
    tsOffice2003Classic:
      begin
        Caption.ColorStart := clBlack;
        Caption.ColorEnd := clBlack;
        Caption.LineColor := clBlack;

        Fill.Color := clWhite;
        Fill.ColorTo := $00C9D1D5;
        Fill.ColorMirror := clNone;
        Fill.ColorMirrorTo := clNone;
        Fill.BorderColor := clGray;
      end;
    tsOffice2007Luna:
      begin
        Caption.ColorStart := $00B0721C;
        Caption.ColorEnd := $009F661A;
        Caption.LineColor := $00B0721C;

        Fill.BorderColor := $E3B28D;
        Fill.Color := $FAF1E9;
        Fill.ColorTo := $EDD8C7;
        Fill.ColorMirror := $EDD8C7;
        Fill.ColorMirrorTo := $FFF2E7;
        Fill.GradientMirrorType := gtVertical;
        Fill.GradientType := gtVertical;
        //Fill.Color := $00FAF1E9;
        //Fill.ColorTo := $00EDD8C7;
        //Fill.BorderColor := $C2C2C2;

      end;
    tsOffice2007Obsidian:
      begin
        Caption.ColorStart := clWhite;
        Caption.ColorEnd := clWhite;
        Caption.LineColor := clWhite;

        Fill.Color := $CFC6C1;
        Fill.ColorTo := $C5BBB4;
        Fill.ColorMirror := $C5BBB4;
        Fill.ColorMirrorTo := $ECECE5;
        Fill.BorderColor := clBlack;
        Fill.GradientMirrorType := gtVertical;


        //Fill.Color := $006E6E6D;
        //Fill.ColorTo := $00CFC6C1;
        //Fill.BorderColor := $00B4B0AE;
      end;
    tsWindowsXP:
      begin
        Caption.ColorStart := clBlack;
        Caption.ColorEnd := clBlack;
        Caption.LineColor := clBlack;
        
        Fill.Color := clBtnFace;
        Fill.ColorTo := clBtnFace;
        Fill.ColorMirror := clNone;
        Fill.ColorMirrorTo := clNone;
        Fill.BorderColor := clBlack;
      end;
    tsWhidbey:
      begin
        Caption.ColorStart := clBlack;
        Caption.ColorEnd := clBlack;
        Caption.LineColor := clBlack;

        Fill.Color := clWhite;
        Fill.ColorTo := $00D9E9EC;
        Fill.ColorMirror := clNone;
        Fill.ColorMirrorTo := clNone;
        Fill.BorderColor := $00828F92;
      end;
    tsCustom: ;
    tsOffice2007Silver:
      begin
        Caption.ColorStart := $00B0721C;
        Caption.ColorEnd := $009F661A;
        Caption.LineColor := $00B0721C;

        //Fill.Color := $00F6F1EE;
        //Fill.ColorTo := $00E7DCD5;
        //Fill.BorderColor := $00C1BFBD;

        Fill.BorderColor := $74706F;
        Fill.Color := $F6F1EE;
        Fill.ColorTo := $E7DCD5;
        Fill.ColorMirror := $E7DCD5;
        Fill.ColorMirrorTo := $F4F4EE;
        Fill.GradientMirrorType := gtVertical;

      end;
    tsWindowsVista:
      begin
        Caption.ColorStart := clBlack;
        Caption.ColorEnd := clBlack;
        Caption.LineColor := $FDDE99;

        Fill.Color := $FDF8F1;
        Fill.ColorTo := $FCEFD5;
        Fill.ColorMirror := clNone;
        Fill.ColorMirrorTo := clNone;
        Fill.BorderColor := $FDDE99;

      end;
    tsWindows7:
      begin
        Caption.ColorStart := clBlack;
        Caption.ColorEnd := clBlack;
        Caption.LineColor := $CEA27D;

        Fill.Color := $FCEBDC;
        Fill.ColorTo := $FCDBC1;
        Fill.ColorMirror := clNone;
        Fill.ColorMirrorTo := clNone;
        Fill.BorderColor := $CEA27D;

      end;

    tsTerminal:
      begin
        Caption.ColorStart := clBlack;
        Caption.ColorEnd := clBlack;
        Caption.LineColor := clBlack;

        Fill.Color := clBtnFace;
        Fill.ColorTo := clBtnFace;
        Fill.ColorMirror := clNone;
        Fill.ColorMirrorTo := clNone;
        Fill.BorderColor := clBlack;
      end;
         tsOffice2010Blue:
      begin
        Caption.ColorStart := $5B391E;
        Caption.ColorEnd := $5B391E;
        Caption.LineColor := $5B391E;

        Fill.Glow := gmRadial;

        Fill.Color := $FDF6EF;
        Fill.ColorTo := $F0DAC7;
        Fill.ColorMirror := clNone;
        Fill.ColorMirrorTo := clNone;
        Fill.BorderColor := $C7B29F;
      end;
         tsOffice2010Silver:
      begin
        Caption.ColorStart := $5B391E;
        Caption.ColorEnd := $5B391E;
        Caption.LineColor := $5B391E;

        Fill.Glow := gmRadial;

        Fill.Color := $FFFFFF;
        Fill.ColorTo := $EDE5E0;
        Fill.ColorMirror := clNone;
        Fill.ColorMirrorTo := clNone;
        Fill.BorderColor := $D2CDC8;
      end;
         tsOffice2010Black:
      begin
        Caption.ColorStart := clWhite;
        Caption.ColorEnd := clWhite;
        Caption.LineColor := clWhite;

        Fill.Glow := gmRadial;

        Fill.Color := $BFBFBF;
        Fill.ColorTo := $919191;
        Fill.ColorMirror := clNone;
        Fill.ColorMirrorTo := clNone;
        Fill.BorderColor := $6D6D6D;
      end;
  end;

end;

procedure TAdvSmoothPanel.SetCursorEx(const Value: TCursor);
begin
  inherited Cursor := Value;
  FoldCursor := Value;
end;

procedure TAdvSmoothPanel.SetFill(const Value: TGDIPFill);
begin
  if FFill <> value then
  begin
    FFill := Value;
    Changed;
  end;
end;

procedure TAdvSmoothPanel.SetTransparent(const Value: Boolean);
begin
  if FTransparent <> Value then
  begin
    FTransparent := Value;
    Changed;
  end;
end;

procedure TAdvSmoothPanel.SetVersion(const Value: String);
begin

end;

procedure TAdvSmoothPanel.WMEraseBkgnd(var Message: TWmEraseBkgnd);
{
var
  DC: HDC;
  i: Integer;
  p: TPoint;
}
begin
  {
  if Assigned(Parent) and (Fill.ShadowOffset > 0) then
  begin
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
  end;
  }

  if not Transparent then
  begin
    inherited;
    Exit;
  end;


  {$IFDEF DELPHI2006_LVL}
  inherited;
  {$ENDIF}
  {$IFNDEF DELPHI2006_LVL}
  message.Result := 1;
  {$ENDIF}
end;

procedure TAdvSmoothPanel.WMPaint(var Message: TWMPaint);
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
  if not Transparent then
  begin
    inherited;
    Exit;
  end;

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

procedure TAdvSmoothPanel.WMSize(var Message: TWMSize);
begin
  inherited;
  Invalidate;
end;

procedure TAdvSmoothPanel.WMWindowPosChanged(var Message: TWMWindowPosChanged);
begin
  if (csDesigning in ComponentState) then
    Invalidate
  else if (Fill.ShadowColor <> clNone) and (Fill.ShadowOffset > 0) then
    Invalidate;
  inherited;
end;

{ TWinCtrl }

procedure TWinCtrl.PaintCtrls(DC: HDC; First: TControl);
begin
  PaintControls(DC, First);
end;

{ TAdvSmoothPanelCaption }

procedure TAdvSmoothPanelCaption.Assign(Source: TPersistent);
begin
  if Source is TAdvSmoothPanelCaption then
  begin
    FText := (Source as TAdvSmoothPanelCaption).Text;
    FLocation := (Source as TAdvSmoothPanelCaption).Location;
    FLeft := (Source as TAdvSmoothPanelCaption).Left;
    FTop := (Source as TAdvSmoothPanelCaption).Top;
    FStartColor := (Source as TAdvSmoothPanelCaption).ColorStart;
    FEndColor := (Source as TAdvSmoothPanelCaption).ColorEnd;
    FGradientType := (Source as TAdvSmoothPanelCaption).GradientType;
    FHatchStyle := (Source as TAdvSmoothPanelCaption).HatchStyle;
    FStartOpacity := (Source as TAdvSmoothPanelCaption).OpacityStart;
    FEndOpacity := (Source as TAdvSmoothPanelCaption).OpacityEnd;
    FPicture.Assign((Source as TAdvSmoothPanelCaption).Picture);
    FHTMLText := (Source as TAdvSmoothPanelCaption).HTMLText;
    FHTMLLocation := (Source as TAdvSmoothPanelCaption).HTMLLocation;
    FHTMLLeft := (Source as TAdvSmoothPanelCaption).HTMLLeft;
    FHTMLTop := (Source as TAdvSmoothPanelCaption).HTMLTop;
    FHTMLURLColor := (Source as TAdvSmoothPanelCaption).HTMLURLColor;
    FHTMLShadowColor := (Source as TAdvSmoothPanelCaption).HTMLShadowColor;
    FHTMLShadowOffset := (Source as TAdvSmoothPanelCaption).HTMLShadowOffset;
    FHTMLFont.Assign((Source as TAdvSmoothPanelCaption).HTMLFont);
    FFont.Assign((Source as TAdvSmoothPanelCaption).Font);
    FLine := (Source as TAdvSmoothPanelCaption).Line;
    Changed;
  end;
end;

procedure TAdvSmoothPanelCaption.Changed;
begin
  FOwner.CaptionChanged(Self);
end;

constructor TAdvSmoothPanelCaption.Create(AOwner: TAdvSmoothPanel);
begin
  FOwner := AOwner;
  FHTMLLocation := plCenterCenter;
  FHTMLTop := 0;
  FHTMLLeft := 0;
  FHTMLShadowColor := clGray;
  FHTMLURLColor := clBlue;
  FHTMLShadowOffset := 5;
  FLocation := plTopLeft;
  FFont := TFont.Create;
  {$IFNDEF DEPLHI9_LVL}
  FFont.Name := 'Tahoma';
  {$ENDIF}
  FFont.OnChange := FontChanged;
  FStartColor := clWhite;
  FEndColor := clSilver;
  FStartOpacity := 255;
  FEndOpacity := 255;
  FFont.Size := 12;
  FLine := true;
  FGradientType := gtVertical;
  FHatchStyle := HatchStyleHorizontal;
  FPicture := TAdvGDIPPicture.Create;
  FPicture.OnChange := PictureChanged;
  FLineColor := $00B0721C;
  FHTMLFont := TFont.Create;
  {$IFNDEF DEPLHI9_LVL}
  FHTMLFont.Name := 'Tahoma';
  {$ENDIF}
  FHTMLFont.OnChange := FontChanged;
  FTextRendering := tAntiAliasGridFit;
end;

destructor TAdvSmoothPanelCaption.Destroy;
begin
  if Assigned(FCache) then
    FCache.Free;

  FPicture.Free;
  FFont.Free;
  FHTMLFont.Free;
  inherited;
end;

procedure TAdvSmoothPanelCaption.FontChanged(Sender: TObject);
begin
  Changed;
end;

procedure TAdvSmoothPanelCaption.LoadFromfile(ini: TIniFile; Section: String);
begin

end;

procedure TAdvSmoothPanelCaption.PictureChanged(Sender: TObject);
begin
  Changed;
end;

procedure TAdvSmoothPanelCaption.SaveToFile(ini: TIniFile; Section: String);
begin
//  ini.WriteInteger(Section, 'HatchStyle', Integer(HatchStyle));
//    property HTMLFont: TFont read FHTMLFont write SetHTMLFont;
//
//
//
//
//    property HTMLURLColor: TColor read FHTMLURLColor write SetHTMLURLColor default clBlue;
//    property HTMLShadowColor: TColor read FHTMLShadowColor write SetHTMLShadowColor default clGray;
//    property HTMLShadowOffset: integer read FHTMLShadowOffset write SetHTMLShadowOffset default 5;
//    property Font: TFont read FFont write SetFont;
//
//
//    property Picture: TAdvGDIPPicture read FPicture write SetPicture;
//    property ColorStart: TColor read FStartColor write SetStartColor default clWhite;
//    property ColorEnd: TColor read FEndColor write SetEndColor default clSilver;
//    property OpacityStart: Byte read FStartOpacity write SetStartOpacity default 255;
//    property OpacityEnd: Byte read FEndOpacity write SetEndOpacity default 255;
//    property GradientType: TAdvGradientType read FGradientType write SetGradientType default gtVertical;
//    property LineColor: TColor read FLineColor write SetLineColor default $00B0721C;
//    property Line: Boolean read FLine write SetLine default true;
end;

procedure TAdvSmoothPanelCaption.SetEndColor(const Value: TColor);
begin
  if FEndColor <> value then
  begin
    FEndColor := Value;
    Changed;
  end;
end;

procedure TAdvSmoothPanelCaption.SetEndOpacity(const Value: Byte);
begin
  if FEndOpacity <> value then
  begin
    FEndOpacity := Value;
    Changed;
  end;
end;

procedure TAdvSmoothPanelCaption.SetFont(const Value: TFont);
begin
  if FFont <> value then
  begin
    FFont.Assign(Value);
    Changed;
  end;
end;

procedure TAdvSmoothPanelCaption.SetGradientType(const Value: TAdvGradientType);
begin
  if FGradientType <> value then
  begin
    FGradientType := Value;
    Changed;
  end;
end;

procedure TAdvSmoothPanelCaption.SetHatchStyle(const Value: THatchStyle);
begin
  if FHatchStyle <> value then
  begin
    FHatchStyle := Value;
    Changed;
  end;
end;

procedure TAdvSmoothPanelCaption.SetHTMLFont(const Value: TFont);
begin
  if FHTMLFont <> value then
  begin
    FHTMLFont.Assign(Value);
    Changed;
  end;
end;

procedure TAdvSmoothPanelCaption.SetHTMLLeft(const Value: integer);
begin
  if FHTMLLeft <> value then
  begin
    FHTMLLeft := Value;
    Changed;
  end;
end;

procedure TAdvSmoothPanelCaption.SetHTMLLocation(
  const Value: TAdvSmoothPanelLocation);
begin
  if FHTMLLocation <> value then
  begin
    FHTMLLocation := Value;
    Changed;
  end;
end;

procedure TAdvSmoothPanelCaption.SetHTMLShadowColor(const Value: TColor);
begin
  if FHTMLShadowColor <> value then
  begin
    FHTMLShadowColor := Value;
    Changed;
  end;
end;

procedure TAdvSmoothPanelCaption.SetHTMLShadowOffset(const Value: integer);
begin
  if FHTMLShadowOffset <> value then
  begin
    FHTMLShadowOffset := Value;
    Changed;
  end;
end;

procedure TAdvSmoothPanelCaption.SetHTMLText(const Value: string);
begin
  if HTMLText <> value then
  begin
    FHTMLText := Value;
    Changed;
  end;
end;

procedure TAdvSmoothPanelCaption.SetHTMLTop(const Value: integer);
begin
  if FHTMLTop <> value then
  begin
    FHTMLTop := Value;
    Changed;
  end;
end;

procedure TAdvSmoothPanelCaption.SetHTMLURLColor(const Value: TColor);
begin
  if FHTMLURLColor <> value then
  begin
    FHTMLURLColor := Value;
    Changed;
  end;
end;

procedure TAdvSmoothPanelCaption.SetLeft(const Value: integer);
begin
  if FLeft <> value then
  begin
    FLeft := Value;
    Changed;
  end;
end;

procedure TAdvSmoothPanelCaption.SetLine(const Value: Boolean);
begin
  if FLine <> value then
  begin
    FLine := Value;
    Changed;
  end;
end;

procedure TAdvSmoothPanelCaption.SetLineColor(const Value: TColor);
begin
  if FLineColor <> Value then
  begin
    FLineColor := Value;
    Changed;
  end;
end;

procedure TAdvSmoothPanelCaption.SetLocation(
  const Value: TAdvSmoothPanelLocation);
begin
  if FLocation <> value then
  begin
    FLocation := Value;
    Changed;
  end;
end;

procedure TAdvSmoothPanelCaption.SetPicture(const Value: TAdvGDIPPicture);
begin
  if FPicture <> value then
  begin
    FPicture.Assign(Value);
    Changed;
  end;
end;

procedure TAdvSmoothPanelCaption.SetStartColor(const Value: TColor);
begin
  if FStartColor <> value then
  begin
    FStartColor := Value;
    Changed;
  end;
end;

procedure TAdvSmoothPanelCaption.SetStartOpacity(const Value: Byte);
begin
  if FStartOpacity <> value then
  begin
    FStartOpacity := Value;
    Changed;
  end;
end;

procedure TAdvSmoothPanelCaption.SetText(const Value: String);
begin
  if FText <> Value then
  begin
    FText := Value;
    Changed;
  end;
end;

procedure TAdvSmoothPanelCaption.SetTextRendering(
  const Value: TAdvSmoothPanelTextRenderingHint);
begin
  if FTextRendering <> Value then
  begin
    FTextRendering := Value;
    Changed;
  end;
end;

procedure TAdvSmoothPanelCaption.SetTop(const Value: integer);
begin
  if FTop <> value then
  begin
    FTop := Value;
    Changed;
  end;
end;

end.
