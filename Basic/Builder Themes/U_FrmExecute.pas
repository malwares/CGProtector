unit U_FrmExecute;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, bsSkinCtrls, bsSkinBoxCtrls, StdCtrls, Mask, BusinessSkinForm,
  U_FrmMain, se_form;

type
  TFrm_Execute = class(TForm)
    bsBusinessSkinForm1: TbsBusinessSkinForm;
    FE_Panel: TbsSkinExPanel;
    FE_Label1: TbsSkinStdLabel;
    FE_EditPath: TbsSkinComboBox;
    FE_Label2: TbsSkinStdLabel;
    FE_EditName: TbsSkinEdit;
    FE_Ok: TbsSkinButton;
    FE_Cancel: TbsSkinButton;
    FB_AnimeForm: TseAnimationForm;
    procedure FE_PanelClose(Sender: TObject);
    procedure FE_EditPathChange(Sender: TObject);
    procedure FE_OkClick(Sender: TObject);
    procedure FE_CancelClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Frm_Execute: TFrm_Execute;

implementation

{$R *.dfm}
uses
U_Type;

procedure TFrm_Execute.FE_CancelClick(Sender: TObject);
begin
  Frm_Execute.Close;
end;

procedure TFrm_Execute.FE_EditPathChange(Sender: TObject);
begin
  if FE_EditPath.ItemIndex = 0 then
  begin
    FE_Label2.Enabled := false;
    FE_EditName.Text := '';
    FE_EditName.Enabled := false;
  end else
  begin
    FE_Label2.Enabled := true;
    FE_EditName.Enabled := true;
  end;
end;

procedure TFrm_Execute.FE_OkClick(Sender: TObject);
begin
  Settings.Execute.index := FE_EditPath.ItemIndex;
  Settings.Execute.Filename := FE_EditName.Text;
  Frm_Execute.Close;
end;

procedure TFrm_Execute.FE_PanelClose(Sender: TObject);
begin
  Frm_Execute.Close;
end;

procedure TFrm_Execute.FormCreate(Sender: TObject);
begin
  FE_EditPath.ItemIndex := Settings.Execute.index;
  FE_EditName.Text := Settings.Execute.Filename;
  if FE_EditPath.ItemIndex = 0 then
  begin
    FE_Label2.Enabled := false;
    FE_EditName.Text := '';
    FE_EditName.Enabled := false;
  end;
end;

end.
