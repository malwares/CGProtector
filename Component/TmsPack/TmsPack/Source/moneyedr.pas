{********************************************************************}
{ TMoneyEdit component                                               }
{ for Delphi 3.0,4.0,5.0,6.0 & C++Builder 3.0,4.0,5.0                }
{ version 1.1                                                        }
{                                                                    }
{ Written by :                                                       }
{   TMS Software                                                     }
{   Copyright © 1999-2001                                            }
{   Email : info@tmssoftware.com                                     }
{   Website : http://www.tmssoftware.com                             }
{********************************************************************}
unit MoneyEdr;

{$I TMSDEFS.INC}
interface

uses
  MoneyEdit,Classes;

{$IFDEF TMSDOTNET}
{$R TMoneyEdit.bmp}
{$ENDIF}

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('TMS Edits', [TMoneyEdit]);
end;



end.


