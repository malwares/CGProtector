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
unit rsPropSaverForm;

interface

{$I rsStorage.inc}

{.$DEFINE RSL_DLGTEST}
{.$DEFINE rsl_trace}

{$IFNDEF RSL_KYLIX}
  {$DEFINE RSL_TEMPLATES}
{$ENDIF}


uses
  SysUtils, Classes, TypInfo, IniFiles, {$IFNDEF RSL_DLGTEST}DeskUtil, {$ENDIF}
  {$ifdef rsl_trace}ursprofiler,{$endif}
  {$IFDEF RSL_KYLIX}
  Types,  QGraphics, QControls, QForms, QDialogs, QStdCtrls, QExtCtrls, QComCtrls,
  QImgList, QMenus, QTypes, QT,
  {$ELSE}
  Forms, Windows, Dialogs, ExtCtrls, Menus, ImgList, Controls, ComCtrls, StdCtrls,
  ToolWin, Graphics,
  {$ENDIF}
  {$IFDEF RSL_TEMPLATES}
  rsPropSaverTemplates,
  {$ENDIF}
  rsConst, rsStorage, rsPropSaver, rsProperty;

type
  TrsFormCfgView = (fvName, fvClass, fvProperty);

  TrsPropSaverForm = class(TForm)
    tbr: TToolBar;
    pnlLeft: TPanel;
    lblTree: TLabel;
    tv: TTreeView;
    sbr: TStatusBar;
    splVert: TSplitter;
    splHorz: TSplitter;
    pnlRight: TPanel;
    lblList: TLabel;
    pnlInfo: TPanel;
    lblName: TLabel;
    edInfoSubstName: TEdit;
    lblType: TLabel;
    cbInfoType: TComboBox;
    lblState: TLabel;
    cbInfoState: TComboBox;
    lblDefValue: TLabel;
    edInfoDef: TEdit;
    cbxEncrypt: TCheckBox;
    lv: TListView;
    tbView: TToolButton;
    tbTemplate: TToolButton;
    tbSeparator: TToolButton;
    tbUp: TToolButton;
    tbDown: TToolButton;
    tbAdd: TToolButton;
    tbDelete: TToolButton;
    tbModify: TToolButton;
    tbInfo: TToolButton;
    ilToolbar: TImageList;
    pmView: TPopupMenu;
    miViewByName: TMenuItem;
    miViewByClass: TMenuItem;
    miViewByProperty: TMenuItem;
    ilTree: TImageList;
    TimerListChange: TTimer;
    pmButtonCaptions: TPopupMenu;
    miTextLabels: TMenuItem;
    pmTemplate: TPopupMenu;
    N1: TMenuItem;
    miTemplsSaveAs: TMenuItem;
    miTemplsCustomize: TMenuItem;
    btnSaveLog: TButton;
    procedure splHorzMoved(Sender: TObject);
    procedure splVertCanResize(Sender: TObject; var NewSize: Integer; var Accept: Boolean);
    procedure splVertMoved(Sender: TObject);
    procedure tbViewClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure miViewByClick(Sender: TObject);
    procedure pmViewPopup(Sender: TObject);
    procedure tvMouseMove(Sender: TObject; Shift: TShiftState; X,Y: Integer);
    procedure tvMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure tbInfoClick(Sender: TObject);
    procedure tbUpClick(Sender: TObject);
    procedure tbDownClick(Sender: TObject);
    procedure tvChange(Sender: TObject; Node: TTreeNode);
    procedure lvEnter(Sender: TObject);
    procedure TimerListChangeTimer(Sender: TObject);
    procedure tbDeleteClick(Sender: TObject);
    procedure lvChange(Sender: TObject; Item: TListItem; Change: TItemChange);
    procedure lvDblClick(Sender: TObject);
    procedure lvDeletion(Sender: TObject; Item: TListItem);
    procedure lvEditing(Sender: TObject; Item: TListItem; var AllowEdit: Boolean);
{$IFDEF RSL_KYLIX}
    procedure lvEdited(Sender: TObject; Item: TListItem; var S: WideString);
{$ELSE}
    procedure lvEdited(Sender: TObject; Item: TListItem; var S: String);
{$ENDIF}
    procedure lvKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure edInfoSubstNameChange(Sender: TObject);
    procedure cbInfoTypeChange(Sender: TObject);
    procedure cbInfoStateChange(Sender: TObject);
    procedure edInfoDefChange(Sender: TObject);
    procedure cbxEncryptClick(Sender: TObject);
    procedure miTextLabelsClick(Sender: TObject);
    procedure tbAddClick(Sender: TObject);
    procedure tbModifyClick(Sender: TObject);
    procedure FormHide(Sender: TObject);
{$IFDEF RSL_WIN}
    procedure tvCustomDrawItem(Sender: TCustomTreeView; Node: TTreeNode;
      State: TCustomDrawState; var DefaultDraw: Boolean);
{$ENDIF}
    procedure pmButtonCaptionsPopup(Sender: TObject);
    procedure miTemplsSaveAsClick(Sender: TObject);
    procedure pmTemplatePopup(Sender: TObject);
    procedure tbTemplateClick(Sender: TObject);
    procedure miTemplsCustomizeClick(Sender: TObject);
    procedure tvKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
  private
    FView: TrsFormCfgView;
    FOnChangeCheck: TTVChangedEvent;
    FPropSaver: TrsPropSaver;
    FProps: TStrings;
    FForm: TComponent;
    FShowInfo: boolean;
    FEncryptList: TStringList;
    FOnSelectComponent: TNotifyEvent;
    FOldSelectedComponent: string;
{$IFDEF RSL_TEMPLATES}
    FTemplates: TrsPropSaverTemplates;
{$ENDIF}
    FNodesCache: TStringList;

    procedure SetView(const Value: TrsFormCfgView);
    function GetCheckState(Node: TTreeNode): TCheckBoxState;
    procedure SetCheckState(Node: TTreeNode; const Value: TCheckBoxState);
    procedure SetPropSaver(const Value: TrsPropSaver);
    function GetItemDefValue(ListItem: TListItem): string;
    function GetItemErrorState(ListItem: TListItem): boolean;
    function GetItemState(ListItem: TListItem): TrsPropertyState;
    function GetItemSubstName(ListItem: TListItem): string;
    function GetItemType(ListItem: TListItem): TrsPropertyType;
    procedure SetItemDefValue(ListItem: TListItem; const Value: string);
    procedure SetItemErrorState(ListItem: TListItem; const Value: boolean);
    procedure SetItemState(ListItem: TListItem; const Value: TrsPropertyState);
    procedure SetItemSubstName(ListItem: TListItem; const Value: string);
    procedure SetItemType(ListItem: TListItem; const Value: TrsPropertyType);
    procedure ClickTVCheck(Sender: TObject; Node: TTreeNode);
    procedure SetShowInfo(const Value: boolean);
    function GetSelectedComponentName: string;
    procedure SetSelectedComponentName(const Value: string);
    procedure SetForm(const Value: TComponent);
{$ifdef rsl_trace} 
    procedure btnSaveLogClick(Sender: TObject);
{$endif}
    function GetPropName(PropInfo: PPropInfo): string;
  protected
    procedure ToolBarResizeButtons(Large: Boolean);
    procedure ToolBarRefresh;

    procedure TreeFill;
    procedure TreeAddProperty(ATypeInfo: PTypeInfo; Node: TTreeNode; AComponent: TObject; AName: string);

    function TreeAddComponent2(AComponent: TObject; const NamePrefix: string = ''): boolean;
    function TreeAddClass2(AComponent: TObject; ATypeInfo: PTypeInfo; const NamePrefix: string = ''): boolean;
    function TreeAddProp2(AComponent: TObject; PropInfo: PPropInfo): TTreeNode;
    function TreeFindAddProperty(const PropName: string): TTreeNode;
    function TreeCopyNode(SourceNode,DestNode: TTreeNode): integer;

    function  TreePrepareNode(Node: TTreeNode): TTreeNode;
    procedure TreeRefreshChecks;
    function  IsCursorInImage(Tree: TTreeView; X,Y:integer): boolean;
{$IFDEF RSL_TEMPLATES}
    function FindNode(Node: TTreeNode; const Value:string): TTreeNode;
{$ENDIF}
    function FindNodeEx(const Value: string): TTreeNode;
    function NodeName(Node: TTreeNode): string;
    procedure DoSelectComponent;

    procedure ListLoad;
    function  ListAdd(Prop: TrsProperty): TListItem;
    procedure ListDelete(const Value: string);
    function  ListFind(const Value: string; const Partial: boolean): TListItem;
    procedure ListItemExchange(const Direction: integer);
    procedure ListSelectNearest(const Index: integer);
    procedure ListSave;
    procedure ListClear;

    function GetIniFile: TCustomIniFile;
    procedure FormStateLoad;
    procedure FormStateSave;

{$IFDEF RSL_TEMPLATES}
    function  TemplateApproach(const Index: integer; Node: TTreeNode): boolean;
{$ENDIF}
    procedure TemplateClick(Sender: TObject);


    procedure CheckStateSet(Node: TTreeNode;const Value: TCheckBoxState; doChilds:boolean); virtual;
    procedure CheckStateVerify(Node: TTreeNode);
    procedure CheckStateToggle(Node: TTreeNode);

    procedure RefreshInfo(const IfShowInfo: boolean);
    procedure RefreshRightPanel;

    procedure GetEncryptList;
    procedure SetEncryptList;

    function PropertyFindByName(const Value:string): TrsProperty;

    property ListItemState[ListItem: TListItem]: TrsPropertyState read GetItemState write SetItemState;
    property ListItemType[ListItem: TListItem]: TrsPropertyType read GetItemType write SetItemType;
    property ListItemErrorState[ListItem: TListItem]: boolean read GetItemErrorState write SetItemErrorState;
    property ListItemDefValue[ListItem: TListItem]: string read GetItemDefValue write SetItemDefValue;
    property ListItemSubstName[ListItem: TListItem]: string read GetItemSubstName write SetItemSubstName;

    property CheckState[Node:TTreeNode]: TCheckBoxState read GetCheckState write SetCheckState;
    property View: TrsFormCfgView read FView write SetView;
    property ShowInfo: boolean read FShowInfo write SetShowInfo default False;
    property OnChangeCheckState : TTVChangedEvent read FOnChangeCheck write FOnChangeCheck;
  public
    property Form: TComponent read FForm write SetForm;
    property PropSaver: TrsPropSaver read FPropSaver write SetPropSaver;
    property OnSelectComponent: TNotifyEvent read FOnSelectComponent write FOnSelectComponent;
    property SelectedComponentName: string read GetSelectedComponentName write SetSelectedComponentName;
  end;


implementation

{$IFDEF RSL_KYLIX}
  {$R *.xfm}
{$ELSE}
  {$R *.dfm}
{$ENDIF}

uses rsProperties;

const
  SmallToolbarSize = 30;
  SmallButtonHeight = 23;
  SmallButtonWidth = 32;
  LargeToolbarSize = 44;
  LargeButtonHeight = 39;
  LargeButtonWidth = 53;

  CImgIdxCheckBlock = 0;
  cTVCustomProperty = $FFFFFFFE;
  cMaskError   = $00000040;


procedure TrsPropSaverForm.ToolBarResizeButtons(Large: Boolean);
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

procedure TrsPropSaverForm.SetView(const Value: TrsFormCfgView);
begin
  if FView <> Value then begin
    FView := Value;
    if tv.Items.Count<>0 then begin
      TreeFill;
      TreeRefreshChecks;
    end;
  end;
end;

procedure TrsPropSaverForm.splHorzMoved(Sender: TObject);
const
  cRightMargin = 6;
var
  i: integer;
begin
{$IFDEF RSL_WIN}
  lv.Columns[0].Width := lv.ClientWidth-GetSystemMetrics(SM_CXVSCROLL);
{$ENDIF}
  i := pnlInfo.Width - cRightMargin;
  cbInfoType.Width := i - cbInfoType.Left;
  cbInfoState.Width := i - cbInfoState.Left;
  edInfoDef.Width := i - edInfoDef.Left;
  cbxEncrypt.Left := i - cbxEncrypt.Width;
  edInfoSubstName.Width := i - edInfoSubstName.Left;
end;

procedure TrsPropSaverForm.splVertCanResize(Sender: TObject; var NewSize: Integer; var Accept: Boolean);
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

procedure TrsPropSaverForm.splVertMoved(Sender: TObject);
begin
  ToolBarResizeButtons(tbr.Height >= LargeToolbarSize);
end;

procedure TrsPropSaverForm.tbViewClick(Sender: TObject);
var
  Rect: TRect;
begin
  Rect := tbView.BoundsRect;
  Rect.TopLeft :=  ClientToScreen(Rect.TopLeft);
  Rect.BottomRight := ClientToScreen(Rect.BottomRight);
  pmView.Popup(Rect.Left, Rect.Bottom);
end;

procedure TrsPropSaverForm.TreeAddProperty(ATypeInfo: PTypeInfo;
  Node: TTreeNode; AComponent: TObject; AName: string);
var
  TypeData: PTypeData;
  tnClass: TTreeNode;
  flTopComponent: boolean;
  PropInfo: PPropInfo;
  i: integer;

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
        TreeAddProperty(PropList^[i]^.PropType^, ZNode, ZComponent, GetPropName(PropList^[i]));

      {Add Custom Properties}
      if PropSaver.CustomProperties<>nil then
        with (PropSaver.CustomProperties as TrsCustomProperties).Properties do
          for i := 0 to Count-1 do
            if Items[i].IsSuitable(ZComponent) then
              tv.Items.AddChildObject(ZNode, Items[i].PropName, Pointer(cTVCustomProperty));
     finally
       FreeMem(PropList, NumProps*SizeOf(PPropInfo));
     end;
   end;

begin
  if Length(AName)=0 then Exit;
  flTopComponent := ATypeInfo=nil;
  if flTopComponent then ATypeInfo := AComponent.ClassInfo;

  TypeData := GetTypeData(ATypeInfo);
  with ATypeInfo^ do
    case Kind of
      tkUnknown :
        TreePrepareNode(tv.Items.AddChild(Node, 'Unknown ' + AName));

{$IFDEF RSL_INT64} tkInt64, {$ENDIF}
      tkVariant,
      tkEnumeration, tkSet, tkWChar,
      tkChar, tkFloat, tkInteger,
      tkString, tkLString, tkWString :
        TreePrepareNode(tv.Items.AddChildObject(Node, AName, AComponent));

      tkClass :
        begin
          if TypeData^.ClassType.InheritsFrom(TComponent) and not flTopComponent
            then begin
{$IFDEF RSL_D6GE}
              Node := TreePrepareNode(tv.Items.AddChildObject(Node, AName, AComponent));

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
              TreePrepareNode(tv.Items.AddChildObject(Node, AName, AComponent));
{$ENDIF}
            end else

          if TypeData^.ClassType.InheritsFrom(TCollection) then begin
            Node := TreePrepareNode(tv.Items.AddChildObject(Node, AName, AComponent));

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
              if tnClass=nil
               then Node := TreePrepareNode(tv.Items.AddChildObject(Node, AComponent.ClassName, nil))
               else Node := tnClass;
            end;
            Node := TreePrepareNode(tv.Items.AddChildObject(Node, AName, AComponent));

            //cache
            if AComponent<>nil then begin
              i := FNodesCache.IndexOf(AComponent.ClassName);
              if (i>=0) and flTopComponent then begin
                TreeCopyNode(TTreeNode(FNodesCache.Objects[i]), Node);
              end else begin
                if flTopComponent then
                  FNodesCache.AddObject(AComponent.ClassName, Node);

                if AComponent<>nil then begin
                  PropInfo := GetPropInfo(AComponent.ClassInfo, AName);
                  if (PropInfo<>nil) and (PropInfo^.PropType^.Kind=tkClass) then
                    AComponent := TObject(GetOrdProp(AComponent, PropInfo));
                end;

                AddPropList(ATypeInfo, Node, AComponent);
              end;
            end else AddPropList(ATypeInfo, Node, AComponent);
            //cache

{            if AComponent<>nil then begin
              PropInfo := GetPropInfo(AComponent.ClassInfo, AName);
              if (PropInfo<>nil) and (PropInfo^.PropType^.Kind=tkClass) then
                AComponent := TObject(GetOrdProp(AComponent, PropInfo));
            end;

            AddPropList(ATypeInfo, Node, AComponent);}
          end;
      end;
    end; {case}
end;

function TrsPropSaverForm.TreeAddClass2(AComponent: TObject; ATypeInfo: PTypeInfo; const NamePrefix: string = ''): boolean;
var
  sName: string;
  TypeData: PTypeData;
  NumProps,i: integer;
  PropList: PPropList;
  Node: TTreeNode;
begin
  Result := False;
  TypeData := GetTypeData(ATypeInfo);

  sName := NamePrefix;

  if Length(sName)=0 then Exit;

  NumProps :=  TypeData^.PropCount;
  Result := NumProps>0;
  GetMem(PropList, NumProps*SizeOf(PPropInfo));

   try
    GetPropInfos(ATypeInfo, PropList);
    for i:=0 to NumProps-1 do begin
      Node := TreeAddProp2(AComponent, PropList^[i]);
      if Node<>nil then begin
        TreePrepareNode(tv.Items.AddChildObject(Node, sName, nil));
      end;
    end;

   finally
     FreeMem(PropList, NumProps*SizeOf(PPropInfo));
   end;
end;

function TrsPropSaverForm.TreeFindAddProperty(const PropName: string): TTreeNode;
var
  i: integer;
begin
  i := FNodesCache.IndexOf(PropName);
  if i<0 then begin
    Result := TreePrepareNode(tv.Items.AddChildObject(tv.Items.GetFirstNode, PropName, nil));
    FNodesCache.AddObject(PropName, Result);
  end else
    Result := TTreeNode(FNodesCache.Objects[i])
{var
  zNode,zRoot: TTreeNode;
begin
  zRoot := tv.Items.GetFirstNode;
  zNode := zRoot.getFirstChild;
  while (zNode<>nil) and (zNode.Text<>PropName) do
    zNode := zRoot.GetNextChild(zNode);

  if zNode=nil
    then Result := TreePrepareNode(tv.Items.AddChildObject(zRoot, PropName, nil))
    else Result := zNode;}
end;

function TrsPropSaverForm.TreeAddProp2(AComponent: TObject; PropInfo: PPropInfo): TTreeNode;
var
  TypeData: PTypeData;
  obj: TObject;
begin
  case PropInfo^.PropType^.Kind of
    tkUnknown :
      Result := TreeFindAddProperty('Unknown ' + GetPropName(PropInfo));

{$IFDEF RSL_INT64} tkInt64, {$ENDIF}
    tkVariant,
    tkEnumeration,
    tkSet,
    tkWChar,
    tkChar,
    tkFloat,
    tkInteger,
    tkString,
    tkLString,
    tkWString:
      Result := TreeFindAddProperty(GetPropName(PropInfo));
    tkMethod: Result := nil;
    tkClass:
      begin
        Result := nil;
        TypeData := GetTypeData(PropInfo^.PropType^);
        obj := TObject(GetOrdProp(AComponent, PropInfo));

        if TypeData^.ClassType.InheritsFrom(TComponent)
          then begin
            if (obj<>nil)  and (csSubComponent in TComponent(obj).ComponentStyle) then begin
              TreeAddComponent2(TComponent(obj), TComponent(AComponent).Name + '.');
            end else
              Result := TreeFindAddProperty(GetPropName(PropInfo));
          end else
        if TypeData^.ClassType.InheritsFrom(TCollection)
          then begin

            if (obj<>nil) and (TCollection(obj).Count>0) then begin
              obj := TCollection(obj).Items[0];
              TreeAddComponent2(obj, TComponent(AComponent).Name + '.' + GetPropName(PropInfo));
            end else begin
              TreeAddClass2(nil, TCollection(obj).ItemClass.ClassInfo,
                            TComponent(AComponent).Name + '.' + GetPropName(PropInfo));
            end;
          end else begin
            if (obj<>nil) then begin
              if not TreeAddComponent2(obj, TComponent(AComponent).Name + '.' + GetPropName(PropInfo))
                then Result := TreeFindAddProperty(GetPropName(PropInfo));
            end else
              Result := TreeFindAddProperty(GetPropName(PropInfo));
          end;
      end;
    else
      Result := TreeFindAddProperty(GetPropName(PropInfo));
  end;
end;

function TrsPropSaverForm.TreeAddComponent2(AComponent: TObject; const NamePrefix: string): boolean;
var
  sName: string;
  TypeInfo: PTypeInfo;
  TypeData: PTypeData;
  i: integer;
  Node: TTreeNode;
begin
  TypeInfo := AComponent.ClassInfo;
  TypeData := GetTypeData(TypeInfo);

  if TypeData^.ClassType.InheritsFrom(TComponent)
    then sName := NamePrefix + TComponent(AComponent).Name
    else sName := NamePrefix;

  Result := TreeAddClass2(AComponent, TypeInfo, sName);

  {Add Custom Properties}
  if PropSaver.CustomProperties<>nil then
    with (PropSaver.CustomProperties as TrsCustomProperties).Properties do
      for i := 0 to Count-1 do
        if Items[i].IsSuitable(AComponent) then begin
           node := TreeFindAddProperty(Items[i].PropName);
           if Node<>nil then begin
             Node.Data := Pointer(cTVCustomProperty);
             TreePrepareNode(tv.Items.AddChildObject(Node, sName, nil));
           end;
           Result := True;
        end;
end;




procedure TrsPropSaverForm.TreeFill;
var
  i: integer;
  Node: TTreeNode;
begin
    with tv, Items do begin
      BeginUpdate;
  {$IFDEF RSL_KYLIX}
      QScrollView_setVScrollBarMode(tv.Handle, QScrollViewScrollBarMode_AlwaysOff);
  {$ENDIF}
{$ifdef rsl_trace}rsProfiler[7].Start;{$endif}
      Clear;
{$ifdef rsl_trace}rsProfiler[7].Stop; rsProfiler[7].Name := 'TreeFill.Clear';{$endif}
      FNodesCache.Clear;
      if Form<>nil then begin
        if View=fvProperty
          then begin
            Node := TreePrepareNode(Add(nil,'Properties'));

{$ifdef rsl_trace}rsProfiler[8].Start;{$endif}
            TreeAddComponent2(Form);
{$ifdef rsl_trace}rsProfiler[8].Stop; rsProfiler[8].Name := 'TreeFill.TreeAddComponent2';{$endif}
            for i:=0 to Form.ComponentCount-1 do begin
{$ifdef rsl_trace}rsProfiler[8].Start;{$endif}
              TreeAddComponent2(Form.Components[i]);
{$ifdef rsl_trace}rsProfiler[8].Stop; {$endif}
            end;
          end else begin
            Node := TreePrepareNode(Add(nil,'Components'));

{$ifdef rsl_trace}rsProfiler[9].Start;{$endif}
            TreeAddProperty(nil, Node, Form, Form.Name);
{$ifdef rsl_trace}rsProfiler[9].Stop; rsProfiler[9].Name := 'TreeFill.TreeAddProperty';{$endif}
            for i:=0 to Form.ComponentCount-1 do begin
{$ifdef rsl_trace}rsProfiler[9].Start;{$endif}
              TreeAddProperty(nil, Node, Form.Components[i], Form.Components[i].Name);
{$ifdef rsl_trace}rsProfiler[9].Stop;{$endif}
            end;
          end;

  {$IFNDEF RSL_KYLIX}
{$ifdef rsl_trace}rsProfiler[14].Start;{$endif}
        tv.AlphaSort;
{$ifdef rsl_trace}rsProfiler[14].Stop; rsProfiler[14].Name := 'TreeFill.AlfaSort';{$endif}
  {$ENDIF}
{$ifdef rsl_trace}rsProfiler[15].Start;{$endif}
        Node.Expanded := True;
{$ifdef rsl_trace}rsProfiler[15].Stop; rsProfiler[15].Name := 'TreeFill.NodeExpanded';{$endif}
      end;

  {$IFDEF RSL_KYLIX}
       QScrollView_setVScrollBarMode(tv.Handle, QScrollViewScrollBarMode_Auto);
  {$ENDIF}
{$ifdef rsl_trace}rsProfiler[16].Start;{$endif}
       EndUpdate;
{$ifdef rsl_trace}rsProfiler[16].Stop; rsProfiler[16].Name := 'TreeFill.EndUpdate';{$endif}
    end;
end;

procedure TrsPropSaverForm.FormActivate(Sender: TObject);
var
  safeCursor: TCursor;
begin
  safeCursor := Screen.Cursor;
  Screen.Cursor := crHourGlass;
  try
  {$ifdef rsl_trace}rsProfiler[2].Start;{$endif}

    if Form is TCustomForm
     then Caption := 'Setup for <'+TCustomForm(Form).Caption+'>'
     else Caption := 'Setup for <'+Form.Name+'>';

  {$ifdef rsl_trace}rsProfiler[3].Start;{$endif}
    TreeFill;
  {$ifdef rsl_trace}rsProfiler[3].Stop; rsProfiler[3].Name := 'FormActivate.TreeFill';{$endif}
  {$ifdef rsl_trace}rsProfiler[4].Start;{$endif}
    ListLoad;
  {$ifdef rsl_trace}rsProfiler[4].Stop; rsProfiler[4].Name := 'FormActivate.ListLoad';{$endif}
  {$ifdef rsl_trace}rsProfiler[5].Start;{$endif}
    GetEncryptList;
  {$ifdef rsl_trace}rsProfiler[5].Stop; rsProfiler[5].Name := 'FormActivate.GetEncryptList';{$endif}
  {$ifdef rsl_trace}rsProfiler[6].Start;{$endif}
    TreeRefreshChecks;
  {$ifdef rsl_trace}rsProfiler[6].Stop; rsProfiler[6].Name := 'FormActivate.TreeRefreshChecks';{$endif}
  {$ifdef rsl_trace}rsProfiler[2].Stop; rsProfiler[2].Name := 'FormActivate';{$endif}
  finally
    Screen.Cursor := safeCursor;
  end;
end;

procedure TrsPropSaverForm.miViewByClick(Sender: TObject);
begin
  View := TrsFormCfgView((Sender as TMenuItem).Tag);
end;

procedure TrsPropSaverForm.pmViewPopup(Sender: TObject);
begin
  miViewByName.Checked := View = fvName;
  miViewByClass.Checked := View = fvClass;
  miViewByProperty.Checked := View = fvProperty;
end;

function TrsPropSaverForm.GetCheckState(Node: TTreeNode): TCheckBoxState;
begin
  Result := TCheckBoxState(Node.ImageIndex-CImgIdxCheckBlock);
end;

procedure TrsPropSaverForm.SetCheckState(Node: TTreeNode; const Value: TCheckBoxState);
begin
  CheckStateSet(Node, Value, True);
end;

procedure TrsPropSaverForm.CheckStateSet(Node: TTreeNode; const Value: TCheckBoxState; doChilds: boolean);
var
  t: TTreeNode;
  r: TRect;
begin
  if Value<>GetCheckState(Node) then begin
    Node.ImageIndex := Integer(Value)+CImgIdxCheckBlock;
    Node.SelectedIndex := Node.ImageIndex;
{$IFDEF RSL_KYLIX}
    r := Node.DisplayRect;// (False);
{$ENDIF}
{$IFDEF RSL_WIN}
    r := Node.DisplayRect(False);
    InvalidateRect(Node.Handle, @r, True);
{$ENDIF}

    if Assigned(FOnChangeCheck) then FOnChangeCheck(tv, Node);
    {correct childs}
    if doChilds AND (Value<>cbGrayed) and (Node.getFirstChild<>nil) then begin
      lv.Items.BeginUpdate;
      t := Node.getFirstChild;
      While t<>nil do begin
        CheckStateSet(t, Value, True);
        t := Node.GetNextChild(t);
      end;
      lv.Items.EndUpdate;
    end;
    {correct parents}
    CheckStateVerify(Node.Parent);
  end;
end;

procedure TrsPropSaverForm.CheckStateToggle(Node: TTreeNode);
var
  li: TListItem;
begin
  if (Node<>nil) and (Node<>tv.Items.GetFirstNode) then begin
    if CheckState[Node] = cbUnChecked then begin
      CheckState[Node] := cbChecked;

      li := ListFind(NodeName(Node), False);
      if li<>nil then begin
        li.Selected := True;
        li.MakeVisible{$IFNDEF RSL_K3}(False){$ENDIF};
      end;
    end else CheckState[Node] := cbUnchecked;
  end;
end;

procedure TrsPropSaverForm.CheckStateVerify(Node: TTreeNode);
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
      if state = cbChecked
        then Inc(CntCheck)
        else
      if state = cbUnChecked
        then Inc(CntUnCheck);
      Inc(Cnt);
      if (CntCheck>0) and (CntUnCheck>0) then Break; //this is grayed
      t := Node.GetNextChild(t);
    end;

    if Cnt>0 then begin
      if Cnt=CntCheck
        then state := cbChecked
        else
      if Cnt=CntUnCheck
        then state := cbUnChecked
        else state := cbGrayed;
      CheckStateSet(Node, state, False);
    end;
  end;
end;

function TrsPropSaverForm.TreePrepareNode(Node: TTreeNode): TTreeNode;
begin
  if Node<>nil then begin
    Node.ImageIndex := CImgIdxCheckBlock;
    Node.SelectedIndex := CImgIdxCheckBlock;
  end;
  Result := Node;
end;

function TrsPropSaverForm.IsCursorInImage(Tree: TTreeView; X,Y: integer): boolean;
var
  Node: TTreeNode;
{$IFDEF RSL_KYLIX}
  Pt: TPoint;
  Item: QListViewItemH;
  Pixmap: QPixmapH;
  PixmapWidth,PixmapHeight: Integer;
{$ENDIF}
begin
  Node := Tree.GetNodeAt(X,Y);
  if Node=nil then begin
    Result := False;
    Exit;
  end;
{$IFDEF RSL_KYLIX}
  Item := Node.Handle;
  Pixmap := QListViewItem_pixmap(Item, 0);
  if Assigned(Pixmap) then begin
    PixmapWidth := QPixmap_width(Pixmap);
    PixmapHeight := QPixmap_height(Pixmap);
  end else begin
    PixmapWidth := 0;
    PixmapHeight := 0;
  end;

  Pt.X := Node.Level * Tree.Indent;
  if Tree.ShowButtons then Inc(Pt.X, Tree.Indent);

  Pt.Y := QListViewItem_itemPos(Item);

  QScrollView_contentsToViewport(Tree.Handle, @Pt, @Pt);

  Result := (X >= Pt.X) and (X <= Pt.X+PixmapWidth) and
            (Y >= Pt.Y) and (Y <= Pt.Y+PixmapHeight);
{$ELSE}
  Result := htOnIcon in Tree.GetHitTestInfoAt(X,Y);
{$ENDIF}
end;

procedure TrsPropSaverForm.tvMouseMove(Sender: TObject; Shift: TShiftState;
  X, Y: Integer);
begin
  if IsCursorInImage(tv, X, Y)
   then tv.Cursor := crHandPoint
   else tv.Cursor := crDefault;
end;

procedure TrsPropSaverForm.tvMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  Node: TTreeNode;
begin
  if Button=mbRight then begin
    Node := tv.GetNodeAt(X, Y);
    if Node<>nil then Node.Selected := True;
  end else begin
    Node := tv.GetNodeAt(X, Y);
    if (Node<>nil) AND IsCursorInImage(tv, X,Y) then CheckStateToggle(Node);
  end;
end;

procedure TrsPropSaverForm.SetPropSaver(const Value: TrsPropSaver);
begin
  if FPropSaver <> Value then begin
    FPropSaver := Value;
    if FPropSaver<>nil then begin
      Form := FPropSaver.Owner as TComponent;
{$ifdef rsl_trace}rsProfiler[1].Start;{$endif}
      FProps.Assign(PropSaver.Properties);

      if tv.Items.Count<>0 then
        TreeFill;
{$ifdef rsl_trace}rsProfiler[1].Stop; rsProfiler[1].Name := 'SetPropSaver'; {$endif}
    end;
  end;
end;

procedure TrsPropSaverForm.FormCreate(Sender: TObject);
begin
{$ifdef rsl_trace}rsProfiler.Clear; rsProfiler.Precision := ppMilliSecond; rsProfiler[0].Start;{$endif}

  FProps := TStringList.Create;
  FEncryptList := TStringList.Create;
{$IFDEF RSL_TEMPLATES}
  FTemplates := TrsPropSaverTemplates.Create;
  FTemplates.Load;
{$ENDIF}

  FShowInfo := False;
  FormStateLoad;

{$IFDEF RSL_WIN}
  tv.OnCustomDrawItem := tvCustomDrawItem;
{$ENDIF}

{$IFDEF RSL_KYLIX}
  QScrollView_setHScrollBarMode(tv.Handle, QScrollViewScrollBarMode_AlwaysOff);
  {$IFDEF RSL_K3}
    OnActivate := nil;
    OnShow := FormActivate; // bug in Kylix3? no OnActivate call?
  {$ELSE}
    OnActivate := FormActivate;
    OnShow := nil;
  {$ENDIF}
{$ENDIF}
  FNodesCache := TStringList.Create;
  FNodesCache.Sorted := True;
  FNodesCache.Duplicates := dupIgnore;
{$ifdef rsl_trace}rsProfiler[0].Stop; rsProfiler[0].Name := 'FormCreate';{$endif}
end;

procedure TrsPropSaverForm.FormDestroy(Sender: TObject);
begin
  ListClear;
  FNodesCache.Free;
{$IFDEF RSL_TEMPLATES}
  FTemplates.Free;
{$ENDIF}
  FEncryptList.Free;
  FProps.Free;
end;

procedure TrsPropSaverForm.ListLoad;
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
{$ifdef rsl_trace}rsProfiler[10].Start;{$endif}
      Prop := TrsProperty.Create;
      Prop.AsString := FProps[i];

      k := Pos('.', Prop.Name);
      if k>0 then s := Copy(Prop.Name, 1, k-1)
       else s := Prop.Name;
      if (Length(s)>0) and (GetPropInfo(Form.ClassInfo,s)<>nil)
       then Prop.Name := Form.Name+'.'+Prop.Name;

      li := ListAdd(Prop);
      ListItemErrorState[li] := (FindNodeEx(Prop.Name)=nil) and not (Prop.PropType in [ptUser,ptVariable]);
{$ifdef rsl_trace}rsProfiler[10].Stop; rsProfiler[10].Name := 'ListLoad.Step';{$endif}
    end;
    EndUpdate;
  end;
end;

function TrsPropSaverForm.ListAdd(Prop: TrsProperty): TListItem;
begin
  Result := lv.Items.Add;
  Result.Caption := Prop.Name;
  Result.Data := Prop;
  ListItemState[Result] := ListItemState[Result];
end;

function TrsPropSaverForm.GetItemDefValue(ListItem: TListItem): string;
begin
 if (ListItem<>nil) and (ListItem.Data<>nil)
  then Result := TrsProperty(ListItem.Data).DefValue;
end;

function TrsPropSaverForm.GetItemErrorState(ListItem: TListItem): boolean;
begin
  Result := (ListItem<>nil) and (TrsProperty(ListItem.Data).ExtFlags and cMaskError>0);
end;

function TrsPropSaverForm.GetItemState(ListItem: TListItem): TrsPropertyState;
begin
  if (ListItem=nil) or (ListItem.Data=nil) then Result := psNormal
   else Result := TrsProperty(ListItem.Data).State;
end;

function TrsPropSaverForm.GetItemSubstName(ListItem: TListItem): string;
begin
 if (ListItem<>nil) and (ListItem.Data<>nil)
  then Result := TrsProperty(ListItem.Data).SubstName;
end;

function TrsPropSaverForm.GetItemType(ListItem: TListItem): TrsPropertyType;
begin
  if (ListItem=nil) or (ListItem.Data=nil) then Result := ptPublished
   else Result := TrsProperty(ListItem.Data).PropType;
end;

function TrsPropSaverForm.GetPropName(PropInfo: PPropInfo): string;
begin
  Result := String(PropInfo^.Name);
end;

procedure TrsPropSaverForm.SetItemDefValue(ListItem: TListItem;
  const Value: string);
begin
  if (ListItem<>nil) and (ListItem.Data<>nil)
   then TrsProperty(ListItem.Data).DefValue := Value;
end;

procedure TrsPropSaverForm.SetItemErrorState(ListItem: TListItem;
  const Value: boolean);
begin
  if ListItem<>nil then begin
    if Value then begin
      with TrsProperty(ListItem.Data) do ExtFlags := ExtFlags or cMaskError;
//      ListItem.StateIndex := cImgIdxError;
    end else begin
      with TrsProperty(ListItem.Data) do ExtFlags := ExtFlags and (not cMaskError);
      ListItemState[ListItem] := ListItemState[ListItem];
    end;
  end;
end;

procedure TrsPropSaverForm.SetItemState(ListItem: TListItem; const Value: TrsPropertyState);
begin
  TrsProperty(ListItem.Data).State := Value;
end;

procedure TrsPropSaverForm.SetItemSubstName(ListItem: TListItem; const Value: string);
begin
  if (ListItem<>nil) and (ListItem.Data<>nil)
   then TrsProperty(ListItem.Data).SubstName := Value;
end;

procedure TrsPropSaverForm.SetItemType(ListItem: TListItem;
  const Value: TrsPropertyType);
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

function TrsPropSaverForm.FindNodeEx(const Value: string): TTreeNode;
var
  s: string;
  IdxBegin,IdxEnd: integer;
  iB,iE: integer;
  Node,Node1 : TTreeNode;
  sl: TStringList;
begin
  Result := tv.Items.GetFirstNode;
  if Result=nil then Exit;
  if Value='' then begin Result := nil; Exit; end;

  if View=fvProperty then begin
    sl := TStringList.Create;
    try
      iB := 1;
      iE := 1;
      while iE<=Length(Value) do begin
        if (Value[iE]='.') or (iE=Length(Value))
          then begin
            if iE=Length(Value) then Inc(iE);
            sl.Add(Copy(Value, iB, iE-iB));
            iB := iE + 1;
          end;
        Inc(iE);
      end;

      while sl.Count>0 do begin
        for iB:=0 to sl.Count-1 do begin
          s := '';
          for iE := sl.Count-1 downto iB do
            s := sl[iE]+'.'+s;
          if Length(s)>0 then SetLength(s, Length(s)-1); //delete last '.'

          Node := Result.getFirstChild;
          While (Node<>nil) and (CompareText(Node.Text, s)<>0) do
             Node := Result.GetNextChild(Node);

          if Node<>nil then begin
            Result := Node;
            While sl.Count>iB do sl.Delete(sl.Count-1);
            Break;
          end;
        end;
        if Result=nil then Break;
        if Result=tv.Items.GetFirstNode then begin
          Result := nil;
          Break;
        end;
      end;

    finally
      sl.Free;
    end;
  end else begin

    Node1 := nil;
    IdxBegin := 1;
    While True do begin
      for IdxEnd:= IdxBegin to Length(Value) do
       if Value[IdxEnd]='.' then Break;

      s := Copy(Value, IdxBegin, IdxEnd-IdxBegin);

      //search component by name
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
end;

procedure TrsPropSaverForm.ClickTVCheck(Sender: TObject; Node: TTreeNode);
var
  Prop: TrsProperty;
begin
  case CheckState[Node] of
    cbUnchecked : ListDelete(NodeName(Node));
    cbChecked   : if Node.Count=0 then begin
                    Prop := TrsProperty.Create;
                    Prop.AsString := NodeName(Node);
                    if Node.Data=Pointer(cTVCustomProperty)
                     then Prop.PropType := ptCustom;
                    ListAdd(Prop);
                  end;
  end;
end;

function TrsPropSaverForm.NodeName(Node: TTreeNode): string;
var
  cIntSep: Char;
  i: integer;
begin
  Result := '';

  if View=fvProperty
    then cIntSep := '-'
    else cIntSep := '.';

  While (Node<>nil) and (Node.Parent<>nil) do begin
    if Result<>'' then Result := Node.Text + cIntSep + Result
     else Result:= Node.Text;
    Node := Node.Parent;
  end;

  if (Node<>nil) and (Node.TreeView=tv) then begin
    if View=fvClass
      then Delete(Result, 1, Pos('.', Result))
      else
    if View=fvProperty
      then begin
        i := Pos('-', Result);
        if i>0 then
          Result := Copy(Result, i+1, Length(Result)-i) + '.' + Copy(Result, 1, i-1);
      end;
  end;
end;

procedure TrsPropSaverForm.ListDelete(const Value: string);
var li: TListItem;
begin
  li := lv.FindCaption(0, Value, False, True, False);
  if li<>nil then li.Delete;
end;

function TrsPropSaverForm.ListFind(const Value: string; const Partial: boolean): TListItem;
begin
  Result := lv.FindCaption(0, Value, Partial, True, False);
end;

procedure TrsPropSaverForm.tbInfoClick(Sender: TObject);
begin
  ShowInfo := not ShowInfo;
end;

procedure TrsPropSaverForm.SetShowInfo(const Value: boolean);
begin
  pnlInfo.Visible := Value;
  tbInfo.Down := Value;
  FShowInfo := Value;
  if Value then begin
    splHorzMoved(Self);
    RefreshInfo(False);
  end;
end;

procedure TrsPropSaverForm.TreeRefreshChecks;
var
  i: integer;
  s: string;
  t: TTreeNode;
begin
  OnChangeCheckState := nil;
  for i:=0 to lv.Items.Count-1 do begin
    s := lv.Items[i].Caption;
{$ifdef rsl_trace}rsProfiler[12].Start;{$endif}
    t := FindNodeEx(s);
{$ifdef rsl_trace}rsProfiler[12].Stop; rsProfiler[12].Name := 'TreeRefreshChecks.FindNodeEx';{$endif}
{$ifdef rsl_trace}rsProfiler[13].Start;{$endif}
    if t<>nil then CheckState[t] := cbChecked;
{$ifdef rsl_trace}rsProfiler[13].Stop; rsProfiler[13].Name := 'TreeRefreshChecks.CheckState';{$endif}
  end;
  OnChangeCheckState := ClickTVCheck;
end;

procedure TrsPropSaverForm.tbUpClick(Sender: TObject);
begin
  with lv do
    if (Selected<>nil) and (Selected.Index>0) then begin
      ListItemExchange(-1);
      ToolBarRefresh;
    end;
end;

procedure TrsPropSaverForm.tbDownClick(Sender: TObject);
begin
  with lv do
    if (Selected<>nil) and (Selected.Index<(Items.Count-1)) then begin
      ListItemExchange(1);
      ToolBarRefresh;
    end;
end;

procedure TrsPropSaverForm.ListItemExchange(const Direction: integer);
var
  s: string;
  i: integer;
  li1,li2: TListItem;
begin
  li1 := lv.Selected;
  i := li1.Index;
  li2 := lv.Items[i+Direction];

  s := li1.Caption;       li1.Caption := li2.Caption;       li2.Caption := s;
  i := Integer(li1.Data); li1.Data := li2.Data;             li2.Data := Pointer(i);

  li2.Selected := True;
  li2.Focused := True;
  lv.Selected.MakeVisible{$IFNDEF RSL_K3}(False){$ENDIF};
end;

procedure TrsPropSaverForm.ToolBarRefresh;
begin
  tbUp.Enabled := (lv.Selected<>nil) and (lv.Selected.Index>0);
  tbDown.Enabled := (lv.Selected<>nil) and (lv.Selected.Index<(lv.Items.Count-1));
  tbDelete.Enabled := lv.Selected<>nil;
  tbModify.Enabled := tbDelete.Enabled;
end;

procedure TrsPropSaverForm.tvChange(Sender: TObject; Node: TTreeNode);
begin
  ToolBarRefresh;
  RefreshRightPanel;
  if FOldSelectedComponent<>SelectedComponentName
   then DoSelectComponent;
end;

procedure TrsPropSaverForm.lvEnter(Sender: TObject);
begin
  ToolBarRefresh;
end;

procedure TrsPropSaverForm.TimerListChangeTimer(Sender: TObject);
begin
  TimerListChange.Enabled := False;
  ToolBarRefresh;
  RefreshInfo(True);
end;

procedure TrsPropSaverForm.lvChange(Sender: TObject; Item: TListItem;
  Change: TItemChange);
begin
  if Change=ctState then begin
    TimerListChange.Enabled := False;
    TimerListChange.Enabled := True;
  end;
end;

procedure TrsPropSaverForm.RefreshInfo(const IfShowInfo: boolean);
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

procedure TrsPropSaverForm.ListSelectNearest(const Index: integer);
begin
  if (lv.Items.Count>0) and (Index>=0) then begin
    if lv.Items.Count<=Index then lv.Selected := lv.Items[lv.Items.Count-1]
     else lv.Selected := lv.Items[Index];
    lv.Selected.Focused := True;
  end;
end;

procedure TrsPropSaverForm.tbDeleteClick(Sender: TObject);
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
    ListSelectNearest(i);
  end;
end;

procedure TrsPropSaverForm.lvDblClick(Sender: TObject);
var
  Node: TTreeNode;
begin
  if (lv.Selected<>nil) or (Sender=nil) then begin
      Node := FindNodeEx(lv.Selected.Caption);
      if Node<>nil then begin
        Node.MakeVisible{$IFDEF RSL_K2LE}(False){$ENDIF};
        tv.Selected := Node;
        tv.SetFocus;
      end;
  end;
end;

procedure TrsPropSaverForm.RefreshRightPanel;
var
  Node: TTreeNode;
  ListItem: TListItem;
begin
  if (ActiveControl=tv) or tv.Focused then begin
    Node := tv.Selected;
    if (Node<>nil) and (CheckState[Node] in [cbGrayed,cbChecked]) then begin
      ListItem := ListFind(NodeName(Node), Node.HasChildren);
      if ListItem<>nil then begin
        ListItem.Selected := True;
        ListItem.MakeVisible{$IFNDEF RSL_K3}(False){$ENDIF};
        RefreshInfo(True);
      end;
    end;
  end;
end;

procedure TrsPropSaverForm.lvDeletion(Sender: TObject; Item: TListItem);
begin
  TrsProperty(Item.Data).Free;
  Item.Data := nil;
end;

procedure TrsPropSaverForm.lvEditing(Sender: TObject; Item: TListItem; var AllowEdit: Boolean);
begin
  AllowEdit := True;
end;

{$IFDEF RSL_KYLIX}
procedure TrsPropSaverForm.lvEdited(Sender: TObject; Item: TListItem; var S: WideString);
{$ELSE}
procedure TrsPropSaverForm.lvEdited(Sender: TObject; Item: TListItem; var S: String);
{$ENDIF}
var
  Node: TTreeNode;
begin
  if (CompareText(Item.Caption, S)=0) then Exit;
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
  ToolBarRefresh;
  RefreshInfo(True);
end;

{$IFDEF RSL_KYLIX}
const
  RSL_F2 = KEY_F2;
  RSL_RETURN = KEY_RETURN;
  RSL_SPACE = KEY_SPACE;
  RSL_DELETE = KEY_DELETE;
  RSL_INSERT = KEY_INSERT;
  RSL_KEYUP = KEY_UP;
  RSL_KEYDOWN = KEY_DOWN;
{$ENDIF}
{$IFDEF RSL_WIN}
const
  RSL_F2 = VK_F2;
  RSL_RETURN = VK_RETURN;
  RSL_SPACE = VK_SPACE;
  RSL_DELETE = VK_DELETE;
  RSL_INSERT = VK_INSERT;
  RSL_KEYUP = VK_UP;
  RSL_KEYDOWN = VK_DOWN;
{$ENDIF}

procedure TrsPropSaverForm.lvKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if ((Key=RSL_F2){ or (Key=RSL_RETURN)}) and (Shift=[]) and (lv.Selected<>nil) and (not lv.IsEditing)
   then tbModify.Click
   else
  if (Key=RSL_SPACE) and (Shift=[]) and (not lv.IsEditing) then lv.OnDblClick(nil)
   else
  if (Key=RSL_DELETE) and (Shift=[]) and (not lv.IsEditing) then tbDelete.Click
   else
  if (Key=RSL_INSERT) and (Shift=[]) and (not lv.IsEditing) then tbAdd.Click
   else
  if (Shift = [ssCtrl]) and (not lv.IsEditing) then begin
   if (key=RSL_KEYUP) and tbUp.Enabled then begin
     tbUpClick(self);
     Key := 0;
   end else
   if (key=RSL_KEYDOWN) and tbDown.Enabled then begin
     tbDownClick(self);
     Key := 0;
   end else;
  end;
end;

procedure TrsPropSaverForm.ListSave;
var
  li: TListItem;
  i,k: integer;
  s: string;
begin
  FProps.Clear;
  for i:=0 to lv.Items.Count-1 do begin
    li := lv.Items[i];
    s := li.Caption;
    k := Length(Form.Name);
    if (StrLIComp(PChar(Form.Name), PChar(s), k)=0) and (Length(s)>k) and (s[k+1]='.')
     then begin
       Delete(TrsProperty(li.Data).Name, 1, k+1);
     end;
    FProps.Add(TrsProperty(li.Data).AsString);
  end;
end;

procedure TrsPropSaverForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
{$IFDEF RSL_WIN}
  FormStateSave;
  ListSave;
  PropSaver.Properties.Assign(FProps);
  SetEncryptList;
{$ENDIF}
end;

procedure TrsPropSaverForm.edInfoSubstNameChange(Sender: TObject);
begin
  ListItemSubstName[lv.Selected] := edInfoSubstName.Text;
end;

procedure TrsPropSaverForm.cbInfoTypeChange(Sender: TObject);
begin
  if cbInfoType.ItemIndex<3//4
    then ListItemType[lv.Selected] := TrsPropertyType(cbInfoType.ItemIndex)
    else ListItemType[lv.Selected] := ptPublished;
end;

procedure TrsPropSaverForm.cbInfoStateChange(Sender: TObject);
var
  li: TListItem;
begin
  li := lv.Selected;
  if li<>nil then begin
    TrsProperty(li.Data).Enabled := cbInfoState.ItemIndex<>3;
    if cbInfoState.ItemIndex=3
      then ListItemState[li] := psNormal
      else
        if cbInfoState.ItemIndex>=0
          then ListItemState[li] := TrsPropertyState(cbInfoState.ItemIndex)
          else ListItemState[li] := psNormal;
  end;
end;

procedure TrsPropSaverForm.edInfoDefChange(Sender: TObject);
begin
  ListItemDefValue[lv.Selected] := edInfoDef.Text;
end;

procedure TrsPropSaverForm.cbxEncryptClick(Sender: TObject);
var
  ListItem: TListItem;
begin
  ListItem := lv.Selected;
  if (ListItem<>nil) and (ListItem.Data<>nil) then
    TrsProperty(ListItem.Data).StoreEncrypted := cbxEncrypt.Checked;
end;

procedure TrsPropSaverForm.GetEncryptList;
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
{$ifdef rsl_trace}rsProfiler[11].Start;{$endif}

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
{$ifdef rsl_trace}rsProfiler[11].Stop; rsProfiler[11].Name := 'GetEncryptList.Step';{$endif}

    end;
  end;
end;

procedure TrsPropSaverForm.SetEncryptList;
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


function TrsPropSaverForm.GetIniFile: TCustomIniFile;
begin
  Result := {$IFDEF RSL_DLGTEST}nil;{$ELSE}IDEIniFile;{$ENDIF}
end;


procedure TrsPropSaverForm.FormStateLoad;
var
  vLeft,vTop,vWidth,vHeight: integer;

   procedure SetDefaultPosition;
   begin
     Width := tbSeparator.Width + tbView.Width*8 + 14;
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
      View := TrsFormCfgView(ReadInteger(SRSLibName, 'ViewType', 0));
      if ReadInteger(SRSLibName, 'ButtonCaption', 1)=0 then miTextLabels.Click;
      if ReadInteger(SRSLibName, 'ShowInfo', 0)=1 then tbInfo.Click;
    end
  else SetDefaultPosition;
  tbr.Repaint;
end;


procedure TrsPropSaverForm.FormStateSave;
begin
  if GetIniFile<>nil then
    with GetIniFile do begin
      WriteInteger(SRSLibName, 'Left', Self.Left);
      WriteInteger(SRSLibName, 'Top', Self.Top);
      WriteInteger(SRSLibName, 'Width', Self.Width);
      WriteInteger(SRSLibName, 'Height', Self.Height);
      WriteInteger(SRSLibName, 'Splitter', pnlLeft.Width);
      WriteInteger(SRSLibName, 'ViewType', Integer(View));
      WriteInteger(SRSLibName, 'ButtonCaption', Integer(tbr.ShowCaptions));
      WriteInteger(SRSLibName, 'ShowInfo', Integer(ShowInfo));
    end;
end;


procedure TrsPropSaverForm.miTextLabelsClick(Sender: TObject);
begin
  ToolBarResizeButtons(not tbr.ShowCaptions);
end;


procedure TrsPropSaverForm.tbAddClick(Sender: TObject);
var
  li: TListItem;
{$IFDEF RSL_KYLIX}
  s: WideString;
{$ELSE}
  s: string;
{$ENDIF}
begin
{$IFDEF RSL_KYLIX}
  if not InputQuery('Add property','Enter property name',s) then Exit;
{$ELSE}
  s := '--------';
{$ENDIF}
  lv.SetFocus;
  li := lv.Items.Add;
  li.Data := TrsProperty.Create;
  li.Caption := s;
  li.Selected := True;
  li.Focused := True;
  li.MakeVisible{$IFNDEF RSL_K3}(False){$ENDIF};
{$IFDEF RSL_KYLIX}
  li.Caption := '';
  lvEdited(nil, li, s);
  li.Caption := s;
{$ELSE}
  li.EditCaption;
{$ENDIF}
end;


procedure TrsPropSaverForm.tbModifyClick(Sender: TObject);
{$IFDEF RSL_KYLIX}
var
  s: WideString;
{$ENDIF}
begin
{$IFDEF RSL_KYLIX}
  if lv.Selected<>nil then begin
    s := lv.Selected.Caption;
    if not InputQuery('Modify property', 'Enter new property', s) then Exit;
    lvEdited(nil, lv.Selected, s);
    lv.Repaint;
  end;
{$ELSE}
  if lv.Selected<>nil then lv.Selected.EditCaption;
{$ENDIF}
end;

procedure TrsPropSaverForm.DoSelectComponent;
begin
  if Assigned(FOnSelectComponent) then FOnSelectComponent(self);
  FOldSelectedComponent := SelectedComponentName;
end;


function TrsPropSaverForm.GetSelectedComponentName: string;
var
  i: integer;
begin
  Result := NodeName(tv.Selected);
  if Length(Result)>0 then begin
    i := 1;
    While not (Result[i] in ['.', #0]) do Inc(i);
    if i<Length(Result) then SetLength(Result, i-1);
  end;
end;

procedure TrsPropSaverForm.SetSelectedComponentName(const Value: string);
var
  Node: TTreeNode;
begin
  Node := FindNodeEx(Value);
  if Node<>nil then begin
    tv.Selected := Node;
    Node.MakeVisible{$IFDEF RSL_K2LE}(False){$ENDIF};
    Node.Expanded := True;
  end;
end;

procedure TrsPropSaverForm.SetForm(const Value: TComponent);
begin
  if FForm<>Value then begin
    FForm := Value;
  end;
end;


procedure TrsPropSaverForm.FormHide(Sender: TObject);
begin
{$IFDEF RSL_KYLIX}
  FormStateSave;
  ListSave;
  PropSaver.Properties.Assign(FProps);
  SetEncryptList;
{$ENDIF}
end;


procedure TrsPropSaverForm.pmButtonCaptionsPopup(Sender: TObject);
begin
  miTextLabels.Checked := tbr.ShowCaptions;
end;

procedure TrsPropSaverForm.ListClear;
var
  i: integer;
begin
  for i:=0 to lv.Items.Count-1 do
    if lv.Items[i].Data<>nil then begin
      TrsProperty(lv.Items[i].Data).Free;
      lv.Items[i].Data := nil;
    end;
  lv.Items.Clear;
end;

function TrsPropSaverForm.PropertyFindByName(const Value: string): TrsProperty;
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

{$IFDEF RSL_WIN}
procedure TrsPropSaverForm.tvCustomDrawItem(Sender: TCustomTreeView;
  Node: TTreeNode; State: TCustomDrawState; var DefaultDraw: Boolean);
begin
  if Node.Data=Pointer(cTVCustomProperty) then begin
    if cdsSelected in State
     then Sender.Canvas.Font.Color := clWhite
     else Sender.Canvas.Font.Color := clNavy;
    Sender.Canvas.Font.Style := [fsBold];
  end;
end;
{$ENDIF}


{$IFDEF RSL_TEMPLATES}
function  TrsPropSaverForm.TemplateApproach(const Index: integer; Node: TTreeNode): boolean;
var
  i: integer;
begin
  FTemplates.CurrentTemplateIndex := Index;
  Result := False;
  for i:=0 to FTemplates.PropertiesCount-1 do begin
    Result := FindNode(Node, FTemplates.Properties[i])<>nil;
    if not Result then Exit;
  end;
end;
{$ENDIF}

{$IFDEF RSL_TEMPLATES}
function TrsPropSaverForm.FindNode(Node: TTreeNode; const Value:string): TTreeNode;
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
{$ENDIF}

procedure TrsPropSaverForm.miTemplsSaveAsClick(Sender: TObject);
{$IFDEF RSL_TEMPLATES}
var
  s,s1: string;
  i,k,Len: integer;
{$ENDIF}
begin
{$IFDEF RSL_TEMPLATES}
  s := '';
  while true do begin
    if not InputQuery('Save current properties as template','Enter template name',s) then Break;
    i := FTemplates.IndexOf(s);
    if i>=0 then begin
      k := MessageDlg('Template <'+s+'> exist! Replace existen template?',
                     mtConfirmation, [mbYes,mbNo, mbCancel], 0);
      if k=mrCancel then Exit;
      if k=mrNo then Continue;
    end else i := FTemplates.Add(s);

    FTemplates.CurrentTemplateIndex := i;
    FTemplates.PropertiesClear;

    s := NodeName(tv.Selected)+'.';
    Len := Length(s);
    for i:=0 to lv.Items.Count-1 do
     if StrLIComp(PChar(s), PChar(lv.Items[i].Caption), Len)=0 then begin
       s1 := lv.Items[i].Caption;
       FTemplates.PropertiesAdd(Copy(s1, Len+1, Length(s1)-Len));
     end;
    Break; 
  end;
  FTemplates.Save;
{$ELSE}
{$ENDIF}
end;

procedure TrsPropSaverForm.pmTemplatePopup(Sender: TObject);
{$IFDEF RSL_TEMPLATES}
var
  mi: TMenuItem;
  i,menuIdx: integer;
{$ENDIF}
begin
{$IFDEF RSL_TEMPLATES}
  with pmTemplate do begin
    While Items.Count>3 do Items.Delete(0);
    menuIdx := 0;
    for i:=0 to FTemplates.Count-1 do
      if TemplateApproach(i, tv.Selected)
        then begin
          FTemplates.CurrentTemplateIndex := i;
          mi := TMenuItem.Create(self);
          mi.Caption := FTemplates.TemplateName;
          mi.Tag := i;
          mi.OnClick := TemplateClick;
          Items.Insert(menuIdx, mi);
          Inc(menuIdx);
        end;
  end;
  miTemplsSaveAs.Enabled := tv.Focused and (tv.Selected<>nil) {restore and (sbrMain.Panels[0].Text='Class')} and (CheckState[tv.Selected]<>cbUnchecked);
{$ENDIF}
end;

procedure TrsPropSaverForm.TemplateClick(Sender: TObject);
{$IFDEF RSL_TEMPLATES}
var
  i:integer;
  Node,Node1: TTreeNode;
{$ENDIF}
begin
{$IFDEF RSL_TEMPLATES}
  Node := tv.Selected;
  if Node=nil then Exit;
  FTemplates.CurrentTemplateIndex := (Sender as TMenuItem).Tag;
  CheckState[Node] := cbUnchecked;

  for i:=0 to FTemplates.PropertiesCount-1 do begin
    Node1 := FindNode(Node, FTemplates.Properties[i]);
    if Node1<>nil then CheckState[Node1] := cbChecked;
  end;
{$ENDIF}
end;

procedure TrsPropSaverForm.tbTemplateClick(Sender: TObject);
begin
{$IFDEF RSL_TEMPLATES}
  tbTemplate.CheckMenuDropdown;
{$ENDIF}
end;

procedure TrsPropSaverForm.miTemplsCustomizeClick(Sender: TObject);
{$IFDEF RSL_TEMPLATES}
var
  F: TrsPropSaverTemplatesForm;
{$ENDIF}
begin
{$IFDEF RSL_TEMPLATES}
  F := TrsPropSaverTemplatesForm.Create(Self);
  try
    F.Templates := FTemplates;
    if F.ShowModal in [mrOK,mrYes] then begin
      FTemplates.Assign(F.Templates);
      FTemplates.Save;
    end;
  finally
    F.Free;
  end;
{$ENDIF}
end;

procedure TrsPropSaverForm.tvKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if (Shift=[]) and (Key=RSL_Space)
    then begin
      CheckStateToggle(tv.Selected);
      Key := 0;
    end;
end;

function TrsPropSaverForm.TreeCopyNode(SourceNode,DestNode: TTreeNode): integer;
var
  ndSrc,ndDest: TTreeNode;
begin
  //copy childrens only
  DestNode.DeleteChildren;
  Result := 0;

  ndSrc := SourceNode.getFirstChild;
  while ndSrc<>nil do begin
    ndDest := DestNode.Owner.AddChildObject(DestNode, ndSrc.Text, ndSrc.Data);
    Inc(Result);
    Result := Result + TreeCopyNode(ndSrc, ndDest);
    ndSrc := ndSrc.getNextSibling;
  end;
end;

{$ifdef rsl_trace}
procedure TrsPropSaverForm.btnSaveLogClick(Sender: TObject);
var
  s: string;
  sl: TStringList;
  i: integer;
begin
  with TSaveDialog.Create(nil) do begin
    s := 'c:\rsllog.txt';
    FileName := s;
    Filter := 'All files|*.*';
    DefaultExt := 'txt';
    if Execute then begin
      s := FileName;
    end else s := '';
    Free;
  end;

  if Length(s)>0 then begin
    sl := TStringList.Create;
    try
      for i:=0 to rsProfiler.Count-1 do
        if rsProfiler[i].Count<>0 then
          sl.Add(IntToStr(i)+': '+rsProfiler[i].AsString);
      sl.Add('treecount='+IntToStr(tv.Items.Count));
      sl.Add('listcount='+IntToStr(lv.Items.Count));
      sl.SaveToFile(s);
    finally
      sl.Free;
    end;
  end;
end;
{$endif}

end.
