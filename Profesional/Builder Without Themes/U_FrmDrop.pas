unit U_FrmDrop;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, AdvSmoothButton, Mask, bsSkinBoxCtrls, AdvCombo,
  AdvSmoothLabel, ExtCtrls;

type
  TFrm_Drop = class(TForm)
    Panel1: TPanel;
    AdvSmoothLabel3: TAdvSmoothLabel;
    AdvSmoothLabel2: TAdvSmoothLabel;
    FD_EditPath: TAdvComboBox;
    FD_EditName: TbsSkinEdit;
    FE_Ok: TAdvSmoothButton;
    FE_Cancel: TAdvSmoothButton;
    AdvSmoothLabel6: TAdvSmoothLabel;
    FD_check1: TCheckBox;
    FD_check2: TCheckBox;
    procedure FE_OkClick(Sender: TObject);
    procedure FE_CancelClick(Sender: TObject);
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



procedure TFrm_Drop.FE_CancelClick(Sender: TObject);
begin
  close;
end;

procedure TFrm_Drop.FE_OkClick(Sender: TObject);
begin
  Settings.Drop.index := FD_EditPath.ItemIndex;
  Settings.Drop.Filename := FD_EditName.Text;
  Settings.Drop.Hidden := FD_check1.Checked;
  Settings.Drop.system := FD_check2.Checked;
  Close;
end;

procedure TFrm_Drop.FormCreate(Sender: TObject);
begin
  FD_EditPath.ItemIndex := Settings.Drop.index;
  FD_EditName.Text := Settings.Drop.Filename;
  FD_check1.Checked := Settings.Drop.Hidden;
  FD_check2.Checked := Settings.Drop.system;
end;

end.
