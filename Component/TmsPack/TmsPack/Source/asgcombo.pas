{*********************************************************************}
{ TASGComboBox component for TAdvStringGrid                           }
{ for Delphi & C++Builder                                             }
{                                                                     }
{ written by                                                          }
{  TMS Software                                                       }
{  copyright © 2001 - 2009                                            }
{  Email : info@tmssoftware.com                                       }
{  Web : http://www.tmssoftware.com                                   }
{                                                                     }
{ The source code is given as is. The author is not responsible       }
{ for any possible damage done due to the use of this code.           }
{ The component can be freely used in any application. The source     }
{ code remains property of the author and may not be distributed      }
{ freely as such.                                                     }
{*********************************************************************}

unit asgcombo;

{$I TMSDEFS.INC}

interface

uses
  Windows, Messages, Classes, Forms, Controls, Graphics, StdCtrls, SysUtils
  {$IFNDEF TMSDOTNET}
  , AdvXPVS
  {$ENDIF}
  {$IFDEF TMSDOTNET}
  , uxTheme
  {$ENDIF}
  ;

const
  MAJ_VER = 1; // Major version nr.
  MIN_VER = 2; // Minor version nr.
  REL_VER = 0; // Release nr.
  BLD_VER = 1; // Build nr.

  // 1.2.0.1 : Improved combo dropdown button appearance

type
  TASGCustomCombo = class(TCustomComboBox)
  private
    FAutoFocus: boolean;
    FFlat: Boolean;
    FEtched: Boolean;
    FOldColor: TColor;
    FOldParentColor: Boolean;
    FButtonWidth: Integer;
    FFocusBorder: Boolean;
    FMouseInControl: Boolean;
    FDropWidth: integer;
    FIsWinXP: Boolean;
    FIsVista: Boolean;
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
    {$ENDIF}
    procedure SetDropWidth(const Value: integer);
    function GetVersion: string;
    procedure SetVersion(const Value: string);
  protected
    function GetVersionNr: Integer; virtual;
    {$IFDEF TMSDOTNET}
    procedure WndProc(var Message: TMessage); override;
    {$ENDIF}
    property ButtonWidth: Integer read FButtonWidth write SetButtonWidth;
    property Flat: Boolean read FFlat write SetFlat;
    property Etched: Boolean read FEtched write SetEtched;
    property FocusBorder: Boolean read FFocusBorder write FFocusBorder;
    property AutoFocus: Boolean read FAutoFocus write FAutoFocus;
    property DropWidth: integer read fDropWidth write SetDropWidth;
  public
    property IsWinXP: Boolean read FIsWinXP write FIsWinXP;
    property IsVista: Boolean read FIsVista write FIsVista;
    constructor Create(AOwner: TComponent); override;
    property Version: string read GetVersion write SetVersion;
  end;

  TASGComboBox = class(TASGCustomCombo)
  published
    property Align;
    property AutoFocus;
    property ButtonWidth;
    property Style;
    property Flat;
    property Etched;
    property FocusBorder;
    property Color;
    property Ctl3D;
    property DragCursor;
    property DragMode;
    property DropDownCount;
    property DropWidth;
    property Enabled;
    property Font;
    {$IFNDEF DELPHI2_LVL}
    property ImeMode;
    property ImeName;
    {$ENDIF}
    property ItemHeight;
    property Items;
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
    property OnEndDrag;
    property OnEnter;
    property OnExit;
    property OnKeyDown;
    property OnKeyPress;
    property OnKeyUp;
    property OnMeasureItem;
    property OnStartDrag;
    {$IFDEF DELPHI4_LVL}
    property Anchors;
    property BiDiMode;
    property Constraints;
    property DragKind;
    property ParentBiDiMode;
    property OnEndDock;
    property OnStartDock;
    {$ENDIF}
    property Version;
  end;


implementation

{ TASGCustomCombo }

constructor TASGCustomCombo.Create(AOwner: TComponent);
begin
  inherited;
  FButtonWidth := GetSystemMetrics(SM_CXVSCROLL) + 4;
  FOldColor := inherited Color;
  FOldParentColor := inherited ParentColor;
  FFlat := True;
  FMouseInControl := False;
end;

procedure TASGCustomCombo.SetButtonWidth(const Value: integer);
begin
  if (value < 14) or (value > 32) then Exit;
  FButtonWidth := Value;
  Invalidate;
end;

procedure TASGCustomCombo.SetFlat(const Value: Boolean);
begin
  if Value<>FFlat then
  begin
    FFlat := Value;
    Ctl3D := not Value;
    Invalidate;
  end;
end;

procedure TASGCustomCombo.SetEtched(const Value: Boolean);
begin
  if Value <> FEtched then
  begin
    FEtched := Value;
    Invalidate;
  end;
end;

procedure TASGCustomCombo.CMEnter(var Message: TCMEnter);
begin
  inherited;
  if not (csDesigning in ComponentState) then
    DrawBorders;
end;

procedure TASGCustomCombo.CMExit(var Message: TCMExit);
begin
  inherited;
  if not (csDesigning in ComponentState) then
    DrawBorders;
end;

procedure TASGCustomCombo.CMMouseEnter(var Message: TMessage);
begin
  inherited;
  if not FMouseInControl and Enabled then
  begin
    FMouseInControl := True;
    DrawBorders;
  end;
  if FAutoFocus then
    Self.SetFocus;
end;

procedure TASGCustomCombo.CMMouseLeave(var Message: TMessage);
begin
  inherited;
  if FMouseInControl and Enabled then
  begin
    FMouseInControl := False;
    DrawBorders;
  end;
end;

procedure TASGCustomCombo.CMEnabledChanged(var Msg: TMessage);
begin
  if FFlat then
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
  inherited;
end;

{$IFNDEF TMSDOTNET}
procedure TASGCustomCombo.WMNCPaint(var Message: TMessage);
begin
  inherited;
  if FFlat then
    DrawBorders;
end;
{$ENDIF}

{$IFDEF TMSDOTNET}
procedure TASGCustomCombo.WndProc(var Message: TMessage);
begin
  inherited;
  if Message.Msg = WM_NCPAINT then
    if FFlat then
      DrawBorders;
end;
{$ENDIF}

//  Returns a "True" if a Mouse button happens to be down.
function IsMouseButtonDown:Boolean;
begin
  // Note: Key state is read twice because the first time you read it, you learn
  // if the bittpm has been pressed ever.  The second time you read it you learn if
  // the button is currently pressed.

  if ((GetAsyncKeyState(VK_RBUTTON)and $8000) = 0) and
     ((GetAsyncKeyState(VK_LBUTTON)and $8000) = 0) then
  begin
    // Mouse buttons are up
    Result := False;
  end
  else
  begin
    // Mouse buttons are up
    Result := True;
  end;
end;

procedure TASGCustomCombo.WMPaint(var Message: TWMPaint);
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

    Inc(ARect.Left, ClientWidth - FButtonWidth);

    if FIsWinXP then // windows XP style combo dropdown
    begin
      {$IFNDEF TMSDOTNET}
      InflateRect(ARect,-1,-1);
      htheme := OpenThemeData(Handle,'combobox');
      if IsMouseButtonDown then
        DrawThemeBackground(htheme,DC,CP_DROPDOWNBUTTON,CBXS_PRESSED,@ARect,nil)
      else
        DrawThemeBackground(htheme,DC,CP_DROPDOWNBUTTON,CBXS_NORMAL,@ARect,nil);
      CloseThemeData(htheme);
      {$ENDIF}

      {$IFDEF TMSDOTNET}
      InflateRect(ARect,-1,-1);
      htheme := OpenThemeData(Handle,'combobox');
      if IsMouseButtonDown then
        DrawThemeBackground(htheme,DC,CP_DROPDOWNBUTTON,CBXS_PRESSED,ARect,nil)
      else
        DrawThemeBackground(htheme,DC,CP_DROPDOWNBUTTON,CBXS_NORMAL,ARect,nil);
      CloseThemeData(htheme);
      {$ENDIF}
    end
    else
    begin  // normal style combo dropdown
      InflateRect(ARect, 0, -1);
      OffsetRect(ARect, -2,1);

      DrawFrameControl(DC, ARect, DFC_SCROLL, DFCS_SCROLLCOMBOBOX or DFCS_FLAT );

      ExcludeClipRect(DC, ClientWidth - FButtonWidth - 4 , 0, ClientWidth + 2, ClientHeight);
    end;
  end;

begin
  if FIsVista then
  begin
    inherited;
    Exit;
  end;

  if not FFlat then
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
      if (BidiMode = bdLeftToRight) then
        DrawButton;
    end;
    PaintWindow(DC);
  finally
    if Message.DC = 0 then
      EndPaint(Handle, PS);
  end;
  DrawBorders;
end;

function TASGCustomCombo.Is3DBorderControl: Boolean;
begin
  if csDesigning in ComponentState then
    Result := False
  else
    Result := FMouseInControl or (Screen.ActiveControl = Self);

  Result := Result and FFocusBorder;
end;

function TASGCustomCombo.Is3DBorderButton: Boolean;
begin
  if csDesigning in ComponentState then
    Result := Enabled
  else
    Result := FMouseInControl or (Screen.ActiveControl = Self);
end;

procedure TASGCustomCombo.DrawButtonBorder(DC: HDC);
const
  Flags: array[Boolean] of Integer = (0, BF_FLAT);
  Edge: array[Boolean] of Integer = (EDGE_RAISED,EDGE_ETCHED);
var
  ARect: TRect;
  BtnFaceBrush: HBRUSH;
begin
  if FIsWInXP then
    Exit;

  ExcludeClipRect(DC, ClientWidth - FButtonWidth + 4, 4, ClientWidth - 4, ClientHeight - 4);

  GetWindowRect(Handle, ARect);
  OffsetRect(ARect, -ARect.Left, -ARect.Top);
  Inc(ARect.Left, ClientWidth - FButtonWidth - 4);

  InflateRect(ARect, -2, -2);

  if Is3DBorderButton or (1>0) then
  begin
    ARect.Bottom := ARect.Bottom + 2;
    ARect.Right := ARect.Right + 1;
    // DrawEdge(DC, ARect, Edge[Etched], BF_RECT or Flags[DroppedDown])
    DrawEdge(DC, ARect, Edge[Etched], BF_RECT)
  end
  else
  begin
    BtnFaceBrush := CreateSolidBrush(GetSysColor(COLOR_BTNFACE));
    InflateRect(ARect, 0, 0);
    OffsetRect(ARect,-2,0);
    ARect.Right := ARect.Right - 1;
    FillRect(DC, ARect, BtnFaceBrush);
    DeleteObject(BtnFaceBrush);
  end;

  ExcludeClipRect(DC, ARect.Left, ARect.Top, ARect.Right, ARect.Bottom);
end;

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


procedure TASGCustomCombo.DrawControlBorder(DC: HDC);
var
  ARect:TRect;
  BtnFaceBrush, WindowBrush: HBRUSH;
  flg: Boolean;


  function IsThemedApp: Boolean;
  var
    i: Integer;
  begin
    // app is linked with COMCTL32 v6 or higher -> xp themes enabled
    i := GetFileVersion('COMCTL32.DLL');
    i := (i shr 16) and $FF;
    Result := (i > 5);
  end;

begin
  if Is3DBorderControl then
    BtnFaceBrush := CreateSolidBrush(GetSysColor(COLOR_BTNFACE))
  else
    BtnFaceBrush := CreateSolidBrush(ColorToRGB((parent as TWinControl).brush.color));

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

      flg := false;

      if IsWinXP then
        flg := IsThemedApp;

      if not flg then
      begin
        InflateRect(ARect, -1, -1);
        FrameRect(DC, ARect, BtnFaceBrush);
      end;

      // InflateRect(ARect, -1, -1);
      // FrameRect(DC, ARect, WindowBrush);
    end;
  finally
    DeleteObject(WindowBrush);
    DeleteObject(BtnFaceBrush);
  end;
end;

procedure TASGCustomCombo.DrawBorders;
var
  DC: HDC;
begin
  if not FFlat then
    Exit;

  if FIsVista then
    Exit;

  DC := GetWindowDC(Handle);
  try
    DrawControlBorder(DC);
    if (Style <> csSimple) then
      if BidiMode = bdLeftToRight then
      
      DrawButtonBorder(DC);
  finally
    ReleaseDC(Handle,DC);
  end;
end;

procedure TASGCustomCombo.CNCommand(var Message: TWMCommand);
var
  r:TRect;
begin
  inherited;
  if Message.NotifyCode in [CBN_CLOSEUP,CBN_DROPDOWN] then
  begin
    r := GetClientRect;
    r.left := r.Right - FButtonWidth;
    {$IFNDEF TMSDOTNET}
    InvalidateRect(Handle,@r,FALSE);
    {$ENDIF}
    {$IFDEF TMSDOTNET}
    InvalidateRect(Handle,r,FALSE);
    {$ENDIF}
  end;
end;

procedure TASGCustomCombo.SetDropWidth(const Value: integer);
begin
  FDropWidth := Value;
  if value > 0 then
    SendMessage(self.Handle,CB_SETDROPPEDWIDTH,FDropWidth,0);
end;

function TAsgCustomCombo.GetVersion: string;
var
  vn: Integer;
begin
  vn := GetVersionNr;
  Result := IntToStr(Hi(Hiword(vn)))+'.'+IntToStr(Lo(Hiword(vn)))+'.'+IntToStr(Hi(Loword(vn)))+'.'+IntToStr(Lo(Loword(vn)));
end;

function TAsgCustomCombo.GetVersionNr: Integer;
begin
  Result := MakeLong(MakeWord(BLD_VER,REL_VER),MakeWord(MIN_VER,MAJ_VER));
end;

procedure TAsgCustomCombo.SetVersion(const Value: string);
begin

end;

end.

