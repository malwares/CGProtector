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
unit atbreg;

interface

uses
  Classes, AdvToolBtn;

{$IFDEF TMSDOTNET}
{$R TAdvToolButton.bmp}
{$R TAdvRepeatButton.bmp}
{$ENDIF}

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('TMS',[TAdvToolButton, TAdvRepeatButton]);
end;

end.
