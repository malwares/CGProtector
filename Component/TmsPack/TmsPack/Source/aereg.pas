{***********************************************************************}
{ TADVEDIT component                                                    }
{ for Delphi & C++Builder                                               }
{ version 2.7                                                           }
{                                                                       }
{ written by                                                            }
{   TMS Software                                                        }
{   Copyright © 1996-2007                                               }
{   Email : info@tmssoftware.com                                        }
{   Web : http://www.tmssoftware.com                                    }
{***********************************************************************}
unit aereg;

interface
{$I TMSDEFS.INC}

uses
  AdvEdit, Classes;

{$IFDEF TMSDOTNET}
{$R TAdvEdit.bmp}
{$R TAdvMaskEdit.bmp}
{$ENDIF}

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('TMS Edits', [TAdvEdit,TAdvMaskEdit]);
end;



end.

