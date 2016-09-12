unit U_FrmProxy;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, AdvCombo, AdvSmoothButton, Mask, bsSkinBoxCtrls,
  AdvSmoothLabel, ExtCtrls;

type
  TFrm_Proxy = class(TForm)
    Panel1: TPanel;
    FE_Ok: TAdvSmoothButton;
    FE_Cancel: TAdvSmoothButton;
    edit_proxytype: TAdvComboBox;
    AdvSmoothLabel4: TAdvSmoothLabel;
    AdvSmoothLabel3: TAdvSmoothLabel;
    edit_proxypass: TbsSkinEdit;
    AdvSmoothLabel1: TAdvSmoothLabel;
    edit_proxyname: TbsSkinEdit;
    AdvSmoothLabel5: TAdvSmoothLabel;
    edit_port: TbsSkinEdit;
    AdvSmoothLabel2: TAdvSmoothLabel;
    edit_proxyhost: TbsSkinEdit;
    procedure FE_CancelClick(Sender: TObject);
    procedure FE_OkClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
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

procedure TFrm_Proxy.FormCreate(Sender: TObject);
begin
  edit_proxyhost.Text := settings.proxy.host;
  edit_proxyname.Text := settings.proxy.user;
  edit_proxypass.Text := settings.proxy.pass;
  edit_proxytype.ItemIndex := settings.proxy.ptype;
  edit_port.Text := inttostr(settings.Proxy.Port);
end;

end.

