{**************************************************************************}
{ THTMLCredit component                                                    }
{ for Delphi & C++Builder                                                  }
{ version 1.0                                                              }
{                                                                          }
{ written by TMS Software                                                  }
{            copyright © 2003 - 2005                                       }
{            Email : info@tmssoftware.com                                  }
{            Web : http://www.tmssoftware.com                              }
{**************************************************************************}

unit HTMLCreditRegDE;

interface
{$I TMSDEFS.INC}
uses
  Classes, HTMLCredit, HTMLDE,
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
  RegisterPropertyEditor(TypeInfo(TStrings), THTMLCredit, 'HTMLText', THTMLTextProperty);
  RegisterComponentEditor(THTMLCredit, THTMLDefaultEditor);  
end;

end.

