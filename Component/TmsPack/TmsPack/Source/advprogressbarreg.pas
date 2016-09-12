{********************************************************************}
{ TADVPROGRESSBAR component                                          }
{ for Delphi 5.0,6.0,7.0,2005 & C++Builder 5.0,6.0                   }
{ version 1.1                                                        }
{                                                                    }
{ written by                                                         }
{       TMS Software                                                 }
{       copyright © 2003 - 2005                                      }
{       Email : info@tmssoftware.com                                 }
{       Web : http://www.tmssoftware.com                             }
{********************************************************************}

unit AdvProgressBarReg;

{$I TMSDEFS.INC}
interface

uses
  Classes, AdvProgressBar;

{$IFDEF TMSDOTNET}
{$R TAdvProgressBar.bmp}
{$ENDIF}

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('TMS', [TAdvProgressBar]);
end;

end.
