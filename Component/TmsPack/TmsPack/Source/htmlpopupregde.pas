{********************************************************************}
{ THTMLPopup component                                               }
{ for Delphi & C++Builder                                            }
{ version 1.0                                                        }
{                                                                    }
{ written by TMS Software                                            }
{            copyright © 2001 - 2004                                 }
{            Email : info@tmssoftware.com                            }
{            Web : http://www.tmssoftware.com                        }
{********************************************************************}

unit htmlpopupregde;

interface
{$I TMSDEFS.INC}
uses
  Classes, HTMLPopup, HTMLDE,
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
  {$IFNDEF TMSDOTNET}
  RegisterPropertyEditor(TypeInfo(TStringList), THTMLPopup, 'Text', THTMLTextProperty);
  {$ENDIF}
  {$IFDEF TMSDOTNET}
  RegisterPropertyEditor(TypeInfo(TStrings), THTMLPopup, 'Text', THTMLTextProperty);
  {$ENDIF}
end;



end.

