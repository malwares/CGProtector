{*************************************************************************}
{ TCOLORCOMBO component                                                   }
{ version 1.0                                                             }
{ written by TMS Software                                                 }
{           copyright © 2001-2006                                         }
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

{$R colorcombo.res}

unit ColorCombo;
{$I TMSDEFS.INC}
interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, AsgCombo;

const
  MAJ_VER = 1; // Major version nr.
  MIN_VER = 0; // Minor version nr.
  REL_VER = 0; // Release nr.
  BLD_VER = 0; // Build nr.

type

   TAdvColorComboBox = class(TAsgCombobox)
   protected
     function GetVersionNr: Integer; override;
     procedure DrawItem(Index: Integer; Rect: TRect; State: TOwnerDrawState); override;
   public
     constructor Create(AOwner: TComponent); override;
     procedure Loaded; override;
   end;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('TMS', [TAdvColorComboBox]);
end;

constructor TAdvColorComboBox.Create(AOwner: TComponent);
begin
  inherited;
  Style := csOwnerDrawFixed;
end;

procedure TAdvColorCombobox.DrawItem(Index: Integer; Rect: TRect; State: TOwnerDrawState);
var
  BC : TColor;
  Nm : string;
begin
  {get selected color and text to display}
  case Index of
     0 : begin BC := clBlack;   Nm := 'Black';     end;  //ivlm
     1 : begin BC := clMaroon;  Nm := 'Maroon';    end;  //ivlm
     2 : begin BC := clGreen;   Nm := 'Green';     end;  //ivlm
     3 : begin BC := clOlive;   Nm := 'Olive';     end;  //ivlm
     4 : begin BC := clNavy;    Nm := 'Navy';      end;  //ivlm
     5 : begin BC := clPurple;  Nm := 'Purple';    end;  //ivlm
     6 : begin BC := clTeal;    Nm := 'Teal';      end;  //ivlm
     7 : begin BC := clGray;    Nm := 'Gray';      end;  //ivlm
     8 : begin BC := clSilver;  Nm := 'Silver';    end;  //ivlm
     9 : begin BC := clRed;     Nm := 'Red';       end;  //ivlm
    10 : begin BC := clLime;    Nm := 'Lime';      end;  //ivlm
    11 : begin BC := clYellow;  Nm := 'Yellow';    end;  //ivlm
    12 : begin BC := clBlue;    Nm := 'Blue';      end;  //ivlm
    13 : begin BC := clFuchsia; Nm := 'Fuchsia';   end;  //ivlm
    14 : begin BC := clAqua;    Nm := 'Aqua';      end;  //ivlm
    15 : begin BC := clWhite;   Nm := 'White';     end;  //ivlm
    else begin BC := clWhite;   Nm := '???';       end;
  end;
  if (State * [odSelected, odFocused] <> []) then begin
    Canvas.Font.Color := clHighLightText;
    Canvas.Brush.Color := clHighLight;
  end else begin
    Canvas.Font.Color := Font.Color;
    Canvas.Brush.Color := Color;
  end;
  Canvas.Pen.Color := Canvas.Brush.Color;
  Canvas.Rectangle(Rect.Left, Rect.Top, Rect.Right, Rect.Bottom);
  Inc(Rect.Left);
  {$IFNDEF TMSDOTNET}
  DrawText(Canvas.Handle,@Nm[1],Length(Nm),Rect,DT_LEFT or DT_VCENTER or DT_SINGLELINE);
  {$ENDIF}
  {$IFDEF TMSDOTNET}
  DrawText(Canvas.Handle,Nm,Length(Nm),Rect,DT_LEFT or DT_VCENTER or DT_SINGLELINE);
  {$ENDIF}
  Canvas.Pen.Color := Font.Color;
  Canvas.Brush.Color := BC;
  Canvas.Rectangle(Rect.Left + 50, Rect.Top + 1, Rect.Right -1, Rect.Bottom - 1);
  Canvas.Brush.Color := clWhite;
  Canvas.Pen.Color := clWhite;
end;

function TAdvColorComboBox.GetVersionNr: Integer;
begin
  Result := MakeLong(MakeWord(BLD_VER,REL_VER),MakeWord(MIN_VER,MAJ_VER));
end;


procedure TAdvColorComboBox.Loaded;
var
  i: integer;
begin
  inherited;
  Items.Clear;
  for I := 0 to 15 do
    Items.Add(inttostr(i));

end;

end.
