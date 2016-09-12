{********************************************************************}
{ THTMDialog component                                               }
{ for Delphi & C++Builder                                            }
{                                                                    }
{  Written by                                                        }
{    TMS Software                                                    }
{    Copyright © 2001 - 2010                                         }
{    Email : info@tmssoftware.com                                    }
{    Web : http://www.tmssoftware.com                                }
{********************************************************************}

unit htmldlgregde;

interface
{$I TMSDEFS.INC}
uses
  Classes, HTMLDialog, HTMLDE,
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
  RegisterPropertyEditor(TypeInfo(TStringList), THTMLDialog, 'HTMLText', THTMLTextProperty);
end;

end.

