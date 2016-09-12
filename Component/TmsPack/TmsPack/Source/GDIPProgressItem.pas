{*************************************************************************}
{ TProgressItem Base Class                                                }
{ for Delphi & C++Builder                                                 }
{                                                                         }
{ written by TMS Software                                                 }
{           copyright ©  2010                                             }
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

unit GDIPProgressItem;

interface

uses
  Classes, GDIPCustomItem, AdvGDIP, GDIPFill;

type
  TProgressItem = class(TCustomItem)
  private
    FAppearance: TGDIPProgress;
    FMax: integer;
    FMin: integer;
    FPosition: integer;
    FValueFormat: string;
    FShowValue: boolean;
    FMargin: integer;
    procedure SetAppearance(const Value: TGDIPProgress);
    procedure SetMax(const Value: integer);
    procedure SetMin(const Value: integer);
    procedure SetPosition(const Value: integer);
    procedure SetShowValue(const Value: boolean);
    procedure SetValueFormat(const Value: string);
    procedure SetMargin(const Value: integer);
  protected
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure Assign(Source: TPersistent); override;
    function CreateNewItem(AOwner: TComponent): TCustomItem; override;
    function GetClassType: TComponentClass; override;
    class function CustomClassName: String; override;
    procedure DrawInRect(g: TGPGraphics; ItemAppearance: TItemAppearance; R: TGPRectF); override;
  published
    property Appearance: TGDIPProgress read FAppearance write SetAppearance;
    property Min: integer read FMin write SetMin default 0;
    property Max: integer read FMax write SetMax default 100;
    property Margin: integer read FMargin write SetMargin default 2;
    property Position: integer read FPosition write SetPosition default 0;
    property ShowValue: boolean read FShowValue write SetShowValue default true;
    property ValueFormat: string read FValueFormat write SetValueFormat;
  end;


procedure Register;

implementation

uses
  SysUtils, Graphics, Windows;

{ TProgressItem }

procedure TProgressItem.Assign(Source: TPersistent);
begin
  inherited;
  FAppearance.Assign((Source as TProgressItem).Appearance);

end;

constructor TProgressItem.Create(AOwner: TComponent);
begin
  inherited;
  FShowValue := true;
  FValueFormat := '%d%%';
  FMargin := 2;
  Height := 40;

  FAppearance := TGDIPProgress.Create;

  with FAppearance do
  begin
    BackGroundFill.Color := $00FFD2AF;
    BackGroundFill.ColorTo := $00FFD2AF;
    BackGroundFill.BorderColor := $00C0C0C0;

    ProgressFill.Color := $00EBFDFF;
    ProgressFill.ColorTo := $00ABEBFF;
    ProgressFill.ColorMirror := $0069D6FF;
    ProgressFill.ColorMirrorTo := $0096E4FF;
    ProgressFill.BorderColor := clSilver;

    ProgressFill.GradientMirrorType := gtVertical;
  end;
end;

function TProgressItem.CreateNewItem(AOwner: TComponent): TCustomItem;
begin
  Result := TProgressItem.Create(AOwner);
end;

class function TProgressItem.CustomClassName: String;
begin
  Result := 'Progressbar item';
end;

destructor TProgressItem.Destroy;
begin
  FAppearance.Free;
  inherited;
end;

procedure TProgressItem.DrawInRect(g: TGPGraphics;
  ItemAppearance: TItemAppearance; R: TGPRectF);
var
  f: TGDIPFill;
  dr,tr: TRect;
  valstr: string;
  h,tw,th: integer;
begin
  if Visible then
  begin
    DoItemStartDraw(Self, g, Self, r);
    DoInternalItemStartDraw(Self, g, Self, r);

    f := GetFill(ItemAppearance);

    if Assigned(f) then
      f.Fill(g, r);

    if ItemAppearance.Focus and (ItemAppearance.FocusedItem = Index) then
      DrawFocus(g, r, ItemAppearance);

    dr := Rect(Trunc(r.X), Trunc(r.Y), Trunc(R.X + R.Width), Trunc(R.Y + R.Height));
    InflateRect(dr, -Margin, - Margin);
    h := dr.Bottom - dr.Top;

    if ShowValue then
      h := h div 2;

    tr := Rect(dr.Left, dr.Top, dr.Right, dr.Top + h);

    // draw progressbar
    FAppearance.Draw(g, tr ,FMin,FMax,FPosition);

    if ShowValue then
    begin
      tr := Rect(dr.Left, dr.Top + h, dr.Right, dr.Top + 2*h);
      valstr := Format(FValueFormat, [FPosition]);
      // measure text value size
      th := g.DrawText(valstr, length(valstr), tr, GetFont(ItemAppearance), DT_CALCRECT);
      tw := tr.Right - tr.Left;
      // center text
      tr := Rect(dr.Left + (dr.Right - dr.Left - tw) div 2, dr.Top + (dr.Bottom - dr.Top - th + h) div 2, dr.Right, dr.Bottom);
      // draw text
      g.DrawText(valstr, length(valstr), tr, GetFont(ItemAppearance), 0);
    end;

    DoItemEndDraw(Self, g, Self, r);
    DoInternalItemEndDraw(Self, g, Self, r);
  end;
end;

function TProgressItem.GetClassType: TComponentClass;
begin
  Result := TProgressItem;
end;

procedure TProgressItem.SetAppearance(const Value: TGDIPProgress);
begin
  FAppearance.Assign(Value);
end;


procedure TProgressItem.SetMargin(const Value: integer);
begin
  if (FMargin <> Value) then
  begin
    FMargin := Value;
    Changed;
  end;
end;

procedure TProgressItem.SetMax(const Value: integer);
begin
  if (FMax <> Value) then
  begin
    FMax := Value;
    Changed;
  end;
end;

procedure TProgressItem.SetMin(const Value: integer);
begin
  if (FMin <> Value) then
  begin
    FMin := Value;
    Changed;
  end;
end;

procedure TProgressItem.SetPosition(const Value: integer);
begin
  if (FPosition <> Value) then
  begin
    FPosition := Value;
    Changed;
  end;
end;

procedure TProgressItem.SetShowValue(const Value: boolean);
begin
  if FShowValue <> Value then
  begin
    FShowValue := Value;
    Changed;
  end;
end;

procedure TProgressItem.SetValueFormat(const Value: string);
begin
  if (FValueFormat <> Value) then
  begin
    FValueFormat := Value;
    Changed;
  end;
end;

procedure Register;
begin
  RegisterPolyItem(TProgressItem);
end;

end.
