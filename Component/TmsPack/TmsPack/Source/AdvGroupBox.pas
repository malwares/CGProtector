{***************************************************************************}
{ TAdvGroupBox component                                                    }
{ for Delphi & C++Builder                                                   }
{                                                                           }
{ written by TMS Software                                                   }
{            copyright © 2007 - 2009                                        }
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

unit AdvGroupBox;

{$I TMSDEFS.INC}

interface

uses
  Classes, Windows, Forms, Dialogs, Controls, Graphics, Messages, ExtCtrls,
  SysUtils, StdCtrls, ImgList;

const

  MAJ_VER = 1; // Major version nr.
  MIN_VER = 0; // Minor version nr.
  REL_VER = 0; // Release nr.
  BLD_VER = 2; // Build nr.

  // version history
  // v1.0.0.0 : first release
  // v1.0.0.1 : fixed issue for XP theming
  // v1.0.0.2 : fixed issue with persisting Ctl3D property setting


type
  TCaptionPosition = (cpTopLeft, cpTopRight, cpTopCenter, cpBottomLeft, cpBottomRight, cpBottomCenter);
  TBorderStyle = (bsNone, bsSingle, bsDouble);

  TWinCtrl = class(TWinControl)
  public
    procedure PaintCtrls(DC: HDC; First: TControl);
  end;

  TAdvCustomGroupBox = class(TCustomGroupBox)
  private
    FTransparent: Boolean;
    FBorderColor: TColor;
    FImageIndex: Integer;
    FImages: TCustomImageList;
    FBorderStyle: TBorderStyle;
    FCaptionPosition: TCaptionPosition;
    FRoundEdges: Boolean;
    Procedure WMEraseBkGnd( Var msg: TWMEraseBkGnd ); message WM_ERASEBKGND;
    procedure CMCtl3DChanged(var Message: TMessage); message CM_CTL3DCHANGED;
    procedure SetTransparent(const Value: Boolean);
    procedure SetBorderColor(const Value: TColor);
    procedure SetImageIndex(const Value: Integer);
    procedure SetImages(const Value: TCustomImageList);
    function GetVersion: string;
    procedure SetVersion(const Value: string);
    procedure SetBorderStyle(const Value: TBorderStyle);
    procedure SetCaptionPosition(const Value: TCaptionPosition);
    procedure SetRoundEdges(const Value: Boolean);
  protected
    procedure Loaded; override;
    procedure Paint; override;
    procedure PaintTransparency; virtual;
    procedure Notification(AComponent: TComponent; AOperation: TOperation); override;
    procedure AdjustClientRect(var Rect: TRect); override;
    procedure CreateParams(var Params: TCreateParams); override;
    function GetCaptionHeight: Integer;
    function GetCaptionRect: TRect;
    function GetBorderWidth: Integer;
    function GetBorderRect: TRect;

    property CaptionPosition: TCaptionPosition read FCaptionPosition write SetCaptionPosition default cpTopLeft;
    property BorderStyle: TBorderStyle read FBorderStyle write SetBorderStyle default bsSingle;
    property Transparent: Boolean read FTransparent write SetTransparent default true;
    property BorderColor: TColor read FBorderColor write SetBorderColor default clSilver;
    property Images: TCustomImageList read FImages write SetImages;
    property ImageIndex: Integer read FImageIndex write SetImageIndex default -1;
    property Version: string read GetVersion write SetVersion stored false;
    property RoundEdges: Boolean read FRoundEdges write SetRoundEdges default False;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    function GetVersionNr: integer;
  end;

  TAdvGroupBox = class(TAdvCustomGroupBox)
  published
    property BorderColor;
    property BorderStyle;
    property CaptionPosition;
    property Images;
    property ImageIndex;
    property Transparent;
    property RoundEdges;
    property Version;

    property Align;
    property Anchors;
    property BiDiMode;
    property Caption;
    property Color;
    property Constraints;
    property Ctl3D default False;
    property DockSite;
    property DragCursor;
    property DragKind;
    property DragMode;
    property Enabled;
    property Font;
    {$IFDEF DELPHI7_LVL}
    property ParentBackground default True;
    {$ENDIF}
    property ParentBiDiMode;
    property ParentColor;
    property ParentCtl3D default False;
    property ParentFont;
    property ParentShowHint;
    property PopupMenu;
    property ShowHint;
    property TabOrder;
    property TabStop;
    property Visible;
    property OnClick;
    property OnContextPopup;
    property OnDblClick;
    property OnDragDrop;
    property OnDockDrop;
    property OnDockOver;
    property OnDragOver;
    property OnEndDock;
    property OnEndDrag;
    property OnEnter;
    property OnExit;
    property OnGetSiteInfo;
    property OnMouseDown;
    property OnMouseMove;
    property OnMouseUp;
    property OnStartDock;
    property OnStartDrag;
    property OnUnDock;
  end;

implementation

uses
  Math;

//------------------------------------------------------------------------------

{TWinCtrl}

procedure TWinCtrl.PaintCtrls(DC: HDC; First: TControl);
begin
  PaintControls(DC, First);
end;

//------------------------------------------------------------------------------

{ TAdvCustomGroupBox }

constructor TAdvCustomGroupBox.Create(AOwner: TComponent);
begin
  inherited;
  ControlStyle := ControlStyle - [csOpaque];
  FTransparent := True;
  FImages := nil;
  FImageIndex := -1;
  FBorderStyle := bsSingle;
  FCaptionPosition := cpTopLeft;
  FRoundEdges := false;
  Ctl3D := false;
  ParentCtl3D := false;
  FBorderColor := clSilver;
end;

//------------------------------------------------------------------------------

procedure TAdvCustomGroupBox.CreateParams(var Params: TCreateParams);
begin
  inherited CreateParams(Params);
  //params.ExStyle := params.ExStyle  or WS_EX_TRANSPARENT;
end;

//------------------------------------------------------------------------------

destructor TAdvCustomGroupBox.Destroy;
begin
  inherited;
end;

//------------------------------------------------------------------------------

procedure TAdvCustomGroupBox.Loaded;
begin
  inherited;
end;

//------------------------------------------------------------------------------

procedure TAdvCustomGroupBox.Notification(AComponent: TComponent;
  AOperation: TOperation);
begin
  inherited;
  if not (csDestroying in ComponentState) and (AOperation = opRemove) then
  begin
    if (AComponent = Images) then
    begin
      Images := nil;
    end;
  end;
end;

//------------------------------------------------------------------------------

procedure TAdvCustomGroupBox.AdjustClientRect(var Rect: TRect);
var
  R: TRect;
begin
  R := Rect;
  inherited  AdjustClientRect(Rect);
  Rect := R;
  if CaptionPosition in [cpTopLeft, cpTopCenter, cpTopRight] then
  begin
    Inc(Rect.Top, Max(GetBorderWidth,GetCaptionHeight));
    Rect := Classes.Rect(Rect.Left + GetBorderWidth, Rect.Top, Rect.Right -GetBorderWidth, Rect.Bottom-GetBorderWidth);
  end
  else if CaptionPosition in [cpBottomLeft, cpBottomCenter, cpBottomRight] then
  begin
    Dec(Rect.Bottom, Max(GetBorderWidth,GetCaptionHeight));
    Rect := Classes.Rect(Rect.Left + GetBorderWidth, Rect.Top + GetBorderWidth, Rect.Right -GetBorderWidth, Rect.Bottom);
  end;

  InflateRect(Rect, -1, -1);
end;

//------------------------------------------------------------------------------

procedure TAdvCustomGroupBox.PaintTransparency;
var
  i: Integer;
  P: TPoint;

begin
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
  begin
    (Parent as TWinCtrl).PaintCtrls(Canvas.Handle, nil);
  end;

  RestoreDC(Canvas.Handle, i);
end;


//------------------------------------------------------------------------------

procedure TAdvCustomGroupBox.Paint;
var
  R, CapR: TRect;
  i, rt: Integer;
  bmp: TBitmap;
begin
  if Transparent then
    PaintTransparency;

  R := ClientRect;
  CapR := GetCaptionRect;
  bmp := TBitmap.Create;
  bmp.Height := (CapR.Bottom - CapR.Top);
  bmp.Width := (CapR.Right - CapR.Left) + 2;
  i := CapR.Left;
  rt := 6;

  //--- Draw Image
  if Assigned(Images) and (ImageIndex >= 0) then
  begin
    Images.Draw(Canvas, CapR.Left, CapR.Top, ImageIndex, Enabled);
    i := CapR.Left + Images.Width + 3;
  end;

  Canvas.Brush.Style := bsClear;
  //--- Draw Caption
  if (Caption <> '') then
  begin
    Canvas.Font.Assign(Self.Font);
    R := Rect(i, CapR.Top, CapR.Right, CapR.Bottom);
    DrawText(Canvas.Handle,PChar(Caption),Length(Caption), R, DT_SINGLELINE or DT_LEFT or DT_VCENTER);
  end;

  bmp.Canvas.CopyRect(Rect(0, 0, bmp.Width, bmp.Height), Canvas, Rect(CapR.Left-1, CapR.Top, CapR.Right+1, CapR.Bottom));
  R := GetBorderRect;
  //--- Draw Borders
  case BorderStyle of
    bsSingle:
    begin
      (*
      if Ctl3D then
      begin

        Canvas.Brush.Style := bsClear;
        Canvas.Pen.Color := clWhite;
        R.Left := R.Left + 1;
        R.Top := R.Top + 1;
        if FRoundEdges then
          Canvas.RoundRect(R.Left, R.Top, R.Right, R.Bottom, rt, rt)
        else
          Canvas.Rectangle(R);

        Canvas.Pen.Color := clGray;
        R.Bottom := R.Bottom -1;
        R.Right := R.Right - 1;
        R.Left := R.Left - 1;
        R.Top := R.Top - 1;
        if FRoundEdges then
          Canvas.RoundRect(R.Left, R.Top, R.Right, R.Bottom, rt, rt)
        else
          Canvas.Rectangle(R);
      end
      else
      *)
      begin
        Canvas.Brush.Style := bsClear;
        Canvas.Pen.Color := BorderColor;
        if FRoundEdges then
          Canvas.RoundRect(R.Left, R.Top, R.Right, R.Bottom, rt, rt)
        else
          Canvas.Rectangle(R);
      end;
    end;
    bsDouble:
    begin
      if Ctl3D then
      begin
        Canvas.Brush.Style := bsClear;
        Canvas.Pen.Color := clWhite;
        R.Left := R.Left + 1;
        R.Top := R.Top + 1;
        if FRoundEdges then
          Canvas.RoundRect(R.Left, R.Top, R.Right, R.Bottom, rt, rt)
        else
          Canvas.Rectangle(R);
        Canvas.Pen.Color := clGray;
        R.Bottom := R.Bottom -1;
        R.Right := R.Right - 1;
        R.Left := R.Left - 1;
        R.Top := R.Top - 1;
        if FRoundEdges then
          Canvas.RoundRect(R.Left, R.Top, R.Right, R.Bottom, rt, rt)
        else
          Canvas.Rectangle(R);

        R.Bottom := R.Bottom +1;
        R.Right := R.Right + 1;

        R := Rect(R.Left+2, R.Top+2, R.Right-2, R.Bottom-2);

        Canvas.Pen.Color := clWhite;
        R.Left := R.Left + 1;
        R.Top := R.Top + 1;
        if FRoundEdges then
          Canvas.RoundRect(R.Left, R.Top, R.Right, R.Bottom, rt, rt)
        else
          Canvas.Rectangle(R);
        Canvas.Pen.Color := clGray;
        R.Bottom := R.Bottom -1;
        R.Right := R.Right - 1;
        R.Left := R.Left - 1;
        R.Top := R.Top - 1;
        if FRoundEdges then
          Canvas.RoundRect(R.Left, R.Top, R.Right, R.Bottom, rt, rt)
        else
          Canvas.Rectangle(R);
      end
      else
      begin
        Canvas.Brush.Style := bsClear;
        Canvas.Pen.Color := BorderColor;
        if FRoundEdges then
          Canvas.RoundRect(R.Left, R.Top, R.Right, R.Bottom, rt, rt)
        else
          Canvas.Rectangle(R);
        R := Rect(R.Left+2, R.Top+2, R.Right-2, R.Bottom-2);
        if FRoundEdges then
          Canvas.RoundRect(R.Left, R.Top, R.Right, R.Bottom, rt, rt)
        else
          Canvas.Rectangle(R);
      end;
    end;
  end;

  if ((Caption <> '') or (Assigned(Images) and (ImageIndex >= 0))) then
  begin
    Canvas.CopyRect(Rect(CapR.Left-1, CapR.Top, CapR.Right+1, CapR.Bottom), bmp.Canvas, Rect(0, 0, bmp.Width, bmp.Height));
  end;
  bmp.Free;
end;

//------------------------------------------------------------------------------

procedure TAdvCustomGroupBox.SetBorderColor(const Value: TColor);
begin
  if (FBorderColor <> Value) then
  begin
    FBorderColor := Value;
    Invalidate;
  end;
end;

//------------------------------------------------------------------------------

procedure TAdvCustomGroupBox.SetImageIndex(const Value: Integer);
begin
  if (FImageIndex <> Value) then
  begin
    FImageIndex := Value;
    Invalidate;
    Realign;
  end;
end;

//------------------------------------------------------------------------------

procedure TAdvCustomGroupBox.SetImages(const Value: TCustomImageList);
begin
  if (FImages <> Value) then
  begin
    FImages := Value;
    if not Assigned(FImages) then
    begin
      ImageIndex := -1;
    end;
    Invalidate;
    Realign;
  end;
end;

//------------------------------------------------------------------------------

procedure TAdvCustomGroupBox.SetTransparent(const Value: Boolean);
begin
  if (FTransparent <> Value) then
  begin
    FTransparent := Value;
    Invalidate;
  end;
end;

//------------------------------------------------------------------------------

procedure TAdvCustomGroupBox.WMEraseBkGnd(var msg: TWMEraseBkGnd);
begin
  inherited;
  //SetBkMode( msg.DC, TRANSPARENT );
  //msg.result := 1;
end;

//------------------------------------------------------------------------------

function TAdvCustomGroupBox.GetVersion: string;
var
  vn: Integer;
begin
  vn := GetVersionNr;
  Result := IntToStr(Hi(Hiword(vn)))+'.'+IntToStr(Lo(Hiword(vn)))+'.'+IntToStr(Hi(Loword(vn)))+'.'+IntToStr(Lo(Loword(vn)));
end;

//------------------------------------------------------------------------------

function TAdvCustomGroupBox.GetVersionNr: integer;
begin
  Result := MakeLong(MakeWord(BLD_VER,REL_VER),MakeWord(MIN_VER,MAJ_VER));
end;

//------------------------------------------------------------------------------

procedure TAdvCustomGroupBox.SetVersion(const Value: string);
begin

end;

//------------------------------------------------------------------------------

function TAdvCustomGroupBox.GetCaptionHeight: Integer;
var
  R: TRect;
begin
  R := GetCaptionRect;
  Result := Max(GetBorderWidth, R.Bottom - R.Top);
end;

//------------------------------------------------------------------------------

function TAdvCustomGroupBox.GetBorderWidth: Integer;
begin
  Result := 0;
  case BorderStyle of
    bsNone: Result := 1;
    bsSingle:
    begin
      Result := 1;
      if Ctl3D then
        Result := Result + 1;
    end;
    bsDouble:
    begin
      Result := 2;
      if Ctl3D then
        Result := Result + 2;
    end;
  end;
end;

//------------------------------------------------------------------------------

function TAdvCustomGroupBox.GetBorderRect: TRect;
begin
  Result := ClientRect;
  if CaptionPosition in [cpTopLeft, cpTopCenter, cpTopRight] then
  begin
    Result.Top := Result.Top + (GetCaptionHeight div 2);
  end
  else if CaptionPosition in [cpBottomLeft, cpBottomCenter, cpBottomRight] then
  begin
    if ((Caption <> '') or (Assigned(Images) and (ImageIndex >= 0))) then
    begin
      Result.Bottom := Result.Bottom - (GetCaptionHeight div 2);
      if (BorderStyle = bsDouble) then
        Result.Bottom := Result.Bottom + 1;
    end;  
  end;
end;

//------------------------------------------------------------------------------

function TAdvCustomGroupBox.GetCaptionRect: TRect;
var
  ImgH, ImgW, CapH, CapW, sp, st, w, h: Integer;
  R: TRect;
begin
  Result := Rect(0, 0, 0, 0);
  ImgH := 0;
  ImgW := 0;
  CapH := 0;
  CapW := 0;
  st := 8;
  sp := 0;
  if (Caption <> '') then
  begin
    Canvas.Font.Assign(Self.Font);
    R := Rect(0, 0, 1000, 100);
    DrawText(Canvas.Handle,PChar(Caption),Length(Caption), R, DT_CALCRECT or DT_LEFT or DT_SINGLELINE);
    CapH := R.Bottom - R.Top;
    CapW := R.Right - R.Left;
  end;

  if Assigned(Images) and (ImageIndex >= 0) then
  begin
    ImgH := Images.Height;
    ImgW := Images.Width;
  end;

  if (CapW > 0) and (ImgW > 0) then
  begin
    sp := 3;
  end;

  w := ImgW + sp + CapW;
  h := Max(ImgH, CapH) + 2;
  case CaptionPosition of
    cpTopLeft:
    begin
      Result.Left := st;
      Result.Right := Result.Left + w;
      Result.Bottom := Result.Top + h;
    end;
    cpTopRight:
    begin
      Result.Right := Width - st;
      Result.Left := Result.Right - w;
      Result.Bottom := Result.Top + h;
    end;
    cpTopCenter:
    begin
      Result.Left := (Width - w) div 2;
      Result.Right := Result.Left + w;
      Result.Bottom := Result.Top + h;
    end;
    cpBottomLeft:
    begin
      Result.Left := st;
      Result.Right := Result.Left + w;
      Result.Top := Height - h;
      Result.Bottom := Result.Top + h;
    end;
    cpBottomRight:
    begin
      Result.Right := Width - st;
      Result.Left := Result.Right - w;
      Result.Top := Height - h;
      Result.Bottom := Result.Top + h;
    end;
    cpBottomCenter:
    begin
      Result.Left := (Width - w) div 2;
      Result.Right := Result.Left + w;
      Result.Top := Height - h;
      Result.Bottom := Result.Top + h;
    end;
  end;
end;

//------------------------------------------------------------------------------

procedure TAdvCustomGroupBox.CMCtl3DChanged(var Message: TMessage);
begin
  inherited;
end;

//------------------------------------------------------------------------------

procedure TAdvCustomGroupBox.SetBorderStyle(const Value: TBorderStyle);
begin
  if (FBorderStyle <> Value) then
  begin
    FBorderStyle := Value;
    Invalidate;
    Realign;
  end;
end;

//------------------------------------------------------------------------------

procedure TAdvCustomGroupBox.SetCaptionPosition(
  const Value: TCaptionPosition);
begin
  if (FCaptionPosition <> Value) then
  begin
    FCaptionPosition := Value;
    Invalidate;
    Realign;
  end;
end;

//------------------------------------------------------------------------------

procedure TAdvCustomGroupBox.SetRoundEdges(const Value: Boolean);
begin
  if (FRoundEdges <> Value) then
  begin
    FRoundEdges := Value;
    Invalidate;
  end;
end;

//------------------------------------------------------------------------------

{$IFDEF FREEWARE}
{$I TRIAL.INC}
{$ENDIF}


end.
