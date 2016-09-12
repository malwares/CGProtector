{********************************************************************}
{ TPARAMTREEVIEW component                                           }
{ for Delphi & C++Builder                                            }
{ version 1.0                                                        }
{                                                                    }
{ Written by                                                         }
{   TMS Software                                                     }
{   Copyright © 2000-2004                                            }
{   Email : info@tmssoftware.com                                     }
{   Web : http://www.tmssoftware.com                                 }
{********************************************************************}

unit paramtreeviewregde;

{$I TMSDEFS.INC}

interface

uses
  ParamTreeview, Classes, paramsde, ComCtrls,
{$IFDEF DELPHI6_LVL}
  {$IFNDEF TMSDOTNET}
  DesignIntf, DesignEditors
  {$ENDIF}
  {$IFDEF TMSDOTNET}
  Borland.Vcl.Design.DesignIntf, Borland.Vcl.Design.DesignEditors
  {$ENDIF}
{$ELSE}
  {$IFNDEF TMSDOTNET}
  DsgnIntf
  {$ENDIF}
  {$IFDEF TMSDOTNET}
  Borland.Vcl.Design.DsgnIntf
  {$ENDIF}

{$ENDIF}
  ;

procedure Register;

implementation

procedure Register;
begin
  RegisterPropertyEditor(TypeInfo(TTreeNodes), TParamTreeView, 'Items', TParamNodesProperty);
  RegisterComponentEditor(TParamTreeView, TParamListDefaultEditor);
end;



end.

