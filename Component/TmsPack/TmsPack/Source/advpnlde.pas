{*************************************************************************}
{ TAdvPanel, TAdvPanelGroup, TAdvPanelStyler component                    }
{ for Delphi & C++Builder                                                 }
{ version 1.5                                                             }
{                                                                         }
{ written                                                                 }
{   TMS Software                                                          }
{   copyright © 2000-2003                                                 }
{ Email : info@tmssoftware.com                                            }
{ Web : http://www.tmssoftware.com                                        }
{                                                                         }
{ The source code is given as is. The author is not responsible           }
{ for any possible damage done due to the use of this code.               }
{ The component can be freely used in any application. The source         }
{ code remains property of the writer and may not be distributed          }
{ freely as such.                                                         }
{*************************************************************************}

{$I TMSDEFS.INC}
unit advpnlde;

interface

uses
  {$IFDEF DELPHI6_LVL}
  {$IFNDEF TMSDOTNET}
  Classes, DesignIntf, DesignEditors;
  {$ENDIF}
  {$IFDEF TMSDOTNET}
  Classes, Borland.Vcl.Design.DesignIntf, Borland.Vcl.Design.DesignEditors;
  {$ENDIF}
  {$ELSE}
  {$IFNDEF TMSDOTNET}
  DsgnIntf;
  {$ENDIF}
  {$IFDEF TMSDOTNET}
  Borland.Vcl.Design.DsgnIntf;
  {$ENDIF}
  {$ENDIF}

{$I TMSDEFS.INC}

type
  TAdvPanelEditor = class(TDefaultEditor)
  protected
  {$IFNDEF DELPHI6_LVL}
    procedure EditProperty(PropertyEditor: TPropertyEditor;
      var Continue, FreeEditor: Boolean); override;
  {$ELSE}
    procedure EditProperty(const PropertyEditor: IProperty; var Continue: Boolean); override;
  {$ENDIF}
  public
  end;


implementation

uses
  SysUtils;

{$IFDEF DELPHI6_LVL}
procedure TAdvPanelEditor.EditProperty(const PropertyEditor: IProperty; var Continue: Boolean);
{$ELSE}
procedure TAdvPanelEditor.EditProperty(PropertyEditor: TPropertyEditor;
  var Continue, FreeEditor: Boolean);
{$ENDIF}
var
  PropName: string;
begin
  PropName := PropertyEditor.GetName;
  if (CompareText(PropName, 'TEXT') = 0) then
  begin
    PropertyEditor.Edit;
    Continue := False;
  end;
end;


end.
