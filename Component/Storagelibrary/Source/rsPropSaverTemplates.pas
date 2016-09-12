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
unit rsPropSaverTemplates;

interface

{$I rsStorage.inc}

{$DEFINE RSL_DLGTEST}

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ImgList, Menus, ComCtrls, StdCtrls, ExtCtrls, ToolWin, IniFiles,
  {$IFNDEF RSL_DLGTEST}DeskUtil,{$ENDIF}
  rsConst;

type
  TPropSaverTemplatesStates = set of (tsEditing,tsAppending);

  TrsPropSaverTemplates = class
  private
    FItems: TStringList;
    FHeaderIndexes: array of integer;
    FPropsBeginIndexes: array of integer;
    FPropsEndIndexes: array of integer;
    FCurrentTemplateIndex: integer;

    function GetFileName: string;
    function GetProperties(index: integer): string;
    procedure SetCurrentTemplateIndex(const Value: integer);
    procedure SetProperties(index: integer; const Value: string);
    function IsTemplateHeader(const Value: string): boolean;
    function GetTemplateHeader(const Value: string): string;
    procedure IndexesRefresh;
    procedure FItemsPrepare;
    function GetTemplateName: string;
    procedure SetTemplateName(const Value: string);
    function GetAsText: string;
    procedure SetAsText(const Value: string);
  public
    constructor Create;
    destructor Destroy; override;

    procedure Assign(Source: TrsPropSaverTemplates);
    procedure Load;
    procedure LoadFromFile(const AFileName: string);
    procedure SaveToFile(const AFileName: string);
    procedure Save;

    function Count: integer;
    function IndexOf(const TemplateName: string): integer;
    function Add(const TemplateName: string): integer;
    procedure Delete(const TemplateIndex: integer);
    property CurrentTemplateIndex: integer read FCurrentTemplateIndex write SetCurrentTemplateIndex;
    property TemplateName: string read GetTemplateName write SetTemplateName;

    function PropertiesCount: integer;
    property Properties[index: integer]: string read GetProperties write SetProperties;
    function PropertiesAdd(const PropertyText: string): integer;
    procedure PropertiesDelete(const PropertyIndex: integer);
    procedure PropertiesClear;
    function IndexOfProperty(const PropertyText: string): integer;
    procedure PropertiesExchange(const PropertyIndex1, PropertyIndex2: integer);

    property AsText: string read GetAsText write SetAsText;
  end;

  TrsPropSaverTemplatesForm = class(TForm)
    Splitter1: TSplitter;
    tbr: TToolBar;
    tbTImport: TToolButton;
    tbTExport: TToolButton;
    tbAdd: TToolButton;
    tbDel: TToolButton;
    tbRename: TToolButton;
    tbSeparator2: TToolButton;
    tbPUp: TToolButton;
    tbPDown: TToolButton;
    pnlLeft: TPanel;
    Label1: TLabel;
    lvNames: TListView;
    pnlRight: TPanel;
    Label2: TLabel;
    lvProps: TListView;
    pmButtonCaptions: TPopupMenu;
    miTextLabels: TMenuItem;
    ilToolbar: TImageList;
    OpenDialog: TOpenDialog;
    SaveDialog: TSaveDialog;
    splVert: TSplitter;
    tbSeparator: TToolButton;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure miTextLabelsClick(Sender: TObject);
    procedure splVertMoved(Sender: TObject);
    procedure splVertCanResize(Sender: TObject; var NewSize: Integer; var Accept: Boolean);
    procedure pmButtonCaptionsPopup(Sender: TObject);
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
    procedure lvEnter(Sender: TObject);
  private
    FTemplates: TrsPropSaverTemplates;
    FStartTemplatesText: string;
    FLVPropsStates: TPropSaverTemplatesStates;
    FLVNamesStates: TPropSaverTemplatesStates;
    procedure SetTemplates(const Value: TrsPropSaverTemplates);

    function GetIniFile: TCustomIniFile;
    procedure FormStateLoad;
    procedure FormStateSave;


    procedure LVNamesLoad;

    procedure TBRRefresh;
    procedure TBRResizeButtons(Large: Boolean);
    procedure LVPropsRefresh;
    procedure PropDelete(const Template,Value: string);
    function  PropAdd(const Template,Value: string): integer;
    function  PropFind(const Template,Value: string): integer;

    procedure TemplateDelete(const Value: string);

    function ActiveListView: TListView;
  public
    property Templates: TrsPropSaverTemplates read FTemplates write SetTemplates;
  end;


implementation

{$R *.dfm}

const
  SmallToolbarSize = 30;
  SmallButtonHeight = 23;
  SmallButtonWidth = 32;
  LargeToolbarSize = 44;
  LargeButtonHeight = 39;
  LargeButtonWidth = 53;

{ TrsPropSaverTemplatesForm }

procedure TrsPropSaverTemplatesForm.SetTemplates(const Value: TrsPropSaverTemplates);
begin
  FTemplates.Assign(Value);
end;

procedure TrsPropSaverTemplatesForm.FormCreate(Sender: TObject);
begin
  FTemplates := TrsPropSaverTemplates.Create;
  FormStateLoad;
end;

procedure TrsPropSaverTemplatesForm.FormDestroy(Sender: TObject);
begin
  FTemplates.Free;
end;

procedure TrsPropSaverTemplatesForm.FormStateLoad;
var
  vLeft,vTop,vWidth,vHeight: integer;

   procedure SetDefaultPosition;
   begin
     Width := tbSeparator.Width*2 + tbTImport.Width*7 + 14;
     Position := poScreenCenter;
   end;

begin
  if GetIniFile<>nil then
    with GetIniFile do begin
      vLeft := ReadInteger(SRSLibName, 'Left', -1);
      vTop  := ReadInteger(SRSLibName, 'Top', -1);
      vWidth := ReadInteger(SRSLibName, 'Width', -1);
      vHeight := ReadInteger(SRSLibName, 'Height', -1);
      if (vLeft>=0) and (vTop>=0) and (vWidth>0) and (vHeight>0) then begin
         Position := poDesigned;
         SetBounds(vLeft, vTop, vWidth, vHeight);
      end else SetDefaultPosition;

      pnlLeft.Width := ReadInteger(SRSLibName, 'Splitter', pnlLeft.Width);
      if ReadInteger(SRSLibName, 'ButtonCaption', 1)=0 then miTextLabels.Click;
    end
  else SetDefaultPosition;
  tbr.Repaint;
end;

procedure TrsPropSaverTemplatesForm.FormStateSave;
begin
  if GetIniFile<>nil then
    with GetIniFile do begin
      WriteInteger(SRSLibName, 'TemplatesLeft', Self.Left);
      WriteInteger(SRSLibName, 'TemplatesTop', Self.Top);
      WriteInteger(SRSLibName, 'TemplatesWidth', Self.Width);
      WriteInteger(SRSLibName, 'TemplatesHeight', Self.Height);
      WriteInteger(SRSLibName, 'TemplatesSplitter', pnlLeft.Width);
      WriteInteger(SRSLibName, 'TemplatesButtonCaption', Integer(tbr.ShowCaptions));
    end;
end;

function TrsPropSaverTemplatesForm.GetIniFile: TCustomIniFile;
begin
  Result := {$IFDEF RSL_DLGTEST}nil;{$ELSE}IDEIniFile;{$ENDIF}
end;

procedure TrsPropSaverTemplatesForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  FormStateSave;
end;

procedure TrsPropSaverTemplatesForm.miTextLabelsClick(Sender: TObject);
begin
  TBRResizeButtons(not tbr.ShowCaptions);
end;

procedure TrsPropSaverTemplatesForm.TBRResizeButtons(Large: Boolean);
begin
  if Large then begin
    if tbr.Height<LargeToolbarSize then tbr.Height := LargeToolbarSize;
    tbr.ButtonHeight := LargeButtonHeight;
    tbr.ButtonWidth := LargeButtonWidth;
    tbr.ShowCaptions := True;
  end else begin
    if tbr.Height>SmallToolbarSize then tbr.Height := SmallToolbarSize;
    tbr.ShowCaptions  := False;
    tbr.ButtonHeight := SmallButtonHeight;
    tbr.ButtonWidth := SmallButtonWidth;
  end;
end;

procedure TrsPropSaverTemplatesForm.splVertMoved(Sender: TObject);
begin
  TBRResizeButtons(tbr.Height >= LargeToolbarSize);
end;

procedure TrsPropSaverTemplatesForm.splVertCanResize(Sender: TObject;
  var NewSize: Integer; var Accept: Boolean);
begin
  with tbr do
    if (Height >= LargeToolbarSize)
     then
       if (NewSize <= SmallToolbarSize)
         then NewSize := SmallToolbarSize
         else NewSize := LargeToolbarSize
     else
       if(NewSize >= LargeToolbarSize)
         then NewSize := LargeToolbarSize
         else NewSize := SmallToolbarSize;
end;

procedure TrsPropSaverTemplatesForm.pmButtonCaptionsPopup(Sender: TObject);
begin
  miTextLabels.Checked := tbr.ShowCaptions;
end;

procedure TrsPropSaverTemplatesForm.LVNamesLoad;
var
  i: integer;
begin
  with lvNames,Items do begin
    BeginUpdate;
    Clear;
    for i:=0 to FTemplates.Count-1 do begin
      FTemplates.CurrentTemplateIndex := i;
      Add.Caption := FTemplates.TemplateName;
    end;
    EndUpdate;
  end;
end;

procedure TrsPropSaverTemplatesForm.FormActivate(Sender: TObject);
begin
  FStartTemplatesText := FTemplates.AsText;
  LVNamesLoad;
  if lvNames.Items.Count>0 then begin
    ActiveControl := lvNames;
    lvNames.Selected := lvNames.Items[0];
    lvNames.Items[0].Focused := True;
  end;
end;

procedure TrsPropSaverTemplatesForm.tbTExportClick(Sender: TObject);
begin
  if SaveDialog.Execute then
    Templates.SaveToFile(SaveDialog.FileName);
end;

procedure TrsPropSaverTemplatesForm.tbTImportClick(Sender: TObject);
begin
  if OpenDialog.Execute then begin
    FTemplates.LoadFromFile(OpenDialog.FileName);
    FormActivate(Self);
  end;
end;

procedure TrsPropSaverTemplatesForm.TBRRefresh;
var
  fl: boolean;
  lv: TListView;
begin
  if (csDestroying in ComponentState) then Exit;
  tbTExport.Enabled := lvNames.Items.Count>0;

  lv := ActiveListView;

  fl := ActiveListView.Selected<>nil;
  tbDel.Enabled := fl;
  tbRename.Enabled := fl;

  tbPUp.Enabled := fl and (lv=lvProps) and (lvProps.Selected.Index>0);
  tbPDown.Enabled := fl and (lv=lvProps) and (lvProps.Selected.Index<(lvProps.Items.Count-1));
end;

function TrsPropSaverTemplatesForm.ActiveListView: TListView;
begin
  if (ActiveControl<>nil) and (ActiveControl is TListView)
   then Result := TListView(ActiveControl)
   else Result := nil;
end;

procedure TrsPropSaverTemplatesForm.LVPropsRefresh;
var
  i: integer;
  li: TListItem;
begin
  if lvNames.Selected<>nil then begin
    i := FTemplates.IndexOf(lvNames.Selected.Caption);
    with lvProps,Items do begin
      BeginUpdate;
      Clear;
      if i>=0 then begin
        FTemplates.CurrentTemplateIndex := i;
        for i:=0 to FTemplates.PropertiesCount-1 do begin
          li := Add;
          li.Caption := FTemplates.Properties[i];
        end;
      end;
      EndUpdate;
    end;
  end;
end;

procedure TrsPropSaverTemplatesForm.lvNamesChange(Sender: TObject; Item: TListItem; Change: TItemChange);
begin
  LVPropsRefresh;
  TBRRefresh;
end;

procedure TrsPropSaverTemplatesForm.lvPropsChange(Sender: TObject;
  Item: TListItem; Change: TItemChange);
begin
  TBRRefresh;
end;

procedure TrsPropSaverTemplatesForm.tbRenameClick(Sender: TObject);
var
  lv: TListView;
begin
  lv := ActiveListView;
  if lv<>nil then begin
    lv.Selected.Focused := True;
    lv.Selected.EditCaption;
  end;
end;

procedure TrsPropSaverTemplatesForm.FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
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

procedure TrsPropSaverTemplatesForm.tbAddClick(Sender: TObject);
var
  lv: TListView;
  li: TListItem;
begin
  lv := ActiveListView;
  if lv<>nil then begin
    if lv=lvNames then Include(FLVNamesStates, tsAppending)
     else begin
       if lvNames.Selected=nil then Exit;
       Include(FLVPropsStates, tsAppending);
     end;
    li := lv.Items.Add;
    li.Caption := '--------';
    lv.Selected := li;
    li.Focused := True;
    li.EditCaption;
  end;
end;

procedure TrsPropSaverTemplatesForm.tbDelClick(Sender: TObject);
var
  lv: TListView;
  s: string;
  i: integer;
begin
  lv := ActiveListView;
  if (lv<>nil) and (lv.Selected<>nil) then begin
    if lv=lvNames
      then s := Format('Delete "%s" template ?',[lv.Selected.Caption])
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
        if lv=lvNames then LVPropsRefresh;
      end;
    end;

  end;
end;

procedure TrsPropSaverTemplatesForm.TemplateDelete(const Value: string);
var
  i: integer;
begin
  i := FTemplates.IndexOf(Value);
  if i>=0 then FTemplates.Delete(i);
end;

function TrsPropSaverTemplatesForm.PropAdd(const Template, Value: string): integer;
var
  i: integer;
begin
  Result := -1;
  i := FTemplates.IndexOf(Template);
  if i<0 then i := FTemplates.Add(Template);
  FTemplates.CurrentTemplateIndex := i;

  i := FTemplates.IndexOfProperty(Value);
  if i<0 then FTemplates.PropertiesAdd(Value);
end;

procedure TrsPropSaverTemplatesForm.PropDelete(const Template, Value: string);
var
  i: integer;
begin
  i := PropFind(Template,Value);
  if i>=0
    then FTemplates.PropertiesDelete(i);
end;

function TrsPropSaverTemplatesForm.PropFind(const Template, Value: string): integer;
var
  i: integer;
begin
  Result := -1;
  i := FTemplates.IndexOf(Template);
  if i<0 then Exit;
  FTemplates.CurrentTemplateIndex := i;
  Result := FTemplates.IndexOfProperty(Value);
end;

procedure TrsPropSaverTemplatesForm.lvNamesEditing(Sender: TObject;
  Item: TListItem; var AllowEdit: Boolean);
begin
  Include(FLVNamesStates, tsEditing);
end;

procedure TrsPropSaverTemplatesForm.lvNamesEdited(Sender: TObject;
  Item: TListItem; var S: String);
var
  i: integer;
  flExist: boolean;
begin
  flExist := (S<>Item.Caption) and (FTemplates.IndexOf(S)>=0);

  if tsAppending in FLVNamesStates then begin
    if flExist then begin
      MessageDlg('Template with name "'+S+'" already exists.', mtInformation, [mbOk], 0);
      S := Item.Caption;
    end else begin
      FTemplates.Add(S)
    end;
    Exclude(FLVNamesStates, tsAppending);
  end else begin
    i := FTemplates.IndexOf(Item.Caption);
    if not flExist then begin
      if i<0 then begin
        FTemplates.Add(S);
      end
      else begin
        FTemplates.CurrentTemplateIndex := i;
        FTemplates.TemplateName := S;
      end;
    end else begin
      MessageDlg('Template with name "'+S+'" already exists.', mtInformation, [mbOk], 0);
      S := Item.Caption;
    end;
  end;
  Exclude(FLVNamesStates, tsEditing);
end;

procedure TrsPropSaverTemplatesForm.tbPUpClick(Sender: TObject);
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
    FTemplates.PropertiesExchange(i, i+1);
  end;
end;

procedure TrsPropSaverTemplatesForm.tbPDownClick(Sender: TObject);
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
    FTemplates.PropertiesExchange(i, i-1);
  end;
end;

procedure TrsPropSaverTemplatesForm.lvPropsKeyDown(Sender: TObject;
  var Key: Word; Shift: TShiftState);
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

procedure TrsPropSaverTemplatesForm.lvPropsEditing(Sender: TObject;
  Item: TListItem; var AllowEdit: Boolean);
begin
  AllowEdit := lvNames.Selected<>nil;
  Include(FLVPropsStates, tsEditing);
end;

procedure TrsPropSaverTemplatesForm.lvPropsEdited(Sender: TObject;
  Item: TListItem; var S: String);
var
  i: integer;
  flExist: boolean;
begin
  flExist := (S<>Item.Caption) and (PropFind(lvNames.Selected.Caption, S)>=0);

  if tsAppending in FLVPropsStates then begin
    if flExist then begin
      MessageDlg('Property with name "'+S+'" already exists.', mtInformation, [mbOk], 0);
      S := Item.Caption;
    end else begin
      PropAdd(lvNames.Selected.Caption, S);
    end;
    Exclude(FLVPropsStates, tsAppending);
  end else begin
    i := PropFind(lvNames.Selected.Caption, Item.Caption);
    if not flExist then begin
      if i<0 then begin
        PropAdd(lvNames.Selected.Caption, S);
      end else FTemplates.Properties[i] := S;
    end else begin
      MessageDlg('Property with name "'+S+'" already exists.', mtInformation, [mbOk], 0);
      S := Item.Caption;
    end;
  end;
  Exclude(FLVPropsStates, tsEditing);
end;

procedure TrsPropSaverTemplatesForm.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
begin
  ModalResult := mrCancel;
  if FStartTemplatesText<>FTemplates.AsText then begin
    ModalResult := MessageDlg('Save changes?', mtConfirmation, [mbYes,mbNo,mbCancel], 0);
    CanClose := ModalResult<>mrCancel;
  end;
end;

procedure TrsPropSaverTemplatesForm.FormResize(Sender: TObject);
begin
  lvNames.Columns[0].Width := lvNames.ClientWidth-GetSystemMetrics(SM_CXVSCROLL);
  lvProps.Columns[0].Width := lvProps.ClientWidth-GetSystemMetrics(SM_CXVSCROLL);
end;

{ TrsPropSaverTemplates }

function TrsPropSaverTemplates.Add(const TemplateName: string): integer;
var
  len: integer;
begin
  if IndexOf(TemplateName)>=0 then begin
    Result := -1;
    Exit;
  end;

  len := Length(FHeaderIndexes);
  SetLength(FHeaderIndexes, len+1);
  SetLength(FPropsBeginIndexes, len+1);
  SetLength(FPropsEndIndexes, len+1);

  Result := len;
  FHeaderIndexes[len] := FItems.Add('['+TemplateName+']');
  FPropsBeginIndexes[len] := -1;
  FPropsEndIndexes[len] := -1;
end;

procedure TrsPropSaverTemplates.Assign(Source: TrsPropSaverTemplates);
begin
  FItems.Assign(Source.FItems);
  FItemsPrepare;
  IndexesRefresh;
  FCurrentTemplateIndex := -1;
end;

function TrsPropSaverTemplates.Count: integer;
begin
  Result := length(FHeaderIndexes);
end;

constructor TrsPropSaverTemplates.Create;
begin
  FItems := TStringList.Create;
  IndexesRefresh;
end;

procedure TrsPropSaverTemplates.Delete(const TemplateIndex: integer);
var
  i: integer;
begin
  if (TemplateIndex<0) or (TemplateIndex>=Count) then Exit;
  i := FHeaderIndexes[TemplateIndex];

  if i>=0 then
    while i<FItems.Count do begin
      FItems.Delete(i);
      if i>=FItems.Count then Break;
      if IsTemplateHeader(FItems[i]) then Break;
    end;

  IndexesRefresh;
end;

destructor TrsPropSaverTemplates.Destroy;
begin
  SetLength(FHeaderIndexes, 0);
  SetLength(FPropsBeginIndexes, 0);
  SetLength(FPropsEndIndexes, 0);
  FItems.Free;
  inherited;
end;

procedure TrsPropSaverTemplates.FItemsPrepare;
var
  i: integer;
begin
  i := 0;
  while i<FItems.Count do
    if Length(FItems[i])=0
      then FItems.Delete(i)
      else Inc(i);
end;

function TrsPropSaverTemplates.GetAsText: string;
begin
  Result := FItems.Text;
end;

function TrsPropSaverTemplates.GetFileName: string;
var
  Len: integer;
begin
  SetLength(Result, 255);
  Len := GetWindowsDirectory(PChar(Result), 255);
  SetLength(Result, Len);
  if (Len>0) and (Result[Len]<>'\') then Result := Result + '\';
  Result := Result + SRSTemplatesFileName;
end;

function TrsPropSaverTemplates.GetProperties(index: integer): string;
begin
  Result := FItems[FPropsBeginIndexes[FCurrentTemplateIndex]+Index];
end;

function TrsPropSaverTemplates.GetTemplateHeader(const Value: string): string;
begin
  Result := Copy(Value, 2, length(Value)-2);
end;

function TrsPropSaverTemplates.GetTemplateName: string;
begin
  Result := GetTemplateHeader(FItems[FHeaderIndexes[FCurrentTemplateIndex]]);
end;

procedure TrsPropSaverTemplates.IndexesRefresh;
var
  i,len: integer;
begin
  SetLength(FHeaderIndexes, 0);

  for i:=0 to FItems.Count-1 do
    if IsTemplateHeader(FItems[i]) then begin
      len := Length(FHeaderIndexes);
      SetLength(FHeaderIndexes, len+1);
      FHeaderIndexes[len] := i;
    end;

  len := Length(FHeaderIndexes);
  SetLength(FPropsBeginIndexes, len);
  SetLength(FPropsEndIndexes, len);

  for i:=0 to len-1 do begin
    FPropsBeginIndexes[i] := FHeaderIndexes[i]+1;
    if FPropsBeginIndexes[i]>=FItems.Count
      then FPropsBeginIndexes[i] := -1;

    if FPropsBeginIndexes[i]<0
      then FPropsEndIndexes[i] := -1
      else
    if i<(len-1)
      then FPropsEndIndexes[i] := FHeaderIndexes[i+1]-1
      else FPropsEndIndexes[i] := FItems.Count-1;
  end;
end;

function TrsPropSaverTemplates.IndexOf(const TemplateName: string): integer;
var
  i: integer;
begin
  Result := 0;

  for i:=0 to Length(FHeaderIndexes)-1 do
    if CompareText(TemplateName, GetTemplateHeader(FItems[FHeaderIndexes[i]]))=0
      then Exit
      else Inc(Result);

  Result := -1;
end;

function TrsPropSaverTemplates.IndexOfProperty(const PropertyText: string): integer;
var
  b,e: integer;
begin
  Result := -1;
  b := FPropsBeginIndexes[FCurrentTemplateIndex];
  if b<0 then Exit;
  e := FPropsEndIndexes[FCurrentTemplateIndex];
  if e<b then Exit;
  while b<=e do begin
    if CompareText(FItems[b], PropertyText)=0 then begin
      Result := b - FPropsBeginIndexes[FCurrentTemplateIndex];
      Break;
    end else Inc(b);
  end;
end;

function TrsPropSaverTemplates.IsTemplateHeader(const Value: string): boolean;
begin
  Result := (Length(Value)>1) and (Value[1]='[') and (Value[Length(Value)]=']');
end;

procedure TrsPropSaverTemplates.Load;
var
  s: string;
begin
  FItems.Clear;
  s := GetFileName;
  if FileExists(s) then FItems.LoadFromFile(s);
  FItemsPrepare;
  IndexesRefresh;
end;

procedure TrsPropSaverTemplates.LoadFromFile(const AFileName: string);
begin
  FItems.Clear;
  if FileExists(AFileName) then FItems.LoadFromFile(AFileName);
  FItemsPrepare;
  IndexesRefresh;
end;

function TrsPropSaverTemplates.PropertiesAdd(const PropertyText: string): integer;
var
  i: integer;
begin
  i := FPropsEndIndexes[FCurrentTemplateIndex];
  if i<0
   then begin
     i := FHeaderIndexes[FCurrentTemplateIndex]+1;
   end else Inc(i);
  FItems.Insert(i, PropertyText);
  IndexesRefresh;
  Result := -1;
end;

procedure TrsPropSaverTemplates.PropertiesClear;
var
  b,e: integer;
begin
  b := FPropsBeginIndexes[FCurrentTemplateIndex];
  e := FPropsEndIndexes[FCurrentTemplateIndex];

  while (e>=0) and (e>=b) do begin
    FItems.Delete(e);
    Dec(e);
  end;

  FPropsBeginIndexes[FCurrentTemplateIndex] := -1;
  FPropsEndIndexes[FCurrentTemplateIndex] := -1;
end;

function TrsPropSaverTemplates.PropertiesCount: integer;
begin
  if FPropsBeginIndexes[FCurrentTemplateIndex]>=0
    then Result := FPropsEndIndexes[FCurrentTemplateIndex]-FPropsBeginIndexes[FCurrentTemplateIndex]+1
    else Result := 0;
end;

procedure TrsPropSaverTemplates.PropertiesDelete(const PropertyIndex: integer);
begin
  FItems.Delete(FPropsBeginIndexes[FCurrentTemplateIndex]+PropertyIndex);
  IndexesRefresh;
end;

procedure TrsPropSaverTemplates.PropertiesExchange(const PropertyIndex1, PropertyIndex2: integer);
var
  i1,i2: integer;
begin
  i1 := FPropsBeginIndexes[FCurrentTemplateIndex]+PropertyIndex1;
  i2 := FPropsBeginIndexes[FCurrentTemplateIndex]+PropertyIndex2;
  FItems.Exchange(i1, i2);
end;

procedure TrsPropSaverTemplates.Save;
begin
  FItems.SaveToFile(GetFileName);
end;

procedure TrsPropSaverTemplates.SaveToFile(const AFileName: string);
begin
  FItems.SaveToFile(AFileName);
end;

procedure TrsPropSaverTemplates.SetAsText(const Value: string);
begin
  FItems.Text := Value;
  FItemsPrepare;
  IndexesRefresh;
end;

procedure TrsPropSaverTemplates.SetCurrentTemplateIndex(const Value: integer);
begin
  FCurrentTemplateIndex := Value;
end;

procedure TrsPropSaverTemplates.SetProperties(index: integer; const Value: string);
begin
  FItems[FPropsBeginIndexes[FCurrentTemplateIndex]+Index] := Value;
end;

procedure TrsPropSaverTemplates.SetTemplateName(const Value: string);
begin
  FItems[FHeaderIndexes[FCurrentTemplateIndex]] := '['+Value+']';
end;

procedure TrsPropSaverTemplatesForm.lvEnter(Sender: TObject);
begin
  TBRRefresh;
end;

end.
