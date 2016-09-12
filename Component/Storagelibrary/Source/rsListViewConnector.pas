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
unit rsListViewConnector;

interface

{$I rsStorage.inc}

uses Classes, SysUtils,
     {$IFDEF RSL_WIN}Comctrls,{$ELSE}QComCtrls,{$ENDIF}
     {$IFDEF RSL_D6GE}Variants,{$ENDIF}
     rsStorage, rsConst;

type
  TrsLVCTraceOption = (lvcTraceEdited, lvcTraceDeletion, lvcTraceInsert);
  TrsLVCTraceOptions = set of TrsLVCTraceOption;


  TrsListViewConnector = class(TrsStorageClient)
  private
    FKeyList: TStringList;
    FListView: TCustomListView;
    FItems: TListItems;

    FTraceOptions: TrsLVCTraceOptions;
    FRealTraceOptions: TrsLVCTraceOptions;
    FCurrentState: TrsLVCTraceOptions;

    FSafeListOnDeletion: {$IFDEF RSL_WIN}TLVDeletedEvent{$ELSE}TLVNotifyEvent{$ENDIF};
    FSafeListOnInsert: {$IFDEF RSL_WIN}TLVDeletedEvent{$ELSE}TLVNotifyEvent{$ENDIF};
    FSafeListOnEdited: TLVEditedEvent;

    procedure ChangeTraceOptions(const OldValue,NewValue: TrsLVCTraceOptions);

    procedure NewListOnDeletion(Sender: TObject; Item: TListItem);
    procedure NewListOnInsert(Sender: TObject; Item: TListItem);
    procedure NewListOnEdited(Sender: TObject; Item: TListItem;
                              var S: {$IFDEF RSL_WIN}string{$ELSE}WideString{$ENDIF});

    procedure SetListView(const Value: TCustomListView);
    procedure SetTraceOptions(const Value: TrsLVCTraceOptions);
  protected
    procedure SetActive(const Value: Boolean); override;
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
    procedure rsNotification(const Value: TrsClientNotification; WParam, LParam: Longint); override;

    procedure ListViewPrepare(const Operation: boolean);
    procedure ListViewAddItem(const KeyName: string);
    procedure ListViewDeleteItem(const KeyName: string);
    procedure ListViewModifyItem(const OldKeyName, NewKeyName: string);
    procedure ListViewModifyKeyValue(const KeyName: string);
    function  ListViewFindAddItem(const Value: String; const CanAdd: boolean): TListItem;
    procedure ListViewLoadItems(Items: TListItems);
    procedure ListViewClearItems(Items: TListItems);
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    function SelectKey(const KeyName: string): TListItem;
    function FindItem(const Value: String): TListItem;
  published
    property Active;
    property ListView: TCustomListView read FListView write SetListView;
    property Storage;
    property TraceOptions: TrsLVCTraceOptions read FTraceOptions write SetTraceOptions;
  end;


implementation

uses rsUtils;

type
  THackListView = class(TCustomListView);

{ TrsListViewConnector }

constructor TrsListViewConnector.Create(AOwner: TComponent);
begin
  inherited;
  FNotifications := [scnClear, scnLoad, scnRootSectionChanged, scnKeyAdd, scnKeyDelete, scnKeyModify,
                     scnKeyValueModify];
  FKeyList := TStringList.Create;
{$IFDEF RSL_AUTOLINKREFERENCES}
  if csDesigning in ComponentState then begin
    Storage := TrsStorage(rsGlobalFindComponent(TrsStorage, AOwner, nil));
  end;
{$ENDIF}
end;

destructor TrsListViewConnector.Destroy;
begin
  Active := False;
  ChangeTraceOptions(TraceOptions, []);
  FKeyList.Free;
  inherited;
end;

function TrsListViewConnector.ListViewFindAddItem(const Value: String; const CanAdd: boolean): TListItem;
var
  i,cmpRes: integer;
  ApropriateItem: TListItem;
  flApropriate: boolean;
begin
  Result := nil;
  if Value='' then Exit;

  ApropriateItem := nil;
  flApropriate := False;
  for i:=0 to FItems.Count-1 do begin
    cmpRes := CompareText(Value, FItems.Item[i].Caption);
    if cmpRes=0 then begin
      Result := FItems.Item[i];
      Break;
    end else
    if (cmpRes>=0) and (not flApropriate) then begin
      flApropriate := True;
      ApropriateItem := FItems.Item[i];
    end;
  end;

  if (Result=nil) and CanAdd then begin
    if ApropriateItem<>nil then begin
      Result := FItems.Insert(ApropriateItem.Index);
    end else begin
      Result := FItems.Add;
    end;
    Result.Caption := Value;
    if THackListView(FListView).Columns.Count>1 then begin
      Result.SubItems.Add(VarToStr(Storage.Values[Value]));
    end;
  end;
end;


procedure TrsListViewConnector.ListViewLoadItems(Items: TListItems);
var
  i: integer;
  li: TListItem;
  cs: TrsLVCTraceOptions;
begin
  with Items do begin
    BeginUpdate;
    //2002-11-21 fix bug with TraceOption.lvcTraceDeletion=True
    cs := FCurrentState;
    FCurrentState := FCurrentState + [lvcTraceDeletion,lvcTraceInsert];

    Clear;
    Storage.KeyList(FKeyList);
    for i:=0 to FKeyList.Count-1 do begin
      li := Add;
      li.Caption := FKeyList[i];
      if THackListView(FListView).Columns.Count>1 then begin
        case Storage.KeyType[FKeyList[i]] of
          kvtBool: if Storage.KeyWrapper.AsBoolean
                     then li.SubItems.Add(RSBooleanIdentsTrue)
                     else li.SubItems.Add(RSBooleanIdentsFalse);
          else li.SubItems.Add(VarToStr(Storage.Values[FKeyList[i]]));
        end;
      end;
    end;
    FCurrentState := cs;
    EndUpdate;
  end;
end;

procedure TrsListViewConnector.ListViewClearItems(Items: TListItems);
var
  cs: TrsLVCTraceOptions;
begin
  with Items do begin
    BeginUpdate;
    //2002-11-21 fix bug with TraceOption.lvcTraceDeletion=True
    cs := FCurrentState;
    FCurrentState := FCurrentState + [lvcTraceDeletion,lvcTraceInsert];
    Clear;
    FCurrentState := cs;
    EndUpdate;
  end;
end;

procedure TrsListViewConnector.Notification(AComponent: TComponent; Operation: TOperation);
begin
  inherited;
  if (Operation=opRemove) and (AComponent=FListView) then ListView := nil;
end;

procedure TrsListViewConnector.rsNotification(const Value: TrsClientNotification; WParam, LParam: Integer);
begin
  inherited;
  if Active and (FListView<>nil) and (Storage<>nil) then begin
    FItems := THackListView(FListView).Items;
    case Value of
      scnClear: ListViewClearItems(FItems);
      scnLoad,
      scnRootSectionChanged: ListViewLoadItems(FItems);
      scnKeyAdd:    if not (lvcTraceInsert in FCurrentState) then ListViewAddItem(RSLString(WParam));
      scnKeyDelete: if not (lvcTraceDeletion in FCurrentState) then ListViewDeleteItem(RSLString(WParam));
      scnKeyModify: if not (lvcTraceEdited in FCurrentState) then ListViewModifyItem(RSLString(WParam), RSLString(LParam));
      scnKeyValueModify: ListViewModifyKeyValue(RSLString(WParam));
    end;
  end;
end;

procedure TrsListViewConnector.SetActive(const Value: Boolean);
begin
  if Value<>Active then begin
    if Value then FActive := True;
    ListViewPrepare(Value);
    if not Value then FActive := False;
  end;
end;

procedure TrsListViewConnector.SetListView(const Value: TCustomListView);
begin
  if FListView<>Value then begin
    if (FListView<>nil) and Active then ListViewPrepare(False);

    FListView := Value;

    if FListView<>nil then begin
      FListView.FreeNotification(Self);
      if Active then ListViewPrepare(True);
    end;
  end;
end;

procedure TrsListViewConnector.ListViewAddItem(const KeyName: string);
begin
  ListViewFindAddItem(KeyName, True);
end;

procedure TrsListViewConnector.ListViewDeleteItem(const KeyName: string);
var
  li: TListItem;
begin
  li := ListViewFindAddItem(KeyName, False);
  if li<>nil then li.Delete;
end;

procedure TrsListViewConnector.ListViewModifyItem(const OldKeyName, NewKeyName: string);
var
  li: TListItem;
begin
  li := ListViewFindAddItem(OldKeyName, False);
  if li<>nil then li.Caption := NewKeyName;
end;

procedure TrsListViewConnector.ListViewModifyKeyValue(const KeyName: string);
begin
{}
end;

procedure TrsListViewConnector.SetTraceOptions(const Value: TrsLVCTraceOptions);
begin
  if FTraceOptions<>Value then begin
    ChangeTraceOptions(FTraceOptions, Value);
    FTraceOptions := Value;
  end;
end;

procedure TrsListViewConnector.ChangeTraceOptions(const OldValue, NewValue: TrsLVCTraceOptions);
begin
  if (FListView<>nil) and Active then begin

    //TraceDeletion add,delete,check
    if not (lvcTraceDeletion in (OldValue*NewValue)) then begin
      if lvcTraceDeletion in NewValue then begin // Set Event
        if not (lvcTraceDeletion in FRealTraceOptions) then begin
          FSafeListOnDeletion := THackListView(FListView).OnDeletion;
          THackListView(FListView).OnDeletion := NewListOnDeletion;
          Include(FRealTraceOptions, lvcTraceDeletion);
        end;
      end else begin // Unset Event
        if lvcTraceDeletion in FRealTraceOptions then begin
          THackListView(FListView).OnDeletion := FSafeListOnDeletion;
          FSafeListOnDeletion := nil;
          Exclude(FRealTraceOptions, lvcTraceDeletion);
        end;
      end;
    end;

    //TraceEdited add,delete,check
    if not (lvcTraceEdited in (OldValue*NewValue)) then begin
      if lvcTraceEdited in NewValue then begin // Set Event
        if not (lvcTraceEdited in FRealTraceOptions) then begin
          FSafeListOnEdited := THackListView(FListView).OnEdited;
          THackListView(FListView).OnEdited := NewListOnEdited;
          Include(FRealTraceOptions, lvcTraceEdited);
        end;
      end else begin // Unset Event
        if lvcTraceEdited in FRealTraceOptions then begin
          THackListView(FListView).OnEdited := FSafeListOnEdited;
          FSafeListOnEdited := nil;
          Exclude(FRealTraceOptions, lvcTraceEdited);
        end;
      end;
    end;

    //TraceInsert add,delete,check
    if not (lvcTraceInsert in (OldValue*NewValue)) then begin
      if lvcTraceInsert in NewValue then begin // Set Event
        if not (lvcTraceInsert in FRealTraceOptions) then begin
          FSafeListOnInsert := THackListView(FListView).OnInsert;
          THackListView(FListView).OnInsert := NewListOnInsert;
          Include(FRealTraceOptions, lvcTraceInsert);
        end;
      end else begin // Unset Event
        if lvcTraceInsert in FRealTraceOptions then begin
          THackListView(FListView).OnInsert := FSafeListOnInsert;
          FSafeListOnInsert := nil;
          Exclude(FRealTraceOptions, lvcTraceInsert);
        end;
      end;
    end;

  end;
//  FTraceOptions := NewValue;
end;

function TrsListViewConnector.FindItem(const Value: String): TListItem;
begin
  Result := ListViewFindAddItem(Value, False);
end;

procedure TrsListViewConnector.ListViewPrepare(const Operation: boolean);
begin
  if Operation then begin
    rsNotification(scnLoad, 0, 0);
    ChangeTraceOptions([], FTraceOptions);
  end else begin
    ChangeTraceOptions(FTraceOptions, []);
    if not (csDestroying in ComponentState) then rsNotification(scnClear, 0, 0);
  end;
end;

procedure TrsListViewConnector.NewListOnDeletion(Sender: TObject; Item: TListItem);
begin
  if Assigned(FSafeListOnDeletion) then FSafeListOnDeletion(Sender, Item);
  if not (lvcTraceDeletion in FCurrentState) then begin
    Include(FCurrentState, lvcTraceDeletion);
    if Active and (Storage<>nil) then Storage.KeyDelete(Item.Caption);
    Exclude(FCurrentState, lvcTraceDeletion);
  end;
end;

procedure TrsListViewConnector.NewListOnInsert(Sender: TObject; Item: TListItem);
begin
  if Assigned(FSafeListOnInsert) then FSafeListOnInsert(Sender, Item);
  if not (lvcTraceInsert in FCurrentState) then begin
    Include(FCurrentState, lvcTraceInsert);
    if Active and (Storage<>nil) then Storage.WriteString(Item.Caption, '');
    Exclude(FCurrentState, lvcTraceInsert);
  end;
end;

procedure TrsListViewConnector.NewListOnEdited(Sender: TObject; Item: TListItem;
                                               var S: {$IFDEF RSL_WIN}string{$ELSE}WideString{$ENDIF});
begin
  if Assigned(FSafeListOnEdited) then FSafeListOnEdited(Sender, Item, S);
  if not (lvcTraceEdited in FCurrentState) then begin
    Include(FCurrentState, lvcTraceEdited);
    if Active and (Storage<>nil) then Storage.KeyRename(Item.Caption, S);
    Exclude(FCurrentState, lvcTraceEdited);
  end;
end;

function TrsListViewConnector.SelectKey(const KeyName: string): TListItem;
begin
  Result := ListViewFindAddItem(KeyName, False);
  if Result<>nil then Result.Selected := True;
end;

end.
