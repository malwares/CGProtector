{**************************************************************************}
{ THTMLabel component                                                      }
{ for Delphi 2.0,3.0,4.05.0,6.0 & C++Builder 1.0,3.0,4.0,5.0               }
{ version 1.5                                                              }
{                                                                          }
{ written by TMS Software                                                  }
{           copyright © 1999-2001                                          }
{           Email : info@tmssoftware.com                                   }
{           Web : http://www.tmssoftware.com                               }
{                                                                          }
{ The source code is given as is. The author is not responsible            }
{ for any possible damage done due to the use of this code.                }
{ The component can be freely used in any application. The complete        }
{ source code remains property of the author and may not be distributed,   }
{ published, given or sold in any form as such. No parts of the source     }
{ code can be included in any other component or application without       }
{ written authorization of the author.                                     }
{**************************************************************************}

unit htmlaregde;

interface

{$IFDEF VER90}
 {$DEFINE NOEDITOR}
{$ENDIF}

{$IFDEF VER93}
 {$DEFINE NOEDITOR}
{$ENDIF}

{$I TMSDEFS.INC}

uses
  Classes, HTMLabel,
{$IFNDEF NOEDITOR}
  HTMLDE,
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
{$ENDIF}
  ;

procedure Register;

implementation

procedure Register;
begin
  {$IFNDEF NOEDITOR}
  {$IFNDEF TMSDOTNET}
  RegisterPropertyEditor(TypeInfo(TStringList), THTMLabel, 'HTMLText', THTMLTextProperty);
  {$ENDIF}
  {$IFDEF TMSDOTNET}
  RegisterPropertyEditor(TypeInfo(TStrings), THTMLabel, 'HTMLText', THTMLTextProperty);
  {$ENDIF}
  RegisterComponentEditor(THTMLabel, THTMLDefaultEditor);
  {$ENDIF}
end;

end.

