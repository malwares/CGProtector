{*************************************************************************}
{ TADVTOOLBUTON component                                                 }
{ for Delphi & C++Builder                                                 }
{ version 1.2                                                             }
{                                                                         }
{ written by TMS Software                                                 }
{           copyright © 2002 - 2004                                       }
{           Email : info@tmssoftware.com                                  }
{           Web : http://www.tmssoftware.com                              }
{*************************************************************************}
{$I TMSDEFS.INC}
unit atbregde;

interface

uses
  Classes, AdvToolBtn, AdvToolButtonDE
  {$IFDEF DELPHI6_LVL}
  {$IFNDEF TMSDOTNET}
  , DesignIntf
  {$ENDIF}
  {$IFDEF TMSDOTNET}
  , Borland.Vcl.Design.DesignIntf
  {$ENDIF}
  {$ELSE}
  , DsgnIntf
  {$ENDIF}
  ;


procedure Register;

implementation

procedure Register;
begin
  RegisterComponentEditor(TAdvToolButton, TAdvToolButtonEditor);  
end;

end.
