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
unit rsTreeViewConnector;

interface

{$I rsStorage.inc}

{$IFDEF RSL_D6GE}
 {$IFDEF RSL_WIN}
   {$DEFINE RSL_TREEONADDITION}
 {$ENDIF}
{$ENDIF}

uses Classes, SysUtils,
     {$IFDEF RSL_WIN}Comctrls,{$ELSE}QComCtrls,{$ENDIF}
     rsStorage, rsConst;

type
  TrsTVCTraceOption = (tvcTraceChange, tvcTraceEdited, tvcTraceDeletion{$IFDEF RSL_TREEONADDITION}, tvcTraceAddition{$ENDIF});
  TrsTVCTraceOptions = set of TrsTVCTraceOption;

  TrsTreeViewConnector = class(TrsStorageClient)
  private
    FTreeView: TCustomTreeView;
    FItems: TTreeNodes;
    FTraceOptions: TrsTVCTraceOptions;
    FRealTraceOptions: TrsTVCTraceOptions;
    FCurrentState: TrsTVCTraceOptions;

    FSafeTreeOnChange: TTVChangedEvent;
    FSafeTreeOnDeletion: TTVExpandedEvent;
    FSafeTreeOnEdited: TTVEditedEvent;
    {$IFDEF RSL_TREEONADDITION}
    FSafeTreeOnAddition: TTVExpandedEvent;
    {$ENDIF}

    procedure ChangeTraceOptions(const OldValue,NewValue: TrsTVCTraceOptions);
    procedure SetTreeView(const Value: TCustomTreeView);
    procedure SetTraceOptions(const Value: TrsTVCTraceOptions);
    procedure NewTreeOnChange(Sender: TObject; Node: TTreeNode);
    procedure NewTreeOnDeletion(Sender: TObject; Node: TTreeNode);
    procedure NewTreeOnEdited(Sender: TObject; Node: TTreeNode;
                              var S: {$IFDEF RSL_WIN}string{$ELSE}WideString{$ENDIF});
    {$IFDEF RSL_TREEONADDITION}
    procedure NewTreeOnAddition(Sender: TObject; Node: TTreeNode);
    {$ENDIF}

    procedure TreePrepare(const Operation: boolean);
  protected
    procedure SetActive(const Value: Boolean); override;
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
    procedure rsNotification(const Value: TrsClientNotification; WParam, LParam: Longint); override;

    procedure TreeViewAddItem(const SectionName: string);
    procedure TreeViewChangeSelected(const SectionName: string);
    procedure TreeViewDeleteItem(const SectionName: string);
    procedure TreeViewItemClear(const SectionName: string);
    procedure TreeViewLoadItems(Items: TTreeNodes);
    function TreeViewFindAddNode(Items: TTreeNodes; const Value: string; const CanAdd: boolean): TTreeNode;
    procedure RecursionLoadItems(Node: TTreeNode);
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    function NodeName(Node: TTreeNode): string;
    function SectionName(Node: TTreeNode): string;
  published
    property Active;
    property Storage;
    property TraceOptions: TrsTVCTraceOptions read FTraceOptions write SetTraceOptions;
    property TreeView: TCustomTreeView read FTreeView write SetTreeView;
  end;

implementation

uses rsUtils;

type
  THackTreeView = class(TCustomTreeView);
  THackStorage = class(TrsStorage);

{ TrsTreeViewConnector }

procedure TrsTreeViewConnector.ChangeTraceOptions(const OldValue, NewValue: TrsTVCTraceOptions);
begin
  if (FTreeView<>nil) and Active then begin

    //TraceChange add,delete,check
    if not (tvcTraceChange in (OldValue*NewValue)) then begin
      if tvcTraceChange in NewValue then begin // Set Event
        if not (tvcTraceChange in FRealTraceOptions) then begin
          FSafeTreeOnChange := THackTreeView(FTreeView).OnChange;
          THackTreeView(FTreeView).OnChange := NewTreeOnChange;
          Include(FRealTraceOptions, tvcTraceChange);
        end;
      end else begin // Unset Event
        if tvcTraceChange in FRealTraceOptions then begin
          THackTreeView(FTreeView).OnChange := FSafeTreeOnChange;
          FSafeTreeOnChange := nil;
          Exclude(FRealTraceOptions, tvcTraceChange);
        end;
      end;
    end;

    //TraceDeletion add,delete,check
    if not (tvcTraceDeletion in (OldValue*NewValue)) then begin
      if tvcTraceDeletion in NewValue then begin // Set Event
        if not (tvcTraceDeletion in FRealTraceOptions) then begin
          FSafeTreeOnDeletion := THackTreeView(FTreeView).OnDeletion;
          THackTreeView(FTreeView).OnDeletion := NewTreeOnDeletion;
          Include(FRealTraceOptions, tvcTraceDeletion);
        end;
      end else begin // Unset Event
        if tvcTraceDeletion in FRealTraceOptions then begin
          THackTreeView(FTreeView).OnDeletion := FSafeTreeOnDeletion;
          FSafeTreeOnDeletion := nil;
          Exclude(FRealTraceOptions, tvcTraceDeletion);
        end;
      end;
    end;

    //TraceEdited add,delete,check
    if not (tvcTraceEdited in (OldValue*NewValue)) then begin
      if tvcTraceEdited in NewValue then begin // Set Event
        if not (tvcTraceEdited in FRealTraceOptions) then begin
          FSafeTreeOnEdited := THackTreeView(FTreeView).OnEdited;
          THackTreeView(FTreeView).OnEdited := NewTreeOnEdited;
          Include(FRealTraceOptions, tvcTraceEdited);
        end;
      end else begin // Unset Event
        if tvcTraceEdited in FRealTraceOptions then begin
          THackTreeView(FTreeView).OnEdited := FSafeTreeOnEdited;
          FSafeTreeOnEdited := nil;
          Exclude(FRealTraceOptions, tvcTraceEdited);
        end;
      end;
    end;

    {$IFDEF RSL_TREEONADDITION}
    //TraceAddition add,delete,check
    if not (tvcTraceAddition in (OldValue*NewValue)) then begin
      if tvcTraceAddition in NewValue then begin // Set Event
        if not (tvcTraceAddition in FRealTraceOptions) then begin
          FSafeTreeOnAddition := THackTreeView(FTreeView).OnAddition;
          THackTreeView(FTreeView).OnAddition := NewTreeOnAddition;
          Include(FRealTraceOptions, tvcTraceAddition);
        end;
      end else begin // Unset Event
        if tvcTraceAddition in FRealTraceOptions then begin
          THackTreeView(FTreeView).OnAddition := FSafeTreeOnAddition;
          FSafeTreeOnAddition := nil;
          Exclude(FRealTraceOptions, tvcTraceAddition);
        end;
      end;
    end;
    {$ENDIF}

  end;
//  FTraceOptions := NewValue;
end;

constructor TrsTreeViewConnector.Create(AOwner: TComponent);
begin
  inherited;
  FNotifications := [scnClear, scnLoad, scnSectionAdd, scnSectionDelete, scnSectionClear, scnRootSectionChanged];
{$IFDEF RSL_AUTOLINKREFERENCES}
  if csDesigning in ComponentState then begin
    Storage := TrsStorage(rsGlobalFindComponent(TrsStorage, AOwner, nil));
  end;
{$ENDIF}
end;

destructor TrsTreeViewConnector.Destroy;
begin
  Active := False;
  ChangeTraceOptions(TraceOptions, []);
  inherited;
end;

{$IFDEF RSL_TREEONADDITION}
procedure TrsTreeViewConnector.NewTreeOnAddition(Sender: TObject; Node: TTreeNode);
begin
  if Assigned(FSafeTreeOnAddition) then FSafeTreeOnAddition(Sender, Node);
  if not (tvcTraceAddition in FCurrentState) then begin
    Include(FCurrentState, tvcTraceAddition);
    if Active and (Storage<>nil) then Storage.SectionAdd(NodeName(Node));
    Exclude(FCurrentState, tvcTraceAddition);
  end;
end;
{$ENDIF}

procedure TrsTreeViewConnector.NewTreeOnChange(Sender: TObject; Node: TTreeNode);
begin
  if Assigned(FSafeTreeOnChange) then FSafeTreeOnChange(Sender, Node);
  if not (tvcTraceChange in FCurrentState) then begin
    Include(FCurrentState, tvcTraceChange);
    if Active and (Storage<>nil) then Storage.RootSection := NodeName(Node);
    Exclude(FCurrentState, tvcTraceChange);
  end;
end;

procedure TrsTreeViewConnector.NewTreeOnDeletion(Sender: TObject; Node: TTreeNode);
begin
  if Assigned(FSafeTreeOnDeletion) then FSafeTreeOnDeletion(Sender, Node);
  if not (tvcTraceDeletion in FCurrentState) then begin
    Include(FCurrentState, tvcTraceDeletion);
    if Active and (Storage<>nil) then Storage.SectionDelete(NodeName(Node));
    Exclude(FCurrentState, tvcTraceDeletion);
  end;
end;


procedure TrsTreeViewConnector.NewTreeOnEdited(Sender: TObject; Node: TTreeNode;
                                               var S: {$IFDEF RSL_WIN}string{$ELSE}WideString{$ENDIF});
var
  CurrSectionName: string;
begin
  if Assigned(FSafeTreeOnEdited) then FSafeTreeOnEdited(Sender, Node, S);
  if not (tvcTraceEdited in FCurrentState) then begin
    Include(FCurrentState, tvcTraceEdited);
    if Active and (Storage<>nil) then begin
      CurrSectionName := SectionName(Node);
      Storage.SectionRename(CurrSectionName + '\' + Node.Text,
                            CurrSectionName + '\' + S);
    end;
    Exclude(FCurrentState, tvcTraceEdited);
  end;
end;

function TrsTreeViewConnector.NodeName(Node: TTreeNode): string;
begin
  Result := '';
  While Node<>nil do begin
    if Result<>'' then Result := Node.Text + '\'+ Result
     else Result:= Node.Text;
    Node := Node.Parent;
  end;
  if Result<>'' then Result := '\' + Result;
end;

procedure TrsTreeViewConnector.Notification(AComponent: TComponent; Operation: TOperation);
begin
  inherited;
  if (Operation=opRemove) and (AComponent=FTreeView) then TreeView := nil;
end;

procedure TrsTreeViewConnector.RecursionLoadItems(Node: TTreeNode);
var
  i, KeyRangeBegin, KeyRangeEnd, RngBegin, RngEnd: integer;
  pSI: PrsSectionItem;
  NewNode: TTreeNode;
begin
  if THackStorage(Storage).GetSectionChildRange(KeyRangeBegin, KeyRangeEnd) then
    for i:=KeyRangeBegin to KeyRangeEnd-1 do begin
      pSI := THackStorage(Storage).GetSectionItem(i);
      NewNode := FItems.AddChild(Node, pSI^.Name);
      if Storage.ChangeDownRootSection(pSI^.Name) then begin
        if THackStorage(Storage).GetSectionChildRange(RngBegin, RngEnd) then begin
          RecursionLoadItems(NewNode);
        end;
        Storage.ChangeUpRootSection;
      end;
    end;
end;

procedure TrsTreeViewConnector.rsNotification(const Value: TrsClientNotification; WParam, LParam: Integer);
begin
  inherited;
  if (FTreeView<>nil) and Active then begin
    FItems := THackTreeView(FTreeView).Items;
    case Value of
      scnClear:         FItems.Clear;
      scnLoad:          TreeViewLoadItems(FItems);
      scnSectionAdd:    {$IFDEF RSL_TREEONADDITION}if not (tvcTraceAddition in FCurrentState) then{$ENDIF} TreeViewAddItem(RSLString(WParam));
      scnSectionDelete: if not (tvcTraceDeletion in FCurrentState) then TreeViewDeleteItem(RSLString(WParam));
      scnSectionClear:  TreeViewItemClear(RSLString(WParam));
      scnRootSectionChanged: if not (tvcTraceChange in FCurrentState) then TreeViewChangeSelected(RSLString(WParam));
    end;
  end;
end;

function TrsTreeViewConnector.SectionName(Node: TTreeNode): string;
begin
  Result := '';
  While Node<>nil do begin
    Node := Node.Parent;
    if Node=nil then Break;
    if Result<>'' then Result := Node.Text + '\'+ Result
     else Result:= Node.Text;
  end;
  if Result<>'' then Result := '\' + Result;
end;

procedure TrsTreeViewConnector.SetActive(const Value: Boolean);
begin
  if Value<>Active then begin
    if Value then FActive := True;
    TreePrepare(Value);
    if not Value then FActive := False;
  end;
end;

procedure TrsTreeViewConnector.SetTraceOptions(const Value: TrsTVCTraceOptions);
begin
  if FTraceOptions<>Value then begin
    ChangeTraceOptions(FTraceOptions, Value);
    FTraceOptions := Value;
  end;
end;

procedure TrsTreeViewConnector.SetTreeView(const Value: TCustomTreeView);
begin
  if FTreeView<>Value then begin
    if (FTreeView<>nil) and Active and
       not (csDestroying in FTreeView.ComponentState) then TreePrepare(False);

    FTreeView := Value;

    if FTreeView<>nil then begin
      FTreeView.FreeNotification(Self);
      if Active then TreePrepare(True);
    end;
  end;
end;

procedure TrsTreeViewConnector.TreePrepare(const Operation: boolean);
begin
  if Operation then begin
    rsNotification(scnLoad, 0, 0);
    ChangeTraceOptions([], FTraceOptions);
  end else begin
    ChangeTraceOptions(FTraceOptions, []);
    if not (csDestroying in ComponentState) then rsNotification(scnClear, 0, 0);
  end;
end;

procedure TrsTreeViewConnector.TreeViewAddItem(const SectionName: string);
begin
  TreeViewFindAddNode(FItems, SectionName, True);
end;



procedure TrsTreeViewConnector.TreeViewChangeSelected(const SectionName: string);
var
  Node: TTreeNode;
begin
  if FTreeView.Focused then begin
    Include(FCurrentState, tvcTraceChange);
    Node := TreeViewFindAddNode(FItems, SectionName, False);
    if Node<>nil then begin
      Node.MakeVisible{$IFDEF RSL_K2LE}(False){$ENDIF};
      FTreeView.Selected := Node;
    end;
    Exclude(FCurrentState, tvcTraceChange);
  end;
end;

procedure TrsTreeViewConnector.TreeViewDeleteItem(const SectionName: string);
var
  Node: TTreeNode;
begin
  Include(FCurrentState, tvcTraceDeletion);
  Node := TreeViewFindAddNode(FItems, SectionName, False);
  if Node<>nil then begin
    Node.Delete;
  end;
  Exclude(FCurrentState, tvcTraceDeletion);
end;

function TrsTreeViewConnector.TreeViewFindAddNode(Items: TTreeNodes; const Value: string; const CanAdd: boolean): TTreeNode;
var
  s: string;
  IdxBegin, IdxEnd, Level, cmpRes: integer;
  Node, ApropriateNode: TTreeNode;
  flFindApropriate: boolean;
begin
  Result := Items.GetFirstNode;
//  if Result=nil then Exit;
  if Value='' then begin Result := nil; Exit; end;

  IdxBegin := 1;
  if Value[1] in cSectionSeparators then Inc(IdxBegin);
  Level := 1;
  While True do begin
    for IdxEnd:= IdxBegin to Length(Value) do    // find next section name
     if Value[IdxEnd] in cSectionSeparators then Break;

    s := Copy(Value, IdxBegin, IdxEnd-IdxBegin); // get section name

    if Level=1
      then Node := Result
      else Node := Result.GetFirstChild;

    ApropriateNode := nil;
    flFindApropriate := False;
    While Node<>nil do begin  // find node (or ApropriateNode for Insert method)
     cmpRes := CompareText(Node.Text, s);
     if cmpRes=0 then Break
      else
     if (cmpRes>=0) and (not flFindApropriate) then begin
       flFindApropriate := True;
       ApropriateNode := Node;
     end;

      if Level=1
        then Node := Node.getNextSibling
        else Node := Result.GetNextChild(Node);
    end;

    if (Node=nil) and CanAdd then begin // add node if not finded
      if Level=1 then begin
        if ApropriateNode<>nil then Node := Items.Insert(ApropriateNode, s)
         else Node := Items.AddChild(nil, s)
      end else begin
        if ApropriateNode<>nil then Node := Items.Insert(ApropriateNode, s)
         else Node := Items.AddChild(Result, s);
      end;
    end;

    Result := Node;
    Inc(Level);

    if (IdxEnd>=Length(Value)) OR (Result=nil) then Break else IdxBegin := IdxEnd+1;
  end;
end;


procedure TrsTreeViewConnector.TreeViewItemClear(const SectionName: string);
var
  Node: TTreeNode;
begin
  Node := TreeViewFindAddNode(FItems, SectionName, False);
  if Node<>nil then begin
    Node.DeleteChildren;
  end;
end;

procedure TrsTreeViewConnector.TreeViewLoadItems(Items: TTreeNodes);
var
  s: string;
begin
  Items.BeginUpdate;
  s := Storage.RootSection;
  try
    Items.Clear;
    Storage.RootSection := '';
    RecursionLoadItems(nil);
  finally
    Storage.RootSection := s;
    Items.EndUpdate;
  end;
end;

end.
