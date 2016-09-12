{*************************************************************************}
{ THTMLTreeList component                                                 }
{ for Delphi & C++Builder                                                 }
{                                                                         }
{ written by TMS Software                                                 }
{           copyright © 2000 - 2010                                       }
{           Email : info@tmssoftware.com                                  }
{           Web : http://www.tmssoftware.com                              }
{                                                                         }
{ The source code is given as is. The author is not responsible           }
{ for any possible damage done due to the use of this code.               }
{ The component can be freely used in any application. The complete       }
{ source code remains property of the author and may not be distributed,  }
{ published, given or sold in any form as such. No parts of the source    }
{ code can be included in any other component or application without      }
{ written authorization of the author.                                    }
{*************************************************************************}

unit HTMLTreeList;

{$I TMSDEFS.INC}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Clipbrd, Mask, ComCtrls, ExtCtrls, PictureContainer, ImgList,
  AdvStyleIF, AdvGradient
  {$IFNDEF TMSDOTNET}
  , CommCtrl
  {$ENDIF}
  {$IFDEF TMSDOTNET}
  , Borland.Vcl.WinUtils, Types, Borland.Vcl.commCtrl, System.Runtime.InteropServices
  {$ENDIF}
  ;

const
  MAJ_VER = 1; // Major version nr.
  MIN_VER = 2; // Minor version nr.
  REL_VER = 1; // Release nr.
  BLD_VER = 0; // Build nr.

  // version history
  // v1.0.0.0 : First release
  // v1.0.0.1 : Fixed issue with HotTrack display
  // v1.0.0.2 : Fixed painting issue when updating nodes
  // v1.0.0.3 : Fixed issue with VCL.NET
  // v1.0.0.4 : Fixed issue with bordersize of header
  // v1.0.0.5 : Fixed painting issue on double click

  // v1.1.0.0 : New : SelectionColors property added, Office2007, Windows Vista, Windows 7 color styles
  //          : New : TAdvFormStyler / ITMSStyle interface compatible
  //          : Improved : DFM property persistence
  // v1.1.0.1 : Fixed : issue with header painting during horizontal scroll
  // v1.1.0.2 : Fixed : issue with GetNodeColumn() to get last column value
  // v1.1.1.0 : New : support for customizing bullets in HTML UL lists
  // v1.2.0.0 : New : Built in support for Office 2010 colors
  // v1.2.1.0 : Improved : vertical centering of HTML text


type
  {$IFDEF DELPHI_UNICODE}
  THintInfo = Controls.THintInfo;
  PHintInfo = Controls.PHintInfo;
  {$ENDIF}
  
  TAnchorEvent = procedure(Sender: TObject; Node: TTreeNode; anchor: string) of object;

  THTMLTreeList = class;

  TColumnItem = class(TCollectionItem)
  private
    FWidth: integer;
    FColumnHeader: string;
    FFont: TFont;
    procedure SetWidth(const value: integer);
    procedure SetColumnHeader(const value: string);
    procedure SetFont(const value: TFont);
  public
    constructor Create(Collection: TCollection); override;
    destructor Destroy; override;
    procedure Assign(source: TPersistent); override;
  published
    property Width: integer read fWidth write SetWidth;
    property Header: string read fColumnHeader write SetColumnHeader;
    property Font: TFont read fFont write SetFont;
  end;

  TColumnCollection = class(TCollection)
  private
    FOwner: THTMLTreeList;
    function GetItem(Index: Integer): TColumnItem;
    procedure SetItem(Index: Integer; const Value: TColumnItem);
  protected
    procedure Update(Item: TCollectionItem); override;
  public
    constructor Create(aOwner: THTMLTreeList);
    function GetOwner: tPersistent; override;
    function Add: TColumnItem;
    function Insert(Index: Integer): TColumnItem;
    property Items[Index: Integer]: TColumnItem read GetItem write SetItem; default;
  end;


  TTLHeaderClickEvent = procedure(Sender: TObject; SectionIdx: integer) of object;

  TTLHeader = class(THeader)
  private
    FColor: tColor;
    FOnClick: TTLHeaderClickEvent;
    FOnRightClick: TTLHeaderClickEvent;
    procedure WMLButtonDown(var Message: TWMLButtonDown); message WM_LBUTTONDOWN;
    procedure WMRButtonDown(var Message: TWMLButtonDown); message WM_RBUTTONDOWN;
    procedure SetColor(const Value: TColor);
  public
    constructor Create(aOwner: TComponent); override;
  protected
    procedure Paint; override;
  published
    property Color: TColor read fColor write SetColor;
    property OnClick: TTLHeaderClickEvent read fOnClick write fOnClick;
    property OnRightClick: TTLHeaderClickEvent read fOnRightClick write fOnRightClick;
  end;

  THeaderSettings = class(TPersistent)
  private
    FOwner: THTMLTreeList;
    FHeight: integer;
    FFont : TFont;
    FColor: TColor;
    FColorTo: TColor;
    FOnChange: TNotifyEvent;
    FFlat: Boolean;
    FAllowResize: Boolean;
    procedure SetFont(const Value: TFont);
    procedure SetFlat(const Value: boolean);
    procedure SetAllowResize(const Value: boolean);
    procedure SetColor(const Value: TColor);
    procedure SetHeight(const Value: integer);
    procedure FontChanged(Sender: TObject);
    procedure SetColorTo(const Value: TColor);
  protected
    procedure Changed;
  public
    constructor Create(aOwner: THTMLTreeList);
    destructor Destroy; override;
  published
    property AllowResize: boolean read FAllowResize write SetAllowResize default true;
    property Color: TColor read FColor write SetColor default clBtnFace;
    property ColorTo: TColor read FColorTo write SetColorTo default clNone;
    property Flat: boolean read FFlat write SetFlat default false;
    property Font: TFont read FFont write SetFont;
    property Height: integer read FHeight write SetHeight default 18;
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
  end;

  THTMLTreeList = class(TTreeview, ITMSStyle)
  private
  { Private declarations }
    FAnchorHint: boolean;
    FHeader: TTLHeader;
    FHeaderSettings: THeaderSettings;
    FFlatHeader: boolean;
    FColumnCollection: TColumnCollection;
    FColumnLines: boolean;
    FColumnSpace: integer;
    FOldScrollPos: integer;
    FSeparator: string;
    FItemHeight: integer;
    FOldCursor: tCursor;
    FOldAnchor: string;
    FURLColor: TColor;
    FImages: TImageList;
    FOnClick: TTLHeaderClickEvent;
    FOnRightClick: TTLHeaderClickEvent;
    FOnAnchorClick: TAnchorEvent;
    FOnAnchorEnter: TAnchorEvent;
    FOnAnchorExit: TAnchorEvent;
    FSelectionFontColor: tcolor;
    FSelectionColors: TGradientStyle;
    procedure WMHScroll(var message: TMessage); message WM_HSCROLL;
    procedure WMMouseMove(var message: TWMMouseMove); message WM_MOUSEMOVE;
    procedure WMLButtonDown(var message: TWMLButtonDown); message WM_LBUTTONDOWN;
    procedure WMRButtonDown(var message: TWMLButtonDown); message WM_RBUTTONDOWN;
    procedure WMLButtonDblClk(var Message: TWMLButtonDblClk); message WM_LBUTTONDBLCLK;
    procedure WMPaint(var message: TWMPaint); message WM_PAINT;
    {$IFNDEF TMSDOTNET}
    procedure CNNotify(var message: TWMNotify); message CN_NOTIFY;
    procedure CMHintShow(var Msg: TMessage); message CM_HINTSHOW;
    {$ENDIF}
    {$IFDEF TMSDOTNET}
    procedure CNNotify(var message: TWMNotifyTV); message CN_NOTIFY;
    procedure CMHintShow(var Message: TCMHintShow); message CM_HINTSHOW;
    {$ENDIF}
    procedure SetColumnCollection(const Value: TColumnCollection);
    procedure SetColumnLines(const Value: boolean);
    procedure UpdateColumns;
    procedure SectionSize(sender: TObject; ASection, AWidth: integer);
    procedure HeaderClick(sender: TObject; ASection: integer); procedure HeaderRightClick(sender: TObject; ASection: integer);
    function GetColWidth(idx: integer): integer;
    function GetColFont(idx: integer): TFont;
    procedure SetSeparator(const Value: string);
    function GetItemHeight: integer;
    procedure SetItemHeight(const Value: integer);
    function GetVisible: boolean;
    procedure SetVisible(const Value: boolean);
    function IsAnchor(node: ttreenode; x, y: integer): string;
    procedure SetURLColor(const value: TColor);
    procedure SetImages(const value: TImageList);
    procedure SetSelectionFontColor(const Value: tcolor);
    function GetColumnText(col: integer; s: string): string;
    function GetVersion: string;
    procedure SetVersion(const Value: string);
    function GetVersionNr: Integer;
    procedure SetSelectionColors(const Value: TGradientStyle);
    procedure HeaderChanged(Sender: TObject);
  protected
  { Protected declarations }
    {$IFDEF TMSDOTNET}
    procedure Loaded; override;
    {$ENDIF}
    procedure Expand(Node: TTreeNode); override;
    procedure Notification(AComponent: TComponent; AOperation: TOperation); override;
    procedure CreateWnd; override;
    procedure DestroyWnd; override;
    function GetClientRect: TRect; override;
{$IFDEF DELPHI4_LVL}
    property ToolTips;
{$ENDIF}
  public
  { Public declarations }
    constructor Create(aOwner: TComponent); override;
    destructor Destroy; override;
    procedure SetBounds(ALeft, ATop, AWidth, AHeight: Integer); override;
    procedure SetNodeColumn(tn: TTreeNode; idx: integer; value: string);
    function GetNodeColumn(tn: TTreeNode; idx: integer): string;
    procedure SetComponentStyle(AStyle: TTMSStyle);
  published
  { Pubished declarations }
    property AnchorHint: boolean read FAnchorHint write FAnchorHint default False;
    property Columns: TColumnCollection read FColumnCollection write SetColumnCollection;
    property ColumnLines: boolean read FColumnLines write SetColumnLines default true;
    property Separator: string read FSeparator write SetSeparator;
    property ItemHeight: integer read GetItemHeight write SetItemHeight;
    property Visible: boolean read GetVisible write SetVisible default true;
    property HeaderSettings: THeaderSettings read FHeaderSettings write FHeaderSettings;
    property HTMLImages: TImageList read fImages write SetImages;
    property SelectionColors: TGradientStyle read FSelectionColors write SetSelectionColors;
    property SelectionFontColor: tcolor read fSelectionFontColor write SetSelectionFontColor default clHighlightText;
    property URLColor: TColor read fURLColor write SetURLColor default clBlue;
    property OnHeaderClick: TTLHeaderClickEvent read fOnClick write FOnClick;
    property OnHeaderRightClick: TTLHeaderClickEvent read fOnRightClick write FOnRightClick;
    property OnAnchorClick: TAnchorEvent read FOnAnchorClick write FOnAnchorClick;
    property OnAnchorEnter: TAnchorEvent read FOnAnchorEnter write FOnAnchorEnter;
    property OnAnchorExit: TAnchorEvent read FOnAnchorExit write fOnAnchorExit;
    property Version: string read GetVersion write SetVersion;
  end;

{$IFDEF VER100}
const
  NM_CUSTOMDRAW = NM_FIRST - 12;

  CDDS_PREPAINT = $00000001;
  CDDS_POSTPAINT = $00000002;
  CDDS_PREERASE = $00000003;
  CDDS_POSTERASE = $00000004;
  CDDS_ITEM = $00010000;
  CDDS_ITEMPREPAINT = CDDS_ITEM or CDDS_PREPAINT;
  CDDS_ITEMPOSTPAINT = CDDS_ITEM or CDDS_POSTPAINT;
  CDDS_ITEMPREERASE = CDDS_ITEM or CDDS_PREERASE;
  CDDS_ITEMPOSTERASE = CDDS_ITEM or CDDS_POSTERASE;
  CDDS_SUBITEM = $00020000;

  // itemState flags
  CDIS_SELECTED = $0001;
  CDIS_GRAYED = $0002;
  CDIS_DISABLED = $0004;
  CDIS_CHECKED = $0008;
  CDIS_FOCUS = $0010;
  CDIS_DEFAULT = $0020;
  CDIS_HOT = $0040;
  CDIS_MARKED = $0080;
  CDIS_INDETERMINATE = $0100;

  CDRF_DODEFAULT = $00000000;
  CDRF_NEWFONT = $00000002;
  CDRF_SKIPDEFAULT = $00000004;
  CDRF_NOTIFYPOSTPAINT = $00000010;
  CDRF_NOTIFYITEMDRAW = $00000020;
  CDRF_NOTIFYSUBITEMDRAW = $00000020; // flags are the same, we can distinguish by context
  CDRF_NOTIFYPOSTERASE = $00000040;

  TVM_GETITEMHEIGHT = TV_FIRST + 28;
  TVM_SETITEMHEIGHT = TV_FIRST + 27;

type
  tagNMCUSTOMDRAWINFO = packed record
    hdr: TNMHdr;
    dwDrawStage: DWORD;
    hdc: HDC;
    rc: TRect;
    dwItemSpec: DWORD; // this is control specific, but it's how to specify an item.  valid only with CDDS_ITEM bit set
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

uses
  ShellApi;

{$I HTMLENGO.PAS}

{ TColumnItem }

constructor TColumnItem.Create(Collection: TCollection);
begin
  inherited;
  FWidth := 50;
  FFont := TFont.Create;
  FFont.Assign((TColumnCollection(Collection).fOwner).Font);
end;

destructor TColumnItem.Destroy;
begin

  FFont.Free;
  inherited Destroy;
end;

procedure TColumnItem.SetWidth(const value: integer);
begin
  fWidth := value;
  TColumnCollection(Collection).Update(self);
end;

procedure TColumnItem.SetColumnHeader(const value: string);
begin
  fColumnHeader := value;
  TColumnCollection(Collection).Update(self);
end;

procedure TColumnItem.SetFont(const value: TFont);
begin
  fFont.Assign(value);
  TColumnCollection(Collection).Update(self);
end;


procedure TColumnItem.Assign(source: TPersistent);
begin
  if Source is TColumnItem then
  begin
    Width := TColumnItem(Source).Width;
    Header := TColumnItem(Source).Header;
    Font.Assign(TColumnItem(Source).Font);
  end
  else inherited Assign(Source);
end;

{ TColumnCollection }

function TColumnCollection.Add: TColumnItem;
begin
  Result := TColumnItem(inherited Add);
end;

constructor TColumnCollection.Create(aOwner: THTMLTreeList);
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

{$IFDEF DELPHI4_LVL}
function TColumnCollection.Insert(Index: Integer): TColumnItem;
begin
  Result := TColumnItem(inherited Insert(Index));
end;
{$ENDIF}

procedure TColumnCollection.SetItem(Index: Integer;
  const Value: TColumnItem);
begin
  Items[Index] := Value;
end;

procedure TColumnCollection.Update(Item: TCollectionItem);
begin
  inherited Update(Item);
  {reflect changes}
  FOwner.UpdateColumns;
end;

{ TTLHeader }

procedure TTLHeader.WMLButtonDown(var Message: TWMLButtonDown);
var
  x, i: integer;
begin
  inherited;
  x := 0;
  i := 0;
  while (x < message.xpos) and (i < sections.Count) do
  begin
    x := x + sectionwidth[i];
    inc(i);
  end;
  dec(i);
  if assigned(fOnClick) then fOnClick(self, i);
end;

procedure TTLHeader.WMRButtonDown(var Message: TWMLButtonDown);
var
  x, i: integer;
begin
  inherited;
  
  x := 0;
  i := 0;
  
  while (x < message.xpos) and (i < sections.Count) do
  begin
    x := x + sectionwidth[i];
    inc(i);
  end;
  dec(i);
  
  if assigned(FOnRightClick) then
    FOnRightClick(self, i);
end;

procedure TTLHeader.Paint;
var
  I, W: Integer;
  S: string;
  R: TRect;
  PR: TRect;
  anchor, stripped: string;
  xsize, ysize: integer;
  urlcol: tcolor;
  imagelist: TImageList;

  hyperlinks,mouselink: integer;
  focusanchor: string;
  re: TRect;
  clr,clrto: TColor;

begin
  with Canvas do
  begin
    Font := Self.Font;
    Brush.Color := fColor;
    I := 0;
    R := Rect(0, 0, 0, ClientHeight);
    W := 0;
    S := '';

    R.Right := R.Right - GetScrollPos((Owner as THTMLTreeList).Handle, SB_HORZ);

    with Owner as THTMLTreeList do
    begin
      urlcol := URLColor;
      imagelist := HTMLImages;
      clr := HeaderSettings.Color;
      clrto := HeaderSettings.ColorTo;
    end;

    repeat

      if I < Sections.Count then
      begin
        W := SectionWidth[i];

        if (i < Sections.Count) then
          S := Sections[i]
        else
          s := Sections[0];

        if (i = 0) and (BorderStyle = bsNone) then
          inc(w);

        Inc(I);
      end;

      R.Left := R.Right;

      Inc(R.Right, W);

      if (ClientWidth - R.Right < 2) or (I = Sections.Count) then
        R.Right := ClientWidth;

      pr := r;

      if clrto <> clNone then
      begin
        DrawGradient(Canvas,clr,clrto,16,r,false);
      end
      else
        FillRect(r);

      InflateRect(pr, -2, -2);

      HTMLDrawEx(Canvas, s, pr, imagelist, 0, 0, -1,-1,1,False, False, false, false, false, false, true, 1.0, URLCol,
        clNone, clNone, clGray, anchor, stripped, focusanchor, xsize, ysize, hyperlinks, mouselink, re,
        nil, nil,0);

      DrawEdge(Canvas.Handle, R, BDR_RAISEDINNER, BF_TOPLEFT);
      DrawEdge(Canvas.Handle, R, BDR_RAISEDINNER, BF_BOTTOMRight);

    until R.Right = ClientWidth;

  end;
  
end;

constructor TTLHeader.Create(aOwner: TComponent);
begin
  inherited;
  fColor := clBtnFace;
end;

procedure TTLHeader.SetColor(const Value: TColor);
begin
  fColor := Value;
  invalidate;
end;

{ THTMLTreeList }

constructor THTMLTreeList.Create(aOwner: TComponent);
begin
  inherited Create(aOwner);
  FHeader := nil;
  Tooltips := false;
  FColumnCollection := TColumnCollection.Create(self);
  FHeaderSettings := THeaderSettings.Create(self);
  FHeaderSettings.OnChange := HeaderChanged;
  FSeparator := ';';
  FItemHeight := 16;
  FColumnLines := true;
  FColumnSpace := 2;
  FOldScrollPos := -1;
  FHeader := nil;
  FURLColor := clBlue;
  FSelectionColors := TGradientStyle.Create;
  FSelectionFontColor := clHighLightText;
  DoubleBuffered := true;
end;

{$IFDEF TMSDOTNET}
procedure THTMLTreeList.Loaded;
begin
  UpdateColumns;
end;
{$ENDIF}

procedure THTMLTreeList.CreateWnd;
const
  hdr: array[boolean] of TBorderStyle = (bsSingle, bsNone);
begin
  inherited CreateWnd;

  if not Assigned(fHeader) then
  begin
    FHeader := TTLHeader.Create(self);
    FHeader.top := Top - 16;
    FHeader.left := Left;
    FHeader.Width := Width - 1;
    FHeader.Height := 18;
    Fheader.borderstyle := hdr[fFlatHeader];
    FHeader.OnSized := SectionSize;
    FHeader.OnClick := HeaderClick;
    FHeader.OnRightClick := HeaderRightClick;
  end;

  FHeader.Parent := Parent;
  ItemHeight := FItemHeight;
end;

procedure THTMLTreeList.SectionSize(sender: TObject; ASection, AWidth: integer);
var
  fIndent: integer;
begin
  FIndent := TreeView_GetIndent(self.handle);
  if Assigned(Images) then
    FIndent := FIndent + Images.Width;

  if (ASection = 0) and (AWidth < fIndent) then
  begin
    AWidth := FIndent;
    if Assigned(FHeader) then
      FHeader.SectionWidth[ASection] := FIndent;
  end;

  TColumnItem(FColumnCollection.Items[ASection]).FWidth := AWidth;
  Invalidate;
end;

procedure THTMLTreeList.HeaderChanged(Sender: TObject);
begin
  if Assigned(FHeader) then
  begin
    if HeaderSettings.Flat then
      FHeader.BorderStyle := bsNone
    else
      FHeader.BorderStyle := bsSingle;

    FHeader.AllowResize := HeaderSettings.AllowResize;
    FHeader.Font.Assign(HeaderSettings.Font);
    FHeader.Color := HeaderSettings.Color;
    FHeader.Height := HeaderSettings.Height;
    FHeader.Top := FHeader.Top;
  end;
end;

procedure THTMLTreeList.HeaderClick(sender: TObject; ASection: integer);
begin
  if Assigned(OnHeaderClick) then
    OnHeaderClick(self, ASection);
end;

procedure THTMLTreeList.HeaderRightClick(sender: TObject; ASection: integer);
begin
  if Assigned(OnHeaderRightClick) then
    OnHeaderRightClick(self, ASection);
end;

procedure THTMLTreeList.DestroyWnd;
begin
  (*
  FHeader.parent := nil;
  if Assigned(FHeader) then
    FHeader.Free;
  FHeader := nil;
  *)
  inherited;
end;

procedure THTMLTreeList.Expand(Node: TTreeNode);
begin
  inherited;
  Invalidate;
end;

destructor THTMLTreeList.Destroy;
begin
  FColumnCollection.Free;
  FHeaderSettings.Free;
  FSelectionColors.Free;
  inherited;
end;

procedure THTMLTreeList.SetColumnLines(const value: boolean);
begin
  if (FColumnLines <> value) then
  begin
    FColumnLines := value;
    if FColumnLines then
      FColumnSpace := 4
    else
      FColumnSpace := 2;
    Invalidate;
  end;
end;


procedure THTMLTreeList.SetComponentStyle(AStyle: TTMSStyle);

  procedure SetHeaderColors(clr1,clr2: TColor);
  begin
    HeaderSettings.Color := clr1;
    HeaderSettings.ColorTo := clr2;
  end;

begin
  SelectionColors.SetStyle(AStyle);
  SelectionFontColor := clHighlightText;
  if not (AStyle in [tsCustom, tsWindowsXP]) then
    SelectionFontColor := clBlack;

  case Astyle of
  tsOffice2003Blue: SetHeaderColors($FDEADA, $E4AE88);
  tsOffice2003Silver: SetHeaderColors($ECE2E1, $B39698);
  tsOffice2003Olive: SetHeaderColors($CFF0EA, $8CC0B1);
  tsOffice2003Classic: SetHeaderColors(clBtnFace, clNone);
  tsOffice2007Luna: SetHeaderColors($00FFEFE3, $00FFD2AF);
  tsOffice2007Silver: SetHeaderColors($00F8F7F6, $00E8E0DB);
  tsOffice2007Obsidian: SetHeaderColors($00F2F1F0, $00C9C2BD);
  tsWindowsXP: SetHeaderColors(clBtnFace, clNone);
  tsWhidbey: SetHeaderColors($00EBEEEF, $007E9898);
  tsWindowsVista: SetHeaderColors($00FAF8F7, $00F4F2F1);
  tsWindows7: SetHeaderColors($00F4E6DC, $00F7E9DD);
  tsTerminal: SetHeaderColors(clBtnFace, clNone);
  tsOffice2010Blue: SetHeaderColors($FDF6EF, $F0DAC7);
  tsOffice2010Silver: SetHeaderColors($FFFFFF, $EDE5E0);
  tsOffice2010Black: SetHeaderColors($BFBFBF, $919191);
  end;

  HeaderSettings.Flat := not (AStyle = tsWindowsXP);
end;

function THTMLTreeList.GetNodeColumn(tn: TTreeNode; idx: integer): string;
var
  s: string;
  i: integer;
begin
  Result := '';
  if Assigned(tn) then
    s := tn.Text
  else
    Exit;

  i := 0;
  while (i <= idx) and (s <> '') do
  begin
    if (pos(Separator, s) > 0) then
    begin
      if (idx = i) then
         Result := copy(s, 1, pos(Separator, s) - 1);
      {$IFNDEF TMSDOTNET}
      system.delete(s, 1, pos(Separator, s));
      {$ENDIF}
      {$IFDEF TMSDOTNET}
      Borland.delphi.system.delete(s, 1, pos(Separator, s));
      {$ENDIF}
      inc(i);
    end
    else
    begin
      Result := s;
      s := '';
    end;
  end;
end;


procedure THTMLTreeList.SetNodeColumn(tn: TTreeNode; idx: integer;
  value: string);
var
  s,su: string;
  i,vp: Integer;
  sel: boolean;
begin
  if Assigned(tn) then
    s := tn.Text
  else
    Exit;

  sel := tn.Selected;

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
  tn.Selected := sel;
  Invalidate;
end;


procedure THTMLTreeList.SetColumnCollection(const value: TColumnCollection);
begin
  fColumnCollection.Assign(value);
end;

procedure THTMLTreeList.SetBounds(ALeft, ATop, AWidth, AHeight: Integer);
begin
  if Align in [alClient, alTop] then
  begin
    inherited SetBounds(ALeft, ATop + FHeaderSettings.height - 2, AWidth, AHeight - (FHeaderSettings.height - 2));
    if Assigned(FHeader) then
    begin
      FHeader.top := ATop;
      FHeader.left := ALeft;
      FHeader.Width := AWidth;
      FHeader.Height := fHeaderSettings.Height;
    end;
  end
  else
  begin
    inherited SetBounds(ALeft, ATop, AWidth, AHeight);
    if Assigned(FHeader) then
    begin
      FHeader.Top := ATop - (FHeaderSettings.height - 2);
      FHeader.Left := ALeft;
      FHeader.Width := AWidth;
      FHeader.Height := fHeaderSettings.height;
    end;
  end;
end;

procedure THTMLTreeList.UpdateColumns;
var
  i: integer;
begin
  if assigned(fHeader) then
  begin
    fHeader.Sections.Clear;
    for i := 1 to fColumnCollection.Count do
    begin
      fHeader.Sections.Add(TColumnItem(fColumnCollection.Items[i - 1]).Header);
      fHeader.SectionWidth[i - 1] := TColumnItem(fColumnCollection.Items[i - 1]).Width;
    end;
    self.Invalidate;
  end;
end;

function THTMLTreeList.GetColWidth(idx: integer): integer;
begin
  if idx >= fColumnCollection.Count - 1 then result := self.width
  else result := TColumnItem(fColumnCollection.Items[idx]).fWidth;
end;

function THTMLTreeList.GetColFont(idx: integer): TFont;
begin
  if idx >= fColumnCollection.Count then result := self.Font
  else result := TColumnItem(fColumnCollection.Items[idx]).fFont;
end;

procedure THTMLTreeList.Notification(AComponent: TComponent;
  AOperation: TOperation);
begin
  if (aOperation = opRemove) and (aComponent = fImages) then fImages := nil;
  inherited;
end;

{$IFNDEF TMSDOTNET}
procedure THTMLTreeList.CNNotify(var message: TWMNotify);
var
  TVcd: TNMTVCustomDraw;
  TVdi: TTVDISPINFO;
  Canvas: TCanvas;
  s, su, anchor, stripped: string;
  tn: ttreenode;
  r,hr: trect;
  fIndent, fIdx, fImgWidth: integer;
  xsize, ysize, th: integer;

  hyperlinks,mouselink:integer;
  focusanchor:string;
  re:trect;

begin
  if message.NMHdr^.code = TVN_GETDISPINFO then
  begin
    TVDi := PTVDispInfo(pointer(message.nmhdr))^;

    if (tvdi.item.mask and TVIF_TEXT = TVIF_TEXT) then
    begin
      inherited;
      tn := items.getnode(tvdi.item.hitem);
      s := HTMLStrip(tn.text);
      StrpCopy(tvdi.item.pszText, s);
      tvdi.item.mask := tvdi.item.mask or TVIF_DI_SETITEM;
      message.Result := 0;
      Exit;
    end;
  end;

  if message.NMHdr^.code = NM_CUSTOMDRAW then
  begin
    fIndent := TreeView_GetIndent(self.handle);
    TVcd := PNMTVCustomDraw(Pointer(message.NMHdr))^;
    case TVcd.nmcd.dwDrawStage of
      CDDS_PREPAINT: message.Result := CDRF_NOTIFYITEMDRAW or CDRF_NOTIFYPOSTPAINT;
      CDDS_ITEMPREPAINT: begin
          if (TVcd.nmcd.uItemState and CDIS_SELECTED = CDIS_SELECTED) then
          begin
            TVcd.nmcd.uItemState := TVcd.nmcd.uItemState and (not CDIS_SELECTED);
            SetTextColor(TVcd.nmcd.hdc, ColorToRGB(self.Color));
            SetBkColor(TVcd.nmcd.hdc, ColorToRGB(self.Color));
            TVcd.clrTextBk := colortorgb(self.Color);
            TVcd.clrText := colortorgb(self.Color);
          end
          else
          begin
            SetTextColor(TVcd.nmcd.hdc, ColorToRGB(self.Color));
            SetBkColor(TVcd.nmcd.hdc, ColorToRGB(self.Color));
          end;
          message.Result := CDRF_NOTIFYPOSTPAINT;
        end;

      CDDS_ITEMPOSTPAINT:
        begin
          Canvas := TCanvas.Create;
          Canvas.Handle := TVcd.nmcd.hdc;

          tn := Items.GetNode(HTReeItem(TVcd.nmcd.dwitemSpec));
          TVcd.nmcd.rc.left := TVcd.nmcd.rc.left + fIndent * (tn.level + 1) - getscrollpos(handle, SB_HORZ);

          FImgWidth := 0;
          if Assigned(Images) then
          begin
            FImgWidth := Images.Width;
            Canvas.Brush.color := Color;
            Canvas.Pen.color := Color;
            Canvas.Rectangle(TVcd.nmcd.rc.left, TVcd.nmcd.rc.top, TVcd.nmcd.rc.left + fImgWidth, TVcd.nmcd.rc.bottom);
            if (TVcd.nmcd.rc.left + fImgWidth < GetColWidth(0)) and (tn.ImageIndex >= 0) then
            begin
              images.draw(canvas, TVcd.nmcd.rc.left, TVcd.nmcd.rc.top, tn.ImageIndex);
            end;
          end;
          
          TVcd.nmcd.rc.left := TVcd.nmcd.rc.left + fImgWidth;

          r := TVcd.nmcd.rc;

          if (TVcd.nmcd.uItemState and CDIS_SELECTED = CDIS_SELECTED) then
          begin
            with TVcd.nmcd.rc do
              SelectionColors.Draw(Canvas, Rect(Left, Top, Right, Bottom));

            Canvas.Font.Color := FSelectionFontColor;
            
            if (TVcd.nmcd.uItemState and CDIS_FOCUS = CDIS_FOCUS) then
            begin
              Canvas.Pen.Color := Color;
              Canvas.Brush.Color := Color;
              TVcd.nmcd.rc.Right := TVcd.nmcd.rc.Right + 1;
              Canvas.DrawFocusRect(TVcd.nmcd.rc);
              TVcd.nmcd.rc.Right := TVcd.nmcd.rc.Right - 1;
            end;
            TVcd.nmcd.rc := r;
            TVcd.nmcd.rc.left := TVcd.nmcd.rc.left + 4;
          end
          else
          begin
            Canvas.Brush.Color := Color;
            Canvas.Pen.Color := Color;
            with TVcd.nmcd.rc do
              Canvas.Rectangle(left, top, right, bottom);
          end;

          TVcd.nmcd.rc := r;
          TVcd.nmcd.rc.left := TVcd.nmcd.rc.left + 2;

          if (TVcd.nmcd.uItemState and CDIS_SELECTED = CDIS_SELECTED) then
          begin
            canvas.brush.color := clHighLight;
            canvas.pen.color := clHighLight;

          end;
          s := tn.text;
          fIdx := 0;

          Setbkmode(TVcd.nmcd.hdc, TRANSPARENT);

          repeat
            Canvas.Font.Assign(GetColFont(fIdx));
            if (TVcd.nmcd.uItemState and CDIS_SELECTED = CDIS_SELECTED) then
              Canvas.Font.color := FSelectionFontColor;

            if (fIdx = 0) then
              r.right := GetColWidth(0)
            else
              r.right := r.left + GetColWidth(fIdx); //+getScrollPos(self.handle,SB_HORZ);

            if fIdx = columns.Count - 1 then r.right := width;

            if (pos(FSeparator, s) > 0) then
            begin
              su := copy(s, 1, pos(fSeparator, s) - 1);
              {$IFNDEF TMSDOTNET}
              system.Delete(s, 1, pos(fSeparator, s) + length(fSeparator) - 1);
              {$ENDIF}
              {$IFDEF TMSDOTNET}
              Borland.Delphi.system.delete(s, 1, pos(fSeparator, s) + length(fSeparator) - 1);
              {$ENDIF}
            end
            else
            begin
              su := s;
              s := '';
            end;

            r.right := r.right - FColumnSpace;
            r.Left := r.Left + 2;

            hr := r;
            th := Canvas.TextHeight('gh');

            if th < hr.Bottom - hr.Top then
              hr.Top := hr.Top + (hr.Bottom - hr.Top - th) div 2;

            if (hr.left < hr.right) then
              HTMLDrawEx(Canvas, su, hr, fImages, 0, 0, -1, -1, 1, false, false, false, false, false, false, true,
                1.0, fURLColor, clNone, clNone, clGray, anchor, stripped, focusanchor, xsize, ysize,
                hyperlinks, mouselink, re, nil , nil, 0);

            r.right := r.right + FColumnSpace;

            r.left := r.right;
            inc(fIdx);

          until (length(s) = 0);

          Canvas.Free;
        end;
    else
      message.Result := 0;
    end;
  end
  else
    inherited;
end;
{$ENDIF}

{$IFDEF TMSDOTNET}
procedure THTMLTreeList.CNNotify(var message: TWMNotifyTV);
var
  TVcd: TNMTVCustomDraw;
  TVdi: TTVDISPINFO;
  canvas: tcanvas;
  s, su, anchor, stripped: string;
  tn: ttreenode;
  r: trect;
  fIndent, fIdx, fImgWidth: integer;
  xsize, ysize: integer;
  sa : array [0..255] of char;
  i : integer;
  Temp: TNMTVCustomDraw;
  TmpItem: TTVItem;

  hyperlinks,mouselink:integer;
  focusanchor:string;
  re:trect;
begin
  Canvas := TCanvas.Create;

  with message do
  begin
    case NMHdr.code of
      TVN_GETDISPINFO:
      begin
        TVDi := TVDispInfo;
        if (tvdi.item.mask and TVIF_TEXT = TVIF_TEXT) then
        begin
          inherited;
          tn := Items.GetNode(tvdi.item.hitem);
          if tn = nil then
            Exit;
          s := HTMLStrip(tn.text);
          for i := 1 to s.length do
            sa[i-1] := s[i];
          Marshal.Copy(tvdi.item.pszText, sa, 0, 255);
          //strplcopy(tvdi.item.pszText,s,255);
          tvdi.item.mask := tvdi.item.mask or TVIF_DI_SETITEM;
          Result := 0;
          Exit;
        end;
      end;
      NM_CUSTOMDRAW:
      begin
        fIndent := TreeView_GetIndent(self.handle);
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
                      Result := CDRF_NOTIFYPOSTPAINT;
                    finally
                      Canvas.Handle := 0;
                    end;
                  end;
                  CDDS_ITEMPOSTPAINT:
                  begin
                    try
                      Canvas.Handle := hdc;
                      Canvas.Font.Assign(Self.Font);
                      Temp := NMTVCustomDraw;

                      NMTVCustomDraw := Temp;
                      Temp.nmcd.rc.left := Temp.nmcd.rc.left + fIndent * (tn.level + 1) - getscrollpos(handle, SB_HORZ);

                      fImgWidth := 0;
                      if assigned(Images) then
                      begin
                        fImgWidth := Images.Width;
                        canvas.brush.color := self.Color;
                        canvas.pen.color := self.Color;
                        canvas.rectangle(Temp.nmcd.rc.left, Temp.nmcd.rc.top, Temp.nmcd.rc.left + fImgWidth, Temp.nmcd.rc.bottom);
                        if (temp.nmcd.rc.left + fImgWidth < GetColWidth(0)) and (tn.ImageIndex >= 0) then
                        begin
                          images.draw(canvas, Temp.nmcd.rc.left, Temp.nmcd.rc.top, tn.ImageIndex);
                        end;
                      end;
                      Temp.nmcd.rc.left := temp.nmcd.rc.left + fImgWidth;

                      r := temp.nmcd.rc;

                      if (temp.nmcd.uItemState and CDIS_SELECTED = CDIS_SELECTED) then
                      begin
                        canvas.brush.color := fSelectionColors.ColorFrom;
                        canvas.pen.color := fSelectionColors.ColorFrom;
                        with Temp.nmcd.rc do
                          canvas.rectangle(left, top, right, bottom);
                        canvas.font.Color := fSelectionFontColor;
                        if (temp.nmcd.uItemState and CDIS_FOCUS = CDIS_FOCUS) then
                        begin
                          canvas.pen.color := self.Color;
                          canvas.brush.color := self.Color;
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
                      Temp.nmcd.rc.left := Temp.nmcd.rc.left + 2;

                      if (Temp.nmcd.uItemState and CDIS_SELECTED = CDIS_SELECTED) then
                      begin
                        canvas.brush.color := clHighLight;
                        canvas.pen.color := clHighLight;
                      end;
                      s := tn.text;
                      fIdx := 0;
                      setbkmode(TVcd.nmcd.hdc, TRANSPARENT);

                      repeat
                        Canvas.Font.Assign(GetColFont(fIdx));
                        if (Temp.nmcd.uItemState and CDIS_SELECTED = CDIS_SELECTED) then
                        begin
                          Canvas.font.color := fSelectionFontColor;
                        end;

                        if (fIdx = 0) then
                          r.right := GetColWidth(0)
                        else
                          r.right := r.left + GetColWidth(fIdx); //+getScrollPos(self.handle,SB_HORZ);

                        if fIdx = Columns.Count - 1 then
                          r.right := width;

                        if (pos(FSeparator, s) > 0) then
                        begin
                          su := copy(s, 1, pos(fSeparator, s) - 1);
                          Borland.Delphi.system.delete(s, 1, pos(fSeparator, s) + length(fSeparator) - 1);
                        end
                        else
                        begin
                          su := s;
                          s := '';
                        end;
                        r.right := r.right - fColumnSpace;

                        if (r.left < r.right) then
                        HTMLDrawEx(canvas, su, r, fImages, 0, 0, -1, -1, 1, false, false, false, false, false, false, true,
                          1.0, fURLColor, clNone, clNone, clGray, anchor, stripped, focusanchor, xsize, ysize,
                          hyperlinks, mouselink, re, nil, nil, 0);

                        r.right := r.right + fColumnSpace;
                        r.left := r.right;
                        inc(fIdx);
                      until (length(s) = 0);
                      canvas.free;
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

procedure THTMLTreeList.SetSeparator(const Value: string);
begin
  FSeparator := Value;
  Invalidate;
end;

procedure THTMLTreeList.WMRButtonDown(var message: TWMRButtonDown);
var
  Node: TTreeNode;
begin
  if RightClickSelect then
  begin
    Node := GetNodeAt(message.XPos, message.YPos);
    if Assigned(Node) then
      Node.Selected := True;
  end;
  
  inherited;
end;

procedure THTMLTreeList.WMLButtonDblClk(var Message: TWMLButtonDblClk);
begin
  inherited;
  Invalidate;
end;

procedure THTMLTreeList.WMLButtonDown(var message: TWMLButtonDown);
var
  Node: TTreeNode;
  a: string;
begin
  if not (csDesigning in ComponentState) then
    inherited
  else
    Exit;
    
  Node := GetNodeAt(message.XPos, message.YPos);
  
  if Assigned(Node) then
  begin
    Node.Selected := true;
    a := IsAnchor(node, message.XPos, message.YPos);
    if (a <> '') then
      if Assigned(FOnAnchorClick) then
        FOnAnchorClick(self, Node, a);
  end;
end;

procedure THTMLTreeList.WMHScroll(var message: TMessage);
begin
  inherited;
  if (FOldScrollPos <> GetScrollPos(Handle, SB_HORZ)) then
  begin
    Invalidate;
    FHeader.Invalidate;
    FOldScrollPos := GetScrollPos(Handle, SB_HORZ);
  end;
end;

procedure THTMLTreeList.WMPaint(var message: TWMPaint);
var
  canvas: tcanvas;
  i: integer;
  xp: integer;
begin
  inherited;

  if (csDestroying in ComponentState) then
    Exit;

  if FColumnLines then
  begin
    Canvas := TCanvas.Create;
    Canvas.Handle := GetDC(Handle);
    try
      xp := 0;
      Canvas.Pen.color := clSilver;
      for i := 1 to FColumnCollection.Count - 1 do
      begin
        xp := xp + TColumnItem(FColumnCollection.Items[i - 1]).Width;
        Canvas.MoveTo(xp - 2 - GetScrollPos(self.handle, SB_HORZ), 0);
        Canvas.Lineto(xp - 2 - GetScrollPos(self.handle, SB_HORZ), height);
      end;
    finally
      ReleaseDC(Handle, Canvas.Handle);
      Canvas.Free;
    end;
  end;
end;

function THTMLTreeList.GetItemHeight: integer;
begin
  Result := TreeView_GetItemHeight(self.Handle);
end;

procedure THTMLTreeList.SetItemHeight(const Value: integer);
begin
  if (Value <> FItemHeight) then
  begin
    FItemHeight := Value;
    TreeView_SetItemHeight(Handle, FItemHeight);
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



function THTMLTreeList.GetVisible: boolean;
begin
  result := inherited Visible;
end;

procedure THTMLTreeList.SetVisible(const Value: boolean);
begin
  inherited Visible := value;
  if assigned(fHeader) then
  begin
    if value then fHeader.Show else fHeader.Hide;
  end;
end;

function THTMLTreeList.GetClientRect: TRect;
var
  r: trect;
begin
  r := inherited GetClientRect;
  r.bottom := r.bottom + fHeaderSettings.Height;
  result := r;
end;

function THTMLTreeList.IsAnchor(node: ttreenode; x, y: integer): string;
var
  r: trect;
  s, a: string;
  xsize, ysize: integer;
{$IFNDEF DELPHI4_LVL}
  canvas: tcanvas;
{$ENDIF}
  i, w: integer;
  hyperlinks,mouselink:integer;
  focusanchor:string;
  re:trect;

begin
  r := node.DisplayRect(true);

  a := '';

  Canvas.Font.Assign(Font);

  w := 0;
  i := 0;
  
  while not ((x >= w - 2) and (x <= w + GetColWidth(i) - 2)) and (i < Columns.Count) do
  begin
    w := w + GetColWidth(i);
    inc(i);
  end;

  if (i = Columns.Count) then dec(i);
  s := GetColumnText(i, node.Text);

  r.left := w;
  if (i < Columns.Count - 1) then r.right := r.left + GetColWidth(i) else r.right := self.width;

  if (i = 0) then
  begin
    r.left := r.left + integer(TreeView_GetIndent(self.handle)) * (node.level + 1);
    if assigned(Images) then r.left := r.left + Images.Width;
  end;

{$IFDEF TMSDEBUG}
  outputdebugstring(pchar('mouse is at pos ' + inttostr(x) + ' in col (' + inttostr(i) + ') @ [' + inttostr(r.left) + ':' + inttostr(r.right) + ']'));
  outputdebugstring(pchar(s));
{$ENDIF}

  HTMLDrawEx(canvas, s, r, fImages, x, y, -1, -1, 1, true, false, false, true, true, false, true,
    1.0, clBlue, clnone, clNone, clGray, a, s, focusanchor, xsize, ysize, hyperlinks, mouselink, re,
    nil, nil, 0);

  Result := a;
end;

procedure THTMLTreeList.WMMouseMove(var message: TWMMouseMove);
var
  Node: TTreeNode;
{$IFDEF DELPHI3_ONLY}
  canvas: tcanvas;
{$ENDIF}
  a: string;

begin
  Node := GetNodeAt(message.XPos, message.YPos);

  if Assigned(Node) then
  begin
    if HotTrack then
      Selected := Node;

    a := IsAnchor(node, message.XPos, message.YPos);
    if (a <> '') then
    begin
      {change from anchor to anchor}
      if (a <> fOldAnchor) and (self.Cursor = crHandPoint) then
      begin
        if FAnchorHint then
          Application.CancelHint;
        if Assigned(FOnAnchorExit) then
          FOnAnchorExit(self, Node, FOldAnchor);
      end;

      if (a <> fOldAnchor) then
      begin
        if Assigned(FOnAnchorEnter) then
          FOnAnchorEnter(self, Node, a);
      end;

      if (Cursor <> crHandPoint) then
      begin
        FOldCursor := Cursor;
        FOldAnchor := a;
        Cursor := crHandPoint;
      end;

    end
    else
    begin
      if FAnchorHint then
        Application.CancelHint;
      if (FOldAnchor <> '') then
      begin
        if Assigned(fOnAnchorExit) then
          FOnAnchorExit(self, Node, fOldAnchor);
        FOldAnchor := '';
      end;

      if (Cursor = crHandPoint) then
        Cursor := FOldCursor;
    end;
  end
  else
    if (Cursor = crHandPoint) then
      Cursor := FOldCursor;
    
  inherited;
end;

function THTMLTreeList.GetColumnText(col: integer; s: string): string;
var
  i: integer;
  su: string;
begin
  i := 0;
  su := s;
  while (i <= col) do
  begin
    if (pos(fSeparator, s) > 0) then
    begin
      su := copy(s, 1, pos(fSeparator, s) - 1);
      {$IFNDEF TMSDOTNET}
      system.delete(s, 1, pos(fSeparator, s) + length(fSeparator) - 1);
      {$ENDIF}
      {$IFDEF TMSDOTNET}
      Borland.Delphi.system.delete(s, 1, pos(fSeparator, s) + length(fSeparator) - 1);
      {$ENDIF}
    end
    else
    begin
      su := s;
      s := '';
    end;

    inc(i);
  end;
  result := su;
end;


procedure THTMLTreeList.SetImages(const Value: TImageList);
begin
  FImages := Value;
  Invalidate;
end;

procedure THTMLTreeList.SetURLColor(const Value: TColor);
begin
  if (FURLColor <> value) then
  begin
    FURLColor := Value;
    Invalidate;
  end;
end;

procedure THTMLTreeList.SetSelectionColors(const Value: TGradientStyle);
begin
  FSelectionColors.Assign(Value);
  Invalidate;
end;

procedure THTMLTreeList.SetSelectionFontColor(const Value: tcolor);
begin
  if (FSelectionFontColor <> Value) then
  begin
    FSelectionFontColor := Value;
    Invalidate;
  end;
end;

{$IFNDEF TMSDOTNET}
procedure THTMLTreeList.CMHintShow(var Msg: TMessage);
var
  CanShow: Boolean;
  hi: PHintInfo;
  anchor: string;
  Node: TTreeNode;
begin
  CanShow := True;
  hi := PHintInfo(Msg.LParam);

  Node := GetNodeAt(hi^.cursorPos.x, hi^.cursorpos.y);
  if assigned(Node) and fAnchorHint then
  begin
    anchor := IsAnchor(Node, hi^.cursorPos.x, hi^.cursorpos.y);
    if (anchor <> '') then
    begin
      hi^.HintPos := clienttoscreen(hi^.CursorPos);
      hi^.hintpos.y := hi^.hintpos.y - 10;
      hi^.hintpos.x := hi^.hintpos.x + 10;
      hi^.HintStr := anchor;
    end;
  end;
  Msg.Result := Ord(not CanShow);
end;
{$ENDIF}

{$IFDEF TMSDOTNET}
procedure THTMLTreeList.CMHintShow(var Message: TCMHintShow);
var
  CanShow: Boolean;
  hi: THintInfo;
  anchor: string;
  Node: TTreeNode;
begin
  CanShow := True;
  hi := Message.HintInfo;

  Node := GetNodeAt(hi.cursorPos.x, hi.cursorpos.y);
  if assigned(Node) and fAnchorHint then
  begin
    anchor := IsAnchor(Node, hi.cursorPos.x, hi.cursorpos.y);
    if (anchor <> '') then
    begin
      hi.HintPos := clienttoscreen(hi.CursorPos);
      hi.hintpos.y := hi.hintpos.y - 10;
      hi.hintpos.x := hi.hintpos.x + 10;
      hi.HintStr := anchor;
    end;
  end;
  Message.HintInfo := hi;
  Message.Result := Ord(not CanShow);
end;
{$ENDIF}

function THTMLTreeList.GetVersion: string;
var
  vn: Integer;
begin
  vn := GetVersionNr;
  Result := IntToStr(Hi(Hiword(vn)))+'.'+IntToStr(Lo(Hiword(vn)))+'.'+IntToStr(Hi(Loword(vn)))+'.'+IntToStr(Lo(Loword(vn)));
end;

function THTMLTreeList.GetVersionNr: Integer;
begin
  Result := MakeLong(MakeWord(BLD_VER,REL_VER),MakeWord(MIN_VER,MAJ_VER));
end;

procedure THTMLTreeList.SetVersion(const Value: string);
begin

end;


{ THeaderSettings }

procedure THeaderSettings.Changed;
begin
  if Assigned(OnChange) then
    OnChange(Self);
end;

constructor THeaderSettings.Create(aOwner: THTMLTreeList);
begin
  inherited Create;
  FOwner := AOwner;
  FColor := clBtnFace;
  FColorTo := clNone;
  FHeight := 18;
  FAllowResize := true;
  FFlat := false;
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
  Changed;
end;

procedure THeaderSettings.SetAllowResize(const Value: boolean);
begin
  if (FAllowResize <> Value) then
  begin
    FAllowResize := Value;
    Changed;
  end;
end;

procedure THeaderSettings.SetColor(const Value: tColor);
begin
  if (FColor <> Value) then
  begin
    FColor := Value;
    Changed;
  end;
end;

procedure THeaderSettings.SetColorTo(const Value: TColor);
begin
  if (FColorTo <> Value) then
  begin
    FColorTo := Value;
    Changed;
  end;
end;

procedure THeaderSettings.SetFlat(const Value: boolean);
begin
  if (FFlat <> Value) then
  begin
    FFlat := Value;
    Changed;
  end;
end;

procedure THeaderSettings.SetFont(const Value: tFont);
begin
  FFont.Assign(Value);
  Changed;
end;

procedure THeaderSettings.SetHeight(const Value: integer);
begin
  if (FHeight <> Value) then
  begin
    FHeight := Value;
    Changed;
  end;
end;


{$IFDEF FREEWARE}
{$I TRIAL.INC}
{$ENDIF}


end.
