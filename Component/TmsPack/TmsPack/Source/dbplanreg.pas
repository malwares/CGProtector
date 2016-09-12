{$I TMSDEFS.INC}
{***********************************************************************}
{ TDBPlanner component                                                  }
{ for Delphi & C++Builder                                               }
{                                                                       }
{ written by                                                            }
{    TMS Software                                                       }
{    copyright © 2001 - 2006                                            }
{    Email : info@tmssoftware.com                                       }
{    Web : http://www.tmssoftware.com                                   }
{                                                                       }
{***********************************************************************}

unit DBPlanReg;

{$IFDEF TMSDOTNET}
{$R TDBPlanner.bmp}
{$R TDBDaySource.bmp}
{$R TDBPeriodSource.bmp}
{$R TDBMonthSource.bmp}
{$R TDBWeekSource.bmp}
{$R TDBMultiMonthSource.bmp}
{$R TDBTimeLineSource.bmp}
{$R TDBHalfDayPeriodSource.bmp}
{$R TDBDisjunctDaySource.bmp}
{$R TDBActiveDaySource.bmp}
{$ENDIF}

interface
uses
  DBPlanner, Classes;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('TMS Planner', [TDBPlanner]);
  RegisterComponents('TMS Planner', [TDBDaySource]);
  RegisterComponents('TMS Planner', [TDBPeriodSource]);
  RegisterComponents('TMS Planner', [TDBMonthSource]);
  RegisterComponents('TMS Planner', [TDBWeekSource]);
  RegisterComponents('TMS Planner', [TDBMultiMonthSource]);
  RegisterComponents('TMS Planner', [TDBTimeLineSource]);
  RegisterComponents('TMS Planner', [TDBHalfDayPeriodSource]);
  RegisterComponents('TMS Planner', [TDBDisjunctDaySource]);
  RegisterComponents('TMS Planner', [TDBActiveDaySource]);
end;

end.
