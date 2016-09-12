{**********************************************************************}
{ TADVCOLUMNGRID component                                             }
{ for Delphi & C++Builder                                              }
{ version 3.0.x.x                                                      }
{                                                                      }
{ written by TMS Software                                              }
{            copyright © 1996-2006                                     }
{            Email : info@tmssoftware.com                              }
{            Web : http://www.tmssoftware.com                          }
{**********************************************************************}
{$I TMSDEFS.INC}

unit asgcreg;

{$IFDEF TMSDOTNET}
{$R TAdvColumnGrid.bmp}
{$ENDIF}

interface

uses
  Classes, AdvCGrid;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('TMS Grids', [TAdvColumnGrid]);
end;

end.

