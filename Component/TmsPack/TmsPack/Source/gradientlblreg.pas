{*********************************************************************}
{ TGradientLabel component                                            }
{ for Delphi & C++Builder                                             }
{ version 1.0                                                         }
{                                                                     }
{ written by                                                          }
{  TMS Software                                                       }
{  copyright © 2002                                                   }
{  Email : info@tmssoftware.com                                       }
{  Web : http://www.tmssoftware.com                                   }
{*********************************************************************}

unit GradientLblReg;

{$I TMSDEFS.INC}
interface

uses
  Classes, GradientLabel;

{$IFDEF TMSDOTNET}
{$R TGradientLabel.bmp}
{$ENDIF}

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('TMS', [TGradientLabel]);
end;



end.

