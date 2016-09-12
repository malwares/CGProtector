{********************************************************************}
{ THTMLButtons components                                            }
{ for Delphi & C++Builder                                            }
{ version 1.2                                                        }
{                                                                    }
{ written by TMS Software                                            }
{            copyright © 1999 - 2004                                 }
{            Email : info@tmssoftware.com                            }
{            Web : http://www.tmssoftware.com                        }
{********************************************************************}

unit htmburegde;

interface
{$I TMSDEFS.INC}
uses
  Classes, htmlbtns, htmlde,
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
  RegisterPropertyEditor(TypeInfo(String), THTMLCheckbox, 'Caption', THTMLStringProperty);
  RegisterPropertyEditor(TypeInfo(String), THTMLRadioButton, 'Caption', THTMLStringProperty);
  RegisterPropertyEditor(TypeInfo(String), THTMLButton, 'Caption', THTMLStringProperty);
end;



end.

