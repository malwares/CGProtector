{********************************************************************}
{ TLOOKUP components : TLUEdit & TLUCombo                            }
{ for Delphi 3.0,4.0,5.0,6.0 & C++Builder 3.0,4.0,5.0                }
{ version 2.2                                                        }
{                                                                    }
{ written by                                                         }
{   TMS Software                                                     }
{   Copyright © 1996-2001                                            }
{   Email : info@tmssoftware.com                                     }
{   Web : http://www.tmssoftware.com                                 }
{********************************************************************}
unit lureg;
{$I TMSDEFS.INC}
interface

uses
  LuCombo, Classes;

{$IFDEF TMSDOTNET}
{$R TLUCombo.bmp}
{$R TLUEdit.bmp}
{$ENDIF}

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('TMS Edits', [TLUCombo,TLUEdit]);
end;


end.

