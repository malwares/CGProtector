{***********************************************************************}
{ TADVSPINEDIT component                                                }
{ for Delphi & C++Builder                                               }
{ version 1.3                                                           }
{                                                                       }
{ written by                                                            }
{   TMS Software                                                        }
{   Copyright © 1998-2005                                               }
{   Email : info@tmssoftware.com                                        }
{   Web : http://www.tmssoftware.com                                    }
{***********************************************************************}
unit asreg;

{$I TMSDEFS.INC}
interface

uses
  AdvSpin, Classes;

{$IFDEF TMSDOTNET}
{$R TAdvSpinEdit.bmp}
{$ENDIF}

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('TMS Edits', [TAdvSpinEdit]);
end;

end.

