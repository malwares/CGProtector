unit U_FrmResource;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, BusinessSkinForm, se_form, bsSkinCtrls,U_FrmMain, bsSkinBoxCtrls,
  StdCtrls, Mask;

type
  TFrm_Resource = class(TForm)
    FR_Panel: TbsSkinExPanel;
    bsBusinessSkinForm1: TbsBusinessSkinForm;
    Label9: TbsSkinStdLabel;
    FR_Type: TbsSkinComboBox;
    Label10: TbsSkinStdLabel;
    FR_Name: TbsSkinEdit;
    SCount: TbsSkinStdLabel;
    FR_Split: TbsSkinNumericEdit;
    FE_Ok: TbsSkinButton;
    FE_Cancel: TbsSkinButton;
    FB_AnimeForm: TseAnimationForm;
    procedure FR_PanelClose(Sender: TObject);
    procedure FE_OkClick(Sender: TObject);
    procedure FE_CancelClick(Sender: TObject);
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
U_Utils,U_Type;

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

procedure TFrm_Resource.FR_PanelClose(Sender: TObject);
begin
  close;
end;

end.
