{**************************************************************************}
{ TAdvSmoothScrollBar component                                            }
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

unit AdvSmoothScrollBar;

{$I TMSDEFS.inc}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, StdCtrls, forms,
  Math, AdvStyleIF, ImgList, DateUtils, ExtCtrls,
  GDIPFill,
  AdvGDIP
  {$IFDEF TMSDOTNET}
  , Types
  {$ENDIF}
  ;

const
  MAJ_VER = 1; // Major version nr.
  MIN_VER = 0; // Minor version nr.
  REL_VER = 3; // Release nr.
  BLD_VER = 0; // Build nr.

  // version history
  // v1.0.0.0 : first release
  // v1.0.1.0 : New : Support for Windows Vista and Windows Seven Style
  // v1.0.2.0 : New : Built-in support for reduced color set for use with terminal servers
  // v1.0.3.0 : New : Built-in support for Office 2010 colors

type
  TWinCtrl = class(TWinControl)
  public
    procedure PaintCtrls(DC: HDC; First: TControl);
  end;

  TAdvSmoothScrollBar = class;

  TAdvSmoothScrollBarAppearance = class(TPersistent)
  private
    FOwner: TAdvSmoothScrollBar;
    FThumbFill: TGDIPFill;
    FScrollButtonSize: integer;
    FBackGroundFill: TGDIPFill;
    FThumbButtonSize: integer;
    FScrollButtonLeft: TGDIPFill;
    FThumbButtonLeft: TGDIPFill;
    FScrollButtonRight: TGDIPFill;
    FThumbButtonRight: TGDIPFill;
    FOnChange: TNotifyEvent;
    procedure SetBackGroundFill(const Value: TGDIPFill);
    procedure SetScrollButtonLeft(const Value: TGDIPFill);
    procedure SetScrollButtonRight(const Value: TGDIPFill);
    procedure SetScrollButtonSize(const Value: integer);
    procedure SetThumbButtonLeft(const Value: TGDIPFill);
    procedure SetThumbButtonRight(const Value: TGDIPFill);
    procedure SetThumbButtonSize(const Value: integer);
    procedure SetThumbFill(const Value: TGDIPFill);
  protected
    procedure Changed;
    procedure FillChanged(Sender: TObject);
  public
    constructor Create(AOwner: TAdvSmoothScrollBar);
    destructor Destroy; override;
    procedure Assign(Source: TPersistent); override;
  published
    property BackGroundFill: TGDIPFill read FBackGroundFill write SetBackGroundFill;
    property ThumbFill: TGDIPFill read FThumbFill write SetThumbFill;
    property ScrollButtonLeft: TGDIPFill read FScrollButtonLeft write SetScrollButtonLeft;
    property ScrollButtonRight: TGDIPFill read FScrollButtonRight write SetScrollButtonRight;
    property ThumbButtonLeft: TGDIPFill read FThumbButtonLeft write SetThumbButtonLeft;
    property ThumbButtonRight: TGDIPFill read FThumbButtonRight write SetThumbButtonRight;
    property ThumbButtonSize: integer read FThumbButtonSize write SetThumbButtonSize;
    property ScrollButtonSize: integer read FScrollButtonSize write SetScrollButtonSize;
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
  end;

  TAdvSmoothScrollBarMode = (sbmNone, sbmScroll, sbmChangePageSize);

  TAdvSmoothHoveredButton = (hbNone, hbScrollMin, hbScrollMax, hbThumbMin, hbThumbMax);

  TAdvSmoothDownButton = (dbNone, dbScrollMin, dbScrollMax, dbThumbMin, dbThumbMax);

  TAdvSmoothScrollButtonChange = (sbcNone, sbcSmallSubstract, sbcSmallAdd, sbcLargeSubstract, sbcLargeAdd);

  TAdvSmoothScrollBarPositionChanged = procedure(Sender: TObject; Position: integer) of object;

  TAdvSmoothScrollBarPageSizeChanged = procedure(Sender: TObject; PageSize: integer) of object;

  TAdvSmoothScrollBar = class(TCustomControl, ITMSStyle)
  private
  {
    FSp: Double;
    FTimeStop, FTimeStart: integer;
    FMouseUp: Boolean;
    FScrollY, FScrollX: integer;
    FDoAnimate: Boolean;}
    FSavedPageSize: integer;
    FDesignTime, FMinThumb, FMaxThumb: Boolean;
    FMx, FMy, FCx, FCy: Double;
    {FAniTimer, }FTimer: TTimer;
    FTime: integer;
    FScrollBarMode: TAdvSmoothScrollBarMode;
    FScrollButtonChange: TAdvSmoothScrollButtonChange;
    FHoveredButton: TAdvSmoothHoveredButton;
    FDownButton: TAdvSmoothDownButton;
    FKind: TScrollBarKind;
    FPosition{, FPositionto}: Integer;
    FMin: Integer;
    FMax: Integer;
    FPageSize: Integer;
    FSmallChange: TScrollBarInc;
    FLargeChange: TScrollBarInc;
    FOnChange: TNotifyEvent;
    FAppearance: TAdvSmoothScrollBarAppearance;
    FTransparent: Boolean;
    FOnPositionChange: TAdvSmoothScrollBarPositionChanged;
    FAnimation: Boolean;
    FAnimationFactor: integer;
    FOnPageSizeChanged: TAdvSmoothScrollBarPageSizeChanged;
    procedure CMMouseLeave(var Message: TMessage); message CM_MOUSELEAVE;
    procedure WMGetDlgCode(var Message: TWMGetDlgCode); message WM_GETDLGCODE;
    procedure WMEraseBkgnd(var Message: TWMEraseBkgnd); message WM_ERASEBKGND;
    procedure WMPaint(var Message: TWMPaint); message WM_PAINT;
    procedure SetAppearance(const Value: TAdvSmoothScrollBarAppearance);
    procedure SetKind(Value: TScrollBarKind);
    procedure SetMax(const Value: Integer);
    procedure SetMin(const Value: Integer);
    procedure SetPosition(const Value: Integer);
    procedure SetPageSize(const Value: Integer);
    procedure SetTransparent(const Value: Boolean);
//    procedure SetAnimation(const Value: Boolean);
//    procedure SetAnimationFactor(const Value: integer);
  protected
    procedure KeyDown(var Key: Word; Shift: TShiftState); override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure Changed;
    procedure AppearanceChanged(Sender: TObject);
    procedure TimerChanged(Sender: TObject);
//    procedure Animate(Sender: TObject);
    function GetMinScrollButton: TGPRectF;
    function GetMaxScrollButton: TGPRectF;
    function GetMinThumbButton: TGPRectF;
    function GetMaxThumbButton: TGPRectF;
    function GetScrollRectangle: TGPRectF;
    function GetScrollSize: integer;
    function GetScrollAreaMin: TGPRectF;
    function GetScrollAreaMax: TGPRectF;
    function GetThumbRectangle: TGPRectF;
    function GetPosition: integer; overload;
    function GetPosition(XYPos: Double): integer; overload;
    function InsideRect: TRect;
    function GetRange: integer;
    function MouseOnThumbButtons(X, Y: integer): Boolean;
    function MouseOnThumb(X, Y: integer): Boolean;
    procedure DrawBackGround(g: TGPGraphics);
    procedure DrawScrollButtons(g: TGPGraphics);
    procedure DrawThumb(g: TGPGraphics);
    procedure DrawThumbButtons(g: TGPGraphics);
    procedure DrawArrow(g: TGPGraphics; r: TGPRectF; Left: Boolean);
    function PtInGPRect(r: TGPRectF; pt: TPoint): Boolean;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure Assign(Source: TPersistent); override;
    procedure SetComponentStyle(AStyle: TTMSStyle);
    procedure Paint; override;
    procedure MouseWheelHandler(var Message: TMessage); override;
    procedure SaveToTheme(FileName: String);
    procedure LoadFromTheme(FileName: String);
    function GetThemeID: String;
  published
//    property Animation: Boolean read FAnimation write SetAnimation default true;
//    property AnimationFactor: integer read FAnimationFactor write SetAnimationFactor default 4;
    property Appearance: TAdvSmoothScrollBarAppearance read FAppearance write SetAppearance;
    property Kind: TScrollBarKind read FKind write SetKind default sbHorizontal;
    property LargeChange: TScrollBarInc read FLargeChange write FLargeChange default 1;
    property Max: Integer read FMax write SetMax default 100;
    property Min: Integer read FMin write SetMin default 0;
    property PageSize: Integer read FPageSize write SetPageSize default 20;
    property Position: Integer read FPosition write SetPosition default 0;
    property SmallChange: TScrollBarInc read FSmallChange write FSmallChange default 1;
    property Transparent: Boolean read FTransparent write SetTransparent default false;
    property OnPositionChanged: TAdvSmoothScrollBarPositionChanged read FOnPositionChange write FOnPositionChange;
    property OnPageSizeChanged: TAdvSmoothScrollBarPageSizeChanged read FOnPageSizeChanged write FOnPageSizeChanged;

    property Align;
    property Anchors;
    property BiDiMode;
    property Constraints;
    property Ctl3D;
    property DoubleBuffered;
    property DragCursor;
    property DragKind;
    property DragMode;
    property Enabled;
    property ParentBiDiMode;
    property ParentCtl3D;
    property ParentShowHint;
    property PopupMenu;
    property ShowHint;
    property TabOrder;
    property TabStop default true;
    property Visible;
    property OnContextPopup;
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
    property OnDragDrop;
    property OnDragOver;
    property OnEndDock;
    property OnEndDrag;
    property OnEnter;
    property OnExit;
    property OnKeyDown;
    property OnKeyPress;
    property OnKeyUp;
    {$IFDEF DELPHI2006_LVL}
    property OnMouseEnter;
    property OnMouseLeave;
    {$ENDIF}
    property OnStartDock;
    property OnStartDrag;
  end;

implementation

{
function AnimateDouble(var Start, Stop: integer; Delta: Double; Margin: integer): Boolean;
begin
  Result := true;
  if (Start > Stop - Margin) and (Start < Stop + Margin) then
  begin
    Start := Stop;
    Result := false;
  end
  else
  begin
    Delta := Max(1, Delta);
    if Start < Stop then
      Start := Round(Start + Delta)
    else
      Start := Round(Start - Delta);
  end;
end;
}

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

{ TWinCtrl }

procedure TWinCtrl.PaintCtrls(DC: HDC; First: TControl);
begin
  inherited PaintControls(DC, First);
end;

{ TAdvSmoothScrollBarAppearance }

procedure TAdvSmoothScrollBarAppearance.Assign(Source: TPersistent);
begin
  if (Source is TAdvSmoothScrollBarAppearance) then
  begin
    FThumbFill.Assign((Source as TAdvSmoothScrollBarAppearance).ThumbFill);
    FScrollButtonSize := (Source as TAdvSmoothScrollBarAppearance).ScrollButtonSize;
    FBackGroundFill.Assign((source as TAdvSmoothScrollBarAppearance).BackGroundFill);
    FThumbButtonSize := (source as TAdvSmoothScrollBarAppearance).ThumbButtonSize;
    FScrollButtonLeft.Assign((Source as TAdvSmoothScrollBarAppearance).ScrollButtonLeft);
    FThumbButtonLeft.Assign((Source as TAdvSmoothScrollBarAppearance).ThumbButtonLeft);
    FScrollButtonRight.Assign((Source as TAdvSmoothScrollBarAppearance).ScrollButtonRight);
    FThumbButtonRight.Assign((Source as TAdvSmoothScrollBarAppearance).ThumbButtonRight);
    Changed;
  end;
end;

procedure TAdvSmoothScrollBarAppearance.Changed;
begin
  FOwner.Changed;
end;

constructor TAdvSmoothScrollBarAppearance.Create(AOwner: TAdvSmoothScrollBar);
begin
  FOwner := AOwner;
  FBackGroundFill := TGDIPFill.Create;
  FBackGroundFill.OnChange := fillChanged;
  FThumbFill := TGDIPFill.Create;
  FThumbFill.OnChange := FillChanged;
  FScrollButtonLeft := TGDIPFill.Create;
  FScrollButtonLeft.OnChange := FillChanged;
  FScrollButtonRight := TGDIPFill.Create;
  FScrollButtonRight.OnChange := FillChanged;
  FThumbButtonLeft := TGDIPFill.Create;
  FThumbButtonLeft.OnChange := FillChanged;
  FThumbButtonRight := TGDIPFill.Create;
  FThumbButtonRight.OnChange := FillChanged;
  if FOwner.FDesignTime then
  begin
    FThumbButtonSize := GetSystemMetrics(SM_CYHSCROLL);
    FScrollButtonSize := GetSystemMetrics(SM_CYHSCROLL);
  end;
end;

destructor TAdvSmoothScrollBarAppearance.Destroy;
begin
  FBackGroundFill.Free;
  FThumbFill.Free;
  FScrollButtonLeft.Free;
  FScrollButtonRight.Free;
  FThumbButtonLeft.Free;
  FThumbButtonRight.Free;
  inherited;
end;

procedure TAdvSmoothScrollBarAppearance.FillChanged(Sender: TObject);
begin
  Changed;
end;

procedure TAdvSmoothScrollBarAppearance.SetBackGroundFill(
  const Value: TGDIPFill);
begin
  if FBackGroundFill <> Value then
  begin
    FBackGroundFill.Assign(value);
    Changed;
  end;
end;

procedure TAdvSmoothScrollBarAppearance.SetScrollButtonLeft(
  const Value: TGDIPFill);
begin
  if FScrollButtonLeft <> value then
  begin
    FScrollButtonLeft.Assign(Value);
    Changed;
  end;
end;

procedure TAdvSmoothScrollBarAppearance.SetScrollButtonRight(
  const Value: TGDIPFill);
begin
  if FScrollButtonRight <> value then
  begin
    FScrollButtonRight.Assign(Value);
    Changed;
  end;
end;

procedure TAdvSmoothScrollBarAppearance.SetScrollButtonSize(
  const Value: integer);
begin
  if FScrollButtonSize <> value then
  begin
    FScrollButtonSize := Value;
    Changed;
  end;
end;

procedure TAdvSmoothScrollBarAppearance.SetThumbButtonLeft(
  const Value: TGDIPFill);
begin
  if FThumbButtonLeft <> value then
  begin
    FThumbButtonLeft.Assign(Value);
    Changed;
  end;
end;

procedure TAdvSmoothScrollBarAppearance.SetThumbButtonRight(
  const Value: TGDIPFill);
begin
  if FThumbButtonRight <> value then
  begin
    FThumbButtonRight.Assign(Value);
    Changed;
  end;
end;

procedure TAdvSmoothScrollBarAppearance.SetThumbButtonSize(
  const Value: integer);
begin
  if FThumbButtonSize <> value then
  begin
    FThumbButtonSize := Value;
    Changed;
  end;
end;

procedure TAdvSmoothScrollBarAppearance.SetThumbFill(const Value: TGDIPFill);
begin
  if FThumbFill <> value then
  begin
    FThumbFill.Assign(Value);
    Changed;
  end;
end;

{ TAdvSmoothScrollBar }

{
procedure TAdvSmoothScrollBar.Animate(Sender: TObject);
var
  p: integer;
  d: Double;
  a: Boolean;
begin
  if FDoAnimate then
  begin
    d := Abs(FPositionto - FPosition) / Math.Max(1, Abs(FSp) * AnimationFactor);
    p := FPosition;
    a := AnimateDouble(p, FPositionTo, d, 1);
    if a then
    begin
      FPosition := p;
      Changed;
    end
    else
      FDoAnimate := false;
  end;
end;
}

procedure TAdvSmoothScrollBar.AppearanceChanged(Sender: TObject);
begin
  Changed;
end;

procedure TAdvSmoothScrollBar.Assign(Source: TPersistent);
begin
  if (Source is TAdvSmoothScrollBar) then
  begin
//    FKind := (Source as TAdvSmoothScrollBar).Kind;
    FPosition := (Source as TAdvSmoothScrollBar).Position;
    FMin := (Source as TAdvSmoothScrollBar).Min;
    FMax := (Source as TAdvSmoothScrollBar).Max;
    FPageSize := (Source as TAdvSmoothScrollBar).PageSize;
    FSmallChange := (Source as TAdvSmoothScrollBar).SmallChange;
    FLargeChange := (Source as TAdvSmoothScrollBar).LargeChange;
    FAppearance.Assign((Source as TAdvSmoothScrollBar).Appearance);
    FTransparent := (Source as TAdvSmoothScrollBar).Transparent;
    Changed;
  end;
end;

procedure TAdvSmoothScrollBar.Changed;
begin
  invalidate;
end;

procedure TAdvSmoothScrollBar.CMMouseLeave(var Message: TMessage);
begin
  inherited;
  FTimer.Enabled := false;
  FTime := 0;
  FScrollBarMode := sbmNone;
  Screen.Cursor := crDefault;
  FScrollButtonChange := sbcNone;
  FMinThumb := false;
  FMaxThumb := false;
  FDownButton := dbNone;
  FHoveredButton := hbNone;
  Changed;
{  FDoAnimate := false;
  FPosition := FPositionto;
  FMouseUp := false;}
end;

constructor TAdvSmoothScrollBar.Create(AOwner: TComponent);
begin
  inherited;
  DoubleBuffered := true;
  FDesignTime := (csDesigning in ComponentState) and not
    ((csReading in Owner.ComponentState) or (csLoading in Owner.ComponentState));

  Width := 121;
  if FDesignTime then
    Height := GetSystemMetrics(SM_CYHSCROLL);
  FKind := sbHorizontal;
  FPosition := 0;
  FMin := 0;
  FMax := 100;
  FSmallChange := 1;
  FLargeChange := 1;
  FAppearance := TAdvSmoothScrollBarAppearance.Create(Self);
  FAppearance.OnChange := AppearanceChanged;
  FTransparent := false;
  FPageSize := 20;
  FAnimation := true;
  FAnimationFactor := 4;
  FTimer := TTimer.Create(Self);
  FTimer.OnTimer := TimerChanged;
  Ftimer.Interval := 100;
  TabStop := true;

  if FDesignTime then
    SetComponentStyle(tsOffice2007Luna);

  {
  FAniTimer := TTimer.Create(Self);
  FAniTimer.OnTimer := Animate;
  FAniTimer.Interval := 10;
  FAniTimer.Enabled := true;
  }
end;

destructor TAdvSmoothScrollBar.Destroy;
begin
  FAppearance.Free;
  FTimer.Free;
  //FAniTimer.Free;
  inherited;
end;

procedure TAdvSmoothScrollBar.DrawArrow(g: TGPGraphics; r: TGPRectF; Left: Boolean);
var
  p: TGPPen;
begin
  //DRAW SIGN
  p := TGPPen.Create(MakeColor(255, clBlack), 2);
  if Kind = sbVertical then
  begin
    if not Left then
    begin
      g.DrawLine(p, r.X + (r.Width / 2), r.Y + (r.Height / 3 * 2), r.X + (r.Width / 3), r.Y + (r.Height / 3));
      g.DrawLine(p, r.X + (r.Width / 2), r.Y + (r.Height / 3 * 2), r.X + (r.Width / 3 * 2), r.Y + (r.Height / 3));
    end
    else
    begin
      g.DrawLine(p, r.X + (r.Width / 2), r.Y + (r.Height / 3), r.X + (r.Width / 3), r.Y + (r.Height / 3 * 2));
      g.DrawLine(p, r.X + (r.Width / 2), r.Y + (r.Height / 3), r.X + (r.Width / 3 * 2), r.Y + (r.Height / 3 * 2));
    end;
  end
  else
  begin
    if not Left then
    begin
      g.DrawLine(p, r.X + (r.Width / 3), r.Y + (r.Height / 3), r.X + (r.Width / 3 * 2), r.Y + (r.Height / 2));
      g.DrawLine(p, r.X + (r.Width / 3), r.Y + (r.Height / 3 * 2), r.X + (r.Width / 3 * 2), r.Y + (r.Height / 2));
    end
    else
    begin
      g.DrawLine(p, r.X + (r.Width / 3 * 2), r.Y + (r.Height / 3), r.X + (r.Width / 3), r.Y + (r.Height / 2));
      g.DrawLine(p, r.X + (r.Width / 3 * 2), r.Y + (r.Height / 3 * 2), r.X + (r.Width / 3), r.Y + (r.Height / 2));
    end;
  end;
  p.Free;
end;

procedure TAdvSmoothScrollBar.DrawBackGround(g: TGPGraphics);
begin
  Appearance.BackGroundFill.Fill(g, MakeRect(0, 0, Width - 1, Height - 1));
end;

procedure TAdvSmoothScrollBar.DrawScrollButtons(g: TGPGraphics);
var
  fmin, fmax: TGDIPFill;
begin
  fmin := TGDIPFill.Create;
  fmax := TGDIPFill.Create;
  fmin.Assign(Appearance.ScrollButtonLeft);
  fmax.Assign(Appearance.ScrollButtonRight);

  if FDownButton = dbScrollMin then
  begin
    if fmin.Color <> clNone then
      fmin.Color := Darker(fmin.Color, 10);
    if fmin.ColorTo <> clNone then
      fmin.ColorTo := Darker(fmin.ColorTo, 10);
    if fmin.ColorMirror <> clNone then
      fmin.ColorMirror := Darker(fmin.ColorMirror, 10);
    if fmin.ColorMirrorTo <> clNone then
      fmin.ColorMirrorTo := Darker(fmin.ColorMirrorTo, 10);
  end
  else if FHoveredButton = hbScrollMin then
  begin
    if fmin.Color <> clNone then
      fmin.Color := Lighter(fmin.Color, 30);
    if fmin.ColorTo <> clNone then
      fmin.ColorTo := Lighter(fmin.ColorTo, 30);
    if fmin.ColorMirror <> clNone then
      fmin.ColorMirror := Lighter(fmin.ColorMirror, 30);
    if fmin.ColorMirrorTo <> clNone then
      fmin.ColorMirrorTo := Lighter(fmin.ColorMirrorTo, 30);
  end;

  fmin.Fill(g, GetMinScrollButton);

  if FDownButton = dbScrollMax then
  begin
    if fmax.Color <> clNone then
      fmax.Color := Darker(fmax.Color, 10);
    if fmax.ColorTo <> clNone then
      fmax.ColorTo := Darker(fmax.ColorTo, 10);
    if fmax.ColorMirror <> clNone then
      fmax.ColorMirror := Darker(fmax.ColorMirror, 10);
    if fmax.ColorMirrorTo <> clNone then
      fmax.ColorMirrorTo := Darker(fmax.ColorMirrorTo, 10);
  end
  else if FHoveredButton = hbScrollMax then
  begin
    if fmax.Color <> clNone then
      fmax.Color := Lighter(fmax.Color, 30);
    if fmax.ColorTo <> clNone then
      fmax.ColorTo := Lighter(fmax.ColorTo, 30);
    if fmax.ColorMirror <> clNone then
      fmax.ColorMirror := Lighter(fmax.ColorMirror, 30);
    if fmax.ColorMirrorTo <> clNone then
      fmax.ColorMirrorTo := Lighter(fmax.ColorMirrorTo, 30);
  end;

  fmax.Fill(g, GetMaxScrollButton);

  if Appearance.ScrollButtonLeft.Picture.Empty then
    DrawArrow(g, GetMinScrollButton, true);

  if Appearance.ScrollButtonRight.Picture.Empty then
    DrawArrow(g, GetMaxScrollButton, false);

  fmax.Free;
  fmin.Free;
end;

procedure TAdvSmoothScrollBar.DrawThumb(g: TGPGraphics);
begin
  Appearance.ThumbFill.Fill(g, GetThumbRectangle);
  DrawThumbButtons(g);
end;

procedure TAdvSmoothScrollBar.DrawThumbButtons(g: TGPGraphics);
var
  fmin, fmax: TGDIPFill;
begin
  fmin := TGDIPFill.Create;
  fmax := TGDIPFill.Create;
  fmin.Assign(Appearance.ThumbButtonLeft);
  fmax.Assign(Appearance.ThumbButtonRight);

  if FDownButton = dbThumbMin then
  begin
    if fmin.Color <> clNone then
      fmin.Color := Darker(fmin.Color, 10);
    if fmin.ColorTo <> clNone then
      fmin.ColorTo := Darker(fmin.ColorTo, 10);
    if fmin.ColorMirror <> clNone then
      fmin.ColorMirror := Darker(fmin.ColorMirror, 10);
    if fmin.ColorMirrorTo <> clNone then
      fmin.ColorMirrorTo := Darker(fmin.ColorMirrorTo, 10);
  end
  else if FHoveredButton = hbThumbMin then
  begin
    if fmin.Color <> clNone then
      fmin.Color := Lighter(fmin.Color, 30);
    if fmin.ColorTo <> clNone then
      fmin.ColorTo := Lighter(fmin.ColorTo, 30);
    if fmin.ColorMirror <> clNone then
      fmin.ColorMirror := Lighter(fmin.ColorMirror, 30);
    if fmin.ColorMirrorTo <> clNone then
      fmin.ColorMirrorTo := Lighter(fmin.ColorMirrorTo, 30);
  end;

  fmin.Fill(g, GetMinThumbButton);

  if FDownButton = dbThumbMax then
  begin
    if fmax.Color <> clNone then
      fmax.Color := Darker(fmax.Color, 10);
    if fmax.ColorTo <> clNone then
      fmax.ColorTo := Darker(fmax.ColorTo, 10);
    if fmax.ColorMirror <> clNone then
      fmax.ColorMirror := Darker(fmax.ColorMirror, 10);
    if fmax.ColorMirrorTo <> clNone then
      fmax.ColorMirrorTo := Darker(fmax.ColorMirrorTo, 10);
  end
  else if FHoveredButton = hbThumbMax then
  begin
    if fmax.Color <> clNone then
      fmax.Color := Lighter(fmax.Color, 30);
    if fmax.ColorTo <> clNone then
      fmax.ColorTo := Lighter(fmax.ColorTo, 30);
    if fmax.ColorMirror <> clNone then
      fmax.ColorMirror := Lighter(fmax.ColorMirror, 30);
    if fmax.ColorMirrorTo <> clNone then
      fmax.ColorMirrorTo := Lighter(fmax.ColorMirrorTo, 30);
  end;

  fmax.Fill(g, GetMaxThumbButton);

  if Appearance.ThumbButtonLeft.Picture.Empty then
    DrawArrow(g, GetMinThumbButton, true);

  if Appearance.ThumbButtonRight.Picture.Empty then
    DrawArrow(g, GetMaxThumbButton, false);

  fmin.Free;
  fmax.Free;
end;

function TAdvSmoothScrollBar.GetMaxScrollButton: TGPRectF;
var
  r: TRect;
begin
  r := InsideRect;
  case Kind of
    sbHorizontal: Result := MakeRect(r.Right - Appearance.ScrollButtonSize, r.Top, Appearance.ScrollButtonSize, r.Bottom - r.Top);
    sbVertical: Result := MakeRect(r.Left, r.Bottom - Appearance.ScrollButtonSize, r.Right - r.Left, Appearance.ScrollButtonSize);
  end;
end;

function TAdvSmoothScrollBar.GetMaxThumbButton: TGPRectF;
var
  r: TGPRectF;
begin
  r := GetThumbRectangle;
  if Appearance.ThumbFill.BorderColor <> clNone then
  begin
    r.X := r.X + Appearance.ThumbFill.BorderWidth;
    r.Y := r.Y + Appearance.ThumbFill.BorderWidth;
    r.Width := r.Width - Appearance.ThumbFill.BorderWidth * 2;
    r.Height := r.Height - Appearance.ThumbFill.BorderWidth * 2;
  end;
  case Kind of
    sbHorizontal: Result := MakeRect(r.X + r.Width - Appearance.ThumbButtonSize, r.Y, Appearance.ThumbButtonSize, r.Height);
    sbVertical: Result := MakeRect(r.X, r.Y + r.Height - Appearance.ThumbButtonSize, r.Width, Appearance.ThumbButtonSize);
  end;
end;

function TAdvSmoothScrollBar.GetMinScrollButton: TGPRectF;
var
  r: TRect;
begin
  r := InsideRect;
  case Kind of
    sbHorizontal: Result := MakeRect(r.Left, r.Top, Appearance.ScrollButtonSize, r.Bottom - r.Top);
    sbVertical: Result := MakeRect(r.Left, r.Top, r.Right - r.Left, Appearance.ScrollButtonSize);
  end;
end;

function TAdvSmoothScrollBar.GetMinThumbButton: TGPRectF;
var
  r: TGPRectF;
begin
  r := GetThumbRectangle;
  if Appearance.ThumbFill.BorderColor <> clNone then
  begin
    r.X := r.X + Appearance.ThumbFill.BorderWidth;
    r.Y := r.Y + Appearance.ThumbFill.BorderWidth;
    r.Width := r.Width - Appearance.ThumbFill.BorderWidth * 2;
    r.Height := r.Height - Appearance.ThumbFill.BorderWidth * 2;
  end;

  case Kind of
    sbHorizontal: Result := MakeRect(r.X, r.Y, Appearance.ThumbButtonSize, r.Height);
    sbVertical: Result := MakeRect(r.X, r.Y, r.Width, Appearance.ThumbButtonSize);
  end;
end;

function TAdvSmoothScrollBar.GetPosition(XYPos: Double): integer;
var
  v, s: Double;
  scr: TGPRectF;
begin
  scr := GetScrollRectangle;
  s := 0;
  case Kind of
    sbHorizontal: s := scr.Width - Math.Max(Appearance.ThumbButtonSize * 2 + 10, (scr.Width / GetRange * PageSize));
    sbVertical: s := scr.Height - Math.Max(Appearance.ThumbButtonSize * 2 + 10, (scr.Height / GetRange * PageSize));
  end;

  if (max - min > 0) and (s > 0) then
  begin
    v := (XYPos / s) * (max - min) + min;
    Result := Round(Math.Max(Math.Min(v, max), min));
  end
  else
    Result := 0;
end;

function TAdvSmoothScrollBar.GetPosition: integer;
var
  s: Double;
  scr: TGPRectF;
begin
  Result := 0;
  scr := GetScrollRectangle;
  s := 0;
  case Kind of
    sbHorizontal: s := scr.Width - Math.Max(Appearance.ThumbButtonSize * 2 + 10, (scr.Width / GetRange * PageSize));
    sbVertical: s := scr.Height - Math.Max(Appearance.ThumbButtonSize * 2 + 10, (scr.Height / GetRange * PageSize));
  end;

  if s <= 0 then
    Exit;

  if (Max - Min) > 0 then
    Result := Round(Math.Min(((Position - Min) / (Max - Min)) * s, s))
  else
    Result := Min;
end;

function TAdvSmoothScrollBar.GetRange: integer;
begin
  Result := Math.Max(1, Max - Min);
end;

function TAdvSmoothScrollBar.GetScrollAreaMin: TGPRectF;
var
  scr: TGPRectF;
  thr: TGPRectF;
begin
  scr := GetScrollRectangle;
  thr := GetThumbRectangle;
  case Kind of
    sbHorizontal:
    begin
      Result.X := scr.X;
      Result.Y := scr.Y;
      Result.Width := thr.X - scr.X;
      result.Height := scr.Height;
    end;
    sbVertical:
    begin
      Result.X := scr.X;
      Result.Y := scr.Y;
      Result.Width := scr.Width;
      result.Height := thr.Y - scr.Y;
    end;
  end;
end;

function TAdvSmoothScrollBar.GetScrollAreaMax: TGPRectF;
var
  scr: TGPRectF;
  thr: TGPRectF;
begin
  scr := GetScrollRectangle;
  thr := GetThumbRectangle;
  case Kind of
    sbHorizontal:
    begin
      Result.X := thr.X + thr.Width;
      Result.Y := scr.Y;
      Result.Width := scr.Width - thr.Width - thr.X + scr.X;
      result.Height := scr.Height;
    end;
    sbVertical:
    begin
      Result.X := scr.X;
      Result.Y := thr.Y + thr.Height;
      Result.Width := scr.Width;
      result.Height := scr.Height - thr.Height - thr.Y + scr.Y;
    end;
  end;
end;

function TAdvSmoothScrollBar.GetScrollRectangle: TGPRectF;
begin
  case Kind of
    sbHorizontal:
    begin
      Result.X := GetMinScrollButton.X + GetMinScrollButton.Width;
      Result.Y := GetMinScrollButton.Y;
      Result.Height := GetMinScrollButton.Height;
      Result.Width := GetMaxScrollButton.X - GetMinScrollbutton.Width;
      Result.X := Result.X + 1;
      Result.Width := Result.Width - 3;
    end;
    sbVertical:
    begin
      Result.X := GetMinScrollButton.X;
      Result.Y := GetMinScrollButton.Y + GetMinScrollButton.Height;
      Result.Height := GetMaxScrollButton.Y - GetMinScrollButton.Height;
      Result.Width := GetMinScrollButton.Width;
      Result.Y := Result.Y + 1;
      Result.Height := Result.Height - 3;
    end;
  end;
end;

function TAdvSmoothScrollBar.GetScrollSize: integer;
begin
  Result := 0;
  case Kind of
    sbHorizontal: Result := Round(GetScrollRectangle.Width - GetThumbRectangle.Width);
    sbVertical: Result := Round(GetScrollRectangle.Height - GetThumbRectangle.Height);
  end;
end;

function TAdvSmoothScrollBar.GetThemeID: String;
begin
  Result := ClassName;
end;

function TAdvSmoothScrollBar.GetThumbRectangle: TGPRectF;
var
  scr: TGPRectF;
  s: Double;
begin
  scr := GetScrollRectangle;
  case Kind of
    sbHorizontal:
    begin
      s := scr.Width / GetRange * PageSize;
      Result.X := scr.X + GetPosition;
      Result.Y := scr.Y;
      Result.Width := Math.Max(Appearance.ThumbButtonSize * 2 + 10, s);
//      Result.Width := s;
      Result.Height := scr.Height;
    end;
    sbVertical:
    begin
      s := scr.Height / GetRange * PageSize;
      Result.X := scr.X;
      Result.Y := scr.Y + GetPosition;
      Result.Width := scr.Width;
      Result.Height := Math.Max(Appearance.ThumbButtonSize * 2 + 10, s);
//      Result.Height := s;
    end;
  end;
end;

function TAdvSmoothScrollBar.InsideRect: TRect;
var
  bw: integer;
begin
  Result := ClientRect;
  // adapt width & height for GDI+ drawing rect
  Result.Right := Result.Right - 1;
  Result.Bottom := Result.Bottom - 1;

  if (Appearance.BackGroundFill.BorderColor <> clNone) then
  begin
    if Appearance.BackGroundFill.BorderWidth = 1 then
      bw := 1
    else
      bw := (Appearance.BackGroundFill.BorderWidth + 1) div 2;

    InflateRect(Result, -bw, -bw);
  end;

  if (Appearance.BackGroundFill.ShadowOffset <> 0) and (Appearance.BackGroundFill.ShadowColor <> clNone) then
  begin
    Result.Right := Result.Right -Appearance.BackGroundFill.ShadowOffset;
    Result.Bottom := Result.Bottom -Appearance.BackGroundFill.ShadowOffset;
  end;
end;

procedure TAdvSmoothScrollBar.KeyDown(var Key: Word; Shift: TShiftState);
begin
  inherited;
  case Key of
    VK_UP, VK_LEFT: Position := Position - SmallChange;
    VK_DOWN, VK_RIGHT: Position := Position + SmallChange;
    VK_HOME: Position := Min;
    VK_END: Position := Max;
    VK_PRIOR: Position := Position - LargeChange;
    VK_NEXT: Position := Position + LargeChange;
  end;
end;

procedure TAdvSmoothScrollBar.LoadFromTheme(FileName: String);
begin

end;

procedure TAdvSmoothScrollBar.MouseDown(Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  inherited;
  FCx := Abs(X - GetThumbRectangle.X + GetScrollRectangle.X);
  FCy := Abs(Y - GetThumbRectangle.Y + GetScrollRectangle.Y);
  FMx := X;
  FMy := Y;
  FSavedPageSize := PageSize;
  {
  FScrollX := X;
  FScrollY := Y;
  FTimeStart := GetTickCount;
  FDoAnimate := false;
  }
  FTime := 0;
  FTimer.Enabled := true;
  if MouseOnThumbButtons(X, Y) then
  begin
    FScrollBarMode := sbmChangePageSize;
    FMinThumb := PtInGPRect(GetMinThumbButton, Point(X, Y));
    FMaxThumb := PtInGPRect(GetMaxThumbButton, Point(X, Y));
  end
  else if MouseOnThumb(X, Y) then
    FScrollBarMode := sbmScroll
  else if PtInGPRect(GetMinScrollButton, Point(X, Y)) then
    FScrollButtonChange := sbcSmallSubstract
  else if PtInGPRect(GetMaxScrollButton, Point(X, Y)) then
    FScrollButtonChange := sbcSmallAdd
  else if PtInGPRect(GetScrollAreaMin, Point(X, Y)) then
    FScrollButtonChange := sbcLargeSubstract
  else if PtInGPRect(GetScrollAreaMax, Point(X, Y)) then
    FScrollButtonChange := sbcLargeAdd;

  if PtInGPRect(GetMinThumbButton, Point(X, Y)) and not (FDownButton = dbThumbMin) then
  begin
    FDownButton := dbThumbMin;
    Changed;
  end
  else if PtInGPRect(GetMaxThumbButton, Point(X, Y)) and not (FDownButton = dbThumbMax) then
  begin
    FDownButton := dbThumbMax;
    Changed;
  end
  else if PtInGPRect(GetMinScrollButton, Point(X, Y)) and not (FDownButton = dbScrollMin) then
  begin
    FDownButton := dbScrollMin;
    Changed;
  end
  else if PtInGPRect(GetMaxScrollButton, Point(X, Y)) and not (FDownButton = dbScrollMax) then
  begin
    FDownButton := dbScrollMax;
    Changed;
  end;
end;

procedure TAdvSmoothScrollBar.MouseMove(Shift: TShiftState; X, Y: Integer);
var
  pos: Double;
  v: integer;
begin
  inherited;
  {
  if FMouseUp then
  begin
    FMouseUp := false;
    if ((FTimeStop - FTimeStart) > 500) or ((FTimeStop - FTimeStart) = 0) then
      exit;

    FSp := Abs(Y - FScrollY) / (FTimeStop - FTimeStart);
    if FSp > 0 then
    begin
      if (Y - FScrollY) > 0 then
        FPositionto := FPosition + 5000
      else
        FPositionto := FPosition - 5000
    end;

    FDoAnimate := true;
  end
  else
  }
  begin
    if FScrollBarMode = sbmChangePageSize then
    begin
      case Kind of
        sbHorizontal: Screen.Cursor := crSizeWE;
        sbVertical: Screen.Cursor := crSizeNS;
      end;

      pos := 0;
      case Kind of
        sbHorizontal: pos := GetRange / GetScrollRectangle.Width * (X - FMx);
        sbVertical: pos := GetRange / GetScrollRectangle.Height * (Y - FMy);
      end;

      if FMinThumb then
      begin
        if Position - Min > 0 then
          PageSize := FSavedPageSize - Round(pos * (GetRange / (Position - Min)))
        else
          PageSize := FSavedPageSize - Round(pos)
      end
      else if FMaxThumb then
      begin
        if Position - Min < GetRange then
          PageSize := FSavedPageSize + Round(pos * (GetRange / (Max - Position)))
        else
          PageSize := FSavedPageSize + Round(pos)
      end;
    end
    else if FScrollBarMode = sbmScroll then
    begin
      pos := 0;
      case Kind of
        sbHorizontal: pos := X - FCx;
        sbVertical: pos := Y - FCy;
      end;

      v := GetPosition(pos);
      Position := v;
    end
    else if MouseOnThumbButtons(X, Y) then
    begin
      case Kind of
        sbHorizontal: Screen.Cursor := crSizeWE;
        sbVertical: Screen.Cursor := crSizeNS;
      end;
    end
    else
    begin
      Screen.Cursor := crDefault;
    end;
  end;

  if PtInGPRect(GetMinThumbButton, Point(X, Y)) and not (FHoveredButton = hbThumbMin) then
  begin
    FHoveredButton := hbThumbMin;
    Changed;
  end
  else if PtInGPRect(GetMaxThumbButton, Point(X, Y)) and not (FHoveredButton = hbThumbMax) then
  begin
    FHoveredButton := hbThumbMax;
    Changed;
  end
  else if PtInGPRect(GetMinScrollButton, Point(X, Y)) and not (FHoveredButton = hbScrollMin) then
  begin
    FHoveredButton := hbScrollMin;
    Changed;
  end
  else if PtInGPRect(GetMaxScrollButton, Point(X, Y)) and not (FHoveredButton = hbScrollMax) then
  begin
    FHoveredButton := hbScrollMax;
    Changed;
  end
  else if not PtInGPRect(GetMaxThumbButton, Point(X, Y)) and not PtInGPRect(GetMinThumbButton, Point(X, Y)) and not PtInGPRect(GetMaxScrollButton, Point(X, Y))
    and not PtInGPRect(GetMinScrollButton, Point(X, Y)) and (FHoveredButton <> hbNone) then
  begin
    FHoveredButton := hbNone;
    Changed;
  end;

end;

function TAdvSmoothScrollBar.MouseOnThumb(X, Y: integer): Boolean;
begin
  Result := PtInGPRect(GetThumbRectangle, Point(X, Y));
end;

function TAdvSmoothScrollBar.MouseOnThumbButtons(X, Y: integer): Boolean;
begin
  result := PtInGPRect(GetMinThumbButton, Point(X, Y)) or PtInGPRect(GetMaxThumbButton, Point(X, Y));
end;

procedure TAdvSmoothScrollBar.MouseUp(Button: TMouseButton; Shift: TShiftState;
  X, Y: Integer);
begin
  inherited;
  {
  FMouseUp := true;
  FTimeStop := GetTickCount;
  }
  if (FScrollBarMode = sbmNone) then
  begin
    if PtInGPRect(GetMinScrollButton, Point(X, Y)) then
      Position := Position - SmallChange
    else if PtInGPRect(GetMaxScrollButton, Point(X, Y)) then
      Position := Position + SmallChange
    else if PtInGPRect(GetScrollAreaMin, Point(X, Y)) then
      Position := Position - LargeChange
    else if PtInGPRect(GetScrollAreaMax, Point(X, Y)) then
      Position := Position + LargeChange;
  end;

  FDownButton := dbNone;
  FMinThumb := false;
  FMaxThumb := false;
  FTimer.Enabled := false;
  FTime := 0;
  FScrollBarMode := sbmNone;
  Screen.Cursor := crDefault;
  FScrollButtonChange := sbcNone;
  Changed;
end;

procedure TAdvSmoothScrollBar.MouseWheelHandler(var Message: TMessage);
begin
  inherited;
  case Message.Msg of
    WM_MOUSEWHEEL:
    begin
      if Message.WParam < 0 then
        Position := Position + LargeChange
      else
        Position := Position - LargeChange;
    end;
  end;
end;

procedure TAdvSmoothScrollBar.Paint;
var
  g: TGPGraphics;
begin
  g := TGPGraphics.Create(Canvas.Handle);
  g.SetSmoothingMode(SmoothingModeAntiAlias);
  g.SetTextRenderingHint(TextRenderingHintClearTypeGridFit);
  if not Transparent then
    DrawBackGround(g);
  DrawThumb(g);
  DrawScrollButtons(g);
  g.Free;
end;

function TAdvSmoothScrollBar.PtInGPRect(r: TGPRectF; pt: TPoint): Boolean;
begin
  result := ((pt.X >= r.X) and (pt.X <= r.X + r.Width)) and
     ((pt.Y >= r.Y) and (pt.Y <= r.Y + r.Height));
end;

//procedure TAdvSmoothScrollBar.SetAnimation(const Value: Boolean);
//begin
//  if FAnimation <> value then
//  begin
//    FAnimation := Value;
//    Changed;
//  end;
//end;
//
//procedure TAdvSmoothScrollBar.SetAnimationFactor(const Value: integer);
//begin
//  if FAnimationFactor <> value then
//  begin
//    FAnimationFactor := Math.Max(0, Value);
//    Changed;
//  end;
//end;

procedure TAdvSmoothScrollBar.SaveToTheme(FileName: String);
begin

end;

procedure TAdvSmoothScrollBar.SetAppearance(
  const Value: TAdvSmoothScrollBarAppearance);
begin
  if FAppearance <> value then
  begin
    FAppearance.Assign(Value);
    Changed;
  end;
end;

procedure TAdvSmoothScrollBar.SetComponentStyle(AStyle: TTMSStyle);
begin
  with Appearance do
  begin
    // TODO : do color settings here
    case AStyle of
      tsOffice2003Blue:
        begin
          BackGroundFill.Color := $00FFD2AF;
          BackGroundFill.ColorTo := $00FFD2AF;
          BackGroundFill.BorderColor := clNone;

          ScrollButtonLeft.Color := $D68759;
          ScrollButtonLeft.ColorTo := $933803;
          ScrollButtonLeft.BorderColor := $962D00;
        end;
      tsOffice2003Silver:
        begin
          BackGroundFill.Color := $00E6D8D8;
          BackGroundFill.ColorTo := $00E6D8D8;
          BackGroundFill.BorderColor := clNone;

          ScrollButtonLeft.Color := $BDA4A5;
          ScrollButtonLeft.ColorTo := $957475;
          ScrollButtonLeft.BorderColor := $947C7C;
        end;
      tsOffice2003Olive:
        begin
          BackGroundFill.Color := RGB(225, 234, 185);
          BackGroundFill.ColorTo := RGB(225, 234, 185);
          BackGroundFill.BorderColor := clNone;

          ScrollButtonLeft.Color := $82C0AF;
          ScrollButtonLeft.ColorTo := $447A63;
          ScrollButtonLeft.BorderColor := $588060;
        end;
      tsOffice2003Classic:
        begin
          BackGroundFill.Color := $00F2F2F2;
          BackGroundFill.ColorTo := $00F2F2F2;
          BackGroundFill.BorderColor := clNone;

          ScrollButtonLeft.Color := $808080;
          ScrollButtonLeft.ColorTo := $808080;
          ScrollButtonLeft.BorderColor := $808080;
        end;
      tsOffice2007Luna:
        begin
          BackGroundFill.Color := $00F3E5DA;
          BackGroundFill.ColorTo := $00F0DED0;
          BackGroundFill.BorderColor := clNone;

          ScrollButtonLeft.Color := $FFEFE3;
          ScrollButtonLeft.ColorTo := $FFD2AF;
          ScrollButtonLeft.BorderColor := $00FFD2AF;
        end;
      tsOffice2007Obsidian:
        begin
          BackGroundFill.Color := $5C534C;
          BackGroundFill.ColorTo := $5C534C;
          BackGroundFill.BorderColor := clNone;

          ScrollButtonLeft.Color := $F2F1F0;
          ScrollButtonLeft.ColorTo := $C9C2BD;
          ScrollButtonLeft.BorderColor := $5C534C;
        end;
      tsWindowsXP:
        begin
          BackGroundFill.Color := $00B6B6B6;
          BackGroundFill.ColorTo := $00B6B6B6;

          ScrollButtonLeft.Color := clBtnFace;
          ScrollButtonLeft.ColorTo := clBtnFace;
          ScrollButtonLeft.BorderColor := clBlack;
        end;
      tsWhidbey:
        begin
          BackGroundFill.Color := $F5F9FA;
          BackGroundFill.ColorTo := $F5F9FA;
          BackGroundFill.BorderColor := clNone;

          ScrollButtonLeft.Color := $EBEEEF;
          ScrollButtonLeft.ColorTo := $7E9898;
          ScrollButtonLeft.BorderColor := $962D00;
        end;
      tsCustom: ;
      tsOffice2007Silver:
        begin
          BackGroundFill.Color := RGB(241, 244, 248);
          BackGroundFill.ColorTo := RGB(227, 232, 240);
          BackGroundFill.BorderColor := clNone;

          ScrollButtonLeft.Color := $F8F7F6;
          ScrollButtonLeft.ColorTo := $E8E0DB;
          ScrollButtonLeft.BorderColor := $74706F;
        end;
      tsWindowsVista:
        begin
          BackGroundFill.Color := $FDF8F1;
          BackGroundFill.ColorTo := $FCEFD5;
          BackGroundFill.BorderColor := clNone;

          ScrollButtonLeft.Color := $FEF9F0;
          ScrollButtonLeft.ColorTo := $FDF0D7;
          ScrollButtonLeft.BorderColor := $FDDE99;
        end;
      tsWindows7:
        begin
          BackGroundFill.Color := $FDFBFA;
          BackGroundFill.ColorTo := $FDF3EB;
          BackGroundFill.BorderColor := clNone;

          ScrollButtonLeft.Color := $FCEBDC;
          ScrollButtonLeft.ColorTo := $FCDBC1;
          ScrollButtonLeft.BorderColor := $CEA27D;
        end;
      tsTerminal:
        begin
          BackGroundFill.Color := clBtnFace;
          BackGroundFill.ColorTo := clBtnFace;
          BackGroundFill.BorderColor := clNone;

          ScrollButtonLeft.Color := clSilver;
          ScrollButtonLeft.ColorTo := clSilver;
          ScrollButtonLeft.BorderColor := clGray;
        end;
         tsOffice2010Blue:
        begin
          BackGroundFill.Color := $FDF6EF;
          BackGroundFill.ColorTo := $F0DAC7;
          BackGroundFill.BorderColor := $C7B29F;

          ScrollButtonLeft.Color := $EAD3BF;
          ScrollButtonLeft.ColorTo := clNone;
          ScrollButtonLeft.BorderColor := $5B391E;
        end;
         tsOffice2010Silver:
        begin
          BackGroundFill.Color := $FFFFFF;
          BackGroundFill.ColorTo := $EDE5E0;
          BackGroundFill.BorderColor := $D2CDC8;

          ScrollButtonLeft.Color := $D4CFCB;
          ScrollButtonLeft.ColorTo := clNone;
          ScrollButtonLeft.BorderColor := $7C6D66;
        end;
         tsOffice2010Black:
        begin
          BackGroundFill.Color := $BFBFBF;
          BackGroundFill.ColorTo := $919191;
          BackGroundFill.BorderColor := $6D6D6D;

          ScrollButtonLeft.Color := $828282;
          ScrollButtonLeft.ColorTo := clNone;
          ScrollButtonLeft.BorderColor := $656565;
        end;
    end;

    ScrollButtonRight.Assign(ScrollButtonLeft);
    ThumbButtonLeft.Assign(ScrollButtonLeft);
    ThumbButtonRight.Assign(ScrollButtonLeft);
    ThumbFill.Color := clWhite;
    ThumbFill.Opacity := 100;
    ThumbFill.GradientType := gtSolid;
    ThumbFill.BorderColor := clWhite;
    BackGroundFill.BorderColor := clSilver;
  end;
end;

procedure TAdvSmoothScrollBar.SetKind(Value: TScrollBarKind);
begin
  if FKind <> Value then
  begin
    FKind := Value;
    if not (csLoading in ComponentState) then
      SetBounds(Left, Top, Height, Width);
    Changed;
  end;
end;

procedure TAdvSmoothScrollBar.SetMax(const Value: Integer);
begin
  if FMax <> value then
  begin
    FMax := Value;
    Changed;
  end;
end;

procedure TAdvSmoothScrollBar.SetMin(const Value: Integer);
begin
  if FMin <> value then
  begin
    FMin := Value;
    Changed;
  end;
end;

procedure TAdvSmoothScrollBar.SetPageSize(const Value: Integer);
begin
  if FPageSize <> value then
  begin
    FPageSize := Math.Min(GetRange, Math.Max(0, Value));
    if Assigned(FOnPageSizeChanged) then
      FOnPageSizeChanged(Self, PageSize);
    Changed;
  end;
end;

procedure TAdvSmoothScrollBar.SetPosition(const Value: Integer);
begin
  if FPosition <> value then
  begin
    FPosition := Math.Max(Self.Min, Math.Min(Self.Max, Value));
//    FPositionTo := FPosition;
    if Assigned(FOnPositionChange) then
        FOnPositionChange(Self, Position);
    changed;
  end;
end;

procedure TAdvSmoothScrollBar.SetTransparent(const Value: Boolean);
begin
  if FTransparent <> value then
  begin
    FTransparent := Value;
    Changed;
  end;
end;

procedure TAdvSmoothScrollBar.TimerChanged(Sender: TObject);
begin
  Inc(FTime);
  if FTime >= 4 then
  begin
    if FScrollButtonChange = sbcSmallSubstract then
    begin
      Position := Position - SmallChange;
      Changed;
    end
    else if FScrollButtonChange = sbcSmallAdd then
    begin
      Position := Position + SmallChange;
      Changed;
    end
    else if FScrollButtonChange = sbcLargeSubstract then
    begin
      Position := Position - LargeChange;
      Changed;
    end
    else if FScrollButtonChange = sbcLargeAdd then
    begin
      Position := Position + LargeChange;
      Changed;
    end;
  end;
end;

procedure TAdvSmoothScrollBar.WMEraseBkgnd(var Message: TWMEraseBkgnd);
begin
  message.Result := 1;
end;

procedure TAdvSmoothScrollBar.WMGetDlgCode(var Message: TWMGetDlgCode);
begin
  if TabStop then
    Message.Result := DLGC_WANTALLKEYS or DLGC_WANTARROWS
  else
    Message.Result := 0;
end;

procedure TAdvSmoothScrollBar.WMPaint(var Message: TWMPaint);
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

end.
