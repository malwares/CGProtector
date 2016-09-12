{***********************************************************************}
{ TDBPLANNERCALENDAR & TDBPLANNERDATEPICKER components                  }
{ for Delphi & C++Builder                                               }
{ version 1.1                                                           }
{                                                                       }
{ written by :                                                          }
{            TMS Software                                               }
{            copyright © 1999-2004                                      }
{            Email : info@tmssoftware.com                               }
{            Website : http://www.tmssoftware.com                       }
{***********************************************************************}
{$I TMSDEFS.INC}

unit DBPlannerCalReg;

{$IFDEF TMSDOTNET}
{$R TDBPlannerCalendar.bmp}
{$R TDBPlannerDatePicker.bmp}
{$R TPlannerDBDatePicker.bmp}
{$R TPlannerDBMaskDatePicker.bmp}
{$ENDIF}

interface

uses
  Classes, DBPlannerCal, DBPlannerDatePicker, PlannerDBDatePicker, PlannerDBMaskDatePicker;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('TMS Planner', [TDBPlannerCalendar,TDBPlannerDatePicker, TPlannerDBDatePicker, TPlannerDBMaskDatePicker]);
  RegisterClass(TDBPlannerCalendar);
end;

end.
 