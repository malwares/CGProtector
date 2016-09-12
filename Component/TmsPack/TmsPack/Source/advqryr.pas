{********************************************************************}
{ TADVEDIT based Query dialog component                              }
{ for Delphi 3.0,4.0,5.0,6.0 & C++Builder 3.0,4.0,5.0                }
{ version 1.0 - rel. Februari, 2001                                  }
{                                                                    }
{ Written by                                                         }
{   TMS Software                                                     }
{   Copyright © 2001                                                 }
{   Email : info@tmssoftware.com                                     }
{   Web : http://www.tmssoftware.com                                 }
{********************************************************************}

unit advqryr;

interface
{$I TMSDEFS.INC}

uses
  Classes, AdvQueryDialog;

{$IFDEF TMSDOTNET}
{$R TAdvQueryDialog.bmp}
{$ENDIF}

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('TMS Edits', [TAdvQueryDialog]);
end;


end.
