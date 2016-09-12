{*************************************************************************}
{ TColumnComboBox component                                               }
{ for Delphi & C++Builder                                                 }
{                                                                         }
{ Copyright © 2000-2010                                                   }
{   TMS Software                                                          }
{   Email : info@tmssoftware.com                                          }
{   Web : http://www.tmssoftware.com                                      }
{                                                                         }
{ The source code is given as is. The author is not responsible           }
{ for any possible damage done due to the use of this code.               }
{ The component can be freely used in any application. The complete       }
{ source code remains property of the author and may not be distributed,  }
{ published, given or sold in any form as such. No parts of the source    }
{ code can be included in any other component or application without      }
{ written authorization of the author.                                    }
{*************************************************************************}

unit ColCombo;

{$I TMSDEFS.INC}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, StdCtrls, AdvCombo,
  Forms, Dialogs;

const
  COLUMN_DELIMITER = '|';
  MAJ_VER = 1; // Major version nr.
  MIN_VER = 4; // Minor version nr.
  REL_VER = 0; // Release nr.
  BLD_VER = 0; // Build nr.

  // version history
  // v1.3.0.1 : adapt text color when component Enabled is set to false
  // v1.3.0.2 : improved non incremental lookup handling for cycling through matching items
  // v1.3.0.3 : improved disabled font color display
  // v1.3.1.0 : Added Items.LoadFromFile, Items.SaveToFile methods
  // v1.3.1.1 : Fixed issue with LoadFromFile, SaveToFile
  // v1.3.1.2 : Fixed issue with painting selected item after list is reloaded
  // v1.3.2.0 : New : exposed Align property
  // v1.3.2.1 : Fixed : issue with OnSelect event
  // v1.4.0.0 : New : Label property added


type
  {$IFDEF DELPHI_UNICODE}
  THintInfo = Controls.THintInfo;
  PHintInfo = Controls.PHintInfo;
  {$ENDIF}

  TColumnComboBox = class;

  TColumnType = (ctText,ctImage);

  TComboColumnItem = class(TCollectionItem)
  private
    FWidth: Integer;
    FAlignment:TAlignment;
    FFont:TFont;
    FColor:TColor;
    FColumnType:TColumnType;
    procedure SetWidth(const Value: Integer);
    procedure SetAlignment(const Value:tAlignment);
    procedure SetFont(const Value:TFont);
    procedure SetColor(const Value:TColor);
    procedure SetColumnType(const Value: TColumnType);
  protected
    function GetDisplayName: string; override;
  public
    constructor Create(Collection:TCollection); override;
    destructor Destroy; override;
    procedure Assign(Source: TPersistent); override;
  published
    property Color:TColor read FColor write SetColor;
    property ColumnType: TColumnType read FColumnType write SetColumnType;
    property Width: Integer read FWidth write SetWidth;
    property Alignment: TAlignment read FAlignment write SetAlignment;
    property Font:TFont read FFont write SetFont;
  end;

  TComboColumnCollection = class(TCollection)
  private
    FOwner:TColumnComboBox;
    function GetItem(Index: Integer): TComboColumnItem;
    procedure SetItem(Index: Integer; const Value: TComboColumnItem);
  protected
    procedure Update(Item: TCollectionItem); override;
  public
    function Add:TComboColumnItem;
    function Insert(index: Integer): TComboColumnItem;
    property Items[Index: Integer]: TComboColumnItem read GetItem write SetItem;
    constructor Create(AOwner:TColumnComboBox);
    function GetOwner: TPersistent; override;
  end;

  TComboItem = class(TCollectionItem)
  private
    FImageIndex: Integer;
    {$IFNDEF TMSDOTNET}
    FStrings:TStringList;
    {$ENDIF}
    {$IFDEF TMSDOTNET}
    FStrings:TStrings;
    {$ENDIF}
    FTag: Integer;
    procedure SetImageIndex(const Value: Integer);
    {$IFNDEF TMSDOTNET}
    procedure SetStrings(const Value: TStringList);
    {$ENDIF}
    {$IFDEF TMSDOTNET}
    procedure SetStrings(const Value: TStrings);
    {$ENDIF}

    procedure StringsChanged(Sender:TObject);
  protected
    function GetDisplayName: string; override;
  public
    constructor Create(Collection:TCollection); override;
    destructor Destroy; override;
    procedure Assign(Source: TPersistent); override;
  published
    property ImageIndex: Integer read FImageIndex write SetImageIndex;
    {$IFNDEF TMSDOTNET}
    property Strings: TStringList read FStrings write SetStrings;
    {$ENDIF}
    {$IFDEF TMSDOTNET}
    property Strings: TStrings read FStrings write SetStrings;
    {$ENDIF}

    property Tag: Integer read FTag write FTag;
  end;

  TComboItemCollection = class(TCollection)
  private
    FOwner:TColumnComboBox;
    function GetItem(Index: Integer): TComboItem;
    procedure SetItem(Index: Integer; const Value: TComboItem);
  protected
    procedure Update(Item: TCollectionItem); override;
  public
    function Add:TComboItem;
    function Insert(index: Integer): TComboItem;
    property Items[Index: Integer]: TComboItem read GetItem write SetItem; default;
    constructor Create(AOwner:TColumnComboBox);
    function GetOwner: tPersistent; override;
    function IndexOf(s:string):tpoint;
    function IndexInColumnOf(col: Integer;s:string): Integer;
    function IndexInRowOf(row: Integer;s:string): Integer;

    {$IFDEF DELPHI_UNICODE}
    procedure SaveToFile(FileName: string; Unicode: boolean = true);
    {$ENDIF}
    {$IFNDEF DELPHI_UNICODE}
    procedure SaveToFile(FileName: string);
    {$ENDIF}
    procedure LoadFromFile(FileName: string);
  end;

  TLabelPosition = (lpLeftTop, lpLeftCenter, lpLeftBottom, lpTopLeft, lpBottomLeft,
    lpLeftTopLeft, lpLeftCenterLeft, lpLeftBottomLeft, lpTopCenter, lpBottomCenter,
    lpRightTop, lpRightCenter, lpRighBottom, lpTopRight, lpBottomRight);

  TColumnComboBox = class(TAdvCustomCombo)
  private
    FImages:TImageList;
    FDropHeight: Integer;
    FColumns:TComboColumnCollection;
    fComboItems:TComboItemCollection;
    FGridLines:boolean;
    FEditColumn: Integer;
    FItemIndex: Integer;
    FSelItemIndex: Integer;
    FUpdateCount: Integer;
    FLookup: string;
    FLookupColumn: Integer;
    FLookupIncr: Boolean;
    FSortColumn: Integer;
    FSortedEx: Boolean;
    FDropped: Boolean;
    FShowItemHint: Boolean;
    FDropWidth: Integer;
    FDisableSelChange: Boolean;
    FShowLookup: Boolean;
    FProgChange: Integer;
    FLabel: TLabel;
    FLabelFont: TFont;
    FLabelPosition: TLabelPosition;
    FLabelMargin: Integer;
    FLabelTransparent: Boolean;
    FFocusLabel: Boolean;
    FLabelAlwaysEnabled: Boolean;
    FOnLabelClick: TNotifyEvent;
    FOnLabelDblClick: TNotifyEvent;
    FParentFnt: Boolean;
    {$IFNDEF DELPHI5_LVL}
    FComboEdit: Boolean;
    procedure CNDrawItem(var Message: TWMDrawItem); message CN_DRAWITEM;
    {$ENDIF}
    {$IFNDEF TMSDOTNET}
    procedure CMHintShow(var Msg: TMessage); message CM_HINTSHOW;
    procedure CMParentFontChanged(var Message: TMessage); message CM_PARENTFONTCHANGED;
    {$ENDIF}
    {$IFDEF TMSDOTNET}
    procedure CMHintShow(var Message: TCMHintShow); message CM_HINTSHOW;
    {$ENDIF}
    procedure CMFontChanged(var Message: TMessage); message CM_FONTCHANGED;
    procedure WMSetFocus(var Msg: TWMSetFocus); message WM_SETFOCUS;
    procedure WMKillFocus(var Msg: TWMKillFocus); message WM_KILLFOCUS;
    procedure CMShowingChanged(var Message: TMessage); message CM_SHOWINGCHANGED;
    procedure CMVisibleChanged(var Message: TMessage); message CM_VISIBLECHANGED;
    procedure CMEnabledChanged(var Message: TMessage); message CM_ENABLEDCHANGED;
    procedure SetDropWidth(Value: Integer);
    function GetDropWidth: Integer;
    procedure SetEditHeight(Value: Integer);
    function GetEditHeight: Integer;
    procedure SetImages(const Value: TImageList);
    procedure CNCommand(var Message: TWMCommand); message CN_COMMAND;
    procedure WMLButtonUp(var Msg:TWMLButtonDown); message WM_LBUTTONUP;
    procedure WMChar(var Msg:TWMChar); message WM_CHAR;
    procedure SetItemIndexP(const Value : Integer);
    function GetItemIndexP: Integer;
    procedure SetGridLines(const Value: boolean);
    procedure SetEditColumn(const Value: Integer);
    procedure BuildItems;
    function GetColumnItems(i, j: Integer): String;
    procedure SetColumnItems(i, j: Integer; const Value: String);
    function GetSortedEx: boolean;
    procedure SetSortedEx(const Value: boolean);
    procedure Sort;
    function GetDelimiter: Char;
    procedure SetDelimiter(const Value: Char);
    procedure QuickSortList(List:TStringList;left,right: Integer);
    function GetEditText: string;
    function GetVersion: string;
    procedure SetVersion(const Value: string);
    procedure SetLabelCaption(const value: string);
    function GetLabelCaption: string;
    procedure SetLabelPosition(const value: TLabelPosition);
    procedure SetLabelMargin(const value: integer);
    procedure SetLabelTransparent(const value: boolean);
    procedure UpdateLabel;
    procedure LabelFontChange(Sender: TObject);
    procedure SetLabelFont(const Value: TFont);
    procedure SetLabelAlwaysEnabled(const Value: Boolean);
  protected
    function GetVersionNr: Integer; override;
    procedure SetStyle(Value: TComboBoxStyle); override;
    procedure KeyDown(var Key: Word; Shift: TShiftState); override;
    procedure MeasureItem(Index: Integer; var Height: Integer); override;
    procedure DrawItem(Index: Integer; Rect: TRect; State: TOwnerDrawState); override;
    procedure CreateWnd; override;
    procedure Notification(AComponent: TComponent; AOperation: TOperation); override;
    property Items;
    procedure Change; override;
    procedure SetParent(AParent: TWinControl); override;
    function CreateLabel: TLabel;
    procedure LabelClick(Sender: TObject);
    procedure LabelDblClick(Sender: TObject);
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure Loaded; override;
    procedure SetBounds(ALeft, ATop, AWidth, AHeight: Integer); override;
    property Text;
    procedure BeginUpdate;
    procedure EndUpdate;
    property ColumnItems[i,j: Integer]: String read GetColumnItems write SetColumnItems;
    property Delimiter: Char read GetDelimiter write SetDelimiter;
    property EditText: string read GetEditText;
    property EditLabel: TLabel read FLabel;
  published
    property Align;
    {$IFDEF DELPHI4_LVL}
    property Anchors;
    property Constraints;
    property BevelInner;
    property BevelKind;
    property BevelOuter;
    property DragKind;
    {$ENDIF}
    property Color;
    property Ctl3D;
    property Columns:TComboColumnCollection read FColumns write FColumns;
    property ComboItems:TComboItemCollection read FComboItems write FComboItems;
    property DragMode;
    property DragCursor;
    property EditColumn: Integer read FEditColumn write SetEditColumn;
    property EditHeight: Integer read GetEditheight write SetEditHeight;
    property DropWidth: Integer read GetDropWidth write SetDropWidth;
    property DropHeight: Integer read FDropHeight write FDropHeight;
    property DropDownCount;
    property Images: TImageList read FImages write SetImages;
    property Enabled;
    property Etched;
    property Flat;
    property FlatParentColor;
    property FlatLineColor;
    property FocusBorder;
    property FocusLabel: Boolean read FFocusLabel write FFocusLabel default false;
    property Font;
    property GridLines: Boolean read FGridLines write SetGridLines;
  //    property ItemHeight;
    property ItemIndex: Integer read GetItemIndexP write SetItemIndexP;
    property LookupIncr: Boolean read FLookupIncr write FLookupIncr default False;
    property LookupColumn: Integer read FLookupColumn write FLookupColumn;
    property LabelCaption: string read GetLabelCaption write SetLabelCaption;
    property LabelPosition: TLabelPosition read FLabelPosition write SetLabelPosition default lpLeftTop;
    property LabelMargin: Integer read FLabelMargin write SetLabelMargin default 4;
    property LabelTransparent: Boolean read FLabelTransparent write SetLabelTransparent default False;
    property LabelAlwaysEnabled: Boolean read FLabelAlwaysEnabled write SetLabelAlwaysEnabled default False;
    property LabelFont: TFont read FLabelFont write SetLabelFont;
    property MaxLength;
    property ParentColor;
    property ParentCtl3D;
    property ParentFont;
    property ParentShowHint;
    property PopupMenu;
    property ShowHint;
    property ShowLookup: Boolean read FShowLookup write FShowLookup default False;
    property ShowItemHint: Boolean read FShowItemHint write FShowItemHint default False;
    property SortColumn: Integer read FSortColumn write FSortColumn;
    property Sorted: Boolean read GetSortedEx write SetSortedEx default False;
    property TabOrder;
    property TabStop;
    property Visible;
    property OnChange;
    property OnClick;
    {$IFDEF DELPHI6_LVL}
    property OnCloseUp;
    {$ENDIF}
    property OnDragDrop;
    property OnDragOver;
    property OnDrawItem;
    property OnDropDown;
    property OnEndDrag;
    property OnEnter;
    property OnExit;
    property OnKeyDown;
    property OnKeyPress;
    property OnKeyUp;
    property OnMeasureItem;
    property OnStartDrag;
    {$IFDEF DELPHI4_LVL}
    property OnStartDock;
    property OnEndDock;
    {$ENDIF}
    {$IFDEF DELPHI5_LVL}
    property OnContextPopup;
    {$ENDIF}
    {$IFDEF DELPHI6_LVL}
    property OnSelect;
    {$ENDIF}
    property Version: string read GetVersion write SetVersion;
    property OnLabelClick: TNotifyEvent read FOnLabelClick write FOnLabelClick;
    property OnLabelDblClick: TNotifyEvent read FOnLabelDblClick write FOnLabelDblClick;
  end;

implementation
uses
  {$IFDEF TMSDOTNET}
   Types,
  {$ENDIF}
  ExtCtrls,ShellApi,CommCtrl {$IFDEF DELPHI4_LVL} ,ImgList {$ENDIF};

const
  FDelimiter : Char = COLUMN_DELIMITER;

var
  SortCol: Integer;

{$IFNDEF DELPHI5_LVL}
procedure TColumnComboBox.CNDrawItem(var Message: TWMDrawItem);
begin
  with Message.DrawItemStruct^ do
    FComboEdit := itemState and ODS_COMBOBOXEDIT <> 0;
  inherited;
end;
{$ENDIF}


procedure TColumnComboBox.SetStyle(Value: TComboBoxStyle);
begin
  inherited SetStyle(csOwnerDrawFixed);
end;

function GetColumnString(var s:string):string;
var
  DelPos: Integer;
begin
  DelPos := Pos(FDelimiter,s);
  if DelPos > 0 then
  begin
    Result := Copy(s,1,DelPos-1);
    Delete(s,1,DelPos);
  end
  else
  begin
    Result := s;
    s := '';
  end;
end;

function GetColumn(i: Integer; s:string): String;
var
  k: Integer;
begin
  k := 0;
  repeat
   Result := GetColumnString(s);
   inc(k);
  until (k > i);
end;

procedure TColumnComboBox.DrawItem(Index: Integer; Rect: TRect; State: TOwnerDrawState);
var
  r,dr:TRect;
  s,su:string;
  align:DWORD;
  col,imgidx,err: Integer;
  ct:TColumnType;
  isEdit:boolean;
  imgstr:string;
begin
  {$IFNDEF DELPHI5_LVL}
  isEdit := FComboEdit;
  {$ELSE}
  isEdit := odComboBoxEdit in State;
  {$ENDIF}

  r := Rect;

  if Index < 0 then
  begin
    if (odSelected in State) then
    begin
      Canvas.Brush.Color := clHighLight;
      Canvas.Pen.Color := clHighLight;
      Canvas.Font.Color := clHighLightText;
    end
    else
    begin
      Canvas.Brush.Color := Color;
      Canvas.Pen.Color := Canvas.Brush.Color;
    end;
    Canvas.Rectangle(r.Left,r.Top,r.Right,r.Bottom);
    Exit;
  end;

  if (odSelected in State) then
    Canvas.Rectangle(r.Left,r.Top,r.Right,r.Bottom);

  s := Items[Index];
  imgstr := GetColumnString(s);
  delete(imgstr,1,1);
  Val(imgstr,imgidx,err);

  for col := 1 to FColumns.Count do
  begin
    ct := FColumns.Items[col-1].ColumnType;

    if (ct = ctText) then
      su := GetColumnString(s)
    else
      su := '';

    if isEdit and (ParentFont) then
      Canvas.Font.Assign(GetParentForm(self).Font)
    else
      Canvas.Font.Assign(FColumns.Items[col-1].Font);

    if (odSelected in State) then
    begin
      Canvas.Brush.Color := clHighLight;
      Canvas.Pen.Color := clHighLight;
      Canvas.Font.Color := clHighLightText;
    end
    else
    begin
      Canvas.Brush.Color := FColumns.Items[col-1].Color;
      Canvas.Pen.color := Canvas.Brush.Color;
    end;

    if not Enabled then
     Canvas.Font.Color := clGrayText;

    dr := r;
    if col = FColumns.Count then
      dr.right := r.right
    else
      dr.right := dr.left + FColumns.Items[col-1].Width;

    case FColumns.Items[col-1].Alignment of
    taLeftJustify: Align := DT_LEFT;
    taRightJustify: Align := DT_RIGHT;
    taCenter: Align := DT_CENTER;
    else
      align := DT_LEFT;
    end;

    if (not isEdit) or (EditColumn=-1) then
    begin
      if not (odSelected in State) then
      begin
        if (s='') then
          Canvas.rectangle(dr.left,dr.top,dr.right,dr.bottom)
        else
          Canvas.rectangle(dr.left,dr.top,dr.right,dr.bottom);
      end;

      dr.Left := dr.Left + 2;
      dr.Top := r.Top + 1;

      if (ct=ctImage) and assigned(FImages) then
      begin
        FImages.Draw(Canvas,dr.left,dr.top,imgidx);
      end
      else
      begin
        dr.right:=dr.right-2;
        {$IFNDEF TMSDOTNET}
        DrawTextEx(Canvas.handle,pchar(su),length(su),dr,align or DT_END_ELLIPSIS or DT_VCENTER or DT_SINGLELINE or DT_NOPREFIX,nil);
        {$ENDIF}
        {$IFDEF TMSDOTNET}
        DrawTextEx(Canvas.handle,su,length(su),dr,align or DT_END_ELLIPSIS or DT_VCENTER or DT_SINGLELINE or DT_NOPREFIX,nil);
        {$ENDIF}
        dr.right := dr.right + 2;
      end;
      r.left := dr.right;
    end
    else
    begin
      if FSelItemIndex >= Items.Count then
       FSelItemIndex := 0;

      if FDropped then
      begin
        if FSelItemIndex < Items.Count then
          su := ColumnItems[FSelItemIndex,EditColumn]
        else
          su := '';
      end
      else
      begin
        if ItemIndex < Items.Count then
          su := ColumnItems[ItemIndex,EditColumn];
      end;

      dr.left := dr.left + 2;
      dr.top := r.top + 1;

      Canvas.Brush.Style := bsClear;

      if (col = EditColumn + 1) and (isEdit) then
      begin
        {$IFNDEF TMSDOTNET}
        if bool(SendMessage(Handle,CB_GETDROPPEDSTATE,0,0)) and FShowLookup then
          DrawTextEx(Canvas.handle,pchar(flookup),length(flookup),dr,align or DT_END_ELLIPSIS or DT_VCENTER or DT_SINGLELINE or DT_NOPREFIX,nil)
        else
          DrawTextEx(Canvas.handle,pchar(su),length(su),dr,align or DT_END_ELLIPSIS or DT_VCENTER or DT_SINGLELINE or DT_NOPREFIX,nil);
        {$ENDIF}
        {$IFDEF TMSDOTNET}
        if bool(SendMessage(Handle,CB_GETDROPPEDSTATE,0,0)) and FShowLookup then
          DrawTextEx(Canvas.Handle,flookup,length(flookup),dr,align or DT_END_ELLIPSIS or DT_VCENTER or DT_SINGLELINE or DT_NOPREFIX,nil)
        else
          DrawTextEx(Canvas.Handle,su,length(su),dr,align or DT_END_ELLIPSIS or DT_VCENTER or DT_SINGLELINE or DT_NOPREFIX,nil);
        {$ENDIF}
      end;
    end;
  end;

  if FGridLines then
  begin
    Canvas.pen.color := clGray;

    if not IsEdit then
    begin
      Canvas.MoveTo(rect.Left,rect.Bottom-1);
      Canvas.LineTo(rect.Right,rect.Bottom-1);
    end;

    ImgIdx := rect.Left;

    if not IsEdit or (EditColumn = -1) then
      for col := 1 to FColumns.Count-1 do
      begin
        ImgIdx := ImgIdx + FColumns.Items[Col - 1].Width;
        Canvas.moveto(imgidx,dr.top);
        Canvas.lineto(imgidx,dr.bottom);
      end;
  end;

  Canvas.Brush.Color := self.Color;
  Canvas.Pen.Color := self.Color;


end;

procedure TColumnComboBox.Change;
begin
  //
end;

procedure TColumnComboBox.CreateWnd;
begin
  inherited CreateWnd;
  DropWidth := FDropWIdth;
end;

constructor TColumnComboBox.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  Style := csOwnerDrawFixed;
  fDropheight := 200;
  fEditColumn := -1;
  FColumns := TComboColumnCollection.Create(self);
  fComboItems := TComboItemCollection.Create(self);
  Flat := false;
  FDelimiter := COLUMN_DELIMITER;
  FProgChange := 0;
  FLabel := nil;
  FLabelMargin := 4;
  FLabelFont := TFont.Create;
  FLabelFont.OnChange := LabelFontChange;
  FParentFnt := false;
end;

destructor TColumnComboBox.Destroy;
begin
  FColumns.Free;
  FComboItems.Free;
  if (FLabel <> nil) then
  begin
    FLabel.Parent := nil;
    FLabel.Free;
    FLabel := nil;
  end;
  FLabelFont.Free;

  inherited Destroy;
end;

procedure TColumnComboBox.MeasureItem(Index: Integer; var Height: Integer);
var
 res: Integer;
 Canvas: TCanvas;
begin
  height := 40;
  if (index >= 0) then
  begin
    Canvas := TCanvas.Create;
    Canvas.handle := GetDC(self.handle);
    Canvas.Font.Assign(self.Font);
    res := Canvas.TextHeight('gh')+4; {some overlap on fonts}
    ReleaseDC(handle,Canvas.handle);
    Canvas.free;
    SendMessage(self.handle,CB_SETITEMHEIGHT,index,res);
  end
  else
    res := EditHeight;

  Height := res;
end;

function TColumnComboBox.GetDropWidth: Integer;
begin
  Result := FDropWidth;
end;

procedure TColumnComboBox.SetDropWidth(Value: Integer);
begin
  FDropWidth := value;
  SendMessage(self.handle,CB_SETDROPPEDWIDTH,Value,0);
end;

function TColumnComboBox.GetEditHeight: Integer;
begin
  Result := SendMessage(self.Handle,CB_GETITEMHEIGHT,-1,0);
end;

procedure TColumnComboBox.SetEditHeight(Value: Integer);
begin
  SendMessage(self.handle,CB_SETITEMHEIGHT,-1,Value);
  SendMessage(self.handle,CB_SETITEMHEIGHT,0,Value);
end;

procedure TColumnComboBox.SetImages(const Value: TImageList);
begin
  FImages := Value;
  Invalidate;
end;

procedure TColumnComboBox.CNCommand(var Message: TWMCommand);
begin
  case message.NotifyCode of
  CBN_DROPDOWN:
    begin
      if (EditHeight <> 16) then
      begin
        DropDown;
        {$IFDEF DELPHI6_LVL}
        AdjustDropDown;
        {$ENDIF}
        MoveWindow(Handle,Left,Top,Width,EditHeight + FDropheight,True);
        FItemIndex := SendMessage(Handle,CB_GETCURSEL,0,0);
        FDropped := True;
        message.Result := 0;
      end
      else
        inherited;
    end;

  CBN_SELCHANGE:
    begin
      if FDisableSelChange then
        inherited
      else
      begin
        FDropped := False;

        FItemIndex := SendMessage(self.Handle,CB_GETCURSEL,0,0);

//        if not bool(SendMessage(Handle,CB_GETDROPPEDSTATE,0,0)) then
//        begin
          if Assigned(OnClick) then
            OnClick(Self);


          if Assigned(OnChange) then
            OnChange(Self);
//        end;

        Invalidate;
      end;
      {$IFDEF DELPHI6_LVL}
      if Assigned(OnSelect) then
        OnSelect(Self);
      {$ENDIF}
      message.Result := 0;
    end;
  else
    inherited;
  end;
end;

function TColumnComboBox.GetItemIndexP: Integer;
begin
  Result := SendMessage(Handle,CB_GETCURSEL,0,0);
end;

function TColumnComboBox.GetLabelCaption: string;
begin
  if FLabel <> nil then
    Result := FLabel.Caption
  else
    Result := '';
end;

procedure TColumnComboBox.SetItemIndexP(const Value: Integer);
begin
  if bool(SendMessage(Handle,CB_GETDROPPEDSTATE,0,0)) then
    FItemIndex := Value;

  FDisableSelChange := true;
  FSelItemIndex := FItemIndex;

  SendMessage(Handle,CB_SETCURSEL,Value,0);

  if (FItemIndex <> -1) and bool(SendMessage(Handle,CB_GETDROPPEDSTATE,0,0)) then
  begin

    FProgChange := FProgChange + 2;

    if (FItemIndex > 0) then
    begin
      SendMessage(Handle,WM_KEYDOWN,VK_UP,0);
      SendMessage(Handle,WM_KEYDOWN,VK_DOWN,0);
    end
    else
    begin
      SendMessage(Handle,WM_KEYDOWN,VK_DOWN,0);
      SendMessage(Handle,WM_KEYDOWN,VK_UP,0);
    end;
    
  end;

  FDisableSelChange := false;
end;

procedure TColumnComboBox.SetLabelAlwaysEnabled(const Value: Boolean);
begin
  FLabelAlwaysEnabled := Value;
  if FLabel <> nil then
    if Value then
      FLabel.Enabled := True;
  Invalidate;
end;

procedure TColumnComboBox.SetLabelCaption(const value: string);
begin
  if FLabel = nil then
    FLabel := CreateLabel;
  FLabel.Caption := Value;
  UpdateLabel;
end;

procedure TColumnComboBox.LabelClick(Sender: TObject);
begin
  if Assigned(FOnLabelClick) then
    FOnLabelClick(Self);
end;

procedure TColumnComboBox.LabelDblClick(Sender: TObject);
begin
  if Assigned(FOnLabelDblClick) then
    FOnLabelDblClick(Self);
end;

procedure TColumnComboBox.LabelFontChange(Sender: TObject);
begin
  if FLabel <> nil then
  begin
    UpdateLabel;
    if (csDesigning in ComponentState) and not (csLoading in ComponentState) then
      ParentFont := false;
  end;
end;

procedure TColumnComboBox.SetLabelFont(const Value: TFont);
begin
  if not ParentFont then
    FLabelFont.Assign(Value);

  if FLabel <> nil then
    UpdateLabel;
end;

procedure TColumnComboBox.SetLabelMargin(const value: integer);
begin
  FLabelMargin := Value;
  if FLabel <> nil then UpdateLabel;
end;

procedure TColumnComboBox.SetLabelPosition(const value: TLabelPosition);
begin
  FLabelPosition := Value;
  if FLabel <> nil then UpdateLabel;
end;

procedure TColumnComboBox.SetLabelTransparent(const value: boolean);
begin
  FLabelTransparent := Value;
  if FLabel <> nil then UpdateLabel;
end;

procedure TColumnComboBox.SetParent(AParent: TWinControl);
begin
  inherited;
  if FLabel <> nil then
    FLabel.Parent := AParent;
end;

procedure TColumnComboBox.Notification(AComponent: TComponent;
  AOperation: TOperation);
begin
  if (AOperation = opRemove) and (AComponent = FImages) then
    FImages := nil;
  inherited;
end;

procedure TColumnComboBox.SetGridLines(const Value: boolean);
begin
  FGridLines := Value;
  Invalidate;
end;

procedure TColumnComboBox.SetEditColumn(const Value: Integer);
begin
  FEditColumn := Value;
  Invalidate;
end;

procedure TColumnComboBox.BuildItems;
var
  i,j: Integer;
  s:string;
begin
  if (csLoading in ComponentState) then
    Exit;

  if FUpdateCount > 0 then
    Exit;

  while Items.Count > FComboItems.Count do
    Items.Delete(Items.Count - 1);

  for i := 1 to FComboItems.Count do
  begin {image index is always first}
     s := '#'+inttostr(fComboItems.Items[i-1].FImageIndex);

     for j := 1 to FColumns.Count do
       if (j <= FComboItems.Items[i-1].Strings.Count) then
         s := s + FDelimiter + FComboItems.Items[i-1].Strings[j-1]
       else
         s := s + FDelimiter;

   if (Items.Count>=i) then
      Items[i - 1] := s
    else
      Items.Add(s);
  end;

end;

procedure TColumnComboBox.Loaded;
begin
  inherited;
  BuildItems;
  ItemIndex := FItemIndex;
  if FSortedEx then Sort;

  if not LabelAlwaysEnabled and Assigned(FLabel) then
    FLabel.Enabled := Enabled;

  if (FLabel <> nil) then
    UpdateLabel;

  if Self.ParentFont and Assigned(FLabel) then
  begin
    FLabel.Font.Assign(Font);
  end;

  FParentFnt := self.ParentFont;

  if (FLabel <> nil) then
    UpdateLabel;
end;

procedure TColumnComboBox.BeginUpdate;
begin
  inc(FUpdateCount);
end;

procedure TColumnComboBox.EndUpdate;
begin
  if FUpdateCount > 0 then
  begin
    Dec(FUpdateCount);
    if FUpdateCount = 0 then
      BuildItems;
  end;
end;

function TColumnComboBox.GetColumnItems(i, j: Integer): String;
var
  k: Integer;

begin
  if (i >= Items.Count) then raise Exception.Create('Item index out of range');

  for k := 1 to j do
   if FColumns.Items[k-1].ColumnType<>ctText then dec(j);

  Result := GetColumn(succ(j), Items[i]);
end;

procedure TColumnComboBox.SetBounds(ALeft, ATop, AWidth, AHeight: Integer);
begin
  inherited SetBounds(ALeft, ATop, AWidth, AHeight);

  if (FLabel <> nil) then
  begin
    if FLabel.Parent <> nil then
      UpdateLabel;
  end;
end;

procedure TColumnComboBox.SetColumnItems(i, j: Integer;
  const Value: String);
var
  s,n,l: String;
  k, OldIndex: Integer;
begin
  if (i >= Items.Count) then raise Exception.Create('Item index out of range');

  for k := 1 to j do
   if FColumns.Items[k-1].ColumnType <> ctText then dec(j);
  inc(j);

  s := self.Items[i];
  k := 0;
  n := '';
  repeat
   if n <> '' then n := n + FDelimiter;
   l := GetColumnString(s);
   if (k <> j) then
     n := n + l
   else
     n := n + Value;

   inc(k);
  until (k > j);

  if (s <> '') then
   begin
    n := n + FDelimiter + s;
   end;

  OldIndex := ItemIndex;
  Items[i] := n;
  ItemIndex := OldIndex;
end;


procedure TColumnComboBox.KeyDown(var Key: Word; Shift: TShiftState);
begin
  {
  if ((Key = VK_INSERT) and (ssShift in Shift)) or
     ((Key in [ord('v'),ord('V')]) and (ssCtrl in Shift)) then
  begin
  end;
  }
  inherited;

  if key in [vk_up,vk_down,vk_left,vk_right,vk_next,vk_prior,vk_home,vk_end,vk_escape] then
  begin
    if FProgChange > 0 then
    begin
      if key in [vk_up,vk_down] then
        dec(FProgChange);
      Exit;
    end;
    FLookup := '';
    Exit;
  end;

  if (Key = vk_back) and (Length(FLookup)>0) then
  begin
    Delete(FLookup,Length(FLookup),1);
    if ShowLookup then
      Invalidate;
  end;
end;

function TColumnComboBox.GetSortedEx: boolean;
begin
  Result := FSortedEx;
end;

procedure TColumnComboBox.QuickSortList(List:TStringList;left,right: Integer);
var
  i,j: Integer;
  s,sw: string;
  sl: TStringList;
  img,tag: Integer;

begin
  i := left;
  j := right;

  {get middle item here}
  s := List.Strings[(left + right) shr 1];

  sl := TStringList.Create;

  repeat
    {$IFNDEF TMSDOTNET}
    while (AnsiStrComp(pchar(GetColumn(SortCol,s)),pchar(GetColumn(SortCol,List.Strings[i])))>0) and (i<right) do inc(i);
    while (AnsiStrComp(pchar(GetColumn(SortCol,s)),pchar(GetColumn(SortCol,List.Strings[j])))<0) and (j>left) do dec(j);
    {$ENDIF}
    {$IFDEF TMSDOTNET}
    while (AnsiCompareStr(GetColumn(SortCol,s),GetColumn(SortCol,List.Strings[i]))>0) and (i<right) do inc(i);
    while (AnsiCompareStr(GetColumn(SortCol,s),GetColumn(SortCol,List.Strings[j]))<0) and (j>left) do dec(j);
    {$ENDIF}

    if (i <= j) then
    begin
      if (i <> j) then
      begin
        {$IFNDEF TMSDOTNET}
        if AnsiStrComp(PChar(GetColumn(SortCol,List.Strings[i])),PChar(GetColumn(SortCol,List.Strings[j])))<>0 then
        {$ENDIF}
        {$IFDEF TMSDOTNET}
        if AnsiCompareStr(GetColumn(SortCol,List.Strings[i]),GetColumn(SortCol,List.Strings[j]))<>0 then
        {$ENDIF}
        begin
          sl.Assign(ComboItems[i].Strings);
          img := ComboItems[i].ImageIndex;
          tag := ComboItems[i].Tag;

          sw := List.Strings[i];
          List.Strings[i] := List.Strings[j];
          List.Strings[j] := sw;

          ComboItems[i].Strings.Assign(ComboItems[j].Strings);
          ComboItems[i].ImageIndex := ComboItems[j].ImageIndex;
          ComboItems[i].Tag := ComboItems[j].Tag;

          ComboItems[j].Strings.Assign(sl);
          ComboItems[j].ImageIndex := Img;
          ComboItems[j].Tag := Tag;
        end;
      end;
      inc(i);
      dec(j);
    end;
  until (i>j);

  sl.Free;

  if (left<j) then QuicksortList(List,left,j);
  if (i<right) then QuickSortList(List,i,right);
end;

procedure TColumnComboBox.Sort;
var
  sl: TStringList;
begin
  sl := TStringList.Create;
  sl.Assign(Items);
  SortCol := FSortColumn;
  BeginUpdate;
  if sl.Count>1 then
    QuickSortList(sl,0,sl.Count-1);
  EndUpdate;

  Items.Assign(sl);
  sl.Free;
end;

function TColumnComboBox.CreateLabel: TLabel;
begin
  Result := TLabel.Create(self);
  Result.Parent := self.Parent;
  Result.FocusControl := self;
  Result.Font.Assign(LabelFont);
  Result.OnClick := LabelClick;
  Result.OnDblClick := LabelDblClick;
  Result.ParentFont := self.ParentFont;
end;

procedure TColumnComboBox.UpdateLabel;
begin
  FLabel.Transparent := FLabeltransparent;

  if not FParentFnt then
  begin
    FLabel.Font.Assign(FLabelFont);
  end
  else
    FLabel.Font.Assign(self.Font);

  case FLabelPosition of
    lpLeftTop:
      begin
        FLabel.Top := self.Top;
        FLabel.Left := self.Left - FLabel.Canvas.TextWidth(FLabel.Caption) - FLabelMargin;
      end;
    lpLeftCenter:
      begin
        if Self.Height > FLabel.Height then
          FLabel.Top := self.Top + ((self.Height - FLabel.Height) div 2)
        else
          FLabel.Top := self.Top - ((FLabel.Height - self.Height) div 2);
        FLabel.Left := self.Left - FLabel.Canvas.TextWidth(FLabel.Caption) - FLabelMargin;
      end;
    lpLeftBottom:
      begin
        FLabel.Top := self.Top + self.Height - FLabel.Height;
        FLabel.Left := self.Left - FLabel.Canvas.TextWidth(FLabel.Caption) - FLabelMargin;
      end;
    lpTopLeft:
      begin
        FLabel.Top := self.Top - FLabel.height - FLabelMargin;
        FLabel.Left := self.Left;
      end;
    lpTopRight:
      begin
        FLabel.Top := self.Top - FLabel.height - FLabelMargin;
        FLabel.Left := self.Left + self.Width - FLabel.Width;
      end;
    lpTopCenter:
      begin
        FLabel.Top := self.Top - FLabel.height - FLabelMargin;
        if self.Width - FLabel.Width > 0 then
          FLabeL.Left := self.Left + ((self.Width - FLabel.Width) div 2)
        else
          FLabeL.Left := self.Left - ((FLabel.Width - self.Width) div 2)
      end;
    lpBottomLeft:
      begin
        FLabel.top := self.top + self.height + FLabelMargin;
        FLabel.left := self.left;
      end;
    lpBottomCenter:
      begin
        FLabel.top := self.top + self.height + FLabelMargin;
        if self.Width - FLabel.Width > 0 then
          FLabeL.Left := self.Left + ((self.Width - FLabel.width) div 2)
        else
          FLabeL.Left := self.Left - ((FLabel.Width - self.width) div 2)
      end;
    lpBottomRight:
      begin
        FLabel.top := self.top + self.height + FLabelMargin;
        FLabel.Left := self.Left + self.Width - FLabel.Width;
      end;
    lpLeftTopLeft:
      begin
        FLabel.top := self.top;
        FLabel.left := self.left - FLabelMargin;
      end;
    lpLeftCenterLeft:
      begin
        if Self.Height > FLabel.Height then
          FLabel.Top := self.top + ((self.height - FLabel.height) div 2)
        else
          FLabel.Top := self.Top - ((FLabel.Height - self.Height) div 2);
        FLabel.left := self.left - FLabelMargin;
      end;
    lpLeftBottomLeft:
      begin
        FLabel.top := self.top + self.height - FLabel.height;
        FLabel.left := self.left - FLabelMargin;
      end;
    lpRightTop:
      begin
        FLabel.Top := self.Top;
        FLabel.Left := self.Left + Self.Width + FLabelMargin;
      end;
    lpRightCenter:
      begin
        if Self.Height > FLabel.Height then
          FLabel.Top := self.Top + ((self.Height - FLabel.Height) div 2)
        else
          FLabel.Top := self.Top - ((FLabel.Height - self.Height) div 2);

        FLabel.Left := self.Left + Self.Width + FLabelMargin;
      end;
    lpRighBottom:
      begin
        FLabel.Top := self.Top + self.Height - FLabel.Height;
        FLabel.Left := self.Left + Self.Width + FLabelMargin;
      end;
  end;

  FLabel.Visible := Visible;
end;

procedure TColumnComboBox.CMShowingChanged(var Message: TMessage);
begin
  inherited;
  if (FLabel <> nil) then
    FLabel.Visible := Visible;
end;

procedure TColumnComboBox.CMVisibleChanged(var Message: TMessage);
begin
  inherited;
  if (FLabel <> nil) then FLabel.Visible := Visible;
end;

procedure TColumnComboBox.CMEnabledChanged(var Message: TMessage);
begin
  inherited;

  if Assigned(FLabel) then
    if not FLabelAlwaysEnabled then
      FLabel.Enabled := Enabled;
end;

procedure TColumnComboBox.CMFontChanged(var Message: TMessage);
begin
  if (csDesigning in ComponentState) or (csLoading in ComponentState) then
    if (FLabel <> nil) and ParentFont then
    begin
      FLabel.Font.Assign(self.font);
    end;

  inherited;
end;

procedure TColumnComboBox.WMSetFocus(var Msg: TWMSetFocus);
begin
  if csLoading in ComponentState then
    Exit;

  inherited;

  if FFocusLabel and (FLabel <> nil) then
    FLabel.Font.Style := FLabel.Font.Style + [fsBold];
end;

procedure TColumnComboBox.WMKillFocus(var Msg: TWMKillFocus);
begin
  if (csLoading in ComponentState) then
    Exit;

  if FFocusLabel and (FLabel <> nil) then
    FLabel.Font.Style := FLabel.Font.Style - [fsBold];

  inherited;
end;

procedure TColumnComboBox.SetSortedEx(const Value: boolean);
begin
  FSortedEx := Value;
  if Value then
    if not (csLoading in ComponentState) then Sort;
end;


procedure TColumnComboBox.WMLButtonUp(var Msg:TWMLButtonDown);
begin
  inherited;
  if FDropped then
  begin
    ItemIndex := FItemIndex;
    if SendMessage(self.Handle,CB_GETDROPPEDSTATE,0,0)=0 then
      FDropped := False;
  end;
end;

{$IFNDEF TMSDOTNET}
procedure TColumnComboBox.CMHintShow(var Msg: TMessage);
var
  hi: PHintInfo;
  s: string;
  i: Integer;
begin
  hi := PHintInfo(Msg.LParam);

  if (ItemIndex >= 0) and FShowItemHint then
  begin
    hi^.HintStr := Items[ItemIndex];
    s := '';
    for i := 1 to Columns.Count do
    begin
      s := s + ' ' + GetColumn(i, hi^.HintStr);
    end;
    hi^.HintStr := s;
  end
  else
    hi^.HintStr := Hint;

end;

procedure TColumnComboBox.CMParentFontChanged(var Message: TMessage);
begin
  inherited;
  if Assigned(FLabel) and ParentFont then
  begin
    FLabel.Font.Assign(Font);
    UpdateLabel;
  end;
end;

{$ENDIF}

{$IFDEF TMSDOTNET}
procedure TColumnComboBox.CMHintShow(var Message: TCMHintShow);
var
  hi: THintInfo;
  s: string;
  i: Integer;
begin
  hi := Message.HintInfo;

  if (ItemIndex >= 0) and FShowItemHint then
  begin
    hi.HintStr := Items[ItemIndex];
    s := '';
    for i := 1 to Columns.Count do
    begin
      s := s + ' ' + GetColumn(i, hi.HintStr);
    end;
    hi.HintStr := s;
  end
  else
    hi.HintStr := Hint;

end;

{$ENDIF}

function TColumnComboBox.GetDelimiter: Char;
begin
  Result := FDelimiter;
end;

procedure TColumnComboBox.SetDelimiter(const Value: Char);
begin
  FDelimiter := Value;
end;

function TColumnComboBox.GetEditText: string;
begin
  if (EditColumn >= 0) and (ItemIndex >= 0) then
    Result := ComboItems.Items[ItemIndex].Strings[EditColumn]
  else
    Result := Text;
end;

procedure TColumnComboBox.WMChar(var Msg: TWMChar);
var
  i,CurIdx,FirstIdx: Integer;
  s: string;
  Key: Char;

  function Max(a,b: Integer): Integer;
  begin
   if (a > b) then
     Result := a
   else
     Result := b;
  end;

begin
  inherited;


  Key := Chr(Msg.CharCode);

  if Key = #13 then
  begin
    Exit;
  end;

  if not FLookupIncr then
  begin
    FLookup := Key
  end
  else
    FLookup := FLookup + Key;

  if (ItemIndex >= 0) and (FLookupIncr) then
  begin
    for i := Max(1,ItemIndex + 1) to Items.Count do
    begin
      s := ColumnItems[i-1,FLookupColumn];
      if (s <> '') then
        if (pos(AnsiUpperCase(FLookup),AnsiUpperCase(s)) = 1) then
        begin
          ItemIndex := i - 1;
          if Assigned(OnChange) then
            OnChange(Self);
          Exit;
        end;
    end;
  end;

  FirstIdx := -1;
  CurIdx := ItemIndex;

  for i := 1 to Items.Count do
  begin
    s := ColumnItems[i - 1,FLookupColumn];

    if (s <> '') then
      if (Pos(Uppercase(FLookup),Uppercase(s))=1) then
      begin
        if FirstIdx = -1 then
          FirstIdx := i - 1;

        if (CurIdx >= i - 1) and (CurIdx >= 0) then
        begin

        end
        else
        begin
          ItemIndex := i - 1;
          if Assigned(OnChange) then
            OnChange(Self);
          Exit;
        end;
      end;
  end;

  if not FLookupIncr and (FirstIdx <> -1) then
  begin
    ItemIndex := FirstIdx;
    if Assigned(OnChange) then
      OnChange(Self);
    Exit;
  end;

  if FLookupIncr then
  begin
    FLookup := Key;
    for i := 1 to Items.Count do
    begin
      s := ColumnItems[i-1,FLookupColumn];
      if (s<>'') then
        if (pos(AnsiUpperCase(FLookup),AnsiUpperCase(s))=1) then
        begin
          ItemIndex := i - 1;
          if Assigned(OnChange) then
            OnChange(Self);
          Exit;
        end;
    end;
  end;


end;

function TColumnComboBox.GetVersion: string;
var
  vn: Integer;
begin
  vn := GetVersionNr;
  Result := IntToStr(Hi(Hiword(vn)))+'.'+IntToStr(Lo(Hiword(vn)))+'.'+IntToStr(Hi(Loword(vn)))+'.'+IntToStr(Lo(Loword(vn)));
end;

function TColumnComboBox.GetVersionNr: Integer;
begin
  Result := MakeLong(MakeWord(BLD_VER,REL_VER),MakeWord(MIN_VER,MAJ_VER));
end;

procedure TColumnComboBox.SetVersion(const Value: string);
begin

end;

{ TComboColumnItem }

procedure TComboColumnItem.Assign(Source: TPersistent);
begin
 if Source is TComboColumnItem then
  begin
    Color := TComboColumnItem(source).Color;
    ColumnType := TComboColumnItem(source).ColumnType;
    Width := TComboColumnItem(source).Width;
    Alignment := TComboColumnItem(source).Alignment;
    Font.Assign(TComboColumnItem(source).Font);
  end;
end;

constructor TComboColumnItem.Create(Collection: TCollection);
begin
  inherited;
  FFont := TFont.Create;
  FWidth := 100;
  FColor := clWindow;
end;

destructor TComboColumnItem.Destroy;
begin
  FFont.Free;
  Inherited;
end;

function TComboColumnItem.GetDisplayName: string;
begin
  Result := 'Column'+inttostr(index);
end;

procedure TComboColumnItem.SetAlignment(const Value: tAlignment);
begin
  FAlignment := Value;
  TComboColumnCollection(Collection).FOwner.Invalidate;
end;

procedure TComboColumnItem.SetColor(const Value: TColor);
begin
  FColor := Value;
  TComboColumnCollection(Collection).FOwner.Invalidate;
end;

procedure TComboColumnItem.SetColumnType(const Value: TColumnType);
begin
  FColumnType := Value;
  TComboColumnCollection(Collection).FOwner.Invalidate;
end;

procedure TComboColumnItem.SetFont(const Value: TFont);
begin
  FFont.Assign(Value);
  TComboColumnCollection(Collection).FOwner.Invalidate;
end;

procedure TComboColumnItem.SetWidth(const Value: Integer);
begin
  FWidth := Value;
  TComboColumnCollection(Collection).FOwner.Invalidate;
end;

{ TComboColumnCollection }

function TComboColumnCollection.Add: TComboColumnItem;
begin
  Result := TComboColumnItem(inherited Add);
end;

constructor TComboColumnCollection.Create(AOwner: TColumnComboBox);
begin
  inherited Create(TComboColumnItem);
  FOwner := AOwner;
end;

function TComboColumnCollection.GetItem(Index: Integer): TComboColumnItem;
begin
  Result := TComboColumnItem(inherited Items[index]);
end;

function TComboColumnCollection.GetOwner: tPersistent;
begin
  Result := FOwner;
end;

function TComboColumnCollection.Insert(index: Integer): TComboColumnItem;
begin
  {$IFNDEF DELPHI4_LVL}
  Result := TComboColumnItem(inherited Add);
  {$ELSE}
  Result := TComboColumnItem(inherited Insert(index));
  {$ENDIF}
end;

procedure TComboColumnCollection.SetItem(Index: Integer;
  const Value: TComboColumnItem);
begin
 inherited SetItem(Index, Value);
end;

procedure TComboColumnCollection.Update(Item: TCollectionItem);
begin
  inherited;
end;


{ TComboItemCollection }

function TComboItemCollection.Add: TComboItem;
begin
  Result := TComboItem(inherited Add);
end;

constructor TComboItemCollection.Create(AOwner: TColumnComboBox);
begin
  inherited Create(TComboItem);
  FOwner := AOwner;
end;

function TComboItemCollection.GetItem(Index: Integer): TComboItem;
begin
  Result := TComboItem(inherited Items[index]);
end;

function TComboItemCollection.GetOwner: tPersistent;
begin
  Result := FOwner;
end;

function TComboItemCollection.IndexInColumnOf(col: Integer;
  s: string): Integer;
var
  i: Integer;
begin
  Result := -1;
  for i := 1 to Count do
  begin
    if Items[i - 1].Strings.Count > Col then
      if Items[i - 1].Strings[Col] = s then
      begin
        Result := i - 1;
        Break;
      end;
  end;
end;

function TComboItemCollection.IndexInRowOf(row: Integer;
  s: string): Integer;
var
  i: Integer;
begin
  Result := -1;
  if (Count > Row) then
    for i := 1 to Items[row].Strings.Count do
    begin
      if Items[Row].Strings[i - 1] = s then
      begin
        Result := i - 1;
        Break;
      end;
    end;
end;


function TComboItemCollection.IndexOf(s: string): tpoint;
var
  i,j: Integer;

begin
  Result:=point(-1,-1);

  for i := 1 to Count do
  begin
    for j := 1 to Items[i-1].Strings.Count do
      if Items[i-1].Strings[j-1]=s then
      begin
        Result.y := i-1;
        Result.x := j-1;
        Break;
      end;
  end;
end;

function TComboItemCollection.Insert(Index: Integer): TComboItem;
begin
  {$IFNDEF DELPHI4_LVL}
  Result := TComboItem(inherited Add);
  {$ELSE}
  Result := TComboItem(inherited Insert(Index));
  {$ENDIF}
end;

procedure TComboItemCollection.LoadFromFile(FileName: string);
var
  {$IFNDEF DELPHI_UNICODE}
  tf: textfile;
  s:string;
  {$ENDIF}
  {$IFDEF DELPHI_UNICODE}
  sl: TStringList;
  i: integer;
  {$ENDIF}
begin
  Clear;
  {$IFNDEF DELPHI_UNICODE}
  assignfile(tf, FileName);
  {$i-}
  reset(tf);
  {$i+}
  if (ioresult = 0) then
  begin
    BeginUpdate;
    while not eof(tf) do
    begin
      readln(tf, s);
      Add.Strings.CommaText := s;
    end;
    EndUpdate;
    closefile(tf);
  end;
  {$ENDIF}

  {$IFDEF DELPHI_UNICODE}
  sl := TStringList.Create;

  try
    sl.LoadFromFile(FileName);
    BeginUpdate;
    for i := 0 to sl.Count - 1 do
    begin
      Add.Strings.CommaText := sl.Strings[i];
    end;
    EndUpdate;

  finally
    sl.Free;
  end;
  {$ENDIF}

end;

{$IFNDEF DELPHI_UNICODE}
procedure TComboItemCollection.SaveToFile(FileName: string);
{$ENDIF}
{$IFDEF DELPHI_UNICODE}
procedure TComboItemCollection.SaveToFile(FileName: string; Unicode: boolean = true);
{$ENDIF}
var
  i: integer;
  {$IFNDEF DELPHI_UNICODE}
  tf: textfile;
  {$ENDIF}
  {$IFDEF DELPHI_UNICODE}
  sl: TStringList;
  {$ENDIF}

begin
  {$IFNDEF DELPHI_UNICODE}
  assignfile(tf, FileName);
  rewrite(tf);
  for i := 1 to Count do
  begin
    writeln(tf, Items[i - 1].Strings.CommaText);
  end;
  closefile(tf);
  {$ENDIF}

  {$IFDEF DELPHI_UNICODE}
  sl := TStringList.Create;
  for i := 1 to Count do
  begin
    sl.Add(Items[i - 1].Strings.CommaText);
  end;

  if Unicode then
    sl.SaveToFile(FileName, TEncoding.Unicode)
  else
    sl.SaveToFile(FileName);

  sl.Free;
  {$ENDIF}
end;

procedure TComboItemCollection.SetItem(Index: Integer;
  const Value: TComboItem);
begin
 inherited SetItem(Index, Value);
end;

procedure TComboItemCollection.Update(Item: TCollectionItem);
begin
  inherited;
end;

{ TComboItem }

procedure TComboItem.Assign(Source: TPersistent);
begin
  if Source is TComboItem then
  begin
    ImageIndex := TComboItem(Source).ImageIndex;
    Strings.Assign(TComboItem(Source).Strings);
    TComboItemCollection(collection).FOwner.BuildItems;
  end;
end;

constructor TComboItem.Create(Collection: TCollection);
begin
  inherited;
  FStrings:=TStringList.Create;
  FImageIndex:=-1;
  {$IFNDEF TMSDOTNET}
  FStrings.OnChange:=StringsChanged;
  {$ENDIF}
  {$IFDEF TMSDOTNET}
  TStringList(FStrings).OnChange:=StringsChanged;
  {$ENDIF}

end;

destructor TComboItem.Destroy;
var
  AOwner: TColumnCombobox;
begin
  AOwner := TComboItemCollection(Collection).FOwner;
  FStrings.Free;
  inherited;
  if AOwner.HandleAllocated then AOwner.BuildItems;
end;

function TComboItem.GetDisplayName: string;
begin
  Result := 'Item'+inttostr(index);
end;

procedure TComboItem.SetImageIndex(const Value: Integer);
begin
  FImageIndex := Value;
  TComboItemCollection(collection).FOwner.Invalidate;
end;

{$IFNDEF TMSDOTNET}
procedure TComboItem.SetStrings(const Value: TStringList);
{$ENDIF}
{$IFDEF TMSDOTNET}
procedure TComboItem.SetStrings(const Value: TStrings);
{$ENDIF}
begin
  FStrings.Assign(Value);
  TComboItemCollection(Collection).FOwner.Invalidate;
end;

procedure TComboItem.StringsChanged(Sender: TObject);
var
  idx: Integer;
begin
  if TComboItemCollection(Collection).FOwner.FUpdateCount > 0 then
    Exit;
  idx := TComboItemCollection(Collection).FOwner.ItemIndex;
  TComboItemCollection(Collection).FOwner.BuildItems;
  TComboItemCollection(Collection).FOwner.ItemIndex := idx;
end;


end.
