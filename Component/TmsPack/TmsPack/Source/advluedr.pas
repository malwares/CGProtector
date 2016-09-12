{********************************************************************}
{ TADVLUEDIT component                                               }
{ for Delphi & C++Builder                                            }
{ version 1.4                                                        }
{                                                                    }
{ written by                                                         }
{   TMS Software                                                     }
{   Copyright © 2000 - 2005                                          }
{   Email : info@tmssoftware.com                                     }
{   Web : http://www.tmssoftware.com                                 }
{********************************************************************}

unit advluedr;

interface

{$I TMSDEFS.INC}

uses
  AdvLuEd, Classes;

procedure Register;

{$IFDEF TMSDOTNET}
{$R TAdvLUEdit.bmp}
{$ENDIF}

implementation

procedure Register;
begin
  RegisterComponents('TMS Edits', [TAdvLUEdit]);
end;


end.
 