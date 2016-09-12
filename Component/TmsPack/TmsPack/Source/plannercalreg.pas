{***********************************************************************}
{ TPLANNERCALENDAR component                                            }
{ for Delphi & C++Builder                                               }
{ version 1.3                                                           }
{                                                                       }
{ written by :                                                          }
{            TMS Software                                               }
{            copyright © 1999-2004                                      }
{            Email : info@tmssoftware.com                               }
{            Website : http://www.tmssoftware.com                       }
{***********************************************************************}
unit PlannerCalReg;

interface
{$I TMSDEFS.INC}

uses
  PlannerCal, PlannerDatePicker, PlannerMaskDatePicker, Classes;

{$IFDEF TMSDOTNET}
{$R TPlannerCalendar.bmp}
{$R TPlannerCalendarGroup.bmp}
{$R TPlannerDatePicker.bmp}
{$R TPlannerMaskDatePicker.bmp}
{$ENDIF}

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('TMS Planner', [TPlannerCalendar,
                                     TPlannerCalendarGroup,
                                     TPlannerDatePicker,
                                     TPlannerMaskDatePicker]);
end;



end.


