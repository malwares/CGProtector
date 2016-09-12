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
unit DBPlannerCalRegDE;

interface
{$I TMSDEFS.INC}
uses
  Classes,DBPlannerCal,DBPlannerCalDE,DBPlannerDatePicker,
{$IFDEF DELPHI6_LVL}
  {$IFNDEF TMSDOTNET}
  DesignIntf, DesignEditors
  {$ENDIF}
  {$IFDEF TMSDOTNET}
  Borland.Vcl.Design.DesignIntf, Borland.Vcl.Design.DesignEditors
  {$ENDIF}

{$ELSE}
  DsgnIntf
{$ENDIF}
  ;

type
  TDBPlannerCalendarEditProperty = class(TClassProperty);


procedure Register;

implementation

procedure Register;
begin
  RegisterPropertyEditor(TypeInfo(string),TDBPlannerCalendar,'StartTimeField',TPlannerCalendarFieldNameProperty);
  RegisterPropertyEditor(TypeInfo(string),TDBPlannerCalendar,'EndTimeField',TPlannerCalendarFieldNameProperty);
  RegisterPropertyEditor(TypeInfo(string),TDBPlannerCalendar,'SubjectField',TPlannerCalendarFieldNameProperty);
  RegisterPropertyEditor(TypeInfo(TDBPlannerCalendar), TDBPlannerDatePicker, 'Calendar', TDBPlannerCalendarEditProperty);
end;

end.

