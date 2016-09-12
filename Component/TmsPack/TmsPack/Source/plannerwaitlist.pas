{$I TMSDEFS.INC}
{***********************************************************************}
{ TPlanner component                                                    }
{ for Delphi & C++Builder                                               }
{                                                                       }
{ written by TMS Software                                               }
{            copyright © 2003 - 2010                                    }
{            Email: info@tmssoftware.com                                }
{            Web: http://www.tmssoftware.com                            }
{                                                                       }
{ The source code is given as is. The author is not responsible         }
{ for any possible damage done due to the use of this code.             }
{ The component can be freely used in any application. The complete     }
{ source code remains property of the author and may not be distributed,}
{ published, given or sold in any form as such. No parts of the source  }
{ code can be included in any other component or application without    }
{ written authorization of the author.                                  }
{***********************************************************************}

unit PlannerWaitList;

interface

{$I TMSDEFS.INC}

uses
  Planner, Classes, Windows, StdCtrls, Dialogs, Controls, Messages, Forms, PictureContainer;

const
  MAJ_VER = 2; // Major version nr.
  MIN_VER = 5; // Minor version nr.
  REL_VER = 0; // Release nr.
  BLD_VER = 4; // Build nr.

  // version history
  // 2.0.0.1 : improved OnItemSelect event handling
  // 2.5.0.0 : compatible with TPlanner v2.5
  //         : Added method CopyToPlanner
  // 2.5.0.3 : Change for showing richedit text
  // 2.5.0.4 : Fixed painting issue in Delphi 2007

type
  {$IFDEF DELPHI_UNICODE}
  THintInfo = Controls.THintInfo;
  PHintInfo = Controls.PHintInfo;
  {$ENDIF}

  TItemHintEvent = procedure(Sender: TObject; Item: TPlannerItem; var AHint: string) of object;

  TItemEvent = procedure(Sender: TObject; Item: TPlannerItem) of object;

  TPlannerWaitList = class(TCustomListbox)
  private
    FPlanner: TPlanner;
    FOnItemHint: TItemHintEvent;
    FOnItemSelect: TItemEvent;
    FOldIdx: Integer;
    FOldHintIdx: Integer;
    FShowSelection: Boolean;
    FOnItemRightClick: TItemEvent;
    FOnItemClick: TItemEvent;
    FOnItemDblClick: TItemEvent;
    FSkin: TPlannerSkin;
    function GetItems: TPlannerItems;
    procedure SetItems(const Value: TPlannerItems);
    procedure SetDefaultItem(const Value: TPlannerItem);
    function GetDefaultItem: TPlannerItem;
    {$IFDEF TMSDOTNET}
    procedure CMHintShow(var Message: TCMHintShow); message CM_HINTSHOW;
    {$ENDIF}
    {$IFNDEF TMSDOTNET}
    procedure CMHintShow(var Message: TMessage); message CM_HINTSHOW;
    {$ENDIF}
    procedure WMLButtonDblClk(var Message: TWMLButtonDblClk); message WM_LBUTTONDBLCLK;
    function GetImages: TImageList;
    procedure SetImages(const Value: TImageList);
    function GetPictureContainer: TPictureContainer;
    procedure SetPictureContainer(const Value: TPictureContainer);
    procedure SetPlannerSkin(const Value: TPlannerSkin);
    function GetVersion: string;
    procedure SetVersion(const Value: string);
    function GetVersionNr: Integer;
  protected
    procedure ItemsChanged(Sender: TObject);
    procedure ItemsUpdated(Sender: TObject);
    procedure DrawItem(Index: Integer; Rect: TRect;State: TOwnerDrawState); override;
    procedure DragOver(Source: TObject; X, Y: Integer;
      State: TDragState; var Accept: Boolean); override;
    procedure Notification(AComponent: TComponent; AOperation: TOperation); override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    procedure KeyUp(var Key: Word; Shift: TShiftState); override;
    procedure DoExit; override;
    function CreatePlanner: TPlanner; virtual;
  public
    constructor Create(AOwner: TComponent); override;
    procedure CreateWnd; override;
    destructor Destroy; override;
    procedure Loaded; override;
    {$IFDEF DELPHI6_LVL}
    procedure DeleteSelected; override;
    {$ENDIF}
    {$IFNDEF DELPHI6_LVL}
    procedure DeleteSelected;
    {$ENDIF}
    procedure DragDrop(Source: TObject; X, Y: Integer); override;
    procedure MoveToPlanner(APlanner: TCustomPlanner; ItemIndex: Integer; X,Y: Integer);
    procedure CopyToPlanner(APlanner: TCustomPlanner; ItemIndex: Integer; X,Y: Integer);
    procedure MoveFromPlanner(APlanner: TCustomPlanner; AItem: TPlannerItem);
  published
    property DefaultItem: TPlannerItem read GetDefaultItem write SetDefaultItem;
    property Images: TImageList read GetImages write SetImages;
    property Items: TPlannerItems read GetItems write SetItems;
    property ItemHeight;
    property PictureContainer: TPictureContainer read GetPictureContainer write SetPictureContainer;
    property ShowSelection: Boolean read FShowSelection write FShowSelection;
    property Skin: TPlannerSkin read FSkin write SetPlannerSkin;
    property OnItemHint: TItemHintEvent read FOnItemHint write FOnItemHint;
    property OnItemSelect: TItemEvent read FOnItemSelect write FOnItemSelect;
    property OnItemClick: TItemEvent read FOnItemClick write FOnItemClick;
    property OnItemRightClick: TItemEvent read FOnItemRightClick write FOnItemRightClick;
    property OnItemDblClick: TItemEvent read FOnItemDblClick write FOnItemDblClick;
    property Align;
    property Anchors;
    property BevelEdges;
    property BevelInner;
    property BevelKind;
    property BevelOuter;
    property BiDiMode;
    property BorderStyle;
    property Color;

    property Constraints;
    property Ctl3D;
    property DragCursor;
    property DragKind;
    property DragMode;
    property Enabled;

    property Font;
    property ImeMode;
    property ImeName;
    property MultiSelect;

    property ShowHint;
    property TabOrder;
    property TabStop;
    property TabWidth;
    property Visible;
    property OnClick;
    {$IFDEF DELPHI5_LVL}
    property OnContextPopup;
    {$ENDIF}
    {$IFDEF DELPHI6_LVL}
    property OnData;
    property OnDataFind;
    property OnDataObject;
    {$ENDIF}
    property OnDblClick;
    property OnDragDrop;
    property OnDragOver;
    property OnDrawItem;
    property OnEndDock;
    property OnEndDrag;
    property OnEnter;
    property OnExit;
    property OnKeyDown;
    property OnKeyPress;
    property OnKeyUp;
    property OnMeasureItem;
    property OnMouseDown;
    property OnMouseMove;
    property OnMouseUp;
    property OnStartDock;
    property OnStartDrag;
    property Version: string read GetVersion write SetVersion;
  end;

  TPlannerItemCrack = class(TPlannerItem);


implementation

uses
  SysUtils;

{ TPlannerWaitList }

{$IFNDEF TMSDOTNET}
procedure TPlannerWaitList.CMHintShow(var Message: TMessage);
{$ENDIF}
{$IFDEF TMSDOTNET}
procedure TPlannerWaitList.CMHintShow(var Message: TCMHintShow);
{$ENDIF}
var
  Idx: Integer;
{$IFNDEF TMSDOTNET}
  hi: PHintInfo;
{$ENDIF}
{$IFDEF TMSDOTNET}
  hi: THintInfo;
{$ENDIF}
  AHint: string;

begin
{$IFNDEF TMSDOTNET}
  hi := PHintInfo(Message.LParam);
  Idx := SendMessage(Handle,LB_ITEMFROMPOINT,0,MakeLParam(Hi^.CursorPos.X,Hi^.CursorPos.Y));
  if (Idx >= 0) and (Idx < Items.Count) then
  begin
    AHint := Items[Idx].Hint;
    if Assigned(FOnItemHint) then
      FOnItemHint(Self, Items[Idx],AHint);
    Hi^.HintStr := AHint;
  end;
{$ENDIF}
{$IFDEF TMSDOTNET}
  hi := Message.HintInfo;
  Idx := SendMessage(Handle,LB_ITEMFROMPOINT,0,MakeLParam(Hi.CursorPos.X,Hi.CursorPos.Y));
  if (Idx >= 0) and (Idx < Items.Count) then
  begin
    AHint := Items[Idx].Hint;
    if Assigned(FOnItemHint) then
      FOnItemHint(Self, Items[Idx],AHint);
    Hi.HintStr := AHint;
  end;
{$ENDIF}

end;

constructor TPlannerWaitList.Create(AOwner: TComponent);
begin
  inherited;
  FPlanner := CreatePlanner;
  FPlanner.OnConflictUpdate := ItemsChanged;
  FPlanner.OnItemUpdate := ItemsUpdated;

  Style := lbOwnerDrawFixed;
  DragMode := dmAutomatic;
  ItemHeight := 32;
  FOldIdx := -1;
  DoubleBuffered := True;

  FSkin := TPlannerSkin.Create(FPlanner);
end;

function TPlannerWaitList.CreatePlanner: TPlanner;
begin
  Result := TPlanner.Create(Self);
end;

procedure TPlannerWaitList.DeleteSelected;
var
  i: integer;
begin
  if MultiSelect then
  begin
    for i := Items.Count - 1 downto 0 do
      begin
        if Selected[i] then
          Items.Delete(i);
      end;
  end
  else
    if ItemIndex >= 0 then
      Items.Delete(ItemIndex);
end;

destructor TPlannerWaitList.Destroy;
begin
  FPlanner.OnConflictUpdate := nil;
  FPlanner.OnItemUpdate := nil;
  FPlanner.Free;
  FSkin.Free; 
  inherited;
end;

procedure TPLannerWaitList.CreateWnd;
begin
  inherited;
  // required change for richedit support
  FPlanner.Parent := self;
  FPLanner.Width :=0;
  FPlanner.Height := 0;
end;

procedure TPlannerWaitList.DragDrop(Source: TObject; X, Y: Integer);
begin
  if Assigned(OnDragDrop) then
    OnDragDrop(Self,Source, X, Y)
  else
    if Source is TCustomPlanner then
    begin
      MoveFromPlanner((Source as TCustomPlanner),(Source as TCustomPlanner).Items.Selected);
    end;
end;

procedure TPlannerWaitList.DragOver(Source: TObject; X, Y: Integer;
  State: TDragState; var Accept: Boolean);
begin
  Accept := (Source is TPlanner);
  if Assigned(OnDragOver) then
    OnDragOver(Self,Source, X,Y, State, Accept);
end;

procedure TPlannerWaitList.DrawItem(Index: Integer; Rect: TRect;
  State: TOwnerDrawState);
begin
  if (Index >= 0) and (Index < FPLanner.Items.Count) then
  begin
    FPlanner.ItemGap := 0;
    FPlanner.Items[Index].Selected := ShowSelection and (odSelected in State);
    FPlanner.Items[Index].Repainted := False;
    TPlannerItemCrack(FPlanner.Items[Index]).Preview := true;
    FPlanner.PreviewPaint(FPlanner.Items[Index], Canvas, Rect, False, False);
  end;
end;

function TPlannerWaitList.GetDefaultItem: TPlannerItem;
begin
  Result := FPlanner.DefaultItem;
end;

function TPlannerWaitList.GetImages: TImageList;
begin
  Result := FPlanner.PlannerImages;
end;

function TPlannerWaitList.GetItems: TPlannerItems;
begin
  Result := FPlanner.Items;
end;

function TPlannerWaitList.GetPictureContainer: TPictureContainer;
begin
  Result := FPlanner.PictureContainer;
end;

procedure TPlannerWaitList.ItemsChanged(Sender: TObject);
begin
  if FPlanner.Items.Count = 0 then
  begin
    inherited Items.Clear;
    Exit;
  end;

  while FPlanner.Items.Count > inherited Items.Count do
  begin
    inherited Items.Add(inttostr(inherited items.Count));
  end;

  while FPlanner.Items.Count < inherited Items.Count do
  begin
    inherited Items.Delete(inherited Items.Count - 1);
  end;
end;

procedure TPlannerWaitList.ItemsUpdated(Sender: TObject);
begin
  Invalidate;
end;

procedure TPlannerWaitList.KeyUp(var Key: Word; Shift: TShiftState);
begin
  inherited;

  if (FOldIdx <> ItemIndex) and (ItemIndex >= 0) and (ItemIndex < Items.Count) then
  begin
    if Assigned(FOnItemSelect) then
      FOnItemSelect(Self, Items[ItemIndex]);
  end;
  
  FOldIdx := ItemIndex;
end;

procedure TPlannerWaitList.Loaded;
begin
  inherited;
  FPlanner.Skin.Assign(Skin);
end;

procedure TPlannerWaitList.DoExit;
begin
  inherited;
  FOldIdx := -1;
end;

procedure TPlannerWaitList.MouseDown(Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
  Idx: Integer;
begin
  inherited;

  Idx := SendMessage(Handle,LB_ITEMFROMPOINT,0,MakeLParam(X,Y));

  if (FOldIdx <> Idx) and (Idx >= 0) and (Idx < Items.Count) then
  begin
    if Assigned(FOnItemSelect) then
      FOnItemSelect(Self, Items[Idx]);
  end;

  if (Idx >= 0) and (Idx < Items.Count) then
  begin
    if (Button = mbRight) and Assigned(FOnItemRightClick) then
      FOnItemRightClick(Self, Items[Idx]);

    if (Button = mbLeft) and Assigned(FOnItemClick) then
      FOnItemClick(Self, Items[Idx]);
  end;

  FOldIdx := Idx;
end;

procedure TPlannerWaitList.MouseMove(Shift: TShiftState; X, Y: Integer);
var
  Idx: Integer;
begin
  inherited;
  Idx := SendMessage(Handle,LB_ITEMFROMPOINT,0,MakeLParam(X,Y));

  if (Idx <> FOldHintIdx) and ShowHint then
  begin
    Application.CancelHint;
  end;
  FOldHintIdx := Idx;
end;

procedure TPlannerWaitList.MoveFromPlanner(APlanner: TCustomPlanner;
  AItem: TPlannerItem);
var
  bi,bp: integer;
begin
  with Items.Add do
  begin
    bi := APlanner.Items.Selected.ItemBegin;
    bp := APlanner.Items.Selected.ItemPos;

    Assign(AItem);
    APlanner.FreeItem(APlanner.Items.Selected);
    APlanner.Items.Selected := nil;
    if not APlanner.SelectionAlways then
    begin
      APlanner.SelectCells(bi,bi,bp);
    end;
  end;
end;

procedure TPlannerWaitList.MoveToPlanner(APlanner: TCustomPlanner;
  ItemIndex: Integer; X, Y: Integer);
var
  pt: TPoint;
  plIt: TPlannerItem;
  delta: Integer;
begin
  pt := APlanner.XYToCell(X,Y);

  with APlanner.CreateItem do
  begin
    plIt := Items[ItemIndex];
    delta := plIt.ItemEnd - plIt.ItemBegin;
    ItemObject:= Items[ItemIndex].ItemObject;

    Assign(plIt);

    if APlanner.SideBar.Position = spTop then
    begin
      ItemBegin := pt.X;
      ItemEnd := pt.X + delta;
      ItemPos := pt.Y;
    end
    else
    begin
      ItemBegin := pt.Y;
      ItemEnd := pt.Y + delta;
      ItemPos := pt.X;
    end;


    Update;

    Items[ItemIndex].Free;
  end;

end;

procedure TPlannerWaitList.CopyToPlanner(APlanner: TCustomPlanner;
  ItemIndex: Integer; X, Y: Integer);
var
  pt: TPoint;
  plIt: TPlannerItem;
  delta: Integer;
begin
  pt := APlanner.XYToCell(X,Y);

  with APlanner.CreateItem do
  begin
    plIt := Items[ItemIndex];
    delta := plIt.ItemEnd - plIt.ItemBegin;
    ItemObject:= Items[ItemIndex].ItemObject;
    Assign(plIt);

    if APlanner.SideBar.Position = spTop then
    begin
      ItemBegin := pt.X;
      ItemEnd := pt.X + delta;
      ItemPos := pt.Y;
    end
    else
    begin
      ItemBegin := pt.Y;
      ItemEnd := pt.Y + delta;
      ItemPos := pt.X;
    end;

    Update;
  end;
end;

procedure TPlannerWaitList.Notification(AComponent: TComponent;
  AOperation: TOperation);
begin
  inherited;

  if csDestroying in ComponentState then
    Exit;

  if (AOperation = opRemove) and Assigned(DefaultItem) then
  begin
    if DefaultItem.Alarm.Handler = AComponent then
      DefaultItem.Alarm.Handler := nil;
    if DefaultItem.Editor = AComponent then
      DefaultItem.Editor := nil;
    if DefaultItem.PopupMenu = AComponent then
      DefaultItem.PopupMenu := nil;
    if DefaultItem.DrawTool = AComponent then
      DefaultItem.DrawTool := nil;
  end;
end;

procedure TPlannerWaitList.SetDefaultItem(const Value: TPlannerItem);
begin
  FPlanner.DefaultItem.Assign(Value);
end;

procedure TPlannerWaitList.SetImages(const Value: TImageList);
begin
  FPlanner.PlannerImages := Value;
end;

procedure TPlannerWaitList.SetItems(const Value: TPlannerItems);
begin
  FPlanner.Items.Assign(Value); 
end;


procedure TPlannerWaitList.SetPictureContainer(
  const Value: TPictureContainer);
begin
  FPlanner.PictureContainer := Value;
end;

procedure TPlannerWaitList.SetPlannerSkin(const Value: TPlannerSkin);
begin
  FSkin.Assign(Value);
end;

procedure TPlannerWaitList.WMLButtonDblClk(var Message: TWMLButtonDblClk);
var
  Idx: Integer;
begin
  Idx := SendMessage(Handle,LB_ITEMFROMPOINT,0,MakeLParam(Message.XPos ,Message.YPos));

  if (Idx >= 0) and (Idx < Items.Count) and Assigned(FOnItemDblClick) then
  begin
    FOnItemDblClick(Self, Items[Idx]);
  end;

end;

function TPlannerWaitList.GetVersion: string;
var
  vn: Integer;
begin
  vn := GetVersionNr;
  Result := IntToStr(Hi(Hiword(vn)))+'.'+IntToStr(Lo(Hiword(vn)))+'.'+IntToStr(Hi(Loword(vn)))+'.'+IntToStr(Lo(Loword(vn)));
end;

function TPlannerWaitList.GetVersionNr: Integer;
begin
  Result := MakeLong(MakeWord(BLD_VER,REL_VER),MakeWord(MIN_VER,MAJ_VER));
end;

procedure TPlannerWaitList.SetVersion(const Value: string);
begin

end;


end.
