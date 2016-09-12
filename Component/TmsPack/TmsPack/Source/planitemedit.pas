{***********************************************************************}
{ TPlanner component                                                    }
{ for Delphi & C++Builder                                               }
{ version 2.1                                                           }
{                                                                       }
{ written by TMS Software                                               }
{            copyright © 1999-2004                                      }
{            Email: info@tmssoftware.com                                }
{            Web: http://www.tmssoftware.com                            }
{                                                                       }
{ The source code is given as is. The author is not responsible         }
{ for any possible damage done due to the use of this code.             }
{ The component can be freely used in any application. The complete     }
{ source code remains property of the author and may not be distributed,}
{ published, given or sold in any form as such. No parts of the source  }
{ code can be included in any other component or application without    }
{ written authorization of the author.                                  }
{***********************************************************************}

{$I TMSDEFS.INC}

unit PlanItemEdit;

interface
{
    Alarm
      - .Active
      - .Address
      - .Message
      - .TimeBefore

    .Flashing
    .Color / .SelectColor / .SelectFontColor / .TrackColor
    .Font
    .TrackVisible
    .URL
    .Caption
    .Text

    .ImageID (wat voor selectie component)

    .Alignment left/right/centered
}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms,
  Dialogs, Planner, StdCtrls, ExtCtrls, ComCtrls, Buttons, CommCtrl

  {$IFDEF TMSDOTNET}
  , Types
  {$ENDIF}

  ;

type
  TEditState = (esEdit, esNew);

type
  TBasePlannerItemEditForm = class(TForm)
  private
    FEditState: TEditState;
  protected
    procedure AssignFromPlannerItem(PlannerItem: TPlannerItem); virtual;
    procedure AssignToPlannerItem(PlannerItem: TPlannerItem); virtual;
    procedure CheckInputValues(PlannerItem: TPlannerItem); virtual;
    procedure EditStateChanged; virtual;
    procedure FixEnabledComponents; virtual;
    procedure InternalEditModal(PlannerItem: TPlannerItem); virtual;
    procedure ProcessWarnings; virtual;
    procedure SetEditState(const Value: TEditState); virtual;
  public
    procedure EditModal(PlannerItem: TPlannerItem); virtual;
    property EditState: TEditState read FEditState write SetEditState;
  end;

  TDefaultPlannerItemEditForm = class(TBasePlannerItemEditForm)
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    BaseColorButton: TButton;
    StartTimeDateTimePicker: TDateTimePicker;
    EndTimeDateTimePicker: TDateTimePicker;
    BaseColorPanel: TPanel;
    SubjectEdit: TEdit;
    NotesMemo: TMemo;
    PlanDateDateTimePicker: TDateTimePicker;
    ColorDialog: TColorDialog;
    WarningPanel: TPanel;
    ButtonBottomPanel: TPanel;
    ButtonBottomRightPanel: TPanel;
    OKBtn: TButton;
    CancBtn: TButton;
    Label9: TLabel;
    UrlEdit: TEdit;
    Bevel1: TBevel;
    ReminderCheckBox: TCheckBox;
    ReminderDateTimePicker: TDateTimePicker;
    ReminderMessageLabel: TLabel;
    ReminderMesssageEdit: TEdit;
    Bevel2: TBevel;
    Label10: TLabel;
    TrackColorButton: TButton;
    TrackColorPanel: TPanel;
    SelectedFontColorButton: TButton;
    SelectedColorButton: TButton;
    SelectedColorPanel: TPanel;
    SelectedFontColorPanel: TPanel;
    Label7: TLabel;
    ShapeComboBox: TComboBox;
    FlashingCheckBox: TCheckBox;
    FontButton: TButton;
    FontDialog: TFontDialog;
    ReminderAddressLabel: TLabel;
    ReminderAddressEdit: TEdit;
    FontPanel: TPanel;
    AlarmImage: TImage;
    CautionImage: TImage;
    ImageSpeedButton: TSpeedButton;
    ImageUpDown: TUpDown;
    AlignLeftBitBtn: TBitBtn;
    AlignCentreLeftBitBtn: TBitBtn;
    AlignRightBitBtn: TBitBtn;
    procedure BaseColorPanelClick(Sender: TObject);
    procedure ReminderCheckBoxClick(Sender: TObject);
    procedure FontButtonClick(Sender: TObject);
    procedure PlanDateDateTimePickerChange(Sender: TObject);
    procedure StartTimeDateTimePickerChange(Sender: TObject);
    procedure EndTimeDateTimePickerChange(Sender: TObject);
    procedure ImageUpDownClick(Sender: TObject; Button: TUDBtnType);
    procedure AlignLeftBitBtnClick(Sender: TObject);
    procedure AlignCentreLeftBitBtnClick(Sender: TObject);
    procedure AlignRightBitBtnClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    FImageList: TImageList;
  protected
    {$IFNDEF TMSDOTNET}
    function GetEndTime: TTime; virtual;
    {$ENDIF}
    {$IFDEF TMSDOTNET}
    function GetEndTime: TDateTime; virtual;
    {$ENDIF}
    function GetPlanDate: TDateTime; virtual;
    {$IFNDEF TMSDOTNET}
    function GetStartTime: TTime; virtual;
    function GetReminderTime: TTime; virtual;
    procedure SetEndTime(const Value: TTime); virtual;
    {$ENDIF}
    {$IFDEF TMSDOTNET}
    function GetStartTime: TDateTime; virtual;
    function GetReminderTime: TDateTime; virtual;
    procedure SetEndTime(const Value: TDateTime); virtual;
    {$ENDIF}
    procedure SetImageList(const Value: TImageList); virtual;
    procedure SetPlanDate(const Value: TDateTime); virtual;
    {$IFNDEF TMSDOTNET}
    procedure SetStartTime(const Value: TTime); virtual;
    procedure SetReminderTime(const Value: TTime); virtual;
    {$ENDIF}
    {$IFDEF TMSDOTNET}
    procedure SetStartTime(const Value: TDateTime); virtual;
    procedure SetReminderTime(const Value: TDateTime); virtual;
    {$ENDIF}
  protected
    property PlanDate: TDateTime read GetPlanDate write SetPlanDate;
    {$IFNDEF TMSDOTNET}
    property StartTime: TTime read GetStartTime write SetStartTime;
    property EndTime: TTime read GetEndTime write SetEndTime;
    {$ENDIF}
    {$IFDEF TMSDOTNET}
    property StartTime: TDateTime read GetStartTime write SetStartTime;
    property EndTime: TDateTime read GetEndTime write SetEndTime;
    {$ENDIF}
    property ImageList: TImageList read FImageList write SetImageList;
    {$IFNDEF TMSDOTNET}
    property ReminderTime: TTime read GetReminderTime write SetReminderTime;
    {$ENDIF}
    {$IFDEF TMSDOTNET}
    property ReminderTime: TDateTime read GetReminderTime write SetReminderTime;
    {$ENDIF}
  protected
    procedure AssignFromPlannerItem(PlannerItem: TPlannerItem); override;
    procedure AssignToPlannerItem(PlannerItem: TPlannerItem); override;
    procedure CheckInputValues(PlannerItem: TPlannerItem); override;
    procedure CopyImageToSpeedButton(Index: Integer); virtual;
    procedure EditStateChanged; override;
    procedure FixEnabledComponents; override;
    procedure ImageChanged; virtual;
    procedure ProcessWarnings; override;
  end;

  TDefaultItemEditor = class(TCustomItemEditor)
  private
    FEditForm: TDefaultPlannerItemEditForm;
    FCenter: Boolean;
    FFormLeft: Integer;
    FFormTop: Integer;
  public
    constructor Create(AOwner: TComponent); override;
    procedure CreateEditor(AOwner: TComponent); override;
    procedure DestroyEditor; override;
    function Execute: Integer; override;
    procedure PlannerItemToEdit(APlannerItem: TPlannerItem); override;
    procedure EditToPlannerItem(APlannerItem: TPlannerItem); override;
  published
    property CenterOnScreen: Boolean read FCenter write FCenter default True;
    property FormLeft: Integer read FFormLeft write FFormLeft;
    property FormTop: Integer read FFormTop write FFormTop;
  end;


const
  OneDay = 1;
  OneHour = OneDay / 24;
  OneMinute = OneHour / 60;
  OneSecond = OneMinute / 60;
  MinDuration = 15 * OneMinute;

implementation

{$R *.dfm}

{ TBasePlannerItemEditForm }

procedure TBasePlannerItemEditForm.AssignFromPlannerItem(
  PlannerItem: TPlannerItem);
begin
  //placeholder for descendants
end;

procedure TBasePlannerItemEditForm.AssignToPlannerItem(
  PlannerItem: TPlannerItem);
begin
  //placeholder for descendants
end;

procedure TBasePlannerItemEditForm.CheckInputValues(PlannerItem: TPlannerItem);
begin
  //placeholder for descendants
end;

procedure TBasePlannerItemEditForm.EditModal(PlannerItem: TPlannerItem);
begin
  Assert(Assigned(PlannerItem), 'Must pass a non-nil planner item for editing');
  EditState := esEdit;
  InternalEditModal(PlannerItem);
end;

procedure TBasePlannerItemEditForm.EditStateChanged;
begin
  //placeholder for descendants
end;

procedure TBasePlannerItemEditForm.FixEnabledComponents;
begin
  //placeholder for descendants
end;

procedure TBasePlannerItemEditForm.InternalEditModal(
  PlannerItem: TPlannerItem);
begin
  AssignFromPlannerItem(PlannerItem);
  FixEnabledComponents;
  ProcessWarnings;
  if (ShowModal = mrOK) then
  begin
    CheckInputValues(PlannerItem);
    AssignToPlannerItem(PlannerItem);
    PlannerItem.Update;
  end;
end;

procedure TBasePlannerItemEditForm.ProcessWarnings;
begin
  //placeholder for descendants
end;

procedure TBasePlannerItemEditForm.SetEditState(const Value: TEditState);
begin
  if Value <> EditState then
  begin
    FEditState := Value;
    EditStateChanged;
  end;
end;


{ TDefaultPlannerItemEditForm }

procedure TDefaultPlannerItemEditForm.AlignCentreLeftBitBtnClick(
  Sender: TObject);
begin
  NotesMemo.Alignment := taCenter;
end;

procedure TDefaultPlannerItemEditForm.AlignLeftBitBtnClick(
  Sender: TObject);
begin
  NotesMemo.Alignment := taLeftJustify;
end;

procedure TDefaultPlannerItemEditForm.AlignRightBitBtnClick(
  Sender: TObject);
begin
  NotesMemo.Alignment := taRightJustify;
end;

procedure TDefaultPlannerItemEditForm.AssignFromPlannerItem(
  PlannerItem: TPlannerItem);
begin
  inherited;
  SubjectEdit.Text := PlannerItem.CaptionText;
  if PlannerItem.RealTime then
  begin
    PlanDate := PlannerItem.ItemRealStartTime;
    StartTime := PlannerItem.ItemRealStartTime;
    EndTime := PlannerItem.ItemRealEndTime;
  end
  else
  begin
    PlanDate := PlannerItem.ItemStartTime;
    StartTime := PlannerItem.ItemStartTime;
    EndTime := PlannerItem.ItemEndTime;
  end;

  NotesMemo.Lines := PlannerItem.Text;
  NotesMemo.Alignment := PlannerItem.Alignment;

  // three possible shapes: 1-psRect, 2-psRounded, 3-psHexagon
  ShapeComboBox.ItemIndex := Ord(PlannerItem.Shape);
  FlashingCheckBox.Checked := PlannerItem.Flashing;
  FlashingCheckBox.Enabled := PlannerItem.Planner.EnableFlashing;

  UrlEdit.Text := PlannerItem.URL;

  ReminderCheckBox.Checked := PlannerItem.Alarm.Active;
  ReminderTime := PlannerItem.Alarm.TimeBefore;
  ReminderMesssageEdit.Text := PlannerItem.Alarm.Message;
  ReminderAddressEdit.Text := PlannerItem.Alarm.Address;

  BaseColorPanel.Color := PlannerItem.Color;
  TrackColorPanel.Color := PlannerItem.TrackColor;
  SelectedColorPanel.Color := PlannerItem.SelectColor;
  SelectedFontColorPanel.Color := PlannerItem.SelectFontColor;

  FontPanel.Font := PlannerItem.Font;

  // First assign ImageList, because that will set the Min/Max values of the ImageUpDown
  ImageList := PlannerItem.Owner.PlannerImages;
  if Assigned(ImageList) then
  begin
    ImageUpDown.Position := PlannerItem.ImageID;
    ImageChanged;
  end;
end;

procedure TDefaultPlannerItemEditForm.AssignToPlannerItem(
  PlannerItem: TPlannerItem);
begin
  inherited;
  PlannerItem.CaptionText := SubjectEdit.Text;
  PlannerItem.ItemStartTime := PlanDate + StartTime;
  PlannerItem.ItemEndTime := PlanDate + EndTime;
  PlannerItem.ItemRealStartTime := PlanDate + StartTime;
  PlannerItem.ItemRealEndTime := PlanDate + EndTime;
  PlannerItem.RealTime := True;
  PlannerItem.Text := TStringList(NotesMemo.Lines);
  PlannerItem.Alignment := NotesMemo.Alignment;

  PlannerItem.Shape := TPlannerShape(ShapeComboBox.ItemIndex);
  PlannerItem.Flashing := FlashingCheckBox.Checked;

  PlannerItem.URL := UrlEdit.Text;

  PlannerItem.Alarm.Active := ReminderCheckBox.Checked;
  PlannerItem.Alarm.TimeBefore := ReminderTime;
  PlannerItem.Alarm.Message := ReminderMesssageEdit.Text;
  PlannerItem.Alarm.Address := ReminderAddressEdit.Text;

  PlannerItem.Color := BaseColorPanel.Color;
  PlannerItem.TrackColor := TrackColorPanel.Color;
  PlannerItem.SelectColor := SelectedColorPanel.Color;
  PlannerItem.SelectFontColor := SelectedFontColorPanel.Color;

  PlannerItem.Font := FontPanel.Font;

  if Assigned(ImageList) then
    PlannerItem.ImageID := ImageUpDown.Position;

  PlannerItem.Update;

end;

procedure TDefaultPlannerItemEditForm.BaseColorPanelClick(Sender: TObject);
begin
  if Sender is TPanel then
  begin
    ColorDialog.Color := (Sender as TPanel).Color;
    if ColorDialog.Execute then
      (Sender as TPanel).Color := ColorDialog.Color;
  end;
end;

procedure TDefaultPlannerItemEditForm.CheckInputValues(PlannerItem: TPlannerItem);
begin
  inherited;
  // three possible shapes: 1-psRect, 2-psRounded, 3-psHexagon
  Assert(ShapeComboBox.ItemIndex in [Ord(Low(PlannerItem.Shape))..Ord(High(PlannerItem.Shape))],
    'Shape index out of range');
end;

procedure TDefaultPlannerItemEditForm.CopyImageToSpeedButton(
  Index: Integer);
begin
  inherited;
  if Assigned(ImageList) and (Index >= 0) and (Index < ImageList.Count) then
  begin
    with ImageSpeedButton.Glyph do
    begin
      Width := ImageList.Width;
      Height := ImageList.Height;
      Canvas.Brush.Color := clFuchsia;//! for lack of a better color
      Canvas.FillRect(Rect(0,0, Width, Height));
      ImageList.Draw(Canvas, 0, 0, Index);
    end;
  end
  else // no ImageList or invalid Image
  begin
    ImageSpeedButton.Glyph := nil;
    //##jpl: To do - clear image of ImageSpeedButton
  end;
end;

procedure TDefaultPlannerItemEditForm.EditStateChanged;
begin
  inherited;
  if EditState = esNew then
  begin
    Caption := 'New appointment';
//      HTMLStaticText1.HTMLText.Add('  <IMG src="calendar">   <FONT face="Verdana">New appointment</FONT>');
  end
  else
  begin
    Caption := 'Edit appointment';
//      HTMLStaticText1.HTMLText.Add('  <IMG src="clock">   <FONT face="Verdana">Edit appointment</FONT>');
  end;
end;

procedure TDefaultPlannerItemEditForm.EndTimeDateTimePickerChange(
  Sender: TObject);
begin
  if EndTime < MinDuration then
    EndTime := MinDuration;
  if StartTime + MinDuration >= EndTime then
    StartTime := EndTime - MinDuration;

  ProcessWarnings;
end;

procedure TDefaultPlannerItemEditForm.FixEnabledComponents;
begin
  inherited;
  ReminderDateTimePicker.Enabled := ReminderCheckBox.Checked;
  ReminderMesssageEdit.Enabled := ReminderCheckBox.Checked;
  if Assigned(ImageList) then
  begin
    ImageSpeedButton.Enabled := True;
    ImageUpDown.Enabled := True;
    ImageUpDown.Min := -1; // -1 is none
    ImageUpDown.Max := ImageList.Count-1; // 0..Count-1 are images
  end
  else
  begin
    ImageSpeedButton.Enabled := False;
    ImageUpDown.Enabled := False;
    ImageUpDown.Min := 0;
    ImageUpDown.Max := 0;
  end;
end;

procedure TDefaultPlannerItemEditForm.FontButtonClick(Sender: TObject);
begin
  FontDialog.Font := FontPanel.Font;
  if FontDialog.Execute then
    FontPanel.Font := FontDialog.Font;
end;

procedure TDefaultPlannerItemEditForm.FormCreate(Sender: TObject);
const
  L_time_format = 'HH:mm:ss';    // 24-hour clock, hours, minutes & seconds
var
  fmt: string;
begin
  {$IFNDEF TMSDOTNET}
  fmt := L_time_format;
  SendMessage (ReminderDateTimePicker.Handle, DTM_SETFORMATA, 0, Integer(fmt));
  {$ENDIF}
end;


{$IFNDEF TMSDOTNET}
function TDefaultPlannerItemEditForm.GetEndTime: TTime;
begin
  Result := Frac(EndTimeDateTimePicker.Time); // only time-portion
end;
{$ENDIF}
{$IFDEF TMSDOTNET}
function TDefaultPlannerItemEditForm.GetEndTime: TDateTime;
begin
  Result := Frac(Double (TDateTime(EndTimeDateTimePicker.Time).Time)); // only time-portion
end;
{$ENDIF}

function TDefaultPlannerItemEditForm.GetPlanDate: TDateTime;
begin
  {$IFNDEF TMSDOTNET}
  Result := Trunc(PlanDateDateTimePicker.Date); // only date-portion
  {$ENDIF}
  {$IFDEF TMSDOTNET}
  Result := Trunc(Double(TDateTime(PlanDateDateTimePicker.Date).Date)); // only date-portion
  {$ENDIF}
end;
{$IFNDEF TMSDOTNET}
function TDefaultPlannerItemEditForm.GetReminderTime: TTime;
begin
  Result := Frac(ReminderDateTimePicker.Time); // only time-portion
end;
{$ENDIF}
{$IFDEF TMSDOTNET}
function TDefaultPlannerItemEditForm.GetReminderTime: TDateTime;
begin
  Result := Frac(Double(TdateTime(ReminderDateTimePicker.Time).Time)); // only time-portion
end;
{$ENDIF}

{$IFNDEF TMSDOTNET}
function TDefaultPlannerItemEditForm.GetStartTime: TTime;
begin
  Result := Frac(StartTimeDateTimePicker.Time); // only time-portion
end;
{$ENDIF}
{$IFDEF TMSDOTNET}
function TDefaultPlannerItemEditForm.GetStartTime: TDateTime;
begin
  Result := Frac(Double(TDateTime(StartTimeDateTimePicker.Time).Time)); // only time-portion
end;
{$ENDIF}

procedure TDefaultPlannerItemEditForm.ImageChanged;
begin
  CopyImageToSpeedButton(ImageUpDown.Position);
end;

procedure TDefaultPlannerItemEditForm.ImageUpDownClick(Sender: TObject;
  Button: TUDBtnType);
begin
  ImageChanged;
end;

procedure TDefaultPlannerItemEditForm.PlanDateDateTimePickerChange(
  Sender: TObject);
begin
  ProcessWarnings;
end;

procedure TDefaultPlannerItemEditForm.ProcessWarnings;
begin
  inherited;
  {$IFNDEF TMSDOTNET}
  if (PlanDateDateTimePicker.Date < Date) or
     ((PlanDateDateTimePicker.Date = Date) and (StartTimeDateTimePicker.Time < Time))
  {$ENDIF}
  {$IFDEF TMSDOTNET}
  if (TDateTime(PlanDateDateTimePicker.Date) < Date) or
     ((TDateTime(PlanDateDateTimePicker.Date) = Date) and (TDateTime(StartTimeDateTimePicker.Time) < Time))
  {$ENDIF}
  then
  begin
//  HTMLStaticText1.HTMLText.Clear;
//  HTMLStaticText1.HTMLText.Add('  <IMG src="caution">   <FONT face="Verdana">' +
//    'Warning: this appointment occurs in the past</FONT>');
    WarningPanel.Visible := True;
  end
  else
    WarningPanel.Visible := False;
end;

procedure TDefaultPlannerItemEditForm.ReminderCheckBoxClick(
  Sender: TObject);
begin
  FixEnabledComponents;
end;

{$IFNDEF TMSDOTNET}
procedure TDefaultPlannerItemEditForm.SetEndTime(const Value: TTime);
{$ENDIF}
{$IFDEF TMSDOTNET}
procedure TDefaultPlannerItemEditForm.SetEndTime(const Value: TDateTime);
{$ENDIF}
begin
  {$IFNDEF TMSDOTNET}
  //TDateTimePicker has a bug where Date=0 and Time=0 gives an error
  EndTimeDateTimePicker.Date := 1; // work around a bug
  EndTimeDateTimePicker.Time := Frac(Value); // time only
  {$ENDIF}
  {$IFDEF TMSDOTNET}
  //TDateTimePicker has a bug where Date=0 and Time=0 gives an error
  EndTimeDateTimePicker.Date := TDate.Create(1); // work around a bug
  EndTimeDateTimePicker.Time := TTime.Create(Frac(Double(Value.Time))); // time only
  {$ENDIF}
end;

procedure TDefaultPlannerItemEditForm.SetImageList(
  const Value: TImageList);
begin
  if Value <> FImageList then
  begin
    FImageList := Value;
    FixEnabledComponents;
  end;
end;

procedure TDefaultPlannerItemEditForm.SetPlanDate(const Value: TDateTime);
begin
  {$IFNDEF TMSDOTNET}
  PlanDateDateTimePicker.Date := Trunc(Value); // date only
  {$ENDIF}
  {$IFDEF TMSDOTNET}
  PlanDateDateTimePicker.Date := TDate.Create(Trunc(Value)); // date only
  {$ENDIF}
end;

{$IFNDEF TMSDOTNET}
procedure TDefaultPlannerItemEditForm.SetReminderTime(const Value: TTime);
begin
  // TDateTimePicker has a bug where Date=0 and Time=0 gives an error
  ReminderDateTimePicker.Date := 1; // work around a bug
  ReminderDateTimePicker.Time := Frac(Value); // only time-portion
end;
{$ENDIF}
{$IFDEF TMSDOTNET}
procedure TDefaultPlannerItemEditForm.SetReminderTime(const Value: TDateTime);
begin
  // TDateTimePicker has a bug where Date=0 and Time=0 gives an error
  ReminderDateTimePicker.Date := TDate.Create(1); // work around a bug
  ReminderDateTimePicker.Time := TTime.Create(Frac(Double(Value.Time))); // only time-portion
end;
{$ENDIF}

{$IFNDEF TMSDOTNET}
procedure TDefaultPlannerItemEditForm.SetStartTime(const Value: TTime);
begin
  // TDateTimePicker has a bug where Date=0 and Time=0 gives an error
  StartTimeDateTimePicker.Date := 1; // work around a bug
  StartTimeDateTimePicker.Time := Frac(Value); // time only
end;
{$ENDIF}
{$IFDEF TMSDOTNET}
procedure TDefaultPlannerItemEditForm.SetStartTime(const Value: TDateTime);
begin
  // TDateTimePicker has a bug where Date=0 and Time=0 gives an error
  StartTimeDateTimePicker.Date := TDate.Create(1); // work around a bug
  StartTimeDateTimePicker.Time := TTime.Create(Frac(Double(Value.Time))); // time only
end;
{$ENDIF}


procedure TDefaultPlannerItemEditForm.StartTimeDateTimePickerChange(
  Sender: TObject);
begin
  if StartTime > 1-MinDuration then
    StartTime := 1-MinDuration;
  if StartTime + MinDuration >= EndTime then
    EndTime := StartTime + MinDuration;

  ProcessWarnings;
end;

{ TDefaultItemEditor }

constructor TDefaultItemEditor.Create(AOwner: TComponent);
begin
  inherited;
  FCenter := True;
end;

procedure TDefaultItemEditor.CreateEditor(AOwner: TComponent);
begin
  inherited;

  FEditForm := TDefaultPlannerItemEditForm.Create(AOwner);
  FEditForm.Top := FFormTop;
  FEditForm.Left := FFormLeft;

  if CenterOnScreen then
    FEditForm.Position := poScreenCenter;
  FEditForm.Caption := Caption;  
end;

procedure TDefaultItemEditor.DestroyEditor;
begin
  ModalResult := FEditForm.ModalResult;
  inherited;
  FEditForm.Free;
end;

procedure TDefaultItemEditor.EditToPlannerItem(APlannerItem: TPlannerItem);
begin
  inherited;
  FEditForm.AssignToPlannerItem(APlannerItem);
end;

function TDefaultItemEditor.Execute: Integer;
begin
  Result := FEditForm.ShowModal;
end;

procedure TDefaultItemEditor.PlannerItemToEdit(APlannerItem: TPlannerItem);
begin
  inherited;
  FEditForm.AssignFromPlannerItem(APlannerItem);
end;

end.
