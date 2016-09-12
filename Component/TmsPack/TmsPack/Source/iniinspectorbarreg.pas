{***************************************************************************}
{ TINIInspectorBar component                                                }
{ for Delphi & C++Builder                                                   }
{ version 1.4                                                               }
{                                                                           }
{ written by TMS Software                                                   }
{            copyright © 2001 - 2005                                        }
{            Email : info@tmssoftware.com                                   }
{            Web : http://www.tmssoftware.com                               }
{                                                                           }
{***************************************************************************}

unit INIInspectorBarReg;

interface
{$I TMSDEFS.INC}

{$IFDEF TMSDOTNET}
{$R TINIInspectorBar.bmp}
{$ENDIF}
uses
  INIInspectorBar, Classes;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('TMS Bars',[TINIInspectorBar]);
end;

end.
 