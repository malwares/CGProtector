{********************************************************************}
{ TDBLUCOMBO component                                               }
{ for Delphi & C++Builder                                            }
{                                                                    }
{ written by                                                         }
{   TMS Software                                                     }
{   Copyright © 2000                                                 }
{   Email : info@tmssoftware.com                                     }
{   Web : http://www.tmssoftware.com                                 }
{********************************************************************}

unit dblucmbr;

interface

{$I TMSDEFS.INC}
uses
  DBLuComb, Classes;

{$IFDEF TMSDOTNET}
{$R TDBLUCombo.bmp}
{$R TDBLUEdit.bmp}
{$ENDIF}

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('TMS Edits', [TDBLUCombo,TDBLUEdit]);
end;




end.
