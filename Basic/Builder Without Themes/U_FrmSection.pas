unit U_FrmSection;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, AdvSmoothButton, Mask, bsSkinBoxCtrls, AdvSmoothLabel,
  ExtCtrls;

type
  TFrm_Section = class(TForm)
    Panel1: TPanel;
    AdvSmoothLabel2: TAdvSmoothLabel;
    FS_SName: TbsSkinEdit;
    FE_Ok: TAdvSmoothButton;
    FE_Cancel: TAdvSmoothButton;
    AdvSmoothLabel1: TAdvSmoothLabel;
    Check_Sect1: TCheckBox;
    Check_Sect2: TCheckBox;
    Check_Sect3: TCheckBox;
    Check_Sect4: TCheckBox;
    procedure FE_CancelClick(Sender: TObject);
    procedure FE_OkClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Frm_Section: TFrm_Section;

implementation

{$R *.dfm}
uses
U_Type,U_Utils;


procedure TFrm_Section.FE_CancelClick(Sender: TObject);
begin
  Close;
end;

procedure TFrm_Section.FE_OkClick(Sender: TObject);
begin
  settings.Section.SName := FS_SName.Text;
  settings.Section.Check1 := Check_Sect1.Checked;
  settings.Section.Check2 := Check_Sect2.Checked;
  settings.Section.Check3 := Check_Sect3.Checked;
  settings.Section.Check4 := Check_Sect4.Checked;
  Close;
end;

end.
