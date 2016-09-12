{********************************************************************}
{ TAdvMoneyEdit component                                            }
{ for Delphi & C++Builder                                            }
{                                                                    }
{ written by TMS Software                                            }
{            copyright © 2000-2008                                   }
{            Email : info@tmssoftware.com                            }
{            Web : http://www.tmssoftware.com                        }
{                                                                    }
{ The source code is given as is. The author is not responsible      }
{ for any possible damage done due to the use of this code.          }
{ The component can be freely used in any application. The source    }
{ code remains property of the author and may not be distributed     }
{ freely as such.                                                    }
{********************************************************************}

unit AdvMoneyEdit;

{$I TMSDEFS.INC}

interface

uses
  Windows, Classes, StdCtrls, ExtCtrls, Controls, Messages, SysUtils,
  Forms, Graphics, Buttons, AdvEdit
  {$IFDEF DELPHI_UNICODE}
  , Character
  {$ENDIF}
  ;

const
  MAJ_VER = 1; // Major version nr.
  MIN_VER = 1; // Minor version nr.
  REL_VER = 1; // Release nr.
  BLD_VER = 1; // Build nr.

  // version history
  // v1.1.1.0 : Fixed : issue with painting due to changed behaviour in VCL TSpeedButton
  // v1.1.1.1 : Fixed : compatibility issue with TAdvEdit for setting Text  

type
  TAdvMoneyEdit = class;

{TTabForm}
  TTabForm = class(TForm)
  private
   FButtonWidth:integer;
   FButtonHeight:integer;
   FButtonColor:TColor;
   FEx:array[1..4] of Boolean;
   procedure SetEx(i:integer;b:boolean);
   function GetEx(i:integer):boolean;
   procedure CMWantSpecialKey(var Msg: TCMWantSpecialKey); message CM_WANTSPECIALKEY;
   procedure WMClose(var Msg:TMessage); message WM_CLOSE;
  protected
   procedure Paint; override;
  public
   constructor Create(aOwner:TComponent); override;
   destructor Destroy; override;
   property Ex[i:integer]:boolean read GetEx write SetEx;
  published
   property ButtonWidth:integer read FButtonWidth write FButtonWidth;
   property ButtonHeight:integer read FButtonHeight write FButtonHeight;
   property ButtonColor:TColor read FButtonColor write FButtonColor;
  end;

{ TDropCalculatorButton }
  TDropCalculatorButton = class(TSpeedButton)
  private
    FFocusControl: TWinControl;
  protected
    procedure Paint; override;
  public
    procedure Click; override;
    constructor Create(AOwner: TComponent); override;
  published
    property FocusControl:TWinControl read FFocusControl write FFocusControl;
  end;

  TCalculatorButton = class(TSpeedButton)
  protected
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;

    procedure Paint; override;
  end;


  TCalculatorLook = class(TPersistent)
  private
    FButtonBkg: TBitmap;
    FButtonWidth: integer;
    FButtonHeight: integer;
    FButtonColor: TColor;
    FColor: TColor;
    FFont: TFont;
    FFlat: boolean;
    procedure SetFont(const Value: TFont);
    procedure SetButtonBkg(const Value: TBitmap);
  public
    constructor Create;
    destructor Destroy; override;
    procedure Assign(Source: TPersistent); override;
  published
    property ButtonWidth:integer read FButtonWidth write FButtonWidth;
    property ButtonHeight:integer read FButtonHeight write FButtonHeight;
    property ButtonColor:TColor read FButtonColor write FButtonColor;
    property Color:TColor read FColor write FColor;
    property Flat:boolean read FFlat write FFlat;
    property Font:TFont read FFont write SetFont;
    property ButtonBkg:TBitmap read FButtonBkg write SetButtonBkg;
  end;

{ TExtraButtons }

  TExtraButtons = class(TPersistent)
  private
    FExtra1: string;
    FExtra4: string;
    FExtra2: string;
    FExtra3: string;
  published
    property Extra1:string read fExtra1 write fExtra1;
    property Extra2:string read fExtra2 write fExtra2;
    property Extra3:string read fExtra3 write fExtra3;
    property Extra4:string read fExtra4 write fExtra4;
  end;

  TExtraButtonClickEvent = procedure(Sender:TObject;idx:integer;var value:extended) of object;

{ TAdvMoneyEdit }

  TAdvMoneyEdit = class(TAdvEdit)
  private
    FButton: TDropCalculatorButton;
    FEditorEnabled: Boolean;
    FOnClickBtn: TNotifyEvent;
    FCalcForm: TTabForm;
    FCalcClosed: Boolean;
    FCloseClick: Boolean;
    FDecim: Integer;
    sp:array[0..22] of TCalculatorButton;
    newval:boolean;
    prevval:extended;
    prevop:integer;
    FCalculatorLook:TCalculatorLook;
    FExtraButtons: TExtraButtons;
    FOnExtraButtonClick:TExtraButtonClickEvent;
    function GetMinHeight: Integer;
    procedure SetEditRect;
    procedure WMSize(var Message: TWMSize); message WM_SIZE;
    procedure CMEnter(var Message: TCMGotFocus); message CM_ENTER;
    procedure CMExit(var Message: TCMExit);   message CM_EXIT;
    procedure WMPaste(var Message: TWMPaste);   message WM_PASTE;
    procedure WMCut(var Message: TWMCut);   message WM_CUT;
    procedure WMKeyDown(var Msg:TWMKeydown); message WM_KEYDOWN;
    procedure FormDeactivate(Sender: TObject);
    procedure NumButtonClick(Sender: TObject);
    procedure FormKeyPress(Sender: TObject; var Key: Char);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure BuildCalculator(AForm:TForm);
    function GetButtonGlyph: TBitmap;
    procedure SetButtonGlyph(const Value: TBitmap);
    procedure docalc;
    procedure doplus;
    procedure domin;
    procedure domul;
    procedure dodiv;
    procedure doeq;
    procedure doperc;
    procedure SetEditorEnabled(const Value: Boolean);
    procedure SetCalculatorLook(const Value: TCalculatorLook);
    function GetValue: extended;
    procedure SetValue(const Value: extended);
    procedure BtnClick(Sender: TObject); virtual;
    procedure SetExtraButtons(const Value: TExtraButtons);
    function GetButtonCaption: string;
    function GetButtonHint: string;
    procedure SetButtonCaption(const Value: string);
    procedure SetButtonHint(const Value: string);
  protected
    function GetVersionNr: Integer; override;
    procedure CreateParams(var Params: TCreateParams); override;
    procedure CreateWnd; override;
    procedure DestroyWnd; override;
    function GetParentForm(Control: TControl): TCustomForm; virtual;
    procedure KeyPress(var key:char); override;
    procedure CalcChange; virtual;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure Loaded; override;
    procedure DoEnter; override;
    property Button: TDropCalculatorButton read FButton;
    property Text;
    property Value:extended read GetValue write SetValue;
    procedure ShowCalculator;
    procedure HideCalculator;   
  published
    {$IFDEF DELPHI4_LVL}
    property Anchors;
    property Constraints;
    property DragKind;
    {$ENDIF}
    property AutoSelect;
    property AutoSize;
    property BorderStyle;
    property ButtonCaption: string read GetButtonCaption write SetButtonCaption;
    property ButtonHint: string read GetButtonHint write SetButtonHint;
    property CalculatorLook:TCalculatorLook read FCalculatorLook write SetCalculatorLook;
    property Color;
    property Ctl3D;
    property DragCursor;
    property DragMode;
    property EditorEnabled: Boolean read FEditorEnabled write SetEditorEnabled default True;
    property Enabled;
    property ExtraButtons: TExtraButtons read FExtraButtons write SetExtraButtons;
    property Font;
    property ButtonGlyph:TBitmap read GetButtonGlyph write SetButtonGlyph;
    property MaxLength;
    property ParentColor;
    property ParentCtl3D;
    property ParentFont;
    property ParentShowHint;
    property PopupMenu;
    property ReadOnly;
    property ShowHint;
    property TabOrder;
    property TabStop;
    property Visible;
    property Height;
    property Width;
    property OnChange;
    property OnClick;
    property OnDblClick;
    property OnDragDrop;
    property OnDragOver;
    property OnEndDrag;
    property OnEnter;
    property OnExit;
    property OnKeyDown;
    property OnKeyPress;
    property OnKeyUp;
    property OnMouseDown;
    property OnMouseMove;
    property OnMouseUp;
    property OnStartDrag;
    {$IFDEF DELPHI4_LVL}
    property OnEndDock;
    property OnStartDock;
    {$ENDIF}
    property OnClickBtn: TNotifyEvent read FOnClickBtn write FOnClickBtn;
    property OnExtraButtonClick: TExtraButtonClickEvent read fOnExtraButtonClick
                  write fOnExtraButtonClick;
  end;

implementation

{$IFDEF TMSDOTNET}
  uses
    Borland.Vcl.Variants, Types;
{$ENDIF}

{$I DELPHIXE.INC}

function StripThousandSep(s:string):string;
begin
  while (Pos(ThousandSeparator,s)>0) do
    Delete(s,Pos(ThousandSeparator,s),1);
  Result := s;
end;



{ TDropCalculatorButton }
constructor TDropCalculatorButton.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  Cursor := crArrow;
end;

procedure TDropCalculatorButton.Paint;
begin
  inherited Paint;
end;

procedure TDropCalculatorButton.Click;
begin
  if (FFocusControl <> nil) and FFocusControl.CanFocus and (GetFocus <> FFocusControl.Handle) then
     FFocusControl.SetFocus;
  inherited Click;
end;

{ TAdvMoneyEdit }
constructor TAdvMoneyEdit.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FButton := TDropCalculatorButton.Create (Self);
  FButton.Width := 15;
  FButton.Height := 17;
  FButton.Visible := True;
  FButton.Parent := Self;
  FButton.FocusControl := Self;
  FButton.OnClick := BtnClick;
  FButton.Margin := 0;
  FButton.Spacing := 0;
  FDecim := 0;
  Text := '0';
  ControlStyle := ControlStyle - [csSetCaption];
  FEditorEnabled := True;
  FCalcClosed := True;
  Enabled := True;
  FCalculatorLook := TCalculatorLook.Create;
  FExtraButtons := TExtraButtons.Create;
  IndentR := 19;
  IndentL := 0;
  EditType := etFloat;
end;

destructor TAdvMoneyEdit.Destroy;
begin
  FButton.Free;
  FCalculatorLook.Free;
  FExtraButtons.Free;
  inherited Destroy;
end;

function TAdvMoneyEdit.GetParentForm(Control: TControl): TCustomForm;
begin
  Result := nil;
  if Assigned(Control) then
    if Control is TCustomForm then
    begin
      Result := Control as TCustomForm;
      Exit;
    end else
    begin
      if Assigned(Control.Parent) then
        Result := GetParentForm(Control.Parent);
    end;
end;

procedure TAdvMoneyEdit.CreateParams(var Params: TCreateParams);
begin
  inherited CreateParams(Params);
  if not (EditType = etPassword) then
  begin
    Params.Style := Params.Style or ES_MULTILINE;
  end;
end;

procedure TAdvMoneyEdit.DestroyWnd;
begin
  inherited;
end;

procedure TAdvMoneyEdit.CreateWnd;
begin
  inherited CreateWnd;
  SetEditRect;
end;

procedure TAdvMoneyEdit.BuildCalculator(AForm:TForm);
var
 i,n:integer;
 FButtonWidth:integer;
 FButtonHeight:integer;
 ex:array[1..4] of string;

begin
  FButtonWidth := FCalculatorLook.ButtonWidth;
  FButtonHeight := FCalculatorLook.ButtonHeight;

  n:=5;
  with fExtraButtons do
   begin
    if (fExtra1<>'') or (fExtra2<>'') or (fExtra3<>'') or (fExtra4<>'') then n:=6;

    AForm.Width:=4+n*(FButtonWidth+2);
    AForm.Height:=4+4*(FButtonHeight+2);

    ex[1]:=fExtra1;
    ex[2]:=fExtra2;
    ex[3]:=fExtra3;
    ex[4]:=fExtra4;

    for i:=1 to 4 do
    if ex[i]<>'' then
     begin
      sp[18+i]:=TCalculatorButton.Create(AForm);
      if not FCalculatorLook.ButtonBkg.Empty then
        begin
         sp[18+i].Glyph:=FCalculatorLook.ButtonBkg;
         sp[18+i].Spacing:=-(FCalculatorLook.ButtonBkg.Width shr 1)-(FCalculatorLook.Font.Size shr 1);
         sp[18+i].Margin:=0;
         sp[18+i].Flat := (FCalculatorLook.Flat) or not FCalculatorLook.ButtonBkg.Empty;
        end;

      sp[18+i].Font.Assign(FCalculatorLook.Font);

      sp[18+i].left:=2+5*(FButtonWidth+2);
      sp[18+i].top:=2+(i-1)*(FButtonHeight+2);
      sp[18+i].width:=FButtonWidth;
      sp[18+i].height:=FButtonHeight;

      {$IFNDEF TMSDOTNET}
      sp[18+i].Tag:=18+i;
      {$ENDIF}
      {$IFDEF TMSDOTNET}
      sp[18+i].Tag:=Variant(18+i);
      {$ENDIF}

      sp[18+i].Flat := FCalculatorLook.Flat;
      sp[18+i].Caption := ex[i]+' ';
      sp[18+i].OnClick := NumButtonClick;
      sp[18+i].Parent := AForm;
      sp[18+i].Visible := true;

     end;
   end;

  for i:=0 to 18 do
   begin
    sp[i]:=TCalculatorButton.Create(AForm);

    sp[i].Font.Assign(FCalculatorLook.Font);

    if not FCalculatorLook.ButtonBkg.Empty then
     begin
       sp[i].Glyph:=FCalculatorLook.ButtonBkg;
       sp[i].Spacing:=-(FCalculatorLook.ButtonBkg.Width shr 1)-(FCalculatorLook.Font.Size shr 1);
       sp[i].Margin:=0;
       sp[i].Flat := (FCalculatorLook.Flat) or not FCalculatorLook.ButtonBkg.Empty;;
     end;

    case i of
    0,1,4,7:sp[i].left:=2;
    2,5,8,14:sp[i].left:=2+(FButtonWidth+2);
    3,6,9,15:sp[i].left:=2+2*(FButtonWidth+2);
    10,11,12,13:sp[i].left:=2+3*(FButtonWidth+2);
    16,17,18:sp[i].left:=2+4*(FButtonWidth+2);
    end;

    case i of
    7,8,9,10:sp[i].top:=2;
    4,5,6,11,18:sp[i].top:=2+(FButtonHeight+2);
    1,2,3,12,16:sp[i].top:=2+2*(FButtonHeight+2);
    0,13,14,15,17:sp[i].top:=2+3*(FButtonHeight+2);
    end;

    sp[i].width:=FButtonWidth;
    sp[i].height:=FButtonHeight;

    sp[i].tag:=i;
    sp[i].flat:= (FCalculatorLook.Flat) or not FCalculatorLook.ButtonBkg.Empty;

    case i of
    0..9:sp[i].caption:=inttostr(i)+' ';
    10:sp[i].caption:='+ ';
    11:sp[i].caption:='- ';
    12:sp[i].caption:='* ';
    13:sp[i].caption:='/ ';
    14:sp[i].caption:='+/- ';
    15:sp[i].caption:='. ';
    16:sp[i].caption:='C ';
    17:sp[i].caption:='= ';
    18:sp[i].caption:='% ';
    end;

    sp[i].OnClick := NumButtonClick;
    sp[i].Parent:=AForm;
    sp[i].Visible:=true;
   end;


end;

procedure TAdvMoneyEdit.ShowCalculator;
var
  P: TPoint;
  fDropDirection:boolean;
  {$IFDEF DELPHI9_LVL}
  w, h : integer;
  {$ENDIF}
begin
  FCalcClosed := False;
  FDecim := 0;
  newval := true;

  P := Point(0, 0);
  P := Self.ClientToScreen(P);

  {$IFDEF DELPHI4_LVL}
  FCalcForm:=TTabForm.CreateNew(self,0);
  {$ELSE}
  FCalcForm:=TTabForm.CreateNew(self);
  {$ENDIF}

  FCalcForm.BorderStyle:=bsNone;
  FCalcForm.Visible := False;
  FCalcForm.ButtonWidth := FCalculatorLook.ButtonWidth;
  FCalcForm.ButtonHeight := FCalculatorLook.ButtonHeight;

  if not FCalculatorLook.ButtonBkg.Empty then
   FCalcForm.ButtonColor:=FCalculatorLook.Color
  else
   FCalcForm.ButtonColor:=FCalculatorLook.ButtonColor;

  FCalcForm.FormStyle := fsStayOnTop;

  FCalcForm.Ex[1]:=FExtraButtons.Extra1<>'';
  FCalcForm.Ex[2]:=FExtraButtons.Extra2<>'';
  FCalcForm.Ex[3]:=FExtraButtons.Extra3<>'';
  FCalcForm.Ex[4]:=FExtraButtons.Extra4<>'';

  FCalcForm.Color := FCalculatorLook.Color;

  FCalcForm.OnDeactivate := FormDeactivate;
  FCalcForm.OnKeypress := FormKeyPress;
  FCalcForm.OnKeyDown := FormKeyDown;

  P := Point(0, 0);
  P := ClientToScreen(P);
  FCalcForm.Left:=P.x;

  BuildCalculator(FCalcForm);

  FDropDirection := false;

  if P.y + FCalcForm.Height >= GetSystemMetrics(SM_CYSCREEN) then
    fDropDirection := True;

  if P.y - FCalcForm.Height <= 0 then
    fDropDirection := False;


  if (FDropDirection=false) then
    FCalcForm.Top:=P.y + self.Height
  else
    FCalcForm.Top:=P.y - FCalcForm.Height;

  {$IFNDEF DELPHI9_LVL}
  FCalcForm.Show;
  {$ENDIF}
  {$IFDEF DELPHI9_LVL}
  w := FCalcForm.Width;
  h := FCalcForm.Height;

  FCalcForm.Width := 0;
  FCalcForm.height := 0;
  FCalcForm.Show;
  FCalcForm.Left:=P.x;
  FDropDirection:=false;

  if P.y + FCalcForm.Height >= GetSystemMetrics(SM_CYSCREEN) then
    fDropDirection := True;

  if P.y - FCalcForm.Height <= 0 then
    fDropDirection := False;


  if (FDropDirection=false) then
    FCalcForm.Top:=P.y + self.Height
  else
    FCalcForm.Top:=P.y - FCalcForm.Height;

  FCalcForm.width := w;
  FCalcForm.Height := h;

  {$ENDIF}
end;

procedure TAdvMoneyEdit.HideCalculator;
begin
  FCalcForm.Free;
  FCalcform := nil;
end;

procedure TAdvMoneyEdit.SetEditRect;
var
  Loc: TRect;
begin
  {$IFNDEF TMSDOTNET}
  SendMessage(Handle, EM_GETRECT, 0, LongInt(@Loc));
  {$ENDIF}
  {$IFDEF TMSDOTNET}
  Perform(EM_GETRECT,0,Loc);
  {$ENDIF}
  Loc.Bottom := ClientHeight + 1;  {+1 is workaround for windows paint bug}
  Loc.Right := ClientWidth - FButton.Width - 3;
  if self.BorderStyle = bsNone then
   begin
    Loc.Top := 2;
    Loc.Left := 2;
   end
  else
   begin
    Loc.Top := 1;
    Loc.Left := 1;
   end;
   {$IFNDEF TMSDOTNET}
  SendMessage(Handle, EM_SETRECTNP, 0, LongInt(@Loc));
  {$ENDIF}
  {$IFDEF TMSDOTNET}
  Perform(EM_SETRECTNP,0,Loc);
  {$ENDIF}
end;


procedure TAdvMoneyEdit.WMSize(var Message: TWMSize);
var
  MinHeight: Integer;
  Dist:integer;
begin
  inherited;

  if BorderStyle=bsNone then Dist:=2 else Dist:=5;

  MinHeight := GetMinHeight;
    { text edit bug: if size to less than minheight, then edit ctrl does
      not display the text }

  if Height < MinHeight then
    Height := MinHeight
  else if FButton <> nil then
  begin
    if NewStyleControls and Ctl3D then
      FButton.SetBounds(Width - FButton.Width - Dist, 0, FButton.Width, Height - Dist)
    else FButton.SetBounds (Width - FButton.Width, 1, FButton.Width, Height - 3);
    SetEditRect;
  end;
end;

function TAdvMoneyEdit.GetMinHeight: Integer;
var
  DC: HDC;
  SaveFont: HFont;
  I: Integer;
  SysMetrics, Metrics: TTextMetric;
begin
  DC := GetDC(0);
  GetTextMetrics(DC, SysMetrics);
  SaveFont := SelectObject(DC, Font.Handle);
  GetTextMetrics(DC, Metrics);
  SelectObject(DC, SaveFont);
  ReleaseDC(0, DC);
  I := SysMetrics.tmHeight;
  if I > Metrics.tmHeight then I := Metrics.tmHeight;
  {Result := Metrics.tmHeight + I div 4 + GetSystemMetrics(SM_CYBORDER) * 4 +2;}
  Result := Metrics.tmHeight + I div 4 {+ GetSystemMetrics(SM_CYBORDER) * 4};
end;

procedure TAdvMoneyEdit.BtnClick (Sender: TObject);
begin
  //if FCalcClosed then
  begin
    if not FCloseClick then
      ShowCalculator
  end;
  //else
  begin
//    FCalcClosed := True;
//    HideCalculator;
  end;

  FCloseClick := False;
  
  if Assigned(FOnClickBtn) then
    FOnClickBtn(Sender);
end;

procedure TAdvMoneyEdit.WMPaste(var Message: TWMPaste);
begin
  if FEditorEnabled then inherited;
end;

procedure TAdvMoneyEdit.WMCut(var Message: TWMPaste);
begin
  if FEditorEnabled then inherited;
end;

procedure TAdvMoneyEdit.CMExit(var Message: TCMExit);
begin
  inherited;
end;

procedure TAdvMoneyEdit.WMKeyDown(var Msg:TWMKeydown);
begin
  inherited;
  
  if (msg.CharCode=vk_F4) then
  begin
    ShowCalculator;
  end;

  if (msg.CharCode = vk_delete) then
    if Text = '' then
      Text := '0';
end;

procedure TAdvMoneyEdit.CMEnter(var Message: TCMGotFocus);
begin
  if AutoSelect and not (csLButtonDown in ControlState) then
    SelectAll;
  inherited;
end;


function TAdvMoneyEdit.GetButtonGlyph: TBitmap;
begin
 result:=fButton.Glyph;
end;

procedure TAdvMoneyEdit.SetButtonGlyph(const Value: TBitmap);
begin
 fButton.Glyph:=Value;
end;

procedure TAdvMoneyEdit.FormDeactivate(Sender: TObject);
var
 pt:tpoint;
 r:trect;
begin
  {check cursor here...}
  getcursorpos(pt);
  pt:=screentoclient(pt);
  r:=clientrect;
  r.left:=r.right-16;
  FCloseClick:=ptinrect(r,pt);
  postmessage((Sender as TForm).Handle,WM_CLOSE,0,0);
end;

procedure TAdvMoneyEdit.NumButtonClick(Sender: TObject);
var
  s:string;
  e,n:extended;
  f: double;
begin
  CalcChange;

  {$IFNDEF TMSDOTNET}
  if ((Sender as TCalculatorButton).Tag in [10..14,16,17,18,19..22]) then
  {$ENDIF}
  {$IFDEF TMSDOTNET}
  if (Integer((Sender as TCalculatorButton).Tag) in [10..14,16,17,18,19..22]) then
  {$ENDIF}
    FDecim := 0;

  if (Integer((Sender as TCalculatorButton).Tag) in [0..9,14,15]) then
  begin
    if (MaxLength > 0) and (Length(Text) = MaxLength) then
      Exit;
  end;

  if ((Sender as TCalculatorButton).Tag < 10) then
  begin
    f := FloatValue;
    if ((FloatValue = 0 ) and (FDecim = 0)) or (newval) then
    begin
      Text := IntToStr((sender as TCalculatorButton).Tag);
      newval := false;
    end
   else
   begin
     if FDecim > 0 then
     begin
       f := f + (Sender as TCalculatorButton).Tag / FDecim;
       FDecim := FDecim * 10;
     end
     else
       f := f * 10 + (Sender as TCalculatorButton).Tag;

     FloatValue := f;
   end;
 end
 else
  begin
   {$IFNDEF TMSDOTNET}
   case ((sender as TCalculatorButton).tag) of
   {$ENDIF}
   {$IFDEF TMSDOTNET}
   case Integer((sender as TCalculatorButton).tag) of
   {$ENDIF}
   10:begin doplus; prevop:=0; end;
   11:begin domin; prevop:=2; end;
   12:begin domul; prevop:=1; end;
   13:begin dodiv; prevop:=3; end;
   14:if pos('-',Text)=0 then Text:='-'+Text
      else
        begin
         s := Text;
         delete(s,1,1);
         Text := s;
        end;
   15:begin
       if pos(DecimalSeparator,Text) = 0 then
       begin
         Text := Text + DecimalSeparator;
       end;
       FDecim := 10;
       if newval then       
         Text := '0';
       newval := false;
     end;
   16:begin
        Text := '0';
        prevval := 0;
        prevop := -1;
      end;
   17:doeq;
   18:begin doperc; end;
   19..22:begin
           if Text='' then Text:='0';
           e:=strtofloat(StripThousandSep(Text));
           n:=e;
           if Assigned(FOnExtraButtonClick) then
             FOnExtraButtonClick(sender,(sender as TSpeedButton).tag-18,e);
           if (e<>n) then Text:=Format('%g',[e]);
          end;
   end;

  end;
  Modified := True;
end;

procedure TAdvMoneyEdit.FormKeyPress(Sender: TObject; var Key: Char);
begin
  CalcChange;
  if Key = DecimalSeparator then
    if (pos(DecimalSeparator,Text)=0) then Text:=Text+DecimalSeparator;

  {$IFNDEF DELPHI_UNICODE}
  if (key in ['0'..'9']) then
  {$ENDIF}
  {$IFDEF DELPHI_UNICODE}
  if character.IsNumber(key) then
  {$ENDIF}
  begin
    if (MaxLength > 0) and (Length(Text) = MaxLength) then
      Exit;
  end;

  case key of
  '0'..'9':
    if (Text = '0') or (newval) then
    begin
      SetTextDirect(key);
      newval := false;
    end
    else
      SetTextDirect(Text + key);
  'c','C':
    begin
      Text := '0';
      prevval := 0;
      newval := true;
      prevop := -1;
    end;
  '+':doplus;
  '/':dodiv;
  '-':domin;
  '*':domul;
  '=':doeq;
  '%':doperc;
  #13:
    begin
      doeq;
      postmessage((Sender as TForm).Handle,WM_CLOSE,0,0);
    end;
  #27:
    postmessage((Sender as TForm).Handle,WM_CLOSE,0,0);
  end;
end;

procedure TAdvMoneyEdit.docalc;
var
 e:extended;
begin
  if Text = '' then
    Text := '0';

  e := strtofloat(StripThousandSep(Text));
  try
    case prevop of
    0:prevval := prevval + e;
    1:prevval := prevval * e;
    2:prevval := prevval - e;
    3:if (e<>0) then prevval:=prevval/e else prevval:=0;
    else
      prevval:=strtofloat(StripThousandSep(Text));
    end;
  except
    prevval:=0;
  end;

  //Text:=format('%g',[prevval]);
  FloatValue := prevval;
  newval := true;
end;

procedure TAdvMoneyEdit.dodiv;
begin
 docalc;
 prevop:=3;
end;

procedure TAdvMoneyEdit.doeq;
begin
  DoCalc;
  if Text = '' then
    Text := '0';

  prevval := strtofloat(StripThousandSep(Text));

  prevop := -1;
end;

procedure TAdvMoneyEdit.doperc;
var
 e:extended;
begin
 if Text='' then Text:='0';
 e:=strtofloat(StripThousandSep(Text));

 e:=prevval*e/100;
 Text:=format('%g',[e]);
end;


procedure TAdvMoneyEdit.domin;
begin
  docalc;
  prevop:=2;
end;

procedure TAdvMoneyEdit.domul;
begin
  docalc;
  prevop:=1;
end;

procedure TAdvMoneyEdit.doplus;
begin
  docalc;
  prevop := 0;
end;


procedure TAdvMoneyEdit.SetEditorEnabled(const Value: Boolean);
begin
  FEditorEnabled := Value;
  ReadOnly:=not fEditorEnabled;
end;

procedure TAdvMoneyEdit.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
var
  s:string;
begin
  if key in [vk_F4, vk_tab] then
    Postmessage((Sender as TForm).Handle,WM_CLOSE,0,0);

  if (key = vk_back) then
  begin
    s := Text;
    Delete(s,Length(Text),1);
    if s = '' then
      s := '0';
    Text := s;
  end;
end;

procedure TAdvMoneyEdit.KeyPress(var Key: Char);
begin
  if FCalcClosed or
    (Assigned(FCalcForm) and (FCalcForm.Visible = false)) then
  case key of
  'c','C':begin
            Text:='0';
            newval:=true;
            prevop:=-1;
           end;
  '+':doplus;
  '/':dodiv;
  '-':domin;
  '*':domul;
  '=',#13:doeq;
  '%':doperc;
  end;

  {$IFNDEF TMSDOTNET}
  {$IFNDEF DELPHI_UNICODE}
  if not (Key in ['0'..'9',DecimalSeparator,#8,'-']) then key := #0;
  {$ENDIF}
  {$IFDEF DELPHI_UNICODE}
  if not (character.IsNumber(Key) or (Key = DecimalSeparator) or (Key = #8) or (Key = '-')) then key := #0;
  {$ENDIF}

  {$ENDIF}
  {$IFDEF TMSDOTNET}
  if not (Key in ['0'..'9',#8,'-']) and not (Key = DecimalSeparator) then key:=#0;
  {$ENDIF}

  {$IFNDEF DELPHI_UNICODE}
  if ((Text='0') or (newval)) and (key in ['0'..'9']) then
  {$ENDIF}
  {$IFDEF DELPHI_UNICODE}
  if ((Text='0') or (newval)) and (character.IsNumber(key)) then
  {$ENDIF}
  begin
    Text := Key;
    Key := #0;
    SelStart := 1 + Length(Prefix);
    SelLength := 0;
    Newval := False;
    Exit;
  end;

  if (Length(Text) = 1) and (Key = #8) then
  begin
    Text := '0';
    Key := #0;
    SelStart := 1 + Length(Prefix);
    SelLength := 0;
    Exit;
  end;

  if (Key = ThousandSeparator) then
  begin
    Key := #0;
  end;

  if (Key = DecimalSeparator) and (Pos(Key,Text)>0) then
  begin
    Key := #0;
  end;

  inherited;
end;

procedure TAdvMoneyEdit.SetCalculatorLook(const Value: TCalculatorLook);
begin
  FCalculatorLook.Assign(Value);
end;

function TAdvMoneyEdit.GetValue: extended;
begin
  if Text = '' then
    Text := '0';
  try
    Result := StrToFloat(StripThousandSep(Text));
  except
    Result := 0;
  end;
end;

procedure TAdvMoneyEdit.SetValue(const Value: extended);
begin
  Text := Format('%g',[value]);
end;

procedure TAdvMoneyEdit.SetExtraButtons(const Value: TExtraButtons);
begin
  FExtraButtons.Assign(Value);
end;

procedure TAdvMoneyEdit.CalcChange;
begin

end;

function TAdvMoneyEdit.GetButtonCaption: string;
begin
  Result := Button.Caption;
end;

function TAdvMoneyEdit.GetButtonHint: string;
begin
  Result := Button.Hint;
end;

procedure TAdvMoneyEdit.SetButtonCaption(const Value: string);
begin
  Button.Caption := Value;
end;

procedure TAdvMoneyEdit.SetButtonHint(const Value: string);
begin
  Button.Hint := Value;
  Button.ShowHint := Value <> '';
end;

procedure TAdvMoneyEdit.Loaded;
begin
  inherited;
  SetEditRect;
end;

procedure TAdvMoneyEdit.DoEnter;
begin
  inherited;
  SetEditRect;
end;

function TAdvMoneyEdit.GetVersionNr: Integer;
begin
  Result := MakeLong(MakeWord(BLD_VER,REL_VER),MakeWord(MIN_VER,MAJ_VER));
end;

{ TTabForm }

procedure TTabForm.CMWantSpecialKey(var Msg: TCMWantSpecialKey);
begin
  inherited;
  if msg.CharCode in [vk_up,vk_down,vk_left,vk_right,vk_tab] then msg.result:=1;
end;

constructor TTabForm.Create(aOwner: TComponent);
begin
  inherited;
end;

destructor TTabForm.Destroy;
begin
  inherited;
end;

procedure TTabForm.SetEx(i:integer;b:boolean);
begin
  if (i<5) and (i>0) then FEx[i]:=b;
end;

function TTabForm.GetEx(i:integer):boolean;
begin
  Result:=false;
  if (i<5) and (i>0) then result:=FEx[i];
end;


procedure TTabForm.Paint;
var
 i,j:integer;
 r:trect;
 oldColor:TColor;

begin
  inherited;
  with canvas do
  begin
    pen.color:=clBlack;
    r := GetClientRect;
    Rectangle(r.left,r.top,r.right,r.bottom);

    oldColor := Canvas.Brush.Color;
    Canvas.Brush.Color := ButtonColor;
    Canvas.Pen.Color := ButtonColor;

    for i := 1 to 6 do
      for j := 1 to 4 do
      begin
        if (i=5) and (j<2) then
          Continue;

        if (i=6) and not FEx[j] then
          Continue;

        Rectangle(2+(2+FButtonWidth)*(i-1),2+(2+FButtonHeight)*(j-1),
                (2+FButtonWidth)*(i),(2+FButtonHeight)*(j));
      end;

    Canvas.brush.color:=oldColor;
  end;
end;

procedure TTabForm.WMClose(var Msg: TMessage);
begin
  inherited;
  self.Free;
end;

{ TCalculatorLook }

procedure TCalculatorLook.Assign(Source: TPersistent);
begin
  if Source is TCalculatorLook then
  begin
    ButtonBkg.Assign(TCalculatorLook(Source).ButtonBkg);
    ButtonWidth := TCalculatorLook(Source).ButtonWidth;
    ButtonHeight := TCalculatorLook(Source).ButtonHeight;
    ButtonColor := TCalculatorLook(Source).ButtonColor;
    Color := TCalculatorLook(Source).Color;
    Font.Assign(TCalculatorLook(Source).Font);
    Flat := TCalculatorLook(Source).Flat;
  end;
end;

constructor TCalculatorLook.Create;
begin
  inherited;
  FFont := TFont.Create;
  FButtonWidth := 24;
  FButtonHeight := 24;
  FButtonColor := clSilver;
  FColor := clWhite;
  FbuttonBkg := TBitmap.Create;
end;

destructor TCalculatorLook.Destroy;
begin
  FFont.Free;
  FbuttonBkg.Free;
  inherited;
end;

procedure TCalculatorLook.SetButtonBkg(const Value: TBitmap);
begin
  FButtonBkg.Assign(Value);
end;

procedure TCalculatorLook.SetFont(const Value: TFont);
begin
  FFont.Assign(Value);
end;

{ TCalculatorButton }

procedure TCalculatorButton.MouseDown(Button: TMouseButton; Shift: TShiftState;
  X, Y: Integer);
begin
  inherited;
  Repaint;
end;

procedure TCalculatorButton.MouseUp(Button: TMouseButton; Shift: TShiftState; X,
  Y: Integer);
begin
  inherited;
  Repaint;
end;

procedure TCalculatorButton.Paint;
var
  hasGlyph: boolean;
  r: TRect;
  s:string;
begin
  hasGlyph := false;

  if Assigned(Glyph) then
    hasGlyph := not Glyph.Empty;

  if not Flat or not hasGlyph then
    inherited
  else
  begin
    s := Trim(Caption);

    if FState = bsDown then
      Canvas.Draw(1,1,Glyph)
    else
      Canvas.Draw(0,0,Glyph);

    r := ClientRect;
    Canvas.Brush.Style := bsClear;

    if FState = bsDown then
      OffsetRect(r,1,1);

    Canvas.Font.Assign(self.Font);

    {$IFNDEF TMSDOTNET}
    DrawText(Canvas.Handle, Pchar(s),length(s),r,DT_SINGLELINE or DT_CENTER or DT_VCENTER);
    {$ENDIF}
    {$IFDEF TMSDOTNET}
    DrawText(Canvas.Handle, s,length(s),r,DT_SINGLELINE or DT_CENTER or DT_VCENTER);
    {$ENDIF}
  end;

end;

end.


