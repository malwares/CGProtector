{***********************************************************************}
{ TPLANNERCALENDAR component                                            }
{ for Delphi & C++Builder                                               }
{                                                                       }
{ written by :                                                          }
{            TMS Software                                               }
{            copyright © 1999-2009                                      }
{            Email : info@tmssoftware.com                               }
{            Website : http://www.tmssoftware.com                       }
{***********************************************************************}
unit PlannerCalRegDE;

interface                         
{$I TMSDEFS.INC}
uses
  PlannerCal, PlannerDatePicker, PlannerMaskDatePicker, Classes, PlanStyles
  {$IFNDEF TMSDOTNET}
  , AdvImage, AdvImgDE
  {$ENDIF}
{$IFDEF DELPHI6_LVL}
  {$IFNDEF TMSDOTNET}
  ,DesignIntf, DesignEditors
  {$ENDIF}
  {$IFDEF TMSDOTNET}
  ,Borland.Vcl.Design.DesignIntf, Borland.Vcl.Design.DesignEditors
  {$ENDIF}

{$ELSE}
  ,DsgnIntf
{$ENDIF}
  ;

type
  TPlannerCalendarEditProperty = class(TClassProperty);

  TPlannerCalendarEditor = class(TDefaultEditor)
  protected
  public
    function GetVerb(index:integer):string; override;
    function GetVerbCount:integer; override;
    procedure ExecuteVerb(Index:integer); override;
  end;


procedure Register;

implementation

uses
  Dialogs, Forms, Controls;

procedure Register;
begin
  {$IFNDEF TMSDOTNET}
  RegisterPropertyEditor(TypeInfo(TAdvImage), TPlannerCalendar, 'Background', TAdvImageProperty);
  RegisterPropertyEditor(TypeInfo(TAdvImage), TPlannerCalendarGroup, 'Background', TAdvImageProperty);
  {$ENDIF}
  RegisterPropertyEditor(TypeInfo(TPlannerCalendar), TPlannerDatePicker, 'Calendar', TPlannerCalendarEditProperty);
  RegisterPropertyEditor(TypeInfo(TPlannerCalendar), TPlannerMaskDatePicker, 'Calendar', TPlannerCalendarEditProperty);

  RegisterComponentEditor(TPlannerCalendar, TPlannerCalendarEditor);
  RegisterComponentEditor(TPlannerDatePicker, TPlannerCalendarEditor);
  RegisterComponentEditor(TPlannerCalendarGroup, TPlannerCalendarEditor);  
end;



{ TPlannerCalendarEditor }

procedure TPlannerCalendarEditor.ExecuteVerb(Index: integer);
var
  psf: TPlanStyleForm;
begin
  inherited;
  if Index = 0 then
  begin
    psf := TPlanStyleForm.Create(Application);
    psf.Caption := 'PlannerCalendar Styles';    
    if psf.ShowModal = mrOK then
    begin
      if (Component is TPlannerCalendar) then
        (Component as TPlannerCalendar).Style := TPlannerCalendarStyle(psf.RadioGroup1.ItemIndex);
      if (Component is TPlannerDatePicker) then
        (Component as TPlannerDatePicker).Calendar.Style := TPlannerCalendarStyle(psf.RadioGroup1.ItemIndex);

      if (Component is TPlannerCalendarGroup) then
        (Component as TPlannerCalendarGroup).Style := TPlannerCalendarStyle(psf.RadioGroup1.ItemIndex);

      Designer.Modified;
    end;
    psf.Free;
  end;
end;

function TPlannerCalendarEditor.GetVerb(index: integer): string;
begin
  if Index = 0 then
    Result := 'Styles';
end;

function TPlannerCalendarEditor.GetVerbCount: integer;
begin
  Result := 1;
end;

end.


