{$I TMSDEFS.INC}
{***********************************************************************}
{ TPlanner component                                                    }
{ for Delphi & C++Builder                                               }
{                                                                       }
{ written by TMS Software                                               }
{            copyright © 1999-2010                                      }
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


unit Planner;

{$HPPEMIT ''}
{$HPPEMIT '#include "winuser.h"'}
{$HPPEMIT ''}

{$H+}
{$J+}
{$Y+}
{$T-}

{$IFDEF VER90}
{$DEFINE DELPHI2COLLECTION}
{$ENDIF}

{$IFDEF VER100}
{$DEFINE DELPHI2COLLECTION}
{$ENDIF}

{$DEFINE REMOVESTRIP}
{$DEFINE REMOVEDRAW}
{$DEFINE HILIGHT}

{$DEFINE TMSSKINS}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls,  Dialogs,
  StdCtrls, ExtCtrls, Grids, Buttons, ComCtrls, Menus, Mask,
  Printers, PlanUtil, PlanObj, PlanCheck, PlanCombo, Forms,
  PictureContainer, AdvStyleIF, ShellApi, CommCtrl, ComObj
{$IFNDEF TMSDOTNET}
  , PlanXPVS
{$IFNDEF DELPHI_UNICODE}
  , PlanUni
{$ENDIF}
{$ENDIF}
{$IFDEF TMSDOTNET}
  , uxTheme, FlatSB, WinUtils, Types, System.Text
{$ENDIF}
{$IFDEF DELPHI6_LVL}
  , Variants
{$ENDIF}
  ;

const
{$IFDEF VER90}
  crSizeAll = crCross;
{$ENDIF}

  MAJ_VER = 2; // Major version nr.
  MIN_VER = 5; // Minor version nr.
  REL_VER = 12; // Release nr.
  BLD_VER = 1; // Build nr.
  DATE_VER = 'Aug, 2010'; // Month version

  // version history
  // 2.2.1.0 : New PlannerHeader.ResizeAll property added
  //         : New Balloon hints for header items
  //         : New PlannerHeader.ShowHint property added
  // 2.2.1.1 : Fixed GetCellTime() procedure for TimeLine mode
  // 2.2.1.2 : Improved Balloon handling
  //         : Improved plCustomList time handling
  // 2.2.1.3 : Fixed rotated header drawing with sidebar on top
  // 2.2.1.4 : Improved painting speed for non visible item indication
  // 2.2.1.5 : Fixed issue with footer text drawing & vertical alignment
  // 2.2.1.6 : Improved recurrency handling
  // 2.2.1.7 : Improvement in use of OnItemSizing event with Allow = false

  // 2.5.0.0 : See separate release notes

  // 2.5.0.1 : Fixed issue with setting end time equal to timeslot end time
  // 2.5.0.2 : Fixed issue with painting in multimonth mode in Delphi 2006
  // 2.5.0.3 : HourLineColor issue with DisplayStart
  //         : Fixed issue with customgroups and scrolling
  // 2.5.0.5 : Fixed issue with BYMONTH recurrency
  //         : TPlannerMonthView compatibility fixes
  // 2.5.0.6 : Improved header & header group painting
  //         : Improved position zoom handling with PositionAutoSize = true
  //         : Fixed issue with completion calculation with header items
  // 2.5.0.7 : Fixed issue with PositionProps and active completion indication
  // 2.5.0.8 : Fixed issue with timelines with non visible display start & end
  // 2.5.0.9 : Fixed issue with DirectMove
  // 2.5.0.10: Fixed issue with footer text drawing
  // 2.5.0.11: Fixed issue with HTML export colors for horizonal oriented planners
  // 2.5.0.12: Fixed issue with yearly recurrency handling
  // 2.5.0.13: Fixed issue in TDBPlanner
  // 2.5.0.14: Fixed issue in TDBPlanner
  // 2.5.0.15: Fixed issue with items after midnight in multiday scenarios
  // 2.5.0.16: Fixed issue with multimonth mode & multiyear items
  // 2.5.0.17: Fixed issue with PlannerHeader.Assign
  //         : Fixed issue with position resize during header resize
  // 2.5.1.0 : New : Office2007 Silver style added
  // 2.5.1.1 : Fixed issue with sidebar printing in timeline mode
  // 2.5.1.2 : Improved : printing of timeline mode
  // 2.5.1.3 : Improved : printing with use of OnPlannerBottomLine event
  // 2.5.1.4 : Fixed : issue with CtrlDragCopy & TDBPlanner
  //         : Fixed : issue with displaying events < DisplayStart & > DisplayEnd
  // 2.5.1.5 : Fixed : sidebar display issue in period mode for horiz. time axis
  // 2.5.1.6 : Improved : painting of planner items with multiple images
  // 2.5.2.0 : New : property NotesMaxLength added
  // 2.5.3.0 : New : event OnSideBarHint added
  // 2.5.3.1 : Improved : header printing for horiz. Planner
  // 2.5.3.2 : Fixed : issue with multipage printing
  // 2.5.3.3 : Fixed : issue with apNextToTime & rightaligned sidebar
  //         : Fixed : issue with scrolling & position resizing
  // 2.5.3.4 : Fixed : issue with ShowCurrentItem := true
  // 2.5.3.5 : Fixed : issue with OnItemImageClick event for items in header
  // 2.5.3.6 : Fixed : issue with recurrency editor
  //         : Fixed : issue with InHeader item painting
  //         : Fixed : issue with cursor with PositionZoomWidth > 0
  // 2.5.3.7 : Fixed : issue with item hint for items in Planner Header
  // 2.5.3.8 : Fixed : issue with header activecolor for vertically scroll grid
  // 2.5.4.0 : New : exposed OnTimer as public event
  //         : Fixed : issue with child item moving/sizing
  // 2.5.4.1 : Fixed : issue with proportional trackbar drawing
  //         : Fixed : issue with active display in sidebar with FullHalfday mode
  // 2.5.4.2 : Fixed : issue with hyperlink in Notes & items without captions
  // 2.5.4.3 : Fixed : issue with printing of transparent background items
  //         : Fixed : issue with HandPoint mouse cursor for header item links
  // 2.5.4.4 : Fixed : issue with PrintOptions.HeaderSize in horizontal printing
  // 2.5.5.0 : Improved : support for printing custom groups added
  // 2.5.5.1 : Fixed : issue with printing multiple pages
  // 2.5.5.2 : Fixed : issue with drag cursor on resizable header
  // 2.5.5.3 : Improved : sidebar drawing in day mode with small display scales
  // 2.5.5.4 : Fixed : painting issue with D2007 for GridControl.DoubleBuffered := true
  //         : Fixed : issue with tab key handling on pagecontrol
  // 2.5.5.5 : Fixed : issue with painting on not rotated top sidebar
  // 2.5.5.6 : Fixed : issue with setting ItemEndTime with uninitialized ItemRealStartTime
  // 2.5.5.7 : Fixed : issue with rotated header painting
  // 2.5.6.0 : Improved : added capability to show multiline text in left rotated header text
  // 2.5.6.1 : Fixed : issue with DisplayText > 1 and showing current time indicator in sidebar
  // 2.5.6.2 : Fixed : header alignment with rotated text
  // 2.5.6.3 : Fixed : issue with completion display for spRight sidebar
  //         : Fixed : issue with item times when setting Planner.Display.DisplayText
  // 2.5.6.4 : Fixed : issue with rotated header drawing for top sidebar Planner
  // 2.5.6.5 : Improved : Assign method
  // 2.5.6.6 : Fixed : issues with specific yearly recurrence types
  // 2.5.6.7 : Fixed : issue with hint hiding after cancelled item move/size
  // 2.5.6.8 : Fixed : issue with SelectionToAbsTime for mode plDay with full day selection
  // 2.5.6.9 : Improved : printing with sidebar right, leftright
  // 2.5.6.10: Fixed : issue with auto delete of recurrent items
  // 2.5.6.11: Fixed : issue with footer font
  //         : Fixed : issue with footer printing
  // 2.5.6.12: Fixed : issue with Planner.SideBar.Visible = false for top position sidebar
  // 2.5.6.13: Fixed : issue with DBDisjunctDaySource when Dates collection is empty
  // 2.5.6.14: Fixed : issue with Item.Reorganize and StartOffset/EndOffset
  //         : Fixed : issue with ShowCurrentTime
  // 2.5.6.15: Improved : Planner header printing
  // 2.5.6.16: Fixed : issue with SideBar.AMPMPos for horiz. time axis
  // 2.5.6.17: Improved : event OnItemCreated is called from item duplication with CtrlDragCopy
  // 2.5.6.18: Fixed : issue with DBPlanner & ScaleToFit option
  // 2.5.6.19: Fixed : issue with setting Planner Cursor from OnMouseMove event
  // 2.5.6.20: Fixed : issue with custom background colors & ShowSelection = false
  // 2.5.6.21: Improved : active cell repainting
  //         : Fixed : header printing for SideBar position set to spRight
  // 2.5.6.22: Fixed : OnPrintFooter for horiz. planner printing not called
  // 2.5.6.23: Fixed : Issue with group image drawing in header
  // 2.5.6.24: Fixed : Issue with DBTimeLineSource and Planner.Mode.TimeLineNVUBegin,Planner.Mode.TimeLineNVUEnd
  // 2.5.6.25 :New : public property Planner.CaptionControl exposed
  //          :New : Planner.HeaderControl.OnMouseXXX events exposed
  // 2.5.6.26 :Improved : Header background color printed
  // 2.5.6.27 :Fixed : issue with ActiveDaySource and events in last timeslot of day
  // 2.5.6.28 :Fixed : issue with completion display in horizontal mode
  // 2.5.6.29 :Improved : performance improvement with active selection indication in sidebar
  // 2.5.7.0  :New : property AutoCreateOnSelect added
  //          :New : property WheelAction added to scroll only with the mousewheel
  //          :Fixed : issue with AllowOverlap = false in specific circumstances
  // 2.5.7.1  :Fixed : issue in TDBPlanner
  // 2.5.7.2  :Fixed : specific issue with printing header/groupheaders
  // 2.5.7.3  :Improved : Auto position sizing in combination with position zooming behaviour
  // 2.5.8.0  :New : PrintOptions.LineWidth property added
  // 2.5.8.1  :Fixed : Issue with rich text inplace editor and rich text hints/balloons
  //          :Fixed : Issue with PlannerItem end time display in plMultiMonth mode
  // 2.5.8.2  :Fixed : Issue with InHeader items and layers
  //          :Fixed : Issue with HTML hints
  // 2.5.8.3  :Fixed : Issue in TDBPlanner
  // 2.5.8.4  :Fixed : Use of Planner.Sidebar.SeparatorLineColor for plHalfDayPeriod mode
  // 2.5.8.5  :Fixed : Inactive day marking in plWeek mode
  // 2.5.8.6  :Fixed : Custom header group printing
  // 2.5.8.7  :Fixed : Issue with header painting in vertical planner
  //          :Fixed : Issue with hints in timeline mode when resizing items
  // 2.5.8.8  :Fixed : Issue with sidebar hour printing in horizontal mode
  // 2.5.8.9  :Fixed : Issue with header drag & drop and scrolled Planner
  // 2.5.8.10 :Fixed : issue with full linked item moving across day boundaries
  // 2.5.9.0  :New : Unicode parameter added in method SaveToHTML() to export as unicode HTML file
  //          :Fixed : Issue with sizing item in horizontal mode under specific circumstances
  // 2.5.10.0 :New : Property Planner.Header.RotateGroupOnLeft added
  //          :New : Property Planner.Header.AutoSizeGroupCaption added
  // 2.5.10.1 :Fixed : Issue with new header group height capabilities
  // 2.5.11.0 :Improved : HTML export with position groups
  // 2.5.11.0 :Improved : HTML export with PositionProps use
  // 2.5.11.1 :Fixed : Issue with using PlannerItem.ItemEndTime, ItemStartTime with DisplayOffset > 0
  // 2.5.12.0 :New : Support for timeindicator in sidebar in plTimeLine mode added
  // 2.5.12.1 :Fixed : Conflict calculation issue when DisplayStart > 0 and items are outside Planner timeaxis range

  s_QuickConfig = 'Quick config';
  s_HTimeAxis = 'Horizontal time axis';
  s_VTimeAxis = 'Vertical time axis';
  s_ShowDesignItem = 'Show design item';
  s_HideDesignItem = 'Hide design item';

  s_Modes : array[0..5] of string = ('Select day mode','Select month mode','Select day period mode',
    'Select half day period mode','Select multimonth mode','Select timeline mode');


  {$IFNDEF DELPHI6_LVL}
  WS_EX_LAYERED  = $00080000;
  {$EXTERNALSYM WS_EX_LAYERED}
  ULW_ALPHA      = $00000002;
  {$EXTERNALSYM ULW_ALPHA}
  {$ENDIF}


  TTI_NONE = 0;
  {$EXTERNALSYM TTI_NONE}
  TTI_ERROR = 3;
  {$EXTERNALSYM TTI_ERROR}
  TTI_INFO = 1;
  {$EXTERNALSYM TTI_INFO}
  TTI_WARNING = 2;
  {$EXTERNALSYM TTI_WARNING}
  TTI_EMPTY = 4;
  {$EXTERNALSYM TTI_EMPTY}
  TTS_BALLOON  = $40;
  {$EXTERNALSYM TTS_BALLOON}

  {$IFDEF DELPHI_UNICODE}
  TTM_SETTITLE = (WM_USER + 33);
  {$ENDIF}
  {$IFNDEF DELPHI_UNICODE}
  TTM_SETTITLE = (WM_USER + 32);
  {$ENDIF}

  {$EXTERNALSYM TTM_SETTITLE}


var
  CF_PLANNERITEM: Word;


const
  crZoomIn = 100;
  crZoomOut = 101;

  EDITOFFSET = 4;

  NumColors = 288;

  MININDAY = 1440;

  // Values only applicable for Delphi 4, C++Builder 4
  MAX_COLS = 192;  // previous value 512 caused problems to run on ActiveForm
  MAX_ROWS = 288;  // previous value 512 caused problems to run on ActiveForm

  CORNER_EFFECT = 10;

{$IFDEF FREEWARE}
  COPYRIGHT = 'Printed by %s © 1998 - 2010 by TMS software';
{$ENDIF}


type
  {$IFDEF DELPHI_UNICODE}
  THintInfo = Controls.THintInfo;
  PHintInfo = Controls.PHintInfo;
  {$ENDIF}

  TCustomPlanner = class;

  TPlannerGrid = class;
  TPlannerItem = class;

  TPlannerBarItem = class;
  TPlannerBarItemList = class;
  TPlannerIntList = class;

  EPlannerError = class(Exception);

  XPColorScheme = (xpNone, xpBlue, xpGreen, xpGray, xpNoTheme);

  TItemEvent = procedure(Sender: TObject; Item: TPlannerItem) of object;

  TPlannerAnchorEvent = procedure(Sender: TObject; X,Y: Integer;
    Anchor:string) of object;

  TItemControlEvent = procedure(Sender: TObject; X,Y: Integer;
    Item: TPlannerItem; ControlID, ControlType, ControlValue:string) of object;

  TItemComboControlEvent = procedure(Sender: TObject; X,Y: Integer;
    Item: TPlannerItem; ControlID, ControlValue:string; ComboIdx: Integer;ComboObject: TObject) of object;

  TItemControlListEvent = procedure(Sender: TObject; Item: TPlannerItem;
    ControlID, ControlValue:string; var Edit:Boolean; Values: TStringList; var Dropheight: Integer) of object;

  TItemAnchorEvent = procedure(Sender: TObject; Item: TPlannerItem;
    Anchor: string) of object;

  TItemImageEvent = procedure(Sender: TObject; Item: TPlannerItem;
    ImageIndex: Integer) of object;

  TItemHintEvent = procedure(Sender: TObject; Item: TPlannerItem;
    var Hint: string) of object;

  TItemLinkEvent = procedure(Sender: TObject; Item: TPlannerItem;
    Link: string; var AutoHandle: Boolean) of object;

  TItemMoveEvent = procedure(Sender: TObject; Item: TPlannerItem;
    FromBegin, FromEnd, FromPos, ToBegin, ToEnd, ToPos: Integer) of object;

  TItemMovingEvent = procedure(Sender: TObject; Item: TPlannerItem;
    DeltaBegin, DeltaPos: Integer; var Allow: Boolean) of object;

  TItemUpdateEvent = procedure(Sender: TObject; Item: TPlannerItem;
    var NewBegin, NewEnd, NewPos: Integer) of object;

  TItemSizingEvent = procedure(Sender: TObject; Item: TPlannerItem;
    DeltaBegin, DeltaEnd: Integer; var Allow: Boolean) of object;

  TItemDragEvent = procedure(Sender: TObject; Item: TPlannerItem;
    var Allow: Boolean) of object;

  TItemBalloonEvent = procedure(Sender: TObject; APlannerItem: TPlannerItem; var ATitle: string; var AText: string; var AIcon: Integer) of object;

  TPlannerBalloonEvent = procedure(Sender: TObject; X,Y: Integer; var ATitle: string; var AText: string; var AIcon: Integer) of object;

  TItemClipboardAction = (itCut,itCopy,itPaste);

  TItemClipboardEvent = procedure(Sender: TObject; Item: TPlannerItem;
    Action: TItemClipboardAction; var Text: string) of object;

  TItemSizeEvent = procedure(Sender: TObject; Item: TPlannerItem;
    Position, FromBegin, FromEnd, ToBegin, ToEnd: Integer) of object;

  TItemPopupPrepareEvent = procedure(Sender: TObject; PopupMenu:TPopupMenu;
    Item: TPlannerItem) of object;

  TPlannerEvent = procedure(Sender: TObject;
    Position, FromSel, FromSelPrecise, ToSel, ToSelPrecise: Integer) of object;

  TPlannerKeyEvent = procedure(Sender: TObject; var Key: Char;
    Position, FromSel, FromSelPrecis, ToSel, ToSelPrecis: Integer) of object;

  TPlannerKeyDownEvent = procedure(Sender: TObject; var Key: Word; Shift: TShiftState;
    Position, FromSel, FromSelPrecis, ToSel, ToSelPrecis: Integer) of object;

  TPlannerItemDraw = procedure(Sender: TObject; PlannerItem: TPlannerItem;
    Canvas: TCanvas; Rect: TRect; Selected: Boolean) of object;

  TPlannerItemText = procedure(Sender: TObject; PlannerItem: TPlannerItem; var Text: string) of object;

  TPlannerSideDraw = procedure(Sender: TObject; Canvas: TCanvas; Rect: TRect;
    Index: Integer) of object;

  TPlannerSideProp = procedure(Sender: TObject; Index: Integer; ABrush: TBrush; AFont: TFont;
    var ColorTo: TColor) of object;

  TPlannerBkgDraw = procedure(Sender: TObject; Canvas: TCanvas; Rect: TRect;
    Index, Position: Integer) of object;

  TPlannerHeaderDraw = procedure(Sender: TObject; Canvas: TCanvas;
    Rect: TRect; Index: Integer; var DoDraw: Boolean) of object;

  TPlannerHeaderProp = procedure(Sender: TObject; ABrush: TBrush; var ColorTo: TColor; AFont: TFont; var AAlignment: TAlignment) of object;

  THeaderHeightChangeEvent = procedure(Sender: TObject; NewSize: integer) of object;

  TPlannerCaptionDraw = procedure(Sender: TObject; Canvas: TCanvas;
    Rect: TRect; var DoDraw: Boolean) of object;

  TPlannerPlanTimeToStrings = procedure (Sender: TObject; MinutesValue: Cardinal;
    var HoursString, MinutesString, AmPmString: string) of object;

  TPlannerGetSideBarLines = procedure (Sender: TObject;
    Index, Position: Integer; var HourString, MinuteString, AmPmString: string) of object;

  TPlannerPrintEvent = procedure(Sender: TObject; Canvas: TCanvas) of object;

  TPlannerSelectCellEvent = procedure(Sender: TObject; Index, Pos: Integer;
    var CanSelect: Boolean) of object;

  TPlannerBottomLineEvent = procedure(Sender: TObject; Index, Pos: Integer;
    APen: TPen) of object;

  TGetCurrentTimeEvent = procedure(Sender: TObject;
    var CurrentTime: TDateTime) of object;

  TPlannerBtnEvent = procedure(Sender: TObject) of object;

  TSideBarPosition = (spLeft, spRight, spTop, spLeftRight);
  TSideBarOrientation = (soHorizontal, soVertical);

  TCustomEditEvent = procedure(Sender: TObject; R: TRect;
    Item: TPlannerItem) of object;

  TPlannerPositionToDay = procedure(Sender: TObject; Pos: Integer;
    var Day: TDateTime) of object;

  TPlannerPositionZoom = procedure(Sender: TObject; Pos: Integer; ZoomIn: Boolean) of object;

  TPlannerBeforePositionZoom = procedure(Sender: TObject; Pos: Integer; ZoomIn: Boolean; var Allow: Boolean) of object;

  TPlannerActiveEvent = procedure(Sender: TObject; Index, Position: Integer; var Active: Boolean) of object;

  TPlannerPrintHFEvent = procedure(Sender: TObject; ACanvas: TCanvas; DrawRect: TRect) of object;

  TPlannerHeaderSizeEvent = procedure(Sender: TObject; APosition, AWidth: Integer) of object;

  TCustomITEvent = procedure(Sender: TObject; Index: Integer; var DT: TDateTime) of object;
  TCustomTIEvent = procedure(Sender: TObject; DT: TDateTime; var Index: Integer) of object;

  TDragOverHeaderEvent = procedure(Sender: TObject; Source: TObject; Position: Integer;State: TDragState; var Accept: Boolean) of object;

  TDragDropHeaderEvent = procedure(Sender: TObject; Source: TObject; Position: Integer) of object;

  {$IFDEF TMSDOTNET}
  TWMNotifyTT = class(TWMNotify)
  protected
    function GetToolTipText: TToolTipText;
    procedure SetToolTipText(value: TToolTipText);
  public
    property ToolTipText: TToolTipText read GetToolTipText write SetToolTipText;
  end;
  {$ENDIF}

  {TCompletion}

  TCompletion = class(TPersistent)
  private
    FStacked: Boolean;
    FShowBorder: Boolean;
    FShowGradient: Boolean;
    FCompletionSmooth: Boolean;
    FShowPercentage: Boolean;
    FLevel2Perc: Integer;
    FSteps: Integer;
    FLevel1Perc: Integer;
    FLevel0Color: TColor;
    FLevel1Color: TColor;
    FLevel3Color: TColor;
    FLevel3ColorTo: TColor;
    FLevel2ColorTo: TColor;
    FLevel2Color: TColor;
    FBorderColor: TColor;
    FLevel1ColorTo: TColor;
    FBackgroundColor: TColor;
    FLevel0ColorTo: TColor;
    FFont: TFont;
    FOnChange: TNotifyEvent;
    procedure SetBackGroundColor(const Value: TColor);
    procedure SetBorderColor(const Value: TColor);
    procedure SetCompletionSmooth(const Value: Boolean);
    procedure SetFont(const Value: TFont);
    procedure SetLevel0Color(const Value: TColor);
    procedure SetLevel0ColorTo(const Value: TColor);
    procedure SetLevel1Color(const Value: TColor);
    procedure SetLevel1ColorTo(const Value: TColor);
    procedure SetLevel1Perc(const Value: Integer);
    procedure SetLevel2Color(const Value: TColor);
    procedure SetLevel2ColorTo(const Value: TColor);
    procedure SetLevel2Perc(const Value: Integer);
    procedure SetLevel3Color(const Value: TColor);
    procedure SetLevel3ColorTo(const Value: TColor);
    procedure SetShowBorder(const Value: Boolean);
    procedure SetShowGradient(const Value: Boolean);
    procedure SetShowPercentage(const Value: Boolean);
    procedure SetStacked(const Value: Boolean);
    procedure SetSteps(const Value: Integer);
  public
    constructor Create;
    destructor Destroy; override;
    procedure Assign(Source: TPersistent); override;
    procedure Changed;
  published
    property Level0Color: TColor read FLevel0Color write SetLevel0Color default clLime;
    property Level0ColorTo : TColor read FLevel0ColorTo write SetLevel0ColorTo default clWhite;
    property Level1Color : TColor read FLevel1Color write SetLevel1Color default clYellow;
    property Level1ColorTo : TColor read FLevel1ColorTo write SetLevel1ColorTo default clWhite;
    property Level2Color : TColor read FLevel2Color write SetLevel2Color default 50943;
    property Level2ColorTo : TColor read FLevel2ColorTo write SetLevel2ColorTo default clWhite;
    property Level3Color : TColor read FLevel3Color write SetLevel3Color default clRed;
    property Level3ColorTo : TColor read FLevel3ColorTo write SetLevel3ColorTo default clWhite;
    property Level1Perc : Integer read FLevel1Perc write SetLevel1Perc default 70;
    property Level2Perc : Integer read FLevel2Perc write SetLevel2Perc default 90;
    property BorderColor : TColor read FBorderColor write SetBorderColor default clGray;
    property ShowBorder : Boolean read FShowBorder write SetShowBorder default True;
    property Stacked : Boolean read FStacked write SetStacked default False;
    property ShowPercentage : Boolean read FShowPercentage write SetShowPercentage default True;
    property Font : TFont read FFont write SetFont;
    property CompletionSmooth : Boolean read FCompletionSmooth write SetCompletionSmooth default True;
    property ShowGradient : Boolean read FShowGradient write SetShowGradient default True;
    property Steps : Integer read FSteps write SetSteps default 8;
    property BackgroundColor : TColor read FBackgroundColor write SetBackGroundColor default clBtnFace;
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
  end;

  TBalloonSettings = class(TPersistent)
  private
    FBackgroundColor: TColor;
    FTextColor: TColor;
    FReshowDelay: Integer;
    FInitialDelay: Integer;
    FAutoHideDelay: Integer;
    FTransparency: Byte;
    FEnable: Boolean;
    FOnEnableChange: TNotifyEvent;
    procedure SetEnable(const Value: Boolean);
  public
    constructor Create;
  published
    property AutoHideDelay: Integer read FAutoHideDelay write FAutoHideDelay default -1;
    property BackgroundColor: TColor read FBackgroundColor write FBackgroundColor default clNone;
    property Enable: Boolean read FEnable write SetEnable default True;
    property InitialDelay: Integer read FInitialDelay write FInitialDelay default -1;
    property ReshowDelay: Integer read FReshowDelay write FReshowDelay default -1;
    property TextColor: TColor read FTextColor write FTextColor default clNone;
    property Transparency: Byte read FTransparency write FTransparency default 0;
    property OnEnableChange: TNotifyEvent read FOnEnableChange write FOnEnableChange;
  end;

  {$IFDEF TMSSKINS}

  TPlannerSkin = class(TPersistent)
  private
    //FOwner: TCustomPlanner;
    FOwner: TCustomControl;
    FSkinTop: TBitmap;
    FSkinCenter: TBitmap;
    FSkinBottom: TBitmap;
    FSkinSelectTop: TBitmap;
    FSkinSelectCenter: TBitmap;
    FSkinSelectBottom: TBitmap;
    FSkinX: Integer;
    FSkinY: Integer;
    FSkinCaptionX: Integer;
    FSkinCaptionY: Integer;
    FOnChange: TNotifyEvent;
    procedure SetSkinTop(const AValue: TBitmap);
    procedure SetSkinCenter(const AValue: TBitmap);
    procedure SetSkinBottom(const AValue: TBitmap);
    procedure SetSkinSelectTop(const AValue: TBitmap);
    procedure SetSkinSelectCenter(const AValue: TBitmap);
    procedure SetSkinSelectBottom(const AValue: TBitmap);
  public
    constructor Create(AOwner: TCustomControl);
    destructor Destroy; override;
    procedure Assign(Source: TPersistent); override;
    procedure LoadFromFile(Filename: string);
    procedure ClearSkin;
  published
    property SkinTop: TBitmap read FSkinTop write SetSkinTop;
    property SkinCenter: TBitmap read FSkinCenter write SetSkinCenter;
    property SkinBottom: TBitmap read FSkinBottom write SetSkinBottom;
    property SkinSelectTop: TBitmap read FSkinSelectTop write SetSkinSelectTop;
    property SkinSelectCenter: TBitmap read FSkinSelectCenter write SetSkinSelectCenter;
    property SkinSelectBottom: TBitmap read FSkinSelectBottom write SetSkinSelectBottom;
    property SkinCaptionX: Integer read FSkinCaptionX write FSkinCaptionX default 0;
    property SkinCaptionY: Integer read FSkinCaptionY write FSkinCaptionY default 0;
    property SkinX: Integer read FSkinX write FSkinX default 0;
    property SkinY: Integer read FSkinY write FSkinY default 0;
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
  end;

  {$ENDIF}

  {TBands}

  TBands = class(TPersistent)
  private
    FOwner: TCustomPlanner;
    FShow: Boolean;
    FActivePrimary: TColor;
    FActiveSecondary: TColor;
    FNonActivePrimary: TColor;
    FNonActiveSecondary: TColor;
    procedure SetActivePrimary(const Value: TColor);
    procedure SetActiveSecondary(const Value: TColor);
    procedure SetNonActivePrimary(const Value: TColor);
    procedure SetNonActiveSecondary(const Value: TColor);
    procedure SetShow(const Value: Boolean);
  public
    constructor Create(AOwner:TCustomPlanner);
  published
    property Show: Boolean read FShow write SetShow default False;
    property ActivePrimary: TColor read FActivePrimary write SetActivePrimary default $00FEE7CB;
    property ActiveSecondary: TColor read FActiveSecondary write SetActiveSecondary default $00FAD9AF;
    property NonActivePrimary: TColor read FNonActivePrimary write SetNonActivePrimary default clSilver;
    property NonActiveSecondary: TColor read FNonActiveSecondary write SetNonActiveSecondary default $00A8A8A8;
  end;

  TAMPMPos = (apUnderTime,apNextToTime,apNone);

  TPlannerSideBar = class(TPersistent)
  private
    FAlignment: TAlignment;
    FBackGround: TColor;
    FBackGroundTo: TColor;
    FFont: TFont;
    FOwner: TCustomPlanner;
    FVisible: Boolean;
    FWidth: Integer;
    FColOffset: Integer;
    FRowOffset: Integer;
    FPosition: TSideBarPosition;
    FShowInPositionGap: Boolean;
    FShowOccupied: Boolean;
    FFlat: Boolean;
    FOccupied: TColor;
    FOccupiedTo: TColor;    
    FOccupiedFontColor: TColor;
    FDateTimeFormat: string;
    FBorder: Boolean;
    FRotateOnTop: Boolean;
    FShowDayName: Boolean;
    FSeparatorLineColor: TColor;
    FAMPMPos: TAMPMPos;
    FActiveColor: TColor;
    FActiveColorTo: TColor;
    FLineColor: TColor;
    FTimeIndicator: Boolean;
    FTimeIndicatorColor: TColor;
    FHourFontRatio: double;
    FShowOtherTimeZone: Boolean;
    FTimeZoneOffset: Integer;
    procedure SetAlignment(const Value: TAlignment);
    procedure SetBackground(const Value: TColor);
    procedure SetBackgroundTo(const Value: TColor);
    procedure SetFont(const Value: TFont);
    procedure FontChanged(Sender: TObject);
    procedure SetVisible(const Value: Boolean);
    procedure SetWidth(const Value: Integer);
    procedure SetPosition(const Value: TSideBarPosition);
    function GetOrientation: TSideBarOrientation;
    procedure SetShowInPositionGap(const Value: Boolean);
    procedure SetShowOccupied(const Value: Boolean);
    procedure SetFlat(const Value: Boolean);
    procedure SetOccupied(const Value: TColor);
    procedure SetOccupiedTo(const Value: TColor);    
    procedure SetOccupiedFontColor(const Value: TColor);
    procedure SetDateTimeFormat(const Value: string);
    procedure SetBorder(const Value: Boolean);
    procedure SetRotateOnTop(const Value: Boolean);
    procedure SetShowDayName(const Value: Boolean);
    procedure SetSeparatorLineColor(const Value: TColor);
    procedure SetAMPMPos(const Value: TAMPMPos);
    procedure SetActiveColor(const Value: TColor);
    procedure SetActiveColorTo(const Value: TColor);
    procedure SetLineColor(const Value: TColor);
    procedure SetTimeIndicator(const Value: Boolean);
    procedure SetTimeIndicatorColor(const Value: TColor);
    procedure SetHourFontRatio(const Value: double);
    procedure SetShowOtherTimeZone(const Value: boolean);
    procedure SetTimeZoneOffset(const Value: integer);
  public
    constructor Create(AOwner: TCustomPlanner);
    destructor Destroy; override;
    procedure Assign(Source: TPersistent); override;
    property Orientation: TSideBarOrientation read GetOrientation;
  protected
    procedure UpdateGrid;
  published
    property ActiveColor: TColor read FActiveColor write SetActiveColor default clNone;
    property ActiveColorTo: TColor read FActiveColorTo write SetActiveColorTo default clNone;
    property Alignment: TAlignment read FAlignment write SetAlignment default taLeftJustify;
    property AMPMPos: TAMPMPos read FAMPMPos write SetAMPMPos default apUnderTime;
    property Background: TColor read FBackGround write SetBackground default clBtnFace;
    property BackgroundTo: TColor read FBackGroundTo write SetBackgroundTo default clWhite;
    property Border: Boolean read FBorder write SetBorder default True;
    property DateTimeFormat: string read FDateTimeFormat write SetDateTimeFormat;
    property Flat: Boolean read FFlat write SetFlat default True;
    property Font: TFont read FFont write SetFont;
    property HourFontRatio: double read FHourFontRatio write SetHourFontRatio;
    property LineColor: TColor read FLineColor write SetLineColor default clGray;
    property Occupied: TColor read FOccupied write SetOccupied default clBlue;
    property OccupiedTo: TColor read FOccupiedTo write SetOccupiedTo default clNone;
    property OccupiedFontColor: TColor read FOccupiedFontColor write SetOccupiedFontColor default clWhite;
    property Position: TSideBarPosition read FPosition write SetPosition default spLeft;
    property RotateOnTop: Boolean read FRotateOnTop write SetRotateOnTop default True;
    property SeparatorLineColor: TColor read FSeparatorLineColor write SetSeparatorLineColor default clGray;
    property ShowInPositionGap: Boolean read FShowInPositionGap write SetShowInPositionGap default False;
    property ShowOccupied: Boolean read FShowOccupied write SetShowOccupied default False;
    property ShowDayName: Boolean read FShowDayName write SetShowDayName default True;
    property ShowOtherTimeZone: Boolean read FShowOtherTimeZone write SetShowOtherTimeZone default False;
    property TimeIndicator: Boolean read FTimeIndicator write SetTimeIndicator default False;
    property TimeIndicatorColor: TColor read FTimeIndicatorColor write SetTimeIndicatorColor default clRed;
    property TimeZoneMinDelta: Integer read FTimeZoneOffset write SetTimeZoneOffset default 0;
    property Visible: Boolean read FVisible write SetVisible default True;
    property Width: Integer read FWidth write SetWidth default 40;
  end;

  TPlannerGradientDirection = (gdHorizontal, gdVertical);

  TPlannerCaption = class(TPersistent)
  private
    FTitle: string;
    FAlignment: TAlignment;
    FBackGround: TColor;
    FBackgroundTo: TColor;
    FFont: TFont;
    FOwner: TCustomPlanner;
    FHeight: Integer;
    FVisible: Boolean;
    FBackgroundSteps: Integer;
    FGradientDirection: TPlannerGradientDirection;
    procedure SetAlignment(const Value: TAlignment);
    procedure SetBackground(const Value: TColor);
    procedure SetFont(const Value: TFont);
    procedure SetTitle(const Value: string);
    procedure SetHeigth(const Value: Integer);
    procedure FontChanged(Sender: TObject);
    procedure SetVisible(const Value: Boolean);
    procedure SetBackgroundTo(const Value: TColor);
    procedure SetBackgroundSteps(const Value: Integer);
    procedure SetGradientDirection(const Value: TPlannerGradientDirection);
  protected
    procedure UpdatePanel;
  public
    constructor Create(AOwner: TCustomPlanner);
    destructor Destroy; override;
    procedure Assign(Source: TPersistent); override;
  published
    property Title: string read FTitle write SetTitle;
    property Font: TFont read FFont write SetFont;
    property Alignment: TAlignment read FAlignment write SetAlignment default taLeftJustify;
    property Background: TColor read FBackGround write SetBackground default clGray;
    property BackgroundSteps: Integer read FBackgroundSteps write SetBackgroundSteps default 128;
    property BackgroundTo: TColor read FBackgroundTo write SetBackgroundTo default clWhite;
    property GradientDirection: TPlannerGradientDirection read FGradientDirection write SetGradientDirection default gdHorizontal;
    property Height: Integer read FHeight write SetHeigth default 32;
    property Visible: Boolean read FVisible write SetVisible default True;
  end;

  TPlannerType = (plDay, plWeek, plMonth, plDayPeriod, plHalfDayPeriod, plMultiMonth,
    plCustom, plTimeLine, plCustomList);

  TPlannerPanel = class(TPanel)
  private
    FPlanner: TCustomPlanner;
    FOldAnchor: string;
    function IsAnchor(x,y: Integer): string;
    procedure CMDesignHitTest(var Msg: TCMDesignHitTest); message CM_DESIGNHITTEST;
  protected
    procedure Paint; override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
  public
    constructor Create(AOwner: TComponent); override;
  end;

  TPlannerMode = class(TPersistent)
  private
    FClip: Boolean;
    FOwner: TCustomPlanner;
    FPlannerType: TPlannerType;
    FWeekStart: Integer;
    FYear: Integer;
    FMonth: Integer;
    FDateTimeFormat: string;
    FPeriodStartDay: Integer;
    FPeriodStartMonth: Integer;
    FPeriodStartYear: Integer;
    FPeriodEndDay: Integer;
    FPeriodEndMonth: Integer;
    FPeriodEndYear: Integer;
    FUpdateCount: Integer;
    FTimeLineStart: TDateTime;
    FTimeLineNVUBegin: Integer;
    FTimeLineNVUEnd: Integer;
    FFullHalfDay: Boolean;
    procedure SetMonth(const Value: Integer);
    procedure SetPlannerType(const Value: TPlannerType);
    procedure SetWeekStart(const Value: Integer);
    procedure SetYear(const Value: Integer);
    procedure SetDateTimeFormat(const Value: string);
    procedure SetPeriodStartDay(const Value: Integer);
    procedure SetPeriodStartMonth(const Value: Integer);
    procedure SetPeriodStartYear(const Value: Integer);
    procedure SetPeriodEndDay(const Value: Integer);
    procedure SetPeriodEndMonth(const Value: Integer);
    procedure SetPeriodEndYear(const Value: Integer);
    function GetPeriodEndDate: TDateTime;
    function GetPeriodStartDate: TDateTime;
    function GetStartOfMonth: TDateTime;
    procedure UpdatePeriod;
    procedure SetPeriodEndDate(const Value: TDateTime);
    procedure SetPeriodStartDate(const Value: TDateTime);
    procedure SetTimeLineStart(const Value: TDateTime);
    procedure SetTimeLineNVUBegin(const Value: Integer);
    procedure SetTimeLineNVUEnd(const Value: Integer);
  public
    constructor Create(AOwner: TCustomPlanner);
    destructor Destroy; override;
    property PeriodStartDate: TDateTime read GetPeriodStartDate write SetPeriodStartDate;
    property PeriodEndDate: TDateTime read GetPeriodEndDate write SetPeriodEndDate;
    property StartOfMonth: TDateTime read GetStartOfMonth;
    procedure BeginUpdate;
    procedure EndUpdate;
    procedure Assign(Source: TPersistent); override;
    property FullHalfDay: Boolean read FFullHalfDay write FFullHalfDay;
  published
    property Clip: Boolean read FClip write FClip default False;
    property DateTimeFormat: string read FDateTimeFormat write SetDateTimeFormat;
    property Month: Integer read FMonth write SetMonth;
    property PeriodStartDay: Integer read FPeriodStartDay write SetPeriodStartDay;
    property PeriodStartMonth: Integer read FPeriodStartMonth write SetPeriodStartMonth;
    property PeriodStartYear: Integer read FPeriodStartYear write SetPeriodStartYear;
    property PeriodEndDay: Integer read FPeriodEndDay write SetPeriodEndDay;
    property PeriodEndMonth: Integer read FPeriodEndMonth write SetPeriodEndMonth;
    property PeriodEndYear: Integer read FPeriodEndYear write SetPeriodEndYear;
    property PlannerType: TPlannerType read FPlannerType write SetPlannerType default plDay;
    property TimeLineStart: TDateTime read FTimeLineStart write SetTimeLineStart;
    property TimeLineNVUBegin: Integer read FTimeLineNVUBegin write SetTimeLineNVUBegin;
    property TimeLineNVUEnd: Integer read FTimeLineNVUEnd write SetTimeLineNVUEnd;    
    property WeekStart: Integer read FWeekStart write SetWeekStart default 0;
    property Year: Integer read FYear write SetYear;
  end;

  TPlannerMaskEdit = class(TMaskEdit)
  private
    FPlannerItem: TPlannerItem;
    procedure WMPaste(var Msg:TMessage); message WM_PASTE;
    procedure WMCopy(var Msg:TMessage); message WM_COPY;
    procedure WMCut(var Msg:TMessage); message WM_CUT;
  protected
    procedure KeyDown(var Key: Word; Shift: TShiftState); override;
    procedure DoExit; override;
  public
    procedure StopEdit;
  published
    property PlannerItem: TPlannerItem read FPlannerItem write FPlannerItem;
  end;

  TPlannerMemo = class(TMemo)
  private
    FPlannerItem: TPlannerItem;
    FPlanner: TCustomPlanner;
    procedure WMPaste(var Msg:TMessage); message WM_PASTE;
    procedure WMCopy(var Msg:TMessage); message WM_COPY;
    procedure WMCut(var Msg:TMessage); message WM_CUT;
  protected
    procedure KeyDown(var Key: Word; Shift: TShiftState); override;
    procedure DoEnter; override;
    procedure DoExit; override;
    procedure DblClick; override;
  public
    procedure StopEdit;
  published
    property PlannerItem: TPlannerItem read FPlannerItem write FPlannerItem;
    property Planner: TCustomPlanner read FPlanner write FPlanner;
  end;

  {$IFNDEF TMSDOTNET}
  {$IFNDEF DELPHI_UNICODE}
  TPlannerUniMemo = class(TPlanUniMemo)
  private
    FPlannerItem: TPlannerItem;
    FPlanner: TCustomPlanner;
    procedure WMPaste(var Msg:TMessage); message WM_PASTE;
    procedure WMCopy(var Msg:TMessage); message WM_COPY;
    procedure WMCut(var Msg:TMessage); message WM_CUT;
  protected
    procedure KeyDown(var Key: Word; Shift: TShiftState); override;
    procedure DoEnter; override;
    procedure DoExit; override;
    procedure DblClick; override;
  public
  published
    property PlannerItem: TPlannerItem read FPlannerItem write FPlannerItem;
    property Planner: TCustomPlanner read FPlanner write FPlanner;
  end;
  {$ENDIF}
  {$ENDIF}

  TPlannerRichEdit = class(TRichEdit)
  private
    FPlannerItem: TPlannerItem;
  protected
    procedure KeyDown(var Key: Word; Shift: TShiftState); override;
    procedure DoEnter; override;
    procedure DoExit; override;
  published
    property PlannerItem: TPlannerItem read FPlannerItem write FPlannerItem;
  end;

  TPlannerDisplay = class(TPersistent)
  private
    FOwner: TCustomPlanner;
    FDisplayStart: Integer;
    FDisplayScale: Integer;
    FDisplayEnd: Integer;
    FDisplayUnit: Integer;
    FActiveEnd: Integer;
    FActiveStart: Integer;
    FColorNonActive: TColor;
    FColorActive: TColor;
    FColorCurrent: TColor;
    FColorCurrentItem: TColor;
    FActiveStartPrecis: Integer;
    FActiveEndPrecis: Integer;
    FDisplayStartPrecis: Integer;
    FDisplayEndPrecis: Integer;
    FShowCurrent: Boolean;
    FShowCurrentItem: Boolean;
    FScaleToFit: Boolean;
    FOldScale: Integer;
    FDisplayOffset: Integer;
    FUpdateCount: Integer;
    FUpdateUnit: Boolean;
    FDisplayText: Integer;
    FCurrentPosFrom: Integer;
    FCurrentPosTo: Integer;
    FHourLineColor: TColor;    
    procedure SetDisplayStart(const Value: Integer);
    procedure SetDisplayEnd(const Value: Integer);
    procedure SetDisplayScale(const Value: Integer);
    procedure SetDisplayUnit(const Value: Integer);
    procedure SetDisplayOffset(const Value: Integer);    
    procedure UpdatePlanner;
    procedure SetActiveEnd(const Value: Integer);
    procedure SetActiveStart(const Value: Integer);
    procedure SetColorActive(const Value: TColor);
    procedure SetColorNonActive(const Value: TColor);
    procedure SetColorCurrent(const Value: TColor);
    procedure SetShowCurrent(const Value: Boolean);
    procedure SetColorCurrentItem(const Value: TColor);
    procedure SetShowCurrentItem(const Value: Boolean);
    procedure SetScaleToFit(const Value: Boolean);
    procedure SetDisplayText(const Value: Integer);
    procedure SetCurrentPosFrom(const Value: Integer);
    procedure SetCurrentPosTo(const Value: Integer);
    procedure SetHourLineColor(const Value: TColor);
  protected
    procedure InitPrecis;
    procedure AutoScale;
  public
    constructor Create(AOwner: TCustomPlanner);
    destructor Destroy; override;
    procedure Assign(Source: TPersistent); override;
    procedure BeginUpdate;
    procedure EndUpdate;
  published
    property ActiveStart: Integer read FActiveStart write SetActiveStart default 16;
    property ActiveEnd: Integer read FActiveEnd write SetActiveEnd default 47;
    property CurrentPosFrom: Integer read FCurrentPosFrom write SetCurrentPosFrom default -1;
    property CurrentPosTo: Integer read FCurrentPosTo write SetCurrentPosTo default - 1;
    property DisplayStart: Integer read FDisplayStart write SetDisplayStart default 0;
    property DisplayEnd: Integer read FDisplayEnd write SetDisplayEnd default 47;
    property DisplayOffset: Integer read FDisplayOffset write SetDisplayOffset default 0;
    property DisplayScale: Integer read FDisplayScale write SetDisplayScale default 24;
    property DisplayUnit: Integer read FDisplayUnit write SetDisplayUnit default 30;
    property DisplayText: Integer read FDisplayText write SetDisplayText default 0;
    property ColorActive: TColor read FColorActive write SetColorActive default clWhite;
    property ColorNonActive: TColor read FColorNonActive write SetColorNonActive default $00DEDEDE;
    property ColorCurrent: TColor read FColorCurrent write SetColorCurrent default clYellow;
    property ColorCurrentItem: TColor read FColorCurrentItem write SetColorCurrentItem default clLime;
    property HourLineColor: TColor read FHourLineColor write SetHourLineColor default clGray;
    property ScaleToFit: Boolean read FScaleToFit write SetScaleToFit default False;
    property ShowCurrent: Boolean read FShowCurrent write SetShowCurrent default False;
    property ShowCurrentItem: Boolean read FShowCurrentItem write SetShowCurrentItem default False;
  end;

  TNavigatorButtons = class(TPersistent)
  private
    FOwner: TCustomPlanner;
    FVisible: Boolean;
    FShowHint: Boolean;
    FNextHint: string;
    FPrevHint: string;
    FFlat: Boolean;
    procedure SetVisible(Value: Boolean);
    procedure SetNextHint(const Value: string);
    procedure SetPrevHint(const Value: string);
    procedure SetShowHint(const Value: Boolean);
    procedure SetFlat(const Value: Boolean);
  public
    constructor Create(AOwner: TCustomPlanner);
  published
    property Flat: Boolean read FFlat write SetFlat default True;
    property Visible: Boolean read FVisible write SetVisible default True;
    property PrevHint: string read FPrevHint write SetPrevHint;
    property NextHint: string read FNextHint write SetNextHint;
    property ShowHint: Boolean read FShowHint write SetShowHint default False;
  end;

  TImagePosition = (ipLeft, ipRight);

  TCompletionType = (ctFullTime, ctActiveTime);

  TPlannerFooter = class(TPersistent)
  private
    FOwner: TCustomPlanner;
    FFlat: Boolean;
    FVisible: Boolean;
    FHeight: Integer;
    FAlignment: TAlignment;
    FColorTo: TColor;
    FLineColor: TColor;
    FColor: TColor;
    FFont: TFont;
    FImages: TImageList;
    FImagePosition: TImagePosition;
    FCaptions: TStringList;
    FVAlignment: TVAlignment;
    FShowCompletion: Boolean;
    FCompletion: TCompletion;
    FCustomCompletionValue: Boolean;
    FCompletionType: TCompletionType;
    FCompletionFormat: string;
    procedure SetAlignment(const Value: TAlignment);
    procedure SetCaptions(const Value: TStringList);
    procedure SetColor(const Value: TColor);
    procedure SetColorTo(const Value: TColor);
    procedure SetFlat(const Value: Boolean);
    procedure SetFont(const Value: TFont);
    procedure SetHeight(const Value: Integer);
    procedure SetImagePosition(const Value: TImagePosition);
    procedure SetImages(const Value: TImageList);
    procedure SetLineColor(const Value: TColor);
    procedure SetVAlignment(const Value: TVAlignment);
    procedure SetVisible(const Value: Boolean);
    procedure ItemsChanged(Sender: TObject);
    procedure SetShowCompletion(const Value: Boolean);
    function GetCompletionValue(Index: Integer): Integer;
    procedure SetCompletionValue(Index: Integer; const Value: Integer);
    procedure SetCustomCompletionValue(const Value: Boolean);
    procedure SetCompletionType(const Value: TCompletionType);
    procedure SetCompletionFormat(const Value: string);
  public
    constructor Create(AOwner: TCustomPlanner);
    destructor Destroy; override;
    procedure Assign(Source: TPersistent); override;    
    property CompletionValue[Index: Integer]: Integer read GetCompletionValue write SetCompletionValue;
  published
    property Alignment: TAlignment read FAlignment write SetAlignment default taLeftJustify;
    property Captions: TStringList read FCaptions write SetCaptions;
    property CompletionFormat: string read FCompletionFormat write SetCompletionFormat;
    property CompletionType: TCompletionType read FCompletionType write SetCompletionType default ctFullTime;
    property Color: TColor read FColor write SetColor default clBtnFace;
    property ColorTo: TColor read FColorTo write SetColorTo default clWhite;
    property Completion: TCompletion read FCompletion write FCompletion;
    property CustomCompletionValue: Boolean read FCustomCompletionValue write SetCustomCompletionValue default False;
    property Height: Integer read FHeight write SetHeight default 32;
    property Flat: Boolean read FFlat write SetFlat default False;
    property Font: TFont read FFont write SetFont;
    property Images: TImageList read FImages write SetImages;
    property ImagePosition: TImagePosition read FImagePosition write SetImagePosition default ipLeft;
    property LineColor: TColor read FLineColor write SetLineColor default clBlack;
    property ShowCompletion: Boolean read FShowCompletion write SetShowCompletion default False;
    property VAlignment: TVAlignment read FVAlignment write SetVAlignment default vtaCenter;
    property Visible: Boolean read FVisible write SetVisible default False;
  end;

  TGroupCollectionItem = class(TCollectionItem)
  private
    FTag: Integer;
    FImageIndex: Integer;
    FSpan: Integer;
    FCaption: string;
    {$IFNDEF TMSDOTNET}
    FWideCaption: widestring;
    {$ENDIF}
    procedure SetCaption(const Value: string);
    procedure SetImageIndex(const Value: Integer);
    procedure SetSpan(const Value: Integer);
    {$IFNDEF TMSDOTNET}
    procedure SetWideCaption(const Value: widestring);
    {$ENDIF}
  protected
  public
    constructor Create(Collection: TCollection); override;
    procedure Assign(Source: TPersistent); override;
  published
    property Caption: string read FCaption write SetCaption;
    {$IFNDEF TMSDOTNET}
    property WideCaption: widestring read FWideCaption write SetWideCaption;
    {$ENDIF}
    property Span: Integer read FSpan write SetSpan default 1;
    property Tag: Integer read FTag write FTag default 0;
    property ImageIndex: Integer read FImageIndex write SetImageIndex default -1;
  end;

  TGroupCollection = class(TOwnedCollection)
  private
    FOwner: TPersistent;
    FOnChange: TNotifyEvent;
    function GetItem(Index: Integer): TGroupCollectionItem;
    procedure SetItem(Index: Integer; AItem: TGroupCollectionItem);
  protected
    procedure DoChanged; virtual;
  public
    constructor Create(AOwner: TPersistent; AItemClass: TCollectionItemClass);
    procedure Assign(Source: TPersistent); override;
    function Add: TGroupCollectionItem;
    function Insert(Index: Integer): TGroupCollectionItem;
    property Items[Index: Integer]: TGroupCollectionItem read GetItem write SetItem; default;
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
  end;

  TPlannerStringList = class(TStringlist)
  private
    function GetItem(Index: Integer): string;
    procedure SetItem(Index: Integer; const Value: string);
  public
    property Strings[Index: Integer]: string read GetItem write SetItem; default;
  end;


  TPlannerHeader = class(TPersistent)
  private
    FOwner: TCustomPlanner;
    FCaptions: TPlannerStringList;
    FVisible: Boolean;
    FHeight: Integer;
    FFont: TFont;
    FGroupFont: TFont;
    FColor: TColor;
    FFlat: Boolean;
    FAlignment: TAlignment;
    FVAlignment: TVAlignment;
    FImages: TImageList;
    FImagePosition: TImagePosition;
    FReadOnly: Boolean;
    FItemHeight: Integer;
    FTextHeight: Integer;
    FAllowResize: Boolean;
    FAllowPositionResize: Boolean;
    FAutoSize: Boolean;
    FItemColor: TColor;
    FGroupCaptions: TPlannerStringList;
    FPopupMenu: TPopupMenu;
    FLineColor: TColor;
    FColorTo: TColor;
    FRotateOnLeft: Boolean;
    FRotateGroupOnLeft: Boolean;
    FRotateOnTop: Boolean;
    FResizeAll: Boolean;
    FShowHint: Boolean;
    FActiveColor: TColor;
    FActiveColorTo: TColor;
    FGroupSpan: TPlannerIntList;
    FCustomGroups: TGroupCollection;
    FWordWrap: Boolean;
    FAutoSizeGroupCaption: boolean;
    {$IFNDEF TMSDOTNET}
    //FWideCaptions: TWideStrings;
    //FWideGroupCaptions: TWideStrings;
    {$ENDIF}
//    FCursor: TCursor;
    procedure SetAlignment(const Value: TAlignment);
    procedure SetCaptions(const Value: TPlannerStringList);
    function GetDragDrop: Boolean;
    procedure SetDragDrop(const Value: Boolean);
    procedure SetHeight(const Value: Integer);
    procedure SetVisible(const Value: Boolean);
    procedure SetColor(const Value: TColor);
    procedure SetFont(const Value: TFont);
    procedure SetGroupFont(const Value: TFont);
    procedure FontChanged(Sender: TObject);
    procedure GroupFontChanged(Sender: TObject);
    procedure ItemsChanged(Sender: TObject);
    procedure SetImages(const Value: TImageList);
    procedure SetImagePosition(const Value: TImagePosition);
    procedure SetFlat(const Value: Boolean);
    procedure SetVAlignment(const Value: TVAlignment);
    procedure SetReadOnly(const Value: Boolean);
    procedure SetItemHeight(const Value: Integer);
    procedure SetTextHeight(const Value: Integer);
    procedure SetAllowResize(const Value: Boolean);
    procedure SetAllowPositionResize(const Value: Boolean);
    procedure SetAutoSize(const Value: Boolean);
    procedure SetItemColor(const Value: TColor);
    procedure SetGroupCaptions(const Value: TPlannerStringList);
    procedure SetLineColor(const Value: TColor);
    procedure UpdateHeights;
    procedure SetColorTo(const Value: TColor);
    procedure SetActiveColor(const Value: TColor);
    procedure SetActiveColorTo(const Value: TColor);
//    procedure SetCursor(const Value: TCursor);
    procedure SetRotateOnLeft(const Value: Boolean);
    procedure SetRotateGroupOnLeft(const Value: Boolean);
    procedure SetRotateOnTop(const Value: Boolean);
    procedure SetCustomGroups(const Value: TGroupCollection);
    procedure CustomGroupChange(Sender: TObject);
    procedure SetWordWrap(const Value: Boolean);
    procedure SetAutoSizeGroupCaption(const Value: boolean);
    {$IFNDEF TMSDOTNET}
    //procedure SetWideCaptions(const Value: TWideStrings);
    //procedure SetWideGroupCaptions(const Value: TWideStrings);
    {$ENDIF}
  protected
    function GetOwner: TPersistent; override;
  public
    constructor Create(AOwner: TCustomPlanner);
    destructor Destroy; override;
    procedure Assign(Source: TPersistent); override;
    procedure MergeHeader(FromSection,ToSection: Integer);
    procedure UnMergeHeader(FromSection,ToSection: Integer);
    property GroupSpan: TPlannerIntList read FGroupSpan write FGroupSpan;
    function GroupSplit(pos: integer): integer;
    function GetGroupCaption(pos: integer): string;
    {$IFNDEF TMSDOTNET}
    //property WideCaptions: TWideStrings read FWideCaptions write SetWideCaptions;
    //property WideGroupCaptions: TWideStrings read FWideGroupCaptions write SetWideGroupCaptions;
    {$ENDIF}
  published
    property ActiveColor: TColor read FActiveColor write SetActiveColor default clNone;
    property ActiveColorTo: TColor read FActiveColorTo write SetActiveColorTo default clNone;
    property Alignment: TAlignment read FAlignment write SetAlignment default taLeftJustify;
    property AllowResize: Boolean read FAllowResize write SetAllowResize default False;
    property AllowPositionResize: Boolean read FAllowPositionResize write SetAllowPositionResize default False;
    property AutoSize: Boolean read FAutoSize write SetAutoSize default False;
    property AutoSizeGroupCaption: boolean read FAutoSizeGroupCaption write SetAutoSizeGroupCaption default False;
    property Captions: TPlannerStringList read FCaptions write SetCaptions;
    property Color: TColor read FColor write SetColor default clBtnFace;
    property ColorTo: TColor read FColorTo write SetColorTo default clWhite;
    property CustomGroups: TGroupCollection read FCustomGroups write SetCustomGroups;
//    property Cursor: TCursor read FCursor write SetCursor default crDefault;
    property DragDrop: Boolean read GetDragDrop write SetDragDrop default False;
    property Height: Integer read FHeight write SetHeight default 32;
    property Flat: Boolean read FFlat write SetFlat default False;
    property Font: TFont read FFont write SetFont;
    property GroupFont: TFont read FGroupFont write SetGroupFont;
    property GroupCaptions: TPlannerStringList read FGroupCaptions write SetGroupCaptions;
    property Images: TImageList read FImages write SetImages;
    property ImagePosition: TImagePosition read FImagePosition write SetImagePosition default ipLeft;
    property ItemColor: TColor read FItemColor write SetItemColor default clGray;
    property ItemHeight: Integer read FItemHeight write SetItemHeight default 32;
    property LineColor: TColor read FLineColor write SetLineColor default clGray;
    property PopupMenu: TPopupMenu read FPopupMenu write FPopupMenu;
    property ReadOnly: Boolean read FReadOnly write SetReadOnly default True;
    property ResizeAll: Boolean read FResizeAll write FResizeAll default True;
    property RotateOnLeft: Boolean read FRotateOnLeft write SetRotateOnLeft default False;
    property RotateGroupOnLeft: Boolean read FRotateGroupOnLeft write SetRotateGroupOnLeft default False;
    property RotateOnTop: Boolean read FRotateOnTop write SetRotateOnTop default False;
    property ShowHint: Boolean read FShowHint write FShowHint default False;
    property TextHeight: Integer read FTextHeight write SetTextHeight default 32;
    property VAlignment: TVAlignment read FVAlignment write SetVAlignment default vtaCenter;
    property Visible: Boolean read FVisible write SetVisible default True;
    property WordWrap: Boolean read FWordWrap write SetWordWrap default False;
  end;

  TCaptionType = (ctNone, ctText, ctTime, ctTimeText);

  TImageChangeEvent = procedure(Sender: TObject) of object;

  TPlannerIntList = class(TList)
  private
    FOnChange: TImageChangeEvent;
    FPlannerItem: TPlannerItem;
    procedure SetInteger(Index: Integer; Value: Integer);
    function GetInteger(Index: Integer): Integer;
  public
    constructor Create(Value: TPlannerItem);
    property Items[Index: Integer]: Integer read GetInteger write SetInteger;
    default;
    procedure Add(Value: Integer);
    procedure Delete(Index: Integer);
    {$IFDEF DELPHI4_LVL}
    procedure Clear; override;
    {$ELSE}
    procedure Clear;
    {$ENDIF}
    property OnChange: TImageChangeEvent read FOnChange write FOnChange;
  end;

  TPlannerItemEdit = (peMemo, peEdit, peMaskEdit, peRichText, peCustom
    , peForm
{$IFNDEF TMSDOTNET}
    , peUniMemo
{$ENDIF}
    );

  TPlannerLinkType = (ltLinkFull, ltLinkBeginEnd, ltLinkEndBegin, ltLinkEndEnd,
    ltLinkBeginBegin);

  TPlannerShape = (psRect, psRounded, psHexagon, psTool
    {$IFDEF TMSSKINS}
    , psSkin
    {$ENDIF}
    );

  TFindTextParameter = (fnMatchCase,fnMatchFull,fnMatchRegular,fnMatchStart,
    fnAutoGoto,fnIgnoreHTMLTags,fnBackward,fnCaptionText,fnText);

  TFindTextParams = set of TFindTextParameter;

  TAlarmNotifyType = (anCaption,anNotes,anMessage);

  TCompletionDisplay = (cdNone, cdVertical, cdHorizontal);

  TPlannerBarItem = class(TPersistent)
  private
    FBegin: Integer;
    FEnd: Integer;
    FColor: TColor;
    FStyle: TBrushStyle;
    FOnDestroy: TNotifyEvent;
    FOwner: TPlannerBarItemList;
    function GetEndTime: TDateTime;
    function GetStartTime: TDateTime;
    procedure SetEndTime( const pEndTime: TDateTime);
    procedure SetStartTime( const pStartTime: TDateTime);
    function CheckOwners: Boolean;
  public
    constructor Create( pOwner: TPlannerBarItemList);
    destructor Destroy; override;
  published
    property BarColor: TColor read FColor write FColor;
    property BarBegin: Integer read FBegin write FBegin;
    property BarEnd: Integer read FEnd write FEnd;
    property BarStyle: TBrushStyle read FStyle write FStyle;
    property Owner: TPlannerBarItemList read FOwner;
    property EndTime: TDateTime read getEndTime write setEndTime;
    property StartTime: TDateTime read getStartTime write setStartTime;
    property OnDestroy: TNotifyEvent read FOnDestroy write FOnDestroy;
  end;

  TPlannerBarItemList = class(TList)
  private
    FOwner: TPlannerItem;
    function GetItem(Index: Integer): TPlannerBarItem;
  public
    function AddItem(pStart,pEnd: TDateTime; pColor: TColor; pStyle: TBrushStyle): Integer;
    constructor Create(AOwner: TPlannerItem);
    destructor Destroy; override;
    property Items[Index: Integer]: TPlannerBarItem read GetItem; default;
    property Owner: TPlannerItem read FOwner write FOwner;
  end;

  TPlannerAlarmHandler = class(TComponent)
  public
    function HandleAlarm(Address,Message:string; Tag, ID: Integer;
      Item: TPlannerItem): Boolean; virtual;
  end;

  TAlarmMessage = class(TPlannerAlarmHandler)
  public
    function HandleAlarm(Address,Message:string; Tag, ID: Integer;
      Item: TPlannerItem): Boolean; override;
  end;

  TAlarmTime = (atBefore,atAfter,atBoth);

  TPlannerAlarm = class(TPersistent)
  private
    FActive: Boolean;
    FTag: Integer;
    FID: Integer;
    FAddress: string;
    FMessage: string;
    FNotifyType: TAlarmNotifyType;
    FTimeBefore: TDateTime;
    FTimeAfter: TDateTime;
    FHandler: TPlannerAlarmHandler;
    FTime: TAlarmTime;
  protected
  public
    procedure Assign(Source: TPersistent); override;
  published
    property Active: Boolean read FActive write FActive default false;
    property Address: string read FAddress write FAddress;
    property Handler: TPlannerAlarmHandler read FHandler write FHandler;
    property ID: Integer read FID write FID default 0;
    property Message: string read FMessage write FMessage;
    property NotifyType: TAlarmNotifyType read FNotifyType write FNotifyType default anCaption;
    property Tag: Integer read FTag write FTag default 0;
    property Time: TAlarmTime read FTime write FTime default atBefore;
    property TimeBefore: TDateTime read FTimeBefore write FTimeBefore;
    property TimeAfter: TDateTime read FTimeAfter write FTimeAfter;    
  end;

  TItemRelationShip = (irParent,irChild);

  TEditorUse = (euAlways, euDblClick);

  TEditDoneEvent = procedure (Sender: TObject; ModalResult: TModalResult) of object;

  TCustomItemEditor = class(TComponent)
  private
    //FEditItem: TPlannerItem;
    FPlanner: TCustomPlanner;
    FCaption: string;
    FEditorUse: TEditorUse;
    FOnEditDone: TEditDoneEvent;
    FModalResult: TModalResult;
  protected
  public
    procedure Edit(APlanner: TCustomPlanner;APlannerItem: TPlannerItem);
    function QueryEdit(APlannerItem: TPlannerItem): Boolean; virtual;
    procedure CreateEditor(AOwner: TComponent); virtual;
    procedure DestroyEditor; virtual;
    function Execute: Integer; virtual;
    procedure PlannerItemToEdit(APlannerItem: TPlannerItem); virtual;
    procedure EditToPlannerItem(APlannerItem: TPlannerItem); virtual;
    property Planner: TCustomPlanner read FPlanner;
    property ModalResult: TModalResult read FModalResult write FModalResult;
  published
    property Caption: string read FCaption write FCaption;
    property EditorUse: TEditorUse read FEditorUse write FEditorUse;
    property OnEditDone: TEditDoneEvent read FOnEditDone write FOnEditDone;
  end;

  TCustomItemDrawTool = class(TComponent)
  private
  public
    procedure DrawItem(PlannerItem: TPlannerItem; Canvas: TCanvas; Rect: TRect;
      Selected,Print: Boolean); virtual;
  end;

  TSelectButton = (sbLeft, sbRight, sbBoth);

  TPlannerItemSelection = class(TPersistent)
  private
    FAutoUnSelect: Boolean;
    FAutoSelectOnAutoInsert: Boolean;
    FAutoEditOnAutoInsert: Boolean;
    FButton: TSelectButton;
  public
    constructor Create;
    procedure Assign(Source: TPersistent); override;
  published
    property AutoEditOnAutoInsert: Boolean read FAutoEditOnAutoInsert write FAutoEditOnAutoInsert default False;
    property AutoSelectOnAutoInsert: Boolean read FAutoSelectOnAutoInsert write FAutoSelectOnAutoInsert default True;
    property AutoUnSelect: Boolean read FAutoUnSelect write FAutoUnSelect default True;
    property Button: TSelectButton read FButton write FButton default sbLeft;
  end;

  TPlannerSelection = class(TCollectionItem)
  private
    FSelBegin: Integer;
    FSelEnd: Integer;
    FSelPos: Integer;
  public
    procedure Update;  
  published
    property SelBegin: Integer read FSelBegin write FSelBegin;
    property SelEnd: Integer read FSelEnd write FSelEnd;
    property SelPos: Integer read FSelPos write FSelPos;
  end;

  TPlannerSelections = class(TCollection)
  private
    FOwner: TCustomPlanner;
    function GetItem(Index: Integer): TPlannerSelection;
    procedure SetItem(Index: Integer; const Value: TPlannerSelection);
  public
    constructor Create(AOwner: TCustomPlanner);
    procedure Clear; 
    function Add: TPlannerSelection;
    function Insert(Index: Integer): TPlannerSelection;
    property Items[Index: Integer]: TPlannerSelection read GetItem write SetItem; default;
  end;

  TItemImagePosition = (ipHorizontal, ipVertical);

  { TPlannerItem }

  TPlannerItem = class(TCollectionItem)
  private
    FAlarm: TPlannerAlarm;
    FBarItems: TPlannerBarItemList;
    FTag: Integer;
    FId: Integer;
    FObject: TObject;
    FAlignment: TAlignment;
    FAttachement: string;
    FCaptionType: TCaptionType;
    FCaptionText: string;
    FEditMask: string;
    FText: TStringList;
    FInplaceEdit: TPlannerItemEdit;
    FItemBegin: Integer;
    FItemEnd: Integer;
    FItemBeginPrecis: Integer;
    FItemEndPrecis: Integer;
    FItemFullBegin: Integer;
    FImageID: Integer;
    FInHeader: Boolean;
    FColor: TColor;
    FColorTo: TColor;
    FBorderColor: TColor;
    FFixedPos: Boolean;
    FFixedSize: Boolean;
    FFixedPosition: Boolean;
    FReadOnly: Boolean;
    FPlanner: TCustomPlanner;
    FItemPos: Integer;
    FConflicts: Integer;
    FConflictPos: Integer;
    FVisible: Boolean;
    FFocus: Boolean;
    FName: string;
    FOnEditModal: TNotifyEvent; 
    FLayer: Integer;
    FTrackColor: TColor;
    FTrackSelectColor: TColor;
    FTrackLinkColor: TColor;
    FTrackVisible: Boolean;
    FHint: string;
    FImageIndexList: TPlannerIntList;
    FImagePosition: TItemImagePosition;
    FItemStartTime: TDateTime;
    FItemEndTime: TDateTime;
    FItemRealStartTime: TDateTime;
    FItemRealEndTime: TDateTime;
    FAllowOverlap: Boolean;
    FBackGround: Boolean;
    FFont: TFont;
    FLinkedItem: TPlannerItem;
    FLinkType: TPlannerLinkType;
    FIsCurrent: Boolean;
    FBrushStyle: TBrushStyle;
    FCaptionAlign: TAlignment;
    FCaptionBkg: TColor;
    FCaptionBkgTo: TColor;
    FCaptionFont: TFont;
    FCaptionHeight: Integer;
    FSelected: Boolean;
    FSelectColor: TColor;
    FSelectColorTo: TColor;
    FShowSelection: Boolean;
    FShowDeleteButton: Boolean;
    FOwnsItemObject: Boolean;
    FRepainted: Boolean;
    FShape: TPlannerShape;
    FBeginExt: Integer;
    FEndExt: Integer;
    FPopupMenu: TPopupMenu;
    FDBTag: Integer;
    FDBKey: string;
    FLinkedDBKey: string;
    FSynched: Boolean;
    FWordWrap: Boolean;
    FURL: string;
    FEndOffset: Integer;
    FBeginOffset: Integer;
    FChanged: Boolean;
    FDoExport: Boolean;
    FRealTime: Boolean;
    FFlashOn: Boolean;
    FFlashing: Boolean;
    FUniformBkg: Boolean;
    FParentIndex: Integer;
    FCursor: TCursor;
    FClipped: Boolean;
    FRelationShip: TItemRelationShip;
    FNonDBItem: Boolean;
    FShadow: Boolean;
    FTransparent: Boolean;
    FSelectFontColor: TColor;
    FEditor: TCustomItemEditor;
    FPopupEdit: Boolean;
    FDrawTool: TCustomItemDrawTool;
    FCompletion: Integer;
    FCompletionDisplay: TCompletionDisplay;
    FFixedTime: Boolean;
    FRecurrency: string;
    FRecurrent: Boolean;
    FRecurrentStart: TDateTime;
    FRecurrentEnd: TDateTime;
    FRecurrentOrigStart: TDateTime;
    FRecurrentOrigEnd: TDateTime;
    FLinkUpdating: Boolean;
    FShowLinks: Boolean;
    FLinkSelect: Boolean;
    FDesignChange: TNotifyEvent;
    FPreview: boolean;
    {$IFNDEF TMSDOTNET}
    FWideCaption: widestring;
    FWideText: widestring;
    FUnicode: boolean;
    {$ENDIF}
    procedure SetColor(const Value: TColor);
    procedure SetColorTo(const Value: TColor);
    procedure SetBorderColor(const Value: TColor);
    procedure SetTrackColor(const Value: TColor);
    procedure SetTrackSelectColor(const Value: TColor);
    procedure SetLayer(const Value: Integer);
    procedure SetItemEnd(const Value: Integer);
    procedure SetItemBegin(const Value: Integer);
    procedure SetText(const Value: TStringList);
    procedure SetAlignment(const Value: TAlignment);
    procedure SetAllowOverlap(const Value: Boolean);
    procedure SetCaptionType(const Value: TCaptionType);
    procedure SetCaptionText(const Value: string);
    procedure SetImageID(const Value: Integer);
    procedure SetImagePosition(const Value: TItemImagePosition);
    procedure SetIsCurrent(const Value: Boolean); 
    procedure SetItemPos(const Value: Integer);
    procedure SetVisible(const Value: Boolean);
    function GetVisible: Boolean;
    procedure SetFocus(const Value: Boolean);
    procedure SetFont(const Value: TFont);
    procedure SetBackground(const Value: Boolean);
    procedure ReOrganize;
    procedure FontChange(Sender: TObject);
    procedure ImageChange(Sender: TObject);
    procedure TextChange(Sender: TObject);
    procedure SetItemRealEndTime(const Value: TDateTime);
    procedure SetItemRealStartTime(const Value: TDateTime);
    procedure SetBrusStyle(const Value: TBrushStyle);
    procedure SetCaptionAlign(const Value: TAlignment);
    procedure SetCaptionBkg(const Value: TColor);
    procedure SetCaptionBkgTo(const Value: TColor);
    procedure SetCaptionFont(const Value: TFont);
    procedure SetSelectColor(const Value: TColor);
    procedure SetSelectColorTo(const Value: TColor);
    procedure SetSelected(const Value: Boolean);
    procedure SetShadow(const Value: Boolean);
    procedure SetObject(const Value: TObject);
    procedure SetInHeader(const Value: Boolean);
    procedure SetItemBeginPrecis(const Value: Integer);
    procedure SetItemEndPrecis(const Value: Integer);
    procedure SetTrackVisible(const Value: Boolean);
    procedure SetShape(const Value: TPlannerShape);
    procedure SetPopupMenu(const Value: TPopupMenu);
    procedure SetShowSelection(const Value: Boolean);
    procedure SetShowDeleteButton(const Value: Boolean);
    procedure SetTimeTag;
    procedure GetTimeTag;
    function GetItemText: string;
    procedure SetWordWrap(const Value: Boolean);
    procedure SetAttachement(const Value: string);
    function GetItemRealEndTime: TDateTime;
    function GetItemRealStartTime: TDateTime;
    procedure SetURL(const Value: string);
    procedure SetAlarm(const Value: TPlannerAlarm);
    function GetStrippedItemText: string;
    procedure SetFlashing(const Value: Boolean);
    function GetParentItem: TPlannerItem;
    function GetCanEdit: Boolean;
    procedure SetSelectFontColor(const Value: TColor);
    procedure SetDrawTool(const Value: TCustomItemDrawTool);
    procedure SetLinkSelect(const Value: Boolean);    
    procedure SetCompletion(const Value: Integer);
    procedure SetCompletionDisplay(const Value: TCompletionDisplay);
    procedure CompletionAdapt(var R:TRect);
    procedure ImageListAdapt(var R:TRect);
    function GetNotes: string;
    {$IFNDEF TMSDOTNET}
    procedure SetWideText(const Value: widestring);
    procedure SetWideCaption(const Value: widestring);
    procedure SetUnicode(const Value: boolean);
    {$ENDIF}
  protected
{$IFNDEF VER90}
    function GetDisplayName: string; override;
{$ENDIF}
    procedure Repaint; virtual;
    procedure SetItemEndTime(const Value: TDateTime); virtual;
    procedure SetItemStartTime(const Value: TDateTime); virtual;
    function GetItemEndTime: TDateTime; virtual;
    function GetItemStartTime: TDateTime; virtual;
    function GetItemEndTimeStr: string; virtual;
    function GetItemStartTimeStr: string; virtual;
    function GetItemSpanTimeStr: string; virtual;

    procedure UpdateWnd;
    procedure CalcConflictRect(var Rect: TRect; Width, Height: Integer; Position: Boolean);
    property IsCurrent: Boolean read FIsCurrent write SetIsCurrent;
    function GetCaptionHeight: Integer;
    function GetGridRect: TRect;
    function GetItemRect: TRect;
    function GetVisibleSpan: Integer;
    {NEW INTERFACES FOR DESCENDENT CLASSES}
    procedure SetClipped(Value: Boolean);
    procedure SetConflicts(Value: integer);
    procedure SetConflictPos(Value: integer);
    property BeginExt: Integer read FBeginExt write FBeginExt;
    property EndExt: Integer read FEndExt write FEndExt;
    property CaptionHeight: integer read FCaptionHeight write FCaptionHeight;
    property IsPopupEdit: Boolean read FPopupEdit;
    {END OF NEW INTERFACES FOR DESCENDENT CLASSES}
    property LinkUpdating: Boolean read FLinkUpdating write FLinkUpdating;
    procedure SetControlVal(ID,AValue:string);
    function GetControlVal(ID: string): string;
    property LinkSelect: Boolean read FLinkSelect write SetLinkSelect;
    property OnDesignChange: TNotifyEvent read FDesignChange write FDesignChange;
  public
    constructor Create(Collection: TCollection); override;
    destructor Destroy; override;
    procedure Assign(Source: TPersistent); override;
    procedure AssignEx(Source: TPersistent);
    function Planner: TCustomPlanner; virtual;
    procedure Changed; virtual;
    procedure ScrollInView;
    procedure EnsureFullVisibility;
    procedure Edit;
    procedure PopupEdit;
    procedure MoveItem(NewBegin,NewEnd,NewPos: Integer; var NewOffset: Integer);
    procedure SizeItem(NewBegin,NewEnd: Integer);
    procedure DefOrganize;
    procedure Update; virtual;
    procedure ChangeCrossing;
    function SetValue(ID,Value:string): Boolean;
    function GetValue(ID:string;var Value:string): Boolean;
    function GetCaptionTimeString: string; virtual;
    function GetCaptionString: string;
    {$IFNDEF TMSDOTNET}
    function GetWideCaptionString: widestring;
    {$ENDIF}
    property ItemObject: TObject read FObject write SetObject;
    property ID: Integer read FId write FId;
    property BeginOffset: Integer read FBeginOffset write FBeginOffset;
    property EndOffset: Integer read FEndOffset write FEndOffset;
    property Clipped: Boolean read FClipped;
    property Conflicts: Integer read FConflicts;
    property ConflictPos: Integer read FConflictPos;
    property ControlValue[index: string]: string read GetControlVal write SetControlVal;
    property Preview: boolean read FPreview write FPreview;
    property Focus: Boolean read FFocus write SetFocus;
    property ImageIndexList: TPlannerIntList read FImageIndexList write FImageIndexList;
    property ItemBeginPrecis: Integer read FItemBeginPrecis write SetItemBeginPrecis;
    property ItemEndPrecis: Integer read FItemEndPrecis write SetItemEndPrecis;
    property ItemStartTime: TDateTime read GetItemStartTime write SetItemStartTime;
    property ItemEndTime: TDateTime read GetItemEndTime write SetItemEndTime;
    property ItemRealStartTime: TDateTime read GetItemRealStartTime write SetItemRealStartTime;
    property ItemRealEndTime: TDateTime read GetItemRealEndTime write SetItemRealEndTime;
    property ItemStartTimeStr: string read GetItemStartTimeStr;
    property ItemEndTimeStr: string read GetItemEndTimeStr;
    property ItemSpanTimeStr: string read GetItemSpanTimeStr;
    property ItemText: string read GetItemText;
    property StrippedItemText: string read GetStrippedItemText;
    property LinkedItem: TPlannerItem read FLinkedItem write FLinkedItem;
    property LinkType: TPlannerLinkType read FLinkType write FLinkType;
    property Owner: TCustomPlanner read FPlanner;
    property Repainted: Boolean read FRepainted write FRepainted;
    property DBKey: string read FDBKey write FDBKey;
    property LinkedDBKey: string read FLinkedDBKey write FLinkedDBKey;
    property Synched: Boolean read FSynched write FSynched;
    property DoExport: Boolean read FDoExport write FDoExport;
    property RealTime: Boolean read FRealTime write FRealTime;
    property Flashing: Boolean read FFlashing write SetFlashing;
    property FlashOn: Boolean read FFlashOn write FFlashOn;
    property ParentItem: TPlannerItem read GetParentItem;
    property ParentIndex: Integer read FParentIndex write FParentIndex;
    property RelationShip: TItemRelationShip read FRelationShip write FRelationShip;
    property BarItems: TPlannerBarItemList read FBarItems write FBarItems;
    property NotEditable: Boolean read GetCanEdit;
    property NonDBItem: Boolean read FNonDBItem write FNonDBItem;
    property Transparent: Boolean read FTransparent write FTransparent;
    property ItemRect: TRect read GetItemRect;
    property NotesText: string read GetNotes;
    property Recurrency: string read FRecurrency write FRecurrency;
    property Recurrent: Boolean read FRecurrent write FRecurrent;
    property RecurrentEnd: TDateTime read FRecurrentEnd write FRecurrentEnd;
    property RecurrentStart: TDateTime read FRecurrentStart write FRecurrentStart;
    property RecurrentOrigEnd: TDateTime read FRecurrentOrigEnd write FRecurrentOrigEnd;
    property RecurrentOrigStart: TDateTime read FRecurrentOrigStart write FRecurrentOrigStart;
  published
    property Alarm: TPlannerAlarm read FAlarm write SetAlarm;
    property Alignment: TAlignment read FAlignment write SetAlignment default taLeftJustify;
    property AllowOverlap: Boolean read FAllowOverlap write SetAllowOverlap default True;
    property Attachement: string read FAttachement write SetAttachement;
    property Background: Boolean read FBackGround write SetBackground default False;
    property BorderColor: TColor read FBorderColor write SetBorderColor default clSilver;
    property BrushStyle: TBrushStyle read FBrushStyle write SetBrusStyle default bsSolid;
    property CaptionAlign: TAlignment read FCaptionAlign write SetCaptionAlign default taLeftJustify;
    property CaptionBkg: TColor read FCaptionBkg write SetCaptionBkg default clWhite;
    property CaptionBkgTo: TColor read FCaptionBkgTo write SetCaptionBkgTo default clNone;
    property CaptionFont: TFont read FCaptionFont write SetCaptionFont;
    property CaptionType: TCaptionType read FCaptionType write SetCaptionType default ctNone;
    property CaptionText: string read FCaptionText write SetCaptionText;
    property Color: TColor read FColor write SetColor default clWhite;
    property ColorTo: TColor read FColorTo write SetColorTo default clBtnFace;
    property Completion: Integer read FCompletion write SetCompletion default 0;
    property CompletionDisplay: TCompletionDisplay read FCompletionDisplay write SetCompletionDisplay default cdNone;
    property Cursor: TCursor read FCursor write FCursor;
    property DBTag: Integer read FDBTag write FDBTag default 0;
    property DrawTool: TCustomItemDrawTool read FDrawTool write SetDrawTool;
    property EditMask: string read FEditMask write FEditMask;
    property Editor: TCustomItemEditor read FEditor write FEditor;
    property FixedPos: Boolean read FFixedPos write FFixedPos default False;
    property FixedPosition: Boolean read FFixedPosition write FFixedPosition default False;
    property FixedSize: Boolean read FFixedSize write FFixedSize default False;
    property FixedTime: Boolean read FFixedTime write FFixedTime default False;
    property Font: TFont read FFont write SetFont;
    property Hint: string read FHint write FHint;    
    property ImageID: Integer read FImageID write SetImageID default -1;
    property ImagePosition: TItemImagePosition read FImagePosition write SetImagePosition default ipHorizontal;
    property InHeader: Boolean read FInHeader write SetInHeader default False;
    property InplaceEdit: TPlannerItemEdit read FInplaceEdit write FInplaceEdit default peMemo;
    property ItemBegin: Integer read FItemBegin write SetItemBegin;
    property ItemEnd: Integer read FItemEnd write SetItemEnd;
    property ItemPos: Integer read FItemPos write SetItemPos;
    property Layer: Integer read FLayer write SetLayer default 0;
    property Name: string read FName write FName;
    property OnEditModal: TNotifyEvent read FOnEditModal write FOnEditModal; 
    property OwnsItemObject: Boolean read FOwnsItemObject write FOwnsItemObject default False;
    property PopupMenu: TPopupMenu read FPopupMenu write SetPopupMenu;
    property ReadOnly: Boolean read FReadOnly write FReadOnly default False;
    property Shape: TPlannerShape read FShape write SetShape default psRect;
    property ShowSelection: Boolean read FShowSelection write SetShowSelection default True;
    property ShowDeleteButton: Boolean read FShowDeleteButton write SetShowDeleteButton default False;
    property SelectColor: TColor read FSelectColor write SetSelectColor default clInfoBk;
    property SelectColorTo: TColor read FSelectColorTo write SetSelectColorTo default clNone;
    property SelectFontColor: TColor read FSelectFontColor write SetSelectFontColor default clRed;
    property Selected: Boolean read FSelected write SetSelected default False;
    property Shadow: Boolean read FShadow write SetShadow;
    property ShowLinks: Boolean read FShowLinks write FShowLinks default false;
    property Tag: Integer read FTag write FTag default 0;
    property Text: TStringList read FText write SetText;
    property TrackColor: TColor read FTrackColor write SetTrackColor default clBlue;
    property TrackLinkColor: TColor read FTrackLinkColor write FTrackLinkColor default clRed;
    property TrackSelectColor: TColor read FTrackSelectColor write SetTrackSelectColor default clBlue;
    property TrackVisible: Boolean read FTrackVisible write SetTrackVisible default True;
    property UniformBkg: Boolean read FUniformBkg write FUniformBkg default True;
    property URL: string read FURL write SetURL;
    property Visible: Boolean read GetVisible write SetVisible default True;
    {$IFNDEF TMSDOTNET}
    property WideCaption: widestring read FWideCaption write SetWideCaption;
    property WideText: widestring read FWideText write SetWideText;
    property Unicode: boolean read FUnicode write SetUnicode default False;
    {$ENDIF}
    property WordWrap: Boolean read FWordWrap write SetWordWrap default True;
  end;

  { TPlannerItems }

  TPlannerItems = class(TCollection)
  private
    FOwner: TCustomPlanner;
    FSelected: TPlannerItem;
    FDBItem: TPlannerItem;
    FUpdateCount: Integer;
    FFindIndex: Integer;
    FChanging: Boolean;
    function GetItem(Index: Integer): TPlannerItem;
    procedure SetItem(Index: Integer; Value: TPlannerItem);
    function NumConflicts(var ItemBegin, ItemEnd: Integer; ItemPos: Integer): Integer;
    function GetSelCount: Integer;
  protected
{$IFNDEF VER90}
    function GetOwner: TPersistent; override;
{$ENDIF}
    procedure ClearSelectedRepaints(ItemBegin,ItemPos: Integer);
    function NumItem(ItemBegin, ItemEnd, ItemPos: Integer): TPoint;
    function NumItemPos(ItemBegin, ItemEnd, ItemPos: Integer): TPoint;
    function NumItemPosStart(ItemBegin, ItemPos: Integer): Integer;
    function FindItem(ItemBegin, ItemPos: Integer): TPlannerItem;
    function FindItemIdx(ItemBegin: Integer): TPlannerItem;
    function FindItemPos(ItemBegin, ItemPos, ItemSubPos: Integer): TPlannerItem;
    function FindBkgPos(ItemBegin, ItemPos, ItemSubPos: Integer): TPlannerItem;
    function FindItemPosIdx(
      ItemBegin, ItemPos, ItemSubPos: Integer): TPlannerItem;
    function FindItemIndex(
      ItemBegin, ItemPos, ItemSubIdx: Integer): TPlannerItem;
    function FindBackground(ItemBegin, ItemPos: Integer): TPlannerItem;
    function QueryItem(Item: TPlannerItem;
      ItemBegin, ItemPos: Integer): TPlannerItem;
    function FocusItem(ItemBegin, ItemPos, ItemSubPos: Integer;
      Control: Boolean): TPlannerItem;
    procedure SetCurrent(ItemCurrent: Integer);
    procedure PasteItem(Position: Boolean; Size: Boolean);
    procedure ClearRepaints;
    procedure SetTimeTags;
    procedure GetTimeTags;
    function MatchItem(Item:TPlannerItem; s:string; Param:TFindTextParams): Boolean;
    function MaxItemsInPos(Position: Integer):Integer;
    procedure MoveLinks(APlannerItem: TPlannerItem);
    procedure SizeLinks(APlannerItem: TPlannerItem);
    procedure UpdateLinks(APlannerItem: TPlannerItem);
    procedure ClearLinks;
  public
    function GetItemClass: TCollectionItemClass; virtual;
    {$IFNDEF TMSDOTNET}
    constructor Create(AOwner: TCustomPlanner);
    {$ENDIF}
    {$IFDEF TMSDOTNET}
    constructor Create(AOwner: TCustomPlanner; AItemClass: TCollectionItemClass);
    {$ENDIF}
    function CheckItems: Boolean;
    function CheckPosition(Position: Integer): Boolean;
    function CheckLayer(Layer: Integer): Boolean;
    function CheckItem(Item: TPlannerItem): Boolean;
    function HasItem(ItemBegin, ItemEnd, ItemPos: Integer): Boolean;
    function FindFirst(ItemBegin, ItemEnd, ItemPos: Integer): TPlannerItem;
    function FindNext(ItemBegin, ItemEnd, ItemPos: Integer): TPlannerItem;
    function FindKey(DBKey: string): TPlannerItem;
    function HeaderFirst(ItemPos: Integer): TPlannerItem;
    function HeaderNext(ItemPos: Integer): TPlannerItem;
    function FindText(StartItem:TPlannerItem;s: string; Param: TFindTextParams):TPlannerItem;
    function Add: TPlannerItem;
    function Insert(Index: Integer): TPlannerItem;
    property Items[Index: Integer]: TPlannerItem read GetItem write SetItem; default;
    function SelectNext: TPlannerItem;
    function SelectPrev: TPlannerItem;
    procedure UnSelect;
    procedure UnSelectAll;
    procedure Select(Item: TPlannerItem);
    property Selected: TPlannerItem read FSelected write FSelected;
    property DBItem: TPlannerItem read FDBItem write FDBItem;
    function InVisibleLayer(Layer: Integer): Boolean;
    procedure ClearConflicts;
    procedure SetConflicts; virtual;
    procedure ItemChanged(Item: TPlannerItem);
    function ItemsAtPosition(Pos: Integer): Integer;
    function ItemsAtIndex(Idx: Integer): Integer;
    function ItemsAtCell(ItemBegin, ItemEnd, ItemPos: Integer): Integer;
    procedure ResolveLinks; virtual;
    procedure BeginUpdate;
{$IFDEF DELPHI4_LVL} override;
{$ENDIF}
    procedure EndUpdate;
{$IFDEF DELPHI4_LVL} override;
{$ENDIF}
    procedure ResetUpdate;
    procedure ClearPosition(Position: Integer);
    procedure ClearLayer(Layer: Integer);
    procedure ClearAll;
    procedure ClearDB;
    procedure CopyToClipboard;
    procedure CutToClipboard;
    procedure PasteFromClipboard;
    procedure PasteFromClipboardAtPos;
    procedure PasteFromClipboardAtXY;
    procedure OffsetItems(Offset: Integer);
    procedure MoveAll(DeltaPos, DeltaBegin: Integer);
    procedure MoveSelected(DeltaPos, DeltaBegin: Integer);
    procedure SizeAll(DeltaStart, DeltaEnd: Integer);
    procedure SizeSelected(DeltaStart, DeltaEnd: Integer);
    property Changing: Boolean read FChanging write FChanging;
  published
    property SelCount: Integer read GetSelCount;
    property UpdateCount: integer read FUpdateCount;
  end;

  { TPositionProp }

  TPositionProp = class(TCollectionItem)
  private
    FActiveStart: Integer;
    FActiveEnd: Integer;
    FColorNonActive: TColor;
    FColorActive: TColor;
    FMinSelection: Integer;
    FMaxSelection: Integer;
    FBrushNoSelect: TBrushStyle;
    FColorNoSelect: TColor;
    FBackground: TBitmap;
    FUse: Boolean;
    FShowGap: Boolean;
    procedure SetActiveEnd(const Value: Integer);
    procedure SetActiveStart(const Value: Integer);
    procedure SetColorActive(const Value: TColor);
    procedure SetColorNonActive(const Value: TColor);
    procedure SetMaxSelection(const Value: Integer);
    procedure SetMinSelection(const Value: Integer);
    procedure SetBrushNoSelect(const Value: TBrushStyle);
    procedure SetColorNoSelect(const Value: TColor);
    procedure SetBackground(const Value: TBitmap);
    procedure SetUse(const Value: Boolean);
    procedure BackgroundChanged(Sender: TObject);
    procedure SetShowGap(const Value: Boolean);
  public
    constructor Create(Collection: TCollection); override;
    destructor Destroy; override;
    procedure Assign(Source: TPersistent); override;
  published
    property ActiveStart: Integer read FActiveStart write SetActiveStart;
    property ActiveEnd: Integer read FActiveEnd write SetActiveEnd;
    property Background: TBitmap read FBackground write SetBackground;
    property ColorActive: TColor read FColorActive write SetColorActive;
    property ColorNonActive: TColor read FColorNonActive write SetColorNonActive;
    property MinSelection: Integer read FMinSelection write SetMinSelection;
    property MaxSelection: Integer read FMaxSelection write SetMaxSelection;
    property ColorNoSelect: TColor read FColorNoSelect write SetColorNoSelect;
    property BrushNoSelect: TBrushStyle read FBrushNoSelect write SetBrushNoSelect;
    property Use: Boolean read FUse write SetUse default True;
    property ShowGap: Boolean read FShowGap write SetShowGap default True;
  end;

  TPositionProps = class(TCollection)
  private
    FOwner: TCustomPlanner;
    function GetItem(Index: Integer): TPositionProp;
    procedure SetItem(Index: Integer; const Value: TPositionProp);
  protected
{$IFNDEF VER90}
    function GetOwner: TPersistent; override;
{$ENDIF}
  public
    constructor Create(AOwner: TCustomPlanner);
    function Add: TPositionProp;
    function Insert(Index: Integer): TPositionProp;
    property Items[Index: Integer]: TPositionProp read GetItem write SetItem; default;
  end;

  TPlannerScrollStyle = (ssNormal,ssFlat,ssEncarta);

  TPlannerScrollBar = class(TPersistent)
  private
    FOwner: TCustomPlanner;
    FFlat: Boolean;
    FWidth: Integer;
    FColor: TColor;
    FStyle: TPlannerScrollStyle;
    procedure SetColor(const Value: TColor);
    procedure SetFlat(const Value: Boolean);
    procedure SetStyle(const Value: TPlannerScrollStyle);
    procedure SetWidth(const Value: Integer);
  public
    constructor Create(AOwner: TCustomPlanner);
    procedure UpdateProps;
  published
    property Color: TColor read FColor write SetColor default clNone;
    property Flat: Boolean read FFlat write SetFlat default False;
    property Style: TPlannerScrollStyle read FStyle write SetStyle default ssNormal;
    property Width: Integer read FWidth write SetWidth default 16;
  end;

  TBackgroundDisplay = (bdTile,bdFixed);

  TBackground = class(TPersistent)
  private
    FPlanner: TCustomPlanner;
    FTop: Integer;
    FLeft: Integer;
    FDisplay: TBackgroundDisplay;
    procedure SetBitmap(Value: TBitmap);
    procedure SetTop(Value: Integer);
    procedure SetLeft(Value: Integer);
    procedure SetDisplay(Value: TBackgroundDisplay);
    procedure BackgroundChanged(Sender: TObject);
  private
    FBitmap: TBitmap;
  public
    constructor Create(APlanner: TCustomPlanner);
    destructor Destroy; override;
    property Display: TBackgroundDisplay read FDisplay write SetDisplay;
    property Top: Integer read FTop write SetTop;
    property Left: Integer read FLeft write SetLeft;
  published
    property Bitmap: TBitmap read FBitmap write SetBitmap;
  end;

  TActiveCellShow = (assNone, assCol, assRow);

  TPlannerGrid = class(TCustomGrid)
  private
    { Private declarations }
    FActiveCellShow: TActiveCellShow;
    FLastHintPos: TPoint;
    FLastHintItem: TPlannerItem;
    FToolTipPos: TPoint;
    FLastDesignChoice: Integer;    
    FUpdateCount: Integer;
    FPlanner: TCustomPlanner;
    {$IFNDEF TMSDOTNET}
    {$IFNDEF DELPHI_UNICODE}
    FUniMemo: TPlannerUniMemo;
    {$ENDIF}
    {$ENDIF}
    FMemo: TPlannerMemo;
    FMaskEdit: TPlannerMaskEdit;
    FMouseDown: Boolean;
    FMouseUnSelect: Boolean;
    FMouseDownMove: Boolean;
    FMouseDownSizeUp: Boolean;
    FMouseDownSizeDown: Boolean;
    FMouseDownMoveFirst: Boolean;
    FMouseStart: Boolean;
    FMouseXY: TPoint;
    FMouseRCD, FMouseRC: TGridCoord;
    FColorList: TPlannerColorArrayList;
    FScrollHintWindow: THintWindow;
    FItemXY: TPoint;
    FItemXYS: TRect;
    FEraseBkGnd: Boolean;
    FSelItem: TPlannerItem;
    FOldSelection, FHiddenSelection: TGridRect;
    FOldTopRow: Integer;
    FOldLeftCol: Integer;
    FScrolling: Boolean;
    FMouseRelease: Boolean;
    FScrollTime: Cardinal;
    FCurrCtrlR: TRect;
    FCurrCtrlID: string;
    FCurrCtrlItem: TPlannerItem;
    FCurrCtrlEdit: string;
    FPosResizing: Boolean;
    FInplaceEdit: TEdit;
    FInplaceCombo: TPlanCombobox;
    FHToolTip: THandle;
    FToolTipBuffer: array[0..4096] of char;
    procedure WMPaint(var Message: TWMPaint); message WM_PAINT;
    {$IFNDEF TMSDOTNET}
    procedure WMNotify(var Message: TWMNOTIFY); message WM_NOTIFY;
    {$ENDIF}
    {$IFDEF TMSDOTNET}
    procedure WMNotify(var Message: TWMNOTIFYTT); message WM_NOTIFY;
    {$ENDIF}
    procedure WMVScroll(var WMScroll: TWMScroll); message WM_VSCROLL;
    procedure WMHScroll(var WMScroll:TWMScroll ); message WM_HSCROLL;
    procedure WMLButtonDblClk(var Message: TWMLButtonDblClk); message WM_LBUTTONDBLCLK;
    procedure WMLButtonDown(var Message: TWMLButtonDown); message WM_LBUTTONDOWN;
    procedure WMEraseBkGnd(var Message: TWMEraseBkgnd); message WM_ERASEBKGND;
    procedure CNKeyDown(var Message: TWMKeydown); message CN_KEYDOWN;
    procedure CMDesignHitTest(var Msg: TCMDesignHitTest); message CM_DESIGNHITTEST;
    {$IFNDEF TMSDOTNET}
    procedure WMSetCursor(var Msg: TWMSetCursor); message WM_SETCURSOR;
    {$ENDIF}
    {$IFDEF TMSDOTNET}
    procedure CMHintShow(var Message: TCMHintShow); message CM_HINTSHOW;
    {$ENDIF}
    {$IFNDEF TMSDOTNET}
    procedure CMHintShow(var Message: TMessage); message CM_HINTSHOW;
    {$ENDIF}
    procedure RTFPaint(ACanvas: TCanvas; ARect: TRect; const rtf: string; Background: TColor);
    {$IFNDEF DELPHI4_LVL}
    procedure WMSize(var WMSize: TWMSize); message WM_SIZE;
    {$ENDIF}
    procedure UpdatePositions;
    procedure StartEditCol(ARect: TRect; APlannerItem: TPlannerItem;
      X, Y: Integer);
    procedure StartEditRow(ARect: TRect; APlannerItem: TPlannerItem;
      X, Y: Integer);
    procedure PaintItemCol(Canvas: TCanvas; ARect: TRect;
      APlannerItem: TPlannerItem; Print, SelColor: Boolean); virtual;
    procedure PaintItemRow(Canvas: TCanvas; ARect: TRect;
      APlannerItem: TPlannerItem; Print, SelColor: Boolean);
    procedure PaintSideCol(Canvas: TCanvas; ARect: TRect;
      ARow, APos, Offs: Integer; Occupied, Print: Boolean); virtual;
    procedure PaintSideRow(Canvas: TCanvas; ARect: TRect; AColumn, APos: Integer;
      Occupied,Print: Boolean; DefColWidth: integer);
    procedure GetSideBarLines(Index, Position: Integer; var Line1, Line2, Line3: string; var HS: Boolean);
    procedure DrawWallPaperFixed(CRect: TRect;xcorr,ycorr: Integer;BKColor:TColor);
    procedure DrawWallPaperTile(ACol,ARow:integer;CRect: TRect;xcorr,ycorr: Integer;BKColor:TColor);
    procedure DrawCellCol(AColumn, ARow: LongInt; ARect: TRect;
      AState: TGridDrawState);
    procedure DrawCellRow(AColumn, ARow: LongInt; ARect: TRect;
      AState: TGridDrawState);
    procedure SetEditDirectSelection(ARect: TRect; X, Y: Integer);
    function CellRectEx(X, Y: Integer):TRect;
    function ColWidthEx(ItemPos: Integer): Integer;
    function RowHeightEx(ItemPos: Integer): Integer;
    procedure SetActiveCellShow(AValue: TActiveCellShow);
    procedure UpdateNVI;
    function MouseOverDesignChoice(X, Y: Integer): Integer;
  protected
    { Protected declarations }
    procedure DrawCell(AColumn, ARow: LongInt; ARect: TRect;
      AState: TGridDrawState); override;
    procedure HintShowXY(X, Y: Integer; Caption: TCaption);
    procedure HintHide;
    procedure Loaded; override;
    {$IFDEF DELPHI4_LVL}
    procedure Resize; override;
    {$ENDIF}
    procedure DestroyWnd; override;
    procedure KeyPress(var Key: Char); override;
    procedure KeyDown(var Key: Word; ShiftState: TShiftState); override;
    procedure KeyUp(var Key: Word; ShiftState: TShiftState); override;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure TopLeftChanged; override;
    function GetHScrollSize: Integer;
    function GetVScrollSize: Integer;
    property RowCount;
    procedure DoEnter; override;
    procedure DoExit; override;
    property ColorList: TPlannerColorArrayList read FColorList write FColorList;
    procedure DragOver(Source: TObject; X, Y: Integer; State: TDragState;
      var Accept: Boolean); override;
    procedure RepaintSelection(ASelection: TGridRect);
    procedure SelChanged;
    function SelectCell(AColumn, ARow: LongInt): Boolean; override;
    procedure MouseToCell(X, Y: Integer; var ACol, ARow: Longint);
    procedure RepaintRect(r:TRect);
    procedure InvalidateCellRect(r:TRect);
    procedure ChangeSelection(x,y,dx,dy: Integer);
    procedure CorrectSelection;
    procedure UpdateVScrollBar;
    procedure UpdateHScrollBar;
    procedure FlatSetScrollInfo(Code: Integer; var ScrollInfo:TScrollInfo; FRedraw: Bool);
    procedure FlatSetScrollProp(Index,NewValue: Integer; FRedraw:bool);
    procedure FlatShowScrollBar(Code: Integer;Show:bool);
    procedure FlatScrollInit;
    procedure FlatScrollDone;
    procedure FormHandle(Item: TPlannerItem; ControlRect: TRect; ControlID,ControlType,ControlValue: string);
    procedure FormExit(Sender: TObject);
    {$IFDEF DELPHI5_LVL}
    function DoMouseWheelDown(Shift: TShiftState; MousePos: TPoint): Boolean; override;
    function DoMouseWheelUp(Shift: TShiftState; MousePos: TPoint): Boolean; override;
    {$ENDIF}
    procedure Paint; override;
  public
    { Public declarations }
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure CreateWnd; override;
    procedure CreateToolTip;
    procedure AddToolTip(IconType: Integer; Text, Title: string);
    procedure DestroyToolTip;
    procedure DragDrop(Source: TObject; X, Y: Integer); override;
    procedure HideSelection;
    procedure UnHideSelection;
    procedure BeginUpdate;
    procedure EndUpdate;
    property Canvas;
    property Col;
    property Ctl3D;
    property EditorMode;
    property GridHeight;
    property GridWidth;
    property LeftCol;
    property Selection;
    property Row;
    property TabStops;
    property TopRow;

    property Options;
    property ColCount;
    property ColWidths;
    property RowHeights;
    property FixedRows;
    property FixedCols;
    property VisibleColCount;
    property VisibleRowCount;
    property BorderStyle;
    property DefaultRowHeight;
    property DefaultColWidth;
    {$IFDEF TMSDOTNET}
    procedure InvalidateColP(Avalue: Integer);
    procedure InvalidateRowP(Avalue: Integer);
    function CellRectP(X,Y: Integer): TRect;
    procedure InvalidateCellP(X,Y: Integer);
    {$ENDIF}
    property MouseRelease: Boolean read FMouseRelease write FMouseRelease;
    property HToolTip: THandle read FHToolTip write FHToolTip;
  published
    { Published declarations }
    property ActiveCellShow: TActiveCellShow read FActiveCellShow write SetActiveCellShow;
    property ScrollBars;
    property OnMouseMove;
    property OnMouseDown;
    property OnMouseUp;
    property OnKeyDown;
    property OnKeyUp;
    property OnKeyPress;
  end;

  THourType = (ht24hrs, ht12hrs, htAMPM0, htAMPM1, htAMPMOnce);

  TInplaceEditType = (ieAlways, ieNever);

  THeaderOrientation = (hoHorizontal, hoVertical);

  THeaderClickEvent = procedure(Sender: TObject; SectionIndex: Integer) of object;
  THeaderHintEvent = procedure(Sender: TObject; SectionIndex: Integer;var AHint: string) of object;
  TSidebarHintEvent = procedure(Sender: TObject; Index: Integer;var AHint: string) of object;  
  
  THeaderDragDropEvent = procedure(Sender: TObject;
    FromSection, ToSection: Integer) of object;

  THeaderEditEvent = procedure(Sender: TObject; SectionIndex: Integer; var Text:string) of object;

  TAdvHeader = class(THeader)
  private
    FOffset: Integer;
    FLeftPos: Integer;
    FAlignment: TAlignment;
    FAllowSizing: Boolean;
    FVAlignment: TVAlignment;
    FColor: TColor;
    FLineColor: TColor;
    FFlat: Boolean;
    FImageList: TImageList;
    FInplaceEdit: TMemo;
    FImagePosition: TImagePosition;
    FOnClick: THeaderClickEvent;
    FOnRightClick: THeaderClickEvent;
    FOnDragDrop: THeaderDragDropEvent;
    FOrientation: THeaderOrientation;
    FSectionDragDrop: Boolean;
    FDragging: Boolean;
    FDragStart: Integer;
    FEditSection: Integer;
    FEditWidth: Integer;
    FOnSectionEditEnd: THeaderClickEvent;
    FOnSectionEditStart: THeaderClickEvent;
    FSectionEdit: Boolean;
    FItemHeight: Integer;
    FTextHeight: Integer;
    FOnDblClick: THeaderClickEvent;
    FShowFixed: Boolean;
    FFixedHeight: Integer;
    FFixedColor: TColor;
    FZoomCol: Integer;
    FZoom: Boolean;
    FLastHintPos: TPoint;
    FColorTo: TColor;
    FRotate: Boolean;
    FSizing: Boolean;
    FHitTest: TPoint;
    FCanResize: Boolean;
    FResizeSection: Integer;
    FMouseOffset: Integer;
    FMouseDownMove: Boolean;
    FDragItem: TPlannerItem;
    FOldAnchor: string;
    FAnchorItem: TPlannerItem;
    FhToolTip: THandle;
    FBalloonItem: TPlannerItem;
    FOnHeaderHint: THeaderHintEvent;
    FToolTipBuffer: array[0..4096] of char;
    procedure SetAlignment(const Value: TAlignment);
    procedure SetColor(const Value: TColor);
    procedure SetImageList(const Value: TImageList);
    procedure SetImagePosition(const Value: TImagePosition);
    {$IFDEF TMSDOTNET}
    procedure CMHintShow(var Message: TCMHintShow); message CM_HINTSHOW;
    {$ENDIF}
    {$IFNDEF TMSDOTNET}
    procedure CMHintShow(var Message: TMessage); message CM_HINTSHOW;
    {$ENDIF}
    procedure WMLButtonDown(var Msg:TWMLButtonDown); message WM_LBUTTONDOWN;
    procedure WMLButtonDblClk(var Message: TWMLButtonDblClk); message WM_LBUTTONDBLCLK;
    procedure WMSize(var Msg: TWMSize); message WM_SIZE;
    {$IFNDEF TMSDOTNET}
    procedure WMNCHitTest(var Msg: TWMNCHitTest); message WM_NCHITTEST;
    procedure WMSetCursor(var Msg: TWMSetCursor); message WM_SETCURSOR;
    {$ENDIF}
    {$IFNDEF TMSDOTNET}
    procedure WMNotify(var Message: TWMNOTIFY); message WM_NOTIFY;
    {$ENDIF}
    {$IFDEF TMSDOTNET}
    procedure WMNotify(var Message: TWMNOTIFYTT); message WM_NOTIFY;
    {$ENDIF}
    procedure SetOrientation(const Value: THeaderOrientation);
    procedure SetFlat(const Value: Boolean);
    procedure SetLineColor(const Value: TColor);
    procedure SetVAlignment(const Value: TVAlignment);
    procedure InplaceExit(Sender: TObject);
    procedure SetItemHeight(const Value: Integer);
    procedure SetTextHeight(const Value: Integer);
    procedure SetFixedColor(const Value: TColor);
    procedure SetFixedHeight(const Value: Integer);
    procedure SetShowFixed(const Value: Boolean);
    procedure SetColorTo(const Value: TColor);
    procedure SetRotate(const Value: Boolean);
//    function IsAnchor(x,y: Integer): string;
  protected
    function XYToSection(X, Y: Integer): Integer; virtual;
    function GetSectionRect(X: Integer): TRect; virtual;
    function GetSectionIdx(X: Integer): Integer; virtual;
    procedure StartEdit(ARect: TRect; APlannerItem: TPlannerItem; X, Y:Integer); virtual;
    procedure StopEdit;
    procedure Paint; override;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure DragOver(Source: TObject; X, Y: Integer; State: TDragState;
      var Accept: Boolean); override;
    procedure CreateToolTip;
    procedure AddToolTip(IconType: Integer; Text, Title: string);
    procedure DestroyToolTip;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    function ItemAtXY(X, Y: Integer;var ARect: TRect): TPlannerItem;
    procedure DragDrop(Source: TObject; X, Y: Integer); override;
  published
    property Alignment: TAlignment read FAlignment write SetAlignment;
    property AllowSizing: Boolean read FAllowSizing write FAllowSizing;
    property Color: TColor read FColor write SetColor;
    property ColorTo: TColor read FColorTo write SetColorTo;
    property Flat: Boolean read FFlat write SetFlat;
    property FixedColor: TColor read FFixedColor write SetFixedColor;
    property FixedHeight: Integer read FFixedHeight write SetFixedHeight;
    property ShowFixed: Boolean read FShowFixed write SetShowFixed;
    property Images: TImageList read FImageList write SetImageList;
    property ImagePosition: TImagePosition read FImagePosition write SetImagePosition;
    property ItemHeight: Integer read FItemHeight write SetItemHeight;
    property TextHeight: Integer read FTextHeight write SetTextHeight;
    property LineColor: TColor read FLineColor write SetLineColor default clGray;
    property SectionDragDrop: Boolean read FSectionDragDrop write FSectionDragDrop;
    property SectionEdit: Boolean read FSectionEdit write FSectionEdit;
    property VAlignment: TVAlignment read FVAlignment write SetVAlignment;
    property Rotate: Boolean read FRotate write SetRotate;
    property Zoom: Boolean read FZoom write FZoom;
    property ZoomCol: Integer read FZoomCol write FZoomCol;
    property Orientation: THeaderOrientation read FOrientation write SetOrientation default hoHorizontal;
    property OnClick: THeaderClickEvent read FOnClick write FOnClick;
    property OnRightClick: THeaderClickEvent read FOnRightClick write FOnRightClick;
    property OnDblClick: THeaderClickEvent read FOnDblClick write FOnDblClick;
    property OnDragDrop: THeaderDragDropEvent read FOnDragDrop write FOnDragDrop;
    property OnSectionEditStart: THeaderClickEvent read FOnSectionEditStart write FOnSectionEditStart;
    property OnSectionEditEnd: THeaderClickEvent read FOnSectionEditEnd write FOnSectionEditEnd;
    property OnHeaderHint: THeaderHintEvent read FOnHeaderHint write FOnHeaderHint;
    property OnMouseMove;
    property OnMouseDown;
    property OnMouseUp;
  end;

  TAdvFooter = class(TAdvHeader)
  private
    FUpdateCount: Integer;
  protected
    procedure Paint; override;
  public
    constructor Create(AOwner: TComponent); override;
    procedure BeginUpdate;
    procedure EndUpdate;
  end;

  TPlannerPrintOptions = class(TPersistent)
  private
    FFooterSize: Integer;
    FLeftMargin: Integer;
    FRightMargin: Integer;
    FHeaderSize: Integer;
    FHeaderFont: TFont;
    FFooterFont: TFont;
    FOrientation: TPrinterOrientation;
    FFooter: TStrings;
    FHeader: TStrings;
    FHeaderAlignment: TAlignment;
    FFooterAlignment: TAlignment;
    FFitToPage: Boolean;
    FJobname: string;
    FCellHeight: Integer;
    FCellWidth: Integer;
    FSidebarWidth: Integer;
    FLineWidth: integer;
    procedure SetFooter(const Value: TStrings);
    procedure SetFooterFont(const Value: TFont);
    procedure SetHeader(const Value: TStrings);
    procedure SetHeaderFont(const Value: TFont);
  public
    constructor Create;
    destructor Destroy; override;
    procedure Assign(Source: TPersistent); override;
  published
    property CellHeight: Integer read FCellHeight write FCellHeight default 0;
    property CellWidth: Integer read FCellWidth write FCellWidth default 0;
    property LineWidth: Integer read FLineWidth write FLineWidth default 1;
    property FitToPage: Boolean read FFitToPage write FFitToPage default True;
    property Footer: TStrings read FFooter write SetFooter;
    property FooterAlignment: TAlignment read FFooterAlignment write FFooterAlignment default taLeftJustify;
    property FooterFont: TFont read FFooterFont write SetFooterFont;
    property FooterSize: Integer read FFooterSize write FFooterSize default 0;
    property Header: TStrings read FHeader write SetHeader;
    property HeaderAlignment: TAlignment read FHeaderAlignment write FHeaderAlignment default taLeftJustify;
    property HeaderFont: TFont read FHeaderFont write SetHeaderFont;
    property HeaderSize: Integer read FHeaderSize write FHeaderSize default 0;
    property JobName: string read FJobname write FJobname;
    property LeftMargin: Integer read FLeftMargin write FLeftMargin default 0;
    property Orientation: TPrinterOrientation read FOrientation write FOrientation default poPortrait;
    property RightMargin: Integer read FRightMargin write FRightMargin default 0;
    property SidebarWidth: Integer read FSidebarWidth write FSidebarWidth default 0;
  end;

  TPlannerHTMLOptions = class(TPersistent)
  private
    FFooterFile: string;
    FHeaderFile: string;
    FBorderSize: Integer;
    FCellSpacing: Integer;
    FTableStyle: string;
    FPrefixTag: string;
    FSuffixTag: string;
    FWidth: Integer;
    FSidebarFontTag: string;
    FHeaderFontTag: string;
    FCellFontTag: string;
    FCellFontStyle: TFontStyles;
    FHeaderFontStyle: TFontStyles;
    FSidebarFontStyle: TFontStyles;
    FShowCaption: Boolean;
  public
    constructor Create;
  published
    property BorderSize: Integer read FBorderSize write FBorderSize default 1;
    property CellSpacing: Integer read FCellSpacing write FCellSpacing default 0;
    property FooterFile: string read FFooterFile write FFooterFile;
    property HeaderFile: string read FHeaderFile write FHeaderFile;
    property TableStyle: string read FTableStyle write FTableStyle;
    property PrefixTag: string read FPrefixTag write FPrefixTag;
    property SuffixTag: string read FSuffixTag write FSuffixTag;
    property Width: Integer read FWidth write FWidth default 100;
    property CellFontTag: string read FCellFontTag write FCellFontTag;
    property CellFontStyle: TFontStyles read FCellFontStyle write FCellFontStyle;
    property HeaderFontTag: string read FHeaderFontTag write FHeaderFontTag;
    property HeaderFontStyle: TFontStyles read FHeaderFontStyle write FHeaderFontStyle;
    property SidebarFontTag: string read FSidebarFontTag write FSidebarFontTag;
    property SidebarFontStyle: TFontStyles read FSidebarFontStyle write FSidebarFontStyle;
    property ShowCaption: Boolean read FShowCaption write FShowCaption default False;
  end;

  TDragOverItemEvent = procedure(Sender, Source: TObject; X, Y: Integer;
    APlannerItem: TPlannerItem; State: TDragState; var Accept: Boolean) of object;

  TDragDropItemEvent = procedure(Sender, Source: TObject; X, Y: Integer;
    PlannerItem: TPlannerItem) of object;

  TWeekDays = class(TPersistent)
  private
    FSat: Boolean;
    FSun: Boolean;
    FMon: Boolean;
    FTue: Boolean;
    FWed: Boolean;
    FThu: Boolean;
    FFri: Boolean;
    FChanged: TNotifyEvent;
    procedure SetSat(const Value: Boolean);
    procedure SetSun(const Value: Boolean);
    procedure SetMon(const Value: Boolean);
    procedure SetTue(const Value: Boolean);
    procedure SetWed(const Value: Boolean);
    procedure SetThu(const Value: Boolean);
    procedure SetFri(const Value: Boolean);
    procedure Changed;
  public
    constructor Create;
  published
    property Sat: Boolean read FSat write SetSat default True;
    property Sun: Boolean read FSun write SetSun default True;
    property Mon: Boolean read FMon write SetMon default False;
    property Tue: Boolean read FTue write SetTue default False;
    property Wed: Boolean read FWed write SetWed default False;
    property Thu: Boolean read FThu write SetThu default False;
    property Fri: Boolean read FFri write SetFri default False;
    property OnChanged: TNotifyEvent read FChanged write FChanged;
  end;

  TByteSet = set of Byte;

  TButtonDirection = (bdLeft,bdRight);

  TAdvSpeedButton = class(TSpeedButton)
  private
    FButtonDirection: TButtonDirection;
    FIsWinXP: Boolean;
    procedure CMMouseLeave(var Message: TMessage); message CM_MOUSELEAVE;
    procedure CMMouseEnter(var Message: TMessage); message CM_MOUSEENTER;
  protected
    procedure Paint; override;
  public
    constructor Create(AOwner: TComponent); override;
  published
    property Direction: TButtonDirection read FButtonDirection write FButtonDirection;
  end;

  TPlannerExChange = class(TComponent)
  private
    FPlanner: TCustomPlanner;
  protected
    procedure Notification(AComponent: TComponent; AOperation: TOperation); override;
  public
    function NumItemsForExport: Integer;
    procedure DoExport; virtual;
    procedure DoImport; virtual;
  published
    property Planner: TCustomPlanner read FPlanner write FPlanner;
  end;

  TPlannerUserMode = (puNormal, puReadOnly, puViewOnly);

  TPlannerWheelAction = (pwaSelect, pwaScroll);


  {$IFDEF TMSDOTNET}
  //[System.ComponentModel.DesignerCategory('Code')]
  {$ENDIF}
  TCustomPlanner = class(TCustomControl, ITMSStyle)
  private
    { Private declarations }
    FHTMLFactor: Double;
    FRichEdit: TPlannerRichEdit;
    FBalloon: TBalloonSettings;
    FDownOnItem: Boolean;
    FActiveDisplay: Boolean;
    FBands: TBands;
    FOverlap: Boolean;
    FColor: TColor;
    FLayer: Integer;
    FEditRTF: Boolean;
    FEditDirect: Boolean;
    FEditScroll: TScrollStyle;
    FTrackColor: TColor;
    FTrackOnly: Boolean;
    FTrackProportional: Boolean;
    FTrackWidth: Integer;
    FFont: TFont;
    FGrid: TPlannerGrid;
    FGridPopup: TPopupmenu;
    FGridLineColor: TColor;
    FItemPopup: TPopupmenu;
    FPopupPlannerItem: TPlannerItem;
    FHeader: TAdvHeader;
    FFooter: TAdvFooter;
    FHintOnItemChange: Boolean;
    FHintColor: TColor;
    FHintPause: Integer;
    FItemGap: Integer;
    FNext: TAdvSpeedButton;
    FPrev: TAdvSpeedButton;
    FMode: TPlannerMode;
    FCaption: TPlannerCaption;
    FSidebar: TPlannerSideBar;
    FDisplay: TPlannerDisplay;
    FDayNames: TStringList;
    FHourType: THourType;
    FPlannerHeader: TPlannerHeader;
    FPlannerFooter: TPlannerFooter;
    FPlannerItems: TPlannerItems;
    FPlannerImages: TImageList;
    FContainer: TPictureContainer;
    FImageCache:  THTMLPictureCache;
    FTimerActiveCells: Integer;
    FPlanChecker: TPlannerCheck;
    FPanel: TPlannerPanel;
    FPositions: Integer;
    FPositionGap: Integer;
    FPositionGapColor: TColor;
    FShowOccupiedInPositionGap: Boolean;
    FPositionWidth: Integer;
    FPositionZoomWidth: Integer;
    FPositionProps: TPositionProps;
    FPrintOptions: TPlannerPrintOptions;
    FHTMLOptions: TPlannerHTMLOptions;
    FInactiveDays: TWeekDays;
    FInactive: TByteSet;
    FLinkUpdate: Boolean;
    FLinkCancel: Boolean;
    FPrinterDriverFix: Boolean;
    FScrollSynch: Boolean;
    FDirectMove: Boolean;
    FDirectDrag: Boolean;
    FTimerID: Integer;
    FLoadLeftCol: Integer;
    FSelections: TPlannerSelections;
    FUserMode: TPlannerUserMode;
    FSelectRange: Boolean;
    FNavigatorButtons: TNavigatorButtons;
    FOnItemAnchorClick: TItemAnchorEvent;
    FOnItemAnchorEnter: TItemAnchorEvent;
    FOnItemAnchorExit: TItemAnchorEvent;
    FOnItemRightClick: TItemEvent;
    FOnItemDblClick: TItemEvent; 
    FOnItemImageClick: TItemImageEvent;
    FOnItemLeftClick: TItemEvent;
    FOnItemMove: TItemMoveEvent;
    FOnItemSize: TItemSizeEvent;
    FOnItemDelete: TItemEvent;
    FOnItemDeleted: TItemEvent;
    FOnItemInsert: TPlannerEvent;
    FOnItemCreated: TItemEvent;
    FOnItemStartEdit: TItemEvent;
    FOnItemEndEdit: TItemEvent;
    FOnItemSelect: TItemEvent;
    FOnItemUnSelect: TItemEvent;
    FOnItemEnter: TItemEvent;
    FOnItemExit: TItemEvent;
    FOnItemHint: TItemHintEvent;
    FOnItemBalloon: TItemBalloonEvent;
    FOnItemClipboardAction: TItemClipboardEvent;
    FOnItemSelChange: TItemEvent;
    FOnItemActivate: TItemEvent;
    FOnItemDeActivate: TItemEvent;
    FOnItemPopupPrepare: TItemPopupPrepareEvent;
    FOnItemPlaceUpdate: TItemUpdateEvent;
    FOnPlannerLeftClick: TPlannerEvent;
    FOnPlannerRightClick: TPlannerEvent;
    FOnPlannerDblClick: TPlannerEvent;
    FOnPlannerBeforeKeyDown: TKeyEvent;
    FOnPlannerKeypress: TPlannerKeyEvent;
    FOnPlannerKeyDown: TPlannerKeyDownEvent;
    FOnPlannerKeyUp: TPlannerKeyDownEvent;
    FOnPlannerItemDraw: TPlannerItemDraw;
    FOnPlannerIsActive: TPlannerActiveEvent;
    FOnPlannerSideDraw: TPlannerSideDraw;
    FOnPlannerSideDrawAfter: TPlannerSideDraw;
    FOnPlannerSideProp: TPlannerSideProp;
    FOnPlannerGetSideBarLines: TPlannerGetSideBarLines;
    FOnPlannerBkgDraw: TPlannerBkgDraw;
    FOnPlannerHeaderDraw: TPlannerHeaderDraw;
    FOnPlannerFooterDraw: TPlannerHeaderDraw;
    FOnPlannerCaptionDraw: TPlannerCaptionDraw;
    FOnPlannerNext: TPlannerBtnEvent;
    FOnPlannerPrev: TPlannerBtnEvent;
    FOnPlannerMouseMove: TMouseMoveEvent;
    FOnPlannerMouseUp: TMouseEvent;
    FOnPlannerMouseDown: TMouseEvent;
    FOnPrintHeader: TPlannerPrintHFEvent;
    FOnPrintFooter: TPlannerPrintHFEvent;
    FOnPlannerBalloon: TPlannerBalloonEvent;
    FOnCaptionAnchorEnter: TPlannerAnchorEvent;
    FOnCaptionAnchorExit: TPlannerAnchorEvent;
    FOnCaptionAnchorClick: TPlannerAnchorEvent;
    FOnCustomEdit: TCustomEditEvent;
    FOnCustomITEvent: TCustomITEvent;
    FOnCustomTIEvent: TCustomTIEvent;
    FOnHeaderClick: THeaderClickEvent;
    FOnHeaderHint: THeaderHintEvent;
    FOnFooterHint: THeaderHintEvent;
    FOnSideBarHint: TSideBarHintEvent;
    FOnHeaderHeightChange: THeaderHeightChangeEvent;
    FOnHeaderSized: TPlannerHeaderSizeEvent;    
    FOnHeaderRightClick: THeaderClickEvent;
    FOnHeaderStartEdit: THeaderEditEvent;
    FOnHeaderEndEdit: THeaderEditEvent;
    FOnPrintStart: TPlannerPrintEvent;
    FOnTopLeftChanged: TPlannerBtnEvent;
    FOnDragOver: TDragOverEvent;
    FOnDragOverCell: TDragOverEvent;
    FOnDragOverItem: TDragOverItemEvent;
    FOnDragOverHeader: TDragOverHeaderEvent;
    FOnDragDrop: TDragDropEvent;
    FOnDragDropCell: TDragDropEvent;
    FONDragDropHeader: TDragDropHeaderEvent;
    FOnDragDropItem: TDragDropItemEvent;
    FOnPlannerSelChange: TPlannerEvent;
    FOnPlannerSelectCell: TPlannerSelectCellEvent;
    FOnItemMoving: TItemMovingEvent;
    FOnItemSizing: TItemSizingEvent;
    FOnItemText: TPlannerItemText;
    FOnGetCurrentTime: TGetCurrentTimeEvent;
    FOnPlanTimeToStrings: TPlannerPlanTimeToStrings;
    FOnExit: TNotifyEvent;
    FOnEnter: TNotifyEvent;
    FMultiSelect: Boolean;
    FDisjunctSelect: Boolean;
    FDefaultItem: TPlannerItem;
    FDefaultItems: TPlannerItems;
    FSelectColor: TColor;
    FShowSelection: Boolean;
    FDisjunctSelectColor: TColor;
    FFlat: Boolean;
    FLoading: Boolean;
    FOnPlannerBottomLine: TPlannerBottomLineEvent;
    FOnPlannerRightLine: TPlannerBottomLineEvent;
    FStreamPersistentTime: Boolean;
    FHTMLHint: Boolean;
    FOnHeaderDragDrop: THeaderDragDropEvent;
    FURLColor: TColor;
    FURLGlyph: TBitmap;
    FDeleteGlyph: TBitmap;
    FAttachementGlyph: TBitmap;
    FOnItemURLClick: TItemLinkEvent;
    FOnItemAttachementClick: TItemLinkEvent;
    FScrollBarStyle: TPlannerScrollBar;
    FBackground: TBackground;
    FPaintMarginTY: Integer;
    FPaintMarginLX: Integer;
    FPaintMarginBY: Integer;
    FPaintMarginRX: Integer;
    FEnableAlarms: Boolean;
    FEnableFlashing: Boolean;
    FEnableKeyboard: Boolean;
    FIndicateNonVisibleItems: Boolean;
    FHandlingAlarm: Boolean;
    FWheelDelta: Integer;
    FWheelAction: TPlannerWheelAction;
    FScrollDelay: Cardinal;
    FOnHeaderDblClick: THeaderClickEvent;
    FAutoItemScroll: Boolean;
    FOnPositionToDay: TPlannerPositionToDay;
    FSelectionAlways: Boolean;
    FFlashColor: TColor;
    FOnItemAlarm: TItemEvent;
    FFlashFontColor: TColor;
    FDragItem: Boolean;
    FCtrlDragCopy: Boolean;
    FOnItemDrag: TItemDragEvent;
    FScrollSmooth: Boolean;
    FPositionGroup: Integer;
    FTrackBump: Boolean;
    FOnPlannerPositionZoom: TPlannerPositionZoom;
    FOnPlannerBeforePositionZoom: TPlannerBeforePositionZoom;
    FOnPlannerUpdateCompletion: TNotifyEvent;
    FSelectBlend: Integer;
    FSelectBackground: Boolean;
    FInsertAlways: Boolean;
    FShowHint: Boolean;
    FTopIndicator: Boolean;
    FBottomIndicator: Boolean;
    FShadowColor: TColor;
    FInplaceEdit: TInplaceEditType;
    FGradientSteps: Integer;
    FGradientHorizontal: Boolean;
    FCompletionColor1: TColor;
    FCompletionColor2: TColor;
    FItemSelection: TPlannerItemSelection;
    FDTList: TDateTimeList;
    FDrawPrecise: Boolean;
    FRoundTime: Boolean;
    FAutoInsDel: Boolean;
    FAutoCreateOnSelect: Boolean;
    FAutoThemeAdapt: Boolean;
    FStickySelect: Boolean;
    FImageOffsetX: integer;
    FImageOffsetY: integer;
    FGroupGapOnly: Boolean;
    FMaxHintWidth: Integer;
    FShowDesignHelper: Boolean;
    FNoPositionSize: Boolean;
    FOnConflictUpdate: TNotifyEvent;
    FOnItemUpdate: TNotifyEvent;
    FEditMode: boolean;
    FPositionAutoSize: boolean;
    FNotesMaxLength: integer;
    FOnItemControlClick: TItemControlEvent;
    FOnItemControlEditStart: TItemControlEvent;
    FOnItemControlEditDone: TItemControlEvent;
    FOnItemControlComboList: TItemControlListEvent;
    FOnItemControlComboSelect: TItemComboControlEvent;
    {$IFDEF TMSSKINS}
    FSkin: TPlannerSkin;
    FOnTimer: TNotifyEvent;
    procedure SetPlannerSkin(AValue: TPlannerSkin);
    {$ENDIF}
    procedure WMTimer(var Message: TWMTimer); message WM_TIMER;
    procedure WMEraseBkGnd(var Message: TWMEraseBkgnd); message WM_ERASEBKGND;
    procedure WMMoving(var Message: TMessage); message WM_MOVING;
    {$IFNDEF DELPHI4_LVL}
    procedure WMSize(var WMSize: TWMSize); message WM_SIZE;
    {$ENDIF}
    procedure InactiveChanged(Sender: TObject);
    procedure SetCaption(const Value: TPlannerCaption);
    procedure SetSideBar(const Value: TPlannerSideBar);
    procedure SetDisplay(const Value: TPlannerDisplay);
    procedure SetDayNames(const Value: TStringList);
    procedure SetHeader(const Value: TPlannerHeader);
    procedure SetFooter(const Value: TPlannerFooter);
    procedure SetMode(const Value: TPlannerMode);
    procedure SetPlannerItems(const Value: TPlannerItems);
    procedure SetImages(const Value: TImageList);
    procedure SetLayer(const Value: LongInt);
    procedure SetDrawPrecise(const Value: Boolean);
    procedure SetHourType(const Value: THourType);
    procedure SetPositions(const Value: Integer);
    procedure SetPositionWidth(const Value: Integer);
    procedure SetPositionAutoSize(const Value: Boolean);
    procedure SetGridTopRow(const Value: Integer);
    procedure SetGridLeftCol(const Value: Integer);
    function GetGridTopRow: Integer;
    function GetGridLeftCol: Integer;
    procedure SetFont(Value: TFont);
    procedure SetTrackColor(const Value: TColor);
    procedure SetTrackOnly(const Value: Boolean);
    procedure SetTrackProportional(const Value: Boolean);
    procedure SetActiveDisplay(const Value: Boolean);
    procedure PlanFontChanged(Sender: TObject);
    procedure HeaderClick(Sender: TObject; SectionIndex: Integer);
    procedure HeaderRightClick(Sender: TObject; SectionIndex: Integer);
    procedure HeaderDblClick(Sender: TObject; SectionIndex: Integer);
    procedure HeaderDragDrop(Sender: TObject; FromSection, ToSection: Integer);
    procedure HeaderSized(Sender: TObject; ASection, AWidth: Integer);
    procedure UpdateTimer;
    function GetSelItemEnd: Integer;
    function GetSelItemBegin: Integer;
    function GetSelPosition: Integer;
    function GetCellTime(i,j: Integer): TDateTime;
    procedure SetSelItemEnd(const Value: Integer);
    procedure SetSelItemBegin(const Value: Integer);
    procedure SetSelPosition(Value: Integer);
    procedure SetShadowColor(const Value: TColor);
    procedure SetGradientSteps(const Value: Integer);
    procedure SetGradientHorizontal(const Value: Boolean);
    procedure SelChange(Sender: TObject);
    procedure SetGridLineColor(const Value: TColor);
    procedure SetColor(const Value: TColor);
    function GetBackGroundColor(ACol, ARow: Integer): TColor;
    procedure SetBackGroundColor(ACol, ARow: Integer; const Value: TColor);
    function GetSelected(ACol, ARow: Integer): Boolean;
    procedure SetSelected(ACol, ARow: Integer; const Value: Boolean);
    procedure SetItemGap(const Value: Integer);
    procedure SaveToHTMLCol(FileName: string; Unicode: boolean = false);
    procedure SaveToHTMLRow(FileName: string; Unicode: boolean = false);
    function GetMemo: TMemo;
    function GetMaskEdit: TMaskEdit;
    procedure SetDefaultItem(const Value: TPlannerItem);
    procedure SetSelectColor(const Value: TColor);
    procedure SetFlat(const Value: Boolean);
    procedure SetPositionGap(const Value: Integer);
    procedure SetPositionGapColor(const Value: TColor);
    procedure SetTrackWidth(const Value: Integer);
    procedure SetURLColor(const Value: TColor);
    procedure SetURLGlyph(const Value: TBitmap);
    procedure SetDeleteGlyph(const Value: TBitmap);
    procedure SetAttachementGlyph(const Value: TBitmap);
    procedure SetEnableAlarms(const Value: Boolean);
    procedure SetPositionProps(const Value: TPositionProps);
    procedure SetEnableFlashing(const Value: Boolean);
    procedure SetFlashColor(const Value: TColor);
    procedure SetFlashFontColor(const Value: TColor);
    function GetDragCopy: Boolean;
    function GetDragMove: Boolean;
    procedure SetPositionGroup(const Value: Integer);
    procedure SetTrackBump(const Value: Boolean);
    function GetPositionWidths(Position: Integer): Integer;
    procedure SetPositionWidths(Position: Integer; const Value: Integer);
    procedure SetPositionZoomWidth(const Value: Integer);
    procedure SetSelectBlend(const Value: Integer);
    procedure SetShowHint(const Value: Boolean);
    procedure SetShowSelection(const Value: Boolean);
    procedure SetItemSelection(AValue: TPlannerItemSelection);
    procedure SetSelectRange(const Value: Boolean);
    procedure ItemDesignChange(Sender: TObject);
    procedure UpdateCompletion;
    procedure SetShowDesignHelper(const Value: Boolean);
    function GapAtColumn(ACol: Integer): Boolean;
    procedure SetGroupGapOnly(AValue: Boolean);
    function GetEditColor(AItem: TPlannerItem; Sel: Boolean): TColor;
    procedure SetVersion(const Value: string);
    function GetVersion: string;
    procedure BalloonInit;
    procedure BalloonDone;
    procedure BalloonChange(Sender: TObject);
  protected
    { Protected declarations }
    procedure Loaded; override;
    {$IFDEF DELPHI4_LVL}
    procedure Resize; override;
    {$ENDIF}
    procedure UpdateSizes;
    procedure CreateParams(var Params: TCreateParams); override;
    procedure DestroyWnd; override;
    procedure WndProc(var Message: TMessage); override;
    procedure CreateWnd; override;
    procedure Paint; override;
    function GetDayName(WeekDay: Integer): string; virtual;
    procedure PrintCol(ACanvas:TCanvas; FromPos, ToPos, FromRow, ToRow: Integer);
    procedure PrintRow(ACanvas:TCanvas; FromPos, ToPos, FromCol, ToCol: Integer);
    procedure GetCellBrush(Pos,Index: Integer; ABrush:TBrush);
    function GetCellColorCol(Pos,Index: Integer; var UseColor: Boolean): TColor;
    procedure NextClick(Sender: TObject); virtual;
    procedure PrevClick(Sender: TObject); virtual;
    procedure ItemMoved(APlannerItem: TPlannerItem; FromBegin, FromEnd, FromPos, ToBegin, ToEnd, ToPos: Integer); virtual;
    procedure ItemSized(APlannerItem: TPlannerItem; FromBegin, FromEnd, ToBegin, ToEnd: Integer); virtual;
    procedure ItemEdited(Item: TPlannerItem); virtual;
    procedure ItemUnSelected(Item: TPlannerItem); virtual;
    procedure ItemSelected(Item: TPlannerItem); virtual;
    procedure Notification(AComponent: TComponent; AOperation: TOperation); override;
    function CreateItems: TPlannerItems; virtual;
    function GetSelMinMax(Pos: Integer; var SelMin, SelMax: Integer): Boolean;
    procedure MapItemTimeOnPlanner(APlannerItem: TPlannerItem); virtual;
    procedure MoveResource(FromPos, ToPos: integer); virtual;
    function GetVersionNr: Integer; virtual;
    function GetVersionString:string; virtual;
    procedure HeaderHeightChange(ASize: Integer); virtual;
    property Selected[ACol,ARow: Integer]: Boolean read GetSelected write SetSelected;
    procedure UpdateSelection(SelBegin, SelEnd, SelPos: Integer;Active: Boolean);
    procedure DoHeaderHint(Sender: TObject; Index: integer; var HintStr: string);
    procedure DoFooterHint(Sender: TObject; Index: integer; var HintStr: string);
    procedure DoPositionAutoSize; virtual;
    function IsDBAware: boolean; virtual;
  public
    { Public declarations }
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure Assign(Source: TPersistent); override;
    procedure AutoSizeHeader;
    procedure SaveToHTML(FileName: string; Unicode: boolean = false);
    procedure SaveToBMP(FileName: string; Size: TSize);
    procedure SaveToStream(Stream: TStream);
    procedure LoadFromStream(Stream: TStream);
    procedure InsertFromStream(Stream: TStream);
    procedure SavePositionToStream(Stream: TStream; Position: Integer);
    procedure LoadPositionFromStream(Stream: TStream; Position: Integer);
    procedure SaveLayerToStream(Stream: TStream; Layer: Integer);
    procedure LoadLayerFromStream(Stream: TStream; Layer: Integer);
    procedure SaveToFile(FileName: string);
    procedure LoadFromFile(FileName: string);
    procedure InsertFromFile(FileName: string);
    procedure SavePositionToFile(FileName: string; Position: Integer);
    procedure LoadPositionFromFile(FileName: string; Position: Integer);
    procedure SaveLayerToFile(FileName: string; Layer: Integer);
    procedure LoadLayerFromFile(FileName: string; Layer: Integer);
    procedure Print;
    procedure PrintPages(NrOfPages: Integer);
    procedure PrintSelection(FromPos, ToPos: Integer);
    procedure PrintRange(FromPos, ToPos, FromItem, ToItem: Integer);
    procedure PrintTo(ACanvas:TCanvas);
    procedure PrintSelectionTo(ACanvas:TCanvas;FromPos, ToPos: Integer);
    procedure PrintRangeTo(ACanvas:TCanvas;FromPos, ToPos, FromItem, ToItem: Integer);
    procedure Invalidate; override;
    procedure ThemeAdapt;
    procedure TextToRich(const RtfText: string);
    function RichToText: string;
    procedure PreviewPaint(APlannerItem: TPlannerItem; Canvas: TCanvas; r: TRect; Direction, Print: Boolean);
    procedure SelectGrid;
    procedure SelectCells(SelBegin,SelEnd,SelPos: Integer);
    procedure ScrollToTime(ATime: TDateTime);

    property CompletionColor1: TColor read FCompletionColor1 write FCompletionColor1;
    property CompletionColor2: TColor read FCompletionColor2 write FCompletionColor2;
    property SelPosition: Integer read GetSelPosition write SetSelPosition;
    property SelItemBegin: Integer read GetSelItemBegin write SetSelItemBegin;
    property SelItemEnd: Integer read GetSelItemEnd write SetSelItemEnd;
    property Selections: TPlannerSelections read FSelections;
    property DateTimeList: TDateTimeList read FDTList write FDTList;
    property GradientSteps: Integer read FGradientSteps write SetGradientSteps;
    property GradientHorizontal: Boolean read FGradientHorizontal write SetGradientHorizontal default False;
    property RichEdit: TPlannerRichEdit read FRichEdit write FRichEdit;
    property MemoEdit: TMemo read GetMemo;
    property MaskEdit: TMaskEdit read GetMaskEdit;
    property EditMode: boolean read FEditMode;
    property BackGroundColor[ACol, ARow: Integer]: TColor read GetBackGroundColor write SetBackGroundColor;
    procedure ClearBackgroundColors;
    property PrinterDriverFix: Boolean read FPrinterDriverFix write FPrinterDriverFix;
    function PlanTimeToStr(MinutesValue: Integer): string;
    procedure PlanTimeToStrings(MinutesValue: Integer; var HoursString, MinutesString, AmPmString: string);
    function IsSelected(AIndex, APosition: Integer): Boolean;
    function IsActive(AIndex, APosition: Integer): Boolean;
    function IsCurPos(APosition: Integer): Boolean;
    function XYToSelection(X,Y: Integer): TPoint;
    function XYToCell(X, Y: Integer): TPoint;
    function XYToItem(X, Y: Integer): TPlannerItem;
    function CellToItem(X, Y: Integer): TPlannerItem;
    function CellToItemNum(X, Y: Integer): Integer;
    function CellToItemIdx(X, Y, Index: Integer): TPlannerItem;
    function CellInCurrTime(X, Y: Integer): Boolean;
    function CellToTime(X, Y: Integer): TDateTime;
    function CellRect(X,Y: Integer): TRect;
    function PosToDay(Pos: Integer): TDateTime; virtual;
    function IndexToTime(Index: Integer): TDateTime; virtual;
    function TimeToIndex(DT: TDateTime): Integer; virtual;
    procedure CellToAbsTime(X: Integer; var dtStart, dtEnd: TDateTime);
    procedure SelectionToAbsTime(var dtStart, dtEnd: TDateTime);
    function AbsTimeToCell(DateTime: TDateTime): Integer;
    function GetPositionCompletion(Position: Integer; Active: Boolean): Integer;
    procedure HideSelection;
    procedure UnHideSelection;
    procedure MovePosition(FromPos, ToPos: Integer);
    procedure DeletePosition(Position: Integer);
    procedure InsertPosition(Position: Integer);
    function CreateItem:TPlannerItem; virtual;
    function CloneItem(Item: TPlannerItem): TPlannerItem; virtual;
    procedure RemoveClones(Item: TPlannerItem);
    function CreateItemAtSelection:TPlannerItem; virtual;
    function CloneItemAtSelection(Item: TPlannerItem): TPlannerItem; virtual;
    procedure StopEditing;
    procedure UpdateItem(APlannerItem:TPlannerItem); virtual;
    procedure RefreshItem(APlannerItem:TPlannerItem); virtual;
    procedure FreeItem(APlannerItem:TPlannerItem); virtual;
    procedure Refresh; virtual;
    procedure MarkInItem(APlannerItem: TPlannerItem; AText: string; DoCase: Boolean);
    procedure MarkInPositon(Pos: Integer; AText: string; DoCase: Boolean);
    procedure MarkInItems(AText: string; DoCase: Boolean);
    procedure UnMarkInItem(APlannerItem: TPlannerItem);
    procedure UnMarkInPositon(Pos: Integer);
    procedure UnMarkInItems;
    procedure HilightInItem(APlannerItem: TPlannerItem; AText: string; DoCase: Boolean);
    procedure HilightInPositon(Pos: Integer; AText: string; DoCase: Boolean);
    procedure HilightInItems(AText: string; DoCase: Boolean);
    procedure UnHilightInItem(APlannerItem: TPlannerItem);
    procedure UnHilightInPositon(Pos: Integer);
    procedure UnHilightInItems;
    procedure ExportItem(APlannerItem: TPlannerItem);
    procedure ExportPosition(Pos: Integer);
    procedure ExportItems;
    procedure ExportLayer(Layer: Integer);
    procedure ExportClear;
    procedure UpdateNVI;
    procedure SetStyle(StyleIndex: Integer);
    procedure SetComponentStyle(AStyle: TTMSStyle);
    procedure ZoomPosition(Pos: Integer);
    procedure UnZoomPosition(Pos: Integer);
    property VersionNr: Integer read GetVersionNr;
    property VersionString: string read GetVersionString;
    property PopupPlannerItem: TPlannerItem read FPopupPlannerItem write FPopupPlannerItem;
    property StreamPersistentTime: Boolean read FStreamPersistentTime write FStreamPersistentTime;
    property PaintMarginTY: Integer read FPaintMarginTY write FPaintMarginTY;
    property PaintMarginLX: Integer read FPaintMarginLX write FPaintMarginLX;
    property PaintMarginBY: Integer read FPaintMarginBY write FPaintMarginBY;
    property PaintMarginRX: Integer read FPaintMarginRX write FPaintMarginRX;
    property MaxHintWidth: Integer read FMaxHintWidth write FMaxHintWidth;
    property AutoItemScroll: Boolean read FAutoItemScroll write FAutoItemScroll;
    property DragCopy: Boolean read GetDragCopy;
    property DragMove: Boolean read GetDragMove;
    property PositionWidths[Position: Integer]: Integer read GetPositionWidths write SetPositionWidths;
    property ScrollDelay: Cardinal read FScrollDelay write FScrollDelay;
    property HeaderControl: TAdvHeader read FHeader;
    property FooterControl: TAdvFooter read FFooter;
    property CaptionControl: TPlannerPanel read FPanel;
    property PrevControl: TAdvSpeedButton read FPrev;
    property NextControl: TAdvSpeedButton read FNext;
    property GridControl: TPlannerGrid read FGrid;
    { Normal published declarations }
    property ActiveDisplay: Boolean read FActiveDisplay write SetActiveDisplay default False;
    property AutoCreateOnSelect: Boolean read FAutoCreateOnSelect write FAutoCreateOnSelect default false;
    property AutoInsDel: Boolean read FAutoInsDel write FAutoInsDel default False;
    property AutoThemeAdapt: Boolean read FAutoThemeAdapt write FAutoThemeAdapt default False;
    property Align;
    property AttachementGlyph: TBitmap read FAttachementGlyph write SetAttachementGlyph;
    property Background: TBackground read FBackground write FBackground;
    property Balloon: TBalloonSettings read FBalloon write FBalloon;
    property Bands: TBands read FBands write FBands;
    {$IFDEF DELPHI4_LVL}
    property Anchors;
    property BiDiMode;
    property Constraints;
    {$ENDIF}
    property Caption: TPlannerCaption read FCaption write SetCaption;
    property Color: TColor read FColor write SetColor default clWindow;
    property CtrlDragCopy: Boolean read FCtrlDragCopy write FCtrlDragCopy default False;
    property DayNames: TStringList read FDayNames write SetDayNames;
    property DefaultItem: TPlannerItem read FDefaultItem write SetDefaultItem;
    property DeleteGlyph: TBitmap read FDeleteGlyph write SetDeleteGlyph;
    property DirectMove: Boolean read FDirectMove write FDirectMove default False;
    property DirectDrag: Boolean read FDirectDrag write FDirectDrag;
    property DisjunctSelect: Boolean read FDisjunctSelect write FDisjunctSelect default False;
    property DisjunctSelectColor: TColor read FDisjunctSelectColor write FDisjunctSelectColor default clHighlight;
    property Display: TPlannerDisplay read FDisplay write SetDisplay;
    property DragItem: Boolean read FDragItem write FDragItem default False;
    property DrawPrecise: Boolean read FDrawPrecise write SetDrawPrecise;
    property RoundTime: Boolean read FRoundTime write FRoundTime;
    property EditRTF: Boolean read FEditRTF write FEditRTF default False;
    property EditDirect: Boolean read FEditDirect write FEditDirect default False;
    property EditScroll: TScrollStyle read FEditScroll write FEditScroll default ssNone;
    property EnableAlarms: Boolean read FEnableAlarms write SetEnableAlarms default False;
    property EnableFlashing: Boolean read FEnableFlashing write SetEnableFlashing default False;
    property EnableKeyboard: Boolean read FEnableKeyboard write FEnableKeyboard default True;
    property FlashColor: TColor read FFlashColor write SetFlashColor default clRed;
    property FlashFontColor: TColor read FFlashFontColor write SetFlashFontColor default clWhite;
    property Flat: Boolean read FFlat write SetFlat default true;
    property Font: TFont read FFont write SetFont;
    property Footer: TPlannerFooter read FPlannerFooter write SetFooter;
    property GridPopup: TPopupmenu read FGridPopup write FGridPopup;
    property GridLeftCol: Integer read GetGridLeftCol write SetGridLeftCol;
    property GridLineColor: TColor read FGridLineColor write SetGridLineColor default $00CECECE;
    property GridTopRow: Integer read GetGridTopRow write SetGridTopRow;
    property GroupGapOnly: Boolean read FGroupGapOnly write SetGroupGapOnly default False;
    property Header: TPlannerHeader read FPlannerHeader write SetHeader;
    property HintColor: TColor read FHintColor write FHintColor default clInfoBk;
    property HintPause: Integer read FHintPause write FHintPause default 500;
    property HintOnItemChange: Boolean read FHintOnItemChange write FHintOnItemChange default True;
    property HourType: THourType read FHourType write SetHourType default ht24hrs;
    property HTMLHint: Boolean read FHTMLHint write FHTMLHint default False;
    property HTMLOptions: TPlannerHTMLOptions read FHTMLOptions write FHTMLOptions;
    property InActiveDays: TWeekDays read FInactiveDays write FInactiveDays;
    property InActive: TByteSet read FInActive;
    property IndicateNonVisibleItems: Boolean read FIndicateNonVisibleItems write FIndicateNonVisibleItems default False;
    property InplaceEdit: TInplaceEditType read FInplaceEdit write FInplaceEdit default ieAlways;
    property InsertAlways: Boolean read FInsertAlways write FInsertAlways default True;
    property ItemChecker: TPlannerCheck read FPlanChecker write FPlanChecker;
    property ItemGap: Integer read FItemGap write SetItemGap default 11;
    property ItemPopup: TPopupmenu read FItemPopup write FItemPopup;
    property Items: TPlannerItems read FPlannerItems write SetPlannerItems;
    property ItemSelection: TPlannerItemSelection read FItemSelection write SetItemSelection;
    property Layer: LongInt read FLayer write SetLayer default 0;
    property Mode: TPlannerMode read FMode write SetMode;
    property MultiSelect: Boolean read FMultiSelect write FMultiSelect default False;
    property NavigatorButtons: TNavigatorButtons read FNavigatorButtons write FNavigatorButtons;
    property NotesMaxLength: integer read FNotesMaxLength write FNotesMaxLength default 0;
    property SelectionAlways: Boolean read FSelectionAlways write FSelectionAlways default True;
    property SelectRange: Boolean read FSelectRange write SetSelectRange default True;
    property ShadowColor: TColor read FShadowColor write SetShadowColor default clGray;
    property ShowHint: Boolean read FShowHint write SetShowHint default False;
    property ShowDesignHelper: Boolean read FShowDesignHelper write SetShowDesignHelper default True;
    property ShowSelection: Boolean read FShowSelection write SetShowSelection default True;    
    property Sidebar: TPlannerSideBar read FSidebar write SetSideBar;
    {$IFDEF TMSSKINS}
    property Skin: TPlannerSkin read FSkin write SetPlannerSkin;
    {$ENDIF}
    property Overlap: Boolean read FOverlap write FOverlap default True;
    property PictureContainer: TPictureContainer read FContainer write FContainer;
    property PlannerImages: TImageList read FPlannerImages write SetImages;
    property Positions: Integer read FPositions write SetPositions default 3;
    property PositionAutoSize: boolean read FPositionAutoSize write SetPositionAutoSize default false;
    property PositionGap: Integer read FPositionGap write SetPositionGap default 0;
    property PositionGapColor: TColor read FPositionGapColor write SetPositionGapColor default clWhite;
    property PositionGroup: Integer read FPositionGroup write SetPositionGroup default 0;
    property PositionProps: TPositionProps read FPositionProps write SetPositionProps;
    property PositionWidth: Integer read FPositionWidth write SetPositionWidth default 0;
    property PositionZoomWidth: Integer read FPositionZoomWidth write SetPositionZoomWidth default 0;
    property PrintOptions: TPlannerPrintOptions read FPrintOptions write FPrintOptions;
    property ScrollSmooth: Boolean read FScrollSmooth write FScrollSmooth default False;
    property ScrollSynch: Boolean read FScrollSynch write FScrollSynch default False;
    property ScrollBarStyle: TPlannerScrollBar read FScrollBarStyle write FScrollBarStyle;
    property SelectBackground: Boolean read FSelectBackground write FSelectBackground default False;
    property SelectBlend: Integer read FSelectBlend write SetSelectBlend default 90;
    property SelectColor: TColor read FSelectColor write SetSelectColor default clHighlight;
    property ShowOccupiedInPositionGap: Boolean read FShowOccupiedInPositionGap write FShowOccupiedInPositionGap default True;
    property StickySelect: Boolean read FStickySelect write FStickySelect default False;
    property TrackBump: Boolean read FTrackBump write SetTrackBump default False;
    property TrackColor: TColor read FTrackColor write SetTrackColor default clBlue;
    property TrackOnly: Boolean read FTrackOnly write SetTrackOnly default False;
    property TrackProportional: Boolean read FTrackProportional write SetTrackProportional default False;
    property TrackWidth: Integer read FTrackWidth write SetTrackWidth default 4;
    property URLColor: TColor read FURLColor write SetURLColor default clBlue;
    property URLGlyph: TBitmap read FURLGlyph write SetURLGlyph;
    property UserMode: TPlannerUserMode read FUserMode write FUserMode default puNormal;
    property ImageOffsetX: integer read FImageOffsetX write FImageOffsetX;
    property ImageOffsetY: integer read FImageOffsetY write FImageOffsetY;
    property Version: string read GetVersion write SetVersion;
    property Visible;
    {$IFDEF DELPHI5_LVL}
    property WheelDelta: Integer read FWheelDelta write FWheelDelta default 1;
    property WheelAction: TPlannerWheelAction read FWheelAction write FWheelAction default pwaSelect;
    {$ENDIF}
    property OnStartDrag;
    property OnEndDrag;
    property OnCaptionAnchorEnter: TPlannerAnchorEvent read FOnCaptionAnchorEnter write FOnCaptionAnchorEnter;
    property OnCaptionAnchorExit: TPlannerAnchorEvent read FOnCaptionAnchorExit write FOnCaptionAnchorExit;
    property OnCaptionAnchorClick: TPlannerAnchorEvent read FOnCaptionAnchorClick write FOnCaptionAnchorClick;
    property OnConflictUpdate: TNotifyEvent read FOnConflictUpdate write FOnConflictUpdate;
    property OnItemUpdate: TNotifyEvent read FOnItemUpdate write FOnItemUpdate;
    property OnCustomEdit: TCustomEditEvent read FOnCustomEdit write FOnCustomEdit;
    property OnEnter: TNotifyEvent read FOnEnter write FOnEnter;
    property OnExit: TNotifyEvent read FOnExit write FOnExit;
    property OnItemAnchorClick: TItemAnchorEvent read FOnItemAnchorClick write FOnItemAnchorClick;
    property OnItemAnchorEnter: TItemAnchorEvent read FOnItemAnchorEnter write FOnItemAnchorEnter;
    property OnItemAnchorExit: TItemAnchorEvent read FOnItemAnchorExit write FOnItemAnchorExit;
    property OnItemControlEditStart: TItemControlEvent read FOnItemControlEditStart write FOnItemControlEditStart;
    property OnItemControlEditDone: TItemControlEvent read FOnItemControlEditDone write FOnItemControlEditDone;
    property OnItemControlComboList: TItemControlListEvent read FOnItemControlComboList write FOnItemControlComboList;
    property OnItemControlClick: TItemControlEvent read FOnItemControlClick write FOnItemControlClick;
    property OnItemControlComboSelect: TItemComboControlEvent read FOnItemControlComboSelect write FOnItemControlComboSelect;
    property OnItemClipboardAction: TItemClipboardEvent read FOnItemClipboardAction write FOnItemClipboardAction;
    property OnItemLeftClick: TItemEvent read FOnItemLeftClick write FOnItemLeftClick;
    property OnItemRightClick: TItemEvent read FOnItemRightClick write FOnItemRightClick;
    property OnItemDblClick: TItemEvent read FOnItemDblClick write FOnItemDblClick;
    property OnItemDrag: TItemDragEvent read FOnItemDrag write FOnItemDrag;
    property OnItemImageClick: TItemImageEvent read FOnItemImageClick write FOnItemImageClick;
    property OnItemURLClick: TItemLinkEvent read FOnItemURLClick write FOnItemURLClick;
    property OnItemAlarm: TItemEvent read FOnItemAlarm write FOnItemAlarm;
    property OnItemAttachementClick: TItemLinkEvent read FOnItemAttachementClick write FOnItemAttachementClick;
    property OnItemBalloon: TItemBalloonEvent read FOnItemBalloon write FOnItemBalloon;
    property OnItemSize: TItemSizeEvent read FOnItemSize write FOnItemSize;
    property OnItemMove: TItemMoveEvent read FOnItemMove write FOnItemMove;
    property OnItemSizing: TItemSizingEvent read FOnItemSizing write FOnItemSizing;
    property OnItemMoving: TItemMovingEvent read FOnItemMoving write FOnItemMoving;
    property OnItemDelete: TItemEvent read FOnItemDelete write FOnItemDelete;
    property OnItemDeleted: TItemEvent read FOnItemDeleted write FOnItemDeleted;
    property OnItemInsert: TPlannerEvent read FOnItemInsert write FOnItemInsert;
    property OnItemCreated: TItemEvent read FOnItemCreated write FOnItemCreated;
    property OnItemStartEdit: TItemEvent read FOnItemStartEdit write FOnItemStartEdit;
    property OnItemEndEdit: TItemEvent read FOnItemEndEdit write FOnItemEndEdit;
    property OnItemSelect: TItemEvent read FOnItemSelect write FOnItemSelect;
    property OnItemUnSelect: TItemEvent read FOnItemUnSelect write FOnItemUnSelect;
    property OnItemEnter: TItemEvent read FOnItemEnter write FOnItemEnter;
    property OnItemExit: TItemEvent read FOnItemExit write FOnItemExit;
    property OnItemHint: TItemHintEvent read FOnItemHint write FOnItemHint;
    property OnItemSelChange: TItemEvent read FOnItemSelChange write FOnItemSelChange;
    property OnItemActivate: TItemEvent read FOnItemActivate write FOnItemActivate;
    property OnItemDeActivate: TItemEvent read FOnItemDeActivate write FOnItemDeActivate;
    property OnItemPlaceUpdate: TItemUpdateEvent read FOnItemPlaceUpdate write FOnItemPlaceUpdate;
    property OnItemPopupPrepare: TItemPopupPrepareEvent read FOnItemPopupPrepare write FOnItemPopupPrepare;
    property OnItemText: TPlannerItemText read FOnItemText write FOnItemText;
    property OnPlannerLeftClick: TPlannerEvent read FOnPlannerLeftClick write FOnPlannerLeftClick;
    property OnPlannerRightClick: TPlannerEvent read FOnPlannerRightClick write FOnPlannerRightClick;
    property OnPlannerDblClick: TPlannerEvent read FOnPlannerDblClick write FOnPlannerDblClick;
    property OnPlannerBeforeKeyDown: TKeyEvent read FOnPlannerBeforeKeyDown write FOnPlannerBeforeKeyDown;
    property OnPlannerKeyPress: TPlannerKeyEvent read FOnPlannerKeypress write FOnPlannerKeypress;
    property OnPlannerKeyDown: TPlannerKeyDownEvent read FOnPlannerKeyDown write FOnPlannerKeyDown;
    property OnPlannerKeyUp: TPlannerKeyDownEvent read FOnPlannerKeyUp write FOnPlannerKeyUp;
    property OnPlannerItemDraw: TPlannerItemDraw read FOnPlannerItemDraw write FOnPlannerItemDraw;
    property OnPlannerIsActive: TPlannerActiveEvent read FOnPlannerIsActive write FOnPlannerIsActive;
    property OnPlannerBottomLine: TPlannerBottomLineEvent read FOnPlannerBottomLine write FOnPlannerBottomLine;
    property OnPlannerRightLine: TPlannerBottomLineEvent read FOnPlannerRightLine write FOnPlannerRightLine;
    property OnPlannerSideDraw: TPlannerSideDraw read FOnPlannerSideDraw write FOnPlannerSideDraw;
    property OnPlannerSideDrawAfter: TPlannerSideDraw read FOnPlannerSideDrawAfter write FOnPlannerSideDrawAfter;
    property OnPlannerSideProp: TPlannerSideProp read FOnPlannerSideProp write FOnPlannerSideProp;    
    property OnPlannerGetSideBarLines: TPlannerGetSideBarLines read FOnPlannerGetSideBarLines write FOnPlannerGetSideBarLines;
    property OnPlannerBkgDraw: TPlannerBkgDraw read FOnPlannerBkgDraw write FOnPlannerBkgDraw;
    property OnPlannerHeaderDraw: TPlannerHeaderDraw read FOnPlannerHeaderDraw write FOnPlannerHeaderDraw;
    property OnPlannerFooterDraw: TPlannerHeaderDraw read FOnPlannerFooterDraw write FOnPlannerFooterDraw;    
    property OnPlannerCaptionDraw: TPlannerCaptionDraw read FOnPlannerCaptionDraw write FOnPlannerCaptionDraw;
    property OnPlannerNext: TPlannerBtnEvent read FOnPlannerNext write FOnPlannerNext;
    property OnPlannerPrev: TPlannerBtnEvent read FOnPlannerPrev write FOnPlannerPrev;
    property OnPlannerSelChange: TPlannerEvent read FOnPlannerSelChange write FOnPlannerSelChange;
    property OnPlannerSelectCell: TPlannerSelectCellEvent read FOnPlannerSelectCell write FOnPlannerSelectCell;
    property OnPlannerMouseMove: TMouseMoveEvent read FOnPlannerMouseMove write FOnPlannerMouseMove;
    property OnPlannerMouseUp: TMouseEvent read FOnPlannerMouseUp write FOnPlannerMouseUp;
    property OnPlannerMouseDown: TMouseEvent read FOnPlannerMouseDown write FOnPlannerMouseDown;
    property OnPlannerPositionZoom: TPlannerPositionZoom read FOnPlannerPositionZoom write FOnPlannerPositionZoom;
    property OnPlannerBeforePositionZoom: TPlannerBeforePositionZoom read FOnPlannerBeforePositionZoom write FOnPlannerBeforePositionZoom;
    property OnPlannerUpdateCompletion: TNotifyEvent read FOnPlannerUpdateCompletion write FOnPlannerUpdateCompletion;
    property OnPlannerBalloon: TPlannerBalloonEvent read FOnPlannerBalloon write FOnPlannerBalloon;
    property OnPlanTimeToStrings: TPlannerPlanTimeToStrings read FOnPlanTimeToStrings write FOnPlanTimeToStrings;
    property OnPositionToDay: TPlannerPositionToDay read FOnPositionToDay write FOnPositionToDay;
    property OnHeaderClick: THeaderClickEvent read FOnHeaderClick write FOnHeaderClick;
    property OnHeaderHeightChange: THeaderHeightChangeEvent read FOnHeaderHeightChange write FOnHeaderHeightChange;
    property OnHeaderHint: THeaderHintEvent read FOnHeaderHint write FOnHeaderHint;
    property OnHeaderRightClick: THeaderClickEvent read FOnHeaderRightClick write FOnHeaderRightClick;
    property OnHeaderDblClick: THeaderClickEvent read FOnHeaderDblClick write FOnHeaderDblClick;
    property OnHeaderDragDrop: THeaderDragDropEvent read FOnHeaderDragDrop write FOnHeaderDragDrop;
    property OnHeaderStartEdit: THeaderEditEvent read FOnHeaderStartEdit write FOnHeaderStartEdit;
    property OnHeaderEndEdit: THeaderEditEvent read FOnHeaderEndEdit write FOnHeaderEndEdit;
    property OnHeaderSized: TPlannerHeaderSizeEvent read FOnHeaderSized write FOnHeaderSized;
    property OnFooterHint: THeaderHintEvent read FOnFooterHint write FOnFooterHint;
    property OnSideBarHint: TSideBarHintEvent read FOnSideBarHint write FOnSideBarHint;
    property OnTimer: TNotifyEvent read FOnTimer write FOnTimer;
    property OnTopLeftChanged: TPlannerBtnEvent read FOnTopLeftChanged write FOnTopLeftChanged;
    property OnPrintStart: TPlannerPrintEvent read FOnPrintStart write FOnPrintStart;
    property OnPrintHeader: TPlannerPrintHFEvent read FOnPrintHeader write FOnPrintHeader;
    property OnPrintFooter: TPlannerPrintHFEvent read FOnPrintFooter write FOnPrintFooter;
    property OnDragOver: TDragOverEvent read FOnDragOver write FOnDragOver;
    property OnDragOverCell: TDragOverEvent read FOnDragOverCell write FOnDragOverCell;
    property OnDragOverHeader: TDragOverHeaderEvent read FOnDragOverHeader write FOnDragOverHeader;
    property OnDragOverItem: TDragOverItemEvent read FOnDragOverItem write FOnDragOverItem;
    property OnDragDrop: TDragDropEvent read FOnDragDrop write FOnDragDrop;
    property OnDragDropCell: TDragDropEvent read FOnDragDropCell write FOnDragDropCell;
    property OnDragDropHeader: TDragDropHeaderEvent read FOnDragDropHeader write FOnDragDropHeader;
    property OnDragDropItem: TDragDropItemEvent read FOnDragDropItem write FOnDragDropItem;
    property OnGetCurrentTime: TGetCurrentTimeEvent read FOnGetCurrentTime write FOnGetCurrentTime;
    property OnCustomIndexToTime: TCustomITEvent read FOnCustomITEvent write FOnCustomITEvent;
    property OnCustomTimeToIndex: TCustomTIEvent read FOnCustomTIEvent write FOnCustomTIEvent;
  end;


  TPlanner = class(TCustomPlanner)
  published
    { Published declarations }
    property ActiveDisplay;
    property Align;
    property AttachementGlyph;
    property AutoCreateOnSelect;
    property AutoInsDel;
    property Background;
    property AutoThemeAdapt;
    property Balloon;
    property Bands;
    {$IFDEF DELPHI4_LVL}
    property Anchors;
    property BiDiMode;
    property Constraints;
    {$ENDIF}
    property Caption;
    property Color;
    property CtrlDragCopy;
    property DayNames;
    property DefaultItem;
    property DeleteGlyph;
    property DirectMove;
    property DisjunctSelect;
    property DisjunctSelectColor;
    property Display;
    property DragItem;
    property EditRTF;
    property EditDirect;
    property EditScroll;
    property EnableAlarms;
    property EnableFlashing;
    property EnableKeyboard;
    property FlashColor;
    property FlashFontColor;
    property Flat;
    property Font;
    property Footer;
    property GradientHorizontal;
    property GridPopup;
    property GridLeftCol;
    property GridLineColor;
    property GridTopRow;
    property GroupGapOnly;
    property Header;
    property HintColor;
    property HintPause;
    property HintOnItemChange;
    property HourType;
    property HTMLHint;
    property HTMLOptions;
    property InActiveDays;
    property IndicateNonVisibleItems;
    property InplaceEdit;
    property InsertAlways;
    property ItemChecker;
    property ItemGap;
    property ItemPopup;
    property Items;
    property ItemSelection;
    property Layer;
    property Mode;
    property MultiSelect;
    property NavigatorButtons;
    property NotesMaxLength;
    property SelectionAlways;
    property ShadowColor;
    property ShowHint;
    property Sidebar;
    property Overlap;
    property PictureContainer;
    property PlannerImages;
    property Positions;
    property PositionAutoSize;
    property PositionGap;
    property PositionGapColor;
    property PositionGroup;
    property PositionProps;
    property PositionWidth;
    property PositionZoomWidth;
    property PrintOptions;
    property ScrollSmooth;
    property ScrollSynch;
    property ScrollBarStyle;
    property SelectBackground;
    property SelectBlend;
    property SelectColor;
    property SelectRange;
    property ShowDesignHelper;
    property ShowOccupiedInPositionGap;
    property ShowSelection;
    property StickySelect;
    property TrackBump;
    property TrackColor;
    property TrackOnly;
    property TrackProportional;
    property TrackWidth;
    property URLColor;
    property URLGlyph;
    property UserMode;
    property Version;
    property Visible;
    {$IFDEF DELPHI5_LVL}
    property WheelDelta;
    {$ENDIF}
    property OnStartDrag;
    property OnEndDrag;
    property OnCaptionAnchorEnter;
    property OnCaptionAnchorExit;
    property OnCaptionAnchorClick;
    property OnCustomEdit;
    property OnCustomIndexToTime;
    property OnCustomTimeToIndex;
    property OnEnter;
    property OnExit;
    property OnItemAnchorClick;
    property OnItemAnchorEnter;
    property OnItemAnchorExit;
    property OnItemControlEditStart;
    property OnItemControlEditDone;
    property OnItemControlComboList;
    property OnItemControlClick;
    property OnItemControlComboSelect;
    property OnItemClipboardAction;
    property OnItemLeftClick;
    property OnItemRightClick;
    property OnItemDblClick;
    property OnItemDrag;
    property OnItemImageClick;
    property OnItemURLClick;
    property OnItemAlarm;
    property OnItemAttachementClick;
    property OnItemBalloon;
    property OnItemSize;
    property OnItemMove;
    property OnItemSizing;
    property OnItemMoving;
    property OnItemDelete;
    property OnItemDeleted;    
    property OnItemInsert;
    property OnItemCreated;
    property OnItemStartEdit;
    property OnItemEndEdit;
    property OnItemSelect;
    property OnItemEnter;
    property OnItemExit;
    property OnItemHint;
    property OnItemSelChange;
    property OnItemActivate;
    property OnItemDeActivate;
    property OnItemPlaceUpdate;
    property OnItemPopupPrepare;
    property OnItemText;
    property OnItemUnSelect;
    property OnPlannerLeftClick;
    property OnPlannerRightClick;
    property OnPlannerDblClick;
    property OnPlannerBeforeKeyDown;
    property OnPlannerKeyPress;
    property OnPlannerKeyDown;
    property OnPlannerKeyUp;
    property OnPlannerItemDraw;
    property OnPlannerBottomLine;
    property OnPlannerRightLine;
    property OnPlannerSideDraw;
    property OnPlannerSideDrawAfter;
    property OnPlannerSideProp;
    property OnPlannerGetSideBarLines;
    property OnPlannerBkgDraw;
    property OnPlannerFooterDraw;    
    property OnPlannerHeaderDraw;
    property OnPlannerCaptionDraw;
    property OnPlannerNext;
    property OnPlannerPrev;
    property OnPlannerSelChange;
    property OnPlannerSelectCell;
    property OnPlannerMouseMove;
    property OnPlannerMouseUp;
    property OnPlannerMouseDown;
    property OnPlannerPositionZoom;
    property OnPlannerBeforePositionZoom;
    property OnPlannerUpdateCompletion;
    property OnPlanTimeToStrings;
    property OnPlannerBalloon;
    property OnPositionToDay;
    property OnFooterHint;
    property OnHeaderClick;
    property OnHeaderHeightChange;
    property OnHeaderHint;
    property OnHeaderRightClick;
    property OnHeaderDblClick;
    property OnHeaderDragDrop;
    property OnHeaderStartEdit;
    property OnHeaderEndEdit;
    property OnHeaderSized;
    property OnTopLeftChanged;
    property OnPrintStart;
    property OnPrintHeader;
    property OnPrintFooter;
    property OnDragOver;
    property OnDragOverCell;
    property OnDragOverHeader;    
    property OnDragOverItem;
    property OnDragDrop;
    property OnDragDropCell;
    property OnDragDropHeader;    
    property OnDragDropItem;
    property OnGetCurrentTime;
    property OnResize;
    property OnSideBarHint;

    {$IFDEF TMSSKINS}
    property Skin;
    {$ENDIF}
  end;

  TPlannerIO = class(TComponent)
    FItems: TPlannerItems;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  published
    property Items: TPlannerItems read FItems write FItems;
  end;

  TPlannerItemIO = class(TComponent)
    FItem: TPlannerItem;
  public
    constructor CreateItem(AOwner: TPlannerItems);
    destructor Destroy; override;
  published
    property Item: TPlannerItem read FItem write FItem;
  end;

  function PlannerGetIdCol(Planner: TCustomPlanner; Index, Position: Integer): string;


{$R PLANNER.RES}

implementation

uses
  ClipBrd, RichEdit, IniFiles, ActnList, PlanHTML, ImgList
{$IFDEF DELPHI7_LVL}
  , DateUtils
{$ENDIF}

{$IFDEF TMSDOTNET}
  , System.Runtime.InteropServices
{$ENDIF}

{$IFDEF TMSCODESITE}
  , CsIntf
{$ENDIF}
  ;




const
  ComCtrl = 'comctl32.dll';

  // theme changed notifier
  WM_THEMECHANGED = $031A;

  BtnWidth = 16;
  DaysPerWeek = 7;
  FirstDayOfWeek = 1;
  LastDayOfWeek = DaysPerWeek;

  ShortDaySun = 'Sun';
  ShortDayMon = 'Mon';
  ShortDayTue = 'Tue';
  ShortDayWed = 'Wed';
  ShortDayThu = 'Thu';
  ShortDayFri = 'Fri';
  ShortDaySat = 'Sat';

{$IFNDEF DELPHI4_LVL}
  //constant definitions for flat/encarta scrollbars}
  WSB_PROP_CYVSCROLL  = $0000001;
  WSB_PROP_CXHSCROLL  = $0000002;
  WSB_PROP_CYHSCROLL  = $0000004;
  WSB_PROP_CXVSCROLL  = $0000008;
  WSB_PROP_CXHTHUMB   = $0000010;
  WSB_PROP_CYVTHUMB   = $0000020;
  WSB_PROP_VBKGColOR  = $0000040;
  WSB_PROP_HBKGColOR  = $0000080;
  WSB_PROP_VSTYLE     = $0000100;
  WSB_PROP_HSTYLE     = $0000200;
  WSB_PROP_WINSTYLE   = $0000400;
  WSB_PROP_PALETTE    = $0000800;
  WSB_PROP_MASK       = $0000FFF;

  FSB_FLAT_MODE       =    2;
  FSB_ENCARTA_MODE    =    1;
  FSB_REGULAR_MODE    =    0;
{$ENDIF}

type
  PHeaderSection = ^THeaderSection;
  THeaderSection = record
    FObject: TObject;
    Width: Integer;
    Title: string;
  end;

{$I DELPHIXE.INC}

function Max(a, b: Integer): Integer;
begin
  if a > b then
    Result := a
  else
    Result := b;
end;

function Min(a, b: Integer): Integer;
begin
  if a < b then
    Result := a
  else
    Result := b;
end;


{$IFDEF TMSDOTNET}
procedure TWMNotifyTT.SetToolTipText(Value: TToolTipText);
begin
  Marshal.StructureToPtr(TObject(Value), IntPtr(OriginalMessage.LParam), False);
end;

function TWMNotifyTT.GetToolTipText: TToolTipText;
begin
  Result := TToolTipText(Marshal.PtrToStructure(IntPtr(LParam), TypeOf(TToolTipText)));
end;
{$ENDIF}


procedure TCustomPlanner.SetComponentStyle(AStyle: TTMSStyle);
begin

  case AStyle of
    tsOffice2003Blue: SetStyle(2);
    tsOffice2003Olive: SetStyle(3);
    tsOffice2003Silver: SetStyle(4);
    tsOffice2003Classic: SetStyle(1);
    tsOffice2007Luna: SetStyle(8);
    tsOffice2007Obsidian: SetStyle(9);
    tsOffice2007Silver: SetStyle(10);
    tsWindowsXP: SetStyle(0);
    tsWhidbey: SetStyle(7);
    tsWindowsVista: SetStyle(11);
    tsWindows7: SetStyle(12);
    tsTerminal: SetStyle(13);
    tsOffice2010Blue: SetStyle(14);
    tsOffice2010Silver: SetStyle(15);
    tsOffice2010Black: SetStyle(16);
  end;

end;

procedure PlannerSetStyle(StyleIndex: Integer; Planner: TCustomPlanner);
begin
  case StyleIndex of
  // Windows XP
  0:begin
      Planner.SideBar.ActiveColor := clNone;
      Planner.SideBar.ActiveColorTo := clNone;
      Planner.Sidebar.Background := clBtnFace;
      Planner.Sidebar.BackgroundTo := clWhite;
      Planner.Sidebar.Occupied := clBlue;
      Planner.SideBar.OccupiedTo := clWhite;
      Planner.Sidebar.SeparatorLineColor := clGray;
      Planner.Sidebar.LineColor := clGray;
      Planner.Sidebar.Flat := true;
      Planner.Sidebar.Font.Color := clBlack;
      Planner.Header.ActiveColor := clNone;
      Planner.Header.ActiveColorTo := clNone;
      Planner.Header.Color := clBtnFace;
      Planner.Header.ColorTo := clWhite;
      Planner.Header.Flat := False;
      Planner.Header.Font.Color := clBlack;
      Planner.Footer.Color := clBtnFace;
      Planner.Footer.ColorTo := clWhite;
      Planner.Display.ColorActive := clWhite;
      Planner.Display.ColorNonActive := $00DEDEDE;
      Planner.Caption.Background := clGray;
      Planner.Caption.BackgroundTo := clWhite;
      Planner.SelectColor := clHighLight;
      Planner.TrackColor := clBlue;
      Planner.GridLineColor := $00CECECE;
      Planner.Display.HourLineColor := clGray;
      Planner.Caption.Font.Color := clWhite;      

      Planner.DefaultItem.ColorTo := $F7F7F7;
      Planner.DefaultItem.Color := clWhite;
      Planner.DefaultItem.SelectColorTo := clInfoBk;
      Planner.DefaultItem.SelectColor := clWhite;
      Planner.DefaultItem.CaptionBkgTo := clSilver;
      Planner.DefaultItem.CaptionBkg := clWhite;
      Planner.DefaultItem.TrackColor := clBlue;
    end;
  // Office 2002
  1:begin
      Planner.SideBar.ActiveColor := clNone;
      Planner.SideBar.ActiveColorTo := clNone;
      Planner.Sidebar.Background := clBtnFace;
      Planner.Sidebar.BackgroundTo := clNone;
      Planner.Sidebar.Occupied := clBlue;
      Planner.SideBar.OccupiedTo := clNone;
      Planner.Sidebar.SeparatorLineColor := clGray;
      Planner.Sidebar.LineColor := clGray;
      Planner.Sidebar.Flat := true;
      Planner.Sidebar.Font.Color := clBlack;
      Planner.Header.ActiveColor := clNone;
      Planner.Header.ActiveColorTo := clNone;
      Planner.Header.Color := clBtnFace;
      Planner.Header.ColorTo := clNone;
      Planner.Header.Flat := False;
      Planner.Header.Font.Color := clBlack;
      Planner.Footer.Color := clBtnFace;
      Planner.Footer.ColorTo := clNone;
      Planner.Display.ColorActive := $80FFFF;
      Planner.Display.ColorNonActive := $40C0C0;
      Planner.Caption.Background := clGray;
      Planner.Caption.BackgroundTo := clNone;
      Planner.SelectColor := clHighLight;
      Planner.TrackColor := clBlue;

      Planner.DefaultItem.ColorTo := $F7F7F7;
      Planner.DefaultItem.Color := clWhite;
      Planner.DefaultItem.SelectColorTo := clInfoBk;
      Planner.DefaultItem.SelectColor := clWhite;
      Planner.DefaultItem.CaptionBkgTo := clSilver;
      Planner.DefaultItem.CaptionBkg := clWhite;
      Planner.DefaultItem.TrackColor := clBlue;
    end;
  // Office 2003 (blue)
  2:begin
      Planner.SideBar.ActiveColor := $D8E9EC;
      Planner.SideBar.ActiveColorTo := $5DCBF9;
      Planner.Sidebar.Background := $FCEAD9;
      Planner.Sidebar.BackgroundTo := $E4A47C;
      Planner.Sidebar.Occupied := $81CCF9;
      Planner.SideBar.OccupiedTo := $5EB3FA;
      Planner.Sidebar.SeparatorLineColor := clGray;
      Planner.Sidebar.LineColor := clGray;
      Planner.Sidebar.Flat := true;
      Planner.Sidebar.Font.Color := clBlack;
      Planner.Header.ActiveColor := $D8E9EC;
      Planner.Header.ActiveColorTo := $5DCBF9;
      Planner.Header.Color := $FCEAD9;
      Planner.Header.ColorTo := $E4A47C;
      Planner.Header.Flat := False;
      Planner.Header.Font.Color := clBlack;
      Planner.Footer.Color := $FCEAD9;
      Planner.Footer.ColorTo := $E4A47C;
      Planner.Display.ColorActive := $D0FCFD;
      Planner.Display.ColorNonActive := $B8F5FF;
      Planner.Caption.Background := $D58456;
      Planner.Caption.BackgroundTo := $943C07;
      Planner.SelectColor := clHighLight;
      Planner.TrackColor := clBlue;

      Planner.Caption.Font.Color := clWhite;

      Planner.GridLineColor := $B1E4F3;
      Planner.Display.HourLineColor := $98D0EA;

      Planner.DefaultItem.Color := $FCEAD9;
      Planner.DefaultItem.ColorTo := $E4A47C;
      Planner.DefaultItem.SelectColor := $81CCF9;
      Planner.DefaultItem.SelectColorTo := $5EB3FA;
      Planner.DefaultItem.CaptionBkg := $D58456;
      Planner.DefaultItem.CaptionBkgTo := $943C07;
      Planner.DefaultItem.TrackColor := clBlue;
    end;
  // Office 2003 (olive)
  3:begin
      Planner.SideBar.ActiveColor := $D8E9EC;
      Planner.SideBar.ActiveColorTo := $5DCBF9;
      Planner.Sidebar.Background := $CFF0EA;
      Planner.Sidebar.BackgroundTo := $8CC0B1;
      Planner.Sidebar.Occupied := $087FE8;
      Planner.SideBar.OccupiedTo := $7CDAF7;
      Planner.Sidebar.SeparatorLineColor := clOlive;
      Planner.Sidebar.LineColor := clOlive;
      Planner.Sidebar.Flat := true;
      Planner.Sidebar.Font.Color := clBlack;
      Planner.Header.ActiveColor := $D8E9EC;
      Planner.Header.ActiveColorTo := $5DCBF9;
      Planner.Header.Color := $CFF0EA;
      Planner.Header.ColorTo := $8CC0B1;
      Planner.Header.Flat := False;
      Planner.Header.Font.Color := clBlack;
      Planner.Footer.Color := $CFF0EA;
      Planner.Footer.ColorTo := $8CC0B1;
      Planner.Display.ColorActive := $D0FCFD;
      Planner.Display.ColorNonActive := $B8F5FF;
      Planner.Caption.Background := $82C0AF;
      Planner.Caption.BackgroundTo := $447A63;
      Planner.SelectColor := clHighLight;
      Planner.TrackColor := clOlive;
      Planner.GridLineColor := $B1E4F3;
      Planner.Display.HourLineColor := $98D0EA;
      Planner.Caption.Font.Color := clWhite;
      Planner.DefaultItem.Color := $E4F1F2;
      Planner.DefaultItem.ColorTo := $AADADA;
      Planner.DefaultItem.SelectColor := $81CCF9;
      Planner.DefaultItem.SelectColorTo := $5EB3FA;
//      Planner.DefaultItem.CaptionBkg := $D58456;
//      Planner.DefaultItem.CaptionBkgTo := $943C07;
      Planner.DefaultItem.CaptionBkg := $82C0AF;
      Planner.DefaultItem.CaptionBkgTo := $447A63;
      Planner.DefaultItem.TrackColor := clBlue;
    end;
  // Office 2003 (silver)
  4:begin
      Planner.SideBar.ActiveColor := $D8E9EC;
      Planner.SideBar.ActiveColorTo := $5DCBF9;
      Planner.Sidebar.Background := $ECE2E1;
      Planner.Sidebar.BackgroundTo := $B39698;
      Planner.Sidebar.Occupied := $81CCF9;
      Planner.SideBar.OccupiedTo := $5EB3FA;
      Planner.Sidebar.SeparatorLineColor := clGray;
      Planner.Sidebar.LineColor := clGray;
      Planner.Sidebar.Flat := true;
      Planner.Sidebar.Font.Color := clBlack;
      Planner.Header.ActiveColor := $D8E9EC;
      Planner.Header.ActiveColorTo := $5DCBF9;
      Planner.Header.Color := $ECE2E1;
      Planner.Header.ColorTo := $B39698;
      Planner.Header.Flat := False;
      Planner.Header.Font.Color := clBlack;
      Planner.Footer.Color := $ECE2E1;
      Planner.Footer.ColorTo := $B39698;
      Planner.Display.ColorActive := $D0FCFD;
      Planner.Display.ColorNonActive := $B8F5FF;
      Planner.Caption.Background := $BDA4A5;
      Planner.Caption.BackgroundTo := $957475;
      Planner.SelectColor := clHighLight;
      Planner.TrackColor := clBlue;
      Planner.GridLineColor := $B1E4F3;
      Planner.Display.HourLineColor := $98D0EA;
      Planner.Caption.Font.Color := clWhite;
      Planner.DefaultItem.Color := $F7F3F3;
      Planner.DefaultItem.ColorTo := $E6D8D8;
      Planner.DefaultItem.SelectColor := $81CCF9;
      Planner.DefaultItem.SelectColorTo := $5EB3FA;
      // Planner.DefaultItem.CaptionBkg := $D58456;
      // Planner.DefaultItem.CaptionBkgTo := $943C07;
      Planner.DefaultItem.CaptionBkg := $BDA4A5;
      Planner.DefaultItem.CaptionBkgTo := $957475;
      Planner.DefaultItem.TrackColor := clBlue;
    end;
  // Flat style
  5:begin
      Planner.SideBar.ActiveColor := clNone;
      Planner.SideBar.ActiveColorTo := clNone;
      Planner.Sidebar.Background := clBtnFace;
      Planner.Sidebar.BackgroundTo := clNone;
      Planner.Sidebar.Occupied := clBlue;
      Planner.SideBar.OccupiedTo := clNone;
      Planner.Sidebar.SeparatorLineColor := clGray;
      Planner.Sidebar.LineColor := clGray;
      Planner.Sidebar.Flat := True;
      Planner.Sidebar.Font.Color := clBlack;
      Planner.Header.ActiveColor := clNone;
      Planner.Header.ActiveColorTo := clNone;
      Planner.Header.Color := clBtnFace;
      Planner.Header.ColorTo := clNone;
      Planner.Header.Flat := True;
      Planner.Header.Font.Color := clBlack;
      Planner.Footer.Color := clBtnFace;
      Planner.Footer.ColorTo := clNone;
      Planner.Display.ColorActive := clWhite;
      Planner.Display.ColorNonActive := clSilver;
      Planner.Caption.Background := clGray;
      Planner.Caption.BackgroundTo := clNone;
      Planner.SelectColor := clHighLight;
      Planner.TrackColor := clBlue;

      Planner.DefaultItem.ColorTo := $F7F7F7;
      Planner.DefaultItem.Color := clWhite;
      Planner.DefaultItem.SelectColorTo := clInfoBk;
      Planner.DefaultItem.SelectColor := clWhite;
      Planner.DefaultItem.CaptionBkgTo := clSilver;
      Planner.DefaultItem.CaptionBkg := clWhite;
      Planner.DefaultItem.TrackColor := clBlue;
    end;
  // Avant garde
  6:begin
      Planner.SideBar.ActiveColor := clNone;
      Planner.SideBar.ActiveColorTo := clNone;
      Planner.Sidebar.Background := $006580DA;
      Planner.Sidebar.BackgroundTo := $00F807F1;
      Planner.Sidebar.Occupied := clBlue;
      Planner.SideBar.OccupiedTo := clNone;
      Planner.Sidebar.SeparatorLineColor := clGray;
      Planner.Sidebar.LineColor := clWhite;
      Planner.Sidebar.Font.Color := clWhite;
      Planner.Sidebar.Flat := True;
      Planner.Header.ActiveColor := clNone;
      Planner.Header.ActiveColorTo := clNone;
      Planner.Header.Color := $006580DA;
      Planner.Header.ColorTo := $00F807F1;
      Planner.Header.Flat := True;
      Planner.Footer.Color := clBtnFace;
      Planner.Footer.ColorTo := clNone;
      Planner.Display.ColorActive := $00FFD9B3;
      Planner.Display.ColorNonActive := $00F8898E;
      Planner.Caption.Background := $00804000;
      Planner.Caption.BackgroundTo := $00F8898E;
      Planner.SelectColor := clHighLight;
      Planner.TrackColor := clWhite;

      Planner.DefaultItem.ColorTo := $00FFD9B3;
      Planner.DefaultItem.Color := $00DEF9B9;
      Planner.DefaultItem.SelectColorTo := clInfoBk;
      Planner.DefaultItem.SelectColor := clWhite;
      Planner.DefaultItem.CaptionBkgTo := $006580DA;
      Planner.DefaultItem.CaptionBkg := $00F807F1;
      Planner.DefaultItem.TrackColor := clWhite;
    end;
  // Whidbey
  7:begin
      Planner.SideBar.ActiveColor := $D8E9EC;
      Planner.SideBar.ActiveColorTo := $5DCBF9;
      Planner.Sidebar.Background := $00F5F9FA;
      Planner.Sidebar.BackgroundTo := $00A8C0C0;
      Planner.Sidebar.Occupied := $81CCF9;
      Planner.SideBar.OccupiedTo := $5EB3FA;

      Planner.Sidebar.SeparatorLineColor := clGray;
      Planner.Sidebar.LineColor := clGray;
      Planner.Sidebar.Flat := true;
      Planner.Sidebar.Font.Color := clBlack;
      Planner.Header.ActiveColor := $D8E9EC;
      Planner.Header.ActiveColorTo := $5DCBF9;
      Planner.Header.Color := $00F5F9FA;
      Planner.Header.ColorTo := $00A8C0C0;
      Planner.Header.Flat := False;
      Planner.Header.Font.Color := clBlack;
      Planner.Footer.Color := $00F5F9FA;
      Planner.Footer.ColorTo := $00A8C0C0;

      Planner.Display.ColorActive := $D0FCFD;
      Planner.Display.ColorNonActive := $B8F5FF;

      //Planner.Caption.Background := $BDA4A5;
      //Planner.Caption.BackgroundTo := $957475;

      Planner.Caption.Background := $EBEEEF;
      Planner.Caption.BackgroundTo := $7E9898;

      Planner.SelectColor := clHighLight;
      Planner.TrackColor := clBlue;
      Planner.GridLineColor := $B1E4F3;
      Planner.Display.HourLineColor := $98D0EA;
      Planner.Caption.Font.Color := clWhite;
      Planner.DefaultItem.Color := $00F5F9FA;
      Planner.DefaultItem.ColorTo := $00A8C0C0;

      Planner.DefaultItem.SelectColor := $81CCF9;
      Planner.DefaultItem.SelectColorTo := $5EB3FA;
      //Planner.DefaultItem.CaptionBkg := $D58456;
      //Planner.DefaultItem.CaptionBkgTo := $943C07;
      Planner.DefaultItem.CaptionBkg := $BDA4A5;
      Planner.DefaultItem.CaptionBkgTo := $957475;
      Planner.DefaultItem.TrackColor := clBlue;

     end;
   // Office 2007 Luna
   8:
     begin
      Planner.SideBar.ActiveColor := $9DD8F9;
      Planner.SideBar.ActiveColorTo := $5EC1F1;
      Planner.Sidebar.Background := $F2E4D5;//$FBF9F6;//$FFEFE3;
      Planner.Sidebar.BackgroundTo := $F2E4D5;//$E8DBD2;//$FFD2AF;
      Planner.Sidebar.Occupied := $7CDAF7;
      Planner.SideBar.OccupiedTo := $087FE8;
      Planner.Sidebar.SeparatorLineColor := $FFD2AF;
      Planner.Sidebar.LineColor := $CF9365;
      Planner.Sidebar.Flat := true;
      Planner.Sidebar.Font.Color := $CF9365;
      Planner.Header.ActiveColor := $9DD8F9;
      Planner.Header.ActiveColorTo := $5EC1F1;
      Planner.Header.Color := $F6ECE4;//$FBF9F6;//$FFEFE3;
      Planner.Header.ColorTo := $EBD4C2;//$E8DBD2;//$FFD2AF;
      Planner.Header.Flat := false;
      Planner.Header.Font.Color := clBlack;
      Planner.Header.ItemColor := $E1BFA5;
      Planner.Header.LineColor := $CF9365;

      Planner.Footer.Color := $F6ECE4;//$FBF9F6;//$FFEFE3;
      Planner.Footer.ColorTo := $EBD4C2;//$E8DBD2;//$FFD2AF;
      Planner.Display.ColorActive := clWhite;
      Planner.Display.ColorNonActive := $F7EDE6;
      Planner.Caption.Background := $FFEFE3;
      Planner.Caption.BackgroundTo := $FFD2AF;
      Planner.Caption.GradientDirection := gdVertical;

      Planner.Caption.Font.Color := $723708;

      Planner.SelectColor := $7A4C29;
      Planner.TrackColor := clBlue;

      Planner.GridLineColor := $F1E1D5;
      Planner.Display.HourLineColor := $E1BFA5;
      Planner.ShadowColor := $DFDFDF;

      Planner.DefaultItem.Color := clWhite;
      Planner.DefaultItem.ColorTo := $EAD3C1;
      Planner.DefaultItem.SelectColor := $BBEEFF;
      Planner.DefaultItem.SelectColorTo := $78DAFF;
      Planner.DefaultItem.CaptionBkg := $FFEFE3;
      Planner.DefaultItem.CaptionBkgTo := $FFD2AF;
      Planner.DefaultItem.TrackColor := $AD7C56;
      Planner.DefaultItem.BorderColor := $AD7C56;
      Planner.DefaultItem.TrackSelectColor := clBlack;      
     end;
   // Office 2007 Obsidian
   9:
     begin
      Planner.SideBar.ActiveColor := $9DD8F9;
      Planner.SideBar.ActiveColorTo := $5EC1F1;
      Planner.Sidebar.Background := $EBEBEB;//$F7F7F7;//$F2F1F0;
      Planner.Sidebar.BackgroundTo := $EBEBEB;//$DEDEDE;//$C9C2BD;
      Planner.Sidebar.Occupied := $7CDAF7;
      Planner.SideBar.OccupiedTo := $087FE8;
      Planner.Sidebar.SeparatorLineColor := $5C534C;
      Planner.Sidebar.LineColor := $5C534C;
      Planner.Sidebar.Flat := true;
      Planner.Sidebar.Font.Color := $5C534C;

      Planner.Header.ActiveColor := $9DD8F9;
      Planner.Header.ActiveColorTo := $5EC1F1;
      Planner.Header.Color := $F6ECE4;//$F7F7F7;//$F2F1F0;
      Planner.Header.ColorTo := $EBD4C2;//$DEDEDE;//$C9C2BD;
      Planner.Header.Flat := False;
      Planner.Header.Font.Color := $5C534C;
      Planner.Header.ItemColor := $E1BFA5;
      Planner.Header.LineColor := $CF9365;

      Planner.Footer.Color := $F6ECE4;//$F7F7F7;//$F2F1F0;
      Planner.Footer.ColorTo := $EBD4C2;//$DEDEDE;//$C9C2BD;
      Planner.Display.ColorActive := clWhite;
      Planner.Display.ColorNonActive := $F7EDE6;
      Planner.Caption.Background := $F2F1F0;
      Planner.Caption.BackgroundTo := $C9C2BD;
      Planner.Caption.GradientDirection := gdVertical;
      Planner.Caption.Font.Color := clBlack;

      Planner.SelectColor := $7A4C29;
      Planner.TrackColor := clBlue;

      Planner.GridLineColor := $F1E1D5;
      Planner.Display.HourLineColor := $E1BFA5;
      Planner.ShadowColor := $DFDFDF;     

      Planner.DefaultItem.Color := clwhite;
      Planner.DefaultItem.ColorTo := $EAD3C1;
      Planner.DefaultItem.SelectColor := $BBEEFF;
      Planner.DefaultItem.SelectColorTo := $78DAFF;
      Planner.DefaultItem.CaptionBkg := $F2F1F0;
      Planner.DefaultItem.CaptionBkgTo := $C9C2BD;
      Planner.DefaultItem.TrackColor := $AD7C56;
      Planner.DefaultItem.BorderColor := $AD7C56;
      Planner.DefaultItem.TrackSelectColor := clBlack;
     end;
   // Office 2007 Silver
   10:
     begin
      Planner.SideBar.ActiveColor := $9DD8F9;
      Planner.SideBar.ActiveColorTo := $5EC1F1;
      Planner.Sidebar.Background := $F2F1F0;
      Planner.Sidebar.BackgroundTo := $F2F1F0;
      Planner.Sidebar.Occupied := $7CDAF7;
      Planner.SideBar.OccupiedTo := $087FE8;
      Planner.Sidebar.SeparatorLineColor := $FFD2AF;
      Planner.Sidebar.LineColor := $74706F;
      Planner.Sidebar.Flat := true;
      Planner.Sidebar.Font.Color := $74706F;

      Planner.Header.ActiveColor := $9DD8F9;
      Planner.Header.ActiveColorTo := $5EC1F1;
      Planner.Header.Color := $F8F7F6;
      Planner.Header.ColorTo := $E7DFDA;
      Planner.Header.Flat := false;
      Planner.Header.Font.Color := clBlack;
      Planner.Header.ItemColor := clSilver;
      Planner.Header.LineColor := clSilver;

      Planner.Footer.Color := Planner.Header.Color;
      Planner.Footer.ColorTo := Planner.Header.ColorTo;

      Planner.Display.ColorActive := clWhite;
      Planner.Display.ColorNonActive := $ECEAE8;
      Planner.Caption.Background := $FAEEEB;
      Planner.Caption.BackgroundTo := $D3C9C7;
      Planner.Caption.GradientDirection := gdVertical;
      Planner.Caption.Font.Color := clBlack;

      Planner.SelectColor := $5C534C;
      Planner.TrackColor := clBlue;   
      Planner.GridLineColor := $A49991;
      Planner.Display.HourLineColor := $D1CBC7;
      Planner.ShadowColor := $DFDFDF;

      Planner.DefaultItem.Color := clWhite;
      Planner.DefaultItem.ColorTo := $DBD7D4;
      Planner.DefaultItem.SelectColor := $BBEEFF;
      Planner.DefaultItem.SelectColorTo := $78DAFF;
      Planner.DefaultItem.CaptionBkg := $FAEEEB;
      Planner.DefaultItem.CaptionBkgTo := $D3C9C7;
      Planner.DefaultItem.TrackColor := $A49991;
      Planner.DefaultItem.BorderColor := clBlack;
      Planner.DefaultItem.TrackSelectColor := clBlack;
     end;
     // WindowsVista
  11:begin
      Planner.SideBar.ActiveColor := $FEF9F0;
      Planner.SideBar.ActiveColorTo := $FDF0D7;
      Planner.Sidebar.Background := $FFFDF9;
      Planner.Sidebar.BackgroundTo := $FFFAF0;
      Planner.Sidebar.Occupied := $FFFFFF;
      Planner.SideBar.OccupiedTo := $FFFFFF;
      Planner.Sidebar.SeparatorLineColor := $FDDE99;
      Planner.Sidebar.LineColor := $FDDE99;
      Planner.Sidebar.Flat := true;
      Planner.Sidebar.Font.Color := clBlack;
      Planner.Header.ActiveColor := $FEF9F0;
      Planner.Header.ActiveColorTo := $FDF0D7;
      Planner.Header.Color := $FFFDF9;
      Planner.Header.ColorTo := $FFFAF0;
      Planner.Header.Flat := False;
      Planner.Header.Font.Color := clBlack;
      Planner.Footer.Color := $FFFDF9;
      Planner.Footer.ColorTo := $FFFAF0;
      Planner.Display.ColorActive := $FDF8F1;
      Planner.Display.ColorNonActive := $FFFFFF;
      Planner.Caption.Background := $FDF8F1;
      Planner.Caption.BackgroundTo := $FCEFD5;
      Planner.SelectColor := $F5D089;
      Planner.TrackColor := $FCEFD5;
      Planner.GridLineColor := $FCF2DA;
      Planner.Display.HourLineColor := $FEDF9A;
      Planner.Caption.Font.Color := clBlack;

      Planner.DefaultItem.ColorTo := $FFFFFF;
      Planner.DefaultItem.Color := $FFFFFF;
      Planner.DefaultItem.SelectColorTo := $FDF0D7;
      Planner.DefaultItem.SelectColor := $FEF9F0;
      Planner.DefaultItem.CaptionBkgTo := $F5D089;
      Planner.DefaultItem.CaptionBkg := $F5D089;
      Planner.DefaultItem.TrackColor := $FCEFD5;
      Planner.DefaultItem.TrackSelectColor := $00AD7C56;
    end;
    // Windows7
  12:begin
      Planner.SideBar.ActiveColor := $FCEBDC;
      Planner.SideBar.ActiveColorTo := $FCDBC1;
      Planner.Sidebar.Background := $FDFBFA;
      Planner.Sidebar.BackgroundTo := $FDF3EB;
      Planner.Sidebar.Occupied := $FFFFFF;
      Planner.SideBar.OccupiedTo := $FFFFFF;
      Planner.Sidebar.SeparatorLineColor := $CEA27D;
      Planner.Sidebar.LineColor := $CEA27D;
      Planner.Sidebar.Flat := true;
      Planner.Sidebar.Font.Color := clBlack;
      Planner.Header.ActiveColor := $FCEBDC;
      Planner.Header.ActiveColorTo := $FCDBC1;
      Planner.Header.Color := $FDFBFA;
      Planner.Header.ColorTo := $FDF3EB;
      Planner.Header.Flat := False;
      Planner.Header.Font.Color := clBlack;
      Planner.Footer.Color := $FDFBFA;
      Planner.Footer.ColorTo := $FDF3EB;
      Planner.Display.ColorActive := $FCEBDC;
      Planner.Display.ColorNonActive := $FFFFFF;
      Planner.Caption.Background := $FCEBDC;
      Planner.Caption.BackgroundTo := $FCDBC1;
      Planner.SelectColor := $F5D089;
      Planner.TrackColor := $FCDBC1;
      Planner.GridLineColor := $FBD6B8;
      Planner.Display.HourLineColor := $CEA27D;
      Planner.Caption.Font.Color := clBlack;

      Planner.DefaultItem.ColorTo := $FFFFFF;
      Planner.DefaultItem.Color := $FFFFFF;
      Planner.DefaultItem.SelectColorTo := $FCEBDC;
      Planner.DefaultItem.SelectColor := $FCDBC1;
      Planner.DefaultItem.CaptionBkgTo := $F5D089;
      Planner.DefaultItem.CaptionBkg := $F5D089;
      Planner.DefaultItem.TrackColor := $FCDBC1;
      Planner.DefaultItem.TrackSelectColor := $00AD7C56;
    end;
    // Terminal
  13:begin
      Planner.SideBar.ActiveColor := clSilver;
      Planner.SideBar.ActiveColorTo := clSilver;
      Planner.Sidebar.Background := clBtnFace;
      Planner.Sidebar.BackgroundTo := clBtnFace;
      Planner.Sidebar.Occupied := clWhite;
      Planner.SideBar.OccupiedTo := clWhite;
      Planner.Sidebar.SeparatorLineColor := clGray;
      Planner.Sidebar.LineColor := clGray;
      Planner.Sidebar.Flat := true;
      Planner.Sidebar.Font.Color := clBlack;
      Planner.Header.ActiveColor := clSilver;
      Planner.Header.ActiveColorTo := clSilver;
      Planner.Header.Color := clBtnFace;
      Planner.Header.ColorTo := clBtnFace;
      Planner.Header.Flat := False;
      Planner.Header.Font.Color := clBlack;
      Planner.Footer.Color := clBtnFace;
      Planner.Footer.ColorTo := clBtnFace;
      Planner.Display.ColorActive := clWhite;
      Planner.Display.ColorNonActive := clBtnFace;
      Planner.Caption.Background := clGray;
      Planner.Caption.BackgroundTo := clGray;
      Planner.SelectColor := clHighLight;
      Planner.TrackColor := clHighLight;
      Planner.GridLineColor := clSilver;
      Planner.Display.HourLineColor := clGray;
      Planner.Caption.Font.Color := clWhite;

      Planner.DefaultItem.ColorTo := clWhite;
      Planner.DefaultItem.Color := clWhite;
      Planner.DefaultItem.SelectColorTo := clBtnFace;
      Planner.DefaultItem.SelectColor := clBtnFace;
      Planner.DefaultItem.CaptionBkgTo := clBtnFace;
      Planner.DefaultItem.CaptionBkg := clBtnFace;
      Planner.DefaultItem.TrackColor := clHighLight;
      Planner.DefaultItem.TrackSelectColor := clGray;
    end;
     // Office2010Blue
  14:begin
      Planner.SideBar.ActiveColor := $7BEEFF;
      Planner.SideBar.ActiveColorTo := $6BD8FF;
      Planner.Sidebar.Background := clWhite;
      Planner.Sidebar.BackgroundTo := clWhite;
      Planner.Sidebar.Occupied := $6CD0FF;
      Planner.SideBar.OccupiedTo := $6CD0FF;
      Planner.Sidebar.SeparatorLineColor := $BD9D84;
      Planner.Sidebar.LineColor := $BD9D84;
      Planner.Sidebar.Flat := true;
      Planner.Sidebar.Font.Color := $5B391E;
      Planner.Header.ActiveColor := $7BEEFF;
      Planner.Header.ActiveColorTo := $6BD8FF;
      Planner.Header.Color := $E1BFA5;
      Planner.Header.ColorTo := $E1BFA5;
      Planner.Header.Flat := False;
      Planner.Header.Font.Color :=$5B391E;
      Planner.Footer.Color := $E1BFA5;
      Planner.Footer.ColorTo := $E1BFA5;
      Planner.Display.ColorActive := clWhite;
      Planner.Display.ColorNonActive := $F7EDE6;
      Planner.Caption.Background := $FDF6EF;
      Planner.Caption.BackgroundTo := $F0DAC7;
      Planner.SelectColor := $7A4C29;
      Planner.TrackColor := $6BD8FF;
      Planner.GridLineColor := $F1E1D5;
      Planner.Display.HourLineColor := $E1BFA5;
      Planner.Caption.Font.Color := $5B391E;

      Planner.DefaultItem.ColorTo := $E6CAB5;
      Planner.DefaultItem.Color := $F6E8DF;
      Planner.DefaultItem.SelectColorTo := $E6CAB5;
      Planner.DefaultItem.SelectColor := $F6E8DF;
      Planner.DefaultItem.CaptionBkgTo := $F0DAC7;
      Planner.DefaultItem.CaptionBkg := $FDF6EF;
      Planner.DefaultItem.TrackColor := clBlack;
      Planner.DefaultItem.TrackSelectColor := clBlack;
    end;
     // Office2010Silver
  15:begin
      Planner.SideBar.ActiveColor := $7BEEFF;
      Planner.SideBar.ActiveColorTo := $6BD8FF;
      Planner.Sidebar.Background := clWhite;
      Planner.Sidebar.BackgroundTo := clWhite;
      Planner.Sidebar.Occupied := $6CD0FF;
      Planner.SideBar.OccupiedTo := $6CD0FF;
      Planner.Sidebar.SeparatorLineColor := $B8B0A9;
      Planner.Sidebar.LineColor := $B8B0A9;
      Planner.Sidebar.Flat := true;
      Planner.Sidebar.Font.Color := $3B3B3B;
      Planner.Header.ActiveColor := $7BEEFF;
      Planner.Header.ActiveColorTo := $6BD8FF;
      Planner.Header.Color := $EFDBCE;
      Planner.Header.ColorTo := $EFDBCE;
      Planner.Header.Flat := False;
      Planner.Header.Font.Color :=$3B3B3B;
      Planner.Footer.Color := $EFDBCE;
      Planner.Footer.ColorTo := $EFDBCE;
      Planner.Display.ColorActive := clWhite;
      Planner.Display.ColorNonActive := $F7EDE6;
      Planner.Caption.Background := $FFFFFF;
      Planner.Caption.BackgroundTo := $EDE5E0;
      Planner.SelectColor := $5C534C;
      Planner.TrackColor := $6BD8FF;
      Planner.GridLineColor := $ECE0D8;
      Planner.Display.HourLineColor := $E1BFA5;
      Planner.Caption.Font.Color := $3B3B3B;

      Planner.DefaultItem.ColorTo := $D1CBC6;
      Planner.DefaultItem.Color := $E8E8E8;
      Planner.DefaultItem.SelectColorTo := $D1CBC6;
      Planner.DefaultItem.SelectColor := $E8E8E8;
      Planner.DefaultItem.CaptionBkgTo := $EDE5E0;
      Planner.DefaultItem.CaptionBkg := $FFFFFF;
      Planner.DefaultItem.TrackColor := clBlack;
      Planner.DefaultItem.TrackSelectColor := clBlack;
    end;
     // Office2010Black
  16:begin
      Planner.SideBar.ActiveColor := $7BEEFF;
      Planner.SideBar.ActiveColorTo := $6BD8FF;
      Planner.Sidebar.Background := clWhite;
      Planner.Sidebar.BackgroundTo := clWhite;
      Planner.Sidebar.Occupied := $6CD0FF;
      Planner.SideBar.OccupiedTo := $6CD0FF;
      Planner.Sidebar.SeparatorLineColor := $B8B8B8;
      Planner.Sidebar.LineColor := $B8B8B8;
      Planner.Sidebar.Flat := true;
      Planner.Sidebar.Font.Color := clBlack;
      Planner.Header.ActiveColor := $7BEEFF;
      Planner.Header.ActiveColorTo := $6BD8FF;
      Planner.Header.Color := $EFDBCE;
      Planner.Header.ColorTo := $EFDBCE;
      Planner.Header.Flat := False;
      Planner.Header.Font.Color :=clBlack;
      Planner.Footer.Color := $EFDBCE;
      Planner.Footer.ColorTo := $EFDBCE;
      Planner.Display.ColorActive := clWhite;
      Planner.Display.ColorNonActive := $F7EDE6;
      Planner.Caption.Background := $BFBFBF;
      Planner.Caption.BackgroundTo := $919191;
      Planner.SelectColor := $5C534C;
      Planner.TrackColor := $6BD8FF;
      Planner.GridLineColor := $ECE0D8;
      Planner.Display.HourLineColor := $E1BFA5;
      Planner.Caption.Font.Color := $D7D7D6;

      Planner.DefaultItem.ColorTo := $D2CCC7;
      Planner.DefaultItem.Color := $E7E7E7;
      Planner.DefaultItem.SelectColorTo := $D2CCC7;
      Planner.DefaultItem.SelectColor := $E7E7E7;
      Planner.DefaultItem.CaptionBkgTo := $919191;
      Planner.DefaultItem.CaptionBkg := $BFBFBF;
      Planner.DefaultItem.TrackColor := clBlack;
      Planner.DefaultItem.TrackSelectColor := clBlack;
    end;
  end;
end;


function Clip(const Value: Integer; const RangeLow, RangeHigh: Integer): Integer;
begin
  if Value > RangeHigh then
    Result := RangeHigh
  else if Value < RangeLow then
    Result := $00DEF9B9
  else
    Result := Value;
end;

type
  TColorRecord = record
    RedValue: Byte;    //  clRed = TColor($0000FF);   Low byte
    GreenValue: Byte;  //  clLime = TColor($00FF00);  Middle byte
    BlueValue: Byte;   //  clBlue = TColor($FF0000);  High byte
    SystemValue: Byte; //  becomes zero when calling ColorToRgb
  end;

function ColorToHtmlHexBgColor(const Value: TColor): string;
const
  HtmlHexBgColor = ' BGCOLOR="#RRGGBB"';
  HexDigit: array[0..$F] of Char = '0123456789ABCDEF';
{$IFDEF TMSDOTNET}
var
  C: Cardinal;
  CR: TColorRecord;
{$ENDIF}

begin
 //  HTML Color looks like this: #RRGGBB
  {$IFDEF TMSDOTNET}
  Result := HtmlHexBgColor;
  C := ColorToRGB(Value);
  CR.RedValue := (C and $FF);
  CR.GreenValue := (C shr 8) and $FF;
  CR.BlueValue := (C shr 16) and $FF;
  with CR do
  {$ENDIF}

  {$IFNDEF TMSDOTNET}
  with TColorRecord(ColorToRGb(Value)) do
  {$ENDIF}
  begin
    Result := HtmlHexBgColor;
    Result[12] := HexDigit[RedValue shr 4];
    Result[13] := HexDigit[RedValue and $F];
    Result[14] := HexDigit[GreenValue shr 4];
    Result[15] := HexDigit[GreenValue and $F];
    Result[16] := HexDigit[BlueValue shr 4];
    Result[17] := HexDigit[BlueValue and $F];
  end;
end;

const
  CStyleLF = '\n';
  RegularCRLF = #13#10;
  HtmlBreak = '<BR>';
  RtfStart = '{\';
  HtmlEndTagStart = '</';
  HtmlNonBreakingSpace = '&nbsp;';

function ReplaceCLFWith(const Value: string; const Replacement: string): string;
var
  CLFPos: Integer;
begin
  Result := Value;
  CLFPos := Pos(CStyleLF, Result);
  while CLFPos > 0 do
  begin
    Result := Copy(Result, 1, CLFPos - 1) +
      RegularCRLF +
      Copy(Result, CLFPos + 2, Length(Result));
    CLFPos := Pos(CStyleLF, Result);
  end;
end;

function CLFToLF(Value: string): string;
begin
  Result := ReplaceCLFWith(Value, RegularCRLF);
end;

function CLToBR(Value: string): string;
begin
  Result := ReplaceCLFWith(Value, HtmlBreak);
end;

function IsRtf(const Value: string): Boolean;
begin
  Result := (Pos(RtfStart, Value) = 1);
end;

function IsHtml(APlannerItem: TPlannerItem; const Value: string;Caption:boolean): Boolean;
begin
  Result := (Pos(HTMLEndTagStart, Value) > 0);
  if (APlannerItem.InplaceEdit = peForm) and not Caption then
    Result := True;
end;

(*
function PlanTimeToStr(HourType: THourType; MinutesValue: Cardinal): string;
var
  Hours, Minutes: Integer;
begin
  Hours := MinutesValue div 60;
  Minutes := MinutesValue mod 60;
  Hours := Hours mod 24;

  if (HourType = ht12hrs) then
  begin
    if (Hours >= 12) then
      Result := TimePMString
    else
      Result := TimeAMString;
    Result := ' ' + Result;
    if (Hours > 12) then
      Hours := Hours - 12
  end
  else
    Result := '';

  Result := Format('%d%s%.2d%s', [Hours, TimeSeparator, Minutes, Result]);
end;
*)

{ TCustomPlanner }

constructor TCustomPlanner.Create(AOwner: TComponent);
var
  Bitmap: TBitmap;
  {$IFNDEF TMSDOTNET}
  PlannerColorArrayPointer: PPlannerColorArray;
  {$ENDIF}
  {$IFDEF TMSDOTNET}
  PlannerColorArrayPointer: TPlannerColorArrayObject;
  {$ENDIF}
  ColorIndex: Integer;

begin

{$IFDEF ACTIVEXDEBUG}
  ShowMessage('TPlanner Create Start');
{$ENDIF}
  inherited Create(AOwner);
  Width := 350;
  Height := 300;
  FHTMLFactor := 1.0;
  FScrollDelay := 50;
  FMaxHintWidth := 240;
  FFont := TFont.Create;
  FWheelDelta := 1;
  FFont.OnChange := PlanFontChanged;
  FRichEdit := TPlannerRichEdit.Create(Self);
  FNavigatorButtons := TNavigatorButtons.Create(Self);
  FHeader := TAdvHeader.Create(Self);
  FFooter := TAdvFooter.Create(Self);
{$IFDEF DELPHI4_LVL}
  FHeader.DoubleBuffered := True;
  FFooter.DoubleBuffered := True;

  FHeader.OnHeaderHint := DoHeaderHint;
  FFooter.OnHeaderHint := DoFooterHint;

  FBalloon := TBalloonSettings.Create;
  FBalloon.OnEnableChange := BalloonChange;

{$ENDIF}
  FPrev := TAdvSpeedButton.Create(Self);
  FPrev.Direction := bdLeft;
  FNext := TAdvSpeedButton.Create(Self);
  FNext.Direction := bdRight;
  FMode := TPlannerMode.Create(Self);
  FGrid := TPlannerGrid.Create(Self);

  FGrid.Options := FGrid.Options - [goHorzLine];
{$IFDEF DELPHI4_LVL}
  FGrid.DoubleBuffered := False;
{$ENDIF}
  FPlannerHeader := TPlannerHeader.Create(Self);
  FPlannerFooter := TPlannerFooter.Create(Self);
  FPanel := TPlannerPanel.Create(Self);
{$IFDEF DELPHI4_LVL}
  FPanel.DoubleBuffered := True;
{$ENDIF}
  FBands := TBands.Create(Self);
  FCaption := TPlannerCaption.Create(Self);
  FSidebar := TPlannerSideBar.Create(Self);
  FDisplay := TPlannerDisplay.Create(Self);
  FPlannerItems := CreateItems;
  FPrintOptions := TPlannerPrintOptions.Create;
  FHTMLOptions := TPlannerHTMLOptions.Create;
  FScrollBarStyle := TPlannerScrollBar.Create(Self);
  FInactiveDays := TWeekDays.Create;
  FDefaultItems := CreateItems;
  FBackground := TBackground.Create(Self);
  FDefaultItem := FDefaultItems.Add;

  if (csDesigning in ComponentState) and not (csLoading in ComponentState) then
    FDefaultItem.OnDesignChange := ItemDesignChange;
    
  FInactiveDays.OnChanged := InactiveChanged;
  FImageCache := THTMLPictureCache.Create;
  FPositionProps := TPositionProps.Create(Self);
  FSelectRange := True;
  FSelections := TPlannerSelections.Create(Self);
  FItemSelection := TPlannerItemSelection.Create;
  FShowOccupiedInPositionGap := True;
  FShowDesignHelper := True;

  FFlat := True;
  FDrawPrecise := False;
  FRoundTime := False;

  FGrid.Visible := True;
  FGrid.Parent := Self;
  FGrid.ShowHint := True;
  FGrid.Ctl3D := False;
  FPanel.Visible := True;
  FPanel.Parent := Self;
  FPanel.BevelOuter := bvNone;
  FPanel.BevelInner := bvNone;
  FTrackColor := clBlue;
  FTrackOnly := False;
  FFlashColor := clRed;
  FFlashFontColor := clWhite;
  FTrackWidth := 4;
  FPositions := 3;
  FPositionWidth := 0;
  FPrinterDriverFix := False;
  FLayer := 0;
  FItemGap := 11;
  FColor := clWindow;
  FSelectBlend := 90;
  FGradientSteps := 32;
  FGradientHorizontal := False;
  FSelectColor := clHighLight;
  FShowSelection := True;
  FDisjunctSelectColor := clHighLight;
  FGridLineColor := $00CECECE;
  FInplaceEdit := ieAlways;
  FDayNames := TStringList.Create;
  FPositionGapColor := clWhite;

  FDayNames.Add(ShortDaySun);
  FDayNames.Add(ShortDayMon);
  FDayNames.Add(ShortDayTue);
  FDayNames.Add(ShortDayWed);
  FDayNames.Add(ShortDayThu);
  FDayNames.Add(ShortDayFri);
  FDayNames.Add(ShortDaySat);

  FHeader.Visible := True;
  FHeader.Parent := Self;
  FHeader.BorderStyle := bsNone;
  FHeader.AllowResize := False;
  FHeader.AllowSizing := False;
  FHeader.OnClick := HeaderClick;
  FHeader.OnRightClick := HeaderRightClick;
  FHeader.OnDblClick := HeaderDblClick;
  FHeader.OnDragDrop := HeaderDragDrop;
  FHeader.OnSized := HeaderSized;

  FFooter.Visible := True;
  FFooter.Parent := Self;
  FFooter.BorderStyle := bsNone;
  FFooter.AllowResize := False;

  FPrev.Parent := Self;
  FNext.Parent := Self;
  FPrev.OnClick := PrevClick;
  FNext.OnClick := NextClick;

  Bitmap := TBitmap.Create;
  Bitmap.LoadFromResourceID(HInstance, 500);
  FPrev.Glyph.Assign(Bitmap);
  Bitmap.LoadFromResourceID(HInstance, 501);
  FNext.Glyph.Assign(Bitmap);
  Bitmap.Free;

  FPositionAutoSize := False;
  FShadowColor := clGray;
  FHintColor := clInfoBk;
  FHintPause := 500;
  FHintOnItemChange := True;
  FTimerID := 0;
  FOverlap := True;
  FLoading := False;
  FURLColor := clBlue;

  FURLGlyph := TBitmap.Create;
  if (csDesigning in ComponentState) then
    FURLGlyph.LoadFromResourceID(Hinstance,503);

  FAttachementGlyph := TBitmap.Create;
  if (csDesigning in ComponentState) then
    FAttachementGlyph.LoadFromResourceID(Hinstance,502);

  FDeleteGlyph := TBitmap.Create;
  if (csDesigning in ComponentState) then
    FDeleteGlyph.LoadFromResourceID(Hinstance,504);

  FEnableKeyboard := True;
  FAutoItemScroll := True;
  FSelectionAlways := True;
  FInsertAlways := True;
{$IFDEF ACTIVEXDEBUG}
  ShowMessage('TPlanner Create Done');
{$ENDIF}

  while FGrid.ColorList.Count < FPositions do
  begin
    PlannerColorArrayPointer := FGrid.ColorList.Add;

    for ColorIndex := 0 to NumColors do
    begin
      {$IFNDEF TMSDOTNET}
      PlannerColorArrayPointer^[ColorIndex].Color := clNone;
      PlannerColorArrayPointer^[ColorIndex].Selected := 0;
      {$ENDIF}

      {$IFDEF TMSDOTNET}
      PlannerColorArrayPointer.Color[ColorIndex] := clNone;
      PlannerColorArrayPointer.Selected[ColorIndex] := 0;
      {$ENDIF}
    end;
  end;

  FCompletionColor1 := clRed;
  FCompletionColor2 := clWhite;

  FDTList := TDateTimeList.Create;

  ControlStyle := ControlStyle + [csAcceptsControls];

  {$IFDEF TMSSKINS}
  FSkin := TPlannerSkin.Create(Self);
  {$ENDIF}
end;

destructor TCustomPlanner.Destroy;
begin
  BalloonDone;
  FDefaultItem.Free;
  FDefaultItem := nil;
  FDefaultItems.Free;
  FRichEdit.Free;
  FBalloon.Free;
  FGrid.Free;
  FGrid := nil;
  FPanel.Free;
  FBands.Free;
  FCaption.Free;
  FSidebar.Free;
  FDisplay.Free;
  FDisplay := nil;
  FPlannerHeader.Free;
  FPlannerFooter.Free;
  FPlannerItems.Free;
  FPlannerItems := nil;
  FMode.Free;
  FFont.Free;
  FHeader.Free;
  FFooter.Free;
  FNext.Free;
  FPrev.Free;
  FNavigatorButtons.Free;
  FScrollBarStyle.Free;
  FPrintOptions.Free;
  FHTMLOptions.Free;
  FDayNames.Free;
  FInactiveDays.Free;
  FBackground.Free;
  FSelections.Free;
  FImageCache.Free;
  FPositionProps.Free;
  FItemSelection.Free;
  FDTList.Free;
  FURLGlyph.Free;
  FDeleteGlyph.Free;
  FAttachementGlyph.Free;
  {$IFDEF TMSSKINS}
  FSkin.Free;
  {$ENDIF}
  inherited;
end;

procedure TCustomPlanner.SetStyle(StyleIndex: Integer);
begin
  PlannerSetStyle(StyleIndex, Self);
end;

{$IFDEF TMSSKINS}
procedure TCustomPlanner.SetPlannerSkin(AValue: TPlannerSkin);
begin
  FSkin.Assign(AValue);
end;
{$ENDIF}

procedure TCustomPlanner.Assign(Source: TPersistent);
begin
  if Assigned(Source) then
  begin
    Items.Assign((Source as TCustomPlanner).Items);
    Display.Assign((Source as TCustomPlanner).Display);
    SideBar.Assign((Source as TCustomPlanner).SideBar);
    Header.Assign((Source as TCustomPlanner).Header);
    Footer.Assign((Source as TCustomPlanner).Footer);
    Caption.Assign((Source as TCustomPlanner).Caption);
  end;
end;

function TCustomPlanner.GetBackGroundColor(ACol, ARow: Integer): TColor;
var
{$IFNDEF TMSDOTNET}
  PlannerColorArrayPointer: PPlannerColorArray;
{$ENDIF}
{$IFDEF TMSDOTNET}
  PlannerColorArrayPointer: TPlannerColorArrayObject;
{$ENDIF}
begin
  if SideBar.Position = spTop then
  begin
    if (ARow < FGrid.ColorList.Count) then
    begin
      PlannerColorArrayPointer := FGrid.ColorList.Items[ARow];

      if (ACol < NumColors) then
      {$IFNDEF TMSDOTNET}
        Result := PlannerColorArrayPointer^[ACol].Color
      {$ENDIF}
      {$IFDEF TMSDOTNET}
        Result := PlannerColorArrayPointer.Color[ACol]
      {$ENDIF}
      else
        Result := clNone;
    end
    else
      Result := FGrid.Color;
  end
  else
  begin
    if (ACol < FGrid.ColorList.Count) then
    begin
      Result := clNone;

      PlannerColorArrayPointer := FGrid.ColorList.Items[ACol];

      if (ARow < NumColors) then
      {$IFNDEF TMSDOTNET}
        Result := PlannerColorArrayPointer^[ARow].Color;
      {$ENDIF}
      {$IFDEF TMSDOTNET}
        Result := PlannerColorArrayPointer.Color[ARow];
      {$ENDIF}
    end
    else
      Result := FGrid.Color;
  end;
end;

procedure TCustomPlanner.ClearBackgroundColors;
var
  i, ColorIndex: Integer;
{$IFNDEF TMSDOTNET}
  PlannerColorArrayPointer: PPlannerColorArray;
{$ENDIF}
{$IFDEF TMSDOTNET}
  PlannerColorArrayPointer: TPlannerColorArrayObject;
{$ENDIF}

begin
  for i := 1 to FGrid.ColorList.Count do
  begin
    PlannerColorArrayPointer := FGrid.ColorList.Items[i - 1];

    for ColorIndex := 0 to NumColors do
    begin
      {$IFNDEF TMSDOTNET}
      PlannerColorArrayPointer^[ColorIndex].Color := clNone;
      PlannerColorArrayPointer^[ColorIndex].Selected := 0;
      {$ENDIF}
      {$IFDEF TMSDOTNET}
      PlannerColorArrayPointer.Color[ColorIndex] := clNone;
      PlannerColorArrayPointer.Selected[ColorIndex] := 0;
      {$ENDIF}
    end;
  end;
  Invalidate;
end;

procedure TCustomPlanner.SetBackGroundColor(ACol, ARow: Integer; const Value: TColor);
var
{$IFNDEF TMSDOTNET}
  PlannerColorArrayPointer: PPlannerColorArray;
{$ENDIF}
{$IFDEF TMSDOTNET}
  PlannerColorArrayPointer: TPlannerColorArrayObject;
{$ENDIF}
begin
  if (ACol < 0) or
     (ARow < 0) or
     (ACol >= FGrid.ColCount) or
     (ARow >= FGrid.RowCount) then Exit;

  if SideBar.Position = spTop then
  begin
    if (ARow < FGrid.ColorList.Count) then
    begin
      PlannerColorArrayPointer := FGrid.ColorList.Items[ARow];

      if (ACol < NumColors) then
      {$IFNDEF TMSDOTNET}
        PlannerColorArrayPointer^[ACol].Color := Value;
      {$ENDIF}
      {$IFDEF TMSDOTNET}
        PlannerColorArrayPointer.Color[ACol] := Value;
      {$ENDIF}

    end;
    {$IFNDEF TMSDOTNET}
    FGrid.InvalidateCell(ACol, ARow + FSideBar.FRowOffset);
    {$ENDIF}
    {$IFDEF TMSDOTNET}
    FGrid.InvalidateCellP(ACol, ARow + FSideBar.FRowOffset);
    {$ENDIF}
  end
  else
  begin
    if (ACol < FGrid.ColorList.Count) then
    begin
      PlannerColorArrayPointer := FGrid.ColorList.Items[ACol];

      if (ARow < NumColors) then
      {$IFNDEF TMSDOTNET}
        PlannerColorArrayPointer^[ARow].Color := Value;
      {$ENDIF}
      {$IFDEF TMSDOTNET}
        PlannerColorArrayPointer.Color[ARow] := Value;
      {$ENDIF}
    end;
    {$IFNDEF TMSDOTNET}
    FGrid.InvalidateCell(ACol + FSidebar.FColOffset, ARow);
    {$ENDIF}
    {$IFDEF TMSDOTNET}
    FGrid.InvalidateCellP(ACol + FSidebar.FColOffset, ARow);
    {$ENDIF}
  end;
end;

function TCustomPlanner.GetSelected(ACol, ARow: Integer): Boolean;
var
{$IFNDEF TMSDOTNET}
  PlannerColorArrayPointer: PPlannerColorArray;
{$ENDIF}
{$IFDEF TMSDOTNET}
  PlannerColorArrayPointer: TPlannerColorArrayObject;
{$ENDIF}
begin
  Result := False;

  if SideBar.Position = spTop then
  begin
    if (ARow < FGrid.ColorList.Count) then
    begin
      PlannerColorArrayPointer := FGrid.ColorList.Items[ARow];

      if (ACol < NumColors) then
      {$IFNDEF TMSDOTNET}
        Result := PlannerColorArrayPointer^[ACol].Selected > 0
      {$ENDIF}
      {$IFDEF TMSDOTNET}
        Result := PlannerColorArrayPointer.Selected[ACol] > 0
      {$ENDIF}
    end;
  end
  else
  begin
    if (ACol < FGrid.ColorList.Count) then
    begin
      PlannerColorArrayPointer := FGrid.ColorList.Items[ACol];
      
      if (ARow < NumColors) then
      {$IFNDEF TMSDOTNET}
        Result := PlannerColorArrayPointer^[ARow].Selected > 0;
      {$ENDIF}
      {$IFDEF TMSDOTNET}
        Result := PlannerColorArrayPointer.Selected[ARow] > 0;
      {$ENDIF}
    end;
  end;
end;

procedure TCustomPlanner.SetSelected(ACol, ARow: Integer; const Value: Boolean);
var
{$IFNDEF TMSDOTNET}
  PlannerColorArrayPointer: PPlannerColorArray;
{$ENDIF}
{$IFDEF TMSDOTNET}
  PlannerColorArrayPointer: TPlannerColorArrayObject;
{$ENDIF}
begin
  if (ACol < 0) or
     (ARow < 0) or
     (ACol >= FGrid.ColCount) or
     (ARow >= FGrid.RowCount) then Exit;

  if SideBar.Position = spTop then
  begin
    if (ARow < FGrid.ColorList.Count) then
    begin
      PlannerColorArrayPointer := FGrid.ColorList.Items[ARow];

      if (ACol < NumColors) then
      begin
        {$IFNDEF TMSDOTNET}
        if Value then
          PlannerColorArrayPointer^[ACol].Selected := PlannerColorArrayPointer^[ACol].Selected + 1
        else
          if PlannerColorArrayPointer^[ACol].Selected > 0 then
            PlannerColorArrayPointer^[ACol].Selected := PlannerColorArrayPointer^[ACol].Selected - 1;
        {$ENDIF}
        {$IFDEF TMSDOTNET}
        if Value then
          PlannerColorArrayPointer.Selected[ACol] := PlannerColorArrayPointer.Selected[ACol] + 1
        else
          if PlannerColorArrayPointer.Selected[ACol] > 0 then
            PlannerColorArrayPointer.Selected[ACol] := PlannerColorArrayPointer.Selected[ACol] - 1;
        {$ENDIF}
      end;
    end;
    {$IFNDEF TMSDOTNET}
    FGrid.InvalidateCell(ACol, ARow + FSideBar.FRowOffset);
    {$ENDIF}
    {$IFDEF TMSDOTNET}
    FGrid.InvalidateCellP(ACol, ARow + FSideBar.FRowOffset);
    {$ENDIF}
  end
  else
  begin
    if (ACol < FGrid.ColorList.Count) then
    begin
      PlannerColorArrayPointer := FGrid.ColorList.Items[ACol];
      
      if (ARow < NumColors) then
      begin
        {$IFNDEF TMSDOTNET}
        if Value then
          PlannerColorArrayPointer^[ARow].Selected := PlannerColorArrayPointer^[ARow].Selected + 1
        else
          if PlannerColorArrayPointer^[ARow].Selected > 0 then
            PlannerColorArrayPointer^[ARow].Selected := PlannerColorArrayPointer^[ARow].Selected - 1;
        {$ENDIF}
        {$IFDEF TMSDOTNET}
        if Value then
          PlannerColorArrayPointer.Selected[ARow] := PlannerColorArrayPointer.Selected[ARow] + 1
        else
          if PlannerColorArrayPointer.Selected[ARow] > 0 then
            PlannerColorArrayPointer.Selected[ARow] := PlannerColorArrayPointer.Selected[ARow] - 1;
        {$ENDIF}
      end;
    end;
    {$IFNDEF TMSDOTNET}
    FGrid.InvalidateCell(ACol + FSidebar.FColOffset, ARow);
    {$ENDIF}
    {$IFDEF TMSDOTNET}
    FGrid.InvalidateCellP(ACol + FSidebar.FColOffset, ARow);
    {$ENDIF}
  end;
end;

procedure TCustomPlanner.DoHeaderHint(Sender: TObject; Index: Integer; var HintStr: string);
begin
  if Assigned(OnHeaderHint) then
    OnHeaderHint(Self, Index, HintStr);
end;

procedure TCustomPlanner.DoFooterHint(Sender: TObject; Index: Integer; var HintStr: string);
begin
  if Assigned(OnFooterHint) then
    OnFooterHint(Self, Index, HintStr);
end;



procedure TCustomPlanner.UpdateSelection(SelBegin, SelEnd, SelPos: Integer;Active: Boolean);
var
  i,f,l: Integer;
begin
  if SelBegin > SelEnd then
  begin
    l := SelBegin;
    f := SelEnd;
  end
  else
  begin
    l := SelEnd;
    f := SelBegin;
  end;

  for i := f to l - 1 do
  begin
    if SideBar.Position = spTop then
      Selected[i, SelPos] := Active
    else
      Selected[SelPos,i] := Active;
  end;
end;


function TCustomPlanner.GetCellColorCol(Pos,Index: Integer; var UseColor: Boolean): TColor;
var
  ABrush: TBrush;
  {$IFNDEF TMSDOTNET}
  PlannerColorArrayPointer: PPlannerColorArray;
  {$ENDIF}
  {$IFDEF TMSDOTNET}
  PlannerColorArrayPointer: TPlannerColorArrayObject;
  {$ENDIF}
begin
  ABrush := TBrush.Create;
  GetCellBrush(Pos,Index,ABrush);
  Result := ABrush.Color;
  ABrush.Free;

  { Custom cell Color }

  if (Pos < FGrid.ColorList.Count) and (Pos >= 0) and
      (Index < NumColors) then
  begin
    {$IFNDEF TMSDOTNET}
    PlannerColorArrayPointer := FGrid.FColorList.Items[Pos];
    if PlannerColorArrayPointer^[Index].Color <> clNone then
      Result := PlannerColorArrayPointer^[Index].Color;
    if PlannerColorArrayPointer^[Index].Selected > 0 then
    begin
      Result := DisjunctSelectColor;
      UseColor := True;
    end;  
    {$ENDIF}
    {$IFDEF TMSDOTNET}
    PlannerColorArrayPointer := FGrid.FColorList.Items[Pos];
    if PlannerColorArrayPointer.Color[Index] <> clNone then
      Result := PlannerColorArrayPointer.Color[Index];
    if PlannerColorArrayPointer.Selected[Index] > 0 then
    begin
      Result := DisjunctSelectColor;
      UseColor := True;
    end;
    {$ENDIF}
  end;

  if CellInCurrTime(Index,Pos) then
  begin
    Result := FDisplay.ColorCurrent;
    UseColor := True;
  end;  
end;

function TCustomPlanner.IsCurPos(APosition: Integer): Boolean;
begin
  Result := True;
  if (Display.CurrentPosFrom = -1) or (Display.CurrentPosTo = -1) then
    Exit;

  Result := (APosition >= Display.CurrentPosFrom) and
            (APosition <= Display.CurrentPosTo);
end;

function TCustomPlanner.IsActive(AIndex, APosition: Integer): Boolean;
var
  DateTime: TDateTime;
  ActiveStart,ActiveEnd,M,Y: Integer;
  UsePP: Boolean;
  dbl: double;
begin
  UsePP := (PositionProps.Count > APosition) and (APosition >= 0);
  if UsePP then
    UsePP := PositionProps.Items[APosition].Use;
  if UsePP then
  begin
    ActiveStart := PositionProps.Items[APosition].ActiveStart;
    ActiveEnd := PositionProps.Items[APosition].ActiveEnd;
  end
  else
  begin
    ActiveStart := FDisplay.ActiveStart;
    ActiveEnd := FDisplay.ActiveEnd;
  end;

  Result := True;

  case FMode.FPlannerType of
  plDay:
    Result := (AIndex < ActiveStart) or (AIndex >= ActiveEnd);
//  plWeek:
//    begin
//      Result := ((AIndex - FMode.WeekStart) mod DaysPerWeek) in [0, 1];
//    end;
  plMonth:
    begin
      DateTime := Mode.StartOfMonth + AIndex;
      Result := DayOfWeek(DateTime) in FInactive;
    end;
  plDayPeriod, plWeek:
    begin
      DateTime := Mode.PeriodStartDate + AIndex;
      Result :=DayOfWeek(DateTime) in FInactive;
    end;
  plHalfDayPeriod:
    begin
      DateTime := Mode.PeriodStartDate + AIndex / 2;
      Result := DayOfWeek(DateTime) in FInactive;
    end;
  plMultiMonth:
    begin
      M := Mode.Month + APosition;
      Y := Mode.Year;
      while M > 12 do
      begin
        Dec(M,12);
        Inc(Y);
      end;
      if AIndex < PlanUtil.DaysInMonth(M,Y) then
      begin
        DateTime := EncodeDate(Y,M,AIndex + 1);
        Result := DayOfWeek(DateTime) in FInactive;
      end; 
    end;
  plCustom, plCustomList:
    begin
      Result := False;
    end;
  plTimeLine:
    begin
      dbl := AIndex * Display.DisplayUnit / (MinInDay - (Mode.TimeLineNVUEnd + Mode.TimeLineNVUBegin) * Display.DisplayUnit);
      {$IFDEF TMSDOTNET}
      DateTime := Mode.TimeLineStart + TDateTime(Trunc(dbl));
      {$ENDIF}
      {$IFNDEF TMSDOTNET}
      DateTime := Mode.TimeLineStart + Trunc(dbl);      
      {$ENDIF}
      Result := DayOfWeek(DateTime) in FInactive;
    end;
  end;
  Result := not Result;

  if Assigned(FOnPlannerIsActive) then
    FOnPlannerIsActive(Self,AIndex, APosition, Result);
end;

procedure TCustomPlanner.GetCellBrush(Pos,Index: Integer; ABrush: TBrush);
var
  DateTime: TDateTime;
  ActiveStart,ActiveEnd,M,Y: Integer;
  ColorActive,ColorNonActive: TColor;
  UsePP: Boolean;
  dbl: double;

begin
  UsePP := (PositionProps.Count > Pos) and (Pos >= 0);

  if UsePP then
    UsePP := PositionProps.Items[Pos].Use;
  if UsePP then
  begin
    ColorActive := PositionProps.Items[Pos].ColorActive;
    ColorNonActive := PositionProps.Items[Pos].ColorNonActive;
    ActiveStart := PositionProps.Items[Pos].ActiveStart;
    ActiveEnd := PositionProps.Items[Pos].ActiveEnd;
  end
  else
  begin
    ColorActive := Self.Display.ColorActive;
    ColorNonActive := Self.Display.ColorNonActive;
    ActiveStart := FDisplay.ActiveStart;
    ActiveEnd := FDisplay.ActiveEnd;
  end;

  if FBands.Show then
  begin
    if Odd(Index) then
      ColorActive := FBands.ActivePrimary
    else
      ColorActive := FBands.ActiveSecondary;

    if Odd(Index) then
      ColorNonActive := FBands.NonActivePrimary
    else
      ColorNonActive := FBands.NonActiveSecondary;
  end;

  ABrush.Style := bsSolid;
  ABrush.Color := ColorActive;

  case FMode.FPlannerType of
    plDay:
      begin
        if (Index < ActiveStart) or (Index >= ActiveEnd) then
          ABrush.Color := ColorNonActive;
      end;
//    plWeek:
//      begin
//        if ((Index - FMode.WeekStart) mod DaysPerWeek) in [0, 1] then
//          ABrush.Color := ColorNonActive;
//      end;
    plMonth:
      begin
        DateTime := Mode.StartOfMonth + Index;
        if DayOfWeek(DateTime) in FInactive then
          ABrush.Color := ColorNonActive;
      end;
    plDayPeriod, plWeek:
      begin
        DateTime := Mode.PeriodStartDate + Index;
        if DayOfWeek(DateTime) in FInactive then
          ABrush.Color := ColorNonActive;
      end;
    plHalfDayPeriod:
      begin
        DateTime := Mode.PeriodStartDate + Index / 2;
        if DayOfWeek(DateTime) in FInactive then
          ABrush.Color := ColorNonActive;
      end;
    plMultiMonth:
      begin     
        M := Mode.Month + Pos;
        Y := Mode.Year;
        while M > 12 do
        begin
          Dec(M,12);
          Inc(Y);
        end;

        if Index < PlanUtil.DaysInMonth(M,Y) then
        begin
          DateTime := EncodeDate(Y,M,Index + 1);
          if DayOfWeek(DateTime) in FInactive then
            ABrush.Color := ColorNonActive;
        end;
      end;
    plCustom, plCustomList:
      begin
      end;
    plTimeLine:
      begin
        dbl := Index * Display.DisplayUnit / (MinInDay - (Mode.TimeLineNVUEnd + Mode.TimeLineNVUBegin) * Display.DisplayUnit);
        {$IFDEF TMSDOTNET}
        DateTime := Mode.TimeLineStart + TDateTime(Trunc(dbl));
        {$ENDIF}
        {$IFNDEF TMSDOTNET}
        DateTime := Mode.TimeLineStart + Trunc(dbl);
        {$ENDIF}

        if DayOfWeek(DateTime) in FInactive then
          ABrush.Color := ColorNonActive;
      end;
  end;

  if UsePP then
  begin
    if PositionProps.Items[Pos].MinSelection > 0 then
    begin
      if  Index < PositionProps.Items[Pos].MinSelection then
      begin
        ABrush.Style := PositionProps.Items[Pos].BrushNoSelect;
        ABrush.Color := PositionProps.Items[Pos].ColorNoSelect;
      end;
    end;
    if PositionProps.Items[Pos].MaxSelection > 0 then
    begin
      if  Index >= PositionProps.Items[Pos].MaxSelection then
      begin
        ABrush.Style := PositionProps.Items[Pos].BrushNoSelect;
        ABrush.Color := PositionProps.Items[Pos].ColorNoSelect;
      end;
    end;
  end;

end;

procedure TCustomPlanner.Print;
begin
  PrintSelection(0,Positions - 1);
end;

procedure TCustomPlanner.PrintTo(ACanvas:TCanvas);
begin
  PrintSelectionTo(ACanvas,0, Positions - 1);
end;

procedure TCustomPlanner.PrintSelection(FromPos, ToPos: Integer);
begin
  with Printer do
  begin
    Title := FPrintOptions.JobName;
    Orientation := FPrintOptions.Orientation;
    BeginDoc;
    PrintSelectionTo(Canvas, FromPos, ToPos);
    EndDoc;
  end;
end;

procedure TCustomPlanner.PrintPages(NrOfPages: Integer);
var
  ItemsPerPage,i: Integer;
  FirstItem,LastItem: Integer;
  
begin
  if NrOfPages <= 0 then
    Exit;

  ItemsPerPage := (Display.DisplayEnd - Display.DisplayStart + 1) div NrOfPages;

  with Printer do
  begin
    Title := FPrintOptions.JobName;
    Orientation := FPrintOptions.Orientation;
    BeginDoc;

    FirstItem := 0;
    
    if ItemsPerPage > 0 then
      LastItem := ItemsPerPage - 1
    else
      LastItem := ItemsPerPage;  

    for i := 1 to NrOfPages do
    begin
      PrintRangeTo(Printer.Canvas, 0, Positions - 1, FirstItem, LastItem);
      FirstItem := LastItem + 1;
      LastItem := LastItem + ItemsPerPage;

      if i = NrOfPages - 1 then
        LastItem := (Display.DisplayEnd - Display.DisplayStart);
      
      if i < NrOfPages then
        NewPage;
    end;
    EndDoc;
  end;
end;


procedure TCustomPlanner.PrintSelectionTo(ACanvas:TCanvas;FromPos, ToPos: Integer);
begin
  if (FromPos > ToPos) then
    Exit;

  if Sidebar.Orientation = soVertical then
    PrintCol(ACanvas, FromPos, ToPos, 0, FGrid.RowCount - 1)
  else
    PrintRow(ACanvas, FromPos, ToPos, 0, FGrid.ColCount - 1);
end;

procedure TCustomPlanner.PrintRange(FromPos, ToPos, FromItem, ToItem: Integer);
begin
  with Printer do
  begin
    Title := FPrintOptions.JobName;
    Orientation := FPrintOptions.Orientation;
    BeginDoc;
    PrintRangeTo(Printer.Canvas, FromPos, ToPos, FromItem, ToItem);
    EndDoc;
  end;
end;

procedure TCustomPlanner.PrintRangeTo(ACanvas:TCanvas; FromPos, ToPos, FromItem, ToItem: Integer);
begin
  if Sidebar.Orientation = soVertical then
    PrintCol(ACanvas, FromPos, ToPos, FromItem, ToItem)
  else
    PrintRow(ACanvas, FromPos, ToPos, FromItem, ToItem);
end;



{$IFDEF FREEWARE}
procedure PrintFreewareNotice(ACanvas:TCanvas; XSize, YSize: Integer; ClassName: string);
var
  DrawRect: TRect;
  LFont: TLogFont;
  HOldFont, HNewFont: HFont;
begin

  DrawRect.Left := 0;
  DrawRect.Right := XSize;
  DrawRect.Top := YSize shr 1;
  DrawRect.Bottom := YSize;

  ACanvas.Font.Size := 20;
  ACanvas.Font.Style := [fsBold];
  ACanvas.Font.Color := clSilver;

  {$IFNDEF TMSDOTNET}
  GetObject(ACanvas.Font.Handle, SizeOf(LFont), Addr(LFont));
  {$ENDIF}

  {$IFDEF TMSDOTNET}
  GetObject(ACanvas.Font.Handle, Marshal.SizeOf(TypeOf(LFont)), LFont);
  {$ENDIF}

  LFont.lfEscapement := 45 * 10;
  LFont.lfOrientation := 45 * 10;

  HNewFont := CreateFontIndirect(LFont);
  HOldFont := SelectObject(ACanvas.Handle, HNewFont);

  SetTextAlign(ACanvas.Handle, TA_TOP);
  SetBkMode(ACanvas.Handle, TRANSPARENT);

  ACanvas.TextOut(XSize shr 2, (YSize shr 2) + (YSize shr 1), Format(COPYRIGHT, [ClassName]));

  HNewFont := SelectObject(ACanvas.Handle, HOldFont);
  DeleteObject(HNewFont);

end;
{$ENDIF}


procedure TCustomPlanner.PrintCol(ACanvas: TCanvas; FromPos, ToPos, FromRow, ToRow: Integer);
var
  XSize, YSize: Integer;
  PositionIndex, RowIndex, SubIndex, GroupIndex, ConflictingCellWidth: Integer;
  NumberOfConflicts: TPoint;
  DrawRect, ARect, NRect, SRect: TRect;
  APlannerItem: TPlannerItem;
  SideBarWidth, HeaderHeight, FooterHeight, GroupHeight, Side: Integer;
  LeftIndent, TopIndent: Integer;
  ColumnWidth, ColumnHeight, GapWidth: Integer;
  PrintPositions, NumCols: Integer;
  DoDraw: Boolean;
  SizedCols: Boolean;
  BottomPen: TPen;
  hdr,a,sa,fa:string;
  XS, YS, ml, hl: Integer;
  cr,hr: TRect;
  CID,CV,CT:string;
  AColorTo: TColor;
  Occupied: Boolean;
  gs: integer;
  gc: string;

begin
  PrintPositions := (ToPos - FromPos) + 1;

  if Assigned(FOnPrintStart) then
    FOnPrintStart(Self, ACanvas);

  // Get the paper dimensions
  XSize := ACanvas.ClipRect.Right - ACanvas.ClipRect.Left -
    FPrintOptions.FLeftMargin - FPrintOptions.FRightMargin;

  YSize := ACanvas.ClipRect.Bottom - ACanvas.ClipRect.Top -
    FPrintOptions.FHeaderSize - FPrintOptions.FFooterSize;

  FHTMLFactor := CanvasToHTMLFactor(Canvas,ACanvas);

  LeftIndent := FPrintOptions.FLeftMargin;
  TopIndent := FPrintOptions.FHeaderSize;

  SideBarWidth := 0;
  HeaderHeight := 0;
  FooterHeight := 0;
  GroupHeight := 0;

  if PositionGroup > 0 then
    GroupIndex := FromPos div PositionGroup
  else
    GroupIndex := 0;

  // Column width
  if FSidebar.Visible then
  begin
    if (FSideBar.Position = spLeftRight) then
      NumCols := PrintPositions + 2
    else
      NumCols := PrintPositions + 1;
  end
  else
    NumCols := PrintPositions;

  SizedCols := (Round(FGrid.ColWidths[1] * (NumCols) {* FHTMLFactor}) > XSize);

  if SizedCols or FPrintOptions.FFitToPage then
    ColumnWidth := (XSize div NumCols)
  else
    ColumnWidth := Round(FGrid.ColWidths[1] {* FHTMLFactor});

  if (FPositionGap > 0) and (FSideBar.ShowInPositionGap) then
    GapWidth := Round(FPositionGap / FGrid.ColWidths[1] * ColumnWidth)
  else
    GapWidth := 0;

  // Row Height
  if FHeader.Visible then
    HeaderHeight := Round(YSize * (Header.Height / (FGrid.RowHeights[0] *
      (ToRow - FromRow + 1))));

  if FFooter.Visible then
    FooterHeight := Round(YSize * (Footer.Height / (FGrid.RowHeights[0] *
      (ToRow - FromRow + 1))));

  // Double header size when group captions need to be printed
//  if FHeader.Visible and (PositionGroup > 0) then
//    GroupHeight := HeaderHeight;

  if FHeader.Visible and (PositionGroup > 0) then
  begin
    GroupHeight := Round(Header.TextHeight / Header.Height * HeaderHeight);
  end;

  YSize := YSize - HeaderHeight - GroupHeight - FooterHeight;

  ColumnHeight := YSize div (ToRow - FromRow + 1);

  if FPrintOptions.CellHeight > 0 then
    ColumnHeight := FPrintOptions.CellHeight;

  if FPrintOptions.CellWidth > 0 then
    ColumnWidth := FPrintOptions.CellWidth;

  if (FPrintOptions.FHeader.Count > 0) or Assigned(FOnPrintHeader) then
  begin
    // Print Header over full size
    DrawRect.Left := LeftIndent;
    DrawRect.Right := XSize;
    DrawRect.Top := 0;
    DrawRect.Bottom := TopIndent;
    ACanvas.Brush.Style := bsClear;
    ACanvas.Font.Assign(FPrintOptions.FHeaderFont);

    if Assigned(FOnPrintHeader) then
      FOnPrintHeader(Self, ACanvas, DrawRect)
    else
    begin
      if pos('</',FPrintOptions.FHeader.Text) > 0 then
        HTMLDrawEx(ACanvas, FPrintOptions.FHeader.Text, DrawRect, PlannerImages, 0, 0, -1, -1, 1, False, False,
        True, False, True, False, False
        ,False
        , FHTMLFactor, URLColor, clNone, clNone, clGray, a, sa, fa, XS, YS, ml, hl, hr
        , cr, CID, CV, CT, FImageCache, FContainer, Handle
        )
      else
        PrinterDrawString(ACanvas,FPrintOptions.FHeader.Text, DrawRect,
          AlignToFlag(FPrintOptions.FHeaderAlignment));
    end;
  end;

  if (FPrintOptions.FFooter.Count > 0) or Assigned(FOnPrintFooter) then
  begin
    // Print footer over full size
    DrawRect.Left := LeftIndent;
    DrawRect.Right := XSize;
    DrawRect.Top := YSize + HeaderHeight + GroupHeight + FPrintOptions.FHeaderSize;
    DrawRect.Bottom := DrawRect.Top + FPrintOptions.FFooterSize;
    ACanvas.Brush.Style := bsClear;
    ACanvas.Font.Assign(FPrintOptions.FFooterFont);

    if Assigned(FOnPrintFooter) then
      FOnPrintFooter(Self, ACanvas, DrawRect)
    else
    begin
      if pos('</',FPrintOptions.FFooter.Text) > 0 then
        HTMLDrawEx(ACanvas, FPrintOptions.FFooter.Text, DrawRect, PlannerImages, 0, 0, -1, -1, 1, False, False,
        True, False, True, False, False
        ,False
        , FHTMLFactor, URLColor, clNone, clNone, clGray, a, sa, fa, XS, YS, ml, hl, hr
        , cr, CID, CV, CT, FImageCache, FContainer, Handle
        )
      else
        PrinterDrawString(ACanvas,FPrintOptions.FFooter.Text, DrawRect, AlignToFlag(FPrintOptions.FFooterAlignment));
    end;
  end;

  // Draw the left sidebar
  if FSidebar.Visible and (FSideBar.Position in [spLeft, spLeftRight]) then
  begin
    if SizedCols or FPrintOptions.FFitToPage then
    begin
      SideBarWidth := Round(XSize *
        (FGrid.ColWidths[0] / (FGrid.ColWidths[1] * (PrintPositions))));

      if FSideBar.Position = spLeftRight then
        ColumnWidth := Trunc((XSize - 2 * SideBarWidth)/PrintPositions)
      else
        ColumnWidth := Trunc((XSize - SideBarWidth)/PrintPositions);
    end
    else
      SideBarWidth := Round(FGrid.ColWidths[0] {* FHTMLFactor});

    if FPrintOptions.SidebarWidth > 0 then
      SidebarWidth := FPrintOptions.SidebarWidth;

    for PositionIndex := FromRow to ToRow do
    begin
      DrawRect.Left := LeftIndent;
      DrawRect.Top := TopIndent + HeaderHeight + GroupHeight + ColumnHeight * (PositionIndex - FromRow);
      DrawRect.Right := DrawRect.Left + SideBarWidth;
      DrawRect.Bottom := DrawRect.Top + ColumnHeight;

      ACanvas.Font.Assign(Sidebar.Font);
      ACanvas.Brush.Color := Sidebar.Background;

      ACanvas.Font.Assign(Sidebar.Font);

      if (Assigned(FOnPlannerSideProp)) then
        FOnPlannerSideProp(Self, PositionIndex, ACanvas.Brush, ACanvas.Font, AColorTo);

      ACanvas.Pen.Color := ACanvas.Brush.Color;
      ACanvas.Pen.Width := PrintOptions.LineWidth;

      if PositionIndex = FromRow then
      begin
        ACanvas.MoveTo(DrawRect.Left, DrawRect.Top);
        ACanvas.LineTo(DrawRect.Right, DrawRect.Top);
      end;

      APlannerItem := Items.FindItemIdx(PositionIndex);

      Occupied := (APlannerItem <> nil) and Sidebar.ShowOccupied;

      if Occupied then
      begin
        ACanvas.Brush.Color := Sidebar.Occupied;
        if SideBar.OccupiedTo <> clNone then
          DrawGradient(ACanvas,ACanvas.Brush.Color,SideBar.OccupiedTo, 64, DrawRect, true)
        else
          ACanvas.Rectangle(DrawRect.Left, DrawRect.Top, DrawRect.Right, DrawRect.Bottom);
      end
      else
      begin
        if SideBar.BackGroundTo <> clNone then
          DrawGradient(ACanvas,ACanvas.Brush.Color,SideBar.BackgroundTo, 64, DrawRect, true)
        else
          ACanvas.Rectangle(DrawRect.Left, DrawRect.Top, DrawRect.Right, DrawRect.Bottom);
      end;

      ACanvas.Pen.Color := SideBar.SeparatorLineColor;
      ACanvas.Pen.Width := PrintOptions.LineWidth;

      if PositionIndex = FromRow then
      begin
        ACanvas.MoveTo(DrawRect.Left, DrawRect.Top);
        ACanvas.LineTo(DrawRect.Right, DrawRect.Top);
      end;

      InflateRect(DrawRect, -1, -1);

      if (Assigned(FOnPlannerSideDraw)) then
        FOnPlannerSideDraw(Self, ACanvas, DrawRect, PositionIndex)
      else
      begin
        FGrid.PaintSideCol(ACanvas, DrawRect, PositionIndex, 0, 0, False, True);

        if Assigned(FOnPlannerSideDrawAfter) then
          FOnPlannerSideDrawAfter(Self, ACanvas, DrawRect, PositionIndex);
      end;

      ACanvas.Brush.Color := Color;
      ACanvas.Font.Assign(Font);
    end;
  end;

  // Draw the right sidebar
  if FSidebar.Visible and (FSideBar.Position in [spRight, spLeftRight]) then
  begin
    if SizedCols or FPrintOptions.FFitToPage then
    begin
      SideBarWidth := Round(XSize *
        (FGrid.ColWidths[FGrid.ColCount - 1] / (FGrid.ColWidths[1] * (PrintPositions))));

      if FSideBar.Position = spLeftRight then
        ColumnWidth := Trunc((XSize - 2 * SideBarWidth)/PrintPositions)
      else
        ColumnWidth := Trunc((XSize - SideBarWidth)/PrintPositions);
    end
    else
      SideBarWidth := Round(FGrid.ColWidths[FGrid.ColCount - 1] {* FHTMLFactor});

    if FPrintOptions.SidebarWidth > 0 then
      SidebarWidth := FPrintOptions.SidebarWidth;

    for PositionIndex := FromRow to ToRow do
    begin
      DrawRect.Left := LeftIndent + (PrintPositions * ColumnWidth);
      if (FSideBar.Position in [spLeft, spLeftRight]) then
        DrawRect.Left := DrawRect.Left + SideBarWidth;

      DrawRect.Top := TopIndent + HeaderHeight + GroupHeight + ColumnHeight * (PositionIndex - FromRow);
      DrawRect.Right := DrawRect.Left + SideBarWidth;
      DrawRect.Bottom := DrawRect.Top + ColumnHeight;

      ACanvas.Font.Assign(Sidebar.Font);
      ACanvas.Brush.Color := Sidebar.Background;

      ACanvas.Font.Assign(Sidebar.Font);

      if (Assigned(FOnPlannerSideProp)) then
        FOnPlannerSideProp(Self, PositionIndex, ACanvas.Brush, ACanvas.Font, AColorTo);

      ACanvas.Pen.Color := ACanvas.Brush.Color;
      ACanvas.Pen.Width := PrintOptions.LineWidth;

      if PositionIndex = FromRow then
      begin
        ACanvas.MoveTo(DrawRect.Left, DrawRect.Top);
        ACanvas.LineTo(DrawRect.Right, DrawRect.Top);
      end;

      APlannerItem := Items.FindItemIdx(PositionIndex);

      Occupied := (APlannerItem <> nil) and Sidebar.ShowOccupied;

      if Occupied then
      begin
        ACanvas.Brush.Color := Sidebar.Occupied;
        if SideBar.OccupiedTo <> clNone then
          DrawGradient(ACanvas,ACanvas.Brush.Color,SideBar.OccupiedTo, 64, DrawRect, true)
        else
          ACanvas.Rectangle(DrawRect.Left, DrawRect.Top, DrawRect.Right, DrawRect.Bottom);
      end
      else
      begin
        if SideBar.BackGroundTo <> clNone then
          DrawGradient(ACanvas,ACanvas.Brush.Color,SideBar.BackgroundTo, 64, DrawRect, true)
        else
          ACanvas.Rectangle(DrawRect.Left, DrawRect.Top, DrawRect.Right, DrawRect.Bottom);
      end;

      ACanvas.Pen.Color := SideBar.SeparatorLineColor;
      ACanvas.Pen.Width:= PrintOptions.LineWidth;

      if PositionIndex = FromRow then
      begin
        ACanvas.MoveTo(DrawRect.Left, DrawRect.Top);
        ACanvas.LineTo(DrawRect.Right, DrawRect.Top);
      end;

      InflateRect(DrawRect, -1, -1);

      if (Assigned(FOnPlannerSideDraw)) then
        FOnPlannerSideDraw(Self, ACanvas, DrawRect, PositionIndex)
      else
      begin
        FGrid.PaintSideCol(ACanvas, DrawRect, PositionIndex, 0, 0, False, True);

        if Assigned(FOnPlannerSideDrawAfter) then
          FOnPlannerSideDrawAfter(Self, ACanvas, DrawRect, PositionIndex);
      end;

      ACanvas.Brush.Color := Color;
      ACanvas.Font.Assign(Font);
    end;
  end;

  Side := 1;

  if FSidebar.Visible and (FSideBar.Position = spRight) then
  begin
    Side := 0;  
    SideBarWidth := 0;
  end;

  // Draw the Header
  if FHeader.Visible then
  begin
    SetBkMode(ACanvas.Handle,TRANSPARENT);

    for PositionIndex := FromPos to ToPos do
    begin
      ACanvas.Font.Assign(Header.Font);
      ACanvas.Brush.Color := FColor;

      if (PositionGroup = 1) and (Header.CustomGroups.Count > 0) then
      begin
        gs := Header.GroupSplit(PositionIndex);
        gc := Header.GetGroupCaption(PositionIndex);


        if (gs <> - 1) then
        begin
          DrawRect.Left := LeftIndent + SideBarWidth + (ColumnWidth * (PositionIndex - FromPos));
          DrawRect.Top := 1 + TopIndent;
          DrawRect.Right := DrawRect.Left + ColumnWidth * gs;

          if DrawRect.Right > LeftIndent + SideBarWidth + ColumnWidth * (1 + ToPos - FromPos) then
            DrawRect.Right := LeftIndent + SideBarWidth + ColumnWidth * (1 + ToPos - FromPos);

          DrawRect.Bottom := GroupHeight + TopIndent;

          //***
          ACanvas.Brush.Color := FHeader.Color;
          if FHeader.ColorTo <> clNone then
            DrawGradient(ACanvas,ACanvas.Brush.Color,FHeader.ColorTo, 64, DrawRect, false)
          else
            ACanvas.Rectangle(DrawRect.Left, DrawRect.Top, DrawRect.Right, DrawRect.Bottom);

          RectLine(ACanvas, DrawRect, GridLineColor, PrintOptions.LineWidth);

          InflateRect(DrawRect, -1, -1);

          ACanvas.Brush.Style := bsClear;

          ACanvas.Font.Assign(Header.GroupFont);

          hdr := gc;

          if pos('</',hdr) > 0 then
          begin
            HTMLDrawEx(ACanvas, hdr, DrawRect, PlannerImages, 0, 0, -1, -1, 1, False, False,
            True, False, True, False, False
            ,False
            , FHTMLFactor, URLColor, clNone, clNone, clGray, a, sa, fa, XS, YS, ml, hl, hr
            , cr, CID, CV, CT, FImageCache, FContainer, Handle
            );
          end
          else
          begin
            PrinterDrawString(ACanvas,CLFToLF(hdr), DrawRect,
              AlignToFlag(Header.Alignment) OR VAlignToFlag(Header.VAlignment) OR WordWrapToFlag(hdr,Header.WordWrap) );
          end;

          hdr := '';
          ACanvas.Font.Assign(Header.Font);
        end;
      end;

      if (PositionGroup > 0) and (Header.CustomGroups.Count = 0) then
      begin
        if (PositionIndex mod PositionGroup = 0) or (PositionIndex = FromPos) then
        begin
          DrawRect.Left := LeftIndent + SideBarWidth + (ColumnWidth * (PositionIndex - FromPos));
          DrawRect.Top := 1 + TopIndent;
          DrawRect.Right := DrawRect.Left + ColumnWidth * (PositionGroup - (PositionIndex mod PositionGroup));

          if DrawRect.Right > LeftIndent + SideBarWidth + ColumnWidth * (1 + ToPos - FromPos) then
            DrawRect.Right := LeftIndent + SideBarWidth + ColumnWidth * (1 + ToPos - FromPos);

          DrawRect.Bottom := GroupHeight + TopIndent;

          ACanvas.Brush.Color := FHeader.Color;
          if FHeader.ColorTo <> clNone then
            DrawGradient(ACanvas,ACanvas.Brush.Color,FHeader.ColorTo, 64, DrawRect, false)
          else
            ACanvas.Rectangle(DrawRect.Left, DrawRect.Top, DrawRect.Right, DrawRect.Bottom);

          RectLine(ACanvas, DrawRect, GridLineColor, PrintOptions.LineWidth);

          if Header.GroupCaptions.Count > GroupIndex then
          begin
            InflateRect(DrawRect, -1, -1);

            ACanvas.Font.Assign(Header.GroupFont);
            ACanvas.Brush.Style := bsClear;

            hdr := Header.GroupCaptions[GroupIndex];
            if pos('</',hdr) > 0 then
            begin
              HTMLDrawEx(ACanvas, hdr, DrawRect, PlannerImages, 0, 0, -1, -1, 1, False, False,
              True, False, True, False, False
              ,False
              , FHTMLFactor, URLColor, clNone, clNone, clGray, a, sa, fa, XS, YS, ml, hl, hr
              , cr, CID, CV, CT, FImageCache, FContainer, Handle
              );
            end
            else
            begin
              PrinterDrawString(ACanvas,CLFToLF(hdr), DrawRect,
                AlignToFlag(Header.Alignment) OR VAlignToFlag(Header.VAlignment) OR WordWrapToFlag(hdr,Header.WordWrap));
            end;

            ACanvas.Font.Assign(Header.Font);
          end;
          inc(GroupIndex);
        end;

      end;

      DrawRect.Left := LeftIndent + SideBarWidth + (ColumnWidth * (PositionIndex - FromPos));
      DrawRect.Top := 4 + PrintOptions.LineWidth + TopIndent + GroupHeight;
      DrawRect.Right := DrawRect.Left + ColumnWidth;
      DrawRect.Bottom := HeaderHeight + GroupHeight + TopIndent;


      ACanvas.Brush.Color := FHeader.Color;
      if FHeader.ColorTo <> clNone then
        DrawGradient(ACanvas,ACanvas.Brush.Color,FHeader.ColorTo, 64, DrawRect, false)
      else
        ACanvas.Rectangle(DrawRect.Left, DrawRect.Top, DrawRect.Right, DrawRect.Bottom);

      RectLine(ACanvas, DrawRect, GridLineColor, PrintOptions.LineWidth);

      InflateRect(DrawRect, -1, -1);

      DoDraw := True;
      ACanvas.Brush.Color := FColor;

      if Assigned(FOnPlannerHeaderDraw) then
      begin
        Font := Self.Font;
        ACanvas.Brush.Color := FColor;
        ACanvas.Pen.Color := FHeader.FLineColor;
        ACanvas.Pen.Width := 1;
        FOnPlannerHeaderDraw(Self, ACanvas, DrawRect, PositionIndex + 1, DoDraw);
      end;

      if DoDraw then
      begin
        DrawRect.Bottom := DrawRect.Top + Round(HeaderHeight * Header.TextHeight /
          Header.Height);

        ACanvas.Brush.Style := bsClear;

        if Header.Captions.Count > PositionIndex + Side then
        begin
          hdr := Header.Captions[PositionIndex + Side];

          if pos('</',hdr) > 0 then
          begin
            HTMLDrawEx(ACanvas, hdr, DrawRect, PlannerImages, 0, 0, -1, -1, 1, False, False,
            True, False, True, False, False
            ,False
            , FHTMLFactor, URLColor, clNone, clNone, clGray, a, sa, fa, XS, YS, ml, hl, hr
            , cr, CID, CV, CT, FImageCache, FContainer, Handle
            );
          end
          else
          begin
            PrinterDrawString(ACanvas,CLFToLF(hdr), DrawRect,
              AlignToFlag(Header.Alignment) OR VAlignToFlag(Header.VAlignment) OR WordWrapToFlag(hdr,Header.WordWrap));
          end;
        end;

        APlannerItem := Items.HeaderFirst(PositionIndex);
        while Assigned(APlannerItem) do
        begin
          DrawRect.Left := DrawRect.Left + 2;
          DrawRect.Right := DrawRect.Right - 2;
          DrawRect.Top := DrawRect.Bottom;
          DrawRect.Bottom := DrawRect.Top + Round(HeaderHeight * Header.ItemHeight /
            Header.Height);

          APlannerItem.FRepainted := False;
          {Paint full Items here}
          FGrid.PaintItemCol(ACanvas, DrawRect, APlannerItem, True, False);
          APlannerItem := Items.HeaderNext(PositionIndex);
        end;
      end;

    end;
  end;

  // Draw the background cells
  for RowIndex := FromRow to ToRow do
    for PositionIndex := FromPos to ToPos do
    begin
      // nr. of Items at cell
      NumberOfConflicts := Items.NumItem(RowIndex, RowIndex, PositionIndex);

      // Cell bounding rect
      DrawRect.Left := LeftIndent + SideBarWidth + ColumnWidth * (PositionIndex - FromPos);
      DrawRect.Top := TopIndent + HeaderHeight + GroupHeight + ColumnHeight * (RowIndex - FromRow);
      DrawRect.Right := DrawRect.Left + ColumnWidth;
      DrawRect.Bottom := DrawRect.Top + ColumnHeight;
      RectLineEx(ACanvas, DrawRect, GridLineColor, PrintOptions.LineWidth);

      BottomPen := TPen.Create;
      BottomPen.Assign(ACanvas.Pen);

      BottomPen.Width := PrintOptions.LineWidth;
      BottomPen.Color := GridLineColor;

      if (Mode.PlannerType = plDay) then
      begin
        if ((RowIndex + 1 + Display.DisplayStart) * Display.DisplayUnit mod 60 = 0) then
          BottomPen.Color := Display.HourLineColor;
      end;

      if Assigned(FOnPlannerBottomLine) then
        FOnPlannerBottomLine(Self, RowIndex, PositionIndex, BottomPen);

      GetCellBrush(PositionIndex,RowIndex,ACanvas.Brush);
      ACanvas.Pen.Color := BottomPen.Color;
      ACanvas.Pen.Width := BottomPen.Width;
      ACanvas.MoveTo(DrawRect.Left, DrawRect.Bottom);
      ACanvas.LineTo(DrawRect.Right, DrawRect.Bottom);
      BottomPen.Free;

      ACanvas.Pen.Color := GridLineColor;
      ACanvas.Pen.Width := PrintOptions.LineWidth;

      if GapWidth > 0 then
      begin
        SRect := DrawRect;
        SRect.Right := SRect.Left + GapWidth;
        RectLine(ACanvas, SRect, GridLineColor, PrintOptions.LineWidth);
        InflateRect(SRect, -1, -1);
        ACanvas.Rectangle(SRect.Left, SRect.Top, SRect.Right, SRect.Bottom);

        ACanvas.Font.Assign(Sidebar.Font);

        if (Assigned(FOnPlannerSideProp)) then
          FOnPlannerSideProp(Self, PositionIndex, ACanvas.Brush, ACanvas.Font, AColorTo);

        FGrid.PaintSideCol(ACanvas, SRect, RowIndex, PositionIndex, 0, False, True);
        DrawRect.Left := DrawRect.Left + GapWidth;
      end;

      if (BackGroundColor[PositionIndex, RowIndex] <> clNone) then
        ACanvas.Brush.Color := BackGroundColor[PositionIndex, RowIndex];

      //if Selected[PositionIndex, RowIndex] then
      //  ACanvas.Brush.Color := DisjunctSelectColor;

      InflateRect(DrawRect, -1, -1);
      ACanvas.FillRect(DrawRect);
      ACanvas.Brush.Color := Color;

      APlannerItem := Items.FindBackground(RowIndex, PositionIndex);

      if Assigned(APlannerItem) then
      begin
        ARect := DrawRect;
        InflateRect(ARect,1,1);
        NRect.Top := ARect.Top -
          ((RowIndex - Max(FromRow,APlannerItem.ItemBegin)) * (ARect.Bottom - ARect.Top));

        NRect.Bottom := ARect.Bottom +
          ((Min(ToRow + 1,APlannerItem.ItemEnd) - RowIndex - 1) * (ARect.Bottom - ARect.Top));
        NRect.Left := ARect.Left;
        NRect.Right := ARect.Right;

        APlannerItem.Repainted := False;
        FGrid.PaintItemCol(ACanvas, NRect, APlannerItem, True, False);
      end;

      if (Assigned(FOnPlannerBkgDraw)) then
        FOnPlannerBkgDraw(Self, ACanvas, DrawRect, RowIndex, PositionIndex);
    end;

  // Draw the normal cells
  for RowIndex := FromRow to ToRow do
    for PositionIndex := FromPos to ToPos do
    begin
      // nr. of Items at cell
      NumberOfConflicts := Items.NumItem(RowIndex, RowIndex, PositionIndex);

      // Cell bounding rect
      DrawRect.Left := LeftIndent + SideBarWidth + GapWidth + ColumnWidth * (PositionIndex - FromPos);
      DrawRect.Top := TopIndent + HeaderHeight + GroupHeight + ColumnHeight * (RowIndex - FromRow);
      DrawRect.Right := DrawRect.Left + ColumnWidth - GapWidth;
      DrawRect.Bottom := DrawRect.Top + ColumnHeight;

      for SubIndex := 0 to NumberOfConflicts.Y do
      begin
        ARect := DrawRect;
        //InflateRect(ARect,1,1);
        if (NumberOfConflicts.Y > 0) then
        begin
          ConflictingCellWidth := (ARect.Right - ARect.Left) div (NumberOfConflicts.Y);
          ARect.Left := ARect.Left + SubIndex * ConflictingCellWidth;
          ARect.Right := ARect.Left + ConflictingCellWidth;
        end;

        APlannerItem := Items.FindItemIndex(RowIndex, PositionIndex, SubIndex);
        if (APlannerItem <> nil) then
        begin
          NRect.Top := ARect.Top -
            ((RowIndex - Max(FromRow, APlannerItem.ItemBegin)) * (ARect.Bottom - ARect.Top));
          NRect.Bottom := ARect.Bottom +
            ((Min(ToRow + 1,APlannerItem.ItemEnd) - RowIndex - 1) * (ARect.Bottom - ARect.Top));
          NRect.Left := ARect.Left;
          NRect.Right := ARect.Right;
          APlannerItem.Repainted := False;
          FGrid.PaintItemCol(ACanvas, NRect, APlannerItem, True, False);
          ARect.Left := ARect.Right - FItemGap;
          {item found, paint only extra rect at Right}
        end;
      end;
    end;


  // Draw the Footer
  if FFooter.Visible then
  begin
    SetBkMode(ACanvas.Handle,TRANSPARENT);

    for PositionIndex := FromPos to ToPos do
    begin
      ACanvas.Font.Assign(Footer.Font);
      ACanvas.Brush.Color := FColor;

      DrawRect.Left := LeftIndent + SideBarWidth + (ColumnWidth * (PositionIndex - FromPos));
      DrawRect.Top := TopIndent + HeaderHeight + GroupHeight + ColumnHeight * (ToRow - FromRow + 1);
      DrawRect.Right := DrawRect.Left + ColumnWidth;
      DrawRect.Bottom := DrawRect.Top + FooterHeight;

      RectLine(ACanvas, DrawRect, GridLineColor, PrintOptions.LineWidth);

      InflateRect(DrawRect, -1, -1);

      DoDraw := True;
      ACanvas.Brush.Color := FColor;

      if Assigned(FOnPlannerFooterDraw) then
      begin
        Font := Self.Font;
        ACanvas.Brush.Color := FColor;
        ACanvas.Pen.Color := FFooter.FLineColor;
        ACanvas.Pen.Width := PrintOptions.LineWidth;
        FOnPlannerFooterDraw(Self, ACanvas, DrawRect, PositionIndex + 1, DoDraw);
      end;

      if DoDraw then
      begin
        DrawRect.Bottom := DrawRect.Top + FooterHeight;

        if Footer.Captions.Count > PositionIndex + Side then
        begin
          hdr := Footer.Captions[PositionIndex + Side];
          if pos('</',hdr) > 0 then
          begin
            HTMLDrawEx(ACanvas, hdr, DrawRect, PlannerImages, 0, 0, -1, -1, 1, False, False,
            True, False, True, False, False
            ,False
            , FHTMLFactor, URLColor, clNone, clNone, clGray, a, sa, fa, XS, YS, ml, hl, hr
            , cr, CID, CV, CT, FImageCache, FContainer, Handle
            );
          end
          else
            PrinterDrawString(ACanvas,CLFToLF(hdr), DrawRect,
              AlignToFlag(Footer.Alignment));
        end;
      end;
    end;
  end;


  FHTMLFactor := 1.0;

{$IFDEF FREEWARE}
  PrintFreewareNotice(ACanvas, XSize, YSize, Self.ClassName);
{$ENDIF}
end;

procedure TCustomPlanner.PrintRow(ACanvas:TCanvas; FromPos, ToPos, FromCol, ToCol: Integer);
var
  XSize, YSize: Integer;
  PositionIndex, ColIndex, SubIndex, ConflictingCellWidth: Integer;
  NumberOfConflicts: TPoint;
  DrawRect, ARect, NRect: TRect;
  APlannerItem: TPlannerItem;
  SideBarWidth, HeaderHeight, GroupHeight, GroupIndex: Integer;
  LeftIndent, TopIndent: Integer;
  ColumnWidth, ColumnHeight: Integer;
  PrintPositions, NumRows: Integer;
  DoDraw: Boolean;
  SizedRows: Boolean;
  BottomPen: TPen;
  HeadIndent,MaxRight: Integer;
  hdr,a,sa,fa:string;
  XS, YS, ml, hl: Integer;
  cr,hr: TRect;
  CID,CV,CT:string;
  AColorTo: TColor;
  gs: integer;
  gc: string;

begin
  PrintPositions := (ToPos - FromPos) + 1;

  if Assigned(FOnPrintStart) then
    FOnPrintStart(Self, ACanvas);

  XSize := ACanvas.ClipRect.Right - ACanvas.ClipRect.Left -
    FPrintOptions.FLeftMargin - FPrintOptions.FRightMargin;
  YSize := ACanvas.ClipRect.Bottom - ACanvas.ClipRect.Top -
    FPrintOptions.FHeaderSize - FPrintOptions.FFooterSize;

  FHTMLFactor := CanvasToHTMLFactor(Canvas,ACanvas);

  if FSidebar.Visible then
    NumRows := PrintPositions + 1
  else
    NumRows := PrintPositions;

  SizedRows := (Round(FGrid.RowHeights[1] * NumRows {* FHTMLFactor}) > YSize);

  if SizedRows or FPrintOptions.FFitToPage then
    ColumnHeight := (YSize div NumRows)
  else
    ColumnHeight := Round(FGrid.RowHeights[1] {* FHTMLFactor});

  LeftIndent := FPrintOptions.FLeftMargin;
  TopIndent := FPrintOptions.FHeaderSize;

  HeadIndent := LeftIndent;

  // Draw Header
  if FPrintOptions.FHeader.Count > 0 then
  begin
    DrawRect.Left := LeftIndent;
    DrawRect.Right := XSize;
    DrawRect.Top := 0;
    DrawRect.Bottom := TopIndent;
    ACanvas.Brush.Style := bsClear;
    ACanvas.Font.Assign(FPrintOptions.FHeaderFont);
    SetBkMode(ACanvas.Handle,TRANSPARENT);

    if pos('</',FPrintOptions.FHeader.Text) > 0 then
      HTMLDrawEx(ACanvas, FPrintOptions.FHeader.Text, DrawRect, PlannerImages, 0, 0, -1, -1, 1, False, False,
      True, False, True, False, False
      ,False
      , FHTMLFactor, URLColor, clNone, clNone, clGray, a, sa, fa, XS, YS, ml, hl, hr
      , cr, CID, CV, CT, FImageCache, FContainer, Handle
      )
    else
      PrinterDrawString(ACanvas,FPrintOptions.FHeader.Text, DrawRect,
        AlignToFlag(FPrintOptions.FHeaderAlignment));
  end;

  // Draw Footer
  if (FPrintOptions.FFooter.Count > 0) or Assigned(FOnPrintFooter) then
  begin
    DrawRect.Left := LeftIndent;
    DrawRect.Right := XSize;
    DrawRect.Top := YSize;
    DrawRect.Bottom := YSize + FPrintOptions.FFooterSize;

    DrawRect.Top := YSize + FPrintOptions.FHeaderSize;
    DrawRect.Bottom := DrawRect.Top + FPrintOptions.FFooterSize;
    ACanvas.Brush.Style := bsClear;
    ACanvas.Font.Assign(FPrintOptions.FFooterFont);
    SetBkMode(ACanvas.Handle,TRANSPARENT);

    if Assigned(FOnPrintFooter) then
      FOnPrintFooter(Self, ACanvas, DrawRect)
    else
    begin
      if pos('</',FPrintOptions.FFooter.Text) > 0 then
        HTMLDrawEx(ACanvas, FPrintOptions.FFooter.Text, DrawRect, PlannerImages, 0, 0, -1, -1, 1, False, False,
        True, False, True, False, False
        ,False
        , FHTMLFactor, URLColor, clNone, clNone, clGray, a, sa, fa, XS, YS, ml, hl, hr
        , cr, CID, CV, CT, FImageCache, FContainer, Handle
        )
      else
        PrinterDrawString(ACanvas,FPrintOptions.FFooter.Text, DrawRect,
          AlignToFlag(FPrintOptions.FFooterAlignment));
    end;
  end;

  SideBarWidth := 0;
  GroupHeight := 0;

  if PositionGroup > 0 then
    GroupIndex := FromPos div PositionGroup
  else
    GroupIndex := 0;

  HeaderHeight := Round(XSize * (Header.Height / (FGrid.ColWidths[0] *
    (ToCol - FromCol + 1))));

  //if PrintOptions.HeaderSize > 0 then
  //  HeaderHeight := PrintOptions.HeaderSize;

  if FHeader.Visible and (PositionGroup > 0) then
    GroupHeight := HeaderHeight;

  // XSize := XSize - HeaderHeight - GroupHeight;

  ColumnWidth := (XSize - HeaderHeight - GroupHeight) div (ToCol - FromCol + 1);


  if FPrintOptions.CellHeight > 0 then
    ColumnHeight := FPrintOptions.CellHeight;

  if FPrintOptions.CellWidth > 0 then
    ColumnWidth := FPrintOptions.CellWidth;

  // Print the SideBar on Top
  if Sidebar.Visible then
  begin
    if SizedRows or FPrintOptions.FitToPage then
      SideBarWidth := Round(YSize * (FGrid.RowHeights[0] / (FGrid.RowHeights[1]
        * (PrintPositions))))
    else
      SideBarWidth := Round(FGrid.RowHeights[0] {* FHTMLFactor});

    if FPrintOptions.SidebarWidth > 0 then
      SidebarWidth := FPrintOptions.SidebarWidth;

    for ColIndex := FromCol to ToCol do
    begin
      DrawRect.Top := TopIndent;
      DrawRect.Left := LeftIndent + HeaderHeight + ColumnWidth * (ColIndex - FromCol);
      DrawRect.Bottom := DrawRect.Top + SideBarWidth;
      DrawRect.Right := DrawRect.Left + ColumnWidth;

      ACanvas.Font.Assign(Sidebar.Font);
      ACanvas.Brush.Color := Sidebar.Background;

      if (Assigned(FOnPlannerSideProp)) then
        FOnPlannerSideProp(Self, ColIndex, ACanvas.Brush, ACanvas.Font, AColorTo);

      ACanvas.Pen.Color := ACanvas.Brush.Color;
      ACanvas.Pen.Width := PrintOptions.LineWidth;

      ACanvas.Rectangle(DrawRect.Left, DrawRect.Top, DrawRect.Right, DrawRect.Bottom);

      InflateRect(DrawRect, -1, -1);

      ACanvas.Pen.Color := SideBar.SeparatorLineColor;
      ACanvas.Pen.Width := PrintOptions.LineWidth;

      if (Assigned(FOnPlannerSideDraw)) then
        FOnPlannerSideDraw(Self, ACanvas, DrawRect, ColIndex)
      else
      begin
        FGrid.PaintSideRow(ACanvas, DrawRect, ColIndex, 0, False, True, ColumnWidth);

        if Assigned(FOnPlannerSideDrawAfter) then
          FOnPlannerSideDrawAfter(Self, ACanvas, DrawRect, ColIndex);
      end;

      ACanvas.Brush.Color := Color;
      ACanvas.Font.Assign(Font);
    end;
  end;

  // Draw the Header
  if FHeader.Visible then
  begin
    SetBkMode(ACanvas.Handle,TRANSPARENT);
    for PositionIndex := FromPos to ToPos do
    begin
      ACanvas.Font.Assign(Header.Font);

      if (PositionGroup = 1) and (Header.CustomGroups.Count > 0) then
      begin
        gs := Header.GroupSplit(PositionIndex);
        gc := Header.GetGroupCaption(PositionIndex);

        if gs <> - 1 then
        begin
          DrawRect.Top := TopIndent + SideBarWidth + (ColumnHeight * (PositionIndex - FromPos));
          DrawRect.Left := 1 + LeftIndent;
          DrawRect.Right := (GroupHeight div 2) + LeftIndent;
          DrawRect.Bottom := DrawRect.Top + ColumnHeight * gs;

          if DrawRect.Bottom > TopIndent + SideBarWidth + ColumnHeight * (1 + ToPos - FromPos) then
            DrawRect.Bottom := TopIndent + SideBarWidth + ColumnHeight * (1 + ToPos - FromPos);

          ACanvas.Brush.Color := FHeader.Color;
          if FHeader.ColorTo <> clNone then
            DrawGradient(ACanvas,ACanvas.Brush.Color,FHeader.ColorTo, 64, DrawRect, true)
          else
            ACanvas.Rectangle(DrawRect.Left, DrawRect.Top, DrawRect.Right, DrawRect.Bottom);

          RectLine(ACanvas, DrawRect, GridLineColor, PrintOptions.LineWidth);

          InflateRect(DrawRect, -1, -1);

          ACanvas.Font.Assign(Header.GroupFont);

          hdr := gc;

          if pos('</',hdr) > 0 then
          begin
            HTMLDrawEx(ACanvas, hdr, DrawRect, PlannerImages, 0, 0, -1, -1, 1, False, False,
            True, False, True, False, False
            ,False
            , FHTMLFactor, URLColor, clNone, clNone, clGray, a, sa, fa, XS, YS, ml, hl, hr
            , cr, CID, CV, CT, FImageCache, FContainer, Handle
            );
          end
          else
          begin
            PrinterDrawString(ACanvas,CLFToLF(hdr), DrawRect,
              AlignToFlag(Header.Alignment));
          end;

          hdr := '';

          ACanvas.Font.Assign(Header.Font);

        end;
      end;

      if (PositionGroup > 1) and (Header.CustomGroups.Count > 0) then
      begin
        if (PositionIndex mod PositionGroup = 0) or (PositionIndex = FromPos) then
        begin
          DrawRect.Top := TopIndent + SideBarWidth + (ColumnHeight * (PositionIndex - FromPos));
          DrawRect.Left := 1 + LeftIndent;
          DrawRect.Right := (GroupHeight div 2) + LeftIndent;

          DrawRect.Bottom := DrawRect.Top + ColumnHeight * (PositionGroup - (PositionIndex mod PositionGroup));

          if DrawRect.Bottom > TopIndent + SideBarWidth + ColumnHeight * (1 + ToPos - FromPos) then
            DrawRect.Bottom := TopIndent + SideBarWidth + ColumnHeight * (1 + ToPos - FromPos);

          ACanvas.Brush.Color := FHeader.Color;
          if FHeader.ColorTo <> clNone then
            DrawGradient(ACanvas,ACanvas.Brush.Color,FHeader.ColorTo, 64, DrawRect, true)
          else
            ACanvas.Rectangle(DrawRect.Left, DrawRect.Top, DrawRect.Right, DrawRect.Bottom);

          RectLine(ACanvas, DrawRect, GridLineColor, PrintOptions.LineWidth);

          if Header.GroupCaptions.Count > GroupIndex then
          begin
            InflateRect(DrawRect, -1, -1);

            ACanvas.Font.Assign(Header.GroupFont);

            hdr := Header.GroupCaptions[GroupIndex];
            if pos('</',hdr) > 0 then
            begin
              HTMLDrawEx(ACanvas, hdr, DrawRect, PlannerImages, 0, 0, -1, -1, 1, False, False,
              True, False, True, False, False
              ,False
              , FHTMLFactor, URLColor, clNone, clNone, clGray, a, sa, fa, XS, YS, ml, hl, hr
              , cr, CID, CV, CT, FImageCache, FContainer, Handle
              );
            end
            else
            begin
              PrinterDrawString(ACanvas,CLFToLF(hdr), DrawRect,
                AlignToFlag(Header.Alignment));
            end;

            hdr := '';

            ACanvas.Font.Assign(Header.Font);
          end;
          inc(GroupIndex);
        end;
      end;

      DrawRect.Top := TopIndent + SideBarWidth + ColumnHeight * (PositionIndex - FromPos);
      DrawRect.Left := 1 + LeftIndent + (GroupHeight div 2);
      DrawRect.Bottom := DrawRect.Top + ColumnHeight;
      DrawRect.Right := HeaderHeight + LeftIndent;

      ACanvas.Brush.Color := FHeader.Color;
      if FHeader.ColorTo <> clNone then
        DrawGradient(ACanvas,ACanvas.Brush.Color,FHeader.ColorTo, 64, DrawRect, true)
      else
        ACanvas.Rectangle(DrawRect.Left, DrawRect.Top, DrawRect.Right, DrawRect.Bottom);

      RectLine(ACanvas, DrawRect, GridLineColor, PrintOptions.LineWidth);

      HeadIndent := DrawRect.Right;

      InflateRect(DrawRect, -1, -1);

      DoDraw := True;
      if Assigned(FOnPlannerHeaderDraw) then
      begin
        Font := Self.Font;
        ACanvas.Brush.Color := FColor;
        ACanvas.Pen.Color := FHeader.FLineColor;
        ACanvas.Pen.Width := PrintOptions.LineWidth;
        FOnPlannerHeaderDraw(Self, ACanvas, DrawRect, PositionIndex + 1, DoDraw);
      end;

      if DoDraw then
      begin
        DrawRect.Bottom := DrawRect.Top + Round(HeaderHeight * Header.TextHeight /
          Header.Height);

        ACanvas.Brush.Style := bsClear;

        if (FSidebar.Visible) then
        begin
          (*
          if Header.GroupCaptions.Count > PositionIndex + 1 then
          begin
            ACanvas.Font.Assign(Header.GroupFont);

            hdr := Header.GroupCaptions[PositionIndex + 1];
            if pos('</',hdr) > 0 then
            begin
              HTMLDrawEx(ACanvas, hdr, DrawRect, PlannerImages, 0, 0, -1, -1, 1, False, False,
              True, False, True, False, False
              ,False
              , FHTMLFactor, URLColor, clNone, clNone, clGray, a, sa, fa, XS, YS, ml, hl, hr
              , cr, CID, CV, CT, FImageCache, FContainer, Handle
              );
            end
            else
              PrinterDrawString(ACanvas,CLFToLF(hdr),
                DrawRect, AlignToFlag(Header.Alignment));

            ACanvas.Font.Assign(Header.Font);
          end;
          *)

          if Header.Captions.Count > PositionIndex + 1 then
            PrinterDrawString(ACanvas,CLFToLF(Header.Captions[PositionIndex + 1]),
              DrawRect, AlignToFlag(Header.Alignment))
        end
        else
        begin
          if Header.Captions.Count > PositionIndex + 1 then
            PrinterDrawString(ACanvas,Header.Captions[PositionIndex + 1],
              DrawRect, AlignToFlag(Header.Alignment));
        end;

        APlannerItem := Items.HeaderFirst(PositionIndex);
        while Assigned(APlannerItem) do
        begin
          DrawRect.Left := DrawRect.Left + 2;
          DrawRect.Right := DrawRect.Right - 2;
          DrawRect.Top := DrawRect.Bottom;
          DrawRect.Bottom := DrawRect.Top + Round(HeaderHeight * Header.ItemHeight /
            Header.Height);

          APlannerItem.FRepainted := False;
          {Paint full Items here}
          FGrid.PaintItemCol(Canvas, DrawRect, APlannerItem, True, False);
          APlannerItem := Items.HeaderNext(PositionIndex);
        end;
      end;

    end;
  end;

  // Draw the background cells

  for ColIndex := FromCol to ToCol do
    for PositionIndex := FromPos to ToPos do
    begin
      // Nr. of Items at cell
      NumberOfConflicts := Items.NumItem(ColIndex, ColIndex, PositionIndex);

      // Cell bounding rect
      DrawRect.Top := TopIndent + SideBarWidth + ColumnHeight * (PositionIndex - FromPos);
      DrawRect.Left := LeftIndent + HeaderHeight + ColumnWidth * (ColIndex - FromCol);
      DrawRect.Bottom := DrawRect.Top + ColumnHeight;
      DrawRect.Right := DrawRect.Left + ColumnWidth;

      if DrawRect.Left < HeadIndent then
        DrawRect.Left := HeadIndent;

      if DrawRect.Right > XSize then
        DrawRect.Right := XSize;

      GetCellBrush(PositionIndex,ColIndex,ACanvas.Brush);

      if BackGroundColor[ColIndex,PositionIndex] <> clNone then
        ACanvas.Brush.Color := BackGroundColor[ColIndex,PositionIndex];

      //if Selected[ColIndex, PositionIndex] then
      //  ACanvas.Brush.Color := DisjunctSelectColor;

      RectLineExExEx(ACanvas, DrawRect, GridLineColor, PrintOptions.LineWidth);

      BottomPen := TPen.Create;
      BottomPen.Assign(ACanvas.Pen);

      BottomPen.Width := PrintOptions.LineWidth;
      BottomPen.Color := GridLineColor;

      //InflateRect(DrawRect, -1, -1);
      ACanvas.FillRect(DrawRect);
      ACanvas.Brush.Color := Color;

      if (Mode.PlannerType = plDay) then
      begin
        if ((ColIndex + 1 + Display.DisplayStart) * Display.DisplayUnit mod 60 = 0) then
          BottomPen.Color := Display.HourLineColor;
      end;

      if Assigned(FOnPlannerBottomLine) then
        FOnPlannerBottomLine(Self, ColIndex, PositionIndex, BottomPen);

      ACanvas.Pen.Color := BottomPen.Color;
      ACanvas.Pen.Width := BottomPen.Width;
      ACanvas.MoveTo(DrawRect.Right - (BottomPen.Width div 2), DrawRect.Top);
      ACanvas.LineTo(DrawRect.Right - (BottomPen.Width div 2), DrawRect.Bottom);
      ACanvas.Pen.Width := PrintOptions.LineWidth;
      BottomPen.Free;


      {
      if ColIndex = ToCol then
      begin
        ACanvas.MoveTo(DrawRect.Right, DrawRect.Top);
        ACanvas.LineTo(DrawRect.Right, DrawRect.Bottom);
      end;

      if PositionIndex = ToPos then
      begin
        ACanvas.MoveTo(DrawRect.Left, DrawRect.Bottom);
        ACanvas.LineTo(DrawRect.Right, DrawRect.Bottom);
      end;
      }
      
      APlannerItem := Items.FindBackground(ColIndex , PositionIndex);

      if Assigned(APlannerItem) then
      begin
        ARect := DrawRect;
        InflateRect(DrawRect, 1, 1);

        NRect.Left := ARect.Left - ((ColIndex - APlannerItem.ItemBegin) * (ARect.Right -
           ARect.Left));
        NRect.Right := ARect.Right + ((APlannerItem.ItemEnd - ColIndex - 1) * (ARect.Right
           - ARect.Left));
        NRect.Top := ARect.Top;
        NRect.Bottom := ARect.Bottom;

        if NRect.Left < HeadIndent then
          NRect.Left := HeadIndent;

        if NRect.Right > XSize then
          NRect.Right := XSize;

        APlannerItem.Repainted := False;
        FGrid.PaintItemRow(ACanvas, NRect, APlannerItem, True, False);
      end;
      
      if (Assigned(FOnPlannerBkgDraw)) then
        FOnPlannerBkgDraw(Self, ACanvas, DrawRect, ColIndex, PositionIndex);
    end;

  // Draw the normal cells
  for ColIndex := FromCol to ToCol do
    for PositionIndex := FromPos to ToPos do
    begin
      // Nr. of Items at cell
      NumberOfConflicts := Items.NumItem(ColIndex, ColIndex, PositionIndex);

      // Cell bounding rect
      DrawRect.Top := TopIndent + SideBarWidth + ColumnHeight * (PositionIndex - FromPos);
      DrawRect.Left := LeftIndent + HeaderHeight + ColumnWidth * (ColIndex - FromCol);
      DrawRect.Bottom := DrawRect.Top + ColumnHeight;
      DrawRect.Right := DrawRect.Left + ColumnWidth;

      if DrawRect.Left < HeadIndent then
        DrawRect.Left := HeadIndent;

      for SubIndex := 0 to NumberOfConflicts.Y do
      begin
        ARect := DrawRect;
        //InflateRect(DrawRect, 1, 1);

        if (NumberOfConflicts.Y > 0) then
        begin
          ConflictingCellWidth := (ARect.Bottom - ARect.Top) div (NumberOfConflicts.Y);
          ARect.Top := ARect.Top + SubIndex * ConflictingCellWidth;
          ARect.Bottom := ARect.Top + ConflictingCellWidth;
        end;

        APlannerItem := Items.FindItemIndex(ColIndex, PositionIndex, SubIndex);

        if (APlannerItem <> nil) then
        begin
          NRect.Left := ARect.Left - ((ColIndex - APlannerItem.ItemBegin) * (ARect.Right - ARect.Left));
          NRect.Right := ARect.Right + ((APlannerItem.ItemEnd - ColIndex - 1) * (ARect.Right - ARect.Left));

          NRect.Top := ARect.Top;
          NRect.Bottom := ARect.Bottom;
          APlannerItem.Repainted := False;

          if NRect.Left < HeadIndent then
            NRect.Left := HeadIndent;

          if NRect.Right > XSize then
            NRect.Right := XSize;

          FGrid.PaintItemRow(ACanvas, NRect, APlannerItem, True, False);
          ARect.Left := ARect.Right - FItemGap;
          // Item found, paint only extra rect at Right
        end;
      end;
    end;

  FHTMLFactor := 1.0;

{$IFDEF FREEWARE}
  PrintFreewareNotice(ACanvas, XSize, YSize, Self.ClassName);
{$ENDIF}
end;

function TCustomPlanner.GetDayName(WeekDay: Integer): string;
begin
  if (WeekDay > DaysPerWeek) then
    WeekDay := WeekDay mod DaysPerWeek;

  while (WeekDay < FirstDayOfWeek) do
    WeekDay := WeekDay + DaysPerWeek;

  if (WeekDay <= FDayNames.Count) and (WeekDay > 0) then
    Result := FDayNames.Strings[WeekDay - 1]
  else
    case WeekDay of
      1: Result := ShortDaySun;
      2: Result := ShortDayMon;
      3: Result := ShortDayTue;
      4: Result := ShortDayWed;
      5: Result := ShortDayThu;
      6: Result := ShortDayFri;
      7: Result := ShortDaySat;
    end;
end;

procedure TCustomPlanner.ScrollToTime(ATime: TDateTime);
begin
  if (SideBar.Position in [spLeft, spRight, spLeftRight]) then
    GridTopRow := AbsTimeToCell(ATime)
  else
    GridLeftCol := AbsTimeToCell(ATime);
end;

procedure TCustomPlanner.SelectGrid;
begin
  if Assigned(Items.Selected) then
    Items.Selected.Focus := False;
  Items.Selected := nil;
  FGrid.SetFocus;
end;

function TCustomPlanner.RichToText: string;
var
  MemoryStream: TMemoryStream;
  {$IFNDEF DELPHI_UNICODE}
  RtfText: string;
  {$ENDIF}

  {$IFDEF DELPHI_UNICODE}
  RtfText: ansistring;
  i: integer;
  ch:ansichar;
  {$ENDIF}
begin
  MemoryStream := TMemoryStream.Create;

  {$IFDEF DELPHI_UNICODE}
  FRichEdit.Lines.SaveToStream(MemoryStream,TEncoding.Unicode);
  {$ENDIF}
  {$IFNDEF DELPHI_UNICODE}
  FRichEdit.Lines.SaveToStream(MemoryStream);
  {$ENDIF}

  MemoryStream.Position := 0;

  {$IFDEF DELPHI_UNICODE}
  rtftext := '';
  for i := 1 to memorystream.size  do
  begin
    MemoryStream.read(ch,1);
    RtfText := RtfText + ch;
  end;
  Result := WideString(RtfText);
  {$ENDIF}

  {$IFNDEF DELPHI_UNICODE}
  {$IFNDEF TMSDOTNET}
  if MemoryStream.Size > 0 then
    SetString(RtfText, PChar(MemoryStream.Memory), MemoryStream.Size);
  {$ENDIF}
  MemoryStream.Free;
  Result := RtfText;
  {$ENDIF}
end;

procedure TCustomPlanner.SetGridLineColor(const Value: TColor);
begin
  if Value <> GridLineColor then
  begin
    FGridLineColor := Value;
    FGrid.Invalidate;
  end;
end;

procedure TCustomPlanner.SetColor(const Value: TColor);
begin
  if Value <> Color then
  begin
    FColor := Value;
    FGrid.Color := FColor;
    FGrid.Invalidate;
  end;
end;

procedure TCustomPlanner.TextToRich(const RtfText: string);
var
  MemoryStream: TMemoryStream;
  {$IFDEF DELPHI_UNICODE}
  ch: char;
  ach: ansichar;
  i: integer;
  {$ENDIF}
begin
  {$IFDEF DELPHI_UNICODE}
  if RtfText <> '' then
  begin
    MemoryStream := TMemoryStream.Create;
    for i := 1 to length(rtftext) do
    begin
      ch := rtftext[i];
      ach := ansichar(ch);
      MemoryStream.Write(ach, 1);
    end;
    MemoryStream.Position := 0;
    FRichEdit.Lines.LoadFromStream(MemoryStream);
    MemoryStream.Free;
  end
  else
    RichEdit.Clear;
  {$ENDIF}

  {$IFNDEF DELPHI_UNICODE}
  if RtfText <> '' then
  begin
    MemoryStream := TMemoryStream.Create;
    MemoryStream.Write(RtfText[1], Length(RtfText));
    MemoryStream.Position := 0;
    FRichEdit.Lines.LoadFromStream(MemoryStream);
    MemoryStream.Free;
  end
  else
    FRichEdit.Clear;
  {$ENDIF}
end;

procedure TCustomPlanner.SaveToFile(FileName: string);
var
  FileStream: TFileStream;
begin
  FileStream := TFileStream.Create(FileName, fmCreate);
  try
    SaveToStream(FileStream);
  finally
    FileStream.Free;
  end;
end;

procedure TCustomPlanner.LoadFromFile(FileName: string);
var
  FileStream: TFileStream;
begin
  FileStream := TFileStream.Create(FileName, fmOpenRead);
  try
    LoadFromStream(FileStream);
  finally
    FileStream.Free;
  end;
end;

procedure TCustomPlanner.InsertFromFile(FileName: string);
var
  FileStream: TFileStream;
begin
  FileStream := TFileStream.Create(FileName, fmOpenRead);
  try
    InsertFromStream(FileStream);
  finally
    FileStream.Free;
  end;
end;

procedure TCustomPlanner.SavePositionToStream(Stream: TStream; Position: Integer);
var
  NewItems: TPlannerItems;
  ItemIndex: Integer;
  PlannerIO: TPlannerIO;

begin
  Items.SetTimeTags;
  NewItems := CreateItems;
  try
    for ItemIndex := 0 to Items.Count - 1 do
    begin
      if Items.Items[ItemIndex].ItemPos = Position then
      begin
        NewItems.Add.Assign(Items.Items[ItemIndex]);
      end;
    end;

    PlannerIO := TPlannerIO.Create(Self);
    try
      PlannerIO.Items.Assign(NewItems);
      Stream.WriteComponent(PlannerIO);
    finally
      PlannerIO.Free;
    end;
  finally
    NewItems.Free;
  end;
end;

procedure TCustomPlanner.LoadPositionFromStream(Stream: TStream; Position: Integer);
var
  NewItems: TPlannerItems;
  PlannerIO: TPlannerIO;
  ItemIndex: Integer;
  APlannerItem: TPlannerItem;

begin
  PlannerIO := TPlannerIO.Create(Self);
  try
    Stream.ReadComponent(PlannerIO);
    NewItems := CreateItems;
    try
      NewItems.Assign(PlannerIO.Items);
      Items.BeginUpdate;
      for ItemIndex := 0 to NewItems.Count - 1 do
      begin
        NewItems.Items[ItemIndex].ItemPos := Position;
        APlannerItem := Items.Add;
        APlannerItem.Assign(NewItems.Items[ItemIndex]);
        APlannerItem.GetTimeTag;
      end;

    finally
      Items.EndUpdate;
      NewItems.Free;
    end;
  finally
    PlannerIO.Free;
  end;
end;

procedure TCustomPlanner.SavePositionToFile(FileName: string; Position: Integer);
var
  FileStream: TFileStream;
begin
  FileStream := TFileStream.Create(FileName, fmCreate);
  try
    SavePositionToStream(FileStream, Position);
  finally
    FileStream.Free;
  end;
end;

procedure TCustomPlanner.LoadPositionFromFile(FileName: string; Position: Integer);
var
  FileStream: TFileStream;
begin
  FileStream := TFileStream.Create(FileName, fmOpenRead);
  try
    LoadPositionFromStream(FileStream, Position);
  finally
    FileStream.Free;
  end;
end;

procedure TCustomPlanner.SaveLayerToStream(Stream: TStream; Layer: Integer);
var
  NewItems: TPlannerItems;
  ItemIndex: Integer;
  PlannerIO: TPlannerIO;
begin
  Items.SetTimeTags;
  NewItems := CreateItems;
  try
    for ItemIndex := 0 to Items.Count - 1 do
    begin
      if Items.Items[ItemIndex].Layer = Layer then
      begin
        NewItems.Add.Assign(Items.Items[ItemIndex]);
      end;
    end;

    PlannerIO := TPlannerIO.Create(Self);
    try
      PlannerIO.Items.Assign(NewItems);
      Stream.WriteComponent(PlannerIO);
    finally
      PlannerIO.Free;
    end;
  finally
    NewItems.Free;
  end;
end;

procedure TCustomPlanner.LoadLayerFromStream(Stream: TStream; Layer: Integer);
var
  NewItems: TPlannerItems;
  PlannerIO: TPlannerIO;
  ItemIndex: Integer;
  APlannerItem: TPlannerItem;
begin
  PlannerIO := TPlannerIO.Create(Self);
  try
    Stream.ReadComponent(PlannerIO);
    NewItems := CreateItems;
    try
      NewItems.Assign(PlannerIO.Items);
      Items.BeginUpdate;
      for ItemIndex := 0 to NewItems.Count - 1 do
      begin
        NewItems.Items[ItemIndex].Layer := Layer;
        APlannerItem := Items.Add;
        APlannerItem.Assign(NewItems.Items[ItemIndex]);
        APlannerItem.GetTimeTag;
      end;
    finally
      Items.EndUpdate;
      NewItems.Free;
    end;
  finally
    PlannerIO.Free;
  end;
end;

procedure TCustomPlanner.SaveLayerToFile(FileName: string; Layer: Integer);
var
  FileStream: TFileStream;
begin
  FileStream := TFileStream.Create(FileName, fmCreate);
  try
    SaveLayerToStream(FileStream, Layer);
  finally
    FileStream.Free;
  end;
end;

procedure TCustomPlanner.LoadLayerFromFile(FileName: string; Layer: Integer);
var
  FileStream: TFileStream;
begin
  FileStream := TFileStream.Create(FileName, fmOpenRead);
  try
    LoadLayerFromStream(FileStream, Layer);
  finally
    FileStream.Free;
  end;
end;

procedure TCustomPlanner.SaveToStream(Stream: TStream);
var
  PlannerIO: TPlannerIO;
begin
  //save ItemBegin / ItemEnd correct for current display unit
  Items.BeginUpdate;
  Items.SetTimeTags;

  PlannerIO := TPlannerIO.Create(Self);
  try
    PlannerIO.Items.Assign(Self.Items);
    Stream.WriteComponent(PlannerIO);
  finally
    PlannerIO.Free;
  end;
  Items.EndUpdate;
end;

procedure TCustomPlanner.LoadFromStream(Stream: TStream);
var
  PlannerIO: TPlannerIO;
begin
  FLoading := True;
  try
    PlannerIO := TPlannerIO.Create(Self);
    try
      Stream.ReadComponent(PlannerIO);
      Items.Assign(PlannerIO.Items);
    finally
      PlannerIO.Free;
    end;
    Items.SetConflicts;
  finally
    FLoading := False;
  end;

  Items.BeginUpdate;
  Items.GetTimeTags;
  Items.OffsetItems(0);
  Items.EndUpdate;
end;

procedure TCustomPlanner.InsertFromStream(Stream: TStream);
var
  PlannerIO: TPlannerIO;
  NewItems: TPlannerItems;
  ItemIndex: Integer;
  APlannerItem: TPlannerItem;
begin
  PlannerIO := TPlannerIO.Create(Self);
  try
    Stream.ReadComponent(PlannerIO);
    NewItems := CreateItems;
    try
      NewItems.Assign(PlannerIO.Items);
      Items.BeginUpdate;

      for ItemIndex := 1 to NewItems.Count do
      begin
        APlannerItem := Items.Add;
        APlannerItem.Assign(NewItems.Items[ItemIndex - 1]);
        APlannerItem.GetTimeTag;
      end;
    finally
      NewItems.Free;
      Items.EndUpdate;
    end;
  finally
    PlannerIO.Free;
  end;
end;

function FontSizeToHtmlFontSize(FontSize: Integer): string;
begin
  case FontSize of
    1..8: Result := '"1"';
    9, 10: Result := '"2"';
    11, 12: Result := '"3"';
    13, 14: Result := '"4"';
    15..18: Result := '"5"';
    19..24: Result := '"6"';
  else
    Result := '"2"';
  end;
end;

function FontToHtmlFont(const Font: TFont): string;
begin
  Result := Format('<Font face="%s" size=%s>',
    [Font.Name, FontSizeToHtmlFontSize(Font.Size)]);
end;

function EmbedInHtmlTag(const Value: string; const Tag: string): string;
begin
  Result := Format('<%s>%s</%s>', [Tag, Value, Tag]);
end;

function EmbedInHtmlFontStyles(const Value: string; const FontStyle: TFontStyles): string;
begin
  Result := Value;
  if fsBold in FontStyle then
    Result := EmbedInHtmlTag(Result, 'B');
  if fsItalic in FontStyle then
    Result := EmbedInHtmlTag(Result, 'I');
  if fsUnderline in FontStyle then
    Result := EmbedInHtmlTag(Result, 'U');
end;

function EmbedInHtmlOptions(const Value: string;
  const FontStyle: TFontStyles; const FontTag: string): string;
begin
  Result := EmbedInHtmlFontStyles(Value, FontStyle);
  if (FontTag <> '') then
    Result := Format('<Font %s>%s</Font>', [FontTag, Result]);
end;

const
  Percent = '%';

function HtmlOptionsToHtmlTablePrefix(HTMLOptions: TPlannerHTMLOptions): string;
begin
//  style="border-collapse:collapse"

  with HTMLOptions do
    Result := Format('<table border="%d" cellspacing="%d" Width="%d%s"%s >',
      [BorderSize, CellSpacing, Width, Percent, TableStyle]);
end;

function PlannerGetIdCol(Planner: TCustomPlanner; Index, Position: Integer): string;
var
  Line1, Line2, Line3: string; // HoursString, MinutesString, AmPmString
  HS: Boolean;
begin
  Planner.FGrid.GetSideBarLines(Index, Position, Line1, Line2, Line3, HS);

  if Planner.Mode.PlannerType in [plDay,plTimeLine] then
  begin
    Result := Format('%s%s%s', [Line1, TimeSeparator, Line2]);
    if Line3 <> '' then
      Result := Format('%s %s', [Result, Line3]);
  end
  else
  begin
    Result := Line1 + Line2 + Line3;
  end;

end;

procedure TCustomPlanner.SaveToBMP(FileName: string; Size: TSize);
var
  BMP: TBitmap;
begin
  BMP := TBitmap.Create;
  BMP.Width := Size.cx;
  BMP.Height := Size.cy;

  PrintTo(BMP.Canvas);

  BMP.SaveToFile(FileName);

  BMP.Free;
end;

procedure TCustomPlanner.SaveToHTMLCol(FileName: string; Unicode: boolean = false);
var
  RowIndex, ColIndex, PosIndex: Integer;
  WidthPercentage, MaxPos, TotCol: Integer;
  TheBackgroundColor: TColor;
  HtmlText, HtmlBackGroundColor,ColSpan: string;
  APlannerItem: TPlannerItem;
  w, sw, txt: string;
  HtmlAlignment: string;
  rtf: string;
  GotSpan: Boolean;
  ABrush: TBrush;
  sl: TStringList;
  grp,grpm,grpc: integer;

begin
  HtmlText := '';

  if HtmlOptions.HeaderFile <> '' then
  begin
    sl := TStringList.Create;
    try
      sl.LoadFromFile(HtmlOptions.HeaderFile);
      HtmlText := HtmlText + sl.Text;
    finally
      sl.Free;
    end;
  end;


  with FGrid do
  begin
    HtmlText := HtmlText + HtmlOptions.PrefixTag + FontToHtmlFont(Self.Font) +
      HtmlOptionsToHtmlTablePrefix(HTMLOptions);

    WidthPercentage := Round((Sidebar.Width / Self.Width) * 100);
    w := Format('Width="%d%s"', [Round((100 - WidthPercentage) / ColCount), Percent]);
    sw := Format('Width="%d%s"', [WidthPercentage, Percent]);


    if PositionGroup > 0 then
    begin
      HtmlBackGroundColor := ColorToHtmlHexBgColor(Sidebar.Background);
      HtmlText := HtmlText + '<tr>';

      if (Sidebar.Position in [spLeft, spLeftRight]) then
      begin
        HtmlText := HtmlText + '<td '+ HtmlBackGroundColor +'>&nbsp;</td>';
      end;

      ColIndex := 0;
      grpc := 0;

      while ColIndex < ColCount - 1 do
      begin
        if PositionGroup = 1 then
        begin
          grpm := Header.CustomGroups.Items[grpc].Span;
        end
        else
          grpm := PositionGroup;

        MaxPos := 0;

        for grp := 1 to grpm do
        begin
          MaxPos := MaxPos + Items.MaxItemsInPos(ColIndex);
          ColIndex := ColIndex + 1;
        end;

        if (MaxPos > 1) and (ColIndex > 0) then
          ColSpan := ' colspan="'+ IntToStr(MaxPos)+'"'
        else
          ColSpan := '';

        HtmlText := HtmlText + '<td ' + w + ColSpan;

        HtmlAlignment := '';
        case Header.Alignment of
        taRightJustify: HtmlAlignment := ' align="Right"';
        taCenter: HtmlAlignment := ' align="center"';
        end;

        HtmlText := HtmlText + HtmlAlignment;

        if Header.GroupCaptions.Count > grpc then
          txt := CLToBR(Header.GroupCaptions[grpc])
        else
          txt := HtmlNonBreakingSpace;

        txt := EmbedInHtmlOptions(txt, HTMLOptions.HeaderFontStyle, HTMLOptions.HeaderFontTag);

        HtmlText := HtmlText + HtmlBackGroundColor + '>' + txt + '</td>'#13#10;

        inc(grpc);
      end;

      HtmlText := HtmlText + '</tr>';
    end;


    for ColIndex := 0 to ColCount - 1 do
    begin

      if (ColIndex = 0) then
        HtmlText := HtmlText + '<td ' + sw
      else
      begin
        MaxPos := Items.MaxItemsInPos(ColIndex - 1);

        {$IFDEF TMSDEBUG}
        outputdebugstring(pchar(inttostr(colindex-1)+':'+inttostr(maxpos)));
        {$ENDIF}

        if (MaxPos > 1) and (ColIndex > 0) then
          ColSpan := ' colspan="'+ IntToStr(MaxPos)+'"'
        else
          ColSpan := '';

        HtmlText := HtmlText + '<td ' + w + ColSpan;
      end;

      HtmlAlignment := '';
      case Header.Alignment of
      taRightJustify: HtmlAlignment := ' align="Right"';
      taCenter: HtmlAlignment := ' align="center"';
      end;

      HtmlText := HtmlText + HtmlAlignment;


      HtmlBackGroundColor := ColorToHtmlHexBgColor(Sidebar.Background);

      if Header.Captions.Count > ColIndex then
        txt := CLToBR(Header.Captions[ColIndex])
      else
        txt := HtmlNonBreakingSpace;

      txt := EmbedInHtmlOptions(txt, HTMLOptions.HeaderFontStyle, HTMLOptions.HeaderFontTag);

      HtmlText := HtmlText + HtmlBackGroundColor + '>' + txt + '</td>'#13#10
    end;

    HtmlText := HtmlText + '</tr>';

    w := '';

    for RowIndex := 0 to RowCount - 1 do
    begin
      HtmlText := HtmlText + '<tr>';


      for ColIndex := 0 to ColCount - 1 do
      begin
        GotSpan := False;

        if ColIndex = 0 then
        begin
          HtmlBackGroundColor := ColorToHtmlHexBgColor(Sidebar.Background);
          txt := PlannerGetIdCol(Self, RowIndex, ColIndex);

          txt := EmbedInHtmlOptions(txt, HTMLOptions.SidebarFontStyle, HTMLOptions.SidebarFontTag);

          HtmlText := HtmlText + '<td ' + sw + HtmlBackGroundColor + '>' + txt + '</td>';
        end
        else
        begin
          MaxPos := Items.MaxItemsInPos(ColIndex - 1);

          for PosIndex := 0 to MaxPos - 1 do
          begin
            HtmlBackGroundColor := '';

            ABrush := TBrush.Create;
            GetCellBrush(ColIndex - 1,RowIndex,ABrush);

            HtmlBackGroundColor := ColorToHtmlHexBgColor(ABrush.Color);

            ABrush.Free;

            TheBackgroundColor := BackGroundColor[ColIndex - 1, RowIndex];
            if TheBackgroundColor <> clNone then
              HtmlBackGroundColor := ColorToHtmlHexBgColor(TheBackgroundColor);

            APlannerItem := Items.FindItem(RowIndex, ColIndex - 1);

            if Assigned(APlannerItem) then
              TotCol := APlannerItem.Conflicts
            else
              TotCol := 0;

            APlannerItem := Items.FindItemPosIdx(RowIndex, ColIndex - 1, PosIndex);

            if Assigned(APlannerItem) then
            begin
              HtmlAlignment := ' valign="Top"';
              case APlannerItem.Alignment of
                taRightJustify: HtmlAlignment := HtmlAlignment + ' align="Right"';
                taCenter: HtmlAlignment := HtmlAlignment + ' align="center"';
              end;

              if (APlannerItem.ItemBegin = RowIndex) then
              begin
                rtf := APlannerItem.Text.Text;

                if IsRtf(rtf) then
                begin
                  TextToRich(rtf);
                  rtf := FRichEdit.Text;
                end
                else
                  rtf := HTMLConvert(rtf);

                if HTMLOptions.ShowCaption then
                  rtf := APlannerItem.GetCaptionString + '<HR>' + rtf;

                rtf := EmbedInHtmlOptions(rtf, HTMLOptions.CellFontStyle, HTMLOptions.CellFontTag);

                if (rtf = '') then
                  rtf := '&nbsp;';
                  
                HtmlBackGroundColor := ColorToHtmlHexBgColor(APlannerItem.Color);

                if  (MaxPos > 1) and (APlannerItem.ConflictPos = 0) and (TotCol = 1) then
                begin
                  ColSpan := ' colspan="' + IntToStr(MaxPos)+'"';
                end
                else
                  ColSpan := '';

                if (APlannerItem.ItemEnd > APlannerItem.ItemBegin) and not GotSpan and
                   (APlannerItem.ConflictPos = PosIndex) then
                  HtmlText := HtmlText + '<td ' + w + HtmlAlignment + ' rowspan="' +
                    IntToStr(APlannerItem.ItemEnd - APlannerItem.ItemBegin) +
                    '"' + ColSpan + HtmlBackGroundColor + ' bordercolor="#000000">' + rtf + '</td>'
                else
                begin
                  HtmlText := HtmlText + '<td ' + w + HtmlAlignment + HtmlBackGroundColor + '>' + rtf + '</td>'
                end;
              end;

              if  (MaxPos > 0) and (APlannerItem.ConflictPos = 0) and (TotCol = 1) then
                GotSpan := True;
            end
            else
            begin
              if TotCol = 0 then
              begin
                if (PosIndex = 0) then
                begin
                  if MaxPos > 1 then
                    ColSpan := ' colspan="' + IntToStr(MaxPos) + '"'
                  else
                    ColSpan := '';

                  HtmlText := HtmlText + '<td ' + ColSpan + HtmlBackGroundColor + '>&nbsp;'+'</td>'#13#10
                end;
              end
              else
              begin
                if not GotSpan then
                  HtmlText := HtmlText + '<td ' + w + HtmlBackGroundColor + '>&nbsp;'+'</td>'
              end;
            end;
          end;
        end;
      end;
      HtmlText := HtmlText + '</tr>';
    end;
    HtmlText := HtmlText + '</table></Font>';
  end;

  HtmlText := HtmlText + HTMLOptions.SuffixTag;

  if HtmlOptions.FooterFile <> '' then
  begin
    sl := TStringList.Create;
    try
      sl.LoadFromFile(HtmlOptions.FooterFile);
      HtmlText := HtmlText + sl.Text;
    finally
      sl.Free;
    end;
  end;

  sl := TStringList.Create;
  sl.Text := HTMLText;
  try
    {$IFDEF DELPHI_UNICODE}
    if Unicode then
      sl.SaveToFile(FileName, TEncoding.Unicode)
    else
      sl.SaveToFile(FileName, TEncoding.ASCII);
    {$ENDIF}
    {$IFNDEF DELPHI_UNICODE}
    sl.SaveToFile(FileName);
    {$ENDIF}
  finally
    sl.Free;
  end;
end;

procedure TCustomPlanner.SaveToHTMLRow(FileName: string; Unicode: boolean = false);
var
  RowIndex, ColIndex, StartCol: Integer;
  HtmlText, HtmlBackGroundColor, txt: string;
  tf: TextFile;
  APlannerItem: TPlannerItem;
  w, sw,hw : string;
  HtmlAlignment: string;
  rtf: string;
  ABrush: TBrush;
  sl: TStringList;
  TotPos, MaxPos, SubPos : integer;
  NumDown,RowSpan : integer;
  GotSpan : boolean;
  ColSpan : string;
  RowSp,HeightSB : string;
  HeightCell : integer;
  grp,grpc,grpm,grprow,grpsp: integer;

  function HTMLSpaces(s:string): string;
  var
    i: integer;
  begin
    Result := '';
    for i := 1 to length(s) do
      if s[i] = ' ' then Result := Result + '&nbsp;' else Result := Result + s[i];
  end;

begin
  HtmlText := '';

  if HtmlOptions.HeaderFile <> '' then
  begin
    sl := TStringList.Create;
    try
      sl.LoadFromFile(HtmlOptions.HeaderFile);
      HtmlText := HtmlText + sl.Text;
    finally
      sl.Free;
    end;
  end;

  with FGrid do
  begin
//    HtmlText := HtmlText + FontToHtmlFont(Self.Font) + HtmlOptionsToHtmlTablePrefix(HTMLOptions);
    HtmlText := HtmlText
      + FontToHtmlFont(Self.Font) + '<table border="' + IntToStr(HtmlOptions.BorderSize) + '" '
      + ' cellspacing="' + IntToStr(HtmlOptions.CellSpacing) + '" width="' + IntToStr(Self.Width) + 'px">';

    if (Header.Visible) then
      w := 'width="' + IntToStr(Round((Self.Width - Header.Height) / ColCount) - 2) + '"'
    else
      w := 'width="' + IntToStr(Round((Self.Width) / ColCount)) + '"';

    sw := 'width="' + IntToStr(Display.DisplayScale) + 'px"';
    hw := 'width="' + IntToStr(Header.Height) + 'px" ';

    HeightSB := ' height="' + IntToStr(SideBar.Width) + 'px" ';

    HtmlText := HtmlText + '<tr>';
    StartCol := 1;
    HtmlBackGroundColor := ColorToHtmlHexBgColor(Header.Color);

    if PositionGroup > 0 then
    begin
      HtmlText := HtmlText + '<td ' + hw + HtmlBackGroundColor + '>&nbsp;</td>';
    end;

    if Header.Visible then
    begin
      HtmlText := HtmlText + '<td ' + hw + HtmlBackGroundColor + '>&nbsp;</td>';
      StartCol := 0;
    end;

    for ColIndex := 0 to ColCount - 1 do
    begin
      HtmlBackGroundColor := ColorToHtmlHexBgColor(Sidebar.Background);

      txt := PlannerGetIdCol(Self, ColIndex, 0);
      txt := EmbedInHtmlOptions(txt, HTMLOptions.HeaderFontStyle, HTMLOptions.HeaderFontTag);

      HtmlText := HtmlText
        + '<td ' + sw + HeightSB + HtmlBackGroundColor + '>'
        + '<div style="overflow:hidden;width:' + IntToStr(Display.DisplayScale - 2) + 'px">'
        + txt + '</div></td>';
    end;
    HtmlText := HtmlText + '</tr>';

    grpc := 0;
    grprow := 1;

    for RowIndex := 1 to RowCount - 1 do
    begin
      MaxPos := Items.MaxItemsInPos(RowIndex - 1);
      SubPos := 1;

      while SubPos <= MaxPos do
      begin
        HtmlText := HtmlText + '<tr>';

        if (PositionGroup > 0) and (RowIndex = grprow) then
        begin
          HtmlBackGroundColor := ColorToHtmlHexBgColor(Header.Color);

          if PositionGroup = 1 then
          begin
            grpm := Header.CustomGroups.Items[grpc].Span;
          end
          else
            grpm := PositionGroup;

          grprow := grprow + grpm;

          grpsp := 0;

          for grp := 1 to grpm do
          begin
            grpsp := grpsp + Items.MaxItemsInPos(grpc + grp - 1);
          end;


          if (grpsp > 1) then
            Rowsp := ' rowspan="' + IntToStr(grpsp) + '" '
          else
            Rowsp := '';

          HtmlText := HtmlText + '<td ' + rowsp + hw + HtmlBackGroundColor + '>'+ Header.GroupCaptions[grpc] + '</td>';

          inc(grpc);
        end;

        for ColIndex := StartCol to ColCount do
        begin
          if ColIndex = 0 then
          begin
            if (ColIndex = 0) and (SubPos = 1) then
            begin
              HtmlBackGroundColor := ColorToHtmlHexBgColor(Header.Color);

              if Header.Captions.Count > ColIndex then
                txt := CLToBR(Header.Captions[RowIndex])
              else
                txt := HtmlNonBreakingSpace;


              txt := EmbedInHtmlOptions(txt, HTMLOptions.SidebarFontStyle, HTMLOptions.SidebarFontTag);

              if (MaxPos > 1) then
                Rowsp := ' rowspan="' + IntToStr(MaxPos) + '" '
              else
                Rowsp := '';

              HtmlText := HtmlText
                + '<td ' + hw + Rowsp + HtmlBackGroundColor + '>'
                + '<div style="overflow:hidden;width:' + IntToStr(Header.Height) + 'px">' + txt + '</div></td>';
            end;
          end
          else
          begin
            HtmlBackGroundColor := '';

            ABrush := TBrush.Create;
            GetCellBrush(RowIndex - 1,ColIndex - 1,ABrush);
            HtmlBackGroundColor := ColorToHtmlHexBgColor(ABrush.Color);
            ABrush.Free;

            if BackGroundColor[ColIndex - 1, RowIndex - 1] <> clNone then
              HtmlBackGroundColor := ColorToHtmlHexBgColor(BackGroundColor[ColIndex - 1, RowIndex - 1]);

            APlannerItem := Items.FindItem(ColIndex - 1, RowIndex - 1);

            if Assigned(APlannerItem) then
              TotPos := APlannerItem.Conflicts
            else
              TotPos := 0;

            if (PositionWidth = 0) then
            begin
              if (TotPos > 0) then
                HeightCell := Round(((Self.Height - SideBar.Width - Self.Caption.Height) / Self.Positions)/MaxPos) - MaxPos
              else
                HeightCell := Round((Self.Height - SideBar.Width - Self.Caption.Height) / Self.Positions);
            end
            else
            begin
              HeightCell := PositionWidth;
              //if (TotPos > 0) then
              //  HeightCell := Round(((Self.Height - SideBar.Width - Self.Caption.Height) / PositionWidth)/MaxPos) - MaxPos
              //else
              //  HeightCell := Round((Self.Height - SideBar.Width - Self.Caption.Height) / PositionWidth);
            end;

            APlannerItem := Items.FindItemPosIdx(ColIndex - 1, RowIndex - 1, SubPos - 1);

            if (Assigned(APlannerItem)) then
            begin
              HtmlAlignment := ' valign="Top"';
              case APlannerItem.Alignment of
                taRightJustify: HtmlAlignment := HtmlAlignment + ' align="Right"';
                taCenter: HtmlAlignment := HtmlAlignment + ' align="center"';
              end;

              if (APlannerItem.ItemBegin = ColIndex - 1) then
              begin
                GotSpan := false;

                rtf := APlannerItem.Text.Text;
                if IsRtf(rtf) then
                begin
                  TextToRich(rtf);
                  rtf := FRichEdit.Text;
                end
                else
                  rtf := HTMLConvert(rtf);

                if HTMLOptions.ShowCaption then
                  rtf := HTMLSpaces(APlannerItem.GetCaptionString) + '<HR>' + rtf;

                rtf := EmbedInHtmlOptions(rtf, HTMLOptions.CellFontStyle, HTMLOptions.CellFontTag);

                if (rtf = '') then
                  rtf := '&nbsp;';

                RowSpan := APlannerItem.ItemEnd - APlannerItem.ItemBegin;

                if  (MaxPos > 1) and (APlannerItem.ConflictPos = 0) and (TotPos = 1) then
                  ColSpan := ' rowspan="' + IntToStr(MaxPos)+'"'
                else
                  ColSpan := '';

                if (MaxPos > 0) and (APlannerItem.ConflictPos = 0) and (TotPos = 1) then
                  GotSpan := True;

                HtmlBackGroundColor := ColorToHtmlHexBgColor(APlannerItem.Color);

                if (APlannerItem.ItemEnd > APlannerItem.ItemBegin) and not GotSpan then
                  HtmlText := HtmlText
                    + '<td height="'+ IntToStr(HeightCell) + 'px" ' + w + HtmlAlignment + ColSpan + ' colspan="'
                    + InttoStr(RowSpan) + '"' + HtmlBackgroundColor
                    + ' bordercolor="#000000"><div style="overflow:hidden;height:' + IntToStr(HeightCell) + 'px">' + rtf + '</div></td>'
                else
                begin
                  HtmlText := HtmlText
                    + '<td height="' + IntToStr(HeightCell) + 'px" ' + ' bordercolor="#000000" ' + w + HTMLAlignment + HtmlBackgroundColor
                    + ' colspan="' + InttoStr(RowSpan) + '"><div style="overflow:hidden;height:' + IntToStr(HeightCell) + 'px">' + rtf + '</div></td>';
                end;
              end;
            end
            else
            begin
              if (TotPos = 0) and (SubPos = 1) then
              begin
                if (MaxPos > 1) then
                  ColSpan := ' rowspan="' + IntToStr(MaxPos) + '"'
                else
                  ColSpan := '';

                HtmlText := HtmlText
                  + '<td width="' + IntToStr(Display.DisplayScale - 2) + 'px" height="'
                  + IntToStr(HeightCell) + 'px" ' + ColSpan + HtmlBackGroundColor + '>'
                  + '<div style="overflow:hidden;width:' + IntToStr(Display.DisplayScale - 2)+'px'
                  + '">&nbsp;'+'</div></td>'#13#10
              end
              else
              begin
                if (Assigned(Items.FindItemPosIdx(ColIndex - 1, RowIndex - 1,SubPos - 2)) or (SubPos = 1)) then
                begin
                  NumDown := 1;

                  while not Assigned(Items.FindItemPosIdx(ColIndex - 1, RowIndex - 1, SubPos - 1 + NumDown)) and (NumDown <= MaxPos - SubPos) do
                    Inc(NumDown);

                  if (NumDown > 0) then
                  begin
                    if (NumDown > 1) then
                      ColSpan := ' rowspan="' + IntToStr(NumDown) + '"'
                    else
                      Colspan := '';

                      HtmlText := HtmlText + '<td height="' + IntToStr(HeightCell) + 'px"'  + Colspan +  HtmlBackGroundColor + '>&nbsp;</td>';
                  end;
                end;
              end;
            end;
          end;
        end;
        Inc(SubPos);
        HtmlText := HtmlText + '</tr>';
      end;
    end;
    HtmlText := HtmlText + '</table></Font>';
  end;
  //End Modified

  if HtmlOptions.FooterFile <> '' then
  begin
    sl := TStringList.Create;
    try
      sl.LoadFromFile(HtmlOptions.FooterFile);
      HtmlText := HtmlText + sl.Text;
    finally
      sl.Free;
    end;
  end;

  sl := TStringList.Create;
  sl.Text := HTMLText;
  try
    {$IFDEF DELPHI_UNICODE}
    if Unicode then
      sl.SaveToFile(FileName, TEncoding.Unicode)
    else
      sl.SaveToFile(FileName, TEncoding.ASCII);
    {$ENDIF}
    {$IFNDEF DELPHI_UNICODE}
    sl.SaveToFile(FileName);
    {$ENDIF}
  finally
    sl.Free;
  end;
end;

procedure TCustomPlanner.SaveToHTML(FileName: string; Unicode: boolean = false);
begin
  if Sidebar.Orientation = soVertical then
    SaveToHTMLCol(FileName, Unicode)
  else
    SaveToHTMLRow(FileName, Unicode);
end;

{$IFDEF DELPHI4_LVL}
procedure TCustomPlanner.Resize;
{$ENDIF}
{$IFNDEF DELPHI4_LVL}
procedure TCustomPlanner.WMSize(var WMSize: TWMSize);
{$ENDIF}
begin
  inherited;
  if FGrid.FMemo.Visible then
    FGrid.FMemo.Visible := False;
  if FRichEdit.Visible then
    FRichEdit.Visible := False;
  if Assigned(FHeader) then
    if Assigned(FHeader.FInplaceEdit) then
    begin
      if FHeader.FInplaceEdit.Visible then
        FHeader.FInplaceEdit.Visible := False;
    end;
  UpdateSizes;
end;

procedure TCustomPlanner.WMMoving(var Message: TMessage);
begin
  inherited;
end;


procedure TCustomPlanner.BalloonInit;

  procedure WindowBlend(hwnd:thandle;colorkey:tcolor;alpha:byte;r:trect);
  var
   dw: dword;
   blnd: _BLENDFUNCTION;
   dskdc: thandle;
   size,src: tpoint;
   hdc: thandle;
  begin
   hdc := GetDC(hwnd);
   dw := GetWindowLong(hwnd, GWL_EXSTYLE);
   SetWindowLong(hwnd, GWL_EXSTYLE,dw or WS_EX_LAYERED);
   {$IFDEF TMSDOTNET}
   SetLayeredWindowAttributes(hwnd,colorkey,alpha,2);
   {$ENDIF}
   {$IFNDEF TMSDOTNET}
   DynaLink_SetLayeredWindowAttributes(hwnd,DWORD(colorkey),alpha,2);
   {$ENDIF}
   blnd.BlendOp := AC_SRC_OVER;
   blnd.BlendFlags := 0;
   blnd.SourceConstantAlpha := 0;
   blnd.AlphaFormat := 0;
   dskdc := GetDC(0);
   size := Point(r.right-r.left,r.bottom-r.top);
   src := Point(r.left,r.top);
   {$IFDEF TMSDOTNET}
//   UpdateLayeredWindow(hwnd,dskdc,nil,size,hdc,src,colorkey, blnd,ULW_ALPHA);
   {$ENDIF}
   {$IFNDEF TMSDOTNET}
   DynaLink_UpdateLayeredWindow(hwnd,dskdc,nil,@size,hdc,@src,dword(colorkey), blnd,ULW_ALPHA);
   {$ENDIF}
   ReleaseDC(0,dskdc);
   ReleaseDC(hwnd,hdc);
  end;

begin
  FGrid.CreateToolTip;
  FGrid.AddToolTip(3,'Planner','ToolTipText');
  if FBalloon.InitialDelay <> -1 then
    SendMessage(FGrid.fhtooltip,TTM_SETDELAYTIME, TTDT_INITIAL, FBalloon.InitialDelay);

  if FBalloon.ReshowDelay <> -1 then
    SendMessage(FGrid.fhtooltip,TTM_SETDELAYTIME, TTDT_RESHOW, FBalloon.ReshowDelay);

  if FBalloon.AutoHideDelay <> -1 then
    SendMessage(FGrid.fhtooltip,TTM_SETDELAYTIME, TTDT_AUTOPOP, FBalloon.AutoHideDelay);

  if (FBalloon.Transparency > 0) then
    WindowBlend(FGrid.fhToolTip,0,255 - FBalloon.Transparency,Rect(0,0,100,100));

  FHeader.CreateToolTip;
  FHeader.AddToolTip(3,'Header','ToolTipText');
  if FBalloon.InitialDelay <> -1 then
    SendMessage(FHeader.fhtooltip,TTM_SETDELAYTIME, TTDT_INITIAL, FBalloon.InitialDelay);

  if FBalloon.ReshowDelay <> -1 then
    SendMessage(FHeader.fhtooltip,TTM_SETDELAYTIME, TTDT_RESHOW, FBalloon.ReshowDelay);

  if FBalloon.AutoHideDelay <> -1 then
    SendMessage(FHeader.fhtooltip,TTM_SETDELAYTIME, TTDT_AUTOPOP, FBalloon.AutoHideDelay);

  if (FBalloon.Transparency > 0) then
    WindowBlend(FHeader.fhToolTip,0,255 - FBalloon.Transparency,Rect(0,0,100,100));
end;

procedure TCustomPlanner.BalloonDone;
begin
  if FBalloon.Enable then
  begin
    FGrid.DestroyToolTip;
    FHeader.DestroyToolTip;
  end;
end;

procedure TCustomPlanner.BalloonChange(Sender: TObject);
begin
  if not (csLoading in ComponentState) then
  begin
    if FBalloon.Enable then
      BalloonInit
    else
      BalloonDone;
  end;
end;

procedure TCustomPlanner.SetSelectRange(const Value: Boolean);
begin
  if Value then
    FGrid.Options := [goRangeSelect]
  else
    FGrid.Options := [];

  FSelectRange := Value;   
end;

procedure TCustomPlanner.SetItemSelection(AValue: TPlannerItemSelection);
begin
  FItemSelection.Assign(AValue);
end;

procedure TCustomPlanner.Loaded;
begin
  inherited;
{$IFDEF TMSCODESITE}
  CodeSite.SendMsg('TPlanner Loaded begin');
{$ENDIF}
  FCaption.UpdatePanel;
  FDisplay.InitPrecis;
  FDisplay.UpdatePlanner;

  Items.SetConflicts;
  FGrid.Color := Self.Color;
  FHeader.Flat := FPlannerHeader.Flat;

  if FPlannerHeader.AutoSize then
    AutoSizeHeader;

  FScrollBarStyle.UpdateProps;
  FGrid.UpdateVScrollBar;

{$IFDEF TMSCODESITE}
  CodeSite.SendMsg('TPlanner Loaded end');
{$ENDIF}
  UpdateTimer;
  FGrid.UpdateNVI;

  SideBar.ActiveColor := SideBar.ActiveColor;
  FGrid.FOldSelection := FGrid.Selection;

  if Footer.ShowCompletion and Footer.Visible then
    UpdateCompletion;

  UpdateSizes;
  FGrid.UpdatePositions;

  if FBalloon.Enable then
    BalloonInit;

  case Sidebar.Orientation of
  soHorizontal: FHeader.Rotate := Header.RotateOnLeft;
  soVertical: FHeader.Rotate := Header.RotateOnTop;
  end;


  if AutoThemeAdapt and not (csDesigning in ComponentState) then
    ThemeAdapt;

  GridLeftCol := FLoadLeftCol;
end;

procedure TCustomPlanner.HeaderHeightChange(ASize: Integer);
begin
  if Assigned(FOnHeaderHeightChange) then
    FOnHeaderHeightChange(Self, ASize);
end;

procedure TCustomPlanner.NextClick(Sender: TObject);
begin
  if Assigned(FOnPlannerNext) then
    FOnPlannerNext(Self);
end;

procedure TCustomPlanner.PrevClick(Sender: TObject);
begin
  if Assigned(FOnPlannerPrev) then
    FOnPlannerPrev(Self);
end;

procedure TCustomPlanner.HeaderClick(Sender: TObject; SectionIndex: Integer);
begin
  if Assigned(FOnHeaderClick) then
    FOnHeaderClick(Self, SectionIndex);
end;

procedure TCustomPlanner.HeaderRightClick(Sender: TObject; SectionIndex: Integer);
begin
  if Assigned(FOnHeaderRightClick) then
    FOnHeaderRightClick(Self, SectionIndex);
end;

procedure TCustomPlanner.HeaderDblClick(Sender: TObject; SectionIndex: Integer);
begin
  if Assigned(FOnHeaderDblClick) then
    FOnHeaderDblClick(Self, SectionIndex)
end;

procedure TCustomPlanner.HeaderDragDrop(Sender: TObject; FromSection, ToSection:
  Integer);
var
  fs,ts: Integer;
begin
  if ToSection > Positions then
    Exit;
  if FromSection > Positions then
    Exit;

  MovePosition(FromSection - 1, ToSection - 1);

  fs := FromSection;
  ts := ToSection;

  if (SideBar.Position in [spLeft,spLeftRight,spTop]) then
  begin
    dec(fs);
    dec(ts);
  end;

  MoveResource(fs,ts);

  if Assigned(FOnHeaderDragDrop) then
    FOnHeaderDragDrop(Self,FromSection,ToSection);
end;

procedure TCustomPlanner.MoveResource(FromPos, ToPos: Integer);
begin

end;

procedure TCustomPlanner.PlanFontChanged(Sender: TObject);
begin
  Invalidate;
end;


procedure TCustomPlanner.CreateWnd;
begin
  inherited;
  FCaption.UpdatePanel;
  UpdateSizes;
end;


procedure TCustomPlanner.CreateParams(var Params: TCreateParams);
begin
  inherited CreateParams(Params);
  with Params do
  begin
    Style := Style and not WS_BORDER;
  end;
end;

procedure TCustomPlanner.DestroyWnd;
begin
  inherited;
end;

procedure TCustomPlanner.Paint;
var
  r: TRect;
begin
  inherited;

  r := ClientRect;

  if FHeader.Visible and (FSideBar.Position <> spTop) then
  begin
    r.Bottom := FHeader.Height + FCaption.Height;
    Canvas.Brush.Color := FHeader.Color;
    Canvas.Pen.Color := FHeader.Color;
    Canvas.FillRect(r); // fill the Header background
    r := ClientRect;
    r.Top := FHeader.Height + FCaption.Height;
  end;
end;

procedure TCustomPlanner.ThemeAdapt;

  function IsThemedApp: Boolean;
  var
    i: Integer;
  begin
    // app is linked with COMCTL32 v6 or higher -> xp themes enabled
    i := GetFileVersion('COMCTL32.DLL');
    i := (i shr 16) and $FF;
    Result := (i > 5);
  end;  

var
  eTheme: XPColorScheme;

  function CurrentXPTheme: XPColorScheme;
  var
    {$IFNDEF TMSDOTNET}
    FileName, ColorScheme, SizeName: WideString;
    {$ENDIF}
    {$IFDEF TMSDOTNET}
    FileName, ColorScheme, SizeName: StringBuilder;
    {$ENDIF}
  begin
    Result := xpNone;

    if IsWinXP then
    begin
      if IsThemedApp then
      begin
        {$IFDEF TMSDOTNET}
        FileName := StringBuilder.Create(255);
        SizeName := StringBuilder.Create(255);
        ColorScheme := StringBuilder.Create(255);
        GetCurrentThemeName(FileName, 255, ColorScheme, 255, SizeName, 255);
        if(ColorScheme.ToString = 'NormalColor') then
          Result := xpBlue
        else if (ColorScheme.ToString = 'HomeStead') then
          Result := xpGreen
        else if (ColorScheme.ToString = 'Metallic') then
          Result := xpGray
        {$ENDIF}
        {$IFNDEF TMSDOTNET}
        SetLength(FileName, 255);
        SetLength(ColorScheme, 255);
        SetLength(SizeName, 255);
        GetCurrentThemeName(PWideChar(FileName), 255,
          PWideChar(ColorScheme), 255, PWideChar(SizeName), 255);
        if(PWideChar(ColorScheme)='NormalColor') then
          Result := xpBlue
        else if (PWideChar(ColorScheme)='HomeStead') then
          Result := xpGreen
        else if (PWideChar(ColorScheme)='Metallic') then
          Result := xpGray
        {$ENDIF}
      end
      else
        Result := xpNoTheme;
    end;
  end;

begin
  eTheme := CurrentXPTheme();
  case eTheme of
  xpBlue: SetStyle(2);
  xpGreen: SetStyle(3);
  xpGray: SetStyle(4);
  xpNoTheme: SetStyle(0);
  else
    SetStyle(1);
  end;
end;

procedure TCustomPlanner.Invalidate;
var
  i: Integer;
begin
  inherited;

  for i := 1 to ControlCount do
    Controls[i - 1].Invalidate;
end;

procedure TCustomPlanner.SetActiveDisplay(const Value: Boolean);
begin
  if FActiveDisplay <> Value then
  begin
    if Sidebar.Orientation = soVertical then
    begin
      if Value then
        FGrid.TopRow := Display.ActiveStart
      else
        FGrid.TopRow := 0;
    end
    else
    begin
      if Value then
        FGrid.LeftCol := Display.ActiveStart
      else
        FGrid.LeftCol := 0;
    end;

    FActiveDisplay := Value;
  end;
end;

procedure TCustomPlanner.SetFont(Value: TFont);
begin
  Font.Assign(Value);
end;

procedure TCustomPlanner.SetTrackColor(const Value: TColor);
begin
  if FTrackColor <> Value then
  begin
    FTrackColor := Value;
    Invalidate;
  end;
end;

procedure TCustomPlanner.SetTrackOnly(const Value: Boolean);
begin
  if FTrackOnly <> Value then
  begin
    FTrackOnly := Value;
    Invalidate;
  end;
end;


procedure TCustomPlanner.SetTrackProportional(const Value: Boolean);
begin
  if FTrackProportional <> Value then
  begin
    FTrackProportional := Value;
    Invalidate;
  end;
end;

procedure TCustomPlanner.SetImages(const Value: TImageList);
begin
  if FPlannerImages <> Value then
  begin
    FPlannerImages := Value;
    Invalidate;
  end;
end;

procedure TCustomPlanner.SetDrawPrecise(const Value: Boolean);
begin
  if FDrawPrecise <> Value then
  begin
    FDrawPrecise := Value;
    Invalidate;
  end;
end;

procedure TCustomPlanner.SetLayer(const Value: LongInt);
begin
  if FLayer <> Value then
  begin
    FLayer := Value;
    Items.SetConflicts;
    Invalidate;
  end;
end;

procedure TCustomPlanner.SetHourType(const Value: THourType);
begin
  if FHourType <> Value then
  begin
    FHourType := Value;
    FGrid.Invalidate;
  end;
end;

procedure TCustomPlanner.SetGridTopRow(const Value: Integer);
begin
  if (Value <> FGrid.TopRow) then
  begin
    if (Value <= FGrid.RowCount - FGrid.VisibleRowCount) then
    begin
      if Value < FGrid.FixedRows then
        FGrid.TopRow := FGrid.FixedRows
      else
        FGrid.TopRow := Value;
    end
    else
     FGrid.TopRow := FGrid.RowCount - FGrid.VisibleRowCount;
  end;
end;

function TCustomPlanner.GetGridTopRow: Integer;
begin
  Result := FGrid.TopRow;
end;

procedure TCustomPlanner.SetGridLeftCol(const Value: Integer);
begin
  if (csLoading in ComponentState) then
  begin
    FLoadLeftCol := Value;
  end;

  if (PositionWidth = 0) and (Sidebar.Position <> spTop) then
    Exit;

  if (FGrid.ColCount - FGrid.VisibleColCount < Value) then
    FGrid.LeftCol := FGrid.ColCount - FGrid.VisibleColCount
  else
    FGrid.LeftCol := Value;
end;

function TCustomPlanner.GetGridLeftCol: Integer;
begin
  Result := FGrid.LeftCol;
end;

procedure TCustomPlanner.SetPositions(const Value: Integer);
var
  ColorIndex: Integer;
  {$IFNDEF TMSDOTNET}
  PlannerColorArrayPointer: PPlannerColorArray;
  {$ENDIF}
  {$IFDEF TMSDOTNET}
  PlannerColorArrayPointer: TPlannerColorArrayObject;
  {$ENDIF}
begin
  if Value <= 0 then
    Exit;

  if Value = FPositions then
    Exit;

  FPositions := Value;

  // If SelectionAlways = false, prevent that changes to grid cause invalid selection
  // v2.0.0.6
  SelectCells(1,1,0);

  // Force Sidebar & position update
  SideBar.Position := SideBar.Position;

  // Synchronize Header with nr of positions

  FPlannerHeader.Captions.BeginUpdate;
  while FPlannerHeader.Captions.Count <= FPositions do
    FPlannerHeader.Captions.Add('');
  FPlannerHeader.Captions.EndUpdate;

  FPlannerFooter.Captions.BeginUpdate;
  while FPlannerFooter.Captions.Count <= FPositions do
    FPlannerFooter.Captions.Add('');
  FPlannerFooter.Captions.EndUpdate;

  if PositionGroup > 0 then
  begin
    FPlannerHeader.GroupCaptions.BeginUpdate;
    while FPlannerHeader.GroupCaptions.Count <= (Positions div PositionGroup) do
      FPlannerHeader.GroupCaptions.Add('');
    FPlannerHeader.GroupCaptions.EndUpdate;
  end;

  FPlannerHeader.ItemsChanged(Self);

  // Synchronize the background Color list with the nr. of positions 
  while FGrid.ColorList.Count < Value do
  begin
    {$IFNDEF TMSDOTNET}
    PlannerColorArrayPointer := FGrid.ColorList.Add;
    for ColorIndex := 0 to NumColors do
    begin
      PlannerColorArrayPointer^[ColorIndex].Color := clNone;
      PlannerColorArrayPointer^[ColorIndex].Selected := 0;
    end;
    {$ENDIF}
    {$IFDEF TMSDOTNET}
    PlannerColorArrayPointer := FGrid.ColorList.Add;
    for ColorIndex := 0 to NumColors do
    begin
      PlannerColorArrayPointer.Color[ColorIndex] := clNone;
      PlannerColorArrayPointer.Selected[ColorIndex] := 0;
    end;
    {$ENDIF}
  end;

  while FGrid.ColorList.Count > Value do
    FGrid.ColorList.Delete(FGrid.ColorList.Count - 1);

  if Footer.Visible and Footer.ShowCompletion then
    UpdateCompletion;
end;

procedure TCustomPlanner.SetPositionAutoSize(const Value: Boolean);
begin
  FPositionAutoSize := Value;
  if FPositionAutoSize then
    DoPositionAutoSize;
end;

function TCustomPlanner.IsDBAware: boolean;
begin
  Result := false;
end;

procedure TCustomPlanner.DoPositionAutoSize;
var
  i,x: Integer;
begin
  if not PositionAutoSize then
    Exit;

  if PositionWidth <= 0 then
    Exit;

  for i := 1 to Positions do
  begin
    if PositionWidths[i - 1] <> PositionZoomWidth then
    begin
      x := Items.MaxItemsInPos(i - 1);
      PositionWidths[i - 1] := Max(x,1) * PositionWidth;
    end;
  end;
end;

procedure TCustomPlanner.SetPositionWidth(const Value: Integer);
begin
  if (Value <> FPositionWidth) then
  begin
    FPositionWidth := Value;
    FGrid.UpdatePositions;
  end;
end;

procedure TCustomPlanner.SetPlannerItems(const Value: TPlannerItems);
begin
  FPlannerItems := Value;
end;

procedure TCustomPlanner.SetCaption(const Value: TPlannerCaption);
begin
  FCaption := Value;
  FPanel.Repaint;
end;

procedure TCustomPlanner.SetDayNames(const Value: TStringList);
begin
  if Assigned(Value) then
    FDayNames.Assign(Value);
  Self.Repaint;
end;

procedure TCustomPlanner.SetDisplay(const Value: TPlannerDisplay);
begin
  FDisplay := Value;
end;

procedure TCustomPlanner.SetHeader(const Value: TPlannerHeader);
begin
  FPlannerHeader := Value;
end;

procedure TCustomPlanner.SetFooter(const Value: TPlannerFooter);
begin
  FPlannerFooter := Value;
end;

procedure TCustomPlanner.SetMode(const Value: TPlannerMode);
begin
  FMode := Value;
end;

procedure TCustomPlanner.SetSideBar(const Value: TPlannerSideBar);
begin
  FSidebar := Value;
end;

procedure TCustomPlanner.WMEraseBkGnd(var Message: TWMEraseBkgnd);
begin
  Message.Result := 0;
end;

procedure TCustomPlanner.UpdateSizes;
begin
  if Sidebar.Orientation = soVertical then
  begin
    if FPlannerHeader.Visible then
    begin
      FHeader.Visible := True;
      FHeader.Top := FPanel.Height;
      FHeader.Height := FPlannerHeader.Height;
    end
    else
    begin
      FHeader.Height := 0;
      FHeader.Visible := False;
    end;

    if FPlannerFooter.Visible then
    begin
      FFooter.Visible := True;
      FFooter.Top := Height - FPlannerFooter.Height;
      FFooter.Left := 0;
      FFooter.Height := FPlannerFooter.Height;
    end
    else
    begin
      FFooter.Left := 0;
      FFooter.Height := 0;
      FFooter.Visible := False;
    end;

    if FNavigatorButtons.Visible then
      FHeader.Width := Self.Width - 2 * BtnWidth
    else
      FHeader.Width := Self.Width;

    FFooter.Width := Self.Width;

    FGrid.Top := FPanel.Height + FHeader.Height;
    FGrid.Left := 0;

    FGrid.Width := Self.Width;
    FGrid.Height := Self.Height - FPanel.Height - FHeader.Height - FFooter.Height;
    FPanel.Width := Self.Width;

    if FNavigatorButtons.Visible and FPlannerHeader.Visible then
    begin
      FHeader.Left := BtnWidth;
      FNext.Top := FPanel.Height;
      FNext.Left := Width - BtnWidth;

      FNext.Width := BtnWidth;
      FNext.Height := FHeader.Height;
      FPrev.Height := FHeader.Height;
      FPrev.Width := BtnWidth;
    end
    else
      FHeader.Left := 0;
  end
  else
  begin
    if FPlannerHeader.Visible then
    begin
      FHeader.Visible := True;
      FHeader.Top := FPanel.Height;
      FHeader.Left := 0;
      FHeader.Width := FPlannerHeader.Height;
      FHeader.Height := Self.Height - FPanel.Height;
    end
    else
    begin
      FHeader.Width := 0;
      FHeader.Visible := False;
    end;

    if FPlannerFooter.Visible then
    begin
      FFooter.Visible := True;
      FFooter.Top := FPanel.Height;
      FFooter.Left := Width - FPlannerFooter.Height;
      FFooter.Width := FPlannerFooter.Height;
      FFooter.Height := Self.Height - FPanel.Height;
    end
    else
    begin
      FFooter.Width := 0;
      FFooter.Visible := False;
    end;

    FGrid.Top := FPanel.Height;
    FGrid.Left := FHeader.Width;
    FGrid.Width := Self.Width - FHeader.Width - FFooter.Width;
    FGrid.Height := Self.Height - FPanel.Height;
    FPanel.Width := Self.Width;
  end;
end;

procedure TCustomPlanner.UpdateTimer;
begin
  if csLoading in ComponentState then
    Exit;
  if (FDisplay.ShowCurrent or FDisplay.ShowCurrentItem or FEnableAlarms or FEnableFlashing or FSideBar.TimeIndicator)
    and (FTimerID = 0) then
    FTimerID := SetTimer(Self.Handle, 1, 500, nil);

  if not (FDisplay.ShowCurrent or FDisplay.ShowCurrentItem or FEnableAlarms or FEnableFlashing or FSideBar.TimeIndicator)
    and (FTimerID <> 0) then
  begin
    KillTimer(Self.Handle, FTimerID);
    FTimerID := 0;
  end;
end;

function TCustomPlanner.IsSelected(AIndex, APosition: Integer): Boolean;
begin
  Result := (AIndex >= SelItemBegin) and
    (AIndex < SelItemEnd) and
    (APosition = SelPosition);
end;

function TCustomPlanner.GetSelItemEnd: Integer;
begin
  if (Sidebar.Orientation = soVertical) then
    Result := FGrid.Selection.Bottom + 1
  else
    Result := FGrid.Selection.Right + 1;
end;

function TCustomPlanner.GetSelItemBegin: Integer;
begin
  if Sidebar.Orientation = soVertical then
    Result := FGrid.Selection.Top
  else
    Result := FGrid.Selection.Left;
end;

function TCustomPlanner.GetSelPosition: Integer;
begin
  case FSidebar.Position of
    spLeft, spLeftRight: Result := FGrid.Selection.Left - 1;
    spRight: Result := FGrid.Selection.Left;
    spTop: Result := FGrid.Selection.Top - 1;
  else
    Result := FGrid.Selection.Left - 1;
  end;
end;

function TCustomPlanner.XYToSelection(X,Y: Integer): TPoint;
begin
  case FSidebar.Position of
    spLeft, spLeftRight: Result.Y := X - 1;
    spRight: Result.Y := X;
    spTop: Result.Y := Y - 1;
  else
    Result.Y := X - 1;
  end;
  
  if Sidebar.Orientation = soVertical then
    Result.X := Y + 1
  else
    Result.X := X + 1;
end;

procedure TCustomPlanner.SetSelItemEnd(const Value: Integer);
var
  GridRect: TGridRect;
begin
  GridRect := FGrid.Selection;

  if Sidebar.Orientation = soVertical then
    GridRect.Bottom := Value
  else
    GridRect.Right := Value;

  FGrid.Selection := GridRect;
end;

procedure TCustomPlanner.SetSelItemBegin(const Value: Integer);
var
  GridRect: TGridRect;
begin
  GridRect := FGrid.Selection;

  if Sidebar.Orientation = soVertical then
    GridRect.Top := Value
  else
    GridRect.Left := Value;

  FGrid.Selection := GridRect;
end;

procedure TCustomPlanner.SetSelPosition(Value: Integer);
var
  GridRect: TGridRect;
begin
  GridRect := FGrid.Selection;

  Inc(Value);

  if Sidebar.Orientation = soVertical then
  begin
    GridRect.Left := Value;
    GridRect.Right := Value;
  end
  else
  begin
    GridRect.Top := Value;
    GridRect.Bottom := Value;
  end;

  if Mode.PlannerType = plMultiMonth then
  begin
    if GridRect.Bottom > 31 then
      GridRect.Bottom := 31;
    if GridRect.Right > 31 then
      GridRect.Right := 31;
  end;

  FGrid.Selection := GridRect;
end;

procedure TCustomPlanner.SetGradientSteps(const Value: Integer);
begin
  if (Value <> FGradientSteps) then
  begin
    FGradientSteps := Value;
    Invalidate;
  end;
end;

procedure TCustomPlanner.SetGradientHorizontal(const Value: Boolean);
begin
  if (Value <> FGradientHorizontal) then
  begin
    FGradientHorizontal := Value;
    Invalidate;
  end;
end;

procedure TCustomPlanner.SelChange(Sender: TObject);
begin
  if Assigned(FOnItemSelChange) then
    FOnItemSelChange(Sender, FRichEdit.FPlannerItem);
end;

function TCustomPlanner.XYToCell(X, Y: Integer): TPoint;
var
  GridCoord: TGridCoord;
begin
  GridCoord := FGrid.MouseCoord(X, Y);
  if {(FSidebar.Visible) and} (FSidebar.Position in [spLeft, spLeftRight]) then
    GridCoord.X := GridCoord.X - 1;
  if {(FSidebar.Visible) and} (FSidebar.Position = spTop) then
    GridCoord.Y := GridCoord.Y - 1;
  Result := Point(GridCoord.X, GridCoord.Y);
end;

function TCustomPlanner.XYToItem(X, Y: Integer): TPlannerItem;
var
  CellPoint: TPoint;
  GridRect: TRect;
  iBegin, iPos: Integer;

begin
  CellPoint := XYToCell(X, Y);

//  Result := CellToItem(CellPoint.X, CellPoint.Y);

  if Sidebar.Orientation = soVertical then
  begin
    GridRect := FGrid.CellRectEx(CellPoint.X + SideBar.FColOffset, CellPoint.Y);
    iBegin := CellPoint.Y;
    iPos := CellPoint.X;
    Result := Items.FindItemPos(iBegin, iPos , X - GridRect.Left);
  end
  else
  begin
    GridRect := FGrid.CellRectEx(CellPoint.X, CellPoint.Y + SideBar.FRowOffset);
    iBegin := CellPoint.X;
    iPos := CellPoint.Y;
    Result := Items.FindItemPos(iBegin, iPos , Y - GridRect.Top);
  end;
end;

function TCustomPlanner.CellToItem(X, Y: Integer): TPlannerItem;
begin
  if Sidebar.Orientation = soVertical then
    Result := Items.FindItemPos(Y, X, 1)
  else
    Result := Items.FindItemPos(X, Y, 1);
end;

function TCustomPlanner.CellToItemIdx(X, Y, Index: Integer): TPlannerItem;
begin
  if Sidebar.Orientation = soVertical then
    Result := Items.FindItemPosIdx(Y, X, Index)
  else
    Result := Items.FindItemPosIdx(X, Y, Index);
end;

function TCustomPlanner.CellToItemNum(X, Y: Integer): Integer;
var
  APlannerItem: TPlannerItem;
begin
  if Sidebar.Orientation = soVertical then
    APlannerItem := Items.FindItem(Y, X)
  else
    APlannerItem := Items.FindItem(X, Y);

  if Assigned(APlannerItem) then
    Result := APlannerItem.FConflicts
  else
    Result := 0;
end;

procedure TCustomPlanner.SelectionToAbsTime(var dtStart, dtEnd: TDateTime);
var
  tdt: TDateTime;
begin
  CellToAbsTime(SelItemBegin, dtStart, dtEnd);
  
  if (Mode.PlannerType in [plDay, plHalfDayPeriod]) then
    CellToAbsTime(SelItemEnd, dtEnd, tdt)
  else
    CellToAbsTime(SelItemEnd - 1, dtEnd, tdt);

  if (Mode.PlannerType = plDay) and (SelItemBegin <> SelItemEnd) and (dtEnd = dtStart) then
  begin
    dtEnd := dtEnd + 1;
  end;
end;

procedure TCustomPlanner.CellToAbsTime(X: Integer; var dtStart, dtEnd: TDateTime);
var
  res: Integer;
  ANow: TDateTime;
  dday, dx: Integer;
  flg: boolean;
begin
  case Mode.PlannerType of
    plDay:
      begin
        ANow := Now;
        if Assigned(FOnGetCurrentTime) then
          FOnGetCurrentTime(Self, ANow);

        res := ((X + Display.DisplayStart) * Display.DisplayUnit) + Display.DisplayOffset;

        flg := false;
        while res >= 1440 do
        begin
          res := res - 1440;
          flg := true;
        end;

        if (res div 60 < 24) then
          dtStart := PosToDay(SelPosition) + EncodeTime(res div 60, res mod 60, 0, 0);

        res := res + Display.DisplayUnit;

        while res >= 1440 do res := res - 1440;

        if (res div 60 < 24) then
          dtEnd := PosToDay(SelPosition) + EncodeTime(res div 60, res mod 60, 0, 0);

        if flg then
        begin
          dtStart := dtStart + 1;
          dtEnd := dtEnd + 1;
        end;

      end;
    plWeek:
      begin
        dtStart := Mode.StartOfMonth + X;
        dtEnd := dtStart + 1;
      end;
    plMonth:
      begin
        dtStart := Mode.StartOfMonth + X;
        dtEnd := dtStart + 1;
      end;
    plDayPeriod:
      begin
        dtStart := Mode.PeriodStartDate + X;
        dtEnd := dtStart + 1;
      end;
    plHalfDayPeriod:
      begin
        dtStart := Mode.PeriodStartDate + X / 2;
        dtEnd := dtStart + 0.5;
      end;
    plMultiMonth:
      begin
        dtStart := EncodeDate(Mode.Year, Mode.Month, 1);
        
        if X < PlanUtil.DaysInMonth(Mode.Month, Mode.Year) then
          dtStart := EncodeDate(Mode.Year, Mode.Month, X + 1);
        dtEnd := dtStart;
      end;
    plCustom, plCustomList:
      begin
        dtStart := IndexToTime(X);
        dtEnd := IndexToTime(X + 1);
      end;
    plTimeLine:
      begin
        // # divisions / day
        dday := (MinInDay div Display.DisplayUnit) - Mode.TimeLineNVUBegin - Mode.TimeLineNVUEnd;

        dx := x;
        while dx < 0 do
          dx := dx + dday;

        if dday = 0 then
          dday := 1;

        dtStart := int(Mode.TimeLineStart) + x div dday;
        res := ((dx mod dday) + Mode.TimeLineNVUBegin) * Display.DisplayUnit;


        if res >= MinInDay then
        begin
          dtStart := dtStart + (res div MinInDay);
          res := res mod MinInDay;
        end;

        dtStart :=  dtStart + EncodeTime(res div 60, res mod 60, 0, 0);
        dtEnd := int(Mode.TimeLineStart) + x div dday;

        res := ((dx mod dday) + Mode.TimeLineNVUBegin + 1) * Display.DisplayUnit;

        if res >= MinInDay then
        begin
          dtEnd := dtEnd + (res div MinInDay);
          res := res mod MinInDay;
        end;

        dtEnd :=  dtEnd + EncodeTime(res div 60, res mod 60, 0, 0);

        if (x < 0) and (dx mod dday <> 0) then
        begin
          dtStart := dtStart - 1;
          dtEnd := dtEnd - 1;
        end;

        {
        res := ((X + Display.DisplayStart) * Display.DisplayUnit) + Display.DisplayOffset;

        dtStart := int(Mode.TimeLineStart);

        if res >= MinInDay then
        begin
          dtStart := dtStart + (res div MinInDay);
        end;

        res := res mod MinInDay;

        dtStart :=  dtStart + EncodeTime(res div 60, res mod 60, 0, 0);

        res := Display.DisplayUnit;

        dtEnd := dtStart + EncodeTime(res div 60, res mod 60, 0, 0);
        }
      end;
  end;
end;


function TCustomPlanner.GetEditColor(AItem: TPlannerItem; Sel: Boolean): TColor;
begin
  if Sel then
    Result := AItem.SelectColor
  else
    Result := Color;

  {$IFDEF TMSSKINS}
  if AItem.Shape = psSkin then
  begin
    if Sel then
    begin
      if Assigned(Skin.SkinSelectCenter) then
        if not Skin.SkinSelectCenter.Empty then
          Result := Skin.SkinSelectCenter.Canvas.Pixels[Skin.SkinSelectCenter.Width div 2, Skin.SkinSelectCenter.Height div 2];
    end
    else
    begin
      if Assigned(Skin.SkinCenter) then
        if not Skin.SkinCenter.Empty then
          Result := Skin.SkinCenter.Canvas.Pixels[Skin.SkinCenter.Width div 2, Skin.SkinCenter.Height div 2];
    end;
  end;
  {$ENDIF}
end;

procedure TCustomPlanner.SetGroupGapOnly(AValue: Boolean);
begin
  FGroupGapOnly := AValue;
  Invalidate;
end;

function TCustomPlanner.GapAtColumn(ACol: Integer): Boolean;
var
  RCol: Integer;
begin
  if SideBar.Position = spLeft then
    RCol := ACol - 1
  else
    RCol := ACol;

  if (PositionProps.Count > RCol) and (RCol >= 0) then
    Result  := PositionProps[RCol].ShowGap
  else
    Result := True;
    
  if GroupGapOnly and (PositionGroup > 0) then
    Result := (RCol mod PositionGroup) = 0;
end;

procedure TCustomPlanner.ItemDesignChange(Sender: TObject);
begin
  if Items.Count > 0 then
    Items[0].AssignEx(FDefaultItem);
end;

procedure TCustomPlanner.SetShowDesignHelper(const Value: Boolean);
begin
  FShowDesignHelper := Value;
  Invalidate;
end;

procedure TCustomPlanner.UpdateCompletion;
var
  i,j,c: Integer;
begin
  if not Footer.ShowCompletion then
    Exit;

  FFooter.BeginUpdate;

  if Assigned(OnPlannerUpdateCompletion) then
    OnPlannerUpdateCompletion(Self);

  while (Footer.Captions.Count <= Positions) do
    Footer.Captions.Add('');

  for i := 1 to Positions do
  begin
    if Sidebar.Position = spRight then
      j := i - 1
    else
      j := i;

    if (not Footer.CustomCompletionValue) then
    begin
      c := GetPositionCompletion(i -1,Footer.CompletionType = ctActiveTime);
      Footer.Captions[j] := IntToStr(c);
    end;
  end;

  FFooter.EndUpdate;
end;

function TCustomPlanner.GetPositionCompletion(Position: Integer; Active: Boolean): Integer;
var
  i,r: Integer;
  plIt: TPlannerItem;
  StartIdx, EndIdx: Integer;
  ActiveStart, ActiveEnd: Integer;
  FoundNonHeader: boolean;

begin
  r := 0;

  if (PositionProps.Count > Position) then
    ActiveStart := PositionProps[Position].ActiveStart
  else
    if (Display.ActiveStart < 0) or (Display.ActiveStart = Display.ActiveEnd) then
      ActiveStart := Display.DisplayStart
    else
      ActiveStart := Display.ActiveStart;

  if (PositionProps.Count > Position) then
    ActiveEnd := PositionProps[Position].ActiveEnd
  else
    if (Display.ActiveEnd < 0) or (Display.ActiveStart = Display.ActiveEnd) then
      ActiveEnd := Display.DisplayEnd
    else
      ActiveEnd := Display.ActiveEnd;

  if Active and (ActiveStart < ActiveEnd) then
  begin
    StartIdx := ActiveStart;
    EndIdx := ActiveEnd - 1;
  end
  else
  begin
    StartIdx := 0;
    EndIdx := Display.DisplayEnd - Display.DisplayStart;
  end;

  for i := StartIdx to EndIdx do
  begin
    plit := Items.FindFirst(i, i + 1, Position);

    if Assigned(plIt) then
    begin
      if not plIt.InHeader then
        inc(r)
      else
      begin
        FoundNonHeader := false;
        repeat
          plit := Items.FindNext(i, i + 1, Position);
          if Assigned(plit) then
            if not plit.InHeader  then
              FoundNonHeader := true;
        until not Assigned(plit) or FoundNonHeader;
        if FoundNonHeader then
          inc(r);
      end;
    end;
  end;

  Result := Round(100 * r / (EndIdx - StartIdx + 1));
end;

function TCustomPlanner.AbsTimeToCell(DateTime: TDateTime): Integer;
var
  Year, Month, Day, Hour, Minute, Second, Second100: Word;
  DateTimeStart: TDateTime;
  dday: Integer;

begin
  Result := 0;
  case Mode.PlannerType of
    plDay:
      begin
        DecodeTime(DateTime, Hour, Minute, Second, Second100);
        Minute := Minute + Hour * 60;
        Result := ((Minute - Display.DisplayOffset) div Display.DisplayUnit) - Display.DisplayStart;
      end;
    plWeek:
      begin
        Result := Trunc(DateTime - Mode.StartOfMonth);
      end;
    plMonth:
      begin
        DecoDedate(DateTime, Year, Month, Day);
        Result := Day - 1;
      end;
    plDayPeriod:
      begin
        DateTimeStart := Mode.PeriodStartDate;
        if DateTime > DateTimeStart then
          Result := Round(DateTime - DateTimeStart);
      end;
    plHalfDayPeriod:
      begin
        DateTimeStart := Mode.PeriodStartDate;
        if DateTime > DateTimeStart then
          Result := Round(2 * (DateTime - DateTimeStart));
      end;
    plMultiMonth:
      begin
      end;
    plCustom, plCustomList:
      begin
        Result := TimeToIndex(DateTime);
      end;
    plTimeLine:
      begin
        // divisions / day
        dday := (MinInDay div Display.DisplayUnit) - Mode.TimeLineNVUBegin - Mode.TimeLineNVUEnd;

        // position based on day
        if DateTime < Mode.TimeLineStart then
          Result := (Trunc(Int(DateTime - Mode.TimeLineStart)) * dday) - dday
        else
          Result := Trunc(Int(DateTime - Mode.TimeLineStart)) * dday;

        DecodeTime(DateTime, Hour, Minute, Second, Second100);
        Minute := Minute + Hour * 60;

        // check if time overflows nvu end
        
        if Minute > 1440 - Mode.TimeLineNVUEnd * Display.DisplayUnit then
          Minute := 1440 - Mode.TimeLineNVUEnd * Display.DisplayUnit; // max. value allowed

        if Minute >= Mode.TimeLineNVUBegin * Display.DisplayUnit then
          Minute := Minute - Mode.TimeLineNVUBegin * Display.DisplayUnit
        else
          Minute := 0;


        Result := Result + (Minute div Display.DisplayUnit);
        {
        DecodeTime(DateTime, Hour, Minute, Second, Second100);
        Minute := Minute + Hour * 60;
        Result := ((Minute - Display.DisplayOffset) div Display.DisplayUnit) - Display.DisplayStart;
        DecodeDate(DateTime, Year, Month, Day);
        Result := Result +  (MININDAY div Display.DisplayUnit) * Round((Int(DateTime - Mode.TimeLineStart)));
        }
      end;
  end;
end;

function TCustomPlanner.CellInCurrTime(X,Y: Integer): Boolean;
var
  DateTime: TDateTime;
  dtStart, dtEnd: TDateTime;
  BCurPos: Boolean;
  da,mo,ye: word;
begin
  Result := False;

  CellToAbsTime(X, dtStart, dtEnd);

  if Mode.PlannerType = plMultiMonth then
  begin
    DecodeDate(dtStart,ye,mo,da);

    while(mo + y - 1 > 12) do
    begin
      inc(ye);
      dec(y,12);
    end;
    mo := mo + y - 1;

    if da <= PlanUtil.DaysInMonth(mo,ye) then
    begin
      dtstart := encodedate(ye,mo,da);
      dtend := dtstart + 1;
    end
    else
      Exit;
  end;

  DateTime := Now;

  if (Mode.PlannerType = plDay) then
  begin
    if int(dtstart) = 0 then
      DateTime := Frac(DateTime);
  end;

  if Assigned(FOnGetCurrentTime) then
    FOnGetCurrentTime(Self, DateTime);

  if Sidebar.Orientation = soVertical then
    BCurPos := IsCurPos(Y - Sidebar.FColOffset)
  else
    BCurPos := IsCurPos(Y - Sidebar.FRowOffset);

  Result := ((DateTime >= dtStart) and (DateTime <= dtEnd)) and (FDisplay.ShowCurrent) and BCurPos;
end;

procedure TCustomPlanner.MovePosition(FromPos, ToPos: Integer);
var
  ItemIndex: Integer;
begin
  {Add extra Position}
  Items.BeginUpdate;

  if ToPos > FromPos then
    Inc(ToPos);

  InsertPosition(ToPos);
  if (ToPos < FromPos) then
    Inc(FromPos);
  with Self.Items do
    for ItemIndex := 0 to Count - 1 do
    begin
      if Items[ItemIndex].ItemPos = FromPos then
        Items[ItemIndex].ItemPos := ToPos;
    end;

  Header.Captions.Strings[ToPos + 1] := Header.Captions.Strings[FromPos + 1];
  Header.Captions.Objects[ToPos + 1] := Header.Captions.Objects[FromPos + 1];

  Footer.Captions.Strings[ToPos + 1] := Footer.Captions.Strings[FromPos + 1];
  Footer.Captions.Objects[ToPos + 1] := Footer.Captions.Objects[FromPos + 1];

  DeletePosition(FromPos);

  Items.EndUpdate;
end;

procedure TCustomPlanner.DeletePosition(Position: Integer);
var
  ItemIndex: Integer;
begin
  Items.BeginUpdate;
  ItemIndex := 0;

  with Self.Items do
    while (ItemIndex < Count) do
    begin
      if Items[ItemIndex].ItemPos > Position then
      begin
        Items[ItemIndex].ItemPos := Items[ItemIndex].ItemPos - 1;
        Inc(ItemIndex);
      end
      else if Items[ItemIndex].ItemPos = Position then
        Items[ItemIndex].Free
      else
        Inc(ItemIndex);

    end;
  Positions := Positions - 1;
  Items.EndUpdate;
  Header.Captions.Delete(Position + 1);
  Footer.Captions.Delete(Position + 1);
end;

procedure TCustomPlanner.InsertPosition(Position: Integer);
var
  ItemIndex: Integer;
begin
  Items.BeginUpdate;
  Positions := Positions + 1;
  with Items do
    for ItemIndex := 0 to Count - 1 do
    begin
      if Items[ItemIndex].ItemPos >= Position then
        Items[ItemIndex].ItemPos := Items[ItemIndex].ItemPos + 1;
    end;
  Items.EndUpdate;
  Header.Captions.Insert(Position + 1, '');
  Footer.Captions.Insert(Position + 1, '');
end;

procedure TCustomPlanner.HideSelection;
begin
  FGrid.HideSelection;
end;

procedure TCustomPlanner.UnHideSelection;
begin
  FGrid.UnHideSelection;
end;

procedure TCustomPlanner.SetItemGap(const Value: Integer);
begin
  if FItemGap <> Value then
  begin
    FItemGap := Value;
    Invalidate;
  end;
end;

procedure TCustomPlanner.WMTimer(var Message: TWMTimer);
var
  ac,i: Integer;
  ANow: TDateTime;
  Msg: string;
  CondA,CondB: Boolean;

begin
  inherited;

  if Assigned(FOnTimer) then
    FOnTimer(self);

  ANow := Now;
  if Assigned(FOnGetCurrentTime) then
    FOnGetCurrentTime(Self, ANow);

  if not (csDesigning in ComponentState) and EnableFlashing then
  begin
    for i := 1 to Items.Count do
    begin
      if Items[i - 1].Flashing then
      begin
        Items[i - 1].FlashOn := not Items[i - 1].FlashOn;
        Items[i - 1].Repaint;
      end;
    end;
  end;


  if not (csDesigning in ComponentState) and EnableAlarms and
     (GetCapture <> FGrid.Handle) and not FHandlingAlarm then
  begin

    for i := 1 to Items.Count do
    begin
      with Items[i - 1].Alarm do

      if Active and (Assigned(Handler) or Assigned(FOnItemAlarm)) then
      begin
        if Items[i - 1].RealTime then
        begin
          CondB := (ANow + TimeBefore > Items[i - 1].ItemRealStartTime) and
            (ANow <= Items[i - 1].ItemRealStartTime);

          CondA := (ANow + TimeAfter > Items[i - 1].ItemRealEndTime);
        end
        else
        begin
          CondB := (Frac(ANow) + Frac(TimeBefore) > Frac(Items[i - 1].ItemStartTime)) and
            (Frac(ANow) <= Frac(Items[i - 1].ItemStartTime));

          if CondB then
          begin
            CondB := ( (Int(ANow) = Int(Items[i - 1].FItemRealStartTime)) or
              (Int(Items[i - 1].FItemRealStartTime) = 0) );
          end;

          CondA := (Frac(ANow) + Frac(TimeAfter) > Frac(Items[i - 1].ItemEndTime)) and
            (((Int(ANow) >= Int(Items[i - 1].ItemEndTime)) or (Int(Items[i - 1].ItemEndTime) = 0)));

          if CondA then
          begin
            CondA := ( (Int(ANow) >= Int(Items[i - 1].FItemRealEndTime)) or
              (Int(Items[i - 1].FItemEndTime) = 0) );
          end;

        end;

        if (CondB and (Items[i - 1].Alarm.Time in [atBefore,atBoth])) or
           (CondA and (Items[i - 1].Alarm.Time in [atAfter,atBoth])) then
        begin
          Active := False;
          FHandlingAlarm := True;

          case NotifyType of
          anCaption: msg := HTMLStrip(Items[i - 1].CaptionText);
          anMessage: msg := Items[i - 1].Alarm.Message;
          anNotes: msg := HTMLStrip(Items[i - 1].Text.Text);
          end;

          if Assigned(FOnItemAlarm) then
            FOnItemAlarm(Self,Items[i - 1]);

          if Assigned(Handler) then
          begin
            if not Handler.HandleAlarm(Address,Msg,Tag,ID,Items[i - 1]) then
              Active := True;
          end;
          FHandlingAlarm := False;
        end;
      end;
    end;
  end;

  ac := AbsTimeToCell(ANow);

  if (ac <> FTimerActiveCells) then
  begin
    if Sidebar.Orientation = soHorizontal then
    begin
      {$IFNDEF TMSDOTNET}
      FGrid.InvalidateCol(FTimerActiveCells);
      FTimerActiveCells := ac;
      FGrid.InvalidateCol(FTimerActiveCells);
      {$ENDIF}
      {$IFDEF TMSDOTNET}
      FGrid.InvalidateColP(FTimerActiveCells);
      FTimerActiveCells := ac;
      FGrid.InvalidateColP(FTimerActiveCells);
      {$ENDIF}
    end
    else
    begin
      {$IFNDEF TMSDOTNET}
      FGrid.InvalidateRow(FTimerActiveCells);
      FTimerActiveCells := ac;
      FGrid.InvalidateRow(FTimerActiveCells);
      {$ENDIF}
      {$IFDEF TMSDOTNET}
      FGrid.InvalidateRowP(FTimerActiveCells);
      FTimerActiveCells := ac;
      FGrid.InvalidateRowP(FTimerActiveCells);
      {$ENDIF}
    end;
  end;

  if FDisplay.ShowCurrentItem then
  begin
    Items.SetCurrent(ac);
  end;

  if FSideBar.TimeIndicator and (Mode.PlannerType in [plTimeLine, plDay]) then
  begin
    if Mode.PlannerType = plTimeLine then
      i := AbsTimeToCell(Now)
    else
      i := AbsTimeToCell(Frac(Now));

    if FSideBar.Position <> spTop then
    begin
      {$IFNDEF TMSDOTNET}
      FGrid.InvalidateCell(0, i - 1);
      FGrid.InvalidateCell(0, i );
      {$ENDIF}
      {$IFDEF TMSDOTNET}
      FGrid.InvalidateCellP(0, i - 1);
      FGrid.InvalidateCellP(0, i );
      {$ENDIF}
    end
    else
    begin
      {$IFNDEF TMSDOTNET}
      FGrid.InvalidateCell(i - 1,0);
      FGrid.InvalidateCell(i,0 );
      {$ENDIF}
      {$IFDEF TMSDOTNET}
      FGrid.InvalidateCellP(i - 1,0);
      FGrid.InvalidateCellP(i,0 );
      {$ENDIF}
    end;

  end;
end;

procedure TCustomPlanner.WndProc(var Message: TMessage);
{$IFDEF DELPHI6_LVL}
var
  ShiftState: TShiftState;
{$ENDIF}
begin
  if (Message.Msg = WM_THEMECHANGED) then
  begin
    if AutoThemeAdapt then
      ThemeAdapt;
  end;
  if (Message.Msg = WM_DESTROY) then
  begin
    if Assigned(FDisplay) then
    begin
      if ((FDisplay.ShowCurrent) or (FDisplay.ShowCurrentItem)) and (FTimerID <> 0) then
      KillTimer(Handle, FTimerID);
    end
    else
      if (FTimerID <> 0) then
        KillTimer(Handle, FTimerID);

    FTimerID := 0;
  end;

  {$IFDEF DELPHI6_LVL}
  if (Message.Msg = CM_CHILDKEY) then
  begin
    ShiftState := KeyDataToShiftState(Message.lParam);
    if (Message.wParam = VK_INSERT) and (ShiftState = []) then
      Message.Result := 0;
  end;
  {$ENDIF}

  inherited;
end;

function TCustomPlanner.GetMemo: TMemo;
begin
  Result := FGrid.FMemo;
end;

function TCustomPlanner.GetMaskEdit: TMaskEdit;
begin
  Result := FGrid.FMaskEdit;
end;

procedure TCustomPlanner.InactiveChanged(Sender: TObject);
begin
  FInactive := [];
  if FInactiveDays.FSun then
    FInactive := FInactive + [1];
  if FInactiveDays.FMon then
    FInactive := FInactive + [2];
  if FInactiveDays.FTue then
    FInactive := FInactive + [3];
  if FInactiveDays.FWed then
    FInactive := FInactive + [4];
  if FInactiveDays.FThu then
    FInactive := FInactive + [5];
  if FInactiveDays.FFri then
    FInactive := FInactive + [6];
  if FInactiveDays.FSat then
    FInactive := FInactive + [7];
  Invalidate;
end;

procedure TCustomPlanner.PreviewPaint(APlannerItem: TPlannerItem; Canvas: TCanvas;
  r: TRect; Direction, Print: Boolean);
begin
  if not Direction then
    FGrid.PaintItemCol(Canvas, r, APlannerItem, Print, False)
  else
    FGrid.PaintItemRow(Canvas, r, APlannerItem, Print, False);
end;

procedure TCustomPlanner.SetDefaultItem(const Value: TPlannerItem);
begin
  FDefaultItem.Assign(Value);
end;

procedure TCustomPlanner.SetSelectColor(const Value: TColor);
begin
  if FSelectColor <> Value then
  begin
    FSelectColor := Value;
    Invalidate;
  end;
end;

procedure TCustomPlanner.SetShowSelection(const Value: Boolean);
begin
  if FShowSelection <> Value then
  begin
    FShowSelection := Value;
    Invalidate;
  end;
end;

procedure TCustomPlanner.SetFlat(const Value: Boolean);
begin
  if Value <> FFlat then
  begin
    if Value then
    begin
      FGrid.BorderStyle := bsNone;
      FGrid.Ctl3D := False;
    end
    else
    begin
      FGrid.BorderStyle := bsSingle;
      FGrid.Ctl3D := True;
    end;
    FFlat := Value;
  end;
  FGrid.UpdatePositions;
end;

procedure TCustomPlanner.AutoSizeHeader;
var
  PositionIndex, MaxItemPerPosition: Integer;
  MaxItemOverAll: Integer;
  APlannerItem: TPlannerItem;

begin
  MaxItemOverAll := 0;

  for PositionIndex := 0 to Positions - 1 do
  begin
    MaxItemPerPosition := 0;
    APlannerItem := Items.HeaderFirst(PositionIndex);

    while Assigned(APlannerItem) do
    begin
      Inc(MaxItemPerPosition);
      APlannerItem := Items.HeaderNext(PositionIndex);
    end;

    if (MaxItemPerPosition > MaxItemOverAll) then
      MaxItemOverAll := MaxItemPerPosition;
  end;

  FNoPositionSize := true;
  Header.Height := Header.TextHeight + MaxItemOverAll * Header.ItemHeight + 2;
  FNoPositionSize := false;
end;

procedure TCustomPlanner.SetPositionGap(const Value: Integer);
begin
  if FPositionGap <> Value then
  begin
    FPositionGap := Value;
    FGrid.Invalidate;
  end;
end;

procedure TCustomPlanner.SetPositionGapColor(const Value: TColor);
begin
  if FPositionGapColor <> Value then
  begin
    FPositionGapColor := Value;
    FGrid.Invalidate;
  end;
end;

procedure TCustomPlanner.Notification(AComponent: TComponent;
  AOperation: TOperation);
var
  i: Integer;
begin
  inherited;

  if csDestroying in ComponentState then
    Exit;

  if (AOperation = opRemove) and
     (AComponent = FPlannerImages) then
    FPlannerImages := nil;
  if (AOperation = opRemove) and
     (AComponent = FContainer) then
    FContainer := nil;
  if (AOperation = opRemove) and
     (AComponent = FPlanChecker) then
    FPlanChecker := nil;

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

  if (AOperation = opRemove) and Assigned(Items) then
  begin
    for i := 1 to Items.Count do
    begin
      if Items[i - 1].Alarm.Handler = AComponent then
        Items[i - 1].Alarm.Handler := nil;

      if Items[i - 1].Editor = AComponent then
        Items[i - 1].Editor := nil;

      if Items[i - 1].PopupMenu = AComponent then
        Items[i - 1].PopupMenu := nil;

      if Items[i - 1].DrawTool = AComponent then
        Items[i - 1].DrawTool := nil;

    end;
  end;


end;

procedure TCustomPlanner.ItemMoved(APlannerItem: TPlannerItem; FromBegin, FromEnd, FromPos, ToBegin, ToEnd,
  ToPos: Integer);
var
  i: Integer;
  NewBegin,NewEnd,NewPos: Integer;

begin
  if (FromBegin = ToBegin) and (FromEnd = ToEnd) and (FromPos = ToPos) then
    Exit;

  if not Assigned(APlannerItem) then
    Exit;

  if Assigned(FOnItemMove) then
    FOnItemMove(Self, APlannerItem, FromBegin, FromEnd, FromPos, ToBegin, ToEnd, ToPos);

  Items.Changing := True;
  if Assigned(APlannerItem) then
  begin
    if APlannerItem.ParentIndex >= 0 then
    begin
      i := 0;
      while i < Items.Count do
      begin
        if (Items[i] <> APlannerItem) and (Items[i].ParentIndex = APlannerItem.ParentIndex) then
        begin
          NewBegin := Items[i].ItemBegin + ToBegin - FromBegin;
          NewEnd := Items[i].ItemEnd + ToEnd - FromEnd;
          NewPos := Items[i].ItemPos + ToPos - FromPos;

          if (NewPos < 0) or (NewPos >= Positions) or
             (NewBegin < Display.DisplayStart) or (NewEnd > Display.DisplayEnd + 1)  then
          begin
            if Items[i].RelationShip = irParent then
              APlannerItem.RelationShip := irParent;
            Items[i].Free;
          end
          else
          begin
            Items[i].ItemBegin := NewBegin;
            Items[i].ItemEnd := NewEnd;
            Items[i].ItemPos := NewPos;
            inc(i);
          end;
        end
        else
          inc(i);
      end;
    end;
  end;  

  Items.Changing := False;
end;

procedure TCustomPlanner.ItemSized(APlannerItem: TPlannerItem; FromBegin, FromEnd, ToBegin, ToEnd: Integer);
var
  i: Integer;
  NewBegin,NewEnd: Integer;

begin
  if (FromBegin = ToBegin) and (FromEnd = ToEnd) then
    Exit;

  if not Assigned(APlannerItem) then
    Exit;

  if Assigned(FOnItemSize) then
    FOnItemSize(Self, APlannerItem, APlannerItem.ItemPos, FromBegin, FromEnd,
                ToBegin, ToEnd);

  Items.Changing := True;
  
  if Assigned(APlannerItem) then
  begin
    if APlannerItem.ParentIndex >= 0 then
    begin
      i := 0;
      while i < Items.Count do
      begin
        if (Items[i] <> APlannerItem) and (Items[i].ParentIndex = APlannerItem.ParentIndex) then
        begin

          NewBegin := Items[i].ItemBegin + ToBegin - FromBegin;

          NewEnd := Items[i].ItemEnd + ToEnd - FromEnd;

          if (NewBegin < Display.DisplayStart) or (NewEnd > Display.DisplayEnd + 1)  then
          begin
            if Items[i].RelationShip = irParent then
              Items.Selected.RelationShip := irChild;
            Items[i].Free;
          end
          else
          begin
            Items[i].ItemBegin := NewBegin;
            Items[i].ItemEnd := NewEnd;
            inc(i);
          end
        end
        else
          inc(i);
      end;
    end;
  end;

  Items.Changing := False;
end;

procedure TCustomPlanner.ItemEdited(Item: TPlannerItem);
begin
  if Assigned(ItemChecker) then
  begin
    if ItemChecker.AutoCorrect then
      Item.Text.Text := ItemChecker.Correct(Item.Text.Text);

    if ItemChecker.AutoMarkError then
      Item.Text.Text := ItemChecker.MarkError(Item.Text.Text);
  end;

  if Assigned(FOnItemEndEdit) then
  begin
    FOnItemEndEdit(Self, Item);
    // Workaround for hanging selection when OnItemEndEdit takes focus away
    // from the Planner. Set Planner.GridControl.MouseRelease := true from event code

    if FGrid.MouseRelease then
    begin
      PostMessage(FGrid.handle,WM_LBUTTONUP,0,0);
    end;
  end;

  FEditMode := False;
end;

function TCustomPlanner.CreateItem: TPlannerItem;
begin
  Result := Items.Add;
  FGrid.UpdateNVI;  
end;

function TCustomPlanner.CloneItem(Item: TPlannerItem): TPlannerItem;
begin
  Result := Items.Add;
  Result.Assign(Item);
  Result.RelationShip := irChild;
  Item.RelationShip := irParent;
  Item.ParentIndex := Item.Index;
  Result.ParentIndex := Item.Index;
end;

procedure TCustomPlanner.RemoveClones(Item: TPlannerItem);
var
  i, idx: Integer;
begin
  idx := Item.ParentIndex;
  i := 0;
  while (i < Items.Count) do
  begin
    if (Items[i].ParentIndex = idx) and (Items[i].RelationShip = irChild) then
      Items[i].Free
    else
      inc(i);
  end;

end;

procedure TCustomPlanner.FreeItem(APlannerItem: TPlannerItem);
var
  i: integer;
  dbkey: string;
begin
  if (APlannerItem.Recurrent) and (APlannerItem.DBKey <> '') then
  begin
    dbkey := APlannerItem.DBKey;

    for i := Items.Count - 1 downto 0 do
    begin
      if (Items[i].DBKey = dbkey) and (Items[i] <> APlannerItem) then
        Items[i].Free;
    end;
  end;

  if Items.FSelected = APlannerItem then
    Items.FSelected := nil;
  APlannerItem.ParentItem.Free;
  FGrid.UpdateNVI;
end;

procedure TCustomPlanner.StopEditing;
begin
  FGrid.SetFocus;
end;

procedure TCustomPlanner.UpdateItem(APlannerItem: TPlannerItem);
begin
  // only used by DBPlanner
end;

procedure TCustomPlanner.RefreshItem(APlannerItem: TPlannerItem);
begin
  // only used by DBPlanner
end;

procedure TCustomPlanner.MapItemTimeOnPlanner(APlannerItem: TPlannerItem);
begin

end;

procedure TCustomPlanner.SetTrackWidth(const Value: Integer);
begin
  if FTrackWidth <> Value then
  begin
    FTrackWidth := Value;
    Invalidate;
  end;
end;

procedure TCustomPlanner.PlanTimeToStrings(MinutesValue: Integer;
  var HoursString: string; var MinutesString: string; var AmPmString: string);
var
  Hours, Minutes: Integer;

  function ChooseNonEmpty(s1,s2:string):string;
  begin
    if s2 = '' then
      Result := s1
    else
      Result := s2;
  end;

begin
  while MinutesValue < 0 do
    MinutesValue := MinutesValue + MININDAY;

  Hours := MinutesValue div 60;
  Minutes := MinutesValue mod 60;
  Hours := Hours mod 24;

  MinutesString := Format('%.2d', [Minutes]);

  case HourType of
  ht24hrs: AmPmString := '';
  ht12hrs: if Hours > 12 then
             Hours := Hours - 12;
  htAMPM0:
    begin
      if Hours >= 12 then
        AmPmString := ChooseNonEmpty('PM',TimePMString)
      else
        AmPmString := ChooseNonEmpty('AM',TimeAMString);
      if Hours > 12 then
        Hours := Hours - 12
    end;
  htAMPM1:
    begin
      if Hours in [1..12] then
        AmPmString := ChooseNonEmpty('AM',TimePMString)
      else
        AmPmString := ChooseNonEmpty('PM',TimeAMString);
      if Hours > 12 then
        Hours := Hours - 12
    end;
  htAMPMOnce:
    begin
      If Minutes = 0 then
      begin
        AMPMString := '';
        if Hours >= 12 then
          MinutesString := ChooseNonEmpty('PM',TimePMString)
        else
          MinutesString := ChooseNonEmpty('AM',TimeAMString);
      end;
      if Hours > 12 then
        Hours := Hours - 12
    end;
  end;

  HoursString := Format('%d', [Hours]);

  if Assigned(OnPlanTimeToStrings) then
    OnPlanTimeToStrings(Self, MinutesValue, HoursString, MinutesString, AmPmString);
end;

function TCustomPlanner.PlanTimeToStr(MinutesValue: Integer): string;
// Result: "HH:MM" (24 hr format) or "HH:MM ZZ" (12 hr format) where ZZ is TimePMString or TimeAMString
var
  HoursString, MinutesString, AmPmString: string;
begin
  while MinutesValue < 0 do
    MinutesValue := MinutesValue + MININDAY;

  PlanTimeToStrings(MinutesValue, HoursString, MinutesString, AmPmString);
  Result := Format('%s%s%s', [HoursString, TimeSeparator, MinutesString]);
  if AmPmString <> '' then
    Result := Format('%s %s', [Result, AmPmString]);
end;

procedure TCustomPlanner.ItemUnSelected(Item: TPlannerItem);
begin
  if Assigned(OnItemUnSelect) then
    OnItemUnSelect(Self, Item);
end;

procedure TCustomPlanner.ItemSelected(Item: TPlannerItem);
begin
  if Assigned(OnItemSelect) then
    OnItemSelect(Self, Item);
end;

procedure TCustomPlanner.SetShadowColor(const Value: TColor);
begin
  if FShadowColor <> Value then
  begin
    FShadowColor := Value;
    Invalidate;
  end;
end;

procedure TCustomPlanner.SetURLColor(const Value: TColor);
begin
  if FURLColor <> Value then
  begin
    FURLColor := Value;
    Invalidate;
  end;
end;

procedure TCustomPlanner.SetURLGlyph(const Value: TBitmap);
begin
  FURLGlyph.Assign(Value);
  Invalidate;
end;

procedure TCustomPlanner.SetDeleteGlyph(const Value: TBitmap);
begin
  FDeleteGlyph.Assign(Value);
  Invalidate;
end;


procedure TCustomPlanner.SetAttachementGlyph(const Value: TBitmap);
begin
  FAttachementGlyph.Assign(Value);
  Invalidate;
end;

procedure TCustomPlanner.HeaderSized(Sender: TObject; ASection, AWidth: Integer);
begin
  if ASection = 0 then
  begin
    if Sidebar.Position = spTop then
      AWidth := FGrid.RowHeights[0]
    else
    begin
      if not NavigatorButtons.Visible then
        AWidth := FGrid.ColWidths[0]
      else
        AWidth := FGrid.ColWidths[0] - BtnWidth;
    end;

    if FFlat then
      FHeader.SectionWidth[0] := AWidth
    else
      FHeader.SectionWidth[0] := AWidth + 2;

    if FFlat then
      FFooter.SectionWidth[0] := AWidth
    else
      FFooter.SectionWidth[0] := AWidth + 2;

  end
  else
  begin
    if Header.ResizeAll then
    begin
//      if FNavigatorButtons.Visible then
//        PositionWidth := AWidth// + BtnWidth
//      else
      PositionWidth := AWidth;
    end
    else
      PositionWidths[ASection - 1] := AWidth;


    if Assigned(OnHeaderSized) then
      OnHeaderSized(Self, ASection - 1, AWidth);  
  end;
end;

function TCustomPlanner.CreateItemAtSelection: TPlannerItem;
begin

  Result := Items.Add;
  Result.ItemBegin := SelItemBegin;
  Result.ItemEnd := SelItemEnd;
  Result.ItemPos := SelPosition;

  FGrid.UpdateNVI;
end;

function TCustomPlanner.CloneItemAtSelection(Item: TPlannerItem): TPlannerItem;
begin
  Result := CloneItem(Item);
  Result.ItemBegin := SelItemBegin;
  Result.ItemEnd := SelItemEnd;
  Result.ItemPos := SelPosition;
end;

procedure TCustomPlanner.SetEnableAlarms(const Value: Boolean);
begin
  FEnableAlarms := Value;
  UpdateTimer;
end;

procedure TCustomPlanner.SetEnableFlashing(const Value: Boolean);
begin
  FEnableFlashing := Value;
  UpdateTimer;
end;

procedure TCustomPlanner.SetPositionProps(const Value: TPositionProps);
begin
  FPositionProps.Assign(Value);
end;

function TCustomPlanner.CreateItems: TPlannerItems;
begin
  {$IFNDEF TMSDOTNET}
  Result := TPlannerItems.Create(Self);
  {$ENDIF}
  {$IFDEF TMSDOTNET}
  Result := TPlannerItems.Create(Self, TPlannerItem);
  {$ENDIF}
end;

procedure TCustomPlanner.Refresh;
begin

end;

function TCustomPlanner.IndexToTime(Index: Integer): TDateTime;
begin
  Result := 0;
  
  if Mode.PlannerType = plCustomList then
  begin
    if Index < FDTList.Count then
      Result := FDTList.Items[Index];
  end;

  if Assigned(FOnCustomITEvent) then
    FOnCustomITEvent(Self,Index,Result);
end;

function TCustomPlanner.TimeToIndex(DT: TDateTime): Integer;
var
  Idx: Integer;
begin
  Result := 0;
  if Mode.PlannerType = plCustomList then
  begin
    Idx := 0;
    while Idx < FDTList.Count do
    begin
      {$IFDEF DELPHI7_LVL}
      if (CompareDateTime(FDTList.Items[Idx], DT) in [0,1]) then
      {$ENDIF}
      {$IFNDEF DELPHI7_LVL}
      if FDTList.Items[Idx] >= DT then
      {$ENDIF}
      begin
        Result := Idx;
        Break;
      end
      else
       Inc(Idx);
    end;
  end;

  if Assigned(FOnCustomTIEvent) then
    FOnCustomTIEvent(Self,DT,Result);
end;

function TCustomPlanner.PosToDay(Pos: Integer): TDateTime;
begin
  Result := 0;
  if Assigned(FOnPositionToDay) then
    FOnPositionToDay(Self,Pos,Result);
end;


procedure TCustomPlanner.SetFlashColor(const Value: TColor);
begin
  if FFlashColor <> Value then
  begin
    FFlashColor := Value;
    Invalidate;
  end;
end;

procedure TCustomPlanner.SetFlashFontColor(const Value: TColor);
begin
  if FFlashFontColor <> Value then
  begin
    FFlashFontColor := Value;
    Invalidate;
  end;
end;

procedure TCustomPlanner.ExportItem(APlannerItem: TPlannerItem);
begin
  APlannerItem.DoExport := True;
end;

procedure TCustomPlanner.ExportItems;
var
  i: Integer;
begin
  for i := 1 to Items.Count do
    Items.Items[i - 1].DoExport := True;
end;

procedure TCustomPlanner.ExportClear;
var
  i: Integer;
begin
  for i := 1 to Items.Count do
    Items.Items[i - 1].DoExport := False;
end;


procedure TCustomPlanner.ExportLayer(Layer: Integer);
var
  i: Integer;
begin
  for i := 1 to Items.Count do
    if Items.Items[i - 1].Layer and Layer = Layer then
      Items.Items[i - 1].DoExport := True;
end;

procedure TCustomPlanner.ExportPosition(Pos: Integer);
var
  i: Integer;
begin
  for i := 1 to Items.Count do
    if Items.Items[i - 1].ItemPos = Pos then
      Items.Items[i - 1].DoExport := True;
end;

procedure TCustomPlanner.HilightInItem(APlannerItem: TPlannerItem; AText: string;
  DoCase: Boolean);
begin
  APlannerItem.Text.Text := Hilight(APlannerItem.Text.Text,AText,'hi',DoCase);
end;

procedure TCustomPlanner.HilightInItems(AText: string; DoCase: Boolean);
var
  i: Integer;
begin
  for i := 1 to Items.Count do
    Items.Items[i - 1].Text.Text := Hilight(Items.Items[i - 1].Text.Text,AText,'hi',DoCase);
end;

procedure TCustomPlanner.HilightInPositon(Pos: Integer; AText: string;
  DoCase: Boolean);
var
  i: Integer;
begin
  for i := 1 to Items.Count do
    if Items.Items[i - 1].ItemPos = Pos then
      Items.Items[i - 1].Text.Text := Hilight(Items.Items[i - 1].Text.Text,AText,'hi',DoCase);
end;

procedure TCustomPlanner.MarkInItem(APlannerItem: TPlannerItem; AText: string;
  DoCase: Boolean);
begin
  APlannerItem.Text.Text := Hilight(APlannerItem.Text.Text,AText,'e',DoCase);
end;

procedure TCustomPlanner.MarkInItems(AText: string; DoCase: Boolean);
var
  i: Integer;
begin
  for i := 1 to Items.Count do
    Items.Items[i - 1].Text.Text := Hilight(Items.Items[i - 1].Text.Text,AText,'e',DoCase);
end;

procedure TCustomPlanner.MarkInPositon(Pos: Integer; AText: string;
  DoCase: Boolean);
var
  i: Integer;
begin
  for i := 1 to Items.Count do
    if Items.Items[i - 1].ItemPos = Pos then
      Items.Items[i - 1].Text.Text := Hilight(Items.Items[i - 1].Text.Text,AText,'e',DoCase);
end;

procedure TCustomPlanner.UnHilightInItem(APlannerItem: TPlannerItem);
begin
  APlannerItem.Text.Text := UnHilight(APlannerItem.Text.Text,'hi');
end;

procedure TCustomPlanner.UnHilightInItems;
var
  i: Integer;
begin
  for i := 1 to Items.Count do
    Items.Items[i - 1].Text.Text := UnHilight(Items.Items[i - 1].Text.Text,'hi');
end;

procedure TCustomPlanner.UnHilightInPositon(Pos: Integer);
var
  i: Integer;
begin
  for i := 1 to Items.Count do
    if Items.Items[i - 1].ItemPos = Pos then
      Items.Items[i - 1].Text.Text := UnHilight(Items.Items[i - 1].Text.Text,'hi');
end;

procedure TCustomPlanner.UnMarkInItem(APlannerItem: TPlannerItem);
begin
  APlannerItem.Text.Text := UnHilight(APlannerItem.Text.Text,'e');
end;

procedure TCustomPlanner.UnMarkInItems;
var
  i: Integer;
begin
  for i := 1 to Items.Count do
    Items.Items[i - 1].Text.Text := UnHilight(Items.Items[i - 1].Text.Text,'e');
end;

procedure TCustomPlanner.UnMarkInPositon(Pos: Integer);
var
  i: Integer;
begin
  for i := 1 to Items.Count do
    if Items.Items[i - 1].ItemPos = Pos then
      Items.Items[i - 1].Text.Text := UnHilight(Items.Items[i - 1].Text.Text,'e');
end;

function TCustomPlanner.GetDragCopy: Boolean;
begin
  Result := GetKeyState(VK_CONTROL) and $8000 = $8000;
end;

function TCustomPlanner.GetDragMove: Boolean;
begin
  Result := GetKeyState(VK_MENU) and $8000 = $8000;
end;

procedure TCustomPlanner.SetPositionGroup(const Value: Integer);
begin
  FPositionGroup := Value;
  FHeader.Invalidate;
end;

procedure TCustomPlanner.SetTrackBump(const Value: Boolean);
begin
  FTrackBump := Value;
  Invalidate;
end;

function TCustomPlanner.GetPositionWidths(Position: Integer): Integer;
begin
  if SideBar.Visible then
    inc(Position);

  if SideBar.Position <> spTop then
     Result := FGrid.ColWidths[Position]
   else
     Result := FGrid.RowHeights[Position];
end;

procedure TCustomPlanner.SetPositionWidths(Position: Integer;
  const Value: Integer);
begin
  if SideBar.Visible then
    Inc(Position);

  if SideBar.Position <> spTop then
  begin
    if Position >= FGrid.ColCount then
      Exit;
    FGrid.FPosResizing := True;
    FGrid.ColWidths[Position] := Value
  end
  else
  begin
    if Position >= FGrid.RowCount then
      Exit;
    FGrid.FPosResizing := True;
    FGrid.RowHeights[Position] := Value;
  end;

  if Header.Visible then
    if FHeader.Sections.Count > Position then
      FHeader.SectionWidth[Position] := Value;

  if Footer.Visible then
    if FFooter.Sections.Count > Position then
      FFooter.SectionWidth[Position] := Value;

  FGrid.FPosResizing := False;
end;

procedure TCustomPlanner.SetPositionZoomWidth(const Value: Integer);
begin
  FPositionZoomWidth := Value;
  FHeader.Zoom := (FPositionZoomWidth > 0) and (PositionZoomWidth > PositionWidth);
  if FHeader.Zoom then
    Header.AllowPositionResize := False
  else
    FHeader.Cursor := crDefault;
end;

procedure TCustomPlanner.SetSelectBlend(const Value: Integer);
begin
  if (Value > 100) or (Value < 0) then
    raise Exception.Create('Illegal blend factor');
  FSelectBlend := Value;
  Invalidate;
end;

procedure TCustomPlanner.SelectCells(SelBegin, SelEnd, SelPos: Integer);
begin
  SelPosition := SelPos;
  SelItemEnd := SelEnd;
  SelItemBegin := SelBegin;
  SelItemEnd := SelEnd;
  SelItemBegin := SelBegin;

  FGrid.FOldSelection := FGrid.Selection;

  if SideBar.ActiveColor <> clNone then
    FGrid.Invalidate;

  if Header.ActiveColor <> clNone then
    FHeader.Invalidate;
end;

function TCustomPlanner.GetSelMinMax(Pos: Integer; var SelMin,
  SelMax: Integer): Boolean;
begin
  Result := False;
  if (PositionProps.Count >= Pos) and (Pos > 0) then
  begin
    if PositionProps[Pos - 1].Use then
    begin
      Result := True;
      SelMin := PositionProps[Pos - 1].MinSelection;
      SelMax := PositionProps[Pos - 1].MaxSelection;
    end;  
  end;
end;

procedure TCustomPlanner.SetShowHint(const Value: Boolean);
begin
  FShowHint := Value;
  FGrid.ShowHint := Value;
end;

procedure TCustomPlanner.UnZoomPosition(Pos: Integer);
var
  x: integer;
begin
  if (Pos >=0) and (Pos < Positions) and
     (PositionWidth > 0) and (PositionZoomWidth > 0) then
  begin
    if PositionAutoSize and (PositionWidth > 0) then
    begin
      x := Items.MaxItemsInPos(Pos);
      PositionWidths[Pos] := Max(x,1) * PositionWidth;
    end
    else
      PositionWidths[Pos] := PositionWidth
  end;
end;

procedure TCustomPlanner.ZoomPosition(Pos: Integer);
begin
  if (Pos >=0) and (Pos < Positions) and
     (PositionWidth > 0) and (PositionZoomWidth > 0) then
  begin
    PositionWidths[Pos] := PositionZoomWidth;
  end;
end;

procedure TCustomPlanner.UpdateNVI;
begin
  FGrid.UpdateNVI;
end;

function TCustomPlanner.GetVersionNr: Integer;
begin
  Result := MakeLong(MakeWord(BLD_VER,REL_VER),MakeWord(MIN_VER,MAJ_VER));
end;

function TCustomPlanner.GetVersion: string;
var
  vn: Integer;
begin
  vn := GetVersionNr;
  Result := IntToStr(Hi(Hiword(vn)))+'.'+IntToStr(Lo(Hiword(vn)))+'.'+IntToStr(Hi(Loword(vn)))+'.'+IntToStr(Lo(Loword(vn)));
end;

procedure TCustomPlanner.SetVersion(const Value: string);
begin
end;

function TCustomPlanner.GetVersionString:string;
var
  vn: Integer;
begin
  vn := GetVersionNr;
  Result := IntToStr(Hi(Hiword(vn)))+'.'+IntToStr(Lo(Hiword(vn)))+'.'+IntToStr(Hi(Loword(vn)))+'.'+IntToStr(Lo(Loword(vn)))+' '+DATE_VER;
end;


function TCustomPlanner.GetCellTime(i, j: Integer): TDateTime;
var
  res,ID,Y: Integer;
  dt: TDateTime;
begin
  Result := 0;

  case Mode.PlannerType of
    plDay:
      begin
        res := (i + Display.DisplayStart) * Display.DisplayUnit + Display.DisplayOffset;
        ID := 0;
        while (res >= 24 * 60) do
        begin
          res := res - 60 * 24;
          inc(ID);
        end;

        Result := EncodeTime(res div 60, res mod 60, 0, 0);
        Result := Result + PosToDay(j) + ID;
      end;
    plTimeLine:
      begin
        CellToAbsTime(i,Result,dt);
      end;
    plMonth,plWeek:
      begin
        Result := Mode.StartOfMonth + i;
      end;
    plDayPeriod:
      begin
        Result := Mode.PeriodStartDate + i;
      end;
    plHalfDayPeriod:
      begin
        Result := Mode.PeriodStartDate + i / 2;
      end;
    plMultiMonth:
      begin
        res := Mode.Month + j;
        Y := Mode.Year;
        while (res > 12) do
        begin
          res := res - 12;
          inc(y);
        end;
        Result := EncodeDate(y,res,i + 1);
      end;
    plCustom, plCustomList:
      begin
        Result := IndexToTime(i);
      end;
  end;
end;

function TCustomPlanner.CellRect(X,Y: Integer): TRect;
begin
{$IFNDEF TMSDOTNET}
  Result := FGrid.CellRect(X,Y);
{$ENDIF}
{$IFDEF TMSDOTNET}
  Result := FGrid.CellRectP(X,Y);
{$ENDIF}
end;

function TCustomPlanner.CellToTime(X, Y: Integer): TDateTime;
begin
  if (X < 0) or (Y < 0) then
    raise Exception.Create('Invalid cell coordinates')
  else
  begin
    if SideBar.Position = spTop then
      Result := GetCellTime(X,Y)
    else
      Result := GetCellTime(Y,X);
  end;     
end;

{ TPlannerGrid }

constructor TPlannerGrid.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  ColCount := 2;
  FixedCols := 1;
  FixedRows := 0;
  RowCount := 49;
  ColWidths[0] := 40;
  GridLineWidth := 0;
  FUpdateCount := 0;
  FSaveCellExtents := False;
  Options := [goRangeSelect];
  Width := 200;
  Height := 250;
  DefaultDrawing := False;

  FEraseBkGnd := False;
  FPlanner := AOwner as TCustomPlanner;

  FMemo := TPlannerMemo.Create(Self);
  FMemo.Parent := Self;
  FMemo.Visible := False;
  FMemo.Width := 0;
  FMemo.Height := 0;
  FMemo.Planner := FPlanner;

  FMaskEdit := TPlannerMaskEdit.Create(Self);
  FMaskEdit.Parent := Self;
  FMaskEdit.Visible := False;
  FMaskEdit.Width := 0;
  FMaskEdit.Height := 0;

  {$IFNDEF TMSDOTNET}
  {$IFNDEF DELPHI_UNICODE}
  FUniMemo := TPlannerUniMemo.Create(Self);
  FUniMemo.Parent := Self;
  FUniMemo.Visible := False;
  FUniMemo.Width := 0;
  FUniMemo.Height := 0;
  FUniMemo.Planner := FPlanner;
  {$ENDIF}
  {$ENDIF}
  

  FMouseDownMove := False;
  FMouseDownSizeUp := False;
  FMouseDownSizeDown := False;
  FMouseDownMoveFirst := False;
  FMouseStart := False;

  FColorList := TPlannerColorArrayList.Create;

  FScrollHintWindow := THintWindow.Create(Self);
  FOldSelection := Selection;

  BorderStyle := bsNone;
  Ctl3D := False;
  FInplaceEdit := TEdit.Create(Self);
  FInplaceEdit.Parent := self;
  FInplaceEdit.Width := 0;
  FInplaceEdit.Height := 0;
  FInplaceEdit.Visible := False;
  FInplaceCombo := TPlanCombobox.Create(Self);
  FInplaceCombo.Parent := self;
  FInplaceCombo.Width := 0;
  FInplaceCombo.Height := 0;
  FInplaceCombo.Visible := False;
  FInplaceCombo.IsWinXP := IsWinXP;
end;

procedure TPlannerGrid.CreateWnd;
begin
  inherited;
  FPlanner.FRichEdit.Parent := Self;
  FPlanner.FRichEdit.Left := 0;
  FPlanner.FRichEdit.Width := 0;
  FPlanner.FRichEdit.Visible := False;
  FPlanner.FRichEdit.BorderStyle := bsNone;
  FPlanner.FRichEdit.OnSelectionChange := FPlanner.SelChange;
end;

destructor TPlannerGrid.Destroy;
begin
  FPlanner.Items.Clear;
  FMemo.Free;
  FMaskEdit.Free;
  FColorList.Free;
  FScrollHintWindow.Free;
  {$IFNDEF TMSDOTNET}
  {$IFNDEF DELPHI_UNICODE}
  FUniMemo.Free;
  {$ENDIF}
  {$ENDIF}
  FInplaceEdit.Free;
  FInplaceCombo.Free;
  inherited Destroy;
end;

procedure TPlannerGrid.SetActiveCellShow(AValue: TActiveCellShow);
begin
  FActiveCellShow := AValue;
  Invalidate;
end;

procedure TPlannerGrid.WMPaint(var Message: TWMPaint);
var
  DC, MemDC: HDC;
  MemBitmap, OldBitmap: HBITMAP;
  PS: TPaintStruct;
begin
  if not FDoubleBuffered or (Message.DC <> 0) then
  begin
    if not (csCustomPaint in ControlState) and (ControlCount = 0) then
      inherited
    else
      PaintHandler(Message);
  end
  else
  begin
    DC := GetDC(0);
    MemBitmap := CreateCompatibleBitmap(DC, ClientRect.Right, ClientRect.Bottom);
    ReleaseDC(0, DC);
    MemDC := CreateCompatibleDC(0);
    OldBitmap := SelectObject(MemDC, MemBitmap);
    try
      DC := BeginPaint(Handle, PS);
      Perform(WM_ERASEBKGND, MemDC, MemDC);
      Message.DC := MemDC;
      WMPaint(Message);
      Message.DC := 0;
      BitBlt(DC, 0, 0, ClientRect.Right, ClientRect.Bottom, MemDC, 0, 0, SRCCOPY);
      EndPaint(Handle, PS);
    finally
      SelectObject(MemDC, OldBitmap);
      DeleteDC(MemDC);
      DeleteObject(MemBitmap);
    end;
  end;
end;

{$IFDEF DELPHI4_LVL}
procedure TPlannerGrid.Resize;
{$ENDIF}
{$IFNDEF DELPHI4_LVL}
procedure TPlannerGrid.WMSize(var WMSize: TWMSize);
{$ENDIF}
begin
  inherited;
  
  if not Assigned(FPlanner) then
    Exit;

  if FPosResizing then
    Exit;

//  FPlanner.FNoPositionSize := True;

  if FPlanner.PositionWidth = 0 then
    UpdatePositions;
    
//  FPlanner.FNoPositionSize := True;

  if FPlanner.Display.ScaleToFit then
    FPlanner.Display.AutoScale;
end;

procedure TPlannerGrid.Loaded;
begin
  inherited Loaded;
end;

procedure TPlannerGrid.HideSelection;
begin
  FHiddenSelection := Selection;
  if HandleAllocated then
    Self.Selection := TGridRect(Rect(ColCount, RowCount, ColCount, RowCount))
  else
    Self.Selection := TGridRect(Rect(-1, -1, -1, -1))
end;

procedure TPlannerGrid.UnHideSelection;
begin
  Selection := FHiddenSelection;
end;

procedure TPlannerGrid.BeginUpdate;
begin
  Perform(WM_SETREDRAW,integer(False),0);
end;

procedure TPlannerGrid.EndUpdate;
begin
  Perform(WM_SETREDRAW,integer(True),0);
  Repaint;
end;

{$IFDEF TMSDOTNET}
procedure TPlannerGrid.InvalidateColP(AValue: Integer);
begin
  inherited InvalidateCol(AValue);
end;

procedure TPlannerGrid.InvalidateRowP(AValue: Integer);
begin
  inherited InvalidateRow(AValue);
end;

function TPlannerGrid.CellRectP(X,Y: Integer): TRect;
begin
  Result := inherited CellRect(X,Y);
end;

procedure TPlannerGrid.InvalidateCellP(X,Y: Integer);
begin
  inherited InvalidateCell(X,Y);
end;
{$ENDIF}


procedure TPlannerGrid.RTFPaint(ACanvas: TCanvas; ARect: TRect; const rtf: string; Background: TColor);
const
  RTF_OFFSET = 2;
  TWIPS_FACTOR = 1440;

type
  TFormatRange = record
    hdcSrc: hdc;
    hdcTarget: hdc;
    rc: TRect;
    rcPage: TRect;
    chrg: TCharRange;
  end;
var
  FormatRange: TFormatRange;
  nLogPixelsX, nLogPixelsY: Integer;
  SaveMapMode: Integer;
  SaveText: string;
  SaveSelStart, SaveSelLength: Integer;
  {$IFDEF TMSDOTNET}
  ap: array of TPoint;
  {$ENDIF}
begin
  SaveText := FPlanner.RichToText;
  SaveSelStart := FPlanner.RichEdit.SelStart;
  SaveSelLength := FPlanner.RichEdit.SelLength;
  try
    FPlanner.TextToRich(rtf);

    SendMessage(FPlanner.RichEdit.Handle, EM_SETBKGNDCOLOR, 0, ColorToRGb(Background));

    {$IFNDEF TMSDOTNET}
    FillChar(FormatRange, SizeOf(TFormatRange), 0);
    {$ENDIF}

    {$IFDEF TMSDOTNET}
    SetLength(ap, 2);
    ap[0] := ARect.TopLeft;
    ap[1] := ARect.BottomRight;
    lptodp(Canvas.Handle,ap,2);
    ARect.TopLeft := ap[0];
    ARect.BottomRight := ap[1];
    {$ENDIF}

    {$IFNDEF TMSDOTNET}
    lptodp(Canvas.Handle,ARect.Topleft,1);
    lptodp(Canvas.Handle,ARect.Bottomright,1);
    {$ENDIF}

    nLogPixelsX := GetDeviceCaps(ACanvas.Handle, LOGPIXELSX);
    nLogPixelsY := GetDeviceCaps(ACanvas.Handle, LOGPIXELSY);

    with FormatRange do
    begin
      FormatRange.hdcSrc := ACanvas.Handle;
      FormatRange.hdcTarget := ACanvas.Handle;
      {convert to twips}{ 1440 TWIPS = 1 inch. }
      FormatRange.rcPage.Left := Round(((ARect.Left + RTF_OFFSET) / nLogPixelsX) * TWIPS_FACTOR);
      FormatRange.rcPage.Top := Round(((ARect.Top + RTF_OFFSET) / nLogPixelsY) * TWIPS_FACTOR);
      FormatRange.rcPage.Right := FormatRange.rcPage.Left +
        Round(((ARect.Right - ARect.Left - RTF_OFFSET) / nLogPixelsX) * TWIPS_FACTOR);
      FormatRange.rcPage.Bottom := (FormatRange.rcPage.Top +
        Round(((ARect.Bottom - ARect.Top - RTF_OFFSET) / nLogPixelsY) * TWIPS_FACTOR));
      FormatRange.rc := FormatRange.rcPage;
      FormatRange.chrg.cpMin := 0;
      FormatRange.chrg.cpMax := -1;
    end;

    SaveMapMode := GetMapMode(ACanvas.Handle);
    try
      SetMapMode(Canvas.Handle, mm_text);
      {$IFNDEF TMSDOTNET}
      SendMessage(FPlanner.FRichEdit.Handle, EM_FORMATRANGE, 1, LongInt(@FormatRange));
      {clear the richtext cache}
      SendMessage(FPlanner.FRichEdit.Handle, EM_FORMATRANGE, 0, 0);
      {$ENDIF}

      {$IFDEF TMSDOTNET}
      Perform(EM_FORMATRANGE,1,FormatRange);
      Perform(EM_FORMATRANGE,0,0);
      {$ENDIF}
    finally
      SetMapMode(ACanvas.Handle, SaveMapMode);
    end;

  finally
    FPlanner.TextToRich(SaveText);
    FPlanner.RichEdit.SelStart := SaveSelStart;
    FPlanner.RichEdit.SelLength := SaveSelLength;
  end;
end;

(*
PROCEDURE PrintBitmap(Canvas:  TCanvas; DestRect:  TRect;  Bitmap:  TBitmap);
  VAR
    BitmapHeader:  pBitmapInfo;
    BitmapImage:  POINTER;
    HeaderSize :  DWORD;
    ImageSize  :  DWORD;
BEGIN
  GetDIBSizes(Bitmap.Handle, HeaderSize, ImageSize);
  GetMem(BitmapHeader, HeaderSize);
  GetMem(BitmapImage,  ImageSize);
  TRY
    GetDIB(Bitmap.Handle, Bitmap.Palette, BitmapHeader^, BitmapImage^);
    StretchDIBits(Canvas.Handle,
                  DestRect.Left, DestRect.Top,     // Destination Origin
                  DestRect.Right  - DestRect.Left, // Destination Width
                  DestRect.Bottom - DestRect.Top,  // Destination Height
                  0, 0,                            // Source Origin
                  Bitmap.Width, Bitmap.Height,     // Source Width & Height
                  BitmapImage,
                  TBitmapInfo(BitmapHeader^),
                  DIB_RGB_COLORS,
                  SRCCOPY)
  FINALLY
    FreeMem(BitmapHeader);
    FreeMem(BitmapImage)
  END
END {PrintBitmap};
*)

const
  DefaultPixelsPerInch = 96;


function TrackBarWidth(TrackBarLogicalPixels:Integer; Canvas: TCanvas): Integer;
begin
  Result := Round(
    TrackBarLogicalPixels * GetDeviceCaps(Canvas.Handle, LOGPIXELSX) / DefaultPixelsPerInch);
end;

function TrackBarHeight(TrackBarLogicalPixels:Integer; Canvas: TCanvas): Integer;
begin
  Result := Round(
    TrackBarLogicalPixels * GetDeviceCaps(Canvas.Handle, LOGPIXELSY) / DefaultPixelsPerInch);
end;

function ConcatenateTextStrings(Text: TStrings): string;
var
  Index: Integer;
begin
  Result := '';
  for Index := 0 to Text.Count - 1 do
    Result := Result + Text.Strings[Index];
end;

procedure TPlannerGrid.CreateToolTip;
begin
  fhToolTip := CreateWindowEx(0, 'Tooltips_Class32', nil, TTS_ALWAYSTIP or TTS_BALLOON or TTS_NOPREFIX,
    Integer(CW_USEDEFAULT), Integer(CW_USEDEFAULT),Integer(CW_USEDEFAULT),
    Integer(CW_USEDEFAULT), Handle, 0, hInstance, nil);

  if fhToolTip <> 0 then
    SetWindowPos(fhToolTip, HWND_TOPMOST, 0, 0, 0, 0, SWP_NOMOVE or SWP_NOSIZE or SWP_NOACTIVATE);
end;

procedure TPlannerGrid.DestroyToolTip;
begin
  DestroyWindow(fhToolTip);
end;


procedure TPlannerGrid.AddToolTip(IconType: Integer; Text, Title: string);
{$IFDEF TMSDOTNET}
type
  [StructLayout(LayoutKind.Sequential, CharSet = CharSet.Unicode)]
  TTOOLINFOEX = packed record
    cbSize: UINT;
    uFlags: UINT;
    hwnd: HWND;
    uId: UINT;
    Rect: TRect;
    hInst: THandle;
    lpszText: IntPtr;
    lParam: LPARAM;
  end;
{$ENDIF}
var
  Item: THandle;
  Rect: TRect;
  {$IFDEF TMSDOTNET}
  ti: TToolInfoEx;
  {$ENDIF}
  {$IFNDEF TMSDOTNET}
  ti: TToolInfo;
  {$ENDIF}
  buffer: array[0..255] of char;
  {$IFDEF TMSDOTNET}
  Mem: IntPtr;
  {$ENDIF}
begin
  Item := self.Handle;

  if (Item <> 0) AND (Windows.GetClientRect(Item, Rect)) then
  begin
    {$IFNDEF TMSDOTNET}
    ti.cbSize := SizeOf(TToolInfo);
    {$ENDIF}

    {$IFDEF TMSDOTNET}
    ti.cbSize := Marshal.SizeOf(TypeOf(TToolInfo));
    {$ENDIF}

    ti.uFlags := TTF_SUBCLASS or TTF_IDISHWND ;
    ti.hInst := hInstance;

    ti.hwnd := Item;
    ti.Rect := Rect;
    ti.uId := Handle;

    {$IFDEF TMSDOTNET}

    ti.lpszText := IntPtr(LPSTR_TEXTCALLBACK);

    try
      Mem := Marshal.AllocHGlobal(Marshal.SizeOf(TypeOf(ti)));
      Marshal.StructureToPtr(TObject(ti),Mem,False);
      SendMessage(fhToolTip, TTM_ADDTOOL, 0, Longint(mem));
    finally
      Marshal.FreeHGlobal(Mem);
    end;
    if (IconType > 3) or (IconType < 0) then IconType := 0;
    SendTextMessage(fhToolTip, TTM_SETTITLE, IconType, Title);

    {$ENDIF}

    {$IFNDEF TMSDOTNET}
    ti.lpszText :=  LPSTR_TEXTCALLBACK;
    SendMessage(fhToolTip, TTM_ADDTOOL, 0, Integer(@ti));
    FillChar(buffer, sizeof(buffer), #0);
    lstrcpy(buffer, PChar(Title));
    if (IconType > 3) or (IconType < 0) then IconType := 0;
    SendMessage(fhToolTip, TTM_SETTITLE, IconType, Integer(@buffer));
    {$ENDIF}
  end;
end;

function TPlannerGrid.MouseOverDesignChoice(X, Y: Integer): Integer;
var
  r: TRect;
  fh: Integer;
begin
  Result := -1;
  r := ClientRect;
  Canvas.Font.Name := 'Tahoma';
  Canvas.Font.Size := 8;

  fh := Canvas.TextHeight('gh') + 2;
  if (x > r.Right - 150) and (x < r.Right - 150 + Canvas.TextWidth(s_HTimeAxis)) and
    (y > r.Bottom - 70 + fh + 4) and
    (y < r.Bottom - 70 + 2 * fh + 4) then
    Result := 1;

  if (x > r.Right - 150) and (x < r.Right - 150 + Canvas.TextWidth(s_ShowDesignItem)) and
    (y > r.Bottom - 70 + 2 * fh + 4) and
    (y < r.Bottom - 70 + 3 * fh + 4) then
    Result := 2;

  if (x > r.Right - 150) and (x < r.Right - 150 + Canvas.TextWidth(s_Modes[0])) and
    (y > r.Bottom - 70 + 3 * fh + 4) and
    (y < r.Bottom - 70 + 4 * fh + 4) then
    Result := 3;
end;

procedure TPlannerGrid.PaintItemCol(Canvas: TCanvas; ARect: TRect; APlannerItem:
  TPlannerItem; Print, SelColor: Boolean);
var
  PaintString, Anchor, StrippedHTMLString, CaptionPaintString, FocusAnchor: string;
  WideCaptionPaintString: widestring;
  r, ro, hr, cr, sr: TRect;
  ColumnHeight, i, iw, ih, pw, ph, ImageIndex, ml, hl: Integer;
  MultiImage: Boolean;
  HorizontalAlign, DrawFlags: DWORD;
  rr, dr, XSize, YSize: Integer;
  PlannerImagePoint: TPoint;
  Bitmap: TBitmap;
  Background: TColor;
  BackgroundTo: TColor;
  pt: TPoint;
  tmpBegin, tmpEnd: integer;
  CellColor, OldColor: TColor;
  CID,CV,CT: string;
  HRGN: THandle;
  gs: TGaugeSettings;
  ch: Integer;

label
  BackGroundOnly;
begin
  if APlannerItem.Repainted then
    Exit;


  if (APlannerItem.ItemBegin = APlannerItem.ItemEnd) and not APlannerItem.InHeader then
    Exit;

  CellColor := Canvas.Brush.Color;

  if not (csDesigning in FPlanner.ComponentState) and not Print then
    APlannerItem.Repainted := True;

  if not APlannerItem.Background and not APlannerItem.InHeader then
    ARect.Right := ARect.Right - FPlanner.FItemGap;

  if Assigned(APlannerItem.FPlanner.OnPlannerItemDraw) then
  begin
    try
      APlannerItem.FPlanner.OnPlannerItemDraw(APlannerItem.FPlanner, APlannerItem,
        Canvas, ARect, False);
      Exit;
    except
      on e: EAbort do {nothing};
    end;
  end;

  if (APlannerItem.Shape = psTool) and Assigned(APlannerItem.DrawTool) then
  begin
    APlannerItem.DrawTool.DrawItem(APlannerItem,Canvas,ARect,APlannerItem.Selected,Print);
    Exit;
  end;

  if APlannerItem.Shadow and not APlannerItem.Background and (APlannerItem.Shape = psRect)
    and not FPlanner.TrackOnly  then
  begin
    Canvas.Brush.Color := FPlanner.ShadowColor;
    Canvas.Pen.Color := Canvas.Brush.Color;
    Canvas.Rectangle(ARect.Right - 3,ARect.Top + 3,ARect.Right,ARect.Bottom);
    Canvas.Rectangle(ARect.Left + 3,ARect.Bottom - 3,ARect.Right,ARect.Bottom);
    Canvas.Brush.Color := CellColor;
    Canvas.Pen.Color := CellColor;
    Canvas.Rectangle(ARect.Right - 3,ARect.Top ,ARect.Right,ARect.Top + 3);
    Canvas.Rectangle(ARect.Left ,ARect.Bottom - 4,ARect.Left + 3,ARect.Bottom -1);

    ARect.Right := ARect.Right - 3;
    ARect.Bottom := ARect.Bottom - 3;
  end;

  if APlannerItem.Background then
    ARect.Bottom := ARect.Bottom - 1;

  ro := ARect;
  r := ARect;

  APlannerItem.FClipped := False;

  Background := APlannerItem.Color;
  BackgroundTo := APlannerItem.ColorTo;

  if APlannerItem.Selected and
     APlannerItem.ShowSelection {and
     not APlannerItem.InHeader} then
  begin
    Background := APlannerItem.SelectColor;
    BackgroundTo := APlannerItem.SelectColorTo;
  end;

  if (APlannerItem.Background) then
  begin
    if APlannerItem.BrushStyle <> bsSolid then
    begin
      Canvas.Brush.Color := Background;
      Canvas.Brush.Style := APlannerItem.BrushStyle;
      SetBkMode(Canvas.Handle, TRANSPARENT);
      SetBkColor(Canvas.Handle, ColorToRGb(FPlanner.Color));
    end;

    goto BackGroundOnly;
  end;

  // Draw the item trackbar
  r.Right := r.Left + TrackBarWidth(APlannerItem.FPlanner.TrackWidth,Canvas);

  if {not APlannerItem.InHeader and}
     APlannerItem.TrackVisible and
     (APlannerItem.Shape = psRect) then
  begin
    if (FPlanner.TrackProportional) then
    begin
      Canvas.Brush.Color := FPlanner.Display.ColorActive;
      Canvas.FillRect(r);

      dr := APlannerItem.FItemBeginPrecis - (APlannerItem.FItemBegin +
        FPlanner.Display.DisplayStart) * FPlanner.Display.DisplayUnit - FPlanner.Display.DisplayOffset;

      dr := Round(dr / FPlanner.Display.DisplayUnit * FPlanner.Display.DisplayScale);

      rr := Round( (APlannerItem.FItemEndPrecis - APlannerItem.FItemBeginPrecis + FPlanner.Display.DisplayOffset) / FPlanner.Display.DisplayUnit * FPlanner.Display.DisplayScale);
      rr := dr + rr;

//      rr := Round((APlannerItem.FItemEndPrecis - APlannerItem.FItemBeginPrecis) /
//        FPlanner.Display.DisplayUnit * FPlanner.Display.DisplayScale) + FPlanner.Display.DisplayOffset;
    end
    else
    begin
      dr := 0;
      rr := r.Bottom - r.Top;
    end;

    r.Bottom := r.Top + rr;    
    r.Top := r.Top + dr;


    if APlannerItem.Focus then
      Canvas.Brush.Color := APlannerItem.TrackSelectColor
    else
      Canvas.Brush.Color := APlannerItem.TrackColor;

    if APlannerItem.LinkSelect then
      Canvas.Brush.Color := APlannerItem.TrackLinkColor;

    Canvas.FillRect(r);

    if FPlanner.TrackBump then
      DrawBumpVert(Canvas,r,Canvas.Brush.Color);

    ARect.Left := ARect.Left + TrackBarWidth(APlannerItem.FPlanner.TrackWidth,Canvas);

    for i := 0 to APlannerItem.BarItems.Count - 1 do
    begin
      with APlannerItem.BarItems[i] do
      begin
        tmpBegin := BarBegin;
        tmpEnd := BarEnd;
        if BarBegin = -1 then
          tmpBegin := 0;
        if BarEnd = -1 then
          tmpEnd := APlannerItem.ItemEnd - APlannerItem.ItemBegin;

        rr := (r.Bottom - r.Top) div (APlannerItem.ItemEnd - APlannerItem.ItemBegin);
        sr.Top := r.Top + (tmpBegin * rr);
        sr.Bottom := r.Top + (tmpEnd * rr);
        sr.Left := r.Left ;
        sr.Right :=  Arect.Left;
        Canvas.Brush.Color := BarColor;
        Canvas.Pen.Color := APlannerItem.TrackColor;
        Canvas.Brush.Style := BarStyle;
        Canvas.Rectangle(sr.Left,sr.Top,sr.Right,sr.Bottom);
       end;
    end;
  end;

  if FPlanner.TrackOnly then
    Exit;

  if APlannerItem.FIsCurrent and not Print then
  begin
    Background := FPlanner.FDisplay.FColorCurrentItem;
    Canvas.Brush.Color := Background;
  end
  else
  begin
    if APlannerItem.BrushStyle <> bsSolid then
    begin
      Background := APlannerItem.Color;

      Canvas.Brush.Color := Background;
      Canvas.Brush.Style := APlannerItem.BrushStyle;

      SetBkMode(Canvas.Handle, TRANSPARENT);
      SetBkColor(Canvas.Handle, ColorToRGb(FPlanner.Color));
    end
    else
      Canvas.Brush.Color := Background;
  end;

  if APlannerItem.Flashing and APlannerItem.FlashOn then
    Canvas.Brush.Color := FPlanner.FlashColor;

  case APlannerItem.Shape of
  psRect:
    begin
      if BackgroundTo <> clNone then
        DrawGradient(Canvas,Canvas.Brush.Color,BackgroundTo,64,ARect,false)
      else
        Canvas.FillRect(ARect);

      Canvas.Pen.Color := APlannerItem.BorderColor;

      Canvas.Brush.Style := bsClear;
      Canvas.Polygon([Point(ARect.Left, ARect.Top),
                      Point(ARect.Right - 1, ARect.Top),
                      Point(ARect.Right - 1, ARect.Bottom - 1),
                      Point(ARect.Left, ARect.Bottom - 1)]);
    end;
  psRounded:
    begin
      //ARect.Right := ARect.Right - 1;
      //ARect.Bottom := ARect.Bottom - 1;
      ARect.Top := ARect.Top + 1;


      if APlannerItem.Shadow then
      begin
        ARect.Right := ARect.Right - 1;
        ARect.Bottom := ARect.Bottom - 1;

        Canvas.Pen.Color := FPlanner.ShadowColor;
        Canvas.Pen.Width := 2;
        OldColor := Canvas.Brush.Color;
        Canvas.Brush.Color := FPlanner.ShadowColor;
        Canvas.RoundRect(ARect.Left + 2,ARect.Top + 2,ARect.Right + 2,ARect.Bottom + 2,CORNER_EFFECT,CORNER_EFFECT);
        Canvas.Brush.Color := OldColor;
      end;

      if APlannerItem.TrackVisible and APlannerItem.FFocus then
      begin
        ARect.Left := ARect.Left + 1;
        Canvas.Pen.Color := APlannerItem.TrackSelectColor;
        Canvas.Pen.Width := 2;
      end
      else
      begin
        Canvas.Pen.Color := APlannerItem.BorderColor;
        Canvas.Pen.Width := 1;
      end;

      if APlannerItem.BrushStyle <> bsSolid then
      begin
        SetBkMode(Canvas.Handle, TRANSPARENT);
        SetBkColor(Canvas.Handle, ColorToRGb(FPlanner.Color));
        InflateRect(ARect,-(CORNER_EFFECT shr 2),-(CORNER_EFFECT shr 2));
        Canvas.FillRect(ARect);
        InflateRect(ARect,+(CORNER_EFFECT shr 2),+(CORNER_EFFECT shr 2));
      end;

      Canvas.RoundRect(ARect.Left,ARect.Top,ARect.Right,ARect.Bottom,CORNER_EFFECT,CORNER_EFFECT);
      InflateRect(ARect,-(CORNER_EFFECT shr 2),-(CORNER_EFFECT shr 2));

    end;
  {$IFDEF TMSSKINS}
  psSkin:
    begin
      if APlannerItem.Selected then
      begin
        BitmapStretch(FPlanner.Skin.SkinSelectTop,Canvas,ARect.Left , ARect.Top, ARect.Right - ARect.Left);

        BitmapStretch(FPlanner.Skin.SkinSelectBottom,Canvas,ARect.Left , ARect.Bottom - FPlanner.Skin.SkinBottom.Height, ARect.Right - ARect.Left);

        BitmapStretchHeight(FPlanner.Skin.SkinSelectCenter,Canvas,ARect.Left , ARect.Top + FPlanner.Skin.SkinTop.Height - 1 ,ARect.Bottom - ARect.Top - FPlanner.Skin.SkinBottom.Height - FPlanner.Skin.SkinTop.Height + 1, ARect.Right - ARect.Left);
      end
      else
      begin
        BitmapStretch(FPlanner.Skin.SkinTop,Canvas,ARect.Left , ARect.Top, ARect.Right - ARect.Left);

        BitmapStretch(FPlanner.Skin.SkinBottom,Canvas,ARect.Left , ARect.Bottom - FPlanner.Skin.SkinBottom.Height, ARect.Right - ARect.Left);

        BitmapStretchHeight(FPlanner.Skin.SkinCenter,Canvas,ARect.Left , ARect.Top + FPlanner.Skin.SkinTop.Height - 1 ,ARect.Bottom - ARect.Top - FPlanner.Skin.SkinBottom.Height - FPlanner.Skin.SkinTop.Height + 1, ARect.Right - ARect.Left);
      end;

    end;
  {$ENDIF}

  psHexagon:
    begin
      InflateRect(ARect,-1,-1);

      if APlannerItem.Shadow then
      begin
        InflateRect(ARect,-2,-2);
        Canvas.Pen.Color := FPlanner.ShadowColor;
        Canvas.Pen.Width := 2;
        OldColor := Canvas.Brush.Color;
        Canvas.Brush.Color := FPlanner.ShadowColor;



        Canvas.Polygon([Point(2 + ARect.Left + CORNER_EFFECT, 2 + ARect.Top),
                        Point(2 + ARect.Right - 1 - CORNER_EFFECT, 2 + ARect.Top),
                        Point(2 + ARect.Right - 1, 2 + ARect.Top +((Arect.Bottom - ARect.Top) shr 1)),
                        Point(2 + ARect.Right - 1 - CORNER_EFFECT, 2 + ARect.Bottom - 2),
                        Point(2 + ARect.Left + CORNER_EFFECT, 2 + ARect.Bottom - 2),
                        Point(2 + ARect.Left, 2 + ARect.Top +((Arect.Bottom - ARect.Top) shr 1))]);

        Canvas.Brush.Color := OldColor;
      end;

      if APlannerItem.TrackVisible and APlannerItem.FFocus then
      begin
        Canvas.Pen.Color := APlannerItem.TrackSelectColor;
        Canvas.Pen.Width := 2;
      end
      else
      begin
        Canvas.Pen.Color := APlannerItem.BorderColor;
        Canvas.Pen.Width := 1;
      end;


      Canvas.Polygon([Point(ARect.Left + CORNER_EFFECT, ARect.Top),
                      Point(ARect.Right - 1 - CORNER_EFFECT, ARect.Top),
                      Point(ARect.Right - 1, ARect.Top +((Arect.Bottom - ARect.Top) shr 1)),
                      Point(ARect.Right - 1 - CORNER_EFFECT, ARect.Bottom - 2),
                      Point(ARect.Left + CORNER_EFFECT, ARect.Bottom - 2),
                      Point(ARect.Left, ARect.Top +((Arect.Bottom - ARect.Top) shr 1))]);
      InflateRect(ARect,-CORNER_EFFECT,0);
    end;
  end;

  Canvas.Brush.Style := bsSolid;

  if APlannerItem.FFocus and
     not Print and
     APlannerItem.FTrackVisible and
     (APlannerItem.Shape = psRect) and
     not APlannerItem.InHeader then
  begin
    Canvas.Brush.Color := APlannerItem.TrackSelectColor;
    r := ARect;
    r.Bottom := r.Top + 3;
    Canvas.FillRect(r);
    r := ARect;
    r.Top := ARect.Bottom - 4;
    r.Bottom := ARect.Bottom;
    Canvas.FillRect(r);
  end;

  BackGroundOnly:

  if APlannerItem.FIsCurrent and not Print then
    Canvas.Brush.Color := FPlanner.FDisplay.FColorCurrentItem
  else
    Canvas.Brush.Color := APlannerItem.Color;

  InflateRect(ARect, -2, -4);

  {$IFDEF TMSSKINS}
  if APlannerItem.Shape = psSkin then
    InflateRect(ARect, -FPlanner.Skin.SkinX, -FPlanner.Skin.SkinY);
  {$ENDIF}  

  if APlannerItem.Background then
  begin
    if APlannerItem.Transparent and SelColor then
    begin
      Canvas.Brush.Color := BlendColor(CellColor,APlannerItem.Color,FPlanner.SelectBlend);
    end;

    if not (Print and APlannerItem.Transparent) then
    begin
      Canvas.FillRect(r);
      Canvas.Pen.Color := APlannerItem.FPlanner.GridLineColor;
      Canvas.Moveto(r.Left,r.Bottom);
      Canvas.Lineto(r.Right - 1,r.Bottom);
    end;
  end;

  ch := 0;
  ih := 0;
  iw := 0;
  ColumnHeight := 0;
  MultiImage := False;

  if (APlannerItem.FBeginOffset <> 0) or (APlannerItem.FEndOffset <> 0) then
    ARect.Right := ARect.Right - 8;

  PlannerImagePoint := Point(0,0);

  if Assigned(APlannerItem.FPlanner.PlannerImages) and
    ((APlannerItem.ImageID >= 0) or (APlannerItem.ImageIndexList.Count > 0)) then
  begin
    PlannerImagePoint.X := Round((APlannerItem.FPlanner.PlannerImages.Width + 2) *
      GetDeviceCaps(Canvas.Handle, LOGPIXELSX) / 96);
    PlannerImagePoint.Y := Round((APlannerItem.FPlanner.PlannerImages.Height + 2) *
      GetDeviceCaps(Canvas.Handle, LOGPIXELSY) / 96);


    ih := PlannerImagePoint.Y;
  end;

  if APlannerItem.CaptionType in [ctTime, ctText, ctTimeText] then
  begin
    Canvas.Font.Assign(APlannerItem.CaptionFont);

    if APlannerItem.Selected and
      APlannerItem.ShowSelection then
      Canvas.Font.Color := APlannerItem.SelectFontColor;

    ColumnHeight := Canvas.TextHeight('gh');

    if APlannerItem.Flashing and APlannerItem.FlashOn and APlannerItem.UniformBkg then
      Canvas.Font.Color := FPlanner.FlashFontColor;

    ih := Max(ih, ColumnHeight);

    ch := ih;

    {$IFDEF TMSSKINS}
    if APlannerItem.Shape <> psSkin then
    begin
    {$ENDIF}

      // Draw line under Caption
      if ARect.Top + ih + 1 < ARect.Bottom then
      begin
        if (APlannerItem.ImagePosition = ipVertical) and Assigned(APlannerItem.FPlanner.PlannerImages) and
           (APlannerItem.ImageIndexList.Count > 0) then
          Canvas.MoveTo(ARect.Left + APlannerItem.FPlanner.PlannerImages.Width, ARect.Top + ih + 1)
        else
          Canvas.MoveTo(ARect.Left, ARect.Top + ih + 1);

        Canvas.LineTo(ARect.Right, ARect.Top + ih + 1);
      end;
    {$IFDEF TMSSKINS}
    end;
    {$ENDIF}

    ih := Min(ARect.Bottom - ARect.Top - 1, ih);

    if not APlannerItem.UniformBkg then
    begin
      Canvas.Brush.Color := APlannerItem.CaptionBkg;
      Canvas.Pen.Color := APlannerItem.CaptionBkg;
    end
    else
    begin
      if APlannerItem.Flashing and APlannerItem.FlashOn then
        Canvas.Brush.Color := FPlanner.FlashColor
      else
        Canvas.Brush.Color := Background;
    end;

    r := ARect;

    r.Left := ARect.Left + iw;
    r.Bottom := r.Top + ih;
    Inflaterect(r,1,1);
    if not APlannerItem.Focus then
      r.Top := r.Top - 2;

    {$IFDEF TMSSKINS}
    if APlannerItem.Shape <> psSkin then
    begin
    {$ENDIF}
      if APlannerItem.CaptionBkgTo <> clNone then
        DrawGradient(Canvas,APlannerItem.CaptionBkg,APlannerItem.CaptionBkgTo,FPlanner.GradientSteps,r,not FPlanner.GradientHorizontal)
      else
        Canvas.FillRect(r);
    {$IFDEF TMSSKINS}
    end;
    {$ENDIF}

  end;

  ih := 0;

  if Assigned(APlannerItem.FPlanner.PlannerImages) then
  begin
    if (APlannerItem.ImageID >= 0) then
    begin
      if ARect.Left + APlannerItem.FPlanner.PlannerImages.Width < ARect.Right then
      begin
        iw := PlannerImagePoint.X;
        ih := PlannerImagePoint.Y;
        if Print then
        begin
          Bitmap := TBitmap.Create;
          APlannerItem.FPlanner.PlannerImages.GetBitmap(APlannerItem.ImageID, Bitmap);
          PrintBitmap(Canvas, Rect(ARect.Left, ARect.Top, ARect.Left + iw,
            ARect.Top + ih), Bitmap);
          Bitmap.Free;
        end
        else
          APlannerItem.FPlanner.PlannerImages.Draw(Canvas, ARect.Left + APlannerItem.FPlanner.ImageOffsetX, ARect.Top + APlannerItem.FPlanner.ImageOffsetY,
            APlannerItem.ImageID);
      end;
    end;

    for ImageIndex := 0 to APlannerItem.FImageIndexList.Count - 1 do
    begin
      if APlannerItem.ImagePosition = ipHorizontal then
      begin
        if ARect.Left + iw + APlannerItem.FPlanner.PlannerImages.Width < ARect.Right then
        begin
          if Print then
          begin
            Bitmap := TBitmap.Create;
            try
              APlannerItem.FPlanner.PlannerImages.GetBitmap(
                APlannerItem.FImageIndexList.Items[ImageIndex], Bitmap);
              PrintBitmap(Canvas, Rect(ARect.Left + iw, ARect.Top,
                ARect.Left + iw + PlannerImagePoint.X, ARect.Top + PlannerImagePoint.Y), Bitmap);
            finally
              Bitmap.Free;
            end;
          end
          else
            APlannerItem.FPlanner.PlannerImages.Draw(Canvas, ARect.Left + iw, ARect.Top,
              APlannerItem.FImageIndexList.Items[ImageIndex]);

          iw := iw + PlannerImagePoint.X;
          ih := PlannerImagePoint.Y;
        end;
      end
      else
      begin
        if ARect.Top + ih + APlannerItem.FPlanner.PlannerImages.Height < ARect.Bottom + 4 then
        begin
          if Print then
          begin
            Bitmap := TBitmap.Create;
            try
              APlannerItem.FPlanner.PlannerImages.GetBitmap(
                APlannerItem.FImageIndexList.Items[ImageIndex], Bitmap);
              PrintBitmap(Canvas, Rect(ARect.Left, ARect.Top + ih,
                ARect.Left + PlannerImagePoint.X, ARect.Top + PlannerImagePoint.Y+ ih), Bitmap);
            finally
              Bitmap.Free;
            end;
          end
          else
            APlannerItem.FPlanner.PlannerImages.Draw(Canvas, ARect.Left , ARect.Top + ih,
              APlannerItem.FImageIndexList.Items[ImageIndex]);

          ih := ih + PlannerImagePoint.Y;
          iw := PlannerImagePoint.X;
        end;
      end;
      MultiImage := True;
    end;

    if (APlannerItem.ImagePosition = ipHorizontal) and (APlannerItem.FImageIndexList.Count > 0)
      and (APlannerItem.CaptionType = ctNone) then
      ARect.Top := ARect.Top + ih;
  end;



  //if APlannerItem.ImagePosition = ipVertical then
  ih := Max(ch, ColumnHeight);

  if APlannerItem.CaptionType in [ctTime, ctText, ctTimeText] then
  begin
    r := ARect;
    r.Bottom := r.Top + ih;
    r.Left := ARect.Left + iw;

    {$IFDEF TMSSKINS}
    if APlannerItem.Shape = psSkin then
    begin
      r.Top := r.Top + FPlanner.Skin.SkinCaptionY;
      r.Left := r.Left + FPlanner.Skin.SkinCaptionX;
    end;
    {$ENDIF}

    //ih := ih + 2;

    if (APlannerItem.URL <> '') and (r.Right - r.Left > 32) then
      r.Right := r.Right - APlannerItem.FPlanner.URLGlyph.Width;

    if (APlannerItem.Attachement <> '')  and (r.Right - r.Left > 32) then
      r.Right := r.Right - APlannerItem.FPlanner.AttachementGlyph.Width;

    if (APlannerItem.ShowDeleteButton) and (r.Right - r.Left > 32) then
      r.Right := r.Right - APlannerItem.FPlanner.DeleteGlyph.Width;

    if (APlannerItem.URL <> '') or (APlannerItem.Attachement <> '') or (APlannerItem.ShowDeleteButton) then
      r.Right := r.Right - 2;

    CaptionPaintString := APlannerItem.GetCaptionString;

    HorizontalAlign := AlignToFlag(APlannerItem.CaptionAlign);
    SetBkMode(Canvas.Handle, TRANSPARENT);

    {$IFNDEF TMSDOTNET}
    if APlannerItem.Unicode then
    begin
      WideCaptionPaintString := APlannerItem.GetWideCaptionString;
      DrawFlags := DT_NOPREFIX or DT_END_ELLIPSIS or HorizontalAlign;
      DrawTextExW(Canvas.Handle, PWideChar(WideCaptionPaintString), Length(WideCaptionPaintString), r, DrawFlags, nil);
    end
    else
    {$ENDIF}
    begin
      if IsHtml(APlannerItem,CaptionPaintString,true) then
        HTMLDrawEx(Canvas, CaptionPaintString, r, FPlanner.PlannerImages, 0, 0, -1, -1, 1, False, False,
          Print, False, True, False, False
          ,False
          , FPlanner.FHTMLFactor, FPlanner.URLColor, clNone, clNone, clGray, Anchor, StrippedHtmlString, FocusAnchor, XSize, YSize, ml, hl, hr
          , cr, CID, CV, CT,FPlanner.FImageCache, FPlanner.FContainer, Handle
          )
      else
      begin
        DrawFlags := DT_NOPREFIX or DT_END_ELLIPSIS or HorizontalAlign;
        {$IFDEF DELPHI4_LVL}
        DrawFlags := FPlanner.DrawTextBiDiModeFlags(DrawFlags);
        {$ENDIF}

        {$IFNDEF TMSDOTNET}
        DrawText(Canvas.Handle, PChar(CaptionPaintString), Length(CaptionPaintString), r, DrawFlags);
        {$ENDIF}
        {$IFDEF TMSDOTNET}
        DrawText(Canvas.Handle, CaptionPaintString, Length(CaptionPaintString), r, DrawFlags);
        {$ENDIF}


      end;

    end;  

    r.Right := ARect.Right;
    r.Top := r.Top - 2;

    if (APlannerItem.ShowDeleteButton) and (r.Right - r.Left > 32) then
    begin
      APlannerItem.FPlanner.DeleteGlyph.TransparentColor := APlannerItem.FPlanner.DeleteGlyph.Canvas.Pixels[0,0];
      APlannerItem.FPlanner.DeleteGlyph.Transparent := True;

      if Print then
      begin
        pw := Round(16 * GetDeviceCaps(Canvas.Handle, LOGPIXELSX) / 96);
        ph := Round(16 * GetDeviceCaps(Canvas.Handle, LOGPIXELSY) / 96);
        PrintBitmap(Canvas, Rect(r.Right - pw, r.Top, r.Right, r.Top + ph), APlannerItem.FPlanner.DeleteGlyph);
        r.Right := r.Right - pw;
      end
      else
      begin
        Canvas.Draw(r.Right - APlannerItem.FPlanner.DeleteGlyph.Width,r.Top,APlannerItem.FPlanner.DeleteGlyph);
        r.Right := r.Right - APlannerItem.FPlanner.DeleteGlyph.Width;
      end;
    end;

    if (APlannerItem.Attachement <> '') and (r.Right - r.Left > 32) then
    begin
      APlannerItem.FPlanner.AttachementGlyph.TransparentColor := APlannerItem.FPlanner.AttachementGlyph.Canvas.Pixels[0,0];
      APlannerItem.FPlanner.AttachementGlyph.Transparent := True;

      if Print then
      begin
        pw := Round(16 * GetDeviceCaps(Canvas.Handle, LOGPIXELSX) / 96);
        ph := Round(16 * GetDeviceCaps(Canvas.Handle, LOGPIXELSY) / 96);
        PrintBitmap(Canvas, Rect(r.Right - pw, r.Top, r.Right, r.Top + ph), APlannerItem.FPlanner.AttachementGlyph);
        r.Right := r.Right - pw;
      end
      else
      begin
        Canvas.Draw(r.Right - APlannerItem.FPlanner.AttachementGlyph.Width,r.Top,APlannerItem.FPlanner.AttachementGlyph);
        r.Right := r.Right - APlannerItem.FPlanner.AttachementGlyph.Width;
      end;

    end;

    if (APlannerItem.URL <> '') and (r.Right - r.Left > 32) then
    begin
      APlannerItem.FPlanner.URLGlyph.TransparentColor := APlannerItem.FPlanner.URLGlyph.Canvas.Pixels[0,0];
      APlannerItem.FPlanner.URLGlyph.Transparent := True;

      if Print then
      begin
        pw := Round(16 * GetDeviceCaps(Canvas.Handle, LOGPIXELSX) / 96);
        ph := Round(16 * GetDeviceCaps(Canvas.Handle, LOGPIXELSY) / 96);
        PrintBitmap(Canvas, Rect(r.Right - pw, r.Top, r.Right, r.Top + ph), APlannerItem.FPlanner.URLGlyph);
      end
      else
      begin
        Canvas.Draw(r.Right - APlannerItem.FPlanner.URLGlyph.Width,r.Top,APlannerItem.FPlanner.URLGlyph);
      end;
    end;

    iw := 0;
  end;

  if MultiImage then
  begin
    iw := 0;
    {
    if (APlannerItem.ImagePosition = ipHorizontal) then
      ih := PlannerImagePoint.Y
    else
      ih := 0;
    }
  end;

  APlannerItem.FCaptionHeight := ch;

  if (APlannerItem.ImagePosition = ipVertical) and Assigned(APlannerItem.FPlanner.PlannerImages) and
    (APlannerItem.ImageIndexList.Count > 0) then
    ARect.Left := ARect.Left + APlannerItem.FPlanner.PlannerImages.Width + EDITOFFSET;

  ARect.Top := ARect.Top + ch + 2 + FPlanner.PaintMarginTY {+ ih};
  ARect.Left := ARect.Left + iw + FPlanner.PaintMarginLX;

  ARect.Bottom := ARect.Bottom - FPlanner.PaintMarginBY;
  ARect.Right := ARect.Right - FPlanner.PaintMarginRX;

  if APlannerItem.CompletionDisplay = cdVertical then
  begin
    gs.Level0Color := FPlanner.CompletionColor1;
    gs.Level0ColorTo := clWhite;
    gs.Level1Perc := 101;
    gs.BackgroundColor := FPlanner.CompletionColor2;
    gs.Font := Canvas.Font;
    gs.Steps := 8;
    gs.Stacked := false;
    gs.ShowPercentage := false;
    gs.BorderColor := clGray;
    gs.ShowBorder := true;
    gs.Orientation := goVertical;
    gs.CompletionFormat := '%d%%';
    DrawGauge(Canvas,Rect(ARect.Left,ARect.Top,ARect.Left + 10 ,ARect.Bottom),APlannerItem.Completion,gs);

    ARect.Left := ARect.Left + 11;
  end;

  if APlannerItem.CompletionDisplay = cdHorizontal then
  begin
    gs.Level0Color := FPlanner.CompletionColor1;
    gs.Level0ColorTo := clWhite;
    gs.Level1Perc := 101;
    gs.Level2Color := FPlanner.CompletionColor1;
    gs.Level2ColorTo := clNone;
    gs.Level3Color := FPlanner.CompletionColor1;
    gs.Level3ColorTo := clNone;
    gs.BackgroundColor := FPlanner.CompletionColor2;
    gs.Font := Canvas.Font;
    gs.Steps := 8;
    gs.Stacked := false;
    gs.ShowPercentage := false;
    gs.BorderColor := clGray;
    gs.ShowBorder := true;
    gs.Orientation := goHorizontal;
    gs.ShowGradient := True;
    gs.CompletionFOrmat := '%d%%';

    DrawGauge(Canvas,Rect(ARect.Left,ARect.Top,ARect.Right ,ARect.Top + 10),APlannerItem.Completion,gs);

    ARect.Top := ARect.Top + 11;
  end;

  PaintString := APlannerItem.ItemText;

  if Assigned(FPlanner.OnItemText) then
    FPlanner.OnItemText(FPlanner,APlannerItem,PaintString);

  Canvas.Font.Assign(APlannerItem.Font);

  if APlannerItem.Selected and APlannerItem.ShowSelection then
    Canvas.Font.Color := APlannerItem.SelectFontColor;

  if APlannerItem.Flashing and APlannerItem.FlashOn then
    Canvas.Font.Color := FPlanner.FlashFontColor;

  HorizontalAlign := AlignToFlag(APlannerItem.Alignment);
  if IsRtf(PaintString) then
    RTFPaint(Canvas, ARect, PaintString, Background)
  else

  {$IFNDEF TMSDOTNET}
  if APlannerItem.Unicode then
  begin

    SetBkMode(Canvas.Handle, TRANSPARENT);
    DrawFlags := DT_NOPREFIX or DT_EDITCONTROL or HorizontalAlign;
    if APlannerItem.FWordWrap then
      DrawFlags := DrawFlags or DT_WORDBREAK
    else
      DrawFlags := DrawFlags or DT_SINGLELINE or DT_END_ELLIPSIS;

    YSize := DrawTextExW(Canvas.Handle, PWideChar(APlannerItem.WideText), Length(APlannerItem.WideText), ARect, DrawFlags,nil);

    APlannerItem.FClipped := YSize > (ARect.Bottom - ARect.Top);
  end
  else
  {$ENDIF}
  begin

    if IsHtml(APlannerItem,PaintString,false) then
    begin

      PaintString := ConcatenateTextStrings(APlannerItem.Text);

      GetCursorPos(pt);
      pt := ScreenToClient(pt);

      if not APlannerItem.Preview then
      begin
        HRGN := CreateRectRgn(ARect.Left,ARect.Top,ARect.Right,ARect.Bottom);
        SelectClipRgn(Canvas.Handle,HRGN);
      end;

      HTMLDrawEx(Canvas, PaintString, ARect, FPlanner.PlannerImages, pt.X, pt.Y, -1, -1, 1, False, False,
        Print, False, True, False, APlannerItem.FWordWrap
        , FMouseDown
        , FPlanner.FHTMLFactor, FPlanner.URLColor,
        clNone, clNone, clGray, Anchor, StrippedHtmlString, FocusAnchor, XSize, YSize, ml, hl, hr
        , cr, CID, CV, CT, FPlanner.FImageCache, FPlanner.FContainer, Handle
        );

       if not APlannerItem.Preview then
       begin
         SelectClipRgn(Canvas.Handle,0);
         DeleteObject(HRGN);
       end;

       APlannerItem.FClipped := YSize > (ARect.Bottom - ARect.Top);
    end
    else
    begin
      SetBkMode(Canvas.Handle, TRANSPARENT);

      DrawFlags := DT_NOPREFIX or DT_EDITCONTROL or HorizontalAlign;

      if APlannerItem.FWordWrap then
        DrawFlags := DrawFlags or DT_WORDBREAK
      else
        DrawFlags := DrawFlags or DT_SINGLELINE or DT_END_ELLIPSIS;

      {$IFDEF DELPHI4_LVL}
      DrawFlags := FPlanner.DrawTextBiDiModeFlags(DrawFlags);
      {$ENDIF}

      {$IFNDEF TMSDOTNET}
      YSize := DrawTextEx(Canvas.Handle, PChar(PaintString), Length(PaintString), ARect, DrawFlags,nil);
      {$ENDIF}

      {$IFDEF TMSDOTNET}
      YSize := DrawTextEx(Canvas.Handle, PaintString, Length(PaintString), ARect, DrawFlags,nil);
      {$ENDIF}



      APlannerItem.FClipped := YSize > (ARect.Bottom - ARect.Top);
    end;

  end;

  if (APlannerItem.FBeginOffset <> 0) and not APlannerItem.InHeader then
  begin
    DrawArrow(Canvas,clBlue,ro.Right - 4 - FPlanner.TrackWidth,
      ro.Top + FPlanner.TrackWidth,adUp);
  end;

  if (APlannerItem.FEndOffset <> 0) and not APlannerItem.InHeader then
  begin
    DrawArrow(Canvas,clBlue,ro.Right - 4 - FPlanner.TrackWidth,
      ro.Bottom - 8 - FPlanner.TrackWidth,adDown);
  end;

end;

procedure TPlannerGrid.PaintItemRow(Canvas: TCanvas; ARect: TRect; APlannerItem:
  TPlannerItem; Print, SelColor: Boolean);
var
  PaintString, Anchor, StrippedHtmlString, CaptionPaintString, FocusAnchor: string;
  r, ro, hr, cr, sr: TRect;
  ColumnHeight, iw, ih, ImageIndex, ml, hl, i: Integer;
  MultiImage: Boolean;
  HorizontalAlign, DrawFlags: DWORD;
  rr, dr, XSize, YSize: Integer;
  PlannerImagePoint: TPoint;
  Bitmap: TBitmap;
  Background: TColor;
  BackgroundTo: TColor;
  pt: TPoint;
  tmpBegin,tmpEnd: Integer;
  CellColor,OldColor: TColor;
  CID,CV,CT: string;
  HRGN: THandle;
  ch,pw,ph: Integer;
  rcorner, lcorner: Integer;

label
  BackGroundOnly;
begin
  if APlannerItem.Repainted then
    Exit;

  if (APlannerItem.ItemBegin = APlannerItem.ItemEnd) and not APlannerItem.InHeader then
    Exit;

  if not (csDesigning in FPlanner.ComponentState) and not Print then
    APlannerItem.Repainted := True;

  if not APlannerItem.Background then
    ARect.Bottom := ARect.Bottom - FPlanner.FItemGap;

  if Assigned(APlannerItem.FPlanner.OnPlannerItemDraw) then
  begin
    try
      APlannerItem.FPlanner.OnPlannerItemDraw(APlannerItem.FPlanner, APlannerItem, Canvas, ARect,
        False);
      Exit;
    except
      on e: EAbort do {nothing};
    end;
  end;

  if (APlannerItem.Shape = psTool) and Assigned(APlannerItem.DrawTool) then
  begin
    APlannerItem.DrawTool.DrawItem(APlannerItem,Canvas,ARect,APlannerItem.Selected,Print);
    Exit;
  end;

  if APlannerItem.ConflictPos = 0 then
  ARect.Top := ARect.Top + 1;

  CellColor := Canvas.Brush.Color;

  if APlannerItem.Shadow and not APlannerItem.Background and (APlannerItem.Shape = psRect)
    and not FPlanner.TrackOnly then
  begin
    Canvas.Brush.Color := FPlanner.ShadowColor;
    Canvas.Pen.Color := Canvas.Brush.Color;
    Canvas.Rectangle(ARect.Right - 3,ARect.Top + 3,ARect.Right,ARect.Bottom - 1);
    Canvas.Rectangle(ARect.Left + 3,ARect.Bottom - 4,ARect.Right,ARect.Bottom - 1);
    Canvas.Brush.Color := CellColor;
    Canvas.Pen.Color := CellColor;
    Canvas.Rectangle(ARect.Right - 3,ARect.Top ,ARect.Right,ARect.Top + 3);
    Canvas.Rectangle(ARect.Left ,ARect.Bottom - 4,ARect.Left + 3,ARect.Bottom - 1);

    ARect.Right := ARect.Right - 3;
    ARect.Bottom := ARect.Bottom - 3;
  end;

  Canvas.Font.Assign(APlannerItem.Font);

  ro := ARect;
  r := ARect;
  Background := APlannerItem.Color;
  BackgroundTo := APlannerItem.ColorTo;

  if APlannerItem.Selected and
     APlannerItem.ShowSelection and
     not APlannerItem.InHeader then
  begin
    Background := APlannerItem.SelectColor;
    BackgroundTo := APlannerItem.SelectColorTo;
  end;

  APlannerItem.FClipped := False;

  if APlannerItem.Background then
  begin
    if APlannerItem.BrushStyle <> bsSolid then
    begin
      Canvas.Brush.Color := Background;
      Canvas.Brush.Style := APlannerItem.BrushStyle;
      SetBkMode(Canvas.Handle, TRANSPARENT);
      SetBkColor(Canvas.Handle, ColorToRGb(FPlanner.Color));
    end;
    goto BackGroundOnly;
  end;

  // Draw the item trackbar
  r.Bottom := r.Top + TrackBarHeight(APlannerItem.FPlanner.TrackWidth,Canvas);

  if not APlannerItem.InHeader and
     APlannerItem.TrackVisible and
     (APlannerItem.Shape = psRect) then
  begin
    if FPlanner.TrackProportional then
    begin
      Canvas.Brush.Color := FPlanner.Display.ColorActive;
      Canvas.FillRect(r);

      dr := APlannerItem.FItemBeginPrecis - (APlannerItem.FItemBegin +
        FPlanner.Display.DisplayStart) * FPlanner.Display.DisplayUnit -  FPlanner.Display.DisplayOffset;

      dr := Round(dr / FPlanner.Display.DisplayUnit *
        FPlanner.Display.DisplayScale);

      rr := Round( (APlannerItem.FItemEndPrecis - APlannerItem.FItemBeginPrecis + FPlanner.Display.DisplayOffset) / FPlanner.Display.DisplayUnit * FPlanner.Display.DisplayScale);
      rr := dr + rr;

//      rr := Round((APlannerItem.FItemEndPrecis - APlannerItem.FItemBeginPrecis) /
//        FPlanner.Display.DisplayUnit * FPlanner.Display.DisplayScale) + FPlanner.Display.DisplayOffset;
    end
    else
    begin
      dr := 0;
      rr := r.Right - r.Left;
    end;

    r.Right := r.Left + rr;
    r.Left := r.Left + dr;


    if APlannerItem.Selected then
      Canvas.Brush.Color := APlannerItem.TrackSelectColor
    else
      Canvas.Brush.Color := APlannerItem.TrackColor;

    if APlannerItem.LinkSelect then
      Canvas.Brush.Color := APlannerItem.TrackLinkColor;

    Canvas.FillRect(r);

    if FPlanner.TrackBump then
      DrawBumpHorz(Canvas,r,APlannerItem.TrackColor);

    ARect.Top := ARect.Top + TrackBarHeight(APlannerItem.FPlanner.TrackWidth,Canvas);

    for i := 0 to APlannerItem.BarItems.Count - 1 do
    begin
      with APlannerItem.BarItems[ i] do
      begin
        tmpBegin := BarBegin;
        tmpEnd := BarEnd;
        if BarBegin = -1 then
          tmpBegin := 0;
        if BarEnd = -1 then
          tmpEnd := APlannerItem.ItemEnd - APlannerItem.ItemBegin;

        rr := (r.Right - r.Left) div (APlannerItem.ItemEnd - APlannerItem.ItemBegin);
        sr.Left := r.Left + (tmpBegin * rr);
        sr.Right := r.Left + (tmpEnd * rr);
        sr.Top := r.Top + 2;
        sr.Bottom := r.Bottom - 1;
        Canvas.Brush.Color := BarColor;
        Canvas.Pen.Color := APlannerItem.TrackColor;
        Canvas.Brush.Style := BarStyle;
        Canvas.Rectangle(sr.Left,sr.Top,sr.Right,sr.Bottom);
       end;
    end;
  end;

  if FPlanner.TrackOnly then
    Exit;

  if APlannerItem.FIsCurrent and not Print then
  begin
    Background := FPlanner.FDisplay.FColorCurrentItem;
    Canvas.Brush.Color := Background;
  end
  else
  begin
    if APlannerItem.BrushStyle <> bsSolid then
    begin
      Background := APlannerItem.Color;
      Canvas.Brush.Color := Background;
      Canvas.Brush.Style := APlannerItem.BrushStyle;
      SetBkMode(Canvas.Handle, TRANSPARENT);
      SetBkColor(Canvas.Handle, ColorToRGb(FPlanner.Color));
    end
    else
      Canvas.Brush.Color := Background;
  end;

  if APlannerItem.Flashing and APlannerItem.FlashOn then
    Canvas.Brush.Color := FPlanner.FlashColor;

  case APlannerItem.Shape of
  psRect:
    begin
      hr := ARect;
      hr.Bottom := hr.Bottom - 1;

      if hr.Bottom > hr.Top then
      begin
        if BackgroundTo <> clNone then
          DrawGradient(Canvas,Canvas.Brush.Color,BackgroundTo,64,hr,false)
        else
          Canvas.FillRect(hr);
      end;

      Canvas.Brush.Style := bsClear;
      Canvas.Pen.Color := APlannerItem.BorderColor;
      Canvas.Polygon([Point(ARect.Left, ARect.Top),
                      Point(ARect.Right - 1, ARect.Top),
                      Point(ARect.Right - 1, ARect.Bottom - 2),
                      Point(ARect.Left, ARect.Bottom - 2)]);
    end;
  psRounded:
    begin
      ARect.Bottom := ARect.Bottom - 1;
      ARect.Left := ARect.Left + 1;
      ARect.Right := ARect.Right - 1;

      if APlannerItem.Shadow then
      begin
        ARect.Bottom := ARect.Bottom - 1;
        ARect.Left := ARect.Left + 1;
        ARect.Right := ARect.Right - 1;

        Canvas.Pen.Color := FPlanner.ShadowColor;
        Canvas.Pen.Width := 2;
        OldColor := Canvas.Brush.Color;
        Canvas.Brush.Color := FPlanner.ShadowColor;
        Canvas.RoundRect(ARect.Left + 2,ARect.Top + 2,ARect.Right + 2,ARect.Bottom + 2,CORNER_EFFECT,CORNER_EFFECT);
        Canvas.Brush.Color := OldColor;
      end;

      if APlannerItem.TrackVisible and APlannerItem.FFocus then
      begin
        ARect.Top := ARect.Top + 1;
        Canvas.Pen.Color := APlannerItem.TrackColor;
        Canvas.Pen.Width := 2;
      end
      else
      begin
        Canvas.Pen.Color := APlannerItem.BorderColor;
        Canvas.Pen.Width := 1;
      end;

      Canvas.RoundRect(ARect.Left,ARect.Top,ARect.Right,ARect.Bottom,CORNER_EFFECT,CORNER_EFFECT);
      InflateRect(ARect,-(CORNER_EFFECT shr 2),-(CORNER_EFFECT shr 2));
    end;
  psHexagon:
    begin
      //InflateRect(ARect,-1,-1);

      lcorner := CORNER_EFFECT;
      rcorner := CORNER_EFFECT;

      if APlannerItem.BeginOffset <> 0 then
        lcorner := 0;
      if APlannerItem.EndOffset <> 0 then
        rcorner := 0;

      if APlannerItem.Shadow then
      begin
        //InflateRect(ARect,-2,-2);
        Canvas.Pen.Color := FPlanner.ShadowColor;
        Canvas.Pen.Width := 2;
        OldColor := Canvas.Brush.Color;
        Canvas.Brush.Color := FPlanner.ShadowColor;
        Canvas.Polygon([Point(2 + ARect.Left + lcorner, 2 + ARect.Top),
                        Point(2 + ARect.Right - 1 - rcorner, 2 + ARect.Top),
                        Point(2 + ARect.Right - 1, 2 + ARect.Top +((Arect.Bottom - ARect.Top) shr 1)),
                        Point(2 + ARect.Right - 1 - rcorner, 2 + ARect.Bottom - 2),
                        Point(2 + ARect.Left + lcorner, 2 + ARect.Bottom - 2),
                        Point(2 + ARect.Left, 2 + ARect.Top +((Arect.Bottom - ARect.Top) shr 1))]);

        Canvas.Brush.Color := OldColor;
      end;

      if APlannerItem.TrackVisible and APlannerItem.FFocus then
      begin
        Canvas.Pen.Color := APlannerItem.TrackColor;
        Canvas.Pen.Width := 2;
      end
      else
      begin
        Canvas.Pen.Color := APlannerItem.BorderColor;
        Canvas.Pen.Width := 1;
      end;

      Canvas.Polygon([Point(ARect.Left + lcorner, ARect.Top),
                      Point(ARect.Right - 1 - rcorner, ARect.Top),
                      Point(ARect.Right - 1, ARect.Top +((Arect.Bottom - ARect.Top) shr 1)),
                      Point(ARect.Right - 1 - rcorner, ARect.Bottom - 2),
                      Point(ARect.Left + lcorner, ARect.Bottom - 2),
                      Point(ARect.Left, ARect.Top +((Arect.Bottom - ARect.Top) shr 1))]);
      InflateRect(ARect,-CORNER_EFFECT,0);
    end;
  {$IFDEF TMSSKINS}
  psSkin:
    begin
      if APlannerItem.Selected then
      begin
        BitmapStretch(FPlanner.Skin.SkinSelectTop,Canvas,ARect.Left , ARect.Top, ARect.Right - ARect.Left);

        BitmapStretch(FPlanner.Skin.SkinSelectBottom,Canvas,ARect.Left , ARect.Bottom - FPlanner.Skin.SkinBottom.Height, ARect.Right - ARect.Left);

        BitmapStretchHeight(FPlanner.Skin.SkinSelectCenter,Canvas,ARect.Left , ARect.Top + FPlanner.Skin.SkinTop.Height - 1 ,ARect.Bottom - ARect.Top - FPlanner.Skin.SkinBottom.Height - FPlanner.Skin.SkinTop.Height + 1, ARect.Right - ARect.Left);
      end
      else
      begin
        BitmapStretch(FPlanner.Skin.SkinTop,Canvas,ARect.Left , ARect.Top, ARect.Right - ARect.Left);

        BitmapStretch(FPlanner.Skin.SkinBottom,Canvas,ARect.Left , ARect.Bottom - FPlanner.Skin.SkinBottom.Height, ARect.Right - ARect.Left);

        BitmapStretchHeight(FPlanner.Skin.SkinCenter,Canvas,ARect.Left , ARect.Top + FPlanner.Skin.SkinTop.Height - 1 ,ARect.Bottom - ARect.Top - FPlanner.Skin.SkinBottom.Height - FPlanner.Skin.SkinTop.Height + 1, ARect.Right - ARect.Left);
      end;

    end;
  {$ENDIF}  
  end;

  Canvas.Brush.Style := bsSolid;

  if APlannerItem.FFocus and
     not Print and
     APlannerItem.FTrackVisible and
     (APlannerItem.Shape = psRect) and
     not APlannerItem.InHeader then
  begin
    Canvas.Brush.Color := APlannerItem.TrackColor;
    r := ARect;
    r.Right := r.Left + 3;
    Canvas.FillRect(r);
    r := ARect;
    r.Left := ARect.Right - 3;
    Canvas.FillRect(r);
  end;

  BackGroundOnly:

  ARect.Top := ARect.Top + 2;

  if APlannerItem.FIsCurrent and not Print then
    Canvas.Brush.Color := FPlanner.FDisplay.FColorCurrentItem
  else
    Canvas.Brush.Color := APlannerItem.Color;

  InflateRect(ARect, -4, 0);

  {$IFDEF TMSSKINS}
  if APlannerItem.Shape = psSkin then
    InflateRect(ARect, -FPlanner.Skin.SkinX, -FPlanner.Skin.SkinY);
  {$ENDIF}


  if APlannerItem.Background then
  begin
    if APlannerItem.Transparent and SelColor then
      Canvas.Brush.Color := BlendColor(CellColor, APlannerItem.Color, FPlanner.SelectBlend);

    if not (Print and APlannerItem.Transparent) then
    begin
      Canvas.FillRect(r);
      Canvas.Pen.Color := APlannerItem.FPlanner.GridLineColor;
      Canvas.MoveTo(r.Right - 1, r.Top);
      Canvas.LineTo(r.Right - 1, r.Bottom);
    end;
  end;

  ColumnHeight := 0;
  ch := 0;
  ih := 0;
  iw := 0;
  MultiImage := False;
  PlannerImagePoint := Point(0,0);

  if Assigned(APlannerItem.FPlanner.PlannerImages) and
    ((APlannerItem.ImageID >= 0) or (APlannerItem.ImageIndexList.Count > 0)) then
  begin
    PlannerImagePoint.X := Round((APlannerItem.FPlanner.PlannerImages.Width + 2) *
      GetDeviceCaps(Canvas.Handle, LOGPIXELSX) / 96);
    PlannerImagePoint.Y := Round((APlannerItem.FPlanner.PlannerImages.Height + 2) *
      GetDeviceCaps(Canvas.Handle, LOGPIXELSY) / 96);
    ih := PlannerImagePoint.Y;
  end;

  if (APlannerItem.CaptionType in [ctTime, ctText, ctTimeText]) then
  begin
    Canvas.Font.Assign(APlannerItem.CaptionFont);

    if APlannerItem.Selected and
      APlannerItem.ShowSelection then
        Canvas.Font.Color := APlannerItem.SelectFontColor;

    if APlannerItem.Flashing and APlannerItem.FlashOn and APlannerItem.UniformBkg then
        Canvas.Font.Color := FPlanner.FlashFontColor;
    SetBkMode(Canvas.Handle, TRANSPARENT);
    ColumnHeight := Canvas.TextHeight('gh') + 4;

    if APlannerItem.Flashing and APlannerItem.FlashOn and APlannerItem.UniformBkg then
      Canvas.Font.Color := FPlanner.FlashFontColor;

    ih := Max(ColumnHeight, ih);

    ch := ih;

    {$IFDEF TMSSKINS}
    if APlannerItem.Shape <> psSkin then
    {$ENDIF}

    // Draw line under Caption
    if ARect.Top + ih + 1 < ARect.Bottom then
    begin
      if (APlannerItem.ImagePosition = ipVertical) and Assigned(APlannerItem.FPlanner.PlannerImages) and
         (APlannerItem.ImageIndexList.Count > 0) then
        Canvas.MoveTo(ARect.Left - 2 + APlannerItem.FPlanner.PlannerImages.Width, ARect.Top + ih + 1)
      else
        Canvas.MoveTo(ARect.Left - 2, ARect.Top + ih + 1);

      Canvas.LineTo(ARect.Right + 2, ARect.Top + ih + 1);
    end;

    ih := Min(ARect.Bottom - ARect.Top - 1, ih);
{
    Canvas.MoveTo(ARect.Left, ARect.Top + ih + 1);
    Canvas.LineTo(ARect.Right, ARect.Top + ih + 1);
}
    if not APlannerItem.UniformBkg then
    begin
      Canvas.Brush.Color := APlannerItem.CaptionBkg;
      Canvas.Pen.Color := APlannerItem.CaptionBkg;
      Canvas.Brush.Style := bsSolid;
    end
    else
    begin
      if APlannerItem.Flashing and APlannerItem.FlashOn then
        Canvas.Brush.Color := FPlanner.FlashColor
      else
        Canvas.Brush.Color := Background;
    end;

    r := ARect;
    r.Left := ARect.Left + iw;
    r.Bottom := r.Top + ih;

    InflateRect(r,1,1);

    if not APlannerItem.Focus then
    begin
      r.Left := r.Left - 2;
      r.Right := r.Right + 2;
    end;

    {$IFDEF TMSSKINS}
    if APlannerItem.Shape <> psSkin then
    begin
    {$ENDIF}

    if APlannerItem.CaptionBkgTo <> clNone then
      DrawGradient(Canvas,APlannerItem.CaptionBkg,APlannerItem.CaptionBkgTo,FPlanner.GradientSteps,r,not FPlanner.GradientHorizontal)
    else
      Canvas.FillRect(r);

    {$IFDEF TMSSKINS}
    end;
    {$ENDIF}

    if not APlannerItem.Focus then
    begin
      r.Left := r.Left + 2;
      r.Right := r.Right - 2;
    end;
  end;

  ih := 0;

  if Assigned(APlannerItem.FPlanner.PlannerImages) then
  begin
    if (APlannerItem.ImageID >= 0) and Assigned(APlannerItem.FPlanner.PlannerImages) then
    begin
      if ARect.Left + APlannerItem.FPlanner.PlannerImages.Width < ARect.Right then
      begin
        iw := PlannerImagePoint.X;
        ih := PlannerImagePoint.Y;
        if Print then
        begin
          Bitmap := TBitmap.Create;
          APlannerItem.FPlanner.PlannerImages.GetBitmap(APlannerItem.ImageID, Bitmap);
          PrintBitmap(Canvas, Rect(ARect.Left, ARect.Top, ARect.Left + iw,
            ARect.Top + ih), Bitmap);
          Bitmap.Free;
        end
        else
          APlannerItem.FPlanner.PlannerImages.Draw(Canvas, ARect.Left + APlannerItem.FPlanner.ImageOffsetX, ARect.Top + APlannerItem.FPlanner.ImageOffsetY,
            APlannerItem.ImageID);
      end;
    end;

    for ImageIndex := 0 to APlannerItem.FImageIndexList.Count - 1 do
    begin
      if APlannerItem.ImagePosition = ipHorizontal then
      begin
        if ARect.Left + iw + APlannerItem.FPlanner.PlannerImages.Width < ARect.Right then
        begin
          if Print then
          begin
            Bitmap := TBitmap.Create;
            try
              APlannerItem.FPlanner.PlannerImages.GetBitmap(
                APlannerItem.FImageIndexList.Items[ImageIndex], Bitmap);
              PrintBitmap(Canvas, Rect(ARect.Left + iw, ARect.Top,
                ARect.Left + iw + PlannerImagePoint.X, ARect.Top + PlannerImagePoint.Y), Bitmap);
            finally
              Bitmap.Free;
            end;
          end
          else
            APlannerItem.FPlanner.PlannerImages.Draw(Canvas, ARect.Left + iw, ARect.Top,
              APlannerItem.FImageIndexList.Items[ImageIndex]);

          iw := iw + PlannerImagePoint.X;
          ih := PlannerImagePoint.Y;
        end;
      end
      else
      begin
        if ARect.Top + iw + APlannerItem.FPlanner.PlannerImages.Height < ARect.Bottom then
        begin
          if Print then
          begin
            Bitmap := TBitmap.Create;
            try
              APlannerItem.FPlanner.PlannerImages.GetBitmap(
                APlannerItem.FImageIndexList.Items[ImageIndex], Bitmap);
              PrintBitmap(Canvas, Rect(ARect.Left, ARect.Top + ih,
                ARect.Left + PlannerImagePoint.X, ARect.Top + PlannerImagePoint.Y+ ih), Bitmap);
            finally
              Bitmap.Free;
            end;
          end
          else
            APlannerItem.FPlanner.PlannerImages.Draw(Canvas, ARect.Left , ARect.Top + ih,
              APlannerItem.FImageIndexList.Items[ImageIndex]);

          ih := ih + PlannerImagePoint.Y;
          iw := PlannerImagePoint.X;
        end;
      end;
      MultiImage := True;
    end;

    if (APlannerItem.ImagePosition = ipHorizontal) and (APlannerItem.FImageIndexList.Count > 0)
      and (APlannerItem.CaptionType = ctNone) then
      ARect.Top := ARect.Top + ih;

  end;

//  if APlannerItem.ImagePosition = ipVertical then
  ih := Max(ch,ColumnHeight);

  if (APlannerItem.CaptionType in [ctTime, ctText, ctTimeText]) then
  begin
    //ih := ih + 2;

    r := ARect;
    r.Left := ARect.Left + iw;
    r.Bottom := r.Top + ih;

    {$IFDEF TMSSKINS}
    if APlannerItem.Shape = psSkin then
    begin
      r.Top := r.Top + FPlanner.Skin.SkinCaptionY;
      r.Left := r.Left + FPlanner.Skin.SkinCaptionX;
    end;
    {$ENDIF}

    if (APlannerItem.ShowDeleteButton) and (r.Right - r.Left > 32) then
      r.Right := r.Right - APlannerItem.FPlanner.DeleteGlyph.Width;

    if (APlannerItem.URL <> '') and (r.Right - r.Left > 32) then
      r.Right := r.Right - APlannerItem.FPlanner.URLGlyph.Width;

    if (APlannerItem.Attachement <> '')  and (r.Right - r.Left > 32) then
      r.Right := r.Right - APlannerItem.FPlanner.AttachementGlyph.Width;

    if (APlannerItem.ShowDeleteButton) or (APlannerItem.URL <> '') or (APlannerItem.Attachement <> '') then
      r.Right := r.Right - 2;

    CaptionPaintString := APlannerItem.GetCaptionString;

    HorizontalAlign := AlignToFlag(APlannerItem.CaptionAlign);

    SetBkMode(Canvas.Handle, TRANSPARENT);

    {$IFNDEF TMSDOTNET}
    if APlannerItem.Unicode then
    begin
      DrawFlags := DT_NOPREFIX or DT_END_ELLIPSIS or HorizontalAlign;
      DrawTextExW(Canvas.Handle, PWideChar(APlannerItem.WideCaption), Length(APlannerItem.WideCaption), r, DrawFlags, nil);
    end
    else
    {$ENDIF}
    begin

      if IsHtml(APlannerItem,CaptionPaintString,true) then

        HTMLDrawEx(Canvas, CaptionPaintString, r, FPlanner.PlannerImages, 0, 0, -1, -1, 1, False, False,
          Print, False, True, False, APlannerItem.WordWrap
          ,False
          , FPlanner.FHTMLFactor, FPlanner.URLColor,
          clNone, clNone, clGray, Anchor, StrippedHtmlString, FocusAnchor, XSize, YSize, ml, hl, hr
          , cr, CID, CV, CT, FPlanner.FImageCache, FPlanner.FContainer, Handle
          )

      else
      begin
        DrawFlags := DT_NOPREFIX or DT_END_ELLIPSIS or HorizontalAlign;

        {$IFDEF DELPHI4_LVL}
        DrawFlags := FPlanner.DrawTextBiDiModeFlags(DrawFlags);
        {$ENDIF}



        {$IFNDEF TMSDOTNET}
        DrawText(Canvas.Handle, PChar(CaptionPaintString), Length(CaptionPaintString), r, DrawFlags);
        {$ENDIF}

        {$IFDEF TMSDOTNET}
        DrawText(Canvas.Handle, CaptionPaintString, Length(CaptionPaintString), r, DrawFlags);
        {$ENDIF}


      end;
    end;  

    r.Right := ARect.Right;
    r.Top := r.Top - 2;

    if (APlannerItem.ShowDeleteButton) and (r.Right - r.Left > 32) then
    begin
      APlannerItem.FPlanner.DeleteGlyph.TransparentColor := APlannerItem.FPlanner.DeleteGlyph.Canvas.Pixels[0,0];
      APlannerItem.FPlanner.DeleteGlyph.Transparent := True;

      if Print then
      begin
        pw := Round(16 * GetDeviceCaps(Canvas.Handle, LOGPIXELSX) / 96);
        ph := Round(16 * GetDeviceCaps(Canvas.Handle, LOGPIXELSY) / 96);
        PrintBitmap(Canvas, Rect(r.Right - pw, r.Top, r.Right, r.Top + ph), APlannerItem.FPlanner.DeleteGlyph);
        r.Right := r.Right - pw;
      end
      else
      begin
        Canvas.Draw(r.Right - APlannerItem.FPlanner.DeleteGlyph.Width,r.Top,APlannerItem.FPlanner.DeleteGlyph);
        r.Right := r.Right - APlannerItem.FPlanner.DeleteGlyph.Width;
      end;
    end;

    if (APlannerItem.Attachement <> '') and (r.Right - r.Left > 32) then
    begin
      APlannerItem.FPlanner.AttachementGlyph.TransparentColor := APlannerItem.FPlanner.AttachementGlyph.Canvas.Pixels[0,0];
      APlannerItem.FPlanner.AttachementGlyph.Transparent := True;

      if Print then
      begin
        pw := Round(16 * GetDeviceCaps(Canvas.Handle, LOGPIXELSX) / 96);
        ph := Round(16 * GetDeviceCaps(Canvas.Handle, LOGPIXELSY) / 96);
        PrintBitmap(Canvas, Rect(r.Right - pw, r.Top, r.Right, r.Top + ph), APlannerItem.FPlanner.AttachementGlyph);
        r.Right := r.Right - pw;
      end
      else
      begin
        Canvas.Draw(r.Right - APlannerItem.FPlanner.AttachementGlyph.Width,r.Top,APlannerItem.FPlanner.AttachementGlyph);
        r.Right := r.Right - APlannerItem.FPlanner.AttachementGlyph.Width;
      end;

    end;

    if (APlannerItem.URL <> '') and (r.Right - r.Left > 32) then
    begin
      APlannerItem.FPlanner.URLGlyph.TransparentColor := APlannerItem.FPlanner.URLGlyph.Canvas.Pixels[0,0];
      APlannerItem.FPlanner.URLGlyph.Transparent := True;

      if Print then
      begin
        pw := Round(16 * GetDeviceCaps(Canvas.Handle, LOGPIXELSX) / 96);
        ph := Round(16 * GetDeviceCaps(Canvas.Handle, LOGPIXELSY) / 96);
        PrintBitmap(Canvas, Rect(r.Right - pw, r.Top, r.Right, r.Top + ph), APlannerItem.FPlanner.URLGlyph);
      end
      else
      begin
        Canvas.Draw(r.Right - APlannerItem.FPlanner.URLGlyph.Width,r.Top,APlannerItem.FPlanner.URLGlyph);
      end;

    end;


    iw := 0;
  end
  else
    ih := 0;

  if MultiImage then
  begin
    iw := 0;
    //ih := PlannerImagePoint.Y;
  end;

  Canvas.Font.Assign(APlannerItem.Font);

  if APlannerItem.Selected and
    APlannerItem.ShowSelection then
      Canvas.Font.Color := APlannerItem.SelectFontColor;

  if APlannerItem.Flashing and APlannerItem.FlashOn then
    Canvas.Font.Color := FPlanner.FlashFontColor;

  APlannerItem.FCaptionHeight := ch;

  if (APlannerItem.ImagePosition = ipVertical) and Assigned(APlannerItem.FPlanner.PlannerImages) and
    (APlannerItem.ImageIndexList.Count > 0) then
    ARect.Left := ARect.Left + APlannerItem.FPlanner.PlannerImages.Width + EDITOFFSET;

  ARect.Top := ARect.Top + ih + 2 + FPlanner.PaintMarginTY;
  ARect.Left := ARect.Left + iw + FPlanner.PaintMarginLX;

  ARect.Bottom := ARect.Bottom - FPlanner.PaintMarginBY;
  ARect.Right := ARect.Right - FPlanner.PaintMarginRX;

  if APlannerItem.CompletionDisplay = cdVertical then
  begin
    Canvas.Brush.Color := FPlanner.CompletionColor1;
    Canvas.Pen.Color := FPlanner.CompletionColor1;
    Canvas.Rectangle(ARect.Left,  ARect.Top - 1 + Round((APlannerItem.Completion) / 100 * (ARect.Bottom - ARect.Top - 4)),ARect.Left + 10, ARect.Bottom - 4);

    Canvas.Brush.Color := FPlanner.CompletionColor2;
    Canvas.Pen.Color := FPlanner.CompletionColor2;
    Canvas.Rectangle(ARect.Left, ARect.Top - 1, ARect.Left + 10,ARect.Top -  2+ Round((APlannerItem.Completion) / 100 * (ARect.Bottom - ARect.Top - 4)));

    Canvas.Brush.Style := bsClear;
    Canvas.Pen.Color := clBlack;
    Canvas.Rectangle(ARect.Left,ARect.Top - 1,ARect.Left + 10, ARect.Bottom - 4 );

    ARect.Left := ARect.Left + 11;
  end;

  if APlannerItem.CompletionDisplay = cdHorizontal then
  begin
    Canvas.Brush.Color := FPlanner.CompletionColor1;
    Canvas.Pen.Color := FPlanner.CompletionColor1;
    Canvas.Rectangle(ARect.Left,  ARect.Top, ARect.Left + Round((APlannerItem.Completion) / 100 * (ARect.Right - ARect.Left + 2)),ARect.Top + 10);

    Canvas.Brush.Color := FPlanner.CompletionColor2;
    Canvas.Pen.Color := FPlanner.CompletionColor2;
    Canvas.Rectangle(ARect.Left + Round((APlannerItem.Completion) / 100 * (ARect.Right - ARect.Left + 2)),ARect.Top, ARect.Right, ARect.Top + 10);

    Canvas.Brush.Style := bsClear;
    Canvas.Pen.Color := clBlack;
    Canvas.Rectangle(ARect.Left,ARect.Top ,ARect.Right, ARect.Top + 10 );

    ARect.Top := ARect.Top + 11;
  end;

  PaintString := APlannerItem.ItemText;

  if Assigned(FPlanner.OnItemText) then
    FPlanner.OnItemText(FPlanner,APlannerItem,PaintString);

  HorizontalAlign := AlignToFlag(APlannerItem.Alignment);

  if IsRtf(PaintString) then
    RTFPaint(Canvas, ARect, PaintString, Background)
  else

  {$IFNDEF TMSDOTNET}
  if APlannerItem.Unicode then
  begin
    SetBkMode(Canvas.Handle, TRANSPARENT);

    DrawFlags := DT_NOPREFIX or DT_EDITCONTROL or HorizontalAlign;

    if APlannerItem.FWordWrap then
      DrawFlags := DrawFlags or DT_WORDBREAK
    else
      DrawFlags := DrawFlags or DT_SINGLELINE or DT_END_ELLIPSIS;

    YSize := DrawTextExW(Canvas.Handle, PWideChar(APlannerItem.WideText), Length(APlannerItem.WideText), ARect, DrawFlags, nil);
    APlannerItem.FClipped := YSize > (ARect.Bottom - ARect.Top);

  end
  else
  {$ENDIF}
  begin

    if IsHtml(APlannerItem,PaintString,false) then
    begin
      PaintString := ConcatenateTextStrings(APlannerItem.Text);

      GetCursorPos(pt);
      pt := ScreenToClient(pt);
      pt.y := pt.y + 2;

      HRGN := CreateRectRgn(ARect.Left,ARect.Top,ARect.Right,ARect.Bottom);
      SelectClipRgn(Canvas.Handle,HRGN);

      HTMLDrawEx(Canvas, PaintString, ARect, FPlanner.PlannerImages, pt.X, pt.Y, -1, -1, 1, False, False,
        Print, False, True, False, APlannerItem.FWordWrap
        ,False
        , FPlanner.FHTMLFactor, FPlanner.URLColor,
        clNone, clNone, clGray, Anchor, StrippedHtmlString, FocusAnchor, XSize, YSize, ml, hl, hr
        , cr, CID, CV, CT, FPlanner.FImageCache, FPlanner.FContainer, Handle
        );

      SelectClipRgn(Canvas.Handle,0);
      DeleteObject(HRGN);

      APlannerItem.FClipped := YSize > (ARect.Bottom - ARect.Top);
    end
    else
    begin
      SetBkMode(Canvas.Handle, TRANSPARENT);

      DrawFlags := DT_NOPREFIX or DT_EDITCONTROL or HorizontalAlign;

      if APlannerItem.FWordWrap then
        DrawFlags := DrawFlags or DT_WORDBREAK
      else
        DrawFlags := DrawFlags or DT_SINGLELINE or DT_END_ELLIPSIS;

      {$IFDEF DELPHI4_LVL}
      DrawFlags := FPlanner.DrawTextBiDiModeFlags(DrawFlags);
      {$ENDIF}

      {$IFNDEF TMSDOTNET}
      YSize := DrawTextEx(Canvas.Handle, PChar(PaintString), Length(PaintString), ARect, DrawFlags, nil);
      {$ENDIF}

      {$IFDEF TMSDOTNET}
      YSize := DrawTextEx(Canvas.Handle, PaintString, Length(PaintString), ARect, DrawFlags, nil);
      {$ENDIF}


      APlannerItem.FClipped := YSize > (ARect.Bottom - ARect.Top);
    end;
  end;  

  if (APlannerItem.FBeginOffset <> 0) and not APlannerItem.InHeader then
  begin
    DrawArrow(Canvas,clBlue,ro.Left + FPlanner.TrackWidth,
      ro.Bottom - 8 - FPlanner.TrackWidth,adLeft);
  end;

  if (APlannerItem.FEndOffset <> 0) and not APlannerItem.InHeader then
  begin
    DrawArrow(Canvas,clBlue,ro.Right - 8 - FPlanner.FTrackWidth,
      ro.Bottom - 8 - FPlanner.TrackWidth,adRight);
  end;

end;


procedure TPlannerGrid.PaintSideCol(Canvas: TCanvas; ARect: TRect; ARow, APos, Offs:
  Integer; Occupied, Print: Boolean);
var
  Line1,Line2,Line3,DT: string;
  HorizontalAlign: Integer;
  MinutesWidth, HoursWidth, MinutesHeight: Integer;
  OldSize: Integer;
  OnTheHour: Boolean;
  HS,IsDay: Boolean;
  DNum, delta: Integer;
  DRect: TRect;
  HOldFont, HNewFont: THandle;
  LFont: TLogFont;
  dday: Integer;
  BTM: DWORD;
  t1,t2: TDateTime;
  p: double;
  PRect: TRect;
  ORow: integer;

begin
  // Initialize
  HS := False;

  PRect := ARect;
  ORow := ARow;

  if (FPlanner.Display.DisplayText > 0) then
  begin
    delta := (FPlanner.Display.DisplayStart + ARow) mod FPlanner.Display.DisplayText;

    if (delta <> 0) then
    begin
      ARow := ARow - delta;

      if Print then
        ARect.Top := ARect.Top - delta * (ARect.Bottom - ARect.Top + 2)
      else
        ARect.Top := ARect.Top - delta * FPlanner.Display.DisplayScale;
    end;
  end;

  GetSideBarLines(ARow + Offs, APos, Line1, Line2, Line3, HS);
//  Canvas.Font.Assign(FPlanner.Sidebar.Font);

  MinutesWidth := Canvas.TextWidth(Line2);
  MinutesHeight := Canvas.TextHeight(Line2);

  if Occupied then
    Canvas.Font.Color := FPlanner.Sidebar.OccupiedFontColor;

  HorizontalAlign := AlignToFlag(FPlanner.Sidebar.Alignment);

  if (FPlanner.FMode.FPlannerType = plHalfDayPeriod) then
  begin
    DRect := ARect;

    if not odd(ARow) then
      ARect.Bottom := ARect.Bottom + DefaultRowHeight
    else
      ARect.Top := ARect.Top - DefaultRowHeight;

    //Canvas.Pen.Color := FPlanner.GridLineColor;

    Canvas.Pen.Color := FPlanner.Sidebar.SeparatorLineColor;

    Canvas.MoveTo(ARect.Left - 1,ARect.Bottom);
    Canvas.LineTo(ARect.Right,ARect.Bottom);

    if FPlanner.Sidebar.AMPMPos = apNone then
      Line3 := '';

    if odd(ARow) then
      BTM := DT_BOTTOM
    else
      BTM := 0;

    SetBkMode(Canvas.Handle,TRANSPARENT);
    {$IFNDEF TMSDOTNET}
    DrawText(Canvas.Handle,PChar(Line3),Length(Line3),DRect, DT_RIGHT or DT_SINGLELINE or BTM);
    {$ENDIF}
    {$IFDEF TMSDOTNET}
    DrawText(Canvas.Handle,Line3,Length(Line3),DRect, DT_RIGHT or DT_SINGLELINE or BTM);
    {$ENDIF}
    Line3 := '';
  end;


  if (FPlanner.FMode.FPlannerType = plTimeLine) then
  begin
    dday := (MININDAY div FPlanner.Display.DisplayUnit) - (FPlanner.Mode.TimeLineNVUEnd + FPlanner.Mode.TimeLineNVUBegin);

    if dday = 0 then
      dday := 1;

    delta := ARow mod dday;
    DNum := ARow div dday;

    {
    delta := ARow mod ((MININDAY div (FPlanner.Display.DisplayUnit)));
    DNum := ((ARow * FPlanner.Display.DisplayUnit) div MININDAY);
    }

    begin
      if FPlanner.Sidebar.DateTimeFormat <> '' then
        DT := FormatDateTime(FPlanner.Sidebar.DateTimeFormat,FPlanner.Mode.TimeLineStart + DNum)
      else
        DT := DateToStr(FPlanner.Mode.TimeLineStart + DNum);

      DRect := ARect;

      if Print then
        DRect.Top := ARect.Top - Delta * (PRect.Bottom - PRect.Top + 2)
      else
        DRect.Top := ARect.Top - Delta * DefaultRowHeight;

      //DRect.Bottom := DRect.Top + (MININDAY div (FPlanner.Display.DisplayUnit)) * DefaultRowHeight;

      if Print then
        DRect.Bottom := DRect.Top + dday * (PRect.Bottom - PRect.Top + 2)
      else
        DRect.Bottom := DRect.Top + dday * DefaultRowHeight;

      SetBkMode(Canvas.Handle,TRANSPARENT);

      // do font rotation here
      {$IFNDEF TMSDOTNET}
      GetObject(Canvas.Font.Handle, SizeOf(LFont), Addr(LFont));
      {$ENDIF}
      {$IFDEF TMSDOTNET}
      GetObject(Canvas.Font.Handle, Marshal.SizeOf(TypeOf(LFont)), LFont);
      {$ENDIF}

      LFont.lfEscapement := 90 * 10;
      LFont.lfOrientation := 90 * 10;

      if Print and FPlanner.FPrinterDriverFix then
      begin
        LFont.lfEscapement  := -LFont.lfEscapement;
        LFont.lfOrientation := -LFont.lfEscapement;
      end;

      HNewFont := CreateFontIndirect(LFont);
      HOldFont := SelectObject(Canvas.Handle, HNewFont);

      if Print then
        Canvas.TextOut(DRect.Left, DRect.Bottom, DT)
      else
        {$IFNDEF TMSDOTNET}
        DrawText(Canvas.Handle,PChar(DT),Length(DT),DRect,
           DT_NOPREFIX or DT_WORDBREAK or DT_VCENTER or DT_LEFT or DT_SINGLELINE);
        {$ENDIF}

        {$IFDEF TMSDOTNET}
        DrawText(Canvas.Handle,DT,Length(DT),DRect,
           DT_NOPREFIX or DT_WORDBREAK or DT_VCENTER or DT_LEFT or DT_SINGLELINE);
        {$ENDIF}



      HNewFont := SelectObject(Canvas.Handle, HOldFont);
      DeleteObject(HNewFont);


    end;

    if (delta = 0) and (ARow > 0) then
    begin
      DRect.Top := ARow * DefaultRowHeight;
      Canvas.Pen.Color := FPlanner.GridLineColor;
      Canvas.MoveTo(ARect.Left - 1,ARect.Top - 1);
      Canvas.LineTo(ARect.Right - 1,ARect.Top - 1);
    end;

    ARect.Left := ARect.Left + (ARect.Right - ARect.Left) div 2;

    Line2 := Line1;
    Line1 := '';

    if (FPlanner.Sidebar.TimeIndicator) then
    begin
      FPlanner.CellToAbsTime(orow, t1,t2);

      if (Now >= t1) and (Now <= t2) then
      begin
        p  := FPlanner.Display.DisplayScale * ((Now - t1) / (t2 - t1));

        Canvas.Pen.Color := FPlanner.SideBar.TimeIndicatorColor;
        Canvas.Pen.Width := 4;
        Canvas.MoveTo(PRect.Left, PRect.Top + round(p));
        Canvas.LineTo(PRect.Right, PRect.Top + round(p));
        Canvas.Pen.Width := 1;
      end;
    end;
  end;


  if (ARect.Bottom - ARect.Top < MinutesHeight * 2) and
     (FPlanner.Mode.PlannerType <> plDay) then
    Line1 := '';

  // Special painting in case there is a Line1 in day mode
  if (FPlanner.FMode.FPlannerType in [plDay]) or (Line1 <> '') then
  begin
    OnTheHour := False;
    IsDay := FPlanner.FMode.FPlannerType = plDay;

    if (FPlanner.Sidebar.TimeIndicator) then
    begin
      FPlanner.CellToAbsTime(orow, t1,t2);

      if (Frac(Now) >= Frac(t1)) and (Frac(Now) <= Frac(t2)) then
      begin
        p  := FPlanner.Display.DisplayScale * ((Frac(Now) - Frac(t1)) / (Frac(t2) - Frac(t1)));

        Canvas.Pen.Color := FPlanner.SideBar.TimeIndicatorColor;
        Canvas.Pen.Width := 4;
        Canvas.MoveTo(PRect.Left, PRect.Top + round(p));
        Canvas.LineTo(PRect.Right, PRect.Top + round(p));
        Canvas.Pen.Width := 1;
      end;
    end;

    HS := HS or not IsDay;

     // Line1=HoursString, Line2=MinutesString, Line3=AmPmString
//    if ARow >= 0 then
    begin
      if FPlanner.FMode.FPlannerType = plDay then
      begin
        OnTheHour := Pos('00',Line2) > 0; // Don't display hours if we are not 'on the hour'

        if FPlanner.SideBar.AMPMPos = apNone then
          Line3 := '';

        if Line3 <> '' then       // There is an AM/PM, so concatenate it to the minutes
        begin
          if FPlanner.SideBar.AMPMPos = apUnderTime then
            Line2 := Line2 + RegularCRLF + Line3
          else
          begin
            Line2 := Line2 + ' ' + Line3;
            MinutesWidth := Canvas.TextWidth(Line2);
          end;
        end;
      end;

      if FPlanner.FMode.FPlannerType = plHalfDayPeriod then
      begin
        if FPlanner.SideBar.AMPMPos = apNone then
          Line3 := '';

        if FPlanner.SideBar.AMPMPos = apUnderTime then
          Line2 := Line2 + RegularCRLF + Line3
        else
          Line2 := Line2 + ' ' + Line3
      end;

      if FPlanner.FSideBar.Flat and (FPlanner.FMode.FPlannerType = plDay) and
        (ARow <> FPlanner.FGrid.TopRow ) then
      begin
        Canvas.Pen.Color := FPlanner.Sidebar.LineColor;

        if OnTheHour then
          Canvas.MoveTo(ARect.Left, ARect.Top - 1) // paint Hours
        else
          Canvas.MoveTo(ARect.Right - MinutesWidth, ARect.Top - 1); // do not paint hours

        Canvas.LineTo(ARect.Right - 1, ARect.Top - 1);
      end;

    end;

    OldSize := Canvas.Font.Size;
    try

      if IsDay then
      begin
        Canvas.Font.Size := Round(Canvas.Font.Size * FPlanner.Sidebar.HourFontRatio);
      end
      else
      begin
        MinutesWidth := 0;
      end;

      HoursWidth := Canvas.TextWidth(Line1);

      SetBKMode(Canvas.Handle,TRANSPARENT);

      case FPlanner.Sidebar.Alignment of
        taLeftJustify:
          begin
            if HS then
              Canvas.TextOut(ARect.Left, ARect.Top, Line1);

            if IsDay then
              ARect.Left := ARect.Left + HoursWidth + 4
          end;
        taRightJustify:
          begin
            if HS then
              Canvas.TextOut(ARect.Right - MinutesWidth - 4 - HoursWidth, ARect.Top, Line1);
          end;
        taCenter:
          begin
            if HS then
              Canvas.TextOut(ARect.Left + (ARect.Right - ARect.Left - HoursWidth - MinutesWidth)
                div 2, ARect.Top, Line1);
            if IsDay then
              ARect.Left := ARect.Left + HoursWidth + 4 +
                (ARect.Right - ARect.Left - HoursWidth - MinutesWidth) div 2;
          end;
      end;

      if not IsDay then
        ARect.Top := ARect.Top + MinutesHeight + 2;

    finally
      if IsDay then
        Canvas.Font.Size := OldSize;
    end;
  end;


  if (FPlanner.Display.DisplayText > 0) then
  begin
    if ((FPlanner.Display.DisplayStart + ARow) mod FPlanner.Display.DisplayText <> 0) then
    begin
      Line2 := '';
    end;
  end;

  { Painting }
  if (Line2 <> '') then
  begin
    SetBKMode(Canvas.Handle,TRANSPARENT);

    {$IFNDEF TMSDOTNET}
    DrawText(Canvas.Handle, PChar(Line2), Length(Line2), ARect, DT_NOPREFIX
      or DT_WORDBREAK or HorizontalAlign);
    {$ENDIF}

    {$IFDEF TMSDOTNET}
    DrawText(Canvas.Handle, Line2, Length(Line2), ARect, DT_NOPREFIX
      or DT_WORDBREAK or HorizontalAlign);
    {$ENDIF}

  end;

end;

procedure TPlannerGrid.PaintSideRow(Canvas: TCanvas; ARect: TRect; AColumn, APos:
  Integer; Occupied, Print: Boolean; DefColWidth: integer);
var
  Line1, Line2, Line3,DT: string;
  HorizontalAlign: Integer;
  OldSize: Integer;
  OnTheOur: Boolean;
  LFont: TLogFont;
  HOldFont, HNewFont: HFont;
  MinorLineWidth: Integer;
  MajorLineWidth: Integer;
  HS: Boolean;
  DNum,delta: Integer;
  DRect,HRect,PRect: TRect;
  dday: Integer;
  p: double;
  t1,t2: TDateTime;
  Mins: integer;
  OCol: integer;

begin
  { Initialize }
  GetSideBarLines(AColumn, APos, Line1, Line2, Line3, HS);
  MinorLineWidth := Canvas.TextHeight(Line2);
  // Canvas.Font.Assign(FPlanner.Sidebar.Font);

  PRect := ARect;
  OCol := AColumn;
  
  HorizontalAlign := AlignToFlag(FPlanner.Sidebar.Alignment);

  HOldFont := 0;
  SetBkMode(Canvas.Handle, TRANSPARENT);

  if (FPlanner.Display.DisplayText > 0) then
  begin
    delta := (FPlanner.Display.DisplayStart + AColumn) mod FPlanner.Display.DisplayText;
    if (delta <> 0) then
    begin
      AColumn := AColumn - delta;
      if Print then
        ARect.Left := ARect.Left - delta * (ARect.Right - ARect.Left + 2)
      else
        ARect.Left := ARect.Left - delta * FPlanner.Display.DisplayScale;

      GetSideBarLines(AColumn, APos, Line1, Line2, Line3, HS);
    end
    else
      Line2 := '';
  end
  else
    if (FPlanner.Mode.FPlannerType  = plTimeLine) then
      Line2 := '';

  if FPlanner.Sidebar.AMPMPos = apNone then
    Line3 := '';

  if Occupied then
    Canvas.Font.Color := FPlanner.Sidebar.OccupiedFontColor;

  if (FPlanner.Mode.FPlannerType  = plHalfDayPeriod) then
  begin
    DRect := ARect;

    if not odd(AColumn) then
      ARect.Right := ARect.Right + DefaultColWidth
    else
      ARect.Left := ARect.Left - DefaultColWidth;

    //Canvas.Pen.Color := FPlanner.GridLineColor;

    Canvas.Pen.Color := FPlanner.Sidebar.SeparatorLineColor;

    Canvas.MoveTo(ARect.Right + 3,ARect.Top);
    Canvas.LineTo(ARect.Right + 3,ARect.Bottom);

    if (line3 <> '') and (not FPlanner.SideBar.RotateOnTop) then
      ARect.Bottom := ARect.Bottom - Canvas.TextHeight('gh');

    SetBkMode(Canvas.Handle,TRANSPARENT);
    {$IFNDEF TMSDOTNET}
    DrawText(Canvas.Handle,PChar(Line3),Length(Line3),DRect, DT_CENTER or DT_SINGLELINE or DT_BOTTOM);
    {$ENDIF}
    {$IFDEF TMSDOTNET}
    DrawText(Canvas.Handle,Line3,Length(Line3),DRect, DT_CENTER or DT_SINGLELINE or DT_BOTTOM);
    {$ENDIF}

    Line3 := '';
  end;

  if (FPlanner.FMode.FPlannerType = plTimeLine) then
  begin
    dday := (MININDAY div FPlanner.Display.DisplayUnit) - (FPlanner.Mode.TimeLineNVUBegin + FPlanner.Mode.TimeLineNVUEnd);
    delta := AColumn mod dday;
    DNum := AColumn div dday;

    {
    delta := AColumn mod (MININDAY div (FPlanner.Display.DisplayUnit));
    DNum := ((AColumn * FPlanner.Display.DisplayUnit) div MININDAY);
    }

    if FPlanner.Sidebar.DateTimeFormat <> '' then
      DT := FormatDateTime(FPlanner.Sidebar.DateTimeFormat,FPlanner.Mode.TimeLineStart + DNum)
    else
      DT := DateToStr(FPlanner.Mode.TimeLineStart + DNum);

    if not Print or (delta = dday - 1) then
    begin
      DRect := ARect;

      if not print then
        DRect.Left := Max(0,ARect.Left - Delta * DefaultColWidth)
      else
        DRect.Left := Max(0, ARect.Left - (dday + 1) * (ARect.Right - ARect.Left));


      {$IFNDEF TMSDOTNET}
      DrawText(Canvas.Handle,PChar(DT),Length(DT), DRect, DT_NOPREFIX or DT_LEFT);
      {$ENDIF}

      {$IFDEF TMSDOTNET}
      DrawText(Canvas.Handle,DT,Length(DT),DRect,
         DT_NOPREFIX or DT_LEFT);
      {$ENDIF}



      if (FPlanner.Sidebar.TimeIndicator) then
      begin
        FPlanner.CellToAbsTime(ocol, t1,t2);
         if (Now >= t1) and (Now <= t2) then
        begin
          p  := ColWidths[ocol] * ((Now - t1) / (t2 - t1));
          Canvas.Pen.Color := FPlanner.SideBar.TimeIndicatorColor;
          Canvas.Pen.Width := 4;
          Canvas.MoveTo(PRect.Left + Max(0,round(p) - 2), PRect.Top );
          Canvas.LineTo(PRect.Left + Max(0,round(p) - 2), PRect.Bottom);
          Canvas.Pen.Width := 1;
        end;
      end;

    end;

    if not print or (delta = 0) then
    begin
      DRect := ARect;
      if not print then
        DRect.Left := (AColumn - delta - LeftCol) * DefaultColWidth;

      Canvas.Pen.Color := FPlanner.GridLineColor;
      Canvas.MoveTo(DRect.Left - 1,ARect.Top);
      Canvas.LineTo(DRect.Left - 1,ARect.Bottom);
    end;

    ARect.Top := ARect.Top + (ARect.Bottom - ARect.Top) div 2;
    if FPlanner.Display.DisplayText >= 0 then
      Line2 := Line1;

    Line1 := '';
  end;


  { Special painting in case there is a Line1 }
  if (FPlanner.FMode.FPlannerType = plDay) or
     ((Line1 <> '') and not FPlanner.SideBar.RotateOnTop) then
  begin
    OnTheOur := False;
    OldSize := Canvas.Font.Size;
    Canvas.Font.Size := Round(Canvas.Font.Size * FPlanner.SideBar.HourFontRatio);

    try
      MajorLineWidth := Canvas.TextHeight(Line1);
      if FPlanner.FMode.FPlannerType = plDay then
      begin
        OnTheOur := Line2 = '00'; // Don't display hours if we are not 'on the hour'
        if Line3 <> '' then // There is an AM/PM, so concatenate it to the minutes
          Line2 := Line2 + RegularCRLF + Line3;
      end;

      HRect := ARect;

      if (FPlanner.FMode.FPlannerType = plDay) then
      begin
        Mins := (AColumn + FPlanner.Display.DisplayStart) * FPlanner.Display.DisplayUnit + FPlanner.Display.DisplayOffset;

        delta := round(((mins mod 60)/FPlanner.Display.DisplayUnit));

        if (delta > 0) then
          HRect.Left := HRect.Left - delta * DefColWidth;
      end;

      //if OnTheOur or HS then
      begin

        {$IFNDEF TMSDOTNET}
        DrawText(Canvas.Handle, PChar(Line1), Length(Line1), HRect,
          DT_NOPREFIX or DT_WORDBREAK or HorizontalAlign);
        {$ENDIF}
        {$IFDEF TMSDOTNET}
        DrawText(Canvas.Handle, Line1, Length(Line1), HRect,
          DT_NOPREFIX or DT_WORDBREAK or HorizontalAlign);
        {$ENDIF}

      end;


      if (AColumn > 0) and (AColumn <= ColCount - 1) and
        (FPlanner.FMode.FPlannerType = plDay) then
      begin
        Canvas.Pen.Color := FPlanner.SideBar.LineColor;

        if OnTheOur then
          Canvas.MoveTo(Arect.Left - 5,ARect.Bottom - 24)
        else
          Canvas.MoveTo(Arect.Left - 5,ARect.Bottom - 12);

        Canvas.LineTo(Arect.Left - 5,ARect.Bottom);
        {
        if OnTheOur then
          Canvas.MoveTo(Arect.Right + 3,ARect.Bottom - 24)
        else
          Canvas.MoveTo(Arect.Right+ 3,ARect.Bottom - 12);

        Canvas.LineTo(Arect.Right + 3,ARect.Bottom);
        }
      end;


      if (FPlanner.Sidebar.TimeIndicator) then
      begin
        FPlanner.CellToAbsTime(OCol, t1,t2);

        if (Frac(Now) >= Frac(t1)) and (Frac(Now) <= Frac(t2)) then
        begin
          p  := FPlanner.Display.DisplayScale * ((Frac(Now) - Frac(t1)) / (Frac(t2) - Frac(t1)));

          Canvas.Pen.Color := FPlanner.SideBar.TimeIndicatorColor;
          Canvas.Pen.Width := 4;
          Canvas.MoveTo(PRect.Left + round(p), PRect.Top);
          Canvas.LineTo(PRect.Left + round(p), PRect.Bottom);
          Canvas.Pen.Width := 1;
        end;
      end;

      ARect.Top := ARect.Top + MajorLineWidth;
    finally
      Canvas.Font.Size := OldSize;
    end;
  end
  else
  begin
    if (Line2 = '') then
      Line2 := Line1;
  end;

  { Painting }


  if Line2 <> '' then
    case FPlanner.FMode.FPlannerType of
      plDay, plWeek, plTimeLine:
        {$IFNDEF TMSDOTNET}
        DrawText(Canvas.Handle, PChar(Line2), Length(Line2), ARect,
          DT_NOPREFIX or DT_WORDBREAK or HorizontalAlign);
        {$ENDIF}
        {$IFDEF TMSDOTNET}
        DrawText(Canvas.Handle, Line2, Length(Line2), ARect,
          DT_NOPREFIX or DT_WORDBREAK or HorizontalAlign);
        {$ENDIF}
      plMonth, plDayPeriod, plHalfDayPeriod, plMultiMonth, plCustomList, plCustom:
        begin
          if FPlanner.SideBar.RotateOnTop then
          begin
            {$IFNDEF TMSDOTNET}
            GetObject(Canvas.Font.Handle, SizeOf(LFont), Addr(LFont));
            {$ENDIF}

            {$IFDEF TMSDOTNET}
            GetObject(Canvas.Font.Handle, Marshal.SizeOf(TypeOf(LFont)), LFont);
            {$ENDIF}

            LFont.lfEscapement := 90 * 10;
            LFont.lfOrientation := 90 * 10;
            if Print and FPlanner.FPrinterDriverFix then
            begin
              LFont.lfEscapement  := -LFont.lfEscapement;
              LFont.lfOrientation := -LFont.lfEscapement;
            end;
            HNewFont := CreateFontIndirect(LFont);
            HOldFont := SelectObject(Canvas.Handle, HNewFont);

            SetTextAlign(Canvas.Handle, TA_TOP);
          end;

          if MinorLineWidth >= ARect.Right - ARect.Left then
            MinorLineWidth := 0 // does not fit in the box, so left align
          else
          case HorizontalAlign of
            DT_LEFT:   MinorLineWidth := 0;
            DT_RIGHT:  MinorLineWidth := ARect.Right - ARect.Left - MinorLineWidth;
            DT_CENTER: MinorLineWidth := (ARect.Right - ARect.Left - MinorLineWidth) shr 1;
          end;

          try
            if FPlanner.SideBar.RotateOnTop then
            begin
              Canvas.Brush.Style := bsClear;

              if Line1 <> '' then
              begin
                Canvas.TextRect(ARect, ARect.Left + MinorLineWidth, ARect.Bottom - 4, Line1);
                ARect.Left := ARect.Left + Canvas.TextHeight('gh');
              end;

              Canvas.TextRect(ARect, ARect.Left + MinorLineWidth, ARect.Bottom - 4, Line2);
              ARect.Left := ARect.Left + Canvas.TextHeight('gh');
              if Line3 <> '' then
                Canvas.TextRect(ARect, ARect.Left + MinorLineWidth, ARect.Bottom - 4, Line3);

            end
            else
            begin
              SetBKMode(Canvas.Handle,TRANSPARENT);

              {$IFNDEF TMSDOTNET}
              DrawText(Canvas.Handle, PChar(Line2), Length(Line2), ARect,
                DT_NOPREFIX or DT_WORDBREAK or HorizontalAlign);
              {$ENDIF}
              {$IFDEF TMSDOTNET}
              DrawText(Canvas.Handle, Line2, Length(Line2), ARect,
                DT_NOPREFIX or DT_WORDBREAK or HorizontalAlign);
              {$ENDIF}


            end;

          finally
            { Cleanup }
            if FPlanner.FMode.FPlannerType in [plMonth, plDayPeriod, plHalfDayPeriod, plMultiMonth, plCustomList, plCustom] then
            begin
              if FPlanner.SideBar.RotateOnTop then
              begin
                HNewFont := SelectObject(Canvas.Handle, HOldFont);
                DeleteObject(HNewFont);
              end;
            end;
          end;
        end;
    end;
end;

procedure TPlannerGrid.DrawCell(AColumn, ARow: LongInt; ARect: TRect;
  AState: TGridDrawState);
begin
  if FPlanner.Sidebar.Orientation = soVertical then
    DrawCellCol(AColumn, ARow, ARect, AState)
  else
    DrawCellRow(AColumn, ARow, ARect, AState);
end;

procedure TPlannerGrid.DrawWallPaperFixed(CRect: TRect;xcorr,ycorr: Integer;BKColor:TColor);
var
  SrcRect,DsTRect,Irect: TRect;
  x,y,ox,oy: Integer;
  dst: TPoint;
begin
  dst.x := FPlanner.FBackground.Left;
  dst.y := FPlanner.FBackground.Top;
  
  x := FPlanner.FBackground.Bitmap.Width;
  y := FPlanner.FBackground.Bitmap.Height;

  DsTRect.Top := dst.y;
  DsTRect.Left := dst.x;
  DsTRect.Right := DsTRect.Left+x;
  DsTRect.Bottom := DsTRect.Top+y;

  if not IntersectRect(irect,crect,dsTRect) then
    Exit;

  SetBkMode(Canvas.Handle,TRANSPARENT);

  ox := crect.Left - dst.x;
  oy := crect.Top - dst.y;

  SrcRect.Left := ox;
  SrcRect.Top := oy;
  SrcRect.Right := ox + crect.Right - crect.Left;
  SrcRect.Bottom := oy + crect.Bottom - crect.Top;


  dst.x := dst.x - xcorr;
  dst.y := dst.y - ycorr;

  if dst.x < 0 then Exit;

  DsTRect := crect;

  if ox <= 0 then
  begin
    DsTRect.Left := dst.x;
    SrcRect.Left := 0;
    SrcRect.Right := DsTRect.Right-DsTRect.Left;
  end;

  if oy <= 0 then
  begin
    DsTRect.Top := dst.y;
    SrcRect.Top := 0;
    SrcRect.Bottom := DsTRect.Bottom-DsTRect.Top;
  end;

  if (SrcRect.Left + (DsTRect.Right - DsTRect.Left) > x) then
  begin
    DsTRect.Right := DsTRect.Left + x - SrcRect.Left;
    SrcRect.Right := x;
  end;

  if (SrcRect.Top + DsTRect.Bottom - DsTRect.Top > y) then
  begin
    DsTRect.Bottom := DsTRect.Top + y - SrcRect.Top;
    SrcRect.Bottom := y;
  end;

  Canvas.CopyRect(DstRect,FPlanner.FBackground.Bitmap.Canvas,SrcRect);
end;

procedure TPlannerGrid.DrawWallPaperTile(ACol,ARow:integer;crect:TRect;xCorr,yCorr:integer;BKColor:TColor);
var
  SrcRect,DsTRect:TRect;
  x,y,xo,yo,ox,oy,i: Integer;
  Bmp: TBitmap;
begin
  Bmp := FPlanner.FBackground.Bitmap;

  if FPlanner.SideBar.Position <> spTop then
  begin
    if (FPlanner.PositionProps.Count >= ACol) and (ACol > 0) then
    begin
      if (not FPlanner.PositionProps[ACol - 1].Background.Empty) and
        FPlanner.PositionProps[ACol - 1].Use then
        Bmp := FPlanner.PositionProps[ACol - 1].Background;
    end;
  end
  else
  begin
    if (FPlanner.PositionProps.Count >= ARow) and (ARow > 0) then
    begin
      if (not FPlanner.PositionProps[ARow - 1].Background.Empty) and
        FPlanner.PositionProps[ARow - 1].Use then
          Bmp := FPlanner.PositionProps[ARow - 1].Background;
    end;
  end;

  x := Bmp.Width;
  y := Bmp.Height;

  SetBkMode(Canvas.Handle,TRANSPARENT);

  if (FPlanner.FSidebar.Position = spLeft) and FPlanner.FSidebar.Visible then
    xo := 1
  else
    xo := 0;

  ox := 0;
  for i := xo + 1 to ACol do
    ox := ox + ColWidths[i - 1];

  yo := 0;
  oy := 0;
  for i := yo + 1 to ARow do
    oy := oy + RowHeights[i - 1];

  ox := ox + xCorr;
  oy := oy + yCorr;

  ox := ox mod x;
  oy := oy mod y;

  SrcRect.Left := ox;
  SrcRect.Top := oy;
  SrcRect.Right := x;
  SrcRect.Bottom := y;

  yo := cRect.Top;

  while yo < cRect.Bottom do
  begin
    xo := cRect.Left;
    SrcRect.Left := ox;
    SrcRect.Right := x;
    while xo < cRect.Right do
    begin
      DstRect := Rect(xo,yo,xo+SrcRect.Right-SrcRect.Left,yo+SrcRect.Bottom-SrcRect.Top);

      if DstRect.Right > crect.Right then
      begin
        DstRect.Right := crect.Right;
        SrcRect.Right := SrcRect.Left + (dstRect.Right - dstRect.Left);
      end;
      if DstRect.Bottom > crect.Bottom then
      begin
        DsTRect.Bottom := crect.Bottom;
        SrcRect.Bottom := SrcRect.Top + (dstRect.Bottom - dstRect.Top);
      end;

      Canvas.CopyRect(DsTRect,Bmp.Canvas,SrcRect);

      xo := xo + SrcRect.Right - SrcRect.Left;
      SrcRect.Left := 0;
      SrcRect.Right := x;
    end;
    yo := yo + SrcRect.Bottom-SrcRect.Top;
    SrcRect.Top := 0;          
    SrcRect.Bottom := y;
  end;
end;


procedure TPlannerGrid.DrawCellCol(AColumn, ARow: LongInt; ARect: TRect;
  AState: TGridDrawState);
var
  OldBrush: TBrush;
  OldFont: TFont;
  SubIndex, m: Integer;
  APlannerItem: TPlannerItem;
  NRect, r: TRect;
  NumberOfConflicts: TPoint;
  CellColor: TColor;
  CellBrush: TBrushStyle;
  Fixcol: Integer;
  ColOffset: Integer;
  {$IFNDEF TMSDOTNET}
  PlannerColorArrayPointer: PPlannerColorArray;
  {$ENDIF}
  {$IFDEF TMSDOTNET}
  PlannerColorArrayPointer: TPlannerColorArrayObject;
  {$ENDIF}
  BottomPen, RightPen: TPen;
  Occupied: Boolean;
  ABrush: TBrush;
  BkgFlag: Boolean;
  RGN: THandle;
  delta: Integer;
  dts,dte: TDateTime;
  bmp: TBitmap;
  selbkg: Boolean;
  AColorTo: TColor;
  UseColor: Boolean;
  sw,tzd: Integer;

begin
  ColOffset := FPlanner.FSidebar.FColOffset;

  if ColOffset = 0 then
    FixCol := ColCount - 1
  else
    FixCol := 0;

  OldFont := TFont.Create;
  OldFont.Assign(Canvas.Font);
  OldBrush := TBrush.Create;
  OldBrush.Assign(Canvas.Brush);

  UseColor := False;

  if (AColumn = FixCol) or
     ((FPlanner.PositionGap > 0) and (FPlanner.SideBar.ShowInPositionGap) and FPlanner.GapAtColumn(AColumn)) or
     ((AColumn = ColCount -1) and (FPlanner.SideBar.Position = spLeftRight) and FPlanner.SideBar.Visible) then
  begin
    // Draw the SideBar
    r := ARect;

    if (AColumn <> FixCol) and not
       ((AColumn = ColCount - 1) and (FPlanner.SideBar.Position = spLeftRight) and FPlanner.SideBar.Visible) then
    begin
      r.Right := r.Left + FPlanner.FPositionGap;
      ARect.Left := ARect.Left + FPlanner.FPositionGap;
    end;

    Canvas.Brush.Color := FPlanner.Sidebar.Background;
    AColorTo := FPlanner.SideBar.BackgroundTo;

    Canvas.Font.Assign(FPlanner.Sidebar.Font);

    if (Assigned(FPlanner.OnPlannerSideProp)) then
      FPlanner.OnPlannerSideProp(FPlanner, ARow, Canvas.Brush, Canvas.Font, AColorTo);

    if AColumn = FixCol then
      APlannerItem := FPlanner.Items.FindItemIdx(ARow)
    else
      APlannerItem := FPlanner.Items.FindItem(ARow, AColumn - ColOffset);

    Occupied := (APlannerItem <> nil) and FPlanner.Sidebar.ShowOccupied;

    if ((ARow >= Selection.Top) and (ARow <= Selection.Bottom) and (FPlanner.SideBar.ActiveColor <> clNone))
      and not (FPlanner.Sidebar.ShowInPositionGap and (AColumn > FixCol + 1))   then
    begin
//      if not FPlanner.SideBar.ShowInPositionGap or (AColumn = Selection.Left) then
      begin
        Canvas.Brush.Color := FPlanner.SideBar.ActiveColor;
        if FPlanner.SideBar.ActiveColorTo <> clNone then
          DrawGradient(Canvas, FPlanner.SideBar.ActiveColor, FPlanner.SideBar.ActiveColorTo, FPlanner.GradientSteps, r, true)
        else
          Canvas.FillRect(r);
      end;
    end
    else
    begin
      if Occupied  then
      begin
        if FPlanner.Sidebar.OccupiedTo = clNone then
        begin
          Canvas.Brush.Color := FPlanner.SideBar.Occupied;
          Canvas.FillRect(r);
        end
        else
          DrawGradient(Canvas,FPlanner.SideBar.Occupied,FPlanner.SideBar.OccupiedTo,FPlanner.GradientSteps,r,True);
      end
      else
      begin
        if FPlanner.SideBar.BackgroundTo <> clNone then
          DrawGradient(Canvas,Canvas.Brush.Color,AColorTo,FPlanner.GradientSteps,r,True)
        else
         Canvas.FillRect(r);
      end;
    end;

    if not FPlanner.SideBar.Flat then
      Frame3D(Canvas, r, clWhite, clGray,1);

    if FPlanner.SideBar.Border then
    begin
      Canvas.Pen.Color := clWhite;
      Canvas.MoveTo(r.Left,r.Top);
      Canvas.LineTo(r.Left,r.Bottom);

      if ARow = FPlanner.FGrid.TopRow then
      begin
        Canvas.MoveTo(r.Left,r.Top);
        Canvas.LineTo(r.Right,r.Top);
      end;

      Canvas.Pen.Color := clGray;
      Canvas.MoveTo(r.Right - 1,r.Top);
      Canvas.LineTo(r.Right - 1,r.Bottom);

      if ARow = FPlanner.FGrid.RowCount -1 then
      begin
        Canvas.MoveTo(r.Left,r.Bottom - 1);
        Canvas.LineTo(r.Right,r.Bottom - 1);
      end;
    end;

    Canvas.Pen.Color := FPlanner.SideBar.SeparatorLineColor;

    if not (FPlanner.FMode.FPlannerType in [plDay,plTimeLine,plHalfDayPeriod]) then
    begin
      Canvas.MoveTo(r.Left, r.Bottom -1);
      Canvas.LineTo(r.Right - 1, r.Bottom -1);
      Canvas.Pen.Color := clGray;
      Canvas.LineTo(r.Right - 1, r.Top);
    end;

    r.Left := r.Left + 4;
    r.Right := r.Right - 4;
    r.Top := r.Top + 1;
    r.Bottom := r.Bottom - 1;

    if Assigned(FPlanner.OnPlannerSideDraw) then
      FPlanner.OnPlannerSideDraw(FPlanner, Self.Canvas, ARect, ARow)
    else
    begin
      if (FPlanner.SideBar.ShowOtherTimeZone) and (FPlanner.Mode.PlannerType = plDay) then
      begin
        sw := (r.Right - r.Left) div 2;
        r.Right := r.Right - sw - 4;
        PaintSideCol(Canvas, r, ARow, AColumn, 0, Occupied, False);

        r.Right := r.Right + sw + 4;
        r.Left := r.Left + sw + 4;

        tzd := FPlanner.SideBar.TimeZoneMinDelta div FPlanner.Display.DisplayUnit;

        PaintSideCol(Canvas, r, ARow, AColumn, tzd, Occupied, False);

        Canvas.MoveTo(r.Left - 4, r.Top - 1);
        Canvas.LineTo(r.Left - 4, r.Bottom + 1);
        if Assigned(FPlanner.FOnPlannerSideDrawAfter) then
          FPlanner.FOnPlannerSideDrawAfter(Self, Canvas, ARect, ARow);
      end
      else
      begin
        PaintSideCol(Canvas, r, ARow, AColumn, 0, Occupied, False);

        if Assigned(FPlanner.FOnPlannerSideDrawAfter) then
          FPlanner.FOnPlannerSideDrawAfter(Self, Canvas, ARect, ARow);
      end;
    end;


    if (AColumn = 0) and (ARow = TopRow) and FPlanner.FTopIndicator then
    begin
      r := CellRect(0,0);
      Canvas.Brush.Color := clInfoBk;
      Canvas.Pen.Color := clBlack;
      Canvas.Pen.Width := 1;
      Canvas.Rectangle(r.Left,r.Top,r.Left + 22, r.Top + 10);
      Canvas.Brush.Color := clBlack;
      Canvas.Polygon([Point(r.Left + 4,r.Top + 2),Point(r.Left + 6,r.Top + 6),Point(r.Left + 2,r.Top + 6)]);
      Canvas.Rectangle(r.Left + 8,r.Top + 5,r.Left + 10,r.Top + 7);
      Canvas.Rectangle(r.Left + 12,r.Top + 5,r.Left + 14,r.Top + 7);
      Canvas.Rectangle(r.Left + 16,r.Top + 5,r.Left + 18,r.Top + 7);
    end;

    if (AColumn = 0) and (ARow = TopRow + VisibleRowCount - 1) and FPlanner.FBottomIndicator then
    begin
      Canvas.Brush.Color := clInfoBk;
      Canvas.Pen.Color := clBlack;
      Canvas.Pen.Width := 1;
      r := CellRect(0,ARow);
      Canvas.Rectangle(r.Left,r.Bottom - 10,r.Left + 22, r.Bottom);
      Canvas.Brush.Color := clBlack;
      Canvas.Polygon([Point(r.Left + 4,r.Bottom - 4),Point(r.Left + 6,r.Bottom - 8),Point(r.Left + 2,r.Bottom - 8)]);
      Canvas.Rectangle(r.Left + 8,r.Bottom - 5,r.Left + 10,r.Bottom - 3);
      Canvas.Rectangle(r.Left + 12,r.Bottom - 5,r.Left + 14,r.Bottom - 3);
      Canvas.Rectangle(r.Left + 16,r.Bottom - 5,r.Left + 18,r.Bottom - 3);
    end;
  end;

  if (AColumn <> FixCol) and not
     ((AColumn = ColCount -1) and (FPlanner.SideBar.Position = spLeftRight) and FPlanner.SideBar.Visible) then
  begin
    if (FPlanner.FPositionGap > 0) and FPlanner.GapAtColumn(Acolumn) and not FPlanner.SideBar.ShowInPositionGap then
    begin
      Canvas.Pen.Color := FPlanner.GridLineColor;
      Canvas.Pen.Width := 1;

      APlannerItem := FPlanner.Items.FindItem(ARow, AColumn - ColOffset);

      if (APlannerItem <> nil) and FPlanner.ShowOccupiedInPositionGap then
        Canvas.Brush.Color := FPlanner.FTrackColor
      else
        Canvas.Brush.Color := FPlanner.PositionGapColor;

      Canvas.FillRect(Rect(ARect.Left, ARect.Top, ARect.Left+FPlanner.FPositionGap,ARect.Bottom));

      ARect.Left := ARect.Left + FPlanner.FPositionGap;

      Canvas.MoveTo(ARect.Left - 1,ARect.Top);
      Canvas.LineTo(ARect.Left - 1,ARect.Bottom);
    end;

    { Draw the normal cells - set BackGround Color }

    ABrush := TBrush.Create;
    FPlanner.GetCellBrush(AColumn - ColOffset,ARow,ABrush);
    CellColor := ABrush.Color;
    CellBrush := ABrush.Style;
    ABrush.Free;

    if FPlanner.CellInCurrTime(ARow,AColumn) then
    begin
      CellColor := FPlanner.FDisplay.ColorCurrent;
      UseColor := True;
    end;  
    
    { Custom cell color }
    if (AColumn - ColOffset < FColorList.Count) and (AColumn - ColOffset >= 0) {and FPlanner.ShowSelection} and
      (ARow < NumColors) then
    begin
      PlannerColorArrayPointer := FColorList.Items[AColumn - ColOffset];

      {$IFNDEF TMSDOTNET}
      if PlannerColorArrayPointer^[ARow].Color <> clNone then
        CellColor := PlannerColorArrayPointer^[ARow].Color;

      if PlannerColorArrayPointer^[ARow].Selected > 0 then
      begin
        CellColor := BlendColor(FPlanner.DisjunctSelectColor, CellColor, FPlanner.FSelectBlend);
        UseColor := true;
      end;  
      {$ENDIF}

      {$IFDEF TMSDOTNET}
      if PlannerColorArrayPointer.Color[ARow] <> clNone then
        CellColor := PlannerColorArrayPointer.Color[ARow];

      if PlannerColorArrayPointer.Selected[ARow] > 0 then
      begin
        CellColor := BlendColor(FPlanner.DisjunctSelectColor, CellColor, FPlanner.FSelectBlend);
        UseColor := true;
      end;
      {$ENDIF}
    end;


    if (gdSelected in AState) and FPlanner.ShowSelection then
    begin
      CellBrush := bsSolid;
      // do color blend
      CellColor := BlendColor(FPlanner.FSelectColor,CellColor,FPlanner.FSelectBlend);
    end;

    Canvas.Brush.Color := CellColor;

    { Nr of Items at cell }
    NumberOfConflicts := FPlanner.Items.NumItem(ARow, ARow + 1, AColumn - ColOffset);

    r := ARect;

    BottomPen := TPen.Create;
    BottomPen.Assign(Canvas.Pen);

    BottomPen.Width := 1;
    BottomPen.Color := FPlanner.GridLineColor;

    if (FPlanner.Mode.PlannerType = plHalfDayPeriod) and (FPlanner.Mode.FullHalfDay) and not odd(ARow) then
    begin
      BottomPen.Color := CellColor;
    end;

    if (FPlanner.Mode.PlannerType = plDay) then
    begin
      if ((ARow + 1 + FPlanner.Display.DisplayStart) * FPlanner.Display.DisplayUnit mod 60 = 0) then
        BottomPen.Color := FPlanner.Display.HourLineColor;
    end;

    if Assigned(FPlanner.FOnPlannerBottomLine) then
      FPlanner.FOnPlannerBottomLine(Self, ARow, AColumn, BottomPen);

    { Draw Items / cell background }

    // if background item, draw first here

    APlannerItem := FPlanner.Items.FindBackground(ARow,AColumn - ColOffset);

    if Assigned(APlannerItem) then
    begin
      NRect.Top := ARect.Top - ((ARow - APlannerItem.ItemBegin) * (ARect.Bottom - ARect.Top));
      NRect.Bottom := ARect.Bottom + ((APlannerItem.ItemEnd - ARow - 1) * (ARect.Bottom - ARect.Top));
      NRect.Left := ARect.Left;
      NRect.Right := ARect.Right;

      RGN := CreateRectRgn(ARect.Left,ARect.Top,ARect.Right,ARect.Bottom);
      SelectClipRgn(Canvas.Handle,RGN);

      if AColumn > 0 then
        selbkg := FPlanner.Selected[AColumn - 1, ARow]
      else
        selbkg := false;

      PaintItemCol(Canvas, NRect, APlannerItem, False, (gdSelected in AState) or selbkg);

      // draw bottom line for background item if required
      if ARow = APlannerItem.ItemEnd -1 then
      begin
        Canvas.Pen.Assign(BottomPen);
        Canvas.MoveTo(ARect.Left,ARect.Bottom - 1);
        Canvas.LineTo(ARect.Right, ARect.Bottom - 1);
      end;

      APlannerItem.Repainted := False;

      SelectClipRgn(Canvas.Handle,0);
      DeleteObject(RGN);

      // make sure overlapping items are repainted  afterwards
      FPlanner.Items.ClearSelectedRepaints(ARow, AColumn - ColOffset);
    end;

    BkgFlag := Assigned(APlannerItem);

    for SubIndex := 1 to NumberOfConflicts.Y do
    begin
      ARect := r;
      m := (ARect.Right - ARect.Left) div NumberOfConflicts.Y;
      ARect.Left := ARect.Left + (SubIndex - 1) * m ;

//      if SubIndex = NumberOfConflicts.Y then
//        ARect.Right := r.Right
//      else
        ARect.Right := ARect.Left + m;

      APlannerItem := FPlanner.Items.FindItemIndex(ARow, AColumn - ColOffset, SubIndex - 1);

      // found item
      if (APlannerItem <> nil) then
      begin
        NRect.Top := ARect.Top - ((ARow - APlannerItem.ItemBegin) * (ARect.Bottom - ARect.Top));
        NRect.Bottom := ARect.Bottom + ((APlannerItem.ItemEnd - ARow - 1) * (ARect.Bottom - ARect.Top));

        NRect.Left := ARect.Left;
        NRect.Right := ARect.Right;

        if (APlannerItem.Shape = psHexagon) then
        begin
          RectHorzEx(Canvas, ARect, CellColor,FPlanner.Color, FPlanner.FGridLineColor, BottomPen.Color, BottomPen.Width,CellBrush);
          APlannerItem.Repainted := False;
        end;

        if ((APlannerItem.Shape in [
        {$IFDEF TMSSKINS}
            psSkin,
        {$ENDIF}
            psRounded, psHexagon]) and
           ((APlannerItem.ItemBegin = ARow) or (APlannerItem.ItemEnd = ARow)))
           or (APlannerItem.Shape = psTool)  then
        begin
          RectHorzEx(Canvas, ARect, CellColor,FPlanner.Color, FPlanner.FGridLineColor, BottomPen.Color, BottomPen.Width,CellBrush);
          APlannerItem.Repainted := False;
        end;

        // do precise time based adaption here
        if FPlanner.DrawPrecise then
        begin

          if FPlanner.Mode.PlannerType = plTimeLine then
          begin
            FPlanner.CellToAbsTime(APlannerItem.ItemBegin,dts,dte);
            delta := 0;
          end
          else
          begin
            delta := APlannerItem.ItemBeginPrecis - ((APlannerItem.ItemBegin + FPlanner.Display.DisplayStart) * FPlanner.Display.DisplayUnit);
            delta := round(delta / FPlanner.Display.DisplayUnit * FPlanner.Display.DisplayScale);
          end;

          if delta > 0 then
          begin
            if (APlannerItem.ItemBegin >= Selection.Top) and
               (APlannerItem.ItemBegin <= Selection.Bottom) and
               (APlannerItem.ItemPos + ColOffset >= Selection.Left) and
               (APlannerItem.ItemPos + ColOffset <= Selection.Right) then
               Canvas.Brush.Color := FPlanner.SelectColor
            else
              Canvas.Brush.Color := FPlanner.GetCellColorCol(AColumn - ColOffset,APlannerItem.ItemBegin, UseColor);

            Canvas.Pen.Color := Canvas.Brush.Color;
            Canvas.Rectangle(NRect.Left -1,NRect.Top,NRect.Right-1,NRect.Top + delta);
          end;

          NRect.Top := NRect.Top + delta;

          if FPlanner.Mode.PlannerType = plTimeLine then
          begin
            FPlanner.CellToAbsTime(APlannerItem.ItemBegin,dts,dte);
            delta := 0;
          end
          else
          begin
            delta := ((APlannerItem.ItemEnd + FPlanner.Display.DisplayStart)* FPlanner.Display.DisplayUnit) - APlannerItem.ItemEndPrecis;
            delta := round(delta / FPlanner.Display.DisplayUnit * FPlanner.Display.DisplayScale);
          end;

          if delta > 0 then
          begin
            inc(delta);

            if (APlannerItem.ItemEnd >= Selection.Top) and
               (APlannerItem.ItemEnd <= Selection.Bottom) then
               Canvas.Brush.Color := FPlanner.SelectColor
            else
              Canvas.Brush.Color := FPlanner.GetCellColorCol(AColumn - ColOffset,APlannerItem.ItemEnd, UseColor);

            Canvas.Brush.Color := CellColor;
            Canvas.Pen.Color := Canvas.Brush.Color;
            Canvas.Rectangle(NRect.Left - 1,NRect.Bottom - delta,NRect.Right - 1,NRect.Bottom - 1);
            Canvas.Pen.Color := FPlanner.GridLineColor;
            Canvas.MoveTo(NRect.Left,NRect.Bottom - 1);
            Canvas.LineTo(NRect.Right,NRect.Bottom - 1);
          end;

          NRect.Bottom := NRect.Bottom - delta;
        end;

        RGN := 0;

        if APlannerItem.Shape = psTool then
        begin
          RGN := CreateRectRgn(r.Left,r.Top,r.Right,r.Bottom);
          SelectClipRgn(Canvas.Handle,RGN);
        end;

        PaintItemCol(Canvas, NRect, APlannerItem, False, True);

        if APlannerItem.Shape = psTool then
        begin
          SelectClipRgn(Canvas.Handle,0);
          DeleteObject(RGN);
        end;

        // blend background items with selection here
        if (gdSelected in AState) and APlannerItem.Background and FPlanner.SelectBackground then
        begin
          bmp := TBitmap.Create;
          bmp.Width := NRect.Right - NRect.Left;
          bmp.Height := NRect.Bottom - NRect.Top;

          bmp.canvas.Brush.Color := FPlanner.SelectColor;
          bmp.Canvas.Rectangle(0,0,bmp.Width,bmp.Height);

          Canvas.CopyMode := cmSrcAnd;
          Canvas.Draw(NRect.Left,NRect.Top,bmp);
          bmp.Free;
        end;

        if FPlanner.TrackOnly then
        begin
          ARect.Right := ARect.Left +  FPlanner.TrackWidth + FPlanner.ItemGap;
        end;

        if not (APlannerItem.Background and not APlannerItem.AllowOverlap) then
          ARect.Left := ARect.Right - FPlanner.FItemGap
        else
          ARect.Left := ARect.Right;

        // Item found, paint only extra rect at Right
        if (not APlannerItem.Background or (SubIndex > 1)) and not BkgFlag then
        begin
          NRect := ARect;
          NRect.Left := ARect.Right - FPlanner.FItemGap;

          if SubIndex = NumberOfConflicts.Y then
            ARect.Right := r.Right + 1;

          if FPlanner.TrackOnly then
          begin
            NRect.Right := NRect.Left +  m - FPlanner.TrackWidth;
          end;

          if (SubIndex = NumberOfConflicts.Y) and (SubIndex > 1) then
            NRect.Right := r.Right;

          if (not FPlanner.Background.Bitmap.Empty) and not (gdSelected in AState) and not UseColor and FPlanner.IsActive(ARow,AColumn - 1) then
          begin
            if FPlanner.Background.Display = bdTile then
            begin
              DrawWallPaperTile(AColumn,ARow,NRect,NRect.Left - r.Left,0,CellColor);
              RectHorzEx(Canvas, NRect, clNone, FPlanner.Color, FPlanner.FGridLineColor, BottomPen.Color, BottomPen.Width,CellBrush);
            end
            else
            begin
              RectHorzEx(Canvas, NRect, CellColor, FPlanner.Color, FPlanner.FGridLineColor, BottomPen.Color, BottomPen.Width,CellBrush);
              DrawWallPaperFixed(NRect,NRect.Left - r.Left,0,CellColor);
              RectHorzEx(Canvas, NRect, clNone, FPlanner.Color, FPlanner.FGridLineColor, BottomPen.Color, BottomPen.Width, CellBrush);
            end;
          end
          else
          begin
            Canvas.Pen.Style := BottomPen.Style;
            RectHorzEx(Canvas, NRect, CellColor, FPlanner.Color, CellColor, BottomPen.Color, BottomPen.Width, CellBrush);
            Canvas.Pen.Style := psSolid;
          end;

          if (AColumn > 0) and (Assigned(FPlanner.OnPlannerBkgDraw)) then
          begin
            FPlanner.OnPlannerBkgDraw(FPlanner, Canvas, NRect, ARow, AColumn - 1);
          end;

        end;
      end
      else
      begin
        if not BkgFlag then
        begin
          NRect := ARect;
          if SuBIndex > 1 then
            NRect.Left := ARect.Left - 1
          else
            NRect.Left := ARect.Left;

          if SubIndex = NumberOfConflicts.Y then
            NRect.Right := r.Right + 1;

          if (not FPlanner.Background.Bitmap.Empty) and not (gdSelected in AState) and not UseColor and FPlanner.IsActive(ARow,AColumn - 1) then
          begin
            if FPlanner.Background.Display = bdTile then
            begin
              DrawWallPaperTile(AColumn, ARow, NRect, NRect.Left - r.Left, 0, CellColor);
              RectHorzEx(Canvas, NRect, clNone,FPlanner.Color, FPlanner.FGridLineColor, BottomPen.Color, BottomPen.Width, CellBrush);
            end
            else
            begin
              RectHorzEx(Canvas, NRect, CellColor,FPlanner.Color, FPlanner.FGridLineColor, BottomPen.Color, BottomPen.Width, CellBrush);
              DrawWallPaperFixed(NRect,NRect.Left - r.Left,0,CellColor);
              RectHorzEx(Canvas, NRect, clNone,FPlanner.Color, FPlanner.FGridLineColor, BottomPen.Color, BottomPen.Width, CellBrush);
            end;
          end
          else
          begin
            Canvas.Pen.Style := BottomPen.Style;
            RectHorzEx(Canvas, NRect, CellColor,FPlanner.Color, CellColor, BottomPen.Color, BottomPen.Width, CellBrush);
            Canvas.Pen.Style := psSolid;
          end;

          if (AColumn > 0) and (Assigned(FPlanner.OnPlannerBkgDraw)) then
          begin
            FPlanner.OnPlannerBkgDraw(FPlanner, Canvas, NRect, ARow, AColumn - 1);
          end;
        end;

      end;
    end;

    { Draws line on Top & Bottom of cell if no Items are present }
    if NumberOfConflicts.X = 0 then
    begin
      if (not FPlanner.Background.Bitmap.Empty) and not (gdSelected in AState) and not UseColor and FPlanner.IsActive(ARow,AColumn - 1) then
      begin
        if FPlanner.Background.Display = bdTile then
        begin
          DrawWallPaperTile(AColumn,ARow,ARect,0,0,CellColor);
          RectHorzEx(Canvas, ARect, clNone,FPlanner.Color, FPlanner.FGridLineColor, BottomPen.Color, BottomPen.Width, CellBrush);
        end
        else
        begin
          RectHorzEx(Canvas, ARect, CellColor, FPlanner.Color, FPlanner.FGridLineColor, BottomPen.Color, BottomPen.Width, CellBrush);
          DrawWallPaperFixed(ARect,0,0,CellColor);
          RectHorzEx(Canvas, ARect, clNone,FPlanner.Color, FPlanner.FGridLineColor, BottomPen.Color, BottomPen.Width, CellBrush);
        end;
      end
      else
      begin
        Canvas.Pen.Style := BottomPen.Style;
        RectHorzEx(Canvas, ARect, CellColor, FPlanner.Color, FPlanner.FGridLineColor, BottomPen.Color, BottomPen.Width, CellBrush);
        Canvas.Pen.Style := psSolid;
      end;
    end;

    BottomPen.Free;

    if (AColumn > 0) and (Assigned(FPlanner.OnPlannerBkgDraw)) then
    begin
      FPlanner.OnPlannerBkgDraw(FPlanner, Canvas, ARect, ARow, AColumn - 1);
    end;

    Canvas.Pen.Color := FPlanner.FGridLineColor;

    RightPen := TPen.Create;
    RightPen.Assign(Canvas.Pen);

    if Assigned(FPlanner.OnPlannerRightLine) then
      FPlanner.FOnPlannerRightLine(FPlanner, AColumn, ARow, RightPen);

    { Draw cell line at end of cell }
    if RightPen.Color <> clNone then
    begin
      Canvas.Pen.Color := RightPen.Color;
      Canvas.Pen.Width := RightPen.Width;
      Canvas.MoveTo(r.Right - 1, ARect.Top - 1);
      Canvas.LineTo(r.Right - 1, ARect.Bottom - 1);
    end;
    
    RightPen.Free;

  end;

  Canvas.Font.Assign(OldFont);
  Canvas.Brush.Assign(OldBrush);
  OldFont.Free;
  OldBrush.Free;
end;

procedure TPlannerGrid.DrawCellRow(AColumn, ARow: LongInt; ARect: TRect;
  AState: TGridDrawState);
var                                
  OldBrush: TBrush;
  OldFont: TFont;
  APlannerItem: TPlannerItem;
  NRect, r: TRect;
  NumberOfConflicts: TPoint;
  CellColor: TColor;
  CellBrush: TBrushStyle;
  FixRow, SubIndex, m: Integer;
  RowOffset: Integer;
  {$IFNDEF TMSDOTNET}
  PlannerColorArrayPointer: PPlannerColorArray;
  {$ENDIF}
  {$IFDEF TMSDOTNET}
  PlannerColorArrayPointer: TPlannerColorArrayObject;
  {$ENDIF}
  BottomPen, RightPen: TPen;
  Occupied: Boolean;
  ABrush: TBrush;
  BkgFlag: Boolean;
  RGN: THandle;
  delta: Integer;
  dts,dte: TDateTime;
  bmp: TBitmap;
  selbkg: Boolean;
  AColorTo: TColor;
  UseColor: Boolean;
begin
  RowOffset := FPlanner.FSidebar.FRowOffset;

  if RowOffset = 0 then
    FixRow := RowCount - 1
  else
    FixRow := 0;


  OldFont := TFont.Create;
  OldFont.Assign(Canvas.Font);
  OldBrush := TBrush.Create;
  OldBrush.Assign(Canvas.Brush);

  if (ARow = FixRow) and (FPlanner.SideBar.Visible) then
  begin
    Canvas.Brush.Color := FPlanner.Sidebar.Background;
    AColorTo := FPlanner.Sidebar.BackgroundTo;

    Canvas.Font.Assign(FPlanner.SideBar.Font);

    if Assigned(FPlanner.OnPlannerSideProp) then
      FPlanner.OnPlannerSideProp(FPlanner, AColumn, Canvas.Brush, Canvas.Font, AColorTo);

    APlannerItem := FPlanner.Items.FindItemIdx(AColumn);

    Occupied := False;

    if (APlannerItem <> nil) and FPlanner.Sidebar.ShowOccupied then
    begin
      Occupied := True;
      Canvas.Brush.Color := FPlanner.SideBar.Occupied;
      AColorTo := FPlanner.SideBar.OccupiedTo;
    end;

    if ((AColumn >= Selection.Left) and (AColumn <= Selection.Right) and (FPlanner.SideBar.ActiveColor <> clNone)) then
    begin
      Canvas.Brush.Color := FPlanner.SideBar.ActiveColor;
      if (AColorTo <> clNone) then
        DrawGradient(Canvas,FPlanner.SideBar.ActiveColor, FPlanner.SideBar.ActiveColorTo, FPlanner.GradientSteps, ARect, False)
      else
        Canvas.FillRect(ARect);
    end
    else
    begin
      if AColorTo <> clNone then
        DrawGradient(Canvas,Canvas.Brush.Color,AColorTo,FPlanner.GradientSteps,ARect,False)
      else
        Canvas.FillRect(ARect);
    end;    

    if not FPlanner.SideBar.Flat then
      Frame3D(Canvas,ARect,clWhite,clGray,1);

    if FPlanner.SideBar.Border then
    begin
      Canvas.Pen.Color := clWhite;
      Canvas.MoveTo(ARect.Left,ARect.Top);
      Canvas.LineTo(ARect.Right,ARect.Top);

      if AColumn = FPlanner.FGrid.LeftCol then
      begin
        Canvas.MoveTo(ARect.Left,ARect.Top);
        Canvas.LineTo(ARect.Left,ARect.Bottom);
      end;

      Canvas.Pen.Color := clGray;
      Canvas.MoveTo(ARect.Left,ARect.Bottom - 1);
      Canvas.LineTo(ARect.Right,ARect.Bottom - 1);

      if AColumn = FPlanner.FGrid.ColCount -1 then
      begin
        Canvas.MoveTo(ARect.Right - 1,ARect.Top);
        Canvas.LineTo(ARect.Right - 1,ARect.Bottom);
      end;
    end;

    if not (FPlanner.FMode.FPlannerType in [plDay,plTimeLine,plHalfDayPeriod]) then
    begin
      Canvas.Pen.Color := clGray;
      Canvas.MoveTo(ARect.Left, ARect.Bottom - 1);
      Canvas.LineTo(ARect.Right - 1, ARect.Bottom - 1);
      Canvas.Pen.Color := FPlanner.Sidebar.SeparatorLineColor;
      Canvas.LineTo(ARect.Right - 1, ARect.Top);
    end;

    r := ARect;

    ARect.Left := ARect.Left + 4;
    ARect.Right := ARect.Right - 4;
    ARect.Top := ARect.Top + 1;
    ARect.Bottom := ARect.Bottom - 1;

    Canvas.Pen.Color := FPlanner.SideBar.SeparatorLineColor;

    if Assigned(FPlanner.OnPlannerSideDraw) then
      FPlanner.OnPlannerSideDraw(FPlanner, Canvas, ARect, AColumn)
    else
    begin
      PaintSideRow(Canvas, ARect, AColumn, ARow, Occupied, False, DefaultColWidth);
      if Assigned(FPlanner.FOnPlannerSideDrawAfter) then
        FPlanner.FOnPlannerSideDrawAfter(Self, Canvas, ARect, AColumn);
    end;


    if (ARow = 0) and (AColumn = LeftCol) and FPlanner.FTopIndicator then
    begin
      Canvas.Brush.Color := clInfoBk;
      Canvas.Pen.Color := clBlack;
      Canvas.Pen.Width := 1;
      Canvas.Rectangle(r.Left,r.Top,r.Left + 22, r.Top + 10);
      Canvas.Brush.Color := clBlack;
      Canvas.Polygon([Point(r.Left + 2,r.Top + 4),Point(r.Left + 4,r.Top + 2),Point(r.Left + 4,r.Top + 6)]);
      Canvas.Rectangle(r.Left + 8,r.Top + 5,r.Left + 10,r.Top + 7);
      Canvas.Rectangle(r.Left + 12,r.Top + 5,r.Left + 14,r.Top + 7);
      Canvas.Rectangle(r.Left + 16,r.Top + 5,r.Left + 18,r.Top + 7);
    end;

    if (ARow = 0) and (AColumn = LeftCol + VisibleColCount - 1) and FPlanner.FBottomIndicator then
    begin
      Canvas.Brush.Color := clInfoBk;
      Canvas.Pen.Color := clBlack;
      Canvas.Pen.Width := 1;
      r := CellRect(AColumn,0);
      r.Bottom := r.Top + 10;
      // Canvas.Rectangle(r.Left,r.Top,r.Left + 22, r.Top + 10);

      Canvas.Rectangle(r.Right - 24,r.Top,r.Right - 2, r.Top + 10);
      Canvas.Brush.Color := clBlack;
      Canvas.Polygon([Point(r.Right - 6,r.Top + 4),Point(r.Right - 8,r.Top + 2),Point(r.Right - 8,r.Top + 6)]);
      Canvas.Rectangle(r.Right - 10,r.Bottom - 5,r.Right - 12,r.Bottom - 3);
      Canvas.Rectangle(r.Right - 14,r.Bottom - 5,r.Right - 16,r.Bottom - 3);
      Canvas.Rectangle(r.Right - 18,r.Bottom - 5,r.Right - 20,r.Bottom - 3);
    end;

  end
  else
  begin
    { Determine the cell background Color first }

    ABrush := TBrush.Create;
    FPlanner.GetCellBrush(ARow - RowOffset, AColumn,ABrush);
    CellColor := ABrush.Color;
    CellBrush := ABrush.Style;
    ABrush.Free;

    if FPlanner.CellInCurrTime(AColumn,ARow) then
      CellColor := FPlanner.FDisplay.ColorCurrent;

    if (ARow - RowOffset < FColorList.Count) and (ARow - RowOffset >= 0) {and FPlanner.ShowSelection} and (AColumn < NumColors) then
    begin
      PlannerColorArrayPointer := FColorList.Items[ARow - RowOffset];

      {$IFNDEF TMSDOTNET}
      if PlannerColorArrayPointer^[AColumn].Color <> clNone then
        CellColor := PlannerColorArrayPointer^[AColumn].Color;

      if PlannerColorArrayPointer^[AColumn].Selected > 0 then
        CellColor := BlendColor(FPlanner.DisjunctSelectColor, CellColor, FPlanner.FSelectBlend);
      {$ENDIF}
      {$IFDEF TMSDOTNET}
      if PlannerColorArrayPointer.Color[AColumn] <> clNone then
        CellColor := PlannerColorArrayPointer.Color[AColumn];

      if PlannerColorArrayPointer.Selected[AColumn] > 0 then
        CellColor := BlendColor(FPlanner.DisjunctSelectColor, CellColor, FPlanner.FSelectBlend);
      {$ENDIF}
    end;

    if (gdSelected in AState) and FPlanner.ShowSelection then
    begin
      CellColor := BlendColor(FPlanner.FSelectColor,CellColor,FPlanner.FSelectBlend);
    end;

    { End of setting cell background Color }
    NumberOfConflicts := FPlanner.Items.NumItem(AColumn, AColumn + 1, ARow - RowOffset);



    r := ARect;

    BottomPen := TPen.Create;
    BottomPen.Assign(Canvas.Pen);

    BottomPen.Width := 1;
    BottomPen.Color := FPlanner.GridLineColor;

    if (FPlanner.Mode.PlannerType = plHalfDayPeriod) and (FPlanner.Mode.FullHalfDay) and not odd(AColumn) then
    begin
      BottomPen.Color := CellColor;
    end;

    if (FPlanner.Mode.PlannerType = plDay) then
    begin
      if ((AColumn + 1 + FPlanner.Display.DisplayStart) * FPlanner.Display.DisplayUnit mod 60 = 0) then
        BottomPen.Color := FPlanner.Display.HourLineColor;
    end;

    if Assigned(FPlanner.FOnPlannerBottomLine) then
      FPlanner.FOnPlannerBottomLine(Self, AColumn, ARow, BottomPen);

    Canvas.Brush.Color := CellColor;

    // if background item, draw first here
    APlannerItem := FPlanner.Items.FindBackground(AColumn,ARow - RowOffset);

    if Assigned(APlannerItem) then
    begin
      NRect.Left := ARect.Left - ((AColumn - APlannerItem.ItemBegin) * (ARect.Right -
        ARect.Left));
      NRect.Right := ARect.Right + ((APlannerItem.ItemEnd - AColumn - 1) * (ARect.Right -
        ARect.Left));
      NRect.Top := ARect.Top;
      NRect.Bottom := ARect.Bottom;

      RGN := CreateRectRgn(ARect.Left,ARect.Top,ARect.Right,ARect.Bottom);
      SelectClipRgn(Canvas.Handle,RGN);

      if ARow > 0 then
        selbkg := FPlanner.Selected[AColumn,ARow - 1]
      else
        selbkg := false;

      PaintItemRow(Canvas, NRect, APlannerItem, False, (gdSelected in AState) or selbkg);

      // draw bottom line for background item if required
      if ARow = APlannerItem.ItemEnd -1 then
      begin
        Canvas.Pen.Assign(BottomPen);
        Canvas.MoveTo(ARect.Right - 1,ARect.Top);
        Canvas.LineTo(ARect.Right - 1, ARect.Bottom-1);
      end;

      APlannerItem.Repainted := False;

      SelectClipRgn(Canvas.Handle,0);
      DeleteObject(RGN);

      // make sure overlapping items are repainted  afterwards
      FPlanner.Items.ClearSelectedRepaints(AColumn, ARow - RowOffset);
    end;

    BkgFlag := Assigned(APlannerItem);

    for SubIndex := 1 to NumberOfConflicts.Y do
    begin
      ARect := r;
      m := (ARect.Bottom - ARect.Top) div (NumberOfConflicts.Y) + 1;
      ARect.Top := ARect.Top + (SubIndex - 1) * m;
      ARect.Bottom := ARect.Top + m;

      APlannerItem := FPlanner.Items.FindItemIndex(AColumn, ARow - RowOffset, SubIndex - 1);

      if (APlannerItem <> nil) then
      begin
        NRect.Left := ARect.Left - ((AColumn - APlannerItem.ItemBegin) * (ARect.Right -
          ARect.Left));
        NRect.Right := ARect.Right + ((APlannerItem.ItemEnd - AColumn - 1) * (ARect.Right -
          ARect.Left));
        NRect.Top := ARect.Top+1;
        NRect.Bottom := ARect.Bottom;

        if ((APlannerItem.Shape in [psRounded,psHexagon
        {$IFDEF TMSSKINS}
           ,psSkin
        {$ENDIF}   
           ]) and
           ((APlannerItem.ItemBegin = AColumn) or (APlannerItem.ItemEnd = AColumn + 1)))
           or (APlannerItem.Shape = psTool) then
        begin
          RectVertEx(Canvas, ARect, CellColor, FPlanner.Color, BottomPen.Color, BottomPen.Width, CellBrush);
          APlannerItem.Repainted := False;
        end;

        if FPlanner.DrawPrecise then
        begin

          if FPlanner.Mode.PlannerType = plTimeLine then
          begin
            FPlanner.CellToAbsTime(APlannerItem.ItemBegin,dts,dte);
            delta := 0;
          end
          else
          begin
            delta := APlannerItem.ItemBeginPrecis - ((APlannerItem.ItemBegin + FPlanner.Display.DisplayStart) * FPlanner.Display.DisplayUnit);
            delta := round(delta / FPlanner.Display.DisplayUnit * FPlanner.Display.DisplayScale);
          end;

          if delta > 0 then
          begin
            if (APlannerItem.ItemBegin >= Selection.Left) and
               (APlannerItem.ItemBegin <= Selection.Right) and
               (APlannerItem.ItemPos + RowOffset >= Selection.Top) and
               (APlannerItem.ItemPos + RowOffset <= Selection.Bottom) then
               Canvas.Brush.Color := FPlanner.SelectColor
            else
              Canvas.Brush.Color := FPlanner.GetCellColorCol(ARow - RowOffset,APlannerItem.ItemBegin, UseColor);

            Canvas.Pen.Color := Canvas.Brush.Color;
            Canvas.Rectangle(NRect.Left,NRect.Top,NRect.Left + delta,NRect.Bottom);
          end;

          NRect.Left := NRect.Left + delta;

          delta := ((APlannerItem.ItemEnd + FPlanner.Display.DisplayStart)  * FPlanner.Display.DisplayUnit) - APlannerItem.ItemEndPrecis;
          delta := round(delta / FPlanner.Display.DisplayUnit * FPlanner.Display.DisplayScale);

          if delta > 0 then
          begin
            inc(delta);

            Canvas.Brush.Color := CellColor;
            Canvas.Pen.Color := Canvas.Brush.Color;
            Canvas.Rectangle(NRect.Right - delta,NRect.Top, NRect.Right - 1, NRect.Bottom);

            Canvas.Pen.Color := FPlanner.GridLineColor;
            Canvas.MoveTo(NRect.Right - 1,NRect.Top);
            Canvas.LineTo(NRect.Right - 1,NRect.Bottom);
          end;

          NRect.Right := NRect.Right - delta;
        end;

        NRect.Top := NRect.Top - 1;
        PaintItemRow(Canvas, NRect, APlannerItem, False, true);
        NRect.Top := NRect.Top + 1;

        // blend background items with selection here
        if (gdSelected in AState) and APlannerItem.Background and FPlanner.SelectBackground then
        begin
          bmp := TBitmap.Create;
          bmp.Width := NRect.Right - NRect.Left;
          bmp.Height := NRect.Bottom - NRect.Top;

          bmp.canvas.Brush.Color := FPlanner.SelectColor;
          bmp.Canvas.Rectangle(0,0,bmp.Width,bmp.Height);

          Canvas.CopyMode := cmSrcAnd;
          Canvas.Draw(NRect.Left,NRect.Top,bmp);
          bmp.Free;
        end;


        NRect.Left := ARect.Left;
        NRect.Right := ARect.Right;


        if FPlanner.TrackOnly then
        begin
          if SubIndex = NumberOfConflicts.Y then // last item of conflicting items
            ARect.Bottom := ARect.Top +  FPlanner.TrackWidth + FPlanner.ItemGap + 1
          else
            ARect.Bottom := ARect.Top +  FPlanner.TrackWidth + FPlanner.ItemGap
        end;

        if not (APlannerItem.Background and not APlannerItem.AllowOverlap) then
          NRect.Top := ARect.Bottom - FPlanner.FItemGap - 1
        else
          NRect.Top := ARect.Bottom - 1;

        if FPlanner.TrackOnly then
        begin
          if SubIndex = NumberOfConflicts.Y then // last item of conflicting items
            NRect.Bottom := NRect.Top +  m - FPlanner.TrackWidth + 2
          else
            NRect.Bottom := NRect.Top +  m - FPlanner.TrackWidth + 1;
        end
        else
        begin
          if SubIndex = NumberOfConflicts.Y then
            NRect.Bottom := ARect.Bottom + 1
          else
            NRect.Bottom := ARect.Bottom;
        end;


        if not BkgFlag then
        begin
          if (not FPlanner.Background.Bitmap.Empty) and not (gdSelected in AState) and FPlanner.IsActive(AColumn,ARow) then
          begin
            if FPlanner.Background.Display = bdTile then
            begin
              DrawWallPaperTile(AColumn,ARow,NRect,0,NRect.Top - r.Top,CellColor);
              RectVertEx(Canvas, NRect, clNone,FPlanner.Color, BottomPen.Color, BottomPen.Width, CellBrush);
            end
            else
            begin
              RectVertEx(Canvas, NRect, CellColor, FPlanner.Color, BottomPen.Color, BottomPen.Width, CellBrush);
              DrawWallPaperFixed(NRect,0,0,CellColor);
              RectVertEx(Canvas, NRect, clNone, FPlanner.Color, BottomPen.Color, BottomPen.Width, CellBrush);
            end;
          end
          else
          begin
            Canvas.Pen.Style := BottomPen.Style;
            RectVertEx(Canvas, NRect, CellColor, FPlanner.Color, BottomPen.Color, BottomPen.Width, CellBrush);
            Canvas.Pen.Style := psSolid;
          end;

          if (ARow > 0) and (Assigned(FPlanner.OnPlannerBkgDraw)) then
          begin
            FPlanner.OnPlannerBkgDraw(FPlanner, Canvas, NRect, AColumn, ARow - 1);
          end;
        end;
      end
      else
      begin
        if not BkgFlag then
        begin
          if (not FPlanner.Background.Bitmap.Empty) and not (gdSelected in AState) and FPlanner.IsActive(AColumn,ARow) then
          begin
            if FPlanner.Background.Display = bdTile then
            begin
              DrawWallPaperTile(AColumn,ARow,ARect,0,ARect.Top - r.Top,CellColor);
              RectVertEx(Canvas, ARect, clNone, FPlanner.Color, BottomPen.Color, BottomPen.Width, CellBrush);
            end
            else
            begin
              RectVertEx(Canvas, ARect, CellColor, FPlanner.Color, BottomPen.Color, BottomPen.Width, CellBrush);
              DrawWallPaperFixed(ARect,0,0,CellColor);
              RectVertEx(Canvas, ARect, clNone, FPlanner.Color, BottomPen.Color, BottomPen.Width, CellBrush);
            end;
          end
          else
          begin
            Canvas.Pen.Style := BottomPen.Style;
            RectVertEx(Canvas, ARect, CellColor, FPlanner.Color, BottomPen.Color, BottomPen.Width, CellBrush);
            Canvas.Pen.Style := psSolid;
          end;  

          if (ARow > 0) and (Assigned(FPlanner.OnPlannerBkgDraw)) then
          begin
            FPlanner.OnPlannerBkgDraw(FPlanner, Canvas, ARect, AColumn , ARow - 1);
          end;
        end;
      end;
    end;

    if (NumberOfConflicts.Y = 0) and not BkgFlag then
    begin
      if (not FPlanner.Background.Bitmap.Empty) and not (gdSelected in AState) and FPlanner.IsActive(AColumn, ARow) then
      begin
        if FPlanner.Background.Display = bdTile then
        begin
          DrawWallPaperTile(AColumn,ARow,ARect,0,0,CellColor);
          RectVertEx(Canvas, ARect, clNone, FPlanner.Color, BottomPen.Color, BottomPen.Width, CellBrush);
        end
        else
        begin
          RectVertEx(Canvas, ARect, CellColor, FPlanner.Color, BottomPen.Color, BottomPen.Width, CellBrush);
          DrawWallPaperFixed(ARect,0,0,CellColor);
          RectVertEx(Canvas, ARect, clNone, FPlanner.Color, BottomPen.Color, BottomPen.Width, CellBrush);
        end;
      end
      else
      begin
        Canvas.Pen.Style := BottomPen.Style;
        RectVertEx(Canvas, ARect, CellColor, FPlanner.Color, BottomPen.Color, BottomPen.Width, CellBrush);
        Canvas.Pen.Style := psSolid;
      end;

      if (ARow > 0) and (Assigned(FPlanner.OnPlannerBkgDraw)) then
      begin
        FPlanner.OnPlannerBkgDraw(FPlanner, Canvas, ARect, AColumn, ARow - 1);
      end;
    end;

    BottomPen.Free;

    ARect := r;

    Canvas.Pen.Color := FPlanner.FGridLineColor;

    RightPen := TPen.Create;
    RightPen.Assign(Canvas.Pen);

    if Assigned(FPlanner.OnPlannerRightLine) then
      FPlanner.FOnPlannerRightLine(FPlanner, ARow, AColumn, RightPen);

    if (RightPen.Color <> clNone) then
    begin
      Canvas.Pen.Width := RightPen.Width;
      Canvas.Pen.Color := RightPen.Color;
      Canvas.MoveTo(ARect.Left, ARect.Top);
      Canvas.LineTo(ARect.Right, ARect.Top);
      if (ARow = RowCount - 1) then
      begin
        Canvas.MoveTo(ARect.Left, ARect.Bottom - 1);
        Canvas.LineTo(ARect.Right, ARect.Bottom - 1);
      end;
    end;

    RightPen.Free;
  end;

  Canvas.Font.Assign(OldFont);
  Canvas.Brush.Assign(OldBrush);
  OldFont.Free;
  OldBrush.Free;
end;

procedure TPlannerGrid.DragDrop(Source: TObject; X, Y: Integer);
var
  Point: TPoint;
  ColOffset, RowOffset: Integer;
  GridRect: TRect;
  GridCoord: TGridCoord;
  APlannerItem: TPlannerItem;
begin

  ColOffset := FPlanner.FSidebar.FColOffset;
  RowOffset := FPlanner.FSidebar.FRowOffset;

  GridCoord := mousecoord(X, Y);
  GridRect := CellRectEx(GridCoord.X, GridCoord.Y);

  if FPlanner.Sidebar.Orientation = soVertical then
  begin
    APlannerItem := FPlanner.Items.FindItemPos(GridCoord.Y - RowOffset,
      GridCoord.X - ColOffset, X - GridRect.Left);
  end
  else
  begin
    APlannerItem := FPlanner.Items.FindItemPos(GridCoord.X - ColOffset, GridCoord.Y - RowOffset,
      Y - GridRect.Top);
  end;

  if Assigned(FPlanner.FOnDragDrop) then
    FPlanner.FOnDragDrop(FPlanner, Source, X, Y);

  Point := FPlanner.XYToCell(X, Y);

  if Assigned(FPlanner.FOnDragDropCell) then
  begin
    FPlanner.FOnDragDropCell(FPlanner, Source, Point.X, Point.Y);
  end;

  if Assigned(APlannerItem) then
  begin
    if Assigned(FPlanner.FOnDragDropItem) then
      FPlanner.FOnDragDropItem(FPlanner, Source, GridCoord.X, GridCoord.Y - RowOffset, APlannerItem);
  end;

  if Source = FPlanner.FHeader then
  begin
    FPlanner.FHeader.FDragItem.Inheader := False;
    if FPlanner.Sidebar.Position = spLeft then
    begin
      FPlanner.FHeader.FDragItem.ItemBegin := Point.Y;
      FPlanner.FHeader.FDragItem.ItemEnd := Point.Y + 1;
      FPlanner.FHeader.FDragItem.ItemPos := Point.X;
    end
    else
    begin
      FPlanner.FHeader.FDragItem.ItemBegin := Point.X;
      FPlanner.FHeader.FDragItem.ItemEnd := Point.X + 1;
      FPlanner.FHeader.FDragItem.ItemPos := Point.Y;
    end;

    FPlanner.FHeader.FDragItem.Update;

    Exit;
  end;

end;

procedure TPlannerGrid.DragOver(Source: TObject; X, Y: Integer;
  State: TDragState; var Accept: Boolean);
var
  GridCoord: TGridCoord;
  APlannerItem: TPlannerItem;
  ColOffset, RowOffset: Integer;
  GridRect: TRect;
begin
  Accept := False;
  inherited;

  GridCoord := MouseCoord(X, Y);

  if (Source = FPlanner.FHeader) then
    Accept := true;


  if Assigned(FPlanner.FOnDragOver) then
  begin
    Accept := True;
    FPlanner.FOnDragOver(FPlanner, Source, X, Y, State, Accept);
  end;

  if Assigned(FPlanner.FOnDragOverCell) then
  begin
    Accept := True;
    if (FPlanner.FSidebar.Visible) and (FPlanner.FSidebar.Position in [spLeft, spLeftRight]) then
      GridCoord.X := GridCoord.X - 1;
    if (FPlanner.FSidebar.Visible) and (FPlanner.Sidebar.Position = spTop) then
      GridCoord.Y := GridCoord.Y - 1;
    FPlanner.FOnDragOverCell(FPlanner, Source, GridCoord.X, GridCoord.Y, State, Accept);
  end;

  ColOffset := FPlanner.FSidebar.FColOffset;
  RowOffset := FPlanner.FSidebar.FRowOffset;

  GridCoord := MouseCoord(X, Y);
  GridRect := CellRectEx(GridCoord.X, GridCoord.Y);

  if FPlanner.Sidebar.Orientation = soVertical then
  begin
    APlannerItem := FPlanner.Items.FindItemPos(GridCoord.Y - RowOffset, GridCoord.X - ColOffset, X - GridRect.Left);
  end
  else
  begin
    APlannerItem := FPlanner.Items.FindItemPos(GridCoord.X - ColOffset, GridCoord.Y - RowOffset, 1);
  end;

  if Assigned(APlannerItem) then
  begin
    if Assigned(FPlanner.FOnDragOverItem) then
      FPlanner.FOnDragOverItem(Self, Source, GridCoord.X, GridCoord.Y, APlannerItem, State, Accept);
  end;
end;

function TPlannerGrid.GetHScrollSize: Integer;
begin
  Result := 0;

  if (VisibleRowCount < RowCount) {and not (Scrollbars in [ssNone, ssHorizontal])} then
  begin
    Result := GetSystemMetrics(SM_CXVSCROLL);
  end;
end;

function TPlannerGrid.GetVScrollSize: Integer;
begin
  Result := 0;
  if (VisibleColCount < ColCount) {and not (Scrollbars in [ssNone, ssVertical])} then
  begin
    Result := GetSystemMetrics(SM_CYHSCROLL);
  end;
end;

procedure TPlannerGrid.UpdatePositions;
var
  ColumnIndex: Integer;
  ItemIndex: Integer;
  SectionIndex: Integer;
  ColumnWidth, j, bw: Integer;
  ColOffset, RowOffset: Integer;
  poswi: SmallInt;

begin
  if csLoading in FPlanner.ComponentState then
    Exit;
  if FPlanner.Positions = 0 then
    Exit;

{$IFDEF TMSCODESITE}
  CodeSite.SendMsg(Format('Updatepositions : %d * %d', [FPlanner.Positions, ColCount]));
{$ENDIF}

  ColOffset := FPlanner.FSidebar.FColOffset;
  RowOffset := FPlanner.FSidebar.FRowOffset;

  if FPlanner.Flat then
    bw := 1
  else
    bw := 5;

  if FPlanner.Sidebar.Orientation = soVertical then
  begin
    if ColCount < FPlanner.Positions + ColOffset then
      ColCount := FPlanner.Positions + ColOffset;

    if FPlanner.SideBar.Visible then
      ColumnWidth := FPlanner.FSidebar.Width
    else
      ColumnWidth := 0;

    case FPlanner.SideBar.Position of
    spLeft:
      begin
        ColumnWidth := Self.Width - ColumnWidth - GetHScrollSize - bw;
        ColumnWidth := ColumnWidth div FPlanner.Positions;
      end;
    spRight:
      begin
        ColumnWidth := Self.Width - ColumnWidth - GetHScrollSize - bw;
        ColumnWidth := ColumnWidth div FPlanner.Positions;
        ColWidths[ColCount - 1] := FPlanner.FSidebar.Width;
      end;
    spLeftRight:
      begin
        ColumnWidth := Self.Width - 2 * ColumnWidth - GetHScrollSize - bw;
        ColumnWidth := ColumnWidth div FPlanner.Positions;
        ColWidths[ColCount - 1] := FPlanner.FSidebar.Width;
      end
    else
    begin
      ColumnWidth := Self.Width - ColumnWidth - GetHScrollSize - bw;
      ColumnWidth := ColumnWidth div FPlanner.Positions;
    end;
    end;

    FPosResizing := True;
    DefaultRowHeight := FPlanner.FDisplay.FDisplayScale;
    FPosResizing := False;

    if FPlanner.FPositionWidth <> 0 then
      ColumnWidth := FPlanner.FPositionWidth;

    if not FPlanner.FNoPositionSize then
      for ColumnIndex := ColOffset to FPlanner.Positions + ColOffset - 1 do
        if (ColumnIndex < ColCount) then
          ColWidths[ColumnIndex] := ColumnWidth;
  end
  else
  begin
    if RowOffset = 1 then
    begin
      if FPlanner.FSidebar.Visible then
        RowHeights[0] := FPlanner.FSidebar.Width
      else
        RowHeights[0] := 0;

      ColumnWidth := Self.Height - RowHeights[0] - GetVScrollSize - bw;
      ColumnWidth := ColumnWidth div FPlanner.Positions;
    end
    else
    begin
      ColumnWidth := Self.Height - GetVScrollSize - 10 - FPlanner.FSidebar.Width;
      ColumnWidth := ColumnWidth div FPlanner.Positions;
      RowHeights[RowCount - 1] := FPlanner.FSidebar.Width;
    end;

    FPosResizing := True;
    DefaultColWidth := FPlanner.FDisplay.FDisplayScale;
    FPosResizing := False;

    if FPlanner.FPositionWidth <> 0 then
      ColumnWidth := FPlanner.FPositionWidth;

    if not FPlanner.FNoPositionSize then
      for ItemIndex := RowOffset to FPlanner.Positions + RowOffset - 1 do
        RowHeights[ItemIndex] := ColumnWidth;
  end;

  for ItemIndex := 0 to FPlanner.Items.Count-1 do
    (FPlanner.Items.Items[ItemIndex] as TPlannerItem).UpdateWnd;

  poswi := 0;

  if FPlanner.Sidebar.Visible then
    Inc(poswi);

  while (FPlanner.FHeader.Sections.Count < FPlanner.Positions + poswi + 1) do
    FPlanner.FHeader.Sections.Add('');

  while (FPlanner.FHeader.Sections.Count > FPlanner.Positions + poswi + 1) do
    FPlanner.FHeader.Sections.Delete(FPlanner.FHeader.Sections.Count - 1);

  while (FPlanner.FFooter.Sections.Count < FPlanner.Positions + poswi + 1) do
    FPlanner.FFooter.Sections.Add('');

  while (FPlanner.FFooter.Sections.Count > FPlanner.Positions + poswi + 1) do
    FPlanner.FFooter.Sections.Delete(FPlanner.FFooter.Sections.Count - 1);


  for SectionIndex := 0 to FPlanner.FHeader.Sections.Count - 1 do
  begin

    if SectionIndex < FPlanner.FPlannerHeader.Captions.Count then
      FPlanner.FHeader.Sections[SectionIndex] :=
        FPlanner.FPlannerHeader.Captions.Strings[SectionIndex]
    else
      FPlanner.FHeader.Sections[SectionIndex] := '';

    if SectionIndex < FPlanner.FPlannerFooter.Captions.Count then
      FPlanner.FFooter.Sections[SectionIndex] :=
        FPlanner.FPlannerFooter.Captions.Strings[SectionIndex]
    else
      FPlanner.FFooter.Sections[SectionIndex] := '';

    if FPlanner.Sidebar.Orientation = soVertical then
      FPlanner.FHeader.SectionWidth[SectionIndex] := ColWidths[SectionIndex]
    else
      FPlanner.FHeader.SectionWidth[SectionIndex] := RowHeights[SectionIndex];

    if FPlanner.Sidebar.Orientation = soVertical then
      FPlanner.FFooter.SectionWidth[SectionIndex] := ColWidths[SectionIndex]
    else
      FPlanner.FFooter.SectionWidth[SectionIndex] := RowHeights[SectionIndex];

    if FPlanner.FSidebar.Visible then
      j := 0
    else
      j := 1;

    if (SectionIndex = j) and FPlanner.NavigatorButtons.Visible and
       (FPlanner.SideBar.Position <> spTop) then
    begin
      FPlanner.FHeader.SectionWidth[SectionIndex] := ColWidths[SectionIndex] - BtnWidth;
    end;

    if FPlanner.Sidebar.Orientation = soVertical then
    begin
      if not FPlanner.NavigatorButtons.Visible then
        FPlanner.FHeader.SectionWidth[0] := ColWidths[0] + 1;
      FPlanner.FFooter.SectionWidth[0] := ColWidths[0] + 1;
    end
    else
    begin
      if not FPlanner.NavigatorButtons.Visible then
        FPlanner.FHeader.SectionWidth[0] := RowHeights[0];
      FPlanner.FFooter.SectionWidth[0] := RowHeights[0];
    end;

    if (SectionIndex = FPlanner.FHeader.Sections.Count - 1) and
      (FPlanner.SideBar.Position <> spTop) and FPlanner.NavigatorButtons.Visible then
      FPlanner.FHeader.SectionWidth[SectionIndex] := ColWidths[SectionIndex] - BtnWidth;

    if (SectionIndex = FPlanner.FFooter.Sections.Count - 1) and
      (FPlanner.SideBar.Position <> spTop) and FPlanner.NavigatorButtons.Visible then
      FPlanner.FFooter.SectionWidth[SectionIndex] := ColWidths[SectionIndex] - BtnWidth;
  end;

  if FPlanner.Flat then
  begin
    if FPlanner.FHeader.Flat then
      FPlanner.FHeader.SectionWidth[0] := FPlanner.FHeader.SectionWidth[0] - 2
    else
      FPlanner.FHeader.SectionWidth[0] := FPlanner.FHeader.SectionWidth[0];
  end
  else
  begin
    if not FPlanner.FHeader.Flat then
      FPlanner.FHeader.SectionWidth[0] := FPlanner.FHeader.SectionWidth[0] + 2
  end;
end;

procedure TPlannerGrid.SelChanged;
var
  FromSel, ToSel, FromSelPrecis, ToSelPrecis, Position: Integer;

  function EqualSel(a, b: TGridRect): Boolean;
  begin
    Result := (a.Left = b.Left) and (a.Top = b.Top) and
              (a.Right = b.Right) and (a.Bottom = b.Bottom);
  end;

begin
  if not EqualSel(FOldSelection, Selection) then
  begin
    if FPlanner.Sidebar.Orientation = soHorizontal then
    begin
      Position := Selection.Top - 1;
      FromSel := Selection.Left;
      ToSel := 1 + Selection.Right;
    end
    else
    begin
      Position := Selection.Left - 1;
      FromSel := Selection.Top;
      ToSel := 1 + Selection.Bottom;
    end;

    FromSelPrecis := FromSel * FPlanner.Display.DisplayUnit + FPlanner.Display.DisplayOffset;
    ToSelPrecis := ToSel * FPlanner.Display.DisplayUnit + FPlanner.Display.DisplayOffset;

    if Assigned(FPlanner.FOnPlannerSelChange) then
      FPlanner.FOnPlannerSelChange(FPlanner, Position, FromSel,
        FromSelPrecis, ToSel, ToSelPrecis);

    RepaintSelection(FOldSelection);
    RepaintSelection(Selection);

    if FPlanner.Header.ActiveColor <> clNone then
    begin
      FPlanner.FHeader.Invalidate;
    end;

    (*
    if FPlanner.SideBar.ActiveColor <> clNone then
    begin
      if (FPlanner.SideBar.Position in [spLeft, spLeftRight]) then
        FPlanner.GridControl.RepaintRect(Rect(0,0,0,FPlanner.GridControl.RowCount - 1));

      if (FPlanner.SideBar.Position in [spRight, spLeftRight]) then
        FPlanner.GridControl.RepaintRect(Rect(FPlanner.GridControl.ColCount - 1,0,FPlanner.GridControl.ColCount - 1,FPlanner.GridControl.RowCount - 1));

      if FPlanner.SideBar.Position = spTop then
        FPlanner.GridControl.RepaintRect(Rect(0,0,FPlanner.GridControl.ColCount - 1,0));
    end;
    *)

  end;

  FOldSelection := Selection;
end;

procedure TPlannerGrid.UpdateNVI;
var
  i,j: Integer;
  TVS,BVS: Boolean;
  ir: TRect;
begin
  if not FPlanner.IndicateNonVisibleItems then
    Exit;

  if (csDestroying in ComponentState) then
    Exit;

  if FPlanner.Items.FUpdateCount > 0 then
    Exit;

  TVS := False;
  BVS := False;

  if FPlanner.SideBar.Position <> spTop then
  begin
    if FPlanner.FTopIndicator then
    begin
      ir := CellRect(0, FOldTopRow);
      RepaintRect(ir);
    end;
    if FPlanner.FBottomIndicator then
    begin
      ir := CellRect(0, FOldTopRow + VisibleRowCount);
      RepaintRect(ir);
    end;

    if TopRow > 0 then
    begin
      for j := 0 to TopRow - 1 do
        for i := 1 to FPlanner.Positions do
        begin
          if Assigned(FPlanner.Items.FindItem(j,i - 1)) then
          begin
            TVS := True;
            Break;
          end;
        end;
    end;

    if TopRow + VisibleRowCount < RowCount then
    begin
      for j := TopRow + VisibleRowCount to RowCount - 1 do
        for i := 1 to FPlanner.Positions  do
        begin
          if Assigned(FPlanner.Items.FindItem(j,i - 1)) then
          begin
            BVS := True;
            Break;
          end;
        end;
    end;

    if FPlanner.FTopIndicator <> TVS then
    begin
      FPlanner.FTopIndicator := TVS;
      FPlanner.FGrid.RepaintRect(Rect(0,0,22,20));
    end;

    FPlanner.FBottomIndicator := BVS;
    ir := Rect(0,FPlanner.FGrid.Height - 30,22,FPlanner.FGrid.Height);

    {$IFNDEF TMSDOTNET}
    InvalidateRect(FPlanner.FGrid.Handle, @ir, true);
    {$ELSE}
    InvalidateRect(FPlanner.FGrid.Handle, ir, true);
    {$ENDIF}

    // FPlanner.FGrid.RepaintRect(Rect(0,FPlanner.FGrid.Height - 30,22,FPlanner.FGrid.Height));
  end
  else
  begin
    if FPlanner.FTopIndicator then
    begin
      ir := CellRect(FOldLeftCol, 0);
      RepaintRect(ir);
    end;
    if FPlanner.FBottomIndicator then
    begin
      ir := CellRect(0, FOldLeftCol + VisibleColCount);
      RepaintRect(ir);
    end;

    if LeftCol > 0 then
    begin
      for j := 0 to LeftCol - 1 do
        for i := 1 to FPlanner.Positions do
        begin
          if Assigned(FPlanner.Items.FindItem(j,i - 1)) then
          begin
            TVS := True;
            Break;
          end;
        end;
    end;

    if LeftCol + VisibleColCount < ColCount then
    begin
      for j := LeftCol + VisibleColCount to ColCount - 1 do
        for i := 1 to FPlanner.Positions  do
        begin
          if Assigned(FPlanner.Items.FindItem(j,i - 1)) then
          begin
            BVS := True;
            Break;
          end;
        end;
    end;

    if FPlanner.FTopIndicator <> TVS then
    begin
      FPlanner.FTopIndicator := TVS;
      FPlanner.FGrid.RepaintRect(Rect(0,0,22,20));
    end;

    FPlanner.FBottomIndicator := BVS;

    ir := Rect(0,0,FPlanner.FGrid.Width,22);

    {$IFNDEF TMSDOTNET}
    InvalidateRect(FPlanner.FGrid.Handle, @ir, true);
    {$ELSE}
    InvalidateRect(FPlanner.FGrid.Handle, ir, true);
    {$ENDIF}

    //FPlanner.FGrid.RepaintRect(Rect(FPlanner.FGrid.Width - 22,0,FPlanner.FGrid.Width,22));

  end;
end;

procedure TPlannerGrid.TopLeftChanged;
var
  ItemIndex,i: Integer;
  r: TRect;
begin
  if (csDesigning in ComponentState) and FPlanner.ShowDesignHelper then
    Invalidate;

  if (FOldLeftCol <> LeftCol) and (FPlanner.Sidebar.Position in [spLeft,spRight,spLeftRight]) then
  begin
    if FGridState = gsSelecting then
     FGridState := gsNormal;
  end;

  if (FOldTopRow <> TopRow) and (FPlanner.Sidebar.Position in [spTop]) then
  begin
    if FGridState = gsSelecting then
     FGridState := gsNormal;
  end;

  for ItemIndex := 0 to FPlanner.Items.Count - 1 do
  begin
    if ((FPlanner.Items.Items[ItemIndex] as TPlannerItem).ItemBegin >= TopRow - 1)
      and
      ((FPlanner.Items.Items[ItemIndex] as TPlannerItem).ItemEnd <= TopRow +
      VisibleRowCount + 1) then
      (FPlanner.Items.Items[ItemIndex] as TPlannerItem).UpdateWnd;
  end;

  if FPlanner.Header.Visible then
  begin
    if FPlanner.Sidebar.Orientation = soVertical then
      FPlanner.FHeader.FLeftPos := Max(0, LeftCol - 1)
    else
      FPlanner.FHeader.FLeftPos := Max(0, TopRow - 1);

    FPlanner.FHeader.Invalidate;
  end;

  if FPlanner.Footer.Visible then
  begin
    if FPlanner.Sidebar.Orientation = soVertical then
      FPlanner.FFooter.FLeftPos := Max(0, LeftCol - 1)
    else
      FPlanner.FFooter.FLeftPos := Max(0, TopRow - 1);

    FPlanner.FFooter.Invalidate;
  end;

  if Assigned(FPlanner.FOnTopLeftChanged) then
    FPlanner.FOnTopLeftChanged(FPlanner);

  if FPlanner.ScrollBarStyle.Flat then
  begin
    UpdateVScrollBar;
    UpdateHScrollBar;
  end;


  if (FPlanner.FSideBar.Position in [spLeft,spLeftRight,spRight]) and
     (FPlanner.FSidebar.ActiveColor <> clNone) then
  begin
    if FPlanner.FSidebar.ShowInPositionGap then
    begin
      for i := 1 to ColCount do
        for ItemIndex := 0 to RowCount - 1 do
        begin
        {$IFNDEF TMSDOTNET}
          InvalidateCell(i - 1,ItemIndex);
        {$ENDIF}
        {$IFDEF TMSDOTNET}
          InvalidateCellP(i - 1,ItemIndex);
        {$ENDIF}
        end;
    end
    else
    begin
      for ItemIndex := 0 to RowCount - 1 do
      begin
        if (FPlanner.SideBar.Position in [spRight, spLeftRight]) then
        begin
          {$IFNDEF TMSDOTNET}
          InvalidateCell(ColCount - 1,ItemIndex);
          {$ENDIF}
          {$IFDEF TMSDOTNET}
          InvalidateCellP(ColCount - 1,ItemIndex);
          {$ENDIF}
        end;

      {$IFNDEF TMSDOTNET}
        InvalidateCell(0,ItemIndex);
      {$ENDIF}
      {$IFDEF TMSDOTNET}
        InvalidateCellP(0,ItemIndex);
      {$ENDIF}
      end;
    end;
  end;


  if FPlanner.FSideBar.Visible and FPlanner.FSideBar.Border and
     (FPlanner.FSideBar.Position in [spLeft,spLeftRight,spRight]) then
  begin
    if FPlanner.FSideBar.Position in [spLeft,spLeftRight] then
    begin
      {$IFNDEF TMSDOTNET}
      InvalidateCell(0,TopRow);
      InvalidateCell(0,FOldTopRow);
      {$ENDIF}
      {$IFDEF TMSDOTNET}
      InvalidateCellP(0,TopRow);
      InvalidateCellP(0,FOldTopRow);
      {$ENDIF}
      FOldTopRow := TopRow;
    end;

    if FPlanner.FSideBar.Position in [spRight,spLeftRight] then
    begin
      {$IFNDEF TMSDOTNET}
      InvalidateCell(ColCount - 1,TopRow);
      InvalidateCell(ColCount - 1,FOldTopRow);
      {$ENDIF}
      {$IFDEF TMSDOTNET}
      InvalidateCellP(ColCount - 1,TopRow);
      InvalidateCellP(ColCount - 1,FOldTopRow);
      {$ENDIF}
      FOldTopRow := TopRow;
    end;
  end;

  if (FPlanner.FSideBar.ShowInPositionGap and
    (FPlanner.FSideBar.Position in [spLeft,spLeftRight,spRight])) then
  begin
    for ItemIndex := 0 to ColCount - 1 do
    begin
      {$IFNDEF TMSDOTNET}
      InvalidateCell(ItemIndex,TopRow);
      InvalidateCell(ItemIndex,FOldTopRow);
      {$ENDIF}
      {$IFDEF TMSDOTNET}
      InvalidateCellP(ItemIndex,TopRow);
      InvalidateCellP(ItemIndex,FOldTopRow);
      {$ENDIF}
    end;
    FOldTopRow := TopRow;
  end;

  if FPlanner.FDisplay.FDisplayText > 0 then
  begin
    if (FPlanner.FSideBar.Position in [spLeft,spLeftRight,spRight]) then
      r := Rect(0,0,ColWidths[0],Height)
    else
      r := Rect(0,0,Width,RowHeights[0]);

    {$IFNDEF TMSDOTNET}
    InvalidateRect(Handle,@r,False);
    {$ENDIF}
    {$IFDEF TMSDOTNET}
    InvalidateRect(Handle,r,False);
    {$ENDIF}
  end;

  if (FPlanner.Mode.PlannerType = plTimeLine) and
     (FPlanner.FSideBar.Position = spTop) and (FPlanner.Sidebar.Visible) then
  begin
    for i := FixedCols to ColCount do
      InvalidateCell(i, 0);
  end;

  if (FPlanner.FSideBar.Visible and FPlanner.FSideBar.Border) and
     (FPlanner.FSideBar.Position = spTop) then
  begin
    {$IFNDEF TMSDOTNET}
    InvalidateCell(LeftCol,0);
    InvalidateCell(FOldLeftCol,0);
    {$ENDIF}
    {$IFDEF TMSDOTNET}
    InvalidateCellP(LeftCol,0);
    InvalidateCellP(FOldLeftCol,0);
    {$ENDIF}

    FOldLeftCol := LeftCol;
  end;

  UpdateNVI;

  FOldLeftCol := LeftCol;
  FOldTopRow := TopRow;
end;

procedure TPlannerGrid.StartEditCol(ARect: TRect; APlannerItem: TPlannerItem; X, Y:
  Integer);
var
  ColumnHeight, ih, iw, ew, tw, eh, TopOffset: Integer;
  s: string;
  ER: TRect;

begin
  if APlannerItem = nil then
    Exit;

  if APlannerItem.FPopupEdit then
    Exit;

  if Assigned(APlannerItem.Editor) then
  begin
    if APlannerItem.Editor.EditorUse = euAlways then
    begin
      if Assigned(FPlanner.OnItemStartEdit) then
      begin
        FPlanner.OnItemStartEdit(Self, APlannerItem);
      end;

      FPlanner.FEditMode := True;

      APlannerItem.Editor.Edit(FPlanner,APlannerItem);

      if Assigned(FPlanner.OnItemEndEdit) then
        FPlanner.OnItemEndEdit(Self, APlannerItem);

      FPlanner.FEditMode := False;

      Exit;
    end;
  end;

  if FPlanner.InplaceEdit = ieNever then
    Exit;

  FPlanner.FEditMode := True;

  if Assigned(FPlanner.OnItemStartEdit) then
  begin
    FPlanner.OnItemStartEdit(Self, APlannerItem);
  end;

  if (APlannerItem.FConflicts > 1) then
  begin
    iw := ColWidthEx(APlannerItem.ItemPos) div APlannerItem.FConflicts;
    ARect.Left := ARect.Left + APlannerItem.FConflictPos * iw;
    ARect.Right := ARect.Left + iw;
  end;

  ColumnHeight := EDITOFFSET;
  ih := 0;
  iw := 0;
  ew := 0;
  eh := 0;

  if (APlannerItem.Shape = psRect) and (APlannerItem.TrackVisible) then
    tw := FPlanner.TrackWidth
  else
    tw := 0;

  case APlannerItem.Shape of
  psRounded:
    begin
      ew := ew + (CORNER_EFFECT shr 2) + 1;
      ARect.Top := ARect.Top + (CORNER_EFFECT shr 2);
      eh := eh + 6;
    end;
  psHexagon:
    begin
      ew := ew + CORNER_EFFECT;
      ARect.Top := ARect.Top + 4;
      eh := eh + 6;
     end;
  {$IFDEF TMSSKINS}
  psSkin:
    begin
      InflateRect(ARect, -FPlanner.Skin.SkinX, -FPlanner.Skin.SkinY);
      eh := FPlanner.Skin.SkinY;
    end;
  {$ENDIF}
  end;

  if APlannerItem.Shadow then
  begin
    ew := ew + 1;
    eh := eh + 3;
  end;

  if APlannerItem.CompletionDisplay = cdVertical then
    ew := ew + 12;

  if ((APlannerItem.ImageID >= 0) or (APlannerItem.FImageIndexList.Count > 0)) and
    Assigned(FPlanner.PlannerImages) then
  begin
    if not (APlannerItem.CaptionType = ctNone) then
      ih := FPlanner.PlannerImages.Height + 6 + FPlanner.ImageOffsetY;

    iw := FPlanner.PlannerImages.Width + EDITOFFSET;
  end;

  if (APlannerItem.CaptionType <> ctNone) or
     ((APlannerItem.FImageIndexList.Count > 1) and (APlannerItem.ImagePosition = ipHorizontal)) then
  begin
    Canvas.Font.Assign(APlannerItem.CaptionFont);
    ColumnHeight := Canvas.TextHeight('gh') + 6;
    if (APlannerItem.ImagePosition = ipHorizontal) then
      iw := 0;
  end;
//  else
//    ih := 0;

  if (ih > ColumnHeight) then
    ColumnHeight := ih;

  s := APlannerItem.Text.Text;

  if APlannerItem.ItemBegin < TopRow then
    TopOffset := 0
  else
    TopOffset := 2 {+ EDITOFFSET} + ColumnHeight;

  if (APlannerItem.CompletionDisplay = cdHorizontal) then
    TopOffset := TopOffset + 12;

  if IsRtf(s) or (APlannerItem.InplaceEdit = peRichText) then
  begin
    FPlanner.FRichEdit.Parent := Self;
    FPlanner.FRichEdit.ScrollBars := FPlanner.EditScroll;
    FPlanner.FRichEdit.PlannerItem := APlannerItem;
    FPlanner.TextToRich(s);
    FPlanner.FRichEdit.Top := ARect.Top + 6 + ColumnHeight;
    FPlanner.FRichEdit.Left := ARect.Left + tw + 1 + iw + ew;
    FPlanner.FRichEdit.Width := ARect.Right - ARect.Left - tw - 3 - FPlanner.FItemGap
      - iw - 2 * ew;
    FPlanner.FRichEdit.Height := (APlannerItem.ItemEnd - APlannerItem.ItemBegin) * RowHeights[0]
      - 10 - ColumnHeight;
    FPlanner.FRichEdit.Visible := True;
    BringWindowToTop(FPlanner.FRichEdit.Handle);
    FPlanner.FRichEdit.SetFocus;
    FPlanner.FRichEdit.SelectAll;
  end
  else
    case APlannerItem.InplaceEdit of
      peMaskEdit, peEdit:
        begin
          if APlannerItem.InplaceEdit = peMaskEdit then
            FMaskEdit.EditMask := APlannerItem.EditMask
          else
            FMaskEdit.EditMask := '';
          FMaskEdit.Font.Assign(FPlanner.Font);
          if APlannerItem.ShowSelection then
          begin
            FMaskEdit.Color := FPlanner.GetEditColor(APlannerItem, true);
            FMaskEdit.Font.Color := APlannerItem.SelectFontColor
          end
          else
            FMaskEdit.Color := FPlanner.GetEditColor(APlannerItem, false);

          FMaskEdit.PlannerItem := APlannerItem;
          FMaskEdit.Top := ARect.Top + TopOffset;
          FMaskEdit.Left := ARect.Left + tw + 1 + iw + ew;
          FMaskEdit.Width := ARect.Right - ARect.Left - tw - 3 - FPlanner.FItemGap -
            iw - 2 * ew;
          FMaskEdit.Height := APlannerItem.GetVisibleSpan * RowHeights[0] - 2 - TopOffset;
          FMaskEdit.BorderStyle := bsNone;
          FMaskEdit.Visible := True;
          if (APlannerItem.Text.Count > 0) then
            FMaskEdit.Text := APlannerItem.Text[0];
          BringWindowToTop(FMaskEdit.Handle);
          FMaskEdit.SetFocus;
        end;
      peMemo:
        begin
          FMemo.Parent := Self;
          FMemo.ScrollBars := FPlanner.EditScroll;
          FMemo.Font.Assign(APlannerItem.Font);
          if APlannerItem.ShowSelection then
          begin
            FMemo.Color := FPlanner.GetEditColor(APlannerItem,true);
            FMemo.Font.Color := APlannerItem.SelectFontColor;
          end
          else
            FMemo.Color := FPlanner.GetEditColor(APlannerItem, false);

          FMemo.PlannerItem := APlannerItem;

          FMemo.Top := ARect.Top + TopOffset;
          FMemo.Left := ARect.Left + tw + iw + ew;
          FMemo.Width := ARect.Right - ARect.Left - tw - 4 - FPlanner.FItemGap - iw - ew;

          FMemo.Height := APlannerItem.GetVisibleSpan * RowHeights[0] - 4 - eh - TopOffset;

          FMemo.BorderStyle := bsNone;
          FMemo.Visible := True;
          BringWindowToTop(FMemo.Handle);
          FMemo.Lines.Text := HTMLStrip(APlannerItem.Text.Text);
          if FPlanner.NotesMaxLength > 0 then
            FMemo.MaxLength := FPlanner.NotesMaxLength;

          FMemo.SetFocus;

          SetEditDirectSelection(ARect, X, Y);
        end;
      {$IFNDEF TMSDOTNET}
      {$IFNDEF DELPHI_UNICODE}
      peUniMemo:
        begin
          FUniMemo.Parent := Self;
          FUniMemo.ScrollBars := FPlanner.EditScroll;
          FUniMemo.Font.Assign(APlannerItem.Font);
          if APlannerItem.ShowSelection then
          begin
            FUniMemo.Color := FPlanner.GetEditColor(APlannerItem,true);
            FUniMemo.Font.Color := APlannerItem.SelectFontColor;
          end
          else
            FUniMemo.Color := FPlanner.GetEditColor(APlannerItem, false);

          FUniMemo.PlannerItem := APlannerItem;

          FUniMemo.Top := ARect.Top + TopOffset;
          FUniMemo.Left := ARect.Left + tw + iw + ew;
          FUniMemo.Width := ARect.Right - ARect.Left - tw - 4 - FPlanner.FItemGap - iw - ew;

          FUniMemo.Height := APlannerItem.GetVisibleSpan * RowHeights[0] - 4 - eh - TopOffset;

          FUniMemo.BorderStyle := bsNone;
          FUniMemo.Visible := True;
          BringWindowToTop(FUniMemo.Handle);
          FUniMemo.Text := APlannerItem.WideText;

          if FPlanner.NotesMaxLength > 0 then
            FUniMemo.MaxLength := FPlanner.NotesMaxLength;

          FUniMemo.SetFocus;
          SetEditDirectSelection(ARect, X, Y);
        end;
      {$ENDIF}
      {$ENDIF}

      peCustom:
        begin
          ER.Left := ARect.Left + tw + 1 + iw + ew;
          ER.Top := ARect.Top + TopOffset;
          ER.Right := ARect.Right - tw - 3 - FPlanner.FItemGap - iw - 2 * ew;
          ER.Bottom := ARect.Top + APlannerItem.GetVisibleSpan * RowHeights[0] - 10 -
            ColumnHeight;
          if Assigned(FPlanner.FOnCustomEdit) then
            FPlanner.FOnCustomEdit(Self,ER,APlannerItem);
        end;
    end;
end;

procedure TPlannerGrid.SetEditDirectSelection(ARect: TRect; X, Y: Integer);
var
  CharacterCoordinate: Integer;
begin
  if (FPlanner.EditDirect) and (X > -1) then
  begin
    CharacterCoordinate := SendMessage(FMemo.Handle, EM_CHARFROMPOS, 0,
      MakeLong(X - ARect.Left, Y - ARect.Top));
    if (CharacterCoordinate = -1) then
      Exit;
    FMemo.SelStart := LoWord(CharacterCoordinate);
    FMemo.SelLength := 0;
  end
  else
    FMemo.SelectAll;
end;

procedure TPlannerGrid.StartEditRow(ARect: TRect; APlannerItem: TPlannerItem; X, Y:
  Integer);
var
  ColumnHeight, ih, iw, ew, eh: Integer;
  s: string;
  ER: TRect;

begin
  if APlannerItem = nil then
    Exit;

  if APlannerItem.FPopupEdit then
    Exit;

  if Assigned(APlannerItem.Editor) then
  begin
    if APlannerItem.Editor.EditorUse = euAlways then
    begin
      FPlanner.FEditMode := True;
      
      if Assigned(FPlanner.OnItemStartEdit) then
      begin
        FPlanner.OnItemStartEdit(Self, APlannerItem);
      end;

      APlannerItem.Editor.Edit(FPlanner,APlannerItem);
      if Assigned(FPlanner.OnItemEndEdit) then
        FPlanner.OnItemEndEdit(Self, APlannerItem);

      FPlanner.FEditMode := False;
      Exit;
    end;
  end;

  if FPlanner.InplaceEdit = ieNever then
    Exit;

  FPlanner.FEditMode := True;    

  if Assigned(FPlanner.OnItemStartEdit) then
  begin
    FPlanner.OnItemStartEdit(Self, APlannerItem);
  end;

  if (APlannerItem.FConflicts > 1) then
  begin
    iw := RowHeightEx(APlannerItem.ItemPos) div APlannerItem.FConflicts;
    ARect.Top := ARect.Top + APlannerItem.FConflictPos * iw;
    ARect.Bottom := ARect.Top + iw;
  end;

  ColumnHeight := 0;
  ih := 0;
  iw := 0;
  ew := 0;
  eh := 0;

  case APlannerItem.Shape of
  psRounded:
    begin
      ew := ew + (CORNER_EFFECT shr 1) - 1;
      ARect.Top := ARect.Top + 4;
    end;
  psHexagon: ew := ew + CORNER_EFFECT;
  {$IFDEF TMSSKINS}
  psSkin:
    begin
      InflateRect(ARect, 0, -(FPlanner.Skin.SkinY div 2));
      ew := FPlanner.Skin.SkinX div 2;
    end;
  {$ENDIF}
  end;

  if APlannerItem.Shadow then
  begin
    ew := ew + 1;
    eh := eh + 2;
  end;

  if APlannerItem.CompletionDisplay = cdVertical then
    ew := ew + 10;

  if APlannerItem.CompletionDisplay = cdHorizontal then
    ARect.Top := ARect.Top + 12;

  if ((APlannerItem.ImageID >= 0) or (APlannerItem.FImageIndexList.Count > 0)) and
    Assigned(FPlanner.PlannerImages) then
  begin
    if not ((APlannerItem.CaptionType = ctNone) or (APlannerItem.ImagePosition = ipVertical)) then
      ih := FPlanner.PlannerImages.Height + 4 + FPlanner.ImageOffsetY;

    iw := FPlanner.PlannerImages.Width + EDITOFFSET;
  end;

  if (APlannerItem.CaptionType <> ctNone) or
     ((APlannerItem.FImageIndexList.Count > 1) and (APlannerItem.ImagePosition = ipHorizontal)) then
  begin
    ColumnHeight := Canvas.TextHeight('gh')  + 8;
    if (APlannerItem.ImagePosition = ipHorizontal) then
      iw := 0;
  end;
//  else
//    ih := 0;

  if (ih > ColumnHeight) then
    ColumnHeight := ih;

  s := APlannerItem.Text.Text;

  if IsRtf(s) or (APlannerItem.InplaceEdit = peRichText) then
  begin
    FPlanner.FRichEdit.Parent := Self;
    FPlanner.FRichEdit.ScrollBars := FPlanner.EditScroll;
    FPlanner.FRichEdit.PlannerItem := APlannerItem;
    FPlanner.TextToRich(s);
    FPlanner.FRichEdit.Top := ARect.Top + FPlanner.TrackWidth + 2 + ColumnHeight;
    FPlanner.FRichEdit.Left := ARect.Left + 3 + iw + ew;
    FPlanner.FRichEdit.Width := (APlannerItem.ItemEnd - APlannerItem.ItemBegin) * ColWidthEx(APlannerItem.ItemPos) -
      6 - ColumnHeight - 2 * ew;
    FPlanner.FRichEdit.Height := ARect.Bottom - ARect.Top - 18 - iw;
    FPlanner.FRichEdit.Visible := True;
    BringWindowToTop(FPlanner.FRichEdit.Handle);
    FPlanner.FRichEdit.SetFocus;
    FPlanner.FRichEdit.SelectAll;
  end
  else
    case APlannerItem.InplaceEdit of
      peMaskEdit, peEdit:
        begin
          if APlannerItem.InplaceEdit = peMaskEdit then
            FMaskEdit.EditMask := APlannerItem.EditMask
          else
            FMaskEdit.EditMask := '';
          FMaskEdit.Font.Assign(FPlanner.Font);

          FMaskEdit.Color := FPlanner.GetEditColor(APlannerItem,APlannerItem.ShowSelection);
          FMaskEdit.Font.Color := APlannerItem.SelectFontColor;
          
          FMaskEdit.PlannerItem := APlannerItem;
          FMaskEdit.Top := ARect.Top + FPlanner.TrackWidth + 2 + ColumnHeight;
          FMaskEdit.Left := ARect.Left + 3 + iw + ew;
          FMaskEdit.Width := APlannerItem.GetVisibleSpan * ColWidthEx(APlannerItem.ItemPos) - 6 - iw - 2 * ew;
          FMaskEdit.Height := ARect.Bottom - ARect.Top - FPlanner.FItemGap - ColumnHeight - FPlanner.TrackWidth;
          FMaskEdit.BorderStyle := bsNone;
          FMaskEdit.Visible := True;
          if (APlannerItem.Text.Count > 0) then
            FMaskEdit.Text := APlannerItem.Text[0];
          BringWindowToTop(FMaskEdit.Handle);
          FMaskEdit.SetFocus;
        end;
      peMemo:
        begin
          FMemo.Parent := Self;
          FMemo.ScrollBars := FPlanner.EditScroll;
          FMemo.Font.Assign(APlannerItem.Font);

          if APlannerItem.ShowSelection then
          begin
            FMemo.Color := FPlanner.GetEditColor(APlannerItem,true);
            FMemo.Font.Color := APlannerItem.SelectFontColor;
          end
          else
            FMemo.Color := FPlanner.GetEditColor(APlannerItem, false);

          FMemo.PlannerItem := APlannerItem;
          FMemo.Top := ARect.Top + FPlanner.TrackWidth + 2 + ColumnHeight;
          FMemo.Left := ARect.Left + 3 + iw + ew;
          FMemo.Width := APlannerItem.GetVisibleSpan * ColWidthEx(APlannerItem.ItemPos) - 8 - iw - 2 * ew;
          FMemo.Height := ARect.Bottom - ARect.Top - FPlanner.FItemGap - ColumnHeight - FPlanner.TrackWidth - 6 - eh;
          FMemo.BorderStyle := bsNone;
          FMemo.Visible := True;
          FMemo.Lines.Text := HTMLStrip(APlannerItem.Text.Text);
          BringWindowToTop(FMemo.Handle);

          if FPlanner.NotesMaxLength > 0 then
            FMemo.MaxLength := FPlanner.NotesMaxLength;

          FMemo.SetFocus;
          SetEditDirectSelection(ARect, X, Y);
        end;
      {$IFNDEF TMSDOTNET}
      {$IFNDEF DELPHI_UNICODE}
      peUniMemo:
        begin
          FUniMemo.Parent := Self;
          FUniMemo.ScrollBars := FPlanner.EditScroll;
          FUniMemo.Font.Assign(APlannerItem.Font);
          if APlannerItem.ShowSelection then
          begin
            FUniMemo.Color := FPlanner.GetEditColor(APlannerItem,true);
            FUniMemo.Font.Color := APlannerItem.SelectFontColor;
          end
          else
            FUniMemo.Color := FPlanner.GetEditColor(APlannerItem, false);

          FUniMemo.PlannerItem := APlannerItem;

          FUniMemo.Top := ARect.Top + FPlanner.TrackWidth + 2 + ColumnHeight;
          FUniMemo.Left := ARect.Left + 3 + iw + ew;
          FUniMemo.Width := APlannerItem.GetVisibleSpan * ColWidthEx(APlannerItem.ItemPos) - 8 - iw - 2 * ew;
          FUniMemo.Height := ARect.Bottom - ARect.Top - FPlanner.FItemGap - ColumnHeight - FPlanner.TrackWidth - 6 - eh;

          FUniMemo.BorderStyle := bsNone;
          FUniMemo.Visible := True;
          BringWindowToTop(FUniMemo.Handle);
          FUniMemo.Text := APlannerItem.WideText;

          if FPlanner.NotesMaxLength > 0 then
            FUniMemo.MaxLength := FPlanner.NotesMaxLength;

          FUniMemo.SetFocus;
          SetEditDirectSelection(ARect, X, Y);
        end;
      {$ENDIF}
      {$ENDIF}

      peCustom:
        begin
          ER.Left := ARect.Left + 3 + iw + ew;
          ER.Top := ARect.Top + FPlanner.TrackWidth + 2 + ColumnHeight;
          ER.Right := ARect.Left + APlannerItem.GetVisibleSpan * ColWidthEx(APlannerItem.ItemPos)
            - 6 - iw - 2 * ew;
          ER.Bottom := ARect.Bottom - FPlanner.FItemGap - ColumnHeight - FPlanner.TrackWidth -6;
          if Assigned(FPlanner.FOnCustomEdit) then
            FPlanner.FOnCustomEdit(Self,ER,APlannerItem);
        end;
    end;
end;

procedure TPlannerGrid.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  FromSel, FromSelPrecis: Integer;
  ToSel, ToSelPrecis: Integer;
  APlannerItem, nplIt: TPlannerItem;
  GridCoord: TGridCoord;
  GridRect,GridRectE, r, tr, hr, cr: TRect;
  iw: Integer;
  grr: TGridRect;
  s, Anchor, StrippedHtmlString, FocusAnchor: string;
  XSize, YSize, ImgSize, ml, hl: Integer;
  ColOffset, RowOffset: Integer;
  OutBounds, AutoHandle: Boolean;
  //ShiftState: TShiftState;
  ScreenPoint: TPoint;
  CID, CV, CT: string;
  OrigButton: TMouseButton;
  SelP: TPoint;

begin
  if (csDesigning in ComponentState) and FPlanner.ShowDesignHelper then
  begin
    case MouseOverDesignChoice(X, Y) of
      1: if FPlanner.SideBar.Position in [spLeft,spRight,spLeftRight] then
           FPlanner.SideBar.Position := spTop
         else
           FPlanner.SideBar.Position := spLeft;
      2: begin
           if FPlanner.items.Count = 0 then
           begin
             with FPlanner.Items.Add do
             begin
               ItemBegin := 4;
               ItemEnd := 8;
               ItemPos := 0;
             end;
             // scroll back to ensure visibility of design item
             TopRow := FixedRows;
             LeftCol := FixedCols;
           end
           else
             FPlanner.Items.Clear;
         end;
      3: begin
           case FPlanner.Mode.PlannerType of
           plDay: FPlanner.Mode.PlannerType := plMonth;
           plMonth: FPlanner.Mode.PlannerType := plDayPeriod;
           plDayPeriod: FPlanner.Mode.PlannerType := plHalfDayPeriod;
           plHalfDayPeriod: FPlanner.Mode.PlannerType := plMultiMonth;
           plMultiMonth: FPlanner.Mode.PlannerType := plTimeLine;
           plTimeLine: FPlanner.Mode.PlannerType := plDay;
           else
             FPlanner.Mode.PlannerType := plDay;
           end;
         end;
    end;
    Exit;
  end;

  FPlanner.FDownOnItem := false;
  ColOffset := FPlanner.FSidebar.FColOffset;
  RowOffset := FPlanner.FSidebar.FRowOffset;

  if Assigned(FPlanner.FOnPlannerMouseDown) then
  begin
    FPlanner.FOnPlannerMouseDown(FPlanner, Button, Shift, X, Y);
  end;

  OrigButton := Button;

  if (Button = mbRight) and (FPlanner.ItemSelection.Button in [sbRight,sbBoth]) then
    Button := mbLeft
  else
    if (Button = mbLeft) and (FPlanner.ItemSelection.Button in [sbRight]) then
    begin
      Button := mbRight;
    end;

  if (Button = mbLeft) then
  begin
    //SetCapture(Self.Handle);

    FMouseUnSelect := False;
    FMouseDown := True;
    FMouseXY := Point(X,Y);
    GridCoord := MouseCoord(X,Y);
    FMouseRCD := MouseCoord(X,Y);

    if not (ssCtrl in Shift) and (FPlanner.Selections.Count > 0) and FPlanner.DisjunctSelect then
    begin
      FPlanner.Selections.Clear;
    end;

    if (ssCtrl in Shift) and FPlanner.DisjunctSelect and (FPlanner.Selections.Count > 0) then
    begin
      SelP := FPlanner.XYToSelection(GridCoord.X,GridCoord.Y);

      iw := 1;
      while iw <= FPlanner.Selections.Count do
      begin
        with FPlanner.Selections[iw - 1] do

        if (SelPos = SelP.Y) and
           (SelBegin <= SelP.X) and
           (SelEnd >= SelP.X) then
           begin
             FPlanner.UpdateSelection(SelBegin, SelEnd, SelPos, False);
             FPlanner.Selections[iw - 1].Free;
             FMouseUnSelect := True;
           end
         else
           inc(iw);
      end;
    end
    else
      if (ssCtrl in Shift) and FPlanner.DisjunctSelect and (FPlanner.Selections.Count = 0) then
      begin
        with FPlanner.FSelections.Add do
        begin
          if FPlanner.SelItemBegin < FPlanner.SelItemEnd then
          begin
            SelBegin := FPlanner.SelItemBegin;
            SelEnd := FPlanner.SelItemEnd;
            SelPos := FPlanner.SelPosition;
          end
          else
          begin
            SelBegin := FPlanner.SelItemEnd;
            SelEnd := FPlanner.SelItemBegin;
            SelPos := FPlanner.SelPosition;
          end;
        end;

        FPlanner.UpdateSelection(FPlanner.SelItemBegin, FPlanner.SelItemEnd, FPlanner.SelPosition, True);
      end;

    GridRect := CellRectEx(GridCoord.X, GridCoord.Y);

    if GetFocus <> Self.Handle then
    begin
      if Self.CanFocus then
        Self.SetFocus;
      //++v1.6b++
      if (Selection.Left < 0) or (Selection.Top < 0) or
         (Selection.Left >= ColCount) or (Selection.Top >= RowCount) then
      //--v1.6b--
      begin
        grr.Top := GridCoord.Y;
        grr.Left := GridCoord.X;
        grr.Bottom := GridCoord.Y;
        grr.Right := GridCoord.X;
        Selection := grr;
        SelChanged;
      end;
    end;

    if FPlanner.Sidebar.Orientation = soVertical then
    begin
      APlannerItem := FPlanner.Items.FindItemPos(GridCoord.Y - RowOffset, GridCoord.X - ColOffset, X
        - GridRect.Left);
      OutBounds := (X > GridRect.Right - FPlanner.ItemGap);
    end
    else
    begin
      APlannerItem := FPlanner.Items.FindItemPos(GridCoord.X - ColOffset, GridCoord.Y - RowOffset, Y
        - GridRect.Top);
      OutBounds := (Y > GridRect.Bottom - FPlanner.ItemGap);
    end;

    if (APlannerItem = nil) or OutBounds then
    begin
      inherited;

      if FPlanner.Mode.FullHalfDay then
      begin
        CorrectSelection;
        InvalidateRow(0);
        InvalidateCol(0);
      end;

      if FPlanner.ItemSelection.AutoUnSelect then
      begin
        FPlanner.Items.UnSelectAll;
        SelChanged;
      end;

      if Assigned(FPlanner.FOnPlannerLeftClick) then
      begin
        if FPlanner.Sidebar.Orientation = soVertical then
        begin
          FromSel := Selection.Top + FPlanner.Display.DisplayStart;
          ToSel := 1 + Selection.Bottom + FPlanner.Display.DisplayStart;
          FromSelPrecis := FromSel * FPlanner.Display.DisplayUnit + FPlanner.Display.DisplayOffset;
          ToSelPrecis := ToSel * FPlanner.Display.DisplayUnit + FPlanner.Display.DisplayOffset;
          FPlanner.FOnPlannerLeftClick(FPlanner, Col - ColOffset, FromSel,
            FromSelPrecis, ToSel, ToSelPrecis);
        end
        else
        begin
          FromSel := Selection.Left + FPlanner.Display.DisplayStart;
          ToSel := 1 + Selection.Right + FPlanner.Display.DisplayStart;
          FromSelPrecis := FromSel * FPlanner.Display.DisplayUnit + FPlanner.Display.DisplayOffset;
          ToSelPrecis := ToSel * FPlanner.Display.DisplayUnit + FPlanner.Display.DisplayOffset;
          FPlanner.FOnPlannerLeftClick(FPlanner, Row - RowOffset, FromSel,
            FromSelPrecis, ToSel, ToSelPrecis);
        end;
      end;

      Exit;
    end
    else
    begin
      FPlanner.FDownOnItem := true;

      if not FPlanner.SelectionAlways then
        HideSelection;

      if FPlanner.Sidebar.Orientation = soVertical then
      begin
        if (APlannerItem.ItemBegin < TopRow) and FPlanner.AutoItemScroll then
          TopRow := APlannerItem.ItemBegin;
      end
      else
      begin
        if (APlannerItem.ItemBegin < LeftCol) and FPlanner.AutoItemScroll then
          LeftCol := APlannerItem.ItemBegin;
      end;

      if Assigned(FPlanner.FOnItemLeftClick) then
      begin
        FMouseDown := false;
        FMouseDownMove := false;
        FMouseDownMoveFirst := false;
        FPlanner.FOnItemLeftClick(FPlanner, APlannerItem);
      end;
    end;

    APlannerItem := FPlanner.Items.FSelected;

    if FPlanner.Sidebar.Orientation = soVertical then
    begin
      nplIt := FPlanner.Items.FocusItem(GridCoord.Y - RowOffset, GridCoord.X - ColOffset, X -
        GridRect.Left, (ssCtrl in Shift) or FPlanner.StickySelect);

      if (Assigned(nplIt)) and (APlannerItem <> nplIt) and not Assigned(APlannerItem) then
      begin
        FPlanner.ItemSelected(nplIt);
        if Self.CanFocus then
          Self.SetFocus;
      end;



      if (Assigned(nplIt)) and (APlannerItem <> nplIt) {and Assigned(APlannerItem)} then
      begin
        FPlanner.ItemSelected(nplIt);
        if Self.CanFocus then
          Self.SetFocus;

        { direct move fix }
        if (FPlanner.DirectMove or nplIt.NotEditable) and not nplIt.FixedPos and (FPlanner.UserMode in [puNormal, puReadOnly]) then
        begin

          FItemXY := Point(nplIt.ItemPos, nplIt.ItemBegin);
          FItemXYS := Rect(nplIt.ItemPos, nplIt.ItemBegin, nplIt.ItemEnd, 0);

          //FMouseDownMove := not APlannerItem.FixedPos;
          FMouseDownMove := not nplIt.FixedPos;
          FMouseDownMoveFirst := FMouseDownMove;
          FMouseStart := FMouseDownMove;
          if FMemo.Visible then
            FMemo.DoExit;

          HintShowXY(X, Y, nplIt.ItemSpanTimeStr);
          Exit;
        end;
        
        if FPlanner.EditDirect then
        begin
          APlannerItem := nplIt;
          APlannerItem.EnsureFullVisibility;
        end
        else
          Exit;
      end;

      if (APlannerItem = nplIt) and Assigned(APlannerItem) then
      begin
        GridRect := CellRectEx(APlannerItem.ItemPos + ColOffset, APlannerItem.ItemBegin);

        GridRectE := CellRectEx(APlannerItem.ItemPos + ColOffset, APlannerItem.ItemEnd - 1);

        ImgSize := 0;

        if Assigned(FPlanner.PlannerImages) and
           ((APlannerItem.ImageID >= 0) or (APlannerItem.FImageIndexList.Count > 0)) then
          begin
            iw := FPlanner.PlannerImages.Width;
            if APlannerItem.ImagePosition = ipHorizontal then
              ImgSize := (iw * APlannerItem.FImageIndexList.Count) + iw
            else
              ImgSize := iw;
          end;

        APlannerItem.CalcConflictRect(GridRect, ColWidthEx(nplIt.ItemPos), RowHeightEx(RowOffset),
          FPlanner.Sidebar.Orientation = soVertical);

        if APlannerItem.Focus then
        begin
          s := ConcatenateTextStrings(APlannerItem.Text);

          r := CellRectEx(GridCoord.X, GridCoord.Y);

          APlannerItem.CalcConflictRect(r, ColWidthEx(nplIt.ItemPos), RowHeightEx(1),
            FPlanner.Sidebar.Orientation = soVertical);

          r.Left := r.Left + FPlanner.TrackWidth;
          r.Top := r.Top - ((GridCoord.Y - APlannerItem.ItemBegin) * DefaultRowHeight) + 4;
          r.Bottom := r.Bottom + ((APlannerItem.ItemEnd - GridCoord.Y - 1) * DefaultRowHeight) + 4;

          if (APlannerItem.CaptionType <> ctNone) then
          begin
            tr := r;
            tr.Right := tr.Right - FPlanner.ItemGap;

            tr.Bottom := tr.Top + 16;

            if APlannerItem.ShowDeleteButton and (r.Right - r.Left - ImgSize > 32) then
            begin
              tr.Left := tr.Right - FPlanner.DeleteGlyph.Width;
              if PtInRect(tr,Point(X,Y)) then
              begin
                if Assigned(FPlanner.OnItemDelete) then
                  FPlanner.OnItemDelete(Self,APlannerItem);

                if FPlanner.AutoInsDel then
                begin
                  if Assigned(FPlanner.OnItemDeleted) then
                    FPlanner.OnItemDeleted(Self,APlannerItem);
                  FPlanner.FreeItem(APlannerItem);
                end;

                Exit;
              end;
              tr.Right := tr.Right - FPlanner.DeleteGlyph.Width;
            end;

            if APlannerItem.Attachement <> '' then
            begin
              tr.Left := tr.Right - FPlanner.AttachementGlyph.Width;

              if PtInRect(tr,Point(X,Y)) then
              begin
                AutoHandle := true;

                if Assigned(FPlanner.FOnItemAttachementClick) then
                  FPlanner.FOnItemAttachementCLick(FPlanner,APlannerItem,APlannerItem.Attachement,AutoHandle);
                if AutoHandle then

                  {$IFNDEF TMSDOTNET}
                  ShellExecute(0,'open',PChar(APlannerItem.Attachement),nil,nil,SW_NORMAL);
                  {$ENDIF}

                  {$IFDEF TMSDOTNET}
                  ShellExecute(0,'open',APlannerItem.Attachement,'','',SW_NORMAL);
                  {$ENDIF}


                Exit;
              end;

              tr.Right := tr.Right - FPlanner.AttachementGlyph.Width;
            end;

            if APlannerItem.URL <> '' then
            begin
              tr.Left := tr.Right - FPlanner.URLGlyph.Width;

              if PtInRect(tr,Point(X,Y)) then
              begin
                AutoHandle := true;

                if Assigned(FPlanner.FOnItemURLClick) then
                  FPlanner.FOnItemURLCLick(FPlanner,APlannerItem,APlannerItem.URL,AutoHandle);
                if AutoHandle then
                  {$IFNDEF TMSDOTNET}
                  ShellExecute(0,'open',PChar(APlannerItem.URL),nil,nil,SW_NORMAL);
                  {$ENDIF}
                  {$IFDEF TMSDOTNET}
                  ShellExecute(0,'open',APlannerItem.URL,'','',SW_NORMAL);
                  {$ENDIF}


                Exit;
              end;
            end;


            if (APlannerItem.CaptionType in [ctText,ctTimeText]) then
            begin
              if IsHtml(APlannerItem,APlannerItem.CaptionText,true) then

                if HTMLDrawEx(Canvas, APlannerItem.CaptionText, r, FPlanner.PlannerImages, X, Y,
                  -1, -1, 1, True, False, False, True, True, False, APlannerItem.WordWrap
                  ,False
                  , 1.0, FPlanner.URLColor,
                  clNone, clNone, clGray, Anchor, StrippedHtmlString, FocusAnchor, XSize, YSize, ml, hl, hr
                  ,cr, CID, CV, CT, FPlanner.FImageCache, FPlanner.FContainer, Handle
                  ) then

              begin
                if Assigned(FPlanner.FOnItemAnchorClick) then
                  FPlanner.FOnItemAnchorClick(FPlanner, APlannerItem, Anchor);
                Exit;
              end;
            end;

            r.Top := r.Top + APlannerItem.FCaptionHeight;
          end;

          if IsHtml(APlannerItem,s,false) then
          begin
            Canvas.Font := APlannerItem.Font;

            if APlannerItem.Shadow and not APlannerItem.Background and (APlannerItem.Shape = psRect)
              and not FPlanner.TrackOnly  then
            begin
              r.Right := r.Right - 5;
              r.Bottom := r.Bottom - 3;
            end
            else
            begin
              r.Right := r.Right - 2;
            end;

            r.Left := r.Left + 2;

            APlannerItem.CompletionAdapt(r);
            APlannerItem.ImageListAdapt(r);

            if HTMLDrawEx(Canvas, s, r, FPlanner.PlannerImages, X, Y,
              -1, -1, 1, True, False, False, True, True, False, APlannerItem.WordWrap
              ,False
              , 1.0, FPlanner.URLColor,
              clNone, clNone, clGray, Anchor, StrippedHtmlString, FocusAnchor, XSize, YSize, ml, hl, hr
              ,cr, CID, CV, CT, FPlanner.FImageCache, FPlanner.FContainer, Handle
              ) then

            begin
              if cr.Right <> 0 then
              begin
                FormHandle(APlannerItem, cr, CID, CT, CV);

                If Assigned(FPlanner.FOnItemControlClick) then
                  FPlanner.FOnItemControlClick(Self,X,Y,APlannerItem,CID,CT,CV);

                {$IFNDEF TMSDOTNET}
                InvalidateRect(Handle,@cr,False);
                {$ENDIF}
                {$IFDEF TMSDOTNET}
                InvalidateRect(Handle,cr,False);
                {$ENDIF}

              end;

              if Assigned(FPlanner.FOnItemAnchorClick) then
                FPlanner.FOnItemAnchorClick(FPlanner, APlannerItem, Anchor);
              Exit;
            end;
          end;
        end;

        if (Y < GridRect.Top + 3) and not APlannerItem.Background and not
          APlannerItem.FixedSize and (FPlanner.UserMode in [puNormal, puReadOnly]) then
        begin
          if FMemo.Visible then
            FMemo.DoExit;
          FItemXY := Point(APlannerItem.ItemPos, APlannerItem.ItemBegin);
          FItemXYS := Rect(APlannerItem.ItemPos, APlannerItem.ItemBegin, APlannerItem.ItemEnd, 0);
          FMouseDownSizeUp := not APlannerItem.FixedSize;
          FMouseStart := FMouseDownSizeUp;
          HintShowXY(X, Y, APlannerItem.ItemStartTimeStr);
          Exit;
        end;

        {
        if (Message.YPos + 5 > GridRect.Bottom + (APlannerItem.ItemEnd - APlannerItem.ItemBegin - 1) *
          DefaultRowHeight) and
          not APlannerItem.Background and not APlannerItem.FixedSize then
        }
        if (Y + 5 > GridRectE.Bottom)  and
          not APlannerItem.Background and not APlannerItem.FixedSize and (FPlanner.UserMode in [puNormal, puReadOnly]) then
        begin
          if FMemo.Visible then
            FMemo.DoExit;

          FItemXY := Point(APlannerItem.ItemPos, APlannerItem.ItemEnd);
          FItemXYS := Rect(APlannerItem.ItemPos, APlannerItem.ItemBegin, APlannerItem.ItemEnd, 0);
          FMouseDownSizeDown := not APlannerItem.FixedSize;
          FMouseStart := FMouseDownSizeDown;

          HintShowXY(X, Y, APlannerItem.ItemEndTimeStr);
          Exit;
        end;

        if Assigned(FPlanner.PlannerImages) and
           Assigned(FPlanner.FOnItemImageClick) then
        begin
          if (Y > GridRect.Top) and (Y < GridRect.Top + FPlanner.PlannerImages.Height + 3) and
             (X >= GridRect.Left) and (X < GridRect.Left + ImgSize) and
            ((APlannerItem.ImageID >= 0) or (APlannerItem.FImageIndexList.Count > 0)) then
          begin
            iw := FPlanner.PlannerImages.Width;

            if (X < GridRect.Left + ImgSize) and (iw > 0) then
            begin
              if (((X - GridRect.Left + 8) div iw) <= APlannerItem.FImageIndexList.Count) or (APlannerItem.ImageID >= 0) then
                FPlanner.FOnItemImageClick(FPlanner, APlannerItem, ((X - GridRect.Left + 8) div iw) - 1);
            end;
            Exit;
          end;
        end;

        if ((X < GridRect.Left + FPlanner.TrackWidth + 2) or
          ((Y > GridRect.Top + 3) and (Y < GridRect.Top +
            APlannerItem.GetCaptionHeight) and (APlannerItem.ItemBegin = GridCoord.Y) and
           (X > GridRect.Left) ))

        and not APlannerItem.Background and not APlannerItem.FixedPos and (FPlanner.UserMode in [puNormal, puReadOnly]) then
        begin
          FItemXY := Point(APlannerItem.ItemPos, APlannerItem.ItemBegin);
          FItemXYS := Rect(APlannerItem.ItemPos, APlannerItem.ItemBegin, APlannerItem.ItemEnd, 0);
          FMouseDownMove := not APlannerItem.FixedPos;
          FMouseDownMoveFirst := FMouseDownMove;
          FMouseStart := FMouseDownMove;
          if FMemo.Visible then
            FMemo.DoExit;

          HintShowXY(X, Y, APlannerItem.ItemSpanTimeStr);
          Exit;
        end;


        if APlannerItem.NotEditable and FPlanner.DirectMove and not APlannerItem.FixedPos and (FPlanner.UserMode in [puNormal, puReadOnly]) then
        begin
          FItemXY := Point(APlannerItem.ItemPos, APlannerItem.ItemBegin);
          FItemXYS := Rect(APlannerItem.ItemPos, APlannerItem.ItemBegin, APlannerItem.ItemEnd, 0);
          FMouseDownMove := not APlannerItem.FixedPos;
          FMouseDownMoveFirst := FMouseDownMove;
          FMouseStart := FMouseDownMove;

          HintShowXY(X, Y, APlannerItem.ItemSpanTimeStr);
          Exit;
        end;

        if APlannerItem.NotEditable then
          Exit;

        GridRect := CellRectEx(APlannerItem.ItemPos + ColOffset, APlannerItem.ItemBegin);

        StartEditCol(GridRect, APlannerItem, X, Y);

      end
      else
        if not Assigned(nplIt) then inherited;
    end
    else
    begin
      nplIt := FPlanner.Items.FocusItem(GridCoord.X - ColOffset, GridCoord.Y - RowOffset, Y -
        GridRect.Top, ssCtrl in Shift);

      if Assigned(nplIt) and (APlannerItem <> nplIt) then
      begin
        FPlanner.ItemSelected(nplIt);
        if Self.CanFocus then
          Self.SetFocus;

        // Direct move handling or always move of readonly items
        if (FPlanner.DirectMove or nplIt.NotEditable) and not nplIt.FixedPos and (FPlanner.UserMode in [puNormal, puReadOnly]) then
        begin
          FItemXY := Point(nplIt.ItemBegin, nplIt.ItemPos);
          FItemXYS := Rect(nplIt.ItemPos, nplIt.ItemBegin, nplIt.ItemEnd, 0);
          FMouseDownMove := not nplIt.FixedPos;
          FMouseDownMoveFirst := FMouseDownMove;
          FMouseStart := FMouseDownMove;
          if FMemo.Visible then
            FMemo.DoExit;

          HintShowXY(X, Y, nplIt.ItemSpanTimeStr);
        end;

        if FPlanner.EditDirect then
        begin
          APlannerItem := nplIt;
          APlannerItem.EnsureFullVisibility;
        end
        else
          Exit;
      end;

      if (Assigned(nplIt)) and (APlannerItem <> nplIt) and not Assigned(APlannerItem) then
      begin
        FPlanner.ItemSelected(nplIt);
        if Self.CanFocus then
          Self.SetFocus;
      end;

      if (APlannerItem = nplIt) and Assigned(APlannerItem) then
      begin
        GridRect := CellRectEx(APlannerItem.ItemBegin, APlannerItem.ItemPos + RowOffset);

        ImgSize := 0;

        if Assigned(FPlanner.PlannerImages) and
           ((APlannerItem.ImageID >= 0) or (APlannerItem.FImageIndexList.Count > 0)) then
          begin
            iw := FPlanner.PlannerImages.Width;
            ImgSize := (iw * APlannerItem.FImageIndexList.Count) + iw;
          end;

        APlannerItem.CalcConflictRect(GridRect, ColWidthEx(nplIt.ItemPos), RowHeightEx(RowOffset),
          FPlanner.Sidebar.Orientation = soVertical);

        if APlannerItem.Focus then
        begin
          s := ConcatenateTextStrings(APlannerItem.Text);

          r := CellRectEx(GridCoord.X, GridCoord.Y);

          APlannerItem.CalcConflictRect(r, ColWidthEx(nplIt.ItemPos), RowHeightEx(nplIt.ItemPos),
            FPlanner.Sidebar.Orientation = soVertical);

          r.Top := r.Top + FPlanner.TrackWidth;
          r.Left := r.Left - ((GridCoord.X - APlannerItem.ItemBegin) * DefaultColWidth) + 4;
          r.Right := r.Right + ((APlannerItem.ItemEnd - GridCoord.X - 1) * DefaultColWidth) +
            4;

          if APlannerItem.CaptionType <> ctNone then
          begin
            tr := r;
            tr.Right := tr.Right - 4 - FPlanner.TrackWidth;

            tr.Bottom := tr.Top + 16;

            if APlannerItem.ShowDeleteButton then
            begin
              tr.Left := tr.Right - FPlanner.DeleteGlyph.Width;
              if PtInRect(tr,Point(X,Y)) then
              begin
                if Assigned(FPlanner.OnItemDelete) then
                  FPlanner.OnItemDelete(Self,APlannerItem);

                if FPlanner.AutoInsDel then
                begin
                  if Assigned(FPlanner.OnItemDeleted) then
                    FPlanner.OnItemDeleted(Self,APlannerItem);
                  FPlanner.FreeItem(APlannerItem);
                end;
                Exit;
              end;
              tr.Right := tr.Right - FPlanner.DeleteGlyph.Width;
            end;


            if APlannerItem.Attachement <> '' then
            begin
              tr.Left := tr.Right - FPlanner.AttachementGlyph.Width;

              if PtInRect(tr,Point(X,Y)) then
              begin
                AutoHandle := true;

                if Assigned(FPlanner.FOnItemAttachementClick) then
                  FPlanner.FOnItemAttachementCLick(FPlanner,APlannerItem,APlannerItem.Attachement,AutoHandle);
                if AutoHandle then

                  {$IFNDEF TMSDOTNET}
                  ShellExecute(0,'open',PChar(APlannerItem.Attachement),nil,nil,SW_NORMAL);
                  {$ENDIF}

                  {$IFDEF TMSDOTNET}
                  ShellExecute(0,'open',APlannerItem.Attachement,'','',SW_NORMAL);
                  {$ENDIF}


                Exit;
              end;

              tr.Right := tr.Right - FPlanner.AttachementGlyph.Width;
            end;

            if APlannerItem.URL <> '' then
            begin
              tr.Left := tr.Right - FPlanner.URLGlyph.Width;

              if PtInRect(tr,Point(X,Y)) then
              begin
                AutoHandle := true;

                if Assigned(FPlanner.FOnItemURLClick) then
                  FPlanner.FOnItemURLCLick(FPlanner,APlannerItem,APlannerItem.URL,AutoHandle);
                if AutoHandle then

                  {$IFNDEF TMSDOTNET}
                  ShellExecute(0,'open',PChar(APlannerItem.URL),nil,nil,SW_NORMAL);
                  {$ENDIF}

                  {$IFDEF TMSDOTNET}
                  ShellExecute(0,'open',APlannerItem.URL,'','',SW_NORMAL);
                  {$ENDIF}


                Exit;
              end;
            end;

            if (APlannerItem.CaptionType in [ctText,ctTimeText]) then
            begin
              if IsHtml(APlannerItem,APlannerItem.CaptionText,true) then

              if HTMLDrawEx(Canvas, APlannerItem.CaptionText, r, FPlanner.PlannerImages, X, Y,
                -1, -1, 1, True, False, False, True, True, False, APlannerItem.WordWrap
                ,False
                , 1.0, FPlanner.URLColor,
                clNone, clNone, clGray, Anchor, StrippedHtmlString, FocusAnchor, XSize, YSize, ml, hl, hr
                , cr, CID, CV, CT, FPlanner.FImageCache, FPlanner.FContainer, Handle
                ) then

              begin
                if Assigned(FPlanner.FOnItemAnchorClick) then
                  FPlanner.FOnItemAnchorClick(FPlanner, APlannerItem, Anchor);
                Exit;
              end;

              r.Top := r.Top + APlannerItem.FCaptionHeight;
            end;
          end;

          if IsHtml(APlannerItem,s,false) then
          begin
            Canvas.Font := APlannerItem.Font;

            if APlannerItem.Shadow and not APlannerItem.Background and (APlannerItem.Shape = psRect)
              and not FPlanner.TrackOnly  then
            begin
              r.Right := r.Right - 5;
              r.Bottom := r.Bottom - 3;
            end
            else
            begin
              r.Right := r.Right - 2;
            end;
            r.Left := r.Left + 2;

            APlannerItem.CompletionAdapt(r);
            APlannerItem.ImageListAdapt(r);

            if HTMLDrawEx(Canvas, s, r, FPlanner.PlannerImages, X, Y,
              -1, -1, 1, True, False, False, True, True, False, APlannerItem.WordWrap
              ,False
              , 1.0, FPlanner.URLColor,
              clNone, clNone, clGray, Anchor, StrippedHtmlString, FocusAnchor, XSize, YSize, ml, hl, hr
              , cr, CID, CV, CT, FPlanner.FImageCache, FPlanner.FContainer, Handle
              ) then

            begin
              if cr.Right <> 0 then
              begin
                OffsetRect(cr,-2,2);
                FormHandle(APlannerItem, cr, CID, CT, CV);

                If Assigned(FPlanner.FOnItemControlClick) then
                  FPlanner.FOnItemControlClick(Self,X,Y,APlannerItem,CID,CT,CV);

                {$IFNDEF TMSDOTNET}
                InvalidateRect(Handle,@cr,False);
                {$ENDIF}

                {$IFDEF TMSDOTNET}
                InvalidateRect(Handle,cr,False);
                {$ENDIF}
              end;

              if Assigned(FPlanner.FOnItemAnchorClick) then
                FPlanner.FOnItemAnchorClick(FPlanner, APlannerItem, Anchor);
              Exit;
            end;
          end;
        end;

        if (X < GridRect.Left + 3) and not APlannerItem.Background and not
          APlannerItem.FixedSize and (FPlanner.UserMode in [puNormal, puReadOnly]) then
        begin
          FItemXY := Point(APlannerItem.ItemBegin, APlannerItem.ItemPos);
          FItemXYS := Rect(APlannerItem.ItemPos, APlannerItem.ItemBegin, APlannerItem.ItemEnd, 0);
          FMouseDownSizeUp := not APlannerItem.FixedSize;
          FMouseStart := FMouseDownSizeUp;
          if FMemo.Visible then
            FMemo.DoExit;

          HintShowXY(X, Y, APlannerItem.ItemStartTimeStr);
          Exit;
        end;

        GridRect := CellRectEx(APlannerItem.ItemEnd -1, APlannerItem.ItemPos + RowOffset);

        if (X + 5 > GridRect.Right) and
          not APlannerItem.Background and not APlannerItem.FixedSize and (FPlanner.UserMode in [puNormal, puReadOnly]) then
        begin
          FItemXY := Point(APlannerItem.ItemEnd, APlannerItem.ItemPos);
          FItemXYS := Rect(APlannerItem.ItemPos, APlannerItem.ItemBegin, APlannerItem.ItemEnd, 0);
          FMouseDownSizeDown := not APlannerItem.FixedSize;
          FMouseStart := FMouseDownSizeDown;

          HintShowXY(X, Y, APlannerItem.ItemEndTimeStr);
          if FMemo.Visible then
            FMemo.DoExit;
          Exit;
        end;

        APlannerItem.CalcConflictRect(GridRect, ColWidthEx(nplIt.ItemPos), RowHeightEx(nplIt.ItemPos),
          FPlanner.Sidebar.Orientation = soVertical);

        if ((Y < GridRect.Top + FPlanner.TrackWidth + 2) or

           ( (Y > GridRect.Top + FPlanner.TrackWidth + 2) and
             (Y < GridRect.Top + FPlanner.TrackWidth + 2 + APlannerItem.GetCaptionHeight) and
             (APlannerItem.ItemPos = GridCoord.Y - RowOffset) and
             (X > r.Left + ImgSize)
           )
           ) and
          not APlannerItem.Background and not APlannerItem.FixedPos and (FPlanner.UserMode in [puNormal, puReadOnly]) then
        begin
          FItemXY := Point(APlannerItem.ItemBegin, APlannerItem.ItemPos);
          FItemXYS := Rect(APlannerItem.ItemPos, APlannerItem.ItemBegin, APlannerItem.ItemEnd, 0);
          FMouseDownMove := not APlannerItem.FixedPos;
          FMouseStart := FMouseDownMove;
          if FMemo.Visible then
            FMemo.DoExit;

          HintShowXY(X, Y, APlannerItem.ItemSpanTimeStr);
          Exit;
        end;

        if Assigned(FPlanner.PlannerImages) and
          Assigned(FPlanner.FOnItemImageClick) then
        begin
          if (X > r.Left) and (X < r.Left + ImgSize) and
             (Y > GridRect.Top) and (Y < GridRect.Top + FPlanner.PlannerImages.Height + 3) and
            ((APlannerItem.ImageID >= 0) or (APlannerItem.FImageIndexList.Count > 0)) then
          begin
            iw := FPlanner.PlannerImages.Width;

            if (((X - r.Left) div iw) >= 0) and (((X - r.Left) div iw) < APlannerItem.ImageIndexList.Count) then
              FPlanner.FOnItemImageClick(FPlanner, APlannerItem, ((X - r.Left) div iw));

            Exit;
          end;
        end;

        if nplIt.NotEditable and FPlanner.DirectMove and not nplIt.FixedPos and (FPlanner.UserMode in [puNormal, puReadOnly]) then
        begin
          FItemXY := Point(nplIt.ItemBegin, nplIt.ItemPos);
          FItemXYS := Rect(nplIt.ItemPos, nplIt.ItemBegin, nplIt.ItemEnd, 0);
          FMouseDownMove := not nplIt.FixedPos;
          FMouseStart := FMouseDownMove;

          HintShowXY(X, Y, nplIt.ItemSpanTimeStr);
          Exit;
        end;

        if APlannerItem.Focus then
        begin
          s := ConcatenateTextStrings(APlannerItem.Text);

          GridRect := CellRectEx(GridCoord.X, GridCoord.Y);
          APlannerItem.CalcConflictRect(GridRect, ColWidthEx(nplIt.ItemPos), RowHeightEx(nplIt.ItemPos),
            FPlanner.Sidebar.Orientation = soVertical);

          GridRect.Top := GridRect.Top + FPlanner.TrackWidth;
          GridRect.Left := GridRect.Left - ((GridCoord.X - APlannerItem.ItemBegin) * DefaultColWidth) + 4;
          GridRect.Right := GridRect.Right + ((APlannerItem.ItemEnd - GridCoord.X - 1) * DefaultColWidth) +
            4;

          if (APlannerItem.CaptionType <> ctNone) then
            GridRect.Top := GridRect.Top + APlannerItem.FCaptionHeight;

          if IsHtml(APlannerItem,s,false) then
          begin
            Canvas.Font := APlannerItem.Font;

            if APlannerItem.Shadow and not APlannerItem.Background and (APlannerItem.Shape = psRect)
              and not FPlanner.TrackOnly  then
            begin
              GridRect.Right := GridRect.Right - 3;
              GridRect.Bottom := GridRect.Bottom - 3;
            end;
            GridRect.Left := GridRect.Left + 2;

            APlannerItem.CompletionAdapt(GridRect);
            APlannerItem.ImageListAdapt(GridRect);            

            if HTMLDrawEx(Canvas, s, GridRect, FPlanner.PlannerImages, X, Y,
              -1, -1, 1, True, False, False, True, True, False, APlannerItem.WordWrap
              ,False
              , 1.0, FPlanner.URLColor,
              clNone, clNone, clGray, Anchor, StrippedHtmlString, FocusAnchor, XSize, YSize, ml, hl, hr
              ,cr, CID, CV, CT, FPlanner.FImageCache, FPlanner.FContainer, Handle
              ) then

            begin
              if Assigned(FPlanner.FOnItemAnchorClick) then
                FPlanner.FOnItemAnchorClick(FPlanner, APlannerItem, Anchor);
            end;
          end;
        end;

        if APlannerItem.NotEditable then
          Exit;

        GridRect := CellRectEx(APlannerItem.ItemBegin, APlannerItem.ItemPos + RowOffset);

        StartEditRow(GridRect, APlannerItem, X, Y);

      end
      else
        inherited;
    end;
  end;

  if OrigButton = mbRight then
  begin
    ColOffset := FPlanner.FSidebar.FColOffset;
    RowOffset := FPlanner.FSidebar.FRowOffset;

    if FMouseDownMove or
      FMouseDownSizeUp or
      FMouseDownSizeDown then
      Exit;

    GridCoord := MouseCoord(X, Y);
    GridRect := CellRectEx(GridCoord.X, GridCoord.Y);

    if FPlanner.Sidebar.Orientation = soVertical then
      APlannerItem := FPlanner.Items.FindItemPos(GridCoord.Y - RowOffset, GridCoord.X - ColOffset, X
        - GridRect.Left)
    else
      APlannerItem := FPlanner.Items.FindItemPos(GridCoord.X - ColOffset, GridCoord.Y - RowOffset, Y
        - GridRect.Top);

    if not Assigned(APlannerItem) or
       ( (FPlanner.Sidebar.Orientation = soVertical) and (X > GridRect.Right - FPlanner.FItemGap)) or
       ( (FPlanner.Sidebar.Orientation = soHorizontal) and (Y > GridRect.Bottom - FPlanner.FItemGap)) then
    begin
      if Assigned(FPlanner.FOnPlannerRightClick) then
      begin
        if FPlanner.Sidebar.Orientation = soVertical then
        begin
          FromSel := Selection.Top + FPlanner.Display.DisplayStart;
          ToSel := 1 + Selection.Bottom + FPlanner.Display.DisplayStart;
          FromSelPrecis := FromSel * FPlanner.Display.DisplayUnit + FPlanner.Display.DisplayOffset;
          ToSelPrecis := ToSel * FPlanner.Display.DisplayUnit + FPlanner.Display.DisplayOffset;

          FPlanner.FOnPlannerRightClick(FPlanner, Col - ColOffset, FromSel,
            FromSelPrecis, ToSel, ToSelPrecis);
        end
        else
        begin
          FromSel := Selection.Left + FPlanner.Display.DisplayStart;
          ToSel := 1 + Selection.Right + FPlanner.Display.DisplayStart;
          FromSelPrecis := FromSel * FPlanner.Display.DisplayUnit + FPlanner.Display.DisplayOffset;
          ToSelPrecis := ToSel * FPlanner.Display.DisplayUnit + FPlanner.Display.DisplayOffset;
          FPlanner.FOnPlannerRightClick(FPlanner, Row - RowOffset, FromSel,
            FromSelPrecis, ToSel, ToSelPrecis);
        end;
      end;
    end;

    if Assigned(APlannerItem) then
    begin
      ScreenPoint := ClientToScreen(Point(X, Y));

      if Assigned(FPlanner.OnItemRightClick) then
        FPlanner.OnItemRightClick(FPlanner, APlannerItem);

      if Assigned(APlannerItem.PopupMenu) then
      begin
        if Assigned(FPlanner.OnItemPopupPrepare) then
          FPlanner.OnItemPopupPrepare(FPlanner, APlannerItem.PopupMenu, APlannerItem);

        FPlanner.PopupPlannerItem := APlannerItem;
        APlannerItem.PopupMenu.PopupComponent := FPlanner;
        APlannerItem.PopupMenu.Popup(ScreenPoint.X, ScreenPoint.Y);
      end;

      if (Assigned(FPlanner.FItemPopup)) then
      begin
        if Assigned(FPlanner.OnItemPopupPrepare) then
          FPlanner.OnItemPopupPrepare(FPlanner, FPlanner.ItemPopup, APlannerItem);

        FPlanner.PopupPlannerItem := APlannerItem;
        FPlanner.ItemPopup.PopupComponent := FPlanner;
        FPlanner.FItemPopup.Popup(ScreenPoint.X, ScreenPoint.Y);
      end;
    end;

    if (Assigned(FPlanner.FGridPopup)) and (APlannerItem = nil) then
    begin
      ScreenPoint := ClientToScreen(Point(X, Y));
      FPlanner.PopupPlannerItem := nil;
      FPlanner.GridPopup.PopupComponent := FPlanner;
      FPlanner.GridPopup.Popup(ScreenPoint.X, ScreenPoint.Y);
    end;
  end;
end;


procedure TPlannerGrid.MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if (csDesigning in ComponentState) then
  begin
    Exit;
  end;

  if Button = mbLeft then
    ReleaseCapture;

  if FCurrCtrlR.Right <> 0 then
    {$IFNDEF TMSDOTNET}
    InvalidateRect(Handle,@FCurrCtrlR,False);
    {$ENDIF}
    {$IFDEF TMSDOTNET}
    InvalidateRect(Handle,FCurrCtrlR,False);
    {$ENDIF}

  inherited;

  if Assigned(FPlanner.FOnPlannerMouseUp) then
  begin
    FPlanner.FOnPlannerMouseUp(FPlanner, Button, Shift, X, Y);
  end;

  if FMouseRelease then
  begin
    FMouseRelease := false;
    FMouseDown := False;
    FMouseDownMove := False;
    FMouseDownSizeUp := False;
    FMouseDownSizeDown := False;
    HintHide;
    Exit;
  end;

  if Button = mbLeft then
  begin
    if FPlanner.Mode.FullHalfDay then
      CorrectSelection;

    if not FMouseDownMove and not FMouseDownSizeUp and not FMouseDownSizeDown and not FMouseUnSelect and
       (ssCtrl in Shift) and FPlanner.DisjunctSelect then
    begin
      with FPlanner.FSelections.Add do
      begin
        SelBegin := FPlanner.SelItemBegin;
        SelEnd := FPlanner.SelItemEnd;
        SelPos := FPlanner.SelPosition;
      end;

      FPlanner.UpdateSelection(FPlanner.SelItemBegin, FPlanner.SelItemEnd, FPlanner.SelPosition, True);
    end;

    if not (ssCtrl in Shift) and FPlanner.DisjunctSelect then
    begin
      with FPlanner.FSelections.Add do
      begin
        SelBegin := FPlanner.SelItemBegin;
        SelEnd := FPlanner.SelItemEnd;
        SelPos := FPlanner.SelPosition;
        FPlanner.UpdateSelection(SelBegin, SelEnd, SelPos, True);
      end;
    end;

    {
    if not (ssCtrl in Shift) and (FPlanner.Selections.Count > 0) and FPlanner.DisjunctSelect then
    begin
      FPlanner.Selections.Clear;
    end;
    }
    
    with FPlanner.Items do
    begin
      if Assigned(Selected) then
      begin
        if FMouseDownMove then
        begin
          HintHide;
          if (FItemXYS.Top <> Selected.ItemBegin) or (FItemXYS.Left <> Selected.ItemPos)
            or (FItemXYS.Right <> Selected.ItemEnd)
            or (Selected.BeginOffset <> 0) or (Selected.EndOffset <> 0) then
            try
              FPlanner.ItemMoved(Selected, FItemXYS.Top, FItemXYS.Right, FItemXYS.Left,
                Selected.ItemBegin, Selected.ItemEnd, Selected.ItemPos);
              // call item moved too for linked items!
              FPlanner.Items.MoveLinks(Selected);

            except
              FMouseDown := False;
              FMouseDownMove := False;
              FMouseDownSizeUp := False;
              FMouseDownSizeDown := False;
            end;
        end;

        if FMouseDownSizeUp then
        begin
          HintHide;
          try
            FPlanner.ItemSized(Selected, FItemXYS.Top, FItemXYS.Right,
                               Selected.ItemBegin, Selected.ItemEnd);
            SizeLinks(Selected);
          except
            FMouseDown := False;
            FMouseDownMove := False;
            FMouseDownSizeUp := False;
            FMouseDownSizeDown := False;
          end;
        end;

        if FMouseDownSizeDown then
        begin
          HintHide;
          try
            FPlanner.ItemSized(Selected, FItemXYS.Top, FItemXYS.Right,
                               Selected.ItemBegin, Selected.ItemEnd);
            SizeLinks(Selected);
          except

            FMouseDown := False;
            FMouseDownMove := False;
            FMouseDownSizeUp := False;
            FMouseDownSizeDown := False;
          end;
        end;
      end;
    end;
    FMouseDown := False;
    FMouseDownMove := False;
    FMouseDownSizeUp := False;
    FMouseDownSizeDown := False;
  end;

  if not FPlanner.FDownOnItem and FPlanner.AutoCreateOnSelect then
  begin
    FPlanner.CreateItemAtSelection;
    FPlanner.FDownOnItem := false;
  end;
end;


{$IFDEF TMSDOTNET}
procedure TPlannerGrid.WMNotify(var Message: TWMNOTIFYTT);
{$ENDIF}
{$IFNDEF TMSDOTNET}
procedure TPlannerGrid.WMNotify(var Message: TWMNOTIFY);
{$ENDIF}
var
  buffer:array[0..255] of char;
  pt: TPoint;
  plIt: TPlannerItem;
  {$IFDEF TMSDOTNET}
  di: TToolTipText;
  {$ENDIF}
  {$IFNDEF TMSDOTNET}
  di: PNMTTDispInfo;
  {$ENDIF}
  ATitle, AText: string;
  AIcon: Integer;
  cell: TPoint;
  len1, len2, i: integer;

begin
  {$IFDEF TMSDOTNET}
  if not (integer(Message.NMHdr.hwndFrom) = integer(fhToolTip)) then
    Exit;
  {$ENDIF}
  {$IFNDEF TMSDOTNET}
  if not (integer(Message.NMHdr^.hwndFrom) = integer(fhToolTip)) then
    Exit;
  {$ENDIF}

  {$IFDEF TMSDOTNET}
  with Message.NMHdr do
  {$ENDIF}
  {$IFNDEF TMSDOTNET}
  with Message.NMHdr^ do
  {$ENDIF}
    case code of
    TTN_NEEDTEXT:
    begin
      if not FPlanner.Balloon.Enable then
        Exit;

      {$IFDEF TMSDOTNET}
      di := Message.ToolTipText;
      {$ENDIF}

      {$IFNDEF TMSDOTNET}
      di := PNMTTDispInfo(TMessage(Message).LParam);
      {$ENDIF}

      GetCursorPos(pt);
      pt := ScreenToClient(pt);

      plIt := FPlanner.XYToItem(pt.X,pt.Y);

      cell := FPlanner.XYToCell(pt.X,pt.Y);

      if Assigned(plIt) then
      begin
        ATitle := HTMLStrip(plIt.CaptionText);
        ATitle := UnFixMarkUp(ATitle);

        if IsRtf(plIt.NotesText) then
        begin
          if not FPlanner.RichEdit.Visible then
          begin
            FPlanner.TextToRich(plIt.NotesText);
            AText := FPlanner.FRichEdit.Text;
          end;
        end
        else
          AText := HTMLStrip(plIt.NotesText);

        AText := UnFixMarkUp(AText);

        {$IFNDEF TMSDOTNET}
        len1 := Length(AText);
        len2 := SizeOf(FTooltipBuffer) div 4;

        // balloon tooltip cannot handle tabs well
        i := 1;
        while i < len1 do
        begin
          if (AText[i] = #9) then
            AText[i] := #32;
          inc(i);
        end;

        i := 1;
        if AText <> '' then
          while ( (AText[i] = #13) or (AText[i] = #10) or (AText[i] = #9) ) do
            inc(i);

        if len1 > len2 then
          AText := Copy(AText, i, len2 - 3) + '...'
        else
          if i > 1 then
            AText := Copy(AText, i, len1 - i + 1);
        {$ENDIF}

        AIcon := 1;
        // for some reason, balloon tips will not show multiline when there is no title  ...
        if ATitle = '' then
          ATitle := ' ';
        if Assigned(FPlanner.OnItemBalloon) then
          FPlanner.OnItemBalloon(FPlanner, plIt, ATitle, AText, AIcon);
      end
      else
      begin
        AText := '';
        ATitle := '';
        AIcon := 1;
        if Assigned(FPlanner.OnPlannerBalloon) then
          FPlanner.OnPlannerBalloon(FPlanner,cell.X, cell.Y, ATitle, AText, AIcon);
      end;

      {$IFNDEF TMSDOTNET}
      strpcopy(ftooltipbuffer,AText);

      if length(ATitle) > 99 then
        ATitle := copy(ATitle,1, 96) + '...';

      strpcopy(buffer,ATitle);

      di^.lpszText := @ftooltipbuffer;
      {$ENDIF}
      {$IFDEF TMSDOTNET}
      di.lpszText := AText;
      Message.ToolTipText := di;
      {$ENDIF}

      if FPlanner.Balloon.TextColor <> clNone then
        SendMessage(fhtooltip, TTM_SETTIPTEXTCOLOR, ColorToRgb(FPlanner.Balloon.TextColor), 0);
      if FPlanner.Balloon.BackgroundColor <> clNone then
        SendMessage(fhtooltip, TTM_SETTIPBKCOLOR, ColorToRgb(FPlanner.Balloon.BackgroundColor), 0);

      SendMessage(fhToolTip, TTM_SETMAXTIPWIDTH, 0, 400);
      {$IFDEF TMSDOTNET}
      SendTextMessage(fhtooltip,TTM_SETTITLE,AIcon,ATitle);
      {$ENDIF}
      {$IFNDEF TMSDOTNET}
      SendMessage(fhtooltip,TTM_SETTITLE,AIcon,longint(@buffer));
      {$ENDIF}
    end;
    TTN_SHOW:
    begin
    end;
    TTN_POP:
    begin
    end;
    end;
end;


procedure TPlannerGrid.MouseMove(Shift: TShiftState; X, Y: Integer);
var
  GridCoord: TGridCoord;
  cr, r, tr, ir, hr, cor: TRect;
  APlannerItem, plIt: TPlannerItem;
  dx, dy, h: Integer;
  s, Anchor, StrippedHtmlString, FocusAnchor: string;
  XSize, YSize, ml, hl: Integer;
  ColOffset, RowOffset: Integer;
  Allow: Boolean;
  MaxCol: Integer;
  ImgSize: Integer;
  NoClip: Boolean;
  SideCorr: Integer;
  CID, CV, CT: string;

begin
  ColOffset := FPlanner.FSidebar.FColOffset;
  RowOffset := FPlanner.FSidebar.FRowOffset;
  GridCoord := MouseCoord(x,y);
  FMouseRC := MouseCoord(x,y);

  NoClip := (FPlanner.Mode.PlannerType in [plDay, plDayPeriod, plMonth, plHalfDayPeriod, plWeek,plTimeLine]) and
            not FPlanner.Mode.Clip;

  if FPlanner.Sidebar.Visible and
    (FPlanner.SideBar.Position in [spLeftRight,spRight]) then
  begin
    if GridCoord.X = ColCount - 1 then
      Exit;
  end;

  if FPlanner.SideBar.Visible and
     (FPlanner.SideBar.Position in [spLeft, spTop]) then
    SideCorr := 1
  else
    SideCorr := 0;

  if FScrolling then
  begin
    if GetTickCount - FScrollTime > FPlanner.FScrollDelay then
      FScrolling := False;
    inherited;
    Exit;
  end;

  FScrollTime := GetTickCount;

  if FMouseDownMove and FPlanner.DirectDrag and FPlanner.DragItem and Assigned(FPlanner.Items.Selected) then
  begin
    if (Cursor <> crSizeAll) and (Cursor <> crSizeNS) and (Cursor <> crSizeWE) then
    begin
      Allow := True;

      if Assigned(FPlanner.OnItemDrag) then
        FPlanner.OnItemDrag(FPlanner,FPlanner.Items.Selected, Allow);

      if Allow then
      begin
        inherited;
        HintHide;
        FPlanner.BeginDrag(True, -1);
        FMouseDownMove := False;
        Exit;
      end;
    end;
  end;

  if (ssCtrl in Shift)
     or (GetKeystate(VK_MENU) and $8000 = $8000)
  then
  begin
    if FMouseDownMove and FPlanner.DragItem and Assigned(FPlanner.Items.Selected)
      and not FPlanner.Dragging then
    begin
      Allow := True;

      if Assigned(FPlanner.OnItemDrag) then
        FPlanner.OnItemDrag(FPlanner,FPlanner.Items.Selected, Allow);

      if Allow then
      begin
        inherited;
        HintHide;
        FPlanner.BeginDrag(True, -1);
        FMouseDownMove := False;
        Exit;
      end;
    end;
  end;

 { Handles vertical planner mode }
  if FPlanner.Sidebar.Orientation = soVertical then
  begin
    if FMouseDownMove and Assigned(FPlanner.Items.Selected) then
    begin
      if (ssCtrl in Shift) and FMouseDownMoveFirst and FPlanner.CtrlDragCopy then
      begin
        FMouseDownMoveFirst := False;
        plIt := FPlanner.CreateItem;
        plIt.Assign(FPlanner.Items.Selected);

        if Assigned(FPlanner.OnItemCreated) then
          FPlanner.OnItemCreated(FPlanner, plIt);

        FPlanner.UpdateItem(plIt);
      end;

      dy := (Y - FMouseXY.Y) div DefaultRowHeight;
      dx := (GridCoord.X - ColOffset - FItemXY.X);

      if FPlanner.Items.Selected.FixedPosition then
        dx := 0;

      if FPlanner.Items.Selected.FixedTime then
        dy := 0;

      case FPlanner.SideBar.Position of
      spLeft: MaxCol := ColCount - 1;
      spRight: MaxCol := ColCount - 2;
      spLeftRight: MaxCol := ColCount - 3
      else
        MaxCol := ColCount - 1;
      end;

      if not FPlanner.SideBar.Visible then
        MaxCol := ColCount - 1;

      with FPlanner.Items.Selected do
      begin
        h := ItemEnd - ItemBegin + BeginOffset + EndOffset;

        if ((ItemBegin <> FItemXY.Y + dy) or (ItemPos <> FItemXY.X + dx)) and
           (FItemXY.X + dx >= 0) and not
           FPlanner.Items.HasItem(FItemXY.Y + dy, FItemXY.Y + dy + h, FItemXY.X + dx) and
           (((FItemXY.Y + dy + h <= RowCount) and (FItemXY.Y + dy >= 0)) or NoClip) and
           (FItemXY.X + dx <= MaxCol) then
        begin
          Allow := True;

          if Assigned(FPlanner.FOnItemMoving) then
            FPlanner.FOnItemMoving(FPlanner, FPlanner.Items.Selected, (FItemXY.Y
              + dy) - ItemBegin, (FItemXY.X + dx) - ItemPos, Allow);

          if not Allow then
          begin
            FMouseRelease := true;
            SendMessage(Handle,WM_LBUTTONUP,0,0);
            Exit;
          end;

          ir := FPlanner.Items.Selected.GetGridRect;
          FPlanner.Items.BeginUpdate;
          MoveItem(FItemXY.Y + dy, FItemXY.Y + dy + h, FItemXY.X + dx, FItemXY.Y);
          FPlanner.Items.ResetUpdate;

          FPlanner.FGrid.InvalidateCellRect(ir);
          FPlanner.Items.Selected.Repaint;

          // Check here if scroll required
          if (ItemEnd - TopRow >= VisibleRowCount) and (TopRow + VisibleRowCount
            < RowCount) and (Y > FMouseXY.Y) then
          begin
            TopRow := TopRow + 1;

            if FPlanner.ScrollSmooth then
              FScrolling := True;

            FMouseXY.Y := FMouseXY.Y - DefaultRowHeight;
          end;

          if (ItemBegin <= TopRow) and (TopRow > 0) then
          begin
            TopRow := TopRow - 1;
            if FPlanner.ScrollSmooth then
              FScrolling := True;
            FMouseXY.Y := FMouseXY.Y + DefaultRowHeight;
          end;

          if FPlanner.ScrollSmooth then
          begin
            if (ItemPos + SideCorr <= LeftCol) and (LeftCol > SideCorr) and (LeftCol > FixedCols) then
            begin
              LeftCol := LeftCol - 1;
              FScrolling := True;
            end;

            if (ItemPos + SideCorr >= VisibleColCount + LeftCol) and
               (LeftCol + VisibleColCount < ColCount) then
            begin
              LeftCol := LeftCol + 1;
              FScrolling := True;
            end;
          end;

          HintShowXY(X, Y, FPlanner.Items.Selected.ItemSpanTimeStr);
        end;
      end;
      Exit;
    end;

    if FMouseDownSizeUp and Assigned(FPlanner.Items.Selected) then
    begin
      dy := (Y - FMouseXY.Y) div DefaultRowHeight;
      with FPlanner.Items.Selected do
      begin
        if (ItemBegin <> FItemXY.Y + dy) and
           (FItemXY.Y + dy >= 0) and
           (FItemXY.Y + dy < ItemEnd) and not FPlanner.Items.HasItem(FItemXY.Y +
            dy, ItemEnd, ItemPos) then
        begin
          Allow := True;

          if Assigned(FPlanner.FOnItemSizing) then
            FPlanner.FOnItemSizing(FPlanner, FPlanner.Items.Selected, FItemXY.Y
              + dy - ItemBegin, 0, Allow);

          if not Allow then
          begin
            FMouseRelease := true;
            SendMessage(Handle,WM_LBUTTONUP,0,0);
            Exit;
          end;

          ir := FPlanner.Items.Selected.GetGridRect;
          FPlanner.Items.BeginUpdate;
          SizeItem(FItemXY.Y + dy, ItemEnd);
          FPlanner.Items.ResetUpdate;

          FPlanner.FGrid.InvalidateCellRect(ir);
          FPlanner.Items.Selected.Repaint;

          { Check here if scroll required }
          if (ItemBegin <= TopRow) and (TopRow > 0) then
          begin
            TopRow := TopRow - 1;
            if FPlanner.ScrollSmooth then
              FScrolling := True;

            FMouseXY.Y := FMouseXY.Y + DefaultRowHeight;
          end;
      
          HintShowXY(X, Y, FPlanner.Items.Selected.ItemStartTimeStr);
        end;
      end;
      Exit;
    end;

    if FMouseDownSizeDown and Assigned(FPlanner.Items.Selected) then
    begin
      dy := (Y - FMouseXY.Y) div DefaultRowHeight;
      with FPlanner.Items.Selected do
      begin

        if ((ItemEnd <> FItemXY.Y + dy)) and
           (FItemXY.Y + dy >= 0) and (FItemXY.Y + dy <= RowCount) and
           (FItemXY.Y + dy > ItemBegin) and not FPlanner.Items.HasItem(ItemBegin,
            FItemXY.Y + dy, ItemPos) then
        begin
          Allow := True;

          if Assigned(FPlanner.FOnItemSizing) then
            FPlanner.FOnItemSizing(FPlanner, FPlanner.Items.Selected, 0,
              FItemXY.Y + dy - ItemEnd, Allow);

          if not Allow then
          begin
            FMouseRelease := true;
            SendMessage(Handle,WM_LBUTTONUP,0,0);
            Exit;
          end;

          ir := FPlanner.Items.Selected.GetGridRect;
          FPlanner.Items.BeginUpdate;
          SizeItem(ItemBegin, FItemXY.Y + dy);

          FPlanner.Items.ResetUpdate;
          FPlanner.FGrid.InvalidateCellRect(ir);
          FPlanner.Items.Selected.Repaint;

          { Check here if scroll required }
          if (ItemEnd - TopRow >= VisibleRowCount) and (TopRow + VisibleRowCount
            < RowCount) then
          begin
            TopRow := TopRow + 1;
            if FPlanner.ScrollSmooth then
              FScrolling := True;

            FMouseXY.Y := FMouseXY.Y - DefaultRowHeight;
          end;
          
          HintShowXY(X,Y, FPlanner.Items.Selected.ItemEndTimeStr);
        end;
      end;
      Exit;
    end;
  end
  else

 { Handles horizontal planner mode }
  begin
    if FMouseDownMove and Assigned(FPlanner.Items.Selected) then
    begin
      if (ssCtrl in Shift) and FMouseDownMoveFirst and FPlanner.CtrlDragCopy then
      begin
        FMouseDownMoveFirst := False;
        plIt := FPlanner.CreateItem;
        plIt.Assign(FPlanner.Items.Selected);

        if Assigned(FPlanner.OnItemCreated) then
          FPlanner.OnItemCreated(self, plIt);
      end;
    
      dx := (X - FMouseXY.X) div DefaultColWidth;
      dy := (GridCoord.Y - RowOffset - FItemXY.Y);

      if FPlanner.Items.Selected.FixedPosition then
        dy := 0;

      if FPlanner.Items.Selected.FixedTime then
        dx := 0;

      if FPlanner.Mode.FullHalfDay then
        if not odd(FPlanner.Items.Selected.BeginOffset + FItemXY.X + dx) {or (FItemXY.X + dx <= 0)} then Exit;


      {$IFDEF TMSDEBUG}
      outputdebugstring(pchar('dx:'+inttostr(dx)));
      {$ENDIF}

      with FPlanner.Items.Selected do
      begin
        h := ItemEnd - ItemBegin;
        if ((ItemBegin <> FItemXY.X + dx) or (ItemPos <> FItemXY.Y + dy)) and
           (FItemXY.Y + dy >= 0) and not FPlanner.Items.HasItem(FItemXY.X + dx,
            FItemXY.X + dx + h, FItemXY.Y + dy) and
           (((FItemXY.X + dx + h <= ColCount) and (FItemXY.X + dx >= 0)) or NoClip) then
        begin
          Allow := True;
          if Assigned(FPlanner.FOnItemMoving) then
            FPlanner.FOnItemMoving(FPlanner, FPlanner.Items.Selected, (FItemXY.X
              + dx) - ItemBegin, (FItemXY.Y + dy) - ItemPos, Allow);

          if not Allow then
          begin
            FMouseRelease := true;
            SendMessage(Handle,WM_LBUTTONUP,0,0);
            Exit;
          end;

          ir := FPlanner.Items.Selected.GetGridRect;
          FPlanner.Items.BeginUpdate;

          MoveItem(FItemXY.X + dx,FItemXY.X + dx + h,FItemXY.Y + dy, FItemXY.X);
          FPlanner.Items.ResetUpdate;

          FPlanner.FGrid.InvalidateCellRect(ir);
          FPlanner.Items.Selected.Repaint;

          { Check here if scroll required }
          if (ItemEnd - LeftCol >= VisibleColCount) and (EndOffset = 0) and (BeginOffset = 0) and
             (LeftCol + VisibleColCount < ColCount) then
          begin
            LeftCol := LeftCol + 1;
            if FPlanner.ScrollSmooth then
              FScrolling := True;
            FMouseXY.X := FMouseXY.X - DefaultColWidth;
          end;

          if (ItemBegin <= LeftCol) and (LeftCol > 0) and (EndOffset = 0) and (BeginOffset = 0) then
          begin
            LeftCol := LeftCol - 1;
            if FPlanner.ScrollSmooth then
              FScrolling := True;
            FMouseXY.X := FMouseXY.X + DefaultColWidth;
          end;

          if (ItemPos - TopRow + SideCorr >= VisibleRowCount) and
             (TopRow + VisibleRowCount < RowCount) then
          begin
            TopRow := TopRow + 1;
            if FPlanner.ScrollSmooth then
              FScrolling := True;
            FMouseXY.Y := FMouseXY.Y + DefaultRowHeight;
          end;

          if (ItemPos + SideCorr <= TopRow) and (TopRow > SideCorr) then
          begin
            TopRow := TopRow - 1;
            if FPlanner.ScrollSmooth then
              FScrolling := True;
            FMouseXY.Y := FMouseXY.Y - DefaultRowHeight;
          end;

          HintShowXY(X, Y, FPlanner.Items.Selected.ItemSpanTimeStr);
        end;
      end;
      Exit;
    end;

    if FMouseDownSizeUp and Assigned(FPlanner.Items.Selected) then
    begin
      dx := (X - FMouseXY.X) div DefaultColWidth;

      if FPlanner.Mode.FullHalfDay then
        if not odd(FItemXY.X + dx) or (FItemXY.X + dx <= 0) then Exit;

      with FPlanner.Items.Selected do
      begin
        if (ItemBegin <> FItemXY.X + dx) and
           (FItemXY.X + dx >= 0) and
           (FItemXY.X + dx < ItemEnd) and not FPlanner.Items.HasItem(FItemXY.X +
            dx, ItemEnd, ItemPos) then
        begin
          Allow := True;

          if Assigned(FPlanner.FOnItemSizing) then
            FPlanner.FOnItemSizing(FPlanner, FPlanner.Items.Selected, (FItemXY.X
              + dx) - ItemBegin, 0, Allow);

          if not Allow then
          begin
            FMouseRelease := true;
            SendMessage(Handle,WM_LBUTTONUP,0,0);
            Exit;
          end;

          ir := FPlanner.Items.Selected.GetGridRect;
          FPlanner.Items.BeginUpdate;
          SizeItem(FItemXY.X + dx, ItemEnd);
          FPlanner.Items.ResetUpdate;
          FPlanner.FGrid.InvalidateCellRect(ir);
          FPlanner.Items.Selected.Repaint;

          { Check here if scroll required }
          if (ItemBegin <= LeftCol) and (LeftCol > 0) then
          begin
            LeftCol := LeftCol - 1;
            if FPlanner.ScrollSmooth then
              FScrolling := True;

            FMouseXY.X := FMouseXY.X + DefaultColWidth;
          end;

          HintShowXY(X, Y, FPlanner.Items.Selected.ItemStartTimeStr);
        end;
      end;
      Exit;
    end;

    if FMouseDownSizeDown and Assigned(FPlanner.Items.Selected) then
    begin
      dx := (X - FMouseXY.X) div DefaultColWidth;

      if FPlanner.Mode.FullHalfDay then
        if not odd(FItemXY.X + dx) or (FItemXY.X + dx <= 0) then Exit;

      with FPlanner.Items.Selected do
      begin
        if ((ItemEnd <> FItemXY.X + dx)) and
           (FItemXY.X + dx >= 0) and (FItemXY.X + dx <= ColCount) and
           (FItemXY.X + dx > ItemBegin) and not FPlanner.Items.HasItem(ItemBegin,
            FItemXY.X + dx, ItemPos) then
        begin
          Allow := True;

          if Assigned(FPlanner.FOnItemSizing) then
            FPlanner.FOnItemSizing(FPlanner, FPlanner.Items.Selected, 0,
              (FItemXY.X + dx) - ItemEnd, Allow);

          if not Allow then
          begin
            FMouseRelease := true;
            SendMessage(Handle,WM_LBUTTONUP,0,0);
            Exit;
          end;

          ir := FPlanner.Items.Selected.GetGridRect;
          FPlanner.Items.BeginUpdate;
          SizeItem(ItemBegin, FItemXY.X + dx);
          FPlanner.Items.ResetUpdate;
          FPlanner.FGrid.InvalidateCellRect(ir);
          FPlanner.Items.Selected.Repaint;

          { Check here if scroll required }
          if (ItemEnd - LeftCol >= VisibleColCount) and (LeftCol +
            VisibleColCount < ColCount) then
          begin
            LeftCol := LeftCol + 1;
            if FPlanner.ScrollSmooth then
              FScrolling := True;

            FMouseXY.X := FMouseXY.X - DefaultColWidth;
          end;
          
          HintShowXY(X, Y, FPlanner.Items.Selected.ItemEndTimeStr);
        end;
      end;
      Exit;
    end;
  end;

  inherited;

  if FMouseDown then
    SelChanged;

  if Assigned(FPlanner.FOnPlannerMouseMove) then
  begin
    FPlanner.FOnPlannerMouseMove(FPlanner, Shift, X, Y);
  end;

  if FMouseDown then
    CorrectSelection;

  if (FLastHintPos.X <> -1) then
    if (GridCoord.X <> FLastHintPos.X) or (GridCoord.Y <> FLastHintPos.Y) then
    begin
      Application.CancelHint;
      FLastHintPos := Point(-1, -1);
      FLastHintItem := nil;
    end;

  if (GridCoord.X <> FToolTipPos.X) or (GridCoord.Y <> FToolTipPos.Y) then
  begin
    SendMessage(FHToolTip, TTM_POP, 0, 0);
  end;

  FToolTipPos.X := GridCoord.X;
  FToolTipPos.Y := GridCoord.Y;

  cr := CellRectEx(GridCoord.X, GridCoord.Y);

  if FPlanner.Sidebar.Orientation = soVertical then
  begin
    APlannerItem := FPlanner.Items.FindItemPos(GridCoord.Y, GridCoord.X - ColOffset, X - cr.Left);

    if Assigned(APlannerItem) and (APlannerItem <> FLastHintItem) and (FLastHintPos.X <> -1) then
    begin
      FLastHintItem := nil;
      FLastHintPos := Point(-1,-1);
      Application.CancelHint;
    end;


    if Assigned(APlannerItem) and (APlannerItem = FPlanner.Items.Selected) then
    begin
      APlannerItem.CalcConflictRect(cr, ColWidthEx(APlannerItem.ItemPos), RowHeightEx(1),
        FPlanner.Sidebar.Orientation = soVertical);

      ImgSize := 0;

      if APlannerItem.Focus then
      begin
        s := ConcatenateTextStrings(APlannerItem.Text);

        r := cr;
        r.Left := r.Left + FPlanner.TrackWidth;
        r.Top := r.Top - ((GridCoord.Y - APlannerItem.ItemBegin) * DefaultRowHeight) + 4;
        r.Bottom := r.Bottom + ((APlannerItem.ItemEnd - GridCoord.Y - 1) * DefaultRowHeight)
          + 4;

        if Assigned(FPlanner.PlannerImages) and
           ((APlannerItem.ImageID >= 0) or (APlannerItem.FImageIndexList.Count > 0)) then
          begin
            ImgSize := FPlanner.PlannerImages.Width;
            if (APlannerItem.ImagePosition = ipHorizontal) and (APlannerItem.FImageIndexList.Count > 0) then
              ImgSize := 8 + (ImgSize * APlannerItem.FImageIndexList.Count - 1);
          end;

        if (APlannerItem.CaptionType <> ctNone) then
        begin
          tr := r;
          tr.Bottom := tr.Top + 16;
          tr.Right := tr.Right - FPlanner.ItemGap;

          if APlannerItem.ShowDeleteButton then
          begin
            tr.Left := tr.Right - FPlanner.DeleteGlyph.Width;

            if PtInRect(tr,Point(X,Y)) then
            begin
              if Self.Cursor <> crHandPoint then
              begin
                Self.Cursor := crHandPoint;
              end;
              Exit;
            end;
            tr.Right := tr.Right - FPlanner.DeleteGlyph.Width;
          end;

          if APlannerItem.Attachement <> '' then
          begin
            tr.Left := tr.Right - FPlanner.AttachementGlyph.Width;

            if PtInRect(tr,Point(X,Y)) then
            begin
              if Self.Cursor <> crHandPoint then
              begin
                Self.Cursor := crHandPoint;
              end;
              Exit;
            end;

            tr.Right := tr.Right - FPlanner.AttachementGlyph.Width;
          end;

          if APlannerItem.URL <> '' then
          begin
            tr.Left := tr.Right - FPlanner.URLGlyph.Width;

            if PtInRect(tr,Point(X,Y)) then
            begin
              if Self.Cursor <> crHandPoint then
              begin
                Self.Cursor := crHandPoint;
              end;
              Exit;
            end;
          end;

          if APlannerItem.CaptionType in [ctText,ctTimeText] then
          begin
            if IsHtml(APlannerItem,APlannerItem.CaptionText,true) then
            begin
             Canvas.Font := APlannerItem.CaptionFont;

             if HTMLDrawEx(Canvas, APlannerItem.CaptionText, r, FPlanner.PlannerImages, X, Y,
               -1, -1, 1, True, False, False, True, True, False, APlannerItem.WordWrap
               , False
               , 1.0, FPlanner.URLColor,
               clNone, clNone, clGray, Anchor, StrippedHtmlString, FocusAnchor, XSize, YSize, ml, hl, hr
               ,cor, CID, CV, CT, FPlanner.FImageCache, FPlanner.FContainer, Handle
               ) then

             begin
               if Self.Cursor <> crHandPoint then
               begin
                 Self.Cursor := crHandPoint;
                 if Assigned(FPlanner.OnItemAnchorEnter) then
                   FPlanner.OnItemAnchorEnter(FPlanner, APlannerItem, Anchor);
               end;
               Exit;
             end
             else if Self.Cursor = crHandPoint then
             begin
               if Assigned(FPlanner.OnItemAnchorExit) then
                 FPlanner.OnItemAnchorExit(FPlanner, APlannerItem, Anchor);
             end;

            end;
          end;
          r.Top := r.Top + APlannerItem.FCaptionHeight;
        end
        else
        begin
          if (APlannerItem.ImageID >= 0) and Assigned(FPlanner.PlannerImages) then
            r.Left := r.Left + ImgSize;
        end;

        if IsHtml(APlannerItem,s,false) then
        begin
          Canvas.Font := APlannerItem.Font;

          if APlannerItem.Shadow and not APlannerItem.Background and (APlannerItem.Shape = psRect)
            and not FPlanner.TrackOnly  then
          begin
            r.Right := r.Right - 5;
            r.Bottom := r.Bottom - 2;
          end
          else
          begin
            r.Right := r.Right - 2;
          end;
          
          r.Left := r.Left + 2;

          APlannerItem.CompletionAdapt(r);
          APlannerItem.ImageListAdapt(r);          

          if HTMLDrawEx(Canvas, s, r, FPlanner.PlannerImages, X, Y,
            -1, -1, 1, True, False, False, True, False, False, APlannerItem.WordWrap
            , False
            , 1.0, FPlanner.URLColor,
            clNone, clNone, clGray, Anchor, StrippedHtmlString, FocusAnchor, XSize, YSize, ml, hl, hr
            , cor, CID, CV, CT, FPlanner.FImageCache, FPlanner.FContainer, Handle
            ) then

          begin
            if (Self.Cursor <> crHandPoint)
             or (CID <> FCurrCtrlID)
            then
            begin
              Self.Cursor := crHandPoint;

              if (cor.Right <> 0) and IsWinXP then
              begin
                if FCurrCtrlR.Right <> 0 then
                  {$IFNDEF TMSDOTNET}
                  InvalidateRect(Handle,@FCurrCtrlR,false);
                  {$ENDIF}
                  {$IFDEF TMSDOTNET}
                  InvalidateRect(Handle,FCurrCtrlR,false);
                  {$ENDIF}


                {$IFDEF TMSDEBUG}
                outputdebugstring('control hot');
                {$ENDIF}
                FCurrCtrlID := CID;
                FCurrCtrlR := cor;

                {$IFNDEF TMSDOTNET}
                InvalidateRect(Handle,@cor,false);
                {$ENDIF}

                {$IFDEF TMSDOTNET}
                InvalidateRect(Handle,cor,false);
                {$ENDIF}
              end;

              if Assigned(FPlanner.OnItemAnchorEnter) then
                FPlanner.OnItemAnchorEnter(FPlanner, APlannerItem, Anchor);
            end;
            Exit;
          end
          else
          if (Self.Cursor = crHandPoint)
             or (CID <> FCurrCtrlID)
            then
          begin
            if (FCurrCtrlR.Right <> 0) and IsWinXP then
            begin
              {$IFDEF TMSDEBUG}
              outputdebugstring(pchar('control cold:'+inttostr(fcurrctrlr.Right)));
              {$ENDIF}

              {$IFNDEF TMSDOTNET}
              InvalidateRect(Handle,@FCurrCtrlR,false);
              {$ENDIF}

              {$IFDEF TMSDOTNET}
              InvalidateRect(Handle,FCurrCtrlR,false);
              {$ENDIF}

              if CID = '' then
                FCurrCtrlR := Rect(0,0,0,0)
              else
                FCurrCtrlR := cor;

              FCurrCtrlID := CID;
            end;
            if Assigned(FPlanner.OnItemAnchorExit) then
              FPlanner.OnItemAnchorExit(FPlanner, APlannerItem, Anchor);
          end;
        end;
      end;

      if APlannerItem.Focus and (APlannerItem.ItemBegin = GridCoord.Y) and
        (Y < cr.Top + 3) and not APlannerItem.FixedSize and (FPlanner.UserMode in [puNormal, puReadOnly]) then
      begin
        if APlannerItem.cursor = crNone then
           self.Cursor := crSizeNS
        else
           self.Cursor := APlannerItem.Cursor;

        FSelItem := APlannerItem;
        Exit;
      end;

      if APlannerItem.Focus and (APlannerItem.ItemEnd - 1 = GridCoord.Y) and
        (Y > cr.Bottom - 5) and not APlannerItem.FixedSize and (FPlanner.UserMode in [puNormal, puReadOnly]) then
      begin
        if APlannerItem.cursor = crNone then
           self.Cursor := crSizeNS
        else
           self.Cursor := APlannerItem.Cursor;

        FSelItem := APlannerItem;
        Exit;
      end;

      if (((X > cr.Left) and (X < cr.Left + FPlanner.TrackWidth)) or
        ((Y > cr.Top + 3) and (Y < cr.Top +
        APlannerItem.GetCaptionHeight) and (APlannerItem.ItemBegin = GridCoord.Y) and
        (X > cr.Left + ImgSize))) and
        not APlannerItem.FixedPos and (FPlanner.UserMode in [puNormal, puReadOnly]) then
      begin
{$IFNDEF DELPHI4_LVL}
        Self.Cursor := crCross;
{$ENDIF}
{$IFDEF DELPHI4_LVL}
        if APlannerItem.Cursor = crNone then
           Self.Cursor := crSizeAll
        else
           self.cursor := APlannerItem.Cursor;
{$ENDIF}
        FSelItem := APlannerItem;
        Exit;
      end;


      if APlannerItem.Focus and
         APlannerItem.NotEditable and
         FPlanner.DirectMove and
         not APlannerItem.BackGround and not APlannerItem.FixedPos and (FPlanner.UserMode in [puNormal, puReadOnly]) then
      begin
{$IFNDEF DELPHI4_LVL}
        Self.Cursor := crCross;
{$ENDIF}
{$IFDEF DELPHI4_LVL}
        if APlannerItem.Cursor = crNone then
           self.Cursor := crSizeAll
        else
           self.Cursor := APlannerItem.Cursor;
{$ENDIF}
        FSelItem := APlannerItem;
        Exit;
      end;
    end
    else
      if Assigned(APlannerItem) then
        if (APlannerItem.Cursor <> crNone) and FPlanner.DirectMove then
        begin
          Self.Cursor := APlannerItem.Cursor;
          Exit;
        end;
  end
  else
  begin
    APlannerItem := FPlanner.Items.FindItemPos(GridCoord.X - ColOffset, GridCoord.Y - RowOffset, Y - cr.Top);

    if Assigned(APlannerItem) and (APlannerItem = FPlanner.Items.Selected) then
    begin
      APlannerItem.CalcConflictRect(cr, ColWidthEx(APlannerItem.ItemPos), RowHeightEx(APlannerItem.ItemPos),
        FPlanner.Sidebar.Orientation = soVertical);

      ImgSize := 0;

      if APlannerItem.Focus then
      begin
        s := ConcatenateTextStrings(APlannerItem.Text);

        r := cr;

        r.Top := r.Top + FPlanner.TrackWidth;
        r.Left := r.Left - ((GridCoord.X - APlannerItem.ItemBegin) * DefaultColWidth) + 4;
        r.Right := r.Right + ((APlannerItem.ItemEnd - GridCoord.X - 1) * DefaultColWidth) +
          4;

        if Assigned(FPlanner.PlannerImages) and
           ((APlannerItem.ImageID >= 0) or (APlannerItem.FImageIndexList.Count > 0)) then
          begin
            ImgSize := FPlanner.PlannerImages.Width;
            if (APlannerItem.ImagePosition = ipHorizontal) and (APlannerItem.FImageIndexList.Count > 0) then
              ImgSize := 8 + (ImgSize * APlannerItem.FImageIndexList.Count - 1);
          end;

        if (APlannerItem.CaptionType <> ctNone) then
        begin
          tr := r;
          tr.Right := tr.Right - 4 - FPlanner.TrackWidth;

          tr.Bottom := tr.Top + 16;

          if APlannerItem.ShowDeleteButton then
          begin
            tr.Left := tr.Right - FPlanner.DeleteGlyph.Width;

            if PtInRect(tr,Point(X,Y)) then
            begin
              if Self.Cursor <> crHandPoint then
              begin
                Self.Cursor := crHandPoint;
              end;
              Exit;
            end;
            tr.Right := tr.Right - FPlanner.DeleteGlyph.Width;
          end;


          if APlannerItem.Attachement <> '' then
          begin
            tr.Left := tr.Right - FPlanner.AttachementGlyph.Width;

            if PtInRect(tr,Point(X,Y)) then
            begin
              if Self.Cursor <> crHandPoint then
              begin
                Self.Cursor := crHandPoint;
              end;
              Exit;
            end;

            tr.Right := tr.Right - FPlanner.AttachementGlyph.Width;
          end;

          if APlannerItem.URL <> '' then
          begin
            tr.Left := tr.Right - FPlanner.URLGlyph.Width;

            if PtInRect(tr,Point(X,Y)) then
            begin
              if Self.Cursor <> crHandPoint then
              begin
                Self.Cursor := crHandPoint;
              end;
              Exit;
            end;
          end;

          if (APlannerItem.CaptionType in [ctText,ctTimeText]) then
          begin
            if IsHtml(APlannerItem,APlannerItem.CaptionText,true) then
            begin
             Canvas.Font := APlannerItem.CaptionFont;

             if HTMLDrawEx(Canvas, APlannerItem.CaptionText, r, FPlanner.PlannerImages, X, Y,
               -1, -1, 1, True, False, False, True, True, False, APlannerItem.WordWrap
               , False
               , 1.0, FPlanner.URLColor,
               clNone, clNone, clGray, Anchor, StrippedHtmlString, FocusAnchor, XSize, YSize, ml, hl, hr
               , cor, CID, CV, CT, FPlanner.FImageCache, FPlanner.FContainer, Handle
               ) then

             begin
               if (Self.Cursor <> crHandPoint) then
               begin
                 Self.Cursor := crHandPoint;
                 if Assigned(FPlanner.OnItemAnchorEnter) then
                   FPlanner.OnItemAnchorEnter(FPlanner, APlannerItem, Anchor);
               end;
               Exit;
             end
             else if (Self.Cursor = crHandPoint) then
             begin
               if Assigned(FPlanner.OnItemAnchorExit) then
                 FPlanner.OnItemAnchorExit(FPlanner, APlannerItem, Anchor);
             end;

            end;
          end;
          r.Top := r.Top + APlannerItem.FCaptionHeight;
        end;

        if IsHtml(APlannerItem,s,false) then
        begin
          Canvas.Font := APlannerItem.Font;
          
          if APlannerItem.Shadow and not APlannerItem.Background and (APlannerItem.Shape = psRect)
            and not FPlanner.TrackOnly  then
          begin
            r.Right := r.Right - 5;
            r.Bottom := r.Bottom - 2;
          end
          else
          begin
            r.Right := r.Right - 2;
          end;

          r.Left := r.Left + 2;

          APlannerItem.CompletionAdapt(r);
          APlannerItem.ImageListAdapt(r);          

          if HTMLDrawEx(Canvas, s, r, FPlanner.PlannerImages, X, Y,
            -1, -1, 1, True, False, False, True, True, False, APlannerItem.WordWrap
            , False
            , 1.0, FPlanner.URLColor,
            clNone, clNone, clGray, Anchor, StrippedHtmlString, FocusAnchor, XSize, YSize, ml, hl, hr
            , cor, CID, CV, CT, FPlanner.FImageCache, FPlanner.FContainer, Handle
            ) then

          begin
            if (Self.Cursor <> crHandPoint)
              or (CID <> FCurrCtrlID)
            then

            begin
              Self.Cursor := crHandPoint;

              if (cor.Right <> 0) and IsWinXP then
              begin
                if FCurrCtrlR.Right <> 0 then
                  {$IFNDEF TMSDOTNET}
                  InvalidateRect(Handle,@FCurrCtrlR,False);
                  {$ENDIF}

                  {$IFDEF TMSDOTNET}
                  InvalidateRect(Handle,FCurrCtrlR,False);
                  {$ENDIF}

                InflateRect(cor,0,2);
                FCurrCtrlID := CID;
                FCurrCtrlR := cor;

                {$IFNDEF TMSDOTNET}
                InvalidateRect(Handle,@cor,False);
                {$ENDIF}
                {$IFDEF TMSDOTNET}
                InvalidateRect(Handle,cor,False);
                {$ENDIF}
              end;

              if Assigned(FPlanner.OnItemAnchorEnter) then
                FPlanner.OnItemAnchorEnter(FPlanner, APlannerItem, Anchor);
            end;
            Exit;
          end
          else
          if (Self.Cursor = crHandPoint)
             or (CID <> FCurrCtrlID)
          then
          begin
            if (FCurrCtrlR.Right <> 0) and IsWinXP then
            begin
              InflateRect(FCurrCtrlR,0,2);

              {$IFNDEF TMSDOTNET}
              InvalidateRect(Handle,@FCurrCtrlR,False);
              {$ENDIF}

              {$IFDEF TMSDOTNET}
              InvalidateRect(Handle,FCurrCtrlR,False);
              {$ENDIF}

              if CID = '' then
                FCurrCtrlR := Rect(0,0,0,0)
              else
                FCurrCtrlR := cor;

              FCurrCtrlID := CID;
            end;

            if Assigned(FPlanner.OnItemAnchorExit) then
              FPlanner.OnItemAnchorExit(FPlanner, APlannerItem, Anchor);
          end;
        end;
      end;

      if APlannerItem.Focus and (APlannerItem.ItemBegin = GridCoord.X) and
        (X < cr.Left + 3) and not APlannerItem.FixedSize and (FPlanner.UserMode in [puNormal, puReadOnly]) then
      begin
        if APlannerItem.cursor = crNone then
           Self.Cursor := crSizeWE
        else
           self.Cursor := APlannerItem.Cursor;

        FSelItem := APlannerItem;
        Exit;
      end;

      if APlannerItem.Focus and (APlannerItem.ItemEnd - 1 = GridCoord.X) and
        (X > cr.Right - 5) and not APlannerItem.FixedSize and (FPlanner.UserMode in [puNormal, puReadOnly]) then
      begin
        if APlannerItem.Cursor = crNone then
           Self.Cursor := crSizeWE
        else
           self.Cursor := APlannerItem.Cursor;

        FSelItem := APlannerItem;
        Exit;
      end;

      if (((Y > cr.Top) and (Y < cr.Top + FPlanner.TrackWidth)) or
        ((Y > cr.Top + FPlanner.TrackWidth) and (Y < cr.Top + FPlanner.TrackWidth + APlannerItem.GetCaptionHeight) and
        (APlannerItem.ItemPos = GridCoord.Y - RowOffset) and
        (X > r.Left + ImgSize))) and
        not APlannerItem.FixedPos and (FPlanner.UserMode in [puNormal, puReadOnly]) then
      begin
{$IFNDEF DELPHI4_LVL}
        Self.Cursor := crCross;
{$ENDIF}
{$IFDEF DELPHI4_LVL}
        if APlannerItem.Cursor = crNone then
           Self.Cursor := crSizeAll
        else
           self.Cursor := APlannerItem.Cursor;
{$ENDIF}
        FSelItem := APlannerItem;
        Exit;
      end;


      if APlannerItem.Focus and
         APlannerItem.NotEditable and
         FPlanner.DirectMove and
         not APlannerItem.Background and not APlannerItem.FixedPos and (FPlanner.UserMode in [puNormal, puReadOnly]) then
      begin
{$IFNDEF DELPHI4_LVL}
        Self.Cursor := crCross;
{$ENDIF}
{$IFDEF DELPHI4_LVL}
        if APlannerItem.Cursor = crNone then
           Self.Cursor := crSizeAll
        else
           self.Cursor := APlannerItem.Cursor;
{$ENDIF}
        FSelItem := APlannerItem;
        Exit;
      end;
    end
    else
      if Assigned(APlannerItem) then
        if (APlannerItem.Cursor <> crNone) and FPlanner.DirectMove then
        begin
          Self.Cursor := APlannerItem.Cursor;
          Exit;
        end;
  end;

  if not FMouseDown then
    FSelItem := nil;

  if (Self.Cursor <> FPlanner.Cursor) then
  begin
    if (FCurrCtrlR.Right <> 0) and IsWinXP then
    begin
      {$IFNDEF TMSDOTNET}
      InvalidateRect(Handle,@FCurrCtrlR,False);
      {$ENDIF}

      {$IFDEF TMSDOTNET}
      InvalidateRect(Handle,FCurrCtrlR,False);
      {$ENDIF}

      FCurrCtrlR := Rect(0,0,0,0);
    end;
    Self.Cursor := FPlanner.Cursor;
  end;
end;


{$IFNDEF TMSDOTNET}
procedure TPlannerGrid.WMSetCursor(var Msg: TWMSetCursor);
var
  p: TPoint;
  nc: Integer;
begin
  if (csDesigning in ComponentState) and FPlanner.ShowDesignHelper then
  begin
    GetCursorPos(P);
    P := ScreenToClient(P);
    nc := MouseOverDesignChoice(P.X, P.Y);
    if nc in [1, 2, 3] then
      Windows.SetCursor(Screen.Cursors[crHandPoint])
    else
      Windows.SetCursor(Screen.Cursors[crDefault])
  end
  else
    inherited;
end;
{$ENDIF}

procedure TPlannerGrid.CMDesignHitTest(var Msg: TCMDesignHitTest);
var
  r: TRect;
  p: TPoint;
  nc: Integer;
begin
  inherited;

  if (csDesigning in ComponentState) and FPlanner.ShowDesignHelper then
  begin
    GetCursorPos(P);
    P := ScreenToClient(P);

    nc := MouseOverDesignChoice(P.X, P.Y);

    if nc <> FLastDesignChoice then
    begin
      r := ClientRect;
      r := Rect(r.Right - 150, r.Bottom - 70, r.Right, r.Bottom);
      {$IFNDEF TMSDOTNET}
      InvalidateRect(Handle, @r, true);
      {$ENDIF}
      {$IFDEF TMSDOTNET}
      InvalidateRect(Handle, r, true);
      {$ENDIF}
    end;

    FLastDesignChoice := nc;

    if nc in [1, 2, 3] then
    begin
      Msg.Result := 1;
    end;
  end;
end;


{$IFDEF TMSDOTNET}
procedure TPlannerGrid.CMHintShow(var Message: TCMHintShow);
{$ENDIF}
{$IFNDEF TMSDOTNET}
procedure TPlannerGrid.CMHintShow(var Message: TMessage);
type
  PHintInfo = ^THintInfo;
{$ENDIF}
var
  CanShow: Boolean;
  {$IFNDEF TMSDOTNET}
  Hi: PHintInfo;
  {$ENDIF}
  {$IFDEF TMSDOTNET}
  Hi: THintInfo;
  {$ENDIF}
  cr, hr, cor: TRect;
  APlannerItem: TPlannerItem;
  GridCoord: TGridCoord;
  s, CID, CV, CT: string;
  Anchor, StrippedHtmlString, FocusAnchor: string;
  XSize, YSize, ml, hl: Integer;
  sideb: boolean;
begin
  if FMouseDownMove or FMouseDownSizeUp or FMouseDownSizeDown then
    Exit;

  if not FPlanner.ShowHint then
    Exit;

  if FPlanner.EditMode then
    Exit;

  {$IFNDEF TMSDOTNET}
  Hi := PHintInfo(Message.LParam);
  {$ENDIF}
  {$IFDEF TMSDOTNET}
  Hi := Message.HintInfo;
  {$ENDIF}

  GridCoord := MouseCoord(Hi.CursorPos.X, Hi.CursorPos.Y);
  cr := CellRectEx(GridCoord.X, GridCoord.Y);

  FLastHintPos := Point(GridCoord.X, GridCoord.Y);

  if FPlanner.Sidebar.Orientation = soVertical then
    APlannerItem := FPlanner.Items.FindItemPos(GridCoord.Y, GridCoord.X - 1, Hi.CursorPos.X - cr.Left)
  else
    APlannerItem := FPlanner.Items.FindItemPos(GridCoord.X, GridCoord.Y - 1, Hi.CursorPos.Y - cr.Top);

  if not Assigned(APlannerItem) then
  begin
    if FPlanner.Sidebar.Orientation = soVertical then
      APlannerItem := FPlanner.Items.FindBkgPos(GridCoord.Y, GridCoord.X - 1, Hi.CursorPos.X - cr.Left)
    else
      APlannerItem := FPlanner.Items.FindBkgPos(GridCoord.X, GridCoord.Y - 1, Hi.CursorPos.Y - cr.Top);
  end;


  sideb := false;
  FLastHintItem := APlannerItem;

  if Assigned(APlannerItem) then
  begin
    s := APlannerItem.ItemText;

    if IsRtf(s) then
    begin
      if not FPlanner.RichEdit.Visible then
      begin
        FPlanner.TextToRich(s);
        s := FPlanner.FRichEdit.Text;
      end;
    end;

    if APlannerItem.Hint <> '' then
      s := APlannerItem.Hint;

    if IsHtml(APlannerItem,s,false) then
    begin
      {Change ? if HTML Hint is enabled ?}
      if APlannerItem.Hint = '' then
        s := ConcatenateTextStrings(APlannerItem.Text);
      cr := ClientRect;
      if not FPlanner.HTMLHint then
      begin
        HTMLDrawEx(Canvas, s, cr, FPlanner.PlannerImages, 0, 0, -1, -1, 1,
          True, True, False, True, True, False, APlannerItem.WordWrap
          , False
          , 1.0, FPlanner.URLColor,
          clNone, clNone, clGray, Anchor, StrippedHtmlString, FocusAnchor,
          XSize, YSize, ml, hl, hr
          , cor, CID, CV, CT, FPlanner.FImageCache, FPlanner.FContainer, Handle
          );

        s := StrippedHtmlString;
      end;
    end;

    {$IFDEF TMSCODESITE}
    CodeSite.SendMsg(s+'*');
    {$ENDIF}

    Hi.HintStr := s;
    if Assigned(FPlanner.OnItemHint) then
      FPlanner.OnItemHint(FPlanner, APlannerItem, Hi.HintStr);
  end
  else
  begin
    if FPlanner.Sidebar.Orientation = soVertical then
    begin
      if GridCoord.X = 0 then
      begin
        if Assigned(FPlanner.OnSideBarHint) then
          FPlanner.OnSideBarHint(self, GridCoord.Y, Hi.HintStr);
        sideb := Hi.HintStr <> '';          
      end;
    end
    else
    begin
      if GridCoord.Y = 0 then
      begin
        if Assigned(FPlanner.OnSideBarHint) then
          FPlanner.OnSideBarHint(self, GridCoord.X, Hi.HintStr);
        sideb := Hi.HintStr <> '';
      end;

    end;
  end;

  if FPlanner.HintColor <> clNone then
    Hi.HintColor := FPlanner.HintColor;

  Hi.HideTimeout := FPlanner.HintPause;

  CanShow := Assigned(APlannerItem) or sideb;

  Message.Result := Ord(not CanShow);
end;

procedure TPlannerGrid.WMLButtonDown(var Message: TWMLButtonDown);
begin
  if (csDesigning in ComponentState) then
  begin
    if FLastDesignChoice <> -1 then
      inherited
    else
      message.Result := 1
  end    
  else
    inherited;
end;

procedure TPlannerGrid.WMLButtonDblClk(var Message: TWMLButtonDblClk);
var
  FromSel, FromSelPrecis: Integer;
  ToSel, ToSelPrecis: Integer;
  GridCoord: TGridCoord;
  APlannerItem: TPlannerItem;
  GridRect: TRect;
  ColOffset, RowOffset: Integer;
begin
  if (csDesigning in ComponentState) then
  begin
    Message.Result := 1;
    Exit;
  end;

  ColOffset := FPlanner.FSidebar.FColOffset;
  RowOffset := FPlanner.FSidebar.FRowOffset;

  GridCoord := MouseCoord(Message.XPos, Message.YPos);
  GridRect := CellRectEx(GridCoord.X, GridCoord.Y);

  if FPlanner.Sidebar.Orientation = soVertical then
    APlannerItem := FPlanner.Items.FindItemPos(GridCoord.Y - RowOffset, GridCoord.X - ColOffset, Message.xpos
      - GridRect.Left)
  else
    APlannerItem := FPlanner.Items.FindItemPos(GridCoord.X - ColOffset, GridCoord.Y - RowOffset, Message.ypos
      - GridRect.Top);

  if (Assigned(APlannerItem)) then
  begin
    if Assigned(APlannerItem.Editor) then
      if APlannerItem.Editor.EditorUse = euDblClick then
        APlannerItem.FPopupEdit := True;
  end;

  inherited;


  if (Assigned(APlannerItem)) then
  begin
    HintHide;
    FMouseDown := False;
    FMouseDownMove := False;
    FMouseDownSizeUp := False;
    FMouseDownSizeDown := False;

    if Assigned(APlannerItem.Editor) then
      if APlannerItem.Editor.EditorUse = euDblClick then
      begin
        APlannerItem.PopupEdit;
        APlannerItem.FPopupEdit := False;
      end;

    if Assigned(FPlanner.OnItemDblClick) then
      FPlanner.OnItemDblClick(FPlanner, APlannerItem);
      
  end
  else
  begin
    if (Message.xpos < GridRect.Right - 10) or (1 > 0) then
    begin
      if Assigned(FPlanner.FOnPlannerDblClick) then
      begin
        if FPlanner.Sidebar.Position = spTop then
        begin
          FromSel := Selection.Left + FPlanner.Display.DisplayStart;
          ToSel := 1 + Selection.Right + FPlanner.Display.DisplayStart;
          FromSelPrecis := FromSel * FPlanner.Display.DisplayUnit + FPlanner.Display.DisplayOffset;
          ToSelPrecis := ToSel * FPlanner.Display.DisplayUnit + FPlanner.Display.DisplayOffset;
          FPlanner.FOnPlannerDblClick(FPlanner, Row - 1, FromSel, FromSelPrecis, ToSel, ToSelPrecis)
        end
        else
        begin
          FromSel := Selection.Top + FPlanner.Display.DisplayStart;
          ToSel := 1 + Selection.Bottom + FPlanner.Display.DisplayStart;
          FromSelPrecis := FromSel * FPlanner.Display.DisplayUnit + FPlanner.Display.DisplayOffset;
          ToSelPrecis := ToSel * FPlanner.Display.DisplayUnit + FPlanner.Display.DisplayOffset;
          if (FPlanner.Sidebar.Position = spRight) then
            FPlanner.FOnPlannerDblClick(FPlanner, Col, FromSel, FromSelPrecis, ToSel, ToSelPrecis)
          else
            FPlanner.FOnPlannerDblClick(FPlanner, Col - 1, FromSel, FromSelPrecis, ToSel, ToSelPrecis);
        end;
      end;
    end;
  end;


end;

procedure TPlannerGrid.WMEraseBkGnd(var Message: TWMEraseBkgnd);
begin
  if FEraseBkGnd then
    inherited
  else
    Message.Result := 0 // Avoid erase backgnd to reduce flicker !
end;


procedure TPlannerGrid.CNKeyDown(var Message: TWMKeydown);
var
  APlannerItem: TPlannerItem;
begin
  APlannerItem := nil;

  if (GetKeyState(VK_CONTROL) and $8000 = $8000) then
  begin
    inherited;
    Exit;
  end;

  if (Message.CharCode = VK_TAB) then
  begin
    if (GetKeyState(VK_SHIFT) and $8000 > 0) then
      APlannerItem := FPlanner.Items.SelectPrev
    else
      APlannerItem := FPlanner.Items.SelectNext;
  end;

  inherited;

  if Assigned(APlannerItem) then
  begin
    SetFocus;
    FPlanner.ItemSelected(APlannerItem);
  end;
end;

procedure TPlannerGrid.KeyDown(var Key: Word; ShiftState: TShiftState);
var
  APlannerItem,plIt: TPlannerItem;
  GridRect: TRect;
  FromSel, FromSelPrecis: Integer;
  ToSel, ToSelPrecis: Integer;
  CharCode: Word;
  Allow: Boolean;

begin
  if Assigned(FPlanner.OnPlannerBeforeKeyDown) then
    FPlanner.OnPlannerBeforeKeyDown(FPlanner, Key, ShiftState);

  APlannerItem := FPlanner.Items.Selected;

  CharCode := Key;

  if not FPlanner.EnableKeyboard then
    if (Key in [VK_UP, VK_LEFT, VK_RIGHT, VK_DOWN]) and (Assigned(FPlanner.Items.Selected)) then
      Exit;

  if FPlanner.Sidebar.Orientation = soHorizontal then
  begin // Map keyboard movement from Horizontal to Vertical
    case CharCode of
      VK_RIGHT: CharCode := VK_DOWN;
      VK_LEFT: CharCode := VK_UP;
      VK_UP: CharCode := VK_LEFT;
      VK_DOWN: CharCode := VK_RIGHT;
    end;
  end;

  case CharCode of
    VK_RETURN, VK_SPACE, VK_F2:
      begin
        if Assigned(APlannerItem) then
        begin
          if not APlannerItem.NotEditable then
          begin
            if FPlanner.Sidebar.Orientation = soVertical then
            begin
              GridRect := CellRectEx(APlannerItem.ItemPos + 1, APlannerItem.ItemBegin);
              StartEditCol(GridRect, APlannerItem, -1, -1);
            end
            else
            begin
              GridRect := CellRectEx(APlannerItem.ItemBegin, APlannerItem.ItemPos +
                FPlanner.FSidebar.FRowOffset);
              StartEditRow(GridRect, APlannerItem, -1, -1);
            end;
          end;
        end;
      end;
    VK_INSERT:
      begin
        if FPlanner.AutoInsDel then
        begin
          plIt := FPlanner.CreateItemAtSelection;
          if Assigned(FPlanner.FOnItemCreated) then
            FPlanner.FOnItemCreated(FPlanner, plIt);

          if FPlanner.ItemSelection.AutoSelectOnAutoInsert or FPlanner.ItemSelection.AutoEditOnAutoInsert then
            FPlanner.Items.Select(plIt);
          if FPlanner.ItemSelection.AutoEditOnAutoInsert then
            plIt.Edit;
        end;

        if Assigned(FPlanner.FOnItemInsert) then
        begin
          if FPlanner.Sidebar.Orientation = soHorizontal then
          begin
            FromSel := Selection.Left;
            ToSel := 1 + Selection.Right;
            FromSelPrecis := FromSel * FPlanner.Display.DisplayUnit + FPlanner.Display.DisplayOffset;
            ToSelPrecis := ToSel * FPlanner.Display.DisplayUnit + FPlanner.Display.DisplayOffset;

            if FPlanner.InsertAlways or not FPlanner.Items.HasItem(FromSel,ToSel,Row - 1) then
              FPlanner.FOnItemInsert(FPlanner, Row - 1, FromSel, FromSelPrecis,
                ToSel, ToSelPrecis);
          end
          else
          begin
            FromSel := Selection.Top;
            ToSel := 1 + Selection.Bottom;
            FromSelPrecis := FromSel * FPlanner.Display.DisplayUnit + FPlanner.Display.DisplayOffset;
            ToSelPrecis := ToSel * FPlanner.Display.DisplayUnit + FPlanner.Display.DisplayOffset;

            if FPlanner.InsertAlways or not FPlanner.Items.HasItem(FromSel,ToSel,Col - 1) then
              FPlanner.FOnItemInsert(FPlanner, Col - 1, FromSel, FromSelPrecis,
                ToSel, ToSelPrecis);
          end;
        end;
      end;

    VK_DELETE:
      begin
        if not (ssShift in ShiftState) then
        begin
          if Assigned(APlannerItem) then
          begin
            if Assigned(FPlanner.OnItemDelete) then
              FPlanner.OnItemDelete(FPlanner, APlannerItem);

            if FPlanner.AutoInsDel then
            begin
              if Assigned(FPlanner.OnItemDeleted) then
                FPlanner.OnItemDeleted(FPlanner, APlannerItem);
              FPlanner.FreeItem(APlannerItem);
            end
            else
          end;
        end;
      end;

    VK_RIGHT:
      begin
        if Assigned(FPlanner.Items.Selected) then
          with FPlanner.Items.Selected do
          begin
            if (ItemPos < FPlanner.Positions - 1) and
              not FPlanner.Items.HasItem(ItemBegin, ItemEnd, ItemPos + 1) and
              not FixedPos and not FixedPosition and (FPlanner.UserMode in [puNormal, puReadOnly]) then
            begin
              Allow := True;

              if Assigned(FPlanner.FOnItemMoving) then
              begin
                FPlanner.FOnItemMoving(FPlanner,FPlanner.Items.Selected,0,+1,Allow);
              end;

              if Allow then
              begin
                ItemPos := ItemPos + 1;
                FPlanner.Items.SetConflicts;

                with FPlanner.Items do
                begin
                  FPlanner.ItemMoved(Selected, Selected.ItemBegin,
                        Selected.ItemEnd, Selected.ItemPos - 1,
                        Selected.ItemBegin, Selected.ItemEnd, Selected.ItemPos);
                  MoveLinks(Selected);     
                end;

                try
                  if (FPlanner.PositionWidth > 0) then
                    if FPlanner.Sidebar.Orientation = soHorizontal then
                    begin
                      if ItemPos >= VisibleRowCount + TopRow then
                        TopRow := TopRow + 1;
                    end
                    else
                    begin
                      if ItemPos >= VisibleColCount + LeftCol then
                        LeftCol := LeftCol + 1;
                    end;
                except
                end;
              end;
            end;
            Key := 0;
          end
      end;
    VK_LEFT:
      begin
        if Assigned(FPlanner.Items.Selected) then
          with FPlanner.Items.Selected do
          begin
            if (ItemPos > 0) and not FPlanner.Items.HasItem(ItemBegin, ItemEnd,
              ItemPos - 1) and not FixedPos and not FixedPosition and (FPlanner.UserMode in [puNormal, puReadOnly]) then
            begin
              Allow := True;

              if Assigned(FPlanner.FOnItemMoving) then
              begin
                FPlanner.FOnItemMoving(FPlanner,FPlanner.Items.Selected,0,-1,Allow);
              end;

              if Allow then
              begin
                ItemPos := ItemPos - 1;
                FPlanner.Items.SetConflicts;

                with FPlanner.Items do
                begin
                  FPlanner.ItemMoved(Selected, Selected.ItemBegin,
                      Selected.ItemEnd, Selected.ItemPos + 1,
                      Selected.ItemBegin, Selected.ItemEnd, Selected.ItemPos);
                  MoveLinks(Selected);
                end;      

                try
                  if (FPlanner.PositionWidth > 0) then
                    if FPlanner.Sidebar.Orientation = soHorizontal then
                    begin
                      if (ItemPos < TopRow - 1) and (TopRow > 1) then
                        TopRow := TopRow - 1;
                    end
                    else
                    begin
                      if (ItemPos < LeftCol - 1) and (LeftCol > 1) then
                        LeftCol := LeftCol - 1;
                    end;
                except
                end;
              end;
            end;
            Key := 0;
          end
        else if (Col = 1) and (FPlanner.Sidebar.Visible) and not (FPlanner.SideBar.Position = spRight) and
          (FPlanner.Sidebar.Orientation = soVertical) then
          Key := 0;
      end;
    VK_UP:
      begin
        if Assigned(FPlanner.Items.Selected) then
        begin
          with FPlanner.Items.Selected do
          begin
            if (GetKeyState(VK_SHIFT) and $8000 = 0) and not FixedPos and not FixedTime and (FPlanner.UserMode in [puNormal, puReadOnly]) then
            begin
              if not FPlanner.Items.HasItem(ItemBegin - 1, ItemEnd - 1,
                ItemPos) and (ItemBegin > 0) then
              begin
                Allow := True;

                if Assigned(FPlanner.FOnItemMoving) then
                begin
                  FPlanner.FOnItemMoving(FPlanner,FPlanner.Items.Selected,-1,0,Allow);
                end;

                if Allow then
                begin
                  ItemBegin := ItemBegin - 1;
                  ItemEnd := ItemEnd - 1;
                  RealTime := False;
                  FPlanner.Items.SetConflicts;

                  with FPlanner.Items do
                  begin
                    FPlanner.ItemMoved(Selected, Selected.ItemBegin
                        + 1, Selected.ItemEnd + 1, Selected.ItemPos,
                        Selected.ItemBegin, Selected.ItemEnd, Selected.ItemPos);
                    MoveLinks(Selected);    
                  end;      
                end;
              end;
            end
            else
            begin
              if (ItemEnd > ItemBegin + 1) and
                not FPlanner.Items.HasItem(ItemBegin, ItemEnd - 1, ItemPos)
                and not FixedSize and (FPlanner.UserMode in [puNormal, puReadOnly]) then
              begin
                Allow := True;

                if Assigned(FPlanner.FOnItemSizing) then
                begin
                  FPlanner.FOnItemSizing(FPlanner,FPlanner.Items.Selected,0,-1,Allow);
                end;

                if Allow then
                begin
                  ItemEnd := ItemEnd - 1;
                  RealTime := False;
                  FPlanner.Items.SetConflicts;

                  with FPlanner.Items do
                  begin
                    FPlanner.ItemSized(Selected, Selected.ItemBegin, Selected.ItemEnd + 1,
                      Selected.ItemBegin, Selected.ItemEnd);
                    SizeLinks(Selected);
                  end;     
                end;
              end;
            end;

            try
              if FPlanner.Sidebar.Orientation = soHorizontal then
              begin
                if (ItemBegin < LeftCol) then
                  LeftCol := LeftCol - 1;
              end
              else
              begin
                if ItemBegin < TopRow then
                  TopRow := TopRow - 1;
              end;
            except
            end;
          end;
          Key := 0;
        end;
      end;
    VK_DOWN:
      begin
        if Assigned(FPlanner.Items.Selected) then
          with FPlanner.Items.Selected do
          begin
            if ItemEnd + FPlanner.Display.DisplayStart <= FPlanner.Display.DisplayEnd then
            begin
              if (GetKeyState(vk_shift) and $8000 = 0) and not FixedPos and not FixedTime and (FPlanner.UserMode in [puNormal, puReadOnly]) then
              begin
                if not FPlanner.Items.HasItem(ItemBegin + 1, ItemEnd + 1,
                  ItemPos) then
                begin
                  Allow := True;

                  if Assigned(FPlanner.FOnItemMoving) then
                  begin
                    FPlanner.FOnItemMoving(FPlanner,FPlanner.Items.Selected,+1,0,Allow);
                  end;

                  if Allow then
                  begin
                    ItemBegin := ItemBegin + 1;
                    ItemEnd := ItemEnd + 1;
                    RealTime := False;
                    FPlanner.Items.SetConflicts;

                    with FPlanner.Items do
                    begin
                      FPlanner.ItemMoved(Selected, Selected.ItemBegin
                          - 1, Selected.ItemEnd - 1, Selected.ItemPos,
                          Selected.ItemBegin, Selected.ItemEnd, Selected.ItemPos);
                      MoveLinks(Selected);
                    end;
                  end;
                end;
                Key := 0;
              end
              else
              begin
                if not FPlanner.Items.HasItem(ItemBegin, ItemEnd + 1, ItemPos)
                  and not FixedSize and (FPlanner.UserMode in [puNormal, puReadOnly]) then
                begin
                  Allow := True;

                  if Assigned(FPlanner.FOnItemSizing) then
                  begin
                    FPlanner.FOnItemSizing(FPlanner,FPlanner.Items.Selected,0,+1,Allow);
                  end;

                  if Allow then
                  begin
                    ItemEnd := ItemEnd + 1;
                    RealTime := False;
                    FPlanner.Items.SetConflicts;

                    with FPlanner.Items do
                    begin
                      FPlanner.ItemSized(Selected, Selected.ItemBegin, Selected.ItemEnd - 1,
                                         Selected.ItemBegin, Selected.ItemEnd);
                      SizeLinks(Selected);
                    end;
                  end;
                end;
              end;

              try
                if FPlanner.Sidebar.Orientation = soHorizontal then
                begin
                  if (ItemEnd > visiblecolcount) then
                    LeftCol := LeftCol + 1;
                end
                else
                begin
                  if ItemEnd > TopRow + VisibleRowCount then
                    TopRow := TopRow + 1;
                end;
              except
              end;
            end;
            Key := 0;
          end;
      end;
  end;

  if not FPlanner.SelectionAlways and Assigned(APlannerItem) then
  begin
    Key := 0;
    Exit;
  end;

  if FPlanner.Mode.FullHalfDay then
  begin
    case Key of
    VK_LEFT:
    begin
      if ssShift in ShiftState then
        ChangeSelection(0,0,-1,0)
      else
        ChangeSelection(-1,0,0,0);
      Key := 0;
    end;
    VK_RIGHT:
    begin
      if ssShift in ShiftState then
        ChangeSelection(0,0,+1,0)
      else
        ChangeSelection(+1,0,0,0);
      Key := 0;
    end;
    VK_UP:
    begin
      if ssShift in ShiftState then
        ChangeSelection(0,0,0,-1)
      else
        ChangeSelection(0,-1,0,0);
      Key := 0;
    end;
    VK_DOWN:
    begin
      if ssShift in ShiftState then
        ChangeSelection(0,0,0,+1)
      else
        ChangeSelection(0,+1,0,0);
      Key := 0;
    end;
    end;
  end;

  inherited;

  if Key in [VK_UP,VK_LEFT,VK_RIGHT,VK_DOWN,VK_PRIOR,VK_NEXT,
    VK_HOME,VK_END] then
      SelChanged;

  CorrectSelection;

  if Assigned(FPlanner.FOnPlannerKeyDown) then
  begin
    if FPlanner.Sidebar.Orientation = soVertical then
    begin
      FromSel := Selection.Top;
      ToSel := 1 + Selection.Bottom;
      FromSelPrecis := FromSel * FPlanner.Display.DisplayUnit + FPlanner.Display.DisplayOffset;
      ToSelPrecis := ToSel * FPlanner.Display.DisplayUnit + FPlanner.Display.DisplayOffset;
      FPlanner.FOnPlannerKeyDown(FPlanner, Key, ShiftState, Col - 1, FromSel,
        FromSelPrecis, ToSel, ToSelPrecis)
    end
    else
    begin
      FromSel := Selection.Left;
      ToSel := 1 + Selection.Right;
      FromSelPrecis := FromSel * FPlanner.Display.DisplayUnit + FPlanner.Display.DisplayOffset;
      ToSelPrecis := ToSel * FPlanner.Display.DisplayUnit + FPlanner.Display.DisplayOffset;
      FPlanner.FOnPlannerKeyDown(FPlanner, Key, ShiftState, Row - 1, FromSel,
        FromSelPrecis, ToSel, ToSelPrecis)
    end;
  end;

end;

procedure TPlannerGrid.DoExit;
begin
  inherited;
  if Assigned(FPlanner.OnExit) then
    FPlanner.OnExit(FPlanner);
end;

procedure TPlannerGrid.DoEnter;
var
  GridRect: TGridRect;
begin
  inherited;
  if (Selection.Left = -1) or (Selection.Top = -1) then
  begin
    {$IFNDEF TMSDOTNET}
    FillChar(GridRect, SizeOf(GridRect), 0);
    {$ENDIF}
    Selection := GridRect;
    SelChanged;
  end;
  if Assigned(FPlanner.OnEnter) then
    FPlanner.OnEnter(FPlanner);
end;

procedure TPlannerGrid.KeyPress(var Key: Char);
var
  FromSel, FromSelPrecis: Integer;
  ToSel, ToSelPrecis: Integer;

begin
  if Assigned(FPlanner.FOnPlannerKeypress) then
  begin
    if FPlanner.Sidebar.Orientation = soVertical then
    begin
      FromSel := Selection.Top;
      ToSel := 1 + Selection.Bottom;
      FromSelPrecis := FromSel * FPlanner.Display.DisplayUnit + FPlanner.Display.DisplayOffset;
      ToSelPrecis := ToSel * FPlanner.Display.DisplayUnit + FPlanner.Display.DisplayOffset;
      FPlanner.FOnPlannerKeypress(FPlanner, Key, Col - 1, FromSel,
        FromSelPrecis, ToSel, ToSelPrecis)
    end
    else
    begin
      FromSel := Selection.Left;
      ToSel := 1 + Selection.Right;
      FromSelPrecis := FromSel * FPlanner.Display.DisplayUnit + FPlanner.Display.DisplayOffset;
      ToSelPrecis := ToSel * FPlanner.Display.DisplayUnit + FPlanner.Display.DisplayOffset;
      FPlanner.FOnPlannerKeypress(FPlanner, Key, Row - 1, FromSel,
        FromSelPrecis, ToSel, ToSelPrecis)
    end;

  end;
end;


function LongMulDiv(Mult1, Mult2, Div1: Integer): Integer; stdcall;
  external 'kernel32.dll' Name 'MulDiv';

procedure TPlannerGrid.WMVScroll(var WMScroll: TWMScroll);
begin
  if (Row < FixedRows) or (Col < FixedCols) then
  begin
    Selection := TGridRect(Rect(FixedCols, FixedRows, FixedCols, FixedRows));
    SelChanged;
  end;

  if (WMScroll.ScrollCode = SB_THUMBTRACK) and (FPlanner.FScrollSynch) then
  begin
    TopRow := FixedRows + LongMulDiv(WMScroll.Pos, RowCount - VisibleRowCount -
      FixedRows, MaxShortInt);
  end;

  FOldTopRow := TopRow;

  inherited;

  UpdateVScrollBar;
end;

procedure TPlannerGrid.DestroyWnd;
begin
  inherited;
end;

procedure TPlannerGrid.HintHide;
begin
  FScrollHintWindow.ReleaseHandle;
end;

procedure TPlannerGrid.HintShowXY(X, Y: Integer; Caption: TCaption);
var
  HintRect: TRect;
  ScreenPoint: TPoint;
begin
  if not FPlanner.HintOnItemChange then
    Exit;

  HintRect := FScrollHintWindow.CalcHintRect(FPlanner.MaxHintWidth, Caption, nil);
  FScrollHintWindow.Caption := Caption;
  FScrollHintWindow.Color := FPlanner.HintColor;
  ScreenPoint := ClientToScreen(Point(X, Y));
  HintRect.Left := HintRect.Left + ScreenPoint.X + 10;
  HintRect.Right := HintRect.Right + ScreenPoint.X + 10;
  HintRect.Top := HintRect.Top + ScreenPoint.Y + 10;
  HintRect.Bottom := HintRect.Bottom + ScreenPoint.Y + 10;
  FScrollHintWindow.ActivateHint(HintRect, Caption);
end;

procedure TPlannerGrid.Paint;
var
  r: TRect;
  fh,i,m: Integer;
  p: TPoint;

begin
  FPlanner.Items.ClearRepaints;

  inherited;


  {$IFDEF FREEWARE}
  if (TopRow = RowCount - VisibleRowCount) then
  begin
    Canvas.Font.Name := 'Tahoma';
    Canvas.Font.Size := 8;
    Canvas.Font.Color := clGray;
    Canvas.Brush.Style := bsClear;

    r := CellRect(1,RowCount -1);
    Canvas.TextOut(r.Left + 4,r.Top + 4,FPlanner.ClassName + ' : Copyright © 1999 - 2009 by TMS software');
  end;
  {$ENDIF}

  if (csDesigning in ComponentState) and FPlanner.ShowDesignHelper then
  begin
    r := ClientRect;
    Canvas.Font.Name := 'Tahoma';
    Canvas.Font.Size := 8;
    Canvas.Brush.Color := clInfoBk;
    Canvas.Pen.Color := clRed;
    r.Left := r.Right - 150;
    r.Top := r.Bottom - 70;
    Canvas.Rectangle(r);
    Canvas.Font.Color := clNavy;
    Canvas.Font.Style := [fsUnderline];
    fh := Canvas.TextHeight('gh') + 2;
    Canvas.TextOut(r.Left + 4, r.Top + 4, s_QuickConfig);

    GetCursorPos(P);
    P := ScreenToClient(P);

    i := MouseOverDesignChoice(P.X, P.Y);

    if i = 1 then
      Canvas.Font.Style := [fsUnderline]
    else
      Canvas.Font.Style := [];

    if (FPlanner.Sidebar.Position in [spLeft, spLeftRight, spRight]) then
      Canvas.TextOut(r.Left + 4, r.Top + 4 + fh, s_HTimeAxis)
    else
      Canvas.TextOut(r.Left + 4, r.Top + 4 + fh, s_VTimeAxis);

    if i = 2 then
      Canvas.Font.Style := [fsUnderline]
    else
      Canvas.Font.Style := [];

    if (FPlanner.Items.Count) > 0 then
      Canvas.TextOut(r.Left + 4, r.Top + 4 + 2 * fh, s_HideDesignItem)
    else
      Canvas.TextOut(r.Left + 4, r.Top + 4 + 2 * fh, s_ShowDesignItem);

    if i = 3 then
      Canvas.Font.Style := [fsUnderline]
    else
      Canvas.Font.Style := [];

    m := 0;
    case FPlanner.Mode.PlannerType of
    plDay : m := 1;
    plMonth : m := 2;
    plDayPeriod : m := 3;
    plHalfDayPeriod : m := 4;
    plMultiMonth : m := 5;
    plTimeLine : m := 0;
    end;

    Canvas.TextOut(r.Left + 4, r.Top + 4 + 3 * fh, s_Modes[m]);
  end;

end;

procedure TPlannerGrid.RepaintSelection(ASelection: TGridRect);
var
  i: integer;
  r: TRect;

begin
  if ActiveCellShow = assRow then
  begin
    for i := ASelection.Left to ASelection.Right do
    begin
      r := CellRect(i,0);

      {$IFNDEF TMSDOTNET}
      InvalidateRect(Handle,@r,True);
      {$ENDIF}

      {$IFDEF TMSDOTNET}
      InvalidateRect(Handle,r,True);
      {$ENDIF}

      if FPlanner.Sidebar.ShowInPositionGap then
      begin
        r := CellRect(i, 1);
        {$IFNDEF TMSDOTNET}
        InvalidateRect(Handle,@r,True);
        {$ENDIF}

        {$IFDEF TMSDOTNET}
        InvalidateRect(Handle,r,True);
        {$ENDIF}
      end;


    end;
  end;

  if (ActiveCellShow = assCol) or (FPlanner.Display.DisplayText > 0) then
  begin
    for i := ASelection.Top to ASelection.Bottom do
    begin
      r := CellRect(0,i);
      InflateRect(r,2,2);

      {$IFNDEF TMSDOTNET}
      InvalidateRect(Handle,@r,True);
      {$ENDIF}

      {$IFDEF TMSDOTNET}
      InvalidateRect(Handle,r,True);
      {$ENDIF}

      if FPlanner.Sidebar.ShowInPositionGap then
      begin
        r := CellRect(1,i);
        {$IFNDEF TMSDOTNET}
        InvalidateRect(Handle,@r,True);
        {$ENDIF}

        {$IFDEF TMSDOTNET}
        InvalidateRect(Handle,r,True);
        {$ENDIF}
      end;


      if (FPlanner.Sidebar.Position in [spRight, spLeftRight]) then
      begin

        r := CellRect(ColCount - 1,i);
        InflateRect(r,2,2);

        {$IFNDEF TMSDOTNET}
        InvalidateRect(Handle,@r,True);
        {$ENDIF}

        {$IFDEF TMSDOTNET}
        InvalidateRect(Handle,r,True);
        {$ENDIF}


      end;
    end;
  end;
end;

function TPlannerGrid.SelectCell(AColumn, ARow: Integer): Boolean;
var
  CanSelect: Boolean;
  PF: TCustomForm;

begin
  PF := GetParentForm(Self);

  if (FPlanner.Sidebar.Position in [spRight, spLeftRight]) and FPlanner.SideBar.Visible and
     (AColumn = ColCount - 1) then
  begin
    Result := False;
    Exit;
  end;

  try
    if Assigned(PF) then
    begin
      if PF.Visible and Visible then
        SetFocus;
    end
    else
      if Visible then
        SetFocus;
  except
  end;

  CanSelect := inherited SelectCell(AColumn, ARow);

  if Assigned(FPlanner.OnPlannerSelectCell) then
  begin
    if FPlanner.SideBar.Position in [spLeft,spRight,spLeftRight] then
      FPlanner.OnPlannerSelectCell(FPlanner,ARow,AColumn,CanSelect)
    else
      FPlanner.OnPlannerSelectCell(FPlanner,AColumn,ARow,CanSelect);
  end;

  Result := CanSelect;
end;

function TPlannerGrid.CellRectEx(X, Y: Integer): TRect;
begin

  if Y > TopRow + VisibleRowCount then
    Y := TopRow + VisibleRowCount - 1;

  if Y < TopRow then
    Y := TopRow;

  if X > LeftCol + VisibleColCount then
    X := LeftCol + VisibleColCount - 1;

  if (X < LeftCol) and (FPlanner.SideBar.Position <> spRight) then
    X := LeftCol;

  Result := CellRect(X,Y);

  if (FPlanner.Sidebar.Position in [spLeft,spLeftRight]) and (FPlanner.FPositionGap > 0) and FPlanner.GapAtColumn(X) then
  begin
    Result.Left := Result.Left + FPlanner.FPositionGap;
  end;
end;

function TPlannerGrid.ColWidthEx(ItemPos: Integer): Integer;
begin
  if FPlanner.Sidebar.Position <> spRight then
    Inc(ItemPos);

  if (FPlanner.PositionGap > 0) and FPlanner.GapAtColumn(ItemPos) then
    Result := ColWidths[ItemPos] - FPlanner.FPositionGap
  else
    Result := ColWidths[ItemPos];
end;

function TPlannerGrid.RowHeightEx(ItemPos: Integer): Integer;
begin
  //if not FPlanner.FSideBar.Visible then
    Inc(ItemPos);

//  Result := RowHeights[ItemPos] - FPlanner.FPositionGap;
  Result := RowHeights[ItemPos];
end;


procedure TPlannerGrid.GetSideBarLines(Index, Position: Integer; var Line1,
  Line2, Line3: string;var HS: Boolean);
var
  Mins: Integer;
  dt,dte: TDatetime;
  h,m,s,s100: Word;
  dbl: double;
begin
  Line1 := '';
  Line2 := '';
  Line3 := '';

  case FPlanner.FMode.FPlannerType of
    plDay:
      begin
        Mins := (Index + FPlanner.Display.DisplayStart) * FPlanner.Display.DisplayUnit
          + FPlanner.Display.DisplayOffset;

        HS := (Mins div 60) <> ((Mins - FPlanner.Display.DisplayUnit) div 60);

        if (Mins = 0) then
          HS := true;

        FPlanner.PlanTimeToStrings(Mins, Line1, Line2, Line3);
      end;
    plTimeLine:
      begin
        FPlanner.CellToAbsTime(Index,dt,dte);

        DecodeTime(dt,h,m,s,s100);

        Mins := h * 60 + m;

        {
        Mins := (Index + FPlanner.Display.DisplayStart) * FPlanner.Display.DisplayUnit
          + FPlanner.Display.DisplayOffset;
        }

        HS := (Mins div 60) <> ((Mins - FPlanner.Display.DisplayUnit) div 60);

        FPlanner.PlanTimeToStrings(Mins, Line1, Line2, Line3);
      end;
    plWeek:
      begin
        if FPlanner.SideBar.ShowDayName then
          Line2 := FPlanner.GetDayName(Index - FPlanner.FMode.WeekStart);
        if FPlanner.SideBar.FDateTimeFormat <> '' then
          Line2 := Line2 + ' ' + FormatDateTime(FPlanner.SideBar.FDateTimeFormat,
          FPlanner.Mode.StartOfMonth + Index);
        HS := true;
      end;
    plMonth:
      begin
        if FPlanner.SideBar.ShowDayName then
          Line1 := FPlanner.GetDayName(DayOfWeek(Index + FPlanner.FMode.StartOfMonth));
        Line2 := FormatDateTime(FPlanner.SideBar.FDateTimeFormat,
          FPlanner.Mode.StartOfMonth + Index);
        HS := true;
      end;
    plDayPeriod:
      begin
        if FPlanner.SideBar.ShowDayName then
          Line1 := FPlanner.GetDayName(DayOfWeek(Index + FPlanner.FMode.PeriodStartDate));
        Line2 := FormatDateTime(FPlanner.SideBar.DateTimeFormat,
          FPlanner.Mode.PeriodStartDate + Index);
        HS := true;
      end;
    plHalfDayPeriod:
    begin
      if FPlanner.SideBar.ShowDayName then
      begin
        dbl := Index / 2;
        {$IFDEF TMSDOTNET}
        Line1 := FPlanner.GetDayName(DayOfWeek(TDateTime(Trunc(dbl)) + FPlanner.FMode.PeriodStartDate));
        {$ENDIF}
        {$IFNDEF TMSDOTNET}
        Line1 := FPlanner.GetDayName(DayOfWeek(Trunc(dbl) + FPlanner.FMode.PeriodStartDate));
        {$ENDIF}
      end;
      Line2 := FormatDateTime(FPlanner.SideBar.DateTimeFormat,
        Trunc(FPlanner.Mode.PeriodStartDate + Index / 2));
      if Odd(Index) then
      Line3 := 'PM' else Line3 := 'AM';
      HS := true;      
    end;
    plMultiMonth:
    begin
      if Index < 31 then
        Line2 := IntTostr(Index + 1);
      HS := true;        
    end;
    plCustom, plCustomList:
    begin
      dt := FPlanner.IndexToTime(Index);
      Line1 := FormatDateTime(FPlanner.Sidebar.DateTimeFormat,dt);
      HS := true;      
    end;
  end;

  if Assigned(FPlanner.OnPlannerGetSideBarLines) then
  begin
    FPlanner.OnPlannerGetSideBarLines(FPlanner, Index, Position, Line1, Line2, Line3);
    HS := Line1 <> '';
  end;
end;

procedure TPlannerGrid.KeyUp(var Key: Word; ShiftState: TShiftState);
var
  FromSel, FromSelPrecis: Integer;
  ToSel, ToSelPrecis: Integer;
begin
  inherited;
  if Assigned(FPlanner.FOnPlannerKeyUp) then
  begin
    if FPlanner.Sidebar.Orientation = soVertical then
    begin
      FromSel := Selection.Top;
      ToSel := 1 + Selection.Bottom;
      FromSelPrecis := FromSel * FPlanner.Display.DisplayUnit + FPlanner.Display.DisplayOffset;
      ToSelPrecis := ToSel * FPlanner.Display.DisplayUnit + FPlanner.Display.DisplayOffset;
      FPlanner.FOnPlannerKeyUp(FPlanner, Key, ShiftState, Col - 1, FromSel,
        FromSelPrecis, ToSel, ToSelPrecis)
    end
    else
    begin
      FromSel := Selection.Left;
      ToSel := 1 + Selection.Right;
      FromSelPrecis := FromSel * FPlanner.Display.DisplayUnit + FPlanner.Display.DisplayOffset;
      ToSelPrecis := ToSel * FPlanner.Display.DisplayUnit + FPlanner.Display.DisplayOffset;
      FPlanner.FOnPlannerKeyUp(FPlanner, Key, ShiftState, Row - 1, FromSel,
        FromSelPrecis, ToSel, ToSelPrecis)
    end;
  end;
end;

procedure TPlannerGrid.UpdateHScrollBar;
var
  ScrollInfo: TScrollinfo;
begin
  if not (ScrollBars in [ssBoth,ssHorizontal]) then
    Exit;

  if not FPlanner.ScrollBarStyle.Flat then
    Exit;

  ScrollInfo.FMask := SIF_ALL;
  {$IFNDEF TMSDOTNET}
  ScrollInfo.cbSize := SizeOf(ScrollInfo);
  {$ENDIF}
  {$IFDEF TMSDOTNET}
  ScrollInfo.cbSize := Marshal.SizeOf(TypeInfo(ScrollInfo));
  {$ENDIF}
  GetScrollInfo(self.Handle,SB_HORZ,ScrollInfo);
  ScrollInfo.FMask := SIF_ALL;
  {$IFNDEF TMSDOTNET}
  ScrollInfo.cbSize := SizeOf(ScrollInfo);
  {$ENDIF}
  {$IFDEF TMSDOTNET}
  ScrollInfo.cbSize := Marshal.SizeOf(TypeInfo(ScrollInfo));
  {$ENDIF}
  FlatSetScrollInfo(SB_HORZ,ScrollInfo,True)
end;

procedure TPlannerGrid.UpdateVScrollBar;
var
  ScrollInfo: TScrollInfo;
begin
  if not (ScrollBars in [ssBoth,ssVertical]) then
    Exit;

  if not FPlanner.ScrollBarStyle.Flat then
    Exit;

  ScrollInfo.FMask := SIF_ALL;
  {$IFNDEF TMSDOTNET}
  ScrollInfo.cbSize := SizeOf(ScrollInfo);
  {$ENDIF}
  {$IFDEF TMSDOTNET}
  ScrollInfo.cbSize := Marshal.SizeOf(TypeInfo(ScrollInfo));  
  {$ENDIF}
  GetScrollInfo(Handle,SB_VERT,ScrollInfo);

  ScrollInfo.FMask := SIF_ALL;
  {$IFNDEF TMSDOTNET}
  ScrollInfo.cbSize := SizeOf(ScrollInfo);
  {$ENDIF}
  {$IFDEF TMSDOTNET}
  ScrollInfo.cbSize := Marshal.SizeOf(TypeInfo(ScrollInfo));
  {$ENDIF}

  FlatSetScrollInfo(SB_VERT,ScrollInfo,True);
end;

procedure TPlannerGrid.FlatSetScrollInfo(Code: Integer;var scrollinfo:TScrollInfo;FRedraw: Bool);
{$IFNDEF TMSDOTNET}
var
  ComCtl32DLL: THandle;
  _FlatSB_SetScrollInfo: function(wnd:hwnd;Code: Integer;var ScrollInfo: TScrollInfo;FRedraw: Bool): Integer; stdcall;
{$ENDIF}
begin
  {$IFNDEF TMSDOTNET}
  ComCtl32DLL := GetModuleHandle(comctrl);
  if ComCtl32DLL > 0 then
  begin

    @_FlatSB_SetScrollInfo := GetProcAddress(ComCtl32DLL,'FlatSB_SetScrollInfo');
    if Assigned(_FlatSB_SetScrollInfo) then
    begin
      _FlatSB_SetScrollInfo(self.Handle,code,scrollinfo,fRedraw);
    end;
  end;
  {$ENDIF}
  {$IFDEF TMSDOTNET}
  FlatSB_SetScrollInfo(self.Handle,code,scrollinfo,fRedraw);
  {$ENDIF}
end;

procedure TPlannerGrid.FlatScrollInit;
{$IFNDEF TMSDOTNET}
var
  ComCtl32DLL: THandle;
  _InitializeFlatSB: function(wnd:hwnd):Bool stdcall;
{$ENDIF}  
begin
  {$IFNDEF TMSDOTNET}
  ComCtl32DLL := GetModuleHandle(comctrl);
  if ComCtl32DLL > 0 then
  begin
    @_InitializeFlatSB := GetProcAddress(ComCtl32DLL,'InitializeFlatSB');
    if Assigned(_InitializeFlatSB) then
      _InitializeFlatSB(self.Handle);
  end;
  {$ENDIF}

  {$IFDEF TMSDOTNET}
  InitializeFlatSB(self.Handle);
  {$ENDIF}
end;

procedure TPlannerGrid.FlatScrollDone;
{$IFNDEF TMSDOTNET}
var
  ComCtl32DLL: THandle;
  _UninitializeFlatSB: function(wnd:hwnd):Bool stdcall;
{$ENDIF}
begin
  {$IFNDEF TMSDOTNET}
  ComCtl32DLL := GetModuleHandle(comctrl);
  if ComCtl32DLL > 0 then
  begin
    @_UninitializeFlatSB := GetProcAddress(ComCtl32DLL,'UninitializeFlatSB');
    if Assigned(_UninitializeFlatSB) then
      _UninitializeFlatSB(self.Handle);
  end;
  {$ENDIF}
  {$IFDEF TMSDOTNET}
  UninitializeFlatSB(self.Handle);
  {$ENDIF}
end;

procedure TPlannerGrid.FormExit(Sender: TObject);
var
  s: string;
  ComboIdx: Integer;
  ComboObj: TObject;
begin
  if FInplaceEdit.Visible then
  begin
    s := FCurrCtrlItem.Text.Text;
    SetControlValue(s,FCurrCtrlEdit,FInplaceEdit.Text);
    FCurrCtrlItem.Text.Text := s;
    FInplaceEdit.Hide;
    if Assigned(FPlanner.OnItemControlEditDone) then
      FPlanner.OnItemControlEditDone(Self,0,0,
        FCurrCtrlItem, FCurrCtrlEdit,'EDIT',FInplaceEdit.Text);
  end;

  if FInplaceCombo.Visible then
  begin
    s := FCurrCtrlItem.Text.Text;

    ComboIdx := FInplaceCombo.ItemIndex;
    if ComboIdx >= 0 then
      ComboObj := FInplaceCombo.Items.Objects[ComboIdx]
    else
      ComboObj := nil;

    SetControlValue(s,FCurrCtrlEdit,FInplaceCombo.Text);
    FCurrCtrlItem.Text.Text := s;
    FInplaceCombo.Hide;
    if Assigned(FPlanner.OnItemControlEditDone) then
      FPlanner.OnItemControlEditDone(Self,0,0,
        FCurrCtrlItem, FCurrCtrlEdit,'COMBO',s);
    if Assigned(FPlanner.OnItemControlComboSelect) then
      FPlanner.OnItemControlComboSelect(Self,0,0,FCurrCtrlItem,FCurrCtrlEdit,s,ComboIdx,ComboObj);
  end;
end;

procedure TPlannerGrid.FormHandle(Item: TPlannerItem; ControlRect: TRect;
  ControlID,ControlType,ControlValue: string);
var
  s: string;
  sl: TStringList;
  Edit: Boolean;
  DropHeight: Integer;
begin
  if Item.ReadOnly or (FPlanner.UserMode in [puReadOnly, puViewOnly]) then
    Exit;

  FCurrCtrlItem := Item;
  FCurrCtrlEdit := ControlID;

  if ControlType = 'CHECK' then
  begin
    s := Item.Text.Text;

    if Uppercase(ControlValue) = 'TRUE' then
      SetControlValue(s,ControlID,'FALSE')
    else
      SetControlValue(s,ControlID,'TRUE');

    Item.Text.Text := s;
  end;

  if Assigned(FPlanner.OnItemControlEditStart) then
    FPlanner.OnItemControlEditStart(Self,ControlRect.Left,ControlRect.Right,
      Item, ControlID,ControlType,ControlValue);

  if ControlType = 'EDIT' then
  begin
    FInplaceEdit.Width := 0;
    FInplaceEdit.Parent := self;
    FInplaceEdit.Visible := True;
    FInplaceEdit.OnExit := FormExit;
    FInplaceEdit.Text := ControlValue;
    FInplaceEdit.BorderStyle := bsNone;
    FInplaceEdit.Left := ControlRect.Left + 2;
    FInplaceEdit.Width := ControlRect.Right - ControlRect.Left - 3;
    FInplaceEdit.Top := ControlRect.Top + 6;
    FInplaceEdit.Height := ControlRect.Bottom - ControlRect.Top - 4;
    BringWindowToTop(FInplaceEdit.Handle);
    FInplaceEdit.SetFocus;
  end;

  if ControlType = 'COMBO' then
  begin
    FInplaceCombo.Width := 0;
    FInplaceCombo.Parent := Self;

    FInplaceCombo.BkColor := ColorToRGB(Item.SelectColor);
    FInplaceCombo.Color := ColorToRGB(Item.SelectColor);
    FInplaceCombo.Visible := True;
    FInplaceCombo.OnExit := FormExit;
    FInplaceCombo.Text := ControlValue;
    FInplaceCombo.Left := ControlRect.Left + 4;
    FInplaceCombo.Width := ControlRect.Right - ControlRect.Left - 4;
    FInplaceCombo.Top := ControlRect.Top + 6;

    DropHeight := 200;

    if Assigned(FPlanner.OnItemControlComboList) then
    begin
      sl := TStringList.Create;
      Edit := True;
      FPlanner.OnItemControlComboList(Self,Item,ControlID,ControlValue,Edit,sl,DropHeight);

      if Edit then
        FInplaceCombo.Style := csDropDown
      else
        FInplaceCombo.Style := csDropDownList;

      FInplaceCombo.Items.Assign(sl);

      FInplaceCombo.ItemIndex := sl.IndexOf(ControlValue);

      sl.Free;
    end;

    if Edit then
      FInplaceCombo.Height := ControlRect.Bottom - ControlRect.Top - 4
    else
      FInplaceCombo.Height := DropHeight;

    BringWindowToTop(FInplaceCombo.Handle);
    FInplaceCombo.SetFocus;

    FInplaceCombo.DroppedDown := True;
  end;
end;

procedure TPlannerGrid.WMHScroll(var WMScroll: TWMScroll);
begin
  FOldLeftCol := LeftCol;

  inherited;

  if (WMScroll.ScrollCode = SB_THUMBTRACK) and (FPlanner.FScrollSynch) then
  begin
    LeftCol := FixedCols + LongMulDiv(WMScroll.Pos, ColCount - VisibleColCount -
      FixedCols, MaxShortInt);
  end;

  UpdateHScrollBar;
end;

procedure TPlannerGrid.FlatSetScrollProp(Index, NewValue: Integer;
  FRedraw: bool);
{$IFNDEF TMSDOTNET}
var
  ComCtl32DLL: THandle;
  _FlatSB_SetScrollProp:function(wnd:hwnd;Index,newValue: Integer;fredraw:bool):bool stdcall;
{$ENDIF}
begin
  {$IFNDEF TMSDOTNET}
  ComCtl32DLL := GetModuleHandle(comctrl);
  if ComCtl32DLL > 0 then
  begin
    @_FlatSB_SetScrollProp:=GetProcAddress(ComCtl32DLL,'FlatSB_SetScrollProp');
    if Assigned(_FlatSB_SetScrollProp) then
      _FlatSB_SetScrollProp(self.Handle,Index,newValue,FRedraw);
  end;
  {$ENDIF}
  {$IFDEF TMSDOTNET}
  FlatSB_SetScrollProp(self.Handle,Index,newValue,FRedraw);
  {$ENDIF}
end;

procedure TPlannerGrid.FlatShowScrollBar(Code: Integer; Show: bool);
{$IFNDEF TMSDOTNET}
var
  ComCtl32DLL: THandle;
  _FlatSB_ShowScrollBar:function(wnd:hwnd;code: Integer;show:bool): Integer; stdcall;
{$ENDIF}
begin
  {$IFNDEF TMSDOTNET}
  case code of
  SB_VERT:if not (ScrollBars in [ssBoth,ssVertical]) then Exit;
  SB_HORZ:if not (ScrollBars in [ssBoth,ssHorizontal]) then Exit;
  end;

  ComCtl32DLL := GetModuleHandle(comctrl);
  if ComCtl32DLL > 0 then
  begin
    @_FlatSB_ShowScrollBar:=GetProcAddress(ComCtl32DLL,'FlatSB_ShowScrollBar');
    if Assigned(_FlatSB_ShowScrollBar) then
      _FlatSB_ShowScrollBar(self.Handle,code,show);
  end;
  {$ENDIF}
  {$IFDEF TMSDOTNET}
  FlatSB_ShowScrollBar(self.Handle,code,show);
  {$ENDIF}
end;

procedure TPlannerGrid.MouseToCell(X, Y: Integer; var ACol, ARow: Longint);
var
  Coord: TGridCoord;
begin
  Coord := MouseCoord(X, Y);
  ACol := Coord.X;
  ARow := Coord.Y;
end;

procedure TPlannerGrid.RepaintRect(r: TRect);
var
  r1,r2,ur:TRect;
begin
  r1 := CellRect(r.Left,r.Top);
  r2 := CellRect(r.Right,r.Bottom);
  UnionRect(ur,r1,r2);

  if IsRectEmpty(r1) or IsRectEmpty(r2) then
    Repaint
  else
    {$IFNDEF TMSDOTNET}
    InvalidateRect(Handle,@ur,True);
    {$ENDIF}

    {$IFDEF TMSDOTNET}
    InvalidateRect(Handle,ur,True);
    {$ENDIF}
end;

procedure TPlannerGrid.InvalidateCellRect(R: TRect);
var
  i,j: Integer;
begin
  for i := R.Left to R.Right do
    for j := R.Top to R.Bottom do
    {$IFNDEF TMSDOTNET}
      InvalidateCell(i,j);
    {$ENDIF}
    {$IFDEF TMSDOTNET}
      InvalidateCellP(i,j);
    {$ENDIF}

  if (FPlanner.Sidebar.Orientation = soVertical) and
     FPlanner.Sidebar.Visible and
     FPlanner.Sidebar.ShowOccupied then
    for i := R.Top to R.Bottom do
    begin
    {$IFNDEF TMSDOTNET}
      InvalidateCell(0, i);
    {$ENDIF}
    {$IFDEF TMSDOTNET}
      InvalidateCellP(0, i);
    {$ENDIF}
    end;

  if (FPlanner.Sidebar.Orientation = soHorizontal) and
     FPlanner.Sidebar.Visible and
     FPlanner.Sidebar.ShowOccupied then
    for i := r.Left to r.Right do
    begin
    {$IFNDEF TMSDOTNET}
      InvalidateCell(i, 0);
    {$ENDIF}
    {$IFDEF TMSDOTNET}
      InvalidateCell(i, 0);
    {$ENDIF}
    end;
end;

{$IFDEF DELPHI5_LVL}
function TPlannerGrid.DoMouseWheelDown(Shift: TShiftState;
  MousePos: TPoint): Boolean;
begin
  if FPlanner.WheelAction = pwaSelect then
  begin
    if (Row < 0) or (Col < 0) or (Row >= RowCount) or (Col >= ColCount) then
    begin
      Selection := TGridRect(Rect(FixedCols,FixedRows,FixedCols,FixedRows));
      SelChanged;
    end;

    if Row + FPlanner.WheelDelta < RowCount - 1 then
      Row := Row + FPlanner.WheelDelta
    else
      Row := RowCount - 1;

    Result := True;
    CorrectSelection;
    SelChanged;
  end
  else
  begin
    Result := false;
    if TopRow < RowCount - VisibleRowCount then
    begin
      TopRow := TopRow + 1;
      Result := true;
    end;  
  end;    

end;

function TPlannerGrid.DoMouseWheelUp(Shift: TShiftState;
  MousePos: TPoint): Boolean;
begin
  if FPlanner.WheelAction = pwaSelect then
  begin
    if (Row < 0) or (Col < 0) or (Row >= RowCount) or (Col >= ColCount) then
    begin
      Selection := TGridRect(Rect(FixedCols,FixedRows,FixedCols,FixedRows));
      SelChanged;
    end;

    if Row - FPlanner.WheelDelta >= FixedRows then
      Row := Row - FPlanner.WheelDelta
    else
      Row := FixedRows;

    Result := True;
    CorrectSelection;
    SelChanged;
  end
  else
  begin
    Result := false;
    if TopRow > FixedRows then
    begin
      Result := true;
      TopRow := TopRow - 1;
    end;
  end;
end;
{$ENDIF}

procedure TPlannerGrid.ChangeSelection(x,y,dx,dy: Integer);
var
  gr: TGridRect;
begin
  gr := Selection;

  if (dx = 0) then
  begin
    gr.Left := gr.Left + x;
    if gr.Left <= 0 then
    begin
      gr.Left := 1;
      LeftCol := FixedCols;
    end;
    gr.Right := gr.Left;
  end
  else
  begin
    if (FMouseRCD.x = gr.Left) then
    begin
      if (dx < 0) and (gr.Right - gr.Left =  1) then
        gr.Left := gr.Left + dx
      else
      begin
        gr.Right := gr.Right + dx;
        if dx < 0 then
          gr.Right := gr.Right - 1;
      end;
    end
    else
    begin
      if (FMouseRCD.x > gr.Left) then
        gr.Left := gr.Left + dx
      else
        gr.Right := gr.Right + dx;
    end;
  end;

  if gr.Left = 0 then
   gr.Left := 1;

  gr.Top := gr.Top + y;
  
  if gr.Top <= TopRow then
    gr.Top := TopRow;
  if gr.Top >= RowCount then
    gr.Top := RowCount - 1;  
    
  gr.Bottom := gr.Bottom + dy;
  if gr.Bottom >= RowCount then
    gr.Bottom := RowCount - 1;

  if not odd(gr.Left) then
  begin
    if (dx < 0) or (x < 0) then
      gr.Left := gr.Left - 1
    else
      gr.Left := gr.Left + 1;
  end;

  if odd(gr.Right) then
  begin
    gr.Right := gr.Right + 1;
  end;

  if (gr.Left >= gr.Right) then
  begin
    gr.Right := gr.Left + 1;
  end;

  if (dx = 0) then
    FMouseRCD.X := gr.Left;

  Selection := gr;
end;

procedure TPlannerGrid.CorrectSelection;
var
  GridRect: TGridRect;
  MinSel,MaxSel: Integer;
  Swp: Integer;

begin
  MinSel := 0;
  MaxSel := 0;

  GridRect := Selection;

  {$IFDEF TMSDEBUG}
  outputdebugstring(pchar('corr sel:'+inttostr(FMouseRCD.X) + ':'+inttostr(gridrect.Left)+'->'+inttostr(gridrect.Right)));
  {$ENDIF}

  if FPlanner.Sidebar.Orientation = soVertical then
  begin
    FPlanner.GetSelMinMax(Selection.Left,MinSel,MaxSel);

    if Selection.Left <> Selection.Right then
    begin
      if Col < GridRect.Right then
        GridRect.Left := GridRect.Right
      else
        GridRect.Right := GridRect.Left;

      Selection := GridRect;
    end;

    if MinSel > 0 then
      if GridRect.Top <= MinSel then
      begin
        GridRect.Top := MinSel;
        if GridRect.Bottom <= MinSel then
          GridRect.Bottom := MinSel;
        Selection := GridRect;
      end;

    if MaxSel > 0 then
      if GridRect.Bottom >= MaxSel then
      begin
        GridRect.Bottom := MaxSel - 1;
        if GridRect.Top >= MaxSel then
          GridRect.Top := MaxSel - 1;
        Selection := GridRect;
      end;
  end
  else
  begin
    FPlanner.GetSelMinMax(Selection.Top,MinSel,MaxSel);

    if Selection.Top <> Selection.Bottom then
    begin
      if Row < GridRect.Bottom then
        GridRect.Top := GridRect.Bottom
      else
        GridRect.Bottom := GridRect.Top;

      Selection := GridRect;
    end;

    if MinSel > 0 then
      if GridRect.Left <= MinSel then
      begin
        GridRect.Left := MinSel;
        if GridRect.Right <= MinSel then
          GridRect.Right := MinSel;
        Selection := GridRect;
      end;

    if MaxSel > 0 then
      if GridRect.Right >= MaxSel then
      begin
        GridRect.Right := MaxSel - 1;
        if GridRect.Left >= MaxSel then
          GridRect.Left := MaxSel - 1;
        Selection := GridRect;
      end;

    if FPlanner.Mode.FullHalfDay and (FMouseRCD.X >= 0) then
    begin
      if (GridRect.Left = GridRect.Right) and ((FMouseRCD.x = GridRect.Left) or (FMouseRCD.X = GridRect.Left - 1)) then
      begin
        if not odd(GridRect.Left) then
        begin
          if (GridRect.Left > 1) then
            GridRect.Left := GridRect.Left - 1
          else
            GridRect.Left := 1;
        end;
        GridRect.Right := GridRect.Left + 1;

        FMouseRCD.X := GridRect.Left;
        Selection := GridRect;
      end
      else
      begin
        if (GridRect.Left < FMouseRCD.X) then
        begin
          if odd(GridRect.Right) then
          begin
            GridRect.Right := GridRect.Right + 1;
          end;

          if not odd(GridRect.Left) then
          begin

            if (GridRect.Left > 1) then
              GridRect.Left := GridRect.Left - 1
            else
              GridRect.Left := 1;

            Selection := GridRect;
          end;
        end
        else
        begin
          if odd(GridRect.Right) then
          begin
            if GridRect.Right < FPlanner.Display.DisplayEnd - 1 then
              GridRect.Right := GridRect.Right + 1
            else
              GridRect.Right := GridRect.Right - 1;
          end;

          if (GridRect.Left < ColCount) and (GridRect.Bottom < RowCount) then
          begin
            Col := FMouseRCD.X;
            GridRect.Left := FMouseRCD.X;

            swp := GridRect.Left;
            GridRect.Left := GridRect.Right;
            GridRect.Right := swp;

            Selection := GridRect;
          end;  
        end;
      end;
    end;
  end;
end;

{ TPlannerCaption }

constructor TPlannerCaption.Create(AOwner: TCustomPlanner);
begin
  inherited Create;
  FFont := TFont.Create;
  FFont.Color := clWhite;
  FFont.Size := 10;
  FFont.Style := [];
  FFont.Name := 'Verdana';

  FFont.OnChange := FontChanged;
  FOwner := AOwner;
  FHeight := 32;
  FBackGround := clGray;
  FBackgroundTo := clWhite;
  FBackgroundSteps := 128;
  UpdatePanel;
  FTitle := 'TMS software <b>'+AOwner.ClassName+'</b>';
  FVisible := True;
end;

destructor TPlannerCaption.Destroy;
begin
  FFont.Free;
  inherited Destroy;
end;

procedure TPlannerCaption.UpdatePanel;
begin

  FOwner.FPanel.Font.Assign(FFont);
  FOwner.FPanel.Color := FBackGround;
  FOwner.FPanel.Alignment := FAlignment;
  FOwner.FPanel.Caption := FTitle;
  FOwner.FPanel.Visible := FVisible;

  if FOwner.FPanel.Visible then
    FOwner.FPanel.Height := FHeight
  else
    FOwner.FPanel.Height := 0;

  FOwner.FPanel.Repaint;

  if not Assigned(FOwner.FSidebar) then
    Exit;

  if (FOwner.Sidebar.Orientation = soVertical) then
  begin
    if FOwner.FHeader.Visible then
    begin
      FOwner.FHeader.Top := FOwner.FPanel.Height;
      FOwner.FHeader.Height := FOwner.FPlannerHeader.Height;
    end
    else
    begin
      FOwner.FHeader.Top := FOwner.FPanel.Height;
      FOwner.FHeader.Height := 0;
    end;

    if FOwner.FFooter.Visible then
    begin
      FOwner.FFooter.Top := FOwner.Height - FOwner.FPlannerFooter.Height;
      FOwner.FFooter.Height := FOwner.FPlannerFooter.Height;
    end
    else
    begin
      FOwner.FFooter.Height := 0;
    end;

    if not FOwner.FNavigatorButtons.Visible then
    begin
      FOwner.FPrev.Visible := False;
      FOwner.FNext.Visible := False;
      FOwner.FHeader.Width := FOwner.Width;
      FOwner.FHeader.Left := 0;
    end
    else
    begin
      FOwner.FPrev.Visible := True;
      FOwner.FNext.Visible := True;

      FOwner.FHeader.Left := BtnWidth;
      FOwner.FHeader.Width := FOwner.Width - 2 * BtnWidth - 2;

      FOwner.FFooter.Width := FOwner.Width;

      FOwner.FPrev.Top := FOwner.FPanel.Height;
      FOwner.FPrev.Left := 0;
      FOwner.FPrev.Width := BtnWidth;
      FOwner.FPrev.Height := FOwner.FHeader.Height;

      FOwner.FNext.Top := FOwner.FPanel.Height;
      FOwner.FNext.Left := FOwner.Width - BtnWidth;
      FOwner.FNext.Width := BtnWidth;
      FOwner.FNext.Height := FOwner.FHeader.Height;

      if not FOwner.FHeader.Flat then
      begin
        FOwner.FHeader.Left := FOwner.FHeader.Left + 1;
        FOwner.FHeader.Width := FOwner.FHeader.Width - 1;
      end;
    end;

    FOwner.FGrid.Height := FOwner.Height - FOwner.FPanel.Height - FOwner.FHeader.Height - FOwner.FFooter.Height;
    FOwner.FGrid.Top := FOwner.FPanel.Height + FOwner.FHeader.Height;
  end
  else
  begin
    if FOwner.FHeader.Visible then
    begin
      FOwner.FHeader.Top := FOwner.FPanel.Height;
      FOwner.FHeader.Width := FOwner.FPlannerHeader.Height;
      FOwner.FHeader.Height := FOwner.Height - FHeight;
    end
    else
    begin
      FOwner.FHeader.Top := FOwner.FPanel.Height;
      FOwner.FHeader.Width := 0;
    end;

    if FOwner.FFooter.Visible then
    begin
      FOwner.FFooter.Left := FOwner.Width - FOwner.Footer.Height;
      FOwner.FFooter.Top := FOwner.FPanel.Height;
      FOwner.FFooter.Height := FOwner.Height;
      FOwner.FFooter.Width := FOwner.Footer.Height;
    end
    else
    begin
      FOwner.FFooter.Height := 0;
    end;

    FOwner.FGrid.Height := FOwner.Height - FOwner.FPanel.Height;
    FOwner.FGrid.Width := FOwner.Width - FOwner.FHeader.Width - FOwner.FFooter.Width;
    FOwner.FGrid.Top := FOwner.FPanel.Height;
    FOwner.FGrid.Left := FOwner.FHeader.Width;

    FOwner.FPrev.Visible := False;
    FOwner.FNext.Visible := False;
  end;

end;

procedure TPlannerCaption.FontChanged(Sender: TObject);
begin
  UpdatePanel;
end;

procedure TPlannerCaption.SetAlignment(const Value: TAlignment);
begin
  if Alignment <> Value then
  begin
    FAlignment := Value;
    UpdatePanel;
  end;
end;

procedure TPlannerCaption.SetBackground(const Value: TColor);
begin
  if Background <> Value then
  begin
    FBackGround := Value;
    UpdatePanel;
  end;
end;

procedure TPlannerCaption.SetFont(const Value: TFont);
begin
  FFont.Assign(Value);
  FontChanged(Self);
end;

procedure TPlannerCaption.SetHeigth(const Value: Integer);
begin
  if FHeight <> Value then
  begin
    FHeight := Value;
    UpdatePanel;
  end;
end;

procedure TPlannerCaption.SetTitle(const Value: string);
begin
  if FTitle <> Value then
  begin
    FTitle := Value;
    FOwner.FPanel.Caption := FTitle;
    FOwner.FPanel.Repaint;
  end;
end;

procedure TPlannerCaption.SetVisible(const Value: Boolean);
begin
  if FVisible <> Value then
  begin
    FVisible := Value;
    UpdatePanel;
  end;
end;

procedure TPlannerCaption.SetBackgroundTo(const Value: TColor);
begin
  if BackgroundTo <> Value then
  begin
    FBackGroundTo := Value;
    UpdatePanel;
  end;
end;

procedure TPlannerCaption.SetBackgroundSteps(const Value: Integer);
begin
  if (BackgroundSteps <> Value) then
  begin
    FBackgroundSteps := Value;
    UpdatePanel;
  end;
end;

procedure TPlannerCaption.Assign(Source: TPersistent);
begin
  if Assigned(Source) then
  begin
    Title := (Source as TPlannerCaption).Title;
    Font.Assign((Source as TPlannerCaption).Font);
    Alignment := (Source as TPlannerCaption).Alignment;
    Background := (Source as TPlannerCaption).Background;
    BackgroundSteps := (Source as TPlannerCaption).BackgroundSteps;
    BackgroundTo := (Source as TPlannerCaption).BackgroundTo;
    Height := (Source as TPlannerCaption).Height;
    Visible := (Source as TPlannerCaption).Visible;
  end;
end;

procedure TPlannerCaption.SetGradientDirection(
  const Value: TPlannerGradientDirection);
begin
  if (Value <> FGradientDirection) then
  begin
    FGradientDirection := Value;
    UpdatePanel;
  end;
end;

{ TPlannerSideBar }

constructor TPlannerSideBar.Create(AOwner: TCustomPlanner);
begin
  inherited Create;
  FOwner := AOwner;
  FFont := TFont.Create;
  FFont.OnChange := FontChanged;
  FFont.Name := 'Arial'; // choose a truetype font by default
  FBackGround := clBtnFace;
  FBackGroundTo := clWhite;
  FOccupied := clBlue;
  FOccupiedTo := clNone;
  FOccupiedFontColor := clWhite;
  FVisible := True;
  FWidth := 40;
  FLineColor := clGray;
  FColOffset := 1;
  FRowOffset := 0;
  FFlat := True;
  FBorder := True;
  FRotateOnTop := True;
  FShowDayName := True;
  FSeparatorLineColor := clGray;
  FActiveColor := clNone;
  FActiveColorTo := clNone;
  FTimeIndicator := False;
  FTimeIndicatorColor := clRed;
  FHourFontRatio := 1.8;
end;

destructor TPlannerSideBar.Destroy;
begin
  FFont.Free;
  inherited Destroy;
end;

procedure TPlannerSideBar.FontChanged(Sender: TObject);
begin
  FOwner.FGrid.Repaint;
end;

procedure TPlannerSideBar.SetAlignment(const Value: TAlignment);
begin
  FAlignment := Value;
  FOwner.FGrid.Repaint;
end;

procedure TPlannerSideBar.SetBackground(const Value: TColor);
begin
  FBackGround := Value;
  FOwner.FGrid.Repaint;
end;

procedure TPlannerSideBar.SetBackgroundTo(const Value: TColor);
begin
  FBackGroundTo := Value;
  FOwner.FGrid.Repaint;
end;


procedure TPlannerSideBar.SetFont(const Value: TFont);
begin
  FFont.Assign(Value);
  FOwner.FGrid.Repaint;
end;

procedure TPlannerSideBar.SetVisible(const Value: Boolean);
begin
  if (FVisible <> Value) then
  begin
    FVisible := Value;
    UpdateGrid;
    FOwner.FGrid.UpdatePositions;
    Position := Position;
  end;
end;

procedure TPlannerSideBar.SetWidth(const Value: Integer);
begin
  FWidth := Value;
  if FVisible then
  begin
    UpdateGrid;
    FOwner.FGrid.UpdatePositions;
  end;
end;

procedure TPlannerSideBar.SetPosition(const Value: TSideBarPosition);
begin
  FPosition := Value;
  case FPosition of
    spLeft:
      begin
        if Visible then
          FOwner.FHeader.FOffset := 1
        else
          FOwner.FHeader.FOffset := 0;
        FColOffset := 1;
        FRowOffset := 0;
        FOwner.FGrid.ColCount := FOwner.Positions + 1;
        FOwner.FGrid.FixedCols := 1;
        FOwner.FGrid.FixedRows := 0;
        FOwner.FHeader.Orientation := hoHorizontal;
        FOwner.FFooter.Orientation := hoHorizontal;
        FOwner.UpdateCompletion;
      end;
    spLeftRight:
      begin
        if Visible then
          FOwner.FHeader.FOffset := 1
        else
          FOwner.FHeader.FOffset := 0;

        FColOffset := 1;
        FRowOffset := 0;

        if FVisible then
          FOwner.FGrid.ColCount := FOwner.Positions + 2
        else
          FOwner.FGrid.ColCount := FOwner.Positions + 1;

        FOwner.FGrid.FixedCols := 1;
        FOwner.FGrid.FixedRows := 0;
        FOwner.FHeader.Orientation := hoHorizontal;
        FOwner.FFooter.Orientation := hoHorizontal;
        FOwner.UpdateCompletion;
      end;
    spRight:
      begin
        FOwner.FHeader.FOffset := 0;
        FColOffset := 0;
        FRowOffset := 0;
        FOwner.FGrid.ColCount := FOwner.Positions + 1;
        FOwner.FGrid.FixedCols := 0;
        FOwner.FGrid.FixedRows := 0;
        FOwner.FHeader.Orientation := hoHorizontal;
        FOwner.FFooter.Orientation := hoHorizontal;
        FOwner.UpdateCompletion;
      end;
    spTop:
      begin

        FOwner.FGrid.RowCount := FOwner.Positions + 1;

        FColOffset := 0;
        FRowOffset := 1;
        FOwner.FHeader.FOffset := 1;
        FOwner.FGrid.FixedCols := 0;
        FOwner.FGrid.FixedRows := 1;
        FOwner.FHeader.Orientation := hoVertical;
        FOwner.FFooter.Orientation := hoVertical;
        FOwner.UpdateCompletion;
      end;
  end;

  UpdateGrid;
  ActiveColor := ActiveColor;
  FOwner.UpdateSizes;
  FOwner.FGrid.SelChanged;
  FOwner.FGrid.UpdatePositions;
  FOwner.FDisplay.UpdatePlanner;
end;

procedure TPlannerSideBar.UpdateGrid;
begin
  case FPosition of
    spLeft, spRight, spLeftRight:
      if not FVisible then
      begin
        if FColOffset = 1 then
        begin
          FOwner.FGrid.ColWidths[0] := 1;
          FOwner.FGrid.ColWidths[1] := FOwner.Width - 5 -
            FOwner.FGrid.GetHScrollSize;
        end
        else
        begin
          FOwner.FGrid.ColWidths[1] := 1;
          FOwner.FGrid.ColWidths[0] := FOwner.Width - 5 -
            FOwner.FGrid.GetHScrollSize;
        end;
      end
      else
      begin
        if FColOffset = 1 then
        begin
          FOwner.FGrid.ColWidths[1] := FOwner.Width - FWidth -
            FOwner.FGrid.GetHScrollSize;
          FOwner.FGrid.ColWidths[0] := FWidth;
        end
        else
        begin
          FOwner.FGrid.ColWidths[0] := FOwner.Width - FWidth -
            FOwner.FGrid.GetHScrollSize;
          FOwner.FGrid.ColWidths[1] := FWidth;
        end;
      end;
    spTop {,spBottom}:

      if not FVisible then
      begin
        if FRowOffset = 1 then
        begin
          FOwner.FGrid.RowHeights[0] := 1;
          FOwner.FGrid.RowHeights[1] := FOwner.Height - 5 -
            FOwner.FGrid.GetVScrollSize;
        end
        else
        begin
          FOwner.FGrid.RowHeights[1] := 1;
          FOwner.FGrid.RowHeights[0] := FOwner.Height - 5 -
            FOwner.FGrid.GetVScrollSize;
        end;
      end
      else
      begin
        if FRowOffset = 1 then
        begin
          FOwner.FGrid.RowHeights[0] := FWidth;
        end
        else
        begin
          FOwner.FGrid.RowHeights[0] := FOwner.Height - FWidth -
            FOwner.FGrid.GetVScrollSize;
          FOwner.FGrid.RowHeights[1] := FWidth;
        end;
      end;
  end;

end;

function TPlannerSideBar.GetOrientation: TSideBarOrientation;
begin
  if Position = spTop then
    Result := soHorizontal
  else
    Result := soVertical;
end;

procedure TPlannerSideBar.SetShowInPositionGap(const Value: Boolean);
begin
  if FShowInPositionGap <> Value then
  begin
    FShowInPositionGap := Value;
    if (csDesigning in FOwner.ComponentState) then
      Visible := not Value;
    FOwner.FGrid.Invalidate;
  end;
end;

procedure TPlannerSideBar.SetShowOccupied(const Value: Boolean);
begin
  if FShowOccupied <> Value then
  begin
    FShowOccupied := Value;
    FOwner.FGrid.Invalidate;
  end;
end;

procedure TPlannerSideBar.SetFlat(const Value: Boolean);
begin
  if FFlat <> Value then
  begin
    FFlat := Value;
    FOwner.FGrid.Invalidate;
  end;
end;

procedure TPlannerSideBar.SetOccupied(const Value: TColor);
begin
  if FOccupied <> Value then
  begin
    FOccupied := Value;
    FOwner.FGrid.Invalidate;
  end;
end;

procedure TPlannerSideBar.SetOccupiedTo(const Value: TColor);
begin
  if FOccupiedTo <> Value then
  begin
    FOccupiedTo := Value;
    FOwner.FGrid.Invalidate;
  end;
end;


procedure TPlannerSideBar.SetOccupiedFontColor(const Value: TColor);
begin
  if FOccupiedFontColor <> Value then
  begin
    FOccupiedFontColor := Value;
    FOwner.FGrid.Invalidate;
  end;
end;

procedure TPlannerSideBar.SetDateTimeFormat(const Value: string);
begin
  if FDateTimeFormat <> Value then
  begin
    FDateTimeFormat := Value;
    FOwner.FGrid.Invalidate;
  end;
end;

procedure TPlannerSideBar.SetBorder(const Value: Boolean);
begin
  if FBorder <> Value then
  begin
    FBorder := Value;
    FOwner.FGrid.Invalidate;
  end;
end;

procedure TPlannerSideBar.SetRotateOnTop(const Value: Boolean);
begin
  if FRotateOnTop <> Value then
  begin
    FRotateOnTop := Value;
    FOwner.FGrid.Invalidate;
  end;
end;

procedure TPlannerSideBar.SetShowDayName(const Value: Boolean);
begin
  if FShowDayName <> Value then
  begin
    FShowDayName := Value;
    FOwner.FGrid.Invalidate;
  end;
end;

procedure TPlannerSideBar.SetSeparatorLineColor(const Value: TColor);
begin
  if FSeparatorLineColor <> Value then
  begin
    FSeparatorLineColor := Value;
    FOwner.FGrid.Invalidate;
  end;
end;


procedure TPlannerSideBar.SetAMPMPos(const Value: TAMPMPos);
begin
  if FAMPMPos <> Value then
  begin
    FAMPMPos := Value;
    FOwner.FGrid.Invalidate;
  end;
end;

procedure TPlannerSideBar.SetActiveColor(const Value: TColor);
begin
  FActiveColor := Value;

  if Position = spTop then
  begin
    if FActiveColor <> clNone then
      FOwner.FGrid.ActiveCellShow := assRow
    else
      FOwner.FGrid.ActiveCellShow := assNone;
  end
  else
  begin
    if FActiveColor <> clNone then
      FOwner.FGrid.ActiveCellShow := assCol
    else
      FOwner.FGrid.ActiveCellShow := assNone;
  end;
end;

procedure TPlannerSideBar.SetActiveColorTo(const Value: TColor);
begin
  FActiveColorTo := Value;
  FOwner.FGrid.Invalidate;
end;

procedure TPlannerSideBar.Assign(Source: TPersistent);
begin

  if Assigned(Source) then
  begin
    ActiveColor := (Source as TPlannerSideBar).ActiveColor;
    Alignment := (Source as TPlannerSideBar).Alignment;
    AMPMPos := (Source as TPlannerSideBar).AMPMPos;
    Background := (Source as TPlannerSideBar).Background;
    BackgroundTo := (Source as TPlannerSideBar).BackgroundTo;
    Border := (Source as TPlannerSideBar).Border;
    DateTimeFormat := (Source as TPlannerSideBar).DateTimeFormat;
    Flat := (Source as TPlannerSideBar).Flat;
    Font.Assign((Source as TPlannerSideBar).Font);
    LineColor := (Source as TPlannerSideBar).LineColor;
    Occupied := (Source as TPlannerSideBar).Occupied;
    OccupiedFontColor := (Source as TPlannerSideBar).OccupiedFontColor;
    Position := (Source as TPlannerSideBar).Position;
    RotateOnTop := (Source as TPlannerSideBar).RotateOnTop;
    SeparatorLineColor := (Source as TPlannerSideBar).SeparatorLineColor;
    ShowInPositionGap := (Source as TPlannerSideBar).ShowInPositionGap;
    ShowOccupied := (Source as TPlannerSideBar).ShowOccupied;
    ShowDayName := (Source as TPlannerSideBar).ShowDayName;
    ShowOtherTimeZone := (Source as TPlannerSideBar).ShowOtherTimeZone;
    TimeIndicator := (Source as TPlannerSideBar).TimeIndicator;
    TimeIndicatorColor := (Source as TPlannerSideBar).TimeIndicatorColor;
    TimeZoneMinDelta := (Source as TPlannerSideBar).TimeZoneMinDelta;
    Visible := (Source as TPlannerSideBar).Visible;
    Width := (Source as TPlannerSideBar).Width;
  end;

end;

procedure TPlannerSideBar.SetLineColor(const Value: TColor);
begin
  if (FLineColor <> Value) then
  begin
    FLineColor := Value;
    FOwner.FGrid.Invalidate;
  end;
end;

procedure TPlannerSideBar.SetTimeIndicator(const Value: Boolean);
begin
  if (FTimeIndicator <> Value) then
  begin
    FTimeIndicator := Value;
    FOwner.FGrid.Invalidate;
  end;
end;

procedure TPlannerSideBar.SetTimeIndicatorColor(const Value: TColor);
begin
  if (FTimeIndicatorColor <> Value) then
  begin
    FTimeIndicatorColor := Value;
    FOwner.FGrid.Invalidate;
  end;
end;

procedure TPlannerSideBar.SetHourFontRatio(const Value: double);
begin
  if (FHourFontRatio <> Value) then
  begin
    FHourFontRatio := Value;
    FOwner.FGrid.Invalidate;
  end;
end;

procedure TPlannerSideBar.SetShowOtherTimeZone(const Value: boolean);
begin
  if (FShowOtherTimeZone <> Value) then
  begin
    FShowOtherTimeZone := Value;
    FOwner.FGrid.Invalidate;
  end;
end;

procedure TPlannerSideBar.SetTimeZoneOffset(const Value: Integer);
begin
  if (FTimeZoneOffset <> Value) then
  begin
    FTimeZoneOffset := Value;
    FOwner.FGrid.Invalidate;
  end;
end;

{ TPlannerDisplay }

constructor TPlannerDisplay.Create(AOwner: TCustomPlanner);
begin
  inherited Create;
  FOwner := AOwner;
  FDisplayStart := 0;
  FDisplayEnd := 47;
  FDisplayScale := 24;
  FOldScale := FDisplayScale;
  FDisplayUnit := 30;
  FDisplayOffset := 0;
  FActiveStart := 16;
  FActiveEnd := 40;
  InitPrecis;
  FColorActive := clWhite;
  FColorNonActive := $00DEDEDE;
  FColorCurrent := clYellow;
  FColorCurrentItem := clLime;
  FCurrentPosFrom := -1;
  FCurrentPosTo := -1;
  FUpdateUnit := False;
  FHourLineColor := clGray;
end;

destructor TPlannerDisplay.Destroy;
begin
  inherited;
end;

procedure TPlannerDisplay.SetDisplayEnd(const Value: Integer);
begin
  FDisplayEnd := Value;
  FDisplayEndPrecis := (FDisplayEnd + 1) * FDisplayUnit + FDisplayOffset;
  UpdatePlanner;
  if ScaleToFit then
    AutoScale;
end;

procedure TPlannerDisplay.SetDisplayStart(const Value: Integer);
begin
  FDisplayStart := Value;
  FDisplayStartPrecis := (FDisplayStart) * FDisplayUnit + FDisplayOffset;
  FUpdateUnit := True;
  UpdatePlanner;
  FUpdateUnit := False;
  if ScaleToFit then
    AutoScale;
end;

procedure TPlannerDisplay.SetDisplayScale(const Value: Integer);
var
  ItemIndex: Integer;
begin
  FDisplayScale := Value;
  { Update here all planneritems! }
  for ItemIndex := 0 to FOwner.Items.Count - 1 do
  begin
    (FOwner.Items.Items[ItemIndex] as TPlannerItem).UpdateWnd;
  end;

  UpdatePlanner;
end;

procedure TPlannerDisplay.SetDisplayUnit(const Value: Integer);
var
  TopRowPrecis: Integer;
begin
  if csLoading in FOwner.ComponentState then
  begin
    if Value <> 0 then
    begin
      FDisplayUnit := Value;
      UpdatePlanner;
    end;
    Exit;
  end;

  if FOwner.Sidebar.Position = spTop then
  begin
    if Value <> 0 then
      FDisplayUnit := Value
    else
      Exit;

    TopRowPrecis := FDisplayUnit * FOwner.FGrid.LeftCol + FDisplayOffset;

    { Rescale everything }
    //FActiveStart := FActiveStartPrecis div FDisplayUnit;
    //FActiveEnd := FActiveEndPrecis div FDisplayUnit;
    FDisplayStart := FDisplayStartPrecis div FDisplayUnit;
    FDisplayEnd := ((FDisplayEndPrecis - FDisplayOffset) div FDisplayUnit) - 1;
    FActiveStart := FActiveStartPrecis div FDisplayUnit - FDisplayStart;
    FActiveEnd := FActiveEndPrecis div FDisplayUnit - FDisplayStart;

    FOwner.FGrid.LeftCol := TopRowPrecis div FDisplayUnit;
  end
  else
  begin
    TopRowPrecis := FDisplayUnit * FOwner.FGrid.TopRow + FDisplayOffset;

    if Value <> 0 then
      FDisplayUnit := Value
    else
      Exit;

    { Rescale everything }
    //FActiveStart := FActiveStartPrecis div FDisplayUnit;
    //FActiveEnd := FActiveEndPrecis div FDisplayUnit;
    FDisplayStart := FDisplayStartPrecis div FDisplayUnit;
    FDisplayEnd := ((FDisplayEndPrecis - FDisplayOffset) div FDisplayUnit) - 1;
    FActiveStart  := FActiveStartPrecis div FDisplayUnit - FDisplayStart;
    FActiveEnd    := FActiveEndPrecis div FDisplayUnit - FDisplayStart;

    FOwner.FGrid.TopRow := TopRowPrecis div FDisplayUnit;
  end;

  FUpdateUnit := True;
  UpdatePlanner;
  FUpdateUnit := False;
end;

procedure TPlannerDisplay.SetDisplayOffset(const Value: Integer);
begin
  if Value > FDisplayUnit then
    Exit;

  if Value <> FDisplayOffset then
  begin
    FUpdateUnit := True;
    FDisplayOffset := Value;
    UpdatePlanner;
    FUpdateUnit := False;
  end;
end;

procedure TPlannerDisplay.UpdatePlanner;
var
  ItemIndex: Integer;
begin
  if FUpdateCount > 0 then
    Exit;

  with FOwner do
    if not (csLoading in ComponentState) then
    begin
      if not FUpdateUnit then
        for ItemIndex := 0 to Items.Count - 1 do
          (FOwner.Items.Items[ItemIndex] as TPlannerItem).DefOrganize;

      if Sidebar.Orientation = soVertical then
      begin
        if FGrid.RowCount <> 1 + FDisplayEnd - FDisplayStart then
          FGrid.RowCount := 1 + FDisplayEnd - FDisplayStart;
        FGrid.DefaultRowHeight := FDisplayScale;
      end
      else
      begin
        if FGrid.ColCount <> 1 + FDisplayEnd - FDisplayStart then
          FGrid.ColCount := 1 + FDisplayEnd - FDisplayStart;
        FGrid.DefaultColWidth := FDisplayScale;
      end;

      for ItemIndex := 0 to Items.Count - 1 do
        (FOwner.Items.Items[ItemIndex] as TPlannerItem).ReOrganize;

      FOwner.Items.SetConflicts;

      FGrid.Repaint;
    end;
end;

procedure TPlannerDisplay.SetActiveEnd(const Value: Integer);
begin
  FActiveEnd := Value;
  FActiveEndPrecis := (FActiveEnd + FOwner.Display.DisplayStart) *
    FOwner.Display.DisplayUnit + FOwner.Display.DisplayOffset;
  UpdatePlanner;
end;

procedure TPlannerDisplay.SetActiveStart(const Value: Integer);
begin
  FActiveStart := Value;
  FActiveStartPrecis := (FActiveStart + FOwner.Display.DisplayStart) *
    FOwner.Display.DisplayUnit + FOwner.Display.DisplayOffset;
  UpdatePlanner;
end;

procedure TPlannerDisplay.SetColorActive(const Value: TColor);
begin
  FColorActive := Value;
  UpdatePlanner;
end;

procedure TPlannerDisplay.SetColorNonActive(const Value: TColor);
begin
  FColorNonActive := Value;
  UpdatePlanner;
end;

procedure TPlannerDisplay.SetColorCurrent(const Value: TColor);
begin
  FColorCurrent := Value;
  UpdatePlanner;
end;

procedure TPlannerDisplay.SetShowCurrent(const Value: Boolean);
begin
  FShowCurrent := Value;
  UpdatePlanner;
  FOwner.UpdateTimer;
end;

procedure TPlannerDisplay.SetColorCurrentItem(const Value: TColor);
begin
  FColorCurrentItem := Value;
  UpdatePlanner;
end;

procedure TPlannerDisplay.SetShowCurrentItem(const Value: Boolean);
begin
  FShowCurrentItem := Value;
  UpdatePlanner;
  FOwner.UpdateTimer;
  if not Value then
    FOwner.Items.SetCurrent(-1);
end;

procedure TPlannerDisplay.SetScaleToFit(const Value: Boolean);
begin
  if FScaleToFit <> Value then
  begin
    FScaleToFit := Value;

    if FScaleToFit then
    begin
      FOldScale := DisplayScale;
      AutoScale;
    end
    else
      DisplayScale := FOldScale;
  end;
end;

procedure TPlannerDisplay.AutoScale;
var
  R: TRect;
  oldUU: Boolean;
begin
  R := FOwner.FGrid.ClientRect;

  oldUU := FUpdateUnit;
  FUpdateUnit := true;

  if FOwner.Sidebar.Position = spTop then
    DisplayScale := (R.Right - R.Left) div (DisplayEnd - DisplayStart + 1)
  else
    DisplayScale := (R.Bottom - R.Top) div (DisplayEnd - DisplayStart + 1);

  FUpdateUnit := oldUU;
end;


procedure TPlannerDisplay.InitPrecis;
begin
  // initialize precise values properly after load
  FDisplayStartPrecis := FDisplayStart * FDisplayUnit + FDisplayOffset;
  FDisplayEndPrecis := (FDisplayEnd + 1) * FDisplayUnit + FDisplayOffset;

  FActiveStartPrecis := (FActiveStart + FDisplayStart) *
    FDisplayUnit + FDisplayOffset;

  FActiveEndPrecis := (FActiveEnd + FDisplayStart) *
    FDisplayUnit + FDisplayOffset;
end;

procedure TPlannerDisplay.BeginUpdate;
begin
  inc(FUpdateCount);
end;

procedure TPlannerDisplay.EndUpdate;
begin
  if FUpdateCount > 0 then
  begin
    dec(FUpdateCount);
    if FUpdateCount = 0 then
      UpdatePlanner;
  end;
end;

procedure TPlannerDisplay.SetDisplayText(const Value: Integer);
begin
  if (FDisplayText <> Value) then
  begin
    FDisplayText := Value;
    FUpdateUnit := True;
    UpdatePlanner;
    FUpdateUnit := False;
  end;
end;

procedure TPlannerDisplay.Assign(Source: TPersistent);
begin
  if Assigned(Source) then
  begin
    ActiveStart := (Source as TPlannerDisplay).ActiveStart;
    ActiveEnd := (Source as TPlannerDisplay).ActiveEnd;
    CurrentPosFrom := (Source as TPlannerDisplay).CurrentPosFrom;
    CurrentPosTo := (Source as TPlannerDisplay).CurrentPosTo;    
    DisplayStart := (Source as TPlannerDisplay).DisplayStart;
    DisplayEnd := (Source as TPlannerDisplay).DisplayEnd;
    DisplayOffset := (Source as TPlannerDisplay).DisplayOffset;
    DisplayScale := (Source as TPlannerDisplay).DisplayScale;
    DisplayUnit := (Source as TPlannerDisplay).DisplayUnit;
    DisplayText := (Source as TPlannerDisplay).DisplayText;
    ColorActive := (Source as TPlannerDisplay).ColorActive;
    ColorNonActive := (Source as TPlannerDisplay).ColorNonActive;
    ColorCurrent := (Source as TPlannerDisplay).ColorCurrent;
    ColorCurrentItem := (Source as TPlannerDisplay).ColorCurrentItem;
    ScaleToFit := (Source as TPlannerDisplay).ScaleToFit;
    ShowCurrent := (Source as TPlannerDisplay).ShowCurrent;
    ShowCurrentItem := (Source as TPlannerDisplay).ShowCurrentItem;
  end;
end;

procedure TPlannerDisplay.SetCurrentPosFrom(const Value: Integer);
begin
  if (FCurrentPosFrom <> Value) then
  begin
    FCurrentPosFrom := Value;
    UpdatePlanner;
  end;
end;

procedure TPlannerDisplay.SetCurrentPosTo(const Value: Integer);
begin
  if (FCurrentPosTo <> Value) then
  begin
    FCurrentPosTo := Value;
    UpdatePlanner;
  end;
end;


procedure TPlannerDisplay.SetHourLineColor(const Value: TColor);
begin
  if (FHourLineColor <> Value) then
  begin
    FHourLineColor := Value;
    FOwner.Invalidate;
  end;  
end;

{ TPlannerItem }

constructor TPlannerItem.Create(Collection: TCollection);
begin
  inherited Create(Collection);
  FPlanner := (Collection as TPlannerItems).FOwner;
  FItemBegin := FPlanner.Display.ActiveStart;
  FItemEnd := FItemBegin + 1;
  FItemPos := 0;
  FColor := clWhite;
  FColorTo := clBtnFace;
  FBorderColor := clSilver;
  FTrackColor := clBlue;
  FTrackSelectColor := clBlue;
  FTrackLinkColor := clRed;
  FTrackVisible := True;
  FText := TStringList.Create;
  FFixedPos := False;
  FFixedSize := False;
  FReadOnly := False;
  FImageID := -1;
  FVisible := (csDesigning in FPlanner.ComponentState);
  FImageIndexList := TPlannerIntList.Create(Self);
  FImageIndexList.OnChange := ImageChange;
  FName := 'PlannerItem' + IntToStr(Index);
  FObject := nil;
  FPopupMenu := nil;
  FShape := psRect;
  FConflicts := 0;
  FConflictPos := 0;
  FShadow := True;
  FIsCurrent := False;
  if FPlanner.Sidebar.Orientation = soVertical then
    FAllowOverlap := True
  else
    FAllowOverlap := False;
  FFont := TFont.Create;
  FFont.Assign(FPlanner.Font);
  FFont.OnChange := FontChange;
  FText.OnChange := TextChange;
  FCaptionFont := TFont.Create;
  FCaptionFont.Assign(FPlanner.Font);
  FCaptionFont.OnChange := FontChange;
  FCaptionBkg := clWhite;
  FCaptionBkgTo := clNone;
  FCaptionAlign := taLeftJustify;
  FBrushStyle := bsSolid;
  FSelected := False;
  FSelectColor := clInfoBk;
  FSelectColorTo := clNone;
  FSelectFontColor := clRed;
  FShowSelection := True;
  FWordWrap := True;
  FUniformBkg := True;
  FAlarm := TPlannerAlarm.Create;
  FParentIndex := -1;
  FRelationShip := irParent;
  FCursor := crNone;
  FBarItems := TPlannerBarItemList.Create(Self);
  FPopupEdit := False;
  FVisible := true;
  FPreview := false;
  DefOrganize;

  if Assigned(FPlanner.DefaultItem) then
    Self.Assign(FPlanner.DefaultItem);
end;

destructor TPlannerItem.Destroy;
var
  plItems: TPlannerItems;
  i: Integer;
begin
  plItems := (Collection as TPlannerItems);

  if (RelationShip = irParent) and (ParentIndex <> -1) then
  begin
    i := 0;
    while i < plItems.Count do
      if (plItems.Items[i].ParentIndex = ParentIndex) and (plItems.Items[i].RelationShip = irChild) then
        plItems.Items[i].Free
      else
        inc(i);
  end;

  FImageIndexList.Free;
  FAlarm.Free;

  if Assigned(FPlanner.FGrid) then
  begin
    if FPlanner.FGrid.FMemo.Visible then
      FPlanner.FGrid.FMemo.Visible := False;
    if FPlanner.FRichEdit.FPlannerItem = Self then
      FPlanner.FRichEdit.Visible := False;
  end;

  if FOwnsItemObject and Assigned(FObject) then
  begin
    FObject.Free;
    FObject := nil;
  end;

  if Self = plItems.Selected then
  begin
    plItems.SelectNext;

    if not Assigned(plItems.Selected) then
    begin
      plItems.Selected := Self;
      plItems.SelectPrev;
    end;
  end;
  FFont.Free;
  FCaptionFont.Free;
  //FVisible := False;
  FText.Free;
  for i := FBarItems.Count - 1 downto 0 do
    FBarItems[ i].Free;
  FBarItems.Free;

  inherited;
  plItems.SetConflicts;
end;

{$IFNDEF VER90}
function TPlannerItem.GetDisplayName: string;
begin
  Result := FName;
end;
{$ENDIF}

procedure TPlannerItem.SetAlignment(const Value: TAlignment);
begin
  FAlignment := Value;
  Repaint;
end;

procedure TPlannerItem.SetAllowOverlap(const Value: Boolean);
begin
  if FAllowOverlap <> Value then
  begin
    FAllowOverlap := Value;
    Repaint;
    Changed;
  end;
end;

procedure TPlannerItem.SetCaptionType(const Value: TCaptionType);
begin
  if (FCaptionType <> Value) then
  begin
    FCaptionType := Value;
    Repaint;
    Changed;    
  end;
end;

procedure TPlannerItem.SetCaptionText(const Value: string);
begin
  FCaptionText := Value;
  try
    Repaint;
  finally
    Changed;
  end;
end;

procedure TPlannerItem.ImageChange(Sender: TObject);
begin
  Repaint;
  Changed;
end;

procedure TPlannerItem.FontChange(Sender: TObject);
begin
  Repaint;
  Changed;
end;

procedure TPlannerItem.TextChange(Sender: TObject);
begin
  Repaint;
  Changed;
end;

procedure TPlannerItem.SetVisible(const Value: Boolean);
begin
  if FVisible <> Value then
  begin
    FVisible := Value;
    Repaint;
  end;
end;

function TPlannerItem.GetVisible: Boolean;
begin
  Result := FVisible and not FInHeader;
end;

procedure TPlannerItem.ScrollInView;
begin
  with (Collection as TPlannerItems).FOwner do
  begin
    if SideBar.Position <> spTop then
    begin
      if FGrid.VisibleRowCount < FGrid.RowCount then
        GridTopRow := FItemBegin;

      if (FGrid.VisibleColCount < FGrid.ColCount) and (PositionWidth > 0) then
      begin
        if SideBar.Visible and (SideBar.Position = spLeft) then
          GridLeftCol := FItemPos + 1
        else
          GridLeftCol := FItemPos
      end
    end
    else
    begin
      if FGrid.VisibleColCount < FGrid.ColCount then
        GridLeftCol := FItemBegin;

      if (FGrid.VisibleRowCount < FGrid.RowCount) and (PositionWidth > 0) then
        GridTopRow := Min(FGrid.RowCount - FGrid.VisibleRowCount, FItemPos + 1);
    end;
  end;
end;

procedure TPlannerItem.PopupEdit;
var
  PlannerInstance: TCustomPlanner;
begin
  if Assigned(Editor) then
  begin
    PlannerInstance := FPlanner;
    PlannerInstance.FEditMode := True;

    if Assigned(PlannerInstance.OnItemStartEdit) then
      PlannerInstance.OnItemStartEdit(PlannerInstance, Self);

    Editor.Edit(PlannerInstance,Self);

    if Assigned(PlannerInstance.OnItemEndEdit) then
      PlannerInstance.OnItemEndEdit(PlannerInstance, Self);

    PlannerInstance.FEditMode := False;
  end;
end;

procedure TPlannerItem.Edit;
var
  GridRect: TRect;
  ColOffset, RowOffset: Integer;
begin
  if (FPlanner.Sidebar.Orientation = soVertical) then
  begin
    ColOffset := FPlanner.FSidebar.FColOffset;
    GridRect := FPlanner.FGrid.CellRectEx(ItemPos + ColOffset, ItemBegin);
    FPlanner.FGrid.StartEditCol(GridRect, Self, -1, -1);
  end
  else
  begin
    RowOffset := FPlanner.FSidebar.FRowOffset;
    GridRect := FPlanner.FGrid.CellRectEx(ItemBegin, ItemPos + RowOffset);
    FPlanner.FGrid.StartEditRow(GridRect, Self, -1, -1);
  end;
end;


procedure TPlannerItem.SetFocus(const Value: Boolean);
begin
  if (csDestroying in FPlanner.ComponentState) then
    Exit;

  if (FFocus <> Value) then
  begin
    if Value then
    begin
      if Assigned(FPlanner.FOnItemEnter) then
        FPlanner.FOnItemEnter(FPlanner, Self);
    end
    else
    begin
      if Assigned(FPlanner.FOnItemExit) then
        FPlanner.FOnItemExit(FPlanner, Self);
    end;

    FFocus := Value;
    Self.Repaint;
  end;
end;

procedure TPlannerItem.SetFont(const Value: TFont);
begin
  FFont.Assign(Value);
  Self.Repaint;
  Changed;
end;

procedure TPlannerItem.SetBackground(const Value: Boolean);
begin
  if (FBackGround <> Value) then
  begin
    FBackGround := Value;
    FReadOnly := True;
    FFixedPos := True;
    FFixedSize := True;
    FAllowOverlap := False;
    Self.Repaint;
    Changed;     
  end;
end;

procedure TPlannerItem.SetImageID(const Value: Integer);
begin
  FImageID := Value;
  Self.Repaint;
  Changed;
end;

procedure TPlannerItem.SetImagePosition(const Value: TItemImagePosition);
begin
  FImagePosition := Value;
  Self.Repaint;
  Changed;
end;

procedure TPlannerItem.SetBorderColor(const Value: TColor);
begin
  FBorderColor := Value;
  Self.Repaint;
  Changed;
end;


procedure TPlannerItem.SetColor(const Value: TColor);
begin
  FColor := Value;
  Self.Repaint;
  Changed;
end;

procedure TPlannerItem.SetColorTo(const Value: TColor);
begin
  FColorTo := Value;
  Self.Repaint;
  Changed;
end;

procedure TPlannerItem.SetTrackColor(const Value: TColor);
begin
  FTrackColor := Value;
  Self.Repaint;
  Changed;
end;

procedure TPlannerItem.SetTrackSelectColor(const Value: TColor);
begin
  FTrackSelectColor := Value;
  Self.Repaint;
  Changed;
end;

procedure TPlannerItem.SetLayer(const Value: Integer);
begin
  FLayer := Value;
  Self.Repaint;
end;

procedure TPlannerItem.SetItemEnd(const Value: Integer);
var
  Difference: Integer;
  OldVisible: Boolean;

begin
  LinkUpdating := true;

  if Assigned(FLinkedItem) and not FPlanner.FLinkUpdate and not FLinkedItem.LinkUpdating then
  begin
    Difference := Value + EndOffset - FItemEnd;

//    FPlanner.FLinkUpdate := True;

    FPlanner.Items.ResetUpdate;

    case LinkType of
      ltLinkFull, ltLinkEndEnd:
        begin
          if (FLinkedItem.ItemEnd + Difference < 0) or
            (FLinkedItem.ItemEnd + Difference > FPlanner.FDisplay.FDisplayEnd - FPlanner.Display.FDisplayStart + 1) or
            FPlanner.FLinkCancel then
          begin
            FLinkedItem.FEndOffset := FLinkedItem.ItemEnd + Difference - FPlanner.FDisplay.FDisplayEnd - 1;
            FLinkedItem.FItemEnd := FPlanner.FDisplay.FDisplayEnd - FPlanner.Display.FDisplayStart + 1;
            FPlanner.FLinkUpdate := false;

            FLinkedItem.FItemEndPrecis := (FLinkedItem.FItemEnd + FLinkedItem.FEndOffset + FPlanner.Display.DisplayStart) *
                                             FPlanner.Display.DisplayUnit + FPlanner.Display.DisplayOffset;
          end
          else
          begin
            if (FLinkedItem.LinkedItem = Self) then
              FPlanner.FLinkUpdate := True;

            FLinkedItem.ItemEnd := FLinkedItem.ItemEnd + Difference;
            FLinkedItem.EndOffset := 0;
            FLinkedItem.FItemEndPrecis := (FLinkedItem.FItemEnd + FLinkedItem.FEndOffset + FPlanner.Display.DisplayStart) *
                                             FPlanner.Display.DisplayUnit + FPlanner.Display.DisplayOffset;

            if (FLinkedItem.LinkedItem = Self) then
              FPlanner.FLinkUpdate := False;
          end;
        end;
      ltLinkEndBegin:
        begin
          if (FLinkedItem.ItemEnd + Difference < 0) or
            (FLinkedItem.ItemEnd + Difference > FPlanner.FDisplay.FDisplayEnd - FPlanner.Display.FDisplayStart) or
            (FLinkedItem.ItemBegin + Difference < 0) or
            (FLinkedItem.ItemBegin + Difference > FPlanner.FDisplay.FDisplayEnd - FPlanner.Display.FDisplayStart + 1) or
            FPlanner.FLinkCancel then
          begin
            FPlanner.FLinkUpdate := False;
            Exit;
          end;

          if FLinkedItem.LinkedItem = Self then
            FPlanner.FLinkUpdate := True;

          FLinkedItem.ItemEnd := FLinkedItem.ItemEnd + Difference;
          FLinkedItem.ItemBegin := FLinkedItem.ItemBegin + Difference;

          if FLinkedItem.LinkedItem = Self then
            FPlanner.FLinkUpdate := False;
        end;
    end;
//    FPlanner.FLinkUpdate := False;
  end;

  LinkUpdating := false;

  OldVisible := Visible;
  Visible := False;

  FItemEnd := Value;

  if not FPlanner.FLoading then
  begin
    FItemEndPrecis := (FItemEnd + FEndOffset + FPlanner.Display.DisplayStart) *
      FPlanner.Display.DisplayUnit + FPlanner.Display.DisplayOffset;
  end;

  Visible := OldVisible;
  (Collection as TPlannerItems).SetConflicts;
end;

procedure TPlannerItem.SetItemBegin(const Value: Integer);
var
  Difference: Integer;
begin
  LinkUpdating := true;
  FPlanner.FLinkCancel := False;

  if Assigned(FLinkedItem) and not FPlanner.FLinkUpdate and not FLinkedItem.LinkUpdating then
  begin
    // FPlanner.FLinkUpdate := True;
    FPlanner.Items.ResetUpdate;

    Difference := Value - FItemBegin - BeginOffset;

    case LinkType of
      ltLinkFull, ltLinkBeginBegin:
        begin
          if (FLinkedItem.ItemBegin + Difference < 0) or
            (FLinkedItem.ItemBegin + Difference > FPlanner.FDisplay.FDisplayEnd - FPlanner.FDisplay.FDisplayStart + 1) then
          begin
            FLinkedItem.FBeginOffset := -Difference;
            FLinkedItem.FItemBegin := 0;
            FLinkedItem.ItemBeginPrecis := (FLinkedItem.FItemBegin + FPlanner.Display.DisplayStart) *
              FPlanner.Display.DisplayUnit + FPlanner.Display.DisplayOffset;

            FPlanner.FLinkUpdate := False;
            //FPlanner.FLinkCancel := True;
          end
          else
          begin
            if FLinkedItem.LinkedItem = Self then
              FPlanner.FLinkUpdate := True;

            FLinkedItem.ItemBegin := FLinkedItem.ItemBegin + Difference;
            FLinkedItem.FBeginOffset := 0;

            if FLinkedItem.LinkedItem = Self then
              FPlanner.FLinkUpdate := False;
          end;
        end;
      ltLinkBeginEnd:
        begin
          if (FLinkedItem.ItemEnd + Difference < 0) or
            (FLinkedItem.ItemEnd + Difference > FPlanner.FDisplay.FDisplayEnd - FPlanner.FDisplay.FDisplayStart) or
            (FLinkedItem.ItemBegin + Difference < 0) or
            (FLinkedItem.ItemBegin + Difference > FPlanner.FDisplay.FDisplayEnd - FPlanner.FDisplay.FDisplayStart + 1) then
          begin
            FPlanner.FLinkUpdate := False;
            FPlanner.FLinkCancel := True;
            Exit;
          end;

          if FLinkedItem.LinkedItem = Self then
            FPlanner.FLinkUpdate := True;

          FLinkedItem.ItemBegin := FLinkedItem.ItemBegin + Difference;
          FLinkedItem.ItemEnd := FLinkedItem.ItemEnd + Difference;

          if FLinkedItem.LinkedItem = Self then
            FPlanner.FLinkUpdate := False;
        end;
    end;
   // FPlanner.FLinkUpdate := False;
  end;

  LinkUpdating := false;  

  Visible := False;
  FItemFullBegin := Value;

  if (Value >= 0) then
    FItemBegin := Value
  else
    FItemBegin := 0;

  if not FPlanner.FLoading then
  begin
    FItemBeginPrecis := (FItemBegin + FPlanner.Display.DisplayStart) *
      FPlanner.Display.DisplayUnit + FPlanner.Display.DisplayOffset;
  end;

  Visible := True;
  (Collection as TPlannerItems).SetConflicts;
end;

function TPlannerItem.GetVisibleSpan: Integer;
var
  cb,ce: Integer;
begin
  cb := ItemBegin;
  ce := ItemEnd;
  if FPlanner.SideBar.Position <> spTop then
  begin
    if cb < FPlanner.FGrid.TopRow then
      cb := FPlanner.FGrid.TopRow;
    if ce > FPlanner.FGrid.VisibleRowCount + FPlanner.FGrid.TopRow then
      ce := FPlanner.FGrid.VisibleRowCount + FPlanner.FGrid.TopRow + 1;
  end
  else
  begin
    if cb < FPlanner.FGrid.LeftCol then
      cb := FPlanner.FGrid.LeftCol;
    if ce >= FPlanner.FGrid.VisibleColCount + FPlanner.FGrid.LeftCol then
      ce := FPlanner.FGrid.VisibleColCount + FPlanner.FGrid.LeftCol;
  end;

  Result := ce - cb;
end;

function TPlannerItem.GetItemRect: TRect;
var
  gr1,gr2: TRect;
begin
  if (FPlanner.Sidebar.Orientation = soVertical) then
  begin
    gr1 := FPlanner.FGrid.CellRectEx(ItemPos + FPlanner.FSideBar.FColOffset, ItemBegin);
    gr2 := FPlanner.FGrid.CellRectEx(ItemPos + FPlanner.FSideBar.FColOffset, ItemEnd - 1);

    CalcConflictRect(gr1, FPlanner.FGrid.ColWidthEx(ItemPos),
      FPlanner.FGrid.RowHeightEx(FPlanner.FSideBar.FRowOffset), True);

    gr1.Bottom := gr2.Bottom;
  end
  else
  begin
    gr1 := FPlanner.FGrid.CellRectEx(ItemBegin, ItemPos + FPlanner.FSideBar.FRowOffset);
    gr2 := FPlanner.FGrid.CellRectEx(ItemEnd-1, ItemPos + FPlanner.FSideBar.FRowOffset);

    CalcConflictRect(gr1, FPlanner.FGrid.RowHeightEx(ItemPos),
      FPlanner.FGrid.RowHeightEx(FPlanner.FSideBar.FRowOffset), True);

    gr1.Right := gr2.Right;
  end;
  Result := gr1;
end;

function TPlannerItem.GetGridRect:TRect;
var
  nBegin, nEnd: Integer;
begin
  nBegin := Self.ItemBegin;
  nEnd := Self.ItemEnd;

  if FPlanner.Sidebar.Orientation = soVertical then
  begin
    Result := Rect(Self.ItemPos + FPlanner.FSidebar.FColOffset,
                   nBegin,
                   Self.ItemPos + FPlanner.FSidebar.FColOffset,
                   nEnd - 1);

  end
  else
  begin
    Result := Rect(nBegin,
                   Self.ItemPos + FPlanner.FSidebar.FRowOffset,
                   nEnd - 1,
                   Self.ItemPos + FPlanner.FSidebar.FRowOffset);
  end;
end;

procedure TPlannerItem.Repaint;
var
  ItemPositionIndex: Integer;
  nBegin, nEnd, nPos: Integer;
begin
  if FPlanner.Items.FUpdateCount > 0 then
    Exit;

  { Repaint the complete conflictzone }
  if InHeader then
  begin
    FPlanner.FHeader.Invalidate;
  end
  else
  begin
    FRepainted := False;
    nBegin := Self.ItemBegin;
    nEnd := Self.ItemEnd;
    nPos := Self.ItemPos;
    FPlanner.Items.NumConflicts(nBegin, nEnd, nPos);

    for ItemPositionIndex := nBegin to nEnd - 1 do
    begin
      if FPlanner.Sidebar.Orientation = soVertical then
      {$IFNDEF TMSDOTNET}
        FPlanner.FGrid.InvalidateCell(
      {$ENDIF}
      {$IFDEF TMSDOTNET}
        FPlanner.FGrid.InvalidateCellP(
      {$ENDIF}
          Self.ItemPos + FPlanner.FSidebar.FColOffset, ItemPositionIndex)
      else
      {$IFNDEF TMSDOTNET}
        FPlanner.FGrid.InvalidateCell(
      {$ENDIF}
      {$IFDEF TMSDOTNET}
        FPlanner.FGrid.InvalidateCellP(
      {$ENDIF}
          ItemPositionIndex, Self.ItemPos + FPlanner.FSidebar.FRowOffset)
    end;

    if (FPlanner.Sidebar.Orientation = soVertical) and
       FPlanner.Sidebar.Visible and
       FPlanner.Sidebar.ShowOccupied then
      for ItemPositionIndex := nBegin to nEnd do
      begin
      {$IFNDEF TMSDOTNET}
        FPlanner.FGrid.InvalidateCell(0, ItemPositionIndex);
      {$ENDIF}
      {$IFDEF TMSDOTNET}
        FPlanner.FGrid.InvalidateCellP(0, ItemPositionIndex);
      {$ENDIF}
      end;

    if (FPlanner.Sidebar.Orientation = soHorizontal) and
       FPlanner.Sidebar.Visible and
       FPlanner.Sidebar.ShowOccupied then
      for ItemPositionIndex := nBegin to nEnd do
      begin
      {$IFNDEF TMSDOTNET}
        FPlanner.FGrid.InvalidateCell(ItemPositionIndex, 0);
      {$ENDIF}
      {$IFDEF TMSDOTNET}
        FPlanner.FGrid.InvalidateCellP(ItemPositionIndex, 0);
      {$ENDIF}
      end;

  end;
end;

procedure TPlannerItem.DefOrganize;
begin
  FItemBeginPrecis := (FItemBegin + FPlanner.Display.DisplayStart) *
    FPlanner.Display.DisplayUnit + FPlanner.Display.DisplayOffset;
  FItemEndPrecis := (FItemEnd + FPlanner.Display.DisplayStart) *
    FPlanner.Display.DisplayUnit + FPlanner.Display.DisplayOffset;
end;

procedure TPlannerItem.ReOrganize;
begin
  FItemBegin := ((FItemBeginPrecis - FPlanner.Display.DisplayOffset) div FPlanner.Display.DisplayUnit) -
    FPlanner.Display.DisplayStart;

  if Frac((FItemEndPrecis - FPlanner.Display.DisplayOffset) / FPlanner.Display.DisplayUnit) > 0 then
    FItemEnd := 1 + ((FItemEndPrecis - FPlanner.Display.DisplayOffset) div FPlanner.Display.DisplayUnit) -
      FPlanner.Display.DisplayStart
  else
    FItemEnd := ((FItemEndPrecis - FPlanner.Display.DisplayOffset) div FPlanner.Display.DisplayUnit) -
      FPlanner.Display.DisplayStart;

      (*
  if FPlanner.IsDBAware then
  begin

    if FItemEnd > FPlanner.Display.DisplayEnd - FPlanner.Display.DisplayStart + 1  then
    begin
      FItemEnd := FPlanner.Display.DisplayEnd - FPlanner.Display.DisplayStart + 1;
    end;

    if FItemBegin < FPlanner.Display.DisplayStart then
    begin
      FItemBegin := FPlanner.Display.DisplayStart;
    end;
  end;
      *)
  UpdateWnd;
end;

procedure TPlannerItem.SetText(const Value: TStringList);
begin
  if Assigned(Value) then
    FText.Assign(Value);
  Repaint;
end;

procedure TPlannerItem.UpdateWnd;
begin
  Self.Repaint;
end;

procedure TPlannerItem.CalcConflictRect(var Rect: TRect; Width, Height: Integer;
  Position: Boolean);
begin
  if FConflicts > 1 then
  begin
    if Position then
    begin
      Width := Width div FConflicts;
      Rect.Left := Rect.Left + Width * FConflictPos;
      Rect.Right := Rect.Left + Width - FPlanner.ItemGap;
    end
    else
    begin
      Height := Height div FConflicts;
      Rect.Top := Rect.Top + Height * FConflictPos;
      Rect.Bottom := Rect.Top + Height - FPlanner.ItemGap;
    end;
  end
  else
  begin
    if Position then
      Rect.Right := Rect.Right - FPlanner.ItemGap
    else
      Rect.Bottom := Rect.Bottom - FPlanner.ItemGap;
  end;
end;

procedure TPlannerItem.SetItemPos(const Value: Integer);
var
  Difference: Integer;
begin
  LinkUpdating := true;
  if FItemPos <> Value then
  begin
    if Assigned(FLinkedItem) and not FPlanner.FLinkUpdate and not FLinkedItem.LinkUpdating then
    begin
      //FPlanner.FLinkUpdate := True;
      FPlanner.Items.ResetUpdate;
      Difference := Value - FItemPos;
      FLinkedItem.ItemPos := FLinkedItem.ItemPos + Difference;
      //FPlanner.FLinkUpdate := False;
    end;

    Visible := False;
    Repaint;

    FItemPos := Value;
    Visible := True;
    FPlanner.Items.SetConflicts;
    Repaint;
  end;
  LinkUpdating := false;  
end;

procedure TPlannerItem.Assign(Source: TPersistent);
begin
  if Source is TPlannerItem then
  begin
    ItemPos := TPlannerItem(Source).ItemPos;
    ItemBegin := TPlannerItem(Source).ItemBegin;
    ItemEnd := TPlannerItem(Source).ItemEnd;
    Color := TPlannerItem(Source).Color;
    ColorTo := TPlannerItem(Source).ColorTo;
    BorderColor := TPlannerItem(Source).BorderColor;
    Completion := TPlannerItem(Source).Completion;
    CompletionDisplay := TPlannerItem(Source).CompletionDisplay;
    Cursor := TPlannerItem(Source).Cursor;
    Text.Text := TPlannerItem(Source).Text.Text;
    ReadOnly := TPlannerItem(Source).ReadOnly;
    FixedSize := TPlannerItem(Source).FixedSize;
    FixedPos := TPlannerItem(Source).FixedPos;
    FixedPosition := TPlannerItem(Source).FixedPosition;
    FixedTime := TPlannerItem(Source).FixedTime;
    CaptionType := TPlannerItem(Source).CaptionType;
    ImageID := TPlannerItem(Source).ImageID;
    ImagePosition := TPlannerItem(Source).ImagePosition;
    Alignment := TPlannerItem(Source).Alignment;
    Name := TPlannerItem(Source).Name;
    Visible := TPlannerItem(Source).Visible;
    Tag := TPlannerItem(Source).Tag;
    TrackColor := TPlannerItem(Source).TrackColor;
    TrackLinkColor :=  TPlannerItem(Source).TrackLinkColor;
    TrackSelectColor := TPlannerItem(Source).TrackSelectColor;    
    TrackVisible := TPlannerItem(Source).TrackVisible;
    CaptionText := TPlannerItem(Source).CaptionText;
    EditMask := TPlannerItem(Source).EditMask;
    InplaceEdit := TPlannerItem(Source).InplaceEdit;
    Layer := TPlannerItem(Source).Layer;
    Font.Assign(TPlannerItem(Source).Font);
    Background := TPlannerItem(Source).Background;
    AllowOverlap := TPlannerItem(Source).AllowOverlap;
    Selected := TPlannerItem(Source).Selected;
    SelectColor := TPlannerItem(Source).SelectColor;
    SelectColorTo := TPlannerItem(Source).SelectColorTo;    
    CaptionBkg := TPlannerItem(Source).CaptionBkg;
    CaptionBkgTo := TPlannerItem(Source).CaptionBkgTo;
    CaptionAlign := TPlannerItem(Source).CaptionAlign;
    CaptionFont.Assign(TPlannerItem(Source).CaptionFont);
    CaptionType := TPlannerItem(Source).CaptionType;
    BrushStyle := TPlannerItem(Source).BrushStyle;
    InHeader := TPlannerItem(Source).InHeader;
    OwnsItemObject := TPlannerItem(Source).OwnsItemObject;
    ItemObject := TPlannerItem(Source).ItemObject;
    ShowDeleteButton := TPlannerItem(Source).ShowDeleteButton;
    Selected := TPlannerItem(Source).Selected;
    SelectColor := TPlannerItem(Source).SelectColor;
    SelectFontColor := TPlannerItem(Source).SelectFontColor;
    Shape := TPlannerItem(Source).Shape;
    PopupMenu := TPlannerItem(Source).PopupMenu;
    ShowSelection := TPlannerItem(Source).ShowSelection;
    DBTag := TPlannerItem(Source).DBTag;
    WordWrap := TPlannerItem(Source).WordWrap;
    Attachement := TPlannerItem(Source).Attachement;
    URL := TPlannerItem(Source).URL;
    UniformBkg := TPlannerItem(Source).UniformBkg;
    Alarm.Assign(TPlannerItem(Source).Alarm);
    Shadow := TPlannerItem(Source).Shadow;
    Editor := TPlannerItem(Source).Editor;
    DrawTool := TPlannerItem(Source).DrawTool;
    Hint := TPlannerItem(Source).Hint;
    ShowLinks := TPlannerItem(Source).ShowLinks;
    Recurrency := TPlannerItem(Source).Recurrency;
    Recurrent := TPlannerItem(Source).Recurrent;
    RecurrentOrigStart := TPlannerItem(Source).RecurrentOrigStart;
    RecurrentOrigEnd := TPlannerItem(Source).RecurrentOrigEnd;
    {$IFNDEF TMSDOTNET}
    WideCaption := TPlannerItem(Source).WideCaption;
    WideText := TPlannerItem(Source).WideText;
    Unicode := TPlannerItem(Source).Unicode;
    {$ENDIF}
  end;
end;

procedure TPlannerItem.AssignEx(Source: TPersistent);
begin
  if Source is TPlannerItem then
  begin
    Color := TPlannerItem(Source).Color;
    ColorTo := TPlannerItem(Source).ColorTo;
    BorderColor := TPlannerItem(Source).BorderColor;
    Cursor := TPlannerItem(Source).Cursor;
    Text.Text := TPlannerItem(Source).Text.Text;
    ReadOnly := TPlannerItem(Source).ReadOnly;
    FixedSize := TPlannerItem(Source).FixedSize;
    FixedPos := TPlannerItem(Source).FixedPos;
    FixedPosition := TPlannerItem(Source).FixedPosition;
    FixedTime := TPlannerItem(Source).FixedTime;    
    CaptionType := TPlannerItem(Source).CaptionType;
    ImageID := TPlannerItem(Source).ImageID;
    Alignment := TPlannerItem(Source).Alignment;
    Name := TPlannerItem(Source).Name;
    Visible := TPlannerItem(Source).Visible;
    Tag := TPlannerItem(Source).Tag;
    TrackColor := TPlannerItem(Source).TrackColor;
    TrackLinkColor := TPlannerItem(Source).TrackLinkColor;    
    TrackSelectColor := TPlannerItem(Source).TrackSelectColor;    
    TrackVisible := TPlannerItem(Source).TrackVisible;
    CaptionText := TPlannerItem(Source).CaptionText;
    EditMask := TPlannerItem(Source).EditMask;
    InplaceEdit := TPlannerItem(Source).InplaceEdit;
    Layer := TPlannerItem(Source).Layer;
    Font.Assign(TPlannerItem(Source).Font);
    Background := TPlannerItem(Source).Background;
    AllowOverlap := TPlannerItem(Source).AllowOverlap;
    ShowDeleteButton := TPlannerItem(Source).ShowDeleteButton;
    Selected := TPlannerItem(Source).Selected;
    SelectColor := TPlannerItem(Source).SelectColor;
    SelectColorTo := TPlannerItem(Source).SelectColorTo;
    CaptionBkg := TPlannerItem(Source).CaptionBkg;
    CaptionBkgTo := TPlannerItem(Source).CaptionBkgTo;
    CaptionAlign := TPlannerItem(Source).CaptionAlign;
    CaptionFont.Assign(TPlannerItem(Source).CaptionFont);
    CaptionType := TPlannerItem(Source).CaptionType;
    BrushStyle := TPlannerItem(Source).BrushStyle;
    InHeader := TPlannerItem(Source).InHeader;
    OwnsItemObject := TPlannerItem(Source).OwnsItemObject;
    ItemObject := TPlannerItem(Source).ItemObject;
    Selected := TPlannerItem(Source).Selected;
    SelectColor := TPlannerItem(Source).SelectColor;
    Shape := TPlannerItem(Source).Shape;
    PopupMenu := TPlannerItem(Source).PopupMenu;
    ShowSelection := TPlannerItem(Source).ShowSelection;
    DBTag := TPlannerItem(Source).DBTag;
    WordWrap := TPlannerItem(Source).WordWrap;
    Attachement := TPlannerItem(Source).Attachement;
    URL := TPlannerItem(Source).URL;
    UniformBkg := TPlannerItem(Source).UniformBkg;
    ShowLinks := TPlannerItem(Source).ShowLinks;
    Alarm.Assign(TPlannerItem(Source).Alarm);
    DrawTool := TPlannerItem(Source).DrawTool;
    Editor := TPlannerItem(Source).Editor;
    Hint := TPlannerItem(Source).Hint;    
    {$IFNDEF TMSDOTNET}
    WideCaption := TPlannerItem(Source).WideCaption;
    WideText := TPlannerItem(Source).WideText;
    Unicode := TPlannerItem(Source).Unicode;
    {$ENDIF}
  end;
end;


procedure TPlannerItem.SetItemEndTime(const Value: TDateTime);
var
  Hour, Minute, Second, Second100: Word;
  Da, Mo, Ye: Word;
  dte,dts: TDateTime;
  nv, delta, Res: Integer;

begin
  FItemEndTime := Value;
  with TPlannerItems(Collection).FOwner do
  begin
    case Mode.PlannerType of
      plDay:
        begin
          delta := 0;
          BeginOffset := 0;
          EndOffset := 0;

         // if FItemRealStartTime <> 0 then
          begin
            if Int(Value) > Int(FItemRealStartTime) then
              delta := 24 * 60;

            if Int(Value) < Int(FItemRealStartTime) then
              delta := - 24 * 60;
          end;

          DecodeTime(Value, Hour, Minute, Second, Second100);

          Minute := Minute + (Hour * 60) - FDisplay.DisplayOffset;

          // start 1.6.0.2 fix to display items on day crossing views
          //if (Minute div Display.DisplayUnit < Display.DisplayStart) and (Display.DisplayStart > 0) then
          //  Minute := Minute + 1440;
          // end 1.6.0.2 fix to display items on day crossing views

          Minute := Minute + Delta;

          FItemEndPrecis := Minute; // moved after delta

          if FItemEndPrecis < FItemBeginPrecis then
          begin
            FItemEndPrecis := FItemEndPrecis + 60 * 24;
            Minute := Minute + 60 * 24;
          end;

          if Minute > Display.FDisplayEndPrecis then
          begin
            if FRoundTime then
              EndOffset := Round((Minute - Display.FDisplayEndPrecis) / Display.DisplayUnit)
            else
              EndOffset := (Minute - Display.FDisplayEndPrecis) div Display.DisplayUnit;

            ItemEnd := Display.DisplayEnd - Display.DisplayStart + 1;
          end
          else
            if FItemBeginPrecis < Display.FDisplayStartPrecis then
            begin
              // hide item if falling outside displayed timespan
              if (Minute < Display.FDisplayStartPrecis) then
              begin
                //ItemBegin := 0;
                //ItemEnd := 0;
                InHeader := true;
              end
              else
              begin
                {
                if FRoundTime then
                  BeginOffset := Round((Display.FDisplayStartPrecis - (Minute - Display.DisplayStart * Display.DisplayUnit)) /
                    Display.DisplayUnit)
                else
                  BeginOffset := (Display.FDisplayStartPrecis - (Minute - Display.DisplayStart * Display.DisplayUnit)) div
                    Display.DisplayUnit;
                }
                if FRoundTime then
                  BeginOffset := Round((Display.FDisplayStartPrecis - FItemBeginPrecis) / Display.DisplayUnit)
                else
                  BeginOffset := (Display.FDisplayStartPrecis - FItemBeginPrecis) div Display.DisplayUnit;

                ItemBegin := 0;

                if FRoundTime then
                  ItemEnd := Round(Minute / Display.DisplayUnit)  - Display.DisplayStart
                else
                begin
                  //if (FItemEndPrecis mod Display.DisplayUnit = 0) then // avoid issue with item with timespan < 60sec
                  //  ItemEnd := ((Minute) div Display.DisplayUnit) + 1 - Display.DisplayStart
                  //else
                    ItemEnd := ((Minute - 1) div Display.DisplayUnit) + 1 - Display.DisplayStart;
                end;
              end;
            end
            else
            begin
              if FRoundTime then
                ItemEnd := Round(Minute / Display.DisplayUnit)  - Display.DisplayStart
              else
              begin
                //if (FItemEndPrecis mod Display.DisplayUnit = 0) then // avoid issue with item with timespan < 60sec
                //  ItemEnd := ((Minute) div Display.DisplayUnit) + 1 - Display.DisplayStart
                //else
                  ItemEnd := ((Minute - 1) div Display.DisplayUnit) + 1 - Display.DisplayStart;
              end;    
            end;

          if FRoundTime then
            if ItemEnd = ItemBegin then
              ItemEnd := ItemEnd + 1;

          // removed in 1.6.0.2
          FItemEndPrecis := Minute; // moved after delta

          {$IFDEF TMSDEBUG}
          outputdebugstring(pchar(formatdatetime('hh:nn dd/mm/yyyy',value)));
          {$ENDIF}

          FItemRealEndTime := Value;
        end;
      plTimeLine:
        begin
          DecodeTime(Value, Hour, Minute, Second, Second100);
          Minute := Minute + Hour * 60;
          FItemEndPrecis := Minute;

          delta := Minute mod Display.DisplayUnit;
          
          // start 1.6.0.2 fix to display items on day crossing views
          // if ((Minute div Display.DisplayUnit) - Display.DisplayStart) < 0 then
          //  Minute := Minute + 1440;
          // end 1.6.0.2 fix to display items on day crossing views

          //DInc := Round(Int(Value) - Int(Mode.TimeLineStart)) * (MININDAY div Display.DisplayUnit);

          // outputdebugstring(pchar('day diff: '+inttostr(Dinc)));

          Minute := (Minute div Display.DisplayUnit) - Display.DisplayStart;

          Res := AbsTimeToCell(Value);

          if Res > Display.DisplayEnd + 1 then
          begin
            EndOffset := Res - Display.DisplayEnd - 1;
            ItemEnd := Display.DisplayEnd + 1;
          end
          else
          begin
            ItemEnd := Res;

            if (delta > 0) and (Mode.TimeLineNVUEnd = 0) and (Mode.TimeLineNVUBegin = 0) then
              ItemEnd := Res + 1;
            EndOffset := 0;
          end;

          {
          if Minute + DInc > Display.FDisplayEnd then
          begin
            EndOffset := Minute + DInc - Display.DisplayEnd - 1;
            ItemEnd := Display.DisplayEnd - Display.DisplayStart + 1;
          end
          else
            ItemEnd := Minute + DInc;
          }
          FItemRealEndTime := Value;
        end;

      plDayPeriod,plMonth,plWeek:
        begin
          dte := FPlanner.Mode.PeriodEndDate;
          dts := FPlanner.Mode.PeriodStartDate;

          FItemRealEndTime := Value;
          EndOffset := 0;

          if Trunc(Value) > dte then
            EndOffset := Trunc(Value - dte);

          nv := Trunc(Value - FPlanner.Mode.PeriodStartDate) + 1;

          // Clip(nv, FPlanner.Display.DisplayStart, FPlanner.Display.DisplayEnd - FPlanner.Display.DisplayStart);

          if (nv < 0) then // Because of the 0 we can't use the Clip function
            nv := FPlanner.Display.DisplayStart;

          if (nv > FPlanner.Display.DisplayEnd - FPlanner.Display.DisplayStart) then
            nv := FPlanner.Display.DisplayEnd - FPlanner.Display.DisplayStart + 1;

          if Value < dts then
          begin
            Self.Visible := False;
          end
          else
            ItemEnd := nv;

          {$IFDEF TMSCODESITE}
          CodeSite.SendInteger('endtime',ItemEnd);
          CodeSite.SendInteger('set endoffset',EndOffset);
          {$ENDIF}

          {$IFDEF TMSDEBUG}
          outputdebugstring(pchar(formatdatetime('et : hh:nn dd/mm/yyyy',value)));
          {$ENDIF}

          FItemRealEndTime := Value;
        end;
      plHalfDayPeriod:
        begin
          dte := FPlanner.Mode.PeriodEndDate + 1;

          EndOffset := 0;

          {$IFDEF TMSCODESITE}
          codesite.SendFloat('diff:',Value - FPlanner.Mode.PeriodStartDate);
          {$ENDIF}

          nv := Trunc(2 * (Value - FPlanner.Mode.PeriodStartDate));

          //if (Frac(Value) >= 0) and (Frac(Value) <> 0.5) then
          //  inc(nv,2);

          if ((Frac(Value) > 0) and (Frac(Value) <> 0.5)) or (nv = ItemBegin) then
            inc(nv,1);

          if (nv < 0) then   // Because of the 0 we can't use the Clip function
            nv := FPlanner.Display.DisplayStart;

          if nv > FPlanner.Display.DisplayEnd - FPlanner.Display.DisplayStart then
            nv := FPlanner.Display.DisplayEnd - FPlanner.Display.DisplayStart + 1;

          ItemEnd := nv;

          if Value > int(dte) then
            EndOffset := Round(2 * (Value - dte));

          {$IFDEF TMSCODESITE}
          CodeSite.SendInteger('starttime',ItemBegin);
          CodeSite.SendInteger('set beginoffset',BeginOffset);
          {$ENDIF}

          FItemRealEndTime := Value;
        end;
      plMultiMonth:
        begin
          DecodeDate(Value,Ye,Mo,Da);

          while (FPlanner.Mode.Year < Ye) do
          begin
            Mo := Mo + 12;
            dec(Ye);
          end;

          ItemPos := Limit(Mo - FPlanner.Mode.Month, 0, Positions - 1);


          if (Mo > FPlanner.Mode.Month + Positions - 1) then
            ItemEnd := PlanUtil.DaysInMonth(ye, FPlanner.Mode.Month + Positions - 1)
          else
            ItemEnd := Da;

        end;
      plCustom, plCustomList:
        begin
          ItemEnd := FPlanner.TimeToIndex(Value);
        end;
    end;
  end;

end;

procedure TPlannerItem.SetItemStartTime(const Value: TDateTime);
var
  Hour, Minute, Second, Second100: Word;
  Da, Mo, Ye: Word;
  dts,dte: TDateTime;
  Res: Integer;

begin
  FItemStartTime := Value;
  with TPlannerItems(Collection).FOwner do
  begin
    case Mode.PlannerType of
      plDay:
        begin
          DecodeTime(Value, Hour, Minute, Second, Second100);
          Minute := Minute + (Hour * 60) - FDisplay.DisplayOffset;

          // start 1.6.0.2 fix to display items on day crossing views
          if (((Minute div Display.DisplayUnit) - Display.DisplayStart) < 0) and (Display.DisplayStart > 0) and (Display.DisplayEnd * Display.DisplayUnit > 1440) then
            Minute := Minute + 1440;
          // end 1.6.0.2 fix to display items on day crossing views

          if FRoundTime then
            ItemBegin := Round(Minute / Display.DisplayUnit) - Display.DisplayStart
          else
            ItemBegin := (Minute div Display.DisplayUnit) - Display.DisplayStart;

          FItemBeginPrecis := Minute;
          FItemRealStartTime := Value;
        end;
      plTimeLine:
        begin
          DecodeTime(Value, Hour, Minute, Second, Second100);
          Minute := Minute + Hour * 60;

          FItemBeginPrecis := Minute;

          Minute := (Minute div Display.DisplayUnit) - Display.DisplayStart;

          Res := AbsTimeToCell(Value);

          if Res < 0 then
          begin
            ItemBegin := 0;
            BeginOffset := -Res;
          end
          else
          begin
            ItemBegin := Res;
            BeginOffset := 0;
          end;

          FItemRealStartTime := Value;
        end;

      plDayPeriod,plMonth,plWeek:
        begin
          dts := FPlanner.Mode.PeriodStartDate;
          dte := FPlanner.Mode.PeriodEndDate;

          BeginOffset := 0;

          if (Trunc(Value) > dts) and (Trunc(Value) <= dte) then
            ItemBegin := Trunc(Value - dts)
          else
          begin
          {$IFDEF TMSDOTNET}
            BeginOffset := Trunc(dts- TDateTime(Trunc(Value)));
          {$ENDIF}
          {$IFNDEF TMSDOTNET}
            BeginOffset := Trunc(dts- Trunc(Value));
          {$ENDIF}

            ItemBegin := 0;
            if Trunc(Value) > dte then
              Self.Visible := False;
          end;

          {$IFDEF TMSCODESITE}
          CodeSite.SendInteger('starttime',ItemBegin);
          CodeSite.SendInteger('set beginoffset',BeginOffset);
          {$ENDIF}

          FItemRealStartTime := Value;
        end;
      plHalfDayPeriod:
        begin
          dts := FPlanner.Mode.PeriodStartDate;
          dte := FPlanner.Mode.PeriodEndDate;

          BeginOffset := 0;

          {$IFDEF TMSCODESITE}
          codesite.SendDateTime('dts',dts);
          codesite.SendDateTime('dte',dte);
          {$ENDIF}

          if (Value >= dts) and (Value < Int(dte) + 1) then
          begin
            ItemBegin := Trunc( 2 * (Value - dts) )
           end
          else
          begin
            BeginOffset := Round(2 * (dts - Value));
            {$IFDEF TMSCODESITE}
            codesite.SendInteger('beginoffset=',beginoffset);
            {$ENDIF}
            ItemBegin := 0;
          end;
          FItemRealStartTime := Value;
        end;
      plMultiMonth:
        begin
          DecodeDate(Value,Ye,Mo,Da);
          while (FPlanner.Mode.Year < Ye) do
          begin
            Mo := Mo + 12;
            dec(Ye);
          end;

          ItemPos := Limit(Mo - FPlanner.Mode.Month, 0, Positions - 1);
          ItemBegin := Da - 1;
        end;
      plCustom, plCustomList:
        begin
          ItemBegin := TimeToIndex(Value);
        end;
    end;
  end;
end;

function TPlannerItem.GetItemEndTime: TDateTime;
var
  res,ID: Integer;
  //DInc: Integer;
  da,mo,ye: word;
  dt: TDateTime;
begin
  with TPlannerItems(Collection).FOwner do
  begin
    Result := 0;
    case Mode.PlannerType of
      plDay:
        begin
          res := FItemEndPrecis;
          ID := 0;
          while (res >= MinInDay) do
          begin
            res := res - MinInDay;
            inc(ID);
          end;
          Result := EncodeTime(res div 60, res mod 60, 0, 0);

          {
          if EndOffset > 0 then
          begin
            res := EndOffset * Display.DisplayUnit;
            Result := Result + EncodeTime(res div 60,res mod 60,0 ,0);
          end;
          }

          Result := Result + PosToDay(ItemPos) + ID;
        end;

      plTimeLine:
        begin
          CellToAbsTime(ItemEnd + EndOffset, Result, dt);

          {
          // res := FItemEndPrecis + (EndOffset - 1) * Display.DisplayUnit
          res := FItemEndPrecis;

          while (res >= MININDAY) do
          begin
            res := res - MININDAY;
          end;

          Result := EncodeTime(res div 60, res mod 60, 0, 0);

          DInc := (ItemEnd + EndOffset) div ((MININDAY div Display.DisplayUnit));

          Result := Result + Int(FPlanner.Mode.TimeLineStart + DInc);
          }
        end;

      plMonth,plWeek:
        begin
          Result := Mode.StartOfMonth - 1 + EndOffset + ItemEnd + Frac(FItemRealEndTime);
        end;
      plDayPeriod:
        begin
          Result := FPlanner.Mode.PeriodStartDate -1 + EndOffset + ItemEnd + Frac(FItemRealEndTime);
        end;
      plHalfDayPeriod:
        begin
          Result := FPlanner.Mode.PeriodStartDate + (ItemEnd + EndOffset) / 2;
        end;
      plMultiMonth:
        begin
          ye := FPlanner.Mode.Year;
          mo := FPlanner.Mode.Month + ItemPos;
          da := ItemEnd;

          while (mo > 12) do
          begin
            mo := mo - 12;
            ye := ye + 1;
          end;

          if da > PlanUtil.DaysInMonth(mo,ye) then
          begin
            inc(mo);
            if mo > 12 then
            begin
              mo := 1;
              inc(ye);
            end;
            da := 1;
          end;

          Result := EncodeDate(ye,mo,da) + Frac(FItemRealEndTime);
        end;
      plCustom, plCustomList:
        begin
          Result := IndexToTime(ItemEnd);
        end;
    end;
  end;

end;

function TPlannerItem.GetItemStartTime: TDateTime;
var
  res,ID,y: Integer;
  //DInc: Integer;
  dt: TDateTime;
begin
  with TPlannerItems(Collection).FOwner do
  begin
    Result := 0;
    case Mode.PlannerType of
      plDay:
        begin
          res := FItemBeginPrecis;
          ID := 0;

          while (res >= 24 * 60) do
          begin
            res := res - 60 * 24;
            inc(ID);
          end;

          Result := EncodeTime(res div 60, res mod 60, 0, 0);

          if BeginOffset > 0 then
          begin
            res := BeginOffset * Display.DisplayUnit;
            Result := Result - EncodeTime(res div 60,res mod 60,0 ,0);
          end;

          Result := Result + PosToDay(ItemPos) + ID;
        end;
      plTimeLine:
        begin
          CellToAbsTime(ItemBegin - BeginOffset, Result, dt);
                    {
          res := FItemBeginPrecis - BeginOffset * Display.DisplayUnit;

          while (res >= MININDAY) do
            res := res - MININDAY;

          while (res < 0) do
            res := res + MININDAY;

          Result := EncodeTime(res div 60, res mod 60, 0, 0);
          DInc := (ItemBegin) div ((MININDAY div Display.DisplayUnit));
          if BeginOffset > 0 then
            DInc := DInc - 1 - (BeginOffset div (MININDAY div Display.DisplayUnit));

          Result := Result + Int(FPlanner.Mode.TimeLineStart + DInc);
          }
        end;
      plMonth,plWeek:
        begin
          Result := Mode.StartOfMonth - BeginOffset + ItemBegin + Frac(FItemRealStartTime);
        end;
      plDayPeriod:
        begin
          Result := FPlanner.Mode.PeriodStartDate - BeginOffset + ItemBegin + Frac(FItemRealStartTime);
        end;
      plHalfDayPeriod:
        begin
          Result := FPlanner.Mode.PeriodStartDate + (ItemBegin - BeginOffset) / 2;
        end;
      plMultiMonth:
        begin
          res := FPlanner.Mode.Month + ItemPos;
          y := FPlanner.Mode.Year;
          while (res > 12) do
          begin
            res := res - 12;
            inc(y);
          end;
          Result := EncodeDate(y,res,ItemBegin + 1) + Frac(FItemRealStartTime);
        end;
      plCustom, plCustomList:
        begin
          Result := FPlanner.IndexToTime(ItemBegin);
        end;
    end;
    FItemStartTime := Result;
  end;
end;

function TPlannerItem.GetItemSpanTimeStr: string;
begin
  Result := GetCaptionTimeString;
end;

function TPlannerItem.GetItemEndTimeStr: string;
var
  dt1,dd: TDateTime;
begin
  with TPlannerItems(Collection).FOwner do
  begin
    Result := '';
    case Mode.PlannerType of
      plDay:
        begin
          Result := PlanTimeToStr(FItemEndPrecis);
        end;
      plTimeLine:
        begin
          FPlanner.CellToAbsTime(ItemEnd + EndOffset,dt1,dd);
          Result := TimeToStr(dt1) + ' ' + DateToStr(dt1)
        end;
      plMonth,plWeek:
        begin
          Result := DateToStr(Mode.StartOfMonth - 1 + ItemEnd + EndOffset);
        end;
      plDayPeriod:
        begin
          Result := DateToStr(Mode.PeriodStartDate -1 + ItemEnd + EndOffset);
        end;
      plHalfDayPeriod:
        begin
          Result := DateToStr(Mode.PeriodStartDate + (ItemEnd - 1 + EndOffset) / 2);
        end;
      plMultiMonth:
        begin
          if not RealTime then
            Result := DateToStr(GetItemEndTime)
          else
            Result := DateToStr(GetItemRealEndTime);
        end;
      plCustom, plCustomList:
        begin
          Result := FormatDateTime(Mode.DateTimeFormat, ItemEndTime);
        end;

    end;
  end;
end;

function TPlannerItem.GetItemStartTimeStr: string;
var
  dt1,dd: TDateTime;
begin
  with TPlannerItems(Collection).FOwner do
  begin
    Result := '';
    case Mode.PlannerType of
      plDay:
        begin
          Result := PlanTimeToStr(FItemBeginPrecis -
            BeginOffset * FPlanner.FDisplay.FDisplayUnit + MININDAY);
        end;
      plTimeLine:
        begin
          //Result := PlanTimeToStr(FItemBeginPrecis -
          //  BeginOffset * FPlanner.FDisplay.FDisplayUnit + MININDAY);

          FPlanner.CellToAbsTime(ItemBegin - BeginOffset,dt1,dd);
          Result := TimeToStr(dt1) + ' ' + DateToStr(dt1)
        end;
      plDayPeriod,plMonth,plWeek:
        begin
          Result := DateToStr(Mode.PeriodStartDate + ItemBegin - BeginOffset);
        end;
      plHalfDayPeriod:
        begin
          Result := DateToStr(Mode.PeriodStartDate + (ItemBegin - BeginOffset) / 2);
        end;
      plMultiMonth:
        begin
          if not RealTime then
            Result := DateToStr(GetItemStartTime)
          else
            Result := DateToStr(GetItemRealStartTime);
        end;
      plCustom, plCustomList:
        begin
          Result := FormatDateTime(Mode.DateTimeFormat, ItemStartTime);
        end;
    end;
  end;
end;

procedure TPlannerItem.SetIsCurrent(const Value: Boolean);
begin
  if FIsCurrent <> Value then
  begin
    FIsCurrent := Value;

    if FIsCurrent and Assigned(FPlanner.FOnItemActivate) then
      FPlanner.FOnItemActivate(FPlanner, Self);

    if not FIsCurrent and Assigned(FPlanner.FOnItemDeActivate) then
      FPlanner.FOnItemDeActivate(FPlanner, Self);

    Repaint;
  end;
end;

procedure TPlannerItem.SetItemRealEndTime(const Value: TDateTime);
begin
  FItemRealEndTime := Value;
end;

procedure TPlannerItem.SetItemRealStartTime(const Value: TDateTime);
begin
  FItemRealStartTime := Value;
end;

procedure TPlannerItem.SetBrusStyle(const Value: TBrushStyle);
begin
  if (FBrushStyle <> Value) then
  begin
    FBrushStyle := Value;
    Repaint;
  end;
end;

procedure TPlannerItem.SetCaptionAlign(const Value: TAlignment);
begin
  if (FCaptionAlign <> Value) then
  begin
    FCaptionAlign := Value;
    Repaint;
  end;
end;

procedure TPlannerItem.SetCaptionBkg(const Value: TColor);
begin
  if (FCaptionBkg <> Value) then
  begin
    FCaptionBkg := Value;
    Self.Repaint;
  end;
end;

procedure TPlannerItem.SetCaptionFont(const Value: TFont);
begin
  FCaptionFont.Assign(Value);
  Self.Repaint;
end;

{$WARNINGS OFF}
function TPlannerItem.GetCaptionTimeString: string;
var
  s1, s2: string;
  DateTime: TDateTime;
  dt1,dt2,dd: TDateTime;
//  DOffs1,DOffs2: Integer;
  ho,mi,se,se100: word;
begin
  case FPlanner.FMode.FPlannerType of
    plDay:
      begin
        s1 := FPlanner.PlanTimeToStr(FItemBeginPrecis -
          BeginOffset * FPlanner.FDisplay.FDisplayUnit + 60 * 24);
        s2 := FPlanner.PlanTimeToStr(FItemEndPrecis {+
          EndOffset * FPlanner.FDisplay.FDisplayUnit});

        if RealTime or InHeader then
        begin
          DecodeTime(ItemRealStartTime,ho,mi,se,se100);

          mi := mi + ho * 60;
          s1 := FPlanner.PlanTimeToStr(mi);

          // s1 := TimeToStr(ItemRealStartTime);

          DecodeTime(ItemRealEndTime,ho,mi,se,se100);
          mi := mi + ho * 60;
          s2 := FPlanner.PlanTimeToStr(mi);

          // s2 := TimeToStr(ItemRealEndTime);

          if (Int(ItemRealStartTime) <> Int(ItemRealEndTime)) and
             (Int(ItemRealStartTime) <> 0) and (Int(ItemRealEndTime) <> 0) then
            Result := s1 + ' ' + DateToStr(ItemRealStartTime) + ' - ' + s2 + ' ' + DateToStr(ItemRealEndTime)
          else
            Result := s1 + ' - ' + s2;

          {$IFDEF TMSDEBUG}
          outputdebugstring(pchar(datetostr(itemrealendtime)));
          {$ENDIF}
        end
        else
        begin
          if (Int(ItemStartTime) <> Int(ItemEndTime)) and
             (Int(ItemStartTime) <> 0) and (Int(ItemEndTime) <> 0) then
            Result := s1 + ' ' + DateToStr(ItemStartTime) + ' - ' + s2 + ' ' + DateToStr(ItemEndTime)
          else
            Result := s1 + ' - ' + s2;
        end;
      end;
    plTimeLine:
      begin
        s1 := FPlanner.PlanTimeToStr(FItemBeginPrecis -
          BeginOffset * FPlanner.FDisplay.FDisplayUnit + MININDAY);

        s2 := FPlanner.PlanTimeToStr(FItemEndPrecis);

        {
        s2 := FPlanner.PlanTimeToStr(FItemEndPrecis +
          EndOffset * FPlanner.FDisplay.FDisplayUnit);
        }
        (*
        if RealTime or InHeader then
        begin
          s1 := TimeToStr(ItemRealStartTime);
          s2 := TimeToStr(ItemRealEndTime);

          if (Int(ItemRealStartTime) <> Int(ItemRealEndTime)) and
             (Int(ItemRealStartTime) <> 0) and (Int(ItemRealEndTime) <> 0) then
            Result := s1 + ' ' + DateToStr(ItemRealStartTime) + ' - ' + s2 + ' ' + DateToStr(ItemRealEndTime)
          else
            Result := s1 + ' - ' + s2;

          {$IFDEF TMSDEBUG}
          outputdebugstring(pchar(datetostr(itemrealendtime)));
          {$ENDIF}
        end
        else
        *)
        begin
          FPlanner.CellToAbsTime(ItemBegin - BeginOffset,dt1,dd);
          FPlanner.CellToAbsTime(ItemEnd -1 + EndOffset,dt2,dd);

          if int(dt1) <> int(dt2) then
            Result := TimeToStr(dt1) + ' ' + DateToStr(dt1) + ' - ' + TimeToStr(dd) + ' ' + DateToStr(dd)
          else
            Result := TimeToStr(dt1) + ' - ' + TimeToStr(dd)+ ' ' + DateToStr(dt2);

          {
          DOffs1 := (((ItemBegin) * FPlanner.Display.DisplayUnit) div MININDAY);
          DOffs2 := (((ItemEnd + EndOffset) * FPlanner.Display.DisplayUnit) div MININDAY);

          if BeginOffset > 0 then
            DOffs1 := DOffs1 - 1 - ((BeginOffset * FPlanner.Display.DisplayUnit) div MININDAY);

          if (Doffs1 <> Doffs2) then
            Result := s1 + ' ' + DateToStr(Planner.Mode.TimeLineStart + DOffs1) + ' - ' + s2 + ' ' + DateToStr(Planner.Mode.TimeLineStart + DOffs2)
          else
            Result := s1 + ' - ' + s2 + ' ' + DateToStr(Planner.Mode.TimeLineStart + DOffs1);
          }
        end;
      end;
    plWeek:
      begin
        s2 := '';
        s1 := FPlanner.GetDayName(ItemBegin - FPlanner.FMode.WeekStart);

        DateTime := FPlanner.Mode.PeriodStartDate + FItemBegin;
        DateTime := DateTime - BeginOffset;

        if FPlanner.Mode.FDateTimeFormat <> '' then
          s1 := s1 + ' ' + FormatDateTime(FPlanner.Mode.FDateTimeFormat,DateTime + Frac(ItemRealStartTime));

        DateTime := FPlanner.Mode.PeriodStartDate + FItemEnd;
        DateTime := DateTime + EndOffset - 1;

        if FItemEnd > FItemBegin + 1 then
        begin
          s2 := FPlanner.GetDayName(FItemEnd - 1 - FPlanner.FMode.WeekStart);
          if FPlanner.Mode.FDateTimeFormat <> '' then
            s2 := s2 + ' ' + FormatDateTime(FPlanner.Mode.FDateTimeFormat,DateTime + Frac(ItemRealEndTime));
        end;

        if s2 <> '' then
          s1 := s1 + ' - ' + s2;
        Result := s1;
      end;

    plDayPeriod,plMonth:
      begin
        with FPlanner.FMode do
        begin
          //v1.2
          DateTime := FPlanner.Mode.PeriodStartDate + FItemBegin;
          DateTime := DateTime - BeginOffset;

          s1 := FormatDateTime(FDateTimeFormat, DateTime + Frac(ItemRealStartTime));

          DateTime := FPlanner.Mode.PeriodStartDate + FItemEnd;
          DateTime := DateTime + EndOffset - 1;

          if FItemEnd > FItemBegin + 1 then
            s2 := '';
          if FItemEnd > FItemBegin + 1 then
            s2 := FormatDateTime(FDateTimeFormat, DateTime+ Frac(ItemRealEndTime));
          if (s2 <> '') then
            s1 := s1 + ' - ' + s2;
          Result := s1;
        end;
      end;
    plHalfDayPeriod:
      begin
        with FPlanner.FMode do
        begin
          DateTime := Trunc(FPlanner.Mode.PeriodStartDate + (FItemBegin - BeginOffset) / 2);

          s1 := FormatDateTime(FDateTimeFormat, DateTime);

          if Odd(FItemBegin - BeginOffset) then
            s1 := s1 + ' PM'
          else
            s1 := s1 + ' AM';

          DateTime := Trunc((FPlanner.Mode.PeriodStartDate + (FItemEnd - 1 + EndOffset) / 2));

          s2 := FormatDateTime(FDateTimeFormat, DateTime);
          if Odd(FItemEnd + EndOffset) then
            s2 := s2 + ' AM'
          else
            s2 := s2 + ' PM';

          Result := s1 + ' - ' + s2;
        end;
      end;
    plMultiMonth:
      begin
        Result := ItemStartTimeStr +  ' - ' + ItemEndTimeStr;
      end;
    plCustom, plCustomList:
      begin
        Result := ItemStartTimeStr +  ' - ' + ItemEndTimeStr;
      end;
  end;
end;
{$WARNINGS ON}

{$IFNDEF TMSDOTNET}
function TPlannerItem.GetWideCaptionString: widestring;
begin
  if RelationShip = irChild then
  begin
    Result := ParentItem.GetCaptionString;
    Exit;
  end;

  if CaptionType in [ctTime,ctTimeText] then
  begin
    Result := GetCaptionTimeString;
    if CaptionType = ctTimeText then
      Result := Result + ' ' + WideCaption;
  end
  else
    Result := WideCaption;
end;
{$ENDIF}

function TPlannerItem.GetCaptionString: string;
begin
  if RelationShip = irChild then
  begin
    Result := ParentItem.GetCaptionString;
    Exit;
  end;

  if CaptionType in [ctTime,ctTimeText] then
  begin
    Result := GetCaptionTimeString;
    if CaptionType = ctTimeText then
      Result := Result + ' ' + CaptionText;
  end
  else
    Result := CaptionText;
end;

function TPlannerItem.GetCaptionHeight: Integer;
begin
  Result := FCaptionHeight;
end;

procedure TPlannerItem.SetSelectColor(const Value: TColor);
begin
  if FSelectColor <> Value then
  begin
    FSelectColor := Value;
    Self.Repaint;
  end;
end;

procedure TPlannerItem.SetLinkSelect(const Value: Boolean);
begin
  if FLinkSelect <> Value then
  begin
    FLinkSelect := Value;
    Self.Repaint;
  end;
end;

procedure TPlannerItem.SetSelectColorTo(const Value: TColor);
begin
  if FSelectColorTo <> Value then
  begin
    FSelectColorTo := Value;
    Self.Repaint;
  end;
end;


procedure TPlannerItem.SetSelectFontColor(const Value: TColor);
begin
  if FSelectFontColor <> Value then
  begin
    FSelectFontColor := Value;
    Self.Repaint;
  end;
end;


procedure TPlannerItem.SetSelected(const Value: Boolean);
begin
  if FSelected <> Value then
  begin
    if not Value and not (csDestroying in FPlanner.ComponentState) then
      FPlanner.ItemUnSelected(Self);
    FSelected := Value;
    Self.Repaint;

    if ShowLinks and FSelected then
      (Collection as TPlannerItems).UpdateLinks(Self);
      
    if ShowLinks and not FSelected then
      (Collection as TPlannerItems).ClearLinks;
  end;
end;

procedure TPlannerItem.SetShadow(const Value: Boolean);
begin
  if FShadow <> Value then
  begin
    FShadow := Value;
    Self.Repaint;
  end;
end;

procedure TPlannerItem.SetObject(const Value: TObject);
begin
  if FObject = Value then
    Exit;
  if FOwnsItemObject and Assigned(FObject) then
    FObject.Free;
  FObject := Value;
end;

procedure TPlannerItem.SetInHeader(const Value: Boolean);
begin
  if FInHeader <> Value then
  begin
    FInHeader := Value;
    FVisible := not FInHeader;

    Self.Repaint;
    FPlanner.FHeader.Invalidate;
    FPlanner.FGrid.Invalidate;

    if FPlanner.FPlannerHeader.AutoSize then
      FPlanner.AutoSizeHeader;

    FPlanner.Items.SetConflicts;
    FPlanner.FGrid.Invalidate;
  end;
end;

procedure TPlannerItem.SetItemBeginPrecis(const Value: Integer);
begin
  FItemBeginPrecis := Value;
  ItemBegin := (FItemBeginPrecis div FPlanner.Display.DisplayUnit) -
    FPlanner.Display.DisplayStart;
end;

procedure TPlannerItem.SetItemEndPrecis(const Value: Integer);
begin
  FItemEndPrecis := Value;
  ItemEnd := (FItemEndPrecis div FPlanner.Display.DisplayUnit) -
    FPlanner.Display.DisplayStart;
end;

procedure TPlannerItem.SetTrackVisible(const Value: Boolean);
begin
  FTrackVisible := Value;
  Repaint;
end;

procedure TPlannerItem.SetShape(const Value: TPlannerShape);
begin
  FShape := Value;
  Repaint;
end;

procedure TPlannerItem.SetPopupMenu(const Value: TPopupMenu);
begin
  FPopupMenu := Value;
end;

procedure TPlannerItem.SetShowSelection(const Value: Boolean);
begin
  FShowSelection := Value;
  Repaint;
end;

procedure TPlannerItem.SetShowDeleteButton(const Value: Boolean);
begin
  FShowDeleteButton := Value;
  Repaint;
end;

procedure TPlannerItem.GetTimeTag;
begin
  ItemBeginPrecis := LoWord(DBTag);
  ItemEndPrecis := HiWord(DBTag);
  FRepainted := False;
end;

procedure TPlannerItem.SetTimeTag;
begin
  ItemBegin := ItemBegin;
  ItemEnd := ItemEnd;
  DBTag := MakeLong(ItemBeginPrecis,ItemEndPrecis);
end;

procedure TPlannerItem.Update;
begin
  FPlanner.UpdateItem(Self);
end;

function TPlannerItem.GetItemText: string;
var
  Index: Integer;
begin
  Result := '';
  for Index := 0 to Text.Count - 1 do
  begin
    if Result <> '' then Result := Result + #13;
    Result := Result + Text.Strings[Index];
  end;
end;

procedure TPlannerItem.SetWordWrap(const Value: Boolean);
begin
  if FWordWrap <> Value then
  begin
    FWordWrap := Value;
    Self.Repaint;
  end;
end;

procedure TPlannerItem.SetAttachement(const Value: string);
begin
  if FAttachement <> Value then
  begin
    FAttachement := Value;
    Self.Repaint;
  end;
end;

procedure TPlannerItem.MoveItem(NewBegin, NewEnd, NewPos: Integer; var NewOffset: Integer);
var
  Delta,W: Integer;
begin
  if Assigned(FPlanner.OnItemPlaceUpdate) then
    FPlanner.OnItemPlaceUpdate(FPlanner,Self,NewBegin,NewEnd,NewPos);

  Delta := NewBegin - ItemBegin;

//  W := newend - newbegin + beginoffset + endoffset;

  W := itemend - itembegin + beginoffset + endoffset;

  RealTime := False;

{$IFDEF CODESITE}
  CodeSite.SendInteger('Moved Begin:',NewBegin);
  CodeSite.SendInteger('Moved End:',NewEnd);
  CodeSite.SendInteger('Delta:',Delta);
{$ENDIF}

  if BeginOffset <> 0 then
  begin
    BeginOffset := BeginOffset - Delta;

    If BeginOffset < 0 then
    begin
      NewBegin := ItemBegin - BeginOffset;
      NewEnd := NewBegin + W;
      BeginOffset := 0;
      NewOffset := NewOffset - Delta;
    end
    else
    begin
      NewBegin := NewBegin - Delta;
      NewOffset := NewOffset - Delta;
      NewEnd := ItemEnd + Delta;
    end;
  end;

  if EndOffset <> 0 then
  begin
    EndOffset := EndOffset + Delta;

    if EndOffset < 0 then
    begin
      NewEnd := ItemEnd + EndOffset;
      EndOffset := 0;
    end
    else
    begin
      NewEnd := ItemEnd + EndOffset;
      NewOffset := NewOffset;
      NewBegin := ItemBegin + Delta; // **
    end;
  end;

  if NewBegin < 0 then
  begin
    BeginOffset := -NewBegin;
    NewBegin := 0;
    NewOffset := NewOffset - Delta;
  end;

  if NewEnd < 1 then
  begin
    NewBegin := 0;
    NewEnd := 1;
    BeginOffset := W - 1;
    EndOffset := 0;
    NewOffset := NewOffset - Delta;
  end;

  if FPlanner.Sidebar.Position = spTop then
  begin
    if NewEnd > FPlanner.FGrid.ColCount then
    begin
      EndOffset := NewEnd - FPlanner.FGrid.ColCount;
      NewEnd := FPlanner.FGrid.ColCount;
    end;
  end
  else
  begin
    if NewEnd > FPlanner.FGrid.RowCount then
    begin
      EndOffset := NewEnd - FPlanner.FGrid.RowCount;
      NewEnd := FPlanner.FGrid.RowCount;
    end;
  end;

{$IFDEF TMSCODESITE}
  CodeSite.SendInteger('NewBegin:',NewBegin);
  CodeSite.SendInteger('NewEnd:',NewEnd);
{$ENDIF}

  ItemBegin := NewBegin;
  ItemEnd := NewEnd;
  ItemPos := NewPos;
end;

procedure TPlannerItem.SizeItem(NewBegin, NewEnd: Integer);
var
  NewPos: Integer;
begin
  RealTime := False;

  NewPos := ItemPos;

  if Assigned(FPlanner.OnItemPlaceUpdate) then
    FPlanner.OnItemPlaceUpdate(FPlanner,Self,NewBegin,NewEnd,NewPos);

  if ItemBegin <> NewBegin then
    ItemBegin := NewBegin;
  if ItemEnd <> NewEnd then
    ItemEnd := NewEnd;
  if ItemPos <> NewPos then
    ItemPos := NewPos;
end;

function TPlannerItem.GetItemRealEndTime: TDateTime;
begin
  if RealTime or InHeader then
    Result := FItemRealEndTime
  else
    Result := ItemEndTime;
end;

function TPlannerItem.GetItemRealStartTime: TDateTime;
begin
  if RealTime then
    Result := FItemRealStartTime
  else
    Result := ItemStartTime;
end;

procedure TPlannerItem.SetURL(const Value: string);
begin
  if FURL <> Value then
  begin
    FURL := Value;
    Self.Repaint;
  end;
end;

procedure TPlannerItem.SetAlarm(const Value: TPlannerAlarm);
begin
  FAlarm.Assign(Value);
end;

function TPlannerItem.GetStrippedItemText: string;
begin
  Result := HTMLStrip(GetItemText);
end;

procedure TPlannerItem.SetFlashing(const Value: Boolean);
begin
  if FFlashing <> Value then
  begin
    FFlashing := Value;
    if not FFlashing then Repaint;
  end;
end;

procedure TPlannerItem.Changed;
begin
  FPlanner.Items.ItemChanged(Self);

  if Assigned(OnDesignChange) then
    OnDesignChange(Self);
end;

procedure TPlannerItem.ChangeCrossing;
var
  delta: Integer;
begin
  delta := ItemEnd + EndOffset - ItemBegin;

  BeginOffset := - (ItemBegin - MinInDay div Planner.Display.DisplayUnit);
  ItemBegin := 0;
  EndOffset := 0;
  ItemEnd := delta - BeginOffset;
end;

function TPlannerItem.Planner: TCustomPlanner;
begin
  Result := (Collection as TPlannerItems).FOwner;
end;

function TPlannerItem.GetParentItem: TPlannerItem;
var
  i: Integer;
begin
  Result := Self;
  if (ParentIndex = -1) or (RelationShip = irParent) then
    Result := Self
  else
    for i := 1 to (Collection as TPlannerItems).Count do
    begin
      if ((Collection as TPlannerItems).Items[i - 1].ParentIndex = ParentIndex) and
         ((Collection as TPlannerItems).Items[i - 1].RelationShip = irParent) then
      begin
        Result := (Collection as TPlannerItems).Items[i - 1];
        Break;
      end;
    end;
end;


procedure TPlannerItem.SetControlVal(ID,AValue:string);
begin
  SetValue(ID, AValue);
end;

function TPlannerItem.GetControlVal(ID: string): string;
var
  v: string;
begin
  Result := '';
  if GetValue(ID, v) then
    Result := v;
end;

function TPlannerItem.GetValue(ID: string; var Value: string): Boolean;
begin
  Result := GetControlValue(Text.Text,ID,Value);
end;

function TPlannerItem.SetValue(ID, Value: string): Boolean;
var
  s:string;
begin
  s := Text.Text;
  Result := SetControlValue(s,ID,Value);
  if Result then
    Text.Text := s;
end;

function TPlannerItem.GetNotes: string;
var
  i: Integer;
begin
  Result := '';
  for i := 1 to Text.Count do
  begin
    Result := Result + Text[i - 1];
    if i < Text.Count then
      Result := Result + #13; 
  end;
end;

function TPlannerItem.GetCanEdit: Boolean;
begin
  Result := ReadOnly or (InplaceEdit = peForm) or (FPlanner.UserMode in [puReadOnly, puViewOnly]);

end;

procedure TPlannerItem.EnsureFullVisibility;
begin
  if FPlanner.Sidebar.Position = spTop then
  begin
    if ItemBegin < FPlanner.FGrid.LeftCol then
     FPlanner.FGrid.LeftCol := ItemBegin;

    if ItemEnd > FPlanner.FGrid.LeftCol + FPlanner.FGrid.VisibleColCount then
     FPlanner.FGrid.LeftCol := ItemEnd - FPlanner.FGrid.VisibleColCount;
  end
  else
  begin
    if ItemBegin < FPlanner.FGrid.TopRow then
     FPlanner.FGrid.TopRow := ItemBegin;

    if ItemEnd > FPlanner.FGrid.TopRow + FPlanner.FGrid.VisibleRowCount then
     FPlanner.FGrid.TopRow := ItemEnd - FPlanner.FGrid.VisibleRowCount;
  end;
end;



procedure TPlannerItem.SetCaptionBkgTo(const Value: TColor);
begin
  if (FCaptionBkgTo <> Value) then
  begin
    FCaptionBkgTo := Value;
    Repaint;
  end;
end;

procedure TPlannerItem.SetDrawTool(const Value: TCustomItemDrawTool);
begin
  if (FDrawTool <> Value) then
  begin
    FDrawTool := Value;
    Repaint;
  end;  
end;

procedure TPlannerItem.SetCompletion(const Value: Integer);
begin
  if Value > 100 then
    raise Exception.Create('Completion cannot be larger than 100');

  if Value < 0 then
    raise Exception.Create('Completion cannot be smaller than 0');

  if (FCompletion <> Value) then
  begin
    FCompletion := Value;
    Repaint;
  end;

end;

procedure TPlannerItem.ImageListAdapt(var R: TRect);
begin
  if ImageIndexList.Count > 0 then
  begin
    if ImagePosition = ipHorizontal then
      r.Top := r.Top + FPlanner.PlannerImages.Height
    else
      r.Left := r.Left + FPlanner.PlannerImages.Width + 4;
  end;
end;

procedure TPlannerItem.CompletionAdapt(var R:TRect);
begin
  if CompletionDisplay = cdVertical then
    r.Left := r.Left + 11;

  if CompletionDisplay = cdHorizontal then
    r.Top := r.Top + 11;
end;

procedure TPlannerItem.SetCompletionDisplay(const Value: TCompletionDisplay);
begin
  if (FCompletionDisplay <> Value) then
  begin
    FCompletionDisplay := Value;
    Repaint;
  end;
end;

{$IFNDEF TMSDOTNET}
procedure TPlannerItem.SetWideText(const Value: widestring);
begin
  FWideText := Value;
  Repaint;
end;

procedure TPlannerItem.SetWideCaption(const Value: widestring);
begin
  FWideCaption := Value;
  Repaint;
end;

procedure TPlannerItem.SetUnicode(const Value: boolean);
begin
  if Value <> FUnicode then
  begin
    FUnicode := Value;
    Repaint;
  end;
end;
{$ENDIF}

{NEW INTERFACES FOR DESCENDENT CLASSES}
procedure TPlannerItem.SetClipped(Value: Boolean);
begin
  FClipped:= Value;
end;

procedure TPlannerItem.SetConflictPos(Value: integer);
begin
  FConflictPos:= Value;
end;

procedure TPlannerItem.SetConflicts(Value: integer);
begin
  FConflicts:= Value;
end;
{END OF NEW INTERFACES FOR DESCENDENT CLASSES}

{ TPlannerItems }

function TPlannerItems.Add: TPlannerItem;
begin
  Result := TPlannerItem(inherited Add);
  Result.Assign(FOwner.DefaultItem);
  SetConflicts;
end;

{$IFDEF TMSDOTNET}
constructor TPlannerItems.Create(AOwner: TCustomPlanner; AItemClass: TCollectionItemClass);
{$ENDIF}
{$IFNDEF TMSDOTNET}
constructor TPlannerItems.Create(AOwner: TCustomPlanner);
{$ENDIF}
begin
  {$IFNDEF TMSDOTNET}
  inherited Create(GetItemClass);
  {$ENDIF}
  {$IFDEF TMSDOTNET}
  inherited Create(AItemClass);
  {$ENDIF}

  FOwner := AOwner;
  FSelected := nil;
  FUpdateCount := 0;
end;

function TPlannerItems.GetItem(Index: Integer): TPlannerItem;
begin
  Result := TPlannerItem(inherited GetItem(Index));
end;

{$IFNDEF VER90}
function TPlannerItems.GetOwner: TPersistent;
begin
  Result := FOwner;
end;
{$ENDIF}

function TPlannerItems.CheckItems: Boolean;
var
  i: Integer;
begin
  Result := True;

  if not Assigned(FOwner.ItemChecker) then
    Exit;

  FOwner.ItemChecker.StartCheck;

  for i := 1 to Count do
    if not CheckItem(Items[i - 1]) then
      Result := False;

  FOwner.ItemChecker.StopCheck;
end;

function TPlannerItems.CheckPosition(Position: Integer): Boolean;
var
  i: Integer;
begin
  Result := True;

  if not Assigned(FOwner.ItemChecker) then
    Exit;

  FOwner.ItemChecker.StartCheck;

  for i := 1 to Count do
    if Items[i - 1].ItemPos = Position then
      if not CheckItem(Items[i - 1]) then
        Result := False;

  FOwner.ItemChecker.StopCheck;
end;

function TPlannerItems.CheckLayer(Layer: Integer): Boolean;
var
  i: Integer;
begin
  Result := True;

  if not Assigned(FOwner.ItemChecker) then
    Exit;

  FOwner.ItemChecker.StartCheck;

  for i := 1 to Count do
    if Items[i - 1].Layer and Layer = Layer then
      if not CheckItem(Items[i - 1]) then
        Result := False;

  FOwner.ItemChecker.StopCheck;
end;

function TPlannerItems.CheckItem(Item: TPlannerItem): Boolean;
var
  Corr: string;
begin
  Result := True;

  if Assigned(FOwner.ItemChecker) then
  begin
    Item.Selected := True;
                                                             
    if FOwner.ItemChecker.UseCorrect then
    begin
      Corr := FOwner.ItemChecker.Correct(HTMLStrip(Item.Text.Text));
      if Corr <> Item.Text.Text then
        Result := False;
      Item.Text.Text := Corr;
    end;

    if FOwner.ItemChecker.UseMarkError then
    begin
      Corr := FOwner.ItemChecker.MarkError(Item.Text.Text);
      if Corr <> Item.Text.Text then
        Result := False;
      Item.Text.Text := Corr;
    end;

    Item.Selected := False;    
  end;

end;


function TPlannerItems.Insert(Index: Integer): TPlannerItem;
begin
{$IFDEF DELPHI2COLLECTION}
  Result := TPlannerItem(inherited Add);
{$ELSE}
  Result := TPlannerItem(inherited Insert(Index));
{$ENDIF}
  Result.Assign(FOwner.DefaultItem);
end;

function TPlannerItems.HasItem(ItemBegin, ItemEnd, ItemPos: Integer): Boolean;
var
  ItemIndex: Integer;
  APlannerItem: TPlannerItem;
begin
  Result := False;

  for ItemIndex := 0 to Self.Count - 1 do
  begin
    APlannerItem := Self.Items[ItemIndex];

    if (
      ((APlannerItem.ItemBegin <= ItemBegin) and (APlannerItem.ItemEnd > ItemBegin)) or
      ((APlannerItem.ItemBegin < ItemEnd) and (APlannerItem.ItemEnd >= ItemEnd)) or
      ((ItemBegin < APlannerItem.ItemEnd) and (ItemEnd >= APlannerItem.ItemEnd)) or
      ((ItemBegin <= APlannerItem.ItemBegin) and (ItemEnd > APlannerItem.ItemBegin))
      ) and
      (APlannerItem.ItemPos = ItemPos) and (APlannerItem.Visible) and (APlannerItem <> Selected)
      and (InVisibleLayer(APlannerItem.Layer)) and (APlannerItem.ItemBegin <> APlannerItem.ItemEnd) then
    begin
      Result := (not APlannerItem.AllowOverlap) or (not FOwner.FOverlap);
      if Result then
        Break;
    end;
  end;
end;

function TPlannerItems.FindFirst(ItemBegin, ItemEnd, ItemPos: Integer):
TPlannerItem;
var
  ItemIndex: Integer;
  APlannerItem: TPlannerItem;

begin
  Result := nil;

  FFindIndex := 1;

  for ItemIndex := 1 to Self.Count do
  begin
    APlannerItem := Self.Items[ItemIndex - 1];

    if (
      ((APlannerItem.ItemBegin <= ItemBegin) and (APlannerItem.ItemEnd > ItemBegin)) or
      ((APlannerItem.ItemBegin < ItemEnd) and (APlannerItem.ItemEnd >= ItemEnd)) or
      ((ItemBegin < APlannerItem.ItemEnd) and (ItemEnd >= APlannerItem.ItemEnd)) or
      ((ItemBegin <= APlannerItem.ItemBegin) and (ItemEnd > APlannerItem.ItemBegin))
      )
      and (APlannerItem.ItemPos = ItemPos) then
    begin
      Result := APlannerItem;
      FFindIndex := ItemIndex + 1;
      Break;
    end;
  end;
end;

function TPlannerItems.FindNext(ItemBegin, ItemEnd, ItemPos: Integer):
TPlannerItem;
var
  ItemIndex: Integer;
  APlannerItem: TPlannerItem;

begin
  Result := nil;

  for ItemIndex := FFindIndex to Self.Count do
  begin
    APlannerItem := Self.Items[ItemIndex - 1];
    if (
      ((APlannerItem.ItemBegin <= ItemBegin) and (APlannerItem.ItemEnd > ItemBegin)) or
      ((APlannerItem.ItemBegin < ItemEnd) and (APlannerItem.ItemEnd >= ItemEnd)) or
      ((ItemBegin < APlannerItem.ItemEnd) and (ItemEnd >= APlannerItem.ItemEnd)) or
      ((ItemBegin <= APlannerItem.ItemBegin) and (ItemEnd > APlannerItem.ItemBegin))
      )
      and (APlannerItem.ItemPos = ItemPos) then
    begin
      FFindIndex := ItemIndex + 1;
      Result := APlannerItem;
      Break;
    end;
  end;
end;

procedure TPlannerItems.ClearSelectedRepaints(ItemBegin,ItemPos: Integer);
var
  ItemIndex,ItemEnd: Integer;
  APlannerItem: TPlannerItem;
begin
  ItemEnd := ItemBegin + 1;
  for ItemIndex := 0 to Self.Count - 1 do
  begin
    APlannerItem := Self.Items[ItemIndex];
    if (

      ((ItemBegin >= APlannerItem.ItemBegin) and (ItemBegin < APlannerItem.ItemEnd)) or
      ((ItemEnd > APlannerItem.ItemBegin) and (ItemEnd < APlannerItem.ItemEnd)) or
      ((APlannerItem.ItemBegin >= ItemBegin) and (APlannerItem.ItemBegin < ItemEnd)) or
      ((APlannerItem.ItemEnd > ItemBegin) and (APlannerItem.ItemEnd <= ItemEnd))

      ) and
      (APlannerItem.ItemPos = ItemPos) and (APlannerItem.Visible) and
      (InVisibleLayer(APlannerItem.Layer)) then
    begin
      APlannerItem.Repainted := False;
    end;
  end;
end;

function TPlannerItems.NumItem(ItemBegin, ItemEnd, ItemPos: Integer): TPoint;
var
  ItemIndex: Integer;
  APlannerItem: TPlannerItem;
begin
  Result.X := 0;
  Result.Y := 0;
  for ItemIndex := 0 to Self.Count - 1 do
  begin
    APlannerItem := Self.Items[ItemIndex];
    if (

      ((ItemBegin >= APlannerItem.ItemBegin) and (ItemBegin < APlannerItem.ItemEnd)) or
      ((ItemEnd > APlannerItem.ItemBegin) and (ItemEnd < APlannerItem.ItemEnd)) or
      ((APlannerItem.ItemBegin >= ItemBegin) and (APlannerItem.ItemBegin < ItemEnd)) or
      ((APlannerItem.ItemEnd > ItemBegin) and (APlannerItem.ItemEnd <= ItemEnd))

      ) and
      (APlannerItem.ItemPos = ItemPos) and (APlannerItem.Visible) and
      (InVisibleLayer(APlannerItem.Layer)) and (APlannerItem.ItemEnd > APlannerItem.ItemBegin) then
    begin
      Inc(Result.X);

      if APlannerItem.FConflicts > Result.Y then
        Result.Y := APlannerItem.FConflicts;

      if not (APlannerItem.Background and APlannerItem.AllowOverlap) then
      begin
        if ItemBegin > APlannerItem.ItemBegin then
          ItemBegin := APlannerItem.ItemBegin;
        if ItemEnd < APlannerItem.ItemEnd then
          ItemEnd := APlannerItem.ItemEnd;
      end;
    end;
  end;
end;

function TPlannerItems.NumItemPos(ItemBegin, ItemEnd, ItemPos: Integer): TPoint;
var
  ItemIndex: Integer;
  APlannerItem: TPlannerItem;
begin
  Result.X := 0;
  Result.Y := 0;
  for ItemIndex := 0 to Self.Count-1 do
  begin
    APlannerItem := Self.Items[ItemIndex];
    if (
      ((APlannerItem.ItemBegin <= ItemBegin) and (APlannerItem.ItemEnd > ItemBegin)) or
      ((APlannerItem.ItemBegin < ItemEnd) and (APlannerItem.ItemEnd >= ItemEnd)) or
      ((ItemBegin < APlannerItem.ItemEnd) and (ItemEnd >= APlannerItem.ItemEnd)) or
      ((ItemBegin <= APlannerItem.ItemBegin) and (ItemEnd > APlannerItem.ItemBegin))
      ) and
      (APlannerItem.ItemPos = ItemPos) and (APlannerItem.Visible) and
      (InVisibleLayer(APlannerItem.Layer)) then
    begin
      Inc(Result.X);
      if APlannerItem.FConflictPos > Result.Y then
        Result.Y := APlannerItem.FConflictPos;
    end;
  end;
end;

function TPlannerItems.NumItemPosStart(ItemBegin, ItemPos: Integer): Integer;
var
  ItemIndex: Integer;
  APlannerItem: TPlannerItem;
begin
  Result := 0;
  for ItemIndex := 0 to Self.Count-1 do
  begin
    APlannerItem := Self.Items[ItemIndex];
    if (APlannerItem.ItemBegin = ItemBegin) and
       (APlannerItem.ItemPos = ItemPos) and (APlannerItem.Visible) and
       (InVisibleLayer(APlannerItem.Layer)) then
    begin
      Inc(Result);
    end;
  end;
end;


function TPlannerItems.FindItem(ItemBegin, ItemPos: Integer): TPlannerItem;
var
  ItemIndex: Integer;
  APlannerItem: TPlannerItem;
begin
  Result := nil;
  for ItemIndex := 0 to Self.Count - 1 do
  begin
    APlannerItem := Self.Items[ItemIndex];
    if (APlannerItem.ItemBegin <= ItemBegin) and
      (APlannerItem.ItemEnd > ItemBegin) and
      (APlannerItem.ItemPos = ItemPos) and (APlannerItem.Visible) and
      (InVisibleLayer(APlannerItem.Layer)) then
    begin
      Result := APlannerItem;
      Break;
    end;
  end;
end;

function TPlannerItems.FindItemIdx(ItemBegin: Integer): TPlannerItem;
var
  ItemIndex: Integer;
  APlannerItem: TPlannerItem;
begin
  Result := nil;
  for ItemIndex := 0 to Self.Count - 1 do
  begin
    APlannerItem := Self.Items[ItemIndex];
    if (APlannerItem.ItemBegin <= ItemBegin) and
      (APlannerItem.ItemEnd > ItemBegin) and
      (APlannerItem.Visible) and
      (InVisibleLayer(APlannerItem.Layer)) then
    begin
      Result := APlannerItem;
      Break;
    end;
  end;
end;


function TPlannerItems.FindItemPos(ItemBegin, ItemPos, ItemSubPos: Integer): TPlannerItem;
var
  ItemIndex, w, wo: Integer;
  APlannerItem: TPlannerItem;
begin
  Result := nil;

  if FOwner.Sidebar.Orientation = soVertical then
    wo := FOwner.FGrid.ColWidthEx(ItemPos)
  else
    wo := FOwner.FGrid.RowHeightEx(ItemPos);

  for ItemIndex := 0 to Self.Count-1 do
  begin
    APlannerItem := Self.Items[ItemIndex];

    if (APlannerItem.ItemBegin <= ItemBegin) and
      (APlannerItem.ItemEnd > ItemBegin) and
      (APlannerItem.ItemPos = ItemPos) and (APlannerItem.Visible) and
      not (APlannerItem.Background and APlannerItem.AllowOverlap) and
      (InVisibleLayer(APlannerItem.Layer)) then
    begin
      if APlannerItem.FConflicts > 1 then
        w := wo div APlannerItem.FConflicts
      else
        w := wo;

      if (ItemSubPos > APlannerItem.FConflictPos * w) and
         (ItemSubPos < (APlannerItem.FConflictPos + 1) * w - FOwner.FItemGap)
      then
      begin
        if FOwner.TrackOnly then
        begin
          if ItemSubPos < APlannerItem.FConflictPos * w + FOwner.TrackWidth then
          begin
            Result := APlannerItem;
            Break;
          end;
        end
        else
        begin
          Result := APlannerItem;
          Break;
        end;
      end;
    end;
  end;
end;

function TPlannerItems.FindBkgPos(ItemBegin, ItemPos, ItemSubPos: Integer): TPlannerItem;
var
  ItemIndex, w, wo: Integer;
  APlannerItem: TPlannerItem;
begin
  Result := nil;

  if FOwner.Sidebar.Orientation = soVertical then
    wo := FOwner.FGrid.ColWidthEx(ItemPos)
  else
    wo := FOwner.FGrid.RowHeightEx(ItemPos);

  for ItemIndex := 0 to Self.Count-1 do
  begin
    APlannerItem := Self.Items[ItemIndex];

    if (APlannerItem.ItemBegin <= ItemBegin) and
      (APlannerItem.ItemEnd > ItemBegin) and
      (APlannerItem.ItemPos = ItemPos) and (APlannerItem.Visible) and
      (APlannerItem.Background and APlannerItem.AllowOverlap) and
      (InVisibleLayer(APlannerItem.Layer)) then
    begin
      if APlannerItem.FConflicts > 1 then
        w := wo div APlannerItem.FConflicts
      else
        w := wo;
      if (ItemSubPos > APlannerItem.FConflictPos * w) and
         (ItemSubPos < (APlannerItem.FConflictPos + 1) * w - FOwner.FItemGap)
      then
      begin
        Result := APlannerItem;
        Break;
      end;
    end;
  end;
end;



function TPlannerItems.FindItemPosIdx(ItemBegin, ItemPos, ItemSubPos: Integer): TPlannerItem;
var
  ItemIndex: Integer;
  APlannerItem: TPlannerItem;
begin
  Result := nil;
  for ItemIndex := 0 to Self.Count - 1 do
  begin
    APlannerItem := Self.Items[ItemIndex];
    if (APlannerItem.ItemBegin <= ItemBegin) and
      (APlannerItem.ItemEnd > ItemBegin) and
      (APlannerItem.ItemPos = ItemPos) and (APlannerItem.Visible) and
      not (APlannerItem.Background and APlannerItem.AllowOverlap) and
      (APlannerItem.FConflictPos = ItemSubPos) and
      (InVisibleLayer(APlannerItem.Layer)) then
    begin
      Result := APlannerItem;
      Break;
    end;
  end;
end;

function TPlannerItems.FindItemIndex(ItemBegin, ItemPos, ItemSubIdx: Integer): TPlannerItem;
var
  ItemIndex: Integer;
  APlannerItem: TPlannerItem;
begin
  Result := nil;
  for ItemIndex := 0 to Self.Count - 1 do
  begin
    APlannerItem := Self.Items[ItemIndex];

    if (APlannerItem.ItemBegin <= ItemBegin) and
      (APlannerItem.ItemEnd > ItemBegin) and
      (APlannerItem.ItemPos = ItemPos) and
      (APlannerItem.FConflictPos = ItemSubIdx) and
      (APlannerItem.Visible) and
      not (APlannerItem.Background and APlannerItem.AllowOverlap) and
      (InVisibleLayer(APlannerItem.Layer)) then
    begin
      Result := APlannerItem;
      Break;
    end;
  end;
end;

function TPlannerItems.FindBackground(ItemBegin, ItemPos: Integer): TPlannerItem;
var
  ItemIndex: Integer;
  APlannerItem: TPlannerItem;
begin
  Result := nil;
  for ItemIndex := 0 to Self.Count - 1 do
  begin
    APlannerItem := Self.Items[ItemIndex];

    if (APlannerItem.ItemBegin <= ItemBegin) and
      (APlannerItem.ItemEnd > ItemBegin) and
      (APlannerItem.ItemPos = ItemPos) and
      (APlannerItem.AllowOverlap) and
      (APlannerItem.Visible) and (APlannerItem.Background) and
      (InVisibleLayer(APlannerItem.Layer)) then
    begin
      Result := APlannerItem;
      Break;
    end;
  end;
end;


function TPlannerItems.QueryItem(Item: TPlannerItem; ItemBegin, ItemPos:
  Integer): TPlannerItem;
var
  ItemIndex, StartIndex: Integer;
  APlannerItem: TPlannerItem;
begin
  Result := nil;
  if Assigned(Item) then
    StartIndex := Item.Index + 2
  else
    StartIndex := 1;

  for ItemIndex := StartIndex to Self.Count do
  begin
    APlannerItem := Self.Items[ItemIndex - 1];
    if (APlannerItem.ItemBegin <= ItemBegin) and
      (APlannerItem.ItemEnd > ItemBegin) and
      (APlannerItem.ItemPos = ItemPos) and (APlannerItem.Visible) and
      (InVisibleLayer(APlannerItem.Layer)) then
    begin
      Result := APlannerItem;
      Break;
    end;
  end;
end;

procedure TPlannerItems.SetCurrent(ItemCurrent: Integer);
var
  ItemIndex: Integer;
  APlannerItem: TPlannerItem;
begin
  for ItemIndex := 0 to Self.Count - 1 do
  begin
    APlannerItem := Self.Items[ItemIndex];
    APlannerItem.IsCurrent := (APlannerItem.ItemBegin <= ItemCurrent) and
      (APlannerItem.ItemEnd > ItemCurrent) and
      not APlannerItem.InHeader and APlannerItem.Planner.IsCurPos(APlannerItem.ItemPos);
  end;
end;

function TPlannerItems.FocusItem(ItemBegin, ItemPos, ItemSubPos: Integer; Control:
  Boolean): TPlannerItem;
var
  ItemIndex, w: Integer;
  APlannerItem: TPlannerItem;

begin
  Result := nil;
  FSelected := nil;

  for ItemIndex := 0 to Self.Count - 1 do
  begin
    if FOwner.Sidebar.Orientation = soVertical then
      w := FOwner.FGrid.ColWidthEx(ItemPos)
    else
      w := FOwner.FGrid.RowHeightEx(ItemPos);

    APlannerItem := Self.Items[ItemIndex];
    if (APlannerItem.ItemBegin <= ItemBegin) and
      (APlannerItem.ItemEnd > ItemBegin) and
      (APlannerItem.ItemPos = ItemPos) and
      (APlannerItem.Visible) and
      not (APlannerItem.Background and APlannerItem.AllowOverlap) and
      (InVisibleLayer(APlannerItem.Layer)) then
    begin
      if APlannerItem.FConflicts > 1 then
        w := w div APlannerItem.FConflicts;

      if (ItemSubPos > APlannerItem.FConflictPos * w) and (ItemSubPos <
        (APlannerItem.FConflictPos + 1) * w) then
      begin
        Result := APlannerItem;
        {
        APlannerItem.Focus := True;

        if Control and APlannerItem.Selected then
          APlannerItem.Selected := False
        else
          APlannerItem.Selected := True;

        FSelected := APlannerItem;
        }
      end
      else
      begin
        APlannerItem.Focus := False;
        if not Control or not FOwner.MultiSelect then
          APlannerItem.Selected := False;
      end;
    end
    else
    begin
      APlannerItem.Focus := False;
      if not Control or not FOwner.MultiSelect then
        APlannerItem.Selected := False;
    end;
  end;

  if Assigned(Result) then
  begin
    APlannerItem := Result;
    APlannerItem.Focus := True;
    if Control and APlannerItem.Selected then
      APlannerItem.Selected := False
    else
      APlannerItem.Selected := True;
    FSelected := APlannerItem;
  end;
end;

procedure TPlannerItems.UnSelect;
begin
  if Assigned(FSelected) then
  begin
    FSelected.Focus := False;
    FSelected.Selected := False;
    FSelected := nil;
  end;
  ClearLinks;
end;

procedure TPlannerItems.UnSelectAll;
var
  i: Integer;
begin
  for i := 0 to Count - 1 do
  with Items[i] do
  begin
    LinkSelect := False;  
    Focus := False;
    Selected := False;
  end;
  FSelected := nil;
end;


function TPlannerItems.SelectNext: TPlannerItem;
var
  idx: Integer;
begin
  if FSelected <> nil then
  begin
    FSelected.Focus := False;
    FSelected.Selected := False;
    idx := FSelected.Index;
    while idx + 1 < Self.Count do
    begin
      if not (Self.Items[idx + 1].Background) then
      begin
        FSelected := Self.Items[idx + 1];
        FSelected.Selected := True;
        Break;
      end
      else
        inc(idx);
    end;
    if (idx + 1 = Self.Count) then
      FSelected := nil;
  end
  else
  begin
    if (Self.Count > 0) then
    begin
      FSelected := Self.Items[0];
      FSelected.Focus := True;
      FSelected.Selected := True;
    end;
  end;
  if Assigned(FSelected) then
    FSelected.Focus := True;
  Result := FSelected;
end;

function TPlannerItems.SelectPrev: TPlannerItem;
var
  idx: Integer;
begin
  if FSelected <> nil then
  begin
    FSelected.Focus := False;
    FSelected.Selected := False;
    idx := FSelected.Index;
    while idx > 0 do
    begin
      if not Self.Items[idx - 1].Background then
      begin
        FSelected := Self.Items[idx - 1];
        FSelected.Selected := True;
        Break;
      end
      else
        dec(idx);
    end;
    if (idx <= 0) then
      FSelected := nil;
  end
  else
  begin
    if Self.Count > 0 then
    begin
      FSelected := Self.Items[Self.Count - 1];
      FSelected.Selected := True;
    end;
  end;
  if Assigned(FSelected) then
    FSelected.Focus := True;
  Result := FSelected;
end;

function TPlannerItems.InVisibleLayer(Layer: Integer): Boolean;
begin
  Result := (FOwner.Layer = 0) or ((FOwner.Layer > 0) and (Layer and FOwner.Layer
    > 0));
end;

procedure TPlannerItems.SetItem(Index: Integer; Value: TPlannerItem);
begin
  inherited SetItem(Index, Value);
end;

procedure TPlannerItems.ClearPosition(Position: Integer);
var
  ItemIndex: Integer;
begin
  BeginUpdate;
  for ItemIndex := Count downto 1 do
  begin
    if Items[ItemIndex - 1].ItemPos = Position then
      Items[ItemIndex - 1].Free
  end;
  EndUpdate;
end;

procedure TPlannerItems.ClearLayer(Layer: Integer);
var
  ItemIndex: Integer;
begin
  BeginUpdate;
  for ItemIndex := Count downto 1 do
  begin
    if Items[ItemIndex - 1].Layer = Layer then
      Items[ItemIndex - 1].Free
  end;
  EndUpdate;
end;

procedure TPlannerItems.BeginUpdate;
begin
  inherited;
  Inc(FUpdateCount);
end;

procedure TPlannerItems.EndUpdate;
begin
  if FUpdateCount > 0 then Dec(FUpdateCount);
  if FUpdateCount = 0 then
  begin
    SetConflicts;
    FOwner.FGrid.UpdateNVI;
    FOwner.FGrid.Invalidate;
  end;
  inherited;
end;

procedure TPlannerItems.ResetUpdate;
var
  i: Integer;
begin
  if FUpdateCount > 0 then Dec(FUpdateCount);
  if FUpdateCount = 0 then
  begin
    SetConflicts;
    ClearRepaints;
    for i := 1 to Count do
      if Items[i - 1].FChanged then
        Items[i - 1].Repaint;
  end;
end;

procedure TPlannerItems.SetConflicts;
type
  tbp = record
    X, Y,Z: Byte;
  end;

  confarray = array of array of tbp;

var
  conf: confarray;

  i, j, k, m, n, mm, NumRows: Integer;
  flg: Boolean;

  function IsOverlapping(APlannerItem: TPlannerItem; ItemBegin: Integer):boolean;
  begin
    Result := False;

    if (APlannerItem.ItemBegin <= ItemBegin) and
       (APlannerItem.ItemEnd > ItemBegin) and
       (APlannerItem.Visible) and
       not (APlannerItem.Background and APlannerItem.AllowOverlap) and
       (InVisibleLayer(APlannerItem.Layer)) then
    begin
      Result := True;
    end;
  end;

begin
  if FUpdateCount > 0 then
    Exit;

  if (csDestroying in FOwner.ComponentState) then
    Exit;

  if FOwner.FLinkUpdate then
   Exit;

  if Count = 0 then
  begin
    if FOwner.Footer.ShowCompletion and FOwner.Footer.Visible then
    begin
      FOwner.UpdateCompletion;
    end;

    if Assigned(FOwner.FOnConflictUpdate) then
      FOwner.FOnConflictUpdate(Self);
    Exit;
  end;

  for i := 1 to Count do
  with Items[i - 1] do
    begin
      FBeginExt := ItemBegin;
      FEndExt := ItemEnd;
      FChanged := False;
    end;

  {Clear counters of overlapping Items}

  if FOwner.SideBar.Orientation = soVertical then
  begin
    SetLength(conf,FOwner.FGrid.ColCount + 1,FOwner.FGrid.RowCount + 1);
    NumRows := FOwner.FGrid.RowCount + 1;
  end
  else
  begin
    SetLength(conf,FOwner.FGrid.RowCount + 1,FOwner.FGrid.ColCount + 1);
    NumRows := FOwner.FGrid.ColCount + 1;
  end;

  {Calculate worst-case item overlap count}

  for i := 0 to Count - 1 do
  begin
    m := 0;
    if InVisibleLayer(Items[i].Layer) and Items[i].Visible and not (Items[i].Background and Items[i].AllowOverlap) then
      for j := 0 to Count - 1 do
      begin
        if (i <> j) and (Items[j].ItemPos = Items[i].ItemPos) then
        for k := Items[i].ItemBegin to Items[i].ItemEnd - 1 do
        begin
          if IsOverlapping(Items[j], k) then
          begin
            if Items[j].FBeginExt < Items[i].FBeginExt then
               Items[i].FBeginExt := Items[j].FBeginExt
            else
               Items[j].FBeginExt := Items[i].FBeginExt;

            if Items[j].FEndExt > Items[i].FEndExt then
               Items[i].FEndExt := Items[j].FEndExt
            else
               Items[j].FEndExt := Items[i].FEndExt;

            Inc(m);
            Break;
          end;

        end;
      end;

    Items[i].FChanged := Items[i].FConflicts <> m + 1;
    Items[i].FConflicts := m + 1;
  end;

  {Count. nr of overlapping Items per cell}
  for i := 0 to Count - 1 do
  begin
    with Items[i] do
    begin
      if (FBeginExt >= 0) and (FEndExt >=0 ) then

        if Visible and InVisibleLayer(Layer) and not (Background and AllowOverlap) then
          for j := FBeginExt to FEndExt - 1 do
          begin

            if (ItemPos < High(Conf)) and (ItemPos >= 0) and (j < High(Conf[ItemPos])) then
              if (Items[i].FConflicts > Conf[ItemPos, j].X) then
                Conf[ItemPos, j].X := Items[i].FConflicts;
          end;
    end;
  end;

  //Assign Items conflicts & conflict positions
  for i := 0 to Count - 1 do
  begin
    with Items[i] do
      if Visible and InVisibleLayer(Layer) and not (Background and AllowOverlap) then
      begin
        m := 0;
        mm := 0;

        {get last assigned conflict position}
        for j := ItemBegin to ItemEnd - 1 do
        begin
          if (ItemPos < High(Conf)) and (ItemPos >=0) and (j < High(Conf[ItemPos])) then
          begin
            if (Conf[ItemPos, j].Y > m)   then
              m := Conf[ItemPos, j].Y;

            if (Conf[ItemPos, j].Z > mm)   then
              mm := Conf[ItemPos, j].Z;
          end;
        end;

        if mm = m then mm := 0;

        {get nr. of conflicts from extended zone}
        n := 0;
        for j := FBeginExt to FEndExt - 1 do
          if (ItemPos < High(Conf)) and (ItemPos >=0) and (j < High(Conf[ItemPos])) then
            if Conf[ItemPos, j].X > n then
              n := Conf[ItemPos, j].X;

        {scan ... if Assigned Position 0,1,2}
        flg := (FConflicts <> n) or
               (FConflictPos <> m);

        FConflicts := n;

        if m < FConflicts then
        begin
          FChanged := FChanged or (FConflictPos <> m);
          FConflictPos := m
        end
        else
        begin
          FChanged := FChanged or (FConflictPos <> mm);
          FConflictPos := mm;
        end;

        if (m >= FConflicts) then
        begin
          mm := mm + 1;
          for j := Max(0,ItemBegin) to Max(0,ItemEnd - 1) do
          begin
            if (ItemPos < High(Conf)) and (ItemPos >=0) and (j < High(Conf[ItemPos])) then
            begin
              Conf[ItemPos, j].Z := mm;
            end;
          end;
        end;


        if m < FConflicts then
          m := m + 1;

        for j := Max(0,ItemBegin) to Max(0,ItemEnd - 1) do
        begin
          if (ItemPos < High(Conf)) and (ItemPos >=0) and (j < High(Conf[ItemPos])) then
            Conf[ItemPos, j].Y := m;
        end;

        if Flg then
          Repaint;

      end;
  end;

  //If better than worst case position found, optimize
  for i := 1 to Count do
  begin
    with Items[i - 1] do
    begin
      m := 0;
      for j := 0 to NumRows - 1 do
        if (ItemPos < High(Conf)) and (ItemPos >=0) and (j < High(Conf[ItemPos])) then
          if Conf[ItemPos, j].Y > m then
            m := Conf[ItemPos, j].Y;

      if FConflicts > m then
      begin
        FChanged := FChanged or (FConflicts <> m);
        FConflicts := m;
        Repaint;
      end;
    end;
  end;

  if FOwner.Footer.ShowCompletion and FOwner.Footer.Visible then
  begin
    FOwner.UpdateCompletion;
  end;

  if Assigned(FOwner.FOnConflictUpdate) then
    FOwner.FOnConflictUpdate(Self);
end;

procedure TPlannerItems.ClearConflicts;
var
  ItemIndex: Integer;
begin
  for ItemIndex := 0 to Count-1 do
  begin
    Items[ItemIndex].FConflictPos := 0;
    Items[ItemIndex].FConflicts := 0;
  end;
end;

function TPlannerItems.NumConflicts(var ItemBegin, ItemEnd: Integer; ItemPos: Integer):
  Integer;
var
  ItemIndex: Integer;
  APlannerItem: TPlannerItem;
begin
  Result := 0;
  for ItemIndex := 0 to Self.Count-1 do
  begin
    APlannerItem := Self.Items[ItemIndex];
    if (
      ((APlannerItem.ItemBegin <= ItemBegin) and (APlannerItem.ItemEnd > ItemBegin)) or
      ((APlannerItem.ItemBegin < ItemEnd) and (APlannerItem.ItemEnd >= ItemEnd)) or
      ((ItemBegin < APlannerItem.ItemEnd) and (ItemEnd >= APlannerItem.ItemEnd)) or
      ((ItemBegin <= APlannerItem.ItemBegin) and (ItemEnd > APlannerItem.ItemBegin))
      ) and
      (APlannerItem.ItemPos = ItemPos) and (APlannerItem.Visible) and
      (InVisibleLayer(APlannerItem.Layer)) then
    begin
      Inc(Result);
      if APlannerItem.ItemBegin < ItemBegin then
        ItemBegin := APlannerItem.ItemBegin;
      if APlannerItem.ItemEnd > ItemEnd then
        ItemEnd := APlannerItem.ItemEnd;
    end;
  end;

  FOwner.DoPositionAutoSize;
end;

procedure TPlannerItems.ResolveLinks;
var
  i,j: integer;
begin
  for i := 1 to Count do
  begin
    if (Items[i - 1].LinkedDBKey <> '') then
    begin
      Items[i - 1].LinkedItem := nil;

      for j := 1 to Count do
      begin
        if (Items[i - 1].LinkedDBKey = Items[j - 1].DBKey) then
          Items[i - 1].LinkedItem := Items[j - 1];
      end;
    end;
  end;
end;

procedure TPlannerItems.CopyToClipboard;
var
  Clipboard: TClipboard;
  PlannerItemIO: TPlannerItemIO;
  MemStream: TMemoryStream;
  Data: THandle;
  {$IFNDEF TMSDOTNET}
  DataPtr: Pointer;
  {$ENDIF}
begin
  Clipboard := TClipboard.Create;

  if Assigned(Selected) then
  begin
    Selected.ItemBegin := Selected.ItemBegin;
    Selected.ItemEnd := Selected.ItemEnd;
    Selected.DBTag := MakeLong(Selected.ItemBeginPrecis, Selected.ItemEndPrecis);

    PlannerItemIO := TPlannerItemIO.CreateItem(Self);
    PlannerItemIO.Item.Assign(Selected);

    MemStream := TMemoryStream.Create;
    try
      MemStream.WriteComponent(PlannerItemIO);

      Clipboard.Open;
      try
        Data := GlobalAlloc(GMEM_MOVEABLE + GMEM_DDESHARE, MemStream.Size);
        {$IFNDEF TMSDOTNET}
        try
          DataPtr := GlobalLock(Data);
          try
            Move(MemStream.Memory^, DataPtr^, MemStream.Size);
            Clipboard.Clear;
            SetClipboardData(CF_PLANNERITEM, Data);
          finally
            GlobalUnlock(Data);
          end;
        except
          GlobalFree(Data);
          raise;
        end;
        {$ENDIF}
      finally
        Clipboard.Close;
      end;
    finally
      MemStream.Free;
    end;
    PlannerItemIO.Free;
  end;
  Clipboard.Free;
end;

procedure TPlannerItems.CutToClipboard;
begin
  CopyToClipboard;
  if Assigned(Selected) then
    FOwner.FreeItem(Selected);
end;

procedure TPlannerItems.PasteItem(Position: Boolean; Size: Boolean);
var
  Clipboard: TClipboard;
  PlannerItemIO: TPlannerItemIO;
  MemStream: TMemoryStream;
  Data: THandle;
  {$IFNDEF TMSDOTNET}
  DataPtr: Pointer;
  {$ENDIF}
  {$IFDEF TMSDOTNET}
  DataPtr: IntPtr;
  {$ENDIF}
  plIt: TPlannerItem;
  delta, EP: Integer;

begin
  Clipboard := TClipboard.Create;

  Clipboard.Open;

  Data := 0;

  try
    Data := GetClipboardData(CF_PLANNERITEM);
    if Data = 0 then
      Exit;

    DataPtr := GlobalLock(Data);
    if DataPtr = nil then
      Exit;
    try
      MemStream := TMemoryStream.Create;
      {$IFNDEF TMSDOTNET}
      MemStream.WriteBuffer(DataPtr^, GlobalSize(Data));
      {$ENDIF}
      MemStream.Position := 0;
      PlannerItemIO := TPlannerItemIO.CreateItem(Self);
      try
        MemStream.ReadComponent(PlannerItemIO);
        with PlannerItemIO.Item do
        begin
          EP := 0;
          if Position then
          begin
            delta := HiWord(DBTag) - LoWord(DBTag);

            ItemBegin := FOwner.SelItemBegin;
            if Size then
            begin
              ItemEndPrecis := ItemBeginPrecis + delta;
              if ItemEnd > FPlanner.Display.DisplayEnd then
              begin
                EP := ItemEnd - FPlanner.Display.DisplayEnd - 1;
                ItemEnd := FPlanner.Display.DisplayEnd + 1;
              end;
            end
            else
              ItemEnd := FOwner.SelItemEnd;

            ItemPos := FOwner.SelPosition;
          end
          else
          begin
            ItemBeginPrecis := LoWord(DBTag);
            ItemEndPrecis := HiWord(DBTag);
          end;
        end;

        plIt := FOwner.CreateItem;
        plIt.Assign(PlannerItemIO.Item);
        plIt.EndOffset := EP;
        plIt.Update;

      finally
        PlannerItemIO.Free;
        MemStream.Free;
      end;
    finally

    end;
  finally
    GlobalUnlock(Data);
  end;

  Clipboard.Close;
  Clipboard.Free;
end;

procedure TPlannerItems.PasteFromClipboard;
begin
  PasteItem(False, True);
end;

procedure TPlannerItems.PasteFromClipboardAtPos;
begin
  PasteItem(True, False);
end;

procedure TPlannerItems.PasteFromClipboardAtXY;
begin
  PasteItem(True, True);
end;


procedure TPlannerItems.OffsetItems(Offset: Integer);
var
  ItemIndex: Integer;
begin
  BeginUpdate;
  try
    for ItemIndex := 0 to Count - 1 do
    begin
      Items[ItemIndex].ItemBegin := Items[ItemIndex].ItemBegin + Offset;
      Items[ItemIndex].ItemEnd := Items[ItemIndex].ItemEnd + Offset;
    end;
  finally
    EndUpdate;
  end;
end;

procedure TPlannerItems.MoveAll(DeltaPos, DeltaBegin: Integer);
var
  ItemIndex: Integer;
begin
  for ItemIndex := 0 to Count - 1 do
  begin
    Items[ItemIndex].ItemBegin := Clip(Items[ItemIndex].ItemBegin + DeltaBegin,
      FOwner.Display.DisplayStart, FOwner.Display.DisplayEnd);
    Items[ItemIndex].ItemEnd := Clip(Items[ItemIndex].ItemEnd + DeltaBegin,
      FOwner.Display.DisplayStart, FOwner.Display.DisplayEnd);
    Items[ItemIndex].ItemPos := Clip(Items[ItemIndex].ItemPos + DeltaPos,
      FOwner.Display.DisplayStart, FOwner.Display.DisplayEnd);
  end;
end;

procedure TPlannerItems.MoveSelected(DeltaPos, DeltaBegin: Integer);
var
  ItemIndex: Integer;
begin
  for ItemIndex := 0 to Count - 1 do
  begin
    if Items[ItemIndex].Selected and not Items[ItemIndex].Focus then
    begin
      Items[ItemIndex].ItemBegin := Clip(Items[ItemIndex].ItemBegin + DeltaBegin,
        FOwner.Display.DisplayStart, FOwner.Display.DisplayEnd);
      Items[ItemIndex].ItemEnd := Clip(Items[ItemIndex].ItemEnd + DeltaBegin,
        FOwner.Display.DisplayStart, FOwner.Display.DisplayEnd);
      Items[ItemIndex].ItemPos := Clip(Items[ItemIndex].ItemPos + DeltaPos,
        FOwner.Display.DisplayStart, FOwner.Display.DisplayEnd);
    end;
  end;
end;

procedure TPlannerItems.SizeAll(DeltaStart, DeltaEnd: Integer);
var
  ItemIndex: Integer;
begin
  for ItemIndex := 0 to Count - 1 do
  begin
    Items[ItemIndex].ItemBegin := Clip(Items[ItemIndex].ItemBegin + DeltaStart,
      FOwner.Display.DisplayStart, FOwner.Display.DisplayEnd);
    Items[ItemIndex].ItemEnd := Clip(Items[ItemIndex].ItemEnd + DeltaEnd,
      FOwner.Display.DisplayStart, FOwner.Display.DisplayEnd);
  end;
end;

procedure TPlannerItems.SizeSelected(DeltaStart, DeltaEnd: Integer);
var
  ItemIndex: Integer;
begin
  for ItemIndex := 0 to Count - 1 do
  begin
    if Items[ItemIndex].Selected and not Items[ItemIndex].Focus then
    begin
      Items[ItemIndex].ItemBegin := Clip(Items[ItemIndex].ItemBegin + DeltaStart,
        FOwner.Display.DisplayStart, FOwner.Display.DisplayEnd);
      Items[ItemIndex].ItemEnd := Clip(Items[ItemIndex].ItemEnd + DeltaEnd,
        FOwner.Display.DisplayStart, FOwner.Display.DisplayEnd);
    end;
  end;
end;

procedure TPlannerItems.ClearRepaints;
var
  ItemIndex: Integer;
begin
  for ItemIndex := 0 to Count - 1 do
    Items[ItemIndex].Repainted := False;
end;


function TPlannerItems.HeaderFirst(ItemPos: Integer): TPlannerItem;
var
  ItemIndex: Integer;
  APlannerItem: TPlannerItem;
begin
  Result := nil;
  FFindIndex := 1;

  for ItemIndex := 1 to Count do
  begin
    APlannerItem := Items[ItemIndex - 1];
    if (APlannerItem.ItemPos = ItemPos) and (APlannerItem.InHeader) and InVisibleLayer(APlannerItem.Layer) then
    begin
      Result := APlannerItem;
      FFindIndex := ItemIndex + 1;
      Break;
    end;
  end;
end;

function TPlannerItems.HeaderNext(ItemPos: Integer): TPlannerItem;
var
  ItemIndex: Integer;
  APlannerItem: TPlannerItem;
begin
  Result := nil;
  for ItemIndex := FFindIndex to Count do
  begin
    APlannerItem := Items[ItemIndex - 1];
    if (APlannerItem.ItemPos = ItemPos) and (APlannerItem.FInHeader) and InVisibleLayer(APlannerItem.Layer) then
    begin
      Result := APlannerItem;
      FFindIndex := ItemIndex + 1;
      Break;
    end;
  end;
end;


procedure TPlannerItems.ClearAll;
begin
  Clear;
  Selected := nil;
  FOwner.Invalidate;
end;

procedure TPlannerItems.ClearDB;
var
  i: Integer;
begin
  i := 0;
  while i < Count do
  begin
    if not Items[i].NonDBItem then
      Items[i].Free
    else
      inc(i);
  end;
end;

procedure TPlannerItems.GetTimeTags;
var
  i: Integer;
begin
  if not FOwner.FStreamPersistentTime then
    Exit;

  for i := 1 to Count do
    Items[i - 1].GetTimeTag;
end;

procedure TPlannerItems.SetTimeTags;
var
  i: Integer;
begin
  for i := 1 to Count do
    Items[i - 1].SetTimeTag;
end;

function TPlannerItems.FindKey(DBKey: string): TPlannerItem;
var
  i: Integer;
begin
  Result := Nil;

  for i := 1 to Count do
  begin
    if Items[i - 1].DBKey = DBKey then
    begin
      Result := Items[i - 1];
      Break;
    end;
  end;
end;

procedure TPlannerItems.UpdateLinks(APlannerItem: TPlannerItem);
begin
  if APlannerItem.LinkUpdating then
    Exit;

  APlannerItem.LinkUpdating := true;

  if Assigned(APlannerItem.LinkedItem) then
  begin
    APlannerItem.LinkedItem.LinkSelect := true;
    UpdateLinks(APlannerItem.LinkedItem);
  end;

  APlannerItem.LinkUpdating := false;
end;

procedure TPlannerItems.ClearLinks;
var
  i: integer;
begin
  for i := 1 to Count do
    Items[i - 1].LinkSelect := false;
end;

procedure TPlannerItems.Select(Item: TPlannerItem);
begin
  UnSelect;
  Item.Focus := True;
  Item.Selected := True;
  FSelected := Item;
  FOwner.ItemSelected(Item);
end;


function TPlannerItems.MatchItem(Item: TPlannerItem; s: string;
  Param: TFindTextParams): Boolean;
var
  SrchText: string;

begin
  Result := False;

  if fnCaptionText in Param then
  begin
    SrchText := Item.CaptionText;

    if fnIgnoreHTMLTags in Param then
      SrchText := HTMLStrip(SrchText);

    if not (fnMatchCase in Param) then
    begin
      SrchText := AnsiUpperCase(SrchText);
      s := AnsiUpperCase(s);
    end;

    if fnMatchFull in Param then
      Result := (s = SrchText)
    else
      if fnMatchStart in Param then
        Result := Pos(s,SrchText) = 1
      else
        if fnMatchRegular in Param then
          Result := MatchStr(s,SrchText,fnMatchCase in Param)
            else
              Result := Pos(s,SrchText) > 0;
  end;

  if Result then Exit;

  if fnText in Param then
  begin
    SrchText := Item.Text.Text;

    if fnIgnoreHTMLTags in Param then
      SrchText := HTMLStrip(SrchText);

    if not (fnMatchCase in Param) then
    begin
      SrchText := AnsiUpperCase(SrchText);
      s := AnsiUpperCase(s);
    end;

    if fnMatchFull in Param then
      Result := (s = SrchText)
    else
      if fnMatchStart in Param then
        Result := Pos(s,SrchText) = 1
      else
        if fnMatchRegular in Param then
          Result := MatchStr(s,SrchText,fnMatchCase in Param)
            else
              Result := Pos(s,SrchText) > 0;
  end;
end;

function TPlannerItems.FindText(StartItem: TPlannerItem; s: string;
  Param: TFindTextParams): TPlannerItem;
var
  i: Integer;

begin
  Result := nil;
  if Count = 0 then
    Exit;

  if not (fnBackward in Param) then
  begin
    i := 0;

    if Assigned(StartItem) then
    begin
      while i < Count do
      begin
        if Items[i] = StartItem then
          Break
        else
          Inc(i);
      end;

      if i < Count then
        Inc(i)
      else
        i := 0;
    end;

    while i < Count do
    begin
      if MatchItem(Items[i],s,Param) then
      begin
        Result := Items[i];
        if fnAutoGoto in Param then
        begin
          Items[i].ScrollInView;
          Items[i].SetFocus(True);
          Items[i].Selected := True;
        end;
        Break;
      end
      else
        inc(i);
  end;
  end
  else
  begin
    i := Count - 1;

    if Assigned(StartItem) then
    begin
      while i > 0 do
      begin
        if Items[i] = StartItem then
          Break
        else
          Dec(i);
      end;

      if i > 0 then
        Dec(i)
      else
        i := Count - 1;
    end;

    while i > 0 do
    begin
      if MatchItem(Items[i],s,Param) then
      begin
        Result := Items[i];
        if fnAutoGoto in Param then
        begin
          Items[i].ScrollInView;
          Items[i].SetFocus(True);
          Items[i].Selected := True;
        end;
        Break;
      end
      else
        Dec(i);
    end;
  end;

end;

procedure TPlannerItems.MoveLinks(APlannerItem: TPlannerItem);
begin
  if not Assigned(APlannerItem) then
    Exit;

  APlannerItem.LinkUpdating := true;
  if Assigned(APlannerItem.LinkedItem) then
  begin
    if not APlannerItem.LinkedItem.LinkUpdating then
    begin
      APlannerItem.LinkUpdating := true;
      FOwner.ItemMoved(APlannerItem.LinkedItem,
                       0,
                       0,
                       0,
                       APlannerItem.LinkedItem.ItemBegin,
                       APlannerItem.LinkedItem.ItemEnd,
                       APlannerItem.LinkedItem.ItemPos);
      MoveLinks(APlannerItem.LinkedItem);

    end;
  end;
  APlannerItem.LinkUpdating := false;
end;

procedure TPlannerItems.SizeLinks(APlannerItem: TPlannerItem);
begin
  if not Assigned(APlannerItem) then
    Exit;

  APlannerItem.LinkUpdating := true;
  if Assigned(APlannerItem.LinkedItem) then
  begin
    if not APlannerItem.LinkedItem.LinkUpdating then
    begin
      APlannerItem.LinkUpdating := true;
      FOwner.ItemSized(APlannerItem.LinkedItem,
                       0,
                       0,
                       APlannerItem.LinkedItem.ItemBegin,
                       APlannerItem.LinkedItem.ItemEnd);
      SizeLinks(APlannerItem.LinkedItem);
    end;
  end;
  APlannerItem.LinkUpdating := false;
end;


function TPlannerItems.MaxItemsInPos(Position: Integer): Integer;
var
  i,m : Integer;
  APlannerItem: TPlannerItem;
begin
  m := 1;
  for i := 1 to Count do
  begin
    APlannerItem := Items[i - 1];

    if (APlannerItem.ItemPos = Position) and (APlannerItem.Visible) and
       (InVisibleLayer(APlannerItem.Layer)) then
    begin
      if (APlannerItem.Conflicts > m) then
        m := APlannerItem.Conflicts;
    end;
  end;
  Result := m;
end;


function TPlannerItems.ItemsAtCell(ItemBegin, ItemEnd, ItemPos: Integer): Integer;
begin
  Result := NumItemPos(ItemBegin, ItemEnd, ItemPos).X;
end;

function TPlannerItems.ItemsAtIndex(Idx: Integer): Integer;
var
  APlannerItem: TPlannerItem;
  i: Integer;
begin
  Result := 0;

  for i := 1 to Count do
  begin
    APlannerItem := Items[i - 1];
    if (APlannerItem.ItemBegin <= Idx) and (APlannerItem.ItemEnd > Idx)
     and APlannerItem.Visible and InVisibleLayer(APlannerItem.Layer) then
       Result := Result + 1;
  end;
end;

function TPlannerItems.ItemsAtPosition(Pos: Integer): Integer;
var
  APlannerItem: TPlannerItem;
  i: Integer;  
begin
  Result := 0;

  for i := 1 to Count do
  begin
    APlannerItem := Items[i - 1];
    if (APlannerItem.ItemPos = Pos) and APlannerItem.Visible and
       InVisibleLayer(APlannerItem.Layer) then
      Result := Result + 1;
  end;
end;

function TPlannerItems.GetItemClass: TCollectionItemClass;
begin
  Result := TPlannerItem;
end;

procedure TPlannerItems.ItemChanged(Item:TPlannerItem);
var
  i: Integer;

begin
  if Assigned(FOwner.OnItemUpdate) then
    FOwner.OnItemUpdate(Self);

  if FChanging then
    Exit;

  if Item.ParentIndex = -1 then
    Exit;

  FChanging := True;

  for i := 1 to Count do
  begin
    if (Items[i - 1] <> Item) and (Item.ParentIndex = Items[i - 1].ParentIndex) then
    begin
      Items[i - 1].AssignEx(Item);
    end;
  end;

  FChanging := False;
end;

function TPlannerItems.GetSelCount: Integer;
var
  i: Integer;
begin
  Result := 0;
  for i := 1 to Count do
  begin
    if Items[i - 1].Selected then
      Inc(Result);
  end;
end;

{ TPlannerMemo }

procedure TPlannerMemo.DoEnter;
begin
  inherited;
end;

procedure TPlannerMemo.DoExit;
var
  s: string;
begin
  inherited;
  if Assigned(Lines) and Assigned(PlannerItem) then
  begin
    s := Lines.Text;
    PlannerItem.Text.Text := s;
    PlannerItem.FPlanner.ItemEdited(PlannerItem);
  end;
  Visible := False;
  Parent.SetFocus;
end;

procedure TPlannerMemo.WMPaste(var Msg:TMessage);
var
  s: string;
begin
  inherited;
  if Assigned(FPlannerItem.FPlanner.OnItemClipboardAction) then
  begin
    s := Lines.Text;
    FPlannerItem.FPlanner.OnItemClipboardAction(FPlannerItem.FPlanner,FPlannerItem,itPaste,s);
    if s <> Lines.Text then
      Lines.Text := s;
  end;
end;

procedure TPlannerMemo.WMCopy(var Msg:TMessage);
var
  s:string;
begin
  inherited;
  if Assigned(FPlannerItem.FPlanner.OnItemClipboardAction) then
  begin
    s := Lines.Text;
    FPlannerItem.FPlanner.OnItemClipboardAction(FPlannerItem.FPlanner,FPlannerItem,itCopy,s);
    if s <> Lines.Text then
      Lines.Text := s;
  end;
end;

procedure TPlannerMemo.WMCut(var Msg:TMessage);
var
  s:string;
begin
  inherited;
  if Assigned(FPlannerItem.FPlanner.OnItemClipboardAction) then
  begin
    s := Lines.Text;
    FPlannerItem.FPlanner.OnItemClipboardAction(FPlannerItem.FPlanner,FPlannerItem,itCut,s);
    if s <> Lines.Text then
      Lines.Text := s;
  end;
end;



procedure TPlannerMemo.KeyDown(var Key: Word; Shift: TShiftState);
begin
  inherited;
  if Key = vk_Escape then
  begin
    Self.Lines.Assign(PlannerItem.Text);
    PlannerItem.FPlanner.SetFocus;
  end;
end;

procedure TPlannerMemo.StopEdit;
var
  s: string;
begin
  inherited;
  if Assigned(Lines) and Assigned(PlannerItem) then
  begin
    s := Lines.Text;
    PlannerItem.Text.Text := s;
    PlannerItem.FPlanner.ItemEdited(PlannerItem);
  end;
  Visible := False;
end;

procedure TPlannerMemo.DblClick;
begin
  inherited;
  if Assigned(FPlanner.OnItemDblClick) then
    FPlanner.OnItemDblClick(FPlanner, FPlannerItem);
end;

{$IFNDEF TMSDOTNET}
{$IFNDEF DELPHI_UNICODE}

{ TPlannerUniMemo }

procedure TPlannerUniMemo.DoEnter;
begin
  inherited;
end;

procedure TPlannerUniMemo.DoExit;
begin
  inherited;
  if Assigned(PlannerItem) then
  begin
    PlannerItem.WideText := Text;
    PlannerItem.FPlanner.ItemEdited(PlannerItem);
  end;
  Visible := False;
  Parent.SetFocus;
end;

procedure TPlannerUniMemo.WMPaste(var Msg:TMessage);
{
var
  s: string;
}  
begin
  inherited;
  {
  if Assigned(FPlannerItem.FPlanner.OnItemClipboardAction) then
  begin
    s := Lines.Text;
    FPlannerItem.FPlanner.OnItemClipboardAction(FPlannerItem.FPlanner,FPlannerItem,itPaste,s);
    if s <> Lines.Text then
      Lines.Text := s;
  end;
  }
end;

procedure TPlannerUniMemo.WMCopy(var Msg:TMessage);
{
var
  s:string;
}
begin
  inherited;
  {
  if Assigned(FPlannerItem.FPlanner.OnItemClipboardAction) then
  begin
    s := Lines.Text;
    FPlannerItem.FPlanner.OnItemClipboardAction(FPlannerItem.FPlanner,FPlannerItem,itCopy,s);
    if s <> Lines.Text then
      Lines.Text := s;
  end;
  }
end;

procedure TPlannerUniMemo.WMCut(var Msg:TMessage);
{
var
  s:string;
}
begin
  inherited;
  {
  if Assigned(FPlannerItem.FPlanner.OnItemClipboardAction) then
  begin
    s := Lines.Text;
    FPlannerItem.FPlanner.OnItemClipboardAction(FPlannerItem.FPlanner,FPlannerItem,itCut,s);
    if s <> Lines.Text then
      Lines.Text := s;
  end;
  }
end;

procedure TPlannerUniMemo.KeyDown(var Key: Word; Shift: TShiftState);
begin
  inherited;
  if Key = vk_Escape then
  begin
    Text := PlannerItem.WideText;
    PlannerItem.FPlanner.SetFocus;
  end;
end;

procedure TPlannerUniMemo.DblClick;
begin
  inherited;
  if Assigned(FPlanner.OnItemDblClick) then
    FPlanner.OnItemDblClick(FPlanner, FPlannerItem);
end;

{$ENDIF}
{$ENDIF}

{ TPlannerMaskEdit }

procedure TPlannerMaskEdit.DoExit;
begin
  inherited;
  if Assigned(PlannerItem) then
  begin
    PlannerItem.Text.Text := Self.Text;
    PlannerItem.FPlanner.ItemEdited(PlannerItem);
  end;
  
  Self.Visible := False;
  Self.Parent.SetFocus;
end;

procedure TPlannerMaskEdit.KeyDown(var Key: Word; Shift: TShiftState);
begin
  inherited;
  if Key = vk_Escape then
  begin
    Self.Text := PlannerItem.Text[0];
    PlannerItem.FPlanner.SetFocus;
  end;
end;

procedure TPlannerMaskEdit.StopEdit;
begin
  inherited;
  if Assigned(PlannerItem) then
  begin
    PlannerItem.Text.Text := Text;
    PlannerItem.FPlanner.ItemEdited(PlannerItem);
  end;
  Visible := False;
end;

procedure TPlannerMaskEdit.WMPaste(var Msg:TMessage);
var
  s:string;
begin
  inherited;
  if Assigned(FPlannerItem.FPlanner.OnItemClipboardAction) then
  begin
    s := Text;
    FPlannerItem.FPlanner.OnItemClipboardAction(FPlannerItem.FPlanner,FPlannerItem,itPaste,s);
    if s <> Text then
      Text := s;
  end;
end;

procedure TPlannerMaskEdit.WMCopy(var Msg:TMessage);
var
  s:string;
begin
  inherited;
  if Assigned(FPlannerItem.FPlanner.OnItemClipboardAction) then
  begin
    s := Text;
    FPlannerItem.FPlanner.OnItemClipboardAction(FPlannerItem.FPlanner,FPlannerItem,itCopy,s);
    if s <> Text then
      Text := s;
  end;   
end;

procedure TPlannerMaskEdit.WMCut(var Msg:TMessage);
var
  s:string;
begin
  inherited;
  if Assigned(FPlannerItem.FPlanner.OnItemClipboardAction) then
  begin
    s := Text;
    FPlannerItem.FPlanner.OnItemClipboardAction(FPlannerItem.FPlanner,FPlannerItem,itCut,s);
    if s <> Text then
      Text := s;
  end;
end;

{ TPlannerHeader }

constructor TPlannerHeader.Create(AOwner: TCustomPlanner);
begin
  inherited Create;
  FOwner := AOwner;
  FCaptions := TPlannerStringList.Create;
  FGroupCaptions := TPlannerStringList.Create;
  FHeight := 32;
  FFont := TFont.Create;
  FGroupFont := TFont.Create; 
  FFont.OnChange := FontChanged;
  FGroupFont.OnChange := GroupFontChanged;
  FCaptions.OnChange := ItemsChanged;
  FGroupCaptions.OnChange := ItemsChanged;
  FColor := clBtnFace;
  FColorTo := clWhite;
  FItemColor := clGray;
  FReadOnly := True;
  FFlat := False;
  FTextHeight := 32;
  FItemHeight := 32;
  FLineColor := clGray;
  FVisible := True;
  FResizeAll := True;
  FActiveColor := clNone;
  FActiveColorTo := clNone;
  {$IFNDEF TMSDOTNET}
  //FWideCaptions := TWideStrings.Create;
  //FWideGroupCaptions := TWideStrings.Create;
  {$ENDIF}

  FGroupSpan := TPlannerIntList.Create(nil);
  FCustomGroups := TGroupCollection.Create(Self, TGroupCollectionItem);
  FCustomGroups.OnChange := CustomGroupChange;
end;

destructor TPlannerHeader.Destroy;
begin
  {$IFNDEF TMSDOTNET}
  //FWideCaptions.Free;
  //FWideGroupCaptions.Free;
  {$ENDIF}
  FGroupSpan.Free;
  FCustomGroups.Free;
  FCaptions.Free;
  FGroupCaptions.Free;
  FGroupFont.Free;
  FFont.Free;
  inherited Destroy;
end;

{$IFNDEF TMSDOTNET}
(*
procedure TPlannerHeader.SetWideCaptions(const Value: TWideStrings);
begin
  FWideCaptions.Assign(Value);
end;

procedure TPlannerHeader.SetWideGroupCaptions(const Value: TWideStrings);
begin
  FWideGroupCaptions.Assign(Value);
end;
*)
{$ENDIF}

procedure TPlannerHeader.SetAlignment(const Value: TAlignment);
begin
  FAlignment := Value;
  FOwner.FHeader.Alignment := Value;
end;

procedure TPlannerHeader.SetCaptions(const Value: TPlannerStringList);
begin
  if Assigned(Value) then
    FCaptions.Assign(Value);
  ItemsChanged(Self);
end;

procedure TPlannerHeader.SetImages(const Value: TImageList);
begin
  FImages := Value;
  FOwner.FHeader.Images := Value;
end;

procedure TPlannerHeader.SetImagePosition(const Value: TImagePosition);
begin
  FImagePosition := Value;
  FOwner.FHeader.ImagePosition := Value;
end;



procedure TPlannerHeader.ItemsChanged(Sender: TObject);
var
  SectionIndex, SectionWidth: Integer;
begin
  if (FOwner.FHeader.Sections.Count = 0) then
    Exit;
  SectionIndex := 0;
  while //(SectionIndex < FCaptions.Count) and
    (SectionIndex < FOwner.FHeader.Sections.Count) do
  begin
    SectionWidth := FOwner.FHeader.SectionWidth[SectionIndex];
    if (SectionIndex < FCaptions.Count) then
      FOwner.FHeader.Sections[SectionIndex] := FCaptions.Strings[SectionIndex]
    else
      FOwner.FHeader.Sections[SectionIndex] := '';

    FOwner.FHeader.SectionWidth[SectionIndex] := SectionWidth;
    Inc(SectionIndex);
  end;

end;

procedure TPlannerHeader.FontChanged(Sender: TObject);
begin
  FOwner.FHeader.Font.Assign(FFont);
end;

procedure TPlannerHeader.GroupFontChanged(Sender: TObject);
begin
  FOwner.FHeader.Invalidate;
end;

procedure TPlannerHeader.SetFont(const Value: TFont);
begin
  Self.FFont.Assign(Value);
  FOwner.FHeader.Font.Assign(Value);
end;

procedure TPlannerHeader.SetGroupFont(const Value: TFont);
begin
  Self.FGroupFont.Assign(Value);
  FOwner.FHeader.Invalidate;
end;

procedure TPlannerHeader.SetColor(const Value: TColor);
begin
  FColor := Value;
  FOwner.FHeader.Color := Value;
end;

procedure TPlannerHeader.SetHeight(const Value: Integer);
begin
  FHeight := Value;
  UpdateHeights;
  FOwner.UpdateSizes;

  if (FOwner.PositionWidth = 0) then
  begin
    FOwner.FNoPositionSize := false;
    FOwner.FGrid.UpdatePositions;
  end;
end;

procedure TPlannerHeader.SetVisible(const Value: Boolean);
begin
  if (FVisible <> Value) then
  begin
    FVisible := Value;
    if FVisible then
    begin
      FOwner.Header.Color := Color;
      FOwner.Header.Flat := Flat;
    end;
    FOwner.UpdateSizes;
  end;
end;

procedure TPlannerHeader.SetFlat(const Value: Boolean);
begin
  FFlat := Value;
  FOwner.FHeader.Flat := Value;
  FOwner.FGrid.UpdatePositions;
end;

procedure TPlannerHeader.SetVAlignment(const Value: TVAlignment);
begin
  FVAlignment := Value;
  FOwner.FHeader.VAlignment := Value;
end;

function TPlannerHeader.GetDragDrop: Boolean;
begin
  Result := FOwner.FHeader.SectionDragDrop;
end;

procedure TPlannerHeader.SetDragDrop(const Value: Boolean);
begin
  FOwner.FHeader.SectionDragDrop := Value;
end;

procedure TPlannerHeader.SetReadOnly(const Value: Boolean);
begin
  FReadOnly := Value;
  FOwner.FHeader.SectionEdit := not Value;
end;

procedure TPlannerHeader.UpdateHeights;
begin
  if FOwner.FHeader.Orientation = hoHorizontal then
  begin
    FOwner.FHeader.Height := FHeight;
    FOwner.FHeader.FItemHeight := FItemHeight;
    FOwner.FHeader.FFixedHeight := FHeight - FTextHeight;
    FOwner.FHeader.FTextHeight := FTextHeight;
  end
  else
  begin
    FOwner.FHeader.Width := FHeight;
    FOwner.FHeader.FItemHeight := FItemHeight;
    FOwner.FHeader.FFixedHeight := FHeight - FTextHeight;
    FOwner.FHeader.FTextHeight := FTextHeight;
  end;
end;


procedure TPlannerHeader.SetItemHeight(const Value: Integer);
begin
  FItemHeight := Value;
  UpdateHeights;
  FOwner.FHeader.ShowFixed := Height - TextHeight > 0;
  FOwner.UpdateSizes;
end;

procedure TPlannerHeader.SetTextHeight(const Value: Integer);
begin
  FTextHeight := Value;
  UpdateHeights;
  FOwner.FHeader.ShowFixed := Height - TextHeight > 0;
  FOwner.UpdateSizes;
end;

procedure TPlannerHeader.SetAllowResize(const Value: Boolean);
begin
  FAllowResize := Value;
  FOwner.FHeader.AllowSizing := Value;
  FOwner.FHeader.AllowResize := Value;
end;

procedure TPlannerHeader.SetAllowPositionResize(const Value: Boolean);
begin
  FAllowPositionResize := Value;
  FOwner.FHeader.AllowResize := Value;
end;

function TPlannerHeader.GroupSplit(pos: integer): integer;
var
  i,gs: integer;
begin
  i := 0;
  gs := 0;
  Result := -1;

  while (gs <= pos) and (i < CustomGroups.Count) do
  begin
    if (gs = pos) then
    begin
      Result := CustomGroups[i].Span;
      Exit;
    end;

    gs := gs + CustomGroups[i].Span;
    inc(i);
  end;
end;

function TPlannerHeader.GetGroupCaption(pos: integer): string;
var
  i,gs: integer;
begin
  i := 0;
  gs := 0;
  Result := '';

  while (gs <= pos) and (i < CustomGroups.Count) do
  begin
    if (gs = pos) then
    begin
      Result := CustomGroups[i].Caption;
      Exit;
    end;

    gs := gs + CustomGroups[i].Span;
    inc(i);
  end;

end;


procedure TPlannerHeader.MergeHeader(FromSection, ToSection: Integer);
var
  i,w: Integer;
  s: String;
begin
  for i := FromSection to ToSection do
  begin
    if i < FOwner.FHeader.Sections.Count then
    begin
      w := FOwner.FHeader.SectionWidth[i];

      if i = FromSection then
      begin
        if Pos('#',FOwner.FHeader.Sections[i]) = 1 then
        begin
          s := FOwner.FHeader.Sections[i];
          Delete(s,1,1);
          FOwner.FHeader.Sections[i] := s;
          FOwner.FHeader.SectionWidth[i] := w;
        end;
      end
      else
      begin
        if Pos('#',FOwner.FHeader.Sections[i]) <> 1 then
        begin
          FOwner.FHeader.Sections[i] := '#' + FOwner.FHeader.Sections[i];
          FOwner.FHeader.SectionWidth[i] := w;
        end;
      end;
    end;
  end;
end;

procedure TPlannerHeader.UnMergeHeader(FromSection, ToSection: Integer);
var
  i: Integer;
  s: String;
  w: Integer;
begin
  for i := FromSection to ToSection do
  begin
    if i < FOwner.FHeader.Sections.Count then
    begin
      if Pos('#',FOwner.FHeader.Sections[i]) = 1 then
      begin
        s := FOwner.FHeader.Sections[i];
        w := FOwner.FHeader.SectionWidth[i];
        Delete(s,1,1);
        FOwner.FHeader.Sections[i] := s;
        FOwner.FHeader.SectionWidth[i] := w;
      end;
    end;
  end;
end;

procedure TPlannerHeader.SetAutoSize(const Value: Boolean);
begin
  if FAutoSize <> Value then
  begin
    FAutoSize := Value;
    if FAutoSize then
      FOwner.AutoSizeHeader;
  end;
end;

procedure TPlannerHeader.SetAutoSizeGroupCaption(const Value: boolean);
begin
  if (FAutoSizeGroupCaption <> Value) then
  begin
    FAutoSizeGroupCaption := Value;
    FOwner.FHeader.Invalidate;
  end;
end;

procedure TPlannerHeader.SetItemColor(const Value: TColor);
begin
  FItemColor := Value;
  FOwner.FHeader.FixedColor := Value;
end;

procedure TPlannerHeader.SetGroupCaptions(const Value: TPlannerStringList);
begin
  FGroupCaptions.Assign(Value);
  FOwner.FHeader.Invalidate;
end;

procedure TPlannerHeader.Assign(Source: TPersistent);
begin
  if Assigned(Source) then
  begin
    Alignment := (Source as TPlannerHeader).Alignment;
    AllowResize := (Source as TPlannerHeader).AllowResize;
    AllowPositionResize := (Source as TPlannerHeader).AllowPositionResize;
    AutoSize := (Source as TPlannerHeader).AutoSize;
    Captions.Assign((Source as TPlannerHeader).Captions);
    Color := (Source as TPlannerHeader).Color;
    ColorTo := (Source as TPlannerHeader).ColorTo;
    DragDrop := (Source as TPlannerHeader).DragDrop;
    ReadOnly := (Source as TPlannerHeader).ReadOnly;
    ResizeAll := (Source as TPlannerHeader).ResizeAll;
    Height := (Source as TPlannerHeader).Height;
    Flat := (Source as TPlannerHeader).Flat;
    Font.Assign((Source as TPlannerHeader).Font);
    GroupCaptions.Assign((Source as TPlannerHeader).GroupCaptions);
    Images := (Source as TPlannerHeader).Images;
    ImagePosition := (Source as TPlannerHeader).ImagePosition;
    ItemColor := (Source as TPlannerHeader).ItemColor;
    ItemHeight := (Source as TPlannerHeader).ItemHeight;
    PopupMenu := (Source as TPlannerHeader).PopupMenu;
    TextHeight := (Source as TPlannerHeader).TextHeight;
    VAlignment := (Source as TPlannerHeader).VAlignment;
    Visible := (Source as TPlannerHeader).Visible;
    CustomGroups.Assign((Source as TPlannerHeader).CustomGroups);
    RotateOnLeft := (Source as TPlannerHeader).RotateOnLeft;
    RotateGroupOnLeft := (Source as TPlannerHeader).RotateGroupOnLeft;
    AutoSizeGroupCaption := (Source as TPlannerHeader).AutoSizeGroupCaption;
  end;
end;

procedure TPlannerHeader.SetLineColor(const Value: TColor);
begin
  FLineColor := Value;
  FOwner.FHeader.LineColor := Value;
end;

procedure TPlannerHeader.SetColorTo(const Value: TColor);
begin
  FColorTo := Value;
  FOwner.FHeader.ColorTo := Value;  
end;

{
procedure TPlannerHeader.SetCursor(const Value: TCursor);
begin
  FCursor := Value;
  FOwner.FHeader.Cursor := Value;
end;
}

procedure TPlannerHeader.SetWordWrap(const Value: Boolean);
begin
  FWordWrap := Value;
  FOwner.FHeader.Invalidate;
end;

procedure TPlannerHeader.SetRotateOnLeft(const Value: Boolean);
begin
  FRotateOnLeft := Value;
  FOwner.FHeader.Rotate := Value and (FOwner.Sidebar.Orientation = soHorizontal) ;
end;

procedure TPlannerHeader.SetRotateGroupOnLeft(const Value: Boolean);
begin
  FRotateGroupOnLeft := Value;
  FOwner.FHeader.Invalidate;
end;


procedure TPlannerHeader.SetRotateOnTop(const Value: Boolean);
begin
  FRotateOnTop := Value;
  FOwner.FHeader.Rotate := Value and (FOwner.Sidebar.Orientation = soVertical) ;;
end;

procedure TPlannerHeader.SetActiveColor(const Value: TColor);
begin
  FActiveColor := Value;
  FOwner.FHeader.Invalidate;
end;

procedure TPlannerHeader.SetActiveColorTo(const Value: TColor);
begin
  FActiveColorTo := Value;
  FOwner.FHeader.Invalidate;
end;

procedure TPlannerHeader.SetCustomGroups(const Value: TGroupCollection);
begin
  FCustomGroups := Value;
end;

function TPlannerHeader.GetOwner: TPersistent;
begin
  Result := FOwner;
end;

procedure TPlannerHeader.CustomGroupChange(Sender: TObject);
begin
  FOwner.FHeader.Invalidate;
end;

{ TPlannerMode }

constructor TPlannerMode.Create(AOwner: TCustomPlanner);
var
  Day, Month, Year: Word;
begin
  inherited Create;
  FOwner := AOwner;
  FPlannerType := plDay;
  FWeekStart := 0;
  FUpdateCount := 0;

  DecoDedate(Now, Year, Month, Day);
  FYear := Year;
  FMonth := Month;

  // default start time in DayPeriod mode
  FPeriodStartYear := Year;
  FPeriodStartMonth := Month;
  FPeriodStartDay := Day;

  // default end time in DayPeriod mode
  DecoDedate(Now + 48, Year, Month, Day);
  FPeriodEndYear := Year;
  FPeriodEndMonth := Month;
  FPeriodEndDay := Day;

  FTimeLineStart := Int(Now);
end;

destructor TPlannerMode.Destroy;
begin
  inherited Destroy;
end;

procedure TPlannerMode.SetMonth(const Value: Integer);
begin
  FMonth := Value;
  FOwner.Repaint;
end;

procedure TPlannerMode.SetPlannerType(const Value: TPlannerType);
begin
  FPlannerType := Value;
  FOwner.InactiveChanged(Self);
  FOwner.FGrid.Repaint; 
end;

procedure TPlannerMode.SetWeekStart(const Value: Integer);
begin
  FWeekStart := Value;
  FOwner.FGrid.Repaint;
end;

procedure TPlannerMode.SetYear(const Value: Integer);
begin
  FYear := Value;
  FOwner.Repaint;
end;

procedure TPlannerMode.SetDateTimeFormat(const Value: string);
begin
  FDateTimeFormat := Value;
  FOwner.Repaint;
end;

procedure TPlannerMode.SetPeriodStartDay(const Value: Integer);
begin
  if (Value > 0) and (Value < 32) then
  begin
    FPeriodStartDay := Value;
    UpdatePeriod;
  end;
end;

procedure TPlannerMode.SetPeriodStartMonth(const Value: Integer);
begin
  if (Value > 0) and (Value < 13) then
  begin
    FPeriodStartMonth := Value;
    UpdatePeriod;
  end;
end;

procedure TPlannerMode.SetPeriodStartYear(const Value: Integer);
begin
  FPeriodStartYear := Value;
  UpdatePeriod;
end;

procedure TPlannerMode.SetPeriodEndDay(const Value: Integer);
begin
  if (Value > 0) and (Value < 32) then
  begin
    FPeriodEndDay := Value;
    UpdatePeriod;
  end;
end;

procedure TPlannerMode.SetPeriodEndMonth(const Value: Integer);
begin
  if (Value > 0) and (Value < 13) then
  begin
    FPeriodEndMonth := Value;
    UpdatePeriod;
  end;
end;

procedure TPlannerMode.SetPeriodEndYear(const Value: Integer);
begin
  FPeriodEndYear := Value;
  UpdatePeriod;
end;

function LimitMonth(Month: word):word;
begin
  Result := Month;
  if Result > 12 then Result := 12;
  if Result < 1 then Result := 1;
end;

function LimitDay(Year, Month, Day: word):word;
const
  NumDays : array[1..12] of word = (31,29,31,30,31,30,31,31,30,31,30,31);
begin

  if Day > NumDays[Month] then
    Result := NumDays[Month]
  else
    Result := Day;

  if (Month = 2) and (Result = 29) then
    if (Year mod 4 <> 0) then
      Result := 28;
end;

function EncodePlannerDate(Year, Month, Day: Word): TDateTime;
begin
   if (Year = 0) or (Month = 0) or (Day = 0) then
    Result := 0
  else
    try
      Month := LimitMonth(Month);
      Day := LimitDay(Year,Month,Day);

      Result := EncodeDate(Year, Month, Day);
    except
      Result := 0;
    end;
end;

function TPlannerMode.GetPeriodEndDate: TDateTime;
begin
  case PlannerType of
  plDay,plHalfDayPeriod: Result := EncodePlannerDate(PeriodEndYear, PeriodEndMonth, PeriodEndDay);
  plMonth,plWeek: Result := GetStartOfMonth +
                    (FOwner.Display.FDisplayEnd - FOwner.Display.FDisplayStart)
  else
    Result := EncodePlannerDate(PeriodEndYear, PeriodEndMonth, PeriodEndDay);
  end;
end;

function TPlannerMode.GetPeriodStartDate: TDateTime;
begin
  case PlannerType of
  plDay,plHalfDayPeriod: Result := EncodePlannerDate(PeriodStartYear, PeriodStartMonth, PeriodStartDay);
  plWeek, plMonth: Result := GetStartOfMonth
  else
    Result := EncodePlannerDate(PeriodStartYear, PeriodStartMonth, PeriodStartDay);
  end;
end;

function TPlannerMode.GetStartOfMonth: TDateTime;
var
  Diff: Integer;
begin
  Result := EncodePlannerDate(Year, Month, 1);
  if PlannerType = plWeek then
  begin
    Diff := (7 - WeekStart) - DayOfWeek(Result);
    if Diff > 0 then
      Diff := Diff - 7;
    Result := Result + Diff;
  end;
end;

procedure TPlannerMode.UpdatePeriod;
var
  DS,DE: TDateTime;
begin
  if FUpdateCount > 0 then
    Exit;

  DS := EncodePlannerDate(FPeriodStartYear,FPeriodStartMonth,FPeriodStartDay);
  DE := EncodePlannerDate(FPeriodEndYear,FPeriodEndMonth,FPeriodEndDay);

  if (DS <= DE) and (DS > 0) and (DE > 0) and
     not (csLoading in FOwner.ComponentState) and
     (PlannerType = plDayPeriod) then
  begin
    FOwner.Display.BeginUpdate;
    FOwner.Display.DisplayStart := 0;
    FOwner.Display.DisplayEnd := Trunc(DE - DS);
    FOwner.Display.EndUpdate;
  end;

  if (DS <= DE) and (DS > 0) and (DE > 0) and
     not (csLoading in FOwner.ComponentState) and
     (PlannerType = plHalfDayPeriod) then
  begin
    FOwner.Display.BeginUpdate;
    FOwner.Display.DisplayStart := 0;
    FOwner.Display.DisplayEnd := 2 * Trunc(DE - DS) + 1;
    FOwner.Display.EndUpdate;
  end;

  FOwner.Invalidate;
end;

procedure TPlannerMode.SetPeriodEndDate(const Value: TDateTime);
var
  Da,Mo,Ye: word;
begin
  DecodeDate(Value,Ye,Mo,Da);
  FPeriodEndYear := Ye;
  FPeriodEndMonth := Mo;
  FPeriodEndDay := Da;
  UpdatePeriod;
end;

procedure TPlannerMode.SetPeriodStartDate(const Value: TDateTime);
var
  Da,Mo,Ye: word;
begin
  DecodeDate(Value,Ye,Mo,Da);
  FPeriodStartYear := Ye;
  FPeriodStartMonth := Mo;
  FPeriodStartDay := Da;
  UpdatePeriod;
end;

procedure TPlannerMode.BeginUpdate;
begin
  Inc(FUpdateCount);
end;

procedure TPlannerMode.EndUpdate;
begin
  if FUpdateCount > 0 then
  begin
    Dec(FUpdateCount);
    if FUpdateCount = 0 then
      UpdatePeriod;
  end;
end;

procedure TPlannerMode.SetTimeLineStart(const Value: TDateTime);
begin
  FTimeLineStart := Value;
  FOwner.FGrid.Invalidate;
end;

procedure TPlannerMode.Assign(Source: TPersistent);
begin
  if (Source is TPlannerMode) then
  begin
    FClip := (Source as TPlannerMode).Clip;
    FDateTimeFormat := (Source as TPlannerMode).DateTimeFormat;
    FMonth := (Source as TPlannerMode).Month;
    PeriodStartDay := (Source as TPlannerMode).PeriodStartDay;
    PeriodStartMonth := (Source as TPlannerMode).PeriodStartMonth;
    PeriodStartYear := (Source as TPlannerMode).PeriodStartYear;
    PeriodEndDay := (Source as TPlannerMode).PeriodEndDay;
    PeriodEndMonth := (Source as TPlannerMode).PeriodEndMonth;
    PeriodEndYear := (Source as TPlannerMode).PeriodEndYear;
    PlannerType := (Source as TPlannerMode).PlannerType;
    TimeLineStart := (Source as TPlannerMode).TimeLineStart;
    WeekStart := (Source as TPlannerMode).WeekStart;
    Year := (Source as TPlannerMode).Year;
  end;
end;

procedure TPlannerMode.SetTimeLineNVUBegin(const Value: Integer);
begin
  FTimeLineNVUBegin := Value;
  FOwner.FGrid.Invalidate;  
end;

procedure TPlannerMode.SetTimeLineNVUEnd(const Value: Integer);
begin
  FTimeLineNVUEnd := Value;
  FOwner.FGrid.Invalidate;
end;

{ TPlannerIO }

constructor TPlannerIO.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FItems := (AOwner as TCustomPlanner).CreateItems;
end;

destructor TPlannerIO.Destroy;
begin
  FItems.Free;
  inherited Destroy;
end;

{ TNavigatorButtons }

constructor TNavigatorButtons.Create(AOwner: TCustomPlanner);
begin
  FOwner := AOwner;
  inherited Create;
  FVisible := True;
  FFlat := True;
end;

procedure TNavigatorButtons.SetFlat(const Value: Boolean);
begin
  FFlat := Value;
  FOwner.FNext.Flat := Value;
  FOwner.FPrev.Flat := Value;
end;

procedure TNavigatorButtons.SetNextHint(const Value: string);
begin
  FNextHint := Value;
  FOwner.FNext.Hint := Value;
end;

procedure TNavigatorButtons.SetPrevHint(const Value: string);
begin
  FPrevHint := Value;
  FOwner.FPrev.Hint := Value;
end;

procedure TNavigatorButtons.SetShowHint(const Value: Boolean);
begin
  FShowHint := Value;
  FOwner.FNext.ShowHint := Value;
  FOwner.FPrev.ShowHint := Value;
end;

procedure TNavigatorButtons.SetVisible(Value: Boolean);
begin
  FVisible := Value;
  FOwner.FCaption.UpdatePanel;
  FOwner.FGrid.UpdatePositions;
end;


{TPlannerRichEdit}

procedure TPlannerRichEdit.DoEnter;
begin
  inherited;
  SelStart := 0;
  SelLength := $FFFF;
end;

procedure TPlannerRichEdit.DoExit;
begin
  inherited;
  if Assigned(PlannerItem) then
  begin
    PlannerItem.Text.Text := PlannerItem.FPlanner.RichToText;
    PlannerItem.FPlanner.ItemEdited(PlannerItem);
  end;
  Self.Visible := False;
  Self.Parent.SetFocus;
end;

procedure TPlannerRichEdit.KeyDown(var Key: Word; Shift: TShiftState);
begin
  inherited;
  if Key = vk_Escape then
  begin
    PlannerItem.FPlanner.TextToRich(PlannerItem.Text.Text);
    PlannerItem.FPlanner.SetFocus;
  end;
end;

constructor TPlannerIntList.Create(Value: TPlannerItem);
begin
  inherited Create;
  FPlannerItem := Value;
end;

procedure TPlannerIntList.SetInteger(Index: Integer; Value: Integer);
begin
  inherited Items[Index] := TObject(Value);

  if Assigned(OnChange) then
    OnChange(Self);
end;

function TPlannerIntList.GetInteger(Index: Integer): Integer;
begin
  Result := Integer(inherited Items[Index]);
end;

procedure TPlannerIntList.Clear;
begin
  inherited;
  if Assigned(OnChange) then
    OnChange(Self);
end;

procedure TPlannerIntList.Add(Value: Integer);
begin
  inherited Add(TObject(Value));
  if Assigned(OnChange) then
    OnChange(Self);
end;

procedure TPlannerIntList.Delete(Index: Integer);
begin
  inherited Delete(Index);
  if Assigned(OnChange) then
    OnChange(Self);
end;

{ TAdvHeader }

constructor TAdvHeader.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FColor := clBtnFace;
  FColorTo := clWhite;
  FFixedColor := clGray;
  FLineColor := clGray;
  FLeftPos := 0;
  FSectionDragDrop := False;
  FTextHeight := 32;
  FItemHeight := 16;
  FShowFixed := True;

  if not (csDesigning in ComponentState) then
  begin
    FInplaceEdit := TMemo.Create(Self);
    FInplaceEdit.Parent := Self;
    FInplaceEdit.Visible := False;
    FInplaceEdit.OnExit := InplaceExit;
  end;

  Zoom := False;
  ZoomCol := -1;
  ShowHint := True;
  Hint := '';
  FLastHintPos := Point(-1,-1);
end;

destructor TAdvHeader.Destroy;
begin
  if not (csDesigning in ComponentState) then
    FInplaceEdit.Free;
  inherited;
end;

procedure TAdvHeader.InplaceExit(Sender: TObject);
var
  EditIdx: Integer;
  s: string;
begin
//  EditIdx := GetSectionIdx(FEditSection);
  EditIdx := FEditSection;

  s := LFToCLF(FInplaceEdit.Text);

  if Assigned((Owner as TCustomPlanner).OnHeaderEndEdit) then
    (Owner as TCustomPlanner).OnHeaderEndEdit(Owner, EditIdx, s);

  (Owner as TCustomPlanner).FEditMode := False;

  Sections[EditIdx] := s;
  SectionWidth[EditIdx] := FEditWidth;
  FInplaceEdit.Visible := False;
end;

procedure TAdvHeader.CreateToolTip;
begin
  fhToolTip := CreateWindowEx(0, 'Tooltips_Class32', nil, TTS_ALWAYSTIP or TTS_BALLOON or TTS_NOPREFIX,
    Integer(CW_USEDEFAULT), Integer(CW_USEDEFAULT),Integer(CW_USEDEFAULT),
    Integer(CW_USEDEFAULT), Handle, 0, hInstance, nil);

  if fhToolTip <> 0 then
    SetWindowPos(fhToolTip, HWND_TOPMOST, 0, 0, 0, 0, SWP_NOMOVE or SWP_NOSIZE or SWP_NOACTIVATE);
end;

procedure TAdvHeader.DestroyToolTip;
begin
  DestroyWindow(fhToolTip);
end;


procedure TAdvHeader.AddToolTip(IconType: Integer; Text, Title: string);
{$IFDEF TMSDOTNET}
type
  [StructLayout(LayoutKind.Sequential, CharSet = CharSet.Unicode)]
  TTOOLINFOEX = packed record
    cbSize: UINT;
    uFlags: UINT;
    hwnd: HWND;
    uId: UINT;
    Rect: TRect;
    hInst: THandle;
    lpszText: IntPtr;
    lParam: LPARAM;
  end;
{$ENDIF}
var
  Item: THandle;
  Rect: TRect;
  {$IFDEF TMSDOTNET}
  ti: TToolInfoEx;
  {$ENDIF}
  {$IFNDEF TMSDOTNET}
  ti: TToolInfo;
  {$ENDIF}
  buffer: array[0..255] of char;
  {$IFDEF TMSDOTNET}
  Mem: IntPtr;
  {$ENDIF}
begin
  Item := self.Handle;

  if (Item <> 0) AND (Windows.GetClientRect(Item, Rect)) then
  begin
    {$IFNDEF TMSDOTNET}
    ti.cbSize := SizeOf(TToolInfo);
    {$ENDIF}

    {$IFDEF TMSDOTNET}
    ti.cbSize := Marshal.SizeOf(TypeOf(TToolInfo));
    {$ENDIF}

    ti.uFlags := TTF_SUBCLASS or TTF_IDISHWND ;
    ti.hInst := hInstance;

    ti.hwnd := Item;
    ti.Rect := Rect;
    ti.uId := Handle;

    {$IFDEF TMSDOTNET}

    ti.lpszText := IntPtr(LPSTR_TEXTCALLBACK);

    try
      Mem := Marshal.AllocHGlobal(Marshal.SizeOf(TypeOf(ti)));
      Marshal.StructureToPtr(TObject(ti),Mem,False);
      SendMessage(fhToolTip, TTM_ADDTOOL, 0, Longint(mem));
    finally
      Marshal.FreeHGlobal(Mem);
    end;
    if (IconType > 3) or (IconType < 0) then IconType := 0;
    SendTextMessage(fhToolTip, TTM_SETTITLE, IconType, Title);

    {$ENDIF}

    {$IFNDEF TMSDOTNET}
    ti.lpszText :=  LPSTR_TEXTCALLBACK;
    SendMessage(fhToolTip, TTM_ADDTOOL, 0, Integer(@ti));
    FillChar(buffer, sizeof(buffer), #0);
    lstrcpy(buffer, PChar(Title));
    if (IconType > 3) or (IconType < 0) then IconType := 0;
    SendMessage(fhToolTip, TTM_SETTITLE, IconType, Integer(@buffer));
    {$ENDIF}
  end;
end;



procedure TAdvHeader.SetAlignment(const Value: TAlignment);
begin
  FAlignment := Value;
  Invalidate;
end;

procedure TAdvHeader.SetVAlignment(const Value: TVAlignment);
begin
  FVAlignment := Value;
  Invalidate;
end;

procedure TAdvHeader.SetColor(const Value: TColor);
begin
  FColor := Value;
  Invalidate;
end;

procedure TAdvHeader.SetLineColor(const Value: TColor);
begin
  FLineColor := Value;
  Invalidate;
end;

procedure TAdvHeader.SetImageList(const Value: TImageList);
begin
  FImageList := Value;
  Invalidate;
end;

procedure TAdvHeader.SetOrientation(const Value: THeaderOrientation);
begin
  FOrientation := Value;
  Invalidate;
end;

procedure TAdvHeader.SetFlat(const Value: Boolean);
begin
  FFlat := Value;
  Invalidate;
end;

procedure TAdvHeader.SetImagePosition(const Value: TImagePosition);
begin
  FImagePosition := Value;
  Invalidate;
end;

function TAdvHeader.GetSectionRect(X: Integer): TRect;
var
  Offset, SectionIndex: Integer;
begin
  Offset := 0;

  for SectionIndex := FLeftPos to X - 1 do
  begin
    if SectionIndex = FLeftPos then
      Offset := Offset + SectionWidth[0]
    else
      Offset := Offset + SectionWidth[SectionIndex];
  end;

  if FOrientation = hoHorizontal then
  begin
    Result.Left := Offset;
    Result.Right := Offset + SectionWidth[X];
    Result.Top := 0;
    Result.Bottom := Self.Height;
  end
  else
  begin
    Result.Left := 0;
    Result.Right := Self.Width;
    Result.Top := Offset;
    Result.Bottom := Offset + SectionWidth[X];
  end;

end;

function TAdvHeader.XYToSection(X, Y: Integer): Integer;
var
  Ofs, SectionIndex: Integer;
begin
  Ofs := 0;
  SectionIndex := FLeftPos;

  if FOrientation = hoHorizontal then
  begin
    while (Ofs < X) and (SectionIndex < Sections.Count) do
    begin
      if SectionIndex = FLeftPos then
        Ofs := Ofs + SectionWidth[0]
      else
        Ofs := Ofs + SectionWidth[SectionIndex];
      Inc(SectionIndex);
    end;
    Dec(SectionIndex);
  end
  else
  begin

    while (Ofs < Y) and (SectionIndex < Sections.Count) do
    begin
      if SectionIndex = FLeftPos then
        Ofs := Ofs + SectionWidth[0]
      else
        Ofs := Ofs + SectionWidth[SectionIndex];
      Inc(SectionIndex);
    end;
    Dec(SectionIndex);
  end;

  Result := SectionIndex;
end;

procedure TAdvHeader.Paint;
var
  SectionIndex, w, AIdx,BIdx,MergeNum: Integer;
  s:string;
  CT,CID,CV: string;
  cr,rct: TRect;
  DrawFlags: DWord;
  DrawGroupFlags: DWord;
  r: TRect;
  pr: TRect;
  tr: TRect;
  HorizontalAlign: Word;
  VerticalAlign: Word;
  AllPainted: Boolean;
  APlannerItem: TPlannerItem;
  DoDraw: Boolean;
  Anchor,Strip,FocusAnchor: string;
  ml,hl,XSize,YSize: integer;
  hr: TRect;
  Planner: TCustomPlanner;
  Orgx,Oldx,GroupIdx: Integer;
  LastRow: Boolean;
  lf : TLogFont;
  tf : TFont;
  vimg: Integer;
  SideOffset: integer;
  spanidx: integer;
  IsGroup: boolean;
  GroupCaption: string;
  GroupWideCaption: widestring;
  GroupImage: integer;
  GroupFontHeight: integer;
  prhbottom: Integer;

  function IsSideSection(APlanner: TCustomPlanner;Idx: Integer): Boolean;
  begin
    case APlanner.Sidebar.Position of
    spLeft,spTop: Result := Idx = 1;
    spRight: Result := Idx >= APlanner.Positions + 1;
    spLeftRight: Result := (Idx = 1) or (Idx > APlanner.Positions + 1);
    else
      Result := false;
    end;
  end;

begin
  Planner := Owner as TCustomPlanner;

  Planner.Header.GroupSpan.Clear;

  spanidx := 0;

  if Planner.Header.AutoSizeGroupCaption then
  begin
    tf := TFont.Create;
    tf.Assign(Canvas.Font);
    try
      Canvas.Font.Assign(Planner.Header.GroupFont);
      GroupFontHeight := Canvas.TextHeight('gh') + 4;
      Canvas.Font.Assign(tf);
    finally
      tf.Free;
    end;
  end
  else
    GroupFontHeight := (FTextHeight shr 1);

  if Planner.Header.CustomGroups.Count > 0 then
  begin
    for w := 1 to Planner.Header.CustomGroups.Count do
    begin
      spanidx := spanidx + Planner.Header.CustomGroups[w - 1].Span;
      Planner.Header.GroupSpan.Add(spanidx);
    end;

    while Planner.Header.GroupSpan.Count <= Planner.Positions do
    begin
      Planner.Header.GroupSpan.Add(spanidx);
      inc(spanidx);
    end;
  end;

  spanidx := 0;

  // adapt for scroll position
  if FLeftPos > 0 then
  begin
    while (spanidx < Planner.Header.GroupSpan.Count) and (FLeftPos >= Planner.Header.GroupSpan[spanidx]) do
      inc(spanidx);
  end;

  SideOffset := 2;

  if Planner.Sidebar.Position = spRight then
    SideOffset := 1;

  with Canvas do
  begin
    Font := Self.Font;
    Brush.Color := FColor;

    if FLineColor = clNone then
      Pen.Color := FColor
    else
      Pen.Color := FLineColor;

    Pen.Width := 1;
    SectionIndex := 0;
    OrgX := 0;

    if (Orientation = hoHorizontal) then
      r := Rect(0, 0, 0, ClientHeight)
    else
      r := Rect(0, 0, ClientWidth, 0);

    AIdx := 0;
    w := 0;
    s := '';

    HorizontalAlign := AlignToFlag(FAlignment);
    VerticalAlign := 0;

    AllPainted := False;
    repeat
      MergeNum := 1;

      if SectionIndex + FLeftPos < Sections.Count then
      begin
        if SectionIndex > 0 then
          w := SectionWidth[SectionIndex + FLeftPos]
        else
          w := SectionWidth[SectionIndex];


        if (w < 0) and (Orientation = hoVertical) then
        begin
          w := Planner.FGrid.RowHeights[SectionIndex];
        end;

        if Flat and (SectionIndex = 0) and (Orientation = hoHorizontal) then
          dec(w);

        if not Flat and (SectionIndex = 0) and (Orientation = hoVertical) then
          inc(w);

        VerticalAlign := VAlignToFlag(FVAlignment);

        // get the caption text

        s := '';

        if FOffset = 1 then
        begin
          if (SectionIndex <= Sections.Count - 1 - FLeftPos) and (SectionIndex > 0) then
          begin
            AIdx := SectionIndex + FLeftPos;
            s := Sections[AIdx];
          end
          else
          begin
            AIdx := -1;
            if SectionIndex = 0 then
              s := Sections[0];
          end;
        end
        else
        begin
          if (SectionIndex < Sections.Count - FLeftPos) then
            AIdx := SectionIndex + 1 + FLeftPos - 1
          else
            AIdx := 0;
          s := Sections[AIdx];
        end;

        // merged cells
        if (Pos('#',s) = 1) and (AIdx > 0) then
        begin
          BIdx := AIdx - 1;
          while (BIdx >= 0) and (Pos('#',Sections[BIdx]) = 1) do
          begin
            Dec(BIdx);
          end;
          s := Sections[BIdx];
        end;

        if AIdx <> -1 then
        begin
          BIdx := AIdx + 1;
          while (BIdx < Sections.Count) do
          begin
            if Pos('#',Sections[BIdx]) = 1 then
            begin
              w := w + SectionWidth[SectionIndex];
              inc(MergeNum);
            end
            else
              break;
            inc(BIdx);
          end;
        end;

        Inc(SectionIndex,MergeNum);
      end;

      if (Orientation = hoHorizontal) then
      begin
        r.Left := r.Right;
        Inc(r.Right, w);

        r.Bottom := ClientHeight;

        if (ClientWidth - r.Right < 2) or (SectionIndex + FLeftPos = Sections.Count) then
        begin
          r.Right := ClientWidth;
          AllPainted := True;
        end;
      end
      else
      begin
        r.Top := r.Bottom;
        Inc(r.Bottom, w);

        if (ClientHeight - r.Bottom < 2) or (SectionIndex + FLeftPos = Sections.Count) then
        begin
          r.Bottom := ClientHeight;
          AllPainted := True;
        end;
      end;

      pr := r;

      if FShowFixed and not IsSideSection(Planner,SectionIndex) then
      begin
        Canvas.Brush.Color := FFixedColor;

        if Orientation = hoHorizontal then
          r.Top := r.Bottom - FFixedHeight
        else
          r.Left := r.Right - FFixedHeight;

        FillRect(r);
        r := pr;

        if Orientation = hoHorizontal then
          r.Bottom := r.Bottom - FFixedHeight
        else
          r.Right := r.Right - FFixedHeight;

        Canvas.Brush.Color := FColor;

        if (Planner.Header.ActiveColor <> clNone) and (SectionIndex + FLeftPos - SideOffset = Planner.SelPosition) then
        begin
          Canvas.Brush.Color := Planner.Header.ActiveColor;
          if Planner.Header.ActiveColorTo <> clNone then
            DrawGradient(Canvas, Planner.Header.ActiveColor,Planner.Header.ActiveColorTo, Planner.GradientSteps, r, Orientation = hoVertical)
          else
            FillRect(r);
        end
        else
        begin
          if FColorTo <> clNone then
            DrawGradient(Canvas,FColor,FColorTo,64,r,Orientation = hoVertical)
          else
            FillRect(r);
        end;

        r := pr;
      end
      else
      begin
        if (Planner.Header.ActiveColor <> clNone) and (SectionIndex + FLeftPos - SideOffset = Planner.SelPosition) then
        begin
          Canvas.Brush.Color := Planner.Header.ActiveColor;
          if Planner.Header.ActiveColorTo <> clNone then
            DrawGradient(Canvas, Planner.Header.ActiveColor,Planner.Header.ActiveColorTo, Planner.GradientSteps, r,  Orientation = hoVertical)
          else
           FillRect(r);
        end
        else
        begin
          if FColorTo <> clNone then
            DrawGradient(Canvas,FColor,FColorTo,64,r,Orientation = hoVertical)
          else
            FillRect(r);
        end;
      end;

      if FLineColor = clNone then
        Pen.Color := FColor
      else
        Pen.Color := FLineColor;

      DoDraw := True;

      if Assigned(Planner.FOnPlannerHeaderDraw) then
      begin
        Font := Self.Font;
        Brush.Color := FColor;
        Pen.Color := FLineColor;
        Pen.Width := 1;
        Planner.FOnPlannerHeaderDraw(TCustomPlanner(Owner), Canvas, r, AIdx, DoDraw);
      end;

      LastRow := false;

      if (Orientation = hoVertical) and (SectionIndex > Planner.GridControl.VisibleRowCount + 2) then
        LastRow := true;


      if DoDraw then
      begin
        InflateRect(pr, -4, 0);

        if Assigned(FImageList) and (FImageList.Count + 1 + FOffset - FLeftPos >
          SectionIndex) and (SectionIndex > FOffset)
          and (SectionIndex <= Sections.Count - 1 - FLeftPos) then
        begin
          vimg := pr.Top;
          if Planner.PositionGroup > 0 then
            vimg := pr.Top + FTextHeight div 2;

          prhbottom := pr.Top + Planner.Header.TextHeight;

          case FVAlignment of
          vtaCenter: vimg := vimg + ((prhBottom - vimg - FImageList.Height) div 2);
          vtaBottom: vimg := prhBottom - FImageList.Height;
          end;

          if FImagePosition = ipLeft then
          begin
            FImageList.Draw(Canvas, pr.Left, vimg, SectionIndex - 1 - FOffset +
              FLeftPos);
            pr.Left := pr.Left + FImageList.Width;
          end
          else
          begin
            pr.Right := pr.Right - FImageList.Width;
            FImageList.Draw(Canvas, pr.Right, vimg, SectionIndex - 1 - FOffset + FLeftPos);
          end;
        end;

        s := CLFToLF(s);

        if Pos(#13, s) = 0 then
          VerticalAlign := VerticalAlign or DT_SINGLELINE
        else
          VerticalAlign := 0;

        if (Orientation = hoHorizontal) then
           pr.Bottom := pr.Top + FTextHeight;

        // adapt header height / width when position groups are used
        if (Planner.PositionGroup > 0) and (Orientation = hoHorizontal)  then
        begin
          pr.Top := pr.Top + GroupFontHeight;
        end;

        if (Planner.PositionGroup > 0) and (Orientation = hoVertical)  then
        begin
          pr.Left := pr.Left + GroupFontHeight;
        end;

        if (Orientation = hoVertical) then
        begin
          pr.Right :=  FTextHeight;
          pr.Bottom := pr.Top + w - 2;
        end;

        DrawFlags := DT_NOPREFIX or DT_END_ELLIPSIS or HorizontalAlign or VerticalAlign;

        if Planner.Header.WordWrap then
          DrawFlags := DrawFlags and not DT_SINGLELINE and not DT_END_ELLIPSIS or DT_WORDBREAK;

        {$IFDEF DELPHI4_LVL}
        DrawFlags := Planner.DrawTextBiDiModeFlags(DrawFlags);
        {$ENDIF}

        if not LastRow then
        begin
          if Pos('</',s) > 0 then
          begin
            HTMLDrawEx(Canvas,s,pr,Planner.PlannerImages,0,0,-1,-1,1,False,False,False,False,False,False,True
              , False
              ,1,
              clBlue,clNone,clNone,clgray,Anchor,Strip,FocusAnchor,XSize,YSize,ml,hl,hr
              ,cr, CID, CV, CT, Planner.FImageCache,Planner.FContainer, Handle
              );
          end
          else
          begin
            Canvas.Brush.Style := bsClear;

            if Rotate or (Planner.Header.RotateOnLeft and (Planner.SideBar.Position = spTop)) then
            begin
              tf := TFont.Create;
              try
                tf.Assign(Font);
                {$IFNDEF TMSDOTNET}
                GetObject(tf.Handle, SizeOf(lf), @lf);
                {$ENDIF}
                {$IFDEF TMSDOTNET}
                GetObject(tf.Handle, Marshal.SizeOf(TypeOf(lf)), lf);
                {$ENDIF}

                lf.lfEscapement := 900;
                lf.lfOrientation := 900;
                tf.Handle := CreateFontIndirect(lf);
                Canvas.Font.Assign(tf);

                while pos(#13, s) > 0 do
                begin
                  case Planner.Header.Alignment of
                  taLeftJustify: TextRect(pr,pr.Left,r.Bottom - 4,copy(s,1,pos(#13,s)-1));
                  taCenter: TextRect(pr,pr.Left,r.Bottom - ((r.Bottom - r.Top - TextWidth(copy(s,1,pos(#13,s)))) div 2),copy(s,1,pos(#13,s)-1));
                  taRightJustify: TextRect(pr,pr.Left, r.Top + TextWidth(copy(s,1,pos(#13,s))),copy(s,1,pos(#13,s)));
                  end;

                  delete(s,1,pos(#13,s)+1);
                  pr.Left  := pr.Left + TextHeight('gh');
                end;

                case Planner.Header.Alignment of
                taLeftJustify: TextRect(pr,pr.Left,r.Bottom - 4,s);
                taCenter: TextRect(pr,pr.Left,r.Bottom - ((r.Bottom - r.Top -  TextWidth(s)) div 2),s);
                taRightJustify: TextRect(pr,pr.Left,r.Top + TextWidth(s) + 4,s);
                end;

              finally
                tf.Free;
              end;
            end
            else
              {$IFNDEF TMSDOTNET}
              DrawText(Canvas.Handle, PChar(s), Length(s), pr, DrawFlags);
              {$ENDIF}
              {$IFDEF TMSDOTNET}
              DrawText(Canvas.Handle, s, Length(s), pr, DrawFlags);
              {$ENDIF}

          end;
        end;

        if FShowFixed and (Orientation = hoHorizontal) and (SectionIndex > 1) then
          r.Bottom := r.Bottom - FFixedHeight;

        if (Orientation = hoVertical) and (SectionIndex + FLeftPos = Sections.Count - 1) then
          r.Bottom  := r.Bottom - 1;

        if FShowFixed and (Orientation = hoVertical) and (SectionIndex > 1) then
          r.Right := r.Right - FFixedHeight;

        // adapt header width / height when positiongroups are used
        if (Planner.PositionGroup > 0) and (Orientation = hoHorizontal) and (SectionIndex > 1) then
          r.Top := r.Top + FTextHeight div 2;

        if (Planner.PositionGroup > 0) and (Orientation = hoVertical) and (SectionIndex > 1) then
          r.Left := r.Left + FTextHeight div 2;

//          r.Left := r.Left + GroupFontHeight;

        rct := r;

        if (SectionIndex  > 1) and (Orientation = hoVertical) and (Planner.PositionGroup > 0) then
          rct.Left := GroupFontHeight;

        if (SectionIndex  > 1) and (Orientation = hoHorizontal) and (Planner.PositionGroup > 0) then
          rct.Top := GroupFontHeight;

        if not FFlat then
        begin
          DrawEdge(Canvas.Handle, rct, BDR_RAISEDINNER, BF_TOPLEFT);
          DrawEdge(Canvas.Handle, rct, BDR_RAISEDINNER, BF_BOTTOMRIGHT);

        end
        else
        begin
          if (SectionIndex > 1) and (Orientation = hoHorizontal) and (FLineColor <> clNone) then
          begin
            Canvas.MoveTo(rct.Left + 2, rct.Top);
            Canvas.LineTo(rct.Left + 2, rct.Bottom);
          end;

          if (SectionIndex > 1) and (Orientation = hoVertical) and (FLineColor <> clNone) then
          begin
            Canvas.MoveTo(rct.Left + 2, rct.Top + 2);
            Canvas.LineTo(rct.Right, rct.Top + 2);
          end;
        end;

        // horizontal positiongroup painting
        if (Planner.PositionGroup > 0) and (Orientation = hoHorizontal) and (SectionIndex > 1) then
        begin
          if SectionIndex = 2 then
            orgx := r.Left;

          r.Top := r.Top - FTextHeight div 2;
          r.Bottom := r.Top + FTextHeight div 2;

          GroupImage := -1;

          if Planner.Header.CustomGroups.Count > 0 then
          begin
            IsGroup := ((SectionIndex - 1 + FLeftPos) = Planner.Header.GroupSpan[spanidx]);

            GroupWideCaption := '';
            GroupCaption := '';

            if IsGroup then
            begin
              if (Planner.Header.CustomGroups.Count > spanidx) then
              begin
                {$IFNDEF TMSDOTNET}
                GroupWideCaption := Planner.Header.CustomGroups[spanidx].WideCaption;
                {$ENDIF}
                GroupCaption := Planner.Header.CustomGroups[spanidx].Caption;
                GroupImage := Planner.Header.CustomGroups[spanidx].ImageIndex;
              end;
              inc(spanidx);
            end;
          end
          else
          begin
            IsGroup := ((SectionIndex - 1 + FLeftPos) mod Planner.PositionGroup = 0);
            GroupIdx := (SectionIndex - 2 + FLeftPos) div Planner.PositionGroup;
            if Planner.Header.GroupCaptions.Count > GroupIdx then
            begin
              GroupCaption := CLFToLF(Planner.Header.GroupCaptions.Strings[GroupIdx]);
            end
            else
              GroupCaption := '';
          end;


          // need to paint new positiongroup here ?
          if IsGroup or AllPainted then
          begin
            //inc(spanidx);
            oldx := r.Left;
            r.Left := orgx;
            rct := r;
            rct.Bottom := GroupFontHeight;

            if not FFlat then
            begin

              DrawEdge(Canvas.Handle, rct, BDR_RAISEDINNER, BF_TOPLEFT);
              DrawEdge(Canvas.Handle, rct, BDR_RAISEDINNER, BF_BOTTOMRIGHT);
            end
            else
            begin
              OffsetRect(rct,2,0);

              Canvas.MoveTo(rct.Left,rct.Top);
              Canvas.LineTo(rct.Right,rct.Top);
              Canvas.LineTo(rct.Right,rct.Bottom);
              Canvas.LineTo(rct.Left,rct.Bottom);
              Canvas.LineTo(rct.Left,rct.Top);

              OffsetRect(rct,-2,0);
            end;

            s := GroupCaption;

            VerticalAlign := VAlignToFlag(Planner.Header.FVAlignment);

            if Pos(#13, s) = 0 then
              DrawGroupFlags := DT_NOPREFIX or HorizontalAlign or DT_SINGLELINE or VerticalAlign
            else
              DrawGroupFlags := DT_NOPREFIX or HorizontalAlign or DT_WORDBREAK or VerticalAlign;

            {$IFDEF DELPHI4_LVL}
            DrawGroupFlags := Planner.DrawTextBiDiModeFlags(DrawGroupFlags);
            {$ENDIF}


            Canvas.Font.Assign(Planner.Header.GroupFont);

            if (GroupImage >= 0) and Assigned(Planner.PlannerImages) then
            begin
              Planner.PlannerImages.Draw(Canvas, rct.Left, rct.Top, GroupImage);
              rct.Left := rct.Left + 2 + Planner.PlannerImages.Width;
            end;

            // Draw text transparent
            Canvas.Brush.Style := bsClear;

            rct.Left:= rct.Left + 4;


            // HTML rendering
            if Pos('</',s) > 0 then
            begin
              HTMLDrawEx(Canvas,s,rct,Planner.PlannerImages,0,0,-1,-1,1,False,False,False,False,False,False,True
                , False
                ,1, clBlue,clNone,clNone,clgray,Anchor,Strip,FocusAnchor,XSize,YSize,ml,hl,hr
                , cr, CID, CV, CT, Planner.FImageCache,Planner.FContainer, Handle
                );
            end
            else
            begin
              if (GroupWideCaption <> '') then
              begin
                {$IFNDEF TMSDOTNET}
                DrawTextExW(Canvas.Handle, PWideChar(GroupWideCaption), Length(GroupWideCaption), rct, DrawGroupFlags, nil);
                {$ENDIF}
              end
              else
              begin
                {$IFNDEF TMSDOTNET}
                DrawText(Canvas.Handle, PChar(s), Length(s), rct, DrawGroupFlags);
                {$ENDIF}
                {$IFDEF TMSDOTNET}
                DrawText(Canvas.Handle, s, Length(s), rct, DrawGroupFlags);
                {$ENDIF}

              end;
            end;

            Canvas.Font.Assign(Font);

            r.Left := oldx;
            orgx := r.Right;
          end;

          r.Bottom := r.Top + FTextHeight;
        end;
        // end of horizontal positiongroup painting

        // vertical positiongroup painting
        if (Planner.PositionGroup > 0) and (Orientation = hoVertical) and (SectionIndex > 1) then
        begin
          if SectionIndex = 2 then
            orgx := r.Top;

          r.Left := r.Left - FTextHeight shr 1;
          r.Right := r.Left + FTextHeight shr 1;

          GroupImage := -1;

          if Planner.Header.CustomGroups.Count > 0 then
          begin
            IsGroup := ((SectionIndex - 1 + FLeftPos) = Planner.Header.GroupSpan[spanidx]);
            GroupWideCaption := '';
            GroupCaption := '';

            if IsGroup then
            begin
              if (Planner.Header.CustomGroups.Count > spanidx) then
              begin
                {$IFNDEF TMSDOTNET}
                GroupWideCaption := Planner.Header.CustomGroups[spanidx].WideCaption;
                {$ENDIF}
                GroupCaption := Planner.Header.CustomGroups[spanidx].Caption;
                GroupImage := Planner.Header.CustomGroups[spanidx].ImageIndex;
              end;
              inc(spanidx);
            end;
          end
          else
          begin
            IsGroup := ((SectionIndex - 1 + FLeftPos) mod Planner.PositionGroup = 0);
            GroupIdx := (SectionIndex - 2 + FLeftPos) div Planner.PositionGroup;
            if Planner.Header.GroupCaptions.Count > GroupIdx then
              GroupCaption := CLFToLF(Planner.Header.GroupCaptions.Strings[GroupIdx])
            else
              GroupCaption := '';
          end;


//          if ((SectionIndex - 1 + FLeftPos) mod Planner.PositionGroup = 0) or AllPainted then
          if IsGroup or AllPainted then
          begin
            oldx := r.Top;
            r.Top := orgx;
            rct := r;
            rct.Right := GroupFontHeight;

            if not FFlat then
            begin
              DrawEdge(Canvas.Handle, rct, BDR_RAISEDINNER, BF_TOPLEFT);
              DrawEdge(Canvas.Handle, rct, BDR_RAISEDINNER, BF_BOTTOMRIGHT);
            end
            else
            begin
              //OffsetRect(rct,2,0);
              Canvas.MoveTo(rct.Left,rct.Top+2);
              Canvas.LineTo(rct.Right+1,rct.Top+2);
              Canvas.LineTo(rct.Right+1,rct.Bottom+1);
              Canvas.LineTo(rct.Left,rct.Bottom+1);
              Canvas.LineTo(rct.Left,rct.Top+2);
              //OffsetRect(rct,-2,0);
            end;

            tr := r;

            if (GroupImage >= 0) and Assigned(Planner.PlannerImages) then
            begin
              if not Planner.Header.RotateOnLeft then
              begin
                Planner.PlannerImages.Draw(Canvas, r.Left, r.Top + ((r.Bottom - r.Top) - Planner.PlannerImages.Height) div 2, GroupImage);
                tr.Left := 2 + Planner.PlannerImages.Width;
              end
              else
              begin
                Planner.PlannerImages.Draw(Canvas, r.Left, r.Bottom - Planner.PlannerImages.Height, GroupImage);
                tr.Bottom := tr.Bottom - 2 - Planner.PlannerImages.Height;
              end;
            end;

            //GroupIdx := (SectionIndex - 2 + FLeftPos) div Planner.PositionGroup;

            if Planner.Header.RotateGroupOnLeft and (Planner.SideBar.Position = spTop) then
            begin
              //if Planner.Header.GroupCaptions.Count > GroupIdx then
              //begin
                s := CLFToLF(GroupCaption);
                //s := CLFToLF(Planner.Header.GroupCaptions.Strings[GroupIdx]);
                SetBkMode(Canvas.Handle, TRANSPARENT);
                tf := TFont.Create;
                try
                  tf.Assign(Planner.Header.GroupFont);
                  {$IFNDEF TMSDOTNET}
                  GetObject(tf.Handle, SizeOf(lf), @lf);
                  {$ENDIF}
                  {$IFDEF TMSDOTNET}
                  GetObject(tf.Handle, Marshal.SizeOf(TypeOf(lf)), lf);
                  {$ENDIF}

                  lf.lfEscapement := 900;
                  lf.lfOrientation := 900;
                  tf.Handle := CreateFontIndirect(lf);
                  Canvas.Font.Assign(tf);
                  Canvas.Brush.Style := bsClear;

                  while pos(#13, s) > 0 do
                  begin
                    TextRect(r,r.Left,r.Bottom - 4,copy(s,1,pos(#13,s)-1));
                    delete(s,1,pos(#13,s)+1);
                    tr.Left  := tr.Left + TextHeight('gh');
                  end;

                  TextRect(tr,tr.Left,tr.Bottom - 4,s);
                finally
                  tf.Free;
                end;
              //end;
            end
            else
            begin
              //if Planner.Header.GroupCaptions.Count > GroupIdx then
              begin
                Canvas.Font.Assign(Planner.Header.GroupFont);

                s := CLFToLF(GroupCaption);

                if Pos(#13, s) = 0 then
                  DrawGroupFlags := DrawFlags
                else
                  DrawGroupFlags := DT_NOPREFIX or HorizontalAlign or DT_WORDBREAK;

                {$IFDEF DELPHI4_LVL}
                DrawGroupFlags := Planner.DrawTextBiDiModeFlags(DrawGroupFlags);
                {$ENDIF}


                if Pos('</',s) > 0 then
                begin
                  HTMLDrawEx(Canvas,s,r,Planner.PlannerImages,0,0,-1,-1,1,False,False,False,False,False,False,True
                    , False
                    ,1, clBlue,clNone,clNone,clgray,Anchor,Strip,FocusAnchor,XSize,YSize,ml,hl,hr
                    ,cr, CID, CV, CT, Planner.FImageCache,Planner.FContainer, Handle
                    );
                end
                else
                  {$IFNDEF TMSDOTNET}
                  DrawText(Canvas.Handle, PChar(s), Length(s), tr, DrawGroupFlags);
                  {$ENDIF}
                  {$IFDEF TMSDOTNET}
                  DrawText(Canvas.Handle, S, Length(s), tr, DrawGroupFlags);
                  {$ENDIF}


                Canvas.Font.Assign(Planner.Header.Font);
              end;
            end;

            r.Top := oldx;
            orgx := r.Bottom;
          end;

          r.Right := r.Left + FTextHeight;
        end;

        if FShowFixed and (Orientation = hoHorizontal) and (SectionIndex > 1) then
        begin
          Canvas.Pen.Color := FLineColor;
          if FFlat then
          begin
            Canvas.MoveTo(r.Left + 1,r.Bottom);
            Canvas.LineTo(r.Left + 1,R.Bottom + FFixedHeight);
          end
          else
          begin
            Canvas.MoveTo(r.Right - 1,r.Bottom);
            Canvas.LineTo(r.Right - 1,R.Bottom + FFixedHeight);
          end;
          r.Bottom := r.Bottom + FFixedHeight;
        end;

        if FShowFixed and (Orientation = hoVertical) and (SectionIndex > 1) then
        begin
          Canvas.Pen.Color := FLineColor;
          
          Canvas.MoveTo(r.Right,r.Bottom + 2);
          Canvas.LineTo(r.Right + FFixedHeight,r.Bottom + 2);

          r.Right := r.Right + FFixedHeight;
        end;

        with Planner do
        begin
          if SideBar.Position = spRight then
            APlannerItem := Items.HeaderFirst(SectionIndex - 1 + FLeftPos)
          else
            APlannerItem := Items.HeaderFirst(SectionIndex - 2 + FLeftPos);

          pr.Top := r.Top;

          while Assigned(APlannerItem) and not IsSideSection(Planner,SectionIndex) do
          begin
            APlannerItem.FRepainted := False;
            {Paint full Items here}
            if Orientation = hoHorizontal then
            begin
              pr.Left := r.Left + 2;
              pr.Right := r.Right - 2;
              pr.Top := pr.Bottom;
              pr.Bottom := pr.Bottom + FItemHeight;
              FGrid.PaintItemCol(Self.Canvas, pr, APlannerItem, False, False);
            end
            else
            begin
              pr.Left := r.Left + FTextHeight;
              pr.Right := r.Right - 2;
              pr.Bottom := pr.Top + FItemHeight;
              FGrid.PaintItemCol(Self.Canvas, pr, APlannerItem, False, False);
              pr.Top := pr.Top + FItemHeight;
            end;
            APlannerItem := Items.HeaderNext(SectionIndex - 2 + FLeftPos);
          end;
        end;

        Font := Self.Font;
        Brush.Color := FColor;
        Pen.Color := FLineColor;
        Pen.Width := 1;
      end;

    until AllPainted;
  end;
end;



{$IFDEF TMSDOTNET}
procedure TAdvHeader.CMHintShow(var Message: TCMHintShow);
{$ENDIF}
{$IFNDEF TMSDOTNET}
procedure TAdvHeader.CMHintShow(var Message: TMessage);
{$IFDEF DELPHI2_LVL}
type
  PHintInfo = ^THintInfo;
{$ENDIF}
{$ENDIF}
var
  CanShow: Boolean;
  {$IFNDEF TMSDOTNET}
  Hi: PHintInfo;
  {$ENDIF}
  {$IFDEF TMSDOTNET}
  Hi: THintInfo;
  {$ENDIF}
  cr, hr, pr, cor: TRect;
  APlannerItem: TPlannerItem;
  s, CID, CV, CT: string;
  Anchor, StrippedHtmlString, FocusAnchor: string;
  XSize, YSize, ml, hl: Integer;
  FPlanner: TCustomPlanner;
  SectionIdx: Integer;
  
begin
  {$IFNDEF TMSDOTNET}
  Hi := PHintInfo(Message.LParam);
  {$ENDIF}
  {$IFDEF TMSDOTNET}
  Hi := Message.HintInfo;
  {$ENDIF}

  CanShow := False;

  APlannerItem := ItemAtXY(Hi.CursorPos.X, Hi.CursorPos.Y,pr);

  FPlanner := TCustomPlanner(Owner);

  FLastHintPos := Point(Hi.CursorPos.X, Hi.CursorPos.Y);

  if Assigned(APlannerItem) and FPlanner.Header.ShowHint then
  begin
    s := APlannerItem.ItemText;
    if APlannerItem.Hint <> '' then
      s := APlannerItem.Hint;

    if IsRtf(s) then
    begin
      if not FPlanner.RichEdit.Visible then
      begin
        FPlanner.TextToRich(s);
        s := FPlanner.FRichEdit.Text;
      end;
    end;
    if IsHtml(APlannerItem,s,false) then
    begin
      {Change ? if HTML Hint is enabled ?}
      if APlannerItem.Hint = '' then
        s := ConcatenateTextStrings(APlannerItem.Text);

      cr := ClientRect;
      if not FPlanner.HTMLHint then
      begin
        HTMLDrawEx(Canvas, s, cr, FPlanner.PlannerImages, 0, 0, -1, -1, 1,
          True, True, False, True, True, False, APlannerItem.WordWrap
          ,False
          , 1.0, FPlanner.URLColor,
          clNone, clNone, clGray, Anchor, StrippedHtmlString, FocusAnchor,
          XSize, YSize, ml, hl, hr
          , cor, CID, CV, CT, FPlanner.FImageCache, FPlanner.FContainer, Handle
          );

        s := StrippedHtmlString;
      end;
    end;

    {$IFDEF TMSCODESITE}
    CodeSite.SendMsg(s+'*');
    {$ENDIF}

{$IFNDEF VER90}
    Hi.HintStr := s;
    if Assigned(FPlanner.OnItemHint) then
      FPlanner.OnItemHint(FPlanner, APlannerItem, Hi.HintStr);
{$ENDIF}
    CanShow := True;
  end
  else
  begin
    SectionIdx := XYToSection(Hi.CursorPos.X, Hi.CursorPos.Y);

    if Assigned(OnHeaderHint) then
    begin
      OnHeaderHint(FPlanner, SectionIdx, Hi.HintStr);
      CanShow := Hi.HintStr <> '';
    end;
    //if Assigned(FPlanner.OnHeaderHint) then
    //begin
    //  FPlanner.OnHeaderHint(FPlanner, SectionIdx, Hi.HintStr);
    //  CanShow := Hi.HintStr <> '';
    //end;
  end;

  if FPlanner.HintColor <> clNone then
    Hi.HintColor := FPlanner.HintColor;

  Hi.HideTimeOut := FPlanner.HintPause;

  Message.Result := Ord(not CanShow);
end;

{$IFNDEF TMSDOTNET}
procedure TAdvHeader.WMNotify(var Message: TWMNOTIFY);
{$ENDIF}
{$IFDEF TMSDOTNET}
procedure TAdvHeader.WMNotify(var Message: TWMNOTIFYTT);
{$ENDIF}
var
  buffer:array[0..255] of char;
  pt: TPoint;
  plIt: TPlannerItem;
  {$IFDEF TMSDOTNET}
  di: TToolTipText;
  {$ENDIF}
  {$IFNDEF TMSDOTNET}
  di: PNMTTDispInfo;
  {$ENDIF}
  ATitle, AText: string;
  AIcon: Integer;
  cell: TPoint;
  len1, len2, i: integer;
  FPlanner: TCustomPlanner;
  r: TRect;

begin
  {$IFDEF TMSDOTNET}
  with Message.NMHdr do
  {$ENDIF}
  {$IFNDEF TMSDOTNET}
  with Message.NMHdr^ do
  {$ENDIF}
    case code of
    TTN_NEEDTEXT:
    begin
      FPlanner := (Owner as TCustomPlanner);

      if not FPlanner.Balloon.Enable then
        Exit;

      {$IFDEF TMSDOTNET}
      di := Message.ToolTipText;
      {$ENDIF}

      {$IFNDEF TMSDOTNET}
      di := PNMTTDispInfo(TMessage(Message).LParam);
      {$ENDIF}

      GetCursorPos(pt);
      pt := ScreenToClient(pt);

      plIt := ItemAtXY(pt.X,pt.Y, r);

//      cell := FPlanner.XYToCell(pt.X,pt.Y);

      cell.X := XYToSection(pt.X, pt.Y);
      cell.Y := -1;

      if Assigned(plIt) then
      begin
        ATitle := HTMLStrip(plIt.CaptionText);

        if IsRtf(plIt.NotesText) then
        begin
          if not FPlanner.RichEdit.Visible then
          begin
            FPlanner.TextToRich(plIt.NotesText);
            AText := FPlanner.FRichEdit.Text;
          end;
        end
        else
          AText := HTMLStrip(plIt.NotesText);

        {$IFNDEF TMSDOTNET}
        len1 := Length(AText);
        len2 := SizeOf(FTooltipBuffer) div 4;

        // balloon tooltip cannot handle tabs well
        i := 1;
        while i < len1 do
        begin
          if (AText[i] = #9) then
            AText[i] := #32;
          inc(i);
        end;

        i := 1;
        if AText <> '' then
          while ( (AText[i] = #13) or (AText[i] = #10) or (AText[i] = #9)) do
            inc(i);

        if len1 > len2 then
          AText := Copy(AText, i, len2 - 3) + '...'
        else
          if i > 1 then
            AText := Copy(AText, i, len1 - i + 1);
        {$ENDIF}

        AIcon := 1;
        // for some reason, balloon tips will not show multiline when there is no title  ...
        if ATitle = '' then
          ATitle := ' ';
        if Assigned(FPlanner.OnItemBalloon) then
          FPlanner.OnItemBalloon(FPlanner, plIt, ATitle, AText, AIcon);
      end
      else
      begin
        AText := '';
        ATitle := '';
        AIcon := 1;
        if Assigned(FPlanner.OnPlannerBalloon) then
          FPlanner.OnPlannerBalloon(FPlanner,cell.X, cell.Y, ATitle, AText, AIcon);
      end;

      {$IFNDEF TMSDOTNET}
      strpcopy(ftooltipbuffer,AText);

      if length(ATitle) > 99 then
        ATitle := copy(ATitle,1, 96) + '...';

      strpcopy(buffer,ATitle);

      di^.lpszText := @ftooltipbuffer;
      {$ENDIF}
      {$IFDEF TMSDOTNET}
      di.lpszText := AText;
      Message.ToolTipText := di;
      {$ENDIF}

      if FPlanner.Balloon.TextColor <> clNone then
        SendMessage(fhtooltip, TTM_SETTIPTEXTCOLOR, ColorToRgb(FPlanner.Balloon.TextColor), 0);
      if FPlanner.Balloon.BackgroundColor <> clNone then
        SendMessage(fhtooltip, TTM_SETTIPBKCOLOR, ColorToRgb(FPlanner.Balloon.BackgroundColor), 0);

      {$IFDEF TMSDOTNET}
      SendTextMessage(fhtooltip,TTM_SETTITLE,AIcon,ATitle);
      {$ENDIF}
      {$IFNDEF TMSDOTNET}
      SendMessage(fhtooltip,TTM_SETTITLE,AIcon,longint(@buffer));
      {$ENDIF}
    end;
    TTN_SHOW:
    begin
    end;
    TTN_POP:
    begin
    end;
    end;
end;


procedure TAdvHeader.WMLButtonDown(var Msg: TWMLButtonDown);
var
  SectionIndex: Integer;
  r, pr: TRect;
  plit: TPlannerItem;
  nodrag: Boolean;
begin
  SectionIndex := XYToSection(Msg.XPos, Msg.YPos);

  r := GetSectionRect(SectionIndex);

  plIt := ItemAtXY(msg.XPos, msg.YPos,pr);

  nodrag := false;
  if Assigned(plIt) then
    nodrag := not plIt.ReadOnly;

  if FSectionDragDrop and not FDragging and not nodrag then
  begin
    FDragStart := SectionIndex;

    InflateRect(r,-2,-2);

    if (FDragStart >= FOffset) and PtInRect(r,Point(Msg.XPos,Msg.YPos)) then
    begin
      FDragging := True;
      Self.Cursor := crDrag;
      SetCapture(Self.Handle);
    end;
  end;
  inherited;
end;

procedure TAdvHeader.WMSize(var Msg: TWMSize);
begin
  {$IFNDEF TMSDOTNET}
  inherited;
  {$ENDIF}
  
  {$IFDEF TMSDOTNET}
  Invalidate;
  {$ENDIF}

  if FSizing then
  begin
    with (Owner as TCustomPlanner) do
    begin
      FNoPositionSize := True;

      if Orientation = hoHorizontal then
        Header.Height := self.Height
      else
        Header.Height := self.Width;

      FNoPositionSize := False;

      HeaderHeightChange(self.Height);
    end;  
  end;
end;

{$IFNDEF TMSDOTNET}
procedure TAdvHeader.WMNCHitTest(var Msg: TWMNCHitTest);
var
  pt: TPoint;
begin
  inherited;

  FSizing := false;

  FHitTest := Point(Msg.XPos, Msg.YPos);

  if AllowSizing then
  begin
    pt := ScreenToClient(FHitTest);

    if Orientation = hoHorizontal then
    begin
      if (pt.Y >= Height - 2) then
      begin
        Msg.Result := HTBOTTOM;
        FSizing := True;
      end;
    end
    else
    begin
      if (pt.X >= Width - 2) then
      begin
        Msg.Result := HTRIGHT;
        FSizing := True;
      end;
    end;
  end;
end;

procedure TAdvHeader.WMSetCursor(var Msg: TWMSetCursor);
var
  Cur: HCURSOR;
  I: Integer;
  Y: Integer;

begin
  if (Cursor = crHandPoint) or (FDragging) then
  begin
    inherited;
    Exit;
  end;

  if Orientation = hoVertical then
  begin
    Cur := 0;
    FResizeSection := 0;
    FHitTest := ScreenToClient(FHitTest);
    Y := 2;
    with Msg do
      if HitTest = HTCLIENT then
      begin
        Inc(Y, SectionWidth[0]); // first fixed section

        for I := FLeftPos + 1 to Sections.Count - 2 do  { don't count last section }
        begin
          Inc(Y, SectionWidth[I]);

          FMouseOffset := Y - (FHitTest.Y + 2);
          if Abs(FMouseOffset) < 4 then
          begin
            Cur := LoadCursor(0, IDC_SIZENS);
            FResizeSection := I;
            Break;
          end;
        end;
      end;

    FCanResize := (AllowResize or (csDesigning in ComponentState)) and (Cur <> 0);

    if FCanResize then
      SetCursor(Cur)
    else
    begin
      FMouseOffset := Self.width - (FHitTest.X + 2);
      if (Abs(FMouseOffset) >= 4) and ((Owner as TCustomPlanner).PositionZoomWidth = 0) then
      begin
        if AllowResize then
          Msg.HitTest := Windows.HTNOWHERE;
        inherited;
      end
      else
        inherited;
    end;
  end
  else
  begin
    Cur := 0;
    FResizeSection := 0;
    FHitTest := ScreenToClient(FHitTest);
    Y := 2;

    with Msg do
      if HitTest = HTCLIENT then
      begin
        Inc(Y, SectionWidth[0]); // first fixed section

        for I := FLeftPos + 1 to Sections.Count - 2 do  { don't count last section }
        begin
          Inc(Y, SectionWidth[I]);

          FMouseOffset := Y - (FHitTest.X + 2);
          if Abs(FMouseOffset) < 4 then
          begin
            Cur := LoadCursor(0, IDC_SIZEWE);
            FResizeSection := I;
            Break;
          end;
        end;
      end;


    FCanResize := (AllowResize or (csDesigning in ComponentState)) and (Cur <> 0);

    if FCanResize then
      SetCursor(Cur)
    else
    begin
      FMouseOffset := Self.Width - (FHitTest.X + 2);

      if (Abs(FMouseOffset) >= 4) and ((Owner as TCustomPlanner).PositionZoomWidth = 0) then
      begin
        if AllowResize then
          Msg.HitTest := Windows.HTNOWHERE;
        inherited;
      end
      else
        inherited;
    end;
  end;
end;
{$ENDIF}

procedure TAdvHeader.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  r,pr: TRect;
  APlannerItem: TPlannerItem;
  SectionIndex,EditIdx,ItemsX: Integer;
  FPlanner: TCustomPlanner;
  s: string;
  ScreenPoint: TPoint;
  CID,CV,CT: string;
  cor: TRect;
  FocusAnchor, Anchor, StrippedHTMLString: string;
  ml,hl: integer;
  hr,tr: TRect;
  XSize, YSize: Integer;
  Allow: Boolean;
  ImgSize,iw: Integer;
  AutoHandle: boolean;

begin
  if ClassName = 'TAdvFooter' then
  begin
    inherited;
    Exit;
  end;

  SectionIndex := XYToSection(X, Y);
  r := GetSectionRect(SectionIndex);

  if Button = mbRight then
  begin
    inherited;

    if Assigned(FOnRightClick) then
      FOnRightClick(Self, XYToSection(X, Y));

    APlannerItem := ItemAtXY(X, Y,pr);
    FPlanner := Owner as TCustomPlanner;

    ScreenPoint := ClientToScreen(Point(X, Y));

    if Assigned(APlannerItem) then
    begin
      with FPlanner do
        if Assigned(OnItemRightClick) then
          OnItemRightClick(Owner,APlannerItem);

      if Assigned(APlannerItem.PopupMenu) then
      begin
        if Assigned(FPlanner.OnItemPopupPrepare) then
          FPlanner.OnItemPopupPrepare(FPlanner, APlannerItem.PopupMenu, APlannerItem);

        FPlanner.PopupPlannerItem := APlannerItem;
        APlannerItem.PopupMenu.PopupComponent := FPlanner;
        APlannerItem.PopupMenu.Popup(ScreenPoint.X, ScreenPoint.Y);
      end;

      if (Assigned(FPlanner.FItemPopup)) then
      begin
        if Assigned(FPlanner.OnItemPopupPrepare) then
          FPlanner.OnItemPopupPrepare(FPlanner, FPlanner.ItemPopup, APlannerItem);

        FPlanner.PopupPlannerItem := APlannerItem;
        FPlanner.ItemPopup.PopupComponent := FPlanner;
        FPlanner.FItemPopup.Popup(ScreenPoint.X, ScreenPoint.Y);
      end;
    end
    else
    begin
      if Assigned(FPlanner.Header.PopupMenu) then
      begin
        FPlanner.Header.PopupMenu.PopupComponent := FPlanner;
        FPlanner.Header.PopupMenu.Popup(ScreenPoint.X,ScreenPoint.Y);
      end;
    end;
    Exit;
  end;

  if Button = mbLeft then
  begin
    if FCanResize {and (Orientation = hoVertical)} then
    begin
      SetCapture(Handle);
      Exit;
    end;

    FPlanner := Owner as TCustomPlanner;

    if FPlanner.FGrid.FMemo.Visible then
      FPlanner.FGrid.FMemo.DoExit;

    APlannerItem := ItemAtXY(X, Y,pr);
    if Assigned(APlannerItem) then
    begin
      ImgSize := 0;
      if (APlannerItem.CaptionType <> ctNone) then
      begin
        tr := pr;
        tr.Right := tr.Right - FPlanner.ItemGap;

        tr.Bottom := tr.Top + 16;

        if APlannerItem.ShowDeleteButton and (r.Right - r.Left - ImgSize > 32) then
        begin
          tr.Left := tr.Right - FPlanner.DeleteGlyph.Width;
          if PtInRect(tr,Point(X,Y)) then
          begin
            if Assigned(FPlanner.OnItemDelete) then
              FPlanner.OnItemDelete(Self,APlannerItem);

            if FPlanner.AutoInsDel then
            begin
              if Assigned(FPlanner.OnItemDeleted) then
                FPlanner.OnItemDeleted(Self,APlannerItem);
              FPlanner.FreeItem(APlannerItem);
            end;

            Exit;
          end;
          tr.Right := tr.Right - FPlanner.DeleteGlyph.Width;
        end;

        if APlannerItem.Attachement <> '' then
        begin
          tr.Left := tr.Right - FPlanner.AttachementGlyph.Width;

          if PtInRect(tr,Point(X,Y)) then
          begin
            AutoHandle := true;

            if Assigned(FPlanner.FOnItemAttachementClick) then
              FPlanner.FOnItemAttachementCLick(FPlanner,APlannerItem,APlannerItem.Attachement,AutoHandle);
            if AutoHandle then

              {$IFNDEF TMSDOTNET}
              ShellExecute(0,'open',PChar(APlannerItem.Attachement),nil,nil,SW_NORMAL);
              {$ENDIF}

              {$IFDEF TMSDOTNET}
              ShellExecute(0,'open',APlannerItem.Attachement,'','',SW_NORMAL);
              {$ENDIF}


            Exit;
          end;

          tr.Right := tr.Right - FPlanner.AttachementGlyph.Width;
        end;

        if APlannerItem.URL <> '' then
        begin
          tr.Left := tr.Right - FPlanner.URLGlyph.Width;

          if PtInRect(tr,Point(X,Y)) then
          begin
            AutoHandle := true;

            if Assigned(FPlanner.FOnItemURLClick) then
              FPlanner.FOnItemURLCLick(FPlanner,APlannerItem,APlannerItem.URL,AutoHandle);
            if AutoHandle then
              {$IFNDEF TMSDOTNET}
              ShellExecute(0,'open',PChar(APlannerItem.URL),nil,nil,SW_NORMAL);
              {$ENDIF}
              {$IFDEF TMSDOTNET}
              ShellExecute(0,'open',APlannerItem.URL,'','',SW_NORMAL);
              {$ENDIF}


            Exit;
          end;
        end;
      end;

      ImgSize := 0;

      if Assigned(FPlanner.PlannerImages) and
         ((APlannerItem.ImageID >= 0) or (APlannerItem.FImageIndexList.Count > 0)) then
        begin
          iw := FPlanner.PlannerImages.Width;
          if APlannerItem.ImagePosition = ipHorizontal then
            ImgSize := (iw * APlannerItem.FImageIndexList.Count) + iw
          else
            ImgSize := iw;
        end;

      if Assigned(FPlanner.PlannerImages) and
         Assigned(FPlanner.FOnItemImageClick) then
      begin
        if (Y > pr.Top) and (Y < pr.Top + FPlanner.PlannerImages.Height + 3) and
           (X >= pr.Left) and (X < pr.Left + ImgSize) and
          ((APlannerItem.ImageID >= 0) or (APlannerItem.FImageIndexList.Count > 0)) then
        begin
          iw := FPlanner.PlannerImages.Width;

          if (X < pr.Left + ImgSize) and (iw > 0) then
          begin
            if (((X - pr.Left + 8) div iw) <= APlannerItem.FImageIndexList.Count) or (APlannerItem.ImageID >= 0) then
              FPlanner.FOnItemImageClick(FPlanner, APlannerItem, ((X - pr.Left + 8) div iw) - 1);
          end;
          Exit;
        end;
      end;

      if IsHTML(APlannerItem,APlannerItem.ItemText,false) and APlannerItem.Selected then
      begin
        pr.Top := pr.Top + 4 + APlannerItem.FCaptionHeight;
        pr.Left := pr.Left + FPlanner.TrackWidth;

        {$IFDEF TMSDEBUG}
        outputdebugstring(pchar('height:'+inttostr(APlannerItem.FCaptionHeight)));
        outputdebugstring(pchar(inttostr(pr.left)+':'+inttostr(pr.Top)+':'+inttostr(pr.Right)+':'+inttostr(pr.Bottom)));
        outputdebugstring(pchar('xy:'+inttostr(x)+':'+inttostr(y)+':'+aplanneritem.itemtext));
        {$ENDIF}

        if HTMLDrawEx(Canvas, APlannerItem.ItemText, pr, FPlanner.PlannerImages, X, Y,
          -1, -1, 1, True, False, False, True, True, False, APlannerItem.WordWrap
          , False
          , 1.0, FPlanner.URLColor,
          clNone, clNone, clGray, Anchor, StrippedHtmlString, FocusAnchor, XSize, YSize, ml, hl, hr
          , cor, CID, CV, CT, FPlanner.FImageCache, FPlanner.FContainer, Handle
          ) then
          begin
            if Assigned(FPlanner.OnItemAnchorClick) then
              FPlanner.OnItemAnchorClick(FPlanner,APlannerItem,Anchor);
            Exit;
          end;
      end;

      if Cursor = crSizeAll then
      begin
        FMouseDownMove := true;
        FDragItem := APlannerItem;
        Exit;
      end;

      with (Owner as TCustomPlanner) do
      begin
        if APlannerItem <> Items.Selected then
        Items.UnSelectAll;
        Items.Selected := APlannerItem;

        if Assigned(OnItemLeftClick) then
          OnItemLeftClick(Owner,APlannerItem);

        if not APlannerItem.NotEditable and (APlannerItem.Selected or FPlanner.EditDirect) then
          StartEdit(pr,APlannerItem, X, Y + TextHeight);

        APlannerItem.Selected := True;

        ItemSelected(APlannerItem);
      end;
    end;

    if FSectionEdit and not (csDesigning in ComponentState) then
    begin
      if FInplaceEdit.Visible then
      begin

        EditIdx := FEditSection;
//        EditIdx := GetSectionIdx(FEditSection);

        s := LFToCLF(FInplaceEdit.Text);

        if Assigned(FPlanner.OnHeaderEndEdit) then
          FPlanner.OnHeaderEndEdit(FPlanner,EditIdx,s);

        (Owner as TCustomPlanner).FEditMode := False;

        Sections[EditIdx] := s;
        SectionWidth[EditIdx] := FEditWidth;
      end;

      FEditSection := XYToSection(X, Y);
      r := GetSectionRect(FEditSection);

      //EditIdx := GetSectionIdx(FEditSection);

      EditIdx := FEditSection;

      InflateRect(r, -2, -2);
      OffsetRect(r, 2, 2);

      if EditIdx >= Self.Sections.Count then
        s := ''
      else
        s := CLFToLF(Self.Sections[EditIdx]);

      FPlanner.FEditMode := true; 

      if Assigned(FPlanner.OnHeaderStartEdit) then
        FPlanner.OnHeaderStartEdit(FPlanner,EditIdx,s);

      {$IFDEF DELPHI4_LVL}
      FInplaceEdit.BiDiMode := FPlanner.BiDiMode;
      {$ENDIF}
      FInplaceEdit.Top := r.Top;
      FInplaceEdit.Left := r.Left;
      FInplaceEdit.Width := r.Right - r.Left - 2;
      FInplaceEdit.Height := r.Bottom - r.Top - 2;
      FInplaceEdit.Color := Self.Color;
      FInplaceEdit.Font.Assign(Self.Font);
      FInplaceEdit.Text := s;
      FInplaceEdit.BorderStyle := bsNone;
      FInplaceEdit.Visible := True;
      FInplaceEdit.SelectAll;

      FEditWidth := SectionWidth[FEditSection];

      FInplaceEdit.SetFocus;
    end;

    if FPlanner.SideBar.Orientation = soVertical then
    begin
      if SectionIndex > FPlanner.FGrid.ColCount then SectionIndex := -1;
    end
    else
    begin
      if SectionIndex >= FPlanner.FGrid.RowCount then SectionIndex := -1;
    end;

    if Zoom and (SectionIndex > 0) and (FPlanner.PositionWidth > 0) then
    begin
      if Cursor = crZoomIn then
      begin
        ZoomCol := SectionIndex;
        Allow := True;
        if Assigned(FPlanner.OnPlannerBeforePositionZoom) then
          FPlanner.OnPlannerBeforePositionZoom(FPlanner, ZoomCol, True, Allow);

        if Allow then
        begin
          FPlanner.PositionWidths[SectionIndex - 1] := FPlanner.PositionZoomWidth;
          ZoomCol := SectionIndex;
          if Assigned(FPlanner.OnPlannerPositionZoom) then
            FPlanner.OnPlannerPositionZoom(FPlanner, ZoomCol, True);
        end;
      end
      else
      begin
        ZoomCol := SectionIndex;
        Allow := True;
        if Assigned(FPlanner.OnPlannerBeforePositionZoom) then
          FPlanner.OnPlannerBeforePositionZoom(FPlanner, ZoomCol, True, Allow);
        if Allow then
        begin
          if FPlanner.PositionAutoSize and (FPlanner.PositionWidth > 0) then
          begin
            ItemsX := FPlanner.Items.MaxItemsInPos(SectionIndex - 1);
            FPlanner.PositionWidths[SectionIndex - 1] := Max(1,ItemsX) * FPlanner.PositionWidth;
          end
          else
            FPlanner.PositionWidths[SectionIndex - 1] := FPlanner.PositionWidth;
          if Assigned(FPlanner.OnPlannerPositionZoom) then
            FPlanner.OnPlannerPositionZoom(FPlanner, ZoomCol, False);
          ZoomCol := -1;
        end;
      end;
    end;
  end;

  inherited;
  {
  if Assigned(FOnClick) then
    FOnClick(Self, XYToSection(X, Y));
  }
end;


procedure TAdvHeader.MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  FDragStop: Integer;
begin
  if ClassName = 'TAdvFooter' then
  begin
    inherited;
    Exit;
  end;

  if FCanResize then
  begin
    ReleaseCapture;
    Sized(FResizeSection, SectionWidth[FResizeSection]);
    FCanResize := False;
  end;

  inherited;

  if Assigned(FOnClick) and (Button = mbLeft) then
    FOnClick(Self, XYToSection(X, Y));

  if FSectionDragDrop and FDragging then
  begin
    FDragging := False;
    Self.Cursor := crDefault;
    ReleaseCapture;
    if Assigned(FOnDragDrop) then
    begin
      FDragStop := XYToSection(X, Y);

      if (FDragStop >= FOffset) and (FDragStop <> FDragStart) then
        FOnDragDrop(Self, FDragStart, FDragStop);
    end;
    Exit;
  end;

  FMouseDownMove := false;
end;


procedure TAdvHeader.WMLButtonDblClk(var Message: TWMLButtonDblClk);
var
  APlannerItem: TPlannerItem;
  pr: TRect;
begin
  APlannerItem := ItemAtXY(Message.XPos, Message.YPos,pr);
  if Assigned(APlannerItem) then
  begin
    with (Owner as TCustomPlanner) do
      if Assigned(OnItemDblClick) then
        OnItemDblClick(Owner,APlannerItem);
  end
  else
   if Assigned(FOnDblClick) then
     FOnDblClick(Self, XYToSection(Message.xpos, Message.ypos));
end;


procedure TAdvHeader.MouseMove(Shift: TShiftState; X, Y: Integer);
var
  SectionIdx: Integer;
  HdrYStart: Integer;
  FPlanner: TCustomPlanner;
  PosOk: Boolean;
  r,pr: TRect;
  APlannerItem: TPlannerItem;
  Allow: Boolean;
  I: Integer;
  sw: Integer;    
  AbsPos: Integer;
  MinPos: Integer;
  MaxPos: Integer;
  CID,CV,CT: string;
  cor: TRect;
  FocusAnchor, Anchor, StrippedHTMLString: string;
  ml,hl: integer;
  hr,tr: TRect;
  XSize, YSize: Integer;

begin
  if ClassName = 'TAdvFooter' then
  begin
    inherited;
    Exit;
  end;

  inherited;

  if (GetCapture = Handle) and FCanResize then
  begin
    if (Orientation = hoVertical) then
    begin
      { absolute position of this item }
      AbsPos := 2;
      Inc(AbsPos, SectionWidth[0]);

      for I := FLeftPos + 1 to FResizeSection do
        Inc(AbsPos, SectionWidth[I]);

      if FResizeSection > 0 then
        MinPos := AbsPos - SectionWidth[FResizeSection] + 2
      else
        MinPos := 2;

      MaxPos := ClientHeight - 2;
      if Y < MinPos then Y := MinPos;
      if Y > MaxPos then Y := MaxPos;

      sw := SectionWidth[FResizeSection];
      Dec(sw, (AbsPos - Y - 2) - FMouseOffset);
      SectionWidth[FResizeSection] := sw;
      Sizing(FResizeSection, SectionWidth[FResizeSection]);
      Refresh;
    end
    else
    begin
      { absolute position of this item }
      AbsPos := 2;
      Inc(AbsPos, SectionWidth[0]);

      for I := FLeftPos + 1 to FResizeSection do
        Inc(AbsPos, SectionWidth[I]);

      if FResizeSection > 0 then MinPos := AbsPos -
        SectionWidth[FResizeSection] + 2
      else
        MinPos := 2;

      MaxPos := ClientWidth - 2;
      if X < MinPos then X := MinPos;
      if X > MaxPos then X := MaxPos;

      sw := SectionWidth[FResizeSection];
      Dec(sw, (AbsPos - X - 2) - FMouseOffset);
      SectionWidth[FResizeSection] := sw;
      Sizing(FResizeSection, SectionWidth[FResizeSection]);
      Refresh;
    end;
  end;


  if FDragging then
  begin
    Cursor := crDrag;
    Exit;
  end;

  if (FLastHintPos.X <> -1) then
    if (Abs(X - FLastHintPos.X) > 4) or (Abs(Y - FLastHintPos.Y) > 4) then
    begin
      Application.CancelHint;
      FLastHintPos := Point(-1, -1);
    end;

  SectionIdx := XYToSection(X,Y);
  FPlanner := Owner as TCustomPlanner;

  if Zoom then
  begin
    HdrYStart := 0;

    if FPlanner.PositionGroup > 0 then
      HdrYStart := TextHeight shr 1;

    if FPlanner.SideBar.Orientation = soVertical then
      PosOK := (Y < TextHeight) and (Y >= HdrYStart) and (SectionIdx < FPlanner.FGrid.ColCount)
    else
      PosOK := (X < TextHeight) and (X >= HdrYStart) and (SectionIdx < FPlanner.FGrid.RowCount);

    if PosOk and (SectionIdx > 0) then
    begin
      if (SectionWidth[SectionIdx] <> FPlanner.PositionZoomWidth) then
        Cursor := crZoomIn
      else
        Cursor := crZoomOut;

      Exit;
    end{
    else
      if (Cursor <> crDefault) and not FDragging then
        Cursor := crDefault;
        }
  end;


  r := GetSectionRect(SectionIdx);

  APlannerItem := ItemAtXY(X, Y, pr);

  if (FBalloonItem <> APlannerItem) and (FPlanner.Balloon.Enable) then
  begin
    // mouse over remove balloon here
    SendMessage(FHToolTip, TTM_POP, 0, 0);
  end;

  FBalloonItem := APlannerItem;

  if Assigned(APlannerItem) then
  begin
    if IsHTML(APlannerItem,APlannerItem.ItemText,false) and APlannerItem.Selected then
    begin
      pr.Top := pr.Top + 4 + APlannerItem.FCaptionHeight;
      pr.Left := pr.Left + FPlanner.TrackWidth;

      {$IFDEF TMSDEBUG}
      outputdebugstring(pchar('height:'+inttostr(APlannerItem.FCaptionHeight)));
      outputdebugstring(pchar(inttostr(pr.left)+':'+inttostr(pr.Top)+':'+inttostr(pr.Right)+':'+inttostr(pr.Bottom)));
      outputdebugstring(pchar('xy:'+inttostr(x)+':'+inttostr(y)+':'+aplanneritem.itemtext));
      {$ENDIF}

      if HTMLDrawEx(Canvas, APlannerItem.ItemText, pr, FPlanner.PlannerImages, X, Y,
        -1, -1, 1, True, False, False, True, True, False, APlannerItem.WordWrap
        , False
        , 1.0, FPlanner.URLColor,
        clNone, clNone, clGray, Anchor, StrippedHtmlString, FocusAnchor, XSize, YSize, ml, hl, hr
        , cor, CID, CV, CT, FPlanner.FImageCache, FPlanner.FContainer, Handle
        ) then
        begin
          Cursor := crHandPoint;
          if FOldAnchor <> Anchor then
            if Assigned(FPlanner.OnItemAnchorEnter) then
              FPlanner.OnItemAnchorEnter(FPlanner,APlannerItem,Anchor);
          FOldAnchor := Anchor;
          FAnchorItem := APlannerItem;
          Exit;
        end;
    end;


    if (APlannerItem.CaptionType <> ctNone) then
    begin
      tr := pr;
      tr.Bottom := tr.Top + 16;
      tr.Right := tr.Right - FPlanner.ItemGap;

      if APlannerItem.ShowDeleteButton then
      begin
        tr.Left := tr.Right - FPlanner.DeleteGlyph.Width;

        if PtInRect(tr,Point(X,Y)) then
        begin
          if Self.Cursor <> crHandPoint then
          begin
            Self.Cursor := crHandPoint;
          end;
          Exit;
        end;
        tr.Right := tr.Right - FPlanner.DeleteGlyph.Width;
      end;

      if APlannerItem.Attachement <> '' then
      begin
        tr.Left := tr.Right - FPlanner.AttachementGlyph.Width;

        if PtInRect(tr,Point(X,Y)) then
        begin
          if Self.Cursor <> crHandPoint then
          begin
            Self.Cursor := crHandPoint;
          end;
          Exit;
        end;

        tr.Right := tr.Right - FPlanner.AttachementGlyph.Width;
      end;

      if APlannerItem.URL <> '' then
      begin
        tr.Left := tr.Right - FPlanner.URLGlyph.Width;

        if PtInRect(tr,Point(X,Y)) then
        begin
          if Self.Cursor <> crHandPoint then
          begin
            Self.Cursor := crHandPoint;
          end;
          Exit;
        end;
      end;
    end;

  end;

  if (FOldAnchor <> '') then
  begin
    if Assigned(FPlanner.OnItemAnchorExit) then
      FPlanner.OnItemAnchorExit(FPlanner,FAnchorItem,FOldAnchor);
    FOldAnchor := '';
    FAnchorItem := nil;
  end;

  if FMouseDownMove and Assigned(FDragItem) and not self.Dragging and FPlanner.DragItem then
  begin
    Allow := True;

    if Assigned(FPlanner.OnItemDrag) then
      FPlanner.OnItemDrag(FPlanner,FPlanner.Items.Selected, Allow);

    if Allow then
    begin
      BeginDrag(True
      {$IFDEF DELPHI4_LVL}
      ,-1
      {$ENDIF}
      );
      FMouseDownMove := False;
      Exit;
    end;

    Exit;
  end;

  if Assigned(APlannerItem) then
  begin
    if APlannerItem.TrackVisible and APlannerItem.Selected then
    begin
      if (X < pr.Left + APlannerItem.FPlanner.TrackWidth) or (Y < pr.Top + APlannerItem.FCaptionHeight) then
        Cursor := crSizeAll
      else
        Cursor := crDefault;
    end
    else
      Cursor := crDefault;
  end
  else
    Cursor := crDefault;

end;

procedure TAdvHeader.SetItemHeight(const Value: Integer);
begin
  FItemHeight := Value;
  Invalidate;
end;

procedure TAdvHeader.SetTextHeight(const Value: Integer);
begin
  FTextHeight := Value;
  Invalidate;
end;

function TAdvHeader.ItemAtXY(X, Y: Integer;var ARect: TRect): TPlannerItem;
var
  SectionIndex: Integer;
  r,pr: TRect;
  APlannerItem: TPlannerItem;

begin
  Result := nil;

  SectionIndex := XYToSection(X,Y);
  r := GetSectionRect(SectionIndex);

  with (Owner as TCustomPlanner) do
  begin
    APlannerItem := Items.HeaderFirst(SectionIndex - 1);

    InflateRect(r,-2,-2);
    pr := r;

    if Orientation = hoHorizontal then
      pr.Top := r.Top + FTextHeight
    else
      pr.Left := r.Left + FTextHeight;

    while Assigned(APlannerItem) do
    begin
      pr.Bottom := pr.Top + FItemHeight;

      if PtInRect(pr,Point(X,Y)) then
      begin
        ARect := pr;
        Result := APlannerItem;
        Break;
      end;
      APlannerItem := Items.HeaderNext(SectionIndex - 1);
      pr.Top := pr.Bottom;
    end;
  end;

end;

procedure TAdvHeader.StopEdit;
var
  FPlanner: TCustomPlanner;
begin
  FPlanner := Owner as TCustomPlanner;

  with FPlanner.FGrid do
  begin
    if FMemo.Visible then
    begin
      FMemo.DoExit;
      FMemo.Visible := False;
    end;

  end;
end;

procedure TAdvHeader.StartEdit(ARect: TRect; APlannerItem: TPlannerItem; X, Y:
  Integer);
var
  ColumnHeight, ih, iw, ew: Integer;
  s: string;
  ER: TRect;
  FPlanner: TCustomPlanner;

begin
  if APlannerItem = nil then
    Exit;

  FPlanner := Owner as TCustomPlanner;

  if Assigned(APlannerItem.Editor) then
  begin
    if APlannerItem.Editor.EditorUse = euAlways then
    begin
      FPlanner.FEditMode := True;
      
      if Assigned(FPlanner.OnItemStartEdit) then
      begin
        FPlanner.OnItemStartEdit(Self, APlannerItem);
      end;

      APlannerItem.Editor.Edit(FPlanner,APlannerItem);

      if Assigned(FPlanner.OnItemEndEdit) then
        FPlanner.OnItemEndEdit(Self, APlannerItem);

      FPlanner.FEditMode := False;
      Exit;
    end;
  end;

  if FPlanner.InplaceEdit = ieNever then
    Exit;

  FPlanner.FEditMode := True;

  if Assigned(FPlanner.OnItemStartEdit) then
    FPlanner.OnItemStartEdit(Self, APlannerItem);

  ColumnHeight := 0;
  ih := 0;
  iw := 0;
  ew := 0;

  case APlannerItem.Shape of
  psRounded: ew := ew + (CORNER_EFFECT shr 1) - 1;
  psHexagon: ew := ew + CORNER_EFFECT;
  end;

  if ((APlannerItem.ImageID >= 0) or (APlannerItem.FImageIndexList.Count > 0)) and
    Assigned(FPlanner.PlannerImages) then
  begin
    ih := FPlanner.PlannerImages.Height + 2;
    iw := FPlanner.PlannerImages.Width + 2;
  end;

  if (APlannerItem.CaptionType <> ctNone) or (APlannerItem.FImageIndexList.Count > 1) then
  begin
    Canvas.Font.Assign(APlannerItem.CaptionFont);
    ColumnHeight := Canvas.TextHeight('gh') + 2;
    iw := 0;
  end
  else
    ih := 0;

  if (ih > ColumnHeight) then
    ColumnHeight := ih;

  s := APlannerItem.Text.Text;

  with FPlanner.FGrid do
  begin
    if IsRtf(s) or (APlannerItem.InplaceEdit = peRichText) then
    begin
      FPlanner.FRichEdit.Parent := Self;
      FPlanner.FRichEdit.ScrollBars := FPlanner.EditScroll;
      FPlanner.FRichEdit.PlannerItem := APlannerItem;
      FPlanner.TextToRich(s);
      FPlanner.FRichEdit.Top := ARect.Top + 3 + ColumnHeight;
      FPlanner.FRichEdit.Left := ARect.Left;
      FPlanner.FRichEdit.Width := ARect.Right - ARect.Left - 3;
      FPlanner.FRichEdit.Height := ItemHeight - 3;

      FPlanner.FRichEdit.Visible := True;
      BringWindowToTop(FPlanner.FRichEdit.Handle);
      FPlanner.FRichEdit.SetFocus;
      FPlanner.FRichEdit.SelectAll;
    end
    else
      case APlannerItem.InplaceEdit of
        {
        peMaskEdit, peEdit:
          begin
            if APlannerItem.InplaceEdit = peMaskEdit then
              FMaskEdit.EditMask := APlannerItem.EditMask
            else
              FMaskEdit.EditMask := '';
            FMaskEdit.Font.Assign(FPlanner.Font);
            if APlannerItem.ShowSelection then
              FMaskEdit.Color := APlannerItem.SelectColor
            else
              FMaskEdit.Color := APlannerItem.Color;
            FMaskEdit.PlannerItem := APlannerItem;
            FMaskEdit.Top := ARect.Top + 6 + ColumnHeight;
            FMaskEdit.Left := ARect.Left + tw + 1 + iw + ew;
            FMaskEdit.Width := ARect.Right - ARect.Left - tw - 3 - FPlanner.FItemGap -
              iw - 2 * ew;
            FMaskEdit.Height := (APlannerItem.ItemEnd - APlannerItem.ItemBegin) * RowHeights[0] - 8
              - ColumnHeight;
            FMaskEdit.BorderStyle := bsNone;
            FMaskEdit.Visible := True;
            if (APlannerItem.Text.Count > 0) then
              FMaskEdit.Text := APlannerItem.Text[0];
            BringWindowToTop(FMaskEdit.Handle);
            FMaskEdit.SetFocus;
          end;
        }
        peMemo, peMaskEdit, peEdit:
          begin
            FMemo.Parent := Self;
            FMemo.ScrollBars := FPlanner.EditScroll;
            {$IFDEF DELPHI4_LVL}
            FMemo.BiDiMode := FPlanner.BiDiMode;
            {$ENDIF}
            FMemo.Font.Assign(APlannerItem.Font);
            if APlannerItem.ShowSelection then
              FMemo.Color := APlannerItem.SelectColor
            else
              FMemo.Color := APlannerItem.Color;
            FMemo.PlannerItem := APlannerItem;
            FMemo.Top := ARect.Top + 3 + ColumnHeight;
            FMemo.Left := ARect.Left + 1 + iw + ew;
            FMemo.Width := ARect.Right - ARect.Left - 3;
            FMemo.Height := ItemHeight - 6;
            FMemo.BorderStyle := bsNone;
            FMemo.Visible := True;
            BringWindowToTop(FMemo.Handle);
            FMemo.Lines.Text := HTMLStrip(APlannerItem.Text.Text);
            FMemo.SetFocus;

            SetEditDirectSelection(ARect, X, Y);
          end;
        peCustom:
          begin
            ER.Left := ARect.Left + 3;
            ER.Top := ARect.Top + 3  + ColumnHeight;
            ER.Right := ARect.Right - 3;
            ER.Bottom := ARect.Top + ItemHeight - 6;
            if Assigned(FPlanner.FOnCustomEdit) then
              FPlanner.FOnCustomEdit(Self,ER,APlannerItem);
          end;
      end;
  end;
end;


function TAdvHeader.GetSectionIdx(X: Integer): Integer;
var
  FPlanner: TCustomPlanner;
begin
  FPlanner := Owner as TCustomPlanner;

  if FPlanner.SideBar.Position = spTop then
    Result := X + FPlanner.FGrid.TopRow - 1
  else
    Result := X + FPlanner.FGrid.LeftCol - 1;
end;

procedure TAdvHeader.SetFixedColor(const Value: TColor);
begin
  FFixedColor := Value;
  Invalidate;
end;

procedure TAdvHeader.SetFixedHeight(const Value: Integer);
begin
  FFixedHeight := Value;
  Invalidate;
end;

procedure TAdvHeader.SetShowFixed(const Value: Boolean);
begin
  FShowFixed := Value;
  Invalidate;
end;

procedure TAdvHeader.SetColorTo(const Value: TColor);
begin
  FColorTo := Value;
  Invalidate;
end;

procedure TAdvHeader.SetRotate(const Value: Boolean);
begin
  FRotate := Value;
  Invalidate;
end;

procedure TAdvHeader.DragOver(Source: TObject; X, Y: Integer;
  State: TDragState; var Accept: Boolean);
var
  FPlanner: TCustomPlanner;
  SectionIdx: Integer;
begin
  inherited;

  FPlanner := (Owner as TCustomPlanner);

  Accept := Source = FPlanner;

  SectionIdx := XYToSection(X,Y);

  if Assigned(FPlanner.OnDragOverHeader) then
    FPlanner.OnDragOverHeader(FPlanner,Source,SectionIdx,State,Accept);
end;

procedure TAdvHeader.DragDrop(Source: TObject; X, Y: Integer);
var
  FPlanner: TCustomPlanner;
  SectionIdx: Integer;
begin
  inherited;

  FPlanner := (Owner as TCustomPlanner);

  SectionIdx := XYToSection(X,Y);

  if Assigned(FPlanner.OnDragDropHeader) then
    FPlanner.OnDragDropHeader(FPlanner,Source,SectionIdx);

  if (Source = FPlanner) then
  begin
    if Assigned(FPlanner.Items.Selected) then
    begin
      FPlanner.Items.Selected.InHeader := True;
      FPlanner.Items.Selected.ItemPos := SectionIdx - 1;
      FPlanner.Items.Selected.Update;
    end;
  end;
end;

{ TAdvFooter }
procedure TAdvFooter.BeginUpdate;
begin
  inc(FUpdateCount);
end;

constructor TAdvFooter.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FUpdateCount := 0;
end;

procedure TAdvFooter.EndUpdate;
begin
  if FUpdateCount > 0 then
  begin
    dec(FUpdateCount);
    if FUpdateCount = 0 then
      Invalidate;
  end;
end;

procedure TAdvFooter.Paint;
var
  SectionIndex, w, AIdx,BIdx,MergeNum, GPos,Err: Integer;
  s:string;
  CT,CID,CV: string;
  cr: TRect;
  DrawFlags: DWord;
  r: TRect;
  pr: TRect;
  HorizontalAlign: Word;
  VerticalAlign: Word;
  AllPainted: Boolean;
  DoDraw: Boolean;
  Anchor,Strip,FocusAnchor: string;
  ml,hl,XSize,YSize: integer;
  hr: TRect;
  Planner: TCustomPlanner;
  gs: TGaugeSettings;
  txtdraw: boolean;
  paintcompl: boolean;
  startsection:  integer;
begin
  if FUpdateCount > 0 then
    Exit;

  Planner := Owner as TCustomPlanner;
  with Canvas do
  begin
    Font.Assign(Planner.Footer.Font);
    Brush.Color := FColor;

    if FLineColor = clNone then
      Pen.Color := FColor
    else
      Pen.Color := FLineColor;

    Pen.Width := 1;
    SectionIndex := 0;

    if (Orientation = hoHorizontal) then
      r := Rect(0, 0, 0, ClientHeight)
    else
      r := Rect(0, 0, ClientWidth, 0);

    AIdx := 0;
    w := 0;
    s := '';

    HorizontalAlign := AlignToFlag(FAlignment);
    VerticalAlign := 0;

    AllPainted := False;
    repeat
      MergeNum := 1;
      PaintCompl := true;

      s := '';
      if (SectionIndex + FLeftPos < Sections.Count) and (SectionIndex + FLeftPos <= Planner.Positions) then
      begin

        if (SectionIndex > 0) or (Flat and (Orientation = hoVertical)) then
          w := SectionWidth[SectionIndex + FLeftPos]
        else
        begin
          if (Orientation = hoHorizontal) then
            w := SectionWidth[SectionIndex] - 1
          else

            w := SectionWidth[SectionIndex] + 1;
        end;

        VerticalAlign := VAlignToFlag(FVAlignment);

        if FOffset = 1 then
        begin
          if (SectionIndex < Sections.Count - 1 - FLeftPos) and (SectionIndex > 0) then
          begin
            AIdx := SectionIndex + FLeftPos;
            s := Sections[AIdx];
          end
          else
          begin
            AIdx := -1;
            s := '';
          end;
        end
        else
        begin
          if (SectionIndex < Sections.Count - FLeftPos) then
            AIdx := SectionIndex + 1 + FLeftPos - 1
          else
            AIdx := 0;
          s := Sections[AIdx];
        end;

        if SectionIndex < FOffset then
          s := '';

        if (Planner.SideBar.Position in [spRight]) and (SectionIndex >= Sections.Count - 2) then
          s := '';

        if (Pos('#',s) = 1) and (AIdx > 0) then
        begin
          BIdx := AIdx - 1;
          while (BIdx >=0) and (Pos('#',Sections[BIdx]) = 1) do
          begin
            Dec(BIdx);
          end;
          s := Sections[BIdx];
        end;

        if AIdx <> -1 then
        begin
          BIdx := AIdx + 1;
          while BIdx < Sections.Count do
          begin
            if Pos('#',Sections[BIdx])=1 then
            begin
              w := w + SectionWidth[SectionIndex];
              inc(MergeNum);
            end;
            inc(BIdx);
          end;
        end;

        Inc(SectionIndex,MergeNum);
      end;

      if (Orientation = hoHorizontal) then
      begin
        r.Left := r.Right;
        Inc(r.Right, w);
        if (ClientWidth - r.Right < 2) or (SectionIndex + FLeftPos = Sections.Count) then
        begin
          r.Right := ClientWidth;
          AllPainted := True;
        end;
        if r.Right - r.Left < 32 then
          paintcompl := false;
      end
      else
      begin
        r.Top := r.Bottom;
        Inc(r.Bottom, w);

        if (ClientHeight - r.Bottom < 2) or (SectionIndex + FLeftPos = Sections.Count) then
        begin
          r.Bottom := ClientHeight;
          AllPainted := True;
        end;
        if r.Bottom - r.Top < 32 then
          paintcompl := false;
      end;

      pr := r;

      if FShowFixed and (SectionIndex > 1) then
      begin
        Canvas.Brush.Color := FFixedColor;

        if Orientation = hoHorizontal then
          r.Top := r.Bottom - FFixedHeight
        else
          r.Left := r.Right - FFixedHeight;

        FillRect(r);
        r := pr;

        if Orientation = hoHorizontal then
          r.Bottom := r.Bottom - FFixedHeight
        else
          r.Right := r.Right - FFixedHeight;

        Canvas.Brush.Color := FColor;

        if FColorTo <> clNone then
          DrawGradient(Canvas,FColor,FColorTo,64,r,Orientation = hoVertical)
        else
          FillRect(r);

        r := pr;
      end
      else
      begin
        if FColorTo <> clNone then
          DrawGradient(Canvas,FColor,FColorTo,64,r,Orientation = hoVertical)
        else
          FillRect(r);
      end;

      if FLineColor = clNone then
        Pen.Color := FColor
      else
        Pen.Color := FLineColor;

      DoDraw := True;

      if Assigned(Planner.FOnPlannerFooterDraw) then
      begin
        Font := Planner.Footer.Font;
        Brush.Color := FColor;
        Pen.Color := FLineColor;
        Pen.Width := 1;
        Planner.FOnPlannerFooterDraw(TCustomPlanner(Owner), Canvas, r, AIdx, DoDraw);
      end;

      if Planner.Sidebar.Position = spRight then
        StartSection := 0
      else
        StartSection := 1;

      if (Planner.Footer.ShowCompletion) and ((s <> '') and (SectionIndex > StartSection)) and paintcompl then
      begin
        pr := r;
        val(s,GPos,err);
        gs.Level0Color := Planner.Footer.Completion.Level0Color;
        gs.Level0ColorTo := Planner.Footer.Completion.Level0ColorTo;
        gs.Level1Color := Planner.Footer.Completion.Level1Color;
        gs.Level1ColorTo := Planner.Footer.Completion.Level1ColorTo;
        gs.Level2Color := Planner.Footer.Completion.Level2Color;
        gs.Level2ColorTo := Planner.Footer.Completion.Level2ColorTo;
        gs.Level3Color := Planner.Footer.Completion.Level3Color;
        gs.Level3ColorTo := Planner.Footer.Completion.Level3ColorTo;
        gs.BorderColor := Planner.Footer.Completion.BorderColor;
        gs.ShowBorder := Planner.Footer.Completion.ShowBorder;
        gs.Level1Perc := Planner.Footer.Completion.Level1Perc;
        gs.Level2Perc := Planner.Footer.Completion.Level2Perc;
        gs.BackgroundColor := Planner.Footer.Completion.BackgroundColor;
        gs.ShowGradient := Planner.Footer.Completion.ShowGradient;

        gs.ShowPercentage := Planner.Footer.Completion.ShowPercentage;
        gs.Stacked := Planner.Footer.Completion.Stacked;
        gs.CompletionSmooth := Planner.Footer.Completion.CompletionSmooth;
        gs.Font := Planner.Footer.Completion.Font;
        gs.Steps := Planner.Footer.Completion.Steps;
        gs.CompletionFormat := Planner.Footer.CompletionFormat;

        if Planner.Sidebar.Position = spTop then
          gs.Orientation := goVertical
        else
          gs.Orientation := goHorizontal;

        InflateRect(pr,-6,-6);
        DrawGauge(Canvas,pr,gpos,gs);
        s := '';
      end;

      if DoDraw and paintcompl then
      begin
        InflateRect(pr, -4, -2);

        if Assigned(FImageList) and (FImageList.Count + 1 + FOffset - FLeftPos >
          SectionIndex) and (SectionIndex > FOffset)
          and (SectionIndex <= Sections.Count - 1 - FLeftPos) then
        begin
          if FImagePosition = ipLeft then
          begin
            FImageList.Draw(Canvas, pr.Left, pr.Top, SectionIndex - 1 - FOffset +
              FLeftPos);
            pr.Left := pr.
            Left + FImageList.Width;
          end
          else
          begin
            pr.Right := pr.Right - FImageList.Width;
            FImageList.Draw(Canvas, pr.Right, pr.Top, SectionIndex - 1 - FOffset);
          end;
        end;

        s := CLFToLF(s);

        if Pos(#13, s) = 0 then
          VerticalAlign := VerticalAlign or DT_SINGLELINE
        else
          VerticalAlign := 0;

        pr.Bottom := pr.Top + ClientHeight;

        {
        if (Planner.PositionGroup > 0) and (Orientation = hoHorizontal)  then
          pr.Top := pr.Top + (FTextHeight shr 1);

        if (Planner.PositionGroup > 0) and (Orientation = hoVertical)  then
        begin
          pr.Left := pr.Left + (FTextHeight shr 1);
        end;
        }

        if (Orientation = hoVertical) then
        begin
          pr.Right :=  Width - 2;
          pr.Bottom := pr.Top + w - 2;
        end;


        DrawFlags := DT_NOPREFIX or DT_END_ELLIPSIS or HorizontalAlign or VerticalAlign;

        {$IFDEF DELPHI4_LVL}
        DrawFlags := Planner.DrawTextBiDiModeFlags(DrawFlags);
        {$ENDIF}

        txtdraw := true;

        if (Planner.Sidebar.Position in [spLeft, spLeftRight]) then
          txtdraw := SectionIndex > 1;

        if txtdraw then
        begin

          if Pos('</',s) > 0 then
          begin
            HTMLDrawEx(Canvas,s,pr,Planner.PlannerImages,0,0,-1,-1,1,False,False,False,False,False,False,True
              , False
              ,1,
              clBlue,clNone,clNone,clgray,Anchor,Strip,FocusAnchor,XSize,YSize,ml,hl,hr
              ,cr, CID, CV, CT, Planner.FImageCache,Planner.FContainer, Handle
              );
          end
          else
          begin
            Canvas.Brush.Style := bsClear;
            {$IFNDEF TMSDOTNET}
            DrawText(Canvas.Handle, PChar(s), Length(s), pr, DrawFlags);
            {$ENDIF}
            {$IFDEF TMSDOTNET}
            DrawText(Canvas.Handle, s, Length(s), pr, DrawFlags);
            {$ENDIF}
          end;
        end;

        if FShowFixed and (Orientation = hoHorizontal) and (SectionIndex > 1) then
          r.Bottom := r.Bottom - FFixedHeight;

        if FShowFixed and (Orientation = hoVertical) and (SectionIndex > 1) then
          r.Right := r.Right - FFixedHeight;

        if not FFlat then
        begin
          DrawEdge(Canvas.Handle, r, BDR_RAISEDINNER, BF_TOPLEFT);
          DrawEdge(Canvas.Handle, r, BDR_RAISEDINNER, BF_BOTTOMRIGHT);
        end
        else
        begin
          if (SectionIndex > 1) and (Orientation = hoHorizontal) and (FLineColor <> clNone) then
          begin
            Canvas.MoveTo(r.Left +2, r.Top);
            Canvas.LineTo(r.Left +2, r.Bottom);
          end;
          if (SectionIndex > 1) and (Orientation = hoVertical) and (FLineColor <> clNone) then
          begin
            Canvas.MoveTo(r.Left, r.Top + 2);
            Canvas.LineTo(r.Right, r.Top + 2);
          end;
        end;

        if FShowFixed and (Orientation = hoHorizontal) and (SectionIndex > 1) then
        begin
          Canvas.Pen.Color := FLineColor;
          if FFlat then
          begin
            Canvas.MoveTo(r.Left + 1,r.Bottom);
            Canvas.LineTo(r.Left + 1,R.Bottom + FFixedHeight);
          end
          else
          begin
            Canvas.MoveTo(r.Right - 1,r.Bottom);
            Canvas.LineTo(r.Right - 1,R.Bottom + FFixedHeight);
          end;
          r.Bottom := r.Bottom + FFixedHeight;
        end;

        if FShowFixed and (Orientation = hoVertical) and (SectionIndex > 1) then
        begin
          Canvas.Pen.Color := FLineColor;
          Canvas.MoveTo(r.Right,r.Bottom - 1);
          Canvas.LineTo(r.Right + + FFixedHeight,r.Bottom - 1);
          r.Right := r.Right + FFixedHeight;
        end;

        Font := Planner.Footer.Font;
        Brush.Color := FColor;
        Pen.Color := FLineColor;
        Pen.Width := 1;
      end;

    until AllPainted;
  end;
end;



{ TPlannerPrintOptions }

constructor TPlannerPrintOptions.Create;
begin
  inherited Create;
  FHeaderFont := TFont.Create;
  FFooterFont := TFont.Create;
  FFooter := TStringList.Create;
  FHeader := TStringList.Create;
  FFitToPage := True;
end;

destructor TPlannerPrintOptions.Destroy;
begin
  FFooterFont.Free;
  FHeaderFont.Free;
  FFooter.Free;
  FHeader.Free;
  inherited;
end;

procedure TPlannerPrintOptions.Assign(Source: TPersistent);
begin
  if (Source is TPlannerPrintOptions) then
  begin
    FCellHeight := (Source as TPlannerPrintOptions).CellHeight;
    FCellWidth := (Source as TPlannerPrintOptions).CellWidth;
    FLineWidth := (Source as TPlannerPrintOptions).LineWidth;
    FFitToPage := (Source as TPlannerPrintOptions).FitToPage;
    FFooter.Assign((Source as TPlannerPrintOptions).Footer);
    FFooterAlignment := (Source as TPlannerPrintOptions).FooterAlignment;
    FFooterFont.Assign((Source as TPlannerPrintOptions).FooterFont);
    FFooterSize := (Source as TPlannerPrintOptions).FooterSize;
    FHeader.Assign((Source as TPlannerPrintOptions).Header);
    FHeaderAlignment := (Source as TPlannerPrintOptions).HeaderAlignment;
    FHeaderFont.Assign((Source as TPlannerPrintOptions).HeaderFont);
    FHeaderSize := (Source as TPlannerPrintOptions).HeaderSize;
    FJobName := (Source as TPlannerPrintOptions).Jobname;
    FLeftMargin := (Source as TPlannerPrintOptions).LeftMargin;
    FOrientation := (Source as TPlannerPrintOptions).Orientation;
    FRightMargin := (Source as TPlannerPrintOptions).RightMargin;
    FSidebarWidth := (Source as TPlannerPrintOptions).SidebarWidth;
  end;
end;

procedure TPlannerPrintOptions.SetFooter(const Value: TStrings);
begin
  if Assigned(Value) then
    FFooter.Assign(Value);
end;

procedure TPlannerPrintOptions.SetFooterFont(const Value: TFont);
begin
  if Assigned(Value) then
    FFooterFont.Assign(Value);
end;

procedure TPlannerPrintOptions.SetHeader(const Value: TStrings);
begin
  if Assigned(Value) then
    FHeader.Assign(Value);
end;

procedure TPlannerPrintOptions.SetHeaderFont(const Value: TFont);
begin
  if Assigned(Value) then
    FHeaderFont.Assign(Value);
end;

{ TPlannerHTMLOptions }

constructor TPlannerHTMLOptions.Create;
begin
  inherited Create;
  FBorderSize := 1;
  FCellSpacing := 0;
  FWidth := 100;
end;

{ TPlannerItemIO }

constructor TPlannerItemIO.CreateItem(AOwner: TPlannerItems);
begin
  inherited Create(nil);

  FItem := TPlannerItem(AOwner.GetItemClass.Create(AOwner));
end;

destructor TPlannerItemIO.Destroy;
begin
  FItem.Free;
  inherited;
end;

{ TWeekDays }

procedure TWeekDays.Changed;
begin
  if Assigned(OnChanged) then
    OnChanged(Self);
end;

constructor TWeekDays.Create;
begin
  inherited;
  FSun := True;
  FSat := True;
end;

procedure TWeekDays.SetFri(const Value: Boolean);
begin
  FFri := Value;
  Changed;
end;

procedure TWeekDays.SetMon(const Value: Boolean);
begin
  FMon := Value;
  Changed;
end;

procedure TWeekDays.SetSat(const Value: Boolean);
begin
  FSat := Value;
  Changed;
end;

procedure TWeekDays.SetSun(const Value: Boolean);
begin
  FSun := Value;
  Changed;
end;

procedure TWeekDays.SetThu(const Value: Boolean);
begin
  FThu := Value;
  Changed;
end;

procedure TWeekDays.SetTue(const Value: Boolean);
begin
  FTue := Value;
  Changed;
end;

procedure TWeekDays.SetWed(const Value: Boolean);
begin
  FWed := Value;
  Changed;
end;

{ TPlannerPanel }

function TPlannerPanel.IsAnchor(x, y: Integer): string;
var
  r,hr: TRect;
  XSize,YSize, ml, hl: Integer;
  a,s,fa:string;
  CID, CV, CT: string;
  cr: TRect;

begin
  r := ClientRect;
  a := '';

  if HTMLDrawEx(Canvas, Caption, r, (Owner as TCustomPlanner).PlannerImages, x, y,
            -1, -1, 1, True, False, False, True, True, False, True
            , False
            , 1.0, clBlue, clNone, clNone, clGray, a, s, fa, XSize, YSize, ml, hl, hr
            ,cr, CID, CV, CT, (Owner as TCustomPlanner).FImageCache, (Owner as TCustomPlanner).FContainer, Handle
            ) then
    Result := a;
end;

procedure TPlannerPanel.MouseDown(Button: TMouseButton; Shift: TShiftState;
  X, Y: Integer);
var
  Anchor: string;
begin
  inherited;

  if (csDesigning in ComponentState) then
  begin
    Anchor := FPlanner.Caption.Title;
    if InputQuery('Planner caption title','Text:',Anchor) then
    begin
      FPlanner.Caption.Title := Anchor;
    end;
    Exit;
  end;

  if Pos('</',Caption) = 0 then
    Exit;

  Anchor := IsAnchor(X,Y);

  if Anchor <> '' then
  begin
    with Owner as TCustomPlanner do
    begin
      if Assigned(FOnCaptionAnchorClick) then
        FOnCaptionAnchorClick(Self.Owner,x,y,Anchor);
    end;
  end;
end;

procedure TPlannerPanel.MouseMove(Shift: TShiftState; X, Y: Integer);
var
  Anchor: string;
begin
  inherited;

  if Pos('</',Caption) = 0 then
    Exit;

  Anchor := IsAnchor(X,Y);

  if Anchor <> '' then
  begin
    if (Cursor = crDefault) or (FOldAnchor <> Anchor) then
    begin
      Self.Cursor := crHandPoint;

      with Owner as TCustomPlanner do
      begin
        if Assigned(FOnCaptionAnchorEnter) then
          FOnCaptionAnchorEnter(self.Owner,x,y,Anchor);
      end;
    end;
    FOldAnchor := Anchor;
  end
  else
  begin
    if (self.Cursor = crHandPoint) then
    begin
      Self.Cursor := crDefault;

      with (Owner as TCustomPlanner) do
      begin
        if Assigned(FOnCaptionAnchorExit) then
          FOnCaptionAnchorExit(self.Owner,x,y,FOldAnchor);
      end;
      FOldAnchor := '';
    end;
  end;
end;

constructor TPlannerPanel.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  ControlStyle := ControlStyle - [csAcceptsControls];
  FPlanner := TCustomPlanner(AOwner);
end;

procedure TPlannerPanel.CMDesignHitTest(var Msg: TCMDesignHitTest);
begin
  if (Width - msg.xpos < 20) and (Msg.Ypos < 20) and FPlanner.ShowDesignHelper then
    msg.Result := 1
  else
    inherited;
end;

procedure TPlannerPanel.Paint;
var
  DoDraw: Boolean;
  a,s,fa: string;
  CID,CV,CT : string;
  cr: TRect;
  XSize, YSize, ml, hl: Integer;
  hr: TRect;
  FPlanner: TCustomPlanner;
  DTFLAGS: DWORD;
  bmp: TBitmap;
begin
  FPlanner := (Owner as TCustomPlanner);
  DoDraw := True;
  if Assigned(FPlanner.OnPlannerCaptionDraw) then
    FPlanner.OnPlannerCaptionDraw(FPlanner, Canvas, GetClientRect, DoDraw);
    
  if DoDraw then
  begin
    if (Pos('</',Caption) > 0) or ((Owner as TCustomPlanner).Caption.BackGroundTo <> clNone) then
    begin
      Canvas.Brush.Color := (Owner as TCustomPlanner).Caption.BackGround;
      Canvas.Pen.Color := Canvas.Brush.Color;

      if ((Owner as TCustomPlanner).Caption.BackGroundTo <> clNone) then
        DrawGradient(Canvas,Canvas.Brush.Color,(Owner as TCustomPlanner).Caption.BackGroundTo,
           (Owner as TCustomPlanner).Caption.BackgroundSteps,ClientRect,(Owner as TCustomPlanner).Caption.GradientDirection = gdHorizontal)
      else
        Canvas.Rectangle(ClientRect.Left,ClientRect.Top,ClientRect.Right,ClientRect.Bottom);

      Canvas.Font.Assign(Font);

      if (Pos('</',Caption) > 0) then
      begin
        HTMLDrawEx(Canvas, Caption, ClientRect, (Owner as TCustomPlanner).PlannerImages, 0, 0,
              -1, -1, 1, False, False, False, False, False, False, True
              , False
              , 1.0, (Owner as TCustomPlanner).URLColor, clNone, clNone, clGray, a, s, fa,
              XSize, YSize, ml, hl, hr
              ,cr, CID, CV, CT, FPlanner.FImageCache, FPlanner.FContainer, Handle
              );
      end
      else
      begin
        if Pos(#13,Caption) = 0 then
          DTFLAGS := DT_VCENTER or DT_END_ELLIPSIS or DT_SINGLELINE
        else
          DTFLAGS := DT_END_ELLIPSIS or DT_WORDBREAK;

        case (Owner as TCustomPlanner).Caption.Alignment of
        taLeftJustify: DTFLAGS := DTFLAGS or DT_LEFT;
        taRightJustify: DTFLAGS := DTFLAGS or DT_RIGHT;
        taCenter: DTFLAGS := DTFLAGS or DT_CENTER;
        end;
        cr := ClientRect;       

        SetBkMode(Canvas.Handle,TRANSPARENT);

        {$IFNDEF TMSDOTNET}
        DrawText(Canvas.Handle,PChar(Caption),Length(Caption),cr,DTFLAGS);
        {$ENDIF}

        {$IFDEF TMSDOTNET}
        DrawText(Canvas.Handle,Caption,Length(Caption),cr,DTFLAGS);
        {$ENDIF}


      end;
    end
    else
      inherited;
  end;

  if (csDesigning in ComponentState) and FPlanner.ShowDesignHelper then
  begin
    bmp := TBitmap.Create;
    bmp.LoadFromResourceID(HInstance,505);
    bmp.TransparentMode := tmAuto;
    bmp.Transparent := true;
    Canvas.Draw(Width - 20, 2, bmp);
    bmp.Free;
  end;
end;

{ TPlannerScrollBar }

constructor TPlannerScrollBar.Create(AOwner: TCustomPlanner);
begin
  inherited Create;
  FOwner := AOwner;
  FStyle := ssNormal;
  FWidth := 16;
  FColor := clNone;
  FFlat := False;
end;

procedure TPlannerScrollBar.SetColor(const Value: TColor);
begin
  if FColor <> Value then
  begin
    FColor := Value;
    UpdateProps;
  end;
end;

procedure TPlannerScrollBar.SetFlat(const Value: Boolean);
begin
  if FFlat <> Value then
  begin
    FFlat := Value;
    if FFlat then
      FOwner.FGrid.FlatScrollInit
    else
      FOwner.FGrid.FlatScrollDone;


    if FOwner.PositionWidth = 0 then
    begin
      if FOwner.SideBar.Position = spTop then
        FOwner.FGrid.FlatShowScrollBar(SB_VERT,FALSE)
      else
        FOwner.FGrid.FlatShowScrollBar(SB_HORZ,FALSE);
    end;

  end;
end;

procedure TPlannerScrollBar.SetStyle(const Value: TPlannerScrollStyle);
begin
  if FStyle <> Value then
  begin
    FStyle := Value;
    UpdateProps;
  end;
end;

procedure TPlannerScrollBar.SetWidth(const Value: Integer);
begin
  if FWidth <> Value then
  begin
    FWidth := Value;
    UpdateProps;
  end;
end;

procedure TPlannerScrollBar.UpdateProps;
begin
  if FFlat then
  begin
    if FColor <>clNone then
    begin
      FOwner.FGrid.FlatSetScrollProp(WSB_PROP_VBKGCOLOR,Integer(FColor),True);
      FOwner.FGrid.FlatSetScrollProp(WSB_PROP_HBKGCOLOR,Integer(FColor),True);
    end;

    FOwner.FGrid.FlatSetScrollProp(WSB_PROP_CXVSCROLL,FWidth,True);
    FOwner.FGrid.FlatSetScrollProp(WSB_PROP_CYHSCROLL,FWidth,True);

    case FStyle of
    ssNormal:FOwner.FGrid.FlatSetScrollProp(WSB_PROP_VSTYLE,FSB_REGULAR_MODE,True);
    ssFlat:FOwner.FGrid.FlatSetScrollProp(WSB_PROP_VSTYLE,FSB_FLAT_MODE,True);
    ssEncarta:FOwner.FGrid.FlatSetScrollProp(WSB_PROP_VSTYLE,FSB_ENCARTA_MODE,True);
    end;

    case FStyle of
    ssNormal:FOwner.FGrid.FlatSetScrollProp(WSB_PROP_HSTYLE,FSB_REGULAR_MODE,True);
    ssFlat:FOwner.FGrid.FlatSetScrollProp(WSB_PROP_HSTYLE,FSB_FLAT_MODE,True);
    ssEncarta:FOwner.FGrid.FlatSetScrollProp(WSB_PROP_HSTYLE,FSB_ENCARTA_MODE,True);
    end;
  end;
end;

{ TBackground }

procedure TBackground.BackgroundChanged(Sender: TObject);
begin
  FPlanner.FGrid.Invalidate;
end;

constructor TBackground.Create(APlanner: TCustomPlanner);
begin
  inherited Create;
  FPlanner := APlanner;
  FBitmap := TBitmap.Create;
  FBitmap.OnChange := BackgroundChanged;
end;

destructor TBackground.Destroy;
begin
  FBitmap.Free;
  inherited;
end;

procedure TBackground.SetBitmap(Value: TBitmap);
begin
  FBitmap.Assign(Value);
  FPlanner.Invalidate;
end;

procedure TBackground.SetDisplay(Value: TBackgroundDisplay);
begin
  if FDisplay <> Value then
  begin
    FDisplay := Value;
    FPlanner.Invalidate;
  end;
end;

procedure TBackground.SetLeft(Value: Integer);
begin
  if FLeft <> Value then
  begin
    FLeft := Value;
    FPlanner.Invalidate;
  end;
end;

procedure TBackground.SetTop(Value: Integer);
begin
  if FTop <> Value then
  begin
    FTop := Value;
    FPlanner.Invalidate;
  end;
end;

{ TPlannerAlarmHandler }

function TPlannerAlarmHandler.HandleAlarm(Address, Message: string; Tag,
  ID: Integer; Item: TPlannerItem): Boolean;
begin
  Result := True;
end;

{ TAlarmMessage }

function TAlarmMessage.HandleAlarm(Address, Message: string; Tag,
  ID: Integer; Item: TPlannerItem): Boolean;
begin
  case Item.Alarm.NotifyType of
  anMessage:MessageDlg(Item.Alarm.Message,mtInformation,[mbok],0);
  anNotes:MessageDlg(HTMLStrip(Item.Text.Text),mtInformation,[mbok],0);
  anCaption:MessageDlg(Item.CaptionText,mtInformation,[mbok],0);
  end;
  Result := True;
end;

{ TAdvSpeedButton }

procedure TAdvSpeedButton.CMMouseEnter(var Message: TMessage);
begin
  inherited;
  Invalidate;
end;

procedure TAdvSpeedButton.CMMouseLeave(var Message: TMessage);
begin
  inherited;
  Invalidate;
end;

constructor TAdvSpeedButton.Create(AOwner: TComponent);
var
  VerInfo: TOSVersioninfo;
begin
  inherited;
  Flat := True; // change default value

{$IFNDEF TMSDOTNET}
  VerInfo.dwOSVersionInfoSize := SizeOf(TOSVersionInfo);
{$ENDIF}
{$IFDEF TMSDOTNET}
  VerInfo.dwOSVersionInfoSize := Marshal.SizeOf(TypeOf(OSVersionInfo));
{$ENDIF}
  GetVersionEx(verinfo);
  FIsWinXP := (verinfo.dwMajorVersion > 5) OR
    ((verinfo.dwMajorVersion = 5) AND (verinfo.dwMinorVersion >= 1));
end;

procedure TAdvSpeedButton.Paint;
const
  DownStyles: array[Boolean] of Integer = (BDR_RAISEDINNER, BDR_SUNKENOUTER);
var
  PaintRect: TRect;
  Offset: TPoint;
  DrawFlags: Integer;
  HTheme: THandle;
  Hot: Boolean;
  pt: TPoint;
begin
  Canvas.Font := Self.Font;
  PaintRect := Rect(0, 0, Width, Height);

  if FIsWinXP then
  begin
    if IsThemeActive then
    begin
      GetCursorPos(pt);
      pt := ScreenToClient(pt);

      Hot := PtInRect(PaintRect,pt);

      HTheme := OpenThemeData(Parent.Handle,'Scrollbar');

      if Direction = bdLeft then
      begin
      {$IFDEF TMSDOTNET}
        if FState in [bsDown, bsExclusive] then
          DrawThemeBackground(HTheme,Canvas.Handle, SBP_ARROWBTN,ABS_LEFTPRESSED,PaintRect,nil)
        else
        if Hot then
          DrawThemeBackground(HTheme,Canvas.Handle, SBP_ARROWBTN,ABS_LEFTHOT,PaintRect,nil)
        else
          DrawThemeBackground(HTheme,Canvas.Handle, SBP_ARROWBTN,ABS_LEFTNORMAL,PaintRect,nil)
      {$ENDIF}
      {$IFNDEF TMSDOTNET}
        if FState in [bsDown, bsExclusive] then
          DrawThemeBackground(HTheme,Canvas.Handle, SBP_ARROWBTN,ABS_LEFTPRESSED,@PaintRect,nil)
        else
        if Hot then
          DrawThemeBackground(HTheme,Canvas.Handle, SBP_ARROWBTN,ABS_LEFTHOT,@PaintRect,nil)
        else
          DrawThemeBackground(HTheme,Canvas.Handle, SBP_ARROWBTN,ABS_LEFTNORMAL,@PaintRect,nil)
      {$ENDIF}
      end
      else
      begin
      {$IFDEF TMSDOTNET}
        if FState in [bsDown, bsExclusive] then
          DrawThemeBackground(HTheme,Canvas.Handle, SBP_ARROWBTN,ABS_RIGHTPRESSED,PaintRect,nil)
        else
        if Hot then
          DrawThemeBackground(HTheme,Canvas.Handle, SBP_ARROWBTN,ABS_RIGHTHOT,PaintRect,nil)
        else
          DrawThemeBackground(HTheme,Canvas.Handle, SBP_ARROWBTN,ABS_RIGHTNORMAL,PaintRect,nil);
       {$ENDIF}
      {$IFNDEF TMSDOTNET}
        if FState in [bsDown, bsExclusive] then
          DrawThemeBackground(HTheme,Canvas.Handle, SBP_ARROWBTN,ABS_RIGHTPRESSED,@PaintRect,nil)
        else
        if Hot then
          DrawThemeBackground(HTheme,Canvas.Handle, SBP_ARROWBTN,ABS_RIGHTHOT,@PaintRect,nil)
        else
          DrawThemeBackground(HTheme,Canvas.Handle, SBP_ARROWBTN,ABS_RIGHTNORMAL,@PaintRect,nil);
       {$ENDIF}
      end;
      CloseThemeData(HTheme);
      Exit;
    end;
  end;

  if not Flat then
  begin
    DrawFlags := DFCS_BUTTONPUSH or DFCS_ADJUSTRECT;
    if FState in [bsDown, bsExclusive] then
      DrawFlags := DrawFlags or DFCS_PUSHED;
    DrawFrameControl(Canvas.Handle, PaintRect, DFC_BUTTON, DrawFlags);
  end
  else
  begin
    DrawEdge(Canvas.Handle, PaintRect, DownStyles[FState in [bsDown, bsExclusive]],
      BF_MIDDLE or BF_RECT);
    InflateRect(PaintRect, -1, -1);
  end;

  if not (FState in [bsDown, bsExclusive]) then
  begin
    Offset.X := 0;
    Offset.Y := 0;
  end;


  if Assigned(Glyph) then
    if not Glyph.Empty then
    begin
      Glyph.Transparent := True;
      Offset.X := 0;
      Offset.Y := 0;
      if Glyph.Width < Width then
        Offset.X := (Width - Glyph.Width) shr 1;
      if Glyph.Height < Height then
        Offset.Y := (Height - Glyph.Height) shr 1;

      if FState = bsDown then
        Canvas.Draw(Offset.X + 1 ,Offset.Y + 1,Glyph)
      else
        Canvas.Draw(Offset.X ,Offset.Y,Glyph)
    end
    else
    begin
      if FState = bsDown then
      begin
        Offset.X := 5;
        Offset.Y := 5;
      end
      else
      begin
        Offset.X := 4;
        Offset.Y := 4;
      end;
      
      Canvas.TextRect(PaintRect,Offset.X,Offset.Y,Caption);
    end;
end;

{ TPositionProps }

function TPositionProps.Add: TPositionProp;
begin
  Result := TPositionProp(Inherited Add);
end;

constructor TPositionProps.Create(AOwner: TCustomPlanner);
begin
  Inherited Create(TPositionProp);
  FOwner := AOwner;
end;

function TPositionProps.GetItem(Index: Integer): TPositionProp;
begin
  Result := TPositionProp(inherited Items[Index]);
end;

function TPositionProps.GetOwner: TPersistent;
begin
  Result := FOwner;
end;

function TPositionProps.Insert(Index: Integer): TPositionProp;
begin
  {$IFDEF DELPHI4_LVL}
  Result := TPositionProp(Inherited Insert(Index));
  {$ELSE}
  Result := TPositionProp(Inherited Add);
  {$ENDIF}
end;

procedure TPositionProps.SetItem(Index: Integer;
  const Value: TPositionProp);
begin
  inherited SetItem(Index, Value);
end;

{ TPositionProp }

procedure TPositionProp.Assign(Source: TPersistent);
begin
  inherited;
  FActiveStart := (Source as TPositionProp).ActiveStart;
  FActiveEnd := (Source as TPositionProp).ActiveEnd;
  FBackground := (Source as TPositionProp).Background;
  FColorActive := (Source as TPositionProp).ColorActive;
  FColorNonActive := (Source as TPositionProp).ColorNonActive;
  FMinSelection := (Source as TPositionProp).MinSelection;
  FMaxSelection := (Source as TPositionProp).MaxSelection;
  FColorNoSelect := (Source as TPositionProp).ColorNoSelect;
  FBrushNoSelect := (Source as TPositionProp).BrushNoSelect;
  FUse := (Source as TPositionProp).Use;
end;

procedure TPositionProp.BackgroundChanged(Sender: TObject);
begin
  TPositionProps(Collection).FOwner.FGrid.Invalidate;
end;

constructor TPositionProp.Create(Collection: TCollection);
begin
  inherited;
  FActiveStart := TPositionProps(Collection).FOwner.Display.ActiveStart;
  FActiveEnd := TPositionProps(Collection).FOwner.Display.ActiveEnd;
  FColorActive := TPositionProps(Collection).FOwner.Display.ColorActive;
  FColorNonActive := TPositionProps(Collection).FOwner.Display.ColorNonActive;
  FColorNoSelect := clRed;
  FBrushNoSelect := bsSolid;
  FBackground := TBitmap.Create;
  FBackground.OnChange := BackgroundChanged;
  FUse := True;
  FShowGap := True;
end;

destructor TPositionProp.Destroy;
begin
  TPositionProps(Collection).FOwner.Invalidate;
  FBackground.Free;
  inherited;
end;

procedure TPositionProp.SetActiveEnd(const Value: Integer);
begin
  FActiveEnd := Value;
  TPositionProps(Collection).FOwner.FGrid.Invalidate;
end;

procedure TPositionProp.SetActiveStart(const Value: Integer);
begin
  FActiveStart := Value;
  TPositionProps(Collection).FOwner.FGrid.Invalidate;
end;

procedure TPositionProp.SetBackground(const Value: TBitmap);
begin
  FBackground.Assign(Value);
  TPositionProps(Collection).FOwner.FGrid.Invalidate;
end;

procedure TPositionProp.SetBrushNoSelect(const Value: TBrushStyle);
begin
  FBrushNoSelect := Value;
  TPositionProps(Collection).FOwner.FGrid.Invalidate;
end;

procedure TPositionProp.SetColorActive(const Value: TColor);
begin
  FColorActive := Value;
  TPositionProps(Collection).FOwner.FGrid.Invalidate;
end;

procedure TPositionProp.SetColorNonActive(const Value: TColor);
begin
  FColorNonActive := Value;
  TPositionProps(Collection).FOwner.FGrid.Invalidate;
end;

procedure TPositionProp.SetColorNoSelect(const Value: TColor);
begin
  FColorNoSelect := Value;
  TPositionProps(Collection).FOwner.FGrid.Invalidate;
end;

procedure TPositionProp.SetMaxSelection(const Value: Integer);
begin
  FMaxSelection := Value;
  TPositionProps(Collection).FOwner.FGrid.Invalidate;
end;

procedure TPositionProp.SetMinSelection(const Value: Integer);
begin
  FMinSelection := Value;
  TPositionProps(Collection).FOwner.FGrid.Invalidate;
end;

procedure TPositionProp.SetShowGap(const Value: Boolean);
begin
  FShowGap := Value;
  TPositionProps(Collection).FOwner.FGrid.Invalidate;
end;

procedure TPositionProp.SetUse(const Value: Boolean);
begin
  FUse := Value;
  TPositionProps(Collection).FOwner.FGrid.Invalidate;
end;

{ TPlannerExChange }

procedure TPlannerExChange.DoExport;
begin

end;

procedure TPlannerExChange.DoImport;
begin

end;

procedure TPlannerExChange.Notification(AComponent: TComponent;
  AOperation: TOperation);
begin
  if (AOperation = opRemove) and (AComponent = FPlanner) then
    FPlanner := nil;
  inherited;
end;

function TPlannerExChange.NumItemsForExport: Integer;
var
  i: Integer;
begin
  Result := 0;
  
  if not Assigned(FPlanner) then
    Exit;

  for i := 1 to FPlanner.Items.Count do
  begin
    if FPlanner.Items[i - 1].DoExport then
      Result := Result + 1;
  end;
end;

{ TPlannerAlarm }

procedure TPlannerAlarm.Assign(Source: TPersistent);
begin
  Active := TPlannerAlarm(Source).Active;
  Address := TPlannerAlarm(Source).Address;
  Handler := TPlannerAlarm(Source).Handler;
  ID := TPlannerAlarm(Source).ID;
  Message := TPlannerAlarm(Source).Message;
  NotifyType := TPlannerAlarm(Source).NotifyType;
  Tag := TPlannerAlarm(Source).Tag;
  TimeBefore := TPlannerAlarm(Source).TimeBefore;
  TimeAfter := TPlannerAlarm(Source).TimeAfter;
  Time := TPlannerAlarm(Source).Time;
end;


{ TPlannerBarItem }

function TPlannerBarItem.CheckOwners: Boolean;
begin
  Result := False;

  // check for list
  if not Assigned(Owner) then
    Exit;
  // check for planner item
  if not Assigned(Owner.Owner) then
    Exit;
  // check for planner
  if not Assigned(Owner.Owner.Owner) then
    Exit;

  Result := True;  
end;

constructor TPlannerBarItem.create( pOwner: TPlannerBarItemList);
begin
  inherited Create;
  FOwner := pOwner;
  FColor := clGreen;
  FBegin := -1;
  FEnd := -1;
  FStyle := bsSolid;
  FOnDestroy := nil;
end;

destructor TPlannerBarItem.Destroy;
begin
  if Assigned(FOwner) then
    FOwner.Remove(Self);
  if Assigned(FOnDestroy) then
    FOnDestroy(Self);
  inherited;
end;

function TPlannerBarItem.GetEndTime: TDateTime;
var
  du: Integer;
begin
  Result := 0;

  if not CheckOwners then
    Exit;

  // Get display unit from planner
  du := Owner.Owner.Owner.Display.displayUnit;

  Result := (BarEnd * du) / 24 /60 + Owner.Owner.ItemStartTime;
end;

function TPlannerBarItem.GetStartTime: TDateTime;
var
  du: Integer;
begin
  Result := 0;

  if not CheckOwners then
    Exit;

  // Get display unit from planner
  du := Owner.Owner.Owner.Display.displayUnit;

  Result := (BarBegin * du) / 24 /60 + Owner.Owner.ItemStartTime;
end;

procedure TPlannerBarItem.SetEndTime(const pEndTime: TDateTime);
var
  du: Integer;
  dDiff: Double;
begin
  if not CheckOwners then
    Exit;

  // Get display unit from planner
  du := Owner.Owner.Owner.Display.DisplayUnit;
  dDiff := Frac(pEndTime - Owner.Owner.ItemStartTime);

  // if over start of day
  if dDiff < 0 then dDiff := dDiff + 1;

  BarEnd := Round(dDiff * 24 * 60  / du);
end;

procedure TPlannerBarItem.SetStartTime(const pStartTime: TDateTime);
var
  du: Integer;
  dDiff: Double;
begin
  if not CheckOwners then
    Exit;

  // get display unit from planner
  du := Owner.Owner.Owner.Display.DisplayUnit;
  dDiff := Frac(pStartTime - Owner.Owner.ItemStartTime);

  // if over start of day
  if dDiff < 0 then dDiff := dDiff + 1;

  BarBegin := Round(dDiff * 24 * 60  / du);
end;

{ TPlannerBarItemList }

constructor TPlannerBarItemList.Create(AOwner: TPlannerItem);
begin
  inherited Create;
  FOwner := AOwner;
end;

function TPlannerBarItemList.getItem(Index: Integer): TPlannerBarItem;
begin
  Result := nil;
  if (( Index > -1) and ( Index < Count)) then
    Result := TPlannerBarItem( inherited Items[ Index]);
end;

function TPlannerBarItemList.AddItem(pStart, pEnd: TDateTime;
  pColor: TColor; pStyle: TBrushStyle): Integer;
var
  pbi: TPlannerBarItem;
begin
  Result := -1;
  if pEnd < pStart then
    Exit;
  pbi := TPlannerBarItem.create(Self);
  pbi.StartTime := pStart;
  pbi.EndTime := pEnd;
  pbi.BarColor := pColor;
  pbi.BarStyle := pStyle;
  Result := inherited Add(pbi);
end;

destructor TPlannerBarItemList.Destroy;
var
  i: Integer;
begin
  if Count > 0 then
    for i := Count - 1 downto 0 do
      Items[ i].free;
  inherited;
end;



{ TBands }

constructor TBands.Create(AOwner: TCustomPlanner);
begin
  inherited Create;
  FOwner := AOwner;
  FActivePrimary := $00FEE7CB;
  FActiveSecondary := $00FAD9AF;
  FNonActivePrimary := clSilver;
  FNonActiveSecondary := $00A8A8A8;
end;

procedure TBands.SetActivePrimary(const Value: TColor);
begin
  FActivePrimary := Value;
  FOwner.Invalidate;
end;

procedure TBands.SetActiveSecondary(const Value: TColor);
begin
  FActiveSecondary := Value;
  FOwner.Invalidate;
end;

procedure TBands.SetNonActivePrimary(const Value: TColor);
begin
  FNonActivePrimary := Value;
  FOwner.Invalidate;
end;

procedure TBands.SetNonActiveSecondary(const Value: TColor);
begin
  FNonActiveSecondary := Value;
  FOwner.Invalidate;
end;

procedure TBands.SetShow(const Value: Boolean);
begin
  FShow := Value;
  FOwner.Invalidate;
end;


{ TCustomItemEditor }

procedure TCustomItemEditor.CreateEditor(AOwner: TComponent);
begin
end;

procedure TCustomItemEditor.DestroyEditor;
begin
  If Assigned(FOnEditDone) Then
    FOnEditDone(Self, FModalResult);
end;

procedure TCustomItemEditor.Edit(APlanner: TCustomPlanner; APlannerItem: TPlannerItem);
begin
  FPlanner := APlanner;
  if QueryEdit(APlannerItem) then
  begin
    CreateEditor(APlanner.Owner);
    try
      //FEditItem := TPlannerItem(APlanner.Items.GetItemClass.Create(APlanner.Items));
      //FEditItem.Assign(APlannerItem);

      PlannerItemToEdit(APlannerItem);
      FModalResult := Execute;
      if FModalResult = mrOK then
        EditToPlannerItem(APlannerItem);

    finally
      DestroyEditor;
    end;
  end;
end;


procedure TCustomItemEditor.EditToPlannerItem(APlannerItem: TPlannerItem);
begin

end;

function TCustomItemEditor.Execute: Integer;
begin
  Result := mrOK;
end;

procedure TCustomItemEditor.PlannerItemToEdit(APlannerItem: TPlannerItem);
begin

end;

function TCustomItemEditor.QueryEdit(APlannerItem: TPlannerItem): Boolean;
begin
  Result := True;
end;

{ TCustomItemDrawTool }

procedure TCustomItemDrawTool.DrawItem(PlannerItem: TPlannerItem;
  Canvas: TCanvas; Rect: TRect; Selected, Print: Boolean);
begin

end;

{ TPlannerItemSelection }

procedure TPlannerItemSelection.Assign(Source: TPersistent);
begin
  if Assigned(Source) then
  begin
    FAutoUnSelect := (Source as TPlannerItemSelection).AutoUnSelect;
    FButton := (Source as TPlannerItemSelection).Button;
  end;
end;

constructor TPlannerItemSelection.Create;
begin
  inherited Create;
  FAutoUnSelect := True;
  FAutoSelectOnAutoInsert := True;
  Button := sbLeft;
end;

{ TPlannerSelections }

function TPlannerSelections.Add: TPlannerSelection;
begin
  Result := TPlannerSelection(inherited Add);
end;

procedure TPlannerSelections.Clear;
begin
  while Count > 0 do
  begin
    with Items[0] do
      FOwner.UpdateSelection(SelBegin,SelEnd,SelPos,False);
    Items[0].Free;
  end;  
end;

constructor TPlannerSelections.Create(AOwner: TCustomPlanner);
begin
  inherited Create(TPlannerSelection);
  FOwner := AOwner;
end;

function TPlannerSelections.GetItem(Index: Integer): TPlannerSelection;
begin
  Result := TPlannerSelection(inherited Items[Index]);
end;

function TPlannerSelections.Insert(Index: Integer): TPlannerSelection;
begin
  Result := TPlannerSelection(inherited Insert(Index)); 
end;

procedure TPlannerSelections.SetItem(Index: Integer;
  const Value: TPlannerSelection);
begin
  inherited Items[Index] := Value;
end;

{ TPlannerFooter }

procedure TPlannerFooter.Assign(Source: TPersistent);
begin
  if (Source is TPlannerFooter) then
  begin
    FAlignment := (Source as TPlannerFooter).Alignment;
    FCaptions.Assign((Source as TPlannerFooter).Captions);
    FCompletionFormat := (Source as TPlannerFooter).CompletionFormat;
    FCompletionType := (Source as TPlannerFooter).CompletionType;
    FColor := (Source as TPlannerFooter).Color;
    FColorTo := (Source as TPlannerFooter).ColorTo;
    FCompletion.Assign((Source as TPlannerFooter).Completion);
    FCustomCompletionValue := (Source as TPlannerFooter).CustomCompletionValue;
    FHeight := (Source as TPlannerFooter).Height;
    FFlat := (Source as TPlannerFooter).Flat;
    FFont.Assign((Source as TPlannerFooter).Font);
    FImages.Assign((Source as TPlannerFooter).Images);
    FImagePosition := (Source as TPlannerFooter).ImagePosition;
    FLineColor := (Source as TPlannerFooter).LineColor;
    FShowCompletion := (Source as TPlannerFooter).ShowCompletion;
    FVAlignment := (Source as TPlannerFooter).VAlignment;
    FVisible := (Source as TPlannerFooter).Visible;
  end;

end;

constructor TPlannerFooter.Create(AOwner: TCustomPlanner);
begin
  inherited Create;
  FOwner := AOwner;
  FHeight := 32;
  FColor := clBtnFace;
  FColorTo := clWhite;
  FCompletionFormat := '%d%%';
  FCompletion := TCompletion.Create;
  FCompletion.OnChange := ItemsChanged;
  FFont := TFont.Create;
  FCaptions := TStringList.Create;
  FCaptions.OnChange := ItemsChanged;
end;

destructor TPlannerFooter.Destroy;
begin
  FCaptions.Free;
  FCompletion.Free;
  FFont.Free;
  inherited;
end;

function TPlannerFooter.GetCompletionValue(Index: Integer): Integer;
var
  e,r: integer;
begin
  r := 0;
  if FCaptions.Count > Index then
  begin
    if (FOwner.Sidebar.Visible) and (FOwner.Sidebar.Position <> spRight) then
      val(FCaptions[Index + 1],r,e)
    else
      val(FCaptions[Index],r,e);
  end;

  Result := r;
end;

procedure TPlannerFooter.ItemsChanged(Sender: TObject);
var
  SectionIndex, SectionWidth: Integer;
begin
  if (FOwner.FFooter.Sections.Count = 0) then
    Exit;
  SectionIndex := 0;
  while (SectionIndex < FCaptions.Count) and
    (SectionIndex < FOwner.FFooter.Sections.Count) do
  begin
    SectionWidth := FOwner.FFooter.SectionWidth[SectionIndex];
    FOwner.FFooter.Sections[SectionIndex] := FCaptions.Strings[SectionIndex];
    FOwner.FFooter.SectionWidth[SectionIndex] := SectionWidth;
    Inc(SectionIndex);
  end;
end;

procedure TPlannerFooter.SetAlignment(const Value: TAlignment);
begin
  FAlignment := Value;
  FOwner.FFooter.Alignment := FAlignment;
end;

procedure TPlannerFooter.SetCaptions(const Value: TStringList);
begin
  FCaptions.Assign(Value);
end;

procedure TPlannerFooter.SetColor(const Value: TColor);
begin
  FColor := Value;
  FOwner.FFooter.Color := Value;
end;

procedure TPlannerFooter.SetColorTo(const Value: TColor);
begin
  FColorTo := Value;
  FOwner.FFooter.ColorTo := Value;
end;

procedure TPlannerFooter.SetCompletionFormat(const Value: string);
begin
  FCompletionFormat := Value;
  FOwner.Invalidate;
end;

procedure TPlannerFooter.SetCompletionType(const Value: TCompletionType);
begin
  FCompletionType := Value;

  if FShowCompletion then
    FOwner.UpdateCompletion
  else
    if not (csLoading in FOwner.ComponentState) then
      Captions.Clear;
  FOwner.Invalidate;
end;

procedure TPlannerFooter.SetCompletionValue(Index: Integer;
  const Value: Integer);
begin
  while FCaptions.Count < Index do
    FCaptions.Add('0');

  if (FOwner.Sidebar.Visible) and (FOwner.Sidebar.Position <> spRight) then
    FCaptions[Index + 1] := IntToStr(Value)
  else
    FCaptions[Index] := IntToStr(Value)
end;

procedure TPlannerFooter.SetCustomCompletionValue(const Value: Boolean);
begin
  FCustomCompletionValue := Value;
  FOwner.FFooter.Invalidate;
end;

procedure TPlannerFooter.SetFlat(const Value: Boolean);
begin
  FFlat := Value;
  FOwner.FFooter.Flat := Value;
  FOwner.FGrid.UpdatePositions;
end;

procedure TPlannerFooter.SetFont(const Value: TFont);
begin
  FFont.Assign(Value);
  FOwner.FFooter.Font.Assign(Value);
end;

procedure TPlannerFooter.SetHeight(const Value: Integer);
begin
  if FHeight <> Value then
  begin
    FHeight := Value;
    FOwner.UpdateSizes;
  end;
end;

procedure TPlannerFooter.SetImagePosition(const Value: TImagePosition);
begin
  FImagePosition := Value;
end;

procedure TPlannerFooter.SetImages(const Value: TImageList);
begin
  FImages := Value;
end;

procedure TPlannerFooter.SetLineColor(const Value: TColor);
begin
  FLineColor := Value;
  FOwner.FFooter.LineColor := Value;
end;

procedure TPlannerFooter.SetShowCompletion(const Value: Boolean);
begin
  if (Value <> FShowCompletion) then
  begin
    FShowCompletion := Value;

    if FShowCompletion then
      FOwner.UpdateCompletion
    else
      Captions.Clear;

    FOwner.Invalidate;
  end;  
end;

procedure TPlannerFooter.SetVAlignment(const Value: TVAlignment);
begin
  FVAlignment := Value;
  FOwner.FFooter.VAlignment := Value;
end;

procedure TPlannerFooter.SetVisible(const Value: Boolean);
begin
  if (FVisible <> Value) then
  begin
    FVisible := Value;
    if FVisible then
    begin
      FOwner.FFooter.Color := Color;
      FOwner.FFooter.Flat := Flat;
    end;
    FOwner.UpdateSizes;
  end;
end;

{ TCompletion }

procedure TCompletion.Assign(Source: TPersistent);
begin
  if (Source is TCompletion) then
  begin
    FLevel0Color := (Source as TCompletion).Level0Color;
    FLevel0ColorTo := (Source as TCompletion).Level0ColorTo;
    FLevel1Color := (Source as TCompletion).Level1Color;
    FLevel1ColorTo := (Source as TCompletion).Level1ColorTo;
    FLevel2Color := (Source as TCompletion).Level2Color;
    FLevel2ColorTo := (Source as TCompletion).Level2ColorTo;
    FLevel3Color := (Source as TCompletion).Level3Color;
    FLevel3ColorTo := (Source as TCompletion).Level3ColorTo;
    FLevel1Perc := (Source as TCompletion).Level1Perc;
    FLevel2Perc := (Source as TCompletion).Level2Perc;
    FBorderColor := (Source as TCompletion).BorderColor;
    FShowBorder := (Source as TCompletion).ShowBorder;
    FStacked := (Source as TCompletion).Stacked;
    FShowPercentage := (Source as TCompletion).ShowPercentage;
    FFont.Assign((Source as TCompletion).Font);
    FCompletionSmooth := (Source as TCompletion).CompletionSmooth;
    FShowGradient := (Source as TCompletion).ShowGradient;
    FSteps := (Source as TCompletion).Steps;
    FBackgroundColor := (Source as TCompletion).BackgroundColor;
  end;
end;

procedure TCompletion.Changed;
begin
  if Assigned(OnChange) then
    OnChange(self);
end;

constructor TCompletion.Create;
begin
  inherited Create;
  FFont := TFont.Create;
  FLevel0Color := clLime;
  FLevel0ColorTo := clWhite;
  FLevel1Color := clYellow;
  FLevel1ColorTo := clWhite;
  FLevel2Color := $0000C6FF;
  FLevel2ColorTo := clWhite;
  FLevel3Color := clRed;
  FLevel3ColorTo := clWhite;
  FLevel1Perc := 70;
  FLevel2Perc := 90;
  FBorderColor := clGray;
  FShowBorder := True;
  FStacked := False;
  FShowPercentage := True;
  FCompletionSmooth := True;
  FShowGradient := True;
  FBackGroundColor := clBtnFace;
  FSteps := 8;
  // make sure to select a truetype font for rotation
  FFont.Name := 'Arial';
end;

destructor TCompletion.Destroy;
begin
  FFont.Free;
  inherited;
end;

procedure TCompletion.SetBackGroundColor(const Value: TColor);
begin
  FBackgroundColor := Value;
  Changed;
end;

procedure TCompletion.SetBorderColor(const Value: TColor);
begin
  FBorderColor := Value;
  Changed;
end;

procedure TCompletion.SetCompletionSmooth(const Value: Boolean);
begin
  FCompletionSmooth := Value;
  Changed;
end;

procedure TCompletion.SetFont(const Value: TFont);
begin
  FFont := Value;
  Changed;
end;

procedure TCompletion.SetLevel0Color(const Value: TColor);
begin
  FLevel0Color := Value;
  Changed;
end;

procedure TCompletion.SetLevel0ColorTo(const Value: TColor);
begin
  FLevel0ColorTo := Value;
  Changed;
end;

procedure TCompletion.SetLevel1Color(const Value: TColor);
begin
  FLevel1Color := Value;
  Changed;
end;

procedure TCompletion.SetLevel1ColorTo(const Value: TColor);
begin
  FLevel1ColorTo := Value;
  Changed;
end;

procedure TCompletion.SetLevel1Perc(const Value: Integer);
begin
  FLevel1Perc := Value;
  Changed;
end;

procedure TCompletion.SetLevel2Color(const Value: TColor);
begin
  FLevel2Color := Value;
  Changed;
end;

procedure TCompletion.SetLevel2ColorTo(const Value: TColor);
begin
  FLevel2ColorTo := Value;
  Changed;
end;

procedure TCompletion.SetLevel2Perc(const Value: Integer);
begin
  FLevel2Perc := Value;
  Changed;
end;

procedure TCompletion.SetLevel3Color(const Value: TColor);
begin
  FLevel3Color := Value;
  Changed;
end;

procedure TCompletion.SetLevel3ColorTo(const Value: TColor);
begin
  FLevel3ColorTo := Value;
  Changed;
end;

procedure TCompletion.SetShowBorder(const Value: Boolean);
begin
  FShowBorder := Value;
  Changed;
end;

procedure TCompletion.SetShowGradient(const Value: Boolean);
begin
  FShowGradient := Value;
  Changed;
end;

procedure TCompletion.SetShowPercentage(const Value: Boolean);
begin
  FShowPercentage := Value;
  Changed;
end;

procedure TCompletion.SetStacked(const Value: Boolean);
begin
  FStacked := Value;
  Changed;
end;

procedure TCompletion.SetSteps(const Value: Integer);
begin
  FSteps := Value;
  Changed;
end;

{ TBalloonSettings }

constructor TBalloonSettings.Create;
begin
  inherited Create;
  FTextColor := clNone;
  FBackgroundColor := clNone;
  FInitialDelay := -1;
  FAutoHideDelay := -1;
  FReshowDelay := -1;
  FEnable := True;
end;

procedure TBalloonSettings.SetEnable(const Value: boolean);
begin
  FEnable := Value;
  if Assigned(FOnEnableChange) then
    FOnEnableChange(self);
end;

{$IFDEF TMSSKINS}

{ TPlannerSkin }

procedure TPlannerSkin.Assign(Source: TPersistent);
begin
  if (Source is TPlannerSkin) then
  begin
    FSkinTop.Assign( (Source as TPlannerSkin).SkinTop);
    FSkinBottom.Assign( (Source as TPlannerSkin).SkinBottom);
    FSkinCenter.Assign( (Source as TPlannerSkin).SkinCenter);
    FSkinSelectTop.Assign( (Source as TPlannerSkin).SkinSelectTop);
    FSkinSelectBottom.Assign( (Source as TPlannerSkin).SkinSelectBottom);
    FSkinSelectCenter.Assign( (Source as TPlannerSkin).SkinSelectCenter);
    FSkinX := (Source as TPlannerSkin).SkinX;
    FSkinY := (Source as TPlannerSkin).SkinY;
    FSkinCaptionX := (Source as TPlannerSkin).SkinCaptionX;
    FSkinCaptionY := (Source as TPlannerSkin).SkinCaptionY;
  end
  else
    raise Exception.Create('Cannot assign object to '+ClassName);
end;

constructor TPlannerSkin.Create(AOwner: TCustomControl);
begin
  inherited Create;
  FOwner := AOwner;
  FSkinTop := TBitmap.Create;
  FSkinCenter := TBitmap.Create;
  FSkinBottom := TBitmap.Create;
  FSkinSelectTop := TBitmap.Create;
  FSkinSelectCenter := TBitmap.Create;
  FSkinSelectBottom := TBitmap.Create;
end;

destructor TPlannerSkin.Destroy;
begin
  FSkinTop.Free;
  FSkinBottom.Free;
  FSkinCenter.Free;
  FSkinSelectTop.Free;
  FSkinSelectBottom.Free;
  FSkinSelectCenter.Free;
  inherited;
end;

procedure TPlannerSkin.LoadFromFile(Filename: string);
var
  inifile: TIniFile;
  fn: string;
begin
  inifile := TIniFile.Create(Filename);

  fn := inifile.ReadString('NORMAL','TOP','');
  if fn <> '' then
    SkinTop.LoadFromFile(fn);

  fn := inifile.ReadString('NORMAL','CENTER','');
  if fn <> '' then
    SkinCenter.LoadFromFile(fn);

  fn := inifile.ReadString('NORMAL','BOTTOM','');
  if fn <> '' then
    SkinBottom.LoadFromFile(fn);

  fn := inifile.ReadString('SELECTED','TOP','');
  if fn <> '' then
    SkinSelectTop.LoadFromFile(fn);

  fn := inifile.ReadString('SELECTED','CENTER','');
  if fn <> '' then
    SkinSelectCenter.LoadFromFile(fn);

  fn := inifile.ReadString('SELECTED','BOTTOM','');
  if fn <> '' then
    SkinSelectBottom.LoadFromFile(fn);


  SkinX := inifile.ReadInteger('MARGIN','X',0);
  SkinY := inifile.ReadInteger('MARGIN','Y',0);
  SkinCaptionX := inifile.ReadInteger('MARGIN','CAPTIONX',0);
  SkinCaptionY := inifile.ReadInteger('MARGIN','CAPTIONY',0);

  inifile.Free;

  if Assigned(OnChange) then
    OnChange(Self);

  FOwner.Invalidate;
end;

procedure TPlannerSkin.ClearSkin;
begin
  SkinTop.Assign(nil);
  SkinCenter.Assign(nil);
  SkinBottom.Assign(nil);
  SkinSelectTop.Assign(nil);
  SkinSelectCenter.Assign(nil);
  SkinSelectBottom.Assign(nil);

  if Assigned(OnChange) then
    OnChange(Self);
end;

procedure TPlannerSkin.SetSkinBottom(const AValue: TBitmap);
begin
  FSkinBottom.Assign(AValue);
  FOwner.Invalidate;
end;

procedure TPlannerSkin.SetSkinCenter(const AValue: TBitmap);
begin
  FSkinCenter.Assign(AValue);
  FOwner.Invalidate;
end;

procedure TPlannerSkin.SetSkinSelectBottom(const AValue: TBitmap);
begin
  FSkinSelectBottom.Assign(AValue);
  FOwner.Invalidate;
end;

procedure TPlannerSkin.SetSkinSelectCenter(const AValue: TBitmap);
begin
  FSkinSelectCenter.Assign(AValue);
  FOwner.Invalidate;
end;

procedure TPlannerSkin.SetSkinSelectTop(const AValue: TBitmap);
begin
  FSkinSelectTop.Assign(AValue);
  FOwner.Invalidate;
end;

procedure TPlannerSkin.SetSkinTop(const AValue: TBitmap);
begin
  FSkinTop.Assign(AValue);
  FOwner.Invalidate;
end;

{$ENDIF}


{ TPlannerSelection }

procedure TPlannerSelection.Update;
begin
  with (Collection as TPlannerSelections) do
    FOwner.UpdateSelection(SelBegin, SelEnd, SelPos, True);
end;

{ TGroupCollectionItem }

procedure TGroupCollectionItem.Assign(Source: TPersistent);
begin
  if (Source is TGroupCollectionItem) then
  begin
    FCaption := (Source as TGroupCollectionItem).Caption;
    {$IFNDEF TMSDOTNET}
    FWideCaption := (Source as TGroupCollectionItem).Caption;
    {$ENDIF}
    FSpan := (Source as TGroupCollectionItem).Span;
    FTag := (Source as TGroupCollectionItem).Tag;
    FImageIndex := (Source as TGroupCollectionItem).ImageIndex;
  end;
end;

constructor TGroupCollectionItem.Create(Collection: TCollection);
begin
  inherited;
  FTag := 0;
  FSpan := 1;
  FImageIndex := -1;
end;

procedure TGroupCollectionItem.SetCaption(const Value: string);
begin
  FCaption := Value;
  (Collection as TGroupCollection).DoChanged;
end;

procedure TGroupCollectionItem.SetImageIndex(const Value: Integer);
begin
  FImageIndex := Value;
  (Collection as TGroupCollection).DoChanged;
end;

procedure TGroupCollectionItem.SetSpan(const Value: Integer);
begin
  FSpan := Value;
  (Collection as TGroupCollection).DoChanged;
end;

{$IFNDEF TMSDOTNET}
procedure TGroupCollectionItem.SetWideCaption(const Value: widestring);
begin
  FWideCaption := Value;
  (Collection as TGroupCollection).DoChanged;
end;
{$ENDIF}

{ TGroupCollection }

function TGroupCollection.Add: TGroupCollectionItem;
begin
  Result := TGroupCollectionItem(inherited Add);
  DoChanged;  
end;

constructor TGroupCollection.Create(AOwner: TPersistent; AItemClass: TCollectionItemClass);
begin
  inherited Create(AOwner, TGroupCollectionItem);
  FOwner := AOwner;
end;

procedure TGroupCollection.Assign(Source: TPersistent);
begin
  inherited;
end;

procedure TGroupCollection.DoChanged;
begin
  if Assigned(FOnChange) then
    FOnChange(Self);
end;

function TGroupCollection.GetItem(Index: Integer): TGroupCollectionItem;
begin
  Result := TGroupCollectionItem(inherited GetItem(Index)); 
end;


function TGroupCollection.Insert(Index: Integer): TGroupCollectionItem;
begin
  Result := TGroupCollectionItem(inherited Insert(Index));
  DoChanged;
end;

procedure TGroupCollection.SetItem(Index: Integer;
  AItem: TGroupCollectionItem);
begin
  inherited SetItem(Index, AItem);
  DoChanged;
end;

{ TPlannerStringList }

function TPlannerStringList.GetItem(Index: Integer): string;
begin
  if (Index >= Count) or (Index < 0) then
    result := ''
  else
    result := inherited Strings[Index];
end;

procedure TPlannerStringList.SetItem(Index: Integer; const Value: string);
begin
  if (Index < Count) then
    inherited Strings[Index] := Value;
end;

{$IFDEF FREEWARE}
function Scramble(s:string): string;
var
  r:string;
  i: integer;
  c: char;
  b: byte;
begin
  r := '';
  for i := 1 to length(s) do
  begin
    b := ord(s[i]);
    b := (b and $E0) + ((b and $1F) xor 5);
    c := chr(b);
    r := r + c;
  end;
  Result := r;
end;
{$ENDIF}



initialization
  {$IFDEF ISDELPHI}
  try
    RegisterClass(TSpeedButton);
    RegisterClass(TPlannerGrid);
    RegisterClass(TPlannerItem);
    RegisterClass(TPlannerItems);
    RegisterClass(TPlannerPanel);
    RegisterClass(TPlannerAlarm);
  except
  end;
  {$ENDIF}  

  RegisterClass(THeader);
  CF_PLANNERITEM := RegisterClipboardFormat('TPlanner Item');
  Screen.Cursors[crZoomIn] := LoadCursor(hinstance,'TMSZOOMIN');
  Screen.Cursors[crZoomOut] := LoadCursor(hinstance,'TMSZOOMOUT');

  {$IFDEF FREEWARE}
  if (FindWindow(PChar(Scramble('QDuuilfdqljk')), nil) = 0) OR
     (FindWindow(PChar(Scramble('QDuuGplia`w')), nil) = 0) then
  begin
    MessageBox(0,PChar(Scramble('Duuilfdqljk%pv`v%qwldi%s`wvljk%jc%QHV%vjcqrdw`%fjhujk`kqv+')+#13#10+Scramble('Fjkqdfq%QHV%vjcqrdw`%mqqu?**rrr+qhvvjcqrdw`+fjh%cjw%sdila%ilf`kvlkb+')),PChar(Scramble('Rdwklkb')),MB_OK);
  end
  {$ENDIF}
end.
