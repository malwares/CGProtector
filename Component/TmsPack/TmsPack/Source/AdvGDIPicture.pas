{***************************************************************************}
{ TAdvGDIPicture                                                            }
{ for Delphi & C++Builder                                                   }
{ version 1.0                                                               }
{                                                                           }
{ written by                                                                }
{   TMS Software                                                            }
{   copyright © 2006 - 2010                                                 }
{   Email : info@tmssoftware.com                                            }
{   Web : http://www.tmssoftware.com                                        }
{                                                                           }
{ The source code is given as is. The author is not responsible             }
{ for any possible damage done due to the use of this code.                 }
{ The component can be freely used in any application. The complete         }
{ source code remains property of the author and may not be distributed,    }
{ published, given or sold in any form as such. No parts of the source      }
{ code can be included in any other component or application without        }
{ written authorization of the author.                                      }
{***************************************************************************}

unit AdvGDIPicture;

{$I TMSDEFS.INC}

interface

uses
  Windows, Messages, Classes, Graphics, Controls , SysUtils, AdvGDIP, GDIPicture,
  ComObj, ActiveX;

{$R AdvGDIPicture.res}  

const
  MAJ_VER = 1; // Major version nr.
  MIN_VER = 0; // Minor version nr.
  REL_VER = 2; // Release nr.
  BLD_VER = 0; // Build nr.

  // version history
  // v1.0.0.0 : first release
  // v1.0.1.0 : New: Added property PopupMenu
  //          : Fixed: issue with Proportional=true
  // v1.0.1.1 : Fixed: issue with centering
  // v1.0.2.0 : New : changes for allow use of DB-aware version

type
  TAdvGDIPPicture = class(TGraphicControl)
  private
    { Private declarations }
    FAutoSize: Boolean;
    FIPicture: TGDIPPicture;
    FDoubleBuffered: Boolean;
    FBackgroundColor: TColor;
    FRefresh: Boolean;
    FCenter: Boolean;
    FStretch: Boolean;
    FProportional: Boolean;
    procedure SetProportional(const Value: Boolean);
    procedure SetStretch(const Value: Boolean);
    procedure SetCenter(const Value: Boolean);
    procedure SetAutoSizeP(const Value: Boolean);
    procedure SeTGDIPPicture(const Value: TGDIPPicture);
    procedure PictureChanged(Sender:TObject);
    procedure PictureCleared(Sender:TObject);
    procedure SetBackgroundColor(const Value: TColor);
    procedure SetDoubleBuffered(const Value: Boolean);
    function GetVersion: string;
    procedure SetVersion(const Value: string);
    function GetVersionNr: Integer;
  protected
    { Protected declarations }
    procedure Paint; override;
    procedure PictureChange; virtual;
  public
    { Public declarations }
    constructor Create(aOwner:TComponent); override;
    destructor Destroy; override;
    procedure Loaded; override;
    property DoubleBuffered: Boolean read FDoubleBuffered write SetDoubleBuffered;
    property BackgroundColor: TColor read FBackgroundColor write SetBackgroundColor;
  published
    { Published declarations }
    property AutoSize: Boolean read FAutoSize write SetAutoSizeP default False;
    property Center: Boolean read FCenter write SetCenter default False;
    property Proportional: Boolean read FProportional write SetProportional default False;
    property Stretch: Boolean read FStretch write SetStretch default False;
    property Picture:TGDIPPicture read FIPicture write SeTGDIPPicture;
    { inherited published properties}
    property Align;
    {$IFDEF DELPHI4_LVL}
    property Anchors;
    property Constraints;
    property DragKind;
    {$ENDIF}
    property DragCursor;
    property DragMode;
    property Enabled;
    property Hint;
    property ParentShowHint;
    property PopupMenu;
    property ShowHint;
    property Visible;
    property OnClick;
    {$IFDEF DELPHI5_LVL}
    property OnContextPopup;
    {$ENDIF}
    property OnDblClick;
    property OnDragDrop;
    property OnDragOver;
    {$IFDEF DELPHI4_LVL}
    property OnEndDock;
    property OnStartDock;
    {$ENDIF}
    property OnEndDrag;
    property OnMouseDown;
    property OnMouseUp;
    property OnMouseMove;
    property OnStartDrag;
    property Version: string read GetVersion write SetVersion;
  end;

implementation

{ TAdvGDIPPicture }

constructor TAdvGDIPPicture.Create(aOwner: TComponent);
begin
  inherited;
  FIPicture := TGDIPPicture.Create;
  FIPicture.OnChange := PictureChanged;
  FIPicture.OnClear := PictureCleared;
  Width := 100;
  Height := 100;
end;

destructor TAdvGDIPPicture.Destroy;
begin
  FIPicture.Free;
  FIPicture := nil;
  inherited;
end;

procedure TAdvGDIPPicture.Loaded;
begin
  inherited;
end;

procedure TAdvGDIPPicture.Paint;
var
  w,h,x,y: integer;
  r: TRect;
begin
  inherited;

  if Stretch then
  begin
    if Proportional then
    begin
      FIPicture.GetImageSizes;
      w := FIPicture.Width;
      h := FIPicture.Height;

      if (w >= h) and (w > 0) then
      begin
        h := round(Width / w * h);
        w := Width;
      end
      else
      if (h >= w) and (h > 0) then
      begin
        w := round(Height / h * w);
        h := Height;
      end;

      x := 0;
      y := 0;
      
      if Center then
      begin
        if (w < Width) then
          x := (Width - w) div 2;

        if (h < Height) then
          y := (Height - h) div 2;
      end;

      r := Rect(x,y,w+x,h+y);
      FIPicture.Draw(Canvas, r);
    end
    else
    begin
      FIPicture.Draw(Canvas, ClientRect);
    end;
  end
  else
  begin
    if Center then
    begin
      FIPicture.GetImageSizes;
      w := FIPicture.Width;
      h := FIPicture.Height;

      x := 0;
      y := 0;

      if (w < Width) then
        x := (Width - w) div 2;

      if (h < Height) then
        y := (Height - h) div 2;

      R := Rect(x,y,x + w,y + h);

      FIPicture.Draw(Canvas, r);
    end
    else
    begin
      FIPicture.GetImageSizes;
      w := FIPicture.Width;
      h := FIPicture.Height;

      R := Rect(0,0,w,h);

      FIPicture.Draw(Canvas, r);
    end;
  end;

  if (csDesigning in ComponentState) then
  begin
    Canvas.Brush.Style := bsClear;
    Canvas.Pen.Style := psDashDot;
    Canvas.Pen.Width := 1;
    Canvas.Pen.Color := clBlack;
    Canvas.Rectangle(ClientRect);
  end;
end;

procedure TAdvGDIPPicture.PictureChange;
begin

end;

procedure TAdvGDIPPicture.PictureChanged(sender: TObject);
begin
  if FAutoSize and not FIPicture.Empty then
    SetAutoSizeP(FAutoSize);

  PictureChange;  
end;

procedure TAdvGDIPPicture.SetAutoSizeP(const Value: Boolean);
begin
  FAutoSize := Value;
  if FAutoSize and not FIPicture.Empty then
  begin
    if FIPicture.GetImageSizes then
    begin
      Self.Width := FIPicture.Width;
      Self.Height := FIPicture.Height;
    end;
  end;
end;

procedure TAdvGDIPPicture.SetGDIPPicture(const Value: TGDIPPicture);
begin
  FIPicture.Assign(Value);
  Invalidate;
end;

procedure TAdvGDIPPicture.SetBackgroundColor(const Value: TColor);
begin
  FBackgroundColor := Value;
  FIPicture.BackgroundColor := Value;
end;

procedure TAdvGDIPPicture.SetCenter(const Value: Boolean);
begin
  FCenter := Value;
  Invalidate;
end;

procedure TAdvGDIPPicture.SetDoubleBuffered(const Value: Boolean);
begin
  FDoubleBuffered := Value;
  FIPicture.DoubleBuffered := Value;
end;

procedure TAdvGDIPPicture.PictureCleared(Sender: TObject);
begin
  FRefresh := True;
  Repaint;
  FRefresh := False;
end;

function TAdvGDIPPicture.GetVersion: string;
var
  vn: Integer;
begin
  vn := GetVersionNr;
  Result := IntToStr(Hi(Hiword(vn)))+'.'+IntToStr(Lo(Hiword(vn)))+'.'+IntToStr(Hi(Loword(vn)))+'.'+IntToStr(Lo(Loword(vn)));
end;

function TAdvGDIPPicture.GetVersionNr: Integer;
begin
  Result := MakeLong(MakeWord(BLD_VER,REL_VER),MakeWord(MIN_VER,MAJ_VER));
end;

procedure TAdvGDIPPicture.SetProportional(const Value: Boolean);
begin
  FProportional := Value;
  Invalidate;
end;

procedure TAdvGDIPPicture.SetStretch(const Value: Boolean);
begin
  FStretch := Value;
  Invalidate;
end;

procedure TAdvGDIPPicture.SetVersion(const Value: string);
begin

end;

{$IFDEF FREEWARE}
{$I TRIAL.INC}
{$ENDIF}

end.
