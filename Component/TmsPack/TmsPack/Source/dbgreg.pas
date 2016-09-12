{*******************************************************************}
{ TDBADVSTRINGGRID component                                        }
{ for Delphi & C++Builder                                           }
{ version 1.7                                                       }
{                                                                   }
{ written by                                                        }
{    TMS Software                                                   }
{    copyright © 1999-2004                                          }
{    Email : info@tmssoftware.com                                   }
{    Web : http://www.tmssoftware.com                               }
{                                                                   }
{*******************************************************************}

unit dbgreg;

interface

{$I TMSDEFS.INC}

uses
  Classes, DBAdvGrd;

{$IFDEF TMSDOTNET}
{$R TDBAdvStringGrid.bmp}
{$ENDIF}

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('TMS Grids', [TDBAdvStringGrid]);
end;


end.
