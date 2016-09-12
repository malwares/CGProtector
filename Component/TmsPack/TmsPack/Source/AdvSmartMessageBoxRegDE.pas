{********************************************************************}
{ AdvSmartMessageBoxRegDE components                                 }
{ for Delphi & C++Builder                                            }
{ version 1.0                                                        }
{                                                                    }
{ written by TMS Software                                            }
{            copyright © 2007                                        }
{            Email : info@tmssoftware.com                            }
{            Web : http://www.tmssoftware.com                        }
{********************************************************************}

unit AdvSmartMessageBoxRegDE;

interface
{$I TMSDEFS.INC}
uses
  Classes, AdvSmartMessageBox, htmlde,
{$IFDEF DELPHI6_LVL}
  {$IFNDEF TMSDOTNET}
  DesignIntf, DesignEditors
  {$ENDIF}
  {$IFDEF TMSDOTNET}
  Borland.vcl.design.DesignIntf, Borland.vcl.design.DesignEditors
  {$ENDIF}

{$ELSE}
  DsgnIntf
{$ENDIF}
  ;


procedure Register;

implementation

procedure Register;
begin
  RegisterPropertyEditor(TypeInfo(String), TDefaultSmartMessage, 'Text', THTMLStringProperty);
  RegisterPropertyEditor(TypeInfo(String), TAdvSmartMessage, 'Text', THTMLStringProperty);
end;



end.

