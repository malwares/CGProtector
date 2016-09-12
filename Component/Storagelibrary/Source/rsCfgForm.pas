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
unit rsCfgForm;

interface

{$I rsStorage.inc}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ComCtrls, ExtCtrls, ToolWin, StdCtrls, TypInfo, Menus, rsConst,
  {$IFNDEF RSL_CB3LE} ImgList, {$ELSE} Commctrl, {$ENDIF}
  {$IFDEF RSL_D6}Variants,{$ENDIF}
  rsStorage, rsPropSaver, rsProperties, rsProperty;

type

  TrsFormCfgView = (fvName, fvClass);

  TrsFormCfg = class(TForm)
    tbrMain: TToolBar;
    Splitter: TSplitter;
    sbrMain: TStatusBar;
    ilTree: TImageList;
    ilToolbar: TImageList;
    tbView: TToolButton;
    pmView: TPopupMenu;
    miViewByName: TMenuItem;
    miViewByClass: TMenuItem;
    tbTemplate: TToolButton;
    tbSeparator: TToolButton;
    pmTemplate: TPopupMenu;
    tbMoveUp: TToolButton;
    tbMoveDown: TToolButton;
    pnlLeft: TPanel;
    tv: TTreeView;
    Label1: TLabel;
    pnlRight: TPanel;
    lv: TListView;
    Label2: TLabel;
    pmButtonCaptions: TPopupMenu;
    miTextLabels: TMenuItem;
    N1: TMenuItem;
    miTemplsSaveAs: TMenuItem;
    miTemplsCustomize: TMenuItem;
    tbAdd: TToolButton;
    tbDelete: TToolButton;
    tbModify: TToolButton;
    tbInfo: TToolButton;
    pnlInfo: TPanel;
    Label3: TLabel;
    cbInfoType: TComboBox;
    Label4: TLabel;
    cbInfoState: TComboBox;
    Label5: TLabel;
    edInfoDef: TEdit;
    TimerLVChange: TTimer;
    cbxEncrypt: TCheckBox;
    Label6: TLabel;
    edInfoSubstName: TEdit;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure tvChange(Sender: TObject; Node: TTreeNode);
    procedure tvKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure tvMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure tvMouseMove(Sender: TObject; Shift: TShiftState; X,Y: Integer);
    procedure miViewByClassClick(Sender: TObject);
    procedure pmViewPopup(Sender: TObject);
    procedure tbMoveUpClick(Sender: TObject);
    procedure tbMoveDownClick(Sender: TObject);
    procedure lvChange(Sender: TObject; Item: TListItem; Change: TItemChange);
    procedure lvDblClick(Sender: TObject);
    procedure lvEnter(Sender: TObject);
    procedure lvKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure tvEnter(Sender: TObject);
    procedure lvMouseMove(Sender: TObject; Shift: TShiftState; X,Y: Integer);
    procedure lvMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure miTextLabelsClick(Sender: TObject);
    procedure pmButtonCaptionsPopup(Sender: TObject);
    procedure pmTemplatePopup(Sender: TObject);
    procedure miTemplsSaveAsClick(Sender: TObject);
    procedure miTemplsCustomizeClick(Sender: TObject);
{$IFNDEF RSL_CB3LE}
    procedure tvCustomDrawItem(Sender: TCustomTreeView; Node: TTreeNode;
      State: TCustomDrawState; var DefaultDraw: Boolean);
    procedure lvCustomDrawItem(Sender: TCustomListView; Item: TListItem;
      State: TCustomDrawState; var DefaultDraw: Boolean);
{$ENDIF}
    procedure lvEdited(Sender: TObject; Item: TListItem; var S: String);
    procedure lvResize(Sender: TObject);
    procedure tbDeleteClick(Sender: TObject);
    procedure tbAddClick(Sender: TObject);
    procedure tbModifyClick(Sender: TObject);
    procedure tbInfoClick(Sender: TObject);
    procedure TimerLVChangeTimer(Sender: TObject);
    procedure cbInfoStateChange(Sender: TObject);
    procedure cbInfoTypeChange(Sender: TObject);
    procedure edInfoDefChange(Sender: TObject);
    procedure lvDeletion(Sender: TObject; Item: TListItem);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure tbViewClick(Sender: TObject);
    procedure tbTemplateClick(Sender: TObject);
    procedure cbxEncryptClick(Sender: TObject);
    procedure lvEditing(Sender: TObject; Item: TListItem;
      var AllowEdit: Boolean);
    procedure edInfoSubstNameChange(Sender: TObject);
  private
    FEncryptList: TStringList;
    FTemplates: TStringList;
    FForm: TComponent;
    FView: TrsFormCfgView;
    FProps: TStrings;
    FOnChangeCheck: TTVChangedEvent;
    FPropSaver: TrsPropSaver;
    FShowInfo: boolean;
    function GetCheckState(Node: TTreeNode): TCheckBoxState;
    procedure SetCheckState(Node: TTreeNode; const Value: TCheckBoxState);
    procedure SetView(const Value: TrsFormCfgView);
    procedure ClickTVCheck(Sender: TObject; Node: TTreeNode);
    procedure TemplateClick(Sender: TObject);
    procedure SetPropSaver(const Value: TrsPropSaver);
    function GetItemState(ListItem: TListItem): TrsPropertyState;
    procedure SetItemState(ListItem: TListItem; const Value: TrsPropertyState);
    function GetItemErrorState(ListItem: TListItem): boolean;
    procedure SetItemErrorState(ListItem: TListItem; const Value: boolean);
    function lvGetHitTestInfoAt(X, Y: Integer): boolean;
    procedure SetShowInfo(const Value: boolean);
    function GetItemType(ListItem: TListItem): TrsPropertyType;
    procedure SetItemType(ListItem: TListItem; const Value: TrsPropertyType);
    function GetItemDefValue(ListItem: TListItem): string;
    procedure SetItemDefValue(ListItem: TListItem; const Value: string);
    function GetItemSubstName(ListItem: TListItem): string;
    procedure SetItemSubstName(ListItem: TListItem; const Value: string);
  protected
    procedure AddProperty(ATypeInfo: PTypeInfo; Node: TTreeNode; AComponent: TObject; AName: string);
    function FindNode(Node: TTreeNode; const Value:string): TTreeNode;
    function FindNodeEx(const Value: string): TTreeNode;

    function IsInfoFocused: boolean;

    procedure LoadTV;

    procedure GetNodeParams(Node: TTreeNode; var s0, s1: string);

    procedure RefreshRightPanel;
    procedure RefreshStatusBar;
    procedure RefreshToolBar;
    procedure RefreshTVChecks;
    procedure RefreshInfo(const IfShowInfo: boolean);
    procedure StringsToLV;
    procedure LVToStrings;

    function NodeName(Node: TTreeNode): string;

    function  LVAdd(Prop: TrsProperty): TListItem;
    procedure LVDelete(const Value: string);
    procedure LVItemExchange(const Direction: integer);
    function  LVFind(const Value: string; const Partial: boolean): TListItem;
//    function  LVFindByRealName(const Value: string): TListItem;
    procedure LVSelectNearest(const Index: integer);

    procedure ToggleState;

    procedure FormStateLoad;
    procedure FormStateSave;

    procedure TemplatesLoad;
    procedure TemplatesSave;
    function  TemplatesFileName: string;
    function  TemplGetCaption(var Value:string): boolean;
    function  TemplApproach(const Index:integer; Node: TTreeNode): boolean;

    procedure IntSetCheckState(Node: TTreeNode;const Value: TCheckBoxState; doChilds:boolean); virtual;
    procedure VerifyCheckState(Node: TTreeNode);
    procedure ToggleCheckState(Node: TTreeNode);
    property CfgForm: TComponent read FForm;

    property ListItemState[ListItem: TListItem]: TrsPropertyState read GetItemState write SetItemState;
    property ListItemType[ListItem: TListItem]: TrsPropertyType read GetItemType write SetItemType;
    property ListItemErrorState[ListItem: TListItem]: boolean read GetItemErrorState write SetItemErrorState;
    property ListItemDefValue[ListItem: TListItem]: string read GetItemDefValue write SetItemDefValue;
    property ListItemSubstName[ListItem: TListItem]: string read GetItemSubstName write SetItemSubstName;

    procedure GetEncryptList;
    procedure SetEncryptList;

    function PropertyFindByName(const Value:string): TrsProperty;

  public
    property PropSaver: TrsPropSaver read FPropSaver write SetPropSaver;
    property CheckState[Node:TTreeNode]: TCheckBoxState read GetCheckState write SetCheckState;
    property OnChangeCheckState : TTVChangedEvent read FOnChangeCheck write FOnChangeCheck;
    property View: TrsFormCfgView read FView write SetView;
    property ShowInfo: boolean read FShowInfo write SetShowInfo default False;
  end;


implementation

uses rsTempls;

{$R *.DFM}
{.$IFDEF RSL_D3}
{$R rsl.res}
{.$ENDIF}

Const

  cImgIdxCheckBlock = 0;
  cImgIdxDisable = 3;
  cImgIdxError = 4;
  cImgIdxRead = 5;
  cImgIdxWrite = 6;
  cTVCustomProperty = $FFFFFFFE;

  cMaskError   = $00000040;
//  cMaskEncrypted = $00000020;

  SOrdType : array[0..4] of string =
    ('ShortInt', 'Byte', 'Integer', 'Word', 'Longint');
  SFloatType : array[0..4] of string =
    ('Single', 'Double', 'Extended', 'Comp', 'Currency');

//  SComponentNoName = '(No Name)';

{ TrsFormCfg }

function TrsFormCfg.GetCheckState(Node: TTreeNode): TCheckBoxState;
begin
  Result := TCheckBoxState(Node.ImageIndex-cImgIdxCheckBlock);
end;

procedure TrsFormCfg.SetCheckState(Node: TTreeNode; const Value: TCheckBoxState);
begin
  IntSetCheckState(Node, Value, True);
end;

procedure TrsFormCfg.SetShowInfo(const Value: boolean);
begin
  pnlInfo.Visible := Value;
  tbInfo.Down := Value;
  FShowInfo := Value;
  if Value then begin
    lvResize(Self);
    RefreshInfo(False);
  end;
end;

procedure TrsFormCfg.SetView(const Value: TrsFormCfgView);
begin
  if FView <> Value then begin
    FView := Value;
    if tv.Items.Count<>0 then begin
      LoadTV;
      RefreshTVChecks;
    end;
  end;
end;

procedure TrsFormCfg.FormCreate(Sender: TObject);
begin
{.$IFDEF RSL_D3}
  ilToolbar.Clear;
  ilTree.Clear;
  if ModuleIsPackage then begin
    ilToolbar.ResInstLoad(Hinstance, rtBitmap, 'RSL_TOOLBAR', clAqua);
    ilTree.ResInstLoad(Hinstance, rtBitmap, 'RSL_TREE', clAqua);
  end else begin
    ilToolbar.ResourceLoad(rtBitmap, 'RSL_TOOLBAR', clAqua);
    ilTree.ResourceLoad(rtBitmap, 'RSL_TREE', clAqua);
  end;
{.$ENDIF}
{$IFNDEF RSL_CB3LE}
  tv.OnCustomDrawItem := tvCustomDrawItem;
  lv.OnCustomDrawItem := lvCustomDrawItem;
  tv.ToolTips := False;
{$ENDIF}
  FProps := TStringList.Create;
  FTemplates := TStringList.Create;
  FEncryptList := TStringList.Create;
  FView := fvName;
  FShowInfo := False;
  FormStateLoad;
  TemplatesLoad;
end;

procedure TrsFormCfg.FormDestroy(Sender: TObject);
begin
  FEncryptList.Free;
  FTemplates.Free;
  FProps.Free;
end;

procedure TrsFormCfg.FormActivate(Sender: TObject);
begin
  if CfgForm is TCustomForm
   then Caption := 'Setup for <'+TCustomForm(CfgForm).Caption+'>'
   else Caption := 'Setup for <'+CfgForm.Name+'>';
  StringsToLV;
  GetEncryptList;
  RefreshTVChecks;
end;

procedure TrsFormCfg.StringsToLV;
var
  i,k: integer;
  li: TListItem;
  Prop: TrsProperty;
  s: string;
begin
  with lv, Items do begin
    BeginUpdate;
    Clear;
    for i:=0 to FProps.Count-1 do begin
      Prop := TrsProperty.Create;
      Prop.AsString := FProps[i];

      k := Pos('.', Prop.Name);
      if k>0 then s := Copy(Prop.Name, 1, k-1)
       else s := Prop.Name;
      if (Length(s)>0) and (GetPropInfo(FForm.ClassInfo,s)<>nil)
       then Prop.Name := FForm.Name+'.'+Prop.Name;

      li := LVAdd(Prop);
      ListItemErrorState[li] := (FindNodeEx(Prop.Name)=nil) and not (Prop.PropType in [ptUser,ptVariable]);
    end;
    EndUpdate;
  end;
end;



procedure TrsFormCfg.LVToStrings;
var
  li: TListItem;
  i,k: integer;
  s: string;
begin
  FProps.Clear;
  for i:=0 to lv.Items.Count-1 do begin
    li := lv.Items[i];
    s := li.Caption;
    k := Length(FForm.Name);
    if (StrLIComp(PChar(FForm.Name), PChar(s), k)=0) and (Length(s)>k) and (s[k+1]='.')
     then begin
       Delete(TrsProperty(li.Data).Name, 1, k+1);
     end;
    FProps.Add(TrsProperty(li.Data).AsString);
  end;
end;



function TrsFormCfg.NodeName(Node: TTreeNode): string;
begin
  Result := '';
  While (Node<>nil) and (Node.Parent<>nil) do begin
    if Result<>'' then Result := Node.Text + '.'+ Result
     else Result:= Node.Text;
    Node := Node.Parent;
  end;

  if (Node<>nil) and (Node.TreeView=tv) and (View=fvClass) then begin
      Delete(Result, 1, Pos('.', Result));
  end;
end;

procedure TrsFormCfg.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  LVToStrings;
  if not FProps.Equals(PropSaver.Properties) then
   case MessageDlg('Save changes in selected properties?', mtConfirmation, mbYesNoCancel, 0) of
     mrYes:    begin
                 PropSaver.Properties.Assign(FProps);
                 SetEncryptList;
               end;
     mrNo:     Action := caFree;
     mrCancel: begin Action := caNone; Exit; end;
   end;
  FormStateSave;
//  Action := caFree;
end;


procedure TrsFormCfg.LoadTV;
var
  i: integer;
  Node: TTreeNode;
begin
  with tv, Items do begin
    BeginUpdate;
    Clear;
    if FForm<>nil then begin
      Node := Add(nil,'Components');
      AddProperty(nil, Node, FForm, FForm.Name);
      for i:=0 to FForm.ComponentCount-1 do
        AddProperty(nil, Node, FForm.Components[i], FForm.Components[i].Name);
{$IFDEF RSL_CB3LE}
      while Node <> nil do begin
        if Node.HasChildren then Node.AlphaSort;
        Node := Node.GetNext;
      end;
      Node := GetFirstNode;
{$ELSE}
      tv.AlphaSort;
{$ENDIF}
      Node.Expanded := True;
    end;

    EndUpdate;
  end;
end;




procedure TrsFormCfg.AddProperty(ATypeInfo: PTypeInfo; Node: TTreeNode; AComponent: TObject; AName: string);
var
  TypeData: PTypeData;
  tnClass: TTreeNode;
  flTopComponent: boolean;
  PropInfo: PPropInfo;

   procedure AddPropList(ZTypeInfo: PTypeInfo; ZNode: TTreeNode; ZComponent: TObject);
   var
     NumProps,i: integer;
     PropList: PPropList;
   begin
     NumProps :=  GetTypeData(ZTypeInfo)^.PropCount;
     GetMem(PropList, NumProps*SizeOf(PPropInfo));
     try
      GetPropInfos(ZTypeInfo, PropList);
      for i := 0 to NumProps-1 do
        AddProperty(PropList^[i]^.PropType^, ZNode, ZComponent, PropList^[i]^.Name);

      {Add Custom Properties}
      if PropSaver.CustomProperties<>nil then
        with (PropSaver.CustomProperties as TrsCustomProperties).Properties do
          for i := 0 to Count-1 do
            if {(ZComponent<>nil) and }Items[i].IsSuitable(ZComponent) then
              tv.Items.AddChildObject(ZNode, Items[i].PropName, Pointer(cTVCustomProperty));
     finally
       FreeMem(PropList, NumProps*SizeOf(PPropInfo));
     end;
   end;

begin
//  if AName='' then AName := SComponentNoName;

  flTopComponent := ATypeInfo=nil;
  if flTopComponent then ATypeInfo := AComponent.ClassInfo;

  TypeData := GetTypeData(ATypeInfo);
  with ATypeInfo^ do
    case Kind of
      tkUnknown :
        tv.Items.AddChild(Node, 'Unknown ' + AName);

{$IFDEF RSL_INT64} tkInt64, {$ENDIF}
      tkVariant,
      tkEnumeration, tkSet, tkWChar,
      tkChar, tkFloat, tkInteger,
      tkString, tkLString, tkWString :
        tv.Items.AddChildObject(Node, AName, AComponent);

      tkClass :
        begin
          if TypeData^.ClassType.InheritsFrom(TComponent) and not flTopComponent
            then begin
{$IFDEF RSL_D6}
              Node := tv.Items.AddChildObject(Node, AName, AComponent);
              if AComponent<>nil then begin
                PropInfo := GetPropInfo(AComponent.ClassInfo, AName);
                if (PropInfo<>nil) and (PropInfo^.PropType^.Kind=tkClass) then begin
                  AComponent := TObject(GetOrdProp(AComponent, PropInfo));
                  if (AComponent<>nil) and (csSubComponent in TComponent(AComponent).ComponentStyle)
                    then begin
                      ATypeInfo := AComponent.ClassInfo;
                      AddPropList(ATypeInfo, Node, AComponent);
                    end;
                end;
              end;
{$ELSE}
              tv.Items.AddChildObject(Node, AName, AComponent);
{$ENDIF}
            end else

          if TypeData^.ClassType.InheritsFrom(TCollection) then begin
            Node := tv.Items.AddChildObject(Node, AName, AComponent);
            if AComponent<>nil then begin
              PropInfo := GetPropInfo(AComponent.ClassInfo, AName);
              AComponent := TObject(GetOrdProp(AComponent, PropInfo));

              if TCollection(AComponent).Count>0 then begin
                AComponent := TCollection(AComponent).Items[0];
                ATypeInfo := AComponent.ClassInfo;
              end else begin
                ATypeInfo := TCollection(AComponent).ItemClass.ClassInfo;
                AComponent := nil;
              end;

              AddPropList(ATypeInfo, Node, AComponent);
            end
          end else

          if flTopComponent or (not TypeData^.ClassType.InheritsFrom(TComponent)) then begin

            if flTopComponent and (View=fvClass) and (AComponent<>nil) then begin
              tnClass := Node.getFirstChild;
              While (tnClass<>nil) and (tnClass.Text<>AComponent.ClassName) do
                tnClass := Node.GetNextChild(tnClass);
              if tnClass=nil then Node := tv.Items.AddChildObject(Node, AComponent.ClassName, nil)
               else Node := tnClass;
            end;
            Node := tv.Items.AddChildObject(Node, AName, AComponent);

            if AComponent<>nil then begin
              PropInfo := GetPropInfo(AComponent.ClassInfo, AName);
              if (PropInfo<>nil) and (PropInfo^.PropType^.Kind=tkClass) then
                AComponent := TObject(GetOrdProp(AComponent, PropInfo));
            end;

            AddPropList(ATypeInfo, Node, AComponent);
          end;
      end;
    end; {case}
end;


procedure TrsFormCfg.GetNodeParams(Node: TTreeNode; var s0, s1: string);
var
  ATypeInfo: PTypeInfo;
  TypeData: PTypeData;
  PropInfo: PPropInfo;
  i: integer;
begin
  if (TObject(Node.Data) is TComponent) AND (Node.Text=TComponent(Node.Data).Name)
   then begin
     s0 := 'Class';
     s1 := TComponent(Node.Data).ClassName;
     Exit;
   end;

  s0 := '';
  s1 := '';
  ATypeInfo := TObject(Node.Data).ClassInfo;
  PropInfo := GetPropInfo(ATypeInfo, Node.Text);

  if PropInfo=nil then Exit;

  TypeData := GetTypeData(PropInfo.PropType^);
  case PropInfo.PropType^.Kind of
   tkSet:     begin
                s0 := 'Set';
                s1 := GetSetProp(TObject(Node.Data), PropInfo);
              end;
   tkInteger: begin
                s0 := SOrdType[Integer(TypeData^.OrdType)];
                i := GetOrdProp(TObject(Node.Data), PropInfo);

                if PropInfo.PropType^.Name='TColor' then s1 := ColorToString(TColor(i))
                 else
                if PropInfo.PropType^.Name='TCursor' then s1 := CursorToString(TCursor(i))
                 else s1 := IntToStr(i);
              end;
   tkFloat:   begin
                s0 := SFloatType[Integer(TypeData^.FloatType)];
                s1 := FloatToStr(GetFloatProp(TObject(Node.Data), PropInfo));
              end;
   tkString, tkLString, tkWString :
              begin
                s0 := 'String';
                s1 := ''''+GetStrProp(TObject(Node.Data), PropInfo)+'''';
              end;
   tkWChar,
   tkChar   : begin
                s0 := System.Copy(GetEnumName(TypeInfo(TTypeKind)
                                  , Integer(PropInfo.PropType^.Kind)), 3, 255);
                i := GetOrdProp(TObject(Node.Data), PropInfo);
                s1 := Chr(i);
              end;
   tkEnumeration:
              begin
                s0 := PropInfo.PropType^.Name;
                i := GetOrdProp(TObject(Node.Data), PropInfo);
                s1 := GetEnumName(PropInfo.PropType^,i);
              end;
   tkClass :  begin
                s0 := 'Class';
                s1 := TypeData^.ClassType.ClassName;
              end;
{$IFDEF RSL_INT64}
   tkInt64 :  begin
                s0 := 'Int64';
                s1 := IntToStr(GetInt64Prop(TObject(Node.Data), PropInfo));
              end;
{$ENDIF}
   tkVariant: begin
                s0 := 'Variant';
                s1 := VarToStr(GetVariantProp(TObject(Node.Data), PropInfo));
              end;
   else begin
     s0:='';
     s1:='';
   end;
  end;
end;

procedure TrsFormCfg.RefreshStatusBar;
var
  s0,s1: string;
  Node: TTreeNode;
begin
  if (ActiveControl=tv) or tv.Focused then Node := tv.Selected
   else
  if ((ActiveControl=lv) or lv.Focused) AND (lv.Selected<>nil)
   then Node := FindNodeEx(lv.Selected.Caption)
   else Node := nil;

  if (Node<>nil) AND (Node.Data=Pointer(cTVCustomProperty)) then begin
    sbrMain.Panels[0].Text := 'Custom Property';
    sbrMain.Panels[1].Text := '';
  end else
  if (Node<>nil) AND (Node.Data<>nil) then begin
    GetNodeParams(Node, s0, s1);
    sbrMain.Panels[0].Text := s0;
    sbrMain.Panels[1].Text := s1;
  end else begin
    if ((ActiveControl=lv) or lv.Focused) AND (ListItemType[lv.Selected]=ptUser)
     then sbrMain.Panels[0].Text := 'User Property'
     else sbrMain.Panels[0].Text := '';
    sbrMain.Panels[1].Text := '';
  end;
end;


procedure TrsFormCfg.tvChange(Sender: TObject; Node: TTreeNode);
begin
  RefreshStatusBar;
  RefreshToolBar;
  RefreshRightPanel;
end;


procedure TrsFormCfg.RefreshRightPanel;
var
  Node: TTreeNode;
  ListItem: TListItem;
begin
  if (ActiveControl=tv) or tv.Focused then begin
    Node := tv.Selected;
    if (Node<>nil) and (CheckState[Node] in [cbGrayed,cbChecked]) then begin
      ListItem := LVFind(NodeName(Node), Node.HasChildren);
      if ListItem<>nil then begin
        ListItem.Selected := True;
        ListItem.MakeVisible(False);
        RefreshInfo(True);
      end;
    end;
  end;
end;


procedure TrsFormCfg.IntSetCheckState(Node: TTreeNode; const Value: TCheckBoxState; doChilds: boolean);
var
  t: TTreeNode;
  r: TRect;
begin
  if Value<>GetCheckState(Node) then begin
    Node.ImageIndex := Integer(Value)+cImgIdxCheckBlock;
    Node.SelectedIndex := Node.ImageIndex;
    r := Node.DisplayRect(False);
    InvalidateRect(Node.Handle, @r, True);

    if Assigned(FOnChangeCheck) then FOnChangeCheck(tv, Node);
    {correct childs}
    if doChilds AND (Value<>cbGrayed) then begin
      lv.Items.BeginUpdate;
      t := Node.getFirstChild;
      While t<>nil do begin
        IntSetCheckState(t, Value, True);
        t := Node.GetNextChild(t);
      end;
      lv.Items.EndUpdate;
    end;
    {correct parents}
    VerifyCheckState(Node.Parent);
  end;
end;

procedure TrsFormCfg.ToggleCheckState(Node: TTreeNode);
var
  li: TListItem;
begin
  if (Node<>nil) and (Node<>tv.Items.GetFirstNode) then begin
    if CheckState[Node] = cbUnChecked then begin
      CheckState[Node] := cbChecked;

      li := LVFind(NodeName(Node), False);
      if li<>nil then begin
        li.Selected := True;
        li.MakeVisible(False);
      end;
    end else CheckState[Node] := cbUnchecked;
  end;
end;

procedure TrsFormCfg.VerifyCheckState(Node: TTreeNode);
var
  t: TTreeNode;
  state: TCheckBoxState;
  CntCheck,CntUnCheck,Cnt: integer;
begin
  if Node<>nil then begin
    t := Node.getFirstChild;
    Cnt:=0; CntCheck:=0; CntUnCheck:=0;
    While t<>nil do begin
      state := GetCheckState(t);
      if state = cbChecked then Inc(CntCheck)
       else if state = cbUnChecked then Inc(CntUnCheck);
      Inc(Cnt);
      t := Node.GetNextChild(t);
    end;

    if Cnt>0 then begin
      if Cnt=CntCheck then state := cbChecked
       else
      if Cnt=CntUnCheck then state := cbUnChecked
       else state := cbGrayed;
      IntSetCheckState(Node, state, False);
    end;
  end;
end;

procedure TrsFormCfg.tvKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if (tv.Selected<>nil) then
   if (key=VK_SPACE) OR ((Key=VK_RETURN) AND (tv.Selected.Count=0))
    then ToggleCheckState(tv.Selected);
end;

procedure TrsFormCfg.tvMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
  Node: TTreeNode;
begin
  if Button=mbRight then begin
    Node := tv.GetNodeAt(X, Y);
    if Node<>nil then Node.Selected := True;
  end else begin
    Node := tv.GetNodeAt(X, Y);
    if (Node<>nil) AND (htOnIcon in tv.GetHitTestInfoAt(X,Y)) then ToggleCheckState(Node);
  end;
end;

procedure TrsFormCfg.tvMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
begin
  if (tv.GetNodeAt(X, Y)<>nil) AND (htOnIcon in tv.GetHitTestInfoAt(X,Y))
   then tv.Cursor := crHandPoint
   else tv.Cursor := crDefault;
end;

procedure TrsFormCfg.miViewByClassClick(Sender: TObject);
begin
  View := TrsFormCfgView((Sender as TMenuItem).Tag);
end;

procedure TrsFormCfg.pmViewPopup(Sender: TObject);
begin
  miViewByName.Checked := View = fvName;
  miViewByClass.Checked := View = fvClass;
end;

procedure TrsFormCfg.RefreshTVChecks;
var
  i: integer;
  s: string;
  t: TTreeNode;
begin
  OnChangeCheckState := nil;
  for i:=0 to lv.Items.Count-1 do begin
    s := lv.Items[i].Caption;
    t := FindNodeEx(s);
    if t<>nil then CheckState[t] := cbChecked;
  end;
  OnChangeCheckState := ClickTVCheck;
end;

procedure TrsFormCfg.ClickTVCheck(Sender: TObject; Node: TTreeNode);
var
  Prop: TrsProperty;
begin
  case CheckState[Node] of
    cbUnchecked : LVDelete(NodeName(Node));
    cbChecked   : if Node.Count=0 then begin
                    Prop := TrsProperty.Create;
                    Prop.AsString := NodeName(Node);
                    if Node.Data=Pointer(cTVCustomProperty)
                     then Prop.PropType := ptCustom;
                    LVAdd(Prop);
                  end;
  end;
end;


procedure TrsFormCfg.RefreshToolBar;
begin
  tbMoveUp.Enabled := (lv.Selected<>nil) and (lv.Selected.Index>0);
  tbMoveDown.Enabled := (lv.Selected<>nil) and (lv.Selected.Index<(lv.Items.Count-1));
  tbDelete.Enabled := lv.Selected<>nil;
  tbModify.Enabled := tbDelete.Enabled;
end;

procedure TrsFormCfg.tbMoveUpClick(Sender: TObject);
begin
  with lv do
    if (Selected<>nil) and (Selected.Index>0) then begin
      LVItemExchange(-1);
      RefreshToolBar;
    end;
end;

procedure TrsFormCfg.tbMoveDownClick(Sender: TObject);
begin
  with lv do
    if (Selected<>nil) and (Selected.Index<(Items.Count-1)) then begin
      LVItemExchange(1);
      RefreshToolBar;
    end;
end;


function TrsFormCfg.LVAdd(Prop: TrsProperty): TListItem;
begin
  Result := lv.Items.Add;
  Result.Caption := Prop.Name;
  Result.Data := Prop;
  ListItemState[Result] := ListItemState[Result];
end;

procedure TrsFormCfg.LVDelete(const Value: string);
var li: TListItem;
begin
  li := lv.FindCaption(0, Value, False, True, False);
  if li<>nil then li.Delete;
end;

procedure TrsFormCfg.lvChange(Sender: TObject; Item: TListItem; Change: TItemChange);
begin
  if Change=ctState then begin
    TimerLVChange.Enabled := False;
    TimerLVChange.Enabled := True;
  end;
end;

procedure TrsFormCfg.lvDblClick(Sender: TObject);
var
  Node: TTreeNode;
  P: TPoint;
begin
  if (lv.Selected<>nil) or (Sender=nil) then begin
    GetCursorPos(P);
    P := lv.ScreenToClient(P);
    if not lvGetHitTestInfoAt(P.X, P.Y) then begin
      Node := FindNodeEx(lv.Selected.Caption);
      if Node<>nil then begin
        Node.MakeVisible;
        tv.Selected := Node;
        tv.SetFocus;
      end;
    end;
  end;
end;

procedure TrsFormCfg.lvEnter(Sender: TObject);
begin
  RefreshStatusBar;
  RefreshToolBar;
end;

procedure TrsFormCfg.lvKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if ((Key=VK_F2) or (Key=VK_RETURN)) and (Shift=[]) and (lv.Selected<>nil) and (not lv.IsEditing)
   then tbModify.Click
   else
  if (Key=VK_SPACE) and (Shift=[]) and (not lv.IsEditing) then lv.OnDblClick(nil)
   else
  if (Key=VK_DELETE) and (Shift=[]) and (not lv.IsEditing) then tbDelete.Click
   else
  if (Key=VK_INSERT) and (Shift=[]) and (not lv.IsEditing) then tbAdd.Click
   else
  if (Shift = [ssCtrl]) and (not lv.IsEditing) then begin
   if (key=VK_UP) and tbMoveUp.Enabled then begin
    tbMoveUpClick(self);
    Key := 0;
   end else
   if (key=VK_DOWN) and tbMoveDown.Enabled then begin
    tbMoveDownClick(self);
    Key := 0;
   end else;
  end;
end;

procedure TrsFormCfg.tvEnter(Sender: TObject);
begin
  tvChange(self, nil);
end;

procedure TrsFormCfg.LVItemExchange(const Direction: integer);
var
  s: string;
  i: integer;
  li1,li2: TListItem;
begin
  li1 := lv.Selected;
  if lv.IsEditing then li1.CancelEdit;
  i := li1.Index;
  li2 := lv.Items[i+Direction];

  s := li1.Caption;       li1.Caption := li2.Caption;       li2.Caption := s;
  i := Integer(li1.Data); li1.Data := li2.Data;             li2.Data := Pointer(i);
  i := li1.StateIndex;    li1.StateIndex := li2.StateIndex; li2.StateIndex := i;

  li2.Selected := True;
  li2.Focused := True;
  lv.Selected.MakeVisible(False);
end;

procedure TrsFormCfg.lvMouseMove(Sender: TObject; Shift: TShiftState; X,Y: Integer);
begin
  if lvGetHitTestInfoAt(X,Y) and (not ListItemErrorState[lv.GetItemAt(X,Y)])
   then lv.Cursor := crHandPoint
   else lv.Cursor := crDefault;
end;

{$IFDEF RSL_CB3LE}
function TrsFormCfg.lvGetHitTestInfoAt(X, Y: Integer): boolean;
var
  HitTest: TLVHitTestInfo;
begin
  with HitTest do begin
    pt.X := X;
    pt.Y := Y;
    ListView_HitTest(lv.Handle, HitTest);
    Result := (flags = LVHT_ONITEMSTATEICON);
  end;
end;
{$ELSE}
function TrsFormCfg.lvGetHitTestInfoAt(X, Y: Integer): boolean;
begin
  Result := htOnStateIcon in lv.GetHitTestInfoAt(X,Y);
end;
{$ENDIF}


procedure TrsFormCfg.lvMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
  li: TListItem;
begin
  if lv.Cursor = crHandPoint then begin
    li := lv.GetItemAt(X,Y);
    if li<>nil then begin
      li.Selected := True;
      li.Focused := True;
      ToggleState;
    end;
  end;
end;

procedure TrsFormCfg.ToggleState;
begin
  if lv.Selected<>nil then begin
    if not TrsProperty(lv.Selected.Data).Enabled
     then begin
       TrsProperty(lv.Selected.Data).Enabled := True;
       ListItemState[lv.Selected] := psNormal;
     end else
      case ListItemState[lv.Selected] of
        psNormal:   ListItemState[lv.Selected] := psRead;
        psRead:     ListItemState[lv.Selected] := psWrite;
        psWrite:    begin
                     TrsProperty(lv.Selected.Data).Enabled := False;
                     ListItemState[lv.Selected] := psNormal;
                    end;
      end;
  end;
end;


function TrsFormCfg.FindNodeEx(const Value: string): TTreeNode;
var
  s: string;
  IdxBegin,IdxEnd: integer;
  Node,Node1 : TTreeNode;
begin
  Result := tv.Items.GetFirstNode;
  if Result=nil then Exit;
  if Value='' then begin Result := nil; Exit; end;

  Node1 := nil;
  IdxBegin := 1;
  While True do begin
    for IdxEnd:= IdxBegin to Length(Value) do
     if Value[IdxEnd]='.' then Break;

    s := Copy(Value, IdxBegin, IdxEnd-IdxBegin);

    if (IdxBegin=1) and (View=fvClass) then begin
      Node := Result.getFirstChild;
      While Node<>nil do begin
        Node1 := Node.getFirstChild;
        While (Node1<>nil) and (CompareText(Node1.Text, s)<>0) do
         Node1 := Node.GetNextChild(Node1);
        if Node1<>nil then Break
         else Node := Result.GetNextChild(Node);
      end;
    end;

    if (IdxBegin=1) and (Node1<>nil) then Result := Node1
     else begin
       Node := Result.getFirstChild;
       While (Node<>nil) and (CompareText(Node.Text, s)<>0) do
          Node := Result.GetNextChild(Node);
       Result := Node;
     end;

    if (IdxEnd>=Length(Value)) OR (Result=nil) then Break else IdxBegin := IdxEnd+1;
  end;
end;

function TrsFormCfg.LVFind(const Value: string; const Partial: boolean): TListItem;
begin
  Result := lv.FindCaption(0, Value, Partial, True, False);
end;

procedure TrsFormCfg.FormStateLoad;
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
     Width := tbSeparator.Width + tbView.Width*8 + 14;
     Position := poScreenCenter;
   end;

begin
if RegOpenKeyEx(HKEY_CURRENT_USER, SRSProductKey, 0, KEY_READ, Key) <> ERROR_SUCCESS
 then SetDefaultPosition
 else
   try
     vLeft := RegReadInteger('Left', -1);
     vTop  := RegReadInteger('Top', -1);
     vWidth := RegReadInteger('Width', -1);
     vHeight := RegReadInteger('Height', -1);
     if (vLeft>=0) and (vTop>=0) and (vWidth>0) and (vHeight>0) then begin
        Position := poDesigned;
        SetBounds(vLeft, vTop, vWidth, vHeight);
     end else SetDefaultPosition;

     pnlLeft.Width := RegReadInteger('Splitter', pnlLeft.Width);
     View := TrsFormCfgView(RegReadInteger('ViewType', 0));
     if RegReadInteger('ButtonCaption', 1)=0 then miTextLabels.Click;
     if RegReadInteger('ShowInfo', 0)=1 then tbInfo.Click;
   finally
     RegCloseKey(Key);
   end;
end;

procedure TrsFormCfg.FormStateSave;
var
  Key: HKey;
  Value: longint;
begin
  if RegCreateKeyEx(HKEY_CURRENT_USER, SRSProductKey, 0, nil, REG_OPTION_NON_VOLATILE, KEY_WRITE, nil, Key, nil) = ERROR_SUCCESS then
   try
     Value := Left;
     RegSetValueEx(Key, 'Left', 0, REG_DWORD, @Value, SizeOf(Value));
     Value := Top;
     RegSetValueEx(Key, 'Top', 0, REG_DWORD, @Value, SizeOf(Value));
     Value := Width;
     RegSetValueEx(Key, 'Width', 0, REG_DWORD, @Value, SizeOf(Value));
     Value := Height;
     RegSetValueEx(Key, 'Height', 0, REG_DWORD, @Value, SizeOf(Value));
     Value := pnlLeft.Width;
     RegSetValueEx(Key, 'Splitter', 0, REG_DWORD, @Value, SizeOf(Value));
     Value := Integer(View);
     RegSetValueEx(Key, 'ViewType', 0, REG_DWORD, @Value, SizeOf(Value));
     Value := Integer(tbrMain.ShowCaptions);
     RegSetValueEx(Key, 'ButtonCaption', 0, REG_DWORD, @Value, SizeOf(Value));
     Value := Integer(ShowInfo);
     RegSetValueEx(Key, 'ShowInfo', 0, REG_DWORD, @Value, SizeOf(Value));
   finally
     RegCloseKey(Key);
   end;
end;


procedure TrsFormCfg.miTextLabelsClick(Sender: TObject);
begin
  tbrMain.ShowCaptions := not tbrMain.ShowCaptions;
  if tbrMain.ShowCaptions then begin
  end else begin
    tbrMain.ButtonHeight := 23;
    tbrMain.ButtonWidth := 24;
  end;
{$IFDEF RSL_CB3LE}
  Realign;
{$ENDIF}
end;

procedure TrsFormCfg.pmButtonCaptionsPopup(Sender: TObject);
begin
  miTextLabels.Checked := tbrMain.ShowCaptions;
end;

function TrsFormCfg.TemplatesFileName: string;
var
  Len: integer;
begin
  SetLength(Result, 255);
  Len := GetWindowsDirectory(PChar(Result), 255);
  SetLength(Result, Len);
  if (Len>0) and (Result[Len]<>'\') then Result := Result + '\';
  Result := Result + SRSTemplatesFileName;
end;

procedure TrsFormCfg.TemplatesLoad;
var
  FileName: string;
begin
  FTemplates.Clear;
  FileName := TemplatesFileName;
  if FileExists(FileName) then FTemplates.LoadFromFile(FileName);
end;

procedure TrsFormCfg.TemplatesSave;
begin
  FTemplates.SaveToFile(TemplatesFileName);
end;

procedure TrsFormCfg.pmTemplatePopup(Sender: TObject);
var
  mi: TMenuItem;
  i,j: integer;
  s: string;
begin
  with pmTemplate do begin
    While Items.Count>3 do Items.Delete(0);
    j := 0;
    for i:=0 to FTemplates.Count-1 do begin
      s := FTemplates[i];
      if TemplGetCaption(s) and TemplApproach(i, tv.Selected) then begin
        mi := TMenuItem.Create(self);
        mi.Caption := s;
        mi.Tag := i;
        mi.OnClick := TemplateClick;
        pmTemplate.Items.Insert(j, mi);
        Inc(j);
      end;
    end;
  end;
  miTemplsSaveAs.Enabled := tv.Focused and (tv.Selected<>nil) and (sbrMain.Panels[0].Text='Class') and (CheckState[tv.Selected]<>cbUnchecked);
end;

function TrsFormCfg.TemplApproach(const Index: integer; Node: TTreeNode): boolean;
var
  i: integer;
begin
  Result := False;
  i := Index+1;
  While (i<FTemplates.Count) and (FTemplates[i]<>'') do begin
    Result := FindNode(Node, FTemplates[i])<>nil;
    if not Result then Break;
    Inc(i);
  end;
end;


function TrsFormCfg.TemplGetCaption(var Value: string): boolean;
begin
  Result := (Length(Value)>1) and (Value[1]='[') and (Value[Length(Value)]=']');
  if Result then Value := Copy(Value, 2, Length(Value)-2);
end;

procedure TrsFormCfg.TemplateClick(Sender: TObject);
var
  i:integer;
  Node,Node1: TTreeNode;
begin
  Node := tv.Selected;
  if Node=nil then Exit;
  i := (Sender as TMenuItem).Tag+1;
  CheckState[Node] := cbUnchecked;

  While (i<FTemplates.Count) and (FTemplates[i]<>'') do begin
    Node1 := FindNode(Node, FTemplates[i]);
    if Node1<>nil then CheckState[Node1] := cbChecked;
    Inc(i);
  end;
end;


function TrsFormCfg.FindNode(Node: TTreeNode; const Value: string): TTreeNode;
var
  s: string;
  IdxBegin,IdxEnd: integer;
  tn: TTreeNode;
begin
  Result := Node;
  if Result=nil then Exit;
  if Value='' then begin Result := nil; Exit; end;
  IdxBegin := 1;

  While True do begin
    for IdxEnd:=IdxBegin to Length(Value) do
     if Value[IdxEnd]='.' then Break;

    s := Copy(Value, IdxBegin, IdxEnd-IdxBegin);

    tn := Result.getFirstChild;
    While tn<>nil do begin
      if tn.Text=s then Break;
      tn := Result.GetNextChild(tn);
    end;
    Result := tn;
    if (IdxEnd>=Length(Value)) OR (Result=nil) then Break else IdxBegin := IdxEnd+1;
  end;
end;


procedure TrsFormCfg.miTemplsSaveAsClick(Sender: TObject);
var
  s,s1: string;
  i,Len: integer;
begin
  s := '';
  if not InputQuery('Save current properties as template','Enter template name',s) then Exit;

  FTemplates.Add('');
  FTemplates.Add('['+s+']');
  s := NodeName(tv.Selected)+'.';
  Len := Length(s);
  for i:=0 to lv.Items.Count-1 do
   if StrLIComp(PChar(s), PChar(lv.Items[i].Caption), Len)=0 then begin
     s1 := lv.Items[i].Caption;
     FTemplates.Add(Copy(s1, Len+1, Length(s1)-Len));
   end;

  TemplatesSave;
end;

procedure TrsFormCfg.miTemplsCustomizeClick(Sender: TObject);
var
  f: TrsFormTempl;
begin
  f := TrsFormTempl.Create(Self);
  try
    f.Templates := FTemplates;
    if f.ShowModal=mrYes then begin
      FTemplates.Assign(f.Templates);
      TemplatesSave;
    end;
  finally
    f.Free;
  end;
end;

procedure TrsFormCfg.SetPropSaver(const Value: TrsPropSaver);
begin
  if FPropSaver <> Value then begin
    FPropSaver := Value;
    if FPropSaver<>nil then begin
      FForm := FPropSaver.Owner as TComponent;
      FProps.Assign(PropSaver.Properties);
      LoadTV;
    end;
  end;
end;

{$IFNDEF RSL_CB3LE}
procedure TrsFormCfg.tvCustomDrawItem(Sender: TCustomTreeView;
  Node: TTreeNode; State: TCustomDrawState; var DefaultDraw: Boolean);
begin
  if Node.Data=Pointer(cTVCustomProperty) then begin
    if cdsSelected in State
     then Sender.Canvas.Font.Color := clWhite
     else Sender.Canvas.Font.Color := clNavy;
    Sender.Canvas.Font.Style := [fsBold];
  end;
end;

procedure TrsFormCfg.lvCustomDrawItem(Sender: TCustomListView;
  Item: TListItem; State: TCustomDrawState; var DefaultDraw: Boolean);
begin
  if Item.Data<>nil then
    case Trsproperty(Item.Data).PropType of
      ptUser:
        begin
          Sender.Canvas.Font.Color := clGreen;
          Sender.Canvas.Font.Style := [fsBold];
        end;
      ptCustom:
        begin
          Sender.Canvas.Font.Color := clNavy;
          Sender.Canvas.Font.Style := [fsBold];
        end;
      ptVariable:
        begin
          Sender.Canvas.Font.Color := clPurple;
          Sender.Canvas.Font.Style := [fsBold];
        end;
    end;
end;
{$ENDIF}



function TrsFormCfg.GetItemState(ListItem: TListItem): TrsPropertyState;
begin
  if (ListItem=nil) or (ListItem.Data=nil) then Result := psNormal
   else Result := TrsProperty(ListItem.Data).State;
end;

procedure TrsFormCfg.SetItemState(ListItem: TListItem; const Value: TrsPropertyState);
begin
  TrsProperty(ListItem.Data).State := Value;
  if not TrsProperty(ListItem.Data).Enabled then ListItem.StateIndex := cImgIdxDisable
   else
    case Value of
      psNormal: ListItem.StateIndex := -1;
      psRead:   ListItem.StateIndex := cImgIdxRead;
      psWrite:  ListItem.StateIndex := cImgIdxWrite;
    end;
end;

function TrsFormCfg.GetItemErrorState(ListItem: TListItem): boolean;
begin
  Result := (ListItem<>nil) and (TrsProperty(ListItem.Data).ExtFlags and cMaskError>0);
end;

procedure TrsFormCfg.SetItemErrorState(ListItem: TListItem; const Value: boolean);
begin
  if ListItem<>nil then begin
    if Value then begin
      with TrsProperty(ListItem.Data) do ExtFlags := ExtFlags or cMaskError;
      ListItem.StateIndex := cImgIdxError;
    end else begin
      with TrsProperty(ListItem.Data) do ExtFlags := ExtFlags and (not cMaskError);
      ListItemState[ListItem] := ListItemState[ListItem];
    end;
  end;
end;

procedure TrsFormCfg.lvEdited(Sender: TObject; Item: TListItem; var S: String);
var
  Node: TTreeNode;
begin
  if CompareText(Item.Caption, S)=0 then Exit;
  Node := FindNodeEx(S);

  if Node<>nil then begin
    if ListItemErrorState[Item] then ListItemErrorState[Item] := False;

    if Node.Data=Pointer(cTVCustomProperty) then ListItemType[Item] := ptCustom
     else ListItemType[Item] := ptPublished;
    S := NodeName(Node);
  end else begin
    if not (ListItemType[Item] in [ptUser,ptVariable]) then begin
      ListItemType[Item] := ptUser;
      ListItemErrorState[Item] := False;
    end;
  end;
  TrsProperty(Item.Data).Name := S;

  OnChangeCheckState := nil;
  if Node<>nil then CheckState[Node] := cbChecked;
  Node := FindNodeEx(Item.Caption);
  if Node<>nil then CheckState[Node] := cbUnChecked;
  OnChangeCheckState := ClickTVCheck;
  RefreshStatusBar;
  RefreshToolBar;
  RefreshInfo(True);
end;


procedure TrsFormCfg.LVSelectNearest(const Index: integer);
begin
  if (lv.Items.Count>0) and (Index>=0) then begin
    if lv.Items.Count<=Index then lv.Selected := lv.Items[lv.Items.Count-1]
     else lv.Selected := lv.Items[Index];
    lv.Selected.Focused := True;
  end;
end;

procedure TrsFormCfg.lvResize(Sender: TObject);
const
  cRightMargin = 9;
var
  i: integer;
begin
  lv.Columns[0].Width := lv.ClientWidth-GetSystemMetrics(SM_CXVSCROLL);
  i := pnlInfo.Width - cRightMargin;
  cbInfoType.Width := i - cbInfoType.Left;
  cbInfoState.Width := i - cbInfoState.Left;
  edInfoDef.Width := i - edInfoDef.Left;
  cbxEncrypt.Left := i - cbxEncrypt.Width;
  edInfoSubstName.Width := i - edInfoSubstName.Left;
end;


procedure TrsFormCfg.tbDeleteClick(Sender: TObject);
var
  Node: TTreeNode;
  i: integer;
begin
if lv.Selected<>nil then
  if MessageDlg('Delete "'+lv.Selected.Caption+'" property ?', mtConfirmation, [mbYes,mbNo], 0)=MRYES then begin
    i := lv.Selected.Index;
    Node := FindNodeEx(lv.Selected.Caption);
    if Node<>nil then CheckState[Node] := cbUnchecked
     else lv.Selected.Delete;
    LVSelectNearest(i);
  end;
end;

procedure TrsFormCfg.tbAddClick(Sender: TObject);
Const
  NewName = '--------';
var
  li: TListItem;
begin
  lv.SetFocus;
  li := lv.Items.Add;
  li.Data := TrsProperty.Create;
  li.Caption := NewName;
  li.Selected := True;
  li.Focused := True;
  li.MakeVisible(False);
  li.EditCaption;
end;

procedure TrsFormCfg.tbModifyClick(Sender: TObject);
begin
  lv.Selected.EditCaption;
end;


procedure TrsFormCfg.tbInfoClick(Sender: TObject);
begin
  ShowInfo := not ShowInfo;
end;

procedure TrsFormCfg.RefreshInfo(const IfShowInfo: boolean);
var
  li: TListItem;
begin
  if IfShowInfo and (Not ShowInfo) then Exit;

  li := lv.Selected;
  if li<>nil then begin
    cbInfoType.ItemIndex := Integer(ListItemType[li]);
    if (li.Data<>nil) and (not TrsProperty(li.Data).Enabled)then cbInfoState.ItemIndex := 3
     else cbInfoState.ItemIndex := Integer(ListItemState[li]);
    edInfoDef.Text := ListItemDefValue[li];
    edInfoSubstName.Text := ListItemSubstName[li];
    cbxEncrypt.Checked := (li.Data<>nil) and TrsProperty(li.Data).StoreEncrypted;
  end else begin
    cbInfoType.ItemIndex := -1;
    cbInfoState.ItemIndex := -1;
    edInfoDef.Text := '';
    edInfoSubstName.Text := '';
    cbxEncrypt.Checked := False;
  end;
end;

procedure TrsFormCfg.TimerLVChangeTimer(Sender: TObject);
begin
  TimerLVChange.Enabled := False;
  RefreshStatusBar;
  RefreshToolBar;
  RefreshInfo(True);
end;

procedure TrsFormCfg.cbInfoStateChange(Sender: TObject);
var
  li: TListItem;
begin
  li := lv.Selected;
  if li<>nil then begin
    if cbInfoState.ItemIndex=3
      then begin
        TrsProperty(li.Data).Enabled := False;
        ListItemState[li] := psNormal;
      end else
    if cbInfoState.ItemIndex>=0
      then ListItemState[li] := TrsPropertyState(cbInfoState.ItemIndex)
      else ListItemState[li] := psNormal;
  end;
end;

function TrsFormCfg.IsInfoFocused: boolean;
var
  Control: TWinControl;
begin
  Control := ActiveControl;
  Result := (Control=cbInfoType) or (Control=cbInfoState) or (Control=edInfoDef) or
            (Control=edInfoSubstName) or (Control=cbxEncrypt);
end;

function TrsFormCfg.GetItemType(ListItem: TListItem): TrsPropertyType;
begin
  if (ListItem=nil) or (ListItem.Data=nil) then Result := ptPublished
   else Result := TrsProperty(ListItem.Data).PropType;
end;


procedure TrsFormCfg.SetItemType(ListItem: TListItem; const Value: TrsPropertyType);
var
  old: TrsPropertyType;
  Node: TTreeNode;
begin
  if ListItem<>nil then begin
    old := GetItemType(ListItem);
    if old = Value then Exit;
    if old in [ptPublished,ptCustom] then begin //uncheck Tree
      Node := FindNodeEx(ListItem.Caption);
      if Node<>nil then begin
        OnChangeCheckState := nil;
        CheckState[Node] := cbUnChecked;
        OnChangeCheckState := ClickTVCheck;
      end;
    end;
    TrsProperty(ListItem.Data).PropType := Value;

    if Value in [ptPublished,ptCustom] then begin //check Tree
      if not lv.IsEditing then begin
        Node := FindNodeEx(ListItem.Caption);
        if Node<>nil then begin
          OnChangeCheckState := nil;
          CheckState[Node] := cbChecked;
          OnChangeCheckState := ClickTVCheck;
          ListItemErrorState[ListItem] := False;
        end else ListItemErrorState[ListItem] := True;
      end;
    end else ListItemErrorState[ListItem] := False;
  end;
end;

procedure TrsFormCfg.cbInfoTypeChange(Sender: TObject);
begin
  if cbInfoType.ItemIndex<3//4
    then ListItemType[lv.Selected] := TrsPropertyType(cbInfoType.ItemIndex)
    else ListItemType[lv.Selected] := ptPublished;
end;

function TrsFormCfg.GetItemDefValue(ListItem: TListItem): string;
begin
 if (ListItem<>nil) and (ListItem.Data<>nil)
  then Result := TrsProperty(ListItem.Data).DefValue;
end;


procedure TrsFormCfg.SetItemDefValue(ListItem: TListItem; const Value: string);
begin
  if (ListItem<>nil) and (ListItem.Data<>nil)
   then TrsProperty(ListItem.Data).DefValue := Value;
end;

procedure TrsFormCfg.edInfoDefChange(Sender: TObject);
begin
  ListItemDefValue[lv.Selected] := edInfoDef.Text;
end;

procedure TrsFormCfg.lvDeletion(Sender: TObject; Item: TListItem);
begin
  TrsProperty(Item.Data).Free;
  Item.Data := nil;
end;

procedure TrsFormCfg.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if (Key=VK_ESCAPE) and (Shift=[]) then Close;
end;

procedure TrsFormCfg.tbViewClick(Sender: TObject);
{$IFDEF RSL_CB3LE}
var Rect: TRect;
{$ENDIF}
begin
{$IFDEF RSL_CB3LE}
  Rect := tbView.BoundsRect;
  Rect.TopLeft :=  ClientToScreen(Rect.TopLeft);
  Rect.BottomRight := ClientToScreen(Rect.BottomRight);
  pmView.Popup(Rect.Left, Rect.Bottom);
{$ELSE}
  tbView.CheckMenuDropdown;
{$ENDIF}
end;


procedure TrsFormCfg.tbTemplateClick(Sender: TObject);
{$IFDEF RSL_CB3LE}
var Rect: TRect;
{$ENDIF}
begin
{$IFDEF RSL_CB3LE}
  Rect := tbTemplate.BoundsRect;
  Rect.TopLeft :=  ClientToScreen(Rect.TopLeft);
  Rect.BottomRight := ClientToScreen(Rect.BottomRight);
  pmTemplate.Popup(Rect.Left, Rect.Bottom);
{$ELSE}
  tbTemplate.CheckMenuDropdown;
{$ENDIF}
end;

procedure TrsFormCfg.GetEncryptList;
var
  i: integer;
  sPref,s,s1: string;
  prop: TrsProperty;
  encr: TrsEncryptor;
begin
  FEncryptList.Clear;
  if (PropSaver<>nil) and (PropSaver.Storage<>nil) then begin
    encr := PropSaver.Storage.Encryptor;
    if not Assigned(encr) then Exit;

    sPref := PropSaver.PreparedRootSection;

    for i:=0 to encr.EncryptKeys.Count-1 do begin
      s := encr.EncryptKeys[i];
      if (Length(s)>0) and (not (s[1] in cSectionSeparators)) then s := '\' + s;
      if StrLIComp(PChar(sPref), PChar(s), Length(sPref))=0 then begin
        s1 := Copy(s, Length(sPref)+1, 255);
        prop := PropertyFindByName(s1);
        if prop<>nil then begin
          prop.StoreEncrypted := True;
          FEncryptList.Add(s);
        end;
      end;
    end;
  end;
end;

procedure TrsFormCfg.cbxEncryptClick(Sender: TObject);
var
  ListItem: TListItem;
begin
 ListItem := lv.Selected;
 if (ListItem<>nil) and (ListItem.Data<>nil) then
   TrsProperty(ListItem.Data).StoreEncrypted := cbxEncrypt.Checked;
end;

procedure TrsFormCfg.SetEncryptList;
var
  i,k: integer;
  s,sPref: string;
  encr: TrsEncryptor;
begin
  if (PropSaver<>nil) and (PropSaver.Storage<>nil) then begin
    encr := PropSaver.Storage.Encryptor;
    if not Assigned(encr) then Exit;

    sPref := PropSaver.PreparedRootSection;

    for i:=0 to lv.Items.Count-1 do
      if TrsProperty(lv.Items[i].Data).StoreEncrypted then begin
        s := sPref + TrsProperty(lv.Items[i].Data).NameInData; //23.12.2001
        k := FEncryptList.IndexOf(s);
        if k>=0 then FEncryptList.Delete(k)
         else
        if  encr.EncryptKeys.IndexOf(s)<0
         then encr.EncryptKeys.Add(s);
      end;

    While FEncryptList.Count>0 do begin
      s := FEncryptList.Strings[0];
      k := encr.EncryptKeys.IndexOf(s);
      if (k<0) and (Length(s)>0) and (s[1] in cSectionSeparators) then begin
        Delete(s, 1, 1);
        k := encr.EncryptKeys.IndexOf(s);
      end;
      if k>=0 then encr.EncryptKeys.Delete(k);
      FEncryptList.Delete(0);
    end;
  end;
end;

(*
function  TrsformCfg.LVFindByRealName(const Value: string): TListItem;
var
  i: integer;
  s: string;
begin
  i := Pos('.', Value);
  if i>0 then s := Copy(Value, 1, i-1)
   else s := Value;
  if (Length(s)>0) and (GetPropInfo(FForm.ClassInfo,s)<>nil)
   then s := FForm.Name+'.'+Value
   else s := Value;

  Result := LVFind(s, False);
end;*)


procedure TrsFormCfg.lvEditing(Sender: TObject; Item: TListItem; var AllowEdit: Boolean);
begin
  AllowEdit := True;
end;

function TrsFormCfg.GetItemSubstName(ListItem: TListItem): string;
begin
 if (ListItem<>nil) and (ListItem.Data<>nil)
  then Result := TrsProperty(ListItem.Data).SubstName;
end;

procedure TrsFormCfg.SetItemSubstName(ListItem: TListItem; const Value: string);
begin
  if (ListItem<>nil) and (ListItem.Data<>nil)
   then TrsProperty(ListItem.Data).SubstName := Value;
end;

procedure TrsFormCfg.edInfoSubstNameChange(Sender: TObject);
begin
  ListItemSubstName[lv.Selected] := edInfoSubstName.Text;
end;

function TrsFormCfg.PropertyFindByName(const Value: string): TrsProperty;
var
  i: integer;
begin
  for i:=0 to lv.Items.Count-1 do
    if (lv.Items[i].Data<>nil) and (TrsProperty(lv.Items[i].Data).NameInData=Value)
      then begin
        Result := lv.Items[i].Data;
        Exit;
      end;
  Result := nil;
end;

end.


