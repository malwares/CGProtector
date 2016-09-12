{***************************************************************************}
{ TInspectorBar component                                                   }
{ for Delphi & C++Builder                                                   }
{ version 1.4                                                               }
{                                                                           }
{ written by TMS Software                                                   }
{            copyright © 2001 - 2005                                        }
{            Email : info@tmssoftware.com                                   }
{            Web : http://www.tmssoftware.com                               }
{                                                                           }
{***************************************************************************}
unit InspectorBarRegDE;

interface
{$I TMSDEFS.INC}
uses
  Classes, InspectorBar, InspDE, Controls,
{$IFDEF DELPHI6_LVL}
  {$IFNDEF TMSDOTNET}
  DesignIntf, DesignEditors, VCLEditors
  {$ENDIF}
  {$IFDEF TMSDOTNET}
  Borland.Vcl.Design.DesignIntf, Borland.Vcl.Design.DesignEditors
  {$ENDIF}
{$ELSE}
  DsgnIntf
{$ENDIF}
{$IFNDEF TMSDOTNET}
, InspImg
{$ENDIF}
  ;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponentEditor(TInspectorBar,TInspectorBarEditor);
  {$IFNDEF TMSDOTNET}
  RegisterPropertyEditor(TypeInfo(TInspImage), TInspectorPanel, 'Splitter', TInspImageProperty);
  RegisterPropertyEditor(TypeInfo(TInspImage), TInspectorItem, 'Background', TInspImageProperty);
  RegisterPropertyEditor(TypeInfo(TShortCut), TInspectorItem, 'Shortcut', TShortCutProperty);  
  {$ENDIF}
  RegisterPropertyEditor(TypeInfo(TWinControl), TInspectorPanel, 'Control', TInspControlProperty);


end;

end.
