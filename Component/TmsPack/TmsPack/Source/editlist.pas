{*********************************************************************}
{ TEDITLISTBOX component                                              }
{ for Delphi & C++ Builder                                            }
{                                                                     }
{ written by TMS Software                                             }
{            copyright © 1998-2010                                    }
{            Email : info@tmssoftware.com                             }
{            Website : http://www.tmssoftware.com                     }
{                                                                     }
{ The source code is given as is. The author is not responsible       }
{ for any possible damage done due to the use of this code.           }
{ The component can be freely used in any application. The source     }
{ code remains property of the author and may not be distributed      }
{ freely as such.                                                     }
{*********************************************************************}

{$I TMSDEFS.INC}

unit editlist;

interface

uses
  StdCtrls, Graphics, Windows, Messages, Classes, Controls, SysUtils, Forms,
  Inifiles, Registry

  {$IFDEF TMSDOTNET}
  , Types, CommCtrl
  {$ENDIF}
  ;

const
  MAJ_VER = 2; // Major version nr.
  MIN_VER = 1; // Minor version nr.
  REL_VER = 1; // Release nr.
  BLD_VER = 0; // Build nr.

  // version history
  // 2.1.0.1 : fixed issue with OnKeyPress
  // 2.1.0.2 : fixed issue with handling ESC/Return on modal form with default buttons
  // 2.1.0.3 : fixed issue with horiz. scrollbar visible when no items are in the list
  // 2.1.0.4 : fixed issue with flat scrollbar & use of BeginUpdate/EndUpdate
  // 2.1.1.0 : New : method HideEdit added 
  

type
  {$IFDEF DELPHI_UNICODE}
  THintInfo = Controls.THintInfo;
  PHintInfo = Controls.PHintInfo;
  {$ENDIF}

  TScrollStyle = (ssNormal, ssFlat, ssEncarta);

  TEditListBox = class;

  TEditDoneEvent = procedure(Sender: TObject; var newstr: string; var allow: boolean) of object;

  TEditStartEvent = procedure(Sender: TObject; itemindex: integer; var allow: boolean) of object;

  TAutoInsertEvent = procedure(Sender: TObject; var avalue: string) of object;

  TAutoDeleteEvent = procedure(Sender: TObject; var avalue: string; var allowdelete: boolean) of object;

  TSelChangeEvent = procedure(Sender: TObject; ListIndex: integer) of object;

{$IFDEF DELPHI3_LVL}

  TTabType = (tableft, tabright);

  TTabPositionItem = class(TCollectionItem)
  private
    fTabPosition: integer;
    fTabType: TTabType;
    procedure SetTabPosition(value: integer);
    procedure SetTabType(value: tTabType);
  published
    property TabPosition: integer read fTabPosition write SetTabPosition;
    property TabType: TTabType read fTabType write SetTabType;
  end;

  TTabPositionCollection = class(TCollection)
  private
    fOwner: TEditListBox;
  public
    constructor Create(aOwner: TEditListBox);
  protected
    function GetOwner: tPersistent; override;
  end;
{$ENDIF}

  TSizeEdit = class(TEdit)
  private
    parentlist: teditlistbox;
    parentlistindex: integer;
    parentlistcount: integer;
    parentlistcache: string;
    procedure WMLButtonDown(var Msg: TWMLButtonDown); message wm_lbuttondown;
    procedure WMChar(var Msg: TWMKey); message wm_char;
    procedure WMGetDlgCode(var Message: TWMGetDlgCode); message WM_GETDLGCODE;
    procedure CMTextChanged(var Message: TMessage); message CM_TEXTCHANGED;
  protected
    procedure CreateParams(var Params: TCreateParams); override;
    procedure UpdateEdit;
    procedure DoExit; override;
    procedure Change; override;
    procedure KeyPress(var Key: char); override;
    procedure KeyDown(var Key: Word; Shift: TShiftState); override;
  public
  published
  end;

  TELStorage = (stInifile, stRegistry);

  TELPersist = class(TPersistent)
  private
    FEnable: boolean;
    FStorage: TELStorage;
    FKey: string;
    FSection: string;
    FCount: integer;
    FMaxCount: boolean;
  published
    property Enable: boolean read fEnable write fEnable;
    property Storage: TELStorage read fStorage write fStorage;
    property Key: string read fKey write fKey;
    property Section: string read fSection write fSection;
    property Count: integer read fCount write fCount;
    property MaxCount: boolean read fMaxCount write fMaxCount;
  end;


  TEditListBox = class(TListBox)
  private
    editctrl: tSizeEdit;
    FHintColor: tcolor;
    FLastHintPos: TPoint;
    FListTimerID: integer;
    FUpdateCount: integer;
    FLookupString: string;
    FReturnIsTab: boolean;
    FReturnIsClick: boolean;
    FReturnIsDblClick: boolean;
    FOnEditDone: tEditDoneEvent;
    FOnEditStart: tEditStartEvent;
    FOnAutoInsert: tAutoInsertEvent;
    FOnAutoDelete: tAutoDeleteEvent;
    FOnSelChange: tSelChangeEvent;
    FEditMode: boolean;
    FAutoInsert: boolean;
    FAutoDelete: boolean;
    FAllowEdit: boolean;
    FLookupIncr: boolean;
    FLookupFull: boolean;
    FScrollStyle: tScrollStyle;
    FScrollColor: tColor;
    FScrollWidth: integer;
    FScrollHorizontal: boolean;
    FCacheExtent: integer;
    FEditDisable: boolean;
    FFocusColor: tcolor;
    FNormalColor: tcolor;
    FHovering: boolean;
    FStopHover: boolean;
    FELPersist: TELPersist;
{$IFDEF DELPHI3_LVL}
    FTabPositions: tTabPositionCollection;
{$ENDIF}
    procedure WMChar(var Msg: TWMChar); message WM_CHAR;
    procedure WMTimer(var Msg: TWMTimer); message WM_TIMER;
    procedure WMLButtonDown(var Msg: TWMLButtonDown); message WM_LBUTTONDOWN;
    procedure WMKeyDown(var Msg: TWMKeydown); message WM_KEYDOWN;
    procedure WMSetFocus(var Msg: TWMSetFocus); message WM_SETFOCUS;
    procedure WMKillFocus(var Msg: TWMKillFocus); message WM_KILLFOCUS;
    procedure SetEditMode(const value: boolean);
    procedure SetAllowEdit(const value: boolean);
    procedure SetHovering(const value: boolean);
    procedure UpdateHover;
    procedure CNCommand(var Message: TWMCommand); message CN_COMMAND;
    {$IFNDEF TMSDOTNET}
    procedure CMHintShow(var Msg: TMessage); message CM_HINTSHOW;
    {$ENDIF}
    {$IFDEF TMSDOTNET}
    procedure CMHintShow(var Message: TCMHintShow); message CM_HINTSHOW;
    {$ENDIF}
    procedure ShowHint(var HintStr: string; var CanShow: Boolean; var HintInfo: THintInfo);
    procedure SetIndexAndScroll(value: integer);
    procedure WMVScroll(var WMScroll: TWMScroll); message WM_VSCROLL;
    procedure WMHScroll(var WMScroll: TWMScroll); message WM_HSCROLL;
    {$IFNDEF TMSDOTNET}
    procedure FlatSetScrollPos(code, pos: integer; fRedraw: bool);
    procedure FlatSetScrollProp(index, newValue: integer; fRedraw: bool);
    procedure FlatSetScrollInfo(code: integer; var scrollinfo: tscrollinfo; fRedraw: bool);
    procedure FlatShowScrollBar(code: integer; show: bool);
    {$ENDIF}
    procedure SetScrollStyle(const Value: TScrollStyle);
    procedure SetScrollColor(const Value: TColor);
    procedure SetScrollWidth(const Value: integer);
    procedure SetScrollHorizontal(const Value: boolean);
{$IFDEF DELPHI3_LVL}
    procedure SetTabPositions(value: tTabPositionCollection);
    procedure SetTabStops;
{$ENDIF}
    function VisibleItems: Integer;
    function GetStringExtent(s: string): integer;
    function GetMaxStringExtent: integer;
    procedure UpdateHScrollExtent;
    procedure UpdateVScrollBar;
    procedure UpdateHScrollBar;
    procedure UpdateStyle;
    procedure UpdateColor;
    procedure UpdateWidth;
    procedure Lookup;
    function GetVersion: string;
    procedure SetVersion(const Value: string);
  protected
    function GetVersionNr: Integer; virtual;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    procedure KeyDown(var Key: Word; Shift: TShiftState); override;
    procedure KeyUp(var Key: Word; Shift: TShiftState); override;
    procedure KeyPress(var Key: char); override;
    procedure DoExit; override;
    procedure WndProc(var Message: TMessage); override;
    procedure CreateParams(var Params: TCreateParams); override;
    procedure Loaded; override;
    procedure DestroyWnd; override;
  public
    constructor Create(aOwner: tComponent); override;
    destructor Destroy; override;
    property EditMode: boolean read fEditMode write SetEditMode;
    procedure BeginUpdate;
    procedure EndUpdate;
    procedure ShowEdit;
    procedure HideEdit;
    procedure SavePersist;
    procedure LoadPersist;
{$IFDEF DELPHI3_LVL}
    procedure OptimizeTabs(padding: integer);
{$ENDIF}
  published
    property OnEditDone: tEditDoneEvent read FOnEditDone write FOnEditDone;
    property OnEditStart: tEditStartEvent read FOnEditStart write FOnEditStart;
    property AutoInsert: boolean read fAutoInsert write fAutoInsert;
    property AutoDelete: boolean read fAutoDelete write fAutoDelete;
    property AllowEdit: boolean read FAllowEdit write SetAllowEdit;
    property OnAutoInsert: TAutoInsertEvent read FOnAutoInsert write FOnAutoInsert;
    property OnAutoDelete: TAutoDeleteEvent read FOnAutoDelete write FOnAutoDelete;
    property OnSelChange: TSelChangeEvent read FOnSelChange write FOnSelChange;
    property ItemIndex write SetIndexAndScroll;
    property ScrollStyle: TScrollStyle read FScrollStyle write SetScrollStyle;
    property ScrollColor: TColor read FScrollColor write SetScrollColor;
    property ScrollWidth: integer read FScrollWidth write SetScrollWidth;
    property ScrollHorizontal: boolean read FScrollHorizontal write SetScrollHorizontal;
    property LookupIncr: boolean read FLookupIncr write FLookupIncr;
    property LookupFull: boolean read FLookupFull write FLookupFull;
    property ReturnIsTab: boolean read FReturnIsTab write FReturnIsTab;
    property ReturnIsClick: boolean read FReturnIsClick write FReturnIsClick;
    property ReturnIsDblClick: boolean read FReturnIsDblClick write FReturnIsDblClick;
    property FocusColor: TColor read fFocusColor write fFocusColor;
    property Hovering: boolean read fHovering write SetHovering;
    property Persist: TELPersist read fELPersist write fELPersist;
    property HintColor: tColor read fHintColor write fHintColor;
{$IFDEF DELPHI3_LVL}
    property TabPositions: tTabPositionCollection read fTabPositions write SetTabPositions;
{$ENDIF}
    property Version: string read GetVersion write SetVersion;
  end;

implementation

const
  commctrl = 'comctl32.dll';
  MAX_TABS = 20;

  WSB_PROP_CYVSCROLL = $0000001;
  WSB_PROP_CXHSCROLL = $0000002;
  WSB_PROP_CYHSCROLL = $0000004;
  WSB_PROP_CXVSCROLL = $0000008;
  WSB_PROP_CXHTHUMB = $0000010;
  WSB_PROP_CYVTHUMB = $0000020;
  WSB_PROP_VBKGCOLOR = $0000040;
  WSB_PROP_HBKGCOLOR = $0000080;
  WSB_PROP_VSTYLE = $0000100;
  WSB_PROP_HSTYLE = $0000200;
  WSB_PROP_WINSTYLE = $0000400;
  WSB_PROP_PALETTE = $0000800;
  WSB_PROP_MASK = $0000FFF;

  FSB_FLAT_MODE = 2;
  FSB_ENCARTA_MODE = 1;
  FSB_REGULAR_MODE = 0;


{$IFDEF TMSDEBUG}

procedure OutputDebugStr(s: string);
begin
  OutputDebugString(pchar(s));
end;
{$ENDIF}

procedure TSizeEdit.CreateParams(var Params: TCreateParams);
begin
  inherited CreateParams(params);
 //params.style:=params.style or ES_MULTILINE;
end;

procedure TSizeEdit.WMLButtonDown(var Msg: TWMLButtonDown);
begin
  inherited;
  if not ptinrect(getclientrect, point(msg.xpos, msg.ypos)) then
    with parent as TEditListbox do
    begin
      self.visible := false;
      setfocus;
      itemindex := parentlistindex;
      parentlistcache := '';
    end;
end;

procedure TSizeEdit.UpdateEdit;
var
  allowupdate: boolean;
  updatetext: string;
begin
  allowupdate := true;
  updatetext := self.text;

  with parent as TEditListbox do
  begin
    fEditDisable := true;
    items[parentlistindex] := updatetext;

    if assigned(parentlist.onEditDone) then
      parentlist.onEditDone(parentlist, updatetext, allowupdate);

    fEditDisable := false;

    if allowupdate then
      items[parentlistindex] := updatetext
    else
    begin
      items[parentlistindex] := parentlistcache;
    end;
    if multiselect then selected[parentlistindex] := true;
  end;
end;

procedure TSizeEdit.WMChar(var Msg: TWMKey);
begin
  if (msg.charcode = vk_return) then Exit;
  inherited;
end;

procedure TSizeEdit.WMGetDlgCode(var Message: TWMGetDlgCode);
begin
  inherited;
  Message.Result := Message.Result or DLGC_WANTALLKEYS;
end;

procedure TSizeEdit.KeyDown(var Key: Word; Shift: TShiftState);
begin
  case key of
    vk_up: with parent as TEditListbox do
      begin
        self.visible := false;
        setfocus;
        if (parentlistindex > 0) then
          itemindex := parentlistindex - 1
        else
          itemindex := parentlistindex;
        parentlistcache := '';
        parentlist.keydown(key, shift);
      end;
    vk_down: with parent as TEditListbox do
      begin
        self.visible := false;
        setfocus;
        if parentlistindex < parentlistcount - 1 then
          itemindex := parentlistindex + 1
        else
          itemindex := parentlistindex;
        parentlistcache := '';
        parentlist.keydown(key, shift);
      end;
    vk_return: with parent as TEditListbox do
      begin
        self.visible := false;
        setfocus;
        itemindex := parentlistindex;
        parentlistcache := '';
      end;
  else
    inherited Keydown(key, shift);
  end;
end;

procedure TSizeEdit.DoExit;
begin
  releasecapture;
  UpdateEdit;
  with parent as TListbox do
  begin
    itemindex := parentlistindex;
    if multiselect then selected[parentlistindex] := true;
    self.visible := false;
    setfocus;
    parentlistcache := '';
  end;
  inherited DoExit;
end;

procedure TSizeEdit.Keypress(var Key: char);
begin
  case key of
    #27: with (parent as TListbox) do
      begin
        self.text := parentlistcache;
        self.visible := false;
        setfocus;
        parentlistcache := '';
      end;
    #13: if (self.text <> '') then
        with parent as TListbox do
        begin
          itemindex := parentlistindex;
          self.visible := false;
          setfocus;
          parentlistcache := '';
        end;
  end;
  inherited;
end;

procedure TSizeEdit.Change;
var
  str: array[0..255] of char;
  edc: hdc;
  tagsize: tSize;
  w: integer;
  r: trect;
  {$IFDEF TMSDOTNET}
  st : string;
  i : integer;
  {$ENDIF}

begin
  inherited;
  edc := getdc(self.handle);
  selectobject(edc, self.font.handle);

  {$IFNDEF TMSDOTNET}
  strpcopy(str, self.text);
  {$ENDIF}
  {$IFDEF TMSDOTNET}
  st := String (self.text);
  for i := 1 to st.Length do
    str[i-1] := st[i];
  {$ENDIF}

  {$IFNDEF TMSDOTNET}
  GetTextExtentPoint32(edc, str, strlen(str), tagsize);
  {$ENDIF}
  {$IFDEF TMSDOTNET}
  GetTextExtentPoint32(edc, str, Length(str), tagsize);
  {$ENDIF}

  r := (parent as TListBox).clientrect;
  with parent as TListBox do
  begin
    w := r.right - r.left;
    if (tagsize.cx + 15 > w) then self.width := w + 1 else
      self.width := tagsize.cx + 15;
  end;
end;

procedure TSizeEdit.CMTextChanged(var Message: TMessage);
var
  str: array[0..255] of char;
  edc: hdc;
  tagsize: tSize;
  w: integer;
  r: trect;
  {$IFDEF TMSDOTNET}
  st : string;
  i : integer;
  {$ENDIF}

begin
  inherited;
  edc := getdc(self.handle);
  selectobject(edc, self.font.handle);
  {$IFNDEF TMSDOTNET}
  strpcopy(str, self.text);
  {$ENDIF}
  {$IFDEF TMSDOTNET}
  st := string(self.text);
  for i := 1 to st.length do
    str[i-1] := st[i];
  {$ENDIF}

  {$IFNDEF TMSDOTNET}
  GetTextExtentPoint32(edc, str, strlen(str), tagsize);
  {$ENDIF}
  {$IFDEF TMSDOTNET}
  GetTextExtentPoint32(edc, str, Length(str), tagsize);
  {$ENDIF}
  r := (parent as TListBox).clientrect;
  with parent as TListBox do
  begin
    w := r.right - r.left;
    if (tagsize.cx + 15 > w) then self.width := w + 1 else
      self.width := tagsize.cx + 15;
  end;
end;

constructor TEditListBox.Create(aOwner: tComponent);
begin
  inherited Create(aOwner);
{$IFDEF DELPHI3_LVL}
  fTabPositions := TTabPositionCollection.Create(self);
{$ENDIF}
  fELPersist := TELPersist.Create;
  ControlStyle := ControlStyle - [csOpaque];
  fScrollColor := clNone;
  fScrollWidth := GetSystemMetrics(SM_CXVSCROLL);
  fScrollStyle := ssNormal;
  fScrollHorizontal := true;
  fFocusColor := clWindow;
  fLookupString := '';
  fEditDisable := false;
  fUpdateCount := 0;
  fHintcolor := clwhite;

  if (csDesigning in ComponentState) then exit;

  editctrl := tSizeEdit.Create(self);
  editctrl.visible := false;
  editctrl.parent := self;
  editctrl.top := 0;
  editctrl.left := 0;
  editctrl.ctl3d := false;
  editctrl.parentlistindex := -1;
  editctrl.parentlistcount := -1;
  editctrl.parentlist := self;
  editctrl.parentlistcache := '';
  editctrl.visible := false;
  fEditMode := false;
  fAllowEdit := true;
end;

procedure TEditListBox.DoExit;
begin
  if editctrl.visible then
  begin
    editctrl.UpdateEdit;
    editctrl.visible := false;
    editctrl.parentlistcache := '';
    editctrl.parentlistindex := -1;
  end;
  inherited DoExit;
end;

procedure TEditListBox.HideEdit;
begin
  if editctrl.visible then
  begin
    editctrl.UpdateEdit;
    editctrl.visible := false;
    editctrl.parentlistcache := '';
    editctrl.parentlistindex := -1;
  end;
end;

procedure TEditListBox.ShowEdit;
var
  idx, hght, cur: longint;
  allow: boolean;

begin
  if (self.ItemIndex = -1) then
    Exit;
  if (self.Items.Count = 0) then
    Exit;
    
  allow := true;
  if Assigned(FOnEditStart) then
    FOnEditStart(self, itemindex, allow);
    
  if not Allow then
    Exit;

  SendMessage(self.Handle, WM_HSCROLL, SB_TOP, 0);

  idx := SendMessage(self.handle, lb_gettopindex, 0, 0);
  hght := SendMessage(self.handle, lb_getitemheight, 0, 0);
  cur := self.ItemIndex;

 //force a no selection in the listbox
 //self.itemindex:=-1;
 //self.selected[cur]:=false;
  fEditDisable := true;
  self.repaint;
  editctrl.visible := true;
  editctrl.ctl3d := false;
  editctrl.top := (cur - idx) * hght;
  editctrl.text := items[cur];
  editctrl.height := hght;
  editctrl.Setfocus;
  editctrl.parentlistindex := cur;
  editctrl.parentlistcount := self.items.count;
  editctrl.parentlistcache := items[cur];
  setcapture(editctrl.handle);
  items[cur] := ''; //??? sets selection again ???
  self.itemindex := -1;
  sendMessage(editctrl.Handle, EM_SETSEL, 0, -1);
  fEditDisable := false;
end;

procedure TEditListBox.SetEditMode(const value: boolean);
begin
  if (value) and (not FEditMode) then ShowEdit;
  if (not value) and (FEditMode) then
  begin
    if (editctrl.text <> '') then
      items[editctrl.parentlistindex] := editctrl.text;
    self.setfocus;
    editctrl.visible := false;
  end;
  FEditMode := value;
end;

procedure TEditListBox.KeyPress(var key: char);
begin
  inherited KeyPress(key);
end;

procedure TEditListBox.KeyUp(var Key: Word; Shift: TShiftState);
begin
  inherited;
  if (fLookupString <> '') then Lookup;
end;

procedure TEditListBox.KeyDown(var Key: Word; Shift: TShiftState);
var
  i: integer;
  s: string;
  allow: boolean;
begin
  if (key = vk_insert) and (fAutoInsert) then
  begin
    s := '';
    if assigned(OnAutoInsert) then OnAutoInsert(self, s);
    i := items.add(s);
    if multiselect then selected[i] := true;
    itemindex := i;
    showedit;
  end;

  if (key = vk_delete) and (fAutoDelete) and (items.count > 0) and (itemindex >= 0) then
  begin
    allow := true;
    s := items[Itemindex];
    if assigned(OnAutoDelete) then OnAutoDelete(self, s, allow);
    if allow then
    begin
      i := itemindex;
      items.delete(itemindex);
      if (i >= items.count) then dec(i);
      itemindex := i;
    end;
  end;
  if (key in [vk_up, vk_down, vk_next, vk_prior, vk_home, vk_end]) then
    fLookupString := '';

  inherited KeyDown(key, shift);
end;

procedure TEditListBox.DestroyWnd;
begin
  if not (csDesigning in ComponentState) then
  begin
    if (fHovering) then killtimer(self.handle, fListTimerID);
  end;
  inherited;
end;

destructor TEditListBox.Destroy;
begin
  if not (csDesigning in ComponentState) then
  begin
    editctrl.Free;
  end;
  fELPersist.Free;
{$IFDEF DELPHI3_LVL}
  fTabPositions.Free;
{$ENDIF}
  inherited Destroy;
end;

procedure TEditListBox.LoadPersist;
var
  Inifile: TInifile;
  RIniFile: TRegIniFile;
  i: integer;
  s: string;
begin
  if self.fELPersist.Enable then
  begin
    if self.fELPersist.Storage = stInifile then
    begin
      Inifile := TInifile.Create(self.fELPersist.Key);
      self.Items.Clear;
      i := 1;
      repeat
        s := Inifile.ReadString(self.fELPersist.Section, 'Item' + inttostr(i), '');
        inc(i);
        if s <> '' then self.Items.Add(s);
      until s = '';

      Inifile.Free;
    end
    else
    begin
      RInifile := TRegInifile.Create(self.fELPersist.Key);
      self.Items.Clear;
      i := 1;
      repeat
        s := RInifile.ReadString(self.fELPersist.Section, 'Item' + inttostr(i), '');
        inc(i);
        if s <> '' then self.Items.Add(s);
      until s = '';

      RInifile.Free;
    end;
  end;
end;

procedure TEditListBox.SavePersist;
var
  IniFile: TIniFile;
  RIniFile: TRegIniFile;
  i, j, k: integer;
begin
  if fELPersist.Enable then
  begin
    if fELPersist.Storage = stInifile then
    begin
      Inifile := TInifile.Create(fELPersist.Key);

      j := 0;
      k := self.Items.Count;
      if fELPersist.MaxCount then k := fELPersist.Count;

      if fELPersist.MaxCount and (self.Items.Count > fELPersist.Count) then
        j := self.Items.Count - self.fELPersist.Count;

      for i := 1 to k do
      begin
        if (i + j <= self.Items.Count) then
          Inifile.WriteString(fELPersist.Section, 'Item' + inttostr(i), self.Items[i + j - 1])
        else
          Inifile.WriteString(fELPersist.Section, 'Item' + inttostr(i), '');
      end;

      Inifile.WriteString(fELPersist.Section, 'Item' + inttostr(k + 1), '');
      Inifile.Free;
    end
    else
    begin
      RInifile := TRegInifile.Create(fELPersist.Key);
      j := 0;
      k := self.Items.Count;
      if fELPersist.MaxCount then k := fELPersist.Count;

      if fELPersist.MaxCount and (self.Items.Count > fELPersist.Count) then
        j := self.Items.Count - self.fELPersist.Count;

      for i := 1 to k do
      begin
        if (i + j <= self.Items.Count) then
          RInifile.WriteString(fELPersist.Section, 'Item' + inttostr(i), self.Items[i + j - 1])
        else
          RInifile.WriteString(fELPersist.Section, 'Item' + inttostr(i), '');
      end;

      RInifile.WriteString(fELPersist.Section, 'Item' + inttostr(k + 1), '');
      RInifile.Free;
    end;
  end;
end;



{$IFDEF DELPHI3_LVL}

procedure TEditListBox.SetTabPositions(value: ttabpositioncollection);
begin
  fTabPositions.Assign(value);
end;

procedure TEditListBox.SetTabStops;
var
  i: integer;
  d: array[0..MAX_TABS] of integer;
  dw: longint;
  tp: integer;
 {
 hdclistbox:thandle;
 hfontnew,hfontold:thandle;
 tm:TTextMetric;
 r:trect;
 }
begin
  {
  dw:=loword(GetDialogBaseUnits);
  outputdebugstring(pchar(inttostr(dw)));
  hDCListBox := GetDC( parent.Handle );
  hFontNew := SendMessage( parent.Handle, WM_GETFONT, 0, 0 );
  hFontOld := SelectObject( hDCListBox, hFontNew );
  GetTextMetrics( canvas.handle, tm );
  SelectObject( hDCListBox, hFontOld );
  ReleaseDC( parent.Handle, hDCListBox );
  outputdebugstring(pchar('avg width = '+inttostr(tm.tmAveCharWidth)));
  dw:=tm.tmAveCharWidth;
  }
  dw := canvas.textwidth('x');

  if (fTabPositions.Count > 0) and (fTabPositions.Count < MAX_TABS) then
  begin
    for i := 0 to fTabPositions.Count - 1 do
    begin
      tp := (fTabPositions.Items[i] as TTabPositionItem).TabPosition;

      if (fTabPositions.Items[i] as TTabPositionItem).TabType = tabRight then
        d[i] := -trunc((tp * 4) / dw)
      else
        d[i] := trunc((tp * 4) / dw)

      {
       if (fTabPositions.Items[i] as TTabPositionItem).TabType=tabRight then
       d[i]:=-(1+((tp*4) div (dw-1)))
      else
       d[i]:=1+((tp*4) div (dw-1));
       }
    end;
    {$IFNDEF TMSDOTNET}
    sendmessage(self.handle, lb_settabstops, fTabPositions.Count, longint(@d));
    {$ENDIF}
    {$IFDEF TMSDOTNET}
    Perform(lb_settabstops, fTabPositions.Count, d);
    {$ENDIF}
  end;
end;
{$ENDIF}

procedure TEditListBox.WMKeyDown(var Msg: TWMKeydown);
begin
  if (msg.charcode = vk_return) then
  begin
    if (fReturnIsTab) then
    begin
      msg.charcode := vk_tab;
      postmessage(self.handle, wm_keydown, VK_TAB, 0);
    end;
    if (fReturnIsClick) then
    begin
      if Assigned(OnClick) then OnClick(self);
    end;
    if (fReturnIsDblClick) then
    begin
      if Assigned(OnDblClick) then OnDblClick(self);
    end;
  end;
  inherited;
end;

procedure TEditListBox.WMSetFocus(var Msg: TWMSetFocus);
begin
  inherited;
  FNormalColor := Color;
  Color := FFocusColor;
  FLookupString := '';
end;

procedure TEditListBox.WMKillFocus(var Msg: TWMKillFocus);
begin
  inherited;
  Color := FNormalColor;
end;

procedure TEditListBox.WMTimer(var Msg: TWMTimer);
var
  lp: TPoint;
  r: TRect;
begin
  if (msg.TimerID = FListTimerID) and not FStopHover and
    (GetFocus = self.handle) then
  begin
    r := getclientrect;
    getcursorpos(lp);
    lp := screentoclient(lp);
    if ptinrect(r, lp) then
    begin
      self.itemindex := sendmessage(self.handle, LB_ITEMFROMPOINT, 0, makelparam(lp.x, lp.y));
    end;
  end;
end;

procedure TEditListBox.WMChar(var Msg: TWMChar);
begin
  case msg.charcode of
    27: fLookupString := '';
    32: if FAllowEdit then ShowEdit else inherited;
    48..58, 65..122:
      begin
        fLookupString := fLookupString + upcase(chr(msg.charcode));
        inherited;
      end;
  else
    inherited;
  end;
end;

procedure TEditListBox.WMLButtonDown(var Msg: TWMLButtonDown);
var
  idx, hght, clk, cur: longint;

begin
  fLookupString := '';
  if not FAllowEdit then
  begin
    inherited;
    exit;
  end;
  idx := sendmessage(self.handle, lb_gettopindex, 0, 0);
  hght := sendmessage(self.handle, lb_getitemheight, 0, 0);
  clk := (msg.ypos div hght) + idx;
  cur := self.itemindex;

  if (cur = editctrl.parentlistindex) and (editctrl.parentlistcache <> '') then exit;

  inherited;

  if (csDesigning in ComponentState) then exit;

  if (clk = cur) and (cur >= 0) and (editctrl.parentlistcache = '') then
  begin
    Showedit;
  end
  else
  begin
    editctrl.visible := false;
    if (editctrl.parentlistcache <> '') then
    begin
      if (editctrl.text <> '') then
        items[editctrl.parentlistindex] := editctrl.text
      else
        items[editctrl.parentlistindex] := editctrl.parentlistcache;
      editctrl.parentlistcache := '';
    end;
  end;
end;

procedure TEditListBox.SetAllowEdit(const value: boolean);
begin
  FAllowEdit := value;
  if (csDesigning in ComponentState) then exit;
  if editctrl.visible then
  begin
    editctrl.UpdateEdit;
    editctrl.visible := false;
    editctrl.parentlistcache := '';
    editctrl.parentlistindex := -1;
    setfocus;
  end;
end;

procedure TEditListBox.SetHovering(const value: boolean);
begin
  if (value <> fHovering) then
  begin
    fHovering := value;
    if not (csDesigning in ComponentState) then
    begin
      if value then
        fListTimerID := settimer(self.handle, 111, 1000, nil)
      else
        KillTimer(self.handle, fListTimerID);
    end;
  end;
end;

procedure TEditListBox.CreateParams(var Params: TCreateParams);
begin
  inherited CreateParams(params);
  params.style := params.style or LBS_USETABSTOPS;
end;

procedure TEditListBox.Loaded;
begin
  inherited;
  UpdateWidth;
  UpdateStyle;
  UpdateColor;
  UpdateVScrollBar;
  UpdateHScrollBar;
  {seems to be required on older COMCTRL versions to force
   scroll height calculation}
  self.height := self.height + 1;
  self.height := self.height - 1;
end;

procedure TEditListBox.WMHScroll(var WMScroll: TWMScroll);
begin
  inherited;
  wmscroll.pos := getscrollpos(self.handle, SB_HORZ);
  {$IFNDEF TMSDOTNET}
  FlatSetScrollPos(SB_HORZ, wmScroll.pos, true);
  {$ENDIF}
  {$IFDEF TMSDOTNET}
  FlatSB_SetScrollPos(Self.Handle,SB_HORZ, wmScroll.pos, true);
  {$ENDIF}
end;

procedure TEditListBox.WMVScroll(var WMScroll: TWMScroll);
begin
  inherited;
  wmscroll.pos := getscrollpos(self.handle, SB_VERT);
  {$IFNDEF TMSDOTNET}
  FlatSetScrollPos(SB_VERT, wmScroll.pos, true);
  {$ENDIF}
  {$IFDEF TMSDOTNET}
  FlatSB_SetScrollPos(Self.Handle, SB_VERT, wmScroll.pos, true);
  {$ENDIF}
end;

procedure TEditListBox.UpdateHover;
var
  lp: tpoint;
  r: trect;
begin
  getcursorpos(lp);
  r := getclientrect;
  lp := screentoclient(lp);
  if ptinrect(r, lp) then
  begin
    {$IFNDEF TMSDOTNET}
    sendmessage(self.handle, lb_getitemrect, self.itemindex, longint(@r));
    {$ENDIF}
    {$IFDEF TMSDOTNET}
    Perform(lb_getitemrect, self.itemindex, r);
    {$ENDIF}
    lp.y := r.top + (r.bottom - r.top) shr 1;
    lp := clienttoscreen(lp);
    setcursorpos(lp.x, lp.y);
  end;
end;

procedure TEditListBox.CNCommand(var Message: TWMCommand);
begin
  inherited;
  if (Message.NotifyCode = LBN_SELCHANGE) then
  begin
    FStopHover := True;
    if Assigned(FOnSelChange) then
      FOnSelChange(Self, Itemindex);
    if FHovering then
      UpdateHover;
    FStopHover := False;
  end;
end;

procedure TEditListBox.WndProc(var Message: TMessage);
begin
  inherited;

  if (message.msg = LB_SETCURSEL) then
  begin
    if assigned(FOnSelChange) then FOnSelChange(self, self.itemindex);
    if fHovering then UpdateHover;
  end;

  if (message.msg = LB_ADDSTRING) or
    (message.msg = WM_SIZE) or
    (message.msg = LB_INSERTSTRING) or
    (message.msg = LB_DELETESTRING) or
    (message.msg = LB_RESETCONTENT) then
  begin
{$IFDEF TMSDEBUG}
    case message.msg of
      LB_ADDSTRING: outputdebugstr('add ' + inttostr(message.result));
      LB_INSERTSTRING: outputdebugstr('insert ' + inttostr(message.wparam));
      LB_DELETESTRING: outputdebugstr('delete ' + inttostr(message.wparam));
      LB_RESETCONTENT: outputdebugstr('reset content');
    end;
{$ENDIF}

    if not FEditDisable and (FUpdateCount = 0) then
    begin
      {$IFNDEF TMSDOTNET}
      if (VisibleItems < self.Items.Count) then FlatShowScrollbar(SB_VERT, true);
      {$ENDIF}
      {$IFDEF TMSDOTNET}
      if (VisibleItems < self.Items.Count) then FlatSB_ShowScrollbar(Self.handle, SB_VERT, true);
      {$ENDIF}

      UpdateHScrollBar;
      UpdateVScrollBar;
      UpdateWidth;
      UpdateStyle;
      UpdateColor;
    end;

    {$IFNDEF TMSDOTNET}
    if (message.msg = LB_RESETCONTENT) then FlatShowScrollbar(SB_VERT, false);
    {$ENDIF}
    {$IFDEF TMSDOTNET}
    if (message.msg = LB_RESETCONTENT) then FlatSB_ShowScrollbar(Self.Handle, SB_VERT, false);
    {$ENDIF}

  end;
end;



procedure TEditListBox.SetIndexAndScroll(value: integer);
begin
  inherited ItemIndex := value;
  UpdateVScrollBar;
end;

function TEditListBox.GetStringExtent(s: string): integer;
var
  dwExtent: DWORD;
  hDCListBox: HDC;
  hFontOld, hFontNew: HFONT;
  tm: TTextMetric;
  Size: TSize;
begin
  hDCListBox := GetDC(Handle);
  hFontNew := SendMessage(Handle, WM_GETFONT, 0, 0);
  hFontOld := SelectObject(hDCListBox, hFontNew);
  GetTextMetrics(hDCListBox, tm);

  {$IFNDEF TMSDOTNET}
  GetTextExtentPoint32(hDCListBox, PChar(s), Length(s), Size);
  {$ENDIF}
  {$IFDEF TMSDOTNET}
  GetTextExtentPoint32(hDCListBox, s, Length(s), Size);
  {$ENDIF}

  dwExtent := Size.cx + tm.tmAveCharWidth;

  SelectObject(hDCListBox, hFontOld);
  ReleaseDC(Handle, hDCListBox);

  GetStringExtent := LOWORD(dwExtent);
end;

function TEditListBox.GetMaxStringExtent: integer;
var
  dwExtent: integer;
  hDCListBox: HDC;
  hFontOld, hFontNew: HFONT;
  tm: TTextMetric;
  Size: TSize;
  i, max: integer;
  d: array[0..MAX_TABS] of integer;

begin
  hDCListBox := GetDC(Handle);
  hFontNew := SendMessage(Handle, WM_GETFONT, 0, 0);
  hFontOld := SelectObject(hDCListBox, hFontNew);
  GetTextMetrics(hDCListBox, tm);

  max := 0;

{$IFDEF DELPHI3_LVL}
  if (fTabPositions.Count > 0) and (fTabPositions.Count < MAX_TABS) then
    for i := 0 to fTabPositions.Count - 1 do
    begin
      d[i] := (fTabPositions.Items[i] as TTabPositionItem).TabPosition;
    end;

  if fTabPositions.Count > 0 then
  begin
    for i := 0 to self.items.count - 1 do
    begin
      {$IFNDEF TMSDOTNET}
      dwExtent := loword(GetTabbedTextExtent(hdcListBox, PChar(items[i]), Length(items[i]), fTabPositions.Count, d));
      {$ENDIF}
      {$IFDEF TMSDOTNET}
      dwExtent := loword(GetTabbedTextExtent(hdcListBox, items[i], Length(items[i]), fTabPositions.Count, d));
      {$ENDIF}
      if dwExtent > max then max := dwExtent;
    end;
  end
  else
  begin
{$ENDIF}
    for i := 0 to self.items.count - 1 do
    begin
      {$IFNDEF TMSDOTNET}
      GetTextExtentPoint32(hDCListBox, PChar(items[i]), Length(items[i]), Size);
      {$ENDIF}
      {$IFDEF TMSDOTNET}
      GetTextExtentPoint32(hDCListBox, items[i], Length(items[i]), Size);
      {$ENDIF}
      dwExtent := Size.cx + tm.tmAveCharWidth;
      if dwExtent > max then max := dwExtent;
    end;
{$IFDEF DELPHI3_LVL}
  end;
{$ENDIF}

  SelectObject(hDCListBox, hFontOld);
  ReleaseDC(Handle, hDCListBox);
  fCacheExtent := max;
  result := max;
end;


procedure TEditListBox.UpdateStyle;
begin
  {$IFNDEF TMSDOTNET}
  case FScrollStyle of
    ssNormal: FlatSetScrollProp(WSB_PROP_VSTYLE, FSB_REGULAR_MODE, true);
    ssFlat: FlatSetScrollProp(WSB_PROP_VSTYLE, FSB_FLAT_MODE, true);
    ssEncarta: FlatSetScrollProp(WSB_PROP_VSTYLE, FSB_ENCARTA_MODE, true);
  end;
  case FScrollStyle of
    ssNormal: FlatSetScrollProp(WSB_PROP_HSTYLE, FSB_REGULAR_MODE, true);
    ssFlat: FlatSetScrollProp(WSB_PROP_HSTYLE, FSB_FLAT_MODE, true);
    ssEncarta: FlatSetScrollProp(WSB_PROP_HSTYLE, FSB_ENCARTA_MODE, true);
  end;
  {$ENDIF}
  {$IFDEF TMSDOTNET}
  case FScrollStyle of
    ssNormal: FlatSB_SetScrollProp(self.handle, WSB_PROP_VSTYLE, FSB_REGULAR_MODE, true);
    ssFlat: FlatSB_SetScrollProp(self.handle, WSB_PROP_VSTYLE, FSB_FLAT_MODE, true);
    ssEncarta: FlatSB_SetScrollProp(self.Handle, WSB_PROP_VSTYLE, FSB_ENCARTA_MODE, true);
  end;
  case FScrollStyle of
    ssNormal: FlatSB_SetScrollProp(self.handle, WSB_PROP_HSTYLE, FSB_REGULAR_MODE, true);
    ssFlat: FlatSB_SetScrollProp(self.handle, WSB_PROP_HSTYLE, FSB_FLAT_MODE, true);
    ssEncarta: FlatSB_SetScrollProp(self.handle, WSB_PROP_HSTYLE, FSB_ENCARTA_MODE, true);
  end;
  {$ENDIF}

end;

procedure TEditListBox.UpdateColor;
begin
  {$IFNDEF TMSDOTNET}
  FlatSetScrollPROP(WSB_PROP_VBKGCOLOR, longint(fScrollColor), true);
  FlatSetScrollPROP(WSB_PROP_HBKGCOLOR, longint(fScrollColor), true);
  {$ENDIF}
  {$IFDEF TMSDOTNET}
  FlatSB_SetScrollPROP(Self.handle, WSB_PROP_VBKGCOLOR, longint(fScrollColor), true);
  FlatSB_SetScrollPROP(Self.Handle, WSB_PROP_HBKGCOLOR, longint(fScrollColor), true);
  {$ENDIF}
end;

procedure TEditListBox.UpdateWidth;
begin
  {$IFNDEF TMSDOTNET}
  FlatSetScrollPROP(WSB_PROP_CXVSCROLL, fScrollWidth, true);
  FlatSetScrollPROP(WSB_PROP_CYHSCROLL, fScrollWidth, true);
  {$ENDIF}
  {$IFDEF TMSDOTNET}
  FlatSB_SetScrollPROP(Self.handle, WSB_PROP_VBKGCOLOR, longint(fScrollColor), true);
  FlatSB_SetScrollPROP(Self.handle, WSB_PROP_HBKGCOLOR, longint(fScrollColor), true);
  {$ENDIF}
end;

procedure TEditListBox.UpdateVScrollBar;
var
  scrollinfo: tscrollinfo;
begin
  scrollinfo.fMask := SIF_ALL;
  scrollinfo.cbSize := sizeof(scrollinfo);
  GetScrollInfo(self.handle, SB_VERT, scrollinfo);
  scrollinfo.fMask := SIF_ALL;
  scrollinfo.cbSize := sizeof(scrollinfo);
  {$IFNDEF TMSDOTNET}
  FlatSetScrollInfo(SB_VERT, scrollinfo, true);
  {$ENDIF}
  {$IFDEF TMSDOTNET}
  FlatSB_SetScrollInfo(self.handle, SB_VERT, scrollinfo, true);
  {$ENDIF}
end;

procedure TEditListBox.UpdateHScrollBar;
var
  scrollinfo: tscrollinfo;
begin
  UpdateHScrollExtent;
  scrollinfo.fMask := SIF_ALL;
  scrollinfo.cbSize := sizeof(scrollinfo);
  GetScrollInfo(self.handle, SB_HORZ, scrollinfo);
  scrollinfo.fMask := SIF_ALL;
  scrollinfo.cbSize := sizeof(scrollinfo);
  {$IFNDEF TMSDOTNET}
  FlatSetScrollInfo(SB_HORZ, scrollinfo, true);
  {$ENDIF}
  {$IFDEF TMSDOTNET}
  FlatSB_SetScrollInfo(self.handle, SB_HORZ, scrollinfo, true);
  {$ENDIF}
end;

procedure TEditListBox.UpdateHScrollExtent;
var
  max, w: integer;
  r: trect;

begin
  if (fUpdateCount > 0) then exit;

  if (self.items.count <= 0) or (fScrollHorizontal = false) then
  begin
    SendMessage(Handle, LB_SETHORIZONTALEXTENT, 0, 0);
    SendMessage(Handle, WM_HSCROLL, SB_TOP, 0);
    ShowScrollBar(self.Handle, SB_HORZ, false);
    Exit;
  end;

  max := GetMaxStringExtent;

  r := getclientrect;
  w := r.right - r.left;

  if (max > w) then
  begin
    {$IFNDEF TMSDOTNET}
    FlatShowScrollBar(SB_HORZ, true);
    {$ENDIF}
    {$IFDEF TMSDOTNET}
    FlatSB_ShowScrollBar(Self.Handle, SB_HORZ, true);
    {$ENDIF}
    SendMessage(Handle, LB_SETHORIZONTALEXTENT, Max, 0);
  end
  else
  begin
    SendMessage(Handle, LB_SETHORIZONTALEXTENT, 0, 0);
    SendMessage(Handle, WM_HSCROLL, SB_TOP, 0);
    ShowScrollBar(Handle, SB_HORZ, false);
    {$IFNDEF TMSDOTNET}
    FlatShowScrollBar(SB_HORZ, false);
    {$ENDIF}
    {$IFDEF TMSDOTNET}
    FlatSB_ShowScrollBar(Self.handle, SB_HORZ, false);
    {$ENDIF}
  end;
end;

{$IFNDEF TMSDOTNET}
procedure TEditListBox.FlatSetScrollPos(code, pos: integer; fRedraw: bool);
var
  ComCtl32DLL: THandle;
  _FlatSB_SetScrollPos: function(wnd: hwnd; code, pos: integer; fRedraw: bool): integer; stdcall;

begin
  ComCtl32DLL := GetModuleHandle(commctrl);
  if (ComCtl32DLL > 0) then
  begin
    @_FlatSB_SetScrollPos := GetProcAddress(ComCtl32DLL, 'FlatSB_SetScrollPos');
    if assigned(_FlatSB_SetScrollPos) then
      _FlatSB_SetScrollPos(self.handle, code, pos, fRedraw);
  end;
end;
{$ENDIF}

{$IFNDEF TMSDOTNET}
procedure TEditListBox.FlatSetScrollInfo(code: integer; var scrollinfo: tscrollinfo; fRedraw: bool);
var
  ComCtl32DLL: THandle;
  _FlatSB_SetScrollInfo: function(wnd: hwnd; code: integer; var scrollinfo: tscrollinfo; fRedraw: bool): integer; stdcall;

begin
  ComCtl32DLL := GetModuleHandle(commctrl);
  if (ComCtl32DLL > 0) then
  begin
    @_FlatSB_SetScrollInfo := GetProcAddress(ComCtl32DLL, 'FlatSB_SetScrollInfo');
    if assigned(_FlatSB_SetScrollInfo) then
    begin
      _FlatSB_SetScrollInfo(self.handle, code, scrollinfo, fRedraw);
    end;
  end;
end;
{$ENDIF}

{$IFNDEF TMSDOTNET}
procedure TEditListBox.FlatSetScrollProp(index, newValue: integer;
  fRedraw: bool);
var
  ComCtl32DLL: THandle;
  _FlatSB_SetScrollProp: function(wnd: hwnd; Index, newValue: integer; fredraw: bool): bool stdcall;

begin
  ComCtl32DLL := GetModuleHandle(commctrl);
  if (ComCtl32DLL > 0) then
  begin
    @_FlatSB_SetScrollProp := GetProcAddress(ComCtl32DLL, 'FlatSB_SetScrollProp');
    if assigned(_FlatSB_SetScrollProp) then
      _FlatSB_SetScrollProp(self.handle, index, newValue, fRedraw);
  end;
end;
{$ENDIF}

{$IFNDEF TMSDOTNET}
procedure TEditListBox.FlatShowScrollBar(code: integer; show: bool);
var
  ComCtl32DLL: THandle;
  _FlatSB_ShowScrollBar: function(wnd: hwnd; code: integer; show: bool): integer; stdcall;

begin
  ComCtl32DLL := GetModuleHandle(commctrl);
  if (ComCtl32DLL > 0) then
  begin
    @_FlatSB_ShowScrollBar := GetProcAddress(ComCtl32DLL, 'FlatSB_ShowScrollBar');
    if assigned(_FlatSB_ShowScrollBar) then
      _FlatSB_ShowScrollBar(self.handle, code, show);
  end;
end;
{$ENDIF}

{$IFNDEF TMSDOTNET}
procedure TEditListBox.SetScrollStyle(const Value: TScrollStyle);
var
  ComCtl32DLL: THandle;
  _InitializeFlatSB: function(wnd: hwnd): Bool stdcall;
  _UnInitializeFlatSB: function(wnd: hwnd): Bool stdcall;

begin
  if (Value in [ssEncarta, ssFlat]) and
    (FScrollStyle = ssNormal) then
  begin
    ComCtl32DLL := GetModuleHandle(commctrl);
    if (ComCtl32DLL > 0) then
    begin
      @_InitializeFlatSB := GetProcAddress(ComCtl32DLL, 'InitializeFlatSB');
      if assigned(_InitializeFlatSB) then
      begin
        _InitializeFlatSB(self.Handle);
      end;
    end;
  end;

  if (value = ssNormal) and
    (FScrollStyle in [ssEncarta, ssFlat]) then
  begin
    ComCtl32DLL := GetModuleHandle(commctrl);
    if (ComCtl32DLL > 0) then
    begin
      @_UnInitializeFlatSB := GetProcAddress(ComCtl32DLL, 'UnInitializeFlatSB');
      if assigned(_UnInitializeFlatSB) then
      begin
        _UnInitializeFlatSB(self.handle);
      end;
    end;
  end;

  FScrollStyle := Value;
  UpdateStyle;
end;
{$ENDIF}

{$IFDEF TMSDOTNET}
procedure TEditListBox.SetScrollStyle(const Value: TScrollStyle);
begin
  if (Value in [ssEncarta, ssFlat]) and
    (FScrollStyle = ssNormal) then
  begin
    InitializeFlatSB(self.handle);
  end;

  if (value = ssNormal) and
    (FScrollStyle in [ssEncarta, ssFlat]) then
  begin
    UnInitializeFlatSB(Self.Handle);
  end;

  FScrollStyle := Value;
  UpdateStyle;
end;
{$ENDIF}


procedure TEditListBox.SetScrollColor(const Value: TColor);
begin
  FScrollColor := Value;
  UpdateColor;
end;

procedure TEditListBox.SetScrollWidth(const Value: integer);
begin
  FScrollWidth := Value;
  UpdateWidth;
end;

procedure TEditListBox.SetScrollHorizontal(const Value: boolean);
begin
  FScrollHorizontal := Value;
  UpdateHScrollBar;
end;

function TEditListBox.VisibleItems: integer;
var
  hght: integer;
begin
  hght := sendmessage(self.handle, lb_getitemheight, 0, 0);
  VisibleItems := self.height div hght;
end;

procedure TEditListBox.Lookup;
var
  i: integer;
  found: boolean;
begin
  if self.items.count <= 0 then exit;
  if not fLookupIncr then exit;

  found := false;
  for i := 0 to self.items.count - 1 do
    if (pos(fLookupString, uppercase(self.items[i])) = 1) then
    begin
      self.itemindex := i;
      found := true;
      break;
    end;

  if not found and fLookupFull then
  begin
    for i := 0 to self.items.count - 1 do
      if (pos(fLookupString, uppercase(self.items[i])) > 0) then
      begin
        self.itemindex := i;
        found := true;
        break;
      end;
  end;

  if not found then fLookupString := '';
end;

{$IFDEF DELPHI3_LVL}

procedure TEditListBox.OptimizeTabs(padding: integer);
var
  max: array[0..MAX_TABS] of integer;
  i, j, k, l, t: integer;
  s, su: string;

begin
  for i := 0 to MAX_TABS do max[i] := 0;
  l := 0;
  for i := 1 to self.items.count do
  begin
    s := self.items[i - 1];
    j := 0;
    while (pos(#9, s) > 0) and (j < MAX_TABS) do
    begin
      su := copy(s, 1, pos(#9, s) - 1);
      k := canvas.textwidth(su);
      if (k > max[j]) then max[j] := k;
      delete(s, 1, pos(#9, s));
      inc(j);
      if (j > l) then l := j;
    end;
    k := canvas.textwidth(s);
    if (k > max[j]) then max[j] := k;
  end;

  if (items.count > 0) then
  begin
    t := padding;
    for i := 1 to l do
    begin
      if (self.tabpositions.count >= i) then
      begin
        if ((self.tabpositions.items[i - 1] as TTabPositionItem).TabType = tabright) then
          (self.tabpositions.items[i - 1] as TTabPositionItem).TabPosition := t + max[i - 1] + max[i]
        else
          (self.tabpositions.items[i - 1] as TTabPositionItem).TabPosition := t + max[i - 1];
      end
      else
        (self.tabpositions.add as TTabPositionItem).TabPosition := t + max[i - 1];

      t := t + max[i - 1] + padding;
    end;
  end;
  self.repaint;
end;
{$ENDIF}

procedure TEditListBox.BeginUpdate;
begin
  inc(fUpdateCount);
end;

procedure TEditListBox.EndUpdate;
begin
  if (fUpdateCount > 0) then
  begin
    dec(fUpdateCount);
    if fUpdateCount = 0 then UpdateHScrollBar;
  end;

  if (ScrollStyle <> ssNormal) then
  begin
    {$IFNDEF TMSDOTNET}
    if (VisibleItems < self.Items.Count) then FlatShowScrollbar(SB_VERT, true);
    {$ENDIF}
    {$IFDEF TMSDOTNET}
    if (VisibleItems < self.Items.Count) then FlatSB_ShowScrollbar(Self.handle, SB_VERT, true);
    {$ENDIF}
  end;

end;

{$IFNDEF TMSDOTNET}
procedure TEditListBox.CMHintShow(var Msg: TMessage);
{$IFNDEF DELPHI3_LVL}
type
  PHintInfo = ^THintInfo;
{$ENDIF}
var
  CanShow: Boolean;
  hi: PHintInfo;
{$IFNDEF DELPHI3_LVL}
  s: string;
{$ENDIF}

begin
  CanShow := True;
  hi := PHintInfo(Msg.LParam);
  ShowHint(hi.HintStr, CanShow, hi^);

  Msg.Result := Ord(not CanShow);
end;
{$ENDIF}

{$IFDEF TMSDOTNET}
procedure TEditListBox.CMHintShow(var Message: TCMHintShow);
var
  CanShow: Boolean;
  hi: THintInfo;
{$IFNDEF DELPHI3_LVL}
  s: string;
{$ENDIF}

begin
  CanShow := True;
  hi := Message.HintInfo;
  ShowHint(hi.HintStr, CanShow, hi);

  Message.Result := Ord(not CanShow);
end;
{$ENDIF}

procedure TEditListBox.ShowHint(var HintStr: string; var CanShow: Boolean; var HintInfo: THintInfo);
var
  hintpos: tpoint;
  idx: integer;

begin
  if (Hintinfo.Hintcontrol = self) then
  begin
    Hintinfo.Hintcolor := FHintColor;

    {search over which thing mouse is}
    with (hintinfo.HintControl as tlistbox) do
    begin
      idx := sendmessage(self.handle, lb_itemfrompoint, 0, makelparam(hintinfo.cursorpos.x, hintinfo.cursorpos.y));

      if (idx < items.count) then
      begin
        flasthintpos.y := idx - SendMessage(Handle,LB_GETTOPINDEX,0,0);
        flasthintpos.x := 0;

        if GetStringExtent(items[idx]) > self.width - scrollwidth then
        begin
          hintstr := items[idx];
          hintpos.x := 0;
          hintpos.y := (idx - SendMessage(Handle,LB_GETTOPINDEX,0,0)) * itemheight - 2;
          hintinfo.hintpos := self.clienttoscreen(hintpos);
        end
        else
          hintstr := self.Hint;
      end
      else
        hintstr := self.Hint;
    end;
  end;
end;


procedure TEditListBox.MouseMove(Shift: TShiftState; X, Y: Integer);
var
  idx: integer;
begin
  if (FLastHintPos.y >= 0) then
  begin
    idx := y div itemheight;
    if (idx <> FLastHintPos.y) then
    begin
      Application.CancelHint;
      FLastHintPos := Point(-1, -1);
    end;
  end;
  inherited MouseMove(Shift, X, Y);
end;

function TEditListBox.GetVersion: string;
var
  vn: Integer;
begin
  vn := GetVersionNr;
  Result := IntToStr(Hi(Hiword(vn)))+'.'+IntToStr(Lo(Hiword(vn)))+'.'+IntToStr(Hi(Loword(vn)))+'.'+IntToStr(Lo(Loword(vn)));
end;

function TEditListBox.GetVersionNr: Integer;
begin
  Result := MakeLong(MakeWord(BLD_VER,REL_VER),MakeWord(MIN_VER,MAJ_VER));
end;

procedure TEditListBox.SetVersion(const Value: string);
begin

end;



{$IFDEF DELPHI3_LVL}

{ TTabPositionCollection }

constructor TTabPositionCollection.Create(aOwner: TEditListBox);
begin
  inherited Create(TTabPositionItem);
  fOwner := aOwner;
end;

function TTabPositionCollection.GetOwner: tPersistent;
begin
  result := fOwner;
end;

{ TTabPositionItem }

procedure TTabPositionItem.SetTabPosition(value: integer);
begin
  fTabPosition := value;
 {reflect this to the control}
  ((collection as TTabPositionCollection).fOwner as TEditListBox).SetTabStops;
  ((collection as TTabPositionCollection).fOwner as TEditListBox).UpdateHScrollBar;
  (collection as TTabPositionCollection).fOwner.Repaint;
end;

procedure TTabPositionItem.SetTabType(value: tTabType);
begin
  fTabType := value;
  ((collection as TTabPositionCollection).fOwner as TEditListBox).SetTabStops;
  ((collection as TTabPositionCollection).fOwner as TEditListBox).UpdateHScrollBar;
  (collection as TTabPositionCollection).fOwner.Repaint;
end;



{$ENDIF}



end.
