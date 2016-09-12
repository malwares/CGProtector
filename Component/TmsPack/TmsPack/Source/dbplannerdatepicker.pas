{***********************************************************************}
{ TDBPlannerDatePicker component                                        }
{ for Delphi & C++ Builder                                              }
{                                                                       }
{ written by :                                                          }
{            TMS Software                                               }
{            copyright © 1999-2008                                      }
{            Email : info@tmssoftware.com                               }
{            Website : http://www.tmssoftware.com                       }
{                                                                       }
{ The source code is given as is. The author is not responsible         }
{ for any possible damage done due to the use of this code.             }
{ The component can be freely used in any application. The source       }
{ code remains property of the writer and may not be distributed        }
{ freely as such.                                                       }
{***********************************************************************}

{$I TMSDEFS.INC}

unit DBPlannerDatePicker;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, PlannerCal, DBPlannerCal, AdvEdBtn, DB, DBCtrls;

const
  MAJ_VER = 1; // Major version nr.
  MIN_VER = 4; // Minor version nr.
  REL_VER = 0; // Release nr.
  BLD_VER = 6; // Build nr.

  // version history
  // 1.4.0.2 : Improvement with dataset update
  // 1.4.0.3 : Fix for putting dataset automatically in edit mode.
  // 1.4.0.4 : Fixed issue with keyboard modifications of date
  // 1.4.0.5 : Fixed issue with returning date when text is empty
  // 1.4.0.6 : Fixed issue with ReadOnly fields

type

  TDBPlannerDatePicker = class(TAdvEditBtn)
  private
    { Private declarations }
    FPlannerCalendar: TDBPlannerCalendar;
    APlannerCalendar: TDBPlannerCalendar;
    PlannerParent : TForm;
    CancelThisBtnClick : Boolean;
    FHideCalendarAfterSelection: boolean;
    FOnDaySelect: TDaySelectEvent;
    FDataLink: TFieldDataLink;
    FInternalChange: Boolean;
    function GetOnGetDateHint: TGetDateEvent;
    function GetOnGetDateHintString: TGetDateEventHint;
    procedure SetOnGetDateHint(const Value: TGetDateEvent);
    procedure SetOnGetDateHintString(const Value: TGetDateEventHint);
    procedure HideParent;
    function GetOnGetEventProp: TEventPropEvent;
    procedure SetOnGetEventProp(const Value: TEventPropEvent);
    function GetOnWeekSelect: TNotifyEvent;
    procedure SetOnWeekSelect(const Value: TNotifyEvent);
    function GetOnAllDaySelect: TNotifyEvent;
    procedure SetOnAllDaySelect(const Value: TNotifyEvent);
    function GetDataField: string;
    function GetDataSource: TDataSource;
    procedure SetDataField(const Value: string);
    procedure SetDataSource(const Value: TDataSource);
    procedure DataUpdate(Sender: TObject);
    procedure DataChange(Sender: TObject);
    procedure ActiveChange(Sender: TObject);
    function GetDate: TDateTime;
    procedure SetDate(const Value: TDateTime);
    {$IFNDEF TMSDOTNET}
    procedure CMGetDataLink(var Message: TMessage); message CM_GETDATALINK;
    {$ENDIF}
  protected
    { Protected declarations }
    function GetVersionNr: Integer; override;
    procedure BtnClick(Sender: TObject); override;
    procedure PlannerParentDeactivate(Sender: TObject);
    procedure PlannerCalendarDaySelect(Sender: TObject; SelDate: TDateTime);
    procedure PlannerCalendarKeyPress(Sender: TObject; var Key: Char);
    procedure PlannerCalendarKeyDown(Sender: TObject; var Key: Integer;
      Shift: TShiftState);
    procedure WMSetFocus(var Message: TWMSetFocus); message WM_SETFOCUS;
    // methods to do correct streaming, because the planner calendar is
    // stored on a hidden form
    procedure Change; override;
    function EditCanModify: Boolean; virtual;
    function GetChildParent : TComponent; override;
    function GetChildOwner : TComponent; override;
    procedure Loaded; override;
    procedure KeyDown(var Key: Word; Shift: TShiftState); override;
    procedure KeyPress(var Key: Char); override;
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
    procedure DoExit; override;
  public
    { Public declarations }
    constructor Create(AOwner: TComponent); override;
    procedure CancelBtnClick;
    procedure DropDown; virtual;
    destructor Destroy; override;
    property Date: TDateTime read GetDate write SetDate;
    procedure GetChildren(Proc: TGetChildProc; Root: TComponent); override;
  published
    { Published declarations }
    property Calendar : TDBPlannerCalendar read FPlannerCalendar
      write FPlannerCalendar;
    property DataField: string read GetDataField write SetDataField;
    property DataSource: TDataSource read GetDataSource write SetDataSource;
    property HideCalendarAfterSelection : boolean read FHideCalendarAfterSelection
      write FHideCalendarAfterSelection;
    property OnGetDateHint: TGetDateEvent read GetOnGetDateHint
      write SetOnGetDateHint;
    property OnGetDateHintString: TGetDateEventHint read GetOnGetDateHintString
      write SetOnGetDateHintString;
    property OnGetEventProp: TEventPropEvent read GetOnGetEventProp
      write SetOnGetEventProp;
    property OnWeekSelect: TNotifyEvent read GetOnWeekSelect write SetOnWeekSelect;
    property OnAllDaySelect: TNotifyEvent read GetOnAllDaySelect write SetOnAllDaySelect;
    property OnDaySelect: TDaySelectEvent read FOnDaySelect write FOnDaySelect;    
  end;

implementation

{ TDBPlannerDatePicker }

procedure TDBPlannerDatePicker.DropDown;
var
  PlannerPosition : TPoint;
  r: TRect;

  function Min(a,b: Integer): Integer;
  begin
    if (a > b) then
      Result := b
    else
      Result := a;
  end;

begin
  // Set planner position
  PlannerPosition.x := -2;
  PlannerPosition.y := Height - 3;
  PlannerPosition := ClientToScreen(PlannerPosition);

  {$IFNDEF TMSDOTNET}
  SystemParametersInfo(SPI_GETWORKAREA, 0,@r,0); //account for taskbar...
  {$ENDIF}
  {$IFDEF TMSDOTNET}
  SystemParametersInfo(SPI_GETWORKAREA, 0,r,0); //account for taskbar...
  {$ENDIF}

  if (plannerposition.y + FPlannerCalendar.Height > r.Bottom) then
    plannerposition.Y := plannerposition.Y - FPlannerCalendar.Height - Height + 3;

  if (plannerposition.x + FPlannerCalendar.Width > r.right) then
    plannerposition.x := plannerposition.x - (FPlannerCalendar.Width - Width);

  PlannerParent.Left := PlannerPosition.x;
  PlannerParent.Top := PlannerPosition.y;

  {$IFNDEF DELPHI4_LVL}
  PlannerParent.Width := FPlannerCalendar.Width;
  PlannerParent.Height := FPlannerCalendar.Height;
  {$ENDIF}

  // Set planner date

  if FPlannerCalendar.MultiSelect then
    Text := FPlannerCalendar.DatesAsText
  else
  begin
    try
      if Text = '' then
        FPlannerCalendar.Date := Now
      else
        FPlannerCalendar.Date := StrToDate(Text);
    except
      on Exception do
         Text := FPlannerCalendar.DatesAsText;
    end;
  end;

  PlannerParent.Show;
  FPlannerCalendar.SetFocus;
end;



procedure TDBPlannerDatePicker.BtnClick(Sender: TObject);
begin
  CancelThisBtnClick := False;
  inherited;
  // call event OnClick - the user can cancel calendar appearance of calendar by calling .CancelBtnClick
  if CancelThisBtnClick then
    Exit;
  DropDown;
end;

procedure TDBPlannerDatePicker.CancelBtnClick;
begin
  CancelThisBtnClick := True;
end;

constructor TDBPlannerDatePicker.Create(AOwner: TComponent);
begin
  inherited;
  // Make planner parent form and a planner, put planner on parent form
  FInternalChange := true;  
  Text := '';
  FInternalChange := false;
  PlannerParent := TForm.Create(Self);
  PlannerParent.BorderStyle := bsNone;

  FPlannerCalendar := TDBPlannerCalendar.Create(Self);
  FPlannerCalendar.Parent := PlannerParent;

  {$IFDEF DELPHI4_LVL}
  PlannerParent.Autosize := True;
  {$ELSE}
  PlannerParent.Width := FPlannerCalendar.Width;
  PlannerParent.Height := FPlannerCalendar.Height;
  {$ENDIF}

  PlannerParent.OnDeactivate := PlannerParentDeactivate;
  FPlannerCalendar.OnDaySelect := PlannerCalendarDaySelect;

  Width := FPlannerCalendar.Width;
  FHideCalendarAfterSelection := True;

  Button.Glyph.Handle := LoadBitmap(0, MakeIntResource(OBM_COMBO));

  // Make the button NOT change the focus
  Button.FocusControl := nil;

  FDataLink := TFieldDataLink.Create;
  FDataLink.Control := Self;
  FDataLink.OnDataChange := DataChange;
  FDataLink.OnUpdateData := DataUpdate;
  FDataLink.OnActiveChange := ActiveChange;
end;


destructor TDBPlannerDatePicker.Destroy;
begin
  FPlannerCalendar.Free;
  PlannerParent.Free;
  FDataLink.Free;
  FDataLink := nil;
  inherited;
end;

procedure TDBPlannerDatePicker.DoExit;
begin
  inherited;
  if FDataLink.Edit then
  begin
    try
      Date := StrToDate(Text);
      DataUpdate(self);
    except
      // do nothing if no valid date is entered
    end;
  end;
end;

function TDBPlannerDatePicker.GetChildOwner: TComponent;
begin
  Result := PlannerParent;
end;

function TDBPlannerDatePicker.GetChildParent: TComponent;
begin
  Result := PlannerParent;
end;

procedure TDBPlannerDatePicker.GetChildren(Proc: TGetChildProc; Root: TComponent);
begin
  inherited;
  Proc(FPlannerCalendar);
  FPlannerCalendar.Parent := PlannerParent;
end;

function TDBPlannerDatePicker.GetOnGetDateHint: TGetDateEvent;
begin
  Result := FPlannerCalendar.OnGetDateHint;
end;

function TDBPlannerDatePicker.GetOnGetDateHintString: TGetDateEventHint;
begin
  Result := FPlannerCalendar.OnGetDateHintString;
end;

function TDBPlannerDatePicker.GetOnGetEventProp: TEventPropEvent;
begin
  Result := FPlannerCalendar.OnGetEventProp;
end;

procedure TDBPlannerDatePicker.HideParent;
begin
  PlannerParent.Hide;
  SetFocus;
end;

procedure TDBPlannerDatePicker.KeyDown(var Key: Word; Shift: TShiftState);
begin
  if (Key = VK_DELETE) or ((Key = VK_INSERT) and (ssShift in Shift)) then
  begin
    if not EditCanModify then
    begin
      key := 0;
      Exit;
    end;
  end;

  if FDataLink.ReadOnly and (key = VK_DELETE) then
    Key := 0;

  inherited KeyDown(Key, Shift);

  if (Key = VK_DELETE) or ((Key = VK_INSERT) and (ssShift in Shift)) then
  begin
    FDataLink.Edit;
  end;

  if (Key <> 0) then
    FDataLink.Modified;


  if key = VK_F4 then
    if PlannerParent.Visible then
      HideParent
    else
      BtnClick(Self);
end;

procedure TDBPlannerDatePicker.Loaded;
begin
  inherited;
  {$IFDEF TMSDEBUG}
  outputdebugstring('loaded picker');
  if FPlannerCalendar.Color = clWhite then
    outputdebugstring('is white');
  {$ENDIF}

  if PlannerParent.ComponentCount > 0 then
  begin
    APlannerCalendar := (PlannerParent.Components[0] as TDBPlannerCalendar);
    APlannerCalendar.OnDaySelect := PlannerCalendarDaySelect;
    APlannerCalendar.OnGetDateHint := FPlannerCalendar.OnGetDateHint;
    APlannerCalendar.OnGetDateHintString := FPlannerCalendar.OnGetDateHintString;
    APlannerCalendar.OnKeyPress := PlannerCalendarKeypress;
    FPlannerCalendar.Free;
    FPlannerCalendar := APlannerCalendar;
  end;
end;

procedure TDBPlannerDatePicker.PlannerCalendarDaySelect(Sender: TObject; SelDate: TDateTime);
var
  NText: string;
begin
  NText := FPlannerCalendar.DatesAsText;

  if EditCanModify then
  begin
    FDataLink.Modified;
    Text := NText;
    DataUpdate(self);
    Modified := true;
  end;

  if Assigned(FOnDaySelect) then
    FOnDaySelect(Self,SelDate);

  if FHideCalendarAfterSelection then
    HideParent;
end;

procedure TDBPlannerDatePicker.PlannerCalendarKeyDown(Sender: TObject;
  var Key: Integer; Shift: TShiftState);
begin
  if Key = VK_F4 then
    HideParent;
end;

procedure TDBPlannerDatePicker.PlannerCalendarKeyPress(Sender: TObject;
  var Key: Char);
begin
  if Key = #13 then
  begin
    PlannerCalendarDaySelect(Sender, FPlannerCalendar.Date);
  end;
  if Key = #27 then
  begin
    HideParent;
  end;
end;

procedure TDBPlannerDatePicker.PlannerParentDeactivate(Sender: TObject);
begin
  (Sender as TForm).Hide;
end;

procedure TDBPlannerDatePicker.SetOnGetDateHint(const Value: TGetDateEvent);
begin
  FPlannerCalendar.OnGetDateHint := Value;
end;

procedure TDBPlannerDatePicker.SetOnGetDateHintString(
  const Value: TGetDateEventHint);
begin
  FPlannerCalendar.OnGetDateHintString := Value;
end;

procedure TDBPlannerDatePicker.SetOnGetEventProp(
  const Value: TEventPropEvent);
begin
  FPlannerCalendar.OnGetEventProp := Value;
end;

procedure TDBPlannerDatePicker.WMSetFocus(var Message: TWMSetFocus);
begin
  if EditorEnabled then
    inherited
  else
    if Button.Enabled then
      Button.SetFocus;
end;

function TDBPlannerDatePicker.GetOnWeekSelect: TNotifyEvent;
begin
  Result := FPlannerCalendar.OnWeekSelect;
end;

procedure TDBPlannerDatePicker.SetOnWeekSelect(const Value: TNotifyEvent);
begin
  FPlannerCalendar.OnWeekSelect := Value;
end;

function TDBPlannerDatePicker.GetOnAllDaySelect: TNotifyEvent;
begin
  Result := FPlannerCalendar.OnAllDaySelect;
end;

procedure TDBPlannerDatePicker.SetOnAllDaySelect(const Value: TNotifyEvent);
begin
  FPlannerCalendar.OnAllDaySelect := Value;
end;

function TDBPlannerDatePicker.GetDataField: string;
begin
  Result := FDataLink.FieldName;
end;

function TDBPlannerDatePicker.GetDataSource: TDataSource;
begin
  Result := FDataLink.DataSource;
end;

procedure TDBPlannerDatePicker.SetDataField(const Value: string);
begin
  FDataLink.FieldName := Value;
end;

procedure TDBPlannerDatePicker.SetDataSource(const Value: TDataSource);
begin
  FDataLink.DataSource := Value;
end;

procedure TDBPlannerDatePicker.ActiveChange(Sender: TObject);
begin
  if Assigned(FDataLink) then
  begin
    if Assigned(FDataLink.DataSet) then
    begin
      if not FDataLink.DataSet.Active then
        Text := '';
    end
    else
    begin
      Text := '';
    end;
  end;
end;

procedure TDBPlannerDatePicker.DataChange(Sender: TObject);
begin
  if not Assigned(FDataLink.DataSet) then
    Exit;
    
  if Assigned(FDataLink.Field) then
  begin
    if FDataLink.Field.DisplayText <> '' then
    begin
      FInternalChange := true;
      Date := FDataLink.Field.AsDateTime;
      FInternalChange := false;
    end
    else
    begin
      FInternalChange := true;
      Text := '';
      FInternalChange := false;
    end;

    EditorEnabled := not FDataLink.Field.ReadOnly;
  end;
end;

procedure TDBPlannerDatePicker.DataUpdate(Sender: TObject);
begin
  if Assigned(FDataLink.Field) then
  begin
    if Text = '' then
      FDataLink.Field.AsString := ''
    else
      FDataLink.Field.AsDateTime := Date;
  end;
end;

procedure TDBPlannerDatePicker.Notification(AComponent: TComponent;
  Operation: TOperation);
begin
  inherited Notification(AComponent, Operation);
  if (Operation = opRemove) and (FDataLink <> nil) and
    (AComponent = DataSource) then DataSource := nil;
end;

function TDBPlannerDatePicker.GetDate: TDateTime;
begin
  if Text = '' then
    Result := 0
  else
    Result := FPlannerCalendar.Date;
end;

procedure TDBPlannerDatePicker.SetDate(const Value: TDateTime);
begin
  FPlannerCalendar.Date := Value;
  Text := DateToStr(Value);
end;

{$IFNDEF TMSDOTNET}
procedure TDBPlannerDatePicker.CMGetDataLink(var Message: TMessage);
begin
  Message.Result := Integer(FDataLink);
end;
{$ENDIF}

procedure TDBPlannerDatePicker.Change;
begin
  inherited;

  if FInternalChange then
    Exit;

  if EditCanModify then
  begin
    FDataLink.Modified;
    ///DataUpdate(self);
  end;

  try
    if Text <> '' then
	  if Assigned(FPlannerCalendar) then
        FPlannerCalendar.Date := StrToDate(Text)
  except
  end;
end;

function TDBPlannerDatePicker.EditCanModify: Boolean;
begin
  Result := FDataLink.Edit;
end;

procedure TDBPlannerDatePicker.KeyPress(var Key: Char);
begin
  if not EditCanMOdify then
    Exit;
  inherited KeyPress(Key);
end;

function TDBPlannerDatePicker.GetVersionNr: Integer;
begin
  Result := MakeLong(MakeWord(BLD_VER,REL_VER),MakeWord(MIN_VER,MAJ_VER));
end;

initialization
  {$IFDEF ISDELPHI}
  try
    RegisterClass(TDBPlannerCalendar);
  except
  end;
  {$ENDIF}  

end.
