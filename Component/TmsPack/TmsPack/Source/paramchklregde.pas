{********************************************************************}
{ TPARAMCHECKLIST component                                          }
{ for Delphi & C++Builder                                            }
{ version 1.2                                                        }
{                                                                    }
{ written by TMS Software                                            }
{            copyright © 2000 - 2004                                 }
{            Email : info@tmssoftware.com                            }
{            Web : http://www.tmssoftware.com                        }
{********************************************************************}

unit paramchklregde;

{$I TMSDEFS.INC}

interface

uses
  paramchklist,classes,paramsde,
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
  RegisterPropertyEditor(TypeInfo(TStrings), TParamCheckList, 'Items', TParamStringListProperty);
  RegisterComponentEditor(TParamCheckList, TParamListDefaultEditor);
end;

end.

