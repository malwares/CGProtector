unit U_Frm_Proxy;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, bsSkinBoxCtrls, StdCtrls, Mask, se_form, BusinessSkinForm,
  bsSkinCtrls;

type
  TFrm_Proxy = class(TForm)
    FE_Panel: TbsSkinExPanel;
    FE_Label1: TbsSkinStdLabel;
    FE_Ok: TbsSkinButton;
    FE_Cancel: TbsSkinButton;
    bsBusinessSkinForm1: TbsBusinessSkinForm;
    FB_AnimeForm: TseAnimationForm;
    edit_proxyhost: TbsSkinEdit;
    bsSkinStdLabel1: TbsSkinStdLabel;
    edit_port: TbsSkinEdit;
    bsSkinStdLabel2: TbsSkinStdLabel;
    edit_proxyname: TbsSkinEdit;
    bsSkinStdLabel3: TbsSkinStdLabel;
    edit_proxypass: TbsSkinEdit;
    bsSkinStdLabel4: TbsSkinStdLabel;
    edit_proxytype: TbsSkinComboBox;
    procedure FE_PanelClose(Sender: TObject);
    procedure FE_CancelClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FE_OkClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Frm_Proxy: TFrm_Proxy;

implementation

{$R *.dfm}
uses
U_Type;

procedure TFrm_Proxy.FE_CancelClick(Sender: TObject);
begin
  close;
end;

procedure TFrm_Proxy.FE_OkClick(Sender: TObject);
begin
  settings.proxy.host := edit_proxyhost.Text;
  settings.proxy.user := edit_proxyname.Text;
  settings.proxy.pass := edit_proxypass.Text;
  settings.Proxy.Port := strtoint(edit_port.Text);
  settings.proxy.ptype := edit_proxytype.ItemIndex;
  Close;
end;

procedure TFrm_Proxy.FE_PanelClose(Sender: TObject);
begin
  close;
end;

procedure TFrm_Proxy.FormCreate(Sender: TObject);
begin
  edit_proxyhost.Text := settings.proxy.host;
  edit_proxyname.Text := settings.proxy.user;
  edit_proxypass.Text := settings.proxy.pass;
  edit_proxytype.ItemIndex := settings.proxy.ptype;
  edit_port.Text := inttostr(settings.Proxy.Port);
end;

end.
