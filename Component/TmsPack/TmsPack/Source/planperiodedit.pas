{$I TMSDEFS.INC}

{***********************************************************************}
{ TPlanner component                                                    }
{ for Delphi & C++Builder                                               }
{ version 2.1, July 2004                                                }
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

unit PlanPeriodEdit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms,
  Dialogs, Planner, StdCtrls, ExtCtrls, ComCtrls;

type
  TEditState = (esEdit, esNew);

type
  TPeriodPlannerItemEditForm = class(TForm)
    Label1: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    StartTime: TDateTimePicker;
    EndTime: TDateTimePicker;
    CBShape: TComboBox;
    PanelColor: TPanel;
    EdSubject: TEdit;
    Notes: TMemo;
    StartDate: TDateTimePicker;
    ColorDialog: TColorDialog;
    WarningPanel: TPanel;
    ButtonBottomPanel: TPanel;
    ButtonBottomRightPanel: TPanel;
    OKBtn: TButton;
    CancBtn: TButton;
    Panel1: TPanel;
    EndDate: TDateTimePicker;
    Label9: TLabel;
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

  TPeriodItemEditor = class(TCustomItemEditor)
  private
    FEditForm: TPeriodPlannerItemEditForm;
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

procedure TPeriodPlannerItemEditForm.EditModal(PlannerItem: TPlannerItem);
begin
  Assert(Assigned(PlannerItem), 'Must pass a non-nil planner item for editing');
  EditState := esEdit;
  InternalEditModal(PlannerItem);
end;

procedure TPeriodPlannerItemEditForm.InternalEditModal(
  PlannerItem: TPlannerItem);
begin
  AssignFromPlannerItem(PlannerItem);
  if (ShowModal = mrOK) then
    AssignToPlannerItem(PlannerItem);
end;

procedure TPeriodPlannerItemEditForm.SetEditState(
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

procedure TPeriodPlannerItemEditForm.PanelColorClick(Sender: TObject);
begin
  ColorDialog.Color := PanelColor.Color;
  if ColorDialog.Execute then
    PanelColor.Color := ColorDialog.Color;
end;

procedure TPeriodPlannerItemEditForm.AssignFromPlannerItem(
  PlannerItem: TPlannerItem);
begin
  EdSubject.Text := PlannerItem.CaptionText;
  {$IFNDEF TMSDOTNET}
  StartDate.Date := PlannerItem.ItemRealStartTime;
  StartTime.Time := PlannerItem.ItemRealStartTime;
  EndDate.Date := PlannerItem.ItemRealEndTime;
  EndTime.Time := PlannerItem.ItemRealEndTime;
  {$ENDIF}
  {$IFDEF TMSDOTNET}
  StartDate.Date := TDate(PlannerItem.ItemRealStartTime);
  StartTime.Time := TTime(PlannerItem.ItemRealStartTime);
  EndDate.Date := TDate(PlannerItem.ItemRealEndTime);
  EndTime.Time := TTime(PlannerItem.ItemRealEndTime);
  {$ENDIF}
  
  Notes.Lines := PlannerItem.Text;
  PanelColor.Color := PlannerItem.Color;
  CBShape.ItemIndex := Ord(PlannerItem.Shape);
  ProcessWarnings;
end;

procedure TPeriodPlannerItemEditForm.AssignToPlannerItem(
  PlannerItem: TPlannerItem);
begin
  PlannerItem.CaptionText := EdSubject.Text;

  with PlannerItem.ParentItem do
  begin
    {$IFNDEF TMSDOTNET}
    ItemStartTime := Int(StartDate.Date) + Frac(StartTime.Time);
    ItemEndTime := Int(EndDate.Date) + Frac(EndTime.Time);

    ItemRealStartTime := Int(StartDate.Date) + Frac(StartTime.Time);
    ItemRealEndTime := Int(EndDate.Date) + Frac(EndTime.Time);
    {$ENDIF}
    {$IFDEF TMSDOTNET}
    ItemStartTime := Int(Double(TDateTime(StartDate.Date))) + Frac(Double(TDateTime(StartTime.Time)));
    ItemEndTime := Int(Double(TDateTime(EndDate.Date))) + Frac(Double(TDateTime(EndTime.Time)));

    ItemRealStartTime := Int(Double(TDateTime(StartDate.Date))) + Frac(Double(TDateTime(StartTime.Time)));
    ItemRealEndTime := Int(Double(TDateTime(EndDate.Date))) + Frac(Double(TDateTime(EndTime.Time)));
    {$ENDIF}

    RealTime := True;

    Text := TStringList(Notes.Lines);

    Color := PanelColor.Color;

    Shape := TPlannerShape(CBShape.ItemIndex);
    Update;
  end;

end;

procedure TPeriodPlannerItemEditForm.ProcessWarnings;
begin
  {$IFNDEF TMSDOTNET}
  if (StartDate.Date < Date) or ((StartDate.Date = Date) and (StartTime.Time < Time)) then
  {$ENDIF}
  {$IFDEF TMSDOTNET}
  if (TDateTime(StartDate.Date) < Date) or ((TDateTime(StartDate.Date) = Date) and (TDateTime(StartTime.Time) < Time)) then
  {$ENDIF}
  begin
    WarningPanel.Visible := True;                     
  end
  else
    WarningPanel.Visible := False;
end;

{ TPeriodItemEditor }

constructor TPeriodItemEditor.Create(AOwner: TComponent);
begin
  inherited;
  FCenter := True;
end;

procedure TPeriodItemEditor.CreateEditor(AOwner: TComponent);
begin
  inherited;
  FEditForm := TPeriodPlannerItemEditForm.Create(AOwner);
  FEditForm.Top := FFormTop;
  FEditForm.Left := FFormLeft;

  if CenterOnScreen then
    FEditForm.Position := poScreenCenter;
  FEditForm.Caption := Caption;  
end;

procedure TPeriodItemEditor.DestroyEditor;
begin
  ModalResult := FEditForm.ModalResult;
  inherited;
  FEditForm.Free;
end;

procedure TPeriodItemEditor.EditToPlannerItem(APlannerItem: TPlannerItem);
begin
  inherited;
  FEditForm.AssignToPlannerItem(APlannerItem);
end;

function TPeriodItemEditor.Execute: Integer;
begin
  Result := FEditForm.ShowModal;
end;

procedure TPeriodItemEditor.PlannerItemToEdit(APlannerItem: TPlannerItem);
begin
  inherited;
  FEditForm.AssignFromPlannerItem(APlannerItem);
end;

end.
