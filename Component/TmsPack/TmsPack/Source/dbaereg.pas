{*************************************************************************}
{ TDBADVEDIT component                                                    }
{ for Delphi & C++Builder                                                 }
{ version 2.6                                                             }
{                                                                         }
{ written by                                                              }
{   TMS Software                                                          }
{   Copyright © 1996-2003                                                 }
{   Email : info@tmssoftware.com                                          }
{   Web : http://www.tmssoftware.com                                      }
{*************************************************************************}

unit dbaereg;
{$I TMSDEFS.INC}
interface

uses
  DBAdvEd, Classes;

{$IFDEF TMSDOTNET}
{$R TDBAdvEdit.bmp}
{$R TDBAdvMaskEdit.bmp}
{$ENDIF}

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('TMS Edits', [TDBAdvEdit, TDBAdvMaskEdit]);
end;



end.

