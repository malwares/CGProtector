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

unit advpnlregde;

interface

{$I TMSDEFS.INC}

uses
  AdvPanel, Classes, HTMLSDE, AdvPnlDe,
{$IFNDEF TMSDOTNET}
  AdvImage, AdvImgDE,
{$ENDIF}
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
  {$IFNDEF TMSDOTNET}
  RegisterPropertyEditor(TypeInfo(TAdvImage), TAdvPanel, 'Background', TAdvImageProperty);
  {$ENDIF}
  RegisterPropertyEditor(TypeInfo(String), TAdvPanel, 'Text', THTMLStringProperty);
  RegisterPropertyEditor(TypeInfo(String), TPanelCaption, 'Text', THTMLStringProperty);
  RegisterComponentEditor(TAdvPanel,TAdvPanelEditor);
end;

end.
