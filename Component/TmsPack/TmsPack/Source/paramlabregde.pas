{********************************************************************}
{ TPARAMLABEL component                                              }
{ for Delphi & C++Builder                                            }
{ version 1.1                                                        }
{                                                                    }
{ written by TMS Software                                            }
{           copyright © 2000 - 2004                                  }
{           Email : info@tmssoftware.com                             }
{           Web : http://www.tmssoftware.com                         }
{********************************************************************}

unit paramlabregde;

interface

{$I TMSDEFS.INC}

uses
  ParamLabel, Classes,
{$IFNDEF NOEDITOR}
  paramsde,
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
{$ENDIF}
  ;


procedure Register;

implementation

procedure Register;
begin
  RegisterPropertyEditor(TypeInfo(TStringList), TParamLabel, 'HTMLText', TParamStringProperty);
  RegisterComponentEditor(TParamLabel, TParamDefaultEditor);
end;



end.

