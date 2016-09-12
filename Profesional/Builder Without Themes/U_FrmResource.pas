unit U_FrmResource;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, bsSkinBoxCtrls, AdvSmoothButton, StdCtrls, Mask, AdvCombo,
  AdvSmoothLabel, ExtCtrls;

type
  TFrm_Resource = class(TForm)
    Panel1: TPanel;
    AdvSmoothLabel3: TAdvSmoothLabel;
    AdvSmoothLabel2: TAdvSmoothLabel;
    FR_Type: TAdvComboBox;
    FR_Name: TbsSkinEdit;
    FE_Ok: TAdvSmoothButton;
    FE_Cancel: TAdvSmoothButton;
    AdvSmoothLabel1: TAdvSmoothLabel;
    FR_Split: TbsSkinNumericEdit;
    procedure FE_CancelClick(Sender: TObject);
    procedure FE_OkClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Frm_Resource: TFrm_Resource;

implementation

{$R *.dfm}
uses
U_Type,U_Utils;

procedure TFrm_Resource.FE_CancelClick(Sender: TObject);
begin
  close;
end;

procedure TFrm_Resource.FE_OkClick(Sender: TObject);
begin
  Settings.Resource.RType := ConvertToResType(FR_Type.Text);
  Settings.Resource.RName := FR_Name.text;
  Settings.Resource.RSplit := Trunc(FR_Split.value);
  close;
end;

end.
