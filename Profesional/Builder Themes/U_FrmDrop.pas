unit U_FrmDrop;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, U_FrmMain, bsSkinCtrls, bsSkinBoxCtrls, StdCtrls, Mask,
  BusinessSkinForm, se_form;

type
  TFrm_Drop = class(TForm)
    FD_Panel: TbsSkinExPanel;
    FD_Label2: TbsSkinStdLabel;
    FD_Label1: TbsSkinStdLabel;
    FD_Label3: TbsSkinStdLabel;
    FD_EditName: TbsSkinEdit;
    FD_EditPath: TbsSkinComboBox;
    FD_Ok: TbsSkinButton;
    FD_Cancel: TbsSkinButton;
    FD_check2: TbsSkinCheckRadioBox;
    FD_check1: TbsSkinCheckRadioBox;
    bsBusinessSkinForm1: TbsBusinessSkinForm;
    seAnimationForm1: TseAnimationForm;
    procedure FD_PanelClose(Sender: TObject);
    procedure FD_OkClick(Sender: TObject);
    procedure FD_CancelClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Frm_Drop: TFrm_Drop;

implementation

{$R *.dfm}
uses
U_Type;

procedure TFrm_Drop.FD_CancelClick(Sender: TObject);
begin
  close;
end;

procedure TFrm_Drop.FD_OkClick(Sender: TObject);
begin
  Settings.Drop.index := FD_EditPath.ItemIndex;
  Settings.Drop.Filename := FD_EditName.Text;
  Settings.Drop.Hidden := FD_check1.Checked;
  Settings.Drop.system := FD_check2.Checked;
  Close;
end;

procedure TFrm_Drop.FD_PanelClose(Sender: TObject);
begin
  close;
end;

procedure TFrm_Drop.FormCreate(Sender: TObject);
begin
  FD_EditPath.ItemIndex := Settings.Drop.index;
  FD_EditName.Text := Settings.Drop.Filename;
  FD_check1.Checked := Settings.Drop.Hidden;
  FD_check2.Checked := Settings.Drop.system;
end;

end.
