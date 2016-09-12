unit U_FrmHardwareGrab;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, bsSkinData, BusinessSkinForm, StdCtrls, Mask, bsSkinBoxCtrls;

type
  TFrm_HardwareGrab = class(TForm)
    skinstore: TbsCompressedStoredSkin;
    skinform: TbsBusinessSkinForm;
    skindata: TbsSkinData;
    Edit1: TEdit;
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Frm_HardwareGrab: TFrm_HardwareGrab;

implementation

{$R *.dfm}
uses
U_Hardwareid;

procedure TFrm_HardwareGrab.FormCreate(Sender: TObject);
begin
 edit1.Text := inttostr(GetHardwareid);
end;

end.
