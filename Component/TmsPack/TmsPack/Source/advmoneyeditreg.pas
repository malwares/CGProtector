{********************************************************************}
{ TAdvMoneyEdit component                                            }
{ for Delphi & C++Builder                                            }
{ version 1.0                                                        }
{                                                                    }
{ Written by :                                                       }
{   TMS Software                                                     }
{   Copyright © 2007                                                 }
{   Email : info@tmssoftware.com                                     }
{   Website : http://www.tmssoftware.com                             }
{********************************************************************}
unit AdvMoneyEditReg;

interface

{$I TMSDEFS.INC}

uses
  Classes, AdvMoneyEdit;

{$IFDEF TMSDOTNET}
{$R TAdvMoneyEdit.bmp}
{$ENDIF}

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('TMS Edits', [TAdvMoneyEdit]);
end;

end.
