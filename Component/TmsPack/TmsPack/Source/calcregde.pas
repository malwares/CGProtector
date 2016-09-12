{********************************************************************}
{ TCALCOMP component                                                 }
{ for Delphi & C++Builder                                            }
{ version 2.1                                                        }
{                                                                    }
{ Written by TMS Software                                            }
{   Copyright © 1998-2004                                            }
{   Email : info@tmssoftware.com                                     }
{   Website : http://www.tmssoftware.com                             }
{********************************************************************}
unit calcregde;

interface
{$I TMSDEFS.INC}
uses
  Calcomp, Classes,
{$IFDEF DELPHI6_LVL}
  {$IFNDEF TMSDOTNET}
  DesignIntf, DesignEditors
  {$ENDIF}
  {$IFDEF TMSDOTNET}
  Borland.vcl.Design.DesignIntf, Borland.vcl.Design.DesignEditors
  {$ENDIF}

{$ELSE}
  DsgnIntf
{$ENDIF}
  ;

type

  TCalcompEditor = class(TComponentEditor)
  public
    function GetVerb(Index: Integer):string; override;
    function GetVerbCount: Integer; override;
    procedure ExecuteVerb(Index: Integer); override;
  end;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponentEditor(TCalcomp,TCalcompEditor);
end;

procedure TCalcompEditor.ExecuteVerb(Index: Integer);
begin
  (Component as TCalComp).Execute;
end;

function TCalcompEditor.GetVerb(Index: Integer): string;
begin
  Result := '&Test';
end;

function TCalcompEditor.GetVerbCount: Integer;
begin
  Result := 1;
end;

end.

