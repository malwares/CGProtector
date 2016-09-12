{********************************************************************}
{ TDBADVLUEDIT component                                             }
{ for Delphi 5.0,6.0,7.0,2005 & C++Builder 5.0,6.0                   }
{ version 1.4                                                        }
{                                                                    }
{ written by                                                         }
{   TMS Software                                                     }
{   Copyright © 2000 - 2005                                          }
{   Email : info@tmssoftware.com                                     }
{   Web : http://www.tmssoftware.com                                 }
{********************************************************************}

unit DBAdvLer;

{$I TMSDEFS.INC}
interface

uses
  DBAdvle, Classes;

{$IFDEF TMSDOTNET}
{$R TDBAdvLUEdit.bmp}
{$ENDIF}

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('TMS Edits', [TDBAdvLUEdit]);
end;


end.

