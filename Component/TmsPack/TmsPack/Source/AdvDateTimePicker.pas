{*************************************************************************}
{ TAdvDateTimePicker component                                            }
{ for Delphi & C++Builder                                                 }
{                                                                         }
{ written by TMS Software                                                 }
{           copyright © 2007 - 2010                                       }
{           Email : info@tmssoftware.com                                  }
{           Website : http://www.tmssoftware.com/                         }
{                                                                         }
{ The source code is given as is. The author is not responsible           }
{ for any possible damage done due to the use of this code.               }
{ The component can be freely used in any application. The complete       }
{ source code remains property of the author and may not be distributed,  }
{ published, given or sold in any form as such. No parts of the source    }
{ code can be included in any other component or application without      }
{ written authorization of the author.                                    }
{*************************************************************************}

unit AdvDateTimePicker;

{$I TMSDEFS.INC}

interface
                
uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ComCtrls, CommCtrl, ExtCtrls
  {$IFDEF TMSDOTNET}
  ,System.Drawing
  ,System.Text
  {$ENDIF}
  ;

const
  MAJ_VER = 1; // Major version nr.
  MIN_VER = 1; // Minor version nr.
  REL_VER = 0; // Release nr.
  BLD_VER = 0; // Build nr.

  // version history
  // v1.0.0.0 : First release
  // v1.0.0.1 : Fixed issue with DB-aware version
  // v1.0.0.2 : Improved : force milliseconds to zero
  // v1.0.0.3 : Improved : position of internal datetimepickers with XP theming enabled
  // v1.0.0.4 : Fixed : issue with DB aware version
  // v1.0.0.5 : Fixed : issue with timeformat setting
  // v1.0.0.6 : Fixed : issue with use in VCL.NET
  // v1.0.0.7 : Fixed : issue with initializing time in older Delphi versions
  // v1.0.0.8 : Fixed : issue with setting Checked = false at design time
  // v1.0.1.0 : New : automatic handling of checkbox with DB-aware component for null dates
  // v1.0.2.0 : New : AutoTab : when true, tabbing between date & time entry is automatic
  // v1.0.2.1 : Fixed : issue with AutoTab
  // v1.0.3.0 : Improved : support to be used as timepicker only
  // v1.0.4.0 : Improved : painting for Vista / Win7 with standard theme
  // v1.1.0.0 : New : Label property added

  DROPDOWNBTN_WIDTH = 21;

type
  TAdvDateTimeKind = (dkDate, dkTime, dkDateTime);
  TLabelPosition = (lpLeftTop, lpLeftCenter, lpLeftBottom, lpTopLeft, lpBottomLeft,
    lpLeftTopLeft, lpLeftCenterLeft, lpLeftBottomLeft, lpTopCenter, lpBottomCenter,
    lpRightTop, lpRightCenter, lpRighBottom);

  TCustomDateTimePicker = class(TDateTimePicker)
  private
    FBorderStyle: TBorderStyle;
    FBorderColor: TColor;
    FIsThemed: Boolean;
    {$IFDEF DELPHI6_LVL}
    FAutoTab: Boolean;
    Fh, Fm, Fs, Fms: Word;
    {$ENDIF}
    procedure WMKeyDown(var Message: TWMKeyDown); message WM_KEYDOWN;
    procedure WMSize(var Message: TWMSize); message WM_SIZE;
    procedure WMNCPaint(var Message: TMessage); message WM_NCPAINT;
    procedure WMPaint(var Message: TWMPaint); message WM_PAINT;
    procedure CMCtl3DChanged(var Message: TMessage); message CM_CTL3DCHANGED;
    procedure NCPaintProc;
    procedure SetBorderColor(const Value: TColor);
  protected
    procedure CreateParams(var Params: TCreateParams); override;
    procedure CreateWnd; override;
    procedure WndProc(var Message: TMessage); override;
    procedure KeyPress(var Key: Char); override;
    {$IFDEF DELPHI6_LVL}
    procedure ShiftFocus; virtual;
    procedure SetAutoTab(const Value: Boolean); virtual;
    {$ENDIF}
    function IsInnerCtrl: Boolean; virtual;
    procedure SetBorderStyle(const Value: TBorderStyle); virtual;
    property BorderStyle: TBorderStyle read FBorderStyle write SetBorderStyle;
    property BorderColor: TColor read FBorderColor write SetBorderColor default clBlack;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  published
    {$IFDEF DELPHI6_LVL}
    property AutoTab: Boolean read FAutoTab write SetAutoTab default False;
    {$ENDIF}
  end;

  TAdvDateTimePicker = class(TCustomDateTimePicker)
  private
    FKind: TAdvDateTimeKind;
    FOnTimeChange: TNotifyEvent;
    FTimeFormat: string;
    FFocusTimer: TTimer;
    Fpt: TPoint;
{$IFDEF DELPHI6_LVL}
    Fy, Fm, Fd: word;
{$ENDIF}
    FLabel: TLabel;
    FLabelFont: TFont;
    FLabelPosition: TLabelPosition;
    FLabelMargin: Integer;
    FLabelTransparent: Boolean;
    FFocusLabel: Boolean;
    FLabelAlwaysEnabled: Boolean;
    FOnLabelClick: TNotifyEvent;
    FOnLabelDblClick: TNotifyEvent;
    FParentFnt: boolean;
    procedure OnTimePickerChanged(Sender: TObject);
    procedure OnTimePickerClicked(Sender: TObject);
    procedure WMKeyDown(var Message: TWMKeyDown); message WM_KEYDOWN;
    procedure WMSize(var Message: TWMSize); message WM_SIZE;
    procedure SetKind(const Value: TAdvDateTimeKind);
    procedure CMColorChanged(var Message: TMessage); message CM_COLORCHANGED;
    procedure CMEnabledChanged(var Message: TMessage); message CM_ENABLEDCHANGED;
{$IFNDEF TMSDOTNET}
    procedure CNNotify(var Message: TWMNotify); message CN_NOTIFY;
    procedure CMParentFontChanged(var Message: TMessage); message CM_PARENTFONTCHANGED;
{$ENDIF}
    procedure CMFontChanged(var Message: TMessage); message CM_FONTCHANGED;
    procedure WMSetFocus(var Msg: TWMSetFocus); message WM_SETFOCUS;
    procedure WMKillFocus(var Msg: TWMKillFocus); message WM_KILLFOCUS;
    procedure CMShowingChanged(var Message: TMessage); message CM_SHOWINGCHANGED;
    procedure CMVisibleChanged(var Message: TMessage); message CM_VISIBLECHANGED;
    procedure OnFocusTimerTime(Sender: TObject);
    function GetTimeEx: TTime;
    procedure SetTimeEx(const Value: TTime);
    function GetDateTimeEx: TDateTime;
{$IFDEF DELPHI6_LVL}
    function GetFormatEx: String;
    procedure SetFormatEx(const Value: String);
    function GetTimeFormat: String;
    procedure SetTimeFormat(const Value: String);
{$ENDIF}
    function GetVersion: string;
    procedure SetVersion(const Value: string);
    procedure LabelFontChange(Sender: TObject);
    procedure SetLabelFont(const Value: TFont);
    procedure SetLabelCaption(const value: string);
    function GetLabelCaption: string;
    procedure SetLabelPosition(const value: TLabelPosition);
    procedure SetLabelMargin(const value: integer);
    procedure SetLabelTransparent(const value: boolean);
    procedure UpdateLabel;
    procedure SetLabelAlwaysEnabled(const Value: Boolean);
  protected
    FTimePicker: TCustomDateTimePicker;
    {$IFDEF DELPHI6_LVL}
    procedure ShiftFocus; override;
    procedure SetAutoTab(const Value: Boolean); override;
    {$ENDIF}
    procedure CreateTimePicker;
    procedure UpdateTimePicker;
    procedure Loaded; override;
    procedure SetBorderStyle(const Value: TBorderStyle); override;
    procedure CreateWnd; override;
    procedure KeyPress(var Key: Char); override;
    procedure SetParent(AParent: TWinControl); override;
    procedure TimePickerChanged; virtual;
    procedure TimePickerClicked; virtual;
    procedure SetDateTimeEx(const Value: TDateTime); virtual;
    procedure TimePickerKeyPress(Sender: TObject; var Key: Char); virtual;
    procedure TimePickerKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);

    function CreateLabel: TLabel;
    procedure LabelClick(Sender: TObject);
    procedure LabelDblClick(Sender: TObject);

    procedure Change; override;
    function IsInnerCtrl: Boolean; override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure SetBounds(ALeft, ATop, AWidth, AHeight: Integer); override;
    property BorderColor;
    function GetVersionNr: integer;

    property PickerLabel: TLabel read FLabel;
    property OnTimeChange: TNotifyEvent read FOnTimeChange write FOnTimeChange;
  published
    property BorderStyle;
    property Ctl3D;
    property DateTime: TDateTime read GetDateTimeEx write SetDateTimeEx;
    {$IFDEF DELPHI6_LVL}
    property Format: String read GetFormatEx write SetFormatEx;
    property TimeFormat: String read GetTimeFormat write SetTimeFormat;
    {$ENDIF}
    property Kind: TAdvDateTimeKind read FKind write SetKind;
    property Time: TTime read GetTimeEx write SetTimeEx;
    property Version: string read GetVersion write SetVersion;

    property FocusLabel: Boolean read FFocusLabel write FFocusLabel default false;
    property LabelCaption: string read GetLabelCaption write SetLabelCaption;
    property LabelPosition: TLabelPosition read FLabelPosition write SetLabelPosition default lpLeftTop;
    property LabelMargin: Integer read FLabelMargin write SetLabelMargin default 4;
    property LabelTransparent: Boolean read FLabelTransparent write SetLabelTransparent default False;
    property LabelAlwaysEnabled: Boolean read FLabelAlwaysEnabled write SetLabelAlwaysEnabled default False;
    property LabelFont: TFont read FLabelFont write SetLabelFont;
    property OnLabelClick: TNotifyEvent read FOnLabelClick write FOnLabelClick;
    property OnLabelDblClick: TNotifyEvent read FOnLabelDblClick write FOnLabelDblClick;
  end;

implementation

uses
  ComStrs
  {$IFDEF DELPHI7_LVL}
  , uxtheme
  {$ENDIF}
  ;

{$IFDEF DELPHI6_LVL}
var
  WM_DTPSHIFTFOCUS: Word;
{$ENDIF}

//------------------------------------------------------------------------------

{$IFNDEF TMSDOTNET}
function IsVista: boolean;
var
  hKernel32: HMODULE;
begin
  hKernel32 := GetModuleHandle('kernel32');
  if (hKernel32 > 0) then
  begin
    Result := GetProcAddress(hKernel32, 'GetLocaleInfoEx') <> nil;
  end
  else
    Result := false;
end;

//------------------------------------------------------------------------------


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

//------------------------------------------------------------------------------

function IsComCtl6: Boolean;
var
  i: Integer;
begin
  i := GetFileVersion('COMCTL32.DLL');
  i := (i shr 16) and $FF;

  Result := (i > 5);
end;

//------------------------------------------------------------------------------

function GetTextSize(WinCtrl: TWinControl; Text: string; font: TFont): TSize;
var
  Canvas: TCanvas;
  R: TRect;
begin
  Canvas := TCanvas.Create;
  Canvas.Handle := GetWindowDC(WinCtrl.Handle);
  Canvas.Font.Assign(font);

  {$IFNDEF TMSDOTNET}
  R := Rect(0, 0, 1000, 200);
  DrawText(Canvas.Handle,PChar(Text),Length(Text), R, DT_CALCRECT or DT_LEFT or DT_SINGLELINE);
  {$ELSE}
  R := TRect.Create(0,0,1000,200);
  DrawText(Canvas.Handle,Text,Length(Text), R, DT_CALCRECT or DT_LEFT or DT_SINGLELINE);
  {$ENDIF}
  Result.cx := R.Right - R.Left;
  Result.cy := R.Bottom - R.Top;
  ReleaseDC(WinCtrl.Handle, Canvas.Handle);
  Canvas.Free;
end;

//------------------------------------------------------------------------------

{ TCustomDateTimePicker }

constructor TCustomDateTimePicker.Create(AOwner: TComponent);
var
  i: Integer;
begin
  inherited;
  DoubleBuffered := True;
  ParentCtl3D := False;
  Ctl3D := false;
  FBorderStyle := bsNone;
  FBorderColor := clBlack;
  i := GetFileVersion('COMCTL32.DLL');
  i := (i shr 16) and $FF;
  FIsThemed := (i > 5);
  //CalExceptionClass := nil;
  {$IFDEF DELPHI6_LVL}
  FAutoTab := False;
  {$ENDIF}
end;

//------------------------------------------------------------------------------

destructor TCustomDateTimePicker.Destroy;
begin
  inherited;
end;

//------------------------------------------------------------------------------

function TCustomDateTimePicker.IsInnerCtrl: Boolean;
begin
  Result := True;
end;

//------------------------------------------------------------------------------

procedure TCustomDateTimePicker.CreateParams(var Params: TCreateParams);
begin
  inherited CreateParams(Params);
  with Params do
  begin
  end;
end;

//------------------------------------------------------------------------------

procedure TCustomDateTimePicker.CreateWnd;
begin
  inherited;
end;

//------------------------------------------------------------------------------

procedure TCustomDateTimePicker.NCPaintProc;
var
  DC: HDC;
  //WindowBrush:hBrush;
  Canvas: TCanvas;

begin
  if Ctl3D then
    Exit;

  DC := GetWindowDC(Handle);
  //WindowBrush := 0;
  try
    Canvas := TCanvas.Create;
    Canvas.Handle := DC;

    //WindowBrush := CreateSolidBrush(ColorToRGB(clRed));

    if (BorderStyle = bsNone) and (Parent is TWinControl) then
      Canvas.Pen.Color := (Parent as TWinControl).Brush.Color
    else
    begin
      if FIsThemed then
        Canvas.Pen.Color := $B99D7F
      else
        Canvas.Pen.Color := BorderColor;
    end;

    Canvas.MoveTo(0,Height);
    Canvas.LineTo(0,0);
    Canvas.LineTo(Width - 1,0);
    Canvas.LineTo(Width - 1,Height - 1);
    Canvas.LineTo(0,Height-1);

    if (BorderStyle = bsSingle) and (Parent is TWinControl) then
      Canvas.Pen.Color := (Parent as TWinControl).Brush.Color;

    if (BorderStyle in [bsNone, bsSingle]) and (Parent is TWinControl) then
    begin
      Canvas.MoveTo(1,Height - 2);
      Canvas.LineTo(1,1);
      Canvas.LineTo(Width - 1,1);
    end;

    Canvas.Free;

    // FrameRect(DC, ARect, WindowBrush);
  finally
    //DeleteObject(WindowBrush);
    ReleaseDC(Handle,DC);
  end;
end;

//------------------------------------------------------------------------------

procedure TCustomDateTimePicker.WMNCPaint(var Message: TMessage);
begin
  inherited;
  NCPaintProc;
  Message.Result := 0;
end;

//------------------------------------------------------------------------------

procedure TCustomDateTimePicker.WMPaint(var Message: TWMPaint);
var
  DC: HDC;
  ACanvas: TCanvas;

begin
  inherited;

  {$IFNDEF TMSDOTNET}
  if Ctl3D or not IsVista then
    Exit;

  DC := GetWindowDC(Handle);
  ACanvas := TCanvas.Create;

  try
    ACanvas.Handle := DC;

    if (BorderStyle = bsNone) and (Parent is TWinControl) then
      ACanvas.Pen.Color := (Parent as TWinControl).Brush.Color
    else
    begin
      if FIsThemed then
        ACanvas.Pen.Color := $B99D7F
      else
        ACanvas.Pen.Color := BorderColor;
    end;

    ACanvas.MoveTo(0,Height);
    ACanvas.LineTo(0,0);
    ACanvas.LineTo(Width - 1,0);
    ACanvas.LineTo(Width - 1,Height - 1);
    ACanvas.LineTo(0,Height-1);

    {$IFDEF DELPHI7_LVL}
    if IsVista and not IsThemeActive then  // for Windows standard scheme
    begin
      ACanvas.MoveTo(1,Height);
      ACanvas.LineTo(1,1);
      ACanvas.LineTo(Width - 2, 1);
      ACanvas.LineTo(Width - 2, Height - 2);
      ACanvas.LineTo(0 ,Height-2);
    end;
    {$ENDIF}
  finally
    ACanvas.Free;
    ReleaseDC(Handle,DC);
  end;
  {$ENDIF}
end;

//------------------------------------------------------------------------------
procedure TCustomDateTimePicker.WMSize(var Message: TWMSize);
begin
  inherited;
end;

//------------------------------------------------------------------------------

procedure TCustomDateTimePicker.WndProc(var Message: TMessage);
begin
  {$IFDEF DELPHI6_LVL}
  if (Message.Msg = WM_DTPSHIFTFOCUS) then
    ShiftFocus;
  {$ENDIF}

  inherited;
end;

//------------------------------------------------------------------------------

procedure TCustomDateTimePicker.KeyPress(var Key: Char);
begin
  {$IFDEF DELPHI6_LVL}
  if (Integer(Key) in [48..57]) and AutoTab then
  begin
    if (Kind = dtkTime) then
      DecodeTime(DateTime, Fh, Fm, Fs, Fms);
    inherited;
    PostMessage(Handle, WM_DTPSHIFTFOCUS, 0, 0);
  end
  else
  {$ENDIF}
    inherited;
end;

//------------------------------------------------------------------------------

procedure TCustomDateTimePicker.WMKeyDown(var Message: TWMKeyDown);
begin
  inherited;
end;

//------------------------------------------------------------------------------

{$IFDEF DELPHI6_LVL}
procedure TCustomDateTimePicker.ShiftFocus;
var
  h, m, s, ms: word;
begin
  if (Kind = dtkTime) then
  begin
    DecodeTime(DateTime, h, m, s, ms);

    if (h <> Fh) or (m <> Fm) or (s <> Fs) then
      PostMessage(Handle, WM_KEYDOWN, VK_RIGHT, 0);
  end;
end;
{$ENDIF}

//------------------------------------------------------------------------------

procedure TCustomDateTimePicker.SetBorderStyle(const Value: TBorderStyle);
begin
  if (FBorderStyle <> Value) then
  begin
    FBorderStyle := Value;
    {if (FBorderStyle = bsCtl3D) then
    begin
      ParentCtl3D := True;
      Ctl3D := True;
    end
    else if Ctl3D then
    begin
      ParentCtl3D := False;
      Ctl3D := false;
    end;
    }
    Invalidate;
  end;
end;

//------------------------------------------------------------------------------
{$IFDEF DELPHI6_LVL}
procedure TCustomDateTimePicker.SetAutoTab(const Value: Boolean);
begin
  FAutoTab := Value;
end;
{$ENDIF}

//------------------------------------------------------------------------------

procedure TCustomDateTimePicker.SetBorderColor(const Value: TColor);
begin
  if (FBorderColor <> Value) then
  begin
    FBorderColor := Value;
    Invalidate;
  end;
end;

//------------------------------------------------------------------------------

procedure TCustomDateTimePicker.CMCtl3DChanged(var Message: TMessage);
begin
  inherited;
  Invalidate;
end;

//------------------------------------------------------------------------------

{ TAdvDateTimePicker }

procedure TAdvDateTimePicker.CMEnabledChanged(var Message: TMessage);
begin
  inherited;
  if Assigned(FTimePicker) then
    FTimePicker.Enabled := Enabled;

  if Assigned(FLabel) then
    if not FLabelAlwaysEnabled then
      FLabel.Enabled := Enabled;
end;

//------------------------------------------------------------------------------

procedure TAdvDateTimePicker.CMFontChanged(var Message: TMessage);
begin
  if (csDesigning in ComponentState) or (csLoading in ComponentState) then
    if (FLabel <> nil) and ParentFont then
    begin
      FLabel.Font.Assign(self.font);
    end;

  inherited;
end;

//------------------------------------------------------------------------------

procedure TAdvDateTimePicker.CMShowingChanged(var Message: TMessage);
begin
  inherited;
  if (FLabel <> nil) then FLabel.Visible := Visible;
end;

//------------------------------------------------------------------------------

procedure TAdvDateTimePicker.CMVisibleChanged(var Message: TMessage);
begin
  inherited;
  if (FLabel <> nil) then FLabel.Visible := Visible;
end;

//------------------------------------------------------------------------------

constructor TAdvDateTimePicker.Create(AOwner: TComponent);
begin
  inherited;
  {
  if (inherited Kind = dtkDate) then
    FKind := dkDateTime
  else
    FKind := dkTime;
  }
  FLabel := nil;
  FLabelMargin := 4;
  FTimePicker := nil;
  FKind := dkDateTime;
  //CreateTimePicker;
  BorderStyle := bsSingle;
  Ctl3D := true;
  FFocusTimer := TTimer.Create(Self);
  FFocusTimer.Enabled := False;
  FFocusTimer.Interval := 20;
  FFocusTimer.OnTimer := OnFocusTimerTime;
  FLabelFont := TFont.Create;
  FLabelFont.OnChange := LabelFontChange;
  FParentFnt := false;
end;

//------------------------------------------------------------------------------

function TAdvDateTimePicker.CreateLabel: TLabel;
begin
  Result := Tlabel.Create(self);
  Result.Parent := self.Parent;
  Result.FocusControl := self;
  Result.Font.Assign(LabelFont);
  Result.OnClick := LabelClick;
  Result.OnDblClick := LabelDblClick;
  Result.ParentFont := self.ParentFont;
end;

//------------------------------------------------------------------------------

procedure TAdvDateTimePicker.CreateTimePicker;
begin
  if not Assigned(FTimePicker) and (FKind = dkDateTime) then
  begin
    FTimePicker := TCustomDateTimePicker.Create(Self);
    if not ((csLoading in ComponentState) and (csDesigning in ComponentState)) then
      FTimePicker.Parent := Self;
    FTimePicker.Width := 90;
    FTimePicker.Height := 17;
    FTimePicker.Visible := False;
    FTimePicker.Enabled := Enabled;
    FTimePicker.Kind := dtkTime;
    FTimePicker.OnChange := OnTimePickerChanged;
    FTimePicker.OnClick := OnTimePickerClicked;
    FTimePicker.OnKeyPress := TimePickerKeyPress;
    FTimePicker.OnKeyDown := TimePickerKeyDown;
  end;
end;

//------------------------------------------------------------------------------

procedure TAdvDateTimePicker.CreateWnd;
var
  oldKind: TAdvDateTimeKind;
begin
  inherited;
  oldKind := FKind;
  FKind := dkDate;
  Kind := oldKind;
end;

//------------------------------------------------------------------------------

procedure TAdvDateTimePicker.UpdateLabel;
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

//------------------------------------------------------------------------------

procedure TAdvDateTimePicker.UpdateTimePicker;
var
  i,j: Integer;
  {$IFNDEF TMSDOTNET}
  lpstr: array[0..255] of char;
  {$ELSE}
  lpstr: StringBuilder;
  {$ENDIF}
begin
  if Assigned(FTimePicker) then
  begin
    if (FTimePicker.Parent <> Self) then
      FTimePicker.Parent := Self;
    FTimePicker.Color := Self.Color;
    FTimePicker.Enabled := Self.Enabled;
    FTimePicker.Visible := (FKind = dkDateTime);
    FTimePicker.Time := Self.Time;
    FTimePicker.DateTime := Self.DateTime;
    {$IFDEF DELPHI6_LVL}
    FTimePicker.Format := Self.TimeFormat;
    {$ENDIF}
    FTimePicker.Font.Assign(Self.Font);

    if not FTimePicker.Visible and (not (csLoading in ComponentState) or (csDesigning in ComponentState)) then
    begin
      FTimePicker.Free;
      FTimePicker := nil;
    end
    else
    begin
      {$IFNDEF TMSDOTNET}
      GetWindowText(FTimepicker.Handle, lpstr,255);
      i := GetTextSize(Self, strpas(lpstr), Font).cx + DROPDOWNBTN_WIDTH + 10;
      {$ELSE}
      lpstr := StringBuilder.Create(255);
      try
        GetWindowText(FTimepicker.Handle, lpstr,255);
        i := GetTextSize(Self, lpstr.ToString, Self.Font).cx + DROPDOWNBTN_WIDTH + 10;
      finally
        lpstr.Free;
      end;
      {$ENDIF}

      {$IFNDEF TMSDOTNET}
      if IsVista then
      begin
        //FTimePicker.SetBounds(Width - i - DROPDOWNBTN_WIDTH - 13, 0, i, Height)
        j := 0;
        if ((BevelInner <> bvNone) or (BevelOuter <> bvNone)) and (BevelKind <> bkNone) then
          j := 4;

        if IsComCtl6
        {$IFDEF DELPHI7_LVl}
        and Assigned(IsThemeActive)
        {$ENDIF}
        then
        begin
          {$IFDEF DELPHI7_LVl}
          if IsThemeActive then
          {$ENDIF}
            FTimePicker.SetBounds(Width - i - DROPDOWNBTN_WIDTH - 13 - j, 1, i, Height - 2 - j)
          {$IFDEF DELPHI7_LVl}
          else  // for Windows standard scheme
            FTimePicker.SetBounds(Width - i - DROPDOWNBTN_WIDTH - j, 2, i, Height - j - 4);
          {$ENDIF}
        end
        else
          FTimePicker.SetBounds(Width - i - DROPDOWNBTN_WIDTH - 2 - j, -2, i, Height - j)
      end
      else
      {$ENDIF}
      begin
        if Ctl3D then
          FTimePicker.SetBounds(Width - i - DROPDOWNBTN_WIDTH, -2, i, Height)
        else
          FTimePicker.SetBounds(Width - i - DROPDOWNBTN_WIDTH, -2, i, Height);
      end;  
    end;
  end;
end;

//------------------------------------------------------------------------------

destructor TAdvDateTimePicker.Destroy;
begin
  FFocusTimer.Free;
  if (FLabel <> nil) then
  begin
    FLabel.Parent := nil;
    FLabel.Free;
    FLabel := nil;
  end;
  FLabelFont.Free;

  if Assigned(FTimePicker) then
    FTimePicker.Free;
  inherited;
end;

//------------------------------------------------------------------------------

procedure TAdvDateTimePicker.SetKind(const Value: TAdvDateTimeKind);
begin
  if (FKind <> Value) then
  begin
    FKind := Value;
    if (FKind = dkTime) then
      inherited Kind := dtkTime
    else
      inherited Kind := dtkDate;

    if (FKind = dkDateTime) then
      CreateTimePicker;

    UpdateTimePicker;
  end;
end;

//------------------------------------------------------------------------------

procedure TAdvDateTimePicker.SetLabelAlwaysEnabled(const Value: Boolean);
begin
  FLabelAlwaysEnabled := Value;
  if FLabel <> nil then
    if Value then
      FLabel.Enabled := True;
  Invalidate;
end;

//------------------------------------------------------------------------------

procedure TAdvDateTimePicker.SetLabelCaption(const value: string);
begin
  if FLabel = nil then
    FLabel := CreateLabel;
  FLabel.Caption := Value;
  UpdateLabel;
end;

//------------------------------------------------------------------------------

procedure TAdvDateTimePicker.SetLabelFont(const Value: TFont);
begin
  if not ParentFont then
    FLabelFont.Assign(Value);

  if FLabel <> nil then
    UpdateLabel;
end;

//------------------------------------------------------------------------------

procedure TAdvDateTimePicker.SetLabelMargin(const value: integer);
begin
  FLabelMargin := Value;
  if FLabel <> nil then UpdateLabel;
end;

//------------------------------------------------------------------------------

procedure TAdvDateTimePicker.SetLabelPosition(const value: TLabelPosition);
begin
  FLabelPosition := Value;
  if FLabel <> nil then UpdateLabel;
end;

//------------------------------------------------------------------------------

procedure TAdvDateTimePicker.SetLabelTransparent(const value: boolean);
begin
  FLabelTransparent := Value;
  if FLabel <> nil then UpdateLabel;
end;

//------------------------------------------------------------------------------

procedure TAdvDateTimePicker.SetParent(AParent: TWinControl);
begin
  inherited;
  if FLabel <> nil then
    FLabel.Parent := AParent;
end;

//------------------------------------------------------------------------------
{$IFDEF DELPHI6_LVL}
procedure TAdvDateTimePicker.ShiftFocus;
var
  y, m, d: word;
  c: char;
begin
  if (FKind = dkTime) then
    inherited
  else
  begin
    DecodeDate(DateTime, y, m, d);
    if (Format <> '') then
    begin
      c := Format[Length(Format)];

      {$IFDEF DELPHI_UNICODE}
      if ((d <> Fd) and (CharInSet(c,['D','d']))) or ((m <> Fm) and (CharInSet(c,['M','m']))) or ((y <> Fy) and (CharInSet(c,['Y','y']))) then
      {$ENDIF}
      {$IFNDEF DELPHI_UNICODE}
      if ((d <> Fd) and (c in ['D','d'])) or ((m <> Fm) and (c in ['M','m'])) or ((y <> Fy) and (c in ['Y','y'])) then
      {$ENDIF}
      begin
        if Assigned(FTimePicker) then
          FTimePicker.SetFocus;
      end
      else
        if (d <> Fd) or (m <> Fm) or (y <> Fy) then
          PostMessage(Handle, WM_KEYDOWN, VK_RIGHT, 0);
    end
    else
    begin
      if (d <> Fd) or (m <> Fm) then
        PostMessage(Handle, WM_KEYDOWN, VK_RIGHT, 0)
      else if (y <> Fy) then
      begin
        if Assigned(FTimePicker) then
          FTimePicker.SetFocus;
      end;
    end;
  end;
end;
{$ENDIF}

//------------------------------------------------------------------------------

procedure TAdvDateTimePicker.KeyPress(var Key: Char);
begin
  {$IFDEF DELPHI6_LVL}
  if (Integer(Key) in [48..57]) and AutoTab then
  begin
    DecodeDate(DateTime, Fy, Fm, Fd);
    inherited;
  end
  else
  {$ENDIF}
    inherited;
end;

//------------------------------------------------------------------------------

procedure TAdvDateTimePicker.WMKeyDown(var Message: TWMKeyDown);
begin
  inherited;
end;

//------------------------------------------------------------------------------

procedure TAdvDateTimePicker.WMKillFocus(var Msg: TWMKillFocus);
begin
  if (csLoading in ComponentState) then
  begin
    inherited;
    Exit;
  end;

  if fFocusLabel and (FLabel <> nil) then
    FLabel.Font.Style := FLabel.Font.Style - [fsBold];

  inherited;
end;

//------------------------------------------------------------------------------

procedure TAdvDateTimePicker.WMSetFocus(var Msg: TWMSetFocus);
begin
  inherited;
  if (csLoading in ComponentState) then
    Exit;
  
  if FFocusLabel and (FLabel <> nil) then
    FLabel.Font.Style := FLabel.Font.Style + [fsBold];
end;

//------------------------------------------------------------------------------

procedure TAdvDateTimePicker.WMSize(var Message: TWMSize);
begin
  inherited;
  UpdateTimePicker;
end;

//------------------------------------------------------------------------------

function TAdvDateTimePicker.GetTimeEx: TTime;
begin
  Result := inherited Time;
  if (FKind = dkDateTime) and Assigned(FTimePicker) then
    Result := FTimePicker.Time;
end;

//------------------------------------------------------------------------------

procedure TAdvDateTimePicker.SetTimeEx(const Value: TTime);
begin
  inherited Time := Value;
  UpdateTimePicker;
end;

//------------------------------------------------------------------------------

{$IFDEF DELPHI6_LVL}
procedure TAdvDateTimePicker.SetAutoTab(const Value: Boolean);
begin
  inherited;
  if Assigned(FTimePicker) then
    FTimePicker.AutoTab := AutoTab;
end;
{$ENDIF}

//------------------------------------------------------------------------------

procedure TAdvDateTimePicker.SetBorderStyle(const Value: TBorderStyle);
begin
  inherited;
  UpdateTimePicker;
end;

//------------------------------------------------------------------------------

procedure TAdvDateTimePicker.SetBounds(ALeft, ATop, AWidth, AHeight: Integer);
begin
  inherited;

  if (FLabel <> nil) then
  begin
    if FLabel.Parent <> nil then
      UpdateLabel;
  end;  
end;

//------------------------------------------------------------------------------

procedure TAdvDateTimePicker.OnFocusTimerTime(Sender: TObject);
var
  pt2: TPoint;
begin
  FFocusTimer.Enabled := False;
  Exit;
  if ShowCheckbox and not DroppedDown then
  begin
    //if GetCaretPos(pt) then
    begin
      FPt := ClientToScreen(FPt);
      FPt.x := Round(FPt.x * (65535 / Screen.Width));
      FPt.y := Round(FPt.y * (65535 / Screen.Height));

      // keeping old mouse pos
      GetCursorPos(pt2);

      // mouse move
      Mouse_Event(MOUSEEVENTF_ABSOLUTE or MOUSEEVENTF_MOVE, FPt.x, FPt.y, 0, 0) ;

      // left mouse button down
      Mouse_Event(MOUSEEVENTF_ABSOLUTE or MOUSEEVENTF_LEFTDOWN, FPt.x, FPt.y, 0, 0);
      // left mouse button Up
      Mouse_Event(MOUSEEVENTF_ABSOLUTE or MOUSEEVENTF_LEFTUP, FPt.x, FPt.y, 0, 0) ;

      // moving mouse to old pos
      pt2.x := Round(Pt2.x * (65535 / Screen.Width)) ;
      Pt2.y := Round(Pt2.y * (65535 / Screen.Height)) ;
      Mouse_Event(MOUSEEVENTF_ABSOLUTE or MOUSEEVENTF_MOVE, Pt2.x, Pt2.y, 0, 0);
    end;
  end;
end;

//------------------------------------------------------------------------------
{$IFNDEF TMSDOTNET}
procedure TAdvDateTimePicker.CNNotify(var Message: TWMNotify);
var
  y, y1, m, m1, d, d1: word;
begin
  if ShowCheckbox then
  begin
    with Message, NMHdr^ do
    begin
      case code of
        DTN_DATETIMECHANGE:
        begin
          //GetCaretPos(Fpt);  //invalid pos
          Fpt := Point(-1, -1);
          DecodeDate(DateTime, y, m, d);
          inherited;
          DecodeDate(DateTime, y1, m1, d1);
          if (y <> y1) then
            Fpt := Point(80, 5)
          else if (m <> m1) then
            Fpt := Point(46, 5)
          else if (d <> d1) then
            Fpt := Point(28, 5);
          if (Fpt.X <> -1) then
            FFocusTimer.Enabled := True;
        end;
      end;
    end;
  end
  else
    inherited;
end;

procedure TAdvDateTimePicker.CMParentFontChanged(var Message: TMessage);
begin
  inherited;
  if Assigned(FLabel) and ParentFont then
  begin
    FLabel.Font.Assign(Font);
  end;
end;

{$ENDIF}
//------------------------------------------------------------------------------

procedure TAdvDateTimePicker.Change;
begin
  inherited;
end;

//------------------------------------------------------------------------------

procedure TAdvDateTimePicker.CMColorChanged(var Message: TMessage);
begin
  inherited;
  UpdateTimePicker;
end;

//------------------------------------------------------------------------------

function TAdvDateTimePicker.GetDateTimeEx: TDateTime;
begin
  if Assigned(FTimePicker) then
    inherited Time := FTimePicker.Time;
  Result := inherited DateTime;
end;

//------------------------------------------------------------------------------

procedure TAdvDateTimePicker.SetDateTimeEx(const Value: TDateTime);
var
  ho,mi,se,se100:word;
begin
  decodetime(value, ho, mi, se, se100);

  inherited DateTime := int(value) + encodetime(ho,mi,se,0);
  CreateTimePicker;
  if Assigned(FTimePicker) then  
    FTimePicker.DateTime := int(value) + encodetime(ho,mi,se,0);
end;

//------------------------------------------------------------------------------

function TAdvDateTimePicker.GetLabelCaption: string;
begin
  if FLabel <> nil then
    Result := FLabel.Caption
  else
    Result := '';
end;

//------------------------------------------------------------------------------
{$IFDEF DELPHI6_LVL}

function TAdvDateTimePicker.GetFormatEx: String;
begin
  Result := inherited Format;
end;

//------------------------------------------------------------------------------

procedure TAdvDateTimePicker.SetFormatEx(const Value: String);
begin
  inherited Format := Value;
end;

//------------------------------------------------------------------------------

function TAdvDateTimePicker.GetTimeFormat: String;
begin
  (*{$IFDEF DELPHI6_LVL}
  if Assigned(FTimePicker) then
    Result := FTimePicker.Format;
  {$ELSE}
  Result := '';
  {$ENDIF}*)
  Result := FTimeFormat;
end;

//------------------------------------------------------------------------------

procedure TAdvDateTimePicker.SetTimeFormat(const Value: String);
begin
  if Assigned(FTimePicker) then
    FTimePicker.Format := Value;

  FTimeFormat := Value;
  UpdateTimePicker;
end;

{$ENDIF}

//------------------------------------------------------------------------------

function TAdvDateTimePicker.GetVersion: string;
var
  vn: Integer;
begin
  vn := GetVersionNr;
  Result := IntToStr(Hi(Hiword(vn)))+'.'+IntToStr(Lo(Hiword(vn)))+'.'+IntToStr(Hi(Loword(vn)))+'.'+IntToStr(Lo(Loword(vn)));
end;

//------------------------------------------------------------------------------

function TAdvDateTimePicker.GetVersionNr: integer;
begin
  Result := MakeLong(MakeWord(BLD_VER,REL_VER),MakeWord(MIN_VER,MAJ_VER));
end;

function TAdvDateTimePicker.IsInnerCtrl: Boolean;
begin
  Result := False;
end;

//------------------------------------------------------------------------------

procedure TAdvDateTimePicker.LabelClick(Sender: TObject);
begin
  if Assigned(FOnLabelClick) then
    FOnLabelClick(Self);
end;

//------------------------------------------------------------------------------

procedure TAdvDateTimePicker.LabelDblClick(Sender: TObject);
begin
  if Assigned(FOnLabelDblClick) then
    FOnLabelDblClick(Self);
end;

//------------------------------------------------------------------------------

procedure TAdvDateTimePicker.LabelFontChange(Sender: TObject);
begin
  if FLabel <> nil then
  begin
    UpdateLabel;
    if (csDesigning in ComponentState) then
      ParentFont := false;
  end;
end;

//------------------------------------------------------------------------------

procedure TAdvDateTimePicker.Loaded;
begin
  inherited;
  if not (csDesigning in ComponentState) then
  begin
    CreateTimePicker;
    UpdateTimePicker;
    if not Checked then
      Checked := false;
  end;

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

//------------------------------------------------------------------------------

procedure TAdvDateTimePicker.SetVersion(const Value: string);
begin

end;

//------------------------------------------------------------------------------

procedure TAdvDateTimePicker.OnTimePickerChanged(Sender: TObject);
begin
  TimePickerChanged;
  if Assigned(OnTimeChange) then
    OnTimeChange(self);
end;

//------------------------------------------------------------------------------

procedure TAdvDateTimePicker.OnTimePickerClicked(Sender: TObject);
begin
  TimePickerClicked;
end;

//------------------------------------------------------------------------------

procedure TAdvDateTimePicker.TimePickerChanged;
begin
  if Assigned(OnChange) then
    OnChange(Self);
end;

//------------------------------------------------------------------------------

procedure TAdvDateTimePicker.TimePickerClicked;
begin
  if Assigned(OnClick) then
    OnClick(Self);
end;

//------------------------------------------------------------------------------

procedure TAdvDateTimePicker.TimePickerKeyPress(Sender: TObject;
  var Key: Char);
begin

end;

//------------------------------------------------------------------------------

procedure TAdvDateTimePicker.TimePickerKeyDown(Sender: TObject;
  var Key: Word; Shift: TShiftState);
begin
  KeyDown(Key,Shift);
end;

//------------------------------------------------------------------------------

{$IFNDEF TMSDOTNET}
{$IFDEF FREEWARE}
{$I TRIALINIT.INC}
{$ENDIF}
{$ENDIF}

initialization
{$IFDEF DELPHI6_LVL}
  WM_DTPSHIFTFOCUS := RegisterWindowMessage('DTPShiftFocus');
{$ENDIF}

{$IFNDEF TMSDOTNET}
{$IFDEF FREEWARE}
  DoTrial;
{$ENDIF}
{$ENDIF}

end.
