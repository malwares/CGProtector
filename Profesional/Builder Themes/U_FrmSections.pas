unit U_FrmSections;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs,U_FrmMain, bsSkinCtrls, StdCtrls, Mask, bsSkinBoxCtrls,
  BusinessSkinForm, se_form;

type
  TFrm_Sections = class(TForm)
    bsBusinessSkinForm1: TbsBusinessSkinForm;
    FS_Panel: TbsSkinExPanel;
    Label12: TbsSkinStdLabel;
    FS_SName: TbsSkinEdit;
    Label11: TbsSkinStdLabel;
    Check_Sect1: TbsSkinCheckRadioBox;
    Check_Sect2: TbsSkinCheckRadioBox;
    Check_Sect3: TbsSkinCheckRadioBox;
    Check_Sect4: TbsSkinCheckRadioBox;
    FE_Ok: TbsSkinButton;
    FE_Cancel: TbsSkinButton;
    FB_AnimeForm: TseAnimationForm;
    procedure FS_PanelClick(Sender: TObject);
    procedure FE_OkClick(Sender: TObject);
    procedure FE_CancelClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Frm_Sections: TFrm_Sections;

implementation

{$R *.dfm}
uses
U_Type;

procedure TFrm_Sections.FE_CancelClick(Sender: TObject);
begin
  Close;
end;

procedure TFrm_Sections.FE_OkClick(Sender: TObject);
begin
  settings.Section.SName := FS_SName.Text;
  settings.Section.Check1 := Check_Sect1.Checked;
  settings.Section.Check2 := Check_Sect2.Checked;
  settings.Section.Check3 := Check_Sect3.Checked;
  settings.Section.Check4 := Check_Sect4.Checked;
  Close;
end;

procedure TFrm_Sections.FS_PanelClick(Sender: TObject);
begin
  Close;
end;

end.
