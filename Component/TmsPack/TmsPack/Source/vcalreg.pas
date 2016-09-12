{***************************************************************************}
{ TvCalendar component                                                      }
{ for Delphi & C++Builder                                                   }
{ version 1.0                                                               }
{                                                                           }
{ written by TMS Software                                                   }
{            copyright © 2001 - 2004                                       }
{            Email : info@tmssoftware.com                                   }
{            Web : http://www.tmssoftware.com                               }
{                                                                           }
{***************************************************************************}

unit vCalReg;

{$I TMSDEFS.INC}
interface

uses
  Classes, vCal;

{$IFDEF TMSDOTNET}
{$R TvCalendar.bmp}
{$ENDIF}
procedure Register;


implementation

procedure Register;
begin
  RegisterComponents('TMS Planner',[TvCalendar]);
end;



end.
 