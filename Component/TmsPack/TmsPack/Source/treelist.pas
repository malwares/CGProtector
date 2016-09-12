{************************************************************************}
{ TTREELIST component                                                    }
{ for Delphi & C++Builder                                                }
{                                                                        }
{ written by TMS Software                                                }
{            copyright © 2000 - 2010                                     }
{            Email : info@tmssoftware.com                                }
{            Web : http://www.tmssoftware.com                            }
{                                                                        }
{ The source code is given as is. The author is not responsible          }
{ for any possible damage done due to the use of this code.              }
{ The component can be freely used in any application. The complete      }
{ source code remains property of the author and may not be distributed, }
{ published, given or sold in any form as such. No parts of the source   }
{ code can be included in any other component or application without     }
{ written authorization of the author.                                   }
{************************************************************************}

unit TreeList;

{$I TMSDEFS.INC}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms,
  StdCtrls, Comctrls, ExtCtrls, CommCtrl
  {$IFNDEF TMSDOTNET}
  {$IFDEF DELPHI6_LVL}
  , Types
  {$ENDIF}
  {$ENDIF}
  {$IFDEF TMSDOTNET}
  , Types, System.Runtime.InteropServices, Dialogs
  {$ENDIF}
  ;

const
  MAJ_VER = 1; // Major version nr.
  MIN_VER = 0; // Minor version nr.
  REL_VER = 1; // Release nr.
  BLD_VER = 5; // Build nr.

  // 0.8.1.3 : Fixed issue with HeaderImage position
  // 1.0.0.0 : Added support for Delphi 2006, C++Builder 2006
  // 1.0.0.1 : Fixed painting issue for TreeList with zero columns
  // 1.0.0.2 : Fixed issue with RightClickSelect
  // 1.0.0.3 : Fixed issue with HeaderSettings.AllowResize
  // 1.0.0.4 : Fixed issue with VCL.NET
  // 1.0.0.5 : Fixed image drawing issue with XP themes
  // 1.0.1.0 : New : Exposed property TreeList.Header
  //         : New : Exposed property TreeList.Header.IsSizing
  // 1.0.1.1 : Fixed : issue with creating Treelist at runtime
  // 1.0.1.2 : Fixed : issue with painting & scrolling
  // 1.0.1.3 : Fixed : issue with header painting during horizontal scroll
  // 1.0.1.4 : Fixed : issue with setting header visibility false
  // 1.0.1.5 : Fixed : issue with persisting OnHeaderSizeChanged event

type
  TTreeList = class;

  TColumnItem = class(TCollectionItem)
  private
    FWidth: Integer;
    FAlignment: TAlignment;
    FColumnHeader: string;
    FFont: TFont;
    FImage: Boolean;
    FHeaderAlign: TAlignment;
    FHeaderImage: Integer;
    procedure SetWidth(const value:integer);
    procedure SetAlignment(const value:tAlignment);
    procedure SetColumnHeader(const value:string);
    procedure SetFont(const value:TFont);
    procedure SetImage(const Value: boolean);
    procedure SetHeaderAlign(const Value: TAlignment);
    procedure SetHeaderImage(const Value: integer);
  public
    constructor Create(Collection:TCollection); override;
    destructor Destroy; override;
    procedure Assign(source :TPersistent); override;
  published
    property Alignment: TAlignment read FAlignment write SetAlignment default taLeftJustify;
    property Font: TFont read FFont write SetFont;
    property Header:string read FColumnHeader write SetColumnHeader;
    property HeaderAlign: TAlignment read FHeaderAlign write SetHeaderAlign default taLeftJustify;
    property HeaderImage: Integer read FHeaderImage write SetHeaderImage default -1;
    property Image: Boolean read FImage write SetImage default false;
    property Width: Integer read FWidth write SetWidth;
  end;

  TColumnCollection = class(TCollection)
  private
    FOwner:TTreeList;
    function GetItem(Index: Integer): TColumnItem;
    procedure SetItem(Index: Integer; const Value: TColumnItem);
  protected
    procedure Update(Item: TCollectionItem); override;
  public
    constructor Create(AOwner: TTreeList);
    function GetOwner: TPersistent; override;
    function Add: TColumnItem;
    function Insert(Index: Integer): TColumnItem;
    property Items[Index: Integer]: TColumnItem read GetItem write SetItem; default;
 end;

  THeaderSizeChangedEvent = procedure (Sender:TObject; Section:integer) of object;
  TTLHeaderClickEvent = procedure (Sender:TObject; SectionIdx:integer) of object;

  TTLHeader = class(THeader)
  private
    FColor: TColor;
    FOnClick: TTLHeaderClickEvent;
    FOnRightClick:TTLHeaderClickEvent;
    FIsSizing: boolean;
    FHitTest: TPoint;
    procedure WMSetCursor(var Msg: TWMSetCursor); message WM_SETCURSOR;
    procedure WMNCHitTest(var Msg: TWMNCHitTest); message WM_NCHITTEST;
    procedure WMLButtonDown(var Message: TWMLButtonDown); message WM_LBUTTONDOWN;
    procedure WMRButtonDown(var Message: TWMLButtonDown); message WM_RBUTTONDOWN;
    procedure SetColor(const Value: TColor);
  public
    constructor Create(aOwner:TComponent); override;
    destructor Destroy; override;
    procedure CreateWnd; override;
    procedure DestroyWnd; override;
    procedure Sizing(ASection, AWidth: Integer); override;
    procedure Sized(ASection, AWidth: Integer); override;
    property IsSizing: boolean read FIsSizing;
  protected
    procedure Paint; override;
  published
    property Color:TColor read fColor write SetColor;
    property OnClick:TTLHeaderClickEvent read fOnClick write fOnClick;
    property OnRightClick:TTLHeaderClickEvent read fOnRightClick write fOnRightClick;
  end;

  THeaderSettings = class(TPersistent)
  private
    FOwner:TTreelist;
    FOldHeight: Integer;
    FHeight: Integer;
    FVisible: Boolean;
    FFont: TFont;
    FAllowResize: boolean;
    function GetFont: tFont;
    procedure SetFont(const Value: TFont);
    function GetFlat: boolean;
    procedure SetFlat(const Value: boolean);
    function GetAllowResize: boolean;
    procedure SetAllowResize(const Value: boolean);
    function GetColor: tColor;
    procedure SetColor(const Value: tColor);
    function GetHeight: integer;
    procedure SetHeight(const Value: integer);
    procedure SetVisible(const Value: Boolean);
    procedure FontChanged(Sender: TObject);
  public
    constructor Create(aOwner:TTreeList);
    destructor Destroy; override;
  published
    property AllowResize:boolean read GetAllowResize write SetAllowResize default False;
    property Color:tColor read GetColor write SetColor;
    property Flat:boolean read GetFlat write SetFlat default False;
    property Font:tFont read GetFont write SetFont;
    property Height:integer read GetHeight write SetHeight;
    property Visible: Boolean read FVisible write SetVisible default True;
  end;

  TTreeList = class(TTreeview)
  private
    { Private declarations }
    FHeader:TTLHeader;
    FHeaderSettings:THeaderSettings;
    FFlatHeader:boolean;
    FColumnCollection:TColumnCollection;
    FColumnLines:boolean;
    FColumnSpace:integer;
    FOldScrollPos:integer;
    FSeparator:string;
    FItemHeight:integer;
    FOnClick:TTLHeaderClickEvent;
    FOnRightClick:TTLHeaderClickEvent;
    FClipRegion: HRGN;
    FOnHeaderSizeChanged : THeaderSizeChangedEvent;
    procedure WMHScroll(var message:TMessage); message WM_HSCROLL;
    procedure WMLButtonDown(var message: TWMLButtonDown); message WM_LBUTTONDOWN;
    procedure WMRButtonDown(var message: TWMLButtonDown); message WM_RBUTTONDOWN;    
    procedure WMPaint(var message: TWMPaint); message WM_PAINT;
    {$IFNDEF TMSDOTNET}
    procedure CNNotify(var message: TWMNotify); message CN_NOTIFY;
    {$ENDIF}
    {$IFDEF TMSDOTNET}
    procedure CNNotify(var message: TWMNotifyTV); message CN_NOTIFY;
    {$ENDIF}
    procedure CMVisibleChanged(var Message: TMessage); message CM_VISIBLECHANGED;
    procedure SetColumnCollection(const Value: TColumnCollection);
    procedure SetColumnLines(const Value: boolean);

    procedure SectionSize(sender:TObject; ASection, AWidth:integer);
    procedure HeaderClick(sender:TObject; ASection:integer); procedure HeaderRightClick(sender:TObject; ASection:integer);
    function GetColImage(idx:integer):boolean;
    function GetColWidth(idx:integer):integer;
    function GetColFont(idx:integer):TFont;
    function GetAlignment(idx:integer):integer;
    procedure SetSeparator(const Value: string);
    function GetItemHeight: integer;
    procedure SetItemHeight(const Value: integer);
    function GetVisible: boolean;
    procedure SetVisible(const Value: boolean);
    function GetVersion: string;
    procedure SetVersion(const Value: string);
  protected
    { Protected declarations }
    function GetVersionNr: Integer; virtual;
    procedure WndProc(var Message:tMessage); override;
    procedure CreateWnd; override;
    procedure DestroyWnd; override;
    function GetClientRect:TRect; override;
  public
    { Public declarations }
    constructor Create(aOwner:TComponent); override;
    destructor Destroy; override;
    procedure SetBounds(ALeft, ATop, AWidth, AHeight: Integer); override;
    procedure SetNodeColumn(tn:TTreeNode;idx:integer;value:string);
    function GetNodeColumn(tn:TTreeNode;idx:integer):string;
    procedure Loaded; override;
    procedure UpdateColumns;
    property Header: TTLHeader read FHeader;
    procedure CreateHeader;
  published
    { Pubished declarations }

    // New introduced properties
    property Columns: TColumnCollection read FColumnCollection write SetColumnCollection;
    property ColumnLines: Boolean read FColumnLines write SetColumnLines;
    property Separator: string read FSeparator write SetSeparator;
    property ItemHeight: Integer read GetItemHeight write SetItemHeight;
    property OnHeaderClick: TTLHeaderClickEvent read fOnClick write fOnClick;
    property OnHeaderRightClick: TTLHeaderClickEvent read fOnRightClick write fOnRightClick;
    property OnHeaderSizeChanged : THeaderSizeChangedEvent read FOnHeaderSizeChanged write FOnHeaderSizeChanged;
    property Visible: Boolean read GetVisible write SetVisible;
    property HeaderSettings: THeaderSettings read FHeaderSettings write FHeaderSettings;
    property Version: string read GetVersion write SetVersion;

    {
    // Default properties
    property Align;
    property Anchors;
    property AutoExpand;
    property BevelEdges;
    property BevelInner;
    property BevelOuter;
    property BevelKind default bkNone;
    property BevelWidth;
    property BiDiMode;
    property BorderStyle;
    property BorderWidth;
    property ChangeDelay;
    property Color;
    property Ctl3D;
    property Constraints;
    property DragKind;
    property DragCursor;
    property DragMode;
    property Enabled;
    property Font;
    property HideSelection;
    property HotTrack;
    property Images;
    property Indent;
    property MultiSelect;
    property MultiSelectStyle;
    property ParentBiDiMode;
    property ParentColor default False;
    property ParentCtl3D;
    property ParentFont;
    property ParentShowHint;
    property PopupMenu;
    property ReadOnly;
    property RightClickSelect;
    property RowSelect;
    property ShowButtons;
    property ShowHint;
    property ShowLines;
    property ShowRoot;
    property SortType;
    property StateImages;
    property TabOrder;
    property TabStop default True;
    property ToolTips;
    property OnAddition;
    property OnChange;
    property OnChanging;
    property OnClick;
    property OnCollapsed;
    property OnCollapsing;
    property OnCompare;
    property OnContextPopup;
    property OnCreateNodeClass;
    property OnDblClick;
    property OnDeletion;
    property OnDragDrop;
    property OnDragOver;
    property OnEdited;
    property OnEditing;
    property OnEndDock;
    property OnEndDrag;
    property OnEnter;
    property OnExit;
    property OnExpanding;
    property OnExpanded;
    property OnGetImageIndex;
    property OnGetSelectedIndex;
    property OnKeyDown;
    property OnKeyPress;
    property OnKeyUp;
    property OnMouseDown;
    property OnMouseMove;
    property OnMouseUp;
    property OnStartDock;
    property OnStartDrag;
    }
    { Items must be published after OnGetImageIndex and OnGetSelectedIndex }
   // property Items;
  end;

{$IFDEF VER100}
const
  NM_CUSTOMDRAW            = NM_FIRST-12;

  CDDS_PREPAINT           = $00000001;
  CDDS_POSTPAINT          = $00000002;
  CDDS_PREERASE           = $00000003;
  CDDS_POSTERASE          = $00000004;
  CDDS_ITEM               = $00010000;
  CDDS_ITEMPREPAINT       = CDDS_ITEM or CDDS_PREPAINT;
  CDDS_ITEMPOSTPAINT      = CDDS_ITEM or CDDS_POSTPAINT;
  CDDS_ITEMPREERASE       = CDDS_ITEM or CDDS_PREERASE;
  CDDS_ITEMPOSTERASE      = CDDS_ITEM or CDDS_POSTERASE;
  CDDS_SUBITEM            = $00020000;

  // itemState flags
  CDIS_SELECTED       = $0001;
  CDIS_GRAYED         = $0002;
  CDIS_DISABLED       = $0004;
  CDIS_CHECKED        = $0008;
  CDIS_FOCUS          = $0010;
  CDIS_DEFAULT        = $0020;
  CDIS_HOT            = $0040;
  CDIS_MARKED         = $0080;
  CDIS_INDETERMINATE  = $0100;

  CDRF_DODEFAULT          = $00000000;
  CDRF_NEWFONT            = $00000002;
  CDRF_SKIPDEFAULT        = $00000004;
  CDRF_NOTIFYPOSTPAINT    = $00000010;
  CDRF_NOTIFYITEMDRAW     = $00000020;
  CDRF_NOTIFYSUBITEMDRAW  = $00000020;  // flags are the same, we can distinguish by context
  CDRF_NOTIFYPOSTERASE    = $00000040;

  TVM_GETITEMHEIGHT         = TV_FIRST + 28;
  TVM_SETITEMHEIGHT         = TV_FIRST + 27;

type
  tagNMCUSTOMDRAWINFO = packed record
    hdr: TNMHdr;
    dwDrawStage: DWORD;
    hdc: HDC;
    rc: TRect;
    dwItemSpec: DWORD;  // this is control specific, but it's how to specify an item.  valid only with CDDS_ITEM bit set
    uItemState: UINT;
    lItemlParam: LPARAM;
  end;
  PNMCustomDraw = ^TNMCustomDraw;
  TNMCustomDraw = tagNMCUSTOMDRAWINFO;


  tagNMTVCUSTOMDRAW = packed record
    nmcd: TNMCustomDraw;
    clrText: COLORREF;
    clrTextBk: COLORREF;
    iLevel: Integer;
  end;
  PNMTVCustomDraw = ^TNMTVCustomDraw;
  TNMTVCustomDraw = tagNMTVCUSTOMDRAW;

function TreeView_SetItemHeight(hwnd: HWND; iHeight: Integer): Integer;

function TreeView_GetItemHeight(hwnd: HWND): Integer;

{$ENDIF}


implementation

type
  PHeaderSection = ^THeaderSection;
  THeaderSection = record
    FObject: TObject;
    Width: Integer;
    Title: string;                                   
  end;


{ TColumnItem }

constructor TColumnItem.Create(Collection: TCollection);
begin
  inherited;
  FWidth := 50;
  FFont := TFont.Create;
  FFont.Assign((TColumnCollection(Collection).FOwner).Font);
  FHeaderImage := -1;
  if (Index = 0) and
     (csDesigning in (TColumnCollection(Collection).FOwner).ComponentState) and
    not (csLoading in (TColumnCollection(Collection).FOwner).ComponentState) then
    FImage := True;
end;

destructor TColumnItem.Destroy;
begin
  FFont.Free;
  inherited Destroy;
end;

procedure TColumnItem.SetWidth(const value:integer);
begin
  FWidth := Value;
  TColumnCollection(Collection).Update(Self);
end;

procedure TColumnItem.SetAlignment(const value:tAlignment);
begin
  FAlignment := Value;
  TColumnCollection(Collection).Update(Self);
end;

procedure TColumnItem.SetColumnHeader(const Value:string);
begin
  FColumnHeader := Value;
  TColumnCollection(Collection).Update(Self);
end;

procedure TColumnItem.SetFont(const value:TFont);
begin
  FFont.Assign(Value);
  TColumnCollection(Collection).Update(Self);
end;


procedure TColumnItem.Assign(source: TPersistent);
begin
  if Source is TColumnItem then
  begin
    Width := TColumnItem(Source).Width;
    Alignment := TColumnItem(Source).Alignment;
    Header := TColumnItem(Source).Header;
    HeaderAlign := TColumnItem(Source).HeaderAlign;
    Font.Assign(TColumnItem(Source).Font);
    Image := TColumnItem(Source).Image;
  end
  else
    inherited Assign(Source);
end;

procedure TColumnItem.SetImage(const Value: boolean);
begin
  FImage := Value;
  TColumnCollection(Collection).Update(Self);
end;

procedure TColumnItem.SetHeaderAlign(const Value: TAlignment);
begin
  FHeaderAlign := Value;
  TColumnCollection(Collection).Update(Self);
end;

procedure TColumnItem.SetHeaderImage(const Value: integer);
begin
  FHeaderImage := Value;
  TColumnCollection(Collection).Update(Self);
end;

{ TColumnCollection }

function TColumnCollection.Add: TColumnItem;
begin
  Result := TColumnItem(inherited Add);
end;

constructor TColumnCollection.Create(aOwner:TTreeList);
begin
  inherited Create(TColumnItem);
  FOwner := AOwner;
end;

function TColumnCollection.GetItem(Index: Integer): TColumnItem;
begin
  Result := TColumnItem(inherited Items[Index]);
end;

function TColumnCollection.GetOwner: TPersistent;
begin
  Result := FOwner;
end;

function TColumnCollection.Insert(Index: Integer): TColumnItem;
begin
  Result := TColumnItem(inherited Insert(Index));
end;

procedure TColumnCollection.SetItem(Index: Integer;
  const Value: TColumnItem);
begin
  inherited Items[Index] := Value;
end;

procedure TColumnCollection.Update(Item:TCollectionItem);
begin
  inherited Update(Item);
  {reflect changes}
  FOwner.UpdateColumns;
end;

{ TTLHeader }

procedure TTLHeader.WMLButtonDown(var Message: TWMLButtonDown);
var
  x,i:integer;
begin
  inherited;
  x := 0;
  i := 0;
  while (x < Message.XPos) and (i < Sections.Count) do
  begin
    x := x + SectionWidth[i];
    inc(i);
  end;
  Dec(i);
  if Assigned(FOnClick) then
    FOnClick(self,i);
end;

procedure TTLHeader.WMNCHitTest(var Msg: TWMNCHitTest);
begin
  inherited;
  FHitTest := SmallPointToPoint(Msg.Pos);
end;

procedure TTLHeader.WMRButtonDown(var Message: TWMLButtonDown);
var
  x,i:integer;
begin
  inherited;
  x := 0;
  i := 0;
  while (x < Message.xpos) and (i < Sections.Count) do
  begin
    x := x + SectionWidth[i];
    Inc(i);
  end;
  Dec(i);
  if Assigned(FOnRightClick) then
    FOnRightClick(self,i);
end;

procedure TTLHeader.WMSetCursor(var Msg: TWMSetCursor);
var
  I: Integer;
  X: Integer;
  FMouseOffset: Integer;

begin
  inherited;
  FIsSizing := false;
  FHitTest := ScreenToClient(FHitTest);
  X := 2;
  with Msg do
    if HitTest = HTCLIENT then
      for I := 0 to Sections.Count - 2 do  { don't count last section }
      begin
        Inc(X, SectionWidth[I]);
        FMouseOffset := X - (FHitTest.X + 2);
        if Abs(FMouseOffset) < 4 then
        begin
          FIsSizing := true;
          Break;
        end;
      end;
  FIsSizing := (AllowResize or (csDesigning in ComponentState)) and (FIsSizing);
end;

procedure TTLHeader.Paint;
var
  I, W: Integer;
  S: string;
  R: TRect;
  PR: TRect;
  halign:word;

begin
  with Canvas do
  begin
    Font := Self.Font;
    Brush.Color := fColor;
    I := 0;
    R := Rect(0, 0, 0, ClientHeight);
    W := 0;
    S := '';

    halign := DT_RIGHT;

    R.Right := R.Right - GetScrollPos((Owner as TTreeList).Handle, SB_HORZ);

    repeat
      with Owner as TTreeList do
      begin
        if (Columns.Count > I) then
          case (Columns.Items[I] as TColumnItem).HeaderAlign of
          taleftJustify:halign := DT_LEFT;
          taRightJustify:halign := DT_RIGHT;
          taCenter:halign := DT_CENTER;
          else
            halign := DT_LEFT;
          end;
      end;

      if I < Sections.Count then
      begin
        W := SectionWidth[i];

        if (i<sections.Count) then
          s := Sections[i]
        else
          s := Sections[0];

        Inc(I);
      end;

      R.Left := R.Right;

      Inc(R.Right, W);
      if (ClientWidth - R.Right < 2) or (I = Sections.Count) then
        R.Right := ClientWidth;

      pr := r;
      FillRect(r);
      InflateRect(pr,-2,-2);

      with (Owner as TTreeList) do
      begin
        if (Columns.Count > 0) then
        begin
          if (Columns.Count > I - 1) and Assigned(Images) then
          if ((Columns.Items[I - 1] as TColumnItem).HeaderImage >= 0) then
          begin
            Images.Draw(self.Canvas,pr.Left,pr.Top,(Columns.Items[I - 1] as TColumnItem).HeaderImage);
            pr.Left := pr.Left+Images.Width + 2;
          end;
        end;
      end;

      {$IFNDEF TMSDOTNET}
      DrawText(canvas.handle,pchar(s),length(s),PR,DT_NOPREFIX or DT_END_ELLIPSIS or halign);
      {$ENDIF}
      {$IFDEF TMSDOTNET}
      DrawText(canvas.handle,s,length(s),PR,DT_NOPREFIX or DT_END_ELLIPSIS or halign);
      {$ENDIF}
      DrawEdge(Canvas.Handle, R, BDR_RAISEDINNER, BF_TOPLEFT);
      DrawEdge(Canvas.Handle, R, BDR_RAISEDINNER, BF_BOTTOMRight);
    until R.Right = ClientWidth;
  end;
end;



constructor TTLHeader.Create(aOwner: TComponent);
begin
  inherited;
  FColor := clBtnFace;
end;

procedure TTLHeader.SetColor(const Value: TColor);
begin
  FColor := Value;
  Invalidate;
end;


procedure TTLHeader.Sized(ASection, AWidth: Integer);
begin
  inherited;
  FIsSizing := false;
end;

procedure TTLHeader.Sizing(ASection, AWidth: Integer);
begin
  inherited;
  FIsSizing := true;
end;

procedure TTLHeader.CreateWnd;
begin
  inherited;
end;

destructor TTLHeader.Destroy;
begin
  inherited;
end;

procedure TTLHeader.DestroyWnd;
begin
  inherited;
end;

{ TTreeList }

constructor TTreeList.Create(aOwner:TComponent);
begin
  inherited Create(aOwner);
  FOnHeaderSizeChanged := nil;
  FHeader := nil;
  FColumnCollection := TColumnCollection.Create(self);
  FHeaderSettings := THeaderSettings.Create(self);
  FHeaderSettings.AllowResize := false;
  FSeparator := ';';
  FItemHeight := 16;
  FColumnLines := true;
  FColumnSpace := 4;
  FOldScrollPos := -1;
end;

procedure TTreeList.CreateHeader;
const
  hdr: array[boolean] of TBorderStyle = (bsSingle,bsNone);
begin
  if not Assigned(FHeader) then
  begin
    FHeader := TTLHeader.Create(self);
    FHeader.Parent := Parent;
    FHeader.top := Top - 16;
    FHeader.left := Left;
    FHeader.Width := Width {- 1};
    FHeader.Height := 18;
    Fheader.borderstyle := hdr[FFlatHeader];
    FHeader.OnSized := SectionSize;
    FHeader.OnClick := HeaderClick;
    FHeader.OnRightClick := HeaderRightClick;

    if (Top < 16) then
      Top := 16;
    UpdateColumns;

    FHeader.Visible := self.Visible and FHeaderSettings.Visible;
    if self.Visible and FHeaderSettings.Visible then
    begin
      ShowWindow(FHeader.Handle, SW_SHOW);
    end
    else
      ShowWindow(FHeader.Handle, SW_HIDE);
  end;
  end;

procedure TTreeList.CreateWnd;
begin
  inherited;
  CreateHeader;
  ItemHeight := FItemHeight;
end;


procedure TTreeList.SectionSize(sender:TObject; ASection, AWidth:integer);
var
  FIndent: Integer;
begin
  FIndent := TreeView_GetIndent(self.Handle);
  if Assigned(Images) then
    FIndent := FIndent + Images.Width;

  if (ASection = 0) and (AWidth < FIndent) then
  begin
    AWidth := FIndent;
    if Assigned(FHeader) then
      FHeader.SectionWidth[ASection] := FIndent;
  end;

  if (ASection >= 0) and (ASection < FColumnCollection.Count) then
  TColumnItem(fColumnCollection.Items[ASection]).FWidth := AWidth;
  
  Invalidate;
  if ((csDesigning in ComponentState) or (csDestroying in ComponentState)) then 
    Exit;

  if not (csDestroying in ComponentState) then
  begin
    if Assigned (FOnHeaderSizeChanged) and Assigned (FHeader) and Assigned (FColumnCollection) then
      FOnHeaderSizeChanged (Self, ASection);
  end;
end;

procedure TTreeList.HeaderClick(sender:TObject; ASection:integer);
begin
  if Assigned(OnHeaderClick) then
    OnHeaderClick(self,ASection);
end;

procedure TTreeList.HeaderRightClick(sender:TObject; ASection:integer);
begin
  if Assigned(OnHeaderRightClick) then
    OnHeaderRightClick(self,ASection);
end;

procedure TTreeList.DestroyWnd;
begin
  inherited;
end;

destructor TTreeList.Destroy;
begin
  FHeaderSettings.Free;
  FColumnCollection.Free;
  inherited;
end;

procedure TTreeList.SetColumnLines(const value :boolean);
begin
  if (FColumnLines <> Value) then
  begin
    FColumnLines := Value;
    if FColumnLines then
      FColumnSpace := 4
    else
      FColumnSpace := 2;

    Invalidate;
  end;
end;

procedure TTreeList.SetColumnCollection(const value :TColumnCollection);
begin
  FColumnCollection.Assign(Value);
end;

procedure TTreeList.SetBounds(ALeft, ATop, AWidth, AHeight: Integer);
var
  HeaderHeight: Integer;
begin
  if not Assigned(FHeaderSettings) then
  begin
    inherited;
    Exit;
  end;

  if not  FHeaderSettings.Visible then
    HeaderHeight := 2
  else
    HeaderHeight := FHeaderSettings.FHeight;

  if Align in [alClient, alTop, alRight, alLeft] then
  begin
    inherited SetBounds(ALeft,ATop + HeaderHeight - 2,AWidth,AHeight - HeaderHeight + 2);

    if not FHeaderSettings.Visible then
      Exit;

    if Assigned(FHeader) then
    begin
      FHeader.Top := ATop;
      FHeader.Left := ALeft;
      FHeader.Width := AWidth {- 1};
      FHeader.Height := FHeaderSettings.Height;
    end;
  end
  else
  begin
    inherited SetBounds(ALeft,ATop,AWidth,AHeight);

    if not FHeaderSettings.Visible then
      Exit;

    if Assigned(FHeader) then
    begin
      FHeader.Top := ATop - (FHeaderSettings.Height - 2);
      FHeader.Left := ALeft;
      FHeader.Width := AWidth {- 1};
      FHeader.Height := FHeaderSettings.Height;
    end;
  end;
end;


procedure TTreeList.UpdateColumns;
var
  i,cw: Integer;
  s:string;
begin
  if Assigned(FHeader) then
  begin
    FHeader.Sections.Clear;
    for i := 1 to FColumnCollection.Count do
    begin
      s := TColumnItem(FColumnCollection.Items[i - 1]).Header;

      FHeader.Sections.Add(s);

      cw := TColumnItem(FColumnCollection.Items[i - 1]).Width;

      if (i = 1) then
      begin
        if (BorderStyle = bsNone) and (HeaderSettings.Flat = false) then
          dec(cw);

        if (HeaderSettings.Flat) and (BorderStyle = bsSingle) then
          inc(cw);
      end;

      FHeader.SectionWidth[i-1] := cw;
    end;
    Invalidate;
  end;
end;

function TTreeList.GetColImage(idx:Integer):boolean;
begin
  if idx >= FColumnCollection.Count then
    Result := False
  else
    Result := TColumnItem(FColumnCollection.Items[idx]).FImage;
end;

function TTreeList.GetColWidth(idx:integer):integer;
begin
  if idx >= FColumnCollection.Count then
    Result := self.Width
  else
    Result := TColumnItem(FColumnCollection.Items[idx]).FWidth;
end;

function TTreeList.GetColFont(idx:integer):TFont;
begin
  if idx >= FColumnCollection.Count then
    Result := self.Font
  else
    Result := TColumnItem(FColumnCollection.Items[idx]).FFont;
end;

function TTreeList.GetAlignment(idx:integer):integer;
begin
  if idx >= FColumnCollection.Count then
    Result := DT_LEFT
  else
    case TColumnItem(FColumnCollection.Items[idx]).FAlignment of
    taLeftJustify:Result := DT_LEFT;
    taCenter:Result := DT_CENTER;
    taRightJustify:Result:=DT_RIGHT
    else
      Result := DT_LEFT;
  end;
end;

procedure TTreeList.CMVisibleChanged(var Message: TMessage);
begin
  if Assigned(FHeader) then
    FHeader.Visible := self.Visible and FHeaderSettings.Visible;
end;

{$IFNDEF TMSDOTNET}
procedure TTreeList.CNNotify(var message: TWMNotify);
var
  TVcd:TNMTVCustomDraw;
  TVdi:TTVDISPINFO;
  canvas:tcanvas;
  s,su:string;
  tn:ttreenode;
  r,nr:trect;
  fIndent,fIdx,fImgWidth:integer;
  defdraw: boolean;
  scpos: integer;
  {$IFDEF DELPHI6_LVL}
  paintimg: boolean;
  {$ENDIF}
  TmpItem: TTVItem;
  code: longbool;


  function GetNodeFromItem(const Item: TTVItem): TTreeNode;
  begin
    Result := nil;
    if Items <> nil then
    with Item do
      if (state and TVIF_PARAM) <> 0 then
        Result := Pointer(lParam)
      else
        Result := Items.GetNode(hItem);
  end;

begin

  if message.NMHdr^.code = TVN_GETDISPINFO then
  begin

    TVDi := PTVDispInfo(pointer(message.nmhdr))^;
    if (tvdi.item.mask and TVIF_TEXT=TVIF_TEXT) then
    begin
      tn := Items.GetNode(tvdi.item.hitem);
      s := tn.Text;
      StrPLCopy(tvdi.item.pszText,s,255);
      tvdi.Item.Mask := tvdi.item.mask or TVIF_DI_SETITEM;
      message.result:=0;
      Exit;
    end;
  end;

  if message.NMHdr^.code = NM_CUSTOMDRAW then
  begin
    FIndent := TreeView_GetIndent(self.handle);
    TVcd := PNMTVCustomDraw(Pointer(message.NMHdr))^;
    case TVcd.nmcd.dwDrawStage of
    CDDS_PREPAINT:
      begin
        {$IFDEF DELPHI6_LVL}
        if Assigned(OnAdvancedCustomDraw) then
          OnAdvancedCustomDraw(self, TVcd.nmcd.rc, TCustomDrawStage(message.NMHdr^.code), defdraw);
        {$ENDIF}

        message.Result := CDRF_NOTIFYITEMDRAW or CDRF_NOTIFYPOSTPAINT;
      end;
    CDDS_ITEMPREPAINT:
      begin
        defdraw := true;

        FillChar(TmpItem, SizeOf(TmpItem), 0);
        with PNMCustomDraw(message.NMHdr)^ do
          TmpItem.hItem := HTREEITEM(dwItemSpec);

        tn := GetNodeFromItem(TmpItem);

        if (tn = nil) then
          Exit;

        //tn := Items.GetNode(tvdi.item.hitem);

        {$IFDEF DELPHI6_LVL}
        paintimg := true;
        if Assigned(OnAdvancedCustomDrawItem) then
          OnAdvancedCustomDrawItem(self, tn, TCustomDrawState(Word(TVcd.nmcd.uItemState)), TCustomDrawStage(message.NMHdr^.code), paintimg, defdraw);
        {$ENDIF}

        if defdraw then
        begin

          if  (TVcd.nmcd.uItemState and CDIS_SELECTED = CDIS_SELECTED) then
          begin
            TVcd.nmcd.uItemState := TVcd.nmcd.uItemState and (not CDIS_SELECTED);
            SetTextColor(TVcd.nmcd.hdc,ColorToRGB(self.Color));
            SetBkColor(TVcd.nmcd.hdc,ColorToRGB(self.Color));
            TVcd.clrTextBk := ColorToRgb(self.Color);
            TVcd.clrText := ColorToRgb(self.Color);
          end
          else
          begin
            SetTextColor(TVcd.nmcd.hdc,ColorToRGB(self.Color));
            SetBkColor(TVcd.nmcd.hdc,ColorToRGB(self.Color));
          end;
        end;

          // use a clip region here to avoid drawing of tree nodes in 2nd column
          FClipRegion := CreateRectRgn(TVcd.nmcd.rc.Left,TVcd.nmcd.rc.Top,TVcd.nmcd.rc.Left + GetColWidth(0) - 1,TVcd.nmcd.rc.Bottom);
          SelectClipRgn(TVcd.nmcd.hdc,FClipRegion);

        message.Result := CDRF_NOTIFYPOSTPAINT;
      end;
    CDDS_ITEMPOSTPAINT:
      begin
        SelectClipRgn(TVcd.nmcd.hdc,0);
        DeleteObject(FClipRegion);

        defdraw := true;

        Canvas := TCanvas.Create;
        Canvas.Handle := TVcd.nmcd.hdc;

        FillChar(TmpItem, SizeOf(TmpItem), 0);
        with PNMCustomDraw(message.NMHdr)^ do
        begin
          TmpItem.hItem := HTREEITEM(dwItemSpec);

        tn := GetNodeFromItem(TmpItem);

          code := true;
          if Assigned(tn) then
            TreeView_GetItemRect(handle, HTREEITEM(dwItemSpec), nr, code);
        end;

        if (tn = nil) then
          Exit;

        // tn := Items.GetNode(tvdi.item.hitem);

        {$IFDEF DELPHI6_LVL}
        paintimg := true;
        if Assigned(OnAdvancedCustomDrawItem) then
          OnAdvancedCustomDrawItem(self, tn, TCustomDrawState(word(TVcd.nmcd.uItemState)), TCustomDrawStage(message.NMHdr^.code), paintimg, defdraw);
        {$ENDIF}  

        scpos := GetScrollPos(handle,SB_HORZ);

        if defdraw then
        begin
          tn := Items.GetNode(HTREEITEM(TVcd.nmcd.dwitemSpec));

          // get left pos from tree level
          TVcd.nmcd.rc.Left := TVcd.nmcd.rc.Left + FIndent * (tn.Level + 1) - scpos;

          // paint image in first column
          FImgWidth := 0;

          if Assigned(Images) and GetColImage(0) and
            ((tn.ImageIndex >= 0) or (tn.SelectedIndex >= 0)) then
          begin
            FImgWidth := Images.Width;
            Canvas.Brush.Color := Color;
            Canvas.Pen.Color := Color;
            Canvas.Rectangle(TVcd.nmcd.rc.left,TVcd.nmcd.rc.top,TVcd.nmcd.rc.left+fImgWidth,TVcd.nmcd.rc.bottom);

            if (TVcd.nmcd.rc.left + FImgWidth < GetColWidth(0)) then
            begin
              if (TVcd.nmcd.uItemState and CDIS_SELECTED = CDIS_SELECTED) and
                (tn.SelectedIndex >= 0) then
                Images.draw(Canvas, TVcd.nmcd.rc.left, nr.Top {TVcd.nmcd.rc.top}, tn.SelectedIndex)
              else
                if (tn.ImageIndex >= 0) then
                  Images.Draw(Canvas, TVcd.nmcd.rc.left, nr.Top {TVcd.nmcd.rc.top}, tn.ImageIndex);

            end;

            if tn.OverlayIndex >= 0 then
              Images.Draw(canvas,TVcd.nmcd.rc.left,nr.Top {TVcd.nmcd.rc.top},tn.OverlayIndex);
          end;

          TVcd.nmcd.rc.Left := TVcd.nmcd.rc.Left + FImgWidth;

          r := TVcd.nmcd.rc;

          fIdx := Canvas.TextHeight('gh');
          if (fIdx < r.Bottom - r.Top) then
            r.Top := r.Top + ((r.Bottom - r.Top - FIdx) shr 1);

          if  (TVcd.nmcd.uItemState and CDIS_SELECTED = CDIS_SELECTED) then
          begin
            Canvas.Brush.Color := clHighLight;
            Canvas.Pen.Color := clHighLight;
            with TVcd.nmcd.rc do
              Canvas.Rectangle(left,top,right,bottom);
            Canvas.Font.Color := clHighLightText;
            if (TVcd.nmcd.uItemState and CDIS_FOCUS = CDIS_FOCUS) then
            begin
              Canvas.pen.color := self.Color;
              Canvas.brush.color := self.Color;
              Canvas.DrawFocusRect(TVcd.nmcd.rc);
            end;
            TVcd.nmcd.rc := r;
            TVcd.nmcd.rc.Left := TVcd.nmcd.rc.Left + 4;
          end
          else
          begin
            Canvas.Brush.Color := self.Color;
            Canvas.Pen.Color := self.Color;
            with TVcd.nmcd.rc do
              Canvas.Rectangle(left,top,right,bottom);
          end;

          TVcd.nmcd.rc := r;

          if  (TVcd.nmcd.uItemState and CDIS_SELECTED = CDIS_SELECTED) then
          begin
            Canvas.brush.color := clHighLight;
            Canvas.pen.color := clHighLight;
          end;

          s := tn.text;
          fIdx := 0;

          SetBkMode(TVcd.nmcd.hdc,TRANSPARENT);

          repeat
            Canvas.Font.Assign(GetColFont(fIdx));
            if  (TVcd.nmcd.uItemState and CDIS_SELECTED = CDIS_SELECTED) then
            begin
              Canvas.font.color := clHighLightText;
            end;

            if (fIdx = 0) then
            begin
              r.Right := GetColWidth(fIdx);
              r.Right := r.Right - scpos;
            end
            else
              r.Right := r.left + GetColWidth(fIdx);

            if fIdx = FColumnCollection.Count - 1 then
              r.Right := width;

            if (pos(FSeparator,s) > 0) then
            begin
              su := Copy(s,1,pos(FSeparator,s)-1);
              {$IFNDEF TMSDOTNET}
              System.Delete(s,1,pos(FSeparator,s) + Length(FSeparator) - 1);
              {$ENDIF}
              {$IFDEF TMSDOTNET}
              Borland.Delphi.system.delete(s,1,pos(fSeparator,s)+length(fSeparator)-1);
              {$ENDIF}
            end
            else
            begin
              su := s;
              s := '';
              if (fIdx >= FColumnCollection.Count) then
                r.right := TVcd.nmcd.rc.right;
            end;

            r.right := r.right - FColumnSpace;

            if Assigned(Images) and GetColImage(fIdx) and (tn.ImageIndex >= 0) and (fIdx>0) then
            begin
              fImgWidth := Images.Width;
              if (fImgWidth < GetColWidth(fIdx)) then
                images.draw(canvas,r.left,TVcd.nmcd.rc.top,tn.ImageIndex);

              r.left := r.left + fImgWidth + 2;
            end;

            if Assigned(Images) and (fidx = 0) and GetColImage(fIdx) then
            begin
              r.left := r.left + 2;
            end;

            {$IFNDEF TMSDOTNET}
            DrawText(canvas.handle,pchar(su),length(su),r,DT_NOPREFIX or DT_END_ELLIPSIS or GetAlignment(fIdx));
            {$ENDIF}
            {$IFDEF TMSDOTNET}
            DrawText(canvas.handle,su,length(su),r,DT_NOPREFIX or DT_END_ELLIPSIS or GetAlignment(fIdx));
            {$ENDIF}

            r.right := r.right + FColumnSpace;
            r.left := r.right;

            inc(fIdx);
          until (length(s) = 0);
         end;

          Canvas.Free;
        end;        
      else
        message.Result := 0;
    end;
  end
  else inherited;
end;
{$ENDIF}

{$IFDEF TMSDOTNET}
procedure TTreeList.CNNotify(var message: TWMNotifyTV);
var
  TVcd:TNMTVCustomDraw;
  TVdi:TTVDISPINFO;
  canvas:tcanvas;
  s,su:string;
  tn:ttreenode;
  r:trect;
  fIndent,fIdx,fImgWidth:integer;
  i : integer;
  Temp: TNMTVCustomDraw;
  TmpItem: TTVItem;
  sa : array [0..255] of char;
  defdraw,paintimg: boolean;

begin
  Canvas := TCanvas.Create;

  with message do
  begin
    case NMHdr.code of
      TVN_GETDISPINFO:
      begin
        TVDi := TVDispInfo;
        if (tvdi.item.mask and TVIF_TEXT=TVIF_TEXT) then
        begin
          tn := Items.GetNode(tvdi.item.hItem);
          if tn = nil then
            Exit;
          s := tn.Text;
          for i := 1 to s.length do
            sa[i-1] := s[i];
          Marshal.Copy(tvdi.item.pszText, sa, 0, 255);
          tvdi.item.mask := tvdi.item.mask or TVIF_DI_SETITEM;
          Result := 0;
          Exit;
        end;
      end;
      NM_CUSTOMDRAW:
      begin
        FIndent := TreeView_GetIndent(self.Handle);
        if Assigned(Canvas) then
          with NMCustomDraw do
          begin
            try
              Result := CDRF_DODEFAULT;

              if (dwDrawStage and CDDS_ITEM) = 0 then
              begin
                case dwDrawStage of
                  CDDS_PREPAINT:
                  begin
                    Result := CDRF_NOTIFYITEMDRAW or CDRF_NOTIFYPOSTPAINT;
                  end;
                end;
              end
              else
              begin
                TmpItem.hItem := HTREEITEM(dwItemSpec);
                tn := Items.GetNode(TmpItem.hItem);
                if tn = nil then
                  Exit;

                case dwDrawStage of
                  CDDS_ITEMPREPAINT:
                  begin
                    defdraw := true;

                    {
                    if Assigned(OnAdvancedCustomDraw) then
                      OnAdvancedCustomDraw(self, temp.nmcd.rc, TCustomDrawStage(drawStage), defdraw);

                    if Assigned(OnAdvancedCustomDrawItem) then
                      OnAdvancedCustomDrawItem(self, tn, temp.nmcd.rc, TCustomDrawStage(drawStage), paintimg, defdraw);
                    }

                    if defdraw then
                    begin
                      try
                        if uItemState and CDIS_SELECTED <> 0 then
                        begin
                          Temp.nmcd.uItemState := uItemState and (not CDIS_SELECTED);
                          SetTextColor(hdc,ColorToRGB(Color));
                          SetBkColor(hdc,ColorToRGB(Color));
                          Temp := NMTVCustomDraw;
                          Temp.clrText := ColorToRGB(Color);
                          Temp.clrTextBk := ColorToRGB(Color);
                          NMTVCustomDraw := Temp;
                        end
                        else
                        begin
                          SetTextColor(hdc,ColorToRGB(Color));
                          SetBkColor(hdc,ColorToRGB(Color));
                        end;
                        // use a clip region here to avoid drawing of tree nodes in 2nd column
                        Temp := NMTVCustomDraw;
                        FClipRegion := CreateRectRgn(Temp.nmcd.rc.Left,Temp.nmcd.rc.Top,Temp.nmcd.rc.Left + GetColWidth(0) - 1,Temp.nmcd.rc.Bottom);
                        SelectClipRgn(Temp.nmcd.hdc,FClipRegion);
                        NMTVCustomDraw := Temp;

                        Result := CDRF_NOTIFYPOSTPAINT;
                      finally
                        Canvas.Handle := 0;
                      end;
                    end;
                  end;

                  CDDS_ITEMPOSTPAINT:
                  begin
                    try
                      Temp := NMTVCustomDraw;
                      SelectClipRgn(temp.nmcd.hdc,0);
                      DeleteObject(FClipRegion);
                      NMTVCustomDraw := Temp;

                      Canvas.Handle := hdc;
                      Canvas.Font.Assign(Self.Font);
                      Temp := NMTVCustomDraw;

                      defdraw := true;

                      {
                      if Assigned(OnAdvancedCustomDraw) then
                        OnAdvancedCustomDraw(self, temp.nmcd.rc, TCustomDrawStage(drawStage), defdraw);

                      if Assigned(OnAdvancedCustomDrawItem) then
                        OnAdvancedCustomDrawItem(self, tn, temp.nmcd.rc, TCustomDrawStage(drawStage), paintimg, defdraw);
                      }

                      if defdraw then
                      begin
                        NMTVCustomDraw := Temp;
                        Temp.nmcd.rc.Left := Temp.nmcd.rc.Left + FIndent * (tn.level + 1) - GetScrollPos(Handle, SB_HORZ);

                        fImgWidth := 0;
                        if assigned(Images) and GetColImage(0) and ((tn.ImageIndex >= 0) or (tn.SelectedIndex >= 0)) then
                        begin
                          fImgWidth := Images.Width;
                          canvas.brush.color := Color;
                          canvas.pen.color := Color;
                          canvas.rectangle(Temp.nmcd.rc.left, Temp.nmcd.rc.top, Temp.nmcd.rc.left + fImgWidth, Temp.nmcd.rc.bottom);
                          if (temp.nmcd.rc.left + fImgWidth < GetColWidth(0)) then
                          begin
                            if (temp.nmcd.uItemState and CDIS_SELECTED = CDIS_SELECTED) and (tn.SelectedIndex >= 0) then
                              Images.Draw(Canvas, Temp.nmcd.Rc.left, Temp.nmcd.rc.top, tn.SelectedIndex)
                            else
                              if (tn.ImageIndex >= 0) then
                                Images.Draw(Canvas, Temp.nmcd.rc.Left, Temp.nmcd.rc.Top, tn.ImageIndex);

                          end;
                          if tn.OverlayIndex >= 0 then
                            Images.Draw(Canvas, Temp.nmcd.Rc.left, Temp.nmcd.rc.Top, tn.OverlayIndex);
                        end;

                        Temp.nmcd.rc.left := temp.nmcd.rc.left + fImgWidth;

                        r := temp.nmcd.rc;

                        fIdx := Canvas.TextHeight('gh');
                        if (fIdx < r.Bottom - r.Top) then
                          r.Top := r.Top + ((r.Bottom - r.Top - FIdx) shr 1);

                        if (temp.nmcd.uItemState and CDIS_SELECTED = CDIS_SELECTED) then
                        begin
                          canvas.brush.color := ClHighlight;
                          canvas.pen.color := ClHighlight;
                          with Temp.nmcd.rc do
                            canvas.rectangle(left, top, right, bottom);
                          canvas.font.Color := ClHighLightText;

                          if (temp.nmcd.uItemState and CDIS_FOCUS = CDIS_FOCUS) then
                          begin
                            canvas.pen.color := Color;
                            canvas.brush.color := Color;
                            canvas.DrawFocusRect(Temp.nmcd.rc);
                          end;
                          Temp.nmcd.rc := r;
                          Temp.nmcd.rc.left := Temp.nmcd.rc.left + 4;
                        end
                        else
                        begin
                          canvas.brush.color := self.Color;
                          canvas.pen.color := self.Color;
                          with Temp.nmcd.rc do
                            canvas.rectangle(left, top, right, bottom);
                        end;

                        Temp.nmcd.rc := r;
                        //Temp.nmcd.rc.left := Temp.nmcd.rc.left + 2;

                        if (Temp.nmcd.uItemState and CDIS_SELECTED = CDIS_SELECTED) then
                        begin
                          canvas.brush.color := clHighLight;
                          canvas.pen.color := clHighLight;
                        end;

                        s := tn.Text;
                        FIdx := 0;
                        SetBKMode(TVcd.nmcd.hdc, TRANSPARENT);

                        repeat
                          Canvas.Font.Assign(GetColFont(fIdx));

                          if (Temp.nmcd.uItemState and CDIS_SELECTED = CDIS_SELECTED) then
                          begin
                            Canvas.font.color := ClHighlightText;
                          end;

                          if (FIdx = 0) then
                            r.right := GetColWidth(fIdx)
                          else
                            r.right := r.left + GetColWidth(fIdx);

                          //if fIdx = columns.Count - 1 then r.right := width;

                          if (pos(fSeparator, s) > 0) then
                          begin
                            su := copy(s, 1, pos(fSeparator, s) - 1);
                            Borland.Delphi.system.delete(s, 1, pos(fSeparator, s) + length(fSeparator) - 1);
                          end
                          else
                          begin
                            su := s;
                            s := '';
                            if (fIdx >= fColumnCollection.Count) then
                              r.right := Temp.nmcd.rc.right;
                          end;

                          r.right := r.right - FColumnSpace;

                          //if (r.left < r.right) then
                          //HTMLDraw(canvas, su, r, fImages, 0, 0, false, false, false, false, false, true, 1.0, fURLColor, anchor, stripped, xsize, ysize);

                          if Assigned(Images) and GetColImage(fIdx) and (tn.ImageIndex>=0) and (fIdx>0) then
                          begin
                            fImgWidth := Images.Width;
                            if (fImgWidth<GetColWidth(fIdx)) then
                              images.draw(canvas,r.left,Temp.nmcd.rc.top,tn.ImageIndex );

                            r.left:=r.left+fImgWidth+2;
                          end;

                          DrawText(Canvas.handle,su,length(su),r, DT_NOPREFIX or DT_END_ELLIPSIS or GetAlignment(fIdx));


                          r.right := r.right + FColumnSpace;
                          r.left := r.right;
                          inc(fIdx);
                        until (length(s) = 0);
                      end;
                        
                      Canvas.Free;
                    finally
                      Canvas.Handle := 0;
                    end;
                  end;
                end;
              end;
            finally
              //Canvas.Unlock;
            end;
          end;
      end;
      else
        inherited;
    end;
  end;
end;
{$ENDIF}

procedure TTreeList.SetSeparator(const Value: string);
begin
  FSeparator := Value;
  Self.Invalidate;
end;

procedure TTreeList.WMLButtonDown(var message: TWMLButtonDown);
var
 Node : TTreeNode;
begin
  if not (csDesigning in ComponentState) then
    inherited
  else
    Exit;

  Node := GetNodeAt(message.XPos,message.YPos);
  if Assigned(Node) then
  begin
    Node.selected := True;
  end;
end;

procedure TTreeList.WMRButtonDown(var message: TWMLButtonDown);
var
 Node : TTreeNode;
begin
  if RightClickSelect then
  begin
    Node := GetNodeAt(message.XPos,message.YPos);
    if Assigned(Node) then
    begin
      Node.selected := True;
    end;
  end;

  if not (csDesigning in ComponentState) then
    inherited
  else
    Exit;

end;


procedure TTreeList.WMHScroll(var message:TMessage);
begin
  inherited;

  if (FOldScrollPos <> GetScrollPos(handle,SB_HORZ)) then
  begin
    Invalidate;
    FHeader.Invalidate;
    FOldScrollPos := GetScrollPos(handle,SB_HORZ);
  end;
end;

procedure TTreeList.WMPaint(var message: TWMPaint);
var
  Canvas: TCanvas;
  i,xp,sp: Integer;
begin
  inherited;

  if FColumnLines and not (csDestroying in ComponentState) then
  begin
    Canvas := TCanvas.Create;
    Canvas.Handle := GetDC(Handle);
    xp := 0;
    Canvas.Pen.Color := clSilver;
    sp := GetScrollPos(Handle,SB_HORZ);

    for i := 1 to FColumnCollection.Count - 1 do
    begin
      xp := xp + TColumnItem(FColumnCollection.Items[i - 1]).Width;
      Canvas.MoveTo(xp - 2 - sp,0);
      Canvas.Lineto(xp - 2 - sp,Height);
    end;
    ReleaseDC(Handle,Canvas.Handle);
    Canvas.free;
  end;
end;

function TTreeList.GetItemHeight: integer;
begin
  Result := TreeView_GetItemHeight(self.Handle);
end;

procedure TTreeList.SetItemHeight(const Value: integer);
begin
  if (Value <> FItemHeight) then
  begin
    FItemHeight := value;
    TreeView_SetItemHeight(Handle,FItemHeight);
  end;
end;


{$IFDEF VER100}
function TreeView_SetItemHeight(hwnd: HWND; iHeight: Integer): Integer;
begin
  Result := SendMessage(hwnd, TVM_SETITEMHEIGHT, iHeight, 0);
end;

function TreeView_GetItemHeight(hwnd: HWND): Integer;
begin
  Result := SendMessage(hwnd, TVM_GETITEMHEIGHT, 0, 0);
end;
{$ENDIF}

function TTreeList.GetVisible: boolean;
begin
  Result := inherited Visible;
end;

procedure TTreeList.SetVisible(const Value: boolean);
begin
  inherited Visible := Value;
  if Assigned(FHeader) then
    FHeader.Visible := Value and FHeaderSettings.Visible;
end;

function TTreeList.GetClientRect: TRect;
var
  r: TRect;
begin
  r := inherited GetClientRect;
  r.bottom := r.bottom + FHeaderSettings.Height;
  Result := r;
end;

function VarPos(su,s:string;var vp: Integer):Integer;
begin
  vp := Pos(su,s);
  Result := vp;
end;

function TTreeList.GetNodeColumn(tn: TTreeNode; idx: integer):string;
var
  s: string;
  i,vp: Integer;

begin
  Result := '';
  if Assigned(tn) then
    s := tn.Text
  else
    Exit;

  i := 0;
  while (i <= idx) and (s <> '') do
  begin
    if VarPos(Separator,s,vp) > 0 then
    begin
     if idx = i then
       Result := Copy(s,1,vp-1);

     {$IFNDEF TMSDOTNET}
     System.Delete(s,1,vp);
     {$ENDIF}
     {$IFDEF TMSDOTNET}
     Borland.Delphi.System.Delete(s,1,vp);
     {$ENDIF}
     inc(i);
    end
    else
    begin
      if i = idx then
        Result := s;
      s := '';
    end;
  end;

end;

procedure TTreeList.SetNodeColumn(tn: TTreeNode; idx: integer; value: string);
var
  s,su: string;
  i,vp: Integer;

begin
  if Assigned(tn) then
    s := tn.Text
  else
    Exit;

  su := s;
  for i := 1 to Columns.Count do
  begin
    if VarPos(Separator,su,vp) > 0 then
      {$IFNDEF TMSDOTNET}
      system.Delete(su,1,vp)
      {$ENDIF}
      {$IFDEF TMSDOTNET}
      Borland.Delphi.system.Delete(su,1,vp)
      {$ENDIF}
    else
      s := s + Separator;
  end;

  i := 0;
  su := '';
  while (i <= idx) and (s <> '') do
  begin
    if VarPos(Separator,s,vp) > 0 then
    begin
      if i < idx then
        su := su + copy(s,1,vp);
      if i = idx then
        su := su + Value + Separator;
      {$IFNDEF TMSDOTNET}
      System.Delete(s,1,vp);
      {$ENDIF}
      {$IFDEF TMSDOTNET}
      Borland.Delphi.System.Delete(s,1,vp);
      {$ENDIF}
      Inc(i);
    end
    else
    begin
      s := '';
      if i = idx then
        su := su + Value;
      Inc(i);
    end;
  end;
  
  su := su + s;
  tn.Text := su;
end;

procedure TTreeList.WndProc(var Message: tMessage);
begin
  inherited;
end;

procedure TTreeList.Loaded;
begin
  inherited;
  UpdateColumns;
  if Assigned(FHeader) then
  begin
    FHeader.Font.Assign(FHeaderSettings.Font);
    FHeader.AllowResize := FHeaderSettings.AllowResize;
    FHeader.Visible := self.Visible and FHeaderSettings.Visible;
    if not FHeader.Visible then
      ShowWindow(FHeader.Handle, SW_HIDE);
  end;
end;

function TTreeList.GetVersion: string;
var
  vn: Integer;
begin
  vn := GetVersionNr;
  Result := IntToStr(Hi(Hiword(vn)))+'.'+IntToStr(Lo(Hiword(vn)))+'.'+IntToStr(Hi(Loword(vn)))+'.'+IntToStr(Lo(Loword(vn)));
end;

function TTreeList.GetVersionNr: Integer;
begin
  Result := MakeLong(MakeWord(BLD_VER,REL_VER),MakeWord(MIN_VER,MAJ_VER));
end;

procedure TTreeList.SetVersion(const Value: string);
begin

end;

{ THeaderSettings }
constructor THeaderSettings.Create(aOwner: TTreeList);
begin
  inherited Create;
  FOwner := AOwner;
  FHeight := 18;
  FOldHeight := FHeight;
  FVisible := True;
  FFont := TFont.Create;
  FFont.OnChange := FontChanged;
end;

destructor THeaderSettings.Destroy;
begin
  FFont.Free;
  inherited;
end;

procedure THeaderSettings.FontChanged(Sender: TObject);
begin
  if assigned (FOwner) then
  begin
    if assigned(Fowner.FHeader) then
      FOwner.FHeader.Font.Assign(FFont);
  end;
end;

function THeaderSettings.GetAllowResize: Boolean;
begin
  Result := FAllowResize;
end;

function THeaderSettings.GetColor: TColor;
begin
  Result := clBtnFace;
  if Assigned(FOwner.FHeader) then
    Result := FOwner.FHeader.Color;
end;

function THeaderSettings.GetFlat: Boolean;
begin
  if Assigned(FOwner.FHeader) then
    Result := (FOwner.FHeader.BorderStyle = bsNone)
  else
    Result := False;
end;

function THeaderSettings.GetFont: TFont;
begin
  //if designmode
(*
  if Assigned(FOwner.FHeader) then
    Result := FOwner.FHeader.Font
  else
    Result := nil;
*)
//  Result := FOwner.Font;
  Result := FFont;
end;

function THeaderSettings.GetHeight: integer;
begin
  Result := FHeight;
end;

procedure THeaderSettings.SetAllowResize(const Value: Boolean);
begin
  if Assigned(FOwner.FHeader) then
    FOwner.fHeader.AllowResize := Value;
  FAllowResize := value;
end;

procedure THeaderSettings.SetColor(const Value: TColor);
begin
  if Assigned(FOwner.FHeader) then
    FOwner.FHeader.Color := Value;
end;

procedure THeaderSettings.SetFlat(const Value: Boolean);
begin
  if Assigned(FOwner.FHeader) then
  begin
    if Value then
      FOwner.FHeader.BorderStyle := bsNone
    else
      FOwner.FHeader.BorderStyle := bsSingle;
  end;
end;

procedure THeaderSettings.SetFont(const Value: TFont);
begin
(*
  if Assigned(FOwner.FHeader) then
    FOwner.FHeader.Font.Assign(Value);
*)
  FFont.Assign(Value);
end;

procedure THeaderSettings.SetHeight(const Value: Integer);
begin
  if Assigned(FOwner.FHeader) then
    FOwner.FHeader.Height := Value;
  FHeight := Value;
  FOldHeight := FHeight;
  FOwner.Top := FOwner.Top;
end;

procedure THeaderSettings.SetVisible(const Value: Boolean);
begin
  FVisible := Value;

  if Assigned(FOwner.FHeader) then
  begin
    if (csDesigning in FOwner.ComponentState) then
    begin
      if Value then
        Height := FOldHeight
      else
      begin
        FOldHeight := Height;
        FOwner.FHeader.Height := 0;
      end;
    end;

    FOwner.FHeader.Visible := Value;
  end;
end;

end.

