{********************************************************************}
{ TADVEDITBTN and TUnitAdvEditBtn component                          }
{ for Delphi & C++Builder                                            }
{ version 1.3                                                        }
{                                                                    }
{ written by                                                         }
{   TMS Software                                                     }
{   Copyright © 2000 - 2002                                          }
{   Email : info@tmssoftware.com                                     }
{   Web : http://www.tmssoftware.com                                 }
{********************************************************************}

unit advedbr;

interface
{$I TMSDEFS.INC}

uses
  AdvEdBtn, AdvFileNameEdit, Classes
  {$IFNDEF TMSDOTNET}
  , AdvDirectoryEdit
  {$ENDIF}
  ;

procedure Register;

{$IFDEF TMSDOTNET}
{$R TAdvEditBtn.bmp}
{$R TUnitAdvEditBtn.bmp}
{$R TAdvFileNameEdit.bmp}
{$ENDIF}

implementation

procedure Register;
begin
  RegisterComponents('TMS Edits', [TAdvEditBtn,TUnitAdvEditBtn]);
  RegisterComponents('TMS Edits', [TAdvFileNameEdit]);
  {$IFNDEF TMSDOTNET}
  RegisterComponents('TMS Edits', [TAdvDirectoryEdit]);
  {$ENDIF}
end;



end.

