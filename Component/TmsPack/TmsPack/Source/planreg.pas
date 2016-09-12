{$I TMSDEFS.INC}

{***********************************************************************}
{ TPlanner component                                                    }
{ for Delphi & C++Builder                                               }
{ version 2.5                                                           }
{                                                                       }
{ written by TMS Software                                               }
{            copyright © 1999-2006                                      }
{            Email : info@tmssoftware.com                               }
{            Web : http://www.tmssoftware.com                           }
{***********************************************************************}

unit planreg;

{$IFDEF TMSDOTNET}
{$R TPlanner.bmp}
{$R TSimpleItemEditor.bmp}
{$R TDefaultItemEditor.bmp}
{$R TPeriodItemEditor.bmp}
{$R TAlarmMessage.bmp}
{$R TCapitalPlannerCheck.bmp}
{$R TShapeDrawTool.bmp}
{$R TPlannerWaitList.bmp}
{$R TPlannerRecurrencyEditor.bmp}
{$ENDIF}

interface

uses
  Classes, Planner, PlanCheck
  , PlanItemEdit, PlanSimpleEdit, PlanPeriodEdit, PlannerWaitList, PlannerActions, ActnList
  {$IFDEF DELPHI5_LVL}
  , PlanRecurrEdit
  , PlanDraw
  {$ENDIF}
  ;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('TMS Planner', [TPlanner]);
  RegisterComponents('TMS Planner', [TCapitalPlannerCheck]);
  RegisterComponents('TMS Planner', [TAlarmMessage]);

  RegisterComponents('TMS Planner', [TSimpleItemEditor]);
  RegisterComponents('TMS Planner', [TDefaultItemEditor]);
  RegisterComponents('TMS Planner', [TPeriodItemEditor]);

  {$IFDEF DELPHI5_LVL}
  RegisterComponents('TMS Planner', [TPlannerRecurrencyEditor]);
  RegisterComponents('TMS Planner', [TShapeDrawTool]);
  RegisterComponents('TMS Planner', [TPlannerWaitList]);
  {$ENDIF}

  RegisterActions('Planner', [TPlannerCut, TPlannerCopy, TPlannerPaste, TPlannerDelete, TPlannerInsert, TPlannerEdit], nil);
end;



end.

