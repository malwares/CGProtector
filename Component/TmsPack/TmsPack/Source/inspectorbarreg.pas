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
unit InspectorBarReg;

interface
{$I TMSDEFS.INC}

{$IFDEF TMSDOTNET}
  {$R TInspectorBar.bmp}
{$ENDIF}

uses
  Classes, InspectorBar;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('TMS Bars',[TInspectorBar]);
end;

end.
