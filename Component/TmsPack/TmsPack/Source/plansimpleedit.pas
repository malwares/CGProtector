{***********************************************************************}
{ TPlanner component                                                    }
{ for Delphi & C++Builder                                               }
{ version 2.1                                                           }
{                                                                       }
{ written by TMS Software                                               }
{            copyright © 1999-2009                                      }
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

unit PlanSimpleEdit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms,
  Dialogs, Planner, StdCtrls, ExtCtrls, ComCtrls;

type
  TEditState = (esEdit, esNew);

type
  TSimplePlannerItemEditForm = class(TForm)
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    StartTime: TDateTimePicker;
    EndTime: TDateTimePicker;
    CBShape: TComboBox;
    PanelColor: TPanel;
    EdSubject: TEdit;
    Notes: TMemo;
    PlanDate: TDateTimePicker;
    ColorDialog: TColorDialog;
    WarningPanel: TPanel;
    ButtonBottomPanel: TPanel;
    ButtonBottomRightPanel: TPanel;
    OKBtn: TButton;
    CancBtn: TButton;
    Panel1: TPanel;
    procedure PanelColorClick(Sender: TObject);
  private
    FEditState: TEditState;
  protected
    procedure AssignFromPlannerItem(PlannerItem: TPlannerItem); virtual;
    procedure AssignToPlannerItem(PlannerItem: TPlannerItem); virtual;
    procedure InternalEditModal(PlannerItem: TPlannerItem); virtual;
    procedure ProcessWarnings; virtual;
    procedure SetEditState(const Value: TEditState); virtual;
  public
    procedure EditModal(PlannerItem: TPlannerItem); virtual;
    property EditState: TEditState read FEditState write SetEditState;
  end;

  TSimpleItemEditor = class(TCustomItemEditor)
  private
    FEditForm: TSimplePlannerItemEditForm;
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


implementation

{$R *.dfm}


{ TDefaultPlannerItemEditForm }

procedure TSimplePlannerItemEditForm.EditModal(PlannerItem: TPlannerItem);
begin
  Assert(Assigned(PlannerItem), 'Must pass a non-nil planner item for editing');
  EditState := esEdit;
  InternalEditModal(PlannerItem);
end;

procedure TSimplePlannerItemEditForm.InternalEditModal(
  PlannerItem: TPlannerItem);
begin
  AssignFromPlannerItem(PlannerItem);
  if (ShowModal = mrOK) then
    AssignToPlannerItem(PlannerItem);
end;

procedure TSimplePlannerItemEditForm.SetEditState(
  const Value: TEditState);
begin
  if Value <> EditState then
  begin
    FEditState := Value;
    if Value = esNew then
    begin
      Caption := 'New appointment';
    end
    else
    begin
      Caption := 'Edit appointment';
    end;
  end;
end;

procedure TSimplePlannerItemEditForm.PanelColorClick(Sender: TObject);
begin
  ColorDialog.Color := PanelColor.Color;
  if ColorDialog.Execute then
    PanelColor.Color := ColorDialog.Color;
end;

procedure TSimplePlannerItemEditForm.AssignFromPlannerItem(
  PlannerItem: TPlannerItem);
begin
  EdSubject.Text := PlannerItem.CaptionText;

  {$IFNDEF TMSDOTNET}
  if PlannerItem.RealTime then
  begin
    PlanDate.Date := PlannerItem.ItemRealStartTime;
    StartTime.Time := PlannerItem.ItemRealStartTime;
    EndTime.Time := PlannerItem.ItemRealEndTime;
  end
  else
  begin
    PlanDate.Date := PlannerItem.ItemStartTime;
    StartTime.Time := PlannerItem.ItemStartTime;
    EndTime.Time := PlannerItem.ItemEndTime;
  end;
  {$ENDIF}
  {$IFDEF TMSDOTNET}
  if PlannerItem.RealTime then
  begin
    PlanDate.Date := TDate(PlannerItem.ItemRealStartTime);
    StartTime.Time := TTime(PlannerItem.ItemRealStartTime);
    EndTime.Time := TTime(PlannerItem.ItemRealEndTime);
  end
  else
  begin
    PlanDate.Date := TDate(PlannerItem.ItemStartTime);
    StartTime.Time := TTime(PlannerItem.ItemStartTime);
    EndTime.Time := TTime(PlannerItem.ItemEndTime);
  end;
  {$ENDIF}
    
  Notes.Lines := PlannerItem.Text;
  PanelColor.Color       := PlannerItem.Color;
  CBShape.ItemIndex      := Ord(PlannerItem.Shape);
  ProcessWarnings;
end;

procedure TSimplePlannerItemEditForm.AssignToPlannerItem(
  PlannerItem: TPlannerItem);
begin
  PlannerItem.CaptionText := EdSubject.Text;

  {$IFNDEF TMSDOTNET}
  PlannerItem.ItemStartTime := Int(PlanDate.Date) + Frac(StartTime.Time);
  PlannerItem.ItemEndTime := Int(PlanDate.Date) + Frac(EndTime.Time);

  PlannerItem.ItemRealStartTime := Int(PlanDate.Date) + Frac(StartTime.Time);
  PlannerItem.ItemRealEndTime := Int(PlanDate.Date) + Frac(EndTime.Time);
  {$ENDIF}
  
  {$IFDEF TMSDOTNET}
//  PlannerItem.ItemStartTime := Int(Double(PlanDate.Date)) + Frac(Double(StartTime.Time));
  PlannerItem.ItemStartTime := Int(Double(TDateTime(PlanDate.Date))) + Frac(Double(TDateTime(StartTime.Time)));
  PlannerItem.ItemEndTime := Int(Double(TDateTime(PlanDate.Date))) + Frac(Double(TDateTime(EndTime.Time)));

  PlannerItem.ItemRealStartTime := Int(Double(TDateTime(PlanDate.Date))) + Frac(Double(TDateTime(StartTime.Time)));
  PlannerItem.ItemRealEndTime := Int(Double(TDateTime(PlanDate.Date))) + Frac(Double(TDateTime(EndTime.Time)));
  {$ENDIF}
  PlannerItem.RealTime := True;

  PlannerItem.Text := TStringList(Notes.Lines);

  // PlannerItem.ImageID := ImagePicker.ItemIndex;
  PlannerItem.Color := PanelColor.Color;

  // three possible shapes: 1-psRect, 2-psRounded, 3-psHexagon
  Assert(CBShape.ItemIndex in [Ord(Low(PlannerItem.Shape))..Ord(High(PlannerItem.Shape))],
    'Shape index out of range');
  PlannerItem.Shape := TPlannerShape(CBShape.ItemIndex);

  PlannerItem.Update;
end;

procedure TSimplePlannerItemEditForm.ProcessWarnings;
begin
  {$IFNDEF TMSDOTNET}
  if (PlanDate.Date < Date) or ((PlanDate.Date = Date) and (StartTime.Time < Time)) then
  {$ENDIF}
  {$IFDEF TMSDOTNET}
  if (TDateTime(PlanDate.Date) < Date) or ((TDateTime(PlanDate.Date) = Date) and (TDateTime(StartTime.Time) < Time)) then
  {$ENDIF}
  begin
    WarningPanel.Visible := True;
  end
  else
    WarningPanel.Visible := False;
end;

{ TSimpleItemEditor }

constructor TSimpleItemEditor.Create(AOwner: TComponent);
begin
  inherited;
  FCenter := True;
end;

procedure TSimpleItemEditor.CreateEditor(AOwner: TComponent);
begin
  inherited;
  FEditForm := TSimplePlannerItemEditForm.Create(AOwner);
  FEditForm.Top := FFormTop;
  FEditForm.Left := FFormLeft;

  if CenterOnScreen then
    FEditForm.Position := poScreenCenter;
  FEditForm.Caption := Caption;  
end;

procedure TSimpleItemEditor.DestroyEditor;
begin
  inherited;
  FEditForm.Free;
end;

procedure TSimpleItemEditor.EditToPlannerItem(APlannerItem: TPlannerItem);
begin
  inherited;
  FEditForm.AssignToPlannerItem(APlannerItem);
end;

function TSimpleItemEditor.Execute: Integer;
begin
  Result := FEditForm.ShowModal;
end;

procedure TSimpleItemEditor.PlannerItemToEdit(APlannerItem: TPlannerItem);
begin
  inherited;
  FEditForm.AssignFromPlannerItem(APlannerItem);
end;

end.
