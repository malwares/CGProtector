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

unit asgcregde;

interface

{$I TMSDEFS.INC}

uses
  AdvGrid, AdvCGrid, Classes, ACGDE,
{$IFDEF DELPHI6_LVL}
  {$IFNDEF TMSDOTNET}
  DesignIntf
  {$ENDIF}
  {$IFDEF TMSDOTNET}
  Borland.Vcl.Design.DesignIntf
  {$ENDIF}

{$ELSE}
  DsgnIntf
{$ENDIF}
  ;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponentEditor(TAdvColumnGrid,TAdvColumnGridEditor);
end;

end.
