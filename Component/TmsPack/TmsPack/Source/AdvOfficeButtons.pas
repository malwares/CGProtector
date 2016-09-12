{*************************************************************************}
{ TAdvOfficeButtons components                                            }
{ for Delphi & C++Builder                                                 }
{                                                                         }
{ written by                                                              }
{    TMS Software                                                         }
{    copyright © 2007 - 2010                                              }
{    Email : info@tmssoftware.com                                         }
{    Web : http://www.tmssoftware.com                                     }
{                                                                         }
{ The source code is given as is. The author is not responsible           }
{ for any possible damage done due to the use of this code.               }
{ The component can be freely used in any application. The complete       }
{ source code remains property of the author and may not be distributed,  }
{ published, given or sold in any form as such. No parts of the source    }
{ code can be included in any other component or application without      }
{ written authorization of the author.                                    }
{*************************************************************************}

unit AdvOfficeButtons;

{$I TMSDEFS.INC}
{$R AdvOfficeButtons.res}
{$DEFINE REMOVESTRIP}
{$DEFINE REMOVEDRAW}

interface

uses
  SysUtils, Windows, Messages, Classes, Graphics, Controls, StdCtrls,
  PictureContainer, AdvGroupBox, AOBXPVS;

const
  MAJ_VER = 1; // Major version nr.
  MIN_VER = 2; // Minor version nr.
  REL_VER = 5; // Release nr.
  BLD_VER = 0; // Build nr.

  // version history
  // 1.0.0.1 : Fixed compatibility issue with TRadioGroup of TAdvOfficeRadioGroup
  // 1.0.1.0 : Improved : exposed Visible property in TAdvOfficeRadioButton
  // 1.0.2.0 : New : Added OnEnter, OnExit events in TAdvOfficeRadioButton, TAdvOfficeCheckBox
  // 1.0.3.0 : Improved : painting hot state of controls
  // 1.1.0.0 : New property Value added in AdvOfficeCheckGroup
  //         : New component TDBAdvOfficeCheckGroup added
  // 1.1.0.1 : Improved : painting of focus rectangle
  // 1.1.0.2 : Fixed : issue with ImageIndex for caption
  // 1.1.0.3 : Fixed : issue with arrow keys & TAdvOfficeRadioGroup
  // 1.1.0.4 : Fixed : issue with dbl click & mouseup handling
  // 1.1.0.5 : Fixed : small painting issue with ClearType fonts
  // 1.1.0.6 : Fixed : issue with runtime creating controls
  // 1.1.0.7 : Fixed : issue with setting separate radiobuttons in group as disabled
  // 1.1.0.8 : Fixed : issue with OnClick event for TAdvOfficeRadioGroup
  // 1.1.0.9 : Fixed : issue with vertical alignment of radiobutton label text
  // 1.1.1.0 : Improved : BidiMode RightToLeft support
  // 1.1.1.1 : Fixed : painting issue with BiDiMode bdRightToLeft for radiobutton
  // 1.1.1.2 : Fixed : issue with transparency on Windows Vista
  // 1.1.1.3 : Improved : tab key handling for TAdvOfficeCheckGroup
  // 1.1.1.4 : Fixed : background painting issue with Delphi 2009
  // 1.1.2.0 : Improved : shows native Windows Vista checkbox & radiobutton on themed Windows Vista
  // 1.2.0.0 : New : DisabledFontColor added for all controls
  // 1.2.1.0 : New : property Themed added to control style of checkbox/radiobutton
  // 1.2.2.0 : Improved : painting of cbGrayed state
  // 1.2.2.1 : Fixed : issue with setting focus on disabled checkboxes in AdvOfficeCheckGroup
  // 1.2.3.0 : New : ShowFocus property added for controls
  // 1.2.3.1 : Fixed : issue with empty caption
  // 1.2.3.2 : Improved : vertical top text alignment
  // 1.2.3.3 : Improved : focus painting
  // 1.2.4.0 : Improved : handling of actions with TAdvOfficeCheckBox
  // 1.2.4.1 : Changed : OnClick event triggered in TAdvOfficeCheckBox for programmatic changes
  // 1.2.4.2 : Improved : bdRightToLeft text drawing for non HTML formatted text
  // 1.2.5.0 : New : Support for cbGrayed state in not themed mode

const
  {$IFDEF DELPHI9_LVL}
  DefDisabledColor = clDkGray;
  {$ENDIF}
  {$IFNDEF DELPHI9_LVL}
  DefDisabledColor = clGray;
  {$ENDIF}

type
  TAnchorClick = procedure (Sender:TObject; Anchor:string) of object;

  TCustomAdvOfficeCheckBox = class;

{$IFDEF DELPHI6_LVL}
  TAdvOfficeCheckBoxActionLink = class(TControlActionLink)
  protected
    FImageIndex: Integer;
    FClient: TCustomAdvOfficeCheckBox;
    function IsCaptionLinked: Boolean; override;
    function IsCheckedLinked: Boolean; override;
    procedure AssignClient(AClient: TObject); override;
    procedure SetChecked(Value: Boolean); override;
    procedure SetCaption(const Value: string); override;
  end;
{$ENDIF}

  TCustomAdvOfficeCheckBox = class(TCustomControl)
  private
    FDown:Boolean;
    FState:TCheckBoxState;
    FFocused:Boolean;
    FShowFocus:Boolean;
    FReturnIsTab:Boolean;
    FImages:TImageList;
    FAnchor: string;
    FAnchorClick: TAnchorClick;
    FAnchorEnter: TAnchorClick;
    FAnchorExit: TAnchorClick;
    FURLColor: TColor;
    FImageCache: THTMLPictureCache;
    FBtnVAlign: TTextLayout;
    FAlignment: TLeftRight;
    FEllipsis: Boolean;
    FCaption: string;
    FContainer: TPictureContainer;
    FShadowOffset: Integer;
    FShadowColor: TColor;
    FIsWinXP: Boolean;
    FHot: Boolean;
    FClicksDisabled: Boolean;
    FOldCursor: TCursor;
    FReadOnly: Boolean;
    {$IFNDEF TMSDOTNET}
    FBkgBmp: TBitmap;
    FBkgCache: boolean;
    FTransparentCaching: boolean;
    {$ENDIF}
    FDrawBkg: boolean;
    FGotClick: boolean;
    FDisabledFontColor: TColor;
    FInternalClick: boolean;
    FThemed: boolean;
    procedure WMEraseBkGnd(var Message:TMessage); message WM_ERASEBKGND;
    procedure CMEnabledChanged(var Message: TMessage); message CM_ENABLEDCHANGED;
    procedure CMDialogChar(var Message: TCMDialogChar); message CM_DIALOGCHAR;
    procedure CMMouseLeave(var Message: TMessage); message CM_MOUSELEAVE;
    procedure CMMouseEnter(var Message: TMessage); message CM_MOUSEENTER;
    procedure SetState(Value:TCheckBoxState);
    procedure SetCaption(Value: string);
    procedure SetImages(const Value: TImageList);
    procedure SetURLColor(const Value:TColor);
    function IsAnchor(x,y:integer):string;
    procedure SetButtonVertAlign(const Value: TTextLayout);
    procedure SetAlignment(const Value: TLeftRight);
    procedure SetEllipsis(const Value: Boolean);
    procedure SetContainer(const Value: TPictureContainer);
    procedure SetShadowColor(const Value: TColor);
    procedure SetShadowOffset(const Value: Integer);
    function GetVersion: string;
    procedure SetVersion(const Value: string);
    procedure SetThemed(const Value: boolean);
    {$IFNDEF TMSDOTNET}
    procedure DrawParentImage (Control: TControl; Dest: TCanvas);
    {$ENDIF}
  protected
    function GetVersionNr: Integer; virtual;
    procedure Notification(AComponent: TComponent; AOperation: TOperation); override;
    procedure DrawCheck;
    procedure Paint; override;
    procedure SetChecked(Value:Boolean); virtual;
    function  GetChecked:Boolean; virtual;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure MouseMove(Shift: TShiftState;X, Y: Integer); override;
    procedure KeyDown(var Key:Word;Shift:TShiftSTate); override;
    procedure KeyUp(var Key:Word;Shift:TShiftSTate); override;
    procedure SetDown(Value:Boolean);
    procedure Loaded; override;
    procedure DoEnter; override;
    procedure DoExit; override;
    property Checked: Boolean read GetChecked write SetChecked default False;
    property ClicksDisabled: Boolean read FClicksDisabled write FClicksDisabled;
{$IFDEF DELPHI6_LVL}
    function GetActionLinkClass: TControlActionLinkClass; override;
    procedure ActionChange(Sender: TObject; CheckDefaults: Boolean); override;
{$ENDIF}
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure Toggle; virtual;
    {$IFNDEF TMSDOTNET}
    procedure SetBounds(ALeft, ATop, AWidth, AHeight: Integer); override;
    property TransparentChaching: boolean read FTransparentCaching write FTransparentCaching;
    {$ENDIF}
    property DrawBkg: Boolean read FDrawBkg write FDrawBkg;
    property Alignment: TLeftRight read FAlignment write SetAlignment;
    property ButtonVertAlign: TTextLayout read FBtnVAlign write setButtonVertAlign default tlTop;
    property Caption: string read FCaption write SetCaption;
    property DisabledFontColor: TColor read FDisabledFontColor write FDisabledFontColor default DefDisabledColor;
    property Down: Boolean read FDown write SetDown default False;
    property Ellipsis: Boolean read FEllipsis write SetEllipsis default False;
    property Images: TImageList read FImages write SetImages;
    property PictureContainer: TPictureContainer read FContainer write SetContainer;
    property ReadOnly: Boolean read FReadOnly write FReadOnly default False;
    property ReturnIsTab: Boolean read FReturnIsTab write FReturnIsTab;
    property ShadowColor: TColor read FShadowColor write SetShadowColor default clGray;
    property ShadowOffset: Integer read FShadowOffset write SetShadowOffset default 1;
    property ShowFocus: Boolean read FShowFocus write FShowFocus default true;
    property State: TCheckBoxState read FState write SetState default cbUnchecked;
    property Themed: boolean read FThemed write SetThemed default false;
    property URLColor: TColor read FURLColor write SetURLColor default clBlue;
    property OnAnchorClick: TAnchorClick read fAnchorClick write fAnchorClick;
    property OnAnchorEnter: TAnchorClick read fAnchorEnter write fAnchorEnter;
    property OnAnchorExit: TAnchorClick read fAnchorExit write fAnchorExit;
    property Version: string read GetVersion write SetVersion;
  end;

  TAdvOfficeCheckBox = class(TCustomAdvOfficeCheckBox)
  published
    property Action;
    property Align;
    property Anchors;
    property BiDiMode;
    property Constraints;
    property Color;
    property Checked;
    property DragCursor;
    property DragKind;
    property DragMode;
    property Enabled;
    property Font;
    property ParentFont;
    property ParentColor;
    property PopupMenu;
    property ShowHint;
    property TabOrder;
    property TabStop;
    property Visible;
    property OnClick;
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

    property Alignment;
    property ButtonVertAlign;
    property Caption;
    property DisabledFontColor;
    property Down;
    property Ellipsis;
    property Images;
    property PictureContainer;
    property ReadOnly;
    property ReturnIsTab;
    property ShadowColor;
    property ShadowOffset;
    property ShowFocus;
    property State;
    property Themed;
    property URLColor;
    property OnAnchorClick;
    property OnAnchorEnter;
    property OnAnchorExit;
    property Version;
  end;

  TCustomAdvOfficeRadioButton = class(TCustomControl)
  private
    FDown: Boolean;
    FChecked: Boolean;
    FFocused: Boolean;
    FShowFocus: Boolean;
    FGroupIndex: Byte;
    FReturnIsTab: Boolean;
    FImages: TImageList;
    FAnchor: string;
    FAnchorClick: TAnchorClick;
    FAnchorEnter: TAnchorClick;
    FAnchorExit: TAnchorClick;
    FURLColor: TColor;
    FImageCache: THTMLPictureCache;
    FBtnVAlign: TTextLayout;
    FAlignment: TLeftRight;
    FEllipsis: Boolean;
    FCaption: string;
    FContainer: TPictureContainer;
    FShadowOffset: Integer;
    FShadowColor: TColor;
    FIsWinXP: Boolean;
    FHot: Boolean;
    FClicksDisabled: Boolean;
    FOldCursor: TCursor;
    {$IFNDEF TMSDOTNET}
    FBkgBmp: TBitmap;
    FBkgCache: boolean;
    FTransparentCaching: boolean;
    {$ENDIF}
    FDrawBkg: Boolean;
    FGotClick: boolean;
    FDisabledFontColor: TColor;
    FThemed: boolean;
    procedure TurnSiblingsOff;
    procedure SetDown(Value:Boolean);
    procedure SetChecked(Value:Boolean);
    procedure SetImages(const Value: TImageList);
    procedure SetURLColor(const Value:TColor);
    function IsAnchor(x,y:integer):string;
    procedure WMLButtonDown(var Message:TWMLButtonDown); message WM_LBUTTONDOWN;
    procedure WMEraseBkGnd(var Message:TMessage); message WM_ERASEBKGND;
    procedure CMEnabledChanged(var Message: TMessage); message CM_ENABLEDCHANGED;
    procedure CMDialogChar(var Message: TCMDialogChar); message CM_DIALOGCHAR;
    procedure CMMouseLeave(var Message: TMessage); message CM_MOUSELEAVE;
    procedure CMMouseEnter(var Message: TMessage); message CM_MOUSEENTER;
    procedure SetButtonVertAlign(const Value: TTextLayout);
    procedure SetAlignment(const Value: TLeftRight);
    procedure SetEllipsis(const Value: Boolean);
    procedure SetCaption(const Value: string);
    procedure SetContainer(const Value: TPictureContainer);
    procedure SetShadowColor(const Value: TColor);
    procedure SetShadowOffset(const Value: Integer);
    function GetVersion: string;
    procedure SetVersion(const Value: string);
    procedure SetThemed(const Value: boolean);
    function GetVersionNr: Integer;
    {$IFNDEF TMSDOTNET}
    procedure DrawParentImage (Control: TControl; Dest: TCanvas);
    {$ENDIF}
  protected
    procedure DrawRadio;
    procedure Paint; override;
    procedure Notification(AComponent: TComponent; AOperation: TOperation); override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure MouseMove(Shift: TShiftState;X, Y: Integer); override;
    procedure KeyDown(var Key:Word;Shift:TShiftSTate); override;
    procedure KeyUp(var Key:Word;Shift:TShiftSTate); override;
    procedure DoEnter; override;
    procedure DoExit; override;
    procedure Loaded; override;
    procedure Click; override;
    procedure DoClick; virtual;
    property ClicksDisabled: Boolean read FClicksDisabled write FClicksDisabled;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    {$IFNDEF TMSDOTNET}
    procedure SetBounds(ALeft, ATop, AWidth, AHeight: Integer); override;
    property TransparentChaching: boolean read FTransparentCaching write FTransparentCaching;
    {$ENDIF}
    property DrawBkg: Boolean read FDrawBkg write FDrawBkg;
    property Alignment: TLeftRight read fAlignment write SetAlignment;
    property URLColor:TColor read FURLColor write SetURLColor default clBlue;
    property ButtonVertAlign: TTextLayout read fBtnVAlign write SetButtonVertAlign default tlTop;
    property Caption: string read FCaption write SetCaption;
    property Checked:Boolean read FChecked write SetChecked default False;
    property DisabledFontColor: TColor read FDisabledFontColor write FDisabledFontColor default DefDisabledColor;
    property Down:Boolean read FDown write SetDown default False;
    property Ellipsis: Boolean read FEllipsis write SetEllipsis default False;
    property GroupIndex:Byte read FGroupIndex write FGroupIndex default 0;
    property Images:TImageList read fImages write SetImages;
    property PictureContainer: TPictureContainer read FContainer write SetContainer;
    property ReturnIsTab:Boolean read FReturnIsTab write FReturnIsTab;
    property ShadowColor: TColor read FShadowColor write SetShadowColor default clGray;
    property ShadowOffset: Integer read FShadowOffset write SetShadowOffset default 1;
    property ShowFocus: Boolean read FShowFocus write FShowFocus default true;
    property Themed: boolean read FThemed write SetThemed default false;
    property OnAnchorClick:TAnchorClick read fAnchorClick write fAnchorClick;
    property OnAnchorEnter:TAnchorClick read fAnchorEnter write fAnchorEnter;
    property OnAnchorExit:TAnchorClick read fAnchorExit write fAnchorExit;
    property Version: string read GetVersion write SetVersion;
  end;

  TAdvOfficeRadioButton = class(TCustomAdvOfficeRadioButton)
  published
    property Align;
    property Action;
    property Anchors;
    property BiDiMode;
    property Constraints;
    property Color;
    property DragCursor;
    property DragKind;
    property DragMode;
    property Enabled;
    property Font;
    property ParentFont;
    property ParentColor;
    property PopupMenu;
    property ShowHint;
    property TabOrder;
    property TabStop;
    property OnClick;
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
    property Visible;

    property Alignment;
    property URLColor;
    property ButtonVertAlign;
    property Caption;
    property Checked;
    property DisabledFontColor;
    property Down;
    property Ellipsis;
    property GroupIndex;
    property Images;
    property PictureContainer;
    property ReturnIsTab;
    property ShadowColor;
    property ShadowOffset;
    property ShowFocus;
    property Themed;
    property OnAnchorClick;
    property OnAnchorEnter;
    property OnAnchorExit;
    property Version;
  end;

  TEnabledEvent = procedure (Sender:TObject; ItemIndex: Integer; var Enabled: Boolean) of object;

  TCustomAdvOfficeRadioGroup = class(TAdvGroupbox)
  private
    FButtons: TList;
    FItems: TStrings;
    FItemIndex: Integer;
    FColumns: Integer;
    FReading: Boolean;
    FUpdating: Boolean;
    FAlignment: TAlignment;
    FBtnVAlign: TTextLayout;
    FImages: TImageList;
    FContainer: TPictureContainer;
    FEllipsis: Boolean;
    FShadowOffset: Integer;
    FShadowColor: TColor;
    FShowFocus: Boolean;
    FOnIsEnabled: TEnabledEvent;
    FIsReadOnly: boolean;
    FDisabledFontColor: TColor;
    FThemed: boolean;
    procedure ArrangeButtons;
    procedure ButtonClick(Sender: TObject);
    procedure ItemsChange(Sender: TObject);
    procedure SetButtonCount(Value: Integer);
    procedure SetColumns(Value: Integer);
    procedure SetItemIndex(Value: Integer);
    procedure SetItems(Value: TStrings);
    procedure UpdateButtons;
    procedure CMEnabledChanged(var Message: TMessage); message CM_ENABLEDCHANGED;
    procedure CMFontChanged(var Message: TMessage); message CM_FONTCHANGED;
    procedure WMSize(var Message: TWMSize); message WM_SIZE;
    procedure SetAlignment(const Value: TAlignment);
    procedure SetButtonVertAlign(const Value: TTextLayout);
    procedure SetContainer(const Value: TPictureContainer);
    procedure SetImages(const Value: TImageList);
    procedure SetEllipsis(const Value: Boolean);
    procedure SetShadowColor(const Value: TColor);
    procedure SetShadowOffset(const Value: Integer);
    procedure SetThemed(const Value: boolean);
    function GetVersion: string;
    procedure SetVersion(const Value: string);
    procedure SetShowFocus(const Value: Boolean);
  protected
    function GetVersionNr: Integer; virtual;
    procedure Loaded; override;
    procedure ReadState(Reader: TReader); override;
    function CanModify: Boolean; virtual;
    procedure Notification(AComponent: TComponent; AOperation: TOperation); override;
    property Columns: Integer read FColumns write SetColumns default 1;
    property ItemIndex: Integer read FItemIndex write SetItemIndex default -1;
    property Items: TStrings read FItems write SetItems;
    property IsReadOnly: boolean read FIsReadOnly write FIsReadOnly;
    property Themed: boolean read FThemed write SetThemed default false;
  public
    procedure GetChildren(Proc: TGetChildProc; Root: TComponent); override;
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure PushKey(var Key: Char);
    procedure PushKeyDown(var Key: Word; Shift: TShiftState);
  
    property Alignment: TAlignment read FAlignment write SetAlignment default taLeftJustify;
    property ButtonVertAlign: TTextLayout read fBtnVAlign write SetButtonVertAlign default tlTop;
    property DisabledFontColor: TColor read FDisabledFontColor write FDisabledFontColor default DefDisabledColor;
    property Ellipsis: Boolean read FEllipsis write SetEllipsis;
    property Images: TImageList read FImages write SetImages;
    property PictureContainer: TPictureContainer read FContainer write SetContainer;
    property ShadowColor: TColor read FShadowColor write SetShadowColor default clSilver;
    property ShadowOffset: Integer read FShadowOffset write SetShadowOffset default 1;
    property ShowFocus: Boolean read FShowFocus write SetShowFocus default true;
    property OnIsEnabled: TEnabledEvent read FOnIsEnabled write FOnIsEnabled;
    property Version: string read GetVersion write SetVersion;
  end;

  TAdvOfficeRadioGroup = class(TCustomAdvOfficeRadioGroup)
  private
  protected
  public
  published
    property Align;
    property Anchors;
    property Constraints;
    property DragKind;
    property ParentBiDiMode;
    property Caption;
    property Color;
    property Columns;
    property Ctl3D;
    property DragCursor;
    property DragMode;
    property Enabled;
    property Font;
    property ItemIndex;
    property Items;
    property ParentColor;
    property ParentCtl3D;
    property ParentFont;
    property ParentShowHint;
    property PopupMenu;
    property ShowHint;
    property TabOrder;
    property TabStop;
    property Themed;
    property Visible;
    property OnClick;
    property OnContextPopup;
    property OnDragDrop;
    property OnDragOver;
    property OnEndDrag;
    property OnEnter;
    property OnExit;
    property OnEndDock;
    property OnStartDock;
    property OnStartDrag;

    property Alignment;
    property ButtonVertAlign;
    property DisabledFontColor;
    property Ellipsis;
    property Images;
    property PictureContainer;
    property ShadowColor;
    property ShadowOffset;
    property ShowFocus;
    property OnIsEnabled;
    property Version;
  end;

  TCustomAdvOfficeCheckGroup = class(TAdvGroupBox)
  private
    FButtons: TList;
    FItems: TStrings;
    FColumns: Integer;
    FReading: Boolean;
    FUpdating: Boolean;
    FAlignment: TAlignment;
    FBtnVAlign: TTextLayout;
    FImages: TImageList;
    FContainer: TPictureContainer;
    FEllipsis: Boolean;
    FShadowOffset: Integer;
    FShadowColor: TColor;
    FShowFocus: Boolean;
    FOnIsEnabled: TEnabledEvent;
    FValue: DWord;
    FFocusButtonIdx: integer;
    FDisabledFontColor: TColor;
    FThemed: Boolean;
    procedure ArrangeButtons;
    procedure ButtonClick(Sender: TObject);
    procedure CheckFocus(Sender: TObject);
    procedure ItemsChange(Sender: TObject);
    procedure SetButtonCount(Value: Integer);
    procedure SetColumns(Value: Integer);
    procedure SetItems(Value: TStrings);
    procedure UpdateButtons;
    procedure CMEnabledChanged(var Message: TMessage); message CM_ENABLEDCHANGED;
    procedure CMFontChanged(var Message: TMessage); message CM_FONTCHANGED;
    procedure WMSize(var Message: TWMSize); message WM_SIZE;
    procedure SetAlignment(const Value: TAlignment);
    procedure SetButtonVertAlign(const Value: TTextLayout);
    procedure SetContainer(const Value: TPictureContainer);
    procedure SetImages(const Value: TImageList);
    procedure SetEllipsis(const Value: Boolean);
    procedure SetShadowColor(const Value: TColor);
    procedure SetShadowOffset(const Value: Integer);
    function GetReadOnly(Index: Integer): Boolean;
    procedure SetReadOnly(Index: Integer; const Value: Boolean);
    function GetVersion: string;
    procedure SetVersion(const Value: string);
    function GetVersionNr: Integer;
    procedure SetValue(const Value: DWord);
    function GetValue: DWord;
    procedure SetThemed(const Value: boolean);
    procedure SetShowFocus(const Value: boolean);
  protected
    procedure Loaded; override;
    procedure DoEnter; override;
    procedure DoExit; override;    
    procedure ReadState(Reader: TReader); override;
    function CanModify: Boolean; virtual;
    function GetChecked(Index: Integer): Boolean; virtual;
    procedure SetChecked(Index: Integer; const Value: Boolean); virtual;
    procedure Notification(AComponent: TComponent; AOperation: TOperation); override;
    property Columns: Integer read FColumns write SetColumns default 1;
    property Items: TStrings read FItems write SetItems;
    property Value: DWord read GetValue write SetValue;
    property Themed: boolean read FThemed write SetThemed default false;
  public
    procedure GetChildren(Proc: TGetChildProc; Root: TComponent); override;
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure UpdateValue;
    procedure PushKey(var Key: Char);
    procedure PushKeyDown(var Key: Word; Shift: TShiftState);
    property Checked[Index: Integer]: Boolean read GetChecked write SetChecked;
    property ReadOnly[Index: Integer]: Boolean read GetReadOnly write SetReadOnly;

    property Alignment: TAlignment read FAlignment write SetAlignment default taLeftJustify;
    property ButtonVertAlign: TTextLayout read fBtnVAlign write SetButtonVertAlign default tlTop;
    property Ellipsis: Boolean read FEllipsis write SetEllipsis;
    property DisabledFontColor: TColor read FDisabledFontColor write FDisabledFontColor default DefDisabledColor;
    property Images: TImageList read FImages write SetImages;
    property PictureContainer: TPictureContainer read FContainer write SetContainer;
    property ShadowColor: TColor read FShadowColor write SetShadowColor default clSilver;
    property ShadowOffset: Integer read FShadowOffset write SetShadowOffset default 1;
    property ShowFocus: boolean read FShowFocus write SetShowFocus default true;
    property OnIsEnabled: TEnabledEvent read FOnIsEnabled write FOnIsEnabled;
    property Version: string read GetVersion write SetVersion;
  end;

  TAdvOfficeCheckGroup = class(TCustomAdvOfficeCheckGroup)
  private
  protected
  public
    property Value;
  published
    property Align;
    property Anchors;
    property Constraints;
    property DragKind;
    property ParentBiDiMode;
    property Caption;
    property Color;
    property Columns;
    property Ctl3D;
    property DragCursor;
    property DragMode;
    property Enabled;
    property Font;
    property Items;
    property ParentColor;
    property ParentCtl3D;
    property ParentFont;
    property ParentShowHint;
    property PopupMenu;
    property ShowHint;
    property TabOrder;
    property TabStop;
    property Themed;
    property Visible;
    property OnClick;
    property OnContextPopup;
    property OnDragDrop;
    property OnDragOver;
    property OnEndDrag;
    property OnEnter;
    property OnExit;
    property OnEndDock;
    property OnStartDock;
    property OnStartDrag;

    property Alignment;
    property ButtonVertAlign;
    property Ellipsis;
    property DisabledFontColor;
    property Images;
    property PictureContainer;
    property ShadowColor;
    property ShadowOffset;
    property ShowFocus;
    property Version;
    property OnIsEnabled;
  end;

var
  TMS_NoClickForProgrammaticCheck: boolean = true;


implementation

uses
  ShellApi, CommCtrl, Math, Imglist, ActnList, Forms;

{$I HTMLENGO.PAS}


const
  BW = 12;

{$IFNDEF TMSDOTNET}
function IsVista: boolean;
var
//  hKernel32: HMODULE;
  dwVersion:Dword;
  dwWindowsMajorVersion,dwWindowsMinorVersion:Dword;

begin
  dwVersion := GetVersion;
  dwWindowsMajorVersion :=  DWORD(LOBYTE(LOWORD(dwVersion)));
  dwWindowsMinorVersion :=  DWORD(HIBYTE(LOWORD(dwVersion)));

  Result := (dwWindowsMajorVersion > 5) OR
    ((dwWindowsMajorVersion = 5) AND (dwWindowsMinorVersion >= 1));

  (*
  hKernel32 := GetModuleHandle('kernel32');
  if (hKernel32 > 0) then
  begin
    Result := GetProcAddress(hKernel32, 'GetLocaleInfoEx') <> nil;
  end
  else
    Result := false;
  *)
end;
{$ENDIF}  

procedure PaintFocusRect(ACanvas: TCanvas; R: TRect; Clr: TColor);
var
  LB: TLogBrush;
  HPen, HOldPen: THandle;
begin
  ACanvas.Pen.Color := Clr;

  lb.lbColor := ColorToRGB(Clr);
  lb.lbStyle := bs_Solid;

  HPen := ExtCreatePen(PS_COSMETIC or PS_ALTERNATE,1, lb, 0, nil);
  HOldPen := SelectObject(ACanvas.Handle, HPen);

  MoveToEx(ACanvas.Handle, R.Left, R.Top, nil);
  LineTo(ACanvas.Handle, R.Right, R.Top);

  MoveToEx(ACanvas.Handle, R.Right, R.Top, nil);
  LineTo(ACanvas.Handle, R.Right, R.Bottom);

  MoveToEx(ACanvas.Handle, R.Right, R.Bottom, nil);
  LineTo(ACanvas.Handle, R.Left, R.Bottom);

  MoveToEx(ACanvas.Handle, R.Left, R.Top, nil);
  LineTo(ACanvas.Handle, R.Left, R.Bottom);

  DeleteObject(SelectObject(ACanvas.Handle,HOldPen));
end;


{$IFNDEF DELPHI4_LVL}
function Min(a,b: Integer): Integer;
begin
  if a < b then
    Result := a
  else
    Result := b;
end;
{$ENDIF}

{$IFDEF DELPHI4_LVL}
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
      if (pvs^.dwSignature = $FEEF04BD) then
      begin
        Result := pvs^.dwFileVersionMS;
      end;
    end;
    FreeMem(buf);
  end;
end;
{$ENDIF}
{$ENDIF}


function DoThemeDrawing: Boolean;
var
  VerInfo: TOSVersioninfo;
  FIsWinXP,FIsComCtl6: boolean;
  i: integer;
begin
  {$IFDEF TMSDOTNET}
  VerInfo.dwOSVersionInfoSize := Marshal.SizeOf(TypeOf(TOSVersionInfo));
  {$ENDIF}
  {$IFNDEF TMSDOTNET}
  VerInfo.dwOSVersionInfoSize := SizeOf(TOSVersionInfo);
  {$ENDIF}

  GetVersionEx(verinfo);

  FIsWinXP := (verinfo.dwMajorVersion > 5) OR
    ((verinfo.dwMajorVersion = 5) AND (verinfo.dwMinorVersion >= 1));

  i := GetFileVersion('COMCTL32.DLL');
  i := (i shr 16) and $FF;

  FIsComCtl6 := (i > 5);

  Result := FIsComCtl6 and FIsWinXP;
end;

{ TCustomHTMLCheckBox }

constructor TCustomAdvOfficeCheckBox.Create(AOwner: TComponent);
var
  VerInfo: TOSVersioninfo;
  FDesignTime: boolean;
begin
  inherited Create(AOwner);
  Width := 120;
  Height := 20;
  FUrlColor := clBlue;
  FBtnVAlign := tlTop;
  FImageCache := THTMLPictureCache.Create;

  FDesignTime := (csDesigning in ComponentState) and not
    ((csReading in Owner.ComponentState) or (csLoading in Owner.ComponentState));

  if FDesignTime then
    FCaption := self.ClassName;

  FShadowOffset := 1;
  FShadowColor := clGray;
  FDisabledFontColor := DefDisabledColor;
  FShowFocus := true;

  {$IFNDEF TMSDOTNET}
  VerInfo.dwOSVersionInfoSize := SizeOf(TOSVersionInfo);
  {$ENDIF}
  {$IFDEF TMSDOTNET}
  VerInfo.dwOSVersionInfoSize := Marshal.SizeOf(TypeOf(TOSVersionInfo));
  {$ENDIF}

  GetVersionEx(verinfo);

  FIsWinXP := (verinfo.dwMajorVersion > 5) OR
    ((verinfo.dwMajorVersion = 5) AND (verinfo.dwMinorVersion >= 1));

  ControlStyle := ControlStyle - [csClickEvents];
  FReadOnly := False;

  {$IFNDEF TMSDOTNET}
  FBkgBmp := TBitmap.Create;
  FBkgCache := false;
  FTransparentCaching := false;
  {$ENDIF}
  FDrawBkg := true;
end;

function TCustomAdvOfficeCheckBox.IsAnchor(x,y:integer):string;
var
  r,hr: TRect;
  XSize,YSize,HyperLinks,MouseLink: Integer;
  s:string;
  Anchor, Stripped, FocusAnchor:string;
begin
  r := Clientrect;
  s := Caption;
  Anchor:='';

  r.left := r.left + BW + 5;
  r.top := r.top + 4;

  Result := '';

  if HTMLDrawEx(Canvas,s,r,FImages,x,y,-1,-1,FShadowOffset,True,False,False,False,False,False,not FEllipsis,1.0,FURLColor,
                clNone,clNone,FShadowColor,Anchor,Stripped,FocusAnchor,XSize,YSize,HyperLinks,MouseLink,hr,FImageCache,FContainer,0) then
    Result := Anchor;
end;

{$IFNDEF TMSDOTNET}

procedure TCustomAdvOfficeCheckBox.DrawParentImage(Control: TControl; Dest: TCanvas);
var
  SaveIndex: Integer;
  DC: HDC;
  Position: TPoint;
begin
  with Control do
  begin
    if Parent = nil then
      Exit;

    DC := Dest.Handle;
    SaveIndex := SaveDC(DC);
    GetViewportOrgEx(DC, Position);
    SetViewportOrgEx(DC, Position.X - Left, Position.Y - Top, nil);
    IntersectClipRect(DC, 0, 0, Parent.ClientWidth, Parent.ClientHeight);

    Parent.Perform(WM_ERASEBKGND, Integer(DC), Integer(0));
    Parent.Perform(WM_PAINT, Integer(DC), Integer(0));
    RestoreDC(DC, SaveIndex);
  end;
end;

procedure TCustomAdvOfficeCheckBox.SetBounds(ALeft, ATop, AWidth, AHeight: Integer);
begin
  inherited;
  FBkgCache := false;
  Repaint;
end;
{$ENDIF}



procedure TCustomAdvOfficeCheckBox.DrawCheck;
var
  bmp: TBitmap;
  BL,BT:Integer;
  HTheme: THandle;
  r: TRect;
  FIsComCtl6: boolean;
  i: integer;
  DrawThemed: boolean;
begin
  BT := 4;

  i := GetFileVersion('COMCTL32.DLL');
  i := (i shr 16) and $FF;

  FIsComCtl6 := (i > 5);

  {$IFNDEF TMSDOTNET}

  DrawThemed := IsVista and Themed and IsThemeActive and FIsComCtl6;

  if DrawThemed then
  begin
    case FBtnVAlign of
    tlTop: BT := 4 + (Canvas.TextHeight('gh') - 16) div 2;
    tlCenter: BT := (ClientRect.Bottom - ClientRect.Top) div 2 - (16 div 2);
    tlBottom: BT := ClientRect.Bottom - 16;
    end;

    if (FAlignment = taRightJustify) or UseRightToLeftAlignment then
      BL := ClientRect.Right - 16 - 1
    else
      BL := 0;

    HTheme := OpenThemeData(Self.Handle,'button');
    r := Rect(BL, BT, BL + 16, BT + 16);

    if HTheme <> 0 then
    begin
      case State of
      cbChecked:
        begin
          if not Enabled then
             DrawThemeBackground(HTheme,Canvas.Handle, BP_CHECKBOX,CBS_CHECKEDDISABLED,@r,nil)
          else
            if Down then
              DrawThemeBackground(HTheme,Canvas.Handle, BP_CHECKBOX,CBS_CHECKEDNORMAL or CBS_PUSHED,@r,nil)
            else
              if FHot then
                DrawThemeBackground(HTheme,Canvas.Handle, BP_CHECKBOX,CBS_CHECKEDNORMAL or CBS_HOT,@r,nil)
              else
                DrawThemeBackground(HTheme,Canvas.Handle, BP_CHECKBOX,CBS_CHECKEDNORMAL,@r,nil);
        end;
      cbUnChecked:
        begin
          if not Enabled then
            DrawThemeBackground(HTheme,Canvas.Handle, BP_CHECKBOX,CBS_UNCHECKEDDISABLED,@r,nil)
          else
          if Down then
            DrawThemeBackground(HTheme,Canvas.Handle, BP_CHECKBOX,CBS_UNCHECKEDNORMAL or CBS_PUSHED,@r,nil)
          else
            if FHot then
              DrawThemeBackground(HTheme,Canvas.Handle, BP_CHECKBOX,CBS_UNCHECKEDNORMAL or CBS_HOT,@r,nil)
            else
              DrawThemeBackground(HTheme,Canvas.Handle, BP_CHECKBOX,CBS_UNCHECKEDNORMAL,@r,nil);
        end;
      cbGrayed:
        begin

          if not Enabled then
            DrawThemeBackground(HTheme,Canvas.Handle, BP_CHECKBOX,CBS_MIXEDDISABLED,@r,nil)
          else
          if Down then
            DrawThemeBackground(HTheme,Canvas.Handle, BP_CHECKBOX,CBS_MIXEDPRESSED,@r,nil)
          else
            if FHot then
              DrawThemeBackground(HTheme,Canvas.Handle, BP_CHECKBOX,CBS_MIXEDHOT or CBS_HOT,@r,nil)
            else
              DrawThemeBackground(HTheme,Canvas.Handle, BP_CHECKBOX,CBS_MIXEDNORMAL,@r,nil);
         end;
      end;
      CloseThemeData(HTheme);
    end
    else
      DrawThemed := false;
  end;
  {$ENDIF TMSDOTNET}
  
  if not DrawThemed then
  begin
    //ExtraBW := 4;
    bmp := TBitmap.Create;

    if state = cbGrayed then
    begin
      if Down then
        bmp.LoadFromResourceName(hinstance,'TMSOFCGD')
      else
        if FHot then
          bmp.LoadFromResourceName(hinstance,'TMSOFCGH')
        else
          bmp.LoadFromResourceName(hinstance,'TMSOFCG');

    end
    else
    if state = cbChecked then
    begin
      if Down then
        bmp.LoadFromResourceName(hinstance,'TMSOFCCD')
      else
        if FHot then
          bmp.LoadFromResourceName(hinstance,'TMSOFCCH')
        else
          bmp.LoadFromResourceName(hinstance,'TMSOFCC');

    end
    else
    begin
      if Down then
        bmp.LoadFromResourceName(hinstance,'TMSOFCUD')
      else
        if FHot then
          bmp.LoadFromResourceName(hinstance,'TMSOFCUH')
        else
          bmp.LoadFromResourceName(hinstance,'TMSOFCU');
    end;

    bmp.Transparent := true;
    bmp.TransparentMode := tmAuto;

    case FBtnVAlign of
    tlTop: BT :=  4 + (Canvas.TextHeight('gh') - bmp.Height) div 2;
    tlCenter: BT := (ClientRect.Bottom - ClientRect.Top) div 2 - (bmp.Height div 2);
    tlBottom: BT := ClientRect.Bottom - bmp.Height;
    end;

    if (FAlignment = taRightJustify) or UseRightToLeftAlignment then
      BL := ClientRect.Right - bmp.Width - 1
    else
      BL := 0;

    Canvas.Draw(BL,BT,bmp);
    bmp.free;
  end;
end;

procedure TCustomAdvOfficeCheckBox.Paint;
var
  R, hr: TRect;
  a,s,fa,text: string;
  xsize,ysize: Integer;
  ExtraBW,HyperLinks,MouseLink: Integer;

begin
  Canvas.Font := Font;

  if FTransparentCaching then
  begin
    if FBkgCache then
    begin
      Canvas.Draw(0,0,FBkgBmp)
    end
    else
    begin
      FBkgBmp.Width := self.Width;
      FBkgBmp.Height := self.Height;
      DrawParentImage(Self, FBkgBmp.Canvas);
      Canvas.Draw(0,0,FBkgBmp);
      FBkgCache := true;
    end;
  end
  else
  begin
    {$IFNDEF DELPHI_UNICODE}
    if FDrawBkg or IsVista then
    {$ENDIF}
      DrawParentImage(Self, Canvas);
  end;

  with Canvas do
  begin
    Text := Caption;

    DrawCheck;

    ExtraBW := 4;

    R := GetClientRect;

    if (FAlignment = taRightJustify) or UseRightToLeftAlignment then
    begin
      r.Left := 0;
      r.Right := r.Right - BW - ExtraBW;
    end
    else
      r.Left := r.Left + BW + ExtraBW;

    r.top := r.top + 4;

    if (BidiMode = bdRightToLeft) and (pos('</',Text) = 0) then
    begin
      Canvas.Brush.Style := bsClear;
      {$IFNDEF TMSDOTNET}
      DrawText(Canvas.Handle, PChar(Text), Length(Text), r, DT_RIGHT);
      {$ENDIF}
      {$IFDEF TMSDOTNET}
      DrawText(Canvas.Handle, Text, Length(Text), r, DT_RIGHT);
      {$ENDIF}
    end
    else
    begin
      HTMLDrawEx(Canvas,Text,R,FImages,0,0,-1,-1,FShadowOffset,True,False,False,False,False,False,not FEllipsis,1.0,FURLColor,
        clNone,clNone,FShadowColor,a,s,fa,XSize,YSize,HyperLinks,MouseLink,hr,FImageCache,FContainer,0);

      if UseRightToLeftAlignment then
        r.Left := r.Right - Xsize - 3;

      if not Enabled then
      begin
        OffsetRect(r,1,1);
        Canvas.Font.Color := clWhite;
        HTMLDrawEx(Canvas,Text,R,FImages,0,0,-1,-1,FShadowOffset,False,False,False,False,False,False,not FEllipsis,1.0,clWhite,
          clNone,clNone,FShadowColor,a,s,fa,XSize,YSize,HyperLinks,MouseLink,hr,FImageCache,FContainer,0);

        //Canvas.Font.Color := clGray;
        Canvas.Font.Color := DisabledFontColor;
        Offsetrect(r,-1,-1);

        HTMLDrawEx(Canvas,Text,R,FImages,0,0,-1,-1,FShadowOffset,False,False,False,False,False,False,not FEllipsis,1.0,clGray,
          clNone,clNone,FShadowColor,a,s,fa,XSize,YSize,HyperLinks,MouseLink,hr,FImageCache,FContainer,0);
      end
      else
        HTMLDrawEx(Canvas,Text,R,FImages,0,0,-1,-1,FShadowOffset,False,False,False,False,False,False,not FEllipsis,1.0,FURLColor,
          clNone,clNone,FShadowColor,a,s,fa,XSize,YSize,HyperLinks,MouseLink,hr,FImageCache,FContainer,0);
    end;

    if FFocused and TabStop and FShowFocus then
    begin
      r.right := r.left + xsize + 3;
      r.bottom := r.top + ysize ;
      //WinProcs.DrawFocusRect(Canvas.Handle,R);
      PaintFocusRect(Canvas,R,Font.Color);
    end;
  end;
end;

procedure TCustomAdvOfficeCheckBox.SetDown(Value:Boolean);
begin
  if FDown <> Value then
  begin
    FDown := Value;
  end;
end;

procedure TCustomAdvOfficeCheckBox.SetState(Value:TCheckBoxState);
var
  r: TRect;
begin
  if FState <> Value then
  begin
    FState := Value;

    if HandleAllocated and HasParent then
    begin
      r := GetClientRect;
      case Alignment of
      taLeftJustify: r.Right := 20;
      taRightJustify: r.Left := r.Right - 20;
      end;
      {$IFNDEF TMSDOTNET}
      InvalidateRect(self.Handle,@r,True);
      {$ENDIF}
      {$IFDEF TMSDOTNET}
      InvalidateRect(self.Handle,r,True);
      {$ENDIF}
    end;
  end;
end;

procedure TCustomAdvOfficeCheckBox.SetThemed(const Value: boolean);
begin
  if (Value <> FThemed) then
  begin
    FThemed := Value;
    Invalidate;
  end;
end;

function TCustomAdvOfficeCheckBox.GetChecked: Boolean;
begin
  Result := (State = cbChecked);
end;

procedure TCustomAdvOfficeCheckBox.SetChecked(Value:Boolean);
begin
  if (Value <> (State = cbChecked)) then
  begin

    if Value then
      State := cbChecked
    else
      State := cbUnchecked;

    Invalidate;

    if not FInternalClick and Assigned(OnClick) and not TMS_NoClickForProgrammaticCheck then
      OnClick(Self);
  end;
end;

//------------------------------------------------------------------------------

{$IFDEF DELPHI6_LVL}
procedure TCustomAdvOfficeCheckBox.ActionChange(Sender: TObject; CheckDefaults: Boolean);
begin
  inherited ActionChange(Sender, CheckDefaults);
  if Sender is TCustomAction then
  begin
    Caption := TCustomAction(Sender).Caption;
    Checked := TCustomAction(Sender).Checked;
    Enabled := TCustomAction(Sender).Enabled;
  end;
end;

//------------------------------------------------------------------------------

function TCustomAdvOfficeCheckBox.GetActionLinkClass: TControlActionLinkClass;
begin
  Result := TAdvOfficeCheckBoxActionLink;
end;
{$ENDIF}


procedure TCustomAdvOfficeCheckBox.DoEnter;
{$IFNDEF DELPHI9_LVL}
var
  R: TRect;
{$ENDIF}  
begin
  inherited DoEnter;
  FFocused := True;
  {$IFDEF DELPHI9_LVL}
  Repaint;
  {$ELSE}
  if ShowFocus then
    Repaint
  else
  begin
    R := ClientRect;
    R.Right := 16;
    InvalidateRect(self.Handle, @R, true);
  end;
  {$ENDIF}
end;


procedure TCustomAdvOfficeCheckBox.DoExit;
var
  db: boolean;
begin
  inherited DoExit;
  FFocused := False;
  db := FDrawBkg;
  FDrawBkg := true;
  Repaint;
  FDrawBkg := db;
end;

procedure TCustomAdvOfficeCheckBox.MouseDown(Button: TMouseButton; Shift: TShiftState;X, Y: Integer);
var
  Anchor:string;
  R: TRect;
begin
  Anchor := '';
  FGotClick := true;

  if FFocused then
  begin
    Anchor := IsAnchor(X,Y);

    if Anchor <> '' then
    begin
      if (Pos('://',Anchor) > 0) or (Pos('mailto:',anchor) > 0) then
        {$IFNDEF TMSDOTNET}
        Shellexecute(0,'open',pchar(anchor),nil,nil,SW_NORMAL)
        {$ENDIF}
        {$IFDEF TMSDOTNET}
        Shellexecute(0,'open',anchor,'','',SW_NORMAL)
        {$ENDIF}
      else
      begin
        if Assigned(FAnchorClick) then
          FAnchorClick(self,anchor);
      end;
    end;
  end
  else
  begin
    if (self.CanFocus and not (csDesigning in ComponentState)) then
    begin
      SetFocus;
      FFocused := True;
    end;
  end;

  if (Anchor = '') then
  begin
    inherited MouseDown(Button, Shift, X, Y);
    MouseCapture := True;
    Down := True;
  end;

  R := ClientRect;
  R.Right := 16;
  InvalidateRect(Self.Handle,@R, true);
end;

procedure TCustomAdvOfficeCheckBox.MouseUp(Button: TMouseButton; Shift: TShiftState;
                                  X, Y: Integer);
var
  R: TRect;
begin
  MouseCapture := False;

  Down := False;

  if (X >= 0) and (X <= Width) and (Y >= 0) and (Y <= Height) and FFocused and FGotClick then
  begin
    ClicksDisabled := True;
    Toggle;
    ClicksDisabled := False;
    Click;
  end;

  inherited MouseUp(Button, Shift, X, Y);

  R := ClientRect;
  R.Right := 16;
  InvalidateRect(Self.Handle,@R, true);

  FGotClick := false;
end;

procedure TCustomAdvOfficeCheckBox.MouseMove(Shift: TShiftState;X, Y: Integer);
var
  Anchor:string;
begin

  if MouseCapture then
     Down := (X >= 0) and (X <= Width) and (Y >= 0) and (Y <= Height);

  if fFocused then
    Anchor := IsAnchor(x,y)
  else
    Anchor := '';

  if Anchor <> '' then
  begin
    if (self.Cursor = crDefault) or (FAnchor <> Anchor) then
    begin
      FAnchor := Anchor;
      self.Cursor := crHandPoint;
      if Assigned(FAnchorEnter) then
        FAnchorEnter(self,Anchor);
    end;
  end
  else
  begin
    if self.Cursor = crHandPoint then
    begin
      self.Cursor := FOldCursor;
      if Assigned(FAnchorExit) then
        FAnchorExit(self,Anchor);
    end;
  end;

  inherited MouseMove(Shift,X,Y);
end;

procedure TCustomAdvOfficeCheckBox.KeyDown(var Key:Word;Shift:TShiftSTate);
begin
  if (Key=vk_return) and (fReturnIsTab) then
  begin
    Key := vk_tab;
    PostMessage(self.Handle,wm_keydown,VK_TAB,0);
  end;

  if Key = vk_Space then
    Down := True;

  inherited KeyDown(Key,Shift);
end;

procedure TCustomAdvOfficeCheckBox.KeyUp(var Key:Word;Shift:TShiftSTate);
begin
  if Key = vk_Space then
  begin
    Down := False;
    Toggle;
    Click;
  end;
end;


procedure TCustomAdvOfficeCheckBox.SetImages(const Value: TImageList);
begin
  FImages := Value;
  Invalidate;
end;

procedure TCustomAdvOfficeCheckBox.SetURLColor(const Value: TColor);
begin
  if FURLColor <> Value then
  begin
    FURLColor := Value;
    Invalidate;
  end;
end;

procedure TCustomAdvOfficeCheckBox.Notification(AComponent: TComponent;
  AOperation: TOperation);
begin
  inherited;

  if (AOperation = opRemove) and (AComponent = FImages) then
    FImages:=nil;

  if (AOperation = opRemove) and (AComponent = FContainer) then
    FContainer := nil;
end;

procedure TCustomAdvOfficeCheckBox.CMEnabledChanged(var Message: TMessage);
begin
  inherited;
  Invalidate;
end;

procedure TCustomAdvOfficeCheckBox.SetButtonVertAlign(const Value: TTextLayout);
begin
  if Value <> FBtnVAlign then
  begin
    FBtnVAlign := Value;
    Invalidate;
  end;
end;

procedure TCustomAdvOfficeCheckBox.SetAlignment(const Value: TLeftRight);
begin
  if FAlignment <> Value then
  begin
    FAlignment := Value;
    Invalidate;
  end;
end;

destructor TCustomAdvOfficeCheckBox.Destroy;
begin
  {$IFNDEF TMSDOTNET}
  FBkgBmp.Free;
  {$ENDIF}
  FImageCache.Free;
  inherited;
end;

procedure TCustomAdvOfficeCheckBox.SetEllipsis(const Value: Boolean);
begin
  if FEllipsis <> Value then
  begin
    FEllipsis := Value;
    Invalidate
  end;
end;

procedure TCustomAdvOfficeCheckBox.SetCaption(Value: string);
begin
  {$IFNDEF TMSDOTNET}
  SetWindowText(Handle,pchar(Value));
  {$ENDIF}
  {$IFDEF TMSDOTNET}                  
  SetWindowText(Handle,Value);
  {$ENDIF}
  FCaption := Value;
  Invalidate;
end;


procedure TCustomAdvOfficeCheckBox.Toggle;
begin
  if not FReadOnly then
  begin
    FInternalClick := true;
    Checked := not Checked;
    FInternalClick := false;
  end;
end;

procedure TCustomAdvOfficeCheckBox.WMEraseBkGnd(var Message: TMessage);
begin
  {$IFDEF DELPHI_UNICODE}
  inherited;
  {$ENDIF}
  {$IFNDEF DELPHI_UNICODE}
  Message.Result := 1
  {$ENDIF}  
end;

procedure TCustomAdvOfficeCheckBox.CMDialogChar(var Message: TCMDialogChar);
begin
  with Message do
  begin
    if IsAccel(CharCode, FCaption) and CanFocus then
    begin
      Toggle;
      if Assigned(OnClick) then
        OnClick(Self);
      if TabStop then
        if (self.CanFocus and not (csDesigning in ComponentState)) then 
          SetFocus;
      Result := 1;
    end 
    else
      inherited;
  end;
end;

procedure TCustomAdvOfficeCheckBox.SetContainer(const Value: TPictureContainer);
begin
  FContainer := Value;
  Invalidate;
end;

procedure TCustomAdvOfficeCheckBox.SetShadowColor(const Value: TColor);
begin
  if FShadowColor <> Value then
  begin
    FShadowColor := Value;
    Invalidate;
  end;
end;

procedure TCustomAdvOfficeCheckBox.SetShadowOffset(const Value: Integer);
begin
  if FShadowOffset <> Value then
  begin
    FShadowOffset := Value;
    Invalidate;
  end;
end;

procedure TCustomAdvOfficeCheckBox.CMMouseEnter(var Message: TMessage);
begin
  FHot := True;
  DrawCheck;
  inherited;
end;

procedure TCustomAdvOfficeCheckBox.CMMouseLeave(var Message: TMessage);
begin
  FHot := False;
  DrawCheck;
  inherited;
end;

procedure TCustomAdvOfficeCheckBox.Loaded;
begin
  inherited;
  FOldCursor := Cursor;
end;

function TCustomAdvOfficeCheckBox.GetVersion: string;
var
  vn: Integer;
begin
  vn := GetVersionNr;
  Result := IntToStr(Hi(Hiword(vn)))+'.'+IntToStr(Lo(Hiword(vn)))+'.'+IntToStr(Hi(Loword(vn)))+'.'+IntToStr(Lo(Loword(vn)));
end;

function TCustomAdvOfficeCheckBox.GetVersionNr: Integer;
begin
  Result := MakeLong(MakeWord(BLD_VER,REL_VER),MakeWord(MIN_VER,MAJ_VER));
end;

procedure TCustomAdvOfficeCheckBox.SetVersion(const Value: string);
begin

end;

{ TCustomAdvOfficeRadioButton }

constructor TCustomAdvOfficeRadioButton.Create(AOwner: TComponent);
var
  VerInfo: TOSVersionInfo;
  FDesignTime: boolean;
begin
  inherited Create(AOwner);
  Width := 135;
  Height := 20;
  FURLColor := clBlue;
  FBtnVAlign := tlTop;
  FImageCache := THTMLPictureCache.Create;

  FDesignTime := (csDesigning in ComponentState) and not
    ((csReading in Owner.ComponentState) or (csLoading in Owner.ComponentState));

  if FDesignTime then
    FCaption := self.ClassName;

  FShadowOffset := 1;
  FShadowColor := clGray;
  FDisabledFontColor := DefDisabledColor;
  FShowFocus := true;
  {$IFNDEF TMSDOTNET}
  VerInfo.dwOSVersionInfoSize := SizeOf(TOSVersionInfo);
  {$ENDIF}
  {$IFDEF TMSDOTNET}
  VerInfo.dwOSVersionInfoSize := Marshal.SizeOf(TypeOf(TOSVersionInfo));
  {$ENDIF}
  GetVersionEx(verinfo);

  FIsWinXP := (verinfo.dwMajorVersion > 5) OR
    ((verinfo.dwMajorVersion = 5) AND (verinfo.dwMinorVersion >= 1));

  {$IFNDEF TMSDOTNET}
  FBkgBmp := TBitmap.Create;
  FBkgCache := false;
  FTransparentCaching := false;
  {$ENDIF}
  FDrawBkg := true;
end;

function TCustomAdvOfficeRadioButton.IsAnchor(x,y:integer):string;
var
  r,hr: TRect;
  XSize,YSize,HyperLinks,MouseLink: Integer;
  s: string;
  Anchor,Stripped,FocusAnchor: string;
begin
  r := Clientrect;
  s := Caption;
  Anchor := '';

  r.left := r.left + BW + 5;
  r.top := r.top + 4;

  Result := '';

  if HTMLDrawEx(Canvas,s,r,FImages,x,y,-1,-1,FShadowOffset,True,False,False,False,False,False,not FEllipsis,1.0,FURLColor,
                clNone,clNone,FShadowColor,Anchor,Stripped,FocusAnchor,XSize,YSize,HyperLinks,MouseLink,hr,FImageCache,FContainer,0) then
    Result := Anchor;
end;

procedure TCustomAdvOfficeRadioButton.DrawParentImage(Control: TControl; Dest: TCanvas);
var
  SaveIndex: Integer;
  DC: HDC;
  Position: TPoint;
begin
  with Control do
  begin
    if Parent = nil then
      Exit;
    DC := Dest.Handle;
    SaveIndex := SaveDC(DC);
    GetViewportOrgEx(DC, Position);
    SetViewportOrgEx(DC, Position.X - Left, Position.Y - Top, nil);
    IntersectClipRect(DC, 0, 0, Parent.ClientWidth, Parent.ClientHeight);
    Parent.Perform(WM_ERASEBKGND, Integer(DC), Integer(0));
    Parent.Perform(WM_PAINT, Integer(DC), Integer(0));
    RestoreDC(DC, SaveIndex);
  end;
end;


procedure TCustomAdvOfficeRadioButton.SetBounds(ALeft, ATop, AWidth, AHeight: Integer);
begin
  inherited;
  begin
    FBkgCache := false;
    Repaint;
  end;
end;

procedure TCustomAdvOfficeRadioButton.DrawRadio;
var
  bmp: TBitmap;
  BT, BL: integer;
  i: integer;
  HTheme: THandle;
  FIsComCtl6: boolean;
  r: TRect;
  DrawThemed: boolean;
begin
  BT := 4;

  i := GetFileVersion('COMCTL32.DLL');
  i := (i shr 16) and $FF;

  FIsComCtl6 := (i > 5);

  DrawThemed := IsVista and Themed and IsThemeActive and FIsComCtl6;

  {$IFNDEF TMSDOTNET}
  if DrawThemed then
  begin
    case FBtnVAlign of
    tlTop: BT := 4;
    tlCenter: BT := (ClientRect.Bottom - ClientRect.Top) div 2 - (16 div 2);
    tlBottom: BT := ClientRect.Bottom - 16;
    end;

    if (FAlignment = taRightJustify) or UseRightToLeftAlignment then
      BL := ClientRect.Right - 16 - 1
    else
      BL := 0;

    HTheme := OpenThemeData(Self.Handle,'button');
    r := Rect(BL, BT, BL + 16, BT + 16);

    if HTheme <> 0 then
    begin
      if Checked then
      begin
        if not Enabled then
           DrawThemeBackground(HTheme,Canvas.Handle, BP_RADIOBUTTON,RBS_CHECKEDDISABLED,@r,nil)
        else
          if Down then
            DrawThemeBackground(HTheme,Canvas.Handle, BP_RADIOBUTTON,RBS_CHECKEDNORMAL or RBS_PUSHED,@r,nil)
          else
            if FHot then
              DrawThemeBackground(HTheme,Canvas.Handle, BP_RADIOBUTTON,RBS_CHECKEDNORMAL or RBS_HOT,@r,nil)
            else
              DrawThemeBackground(HTheme,Canvas.Handle, BP_RADIOBUTTON,RBS_CHECKEDNORMAL,@r,nil);
      end
      else
      begin
        if not Enabled then
          DrawThemeBackground(HTheme,Canvas.Handle, BP_RADIOBUTTON,RBS_UNCHECKEDDISABLED,@r,nil)
        else
        if Down then
          DrawThemeBackground(HTheme,Canvas.Handle, BP_RADIOBUTTON,RBS_UNCHECKEDNORMAL or RBS_PUSHED,@r,nil)
        else
          if FHot then
            DrawThemeBackground(HTheme,Canvas.Handle, BP_RADIOBUTTON,RBS_UNCHECKEDNORMAL or RBS_HOT,@r,nil)
          else
            DrawThemeBackground(HTheme,Canvas.Handle, BP_RADIOBUTTON,RBS_UNCHECKEDNORMAL,@r,nil);
      end;

      CloseThemeData(HTheme);
    end
    else
      DrawThemed := false;
  end;
  {$ENDIF}
  if not DrawThemed then
  begin
    bmp := TBitmap.Create;
    if (Checked) then
    begin
      if Down then
        bmp.LoadFromResourceName(hinstance,'TMSOFRCD')
      else
        if FHot then
          bmp.LoadFromResourceName(hinstance,'TMSOFRCH')
        else
          bmp.LoadFromResourceName(hinstance,'TMSOFRC');

    end
    else
    begin
      if Down then
        bmp.LoadFromResourceName(hinstance,'TMSOFRUD')
      else
        if FHot then
          bmp.LoadFromResourceName(hinstance,'TMSOFRUH')
        else
          bmp.LoadFromResourceName(hinstance,'TMSOFRU');
    end;

    bmp.Transparent:=true;
    bmp.TransparentMode :=tmAuto;

    case FBtnVAlign of
    tlTop: BT := 4;
    tlCenter: BT := (ClientRect.Bottom-ClientRect.Top) div 2 - (bmp.Height div 2);
    tlBottom: BT := ClientRect.Bottom - bmp.Height - 2;
    end;

    if (FAlignment = taRightJustify) or UseRightToLeftAlignment then
      BL := ClientRect.Right - bmp.Width - 1
    else
      BL := 0;
    Canvas.Draw(BL,BT,bmp);
    bmp.Free;
  end;
end;

procedure TCustomAdvOfficeRadioButton.Paint;
var
  BR:Integer;
  R,hr: TRect;
  a,s,fa,text: string;
  XSize,YSize,HyperLinks,MouseLink: Integer;

begin
  Canvas.Font := Font;
  Text := Caption;

  if FTransparentCaching then
  begin
    if FBkgCache then
    begin
      Self.Canvas.Draw(0,0,FBkgBmp)
    end
    else
    begin
      FBkgBmp.Width := self.Width;
      FBkgBmp.Height := self.Height;
      //FBkgBmp.PixelFormat := pf32bit;
      DrawParentImage(Self, FBkgBmp.Canvas);
      Self.Canvas.Draw(0,0,FBkgBmp);
      FBkgCache := true;
    end;
  end
  else
  begin
    {$IFNDEF DELPHI_UNICODE}
    if DrawBkg or IsVista then
    {$ENDIF}
      DrawParentImage(Self, self.Canvas);
  end;

  with Canvas do
  begin
    BR := 13;
    DrawRadio;

    r := GetClientRect;
    if (FAlignment = taRightJustify) or UseRightToLeftAlignment then
    begin
      r.Left := 0;
      r.Right := r.Right - BR - 5;
    end
    else
      r.Left := r.Left + BR + 5;

    r.Top := r.Top + 4;

    HTMLDrawEx(Canvas,Text,R,FImages,0,0,-1,-1,FShadowOffset,True,False,False,False,False,False,not FEllipsis,1.0,clGray,
      clNone,clNone,FShadowColor,a,s,fa,XSize,YSize,HyperLinks,MouseLink,hr,FImageCache,FContainer,0);

    if UseRightToLeftAlignment then
      r.Left := r.Right - Xsize - 3;

    if ButtonVertAlign in [tlCenter, tlBottom] then
    begin
      HTMLDrawEx(Canvas,Text,R,FImages,0,0,-1,-1,FShadowOffset,false,true,False,False,False,False,not FEllipsis,1.0,FURLColor,
              clNone,clNone,FShadowColor,a,s,fa,XSize,YSize,HyperLinks,MouseLink,hr,FImageCache,FContainer,0);
      case ButtonVertAlign of
      tlCenter: r.Top := r.Top - 3 + (r.Bottom - r.Top - YSize) div 2;
      tlBottom: r.Top := r.Bottom - YSize - 3;
      end;
    end;

    if not Enabled then
    begin
      OffsetRect(R,1,1);
      Canvas.Font.Color := clWhite;
      HTMLDrawEx(Canvas,Text,R,FImages,0,0,-1,-1,FShadowOffset,False,False,False,False,False,False,not FEllipsis,1.0,clGray,
        clNone,clNone,FShadowColor,a,s,fa,XSize,YSize,HyperLinks,MouseLink,hr,FImageCache,FContainer,0);
      //Canvas.Font.Color := clGray;
      Canvas.Font.Color := DisabledFontColor;
      Offsetrect(R,-1,-1);
      HTMLDrawEx(Canvas,Text,R,FImages,0,0,-1,-1,FShadowOffset,False,False,False,False,False,False,not FEllipsis,1.0,clWhite,
        clNone,clNone,FShadowColor,a,s,fa,XSize,YSize,HyperLinks,MouseLink,hr,FImageCache,FContainer,0);
    end
    else
    begin
      Canvas.Font.Color := Font.Color;
      HTMLDrawEx(Canvas,Text,R,FImages,0,0,-1,-1,FShadowOffset,False,False,False,False,False,False,not FEllipsis,1.0,FURLColor,
              clNone,clNone,FShadowColor,a,s,fa,XSize,YSize,HyperLinks,MouseLink,hr,FImageCache,FContainer,0);
    end;


    (*
    if FFocused then
    begin
      r.Right := r.Left + xsize + 3;
      r.Bottom := r.Top + ysize {+ 1};
      PaintFocusRect(Canvas,R,clBlack);
    end;
    *)
    R.Right := R.Left + XSize + 1;
    R.Left := ClientRect.Left;
    R.Bottom := ClientRect.Bottom - 1;
    R.Top := R.Top - 1;

    if FFocused and FChecked and TabStop and FShowFocus then
    begin
      PaintFocusRect(Canvas,R,Font.Color);
    end
    else if (Parent <> nil) then
    begin
      //PaintFocusRect(Canvas,R,TCustomAdvOfficeRadioGroup(Parent).Color);
    end;
  end;
end;

procedure TCustomAdvOfficeRadioButton.SetURLColor(const Value: TColor);
begin
  FURLColor := Value;
  Invalidate;
end;


procedure TCustomAdvOfficeRadioButton.SetDown(Value:Boolean);
begin
  if FDown<>Value then
  begin
    FDown := Value;
  end;
end;


procedure TCustomAdvOfficeRadioButton.TurnSiblingsOff;
var
  i:Integer;
  Sibling: TAdvOfficeRadioButton;

begin
  if (Parent <> nil) then
  for i:=0 to Parent.ControlCount-1 do
    if Parent.Controls[i] is TAdvOfficeRadioButton then
    begin
      Sibling := TAdvOfficeRadioButton(Parent.Controls[i]);
      if (Sibling <> Self) and
         (Sibling.GroupIndex = GroupIndex) then
          Sibling.SetChecked(False);
    end;
end;

procedure TCustomAdvOfficeRadioButton.SetChecked(Value: Boolean);
{$IFDEF DELPHI2006_LVL}
var
  r: TRect;
{$ENDIF}
begin
  if FChecked <> Value then
  begin
    TabStop := Value;
    FChecked := Value;
    if Value then
    begin
      TurnSiblingsOff;
      if not FClicksDisabled then
        DoClick;
    end;

    {$IFDEF DELPHI2006_LVL}
    if HandleAllocated and HasParent then
    begin
      R := ClientRect;
      if BiDiMode = bdLeftToRight then
      begin
        R.Right := 16;
      end
      else
      begin
        R.Left := R.Right - 16;
      end;

      InvalidateRect(self.Handle, @r, true);
    end;
    {$ENDIF}

    {$IFNDEF DELPHI2006_LVL}
    Invalidate;
    {$ENDIF}
  end;
end;


procedure TCustomAdvOfficeRadioButton.DoClick;
begin
  if not (csLoading in ComponentState) then
    if Assigned(OnClick) then
      OnClick(Self);
end;

procedure TCustomAdvOfficeRadioButton.DoEnter;
{$IFNDEF DELPHI9_LVL}
var
  R: TRect;
{$ENDIF}
begin
  inherited DoEnter;
  FFocused := True;
  Checked := true;
  {$IFDEF DELPHI9_LVL}
  Repaint;
  {$ELSE}
  R := ClientRect;
  R.Right := 16;
  InvalidateRect(self.Handle, @R, true);
  {$ENDIF}
end;

procedure TCustomAdvOfficeRadioButton.DoExit;
var
  db: boolean;
begin
  inherited DoExit;
  FFocused := False;
  db := FDrawBkg;
  FDrawBkg := true;
  Repaint;
  FDrawBkg := db;
end;

procedure TCustomAdvOfficeRadioButton.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  Anchor:string;
  {$IFDEF DELPHI2006_LVL}
  R: TRect;
  {$ENDIF}
begin
  Anchor := '';
  FGotClick := true;

  if FFocused then
  begin
    Anchor := IsAnchor(X,Y);
    if Anchor <> '' then
    begin
      if (Pos('://',Anchor)>0) or (Pos('mailto:',Anchor)>0) then
        {$IFNDEF TMSDOTNET}
        ShellExecute(0,'open',PChar(Anchor),nil,nil,SW_NORMAL)
        {$ENDIF}
        {$IFDEF TMSDOTNET}
        ShellExecute(0,'open',Anchor,'','',SW_NORMAL)
        {$ENDIF}
      else
      begin
        if Assigned(FAnchorClick) then
          FAnchorClick(self,anchor);
      end;
    end;
  end
  else
  begin
    if (self.CanFocus and not (csDesigning in ComponentState)) then
    begin
      SetFocus;
      FFocused := True;
    end;
  end;

  if Anchor = '' then
  begin
    inherited MouseDown(Button, Shift, X, Y);
    MouseCapture := True;
    Down := True;
  end;

  {$IFNDEF DELPHI2006_LVL}
  Invalidate;
  {$ENDIF}
  {$IFDEF DELPHI2006_LVL}
  R := ClientRect;
  R.Right := 16;
  InvalidateRect(self.Handle, @r, true);
  {$ENDIF}
end;

procedure TCustomAdvOfficeRadioButton.MouseUp(Button: TMouseButton; Shift: TShiftState;
                                  X, Y: Integer);
{$IFDEF DELPHI2006_LVL}
var
  R: TRect;
{$ENDIF}
begin
  MouseCapture := False;
  Down := False;

  if (X >= 0) and (X <= Width) and (Y >= 0) and (Y <= Height) and not Checked and FGotClick then
  begin
    Checked := true;
  end;

  inherited MouseUp(Button, Shift, X, Y);

  if FGotClick then
    DoClick;

  {$IFNDEF DELPHI2006_LVL}
  Invalidate;
  {$ENDIF}
  {$IFDEF DELPHI2006_LVL}
  R := ClientRect;
  R.Right := 16;
  InvalidateRect(self.Handle, @r, true);
  {$ENDIF}
  FGotClick := false;
end;

procedure TCustomAdvOfficeRadioButton.MouseMove(Shift: TShiftState;X, Y: Integer);
var
  Anchor:string;
begin
  if MouseCapture then
    Down := (X>=0) and (X<=Width) and (Y>=0) and (Y<=Height);

  if FFocused then
    Anchor := IsAnchor(x,y)
  else
    Anchor := '';

  if Anchor <> '' then
  begin
    if (self.Cursor = crDefault) or (fAnchor <> Anchor) then
    begin
      FAnchor := Anchor;
      self.Cursor := crHandPoint;
      if Assigned(FAnchorEnter) then
        FAnchorEnter(self,anchor);
    end;
  end
  else
  begin
    if self.Cursor = crHandPoint then
    begin
      self.Cursor := FOldCursor;
      if Assigned(FAnchorExit) then
        FAnchorExit(self,anchor);
    end;
  end;

  inherited MouseMove(Shift,X,Y);
end;

procedure TCustomAdvOfficeRadioButton.KeyDown(var Key:Word;Shift:TShiftSTate);
begin
  if (Key = vk_return) and (FReturnIsTab) then
  begin
    Key := vk_tab;
    PostMessage(self.Handle,wm_keydown,VK_TAB,0);
  end;

  if Key = VK_SPACE then
    Down := True;

  inherited KeyDown(Key,Shift);
end;

procedure TCustomAdvOfficeRadioButton.KeyUp(var Key:Word;Shift:TShiftSTate);
begin
  if Key = VK_SPACE then
  begin
    Down := False;
    if not Checked then Checked := True;
  end;
end;

procedure TCustomAdvOfficeRadioButton.SetImages(const Value: TImageList);
begin
  FImages := Value;
  Invalidate;
end;

procedure TCustomAdvOfficeRadioButton.Notification(AComponent: TComponent;
  AOperation: TOperation);
begin
  inherited;
  if (AOperation = opRemove) and (AComponent = FImages) then
    FImages := nil;

  if (AOperation = opRemove) and (AComponent = FContainer) then
    FContainer := nil;
end;

procedure TCustomAdvOfficeRadioButton.CMEnabledChanged(var Message: TMessage);
begin
  inherited;
  Invalidate;
end;

procedure TCustomAdvOfficeRadioButton.SetButtonVertAlign(const Value: TTextLayout);
begin
  if Value <> FBtnVAlign then
  begin
    FBtnVAlign := Value;
    Invalidate;
  end;
end;

procedure TCustomAdvOfficeRadioButton.SetAlignment(const Value: TLeftRight);
begin
  if FAlignment <> Value then
  begin
    FAlignment := Value;
    Invalidate;
  end;
end;

destructor TCustomAdvOfficeRadioButton.Destroy;
begin
  {$IFNDEF TMSDOTNET}
  FBkgBmp.Free;
  {$ENDIF}
  FImageCache.Free;
  inherited;
end;

procedure TCustomAdvOfficeRadioButton.SetEllipsis(const Value: Boolean);
begin
  if FEllipsis <> Value then
  begin
    FEllipsis := Value;
    Invalidate;
  end;
end;

procedure TCustomAdvOfficeRadioButton.SetCaption(const Value: string);
begin
  inherited Caption := Value;
  FCaption := Value;
  Invalidate;
end;

procedure TCustomAdvOfficeRadioButton.Click;
begin
//  inherited;
end;

procedure TCustomAdvOfficeRadioButton.CMDialogChar(var Message: TCMDialogChar);
begin
  with Message do
    if IsAccel(CharCode, FCaption) and CanFocus then
    begin
      Checked := True;
      if TabStop then
        if (self.CanFocus and not (csDesigning in ComponentState)) then 
          SetFocus;
      Result := 1;
    end else
      inherited;
end;

procedure TCustomAdvOfficeRadioButton.SetContainer(const Value: TPictureContainer);
begin
  FContainer := Value;
  Invalidate;
end;

procedure TCustomAdvOfficeRadioButton.SetShadowColor(const Value: TColor);
begin
  if FShadowColor <> Value then
  begin
    FShadowColor := Value;
    Invalidate;
  end;
end;

procedure TCustomAdvOfficeRadioButton.SetShadowOffset(const Value: Integer);
begin
  if FShadowOffset <> Value then
  begin
    FShadowOffset := Value;
    Invalidate;
  end;
end;

procedure TCustomAdvOfficeRadioButton.SetThemed(const Value: boolean);
begin
  if (Value <> FThemed) then
  begin
    FThemed := Value;
    Invalidate;
  end;
end;

procedure TCustomAdvOfficeRadioButton.CMMouseEnter(var Message: TMessage);
begin
  FHot := True;
  DrawRadio;
  inherited;
end;

procedure TCustomAdvOfficeRadioButton.CMMouseLeave(var Message: TMessage);
begin
  FHot := False;
  DrawRadio;
  inherited;
end;


procedure TCustomAdvOfficeRadioButton.WMEraseBkGnd(var Message: TMessage);
begin
  {$IFDEF DELPHI_UNICODE}
  inherited;
  {$ENDIF}
  {$IFNDEF DELPHI_UNICODE}
  Message.Result := 1
  {$ENDIF}
end;

procedure TCustomAdvOfficeRadioButton.WMLButtonDown(var Message:TWMLButtonDown);
begin
  FClicksDisabled := True;
  if (self.CanFocus and not (csDesigning in ComponentState)) then
    SetFocus;
  FClicksDisabled := False;
  inherited;
end;

procedure TCustomAdvOfficeRadioButton.Loaded;
begin
  inherited;
  FOldCursor := Cursor;
end;

function TCustomAdvOfficeRadioButton.GetVersion: string;
var
  vn: Integer;
begin
  vn := GetVersionNr;
  Result := IntToStr(Hi(Hiword(vn)))+'.'+IntToStr(Lo(Hiword(vn)))+'.'+IntToStr(Hi(Loword(vn)))+'.'+IntToStr(Lo(Loword(vn)));
end;

function TCustomAdvOfficeRadioButton.GetVersionNr: Integer;
begin
  Result := MakeLong(MakeWord(BLD_VER,REL_VER),MakeWord(MIN_VER,MAJ_VER));
end;

procedure TCustomAdvOfficeRadioButton.SetVersion(const Value: string);
begin

end;


{ TAdvGroupButton }

type
  TAdvGroupButton = class(TAdvOfficeRadioButton)
  private
    FInClick: Boolean;
    procedure CNCommand(var Message: TWMCommand); message CN_COMMAND;
  protected
    procedure KeyDown(var Key: Word; Shift: TShiftState); override;
    procedure KeyPress(var Key: Char); override;
  public
    constructor InternalCreate(RadioGroup: TCustomAdvOfficeRadioGroup);
    destructor Destroy; override;
  end;

constructor TAdvGroupButton.InternalCreate(RadioGroup: TCustomAdvOfficeRadioGroup);
begin
  inherited Create(RadioGroup);
  RadioGroup.FButtons.Add(Self);
  Visible := False;
  Enabled := RadioGroup.Enabled;
  ParentShowHint := False;
  OnClick := RadioGroup.ButtonClick;
  Parent := RadioGroup;
end;

destructor TAdvGroupButton.Destroy;
begin
  TCustomAdvOfficeRadioGroup(Owner).FButtons.Remove(Self);
  inherited Destroy;
end;

procedure TAdvGroupButton.CNCommand(var Message: TWMCommand);
begin
  if not FInClick then
  begin
    FInClick := True;
    try
      if ((Message.NotifyCode = BN_CLICKED) or
        (Message.NotifyCode = BN_DOUBLECLICKED)) and
        TCustomAdvOfficeRadioGroup(Parent).CanModify then
        inherited;
    except
      Application.HandleException(Self);
    end;

    FInClick := False;
  end;
end;

procedure TAdvGroupButton.KeyPress(var Key: Char);
begin
  inherited KeyPress(Key);
  TCustomAdvOfficeRadioGroup(Parent).PushKey(Key);
  if (Key = #8) or (Key = ' ') then
  begin
    if not TCustomAdvOfficeRadioGroup(Parent).CanModify then Key := #0;
  end;
end;

procedure TAdvGroupButton.KeyDown(var Key: Word; Shift: TShiftState);
begin
  inherited KeyDown(Key, Shift);
  TCustomAdvOfficeRadioGroup(Parent).PushKeyDown(Key, Shift);
end;

{ TCustomAdvOfficeRadioGroup }

constructor TCustomAdvOfficeRadioGroup.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  ControlStyle := [csSetCaption];
  FButtons := TList.Create;
  FItems := TStringList.Create;
  TStringList(FItems).OnChange := ItemsChange;
  FItemIndex := -1;
  FColumns := 1;
  FAlignment := taLeftJustify;
  FBtnVAlign := tlTop;
  ShadowOffset := 1;
  ShadowColor := clSilver;
  ShowFocus := true;
  FIsReadOnly := false;
  FDisabledFontColor := DefDisabledColor;
end;

destructor TCustomAdvOfficeRadioGroup.Destroy;
begin
  SetButtonCount(0);
  TStringList(FItems).OnChange := nil;
  FItems.Free;
  FButtons.Free;
  inherited Destroy;
end;

procedure TCustomAdvOfficeRadioGroup.PushKey(var Key: Char);
begin
  KeyPress(Key);
end;

procedure TCustomAdvOfficeRadioGroup.PushKeyDown(var Key: Word; Shift: TShiftState);
begin
  KeyDown(Key,Shift);
end;


procedure TCustomAdvOfficeRadioGroup.ArrangeButtons;
var
  ButtonsPerCol, ButtonWidth, ButtonHeight, TopMargin, I: Integer;
  DC: HDC;
  SaveFont: HFont;
  Metrics: TTextMetric;
  DeferHandle: THandle;
  ALeft: Integer;
  RadioEnable: Boolean;

begin

  if (csLoading in ComponentState) then
    Exit;

  if not HandleAllocated then
    Exit;


  if (FButtons.Count <> 0) and not FReading then
  begin
    DC := GetDC(0);
    SaveFont := SelectObject(DC, Font.Handle);
    GetTextMetrics(DC, Metrics);
    SelectObject(DC, SaveFont);
    ReleaseDC(0, DC);
    ButtonsPerCol := (FButtons.Count + FColumns - 1) div FColumns;
    ButtonWidth := (Width - 10) div FColumns;
    I := Height - Metrics.tmHeight - 5;
    ButtonHeight := I div ButtonsPerCol;
    TopMargin := Metrics.tmHeight + 1 + (I mod ButtonsPerCol) div 2;

	if Length(Caption) <= 0 then
		TopMargin := TopMargin - Metrics.tmHeight div 2;

    DeferHandle := BeginDeferWindowPos(FButtons.Count);
    try
      for I := 0 to FButtons.Count - 1 do
        with TAdvGroupButton(FButtons[I]) do
        begin
          {$IFDEF DELPHI4_LVL}
          BiDiMode := Self.BiDiMode;
          {$ENDIF}

          DrawBkg := false;
          Alignment := Self.Alignment;
          ButtonVertAlign := Self.ButtonVertAlign;
          Images := Self.Images;
          PictureContainer := Self.PictureContainer;
          Ellipsis := Self.Ellipsis;
          ShadowOffset := Self.ShadowOffset;
          ShadowColor := Self.ShadowColor;
          ShowFocus := self.ShowFocus;
          DisabledFontColor := Self.DisabledFontColor;
          Themed := self.Themed;

          RadioEnable := Self.Enabled and Enabled and not FIsReadOnly;
          if Assigned(FOnIsEnabled) then
            FOnIsEnabled(Self,I,RadioEnable);

          Enabled := RadioEnable;

          ALeft := (I div ButtonsPerCol) * ButtonWidth + 8;
          {$IFDEF DELPHI4_LVL}
          if UseRightToLeftAlignment then
            ALeft := Self.ClientWidth - ALeft - ButtonWidth;
          {$ENDIF}

          DeferHandle := DeferWindowPos(DeferHandle, Handle, 0,
            ALeft,
            (I mod ButtonsPerCol) * ButtonHeight + TopMargin,
            ButtonWidth, ButtonHeight,
            SWP_NOZORDER or SWP_NOACTIVATE);

        //  Left := ALeft;
        //  Top := (I mod ButtonsPerCol) * ButtonHeight + TopMargin;
          Visible := True;

        end;
    finally
      EndDeferWindowPos(DeferHandle);
    end;
  end;
end;

procedure TCustomAdvOfficeRadioGroup.ButtonClick(Sender: TObject);
begin
  if not FUpdating then
  begin
    FItemIndex := FButtons.IndexOf(Sender);
    Changed;
    Click;
  end;
end;

procedure TCustomAdvOfficeRadioGroup.ItemsChange(Sender: TObject);
begin
  if not FReading then
  begin
    if FItemIndex >= FItems.Count then
      FItemIndex := FItems.Count - 1;
    UpdateButtons;
  end;
end;

procedure TCustomAdvOfficeRadioGroup.Loaded;
begin
  inherited Loaded;
  ArrangeButtons;
end;

procedure TCustomAdvOfficeRadioGroup.ReadState(Reader: TReader);
begin
  FReading := True;
  inherited ReadState(Reader);
  FReading := False;
  UpdateButtons;
end;

procedure TCustomAdvOfficeRadioGroup.SetButtonCount(Value: Integer);
begin
  while FButtons.Count < Value do TAdvGroupButton.InternalCreate(Self);
  while FButtons.Count > Value do TAdvGroupButton(FButtons.Last).Free;
end;

procedure TCustomAdvOfficeRadioGroup.SetColumns(Value: Integer);
begin
  if Value < 1 then Value := 1;
  if Value > 16 then Value := 16;
  if FColumns <> Value then
  begin
    FColumns := Value;
    ArrangeButtons;
    Invalidate;
  end;
end;

procedure TCustomAdvOfficeRadioGroup.SetItemIndex(Value: Integer);
begin
  if FReading then FItemIndex := Value else
  begin
    if Value < -1 then Value := -1;
    if Value >= FButtons.Count then Value := FButtons.Count - 1;
    if FItemIndex <> Value then
    begin
      if FItemIndex >= 0 then
        TAdvGroupButton(FButtons[FItemIndex]).Checked := False;
      FItemIndex := Value;
      if FItemIndex >= 0 then
        TAdvGroupButton(FButtons[FItemIndex]).Checked := True;
    end;
  end;
end;

procedure TCustomAdvOfficeRadioGroup.SetItems(Value: TStrings);
begin
  FItems.Assign(Value);
end;

procedure TCustomAdvOfficeRadioGroup.UpdateButtons;
var
  I: Integer;
begin
  SetButtonCount(FItems.Count);
  for I := 0 to FButtons.Count - 1 do
    TAdvGroupButton(FButtons[I]).Caption := FItems[I];
  if FItemIndex >= 0 then
  begin
    FUpdating := True;
    TAdvGroupButton(FButtons[FItemIndex]).Checked := True;
    FUpdating := False;
  end;
  ArrangeButtons;
  Invalidate;
end;

procedure TCustomAdvOfficeRadioGroup.CMEnabledChanged(var Message: TMessage);
var
  I: Integer;
begin
  inherited;
  for I := 0 to FButtons.Count - 1 do
    TAdvGroupButton(FButtons[I]).Enabled := Enabled;
end;

procedure TCustomAdvOfficeRadioGroup.CMFontChanged(var Message: TMessage);
begin
  inherited;
  ArrangeButtons;
end;

procedure TCustomAdvOfficeRadioGroup.WMSize(var Message: TWMSize);
begin
  inherited;
  ArrangeButtons;
end;

function TCustomAdvOfficeRadioGroup.CanModify: Boolean;
begin
  Result := True;
end;

procedure TCustomAdvOfficeRadioGroup.GetChildren(Proc: TGetChildProc; Root: TComponent);
begin
end;

procedure TCustomAdvOfficeRadioGroup.SetAlignment(const Value: TAlignment);
begin
  FAlignment := Value;
  ArrangeButtons;
end;

procedure TCustomAdvOfficeRadioGroup.SetButtonVertAlign(
  const Value: TTextLayout);
begin
  fBtnVAlign := Value;
  ArrangeButtons;
end;

procedure TCustomAdvOfficeRadioGroup.SetContainer(
  const Value: TPictureContainer);
begin
  FContainer := Value;
  ArrangeButtons;
end;

procedure TCustomAdvOfficeRadioGroup.SetImages(const Value: TImageList);
begin
  inherited Images := Value;
  FImages := Value;
  ArrangeButtons;
end;

procedure TCustomAdvOfficeRadioGroup.Notification(AComponent: TComponent;
  AOperation: TOperation);
begin
  inherited;

  if (AOperation = opRemove) and (AComponent = FImages) then
    FImages:=nil;

  if (AOperation = opRemove) and (AComponent = FContainer) then
    FContainer := nil;
end;

procedure TCustomAdvOfficeRadioGroup.SetEllipsis(const Value: Boolean);
begin
  FEllipsis := Value;
  ArrangeButtons;
end;

procedure TCustomAdvOfficeRadioGroup.SetShadowColor(const Value: TColor);
begin
  FShadowColor := Value;
  ArrangeButtons;
end;

procedure TCustomAdvOfficeRadioGroup.SetShadowOffset(const Value: Integer);
begin
  FShadowOffset := Value;
  ArrangeButtons;
end;

procedure TCustomAdvOfficeRadioGroup.SetShowFocus(const Value: Boolean);
begin
  if (FShowFocus <> Value) then
  begin
    FShowFocus := Value;
    ArrangeButtons;
  end;
end;

procedure TCustomAdvOfficeRadioGroup.SetThemed(const Value: boolean);
begin
  if (FThemed <> Value) then
  begin
    FThemed := Value;
    ArrangeButtons;
  end;
end;

function TCustomAdvOfficeRadioGroup.GetVersion: string;
var
  vn: Integer;
begin
  vn := GetVersionNr;
  Result := IntToStr(Hi(Hiword(vn)))+'.'+IntToStr(Lo(Hiword(vn)))+'.'+IntToStr(Hi(Loword(vn)))+'.'+IntToStr(Lo(Loword(vn)));
end;

function TCustomAdvOfficeRadioGroup.GetVersionNr: Integer;
begin
  Result := MakeLong(MakeWord(BLD_VER,REL_VER),MakeWord(MIN_VER,MAJ_VER));
end;

procedure TCustomAdvOfficeRadioGroup.SetVersion(const Value: string);
begin

end;


{ TGroupCheck }

type
  TGroupCheck = class(TAdvOfficeCheckBox)
  private
    FInClick: Boolean;
    procedure CNCommand(var Message: TWMCommand); message CN_COMMAND;
  protected
    procedure KeyDown(var Key: Word; Shift: TShiftState); override;
    procedure KeyPress(var Key: Char); override;
  public
    constructor InternalCreate(CheckGroup: TCustomAdvOfficeCheckGroup);
    destructor Destroy; override;
  end;

constructor TGroupCheck.InternalCreate(CheckGroup: TCustomAdvOfficeCheckGroup);
begin
  inherited Create(CheckGroup);
  CheckGroup.FButtons.Add(Self);
  Visible := False;
  Enabled := CheckGroup.Enabled;
  ParentShowHint := False;
  OnClick := CheckGroup.ButtonClick;
  OnEnter := CheckGroup.CheckFocus;
  Parent := CheckGroup;
end;

destructor TGroupCheck.Destroy;
begin
  TCustomAdvOfficeCheckGroup(Owner).FButtons.Remove(Self);
  inherited Destroy;
end;

procedure TGroupCheck.CNCommand(var Message: TWMCommand);
begin
  if not FInClick then
  begin
    FInClick := True;
    try
      if ((Message.NotifyCode = BN_CLICKED) or
        (Message.NotifyCode = BN_DOUBLECLICKED)) and
        TCustomAdvOfficeCheckGroup(Parent).CanModify then
        inherited;
    except
      Application.HandleException(Self);
    end;
    FInClick := False;
  end;
end;

procedure TGroupCheck.KeyPress(var Key: Char);
begin
  inherited KeyPress(Key);
  TCustomAdvOfficeCheckGroup(Parent).PushKey(Key);
  if (Key = #8) or (Key = ' ') then
  begin
    if not TCustomAdvOfficeCheckGroup(Parent).CanModify then Key := #0;
  end;
end;

procedure TGroupCheck.KeyDown(var Key: Word; Shift: TShiftState);
begin
  inherited KeyDown(Key, Shift);
  TCustomAdvOfficeCheckGroup(Parent).PushKeyDown(Key, Shift);
end;


{ TCustomAdvOfficeCheckGroup }

constructor TCustomAdvOfficeCheckGroup.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  ControlStyle := [csSetCaption, csDoubleClicks];
  FButtons := TList.Create;
  FItems := TStringList.Create;
  TStringList(FItems).OnChange := ItemsChange;
  FColumns := 1;
  FAlignment := taLeftJustify;
  FBtnVAlign := tlTop;
  ShadowOffset := 1;
  ShadowColor := clSilver;
  ShowFocus := true;
  FDisabledFontColor := DefDisabledColor;  
  FValue := 0;
end;

destructor TCustomAdvOfficeCheckGroup.Destroy;
begin
  SetButtonCount(0);
  TStringList(FItems).OnChange := nil;
  FItems.Free;
  FButtons.Free;
  inherited Destroy;
end;

procedure TCustomAdvOfficeCheckGroup.PushKey(var Key: Char);
begin
  KeyPress(Key);
end;

procedure TCustomAdvOfficeCheckGroup.PushKeyDown(var Key: Word; Shift: TShiftState);
begin
  KeyDown(Key,Shift);
end;


procedure TCustomAdvOfficeCheckGroup.ArrangeButtons;
var
  ButtonsPerCol, ButtonWidth, ButtonHeight, TopMargin, I: Integer;
  DC: HDC;
  SaveFont: HFont;
  Metrics: TTextMetric;
  DeferHandle: THandle;
  ALeft: Integer;
  RadioEnable: Boolean;

begin
  if (FButtons.Count <> 0) and not FReading then
  begin
    DC := GetDC(0);
    SaveFont := SelectObject(DC, Font.Handle);
    GetTextMetrics(DC, Metrics);
    SelectObject(DC, SaveFont);
    ReleaseDC(0, DC);
    ButtonsPerCol := (FButtons.Count + FColumns - 1) div FColumns;
    ButtonWidth := (Width - 10) div FColumns;
    I := Height - Metrics.tmHeight - 5;
    ButtonHeight := I div ButtonsPerCol;
    TopMargin := Metrics.tmHeight + 1 + (I mod ButtonsPerCol) div 2;

	if Length(Caption) <= 0 then
		TopMargin := TopMargin - Metrics.tmHeight div 2;

    DeferHandle := BeginDeferWindowPos(FButtons.Count);
    try
      for I := 0 to FButtons.Count - 1 do
        with TGroupCheck(FButtons[I]) do
        begin
          {$IFDEF DELPHI4_LVL}
          BiDiMode := Self.BiDiMode;
          {$ENDIF}

          DrawBkg := false;
          Alignment := self.Alignment;
          ButtonVertAlign := self.ButtonVertAlign;
          Images := self.Images;
          PictureContainer := self.PictureContainer;
          Ellipsis := self.Ellipsis;
          ShadowOffset := self.ShadowOffset;
          ShadowColor := self.ShadowColor;
          ShowFocus := self.ShowFocus;
          DisabledFontColor := Self.DisabledFontColor;
          Themed := Self.Themed;

          RadioEnable := self.Enabled;
          if Assigned(FOnIsEnabled) then
            FOnIsEnabled(Self,I,RadioEnable);

          Enabled := RadioEnable;

          ALeft := (I div ButtonsPerCol) * ButtonWidth + 8;
          {$IFDEF DELPHI4_LVL}
          if UseRightToLeftAlignment then
            ALeft := Self.ClientWidth - ALeft - ButtonWidth;
          {$ENDIF}
          DeferHandle := DeferWindowPos(DeferHandle, Handle, 0,
            ALeft,
            (I mod ButtonsPerCol) * ButtonHeight + TopMargin,
            ButtonWidth, ButtonHeight,
            SWP_NOZORDER or SWP_NOACTIVATE);
          Visible := True;

        end;
    finally
      EndDeferWindowPos(DeferHandle);
    end;
  end;
end;

procedure TCustomAdvOfficeCheckGroup.CheckFocus(Sender: TObject);
var
  i: integer;
begin
  for i := 0 to FButtons.Count - 1 do
  begin
    if TGroupCheck(FButtons[i]).Focused then
      FFocusButtonIdx := i;
  end;
end;


procedure TCustomAdvOfficeCheckGroup.ButtonClick(Sender: TObject);
begin
  if not FUpdating then
  begin
    Changed;
    Click;
  end;
  UpdateValue;
end;

procedure TCustomAdvOfficeCheckGroup.ItemsChange(Sender: TObject);
begin
  if not FReading then
  begin
    UpdateButtons;
  end;
end;

procedure TCustomAdvOfficeCheckGroup.DoExit;
begin
  inherited;
end;

procedure TCustomAdvOfficeCheckGroup.DoEnter;
var
  i: integer;
  found: boolean;
begin
  inherited;

  if FButtons.Count >  FFocusButtonIdx then
  begin
    if TGroupCheck(FButtons[FFocusButtonIdx]).HandleAllocated then
    begin
      if ReadOnly[FFocusButtonIdx] then
      begin
        found := false;
        for i := 0 to Items.Count - 1 do
        begin
          if not ReadOnly[i] then
          begin
            FFocusButtonIdx := i;
            found := true;
            break;
          end;
        end;
        if not found then
          Exit;
      end;

      TGroupCheck(FButtons[FFocusButtonIdx]).SetFocus;
      Invalidate;
    end;
  end;
end;


procedure TCustomAdvOfficeCheckGroup.Loaded;
begin
  inherited Loaded;
  ArrangeButtons;
  Value := Value;
end;

procedure TCustomAdvOfficeCheckGroup.ReadState(Reader: TReader);
begin
  FReading := True;
  inherited ReadState(Reader);
  FReading := False;
  UpdateButtons;
end;

procedure TCustomAdvOfficeCheckGroup.SetButtonCount(Value: Integer);
begin
  while FButtons.Count < Value do
    TGroupCheck.InternalCreate(Self);
  while FButtons.Count > Value do
    TGroupCheck(FButtons.Last).Free;
end;

procedure TCustomAdvOfficeCheckGroup.SetColumns(Value: Integer);
begin
  if Value < 1 then Value := 1;
  if Value > 16 then Value := 16;
  if FColumns <> Value then
  begin
    FColumns := Value;
    ArrangeButtons;
    Invalidate;
  end;
end;

procedure TCustomAdvOfficeCheckGroup.SetItems(Value: TStrings);
begin
  FItems.Assign(Value);
end;

procedure TCustomAdvOfficeCheckGroup.UpdateButtons;
var
  I: Integer;
begin
  SetButtonCount(FItems.Count);
  for I := 0 to FButtons.Count - 1 do
    TGroupCheck(FButtons[I]).Caption := FItems[I];

  ArrangeButtons;
  Invalidate;
end;

procedure TCustomAdvOfficeCheckGroup.CMEnabledChanged(var Message: TMessage);
var
  I: Integer;
begin
  inherited;
  for I := 0 to FButtons.Count - 1 do
    TGroupCheck(FButtons[I]).Enabled := Enabled;
end;

procedure TCustomAdvOfficeCheckGroup.CMFontChanged(var Message: TMessage);
begin
  inherited;
  ArrangeButtons;
end;

procedure TCustomAdvOfficeCheckGroup.WMSize(var Message: TWMSize);
begin
  inherited;
  ArrangeButtons;
end;

function TCustomAdvOfficeCheckGroup.CanModify: Boolean;
begin
  Result := True;
end;

procedure TCustomAdvOfficeCheckGroup.GetChildren(Proc: TGetChildProc; Root: TComponent);
begin
end;

procedure TCustomAdvOfficeCheckGroup.SetAlignment(const Value: TAlignment);
begin
  FAlignment := Value;
  ArrangeButtons;
end;

procedure TCustomAdvOfficeCheckGroup.SetButtonVertAlign(
  const Value: TTextLayout);
begin
  fBtnVAlign := Value;
  ArrangeButtons;
end;

procedure TCustomAdvOfficeCheckGroup.SetContainer(
  const Value: TPictureContainer);
begin
  FContainer := Value;
  ArrangeButtons;
end;

procedure TCustomAdvOfficeCheckGroup.SetImages(const Value: TImageList);
begin
  inherited Images := Value;
  FImages := Value;
  ArrangeButtons;
end;

procedure TCustomAdvOfficeCheckGroup.Notification(AComponent: TComponent;
  AOperation: TOperation);
begin
  inherited;

  if (AOperation = opRemove) and (AComponent = FImages) then
    FImages := nil;

  if (AOperation = opRemove) and (AComponent = FContainer) then
    FContainer := nil;
end;

procedure TCustomAdvOfficeCheckGroup.SetEllipsis(const Value: Boolean);
begin
  if (FEllipsis <> Value) then
  begin
    FEllipsis := Value;
    ArrangeButtons;
  end;
end;

procedure TCustomAdvOfficeCheckGroup.SetShadowColor(const Value: TColor);
begin
  if (FShadowColor <> Value) then
  begin
    FShadowColor := Value;
    ArrangeButtons;
  end;
end;

procedure TCustomAdvOfficeCheckGroup.SetShadowOffset(const Value: Integer);
begin
  if (FShadowOffset <> Value) then
  begin
    FShadowOffset := Value;
    ArrangeButtons;
  end;
end;


procedure TCustomAdvOfficeCheckGroup.SetShowFocus(const Value: boolean);
begin
  if (FShowFocus <> Value) then
  begin
    FShowFocus := Value;
    ArrangeButtons;
  end;
end;

procedure TCustomAdvOfficeCheckGroup.SetThemed(const Value: boolean);
begin
  if (FThemed <> Value) then
  begin
    FThemed := Value;
    ArrangeButtons;
  end;
end;

function TCustomAdvOfficeCheckGroup.GetChecked(Index: Integer): Boolean;
begin
  if (Index < FButtons.Count)  and (Index >= 0) then
    Result := TGroupCheck(FButtons[Index]).Checked
  else
    raise Exception.Create('Invalid checkbox index');
end;

procedure TCustomAdvOfficeCheckGroup.SetChecked(Index: Integer;
  const Value: Boolean);
begin
  if (Index < FButtons.Count)  and (Index >= 0) then
  begin
    TGroupCheck(FButtons[Index]).Checked := Value;
  end;
end;

function TCustomAdvOfficeCheckGroup.GetReadOnly(Index: Integer): Boolean;
begin
  if (Index < FButtons.Count)  and (Index >= 0) then
    Result := not TGroupCheck(FButtons[Index]).Enabled
  else
    raise Exception.Create('Invalid checkbox index');
end;

procedure TCustomAdvOfficeCheckGroup.SetReadOnly(Index: Integer;
  const Value: Boolean);
begin
  if (Index < FButtons.Count)  and (Index >= 0) then
    TGroupCheck(FButtons[Index]).Enabled := not Value;
end;

procedure TCustomAdvOfficeCheckGroup.UpdateValue;
var
  i, j: Integer;
  BitMask: DWord;
begin
  FValue := Value;
  j := Min(FButtons.Count, sizeof(DWord) * 8);
  BitMask := 1;
  FValue := 0;
  for i := 0 to j - 1 do
  begin
    if TGroupCheck(FButtons[i]).Checked then
    begin
      FValue := FValue or BitMask;
    end;
    BitMask := BitMask * 2;
  end;
end;

function TCustomAdvOfficeCheckGroup.GetValue: DWord;
begin
  Result := FValue;
end;

procedure TCustomAdvOfficeCheckGroup.SetValue(const Value: DWord);
var
  i, j: Integer;
  BitMask: Integer;
begin
  //if (FValue <> Value) then
  begin
    FValue := Value;
    j := Min(FButtons.Count, sizeof(DWord) * 8);
    BitMask := 1;
    for i := 0 to j - 1 do
    begin
      TGroupCheck(FButtons[i]).Checked := ((FValue And BitMask) > 0);
      BitMask := BitMask * 2;
    end;
  end;
end;

function TCustomAdvOfficeCheckGroup.GetVersion: string;
var
  vn: Integer;
begin
  vn := GetVersionNr;
  Result := IntToStr(Hi(Hiword(vn)))+'.'+IntToStr(Lo(Hiword(vn)))+'.'+IntToStr(Hi(Loword(vn)))+'.'+IntToStr(Lo(Loword(vn)));
end;

function TCustomAdvOfficeCheckGroup.GetVersionNr: Integer;
begin
  Result := MakeLong(MakeWord(BLD_VER,REL_VER),MakeWord(MIN_VER,MAJ_VER));
end;

procedure TCustomAdvOfficeCheckGroup.SetVersion(const Value: string);
begin

end;



{$IFDEF DELPHI6_LVL}
procedure TAdvOfficeCheckBoxActionLink.AssignClient(AClient: TObject);
begin
  inherited AssignClient(AClient);
  FClient := AClient as TCustomAdvOfficeCheckBox;
end;

procedure TAdvOfficeCheckBoxActionLink.SetChecked(Value: Boolean);
begin
  FClient.Checked := Value;
end;

procedure TAdvOfficeCheckBoxActionLink.SetCaption(const Value: string);
begin
  FClient.Caption := Value;
end;

function TAdvOfficeCheckBoxActionLink.IsCaptionLinked: Boolean;
begin
  Result := inherited IsCaptionLinked;
end;

function TAdvOfficeCheckBoxActionLink.IsCheckedLinked: Boolean;
begin
  Result := inherited IsCheckedLinked;
end;

{$ENDIF}


{$IFDEF FREEWARE}
{$I TRIAL.INC}
{$ENDIF}


end.
