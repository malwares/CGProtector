{**************************************************************************}
{ THTMLStaticText component                                                }
{ for Delphi & C++Builder                                                  }
{ version 1.2                                                              }
{                                                                          }
{ written by TMS Software                                                  }
{            copyright © 2000 - 2004                                       }
{            Email : info@tmssoftware.com                                  }
{            Web : http://www.tmssoftware.com                              }
{**************************************************************************}

unit htmstregde;

interface
{$I TMSDEFS.INC}
uses
  Classes, HTMLText, HTMLDE,
{$IFDEF DELPHI6_LVL}
  {$IFNDEF TMSDOTNET}
  DesignIntf, DesignEditors
  {$ENDIF}
  {$IFDEF TMSDOTNET}
  Borland.Vcl.Design.DesignIntf, Borland.Vcl.Design.DesignEditors
  {$ENDIF}
{$ELSE}
  DsgnIntf
{$ENDIF}
  ;

procedure Register;

implementation

procedure Register;
begin
  RegisterPropertyEditor(TypeInfo(TStrings), THTMLStaticText, 'HTMLText', THTMLTextProperty);
  RegisterComponentEditor(THTMLStaticText, THTMLDefaultEditor);  
end;

end.

