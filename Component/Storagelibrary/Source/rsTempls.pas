{*******************************************************}
{                                                       }
{                Delphi VCL Extensions                  }
{                   Storage library                     }
{                                                       }
{         Copyright (c) 2000-2007 Deepsoftware          }
{                                                       }
{           www - http://www.deepsoftware.com           }
{              email - ray@deepsoftware.com             }
{                                                       }
{*******************************************************}
unit rsTempls;

interface

{$I rsStorage.inc}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ExtCtrls, ComCtrls, ToolWin, rsConst, StdCtrls,
  {$IFNDEF RSL_CB3LE} ImgList, {$ENDIF}
  Menus;

type
  TrsTemplStates = set of (tsEditing,tsAppending);

  TrsFormTempl = class(TForm)
    tbrMain: TToolBar;
    pnlLeft: TPanel;
    Splitter1: TSplitter;
    pnlRight: TPanel;
    Label1: TLabel;
    lvNames: TListView;
    Label2: TLabel;
    lvProps: TListView;
    pmButtonCaptions: TPopupMenu;
    miTextLabels: TMenuItem;
    ilToolbar: TImageList;
    tbAdd: TToolButton;
    tbDel: TToolButton;
    tbRename: TToolButton;
    tbSeparator2: TToolButton;
    tbTImport: TToolButton;
    tbTExport: TToolButton;
    tbSeparator1: TToolButton;
    OpenDialog: TOpenDialog;
    SaveDialog: TSaveDialog;
    tbPUp: TToolButton;
    tbPDown: TToolButton;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure miTextLabelsClick(Sender: TObject);
    procedure pmButtonCaptionsPopup(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure tbTExportClick(Sender: TObject);
    procedure tbTImportClick(Sender: TObject);
    procedure lvNamesChange(Sender: TObject; Item: TListItem; Change: TItemChange);
    procedure lvPropsChange(Sender: TObject; Item: TListItem; Change: TItemChange);
    procedure tbRenameClick(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure tbAddClick(Sender: TObject);
    procedure tbDelClick(Sender: TObject);
    procedure lvNamesEditing(Sender: TObject; Item: TListItem; var AllowEdit: Boolean);
    procedure lvNamesEdited(Sender: TObject; Item: TListItem; var S: String);
    procedure tbPUpClick(Sender: TObject);
    procedure tbPDownClick(Sender: TObject);
    procedure lvPropsKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure lvPropsEditing(Sender: TObject; Item: TListItem; var AllowEdit: Boolean);
    procedure lvPropsEdited(Sender: TObject; Item: TListItem; var S: String);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormResize(Sender: TObject);
  private
    StartTemplates: string;
    PropStates: TrsTemplStates;
    TemplStates: TrsTemplStates;
    FTemplates: TStringList;
    procedure FormStateLoad;
    procedure FormStateSave;
    procedure SetTemplates(const Value: TStringList);
    procedure LVNamesLoad;
    procedure RefreshToolBar;
    procedure RefreshLVProps;
    function ActiveListView: TListView;

    function  TemplateFind(const Value: string): integer;
    function  PropFind(const Template,Value: string): integer;
    procedure TemplateDelete(const Value: string);
    procedure PropDelete(const Template,Value: string);
    function  PropAdd(const Template,Value: string): integer;
  public
    property Templates: TStringList read FTemplates write SetTemplates;
  end;

var
  rsFormTempl: TrsFormTempl;

implementation


{$R *.DFM}

{ TrsFormTempl }

procedure TrsFormTempl.FormStateLoad;
var
  Key: HKey;
  vLeft,vTop,vWidth,vHeight: integer;

   function RegReadInteger(Const ValueName: PChar; DefValue: integer): integer;
   var
     Value: integer;
     DataSize: longint;
   begin
     DataSize := SizeOf(Value);
     if RegQueryValueEx(Key, ValueName, nil,  nil, @Value, @DataSize)=ERROR_SUCCESS
      then Result := Value
      else Result := DefValue;
   end;

   procedure SetDefaultPosition;
   begin
     Width := tbSeparator1.Width*2 + tbTImport.Width*7 + 14;
     pnlLeft.Width := (ClientWidth - Splitter1.Width-12) div 2;
     Position := poScreenCenter;
   end;

begin
if RegOpenKeyEx(HKEY_CURRENT_USER, SRSProductKey, 0, KEY_READ, Key) <> ERROR_SUCCESS
 then SetDefaultPosition
 else
   try
     vLeft := RegReadInteger('TemplLeft', -1);
     vTop  := RegReadInteger('TemplTop', -1);
     vWidth := RegReadInteger('TemplWidth', -1);
     vHeight := RegReadInteger('TemplHeight', -1);
     if (vLeft>=0) and (vTop>=0) and (vWidth>0) and (vHeight>0) then begin
        Position := poDesigned;
        SetBounds(vLeft, vTop, vWidth, vHeight);
     end else SetDefaultPosition;

     pnlLeft.Width := RegReadInteger('TemplSplitter', lvNames.Width);
     if RegReadInteger('TemplButtonCaption', 1)=0 then miTextLabels.Click;

   finally
     RegCloseKey(Key);
   end;
end;

procedure TrsFormTempl.FormStateSave;
var
  Key: HKey;
  Value: longint;
begin
  if RegCreateKeyEx(HKEY_CURRENT_USER, SRSProductKey, 0, nil, REG_OPTION_NON_VOLATILE, KEY_WRITE, nil, Key, nil) = ERROR_SUCCESS then
   try
     Value := Left;
     RegSetValueEx(Key, 'TemplLeft', 0, REG_DWORD, @Value, SizeOf(Value));
     Value := Top;
     RegSetValueEx(Key, 'TemplTop', 0, REG_DWORD, @Value, SizeOf(Value));
     Value := Width;
     RegSetValueEx(Key, 'TemplWidth', 0, REG_DWORD, @Value, SizeOf(Value));
     Value := Height;
     RegSetValueEx(Key, 'TemplHeight', 0, REG_DWORD, @Value, SizeOf(Value));
     Value := pnlLeft.Width;
     RegSetValueEx(Key, 'TemplSplitter', 0, REG_DWORD, @Value, SizeOf(Value));
     Value := Integer(tbrMain.ShowCaptions);
     RegSetValueEx(Key, 'TemplButtonCaption', 0, REG_DWORD, @Value, SizeOf(Value));
   finally
     RegCloseKey(Key);
   end;
end;

procedure TrsFormTempl.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  FormStateSave;
end;

procedure TrsFormTempl.FormCreate(Sender: TObject);
begin
{$IFDEF RSL_D3}
  ilToolbar.Clear;
  if ModuleIsPackage then ilToolbar.ResInstLoad(Hinstance, rtBitmap, 'RSL_TEMPLATES', clAqua)
   else ilToolbar.ResourceLoad(rtBitmap, 'RSL_TEMPLATES', clAqua);
{$ENDIF}
  FTemplates := TStringList.Create;
  FormStateLoad;
end;

procedure TrsFormTempl.miTextLabelsClick(Sender: TObject);
begin
  tbrMain.ShowCaptions := not tbrMain.ShowCaptions;
  if tbrMain.ShowCaptions then begin
  end else begin
    tbrMain.ButtonHeight := 23;
    tbrMain.ButtonWidth := 24;
  end;
{$IFDEF RSL_D3}
  Realign;
{$ENDIF}
end;

procedure TrsFormTempl.pmButtonCaptionsPopup(Sender: TObject);
begin
  miTextLabels.Checked := tbrMain.ShowCaptions;
end;

procedure TrsFormTempl.SetTemplates(const Value: TStringList);
begin
  FTemplates.Assign(Value);
end;

procedure TrsFormTempl.FormDestroy(Sender: TObject);
begin
  FTemplates.Free;
end;


procedure TrsFormTempl.LVNamesLoad;
var
  i: integer;
  s: string;
begin
  with lvNames,Items do begin
    BeginUpdate;
    Clear;
    for i:=0 to Templates.Count-1 do begin
      s := Templates[i];
      if (Length(s)>0) and (s[1]='[') and (s[Length(s)]=']')
       then Add.Caption := Copy(s, 2, Length(s)-2);
    end;
    EndUpdate;
  end;
end;


procedure TrsFormTempl.FormActivate(Sender: TObject);
begin
  StartTemplates := FTemplates.Text;
  LVNamesLoad;
  if lvNames.Items.Count>0 then begin
    ActiveControl := lvNames;
    lvNames.Selected := lvNames.Items[0];
    lvNames.Items[0].Focused := True;
  end;
end;

procedure TrsFormTempl.tbTExportClick(Sender: TObject);
begin
 if SaveDialog.Execute then
   Templates.SaveToFile(SaveDialog.FileName);
end;

procedure TrsFormTempl.tbTImportClick(Sender: TObject);
begin
  if OpenDialog.Execute then begin
    FTemplates.LoadFromFile(OpenDialog.FileName);
    FormActivate(Self);
  end;
end;

procedure TrsFormTempl.RefreshToolBar;
var
  fl: boolean;
  lv: TListView;
begin
  if (csDestroying in ComponentState) then Exit;
  tbTExport.Enabled := Length(Trim(FTemplates.Text))>0;

  lv := ActiveListView;

  fl := ActiveListView.Selected<>nil;
  tbDel.Enabled := fl;
  tbRename.Enabled := fl;

  tbPUp.Enabled := fl and (lv=lvProps) and (lvProps.Selected.Index>0);
  tbPDown.Enabled := fl and (lv=lvProps) and (lvProps.Selected.Index<(lvProps.Items.Count-1));
end;


procedure TrsFormTempl.RefreshLVProps;
var
  s: string;
  i: integer;
  li: TListItem;
begin
  if lvNames.Selected<>nil then begin
    i := TemplateFind(lvNames.Selected.Caption);
    with lvProps,Items do begin
      BeginUpdate;
      Clear;
      if i>=0 then begin
        Inc(i);
        While i<FTemplates.Count do begin
          s := FTemplates.Strings[i];
          if (s='') or ((Length(s)>1) and (s[1]='[') and (s[Length(s)]=']')) then break;
          li := Add;
          li.Caption := s;
          Inc(i);
        end;
      end;
      EndUpdate;
    end;
  end;
end;

procedure TrsFormTempl.lvNamesChange(Sender: TObject; Item: TListItem;
  Change: TItemChange);
begin
  RefreshLVProps;
  RefreshToolBar;
end;

procedure TrsFormTempl.lvPropsChange(Sender: TObject; Item: TListItem;
  Change: TItemChange);
begin
  RefreshToolBar;
end;

procedure TrsFormTempl.tbRenameClick(Sender: TObject);
var
  lv: TListView;
begin
  lv := ActiveListView;
  if lv<>nil then begin
    lv.Selected.Focused := True;
    lv.Selected.EditCaption;
  end;
end;

procedure TrsFormTempl.FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
var
  lv: TListView;
begin
  if (key=VK_ESCAPE) and (Shift=[]) then Close
   else begin
     lv := ActiveListView;
     if lv<>nil then begin
       if ((key=VK_F2) or (key=VK_RETURN)) and (Shift=[]) then begin
         if lv.Selected<>nil then lv.Selected.EditCaption;
       end else
       if (key=VK_DELETE) and (Shift=[]) then begin
         if tbDel.Enabled and (not lv.IsEditing) then tbDel.Click;
       end else
       if (key=VK_INSERT) and (Shift=[]) then begin
         if tbAdd.Enabled and (not lv.IsEditing) then tbAdd.Click;
       end else;
     end;
   end;
end;

function TrsFormTempl.ActiveListView: TListView;
begin
  if (ActiveControl<>nil) and (ActiveControl is TListView)
   then Result := TListView(ActiveControl)
   else Result := nil;
end;

procedure TrsFormTempl.tbAddClick(Sender: TObject);
var
  lv: TListView;
  li: TListItem;
begin
  lv := ActiveListView;
  if lv<>nil then begin
    if lv=lvNames then Include(TemplStates, tsAppending)
     else begin
       if lvNames.Selected=nil then Exit;
       Include(PropStates, tsAppending);
     end;
    li := lv.Items.Add;
    li.Caption := '--------';
    lv.Selected := li;
    li.Focused := True;
    li.EditCaption;
  end;
end;

procedure TrsFormTempl.tbDelClick(Sender: TObject);
var
  lv: TListView;
  s: string;
  i: integer;
begin
  lv := ActiveListView;
  if (lv<>nil) and (lv.Selected<>nil) then begin
    if lv=lvNames then s := Format('Delete "%s" template ?',[lv.Selected.Caption])
     else s := Format('Delete "%s" property ?',[lv.Selected.Caption]);

    if MessageDlg(s, mtConfirmation, [mbYes,mbNo], 0)=mrYes then begin
      i := lv.Selected.Index;
      if lv=lvNames then begin
        s := lv.Selected.Caption;
        lv.Selected.Delete;
        TemplateDelete(s);
      end else begin
        s := lv.Selected.Caption;
        lv.Selected.Delete;
        PropDelete(lvNames.Selected.Caption, s);
      end;
      if i>=lv.Items.Count then i := lv.Items.Count-1;
      if i>=0 then begin
        lv.Selected := lv.Items.Item[i];
        lv.Selected.Focused := true;
        if lv=lvNames then RefreshLVProps;
      end;
    end;

  end;
end;

procedure TrsFormTempl.TemplateDelete(const Value: string);
var
  s: string;
  i: integer;
begin
  i := TemplateFind(Value);
  if i>=0 then
   While i<FTemplates.Count do begin
     FTemplates.Delete(i);
     if i>=FTemplates.Count then Break;
     s := FTemplates.Strings[i];
     if (Length(s)=0) or ((Length(s)>1) and (s[1]='[') and (s[Length(s)]=']')) then Break;
   end;
end;


procedure TrsFormTempl.PropDelete(const Template,Value: string);
var
  i: integer;
begin
  i := PropFind(Template,Value);
  if i>=0 then FTemplates.Delete(i);
end;

function TrsFormTempl.TemplateFind(const Value: string): integer;
begin
  Result := FTemplates.IndexOf(Format('[%s]',[Value]));
end;


function TrsFormTempl.PropFind(const Template, Value: string): integer;
var
  s: string;
begin
  Result := TemplateFind(Template);
  if Result>=0 then begin
    Inc(Result);
    While Result<FTemplates.Count do begin
      s := FTemplates.Strings[Result];
      if CompareText(s, Value)=0 then  Exit;
      if (Length(s)=0) or ((Length(s)>1) and (s[1]='[') and (s[Length(s)]=']')) then break;
      Inc(Result);
    end;
    Result := -1;
  end;
end;


procedure TrsFormTempl.lvNamesEditing(Sender: TObject; Item: TListItem; var AllowEdit: Boolean);
begin
  Include(TemplStates, tsEditing);
end;

procedure TrsFormTempl.lvNamesEdited(Sender: TObject; Item: TListItem; var S: String);
var
  i: integer;
  flExist: boolean;
begin
  flExist := (S<>Item.Caption) and (TemplateFind(S)>=0);

  if tsAppending in TemplStates then begin
    if flExist then begin
      MessageDlg('Template with name "'+S+'" already exists.', mtInformation, [mbOk], 0);
      S := Item.Caption;
    end else begin
      FTemplates.Add('');
      FTemplates.Add(Format('[%s]',[S]));
    end;
    Exclude(TemplStates, tsAppending);
  end else begin
    i := TemplateFind(Item.Caption);
    if not flExist then begin
      if i<0 then begin
        FTemplates.Add('');
        FTemplates.Add(Format('[%s]',[S]));
      end else FTemplates.Strings[i] := Format('[%s]',[S])
    end else begin
      MessageDlg('Template with name "'+S+'" already exists.', mtInformation, [mbOk], 0);
      S := Item.Caption;
    end;
  end;
  Exclude(TemplStates, tsEditing);
end;


procedure TrsFormTempl.tbPUpClick(Sender: TObject);
var
  s: string;
  liSrc,liDest: TListItem;
  i: integer;
begin
  liSrc := lvProps.Selected;
  if (liSrc<>nil) and (liSrc.Index>0) then begin
    liDest := lvProps.Items[liSrc.Index-1];
    s := liDest.Caption;
    liDest.Caption := liSrc.Caption;
    liSrc.Caption := s;
    lvProps.Selected := liDest;
    liDest.Focused := True;
    i := PropFind(lvNames.Selected.Caption, s);
    FTemplates.Exchange(i, i+1);
  end;
end;

procedure TrsFormTempl.tbPDownClick(Sender: TObject);
var
  s: string;
  liSrc,liDest: TListItem;
  i: integer;
begin
  liSrc := lvProps.Selected;
  if (liSrc<>nil) and (liSrc.Index<(lvProps.Items.Count-1)) then begin
    liDest := lvProps.Items[liSrc.Index+1];
    s := liDest.Caption;
    liDest.Caption := liSrc.Caption;
    liSrc.Caption := s;
    lvProps.Selected := liDest;
    liDest.Focused := True;
    i := PropFind(lvNames.Selected.Caption, s);
    FTemplates.Exchange(i, i-1);
  end;
end;

procedure TrsFormTempl.lvPropsKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if (Key=VK_DOWN) and (Shift=[ssCtrl]) then begin
    if tbPDown.Enabled then begin
      tbPDown.Click;
      Key := 0;
    end;
  end else
  if (Key=VK_UP) and (Shift=[ssCtrl]) then begin
    if tbPUp.Enabled then begin
      tbPUp.Click;
      Key := 0;
    end;
  end;// else
end;

procedure TrsFormTempl.lvPropsEditing(Sender: TObject; Item: TListItem; var AllowEdit: Boolean);
begin
  AllowEdit := lvNames.Selected<>nil;
  Include(PropStates, tsEditing);
end;


procedure TrsFormTempl.lvPropsEdited(Sender: TObject; Item: TListItem; var S: String);
var
  i: integer;
  flExist: boolean;
begin
  flExist := (S<>Item.Caption) and (PropFind(lvNames.Selected.Caption, S)>=0);

  if tsAppending in PropStates then begin
    if flExist then begin
      MessageDlg('Property with name "'+S+'" already exists.', mtInformation, [mbOk], 0);
      S := Item.Caption;
    end else begin
      PropAdd(lvNames.Selected.Caption, S);
    end;
    Exclude(PropStates, tsAppending);
  end else begin
    i := PropFind(lvNames.Selected.Caption, Item.Caption);
    if not flExist then begin
      if i<0 then begin
        PropAdd(lvNames.Selected.Caption, S);
      end else FTemplates.Strings[i] := S;
    end else begin
      MessageDlg('Property with name "'+S+'" already exists.', mtInformation, [mbOk], 0);
      S := Item.Caption;
    end;
  end;
  Exclude(PropStates, tsEditing);
end;


function TrsFormTempl.PropAdd(const Template, Value: string): integer;
var
  s: string;
begin
  Result := TemplateFind(Template);
  if Result>=0 then begin
    Inc(Result);
    While Result<FTemplates.Count do begin
      s := FTemplates.Strings[Result];
      if (Length(s)=0) or ((Length(s)>1) and (s[1]='[') and (s[Length(s)]=']')) then begin
        FTemplates.Insert(Result, Value);
        Exit;
      end;
      Inc(Result);
    end;
    Result := FTemplates.Add(Value);
  end else begin
    FTemplates.Add('');
    FTemplates.Add(Format('[%s]',[Template]));
    Result := FTemplates.Add(Value);
  end;
end;


procedure TrsFormTempl.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  ModalResult := mrCancel;
  if StartTemplates<>FTemplates.Text then begin
    ModalResult := MessageDlg('Save changes in templates ?', mtConfirmation, [mbYes,mbNo,mbCancel], 0);
    CanClose := ModalResult<>mrCancel;
  end;
end;

procedure TrsFormTempl.FormResize(Sender: TObject);
begin
  lvNames.Columns[0].Width := lvNames.ClientWidth-GetSystemMetrics(SM_CXVSCROLL);
  lvProps.Columns[0].Width := lvProps.ClientWidth-GetSystemMetrics(SM_CXVSCROLL);
end;

end.
