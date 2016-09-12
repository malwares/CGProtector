unit U_FrmExecute;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, AdvSmoothButton, StdCtrls, Mask, bsSkinBoxCtrls, AdvCombo,
  AdvSmoothLabel, ExtCtrls;

type
  TFrm_Execute = class(TForm)
    Panel1: TPanel;
    AdvSmoothLabel3: TAdvSmoothLabel;
    FE_EditPath: TAdvComboBox;
    AdvSmoothLabel2: TAdvSmoothLabel;
    FE_EditName: TbsSkinEdit;
    FE_Ok: TAdvSmoothButton;
    FE_Cancel: TAdvSmoothButton;
    procedure FE_CancelClick(Sender: TObject);
    procedure FE_EditPathChange(Sender: TObject);
    procedure FE_OkClick(Sender: TObject);
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
    FE_EditName.Text := '';
    FE_EditName.Enabled := false;
  end else
  begin
    FE_EditName.Enabled := true;
  end;
end;

procedure TFrm_Execute.FE_OkClick(Sender: TObject);
begin
  Settings.Execute.index := FE_EditPath.ItemIndex;
  Settings.Execute.Filename := FE_EditName.Text;
  Frm_Execute.Close;
end;

procedure TFrm_Execute.FormCreate(Sender: TObject);
begin
  FE_EditPath.ItemIndex := Settings.Execute.index;
  FE_EditName.Text := Settings.Execute.Filename;
  if FE_EditPath.ItemIndex = 0 then
  begin
    FE_EditName.Text := '';
    FE_EditName.Enabled := false;
  end;
end;

end.
