{**********************************************************************}
{ TAdvComboBox component                                               }
{ for Delphi & C++Builder                                              }
{                                                                      }
{ written by                                                           }
{  TMS Software                                                        }
{  copyright © 1996-2010                                               }
{  Email : info@tmssoftware.com                                        }
{  Web : http://www.tmssoftware.com                                    }
{                                                                      }
{ The source code is given as is. The author is not responsible        }
{ for any possible damage done due to the use of this code.            }
{ The component can be freely used in any application. The source      }
{ code remains property of the author and may not be distributed       }
{ freely as such.                                                      }
{**********************************************************************}

unit AdvCombo;

{$I TMSDEFS.INC}

interface

uses
  Windows, Messages, Classes, Forms, Controls, Graphics, StdCtrls,
  SysUtils
  {$IFNDEF TMSDOTNET}
  , ACXPVS
  {$ENDIF}
  {$IFDEF TMSDOTNET}
  , uxTheme
  {$ENDIF}
  ;

const
  MAJ_VER = 1; // Major version nr.
  MIN_VER = 3; // Minor version nr.
  REL_VER = 1; // Release nr.
  BLD_VER = 0; // Build nr.

  // version history
  // 1.1.0.1 : fixed issue with changing visibility at runtime
  // 1.2.0.0 : New FocusColor, FocusBorderColor properties added
  //         : Improved DFM property storage
  // 1.2.1.0 : Exposed ComboLabel public property
  // 1.2.2.0 : Improved : behaviour with ParentFont = true for LabelFont
  // 1.2.3.0 : New : property DisabledBorder added
  // 1.2.4.0 : New : method SelectItem added
  // 1.2.4.1 : Fixed : issue with label margin
  // 1.2.5.0 : New : exposed Align property
  // 1.2.5.1 : Fixed : possible issue with label positioning for large label font
  // 1.2.5.2 : Improved : painting of dropdown button in flat mode
  // 1.2.5.3 : Fixed : focus border paint issue on Windows Vista
  // 1.2.6.0 : New : FocusLabel property added
  // 1.2.6.1 : Improved : painting in flat mode
  // 1.3.0.0 : New : label RightTop, RightCenter, RightBottom positions added
  // 1.3.0.1 : Fixed : issue with LabelFont and Form ScaleBy
  // 1.3.1.0 : New : Exposed CharCase property


type
  TWinCtrl = class(TWinControl);

  TLabelPosition = (lpLeftTop, lpLeftCenter, lpLeftBottom, lpTopLeft, lpBottomLeft,
                    lpLeftTopLeft, lpLeftCenterLeft, lpLeftBottomLeft, lpTopCenter,
                    lpBottomCenter, lpRightTop, lpRightCenter, lpRighBottom);

  TAdvCustomCombo = class(TCustomComboBox)
  private
    FAutoFocus: boolean;
    FFlat: Boolean;
    FEtched: Boolean;
    FOldColor: TColor;
    FLoadedColor: TColor;
    FOldParentColor: Boolean;
    FButtonWidth: Integer;
    FFocusBorder: Boolean;
    FMouseInControl: Boolean;
    FDropWidth: integer;
    FIsWinXP: Boolean;
    FIsThemed: Boolean;
    FButtonHover: Boolean;
    FLabelAlwaysEnabled: Boolean;
    FLabelTransparent: Boolean;
    FLabelMargin: Integer;
    FLabelFont: TFont;
    FLabelPosition: TLabelPosition;
    FLabel: TLabel;
    FFlatLineColor: TColor;
    FFlatParentColor: Boolean;
    FOnDropUp: TNotifyEvent;
    FFocusColor: TColor;
    FFocusBorderColor: TColor;
    FDisabledBorder: boolean;
    FNormalColor: TColor;
    FHasFocus: Boolean;
    FFocusLabel: Boolean;
    procedure SetEtched(const Value: Boolean);
    procedure SetFlat(const Value: Boolean);
    procedure SetButtonWidth(const Value: Integer);
    procedure DrawButtonBorder(DC:HDC);
    procedure DrawControlBorder(DC:HDC);
    procedure DrawBorders;
    function  Is3DBorderControl: Boolean;
    function  Is3DBorderButton: Boolean;
    procedure CMEnter(var Message: TCMEnter); message CM_ENTER;
    procedure CMExit(var Message: TCMExit); message CM_EXIT;
    procedure CMMouseEnter(var Message: TMessage); message CM_MOUSEENTER;
    procedure CMMouseLeave(var Message: TMessage); message CM_MOUSELEAVE;
    procedure CMEnabledChanged(var Msg: TMessage); message CM_ENABLEDCHANGED;
    procedure CNCommand (var Message: TWMCommand); message CN_COMMAND;
    procedure WMPaint(var Message: TWMPaint); message WM_PAINT;
    {$IFNDEF TMSDOTNET}
    procedure WMNCPaint (var Message: TMessage); message WM_NCPAINT;
    procedure CMParentFontChanged(var Message: TMessage); message CM_PARENTFONTCHANGED;
    {$ENDIF}
    procedure WMSetFocus(var Message: TWMSetFocus); message WM_SETFOCUS;
    procedure WMKillFocus(var Message: TWMKillFocus); message WM_KILLFOCUS;
    procedure SetDropWidth(const Value: integer);
    function GetLabelCaption: string;
    procedure SetLabelAlwaysEnabled(const Value: Boolean);
    procedure SetLabelCaption(const Value: string);
    procedure SetLabelFont(const Value: TFont);
    procedure SetLabelMargin(const Value: Integer);
    procedure SetLabelPosition(const Value: TLabelPosition);
    procedure SetLabelTransparent(const Value: Boolean);
    procedure UpdateLabel;
    procedure LabelFontChange(Sender: TObject);
    procedure SetFlatLineColor(const Value: TColor);
    procedure SetFlatParentColor(const Value: Boolean);
    function GetColorEx: TColor;
    procedure SetColorEx(const Value: TColor);
    function GetEnabledEx: Boolean;
    procedure SetEnabledEx(const Value: Boolean);
    function GetVersionEx: string;
    procedure SetVersion(const Value: string);
    function GetVisibleEx: boolean;
    procedure SetVisibleEx(const Value: boolean);
  protected
    function GetVersionNr: Integer; virtual;
    {$IFDEF TMSDOTNET}
    procedure WndProc(var Message: TMessage); override;
    {$ENDIF}
    function DoVisualStyles: Boolean;
    function CreateLabel: TLabel;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    property ButtonWidth: integer read FButtonWidth write SetButtonWidth default 19;
    property Flat: Boolean read FFlat write SetFlat default False;
    property FlatLineColor: TColor read FFlatLineColor write SetFlatLineColor default clBlack;
    property FlatParentColor: Boolean read FFlatParentColor write SetFlatParentColor default True;
    property Etched: Boolean read FEtched write SetEtched default False;
    property FocusBorder: Boolean read FFocusBorder write FFocusBorder default False;
    property FocusBorderColor: TColor read FFocusBorderColor write FFocusBorderColor default clNone;
    property FocusColor: TColor read FFocusColor write FFocusColor default clNone;
    property FocusLabel: Boolean read FFocusLabel write FFocusLabel default false;
    property AutoFocus: Boolean read FAutoFocus write FAutoFocus default False;
    property DropWidth: integer read FDropWidth write SetDropWidth;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure Loaded; override;
    procedure Init;
    procedure SetBounds(ALeft, ATop, AWidth, AHeight: Integer); override;
    property ComboLabel: TLabel read FLabel;
    property DisabledBorder: Boolean read FDisabledBorder write FDisabledBorder default true;
    property LabelCaption:string read GetLabelCaption write SetLabelCaption;
    property LabelPosition:TLabelPosition read FLabelPosition write SetLabelPosition default lpLeftTop;
    property LabelMargin: Integer read FLabelMargin write SetLabelMargin default 4;
    property LabelTransparent: Boolean read FLabelTransparent write SetLabelTransparent default False;
    property LabelAlwaysEnabled: Boolean read FLabelAlwaysEnabled write SetLabelAlwaysEnabled default False;
    property LabelFont:TFont read FLabelFont write SetLabelFont;
    property Enabled: Boolean read GetEnabledEx write SetEnabledEx;
    procedure SelectItem(AString: string);
  published
    {$IFDEF DELPHI7_LVL}
    property AutoComplete;
    {$ENDIF}
    property Color: TColor read GetColorEx write SetColorEx;
    property OnDropUp: TNotifyEvent read FOnDropUp write FOnDropUp;
    property Version: string read GetVersionEx write SetVersion;
    property Visible: boolean read GetVisibleEx write SetVisibleEx;
  end;

  TAdvComboBox = class(TAdvCustomCombo)
  published
    property Align;
    property AutoFocus;
    property ButtonWidth;
    property DisabledBorder;
    property Style;
    property Flat;
    property FlatLineColor;
    property FlatParentColor;
    property Etched;
    property FocusBorder;
    property FocusBorderColor;
    property FocusColor;
    property FocusLabel;
    {$IFDEF DELPHI7_LVL}
    property CharCase;
    {$ENDIF}
    property Color;
    property Ctl3D;
    property DragCursor;
    property DragMode;
    property DropDownCount;
    property DropWidth;
    property Enabled;
    property Font;
    property ImeMode;
    property ImeName;
    property ItemIndex;
    property ItemHeight;
    property Items;
    property LabelCaption;
    property LabelPosition;
    property LabelMargin;
    property LabelTransparent;
    property LabelAlwaysEnabled;
    property LabelFont;
    property MaxLength;
    property ParentColor;
    property ParentCtl3D;
    property ParentFont;
    property ParentShowHint;
    property PopupMenu;
    property ShowHint;
    property Sorted;
    property TabOrder;
    property TabStop;
    property Text;
    property Visible;
    property OnChange;
    property OnClick;
    property OnDblClick;
    property OnDragDrop;
    property OnDragOver;
    property OnDrawItem;
    property OnDropDown;
    property OnDropUp;
    property OnEndDrag;
    property OnEnter;
    property OnExit;
    property OnKeyDown;
    property OnKeyPress;
    property OnKeyUp;
    property OnMeasureItem;
    property OnStartDrag;
    {$IFDEF DELPHI6_LVL}
    property OnSelect;
    {$ENDIF}
    {$IFDEF DELPHI4_LVL}
    property Anchors;
    property BiDiMode;
    property Constraints;
    property DragKind;
    property ParentBiDiMode;
    property OnEndDock;
    property OnStartDock;
    {$ENDIF}
    {$IFDEF DELPHI7_LVL}
    property BevelKind;
    property BevelInner;
    property BevelOuter;
    property BevelEdges;
    {$ENDIF}
  end;


implementation

{$IFNDEF DELPHI7_LVL}
{$IFNDEF TMSDOTNET}
function GetFileVersion(FileName:string): Integer;
var
  FileHandle:dword;
  l: Integer;
  pvs: PVSFixedFileInfo;
  lptr: uint;
  querybuf: array[0..255] of char;
  buf: PChar;
begin
  Result := -1;

  StrPCopy(querybuf,FileName);
  l := GetFileVersionInfoSize(querybuf,FileHandle);
  if (l>0) then
  begin
    GetMem(buf,l);
    GetFileVersionInfo(querybuf,FileHandle,l,buf);
    if VerQueryValue(buf,'\',Pointer(pvs),lptr) then
    begin
      if (pvs^.dwSignature=$FEEF04BD) then
      begin
        Result := pvs^.dwFileVersionMS;
      end;
    end;
    FreeMem(buf);
  end;
end;
{$ENDIF}
{$ENDIF}


{ TAdvCustomCombo }
constructor TAdvCustomCombo.Create(AOwner: TComponent);
var
  dwVersion:Dword;
  dwWindowsMajorVersion,dwWindowsMinorVersion:Dword;
  i: Integer;

begin
  inherited;
  FButtonWidth := GetSystemMetrics(SM_CXVSCROLL) + 2;
//  FOldColor := inherited Color;
//  FOldParentColor := inherited ParentColor;
  FFlat := False;
  FMouseInControl := False;
  FDisabledBorder := True;

  dwVersion := GetVersion;
  dwWindowsMajorVersion :=  DWORD(LOBYTE(LOWORD(dwVersion)));
  dwWindowsMinorVersion :=  DWORD(HIBYTE(LOWORD(dwVersion)));

  FIsWinXP := (dwWindowsMajorVersion > 5) OR
    ((dwWindowsMajorVersion = 5) AND (dwWindowsMinorVersion >= 1));

  // app is linked with COMCTL32 v6 or higher -> xp themes enabled
  i := GetFileVersion('COMCTL32.DLL');
  i := (i shr 16) and $FF;
  FIsThemed := (i > 5);
    
  FButtonHover := False;
  FLabel := nil;
  FLabelFont := TFont.Create;
  FLabelFont.OnChange := LabelFontChange;
  FLabelMargin := 4;
  FFlatLineColor := clBlack;
  FFlatParentColor := True;
  FLoadedColor := clWindow;
  FFocusColor := clNone;
  FFocusBorderColor := clNone;
end;

procedure TAdvCustomCombo.SetButtonWidth(const Value: integer);
begin
  if (value<14) or (value>32) then
    Exit;

  FButtonWidth := Value;
  Invalidate;
end;

procedure TAdvCustomCombo.SetFlat(const Value: Boolean);
begin
  if Value <> FFlat then
  begin
    FFlat := Value;
    Ctl3D := not Value;
    if FFlatParentColor and FFlat then
    begin
      if (Parent is TWinControl) then
        inherited Color := (Parent as TWinControl).Brush.Color;
    end
    else
      inherited Color := FLoadedColor;

    Invalidate;
  end;
end;

procedure TAdvCustomCombo.SetEtched(const Value: Boolean);
begin
  if Value <> FEtched then
  begin
    FEtched := Value;
    Invalidate;
  end;
end;

procedure TAdvCustomCombo.CMEnter(var Message: TCMEnter);
begin
  inherited;
  if not (csDesigning in ComponentState) then
  begin
    FHasFocus := true;
    DrawBorders;
    if (FFocusColor <> clNone) then
      Color := FFocusColor;

    if FFocusLabel and (FLabel <> nil) then
      FLabel.Font.Style := FLabel.Font.Style + [fsBold];

  end;
end;

procedure TAdvCustomCombo.CMExit(var Message: TCMExit);
begin
  inherited;

  if not (csDesigning in ComponentState) then
  begin
    FHasFocus := false;
    DrawBorders;
    if (FFocusColor <> clNone) and (FNormalColor <> clNone) then
      Color := FNormalColor;

    if FFocusLabel and (FLabel <> nil) then
      FLabel.Font.Style := FLabel.Font.Style - [fsBold];

  end;
end;

procedure TAdvCustomCombo.CMMouseEnter(var Message: TMessage);
var
  pf: TCustomForm;
begin
  inherited;
  if not FMouseInControl and Enabled then
    begin
     FMouseInControl := True;
     DrawBorders;
    end;

  pf := GetParentForm(self);

  if FAutoFocus and not (csDesigning in ComponentState) then
  begin
    if Assigned(pf) then
    begin
      if (GetActiveWindow = pf.Handle) then
        SetFocus;
    end
    else
      SetFocus;
  end;


  if FIsWinXP then
    Invalidate;
end;

procedure TAdvCustomCombo.CMMouseLeave(var Message: TMessage);
begin
  inherited;
  if FMouseInControl and Enabled then
    begin
     FMouseInControl := False;
     DrawBorders;
    end;
  if FIsWinXP then
  begin
    FButtonHover := False;
    Invalidate;
  end;
end;

procedure TAdvCustomCombo.CMEnabledChanged(var Msg: TMessage);
begin
  if FFlat then
  begin
    if not (csLoading in ComponentState) then
    begin
      if Enabled then
      begin
        inherited ParentColor := FOldParentColor;
        inherited Color := FOldColor;
      end
      else
      begin
        FOldParentColor := inherited Parentcolor;
        FOldColor := inherited Color;
        inherited ParentColor := True;
      end;
    end;
  end;
  inherited;
end;

{$IFNDEF TMSDOTNET}
procedure TAdvCustomCombo.WMNCPaint(var Message: TMessage);
begin
  inherited;
  if FFlat or (not Enabled and DoVisualStyles and not FDisabledBorder) then
    DrawBorders;

  if (FFocusBorderColor <> clNone) and (GetFocus = self.Handle) then
    DrawBorders;
end;
{$ENDIF}

{$IFDEF TMSDOTNET}
procedure TAdvCustomCombo.WndProc(var Message: TMessage);
begin
  inherited;
  if Message.Msg = WM_NCPAINT then
  begin
    if FFlat or (not Enabled and DoVisualStyles and not FDisabledBorder) then
      DrawBorders;

    if (FFocusBorderColor <> clNone) and (GetFocus = self.Handle) then
      DrawBorders;
  end;
end;
{$ENDIF}

function IsMouseButtonDown:Boolean;
{
  Returns a "True" if a Mouse button happens to be down.
}
begin
  {Note: Key state is read twice because the first time you read it,
   you learn if the bittpm has been pressed ever.
   The second time you read it you learn if
   the button is currently pressed.}
  Result := not(((GetAsyncKeyState(VK_RBUTTON)and $8000)=0) and
     ((GetAsyncKeyState(VK_LBUTTON)and $8000)=0));
     (*
  begin
    {Mouse buttons are up}
    Result := False;
  end
  else
  begin
    {Mouse buttons are up}
    Result:=True;
  end;
  *)
end;


procedure TAdvCustomCombo.WMPaint(var Message: TWMPaint);
var
  DC: HDC;
  PS: TPaintStruct;

  procedure DrawButton;
  var
    ARect: TRect;
    htheme: THandle;
  begin
    GetWindowRect(Handle, ARect);
    OffsetRect(ARect, -ARect.Left, -ARect.Top);
    Inc(ARect.Left, ClientWidth - FButtonWidth + 2);
    InflateRect(ARect, -1, -1);

    if DoVisualStyles then
    begin
      htheme := OpenThemeData(Handle,'combobox');

      if not Enabled then
      begin
        {$IFNDEF TMSDOTNET}
        DrawThemeBackground(htheme,DC,CP_DROPDOWNBUTTON,CBXS_DISABLED,@ARect,nil)
        {$ENDIF}
        {$IFDEF TMSDOTNET}
        DrawThemeBackground(htheme,DC,CP_DROPDOWNBUTTON,CBXS_DISABLED,ARect,nil)
        {$ENDIF}
      end
      else
      begin
        if IsMouseButtonDown and DroppedDown then
        begin
          {$IFNDEF TMSDOTNET}
          DrawThemeBackground(htheme,DC,CP_DROPDOWNBUTTON,CBXS_PRESSED,@ARect,nil)
          {$ENDIF}
          {$IFDEF TMSDOTNET}
          DrawThemeBackground(htheme,DC,CP_DROPDOWNBUTTON,CBXS_PRESSED,ARect,nil)
          {$ENDIF}
        end
        else
        begin
          {$IFNDEF TMSDOTNET}
          if not IsMouseButtonDown and FButtonHover and not DroppedDown then
            DrawThemeBackground(htheme,DC,CP_DROPDOWNBUTTON,CBXS_HOT,@ARect,nil)
          else
          DrawThemeBackground(htheme,DC,CP_DROPDOWNBUTTON,CBXS_NORMAL,@ARect,nil);
          {$ENDIF}
          {$IFDEF TMSDOTNET}
          if not IsMouseButtonDown and FButtonHover and not DroppedDown then
            DrawThemeBackground(htheme,DC,CP_DROPDOWNBUTTON,CBXS_HOT,ARect,nil)
          else
          DrawThemeBackground(htheme,DC,CP_DROPDOWNBUTTON,CBXS_NORMAL,ARect,nil);
          {$ENDIF}
        end;
      end;

      CloseThemeData(htheme);
    end
    else
    begin
      if Enabled then
        DrawFrameControl(DC, ARect, DFC_SCROLL, DFCS_SCROLLCOMBOBOX or DFCS_FLAT )
      else
        DrawFrameControl(DC, ARect, DFC_SCROLL, DFCS_SCROLLCOMBOBOX or DFCS_INACTIVE )
    end;

    ExcludeClipRect(DC, ClientWidth - FButtonWidth -4 , 0, ClientWidth +2, ClientHeight);
  end;

begin
  if not (FFlat or ( (FFocusBorderColor <> clNone) and FHasFocus)) and not (not Enabled and DoVisualStyles and not DisabledBorder) then
  begin
    inherited;
    Exit;
  end;

  if Message.DC = 0 then
    DC := BeginPaint(Handle, PS)
  else
    DC := Message.DC;
  try
    if (Style <> csSimple) then
    begin
      FillRect(DC, ClientRect, Brush.Handle);
      DrawButton;
    end;

    PaintWindow(DC);
  finally
    if Message.DC = 0 then
      EndPaint(Handle, PS);
  end;
  DrawBorders;
end;

function TAdvCustomCombo.Is3DBorderControl: Boolean;
begin
  if csDesigning in ComponentState then
    Result := False
  else
    Result := FMouseInControl or (Screen.ActiveControl = Self);

  Result := Result and FFocusBorder;
end;

function TAdvCustomCombo.Is3DBorderButton: Boolean;
begin
  if csDesigning in ComponentState then
    Result := Enabled
  else
    Result := FMouseInControl or (Screen.ActiveControl = Self);
end;

procedure TAdvCustomCombo.DrawButtonBorder(DC: HDC);
const
  Flags: array[Boolean] of Integer = (0, BF_FLAT);
  Edge: array[Boolean] of Integer = (EDGE_RAISED,EDGE_ETCHED);

var
  ARect: TRect;
  BtnFaceBrush: HBRUSH;

begin
  ExcludeClipRect(DC, ClientWidth - FButtonWidth + 4, 4, ClientWidth - 4, ClientHeight - 4);

  GetWindowRect(Handle, ARect);
  OffsetRect(ARect, -ARect.Left, -ARect.Top);
  Inc(ARect.Left, ClientWidth - FButtonWidth - 2);
  InflateRect(ARect, -2, -2);

  if Is3DBorderButton then
    DrawEdge(DC, ARect, Edge[Etched], BF_RECT or Flags[DroppedDown])
  else
  begin
    BtnFaceBrush := CreateSolidBrush(GetSysColor(COLOR_BTNFACE));
    InflateRect(ARect, 0, -1);
    ARect.Right := ARect.Right - 1;
    FillRect(DC, ARect, BtnFaceBrush);
    DeleteObject(BtnFaceBrush);
  end;

  ExcludeClipRect(DC, ARect.Left, ARect.Top, ARect.Right, ARect.Bottom);
end;

procedure TAdvCustomCombo.DrawControlBorder(DC: HDC);
var
  ARect:TRect;
  BtnFaceBrush, WindowBrush: HBRUSH;
  OldPen: HPen;

begin
  if not Enabled and FIsThemed and not DisabledBorder then
  begin
    BtnFaceBrush := CreateSolidBrush(ColorToRGB($B99D7F));
    GetWindowRect(Handle, ARect);
    OffsetRect(ARect, -ARect.Left, -ARect.Top);
    FrameRect(DC, ARect, BtnFaceBrush);
    DeleteObject(BtnFaceBrush);
    Exit;
  end;

  if (FFocusBorderColor <> clNone) then
  begin
    if FHasFocus then
    begin
      BtnFaceBrush := CreateSolidBrush(ColorToRGB(FFocusBorderColor));
      GetWindowRect(Handle, ARect);
      OffsetRect(ARect, -ARect.Left, -ARect.Top);
      FrameRect(DC, ARect, BtnFaceBrush);
      DeleteObject(BtnFaceBrush);
    end;
    Exit;
  end;

  if Is3DBorderControl then
    BtnFaceBrush := CreateSolidBrush(GetSysColor(COLOR_BTNFACE))
  else
    BtnFaceBrush := CreateSolidBrush(ColorToRGB((Parent as TWinControl).Brush.Color));

  WindowBrush := CreateSolidBrush(ColorToRGB(self.Color));

  try
    GetWindowRect(Handle, ARect);
    OffsetRect(ARect, -ARect.Left, -ARect.Top);
    if Is3DBorderControl then
    begin
      DrawEdge(DC, ARect, BDR_SUNKENOUTER, BF_RECT or BF_ADJUST);
      FrameRect(DC, ARect, BtnFaceBrush);
      InflateRect(ARect, -1, -1);
      FrameRect(DC, ARect, WindowBrush);
    end
    else
    begin
      FrameRect(DC, ARect, BtnFaceBrush);
      InflateRect(ARect, -1, -1);

      ARect.Right := ARect.Right - ButtonWidth; //GetSystemMetrics(SM_CXVSCROLL);
      FrameRect(DC, ARect, BtnFaceBrush);
      InflateRect(ARect, -1, -1);
      FrameRect(DC, ARect, WindowBrush);
      ARect.Right := ARect.Right + ButtonWidth; //GetSystemMetrics(SM_CXVSCROLL);
    end;

    if FFlat and (FFlatLineColor <> clNone) then
    begin
      OldPen := SelectObject(DC,CreatePen( PS_SOLID,1,ColorToRGB(FFlatLineColor)));
      MovetoEx(DC,ARect.Left - 2,Height - 1,nil);
      LineTo(DC,ARect.Right - ButtonWidth - 1 ,Height - 1);
      DeleteObject(SelectObject(DC,OldPen));
    end;

  finally
    DeleteObject(WindowBrush);
    DeleteObject(BtnFaceBrush);
  end;
end;

procedure TAdvCustomCombo.DrawBorders;
var
  DC: HDC;
begin
  if Enabled and not (FFlat or (FFocusBorderColor <> clNone)) then
    Exit;

  DC := GetWindowDC(Handle);
  try
    DrawControlBorder(DC);
    if (Style <> csSimple) and not
      (FIsWinXP and DoVisualStyles) then
        DrawButtonBorder(DC);
  finally
    ReleaseDC(Handle,DC);
  end;
end;

procedure TAdvCustomCombo.CNCommand(var Message: TWMCommand);
var
  r:TRect;
begin
  inherited;

  if (Message.NotifyCode in [CBN_CLOSEUP,CBN_DROPDOWN]) then
  begin
    r := GetClientRect;
    r.Left := r.Right - Fbuttonwidth;
    {$IFNDEF TMSDOTNET}
    InvalidateRect(Handle,@r,FALSE);
    {$ENDIF}
    {$IFDEF TMSDOTNET}
    InvalidateRect(Handle,r,FALSE);
    {$ENDIF}
    if (Message.NotifyCode = CBN_CLOSEUP) and Assigned(FOnDropUp) then
      FOnDropUp(Self);
  end;
end;


procedure TAdvCustomCombo.SetDropWidth(const Value: integer);
begin
  FDropWidth := Value;
  if Value > 0 then
    SendMessage(self.Handle,CB_SETDROPPEDWIDTH,FDropWidth,0);
end;

function TAdvCustomCombo.DoVisualStyles: Boolean;
begin
  if FIsThemed then
    Result := IsThemeActive
  else
    Result := False;
end;

procedure TAdvCustomCombo.MouseMove(Shift: TShiftState; X, Y: Integer);
begin
  inherited;
  if (X > Width - FButtonWidth) and (X < Width) then
  begin
    if not FButtonHover then
    begin
      FButtonHover := True;
      Invalidate;
    end;
  end
  else
  begin
    if FButtonHover then
    begin
      FButtonHover := False;
      Invalidate;
    end;
  end;

end;

function TAdvCustomCombo.GetLabelCaption: string;
begin
  if FLabel <> nil then
    Result := FLabel.Caption
  else
    Result := '';
end;

procedure TAdvCustomCombo.SetLabelAlwaysEnabled(const Value: Boolean);
begin
  FLabelAlwaysEnabled := Value;
  if FLabel <> nil then UpdateLabel;  
end;

procedure TAdvCustomCombo.SetLabelCaption(const Value: string);
begin
  if FLabel = nil then
     FLabel := CreateLabel;
  FLabel.Caption := Value;
  UpdateLabel;
end;

procedure TAdvCustomCombo.SetLabelFont(const Value: TFont);
begin
  FLabelFont.Assign(Value);
end;

procedure TAdvCustomCombo.SetLabelMargin(const Value: Integer);
begin
  FLabelMargin := Value;
  if FLabel <> nil then UpdateLabel;
end;

procedure TAdvCustomCombo.SetLabelPosition(const Value: TLabelPosition);
begin
  FLabelPosition := Value;
  if FLabel <> nil then UpdateLabel;
end;

procedure TAdvCustomCombo.SetLabelTransparent(const Value: Boolean);
begin
  FLabelTransparent := Value;
  if FLabel <> nil then UpdateLabel;
end;

destructor TAdvCustomCombo.Destroy;
begin
  {$IFNDEF TMSDOTNET}
  FlabelFont.Destroy;
  {$ENDIF}
  {$IFDEF TMSDOTNET}
  FLabelFont.Free;
  {$ENDIF}
  if FLabel <> nil then
    FLabel.Free;
  inherited;
end;

function TAdvCustomCombo.CreateLabel: TLabel;
begin
  Result := Tlabel.Create(self);
  Result.Parent:=self.parent;
  Result.FocusControl:=self;
  Result.Font.Assign(LabelFont);
  Result.ParentFont := self.ParentFont;  
end;


procedure TAdvCustomCombo.UpdateLabel;
begin
  FLabel.Transparent := FLabeltransparent;

  if not ParentFont then
    FLabel.Font.Assign(FLabelFont);

  case FLabelPosition of
  lpLeftTop:
    begin
      FLabel.top := self.top;
      FLabel.left := self.left-FLabel.Canvas.TextWidth(FLabel.caption)-FLabelMargin;
    end;
  lpLeftCenter:
    begin
      if self.Height < FLabel.Height then
        FLabel.Top := self.Top - ((FLabel.Height - self.Height) div 2)
      else
        FLabel.top := self.top + ((self.height - FLabel.height) div 2);
      FLabel.left := self.left-FLabel.canvas.textwidth(FLabel.caption)-FLabelMargin;
    end;
  lpLeftBottom:
    begin
      FLabel.top := self.top+self.height-FLabel.height;
      FLabel.left := self.left-FLabel.canvas.textwidth(FLabel.caption)-FLabelMargin;
    end;
  lpTopLeft:
    begin
      FLabel.top := self.Top - FLabel.Height - FLabelMargin;
      FLabel.left := self.Left;
    end;
  lpTopCenter:
    begin
      FLabel.Top := self.top-FLabel.height-FLabelMargin;
      if (self.Width > FLabel.width) then
        FLabeL.Left := self.Left + ((self.Width-FLabel.width) div 2)
      else
        FLabeL.Left := self.Left - ((FLabel.Width - self.Width) div 2)
    end;
  lpBottomLeft:
    begin
      FLabel.top := self.top+self.height+FLabelMargin;
      FLabel.left := self.left;
    end;
  lpBottomCenter:
    begin
      FLabel.top := self.top+self.height+FLabelMargin;

      if (self.Width > FLabel.width) then
        FLabeL.Left := self.Left + ((self.Width-FLabel.width) div 2)
      else
        FLabeL.Left := self.Left - ((FLabel.Width - self.Width) div 2)
    end;
  lpLeftTopLeft:
    begin
      FLabel.top := self.top;
      FLabel.left := self.left-FLabelMargin;
    end;
  lpLeftCenterLeft:
    begin
      if self.Height < FLabel.Height then
        FLabel.Top := self.Top - ((FLabel.Height - self.Height) div 2)
      else
        FLabel.top := self.top + ((self.height-FLabel.height) div 2);

      FLabel.left := self.left - FLabelMargin;
    end;
  lpLeftBottomLeft:
    begin
      FLabel.top:=self.top+self.height-FLabel.height;
      FLabel.left:=self.left-FLabelMargin;
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

procedure TAdvCustomCombo.LabelFontChange(Sender: TObject);
begin
  if FLabel <> nil then
  begin
    UpdateLabel;
    if (csDesigning in ComponentState) then
      ParentFont := false;
  end;
end;

procedure TAdvCustomCombo.Loaded;
begin
  inherited;
  if FLabel <> nil then
    UpdateLabel;
  if FDropWidth > 0 then
    DropWidth := FDropWidth;
  FOldColor := FLoadedColor;
  if not FlatParentColor or Flat then
    Color := FLoadedColor;

  if not LabelAlwaysEnabled and Assigned(FLabel) then
    FLabel.Enabled := Enabled;

  Init;
end;

{$IFNDEF TMSDOTNET}
procedure TAdvCustomCombo.CMParentFontChanged(var Message: TMessage);
begin
  inherited;
  if Assigned(FLabel) and ParentFont then
  begin
    FLabel.Font.Assign(Font);
    UpdateLabel;
  end;
end;
{$ENDIF}


procedure TAdvCustomCombo.Init;
begin
  FNormalColor := Color;
end;

procedure TAdvCustomCombo.SelectItem(AString: string);
var
  i: integer;
begin
  i := Items.IndexOf(Astring);
  if (i <> -1) then
    ItemIndex := i;
end;

procedure TAdvCustomCombo.SetBounds(ALeft, ATop, AWidth, AHeight: Integer);
begin
  inherited;
  if (csDestroying in ComponentState) then
    Exit;
  if FLabel <> nil then
    UpdateLabel;
end;

procedure TAdvCustomCombo.SetFlatLineColor(const Value: TColor);
begin
  FFlatLineColor := Value;
  Invalidate;
end;

procedure TAdvCustomCombo.SetFlatParentColor(const Value: Boolean);
begin
  FFlatParentColor := Value;
  Invalidate;
end;

function TAdvCustomCombo.GetColorEx: TColor;
begin
  Result := inherited Color;
end;

procedure TAdvCustomCombo.SetColorEx(const Value: TColor);
begin
  if (csLoading in ComponentState) then
    FLoadedColor := Value;

  inherited Color := Value;
end;

function TAdvCustomCombo.GetEnabledEx: Boolean;
begin
  Result := inherited Enabled;
end;

procedure TAdvCustomCombo.SetEnabledEx(const Value: Boolean);
var
  OldValue: Boolean;

begin
  OldValue := inherited Enabled;

  inherited Enabled := Value;

  if (csLoading in ComponentState) or
     (csDesigning in ComponentState) then
    Exit;

  if OldValue <> Value then
  begin
    if Assigned(FLabel) then
      if not FLabelAlwaysEnabled then
      begin
        FLabel.Enabled := Value;
        UpdateLabel;
      end;
  end;
end;

function TAdvCustomCombo.GetVersionEx: string;
var
  vn: Integer;
begin
  vn := GetVersionNr;
  Result := IntToStr(Hi(Hiword(vn)))+'.'+IntToStr(Lo(Hiword(vn)))+'.'+IntToStr(Hi(Loword(vn)))+'.'+IntToStr(Lo(Loword(vn)));
end;

function TAdvCustomCombo.GetVersionNr: Integer;
begin
  Result := MakeLong(MakeWord(BLD_VER,REL_VER),MakeWord(MIN_VER,MAJ_VER));
end;

procedure TAdvCustomCombo.SetVersion(const Value: string);
begin

end;

function TAdvCustomCombo.GetVisibleEx: boolean;
begin
  Result := inherited Visible;
end;

procedure TAdvCustomCombo.SetVisibleEx(const Value: boolean);
begin
  inherited Visible := Value;
  if Assigned(FLabel) then
    FLabel.Visible := Value;
end;

procedure TAdvCustomCombo.WMKillFocus(var Message: TWMKillFocus);
begin
  inherited;

  if (FFocusColor <> clNone) and (FNormalColor <> clNone) then
    Color := FNormalColor;

  if FIsWinXP then
  begin
    Width := Width + 1;
    Width := Width - 1;
  end;

  if FFocusLabel and (FLabel <> nil) then
    FLabel.Font.Style := FLabel.Font.Style - [fsBold];

  Invalidate;
end;

procedure TAdvCustomCombo.WMSetFocus(var Message: TWMSetFocus);
begin
  inherited;

  if FFocusBorderColor <> clNone then
   Invalidate;

  if FFocusColor <> clNone then
  begin
    inherited Color := FFocusColor;
    if FIsWinXP then
    begin
      Width := Width + 1;
      Width := Width - 1;
    end;
  end;

  if FFocusLabel and (FLabel <> nil) then
    FLabel.Font.Style := FLabel.Font.Style + [fsBold];
end;

{$IFDEF FREEWARE}
{$I TRIAL.INC}
{$ENDIF}

end.

