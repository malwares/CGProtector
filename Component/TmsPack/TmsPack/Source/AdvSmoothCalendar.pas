{**************************************************************************}
{ TAdvSmoothCalendar component                                             }
{ for Delphi & C++Builder                                                  }
{                                                                          }
{ written                                                                  }
{   TMS Software                                                           }
{   copyright © 2010                                                       }
{   Email : info@tmssoftware.com                                           }
{   Web : http://www.tmssoftware.com                                       }
{                                                                          }
{ The source code is given as is. The author is not responsible            }
{ for any possible damage done due to the use of this code.                }
{ The component can be freely used in any application. The complete        }
{ source code remains property of the author and may not be distributed,   }
{ published, given or sold in any form as such. No parts of the source     }
{ code can be included in any other component or application without       }
{ written authorization of the author.                                     }
{**************************************************************************}

unit AdvSmoothCalendar;

{$I TMSDEFS.INC}

interface

uses
  Forms, Windows, SysUtils, Graphics, Classes, Controls,
  Messages, GDIPFill, Math, ExtCtrls, AdvStyleIF,
  AdvGDIP, ComCtrls
{$IFDEF DELPHI7_LVL}
  , DateUtils
{$ENDIF}
  ;

const
  MAJ_VER = 2; // Major version nr.
  MIN_VER = 0; // Minor version nr.
  REL_VER = 1; // Release nr.
  BLD_VER = 0; // Build nr.

  // version history
  // v1.0.0.0 : First release
  // v1.0.0.1 : Fixed : click on currentdate for calendar with animation repaints incorrect
  // v1.1.0.0 : New: DateAppearance.WeekendFill to mark the weekend days.
  //          : New: Exposed Event OnDateHint
  //          : New: Exposed Event OnDateFill to customize the Fill of the date.
  // v1.1.0.1 : Fix with default weekend fill
  // v1.1.0.2 : Fix with font and fill changing in OnDateFill
  // v1.1.0.3 : Fixed : issue with changing SelectedDate property not reflecting at runtime.
  //          : Fixed : issue with OnMonthChanged, OnYearChanged not called when changing month or year with keyboard.
  // v1.5.0.0 : New : Calendar Date Status Indicator
  //          : New : Exposed Event OnDateStatus
  // v1.6.0.0 : New : Days before and after current month with seperate fill and font
  //          : Fixed : Multi Selected Date fill disappearing when resizing calendar
  // v1.6.0.1 : Fixed : Calendar disappearing when clicking on a day when animating month switch
  // v1.6.0.2 : Fixed : Issue with Save and load from Clipboard
  //          : Fixed : StatusAppearance not assigned when displaying statusmessages
  // v1.6.0.3 : Fixed : Border issue with OnDateFill
  // v1.6.0.4 : Fixed : Issue with FShowCurrentDate := true in SetSelectedDate
  //          : Fixed : Issue with multi select date in multiple months
  // v1.6.1.0 : New : Support for Windows Vista and Windows Seven Style
  //          : Fixed : Issue with Calculating Week numbers
  //          : Fixed : issue with Assign method in TAdvSmoothCalendar DateAppearance
  //          : Fixed : issue with animating months when footer is not visible.
  // v1.6.2.0 : New : Built-in support for reduced color set for use with terminal servers
  // v1.6.3.0 : New : functions CurrentDay, CurrentMonth and CurrentYear
  // v1.6.4.0 : New : Office 2010 Touch Support
  //          : New : Change month with left to right or right to left mouse flick
  // v1.6.5.0 : New : Exposed event OnDateText
  // v1.6.6.0 : New : Event OnBeforeSelectDate
  // v1.6.6.1 : Improved : Functions Year and Month returning the current Year and Current month after date change
  // v1.6.7.0 : New : Built-in support for Office 2010 colors
  // v2.0.0.0 : New : Spin button for fast year switch on hovering
  //          : New : Disjunct Date selection
  //          : New : OnSelectDisjunctDate event called when selecting dates
  //          : New : OnDateStatusClick event called when clicking status indicator
  // v2.0.0.1 : Fixed : Issue with changing year in spinner in non-day mode
  //          : Fixed : Issue with selecting month in non animation mode
  //          : Improved : ChangeMode to change to a mode of choice
  // v2.0.1.0 : New : SelectDisjunctDates procedure
  //          : Fixed : Issue with borders in AdvSmoothCalendar
  //          : Fixed : Issue with selecting date

type
  TAdvSmoothCalendar = class;

  TWinCtrl = class(TWinControl)
  public
    procedure PaintCtrls(DC: HDC; First: TControl);
  end;

  TAdvSmoothCalendarCaptionLocation = (cpTopLeft, cpTopRight, cpTopCenter, cpCenterLeft, cpCenterRight, cpCenterCenter, cpBottomLeft, cpBottomRight, cpBottomCenter, cpCustom);

  TAdvSmoothCalendarHeader = class(TPersistent)
  private
    FOwner: TAdvSmoothCalendar;
    FCaptionPosition: TAdvSmoothCalendarCaptionLocation;
    FFont: TFont;
    FHeight: integer;
    FOnChange: TNotifyEvent;
    FVisible: Boolean;
    FCaptionTop: integer;
    FCaptionLeft: integer;
    FFill: TGDIPFill;
    FArrowsVisible: Boolean;
    FArrowColor: TColor;
    FArrowSize: Integer;
    procedure SetCaptionLeft(const Value: integer);
    procedure SetCaptionPosition(const Value: TAdvSmoothCalendarCaptionLocation);
    procedure SetCaptionTop(const Value: integer);
    procedure SetFill(const Value: TGDIPFill);
    procedure SetFont(const Value: TFont);
    procedure SetHeight(const Value: integer);
    procedure SetVisible(const Value: Boolean);
    procedure SetArrowColor(const Value: TColor);
    procedure SetArrowsVisible(const Value: Boolean);
    procedure SetArrowSize(const Value: Integer);
  protected
    procedure Changed;
    procedure FontChanged(Sender: TObject);
    procedure FillChanged(Sender: TObject);
    function GetHeight: integer;
  public
    constructor Create(AOwner: TAdvSmoothCalendar);
    destructor Destroy; override;
    procedure Assign(Source: TPersistent); override;
  published
    property Fill: TGDIPFill read FFill write SetFill;
    property ArrowColor: TColor read FArrowColor write SetArrowColor default clWhite;
    property ArrowsVisible: Boolean read FArrowsVisible write SetArrowsVisible default true;
    property ArrowSize: Integer read FArrowSize write SetArrowSize default 10;
    property Height: integer read FHeight write SetHeight default 25;
    property CaptionPosition: TAdvSmoothCalendarCaptionLocation read FCaptionPosition write SetCaptionPosition default cpCenterCenter;
    property CaptionLeft: integer read FCaptionLeft write SetCaptionLeft default 0;
    property CaptionTop: integer read FCaptionTop write SetCaptionTop default 0;
    property Font: TFont read FFont write SetFont;
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
    property Visible: Boolean read FVisible write SetVisible default true;
  end;

  TAdvSmoothCalendarFooter = class(TPersistent)
  private
    FOwner: TAdvSmoothCalendar;
    FCaptionTop: integer;
    FCaptionLeft: integer;
    FCaptionPosition: TAdvSmoothCalendarCaptionLocation;
    FFont: TFont;
    FVisible: Boolean;
    FCurrentDateCaption: Boolean;
    FCurrentDateFormat: string;
    FFill: TGDIPFill;
    FHeight: integer;
    FOnChange: TNotifyEvent;
    FCaption: string;
    procedure SetCaptionLeft(const Value: integer);
    procedure SetCaptionPosition(
      const Value: TAdvSmoothCalendarCaptionLocation);
    procedure SetCaptionTop(const Value: integer);
    procedure SetCurrentDateCaption(const Value: Boolean);
    procedure SetFill(const Value: TGDIPFill);
    procedure SetFont(const Value: TFont);
    procedure SetHeight(const Value: integer);
    procedure SetVisible(const Value: Boolean);
    procedure SetCaption(const Value: string);
    procedure SetCurrentDateFormat(const Value: string);
  protected
    procedure Changed;
    procedure FontChanged(Sender: TObject);
    procedure FillChanged(Sender: TObject);
    function GetHeight: integer;
  public
    constructor Create(AOwner: TAdvSmoothCalendar);
    destructor Destroy; override;
    procedure Assign(Source: TPersistent); override;
  published
    property Fill: TGDIPFill read FFill write SetFill;
    property Height: integer read FHeight write SetHeight default 25;
    property Caption: string read FCaption write SetCaption;
    property CaptionPosition: TAdvSmoothCalendarCaptionLocation read FCaptionPosition write SetCaptionPosition default cpCenterCenter;
    property CaptionLeft: integer read FCaptionLeft write SetCaptionLeft default 0;
    property CaptionTop: integer read FCaptionTop write SetCaptionTop default 0;
    property Font: TFont read FFont write SetFont;
    property Visible: Boolean read FVisible write SetVisible default true;
    property CurrentDateCaption: Boolean read FCurrentDateCaption write SetCurrentDateCaption default true;
    property CurrentDateFormat: string read FCurrentDateFormat write SetCurrentDateFormat;
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
  end;

  TAdvSmoothCalendarDateAppearance = class;

  TAdvSmoothCalendarDateWeekNumbers = class(TPersistent)
  private
    FOwner: TAdvSmoothCalendarDateAppearance;
    FFont: TFont;
    FVisible: Boolean;
    FFill: TGDIPFill;
    FOnChange: TNotifyEvent;
    FWidth: Integer;
    procedure SetFill(const Value: TGDIPFill);
    procedure SetFont(const Value: TFont);
    procedure SetVisible(const Value: Boolean);
    procedure SetWidth(const Value: Integer);
  protected
    procedure Changed;
    procedure FontChanged(Sender: TObject);
    procedure FillChanged(Sender: TObject);
  public
    constructor Create(AOwner: TAdvSmoothCalendarDateAppearance);
    destructor Destroy; override;
    procedure Assign(Source: TPersistent); override;
    procedure AssignVisuals(Source: TPersistent);
    function GetWidth: integer;
  published
    property Visible: Boolean read FVisible write SetVisible default false;
    property Font: TFont read FFont write SetFont;
    property Fill: TGDIPFill read FFill write SetFill;
    property Width: Integer read FWidth write SetWidth default 30;
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
  end;

  TAdvSmoothCalendarStartDay = (Sunday, Monday, Tuesday, Wednesday, Thursday, Friday, Saturday);

  TAdvSmoothCalendarDateAppearance = class(TPersistent)
  private
    FOwner: TAdvSmoothCalendar;
    FDayOfWeekFill: TGDIPFill;
    FSelectedDateFont: TFont;
    FDateFont: TFont;
    FSelectedDateFill: TGDIPFill;
    FCurrentDateFont: TFont;
    FHoverDateFont: TFont;
    FDateFill: TGDIPFill;
    FCurrentDateFill: TGDIPFill;
    FHoverDateFill: TGDIPFill;
    FDayOfWeekFont: TFont;
    FOnChange: TNotifyEvent;
    FWeekNumbers: TAdvSmoothCalendarDateWeekNumbers;
    FMonthFont: TFont;
    FYearFont: TFont;
    FStartDay: TAdvSmoothCalendarStartDay;
    FDisabledDateFont: TFont;
    FDisabledDateFill: TGDIPFill;
    FWeekendFont: TFont;
    FWeekendFill: TGDIPFill;
    FShowDaysBefore: Boolean;
    FShowDaysAfter: Boolean;
    FDateBeforeFill: TGDIPFill;
    FDateAfterFill: TGDIPFill;
    FDateAfterFont: TFont;
    FDateBeforeFont: TFont;
    procedure SetCurrentDateFill(const Value: TGDIPFill);
    procedure SetCurrentDateFont(const Value: TFont);
    procedure SetDateFill(const Value: TGDIPFill);
    procedure SetDateFont(const Value: TFont);
    procedure SetDayOfWeekFill(const Value: TGDIPFill);
    procedure SetDayOfWeekFont(const Value: TFont);
    procedure SetHoverDateFill(const Value: TGDIPFill);
    procedure SetHoverDateFont(const Value: TFont);
    procedure SetSelectedDateFill(const Value: TGDIPFill);
    procedure SetSelectedDateFont(const Value: TFont);
    procedure SetWeekNumbers(const Value: TAdvSmoothCalendarDateWeekNumbers);
    procedure SetMonthFont(const Value: TFont);
    procedure SetYearFont(const Value: TFont);
    procedure SetStartDay(const Value: TAdvSmoothCalendarStartDay);
    procedure SetDisabledDateFill(const Value: TGDIPFill);
    procedure SetDisabledDateFont(const Value: TFont);
    procedure SetWeekendFill(const Value: TGDIPFill);
    procedure SetWeekendFont(const Value: TFont);
    procedure SetShowDaysAfter(const Value: Boolean);
    procedure SetShowDaysBefore(const Value: Boolean);
    procedure SetDateAfterFill(const Value: TGDIPFill);
    procedure SetDateBeforeFill(const Value: TGDIPFill);
    procedure SetDateAfterFont(const Value: TFont);
    procedure SetDateBeforeFont(const Value: TFont);
  protected
    procedure Changed;
    procedure FontChanged(Sender: TObject);
    procedure FillChanged(Sender: TObject);
    procedure WeekNumbersChanged(Sender: TObject);
  public
    constructor Create(AOwner: TAdvSmoothCalendar);
    destructor Destroy; override;
    procedure Assign(Source: TPersistent); override;
    procedure AssignVisuals(Source: TPersistent);
  published
    property DateFont: TFont read FDateFont write SetDateFont;
    property DateFill: TGDIPFill read FDateFill write SetDateFill;
    property DayOfWeekFont: TFont read FDayOfWeekFont write SetDayOfWeekFont;
    property DayOfWeekFill: TGDIPFill read FDayOfWeekFill write SetDayOfWeekFill;
    property SelectedDateFont: TFont read FSelectedDateFont write SetSelectedDateFont;
    property SelectedDateFill: TGDIPFill read FSelectedDateFill write SetSelectedDateFill;
    property CurrentDateFont: TFont read FCurrentDateFont write SetCurrentDateFont;
    property CurrentDateFill: TGDIPFill read FCurrentDateFill write SetCurrentDateFill;
    property WeekendFill: TGDIPFill read FWeekendFill write SetWeekendFill;
    property WeekendFont: TFont read FWeekendFont write SetWeekendFont;
    property HoverDateFont: TFont read FHoverDateFont write SetHoverDateFont;
    property HoverDateFill: TGDIPFill read FHoverDateFill write SetHoverDateFill;
    property MonthDateFont: TFont read FMonthFont write SetMonthFont;
    property YearDateFont: TFont read FYearFont write SetYearFont;
    property WeekNumbers: TAdvSmoothCalendarDateWeekNumbers read FWeekNumbers write SetWeekNumbers;
    property StartDay: TAdvSmoothCalendarStartDay read FStartDay write SetStartDay default Sunday;
    property DisabledDateFont: TFont read FDisabledDateFont write SetDisabledDateFont;
    property DisabledDateFill: TGDIPFill read FDisabledDateFill write SetDisabledDateFill;
    property ShowDaysBefore: Boolean read FShowDaysBefore write SetShowDaysBefore default false;
    property ShowDaysAfter: Boolean read FShowDaysAfter write SetShowDaysAfter default false;
    property DateBeforeFill: TGDIPFill read FDateBeforeFill write SetDateBeforeFill;
    property DateAfterFill: TGDIPFill read FDateAfterFill write SetDateAfterFill;
    property DateBeforeFont: TFont read FDateBeforeFont write SetDateBeforeFont;
    property DateAfterFont: TFont read FDateAfterFont write SetDateAfterFont;
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
  end;

  TDisjunctDateTimeArray = array of TDateTime;

  TAdvSmoothCalendarDateRange = (drSingledate, drMultiDates);

  TAdvSmoothCalendarDateKind = (dkNormal, dkWeekend, dkCurrent, dkDisabled, dkHovered, dkSelected);

  TAdvSmoothCalendarDateMode = (dmDay, dmMonth, dmYear);

  TAdvSmoothCalendarBeforeDateSelectedEvent = procedure(Sender: TObject; Mode: TAdvSmoothCalendarDateMode; Date: TDateTime; var AllowChange: Boolean) of object;

  TAdvSmoothCalendarDateSelectedEvent = procedure(Sender: TObject; Mode: TAdvSmoothCalendarDateMode; Date: TDateTime) of object;

  TAdvSmoothCalendarMultiDateSelectedEvent = procedure(Sender: TObject; Mode: TAdvSmoothCalendarDateMode; StartDate, EndDate: TDateTime) of object;

  TAdvSmoothCalendarDisjunctDateSelectedEvent = procedure(Sender: TObject; Mode: TAdvSmoothCalendarDateMode; DisjunctDates: TDisjunctDateTimeArray) of object;

  TAdvSmoothCalendarDateModeChangedEvent = procedure(Sender: TObject; Mode, ModeTo: TAdvSmoothCalendarDateMode; var allow: Boolean) of object;

  TAdvSmoothCalendarMonthChangedEvent = procedure(Sender: TObject; Month: integer) of object;

  TAdvSmoothCalendarYearChangedEvent = procedure(Sender: TObject; Year: integer) of object;

  TAdvSmoothCalendarYearRangeChangedEvent = procedure(Sender: TObject; YearFrom, YearTo: integer) of object;

  TAdvSmoothCalendarCurrentDayClickEvent = procedure(Sender: TObject; var Allow: Boolean) of object;

  TAdvSmoothCalendarDateHintEvent = procedure(Sender: TObject; Date: TDateTime; var hint: String) of object;

  TAdvSmoothCalendarDateFillEvent = procedure(Sender: TObject; AFill: TGDIPFill; AFont: TFont; Date: TDateTime; DateKind: TAdvSmoothCalendarDateKind) of object;

  TAdvSmoothCalendarDateTextEvent = procedure(Sender: TObject; Date: TDateTime; AFont: TFont; var AText:String) of object;

  TAdvSmoothCalendarForceDateMode = (fdNone, fdDay, fdMonth, fdYear);

  TAdvSmoothCalendarGetDateStatusEvent = procedure(Sender: TObject; Date: TDateTime; var StatusMessage: String;
    Fill: TGDIPStatus; var OffsetX: integer; var OffsetY: integer) of object;

  TAdvSmoothCalendarStatusClickEvent = procedure(Sender: TObject; StatusMessage: String; Date: TDateTime) of object;

  TAdvSmoothCalendarDrawDayEvent = procedure(Sender: TObject; Date: TDateTime; var Allow: Boolean) of object;

  TDateStatus = record
  Date: TDateTime;
  Text: String;
  Found: Boolean;
  end;

  TAdvSmoothCalendar = class(TCustomControl, ITMSStyle)
  private
    FTick: Cardinal;
    FLoading: Boolean;
    FDisjunctDays: TDisjunctDateTimeArray;
    FUpDown: tUpDown;
    FMx, FMy: Integer;
    FMultiDateSet: Boolean;
    FMouseDown, FFocused, FDesignTime: Boolean;
    arrMulti: array of TGPRectF;
    FRows: integer;
    FTempDateMode, FDateMode: TAdvSmoothCalendarDateMode;
    FAnimateDateMode, FAnimateDayOpc, FAnimateOpacity, FAnimate, Fanimating: Boolean;
    FStartPos, FCurrentPos, FPosTo: single;
    FYearOpc, FYearOpcTo, FDayOpc, FDayOpcTo, FMonthOpc, FMonthOpcTo, FWeekNumberOpc, FWeekNumberOpcTo: Byte;
    FAnimateTimer: TTimer;
    FStartDate, FEndDate: TDateTime;
    FSelectedDateRange: TAdvSmoothCalendarDateRange;
    FHoverDate: TDateTime;
    FFocusDate, FSelectedDate: TDateTime;
    FCurrentDate: TDateTime;
    FFill: TGDIPFill;
    FTransparent: Boolean;
    FHeader: TAdvSmoothCalendarHeader;
    FNextYearFrom, FNextYearTo, FCurrentYearFrom, FCurrentYearTo, FNextYear, FCurrentYear, FYear: integer;
    FNextMonth, FCurrentMonth, FMonth: integer;
    FCurrentDay: integer;
    FDateAppearance: TAdvSmoothCalendarDateAppearance;
    FFooter: TAdvSmoothCalendarFooter;
    FAnimation: Boolean;
    FOnSelectDate: TAdvSmoothCalendarDateSelectedEvent;
    FOnDateModeChanged: TAdvSmoothCalendarDateModeChangedEvent;
    FOnYearChanged: TAdvSmoothCalendarYearChangedEvent;
    FOnMonthChanged: TAdvSmoothCalendarMonthChangedEvent;
    FOnYearRangeChanged: TAdvSmoothCalendarYearRangeChangedEvent;
    FShowFocus: Boolean;
    FFocusColor: TColor;
    FMultiSelect: Boolean;
    FOnSelectMultiDate: TAdvSmoothCalendarMultiDateSelectedEvent;
    FShowCurrentDate: Boolean;
    FKeyBoardDateModeToggle: Boolean;
    FOnCurrentDayClick: TAdvSmoothCalendarCurrentDayClickEvent;
    FMaxDate: TDate;
    FMinDate: TDate;
    FOnDateFill: TAdvSmoothCalendarDateFillEvent;
    FOnDateHint: TAdvSmoothCalendarDateHintEvent;
    FStatusAppearance: TGDIPStatus;
    FOnDateStatus: TAdvSmoothCalendarGetDateStatusEvent;
    FOnDateText: TAdvSmoothCalendarDateTextEvent;
    FOnBeforeSelectDate: TAdvSmoothCalendarBeforeDateSelectedEvent;
    FOnChange: TNotifyEvent;
    FDisjunctDaySelect: Boolean;
    FOnSelectDisjunctDate: TAdvSmoothCalendarDisjunctDateSelectedEvent;
    FOnDateStatusClick: TAdvSmoothCalendarStatusClickEvent;
    procedure CMMouseLeave(var Message: TMessage); message CM_MOUSELEAVE;
    procedure CMHintShow(var Message: TMessage); message CM_HINTSHOW;
    function GetVersion: String;
    procedure SetVersion(const Value: String);
    procedure SetFill(const Value: TGDIPFill);
    procedure SetTransparent(const Value: Boolean);
    procedure SetHeader(const Value: TAdvSmoothCalendarHeader);
    procedure SetMonth(const Value: integer);
    procedure SetYear(const Value: integer);
    procedure SetDateAppearance(const Value: TAdvSmoothCalendarDateAppearance);
    procedure SetFooter(const Value: TAdvSmoothCalendarFooter);
    procedure SetAnimation(const Value: Boolean);
    procedure SetShowFocus(const Value: Boolean);
    procedure SetFocusColor(const Value: TColor);
    procedure SetMultiSelect(const Value: Boolean);
    procedure SetEndDate(const Value: TDateTime);
    procedure SetSelectedDate(const Value: TDateTime);
    procedure SetStartDate(const Value: TDateTime);
    procedure SetHoveredDate(const Value: TDateTime);
    procedure SetShowCurrentDate(const Value: Boolean);
    procedure SetKeyBoardDateModeToggle(const Value: Boolean);
    function DoStoreMaxDate: Boolean;
    function DoStoreMinDate: Boolean;
    procedure SetMaxDate(const Value: TDate);
    procedure SetMinDate(const Value: TDate);
    procedure SetStatusAppearance(const Value: TGDIPStatus);
    function GetMonth: integer;
    function GetYear: integer;
    procedure SetDisjunctDaySelect(const Value: Boolean);
  protected
    procedure Changed;
    procedure UpDownChange(Sender: TObject; var AllowChange: Boolean;
      NewValue: SmallInt; Direction: TUpDownDirection);
    procedure DoGetDayStatus(Sender: TObject; Date: TDateTime; var StatusMessage: String;
      Fill: TGDIPStatus; var OffsetX: integer; var OffsetY: integer);
    procedure DoChangeMode(Sender: TObject; Mode, ModeTo: TAdvSmoothCalendarDateMode; var allow: Boolean);
    procedure DoSelectDate(Sender: TObject; Mode: TAdvSmoothCalendarDateMode; Date: TDateTime);
    procedure DoSelectMultiDate(Sender: TObject; Mode: TAdvSmoothCalendarDateMode; StartDate, EndDate: TDateTime);
    procedure DoSelectDisjunctDate(Sender: TObject; Mode: TAdvSmoothCalendarDateMode; DisjunctDates: TDisjunctDateTimeArray);
    procedure DoCurrentDateClick(Sender: TObject; var allow: Boolean);
    procedure DoChangeMonth(Sender: TObject; Month: integer);
    procedure DoChangeYear(Sender: TObject; Year: integer);
    procedure DoChangeYearRange(Sender: TObject; YearFrom, YearTo: integer);
    procedure FillChanged(Sender: TObject);
    procedure HeaderChanged(Sender: TObject);
    procedure FooterChanged(Sender: TObject);
    procedure DateAppearanceChanged(Sender: TObject);
    procedure StatusAppearanceChanged(Sender: TObject);
    procedure AnimateCal(Sender: TObject);
    procedure AnimateMode(var opcModeStart: Byte; opcModeStartTo: Byte);
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure CreateWnd; override;
    procedure CreateParams(var Params: TCreateParams); override;
    procedure DoEnter; override;
    procedure DoExit; override;
    procedure Resize; override;
    procedure WMEraseBkgnd(var Message: TWmEraseBkgnd); message WM_ERASEBKGND;
    procedure WMPaint(var Message: TWMPaint); message WM_PAINT;
    procedure KeyDown(var Key: Word; Shift: TShiftState); override;
    procedure WMGetDlgCode(var Message: TWMGetDlgCode); message WM_GETDLGCODE;
    procedure InitPreview;
    function InsideRect: TRect;
    function GetArrowRect(left: Boolean): TRect;
    function GetDateValuesRect: TGPRectF;
    function GetFooterCaptionRect: TRect;
    function GetWeekDaysRect: TGPRectF;
    function GetHeaderCaptionRect: TRect;
    function GetCountRows: integer;
    function GetVersionNr: integer;
    function GetCellWidth: Double;
    function GetCellHeight: Double;
    function GetShadowOffset: Integer;
    function IsWeekendDay(date: TDateTime): Boolean;
    function GetDate(day, dim: integer): TDateTime;
    function IsDisjunctDate(Date: TDateTime): Boolean;
    function RemoveDateIfSelect(Date: TDateTime): Boolean;
    function IndicatorAtXY(X, Y: Integer): TDateStatus;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure Assign(Source: TPersistent); override;
    procedure Paint; override;
    procedure DrawBackGround;
    procedure DrawHeader;
    procedure DrawFooter;
    procedure DrawDayOfWeek;
    procedure DrawWeekNumbers;
    procedure DrawArrow(left: Boolean);
    procedure DrawDays(Month, Year: integer; XPos: single);
    procedure DrawMonths(Year: integer; XPos: single);
    procedure DrawYears(YearFrom, YearTo: integer; XPos: Single);
    procedure PreviousDate;
    procedure NextDate;
    procedure ToggleMode;
    procedure ChangeMode(ADateMode: TAdvSmoothCalendarDateMode);
    procedure SelectDate(Shift: TShiftState; Date: TDateTime);
    function GetDayOfWeekColumn(date: TDateTime): integer;
    function GetCurrentDay(year, month: Word): integer;
    function XYToDate(X, Y: integer): TDateTime;
    function GetStartDate: TDateTime;
    function GetEndDate: TDateTime;
    property HoveredDate: TDateTime read FHoverDate write SetHoveredDate;
    property EndDate: TDateTime read GetEndDate write SetEndDate;
    property StartDate: TDateTime read GetStartDate write SetStartDate;
    property SelectedDate: TDateTime read FSelectedDate write SetSelectedDate;
    property KeyBoardDateModeToggle: Boolean read FKeyBoardDateModeToggle write SetKeyBoardDateModeToggle default true;
    procedure SetComponentStyle(AStyle: TTMSStyle);
    procedure SaveToTheme(FileName: String);
    procedure LoadFromTheme(FileName: String);
    function GetThemeId: String;
    function CurrentDay: Integer;
    function CurrentMonth: Integer;
    function CurrentYear: Integer;
    property DisjunctDates: TDisjunctDateTimeArray read FDisjunctDays;
    procedure SelectDisjunctDates(ADisjunctDates: array of TDateTime);
  published
    property Animation: Boolean read FAnimation write SetAnimation default true;
    property Year: integer read GetYear write SetYear;
    property Month: integer read GetMonth write SetMonth;
    property MaxDate: TDate read FMaxDate write SetMaxDate stored DoStoreMaxDate;
    property MinDate: TDate read FMinDate write SetMinDate stored DoStoreMinDate;
    property Fill: TGDIPFill read FFill write SetFill;
    property DateAppearance: TAdvSmoothCalendarDateAppearance read FDateAppearance write SetDateAppearance;
    property StatusAppearance: TGDIPStatus read FStatusAppearance write SetStatusAppearance;
    property Header: TAdvSmoothCalendarHeader read FHeader write SetHeader;
    property Footer: TAdvSmoothCalendarFooter read FFooter write SetFooter;
    property Transparent: Boolean read FTransparent write SetTransparent default false;
    property Version: String read GetVersion write SetVersion;
    property OnDateHint: TAdvSmoothCalendarDateHintEvent read FOnDateHint write FOnDateHint;
    property OnDateFill: TAdvSmoothCalendarDateFillEvent read FOnDateFill write FOnDateFill;
    property OnGetDateText: TAdvSmoothCalendarDateTextEvent read FOnDateText write FOnDateText;
    property OnBeforeSelectDate: TAdvSmoothCalendarBeforeDateSelectedEvent read FOnBeforeSelectDate write FOnBeforeSelectDate;
    property OnSelectDate: TAdvSmoothCalendarDateSelectedEvent read FOnSelectDate write FOnSelectDate;
    property OnSelectMultiDate: TAdvSmoothCalendarMultiDateSelectedEvent read FOnSelectMultiDate write FOnSelectMultiDate;
    property OnSelectDisjunctDate: TAdvSmoothCalendarDisjunctDateSelectedEvent read FOnSelectDisjunctDate write FOnSelectDisjunctDate;
    property OnDateModeChanged: TAdvSmoothCalendarDateModeChangedEvent read FOnDateModeChanged write FOnDateModeChanged;
    property OnMonthChanged: TAdvSmoothCalendarMonthChangedEvent read FOnMonthChanged write FOnMonthChanged;
    property OnYearChanged: TAdvSmoothCalendarYearChangedEvent read FOnYearChanged write FOnYearChanged;
    property OnYearRangeChanged: TAdvSmoothCalendarYearRangeChangedEvent read FOnYearRangeChanged write FOnYearRangeChanged;
    property OnCurrentDayClick: TAdvSmoothCalendarCurrentDayClickEvent read FOnCurrentDayClick write FOnCurrentDayClick;
    property OnDateStatus: TAdvSmoothCalendarGetDateStatusEvent read FOnDateStatus write FOnDateStatus;
    property OnDateStatusClick: TAdvSmoothCalendarStatusClickEvent read FOnDateStatusClick write FOnDateStatusClick;
    property ShowFocus: Boolean read FShowFocus write SetShowFocus default true;
    property ShowCurrentDate: Boolean read FShowCurrentDate write SetShowCurrentDate default true;
    property FocusColor: TColor read FFocusColor write SetFocusColor default clBlack;
    property MultiSelect: Boolean read FMultiSelect write SetMultiSelect default false;
    property DisjunctDaySelect: Boolean read FDisjunctDaySelect write SetDisjunctDaySelect default false;
    property TabOrder;
    property TabStop default true;
    property Visible;
    property ShowHint;
    property OnChange: TNotifyEvent read FOnChange write FOnChange;

    property Align;
    property Anchors;
    property Constraints;
    property DragMode;
    property DragCursor;
    property DragKind;

    {$IFDEF DELPHI2006_LVL}
    property OnCanResize;
    property OnConstrainedResize;
    property OnContextPopup;
    {$ENDIF}
    property OnDblClick;
    property OnDockDrop;
    property OnDockOver;
    property OnDragDrop;
    property OnDragOver;
    property OnEndDock;
    property OnEndDrag;
    property OnEnter;
    property OnExit;
    property OnGetSiteInfo;
    {$IFDEF DELPHI2006_LVL}
    property OnMouseActivate;
    property OnMouseEnter;
    property OnMouseLeave;
    {$ENDIF}
    property OnResize;
    property OnStartDock;
    property OnStartDrag;
    property OnUnDock;
    property PopupMenu;
     property OnMouseMove;
    property OnMouseUp;
    property OnMouseDown;
    property OnClick;
    property OnKeyDown;
    property OnKeyUp;
    property OnKeyPress;
    {$IFDEF DELPHI_TOUCH}
    property OnGesture;
    property Touch;
    {$ENDIF}
  end;

implementation

{$I DELPHIXE.INC}

{$IFNDEF DELPHI7_LVL}

const
   CS_DROPSHADOW = $00020000;

function DayOf(d: TDateTime): word;
var
  LYear, LMonth: Word;
begin
  DecodeDate(d, LYear, LMonth, Result);
end;

function MonthOf(d: TDateTime): word;
var
  LYear, LDay: Word;
begin
  DecodeDate(d, LYear, Result, LDay);
end;

function YearOf(d: TDateTime): word;
var
  LMonth, LDay: Word;
begin
   DecodeDate(d, Result, LMonth, LDay);
end;

function getWeekNumber(today: Tdatetime): integer; const
  Fiddle : array[1..7] of Byte = (6,7,8,9,10,4,5);
var
  present, startOfYear: Tdatetime;
  firstDayOfYear, weekNumber, numberOfDays: integer;
  year, month, day: word;
begin
  present:= trunc(today); //truncate to remove hours, mins and secs
  decodeDate(present, year, month, day); //decode to find year
  startOfYear:= encodeDate(year, 1, 1);  //encode 1st Jan of the year

  //find what day of week 1st Jan is, then add days according to rule
  firstDayOfYear:= Fiddle[dayOfWeek(startOfYear)];

  //calc number of days since beginning of year + additional according to rule
  numberOfDays:= trunc(present - startOfYear) + firstDayOfYear;

   //calc number of weeks
  weekNumber:= trunc(numberOfDays / 7);

  //create datecode string
  result := weekNumber;

  if weekNumber = 0 then //recursive call for year begin/end...
    //see if previous year end was week 52 or 53
    result := getWeekNumber(encodeDate(year - 1, 12, 31))
  else
    if weekNumber = 53 then
    //if 31st December less than Thursday then must be week 01 of next year
    if dayOfWeek(encodeDate(year, 12, 31)) < 5 then
    begin
      result:= 1;
    end;
end;

function WeekOf(d: TDateTime): word;
begin
  Result := getWeekNumber(d);
end;

function CompareDateTime(d1,d2: TDateTime): integer; begin  if Abs(d1 - d2) < (1 / (60 * 24 * 60 * 1000)) then
    Result := 0
  else if d1 < d2 then
    Result := -1
  else
    Result := +1;
end;

function CompareDate(d1,d2: TDateTime): integer; begin
  if Trunc(d1) = Trunc(d2) then
    Result := 0
  else if d1 < d2 then
    Result := -1
  else
    Result := 1;
end;

function DaysInAMonth(const AYear, AMonth: Word): Word;
begin
  Result := MonthDays[(AMonth = 2) and IsLeapYear(AYear), AMonth];
end;

function DaysInMonth(d: TDateTime): word; var
  LYear, LMonth, LDay: Word;
begin
  DecodeDate(d, LYear, LMonth, LDay);
  Result := DaysInAMonth(LYear, LMonth);
end;

function DaysPerWeek: word;
begin
  Result := 7;
end;
{$ENDIF}

procedure DeleteArrayItem(var X: TDisjunctDateTimeArray; const Index: Integer) ;
begin
   if Index > High(X) then
     Exit;
   if Index < Low(X) then
     Exit;
   if Index = High(X) then
   begin
     SetLength(X, Length(X) - 1) ;
     Exit;
   end;
   System.Move(X[Index +1], X[Index],(Length(X) - Index -1) * SizeOf(string) + 1) ;
   SetLength(X, Length(X) - 1) ;
end;

function AnimateDouble(var Start: Single; Stop, Delta, Margin: Single): Boolean;
begin
  Result := true;
  if (Start > Stop - Margin) and (Start < Stop + Margin) then
  begin
    Start := Stop;
    Result := false;
  end
  else
  begin
    Delta := Max(1, Delta);
    if Start < Stop then
      Start := Round(Start + Delta)
    else
      Start := Round(Start - Delta);
  end;
end;

procedure GetCaptionPosition(var x, y: integer; rectangle: TGPRectF; objectwidth, objectheight: integer; location: TAdvSmoothCalendarCaptionLocation);
var
  w, h, tw, th: integer;
begin
  tw := objectwidth;
  th := objectheight;
  w := Round(rectangle.Width);
  h := Round(rectangle.Height);
  case location of
    cpTopLeft:
    begin
      x := 0;
      y := 0;
    end;
    cpTopRight:
    begin
      x := w - tw;
      y := 0;
    end;
    cpBottomLeft:
    begin
      x := 0;
      y := h - th;
    end;
    cpBottomRight:
    begin
      x := w - tw;
      y := h - th;
    end;
    cpTopCenter:
    begin
      x := (w - tw) div 2;
      y := 0;
    end;
    cpBottomCenter:
    begin
      x := (w - tw) div 2;
      y := h - th;
    end;
    cpCenterCenter:
    begin
      x := (w - tw) div 2;
      y := (h - th) div 2;
    end;
    cpCenterLeft:
    begin
      x := 0;
      y := (h - th) div 2;
    end;
    cpCenterRight:
    begin
      x := w - tw;
      y := (h - th) div 2;
    end;
  end;
end;

{ TAdvSmoothCalendar }

procedure TAdvSmoothCalendar.AnimateCal(Sender: TObject);
var
  d, opc: Single;
begin
  if (Int(Now) <> FCurrentDate) then
  begin
    FCurrentDate := Int(Now);
    FCurrentDay := DayOf(Now);
    Invalidate;
  end;

  if FAnimateDateMode then
  begin
    case FDateMode of
      dmDay:
      begin
        case FTempDateMode of
          dmMonth, dmDay, dmYear: AnimateMode(FDayOpc, FDayOpcTo);
        end;
      end;
      dmMonth:
      begin
        case FTempDateMode of
          dmDay, dmYear, dmMonth: AnimateMode(FMonthOpc, FMonthOpcTo);
        end;
      end;
      dmYear:
      begin
        case FTempDateMode of
          dmDay, dmMonth, dmYear: AnimateMode(FYearOpc, FYearOpcTo);
        end;
      end;
    end;
  end;

  if FAnimate and Animation then
  begin
    d := Abs(FCurrentPos - FPosTo) / 4;

    FAnimating := AnimateDouble(FCurrentPos, Fposto, d, 0.1);
    if FAnimating then
    begin
      FHoverDate := -1;
      Changed;
    end
    else
    begin
      FCurrentPos := 0;
      FPosTo := 0;
      FNextYear := FCurrentYear;
      FNextMonth := FCurrentMonth;
      FNextYearTo := FCurrentYearTo;
      FNextYearFrom := FCurrentYearFrom;

      opc := FWeekNumberOpc;
      d := Abs(opc - FWeekNumberOpcTo) / 4;
      FAnimateOpacity := AnimateDouble(opc, FWeekNumberOpcTo, d, 1);
      if FAnimateOpacity then
      begin
        FWeekNumberOpc := Round(opc);
        Changed;
      end
      else
      begin
        FAnimate := false;
        Invalidate;
      end;
    end;
  end;
end;

procedure TAdvSmoothCalendar.AnimateMode(var opcModeStart: Byte; opcModeStartTo: Byte);
var
  d, opc: Single;
begin
  opc := opcModeStart;
  d := Abs(opc - opcModeStartTo) / 4;
  FAnimateDayOpc := AnimateDouble(opc, opcModeStartTo, d, 0.1);
  if FAnimateDayOpc then
  begin
    opcModeStart := Round(opc);
    Changed;
  end
  else
    FDateMode := FTempDateMode;
end;

procedure TAdvSmoothCalendar.Assign(Source: TPersistent);
begin
  if Source is TAdvSmoothCalendar then
  begin
    FFill.Assign((Source as TAdvSmoothCalendar).Fill);
    FTransparent := (Source as TAdvSmoothCalendar).Transparent;
    FYear := (Source as TAdvSmoothCalendar).Year;
    FMonth := (Source as TAdvSmoothCalendar).Month;
    FHeader.Assign((Source as TAdvSmoothCalendar).Header);
    FDateAppearance.Assign((Source as TAdvSmoothCalendar).DateAppearance);
    FFooter.Assign((Source as TAdvSmoothCalendar).Footer);
    FShowFocus := (Source as TAdvSmoothCalendar).ShowFocus;
    FFocusColor := (Source as TAdvSmoothCalendar).FocusColor;
    FMultiSelect := (Source as TAdvSmoothCalendar).MultiSelect;
    FDisjunctDaySelect := (Source as TAdvSmoothCalendar).DisjunctDaySelect;
    Changed;
  end;
end;

procedure TAdvSmoothCalendar.Changed;
begin
  Invalidate;
  if Assigned(OnChange) then
    OnChange(Self);
end;

procedure TAdvSmoothCalendar.ChangeMode(ADateMode: TAdvSmoothCalendarDateMode);
var
  t: TAdvSmoothCalendarDateMode;
  allow: Boolean;
begin
  if FTempDateMode <> FDateMode then
    Exit;

  t := ADateMode;

  allow := true;
  DoChangeMode(Self, FDateMode, t, allow);

  if not allow then
    exit;

  FTempDateMode := t;

  if FTempDateMode = dmDay then
  begin
    FDayOpcTo := 255;
    FMonthOpcTo := 0;
    FYearOpcTo := 0;
    FWeekNumberOpcTo := 255;
  end
  else if FTempDateMode = dmMonth then
  begin
    FDayOpcTo := 0;
    FYearOpcTo := 0;
    FMonthOpcTo := 255;
    FWeekNumberOpcTo := 0;
  end
  else if FTempDateMode = dmYear then
  begin
    FMonthOpcTo := 0;
    FDayOpcTo := 0;
    FYearOpcTo := 255;
    FWeekNumberOpcTo := 0;
  end;

  if not Animation then
  begin
    FWeekNumberOpc := FWeekNumberOpcTo;
    FDayOpc := FDayOpcTo;
    FMonthOpc := FMonthOpcTo;
    FYearOpc := FYearOpcTo;
    FDateMode := FTempDateMode;
    Changed;
  end
  else
  begin
    FAnimateDateMode := true;
    FAnimate := true;
  end;
end;

procedure TAdvSmoothCalendar.CMHintShow(var Message: TMessage);
var
  hint: String;
begin
  with TCMHintShow(Message).HintInfo^ do
  begin
    hint := FormatDateTime('dd/mm/yyyy', FHoverDate);
    if Assigned(OnDateHint) then
      OnDateHint(Self, FHoverDate, hint);
    HintStr := hint;
    ReshowTimeout := 0;
  end;
end;

procedure TAdvSmoothCalendar.CMMouseLeave(var Message: TMessage);
begin
  inherited;
  FHoverDate := -1;
  Changed;
end;

constructor TAdvSmoothCalendar.Create(AOwner: TComponent);
begin
  inherited;
  FDesignTime := (csDesigning in ComponentState) and not
    ((csReading in Owner.ComponentState) or (csLoading in Owner.ComponentState));

  FKeyBoardDateModeToggle := true;
  FMultiSelect := false;
  FAnimation := true;
  FShowFocus := true;

  FAnimateTimer := TTimer.Create(self);
  FAnimateTimer.Interval := 10;
  FAnimateTimer.Enabled := not (csDesigning in ComponentState);
  FAnimateTimer.OnTimer := AnimateCal;

  FFill := TGDIPFill.Create;
  DoubleBuffered := true;
  FFill.OnChange := FillChanged;
  FDateAppearance := TAdvSmoothCalendarDateAppearance.Create(self);
  FDateAppearance.OnChange := DateAppearanceChanged;
  FStatusAppearance := TGDIPStatus.Create;
  FStatusAppearance.OnChange := StatusAppearanceChanged;
  if FDesigntime then
  begin
    FStatusAppearance.Fill.Color := clRed;
    FStatusAppearance.Fill.GradientType := gtSolid;
    FStatusAppearance.Fill.BorderColor := clGray;
    FStatusAppearance.Font.Color := clWhite;
  end;
  FHeader := TAdvSmoothCalendarHeader.Create(self);
  FHeader.OnChange := HeaderChanged;
  FFooter := TAdvSmoothCalendarFooter.Create(self);
  FFooter.OnChange := FooterChanged;
  Width := 257;
  Height := 249;
  FTransparent := false;

  FYear := YearOf(Now);
  FMonth := MonthOf(Now);
  FShowCurrentDate := true;
  FCurrentYear := FYear;
  FCurrentYearFrom := FYear;
  FCurrentYearTo := FYear + 11;
  FCurrentMonth := FMonth;
  FNextYear := FYear;
  FNextYearFrom := FYear;
  FNextYearTo := FYear + 11;
  FNextMonth := FMonth;

  FCurrentDate := Int(Now);
  FCurrentDay := DayOf(Now);

  FFocusDate := FCurrentDate;
  FWeekNumberOpc := 255;
  FDayOpc := 255;
  FMonthOpc := 0;

  FUpDown := TUpDown.Create(Self);
  FUpDown.OnChangingEx := UpDownChange;
  FUpDown.Visible := False;
  FUpDown.Width := FUpDown.Width - 2;
  FUpDown.Height := FUpDown.Height - 4;
  FUpDown.Min := Year - 10;
  FUpDown.Max := Year + 10;
  FUpDown.Position := Year;

  FDisjunctDaySelect := False;

  TabStop := true;

  if FDesignTime then
    SetComponentStyle(tsOffice2007Luna);
end;

procedure TAdvSmoothCalendar.CreateParams(var Params: TCreateParams);
begin
  { call the create of the params }
  inherited CreateParams(Params);
  ControlStyle := ControlStyle - [csOpaque] + [csAcceptsControls];

  if (Win32Platform = VER_PLATFORM_WIN32_NT) and
     ((Win32MajorVersion > 5) or
      ((Win32MajorVersion = 5) and (Win32MinorVersion >= 1))) then
        if Params.WindowClass.Style and CS_DROPSHADOW <> 0 then
          Params.WindowClass.Style := Params.WindowClass.Style - CS_DROPSHADOW;
end;

procedure TAdvSmoothCalendar.CreateWnd;
begin
  inherited;
  if FDesignTime then
    InitPreview;
end;

function TAdvSmoothCalendar.CurrentDay: Integer;
begin
  Result := FCurrentDay;
end;

function TAdvSmoothCalendar.CurrentMonth: Integer;
begin
  Result := FCurrentMonth;
end;

function TAdvSmoothCalendar.CurrentYear: Integer;
begin
  Result := FCurrentYear;
end;

procedure TAdvSmoothCalendar.DateAppearanceChanged(Sender: TObject);
begin
  Changed;
end;

destructor TAdvSmoothCalendar.Destroy;
begin
  FUpDown.Free;
  FFill.Destroy;
  FDateAppearance.Free;
  FHeader.Free;
  FFooter.Free;
  FAnimateTimer.Free;
  FStatusAppearance.Free;
  inherited;
end;

procedure TAdvSmoothCalendar.DoChangeMode(Sender: TObject;
  Mode, ModeTo: TAdvSmoothCalendarDateMode; var allow: Boolean);
begin
  if Assigned(FOnDateModeChanged) then
    FOnDateModeChanged(Sender, Mode, ModeTo, allow);
end;

procedure TAdvSmoothCalendar.DoChangeMonth(Sender: TObject; Month: integer);
begin
  if Assigned(FOnMonthChanged) then
    FOnMonthChanged(Sender, Month);
end;

procedure TAdvSmoothCalendar.DoChangeYear(Sender: TObject; Year: integer);
begin
  if Assigned(FOnYearChanged) then
    FOnYearChanged(Sender, Year);
end;

procedure TAdvSmoothCalendar.DoChangeYearRange(Sender: TObject; YearFrom,
  YearTo: integer);
begin
  if Assigned(FOnYearRangeChanged) then
    FOnYearRangeChanged(Sender, YearFrom, YearTo);
end;

procedure TAdvSmoothCalendar.DoCurrentDateClick(Sender: TObject;
  var allow: Boolean);
begin
  if Assigned(FOnCurrentDayClick) then
    FOnCurrentDayClick(Sender, Allow);
end;

procedure TAdvSmoothCalendar.DoEnter;
begin
  inherited;
  FFocused := true;
  Changed;
end;

procedure TAdvSmoothCalendar.DoExit;
begin
  inherited;
  FFocused := false;
  Changed;
end;

procedure TAdvSmoothCalendar.DoGetDayStatus(Sender: TObject; Date: TDateTime;
  var StatusMessage: String; Fill: TGDIPStatus; var OffsetX: integer; var OffsetY: integer);
begin
  if Assigned(FOnDateStatus) then
    FOnDateStatus(Sender, Date, StatusMessage, Fill, OffsetX, OffsetY);
end;

procedure TAdvSmoothCalendar.DoSelectDate(Sender: TObject;
  Mode: TAdvSmoothCalendarDateMode; Date: TDateTime);
begin
  if Assigned(FUpDown) then
  begin
    FUpDown.Min := Year - 10;
    FUpDown.Max := Year + 10;
    FLoading := True;
    FUpDown.Position := YearOf(Date);
    FLoading := False;
  end;
  if Assigned(FOnSelectDate) then
    FOnSelectDate(Sender, Mode, Date);
end;

procedure TAdvSmoothCalendar.DoSelectDisjunctDate(Sender: TObject;
  Mode: TAdvSmoothCalendarDateMode; DisjunctDates: TDisjunctDateTimeArray);
begin
  if Assigned(FOnSelectDisjunctDate) then
    FOnSelectDisjunctDate(Sender, Mode, DisjunctDates);
end;

procedure TAdvSmoothCalendar.DoSelectMultiDate(Sender: TObject;
  Mode: TAdvSmoothCalendarDateMode; StartDate, EndDate: TDateTime);
begin
  if Assigned(FOnSelectMultiDate) then
    FOnSelectMultiDate(Sender, Mode, StartDate, EndDate);
end;

function TAdvSmoothCalendar.DoStoreMaxDate: Boolean;
begin
  Result := FMaxDate <> 0.0;
end;

function TAdvSmoothCalendar.DoStoreMinDate: Boolean;
begin
  Result := FMinDate <> 0.0;
end;

procedure TAdvSmoothCalendar.DrawArrow(left: Boolean);
var
  g: TGPGraphics;
  path: TGPGraphicsPath;
  b: TGPSolidBrush;
  pts: array[0..3] of TGPPointF;
  r: TRect;
begin
  if Header.ArrowsVisible then
  begin
    g := TGPGraphics.Create(Canvas.Handle);
    g.SetSmoothingMode(SmoothingModeAntiAlias);

    path := TGPGraphicsPath.Create;

    r := GetArrowRect(left);
    if left then
    begin
      pts[0].X := r.Left;
      pts[0].Y := r.Top + (r.Bottom - r.Top) / 2;

      pts[1].X := r.Right;
      pts[1].Y := r.Top;

      pts[2].X := r.Right;
      pts[2].Y := r.Bottom;
    end
    else
    begin
      pts[0].X := r.Right;
      pts[0].Y := r.Top + (r.Bottom - r.Top) / 2;

      pts[1].X := r.Left;
      pts[1].Y := r.Top;

      pts[2].X := r.Left;
      pts[2].Y := r.Bottom;
    end;

    path.AddPolygon(PGPPointF(@pts), 3);

    b := TGPSolidBrush.Create(MakeColor(255, Header.ArrowColor));
    g.FillPath(b, path);

    b.Free;
    path.Free;
    g.Free;
  end;
end;

procedure TAdvSmoothCalendar.DrawBackGround;
var
  g: TGPGraphics;
  r: TGPRectf;
begin
  if not Transparent then
  begin
    g := TGPGraphics.Create(Canvas.Handle);
    if (Fill.BorderColor = clNone) or (Fill.BorderWidth = 0) then
      r := MakeRect(-1, -1, Width + 1, Height + 1)
    else
      r := MakeRect(0, 0, Width - 1, Height - 1);

    Fill.Fill(g, r);
    g.Free;
  end;
end;

procedure TAdvSmoothCalendar.DrawDays(Month, Year: integer; XPos: single);
var
  g: TGPGraphics;
  ff: TGPFontFamily;
  fs: integer;
  f: TGPFont;
  sf: TGPStringFormat;
  I: Integer;
  layr, sizer: TGPRectF;
  day: String;
  wdtotalfirst, wdtotallast: integer;
  wd: single;
  b: TGPSolidBrush;
  dim: integer;
  cmy, date: TDateTime;
  cf: TFont;
  fillr: TGPRectF;
  drawselected: Boolean;
  drawcurrent: Boolean;
  wnoff,h: integer;
  opc: Byte;
  cw, ch: Double;
  rows: integer;
  wdr: Trect;
  multir: TRect;
  focusdate: Boolean;
  ed, sd: TDateTime;
  bw, xoff, yoff: Double;
  mind, maxd: TDateTime;
  str: String;
  status: TGDIPStatus;
  x, y: Double;
  OffSetX, OffsetY, start, stop: integer;
  fl: TGDIPFill;
  Allow: Boolean;
begin
  fl := TGDIPFill.Create;

  with DateAppearance do
  begin
    cf := TFont.Create;
    g := TGPGraphics.Create(Canvas.Handle);

    //RECTANGLE
    layr := GetDateValuesRect;

    cw := GetCellWidth;
    ch := GetCellHeight;
    cmy := EncodeDate(FCurrentYear, FCurrentMonth, 1);
    dim := DaysInMonth(cmy);

    rows := 1;
    yoff := Layr.Y;
    xoff := layr.X;
    wdtotalfirst := GetDayOfWeekColumn(EncodeDate(FcurrentYear, FCurrentMonth, 1));
    wdtotallast := GetDayOfWeekColumn(EncodeDate(FcurrentYear, FCurrentMonth, dim));
    if DateAppearance.ShowDaysBefore then
      start := 2-wdtotalfirst
    else
      start := 1;

    if DateAppearance.ShowDaysAfter then
      stop := dim + 7 - wdtotallast
    else
      stop := dim;

    for I := start to stop do
    begin
      date := GetDate(i, dim);
      wd := GetDayOfWeekColumn(date);

      fillr.X := xpos + xoff + (wd * cw) - cw;
      fillr.Y := yoff + ((rows - 1) * ch);
      fillr.Height := ch;
      fillr.Width := cw;
      drawselected := false;

      drawcurrent := (CompareDateTime(FCurrentDate, date) = 0) and FShowCurrentDate;

      if (FSelectedDateRange = drSingledate) then
      begin
        if Length(FDisjunctDays) > 0 then
          drawselected := IsDisjunctDate(Date)
        else
          drawselected := CompareDate(FSelectedDate, date) = 0;

        if (I >= 1) and (I <= dim) then
          cf.Assign(FDateFont)
        else if (I < 1) then
          cf.Assign(FDateBeforeFont)
        else if (I > dim) then
          cf.Assign(FDateAfterFont)
      end
      else
      begin
        if (date >= Int(StartDate)) and (date <= Int(EndDate)) then
          cf.Assign(FSelectedDateFont)
        else
        begin
          if (I >= 1) and (I <= dim) then
            cf.Assign(FDateFont)
          else if (I < 1) then
            cf.Assign(FDateBeforeFont)
          else if (I > dim) then
            cf.Assign(FDateAfterFont)
        end
      end;

      focusdate := (CompareDateTime(FFocusDate, date) = 0) and ShowFocus and FFocused and TabStop;

      mind := MinDate;
      maxd := MaxDate;

      if MinDate = 0 then
        mind := date;

      if MaxDate = 0 then
        maxd := date;

      if not ((FSelectedDateRange = drMultiDates) and (date >= StartDate) and (date <= EndDate)) then
      begin
        if (date >= mind) and (date <= maxd) then
        begin
          if drawselected then
          begin
            cf.Assign(FSelectedDateFont);
            fl.Assign(SelectedDateFill);
            fl.Focus := focusdate;
            fl.FocusColor := FocusColor;
            if Assigned(FOnDateFill) then
              FOnDateFill(Self, fl, cf, date, dkSelected);

            if fl.BorderColor <> clNone then
            begin
              bw := (fl.BorderWidth / 2);
              fillr.X := fillr.X + bw;
              fillr.Y := fillr.Y + bw;
              fillr.Height := fillr.Height - (bw * 2);
              fillr.Width := fillr.Width - (bw * 2);
            end;
          end
          else if drawcurrent and not ((date >= StartDate) and (date <= EndDate)) then
          begin
            cf.Assign(FCurrentDateFont);
            fl.Assign(CurrentDateFill);
            fl.Focus := focusdate;
            fl.FocusColor := FocusColor;
            if Assigned(FOnDateFill) then
              FOnDateFill(Self, fl, cf, date, dkCurrent);
            if fl.BorderColor <> clNone then
            begin
              bw := (fl.BorderWidth / 2);
              fillr.X := fillr.X + bw;
              fillr.Y := fillr.Y + bw;
              fillr.Height := fillr.Height - (bw * 2);
              fillr.Width := fillr.Width - (bw * 2);
            end;
          end
          else if not drawcurrent and (CompareDateTime(FHoverDate, date) = 0)
            and not ((date >= StartDate) and (date <= EndDate)) then
          begin
            cf.Assign(FHoverDateFont);
            fl.Assign(HoverDateFill);
            fl.Focus := focusdate;
            fl.FocusColor := FocusColor;
            if Assigned(FOnDateFill) then
              FOnDateFill(Self, fl, cf, date, dkHovered);
            if fl.BorderColor <> clNone then
            begin
              bw := (fl.BorderWidth / 2);
              fillr.X := fillr.X + bw;
              fillr.Y := fillr.Y + bw;
              fillr.Height := fillr.Height - (bw * 2);
              fillr.Width := fillr.Width - (bw * 2);
            end;
          end
          else if not drawcurrent
            and not ((date >= StartDate) and (date <= EndDate)) then
          begin
            if IsWeekendDay(date) and (I >= 1) and (I <= dim) then
            begin
              cf.Assign(WeekendFont);
              fl.Assign(WeekendFill);
              fl.Focus := focusdate;
              fl.FocusColor := FocusColor;
              if Assigned(FOnDateFill) then
                FOnDateFill(Self, fl, cf, date, dkWeekend);
            end
            else if (I >= 1) and (I <= dim) then
            begin
              cf.Assign(FDateFont);
              fl.Assign(DateFill);
              fl.Focus := focusdate;
              fl.FocusColor := FocusColor;
              if Assigned(FOnDateFill) then
                FOnDateFill(Self, fl, cf, date, dkNormal);
            end
            else if (I < 1) then
            begin
              cf.Assign(FDateBeforeFont);
              fl.Assign(DateBeforeFill);
              fl.Focus := focusdate;
              fl.FocusColor := FocusColor;
              if Assigned(FOnDateFill) then
                FOnDateFill(Self, fl, cf, date, dkNormal);
            end
            else if (I > dim) then
            begin
              cf.Assign(FDateAfterFont);
              fl.Assign(DateAfterFill);
              fl.Focus := focusdate;
              fl.FocusColor := FocusColor;
              if Assigned(FOnDateFill) then
                FOnDateFill(Self, fl, cf, date, dkNormal);
            end;

            if fl.BorderColor <> clNone then
            begin
              bw := (fl.BorderWidth / 2);
              fillr.X := fillr.X + bw;
              fillr.Y := fillr.Y + bw;
              fillr.Height := fillr.Height - (bw * 2);
              fillr.Width := fillr.Width - (bw * 2);
            end;
          end;
        end
        else
        begin
          cf.Assign(FDisabledDateFont);
          fl.Assign(DisabledDateFill);
          fl.Focus := focusdate;
          fl.FocusColor := FocusColor;
          if Assigned(FOnDateFill) then
            FOnDateFill(Self, fl, cf, date, dkDisabled);
        end;


        fl.Fill(g, fillr, Min(fl.Opacity, FDayOpc),
                              Min(fl.Opacity, FDayOpc),
                              Min(fl.OpacityTo, FDayOpc),
                              Min(fl.OpacityMirror, FDayOpc),
                              Min(fl.OpacityMirrorTo, FDayOpc));
      end;

      day := inttostr(DayOf(date));

      if Assigned(OnGetDateText) then
        OnGetDateText(Self, date, cf, day);

      ff := TGPFontFamily.Create(cf.Name);
      if (ff.Status in [FontFamilyNotFound, FontStyleNotFound]) then
      begin
        ff.Free;
        ff := TGPFontFamily.Create('Arial');
      end;

      fs := 0;
      if (fsBold in cf.Style) then
        fs := fs + 1;
      if (fsItalic in cf.Style) then
        fs := fs + 2;
      if (fsUnderline in cf.Style) then
        fs := fs + 4;

      sf := TGPStringFormat.Create;
      sf.SetAlignment(StringAlignmentCenter);
      sf.SetLineAlignment(StringAlignmentCenter);
      sf.SetTrimming(StringTrimmingEllipsisWord);
      f := TGPFont.Create(ff, cf.Size, fs, UnitPoint);
      g.SetTextRenderingHint(TextRenderingHintClearTypeGridFit);
      b := TGPSolidBrush.Create(MakeColor(Round(FDayOpc), cf.Color));

      g.MeasureString(day, length(day), f, layr, sf, sizer);
      g.DrawString(day, Length(day), f, fillr, sf, b);

      if (wd = 7) and (I >= 1) and (I <= dim) then
      begin
        Inc(rows);
      end;

      b.Free;
      f.Free;
      sf.Free;
      ff.Free;
    end;

    SetLength(arrMulti, 0);

    status := TGDIPStatus.Create;
    rows := 1;
    g.SetSmoothingMode(SmoothingModeAntiAlias);
    g.SetTextRenderingHint(TextRenderingHintAntiAlias);
    for I := start to stop do
    begin
      status.Assign(StatusAppearance);
      date := GetDate(i, dim);
      wd := GetDayOfWeekColumn(date);
      str := '';
      x := xpos + xoff + (wd * cw);
      y := yoff + ((rows - 1) * ch);
      OffSetX := 0;
      OffsetY := 0;
      DoGetDayStatus(Self, date, str, status, Offsetx, Offsety);
      if str <> '' then
      begin
        status.CalculateSize(g, str);
        x := x - (status.GetWidth / 3 * 2) + OffsetX;
        y := y - (status.GetHeight / 2) + OffsetY;
        status.Draw(g, Round(x), Round(y), 0, 0, True, str);
      end;

      if wd = 7 then
      begin
        Inc(rows);
      end;
    end;
    status.Free;
    //
    cf.free;
    g.Free;
  end;

  fl.Free;
end;

procedure TAdvSmoothCalendar.DrawDayOfWeek;
var
  g: TGPGraphics;
  ff: TGPFontFamily;
  f: TGPFont;
  sf: TGPStringFormat;
  fs: integer;
  layr, sizer, fillr: TGPRectF;
  dpw: Integer;
  b: TGPSolidBrush;
  i: integer;
  weekday: string;
  dow: integer;
  wwd: Double;
begin
  with DateAppearance do
  begin
    g := TGPGraphics.Create(Canvas.Handle);

    layr := GetDateValuesRect;
    layr.Y := Header.GetHeight;
    wwd := GetCellWidth;
    dpw := DaysPerWeek;

    ////DAY OF WEEK////////////
    ff := TGPFontFamily.Create(FDayOfWeekFont.Name);

    fs := 0;
    if (fsBold in FDayOfWeekFont.Style) then
      fs := fs + 1;
    if (fsItalic in FDayOfWeekFont.Style) then
      fs := fs + 2;
    if (fsUnderline in FDayOfWeekFont.Style) then
      fs := fs + 4;

    sf := TGPStringFormat.Create;
    f := TGPFont.Create(ff, FDayOfWeekFont.Size, fs, UnitPoint);
    g.SetTextRenderingHint(TextRenderingHintClearTypeGridFit);
    b := TGPSolidBrush.Create(MakeColor(255, FDayOfWeekFont.Color));

    for I := 1 to dpw do
    begin
      dow := GetDayOfWeekColumn(EncodeDate(FCurrentYear, FCurrentMonth, i));
      {$IFDEF DELPHIXE_LVL}
      weekday := FormatSettings.ShortDayNames[DayOfWeek(EncodeDate(FCurrentYear, FCurrentMonth, i))];
      {$ENDIF}
      {$IFNDEF DELPHIXE_LVL}
      weekday := ShortDayNames[DayOfWeek(EncodeDate(FCurrentYear, FCurrentMonth, i))];
      {$ENDIF}
      g.MeasureString(weekday, length(weekday), f, layr, sf, sizer);
      fillr := MakeRect(((dow - 1) * wwd) + layr.X, layr.Y, wwd, sizer.Height);
      DayOfWeekFill.Fill(g, fillr);
      g.DrawString(weekday, Length(weekday), f, MakeRect(fillr.X + (wwd - sizer.Width) / 2, layr.Y, wwd, sizer.Height), sf, b);
    end;

    b.Free;
    sf.Free;
    ff.Free;
    f.Free;
    g.Free;
  end;
end;

procedure TAdvSmoothCalendar.DrawFooter;
var
  r: TRect;
  th, tw, x, y: integer;
  g: TGPGraphics;
  f: TGPFont;
  ff: TGPFontFamily;
  sf: TGPStringFormat;
  b: TGPSolidBrush;
  fs: integer;
  pt: TGPPointF;
  fillr, sizer: TGPRectF;
  h: String;
begin
  with Footer do
  begin
    if Visible then
    begin
      if CurrentDateCaption then
      begin
        if CurrentDateFormat = '' then
          h := Caption + ' ' + DateToStr(FCurrentDate)
        else
          h := Caption + ' ' + FormatDateTime(CurrentDateFormat, FCurrentDate)
      end
      else
        h := Caption;

      g := TGPGraphics.Create(Canvas.Handle);

      if (Fill.BorderColor = clNone) or (Fill.BorderWidth = 0) then
        r := Rect(InsideRect.Left, InsideRect.Bottom - Height - FOwner.GetShadowOffset, InsideRect.Right - FOwner.GetShadowOffset, InsideRect.Bottom - FOwner.GetShadowOffset)
      else
        r := Rect(InsideRect.Left, InsideRect.Bottom - Height - FOwner.GetShadowOffset, InsideRect.Right - FOwner.GetShadowOffset - 1, InsideRect.Bottom - FOwner.GetShadowOffset - 1);

      fillr := fill.Fill(g, MakeRect(R.Left, r.Top, r.Right - r.Left, r.Bottom - r.Top));

      if h <> '' then
      begin

        ff := TGPFontFamily.Create(FFont.Name);
        if (ff.Status in [FontFamilyNotFound, FontStyleNotFound]) then
        begin
          ff.Free;
          ff := TGPFontFamily.Create('Arial');
        end;

        fs := 0;
        if (fsBold in FFont.Style) then
          fs := fs + 1;
        if (fsItalic in FFont.Style) then
          fs := fs + 2;
        if (fsUnderline in FFont.Style) then
          fs := fs + 4;

        sf := TGPStringFormat.Create;
        f := TGPFont.Create(ff, FFont.Size, fs, UnitPoint);
        g.SetTextRenderingHint(TextRenderingHintClearTypeGridFit);

        g.MeasureString(h, Length(h), f, fillr, sf, sizer);

        th := Round(sizer.Height);
        tw := Round(sizer.Width);

        if FCaptionPosition <> cpCustom then
          GetCaptionPosition(x, y, fillr, tw, th, FCaptionPosition)
        else
        begin
          x := FCaptionLeft;
          y := FCaptionTop;
        end;

        pt := MakePoint(fillr.X + x, fillr.Y + y);

        b := TGPSolidBrush.Create(ColorToARGB(FFont.Color));
        g.DrawString(h, length(h), f, pt, sf, b);
        b.Free;

        ff.Free;
        sf.Free;
        f.free;

      end;
      g.Free;
    end;
  end;
end;

procedure TAdvSmoothCalendar.DrawHeader;
var
  r: TRect;
  th, tw, x, y: integer;
  g: TGPGraphics;
  f: TGPFont;
  ff: TGPFontFamily;
  sf: TGPStringFormat;
  b: TGPSolidBrush;
  fs: integer;
  pt: TGPPointF;
  fillr, sizer: TGPRectF;
  h: String;
  bw: integer;
begin
  with Header do
  begin
    if Visible then
    begin
      case FDateMode of
        dmDay: h := FormatDateTime('mmmm yyyy', EncodeDate(FCurrentYear, FCurrentMonth, 1));
        dmMonth: h := FormatDateTime('yyyy', EncodeDate(FCurrentYear, FCurrentMonth, 1));
        dmYear: h := IntToStr(FCurrentYearFrom) + ' - ' + IntToStr(FCurrentYearTo);
      end;

      g := TGPGraphics.Create(Canvas.Handle);

      bw := 0;
      if Header.Fill.BorderColor <> clNone then
        bw := Min(1, Header.Fill.BorderWidth);

      r := Rect(InsideRect.Left, InsideRect.Top , InsideRect.Right - FOwner.GetShadowOffset - bw, InsideRect.Top + Height - bw);

      fillr := fill.Fill(g, MakeRect(R.Left, r.Top, r.Right - r.Left, r.Bottom - r.Top));

      if h <> '' then
      begin

        ff := TGPFontFamily.Create(FFont.Name);
        if (ff.Status in [FontFamilyNotFound, FontStyleNotFound]) then
        begin
          ff.Free;
          ff := TGPFontFamily.Create('Arial');
        end;

        fs := 0;
        if (fsBold in FFont.Style) then
          fs := fs + 1;
        if (fsItalic in FFont.Style) then
          fs := fs + 2;
        if (fsUnderline in FFont.Style) then
          fs := fs + 4;

        sf := TGPStringFormat.Create;
        f := TGPFont.Create(ff, FFont.Size, fs, UnitPoint);
        g.SetTextRenderingHint(TextRenderingHintClearTypeGridFit);

        g.MeasureString(h, Length(h), f, fillr, sf, sizer);

        th := Round(sizer.Height);
        tw := Round(sizer.Width);

        if FCaptionPosition <> cpCustom then
          GetCaptionPosition(x, y, fillr, tw, th, FCaptionPosition)
        else
        begin
          x := FCaptionLeft;
          y := FCaptionTop;
        end;

        pt := MakePoint(fillr.X + x, fillr.Y + y);
        b := TGPSolidBrush.Create(ColorToARGB(Font.Color));
        g.DrawString(h, length(h), f, pt, sf, b);
        b.Free;

        ff.Free;
        sf.Free;
        f.free;

      end;

      //Arrows
      if ArrowsVisible then
      begin
        DrawArrow(true);
        DrawArrow(false);
      end;
      ///

      g.Free;
    end;
  end;
end;

procedure TAdvSmoothCalendar.DrawMonths(Year: integer; XPos: single);
var
  g: TGPGraphics;
  ff: TGPFontFamily;
  fs: integer;
  f: TGPFont;
  sf: TGPStringFormat;
  I: Integer;
  layr, sizer: TGPRectF;
  month: String;
  wd: integer;
  b: TGPSolidBrush;
  cf: TFont;
  fillr: TGPRectF;
  cw, ch: Double;
  rows: integer;
  focusdate: Boolean;
  date: TDateTime;
  bw: Double;
begin
  with DateAppearance do
  begin
    g := TGPGraphics.Create(Canvas.Handle);

    layr := GetDateValuesRect;
    cw := GetCellWidth;
    ch := GetCellHeight;

    rows := 1;
    wd := 1;
    for I := 1 to 12 do
    begin
      fillr.X := xpos + layr.X + (wd * cw) - cw;
      fillr.Y := layr.Y + ((rows - 1) * ch);
      fillr.Height := ch;
      fillr.Width := cw;

      if DayOf(FFocusDate) <= DaysInMonth(EncodeDate(Year, I, 1)) then
        date := EncodeDate(Year, I, DayOf(FFocusDate))
      else
        date := EncodeDate(Year, I, DaysInMonth(EncodeDate(Year, I, 1)));

      focusdate := (CompareDateTime(FFocusDate, date) = 0) and ShowFocus and FFocused and TabStop;

      if (FCurrentMonth = I) and (FCurrentYear = Year) then
      begin
        cf := FSelectedDateFont;
        SelectedDateFill.BeginUpdate;
        SelectedDateFill.Focus := focusdate;
        SelectedDateFill.FocusColor := FocusColor;
        if SelectedDateFill.BorderColor <> clNone then
        begin
          bw := (SelectedDateFill.BorderWidth / 2);
          fillr.X := fillr.X + bw;
          fillr.Y := fillr.Y + bw;
          fillr.Height := fillr.Height - (bw * 2);
          fillr.Width := fillr.Width - (bw * 2);
        end;
        SelectedDateFill.Fill(g, fillr, Min(SelectedDateFill.BorderOpacity, FMonthOpc),
                                     Min(SelectedDateFill.Opacity, FMonthOpc),
                                     Min(SelectedDateFill.OpacityTo, FMonthOpc),
                                     Min(SelectedDateFill.OpacityMirror, FMonthOpc),
                                     Min(SelectedDateFill.OpacityMirrorTo, FMonthOpc));
        SelectedDateFill.EndUpdate;
      end
      else if CompareDate(FCurrentDate, date) = 0 then
      begin
        cf := FCurrentDateFont;
        CurrentDateFill.BeginUpdate;
        CurrentDateFill.Focus := focusdate;
        CurrentDateFill.FocusColor := FocusColor;
        if CurrentDateFill.BorderColor <> clNone then
        begin
          bw := (CurrentDateFill.BorderWidth / 2);
          fillr.X := fillr.X + bw;
          fillr.Y := fillr.Y + bw;
          fillr.Height := fillr.Height - (bw * 2);
          fillr.Width := fillr.Width - (bw * 2);
        end;
        CurrentDateFill.Fill(g, fillr, Min(CurrentDateFill.BorderOpacity, FMonthOpc),
                                     Min(CurrentDateFill.Opacity, FMonthOpc),
                                     Min(CurrentDateFill.OpacityTo, FMonthOpc),
                                     Min(CurrentDateFill.OpacityMirror, FMonthOpc),
                                     Min(CurrentDateFill.OpacityMirrorTo, FMonthOpc));
        CurrentDateFill.EndUpdate;
      end
      else if (MonthOf(FHoverDate) = I) and (FHoverDate <> -1) then
      begin
        cf := FHoverDateFont;
        HoverDateFill.BeginUpdate;
        HoverDateFill.Focus := focusdate;
        HoverDateFill.FocusColor := FocusColor;
        if HoverDateFill.BorderColor <> clNone then
        begin
          bw := (HoverDateFill.BorderWidth / 2);
          fillr.X := fillr.X + bw;
          fillr.Y := fillr.Y + bw;
          fillr.Height := fillr.Height - (bw * 2);
          fillr.Width := fillr.Width - (bw * 2);
        end;
        HoverDateFill.Fill(g, fillr, Min(HoverDateFill.BorderOpacity, FMonthOpc),
                                     Min(HoverDateFill.Opacity, FMonthOpc),
                                     Min(HoverDateFill.OpacityTo, FMonthOpc),
                                     Min(HoverDateFill.OpacityMirror, FMonthOpc),
                                     Min(HoverDateFill.OpacityMirrorTo, FMonthOpc));
        HoverDateFill.EndUpdate;
      end
      else
      begin
        cf := FMonthFont;
        DateFill.BeginUpdate;
        DateFill.Focus := focusdate;
        DateFill.FocusColor := FocusColor;
        DateFill.Fill(g, fillr, Min(DateFill.BorderOpacity, FMonthOpc),
                                Min(DateFill.Opacity, FMonthOpc),
                                Min(DateFill.OpacityTo, FMonthOpc),
                                Min(DateFill.OpacityMirror, FMonthOpc),
                                Min(DateFill.OpacityMirrorTo, FMonthOpc));
        DateFill.EndUpdate;
      end;

      ff := TGPFontFamily.Create(cf.Name);
      if (ff.Status in [FontFamilyNotFound, FontStyleNotFound]) then
      begin
        ff.Free;
        ff := TGPFontFamily.Create('Arial');
      end;

      fs := 0;
      if (fsBold in cf.Style) then
        fs := fs + 1;
      if (fsItalic in cf.Style) then
        fs := fs + 2;
      if (fsUnderline in cf.Style) then
        fs := fs + 4;

      sf := TGPStringFormat.Create;
      f := TGPFont.Create(ff, cf.Size, fs, UnitPoint);
      g.SetTextRenderingHint(TextRenderingHintClearTypeGridFit);
      b := TGPSolidBrush.Create(MakeColor(Round(FMonthOpc), cf.Color));
      {$IFDEF DELPHIXE_LVL}
      month := FormatSettings.ShortMonthNames[i];
      {$ENDIF}
      {$IFNDEF DELPHIXE_LVL}
      month := ShortMonthNames[i];
      {$ENDIF}
      g.MeasureString(month, length(month), f, layr, sf, sizer);
      g.DrawString(month, Length(month), f, MakePoint(fillr.X + (fillr.Width - sizer.Width) / 2, fillr.Y + (fillr.Height - sizer.Height) / 2), sf, b);

      if wd = 4 then
      begin
        Inc(rows);
        wd := 0;
      end;

      Inc(wd);

      b.Free;
      f.Free;
      sf.Free;
      ff.Free;
    end;
    //////////////////////////
    g.Free;
  end;
end;

procedure TAdvSmoothCalendar.DrawWeekNumbers;
var
  r, wr: TRect;
  g: TGPGraphics;
  f: TGPFont;
  ff: TGPFontFamily;
  sf: TGPStringFormat;
  b: TGPSolidBrush;
  fs: integer;
  fillr, sizer: TGPRectF;
  pt: TGPPointF;
  wdtotalfirst, dim, start, K: integer;
  s: String;
  ch: Double;
  wdr: TGPRectF;
  d, dweek: TDateTime;
begin
  with DateAppearance.WeekNumbers do
  begin
    if Visible then
    begin
      g := TGPGraphics.Create(Canvas.Handle);

      r := Rect(InsideRect.Left, InsideRect.Top + Header.GetHeight, InsideRect.Left + Width, InsideRect.Bottom - Footer.GetHeight - 1);
      wdr := GetDateValuesRect;

      fillr := fill.Fill(g, MakeRect(R.Left, r.Top, r.Right - r.Left, r.Bottom - r.Top));

      ff := TGPFontFamily.Create(FFont.Name);
      if (ff.Status in [FontFamilyNotFound, FontStyleNotFound]) then
      begin
        ff.Free;
        ff := TGPFontFamily.Create('Arial');
      end;

      fs := 0;
      if (fsBold in FFont.Style) then
        fs := fs + 1;
      if (fsItalic in FFont.Style) then
        fs := fs + 2;
      if (fsUnderline in FFont.Style) then
        fs := fs + 4;

      sf := TGPStringFormat.Create;
      f := TGPFont.Create(ff, FFont.Size, fs, UnitPoint);
      g.SetTextRenderingHint(TextRenderingHintClearTypeGridFit);

      b := TGPSolidBrush.Create(MakeColor(FWeekNumberOpc, FFont.Color));

      d := EncodeDate(FcurrentYear, FCurrentMonth, 1);
      dim := DaysInMonth(d);
      wdtotalfirst := GetDayOfWeekColumn(d);
      start := 2-wdtotalfirst;
      dweek := GetDate(start, dim);


      ch := GetCellHeight;

      K := 1;
      while dweek <= EncodeDate(FCurrentYear, FCurrentMonth, dim) do
      begin
        wr.left := 0;
        wr.right := Width;
        wr.top := Round(wdr.Y + ((K - 1) * ch));
        wr.bottom := Round(wdr.Y + ch - 2);

        fillr := MakeRect(wr.Left, wr.Top, wr.Right - wr.Left, wr.Bottom - wr.Top);

        s := IntToStr(WeekOf(dweek));
        g.MeasureString(s, Length(s), f, fillr, sf, sizer);
        pt := MakePoint((r.Right - sizer.Width) / 2, wr.Top + (ch - sizer.Height) / 2);
        g.DrawString(s, Length(s), f, pt, sf, b);
        dweek := dweek + 7;
        Inc(K);
      end;


      if k < GetCountRows then
      begin

      end;

      b.Free;

      ff.Free;
      sf.Free;
      f.free;

      g.Free;

    end;
  end;
end;

procedure TAdvSmoothCalendar.DrawYears(YearFrom, YearTo: integer; XPos: Single);
var
  g: TGPGraphics;
  ff: TGPFontFamily;
  fs: integer;
  f: TGPFont;
  sf: TGPStringFormat;
  I: Integer;
  layr, sizer: TGPRectF;
  year: String;
  wd: integer;
  b: TGPSolidBrush;
  cf: TFont;
  fillr: TGPRectF;
  cw, ch: Double;
  rows: integer;
  focusdate: Boolean;
  date: TDateTime;
  bw: Double;
begin
  with DateAppearance do
  begin
    g := TGPGraphics.Create(Canvas.Handle);

    layr := GetDateValuesRect;
    cw := GetCellWidth;
    ch := GetCellHeight;

    rows := 1;
    wd := 1;
    for I := 1 to 12 do
    begin
      fillr.X := xpos + layr.X + (wd * cw) - cw;
      fillr.Y := layr.Y + ((rows - 1) * ch);
      fillr.Height := ch;
      fillr.Width := cw;

      date := EncodeDate(YearFrom + (I - 1), FCurrentMonth, DayOf(FFocusDate));
      focusdate := (CompareDateTime(FFocusDate, date) = 0) and ShowFocus and FFocused and TabStop;

      if FCurrentYear = YearFrom + (I - 1) then
      begin
        cf := FCurrentDateFont;
        SelectedDateFill.BeginUpdate;
        SelectedDateFill.Focus := focusdate;
        if SelectedDateFill.BorderColor <> clNone then
        begin
          bw := (SelectedDateFill.BorderWidth / 2);
          fillr.X := fillr.X + bw;
          fillr.Y := fillr.Y + bw;
          fillr.Height := fillr.Height - (bw * 2);
          fillr.Width := fillr.Width - (bw * 2);
        end;
        SelectedDateFill.Fill(g, fillr, Min(SelectedDateFill.BorderOpacity, FYearOpc),
                                     Min(SelectedDateFill.Opacity, FYearOpc),
                                     Min(SelectedDateFill.OpacityTo, FYearOpc),
                                     Min(SelectedDateFill.OpacityMirror, FYearOpc),
                                     Min(SelectedDateFill.OpacityMirrorTo, FYearOpc));
        SelectedDateFill.EndUpdate;
      end
      else if YearOf(FCurrentDate) = YearFrom + (I - 1) then
      begin
        cf := FCurrentDateFont;
        CurrentDateFill.BeginUpdate;
        CurrentDateFill.Focus := focusdate;
        if CurrentDateFill.BorderColor <> clNone then
        begin
          bw := (CurrentDateFill.BorderWidth / 2);
          fillr.X := fillr.X + bw;
          fillr.Y := fillr.Y + bw;
          fillr.Height := fillr.Height - (bw * 2);
          fillr.Width := fillr.Width - (bw * 2);
        end;
        CurrentDateFill.Fill(g, fillr, Min(CurrentDateFill.BorderOpacity, FYearOpc),
                                     Min(CurrentDateFill.Opacity, FYearOpc),
                                     Min(CurrentDateFill.OpacityTo, FYearOpc),
                                     Min(CurrentDateFill.OpacityMirror, FYearOpc),
                                     Min(CurrentDateFill.OpacityMirrorTo, FYearOpc));
        CurrentDateFill.EndUpdate;
      end
      else if (YearOf(FHoverDate) = YearFrom + (I - 1)) and (FHoverDate <> -1) then
      begin
        cf := FHoverDateFont;
        HoverDateFill.BeginUpdate;
        HoverDateFill.Focus := focusdate;
        if HoverDateFill.BorderColor <> clNone then
        begin
          bw := (HoverDateFill.BorderWidth / 2);
          fillr.X := fillr.X + bw;
          fillr.Y := fillr.Y + bw;
          fillr.Height := fillr.Height - (bw * 2);
          fillr.Width := fillr.Width - (bw * 2);
        end;
        HoverDateFill.Fill(g, fillr, Min(HoverDateFill.BorderOpacity, FYearOpc),
                                     Min(HoverDateFill.Opacity, FYearOpc),
                                     Min(HoverDateFill.OpacityTo, FYearOpc),
                                     Min(HoverDateFill.OpacityMirror, FYearOpc),
                                     Min(HoverDateFill.OpacityMirrorTo, FYearOpc));
        HoverDateFill.EndUpdate;
      end
      else
      begin
        cf := FYearFont;
        DateFill.BeginUpdate;
        DateFill.Focus := focusdate;
        DateFill.Fill(g, fillr, Min(DateFill.BorderOpacity, FYearOpc),
                                Min(DateFill.Opacity, FYearOpc),
                                Min(DateFill.OpacityTo, FYearOpc),
                                Min(DateFill.OpacityMirror, FYearOpc),
                                Min(DateFill.OpacityMirrorTo, FYearOpc));
        DateFill.EndUpdate;
      end;

      ff := TGPFontFamily.Create(cf.Name);
      if (ff.Status in [FontFamilyNotFound, FontStyleNotFound]) then
      begin
        ff.Free;
        ff := TGPFontFamily.Create('Arial');
      end;

      fs := 0;
      if (fsBold in cf.Style) then
        fs := fs + 1;
      if (fsItalic in cf.Style) then
        fs := fs + 2;
      if (fsUnderline in cf.Style) then
        fs := fs + 4;

      sf := TGPStringFormat.Create;
      f := TGPFont.Create(ff, cf.Size, fs, UnitPoint);
      g.SetTextRenderingHint(TextRenderingHintClearTypeGridFit);
      b := TGPSolidBrush.Create(MakeColor(Round(FYearOpc), cf.Color));
      year := inttostr(YearFrom + (i - 1));
      g.MeasureString(year, length(year), f, layr, sf, sizer);
      g.DrawString(year, Length(year), f, MakePoint(fillr.X + (fillr.Width - sizer.Width) / 2, fillr.Y + (fillr.Height - sizer.Height) / 2), sf, b);

      if wd = 4 then
      begin
        Inc(rows);
        wd := 0;
      end;

      Inc(wd);

      b.Free;
      f.Free;
      sf.Free;
      ff.Free;
    end;
    //////////////////////////
    g.Free;
  end;
end;

function TAdvSmoothCalendar.GetEndDate: TDateTime;
begin
  if FEndDate > FStartDate then
    Result := FEndDate
  else
    Result := FStartDate;
end;

procedure TAdvSmoothCalendar.FillChanged(Sender: TObject);
begin
  Changed;
end;

procedure TAdvSmoothCalendar.FooterChanged(Sender: TObject);
begin
  Changed;
end;

function TAdvSmoothCalendar.GetArrowRect(left: Boolean): TRect;
var
  c, s: integer;
begin
  c := Round(Header.GetHeight / 2);
  s := Header.ArrowSize;
  if left then
  begin
    Result.Left := s;
    Result.Right := Result.Left + s;
    Result.Top := Round(c - (s / 2));
    Result.Bottom := Result.Top + s;
  end
  else
  begin
    Result.Left := ClientRect.Right - GetShadowOffset - (s * 2);
    Result.Right := Result.Left + s;
    Result.Top := Round(c - (s / 2));
    Result.Bottom := Result.Top + s;
  end;
end;

function TAdvSmoothCalendar.GetCellHeight: Double;
var
  r: TGPRectF;
begin
  result := 0;
  r := GetDateValuesRect;
  case FDateMode of
    dmDay: Result := r.Height / GetCountRows;
    dmYear, dmMonth: Result := r.Height / 3;
  end;
end;

function TAdvSmoothCalendar.GetCellWidth: Double;
var
  r: TGpRectF;
begin
  Result := 0;
  r := GetDateValuesRect;
  case FDateMode of
    dmDay: Result := r.Width / DaysPerWeek;
    dmYear, dmMonth: Result := r.Width / 4;
  end;
end;

function TAdvSmoothCalendar.GetCountRows: integer;
var
  dim, wd, i: integer;
  cmy, date: TDateTime;
  wdtotalfirst, wdtotallast: integer;
begin
  result := 0;
  cmy := EncodeDate(FCurrentYear, FCurrentMonth, 1);
  dim := DaysInMonth(cmy);
  case FDateMode of
    dmDay:
    begin
      result := 0;
      wdtotalfirst := GetDayOfWeekColumn(EncodeDate(FcurrentYear, FCurrentMonth, 1));
      wdtotallast := GetDayOfWeekColumn(EncodeDate(FcurrentYear, FCurrentMonth, dim));
      for I := 2-wdtotalfirst to dim + 7 - wdtotallast do
      begin
        date := GetDate(i, dim);
        wd := GetDayOfWeekColumn(date);
        if (wd = 7) then
          Inc(result);
      end;
    end;
    dmYear, dmMonth: result := 4;
  end;
end;

function TAdvSmoothCalendar.GetCurrentDay(year, month: Word): integer;
begin
  Result := Min(DaysInMonth(EncodeDate(year, month, 1)), FcurrentDay);
end;

function TAdvSmoothCalendar.GetDate(day, dim: integer): TDateTime;
begin
  if (day <= dim) and (day >= 1) then
    result := EncodeDate(FCurrentYear, FCurrentMonth, day)
  else if day > dim then
  begin
    if FCurrentMonth = 12 then
      result := EncodeDate(FCurrentYear + 1, 1, day - DaysInMonth(EncodeDate(FcurrentYear + 1, 1, 1)))
    else
      result := EncodeDate(FCurrentYear, FCurrentMonth + 1, day - dim)
  end
  else
  begin
    if FCurrentMonth = 1 then
      result := EncodeDate(FCurrentYear - 1, 12, DaysInMonth(EncodeDate(FCurrentYear - 1, 12, 1)) + day)
    else
      result := EncodeDate(FCurrentYear, FCurrentMonth - 1, DaysInMonth(EncodeDate(FcurrentYear, FCurrentMonth - 1, 1)) + day);
  end;
end;

function TAdvSmoothCalendar.GetDateValuesRect: TGPRectF;
var
  wdr: TGPRectF;
  h, wnoff: integer;
  f, fb, dw: integer;
begin
  wdr := GetWeekDaysRect;
  h := Header.GetHeight;
  f := Footer.GetHeight;
  wnoff := DateAppearance.WeekNumbers.GetWidth;

  fb := 0;
  if Footer.Fill.BorderColor <> clnone then
    fb := Footer.Fill.BorderWidth;

  dw := 0;
  if DateAppearance.DayOfWeekFill.BorderColor <> clNone then
    dw := DateAppearance.DayOfWeekFill.BorderWidth;

  case FDateMode of
    dmDay:
    begin
      result.X := InsideRect.Left + wnoff;
      result.Y := wdr.Y + wdr.Height + dw;
      Result.Height := InsideRect.Bottom - f - InsideRect.Top - wdr.Height - h - fb - GetShadowOffset;
      Result.Width := InsideRect.Right - 1 - wnoff - GetShadowOffset;
    end;
    dmMonth, dmYear:
    begin
      result.X := InsideRect.Left;
      result.Y := InsideRect.Top + h;
      Result.Height := InsideRect.Bottom - f - InsideRect.Top - h - GetShadowOffset - fb;
      Result.Width := InsideRect.Right - 1 - GetShadowOffset;
    end;
  end;
end;

function TAdvSmoothCalendar.GetDayOfWeekColumn(date: TDateTime): integer;
var
  dow: integer;
begin
  dow := DayOfWeek(date) - Integer(DateAppearance.StartDay);
  if dow > 0 then
    Result := dow
  else
    Result := dow + 7;

end;

function TAdvSmoothCalendar.GetFooterCaptionRect: TRect;
var
  g: TGPGraphics;
  h: String;
  r: Trect;
  sizer, fillr: TGPRectF;
  ff: TGPFontFamily;
  fs: Integer;
  f: TGPFont;
  sf: TGPStringFormat;
  pt: TGPPointF;
  th, tw, x, y: Integer;
begin
  with Footer do
  begin
    if Visible then
    begin
      if CurrentDateCaption then
        h := FormatDateTime('dd/mm/yyyy', FCurrentDate)
      else
        h := Caption;

      g := TGPGraphics.Create(Canvas.Handle);

      r := Rect(InsideRect.Left, InsideRect.Bottom - Height, InsideRect.Right - 1, InsideRect.Bottom);

      fillr := MakeRect(R.Left, r.Top, r.Right - r.Left, r.Bottom - r.Top);

      if h <> '' then
      begin

        ff := TGPFontFamily.Create(FFont.Name);
        if (ff.Status in [FontFamilyNotFound, FontStyleNotFound]) then
        begin
          ff.Free;
          ff := TGPFontFamily.Create('Arial');
        end;

        fs := 0;
        if (fsBold in FFont.Style) then
          fs := fs + 1;
        if (fsItalic in FFont.Style) then
          fs := fs + 2;
        if (fsUnderline in FFont.Style) then
          fs := fs + 4;

        sf := TGPStringFormat.Create;
        f := TGPFont.Create(ff, FFont.Size, fs, UnitPoint);
        g.SetTextRenderingHint(TextRenderingHintClearTypeGridFit);

        g.MeasureString(h, Length(h), f, fillr, sf, sizer);

        th := Round(sizer.Height);
        tw := Round(sizer.Width);

        if FCaptionPosition <> cpCustom then
          GetCaptionPosition(x, y, fillr, tw, th, FCaptionPosition)
        else
        begin
          x := FCaptionLeft;
          y := FCaptionTop;
        end;

        pt := MakePoint(fillr.X + x, fillr.Y + y);

        Result := Bounds(Round(pt.X), Round(pt.Y), tw, th);

        ff.Free;
        sf.Free;
        f.free;

      end;
      g.Free;
    end;
  end;
end;

function TAdvSmoothCalendar.GetHeaderCaptionRect: TRect;
var
  r: TRect;
  th, tw, x, y: integer;
  g: TGPGraphics;
  f: TGPFont;
  ff: TGPFontFamily;
  sf: TGPStringFormat;
  fs: integer;
  pt: TGPPointF;
  fillr, sizer: TGPRectF;
  h: String;
begin
  with Header do
  begin
    if Visible then
    begin
      case FDateMode of
        dmDay: h := FormatDateTime('mmmm yyyy', EncodeDate(FCurrentYear, FCurrentMonth, 1));
        dmMonth: h := FormatDateTime('yyyy', EncodeDate(FCurrentYear, FCurrentMonth, 1));
        dmYear: h := IntToStr(FCurrentYearFrom) + ' - ' + IntToStr(FCurrentYearTo);
      end;

      g := TGPGraphics.Create(Canvas.Handle);

      r := Rect(InsideRect.Left, InsideRect.Top , InsideRect.Right, InsideRect.Top + Height);
      fillr := MakeRect(r.Left, r.Top, r.Right, r.Bottom);

      if h <> '' then
      begin

        ff := TGPFontFamily.Create(FFont.Name);
        if (ff.Status in [FontFamilyNotFound, FontStyleNotFound]) then
        begin
          ff.Free;
          ff := TGPFontFamily.Create('Arial');
        end;

        fs := 0;
        if (fsBold in FFont.Style) then
          fs := fs + 1;
        if (fsItalic in FFont.Style) then
          fs := fs + 2;
        if (fsUnderline in FFont.Style) then
          fs := fs + 4;

        sf := TGPStringFormat.Create;
        f := TGPFont.Create(ff, FFont.Size, fs, UnitPoint);
        g.SetTextRenderingHint(TextRenderingHintClearTypeGridFit);

        g.MeasureString(h, Length(h), f, fillr, sf, sizer);

        th := Round(sizer.Height);
        tw := Round(sizer.Width);

        if FCaptionPosition <> cpCustom then
          GetCaptionPosition(x, y, fillr, tw, th, FCaptionPosition)
        else
        begin
          x := FCaptionLeft;
          y := FCaptionTop;
        end;

        pt := MakePoint(fillr.X + x, fillr.Y + y);

        Result := Bounds(Round(pt.X), Round(pt.Y), Round(sizer.Width), Round(sizer.Height));
        ff.Free;
        sf.Free;
        f.free;

      end;

      g.Free;
    end;
  end;
end;

function TAdvSmoothCalendar.GetMonth: integer;
begin
  Result := CurrentMonth;
end;

function TAdvSmoothCalendar.GetVersion: String;
var
  vn: Integer;
begin
  vn := GetVersionNr;
  Result := IntToStr(Hi(Hiword(vn)))+'.'+IntToStr(Lo(Hiword(vn)))+'.'+IntToStr(Hi(Loword(vn)))+'.'+IntToStr(Lo(Loword(vn)));
end;

function TAdvSmoothCalendar.GetVersionNr: integer;
begin
  Result := MakeLong(MakeWord(BLD_VER,REL_VER),MakeWord(MIN_VER,MAJ_VER));
end;

function TAdvSmoothCalendar.GetWeekDaysRect: TGPRectF;
var
  hweek: integer;
  g: TGPGraphics;
  wnoff: integer;
  layr, sizer: TGPRectF;
  dpw: integer;
  ff: TGPFontFamily;
  f: TGPFont;
  fs: integer;
  sf: TGPStringFormat;
  b: TGPSolidBrush;
  i: integer;
  weekday: string;
begin
  with DateAppearance do
  begin
    g := TGPGraphics.Create(Canvas.Handle);
    g.SetSmoothingMode(SmoothingModeAntiAlias);

    wnoff := WeekNumbers.GetWidth;
    layr := MakeRect(InsideRect.Left + wnoff, InsideRect.Top + Header.GetHeight, InsideRect.Right - wnoff, InsideRect.Bottom - InsideRect.Top - Header.GetHeight);
    dpw := DaysPerWeek;

    ff := TGPFontFamily.Create(FDayOfWeekFont.Name);
    if (ff.Status in [FontFamilyNotFound, FontStyleNotFound]) then
    begin
      ff.Free;
      ff := TGPFontFamily.Create('Arial');
    end;

    fs := 0;
    if (fsBold in FDayOfWeekFont.Style) then
      fs := fs + 1;
    if (fsItalic in FDayOfWeekFont.Style) then
      fs := fs + 2;
    if (fsUnderline in FDayOfWeekFont.Style) then
      fs := fs + 4;

    sf := TGPStringFormat.Create;
    f := TGPFont.Create(ff, FDayOfWeekFont.Size, fs, UnitPoint);
    g.SetTextRenderingHint(TextRenderingHintClearTypeGridFit);
    b := TGPSolidBrush.Create(MakeColor(255, FDayOfWeekFont.Color));

    hweek := 0;
    for I := 1 to dpw do
    begin
      {$IFDEF DELPHIXE_LVL}
      weekday := FormatSettings.ShortDayNames[I];
      {$ENDIF}
      {$IFNDEF DELPHIXE_LVL}
      weekday := ShortDayNames[I];
      {$ENDIF}
      g.MeasureString(weekday, length(weekday), f, layr, sf, sizer);
      hweek := Round(Max(hweek, sizer.Height));
    end;

    b.Free;
    sf.Free;
    ff.Free;
    f.Free;
    g.Free;

    Result := MakeRect(layr.X, layr.Y, layr.Width, hweek);
  end;
end;

function TAdvSmoothCalendar.GetYear: integer;
begin
  Result := CurrentYear;
end;

procedure TAdvSmoothCalendar.HeaderChanged(Sender: TObject);
begin
  Changed;
end;

function TAdvSmoothCalendar.IndicatorAtXY(X, Y: Integer): TDateStatus;
var
  status: TGDIPStatus;
  rows: Integer;
  start, stop: integer;
  bmp: TBitmap;
  g: TGPGraphics;
  i: integer;
  dt: TDateTime;
  dim: Integer;
  wd: single;
  cmy: TDateTime;
  str: String;
  layr: TGPRectF;
  xoff, yoff: Double;
  cw, ch: Double;
  xf, yf: Double;
  OffSetX, OffsetY: Integer;
  wdtotalfirst, wdtotallast: integer;
begin
  Result.Found := False;
  layr := GetDateValuesRect;
  rows := 1;
  yoff := Layr.Y;
  xoff := layr.X;
  status := TGDIPStatus.Create;
  cmy := EncodeDate(FCurrentYear, FCurrentMonth, 1);
  dim := DaysInMonth(cmy);
  cw := GetCellWidth;
  ch := GetCellHeight;

  wdtotalfirst := GetDayOfWeekColumn(EncodeDate(FcurrentYear, FCurrentMonth, 1));
  wdtotallast := GetDayOfWeekColumn(EncodeDate(FcurrentYear, FCurrentMonth, dim));
  if DateAppearance.ShowDaysBefore then
    start := 2-wdtotalfirst
  else
    start := 1;

  if DateAppearance.ShowDaysAfter then
    stop := dim + 7 - wdtotallast
  else
    stop := dim;

  bmp := TBitmap.Create;
  g := TGPGraphics.Create(bmp.Canvas.Handle);

  for I := start to stop do
  begin
    status.Assign(StatusAppearance);
    dt := GetDate(i, dim);
    wd := GetDayOfWeekColumn(dt);
    str := '';
    xf := xoff + (wd * cw);
    yf := yoff + ((rows - 1) * ch);
    OffSetX := 0;
    OffsetY := 0;
    DoGetDayStatus(Self, dt, str, status, Offsetx, Offsety);
    if str <> '' then
    begin
      status.CalculateSize(g, str);
      xf := xf - (status.GetWidth / 3 * 2) + OffsetX;
      yf := yf - (status.GetHeight / 2) + OffsetY;
      if PtInRect(Bounds(Round(xf), Round(yf), status.GetWidth, status.GetHeight), Point(X, Y)) then
      begin
        Result.Found := True;
        Result.Text := Str;
        Result.Date := dt;
        Break;
      end;
    end;

    if wd = 7 then
    begin
      Inc(rows);
    end;
  end;

  status.Free;
  bmp.free;
  g.free;
end;

procedure TAdvSmoothCalendar.InitPreview;
begin
  (*
  DateAppearance.SelectedDateFill.Color := clWhite;
  DateAppearance.SelectedDateFill.BorderColor := clBlack;
  DateAppearance.SelectedDateFill.ColorTo := RGB(223, 223, 223);

  DateAppearance.CurrentDateFont.Style := DateAppearance.CurrentDateFont.Style + [fsBold];
  DateAppearance.CurrentDateFill.BorderColor := clBlue;
  DateAppearance.CurrentDateFill.Color := clWhite;
  DateAppearance.CurrentDateFill.Color := clSilver;
  DateAppearance.CurrentDateFill.Rounding := 5;
  *)
end;

function TAdvSmoothCalendar.InsideRect: TRect;
var
  bw: integer;
begin
  Result := ClientRect;
  if (Fill.BorderColor <> clNone) then
  begin
    if Fill.BorderWidth = 1 then
      bw := 1
    else
      bw := Fill.BorderWidth div 2;

    InflateRect(Result, -bw, -bw);
  end;
end;

function TAdvSmoothCalendar.IsDisjunctDate(Date: TDateTime): Boolean;
var
  I: Integer;
begin
  if (Length(FDisjunctDays) > 0) then
  begin
    Result := False;
    for I := 0 to Length(FDisjunctDays) - 1 do
    begin
      if FDisjunctDays[i] = Date then
      begin
        Result := True;
        break;
      end;
    end;
  end
  else
    Result := True;
end;

function TAdvSmoothCalendar.IsWeekendDay(date: TDateTime): Boolean;
begin
  Result := (DayOfWeek(Date) = 1) or (DayOfWeek(date) = 7);
end;

procedure TAdvSmoothCalendar.KeyDown(var Key: Word; Shift: TShiftState);
var
  date: TDateTime;
  m, y: integer;
begin
  inherited;

  date := EncodeDate(FCurrentYear, FCurrentMonth, 1);
  case Key of
    VK_SHIFT: FStartDate := FFocusDate;
    VK_F4:
    begin
      if KeyBoardDateModeToggle then
        ToggleMode;
    end;
    VK_SPACE, VK_RETURN:
    begin
      SelectDate(Shift, FFocusDate);
    end;
    VK_RIGHT, VK_DOWN:
    begin
      case FDateMode of
        dmDay:
        begin
          if Key = VK_RIGHT then
            FFocusDate := FFocusDate + 1
          else
            FFocusDate := FFocusDate + 7;

          if Monthof(FFocusDate) <> MonthOf(date) then
          begin
            if FCurrentMonth = 12 then
            begin
              FCurrentMonth := 1;
              FNextMonth := FCurrentMonth;
              DoChangeMonth(Self, FNextMonth);
              Inc(FCurrentYear);
              FNextYear := FCurrentYear;
              DoChangeYear(Self, FNextYear);
            end
            else
            begin
              Inc(FCurrentMonth);
              FNextMonth := FCurrentMonth;
              DoChangeMonth(Self, FNextMonth);
            end;
          end;

          if (ssShift in Shift) then
            SelectDate(Shift, FFocusDate);

        end;
        dmMonth:
        begin
          m := MonthOf(FFocusDate);

          if m = 12 then
          begin
            Inc(FCurrentYear);
            FNextYear := FCurrentYear;
            DoChangeYear(Self, FNextYear);
            m := 1;
          end
          else
          begin
            if Key = VK_RIGHT then
              Inc(m)
            else
              m := m + 4;
          end;

          FFocusDate := EncodeDate(FCurrentYear, Max(1, Min(12, m)), DayOf(FFocusDate));

        end;
        dmYear:
        begin
          y := YearOf(FFocusDate);

          if y = FCurrentYearTo then
          begin
            FCurrentYearFrom := FCurrentYearTo;
            FCurrentYearTo := FCurrentYearFrom + 11;
            y := FCurrentYearFrom;
            FNextYearFrom := FCurrentYearFrom;
            FNextYearTo := FCurrentYearTo;
            DoChangeYearRange(Self, FNextYearFrom, FNextYearTo);
          end
          else
          begin
            if Key = VK_RIGHT then
              Inc(y)
            else
              y := y + 4;
          end;

          FFocusDate := EncodeDate(Max(FCurrentYearFrom, Min(FCurrentYearTo, y)), FCurrentMonth, DayOf(FFocusDate));
        end;
      end;

      Changed;
    end;
    VK_LEFT, VK_UP:
    begin
      case FDateMode of
        dmDay:
        begin
          if Key = VK_LEFT then
            FFocusDate := FFocusDate - 1
          else
            FFocusDate := FFocusDate - 7;

          if Monthof(FFocusDate) <> MonthOf(date) then
          begin
            if FCurrentMonth = 1 then
            begin
              FCurrentMonth := 12;
              FNextMonth := FCurrentMonth;
              Dec(FCurrentYear);
              FNextYear := FCurrentYear;
              DoChangeMonth(Self, FNextMonth);
              DoChangeYear(Self, FNextYear);
            end
            else
            begin
              Dec(FCurrentMonth);
              FNextMonth := FCurrentMonth;
              DoChangeMonth(Self, FNextMonth);
            end;
          end;

          if (ssShift in Shift) then
            SelectDate(Shift, FFocusDate);

        end;
        dmMonth:
        begin
          m := MonthOf(FFocusDate);

          if m = 1 then
          begin
            Dec(FCurrentYear);
            FNextYear := FCurrentYear;
            DoChangeYear(Self, FNextYear);
            m := 12;
          end
          else
          begin
            if Key = VK_LEFT then
              Dec(m)
            else
              m := m - 4;
          end;

          FFocusDate := EncodeDate(FCurrentYear, Max(1, Min(12, m)), DayOf(FFocusDate));
        end;
        dmYear:
        begin
          y := YearOf(FFocusDate);

          if y = FCurrentYearFrom then
          begin
            FCurrentYearTo := FCurrentYearFrom;
            FCurrentYearFrom := FCurrentYearFrom - 11;
            y := FCurrentYearTo;
            FNextYearFrom := FCurrentYearFrom;
            FNextYearTo := FCurrentYearTo;
            DoChangeYearRange(Self, FNextYearFrom, FNextYearTo);
          end
          else
          begin
            if key = VK_LEFT then
              Dec(y)
            else
              y := y - 4;
          end;

          FFocusDate := EncodeDate(Max(FCurrentYearFrom, Min(FCurrentYearTo, y)), FCurrentMonth, DayOf(FFocusDate));
        end;
      end;
      Changed;
    end;
    VK_HOME:
    begin
      FFocusDate := FCurrentDate;
      FCurrentYear := YearOf(FFocusDate);
      FCurrentMonth := MonthOf(FFocusDate);
      Changed;
    end;
    VK_NEXT:
    begin
      NextDate;
      FFocusDate := EncodeDate(FCurrentYear, FCurrentMonth, DayOf(FFocusDate));
    end;
    VK_PRIOR:
    begin
      PreviousDate;
      FFocusDate := EncodeDate(FCurrentYear, FCurrentMonth, DayOf(FFocusDate));
    end;
  end;
end;

procedure TAdvSmoothCalendar.LoadFromTheme(FileName: String);
begin

end;

procedure TAdvSmoothCalendar.MouseDown(Button: TMouseButton; Shift: TShiftState;
  X, Y: Integer);
var
  d: TDateTime;
  switch, allowc: Boolean;
begin
  inherited;

  FTick := GetTickCount;

  if IndicatorAtXY(X, Y).Found then
    Exit;

  FMouseDown := true;
  FMX := X;
  FMY := Y;

  if not PtInrect(GetArrowRect(true), Point(X, Y)) and not PtInrect(GetArrowRect(false), Point(X, Y))  and Fanimating then
    Exit;

  if PtInRect(GetFooterCaptionRect, Point(X, Y)) and Footer.CurrentDateCaption and Footer.Visible then
  begin
    allowc := true;
    DoCurrentDateClick(Self, allowc);
    if allowc then
    begin
      if FCurrentYear = YearOf(FCurrentDate) then
        switch := FCurrentMonth <> MonthOf(FCurrentDate)
      else
        switch := FCurrentYear <> YearOf(FCurrentDate);

      if switch then
      begin
        FCurrentYear := YearOf(FCurrentDate);
        FCurrentMonth := MonthOf(FCurrentDate);
        FCurrentDay := DayOf(FCurrentDate);
        FCurrentYearFrom := FCurrentYear;
        FCurrentYearTo := FCurrentYear + 11;
        FTempDateMode := dmDay;
        FDayOpcTo := 255;
        FMonthOpcTo := 0;
        FYearOpcTo := 0;
        FWeekNumberOpcTo := 255;
        if FNextMonth > FCurrentMonth then
        begin
          FPosTo := ClientWidth;
          FStartPos := -ClientWidth;
        end
        else
        begin
          FPosTo := -ClientWidth;
          FStartPos := ClientWidth;
        end;

        DoChangeMonth(Self, FcurrentMonth);
        DoChangeYear(Self, FCurrentYear);
        DoChangeYearRange(Self, FCurrentYearFrom, FCurrentYearTo);

        //if not Animation then
        begin
          FDayOpc := FDayOpcTo;
          FMonthOpc := FMonthOpcTo;
          FYearOpc := FYearOpcTo;
          FDateMode := FTempDateMode;
          FNextYearFrom := FCurrentYearFrom;
          FNextYearTo := FCurrentYearTo;
          FNextMonth := FCurrentMonth;
          FNextYear := FCurrentYear;
          FWeekNumberOpc := FWeekNumberOpcTo;
          Changed;
        end
        //else
        //begin
        //  FAnimateDateMode := true;
        //  FAnimate := true;
        //end;
      end;

      SelectDate(Shift, FCurrentDate);
    end;
  end
  else if PtInrect(GetHeaderCaptionRect, Point(X, Y)) then
  begin
    ToggleMode;
  end
  else
  begin
    if FAnimating then
    begin
      FAnimate := false;
      FCurrentPos := FPosTo;
    end;

    FHoverDate := -1;
    if PtInRect(GetArrowRect(true), Point(X, Y)) then
      PreviousDate
    else if Ptinrect(GetArrowRect(false), Point(X, Y)) then
      NextDate
    else
    begin
      d := XYToDate(X, Y);
      allowc := true;
      if d = FCurrentDate then
        DoCurrentDateClick(Self, allowc);

      if allowc then
        SelectDate(Shift, d);
    end;
  end;
end;

procedure TAdvSmoothCalendar.MouseMove(Shift: TShiftState; X, Y: Integer);
var
  d: TDateTime;
  al, ar, hdr, fdr: TRect;
  pt: TPoint;
  select: Boolean;
  mind, maxd: TDate;
begin
  inherited;

  if IndicatorAtXY(X, Y).Found then
  begin
    if FHoverDate <> -1 then
    begin
      FHoverDate := -1;
      Changed;
    end;
    Exit;
  end;

  if not Fanimating then
  begin
    d := XYToDate(X, Y);

    mind := MinDate;
    maxd := MaxDate;

    if MinDate = 0 then
      mind := d;

    if MaxDate = 0 then
      maxd := d;

    select := true;
    case FDateMode of
      dmDay: select := (d >= mind) and (d <= maxd);
    end;

    if select then
    begin
      if d <> FHoverDate then
      begin
        FHoverDate := d;
        Application.CancelHint;
        Changed;
      end;

      if (ssShift in Shift) and FMouseDown and MultiSelect and (d <> -1) and not (CompareDate(d, FStartDate) = 0) then
      begin
        FEndDate := d;
        FSelectedDateRange := drMultiDates;
        DoSelectMultiDate(Self, FDateMode, StartDate, EndDate);
        Changed;
      end;
    end;

    al := GetArrowRect(true);
    ar := GetArrowRect(false);
    hdr := GetHeaderCaptionRect;
    fdr := GetFooterCaptionRect;
    pt := Point(X, Y);
    if Ptinrect(al, pt) or PtInRect(ar, pt) or PtInRect(hdr, pt) or PtInRect(fdr, pt) then
      Cursor := crHandPoint
    else
      Cursor := crArrow;

    if (FDateMode = dmDay) and PtInRect(Bounds(hdr.Left, hdr.Top, hdr.Right - hdr.Left + FUpDown.Width + 5, hdr.Bottom - hdr.Top), pt) then
    begin
      if Assigned(FUpDown) then
      begin
        if not FUpDown.Visible then
        begin
          FUpDown.Left := hdr.Right + 5;
          FUpDown.Top := hdr.Top + (hdr.Bottom - hdr.Top - FUpDown.Height) div 2;
          FUpDown.Parent := Self;
          FUpDown.Visible := True;
        end;
      end
    end
    else
    begin
      if Assigned(FUpDown) then
      begin
        if FUpDown.Visible then
        begin
          FUpDown.Visible := False;
          FUpDown.Parent := nil;
        end;
      end;
    end;
  end;
end;

procedure TAdvSmoothCalendar.MouseUp(Button: TMouseButton; Shift: TShiftState;
  X, Y: Integer);
var
  st: TDateStatus;
begin
  inherited;

  st := IndicatorAtXY(X, Y);
  if st.Found then
  begin
    if Assigned(OnDateStatusClick) then
      OnDateStatusClick(Self, st.Text, st.Date);
  end;

  if (Abs(Y - FMy) < 10) and (Abs(X - FMx) > 20) and FMouseDown and ((GetTickCount - FTick) < 1000) then
  begin
    if X < FMx then
      NextDate
    else
      PreviousDate;
  end;

  FMy := Y;
  FMx := X;
  FMouseDown := false;
end;

procedure TAdvSmoothCalendar.NextDate;
begin
  case FDateMode of
    dmDay:
    begin
      if FCurrentMonth = 12 then
      begin
        FCurrentMonth := 1;
        Inc(FCurrentYear);
        Inc(FCurrentYearFrom);
        Inc(FCurrentYearTo);
      end
      else
        Inc(FCurrentMonth);

      DoChangeMonth(Self, FCurrentMonth);
    end;
    dmMonth:
    begin
      Inc(FCurrentYear);
      Inc(FCurrentYearFrom);
      Inc(FCurrentYearTo);
      DoChangeYear(Self, FCurrentYear);
    end;
    dmYear:
    begin
      FCurrentYearFrom := FCurrentYearFrom + 11;
      FCurrentYearTo := FCurrentYearTo + 11;
      DoChangeYearRange(Self, FCurrentYearFrom, FCurrentYearTo);
    end;
  end;

  FPosTo := -ClientWidth;
  FStartPos := ClientWidth;
  FWeekNumberOpc := 0;
  FWeekNumberOpcTo := 255;
  if not Animation then
  begin
    FCurrentPos := 0;
    FPosTo := 0;
    FNextYear := FCurrentYear;
    FNextMonth := FCurrentMonth;
    FNextYearFrom := FCurrentYearFrom;
    FNextYearTo := FCurrentYearTo;
    FWeekNumberOpc := 255;
    Changed;
  end
  else
    FAnimate := true;
end;

procedure TAdvSmoothCalendar.Paint;
var
  dr, r: TGPRectF;
  rows, i: integer;
  date: TDateTime;
  wd, cw, ch: Double;
  layr, fillr: TGPRectF;
  multir: TGPRectF;
  g: TGPGraphics;
  bw: Double;
  dim, start, stop, wdtotalfirst, wdtotallast: integer;
begin
  DrawBackGround;
  DrawHeader;
  DrawFooter;
  if Height = (Footer.GetHeight + Header.GetHeight) then
    exit;

  dr := GetDateValuesRect;

  case FDateMode of
    dmDay:
    begin
     DrawDayOfWeek;

     if (FSelectedDateRange = drMultiDates) then
     begin
       SetLength(arrMulti, 0);
       layr := GetDateValuesRect;
       cw := GetCellWidth;
       ch := GetCellHeight;
       dim := DaysInMonth(EncodeDate(FcurrentYear, FCurrentMonth, 1));
       rows := 1;
       FRows := 1;
       wdtotalfirst := GetDayOfWeekColumn(EncodeDate(FcurrentYear, FCurrentMonth, 1));
       wdtotallast := GetDayOfWeekColumn(EncodeDate(FcurrentYear, FCurrentMonth, dim));
       if DateAppearance.ShowDaysBefore then
         start := 2-wdtotalfirst
       else
         start := 1;

       if DateAppearance.ShowDaysAfter then
         stop := dim + 7 - wdtotallast
       else
         stop := dim;

       for I := start to stop do
       begin
         date := GetDate(i, dim);
         wd := GetDayOfWeekColumn(date);

         fillr.X := layr.X + (wd * cw) - cw;
         fillr.Y := layr.Y + ((rows - 1) * ch);
         fillr.Height := ch;
         fillr.Width := cw;

         if (date <= EndDate) and (date >= StartDate) then
         begin
           if (date = startdate) or (Frows <> rows)
           or ((MonthOf(startdate) <> FCurrentMonth) and (I = start))
            then
           begin
             if rows <> frows then
               Frows := rows;
             multir := fillr;
           end
           else
             multir.Width := multir.Width + Fillr.Width;

           if (wd = 7) or (date = GetDate(start, dim)) or (date = GetDate(stop, dim)) or (date = startdate) or (date = enddate) then
           begin
             SetLength(arrMulti, Length(arrMulti) + 1);
             arrMulti[Length(arrMulti) - 1] := multir;
             multir := fillr;
           end;
         end;

         if wd = 7 then
           Inc(Rows);
       end;

       with DateAppearance do
       begin
         g := TGPGraphics.Create(Canvas.Handle);

         for I := 0 to Length(arrMulti) - 1 do
         begin
           r := arrMulti[I];
           SelectedDateFill.BeginUpdate;
           SelectedDateFill.Focus := false;
           if SelectedDateFill.BorderColor <> clNone then
           begin
             bw := (SelectedDateFill.BorderWidth / 2);
             r.X := r.X + bw;
             r.Y := r.Y + bw;
             r.Height := r.Height - (bw * 2);
             r.Width := r.Width - (bw * 2);
           end;
           SelectedDateFill.Fill(g, r, Min(SelectedDateFill.BorderOpacity, FDayOpc),
                                           Min(SelectedDateFill.Opacity, FDayOpc),
                                           Min(SelectedDateFill.OpacityTo, FDayOpc),
                                           Min(SelectedDateFill.OpacityMirror, FDayOpc),
                                           Min(SelectedDateFill.OpacityMirrorTo, FDayOpc));
           SelectedDateFill.EndUpdate;
         end;

         g.Free;
       end;
     end;


     if FCurrentMonth <> FNextMonth then
       DrawDays(FCurrentMonth, FCurrentYear, FStartPos + FCurrentPos);

     DrawDays(FNextMonth, FNextYear, FCurrentPos);

     DrawWeekNumbers;

    end;
    dmMonth:
    begin
     if FCurrentYear <> FNextYear then
       DrawMonths(FCurrentYear, FStartPos + FCurrentPos);

     DrawMonths(FNextYear, FCurrentPos);
    end;
    dmYear:
    begin
     if (FCurrentYearFrom <> FNextYearFrom) and (FCurrentYearTo <> FNextYearTo) then
       DrawYears(FCurrentYearFrom, FCurrentYearTo, FStartPos + FCurrentPos);

     DrawYears(FNextYearFrom, FNextYearTo, FCurrentPos);
    end;
  end;
end;

procedure TAdvSmoothCalendar.PreviousDate;
begin
  case FDateMode of
    dmDay:
    begin
      if FCurrentMonth = 1 then
      begin
        FCurrentMonth := 12;
        Dec(FCurrentYear);
        Dec(FCurrentYearFrom);
        Dec(FCurrentYearTo);
      end
      else
        Dec(FCurrentMonth);

      DoChangeMonth(Self, FCurrentMonth);
    end;
    dmMonth:
    begin
      Dec(FCurrentYear);
      Dec(FCurrentYearFrom);
      Dec(FCurrentYearTo);
      DoChangeYear(Self, FCurrentYear);
    end;
    dmYear:
    begin
      FCurrentYearFrom := FCurrentYearFrom - 11;
      FCurrentYearTo := FCurrentYearTo - 11;
      DoChangeYearRange(Self, FCurrentYearFrom, FCurrentYearTo);
    end;
  end;

  FPosTo := ClientWidth;
  FStartPos := -ClientWidth;
  FWeekNumberOpc := 0;
  FWeekNumberOpcTo := 255;
  if not Animation then
  begin
    FCurrentPos := 0;
    FPosTo := 0;
    FNextYear := FCurrentYear;
    FNextMonth := FCurrentMonth;
    FNextYearFrom := FCurrentYearFrom;
    FNextYearTo := FCurrentYearTo;
    FWeekNumberOpc := 255;
    Changed;
  end
  else
    FAnimate := true;
end;

function TAdvSmoothCalendar.RemoveDateIfSelect(Date: TDateTime): Boolean;
var
  I: Integer;
begin
  Result := True;
  for I := 0 to Length(FDisjunctDays) - 1 do
  begin
    if CompareDateTime(Date, FDisjunctDays[i]) = 0 then
    begin
      DeleteArrayItem(FDisjunctDays, i);
      Result := False;
      Break;
    end;
  end;
end;

procedure TAdvSmoothCalendar.Resize;
begin
  inherited;
  Height := Max(Height, Footer.GetHeight + Header.GetHeight);
  Width := Max(Width, Footer.GetHeight + Header.GetHeight);
end;

procedure TAdvSmoothCalendar.SaveToTheme(FileName: String);
begin

end;

procedure TAdvSmoothCalendar.SelectDate(Shift: TShiftState; Date: TDateTime);
var
  select: Boolean;
  mind, maxd: TDate;
  AllowChange: Boolean;
begin
  AllowChange := true;
  if Assigned(OnBeforeSelectDate) then
    OnBeforeSelectDate(Self, FDateMode, Date, AllowChange);

  if AllowChange then
  begin
    select := true;

    mind := MinDate;
    maxd := MaxDate;

    if MinDate = 0 then
      mind := Date;

    if MaxDate = 0 then
      maxd := Date;

    case FDateMode of
      dmDay: select := (Date >= mind) and (Date <= maxd);
    end;

    if (Date <> - 1) and select then
    begin
      if (ssShift in Shift) and (FDateMode = dmDay) and MultiSelect then
      begin
        SetLength(FDisjunctDays, 0);
        FEndDate := Date;
        FSelectedDateRange := drMultiDates;
        DoSelectMultiDate(Self, FDateMode, StartDate, EndDate);
        FHoverDate := -1;
        Changed;
      end
      else if (ssCtrl in Shift) and (FDateMode = dmDay) and MultiSelect and DisjunctDaySelect then
      begin
        if RemoveDateIfSelect(Date) then
        begin
          SetLength(FDisjunctDays, Length(FDisjunctDays) + 1);
          FDisjunctDays[Length(FDisjunctDays) - 1] := Date;
        end;
        FSelectedDateRange := drSingledate;
        DoSelectDisjunctDate(Self, FDateMode, FDisjunctDays);
        FHoverDate := -1;
        Changed;
      end
      else
      begin
        SetLength(FDisjunctDays, 0);
        SetLength(FDisjunctDays, Length(FDisjunctDays) + 1);
        FDisjunctDays[Length(FDisjunctDays) - 1] := Date;
        FSelectedDateRange := drSingledate;
        FStartDate := Date;
        FEndDate := Date;
        FCurrentYear := YearOf(Date);
        FNextYear := FCurrentYear;
        FCurrentMonth := MonthOf(Date);
        FNextMonth := FCurrentMonth;
        FCurrentDay := DayOf(Date);

        FSelectedDate := Date;
        FFocusDate := Date;
        FHoverDate := -1;

        if not Animation then
          DoSelectDate(Self, FDateMode, FSelectedDate);

        case FDateMode of
          dmMonth: FTempDateMode := dmDay;
          dmYear: FTempDateMode := dmMonth;
        end;

        case FDateMode of
          dmMonth:
          begin
            FAnimateDateMode := true;
            FAnimate := true;
            FMonthOpcTo := 0;
            FDayOpcTo := 255;
            FWeekNumberOpcTo := 255;
            if not Animation then
            begin
              FDayOpc := FDayOpcTo;
              FYearOpc := FYearOpcTo;
              FDateMode := FTempDateMode;
              FWeekNumberOpc := FWeekNumberOpcTo;
            end;
          end;
          dmYear:
          begin
            FAnimateDateMode := true;
            FAnimate := true;
            FYearOpcTo := 0;
            FMonthOpcTo := 255;
            if not Animation then
            begin
              FMonthOpc := FMonthOpcTo;
              FYearOpc := FYearOpcTo;
              FDateMode := FTempDateMode;
            end;
          end;
        end;

        if Animation then
          DoSelectDate(Self, FDateMode, FSelectedDate);
        Changed;
      end;
    end;
  end;
end;

procedure TAdvSmoothCalendar.SelectDisjunctDates(
  ADisjunctDates: array of TDateTime);
var
  I: Integer;
  d: TDate;
begin
  if MultiSelect and DisjunctDaySelect then
  begin
    SetLength(FDisjunctDays, 0);
    for I := 0 to Length(ADisjunctDates) - 1 do
    begin
      d := int(ADisjunctDates[i]);
      SetLength(FDisjunctDays, Length(FDisjunctDays) + 1);
      FDisjunctDays[Length(FDisjunctDays) - 1] := d;
    end;
    FSelectedDateRange := drSingledate;
    DoSelectDisjunctDate(Self, FDateMode, FDisjunctDays);
    FHoverDate := -1;
    Changed;
  end;
end;

procedure TAdvSmoothCalendar.SetAnimation(const Value: Boolean);
begin
  if FAnimation <> value then
  begin
    FAnimation := Value;
    Changed;
  end;
end;

procedure TAdvSmoothCalendar.SetComponentStyle(AStyle: TTMSStyle);
begin
  // TODO : do color settings here
 case AStyle of
    tsOffice2003Blue:
      begin
        Fill.Color := $00FFD2AF;
        Fill.ColorTo := $00FFD2AF;
        Fill.BorderColor := clNone;

        Header.Fill.Color := $D68759;
        Header.Fill.ColorTo := $933803;
        Header.Font.Color := clWhite;
        Header.Fill.BorderColor := $962D00;

        Footer.Fill.Color := $D68759;
        Footer.Fill.ColorTo := $933803;
        Footer.Font.Color := clWhite;
        Footer.Fill.BorderColor := $962D00;

        DateAppearance.DayOfWeekFill.Color := RGB(196, 218, 250);
        DateAppearance.DayOfWeekFill.ColorTo := RGB(215, 232, 253);
        DateAppearance.DayOfWeekFill.BorderColor := Fill.BorderColor;

        DateAppearance.WeekNumbers.Fill.Color := DateAppearance.DayOfWeekFill.Color;
        DateAppearance.WeekNumbers.Fill.ColorTo := DateAppearance.DayOfWeekFill.ColorTo;
        DateAppearance.WeekNumbers.Fill.BorderColor := DateAppearance.DayOfWeekFill.BorderColor;

        DateAppearance.DateFill.Color := $EEDBC8;
        DateAppearance.DateFill.ColorTo := $F6DDC9;
        DateAppearance.DateFill.ColorMirror := $EDD4C0;
        DateAppearance.DateFill.ColorMirrorTo := $F7E1D0;
        //DateAppearance.DateFill.BorderColor := $E0B99B;
        DateAppearance.DateFill.BorderColor := clNone;
        DateAppearance.DateFill.GradientMirrorType := gtVertical;

        DateAppearance.WeekendFill.Color := $EEDBC8;
        DateAppearance.WeekendFill.ColorTo := $F6DDC9;
        DateAppearance.WeekendFill.ColorMirror := $EDD4C0;
        DateAppearance.WeekendFill.ColorMirrorTo := $F7E1D0;
        //DateAppearance.DateFill.BorderColor := $E0B99B;
        DateAppearance.WeekendFill.BorderColor := clNone;
        DateAppearance.WeekendFill.GradientMirrorType := gtVertical;

        DateAppearance.HoverDateFill.Color := $EBFDFF;
        DateAppearance.HoverDateFill.ColorTo := $ACECFF;
        DateAppearance.HoverDateFill.ColorMirror := $59DAFF;
        DateAppearance.HoverDateFill.ColorMirrorTo := $A4E9FF;
        DateAppearance.HoverDateFill.BorderColor :=  $99CEDB;
        DateAppearance.HoverDateFill.GradientMirrorType := gtVertical;

        DateAppearance.SelectedDateFill.Color := $AAD9FF;
        DateAppearance.SelectedDateFill.ColorTo := $6EBBFF;
        DateAppearance.SelectedDateFill.ColorMirror := $42AEFE;
        DateAppearance.SelectedDateFill.ColorMirrorTo := $7AE1FE;
        DateAppearance.SelectedDateFill.BorderColor := $42AEFE;
        DateAppearance.SelectedDateFill.GradientMirrorType := gtVertical;

        DateAppearance.DisabledDateFill.Color := $00F2F2F2;
        DateAppearance.DisabledDateFill.ColorTo := $00B6B6B6;
        DateAppearance.DisabledDateFill.ColorMirror := clNone;
        DateAppearance.DisabledDateFill.ColorMirrorTo := clNone;
        DateAppearance.DisabledDateFont.Color := clGray;
//        DateAppearance.DisabledDateFill.BorderColor := $962D00;
        DateAppearance.DisabledDateFill.GradientMirrorType := gtVertical;

        DateAppearance.CurrentDateFill.Color := $76AFF1;
        DateAppearance.CurrentDateFill.ColorTo := $4190F3;
        DateAppearance.CurrentDateFill.ColorMirror := $0E72F1;
        DateAppearance.CurrentDateFill.ColorMirrorTo := $4C9FFD;
        DateAppearance.CurrentDateFill.BorderColor := $45667B;
        DateAppearance.CurrentDateFill.GradientMirrorType := gtVertical;

      end;
    tsOffice2003Silver:
      begin
        Fill.Color := $00E6D8D8;
        Fill.ColorTo := $00E6D8D8;
        Fill.BorderColor := clNone;

        Header.Fill.Color := $BDA4A5;
        Header.Fill.ColorTo := $957475;
        Header.Font.Color := clWhite;
        Header.Fill.BorderColor := $947C7C;

        Footer.Fill.Color := $BDA4A5;
        Footer.Fill.ColorTo := $957475;
        Footer.Font.Color := clWhite;
        Footer.Fill.BorderColor := $947C7C;

        DateAppearance.DayOfWeekFill.Color := RGB(222, 222, 235);
        DateAppearance.DayOfWeekFill.ColorTo := RGB(239, 239, 244);
        DateAppearance.DayOfWeekFill.BorderColor := Fill.BorderColor;

        DateAppearance.WeekNumbers.Fill.Color := DateAppearance.DayOfWeekFill.Color;
        DateAppearance.WeekNumbers.Fill.ColorTo := DateAppearance.DayOfWeekFill.ColorTo;
        DateAppearance.WeekNumbers.Fill.BorderColor := DateAppearance.DayOfWeekFill.BorderColor;

        DateAppearance.DateFill.Color := $E6E9E2;
        DateAppearance.DateFill.ColorTo := $00E6D8D8;
        DateAppearance.DateFill.ColorMirror := $C8B2B3;
        DateAppearance.DateFill.ColorMirrorTo := $E6E9E2;
        //DateAppearance.DateFill.BorderColor := $927476;
        DateAppearance.DateFill.BorderColor := clNone;
        DateAppearance.DateFill.GradientMirrorType := gtVertical;

        DateAppearance.WeekendFill.Color := $E6E9E2;
        DateAppearance.WeekendFill.ColorTo := $00E6D8D8;
        DateAppearance.WeekendFill.ColorMirror := $C8B2B3;
        DateAppearance.WeekendFill.ColorMirrorTo := $E6E9E2;
        //DateAppearance.DateFill.BorderColor := $927476;
        DateAppearance.WeekendFill.BorderColor := clNone;
        DateAppearance.WeekendFill.GradientMirrorType := gtVertical;

        DateAppearance.HoverDateFill.Color := $EBFDFF;
        DateAppearance.HoverDateFill.ColorTo := $ACECFF;
        DateAppearance.HoverDateFill.ColorMirror := $59DAFF;
        DateAppearance.HoverDateFill.ColorMirrorTo := $A4E9FF;
        DateAppearance.HoverDateFill.BorderColor :=  $99CEDB;
        DateAppearance.HoverDateFill.GradientMirrorType := gtVertical;

        DateAppearance.DisabledDateFill.Color := $00F2F2F2;
        DateAppearance.DisabledDateFill.ColorTo := $00B6B6B6;
        DateAppearance.DisabledDateFill.ColorMirror := clNone;
        DateAppearance.DisabledDateFill.ColorMirrorTo := clNone;
        DateAppearance.DisabledDateFont.Color := clGray;
//        DateAppearance.DisabledDateFill.BorderColor := $947C7C;
        DateAppearance.DisabledDateFill.GradientMirrorType := gtVertical;

        DateAppearance.SelectedDateFill.Color := $AAD9FF;
        DateAppearance.SelectedDateFill.ColorTo := $6EBBFF;
        DateAppearance.SelectedDateFill.ColorMirror := $42AEFE;
        DateAppearance.SelectedDateFill.ColorMirrorTo := $7AE1FE;
        DateAppearance.SelectedDateFill.BorderColor := $42AEFE;
        DateAppearance.SelectedDateFill.GradientMirrorType := gtVertical;

        DateAppearance.CurrentDateFill.Color := $76AFF1;
        DateAppearance.CurrentDateFill.ColorTo := $4190F3;
        DateAppearance.CurrentDateFill.ColorMirror := $0E72F1;
        DateAppearance.CurrentDateFill.ColorMirrorTo := $4C9FFD;
        DateAppearance.CurrentDateFill.BorderColor := $45667B;
        DateAppearance.CurrentDateFill.GradientMirrorType := gtVertical;
      end;
    tsOffice2003Olive:
      begin
        Fill.Color := RGB(225, 234, 185);
        Fill.ColorTo := RGB(225, 234, 185);
        Fill.BorderColor := clNone;

        Header.Fill.Color := $82C0AF;
        Header.Fill.ColorTo := $447A63;
        Header.Font.Color := clWhite;
        Header.Fill.BorderColor := $588060;

        Footer.Fill.Color := $82C0AF;
        Footer.Fill.ColorTo := $447A63;
        Footer.Font.Color := clWhite;
        Footer.Fill.BorderColor := $588060;

        DateAppearance.DayOfWeekFill.Color := $CFF0EA;
        DateAppearance.DayOfWeekFill.ColorTo := RGB(225, 234, 185);
        DateAppearance.DayOfWeekFill.BorderColor := Fill.BorderColor;

        DateAppearance.WeekNumbers.Fill.Color := DateAppearance.DayOfWeekFill.Color;
        DateAppearance.WeekNumbers.Fill.ColorTo := DateAppearance.DayOfWeekFill.ColorTo;
        DateAppearance.WeekNumbers.Fill.BorderColor := DateAppearance.DayOfWeekFill.BorderColor;

        DateAppearance.DateFill.Color := $CFF0EA;
        DateAppearance.DateFill.ColorTo := $CFF0EA;
        DateAppearance.DateFill.ColorMirror := $8CC0B1;
        DateAppearance.DateFill.ColorMirrorTo := $CFF0EA;
//        DateAppearance.DateFill.BorderColor := $8CC0B1;
        DateAppearance.DateFill.BorderColor := clNone;
        DateAppearance.DateFill.GradientMirrorType := gtVertical;

        DateAppearance.WeekendFill.Color := $CFF0EA;
        DateAppearance.WeekendFill.ColorTo := $CFF0EA;
        DateAppearance.WeekendFill.ColorMirror := $8CC0B1;
        DateAppearance.WeekendFill.ColorMirrorTo := $CFF0EA;
//        DateAppearance.DateFill.BorderColor := $8CC0B1;
        DateAppearance.WeekendFill.BorderColor := clNone;
        DateAppearance.WeekendFill.GradientMirrorType := gtVertical;

        DateAppearance.DisabledDateFill.Color := $00F2F2F2;
        DateAppearance.DisabledDateFill.ColorTo := $00B6B6B6;
        DateAppearance.DisabledDateFill.ColorMirror := clNone;
        DateAppearance.DisabledDateFill.ColorMirrorTo := clNone;
        DateAppearance.DisabledDateFont.Color := clGray;
//        DateAppearance.DisabledDateFill.BorderColor := $588060;
        DateAppearance.DisabledDateFill.GradientMirrorType := gtVertical;

        DateAppearance.HoverDateFill.Color := $EBFDFF;
        DateAppearance.HoverDateFill.ColorTo := $ACECFF;
        DateAppearance.HoverDateFill.ColorMirror := $59DAFF;
        DateAppearance.HoverDateFill.ColorMirrorTo := $A4E9FF;
        DateAppearance.HoverDateFill.BorderColor :=  $99CEDB;
        DateAppearance.HoverDateFill.GradientMirrorType := gtVertical;

        DateAppearance.SelectedDateFill.Color := $AAD9FF;
        DateAppearance.SelectedDateFill.ColorTo := $6EBBFF;
        DateAppearance.SelectedDateFill.ColorMirror := $42AEFE;
        DateAppearance.SelectedDateFill.ColorMirrorTo := $7AE1FE;
        DateAppearance.SelectedDateFill.BorderColor := $42AEFE;
        DateAppearance.SelectedDateFill.GradientMirrorType := gtVertical;

        DateAppearance.CurrentDateFill.Color := $76AFF1;
        DateAppearance.CurrentDateFill.ColorTo := $4190F3;
        DateAppearance.CurrentDateFill.ColorMirror := $0E72F1;
        DateAppearance.CurrentDateFill.ColorMirrorTo := $4C9FFD;
        DateAppearance.CurrentDateFill.BorderColor := $45667B;
        DateAppearance.CurrentDateFill.GradientMirrorType := gtVertical;
      end;
    tsOffice2003Classic:
      begin
        Fill.Color := $00F2F2F2;
        Fill.ColorTo := $00F2F2F2;
        Fill.BorderColor := clNone;

        Header.Fill.Color := $808080;
        Header.Fill.ColorTo := $808080;
        Header.Font.Color := clWhite;
        Header.Fill.BorderColor := $808080;

        Footer.Fill.Color := $808080;
        Footer.Fill.ColorTo := $808080;
        Footer.Font.Color := clWhite;
        Footer.Fill.BorderColor := $808080;

        DateAppearance.DayOfWeekFill.Color := RGB(230, 227, 223);
        DateAppearance.DayOfWeekFill.ColorTo := RGB(214, 210, 202);
        DateAppearance.DayOfWeekFill.BorderColor := Fill.BorderColor;

        DateAppearance.WeekNumbers.Fill.Color := DateAppearance.DayOfWeekFill.Color;
        DateAppearance.WeekNumbers.Fill.ColorTo := DateAppearance.DayOfWeekFill.ColorTo;
        DateAppearance.WeekNumbers.Fill.BorderColor := DateAppearance.DayOfWeekFill.BorderColor;

        DateAppearance.DateFill.Color := clWhite;
        DateAppearance.DateFill.ColorTo := $C9D1D5;
        DateAppearance.DateFill.ColorMirror := clNone;
        DateAppearance.DateFill.ColorMirrorTo := clNone;
//        DateAppearance.DateFill.BorderColor := $8CC0B1;
        DateAppearance.DateFill.BorderColor := clNone;
        DateAppearance.DateFill.GradientMirrorType := gtVertical;

        DateAppearance.WeekendFill.Color := clWhite;
        DateAppearance.WeekendFill.ColorTo := $C9D1D5;
        DateAppearance.WeekendFill.ColorMirror := clNone;
        DateAppearance.WeekendFill.ColorMirrorTo := clNone;
//        DateAppearance.DateFill.BorderColor := $8CC0B1;
        DateAppearance.WeekendFill.BorderColor := clNone;
        DateAppearance.WeekendFill.GradientMirrorType := gtVertical;

        DateAppearance.HoverDateFill.Color := $D2BDB6;
        DateAppearance.HoverDateFill.ColorTo := $D2BDB6;
        DateAppearance.HoverDateFill.ColorMirror := clNone;
        DateAppearance.HoverDateFill.ColorMirrorTo := clNone;
        DateAppearance.HoverDateFill.BorderColor := $808080;
        DateAppearance.HoverDateFill.GradientMirrorType := gtVertical;

        DateAppearance.DisabledDateFill.Color := $D8D5D4;
        DateAppearance.DisabledDateFill.ColorTo := $D8D5D4;
        DateAppearance.DisabledDateFill.ColorMirror := clNone;
        DateAppearance.DisabledDateFill.ColorMirrorTo := clNone;
        DateAppearance.DisabledDateFont.Color := clGray;
//        DateAppearance.DisabledDateFill.BorderColor := $808080;
        DateAppearance.DisabledDateFill.GradientMirrorType := gtVertical;

        DateAppearance.SelectedDateFill.Color := $B59285;
        DateAppearance.SelectedDateFill.ColorTo := $B59285;
        DateAppearance.SelectedDateFill.ColorMirror := clNone;
        DateAppearance.SelectedDateFill.ColorMirrorTo := clNone;
        DateAppearance.SelectedDateFill.BorderColor := $808080;
        DateAppearance.SelectedDateFill.GradientMirrorType := gtVertical;

        DateAppearance.CurrentDateFill.Color := $D8D5D4;
        DateAppearance.CurrentDateFill.ColorTo := $D8D5D4;
        DateAppearance.CurrentDateFill.ColorMirror := clNone;
        DateAppearance.CurrentDateFill.ColorMirrorTo := clNone;
        DateAppearance.CurrentDateFill.BorderColor := $808080;
        DateAppearance.CurrentDateFill.GradientMirrorType := gtVertical;
      end;
    tsOffice2007Luna:
      begin
        Fill.Color := $00F3E5DA;
        Fill.ColorTo := $00F0DED0;
        Fill.BorderColor := clNone;

        Header.Fill.Color := $FFEFE3;
        Header.Fill.ColorTo := $FFD2AF;
        Header.Font.Color := $723708;
        Header.Fill.BorderColor := $00FFD2AF;

        Footer.Fill.Color := $FFEFE3;
        Footer.Fill.ColorTo := $FFD2AF;
        Footer.Font.Color := $723708;
        Footer.Fill.BorderColor := $00FFD2AF;

        DateAppearance.DayOfWeekFill.Color := Fill.Color;
        DateAppearance.DayOfWeekFill.ColorTo := Fill.ColorTo;
        DateAppearance.DayOfWeekFill.BorderColor := Fill.BorderColor;

        DateAppearance.WeekNumbers.Fill.Color := DateAppearance.DayOfWeekFill.Color;
        DateAppearance.WeekNumbers.Fill.ColorTo := DateAppearance.DayOfWeekFill.ColorTo;
        DateAppearance.WeekNumbers.Fill.BorderColor := DateAppearance.DayOfWeekFill.BorderColor;

        DateAppearance.DateFill.Color := $FFEFE3;
        DateAppearance.DateFill.ColorTo := $FFDDC4;
        DateAppearance.DateFill.ColorMirror := $FFD1AD;
        DateAppearance.DateFill.ColorMirrorTo := $FFDBC0;
//        DateAppearance.DateFill.BorderColor := $FFD1AD;
        DateAppearance.DateFill.BorderColor := clNone;
        DateAppearance.DateFill.GradientMirrorType := gtVertical;

        DateAppearance.WeekendFill.Color := $FFEFE3;
        DateAppearance.WeekendFill.ColorTo := $FFDDC4;
        DateAppearance.WeekendFill.ColorMirror := $FFD1AD;
        DateAppearance.WeekendFill.ColorMirrorTo := $FFDBC0;
//        DateAppearance.DateFill.BorderColor := $FFD1AD;
        DateAppearance.WeekendFill.BorderColor := clNone;
        DateAppearance.WeekendFill.GradientMirrorType := gtVertical;

        DateAppearance.HoverDateFill.Color := $EBFDFF;
        DateAppearance.HoverDateFill.ColorTo := $ACECFF;
        DateAppearance.HoverDateFill.ColorMirror := $59DAFF;
        DateAppearance.HoverDateFill.ColorMirrorTo := $A4E9FF;
        DateAppearance.HoverDateFill.BorderColor :=  $99CEDB;
        DateAppearance.HoverDateFill.GradientMirrorType := gtVertical;

        DateAppearance.DisabledDateFill.Color := $00F2F2F2;
        DateAppearance.DisabledDateFill.ColorTo := $00B6B6B6;
        DateAppearance.DisabledDateFill.ColorMirror := $00B6B6B6;
        DateAppearance.DisabledDateFill.ColorMirrorTo := $00F2F2F2;
        DateAppearance.DisabledDateFont.Color := clGray;
//        DateAppearance.DisabledDateFill.BorderColor := $FFD1AD;//$00B6B6B6;
        DateAppearance.DisabledDateFill.GradientMirrorType := gtVertical;

        DateAppearance.SelectedDateFill.Color := $AAD9FF;
        DateAppearance.SelectedDateFill.ColorTo := $6EBBFF;
        DateAppearance.SelectedDateFill.ColorMirror := $42AEFE;
        DateAppearance.SelectedDateFill.ColorMirrorTo := $7AE1FE;
        DateAppearance.SelectedDateFill.BorderColor := $42AEFE;
        DateAppearance.SelectedDateFill.GradientMirrorType := gtVertical;

        DateAppearance.CurrentDateFill.Color := $76AFF1;
        DateAppearance.CurrentDateFill.ColorTo := $4190F3;
        DateAppearance.CurrentDateFill.ColorMirror := $0E72F1;
        DateAppearance.CurrentDateFill.ColorMirrorTo := $4C9FFD;
        DateAppearance.CurrentDateFill.BorderColor := $45667B;
        DateAppearance.CurrentDateFill.GradientMirrorType := gtVertical;

      end;
    tsOffice2007Obsidian:
      begin
        Fill.Color := $5C534C;
        Fill.ColorTo := $5C534C;
        Fill.BorderColor := clNone;

        Header.Fill.Color := $F2F1F0;
        Header.Fill.ColorTo := $C9C2BD;
        Header.Font.Color := $433C37;
        Header.Fill.BorderColor := $5C534C;

        Footer.Fill.Color := $F2F1F0;
        Footer.Fill.ColorTo := $C9C2BD;
        Footer.Font.Color := $433C37;
        Footer.Fill.BorderColor := $5C534C;

        DateAppearance.DayOfWeekFill.Color := RGB(215, 219, 224);
        DateAppearance.DayOfWeekFill.ColorTo := RGB(194, 199, 207);
        DateAppearance.DayOfWeekFill.BorderColor := Fill.BorderColor;

        DateAppearance.WeekNumbers.Fill.Color := DateAppearance.DayOfWeekFill.Color;
        DateAppearance.WeekNumbers.Fill.ColorTo := DateAppearance.DayOfWeekFill.ColorTo;
        DateAppearance.WeekNumbers.Fill.BorderColor := DateAppearance.DayOfWeekFill.BorderColor;

        DateAppearance.DateFill.Color := $F9F8F8;
        DateAppearance.DateFill.ColorTo := $E4E2DF;
        DateAppearance.DateFill.ColorMirror := $D1CBC7;
        DateAppearance.DateFill.ColorMirrorTo := $E2DEDB;
//        DateAppearance.DateFill.BorderColor := $D1CBC7;
        DateAppearance.DateFill.BorderColor := clNone;
        DateAppearance.DateFill.GradientMirrorType := gtVertical;

        DateAppearance.WeekendFill.Color := $F9F8F8;
        DateAppearance.WeekendFill.ColorTo := $E4E2DF;
        DateAppearance.WeekendFill.ColorMirror := $D1CBC7;
        DateAppearance.WeekendFill.ColorMirrorTo := $E2DEDB;
//        DateAppearance.DateFill.BorderColor := $D1CBC7;
        DateAppearance.WeekendFill.BorderColor := clNone;
        DateAppearance.WeekendFill.GradientMirrorType := gtVertical;

        DateAppearance.HoverDateFill.Color := $EBFDFF;
        DateAppearance.HoverDateFill.ColorTo := $ACECFF;
        DateAppearance.HoverDateFill.ColorMirror := $59DAFF;
        DateAppearance.HoverDateFill.ColorMirrorTo := $A4E9FF;
        DateAppearance.HoverDateFill.BorderColor :=  $99CEDB;
        DateAppearance.HoverDateFill.GradientMirrorType := gtVertical;

        DateAppearance.DisabledDateFill.Color := $00F2F2F2;
        DateAppearance.DisabledDateFill.ColorTo := $00B6B6B6;
        DateAppearance.DisabledDateFill.ColorMirror := $00B6B6B6;
        DateAppearance.DisabledDateFill.ColorMirrorTo := $00F2F2F2;
        DateAppearance.DisabledDateFont.Color := clGray;
//        DateAppearance.DisabledDateFill.BorderColor := clBlack;//$00B6B6B6;
        DateAppearance.DisabledDateFill.GradientMirrorType := gtVertical;

        DateAppearance.SelectedDateFill.Color := $AAD9FF;
        DateAppearance.SelectedDateFill.ColorTo := $6EBBFF;
        DateAppearance.SelectedDateFill.ColorMirror := $42AEFE;
        DateAppearance.SelectedDateFill.ColorMirrorTo := $7AE1FE;
        DateAppearance.SelectedDateFill.BorderColor := $42AEFE;
        DateAppearance.SelectedDateFill.GradientMirrorType := gtVertical;

        DateAppearance.CurrentDateFill.Color := $76AFF1;
        DateAppearance.CurrentDateFill.ColorTo := $4190F3;
        DateAppearance.CurrentDateFill.ColorMirror := $0E72F1;
        DateAppearance.CurrentDateFill.ColorMirrorTo := $4C9FFD;
        DateAppearance.CurrentDateFill.BorderColor := $45667B;
        DateAppearance.CurrentDateFill.GradientMirrorType := gtVertical;
      end;
    tsWindowsXP:
      begin
        Fill.Color := $00B6B6B6;
        Fill.ColorTo := $00B6B6B6;

        Header.Fill.Color := clBtnFace;
        Header.Fill.ColorTo := clBtnFace;
        Header.Font.Color := clBlack;
        Header.Fill.BorderColor := clBlack;

        Footer.Fill.Color := clBtnFace;
        Footer.Fill.ColorTo := clBtnFace;
        Footer.Font.Color := clBlack;
        Footer.Fill.BorderColor := clBlack;

        DateAppearance.DayOfWeekFill.Color := clBtnFace;
        DateAppearance.DayOfWeekFill.ColorTo := clBtnFace;
        DateAppearance.DayOfWeekFill.BorderColor := Fill.BorderColor;

        DateAppearance.WeekNumbers.Fill.Color := DateAppearance.DayOfWeekFill.Color;
        DateAppearance.WeekNumbers.Fill.ColorTo := DateAppearance.DayOfWeekFill.ColorTo;
        DateAppearance.WeekNumbers.Fill.BorderColor := DateAppearance.DayOfWeekFill.BorderColor;

        DateAppearance.DateFill.Color := clBtnFace;//clWhite;
        DateAppearance.DateFill.ColorTo := clBtnFace;//$B9D8DC;
        DateAppearance.DateFill.ColorMirror := clNone;
        DateAppearance.DateFill.ColorMirrorTo := clNone;
//        DateAppearance.DateFill.BorderColor := $B9D8DC;
        DateAppearance.DateFill.BorderColor := clNone;
        DateAppearance.DateFill.GradientMirrorType := gtVertical;

        DateAppearance.WeekendFill.Color := clBtnFace;//clWhite;
        DateAppearance.WeekendFill.ColorTo := clBtnFace;//$B9D8DC;
        DateAppearance.WeekendFill.ColorMirror := clNone;
        DateAppearance.WeekendFill.ColorMirrorTo := clNone;
//        DateAppearance.DateFill.BorderColor := $B9D8DC;
        DateAppearance.WeekendFill.BorderColor := clNone;
        DateAppearance.WeekendFill.GradientMirrorType := gtVertical;

        DateAppearance.DisabledDateFill.Color := $00B6B6B6;
        DateAppearance.DisabledDateFill.ColorTo := $00B6B6B6;
        DateAppearance.DisabledDateFill.ColorMirror := clNone;
        DateAppearance.DisabledDateFill.ColorMirrorTo := clNone;
        DateAppearance.DisabledDateFont.Color := clGray;
//        DateAppearance.DisabledDateFill.BorderColor := clBlack;
        DateAppearance.DisabledDateFill.GradientMirrorType := gtVertical;

        DateAppearance.HoverDateFill.Color := $EFD3C6;
        DateAppearance.HoverDateFill.ColorTo := $EFD3C6;
        DateAppearance.HoverDateFill.ColorMirror := clNone;
        DateAppearance.HoverDateFill.ColorMirrorTo := clNone;
        DateAppearance.HoverDateFill.BorderColor :=  clHighlight;
        DateAppearance.HoverDateFill.GradientMirrorType := gtVertical;

        DateAppearance.SelectedDateFill.Color := clInactiveCaption;
        DateAppearance.SelectedDateFill.ColorTo := clInactiveCaption;
        DateAppearance.SelectedDateFill.ColorMirror := clNone;
        DateAppearance.SelectedDateFill.ColorMirrorTo := clNone;
        DateAppearance.SelectedDateFill.BorderColor := clHighLight;
        DateAppearance.SelectedDateFill.GradientMirrorType := gtVertical;

        DateAppearance.CurrentDateFill.Color := $B9D8DC;
        DateAppearance.CurrentDateFill.ColorTo := $B9D8DC;
        DateAppearance.CurrentDateFill.ColorMirror := clNone;
        DateAppearance.CurrentDateFill.ColorMirrorTo := clNone;
        DateAppearance.CurrentDateFill.BorderColor := clBlack;
        DateAppearance.CurrentDateFill.GradientMirrorType := gtVertical;
      end;
    tsWhidbey:
      begin
        Fill.Color := $F5F9FA;
        Fill.ColorTo := $F5F9FA;
        Fill.BorderColor := clNone;

        Header.Fill.Color := $EBEEEF;
        Header.Fill.ColorTo := $7E9898;
        Header.Font.Color := clWhite;
        Header.Fill.BorderColor := $962D00;

        Footer.Fill.Color := $EBEEEF;
        Footer.Fill.ColorTo := $7E9898;
        Footer.Font.Color := clWhite;
        Footer.Fill.BorderColor := $962D00;

        DateAppearance.DayOfWeekFill.Color := RGB(232, 230, 210);
        DateAppearance.DayOfWeekFill.ColorTo := RGB(224, 221, 197);
        DateAppearance.DayOfWeekFill.BorderColor := Fill.BorderColor;

        DateAppearance.WeekNumbers.Fill.Color := DateAppearance.DayOfWeekFill.Color;
        DateAppearance.WeekNumbers.Fill.ColorTo := DateAppearance.DayOfWeekFill.ColorTo;
        DateAppearance.WeekNumbers.Fill.BorderColor := DateAppearance.DayOfWeekFill.BorderColor;

        DateAppearance.DateFill.Color := clWhite;
        DateAppearance.DateFill.ColorTo := $DFEDF0;
        DateAppearance.DateFill.ColorMirror := $DFEDF0;
        DateAppearance.DateFill.ColorMirrorTo := $DFEDF0;
        //DateAppearance.DateFill.BorderColor := $99A8AC;
        DateAppearance.DateFill.BorderColor := clNone;
        DateAppearance.DateFill.GradientMirrorType := gtVertical;

        DateAppearance.WeekendFill.Color := clWhite;
        DateAppearance.WeekendFill.ColorTo := $DFEDF0;
        DateAppearance.WeekendFill.ColorMirror := $DFEDF0;
        DateAppearance.WeekendFill.ColorMirrorTo := $DFEDF0;
        //DateAppearance.DateFill.BorderColor := $99A8AC;
        DateAppearance.WeekendFill.BorderColor := clNone;
        DateAppearance.WeekendFill.GradientMirrorType := gtVertical;

        DateAppearance.DisabledDateFill.Color := $00F2F2F2;
        DateAppearance.DisabledDateFill.ColorTo := $00B6B6B6;
        DateAppearance.DisabledDateFill.ColorMirror := clNone;
        DateAppearance.DisabledDateFill.ColorMirrorTo := clNone;
        DateAppearance.DisabledDateFont.Color := clGray;
//        DateAppearance.DisabledDateFill.BorderColor := $962D00;
        DateAppearance.DisabledDateFill.GradientMirrorType := gtVertical;

        DateAppearance.HoverDateFill.Color := $EBFDFF;
        DateAppearance.HoverDateFill.ColorTo := $ACECFF;
        DateAppearance.HoverDateFill.ColorMirror := $59DAFF;
        DateAppearance.HoverDateFill.ColorMirrorTo := $A4E9FF;
        DateAppearance.HoverDateFill.BorderColor :=  $99CEDB;
        DateAppearance.HoverDateFill.GradientMirrorType := gtVertical;

        DateAppearance.SelectedDateFill.Color := $AAD9FF;
        DateAppearance.SelectedDateFill.ColorTo := $6EBBFF;
        DateAppearance.SelectedDateFill.ColorMirror := $42AEFE;
        DateAppearance.SelectedDateFill.ColorMirrorTo := $7AE1FE;
        DateAppearance.SelectedDateFill.BorderColor := $42AEFE;
        DateAppearance.SelectedDateFill.GradientMirrorType := gtVertical;

        DateAppearance.CurrentDateFill.Color := $76AFF1;
        DateAppearance.CurrentDateFill.ColorTo := $4190F3;
        DateAppearance.CurrentDateFill.ColorMirror := $0E72F1;
        DateAppearance.CurrentDateFill.ColorMirrorTo := $4C9FFD;
        DateAppearance.CurrentDateFill.BorderColor := $45667B;
        DateAppearance.CurrentDateFill.GradientMirrorType := gtVertical;
      end;
    tsCustom: ;
    tsOffice2007Silver:
      begin
        Fill.Color := RGB(241, 244, 248);
        Fill.ColorTo := RGB(227, 232, 240);
        Fill.BorderColor := clNone;

        Header.Fill.Color := $F8F7F6;
        Header.Fill.ColorTo := $E8E0DB;
        Header.Font.Color := $8B4215;
        Header.Fill.BorderColor := $74706F;

        Footer.Fill.Color := $F8F7F6;
        Footer.Fill.ColorTo := $E8E0DB;
        Footer.Font.Color := $8B4215;
        Footer.Fill.BorderColor := $74706F;

        DateAppearance.DayOfWeekFill.Color := RGB(241, 244, 248);
        DateAppearance.DayOfWeekFill.ColorTo := RGB(227, 232, 240);
        DateAppearance.DayOfWeekFill.BorderColor := Fill.BorderColor;

        DateAppearance.WeekNumbers.Fill.Color := DateAppearance.DayOfWeekFill.Color;
        DateAppearance.WeekNumbers.Fill.ColorTo := DateAppearance.DayOfWeekFill.ColorTo;
        DateAppearance.WeekNumbers.Fill.BorderColor := DateAppearance.DayOfWeekFill.BorderColor;

        DateAppearance.DateFill.Color := $F9F8F8;
        DateAppearance.DateFill.ColorTo := $E4E2DF;
        DateAppearance.DateFill.ColorMirror := $D1CBC7;
        DateAppearance.DateFill.ColorMirrorTo := $E2DEDB;
        //DateAppearance.DateFill.BorderColor := $D1CBC7;
        DateAppearance.DateFill.BorderColor := clNone;
        DateAppearance.DateFill.GradientMirrorType := gtVertical;

        DateAppearance.WeekendFill.Color := $F9F8F8;
        DateAppearance.WeekendFill.ColorTo := $E4E2DF;
        DateAppearance.WeekendFill.ColorMirror := $D1CBC7;
        DateAppearance.WeekendFill.ColorMirrorTo := $E2DEDB;
        //DateAppearance.DateFill.BorderColor := $D1CBC7;
        DateAppearance.WeekendFill.BorderColor := clNone;
        DateAppearance.WeekendFill.GradientMirrorType := gtVertical;

        DateAppearance.HoverDateFill.Color := $EBFDFF;
        DateAppearance.HoverDateFill.ColorTo := $ACECFF;
        DateAppearance.HoverDateFill.ColorMirror := $59DAFF;
        DateAppearance.HoverDateFill.ColorMirrorTo := $A4E9FF;
        DateAppearance.HoverDateFill.BorderColor :=  $99CEDB;
        DateAppearance.HoverDateFill.GradientMirrorType := gtVertical;

        DateAppearance.SelectedDateFill.Color := $AAD9FF;
        DateAppearance.SelectedDateFill.ColorTo := $6EBBFF;
        DateAppearance.SelectedDateFill.ColorMirror := $42AEFE;
        DateAppearance.SelectedDateFill.ColorMirrorTo := $7AE1FE;
        DateAppearance.SelectedDateFill.BorderColor := $42AEFE;
        DateAppearance.SelectedDateFill.GradientMirrorType := gtVertical;

        DateAppearance.DisabledDateFill.Color := $00F2F2F2;
        DateAppearance.DisabledDateFill.ColorTo := $00B6B6B6;
        DateAppearance.DisabledDateFill.ColorMirror := $00B6B6B6;
        DateAppearance.DisabledDateFill.ColorMirrorTo := $00F2F2F2;
        DateAppearance.DisabledDateFont.Color := clGray;
//        DateAppearance.DisabledDateFill.BorderColor := clBlack;//$00B6B6B6;
        DateAppearance.DisabledDateFill.GradientMirrorType := gtVertical;

        DateAppearance.CurrentDateFill.Color := $76AFF1;
        DateAppearance.CurrentDateFill.ColorTo := $4190F3;
        DateAppearance.CurrentDateFill.ColorMirror := $0E72F1;
        DateAppearance.CurrentDateFill.ColorMirrorTo := $4C9FFD;
        DateAppearance.CurrentDateFill.BorderColor := $45667B;
        DateAppearance.CurrentDateFill.GradientMirrorType := gtVertical;
      end;
      tsWindowsVista:
      begin
        Fill.Color := RGB(255, 255, 255);
        Fill.ColorTo := RGB(255, 255, 255);
        Fill.BorderColor := RGB(151, 151, 151);

        Header.Fill.Color := $FFFFFF;
        Header.Fill.ColorTo := $FFFFFF;
        Header.Font.Color := clBlack;
        Header.Fill.BorderColor := clNone;

        Footer.Fill.Color := $FFFFFF;
        Footer.Fill.ColorTo := $FFFFFF;
        Footer.Font.Color := clBlack;
        Footer.Fill.BorderColor := clNone;

        DateAppearance.DayOfWeekFill.Color := $FFFFFF;
        DateAppearance.DayOfWeekFill.ColorTo := $FFFFFF;
        DateAppearance.DayOfWeekFill.BorderColor := Fill.BorderColor;

        DateAppearance.WeekNumbers.Fill.Color := DateAppearance.DayOfWeekFill.Color;
        DateAppearance.WeekNumbers.Fill.ColorTo := DateAppearance.DayOfWeekFill.ColorTo;
        DateAppearance.WeekNumbers.Fill.BorderColor := DateAppearance.DayOfWeekFill.BorderColor;

        DateAppearance.DateFill.Color := $FFFFFF;
        DateAppearance.DateFill.ColorTo := $FFFFFF;
        DateAppearance.DateFill.ColorMirror := $FFFFFF;
        DateAppearance.DateFill.ColorMirrorTo := $FFFFFF;
//        DateAppearance.DateFill.BorderColor := $8CC0B1;
        DateAppearance.DateFill.BorderColor := clNone;
        DateAppearance.DateFill.GradientMirrorType := gtVertical;

        DateAppearance.WeekendFill.Color := $FFFFFF;
        DateAppearance.WeekendFill.ColorTo := $FFFFFF;
        DateAppearance.WeekendFill.ColorMirror := $FFFFFF;
        DateAppearance.WeekendFill.ColorMirrorTo := $FFFFFF;
//        DateAppearance.DateFill.BorderColor := $8CC0B1;
        DateAppearance.WeekendFill.BorderColor := clNone;
        DateAppearance.WeekendFill.GradientMirrorType := gtVertical;

        DateAppearance.DisabledDateFill.Color := $FFFFFF;
        DateAppearance.DisabledDateFill.ColorTo := $FFFFFF;
        DateAppearance.DisabledDateFill.ColorMirror := clNone;
        DateAppearance.DisabledDateFill.ColorMirrorTo := clNone;
        DateAppearance.DisabledDateFont.Color := $646464;
//        DateAppearance.DisabledDateFill.BorderColor := $588060;
        DateAppearance.DisabledDateFill.GradientMirrorType := gtVertical;

        DateAppearance.HoverDateFill.Color := $FFFDF9;
        DateAppearance.HoverDateFill.ColorTo := $FFFAF0;
        DateAppearance.HoverDateFill.ColorMirror := clNone;
        DateAppearance.HoverDateFill.ColorMirrorTo := clNone;
        DateAppearance.HoverDateFill.BorderColor :=  $FCF2DA;
        DateAppearance.HoverDateFill.GradientMirrorType := gtVertical;
        DateAppearance.HoverDateFont.Color :=  $CC6600;


        DateAppearance.SelectedDateFill.Color := $FEF9F0;
        DateAppearance.SelectedDateFill.ColorTo := $FDF0D7;
        DateAppearance.SelectedDateFill.ColorMirror := clNone;
        DateAppearance.SelectedDateFill.ColorMirrorTo := clNone;
        DateAppearance.SelectedDateFill.BorderColor := $FEDF9A;
        DateAppearance.SelectedDateFill.GradientMirrorType := gtVertical;

        DateAppearance.CurrentDateFill.Color := $FEF9F0;
        DateAppearance.CurrentDateFill.ColorTo := $FDF0D7;
        DateAppearance.CurrentDateFill.ColorMirror := clNone;
        DateAppearance.CurrentDateFill.ColorMirrorTo := clNone;
        DateAppearance.CurrentDateFill.BorderColor := $FEDF9AB;
        DateAppearance.CurrentDateFill.GradientMirrorType := gtVertical;
      end;
      tsWindows7:
      begin
        Fill.Color := RGB(255, 255, 255);
        Fill.ColorTo := RGB(255, 255, 255);
        Fill.BorderColor := RGB(151, 151, 151);

        Header.Fill.Color := $FFFFFF;
        Header.Fill.ColorTo := $FFFFFF;
        Header.Font.Color := clBlack;
        Header.Fill.BorderColor := clNone;

        Footer.Fill.Color := $FFFFFF;
        Footer.Fill.ColorTo := $FFFFFF;
        Footer.Font.Color := clBlack;
        Footer.Fill.BorderColor := clNone;

        DateAppearance.DayOfWeekFill.Color := $FFFFFF;
        DateAppearance.DayOfWeekFill.ColorTo := $FFFFFF;
        DateAppearance.DayOfWeekFill.BorderColor := Fill.BorderColor;

        DateAppearance.WeekNumbers.Fill.Color := DateAppearance.DayOfWeekFill.Color;
        DateAppearance.WeekNumbers.Fill.ColorTo := DateAppearance.DayOfWeekFill.ColorTo;
        DateAppearance.WeekNumbers.Fill.BorderColor := DateAppearance.DayOfWeekFill.BorderColor;

        DateAppearance.DateFill.Color := $FFFFFF;
        DateAppearance.DateFill.ColorTo := $FFFFFF;
        DateAppearance.DateFill.ColorMirror := $FFFFFF;
        DateAppearance.DateFill.ColorMirrorTo := $FFFFFF;
//        DateAppearance.DateFill.BorderColor := $8CC0B1;
        DateAppearance.DateFill.BorderColor := clNone;
        DateAppearance.DateFill.GradientMirrorType := gtVertical;

        DateAppearance.WeekendFill.Color := $FFFFFF;
        DateAppearance.WeekendFill.ColorTo := $FFFFFF;
        DateAppearance.WeekendFill.ColorMirror := $FFFFFF;
        DateAppearance.WeekendFill.ColorMirrorTo := $FFFFFF;
//        DateAppearance.DateFill.BorderColor := $8CC0B1;
        DateAppearance.WeekendFill.BorderColor := clNone;
        DateAppearance.WeekendFill.GradientMirrorType := gtVertical;

        DateAppearance.DisabledDateFill.Color := $FFFFFF;
        DateAppearance.DisabledDateFill.ColorTo := $FFFFFF;
        DateAppearance.DisabledDateFill.ColorMirror := clNone;
        DateAppearance.DisabledDateFill.ColorMirrorTo := clNone;
        DateAppearance.DisabledDateFont.Color := $646464;
//        DateAppearance.DisabledDateFill.BorderColor := $588060;
        DateAppearance.DisabledDateFill.GradientMirrorType := gtVertical;

        DateAppearance.HoverDateFill.Color := $FDFBFA;
        DateAppearance.HoverDateFill.ColorTo := $FDF3EB;
        DateAppearance.HoverDateFill.ColorMirror := clNone;
        DateAppearance.HoverDateFill.ColorMirrorTo := clNone;
        DateAppearance.HoverDateFill.BorderColor :=  $FBD6B8;
        DateAppearance.HoverDateFill.GradientMirrorType := gtVertical;
        DateAppearance.HoverDateFont.Color :=  $CC6600;


        DateAppearance.SelectedDateFill.Color := $FCEBDC;
        DateAppearance.SelectedDateFill.ColorTo := $FCDBC1;
        DateAppearance.SelectedDateFill.ColorMirror := clNone;
        DateAppearance.SelectedDateFill.ColorMirrorTo := clNone;
        DateAppearance.SelectedDateFill.BorderColor := $CEA27D;
        DateAppearance.SelectedDateFill.GradientMirrorType := gtVertical;

        DateAppearance.CurrentDateFill.Color := $FEF9F0;
        DateAppearance.CurrentDateFill.ColorTo := $FCDBC1;
        DateAppearance.CurrentDateFill.ColorMirror := clNone;
        DateAppearance.CurrentDateFill.ColorMirrorTo := clNone;
        DateAppearance.CurrentDateFill.BorderColor := $CEA27D;
        DateAppearance.CurrentDateFill.GradientMirrorType := gtVertical;
      end;
      tsTerminal:
      begin
        Fill.Color := clBtnFace;
        Fill.ColorTo := clBtnFace;
        Fill.BorderColor := clGray;

        Header.Fill.Color := clBtnFace;
        Header.Fill.ColorTo := clBtnFace;
        Header.Font.Color := clBlack;
        Header.Fill.BorderColor := clNone;

        Footer.Fill.Color := clBtnFace;
        Footer.Fill.ColorTo := clBtnFace;
        Footer.Font.Color := clBlack;
        Footer.Fill.BorderColor := clNone;

        DateAppearance.DayOfWeekFill.Color := clBtnFace;
        DateAppearance.DayOfWeekFill.ColorTo := clBtnFace;
        DateAppearance.DayOfWeekFill.BorderColor := Fill.BorderColor;

        DateAppearance.WeekNumbers.Fill.Color := DateAppearance.DayOfWeekFill.Color;
        DateAppearance.WeekNumbers.Fill.ColorTo := DateAppearance.DayOfWeekFill.ColorTo;
        DateAppearance.WeekNumbers.Fill.BorderColor := DateAppearance.DayOfWeekFill.BorderColor;

        DateAppearance.DateFill.Color := clBtnFace;
        DateAppearance.DateFill.ColorTo := clBtnFace;
        DateAppearance.DateFill.ColorMirror := clNone;
        DateAppearance.DateFill.ColorMirrorTo := clNone;
        DateAppearance.DateFill.BorderColor := clNone;


        DateAppearance.WeekendFill.Color := clBtnFace;
        DateAppearance.WeekendFill.ColorTo := clBtnFace;
        DateAppearance.WeekendFill.ColorMirror := clNone;
        DateAppearance.WeekendFill.ColorMirrorTo := clNone;
        DateAppearance.WeekendFill.BorderColor := clNone;


        DateAppearance.DisabledDateFill.Color := clBtnFace;
        DateAppearance.DisabledDateFill.ColorTo := clBtnFace;
        DateAppearance.DisabledDateFill.ColorMirror := clNone;
        DateAppearance.DisabledDateFill.ColorMirrorTo := clNone;
        DateAppearance.DisabledDateFont.Color := clGray;


        DateAppearance.HoverDateFill.Color := clSilver;
        DateAppearance.HoverDateFill.ColorTo := clSilver;
        DateAppearance.HoverDateFill.ColorMirror := clNone;
        DateAppearance.HoverDateFill.ColorMirrorTo := clNone;
        DateAppearance.HoverDateFill.BorderColor :=  clGray;
        DateAppearance.HoverDateFont.Color :=  clBlack;


        DateAppearance.SelectedDateFill.Color := clHighLight;
        DateAppearance.SelectedDateFill.ColorTo := clHighLight;
        DateAppearance.SelectedDateFill.ColorMirror := clNone;
        DateAppearance.SelectedDateFill.ColorMirrorTo := clNone;
        DateAppearance.SelectedDateFill.BorderColor := clGray;
        DateAppearance.SelectedDateFont.Color := clWhite;

        DateAppearance.CurrentDateFill.Color := clBtnFace;
        DateAppearance.CurrentDateFill.ColorTo := clBtnFace;
        DateAppearance.CurrentDateFill.ColorMirror := clNone;
        DateAppearance.CurrentDateFill.ColorMirrorTo := clNone;
        DateAppearance.CurrentDateFill.BorderColor := clHighLight;

      end;
      tsOffice2010Blue:
      begin
        Fill.Color := $EDDBCD;
        Fill.ColorTo := clNone;
        Fill.BorderColor := clNone;

        Header.Fill.Color := $EDDBCD;
        Header.Fill.ColorTo := clNone;
        Header.Font.Color := $5B391E;
        Header.Fill.BorderColor := $EEDDCF;

        Footer.Fill.Color := $EDDBCD;
        Footer.Fill.ColorTo := clNone;
        Footer.Font.Color := $5B391E;
        Footer.Fill.BorderColor := $EEDDCF;

        DateAppearance.DayOfWeekFill.Color := $EDDBCD;
        DateAppearance.DayOfWeekFill.ColorTo := clNone;
        DateAppearance.DayOfWeekFill.BorderColor := $FFC69A;

        DateAppearance.WeekNumbers.Fill.Color := DateAppearance.DayOfWeekFill.Color;
        DateAppearance.WeekNumbers.Fill.ColorTo := DateAppearance.DayOfWeekFill.ColorTo;
        DateAppearance.WeekNumbers.Fill.BorderColor := DateAppearance.DayOfWeekFill.BorderColor;

        DateAppearance.DateFill.Color := $EDDBCD;
        DateAppearance.DateFill.ColorTo := clNone;
        DateAppearance.DateFill.ColorMirror := clNone;
        DateAppearance.DateFill.ColorMirrorTo := clNone;
//        DateAppearance.DateFill.BorderColor := $8CC0B1;
        DateAppearance.DateFill.BorderColor := clNone;
        DateAppearance.DateFill.GradientMirrorType := gtVertical;

        DateAppearance.WeekendFill.Color := $EDDBCD;
        DateAppearance.WeekendFill.ColorTo := clNone;
        DateAppearance.WeekendFill.ColorMirror := clNone;
        DateAppearance.WeekendFill.ColorMirrorTo := clNone;
//        DateAppearance.DateFill.BorderColor := $8CC0B1;
        DateAppearance.WeekendFill.BorderColor := clNone;
        DateAppearance.WeekendFill.GradientMirrorType := gtVertical;

        DateAppearance.DisabledDateFill.Color := $DEC1A9;
        DateAppearance.DisabledDateFill.ColorTo := clNone;
        DateAppearance.DisabledDateFill.ColorMirror := clNone;
        DateAppearance.DisabledDateFill.ColorMirrorTo := clNone;
        DateAppearance.DisabledDateFont.Color := clWhite;//$C0C0C0;
//        DateAppearance.DisabledDateFill.BorderColor := $588060;
        DateAppearance.DisabledDateFill.GradientMirrorType := gtVertical;

        DateAppearance.HoverDateFill.Color := $FFEBDB;
        DateAppearance.HoverDateFill.ColorTo := clNone;
        DateAppearance.HoverDateFill.ColorMirror := clNone;
        DateAppearance.HoverDateFill.ColorMirrorTo := clNone;
        DateAppearance.HoverDateFill.BorderColor :=  clNone;
        DateAppearance.HoverDateFill.GradientMirrorType := gtVertical;
        DateAppearance.HoverDateFont.Color := $5B391E;


        DateAppearance.SelectedDateFill.Color := $DEC1A9;
        DateAppearance.SelectedDateFill.ColorTo := clNone;
        DateAppearance.SelectedDateFill.ColorMirror := clNone;
        DateAppearance.SelectedDateFill.ColorMirrorTo := clNone;
        DateAppearance.SelectedDateFill.BorderColor := clNone;
        DateAppearance.SelectedDateFill.GradientMirrorType := gtVertical;

        DateAppearance.CurrentDateFill.Color := $EDDBCD;
        DateAppearance.CurrentDateFill.ColorTo := clNone;
        DateAppearance.CurrentDateFill.ColorMirror := clNone;
        DateAppearance.CurrentDateFill.ColorMirrorTo := clNone;
        DateAppearance.CurrentDateFill.BorderColor := $055CC9;
        DateAppearance.CurrentDateFill.GradientMirrorType := gtVertical;


      end;

      tsOffice2010Silver:
      begin
        Fill.Color := $EDE9E5;
        Fill.ColorTo := clNone;
        Fill.BorderColor := clNone;

        Header.Fill.Color := $EDE9E5;
        Header.Fill.ColorTo := clNone;
        Header.Font.Color := $5B391E;
        Header.Fill.BorderColor := $EEDDCF;

        Footer.Fill.Color := $EDE9E5;
        Footer.Fill.ColorTo := clNone;
        Footer.Font.Color := $5B391E;
        Footer.Fill.BorderColor := $EEDDCF;

        DateAppearance.DayOfWeekFill.Color := $EDE9E5;
        DateAppearance.DayOfWeekFill.ColorTo := clNone;
        DateAppearance.DayOfWeekFill.BorderColor := $FFC69A;

        DateAppearance.WeekNumbers.Fill.Color := DateAppearance.DayOfWeekFill.Color;
        DateAppearance.WeekNumbers.Fill.ColorTo := DateAppearance.DayOfWeekFill.ColorTo;
        DateAppearance.WeekNumbers.Fill.BorderColor := DateAppearance.DayOfWeekFill.BorderColor;

        DateAppearance.DateFill.Color := $EDE9E5;
        DateAppearance.DateFill.ColorTo := clNone;
        DateAppearance.DateFill.ColorMirror := clNone;
        DateAppearance.DateFill.ColorMirrorTo := clNone;
//        DateAppearance.DateFill.BorderColor := $8CC0B1;
        DateAppearance.DateFill.BorderColor := clNone;
        DateAppearance.DateFill.GradientMirrorType := gtVertical;

        DateAppearance.WeekendFill.Color := $EDE9E5;
        DateAppearance.WeekendFill.ColorTo := clNone;
        DateAppearance.WeekendFill.ColorMirror := clNone;
        DateAppearance.WeekendFill.ColorMirrorTo := clNone;
//        DateAppearance.DateFill.BorderColor := $8CC0B1;
        DateAppearance.WeekendFill.BorderColor := clNone;
        DateAppearance.WeekendFill.GradientMirrorType := gtVertical;

        DateAppearance.DisabledDateFill.Color := $DEC1A9;
        DateAppearance.DisabledDateFill.ColorTo := clNone;
        DateAppearance.DisabledDateFill.ColorMirror := clNone;
        DateAppearance.DisabledDateFill.ColorMirrorTo := clNone;
        DateAppearance.DisabledDateFont.Color := clWhite;//$C0C0C0;
//        DateAppearance.DisabledDateFill.BorderColor := $588060;
        DateAppearance.DisabledDateFill.GradientMirrorType := gtVertical;

        DateAppearance.HoverDateFill.Color := $EEDDCF;
        DateAppearance.HoverDateFill.ColorTo := clNone;
        DateAppearance.HoverDateFill.ColorMirror := clNone;
        DateAppearance.HoverDateFill.ColorMirrorTo := clNone;
        DateAppearance.HoverDateFill.BorderColor :=  clNone;
        DateAppearance.HoverDateFill.GradientMirrorType := gtVertical;
        DateAppearance.HoverDateFont.Color := $5B391E;


        DateAppearance.SelectedDateFill.Color := $DEC1A9;
        DateAppearance.SelectedDateFill.ColorTo := clNone;
        DateAppearance.SelectedDateFill.ColorMirror := clNone;
        DateAppearance.SelectedDateFill.ColorMirrorTo := clNone;
        DateAppearance.SelectedDateFill.BorderColor := clNone;
        DateAppearance.SelectedDateFill.GradientMirrorType := gtVertical;

        DateAppearance.CurrentDateFill.Color := $EDE9E5;
        DateAppearance.CurrentDateFill.ColorTo := clNone;
        DateAppearance.CurrentDateFill.ColorMirror := clNone;
        DateAppearance.CurrentDateFill.ColorMirrorTo := clNone;
        DateAppearance.CurrentDateFill.BorderColor := $055CC9;
        DateAppearance.CurrentDateFill.GradientMirrorType := gtVertical;
      end;
      tsOffice2010Black:
      begin
        Fill.Color := $828282;
        Fill.ColorTo := clNone;
        Fill.BorderColor := clNone;

        Header.Fill.Color := $828282;
        Header.Fill.ColorTo := clNone;
        Header.Font.Color := $5B391E;
        Header.Fill.BorderColor := $EEDDCF;

        Footer.Fill.Color := $828282;
        Footer.Fill.ColorTo := clNone;
        Footer.Font.Color := $5B391E;
        Footer.Fill.BorderColor := $EEDDCF;

        DateAppearance.DayOfWeekFill.Color :=  $828282;
        DateAppearance.DayOfWeekFill.ColorTo := clNone;
        DateAppearance.DayOfWeekFill.BorderColor := $FFC69A;

        DateAppearance.WeekNumbers.Fill.Color := DateAppearance.DayOfWeekFill.Color;
        DateAppearance.WeekNumbers.Fill.ColorTo := DateAppearance.DayOfWeekFill.ColorTo;
        DateAppearance.WeekNumbers.Fill.BorderColor := DateAppearance.DayOfWeekFill.BorderColor;

        DateAppearance.DateFill.Color := $828282;
        DateAppearance.DateFill.ColorTo := clNone;
        DateAppearance.DateFill.ColorMirror := clNone;
        DateAppearance.DateFill.ColorMirrorTo := clNone;
//        DateAppearance.DateFill.BorderColor := $8CC0B1;
        DateAppearance.DateFill.BorderColor := clNone;
        DateAppearance.DateFill.GradientMirrorType := gtVertical;

        DateAppearance.WeekendFill.Color := $828282;
        DateAppearance.WeekendFill.ColorTo := clNone;
        DateAppearance.WeekendFill.ColorMirror := clNone;
        DateAppearance.WeekendFill.ColorMirrorTo := clNone;
//        DateAppearance.DateFill.BorderColor := $8CC0B1;
        DateAppearance.WeekendFill.BorderColor := clNone;
        DateAppearance.WeekendFill.GradientMirrorType := gtVertical;

        DateAppearance.DisabledDateFill.Color := $A3A3A3;
        DateAppearance.DisabledDateFill.ColorTo := clNone;
        DateAppearance.DisabledDateFill.ColorMirror := clNone;
        DateAppearance.DisabledDateFill.ColorMirrorTo := clNone;
        DateAppearance.DisabledDateFont.Color := clWhite;
//        DateAppearance.DisabledDateFill.BorderColor := $588060;
        DateAppearance.DisabledDateFill.GradientMirrorType := gtVertical;

        DateAppearance.HoverDateFill.Color := $EEDDCF;
        DateAppearance.HoverDateFill.ColorTo := clNone;
        DateAppearance.HoverDateFill.ColorMirror := clNone;
        DateAppearance.HoverDateFill.ColorMirrorTo := clNone;
        DateAppearance.HoverDateFill.BorderColor :=  clNone;
        DateAppearance.HoverDateFill.GradientMirrorType := gtVertical;
        DateAppearance.HoverDateFont.Color := $5B391E;


        DateAppearance.SelectedDateFill.Color := $DEC1A9;
        DateAppearance.SelectedDateFill.ColorTo := clNone;
        DateAppearance.SelectedDateFill.ColorMirror := clNone;
        DateAppearance.SelectedDateFill.ColorMirrorTo := clNone;
        DateAppearance.SelectedDateFill.BorderColor := clNone;
        DateAppearance.SelectedDateFill.GradientMirrorType := gtVertical;

        DateAppearance.CurrentDateFill.Color := $828282;
        DateAppearance.CurrentDateFill.ColorTo := clNone;
        DateAppearance.CurrentDateFill.ColorMirror := clNone;
        DateAppearance.CurrentDateFill.ColorMirrorTo := clNone;
        DateAppearance.CurrentDateFill.BorderColor := $055CC9;
        DateAppearance.CurrentDateFill.GradientMirrorType := gtVertical;
      end;


  end;


  Header.ArrowColor := Header.Font.Color;
  DateAppearance.DateBeforeFill.Color := clNone;
  DateAppearance.DateBeforeFont.Color := clSilver;
  DateAppearance.DateAfterFont.Color := clSilver;
  DateAppearance.DateAfterFill.Color := clNone;

   case AStyle of
     tsOffice2010Blue:
     begin
   DateAppearance.DateBeforeFill.Color := $EDDBCD;
   DateAppearance.DateBeforeFill.ColorTo := clNone;
   DateAppearance.DateBeforeFont.Color := $AD815E;
   DateAppearance.DateAfterFont.Color := $AD815E;
   DateAppearance.DateAfterFill.Color := $EDDBCD;
   DateAppearance.DateAfterFill.ColorTo := clNone;

     end;
     tsOffice2010Silver:
     begin
   DateAppearance.DateBeforeFill.Color := $EDE9E5;
   DateAppearance.DateBeforeFill.ColorTo := clNone;
   DateAppearance.DateBeforeFont.Color := $AD815E;
   DateAppearance.DateAfterFont.Color := $AD815E;
   DateAppearance.DateAfterFill.Color := $EDE9E5;
   DateAppearance.DateAfterFill.ColorTo := clNone;

     end;
     tsOffice2010Black:
     begin
   DateAppearance.DateBeforeFill.Color := $828282;
   DateAppearance.DateBeforeFill.ColorTo := clNone;
   DateAppearance.DateBeforeFont.Color := $AD815E;
   DateAppearance.DateAfterFont.Color := $AD815E;
   DateAppearance.DateAfterFill.Color := $828282;
   DateAppearance.DateAfterFill.ColorTo := clNone;

     end;
   end;

end;

procedure TAdvSmoothCalendar.SetDateAppearance(
  const Value: TAdvSmoothCalendarDateAppearance);
begin
  if FDateAppearance <> value then
  begin
    FDateAppearance.Assign(value);
    Changed;
  end;
end;

procedure TAdvSmoothCalendar.SetDisjunctDaySelect(const Value: Boolean);
begin
  if FDisjunctDaySelect <> Value then
  begin
    FDisjunctDaySelect := Value;
    Changed;
  end;
end;

procedure TAdvSmoothCalendar.SetEndDate(const Value: TDateTime);
begin
  if FEndDate <> value then
  begin
    FEndDate := Value;
    FSelectedDateRange := drMultiDates;
    if not FMultiDateSet then
      FMultiDateSet := true
    else
    begin
      DoSelectMultiDate(Self, FDateMode, StartDate, EndDate);
      FMultiDateSet := false;
    end;
    Changed;
  end;
end;

procedure TAdvSmoothCalendar.SetFill(const Value: TGDIPFill);
begin
  if FFill <> value then
  begin
    FFill.Assign(Value);
    Changed;
  end;
end;

procedure TAdvSmoothCalendar.SetFocusColor(const Value: TColor);
begin
  if FFocusColor <> value then
  begin
    FFocusColor := Value;
    Changed;
  end;
end;

procedure TAdvSmoothCalendar.SetFooter(const Value: TAdvSmoothCalendarFooter);
begin
  if FFooter <> value then
  begin
    FFooter.Assign(Value);
    Changed;
  end;
end;

procedure TAdvSmoothCalendar.SetHeader(const Value: TAdvSmoothCalendarHeader);
begin
  if FHeader <> value then
  begin
    FHeader.Assign(value);
    Changed;
  end;
end;

procedure TAdvSmoothCalendar.SetHoveredDate(const Value: TDateTime);
begin
  if FHoverDate <> value then
  begin
    FHoverDate := Value;
    Changed;
  end;
end;

procedure TAdvSmoothCalendar.SetKeyBoardDateModeToggle(const Value: Boolean);
begin
  if FKeyBoardDateModeToggle <> value then
  begin
    FKeyBoardDateModeToggle := Value;
    Changed
  end;
end;

procedure TAdvSmoothCalendar.SetMaxDate(const Value: TDate);
begin
  if FMaxDate <> value then
  begin
    FMaxDate := Value;
    Changed;
  end;
end;

procedure TAdvSmoothCalendar.SetMinDate(const Value: TDate);
begin
  if FMinDate <> value then
  begin
    FMinDate := Value;
    Changed;
  end;
end;

procedure TAdvSmoothCalendar.SetMonth(const Value: integer);
begin
  if FMonth <> value then
  begin
    FMonth := Min(12, Max(1, Value));
    FCurrentMonth := Fmonth;
    Changed;
  end;
end;

procedure TAdvSmoothCalendar.SetMultiSelect(const Value: Boolean);
begin
  if FMultiSelect <> value then
  begin
    FMultiSelect := Value;
    Changed;
  end;
end;

procedure TAdvSmoothCalendar.SetSelectedDate(const Value: TDateTime);
begin
  SelectDate([], Value);
end;

procedure TAdvSmoothCalendar.SetShowCurrentDate(const Value: Boolean);
begin
  if (FShowCurrentDate <> Value) then
  begin
    FShowCurrentDate := Value;
    Changed;
  end;
end;

procedure TAdvSmoothCalendar.SetShowFocus(const Value: Boolean);
begin
  if FShowFocus <> value then
  begin
    FShowFocus := Value;
    Changed;
  end;
end;

procedure TAdvSmoothCalendar.SetStartDate(const Value: TDateTime);
begin
  if FStartDate <> value then
  begin
    FStartDate := Value;
    FSelectedDateRange := drMultiDates;
    if not FMultiDateSet then
      FMultiDateSet := true
    else
    begin
      DoSelectMultiDate(Self, FDateMode, StartDate, EndDate);
      FMultiDateSet := false;
    end;
    Changed;
  end;
end;

procedure TAdvSmoothCalendar.SetStatusAppearance(const Value: TGDIPStatus);
begin
  if FStatusAppearance <> value then
  begin
    FStatusAppearance := Value;
    StatusAppearanceChanged(Self);
  end;
end;

procedure TAdvSmoothCalendar.SetTransparent(const Value: Boolean);
begin
  if FTransparent <> value then
  begin
    FTransparent := Value;
    Changed;
  end;
end;

procedure TAdvSmoothCalendar.SetVersion(const Value: String);
begin

end;

procedure TAdvSmoothCalendar.SetYear(const Value: integer);
begin
  if FYear <> value then
  begin
    FYear := Max(1900, Value);
    FCurrentYear := FYear;
    if Assigned(FUpDown) then
    begin
      FUpDown.Min := Year - 10;
      FUpDown.Max := Year + 10;
      FLoading := True;
      FUpDown.Position := FYear;
      FLoading := False;
    end;
    Changed;
  end;
end;

procedure TAdvSmoothCalendar.StatusAppearanceChanged(Sender: TObject);
begin
  Changed;
end;

function TAdvSmoothCalendar.GetShadowOffset: integer;
begin
  Result := 0;
  if FFill.ShadowColor <> clNone then
    Result := FFill.ShadowOffset;
end;

function TAdvSmoothCalendar.GetStartDate: TDateTime;
begin
  if FStartDate > FEndDate then
    Result := FEndDate
  else
    Result := FStartDate;
end;

function TAdvSmoothCalendar.GetThemeId: String;
begin
  Result := ClassName;
end;

procedure TAdvSmoothCalendar.ToggleMode;
var
  allow: Boolean;
  t: TAdvSmoothCalendarDateMode;
begin
  if FTempDateMode <> FDateMode then
    Exit;

  t := FTempDateMode;

  if t = dmYear then
    t := dmDay
  else
    Inc(t);

  allow := true;
  DoChangeMode(Self, FDateMode, t, allow);

  if not allow then
    exit;

  FTempDateMode := t;

  if FTempDateMode = dmDay then
  begin
    FDayOpcTo := 255;
    FMonthOpcTo := 0;
    FYearOpcTo := 0;
    FWeekNumberOpcTo := 255;
  end
  else if FTempDateMode = dmMonth then
  begin
    FDayOpcTo := 0;
    FYearOpcTo := 0;
    FMonthOpcTo := 255;
    FWeekNumberOpcTo := 0;
  end
  else if FTempDateMode = dmYear then
  begin
    FMonthOpcTo := 0;
    FDayOpcTo := 0;
    FYearOpcTo := 255;
    FWeekNumberOpcTo := 0;
  end;

  if not Animation then
  begin
    FWeekNumberOpc := FWeekNumberOpcTo;
    FDayOpc := FDayOpcTo;
    FMonthOpc := FMonthOpcTo;
    FYearOpc := FYearOpcTo;
    FDateMode := FTempDateMode;
    Changed;
  end
  else
  begin
    FAnimateDateMode := true;
    FAnimate := true;
  end;
end;

procedure TAdvSmoothCalendar.UpDownChange(Sender: TObject;
  var AllowChange: Boolean; NewValue: SmallInt; Direction: TUpDownDirection);
begin
  if FLoading then
    Exit;
  case Direction of
    updUp:
    begin
      Year := Year + 1;
    end;
    updDown:
    begin
      Year := Year - 1;
    end;
  end;

  (Sender as TUpDown).Min := Year - 10;
  (Sender as TUpDown).Max := Year + 10;
end;

procedure TAdvSmoothCalendar.WMEraseBkgnd(var Message: TWmEraseBkgnd);
begin
  Message.Result := 1;
end;

procedure TAdvSmoothCalendar.WMGetDlgCode(var Message: TWMGetDlgCode);
begin
  if TabStop then
    Message.Result := DLGC_WANTALLKEYS or DLGC_WANTARROWS
  else
    Message.Result := 0;
end;

procedure TAdvSmoothCalendar.WMPaint(var Message: TWMPaint);
var
  DC, MemDC: HDC;
  MemBitmap, OldBitmap: HBITMAP;
  PS: TPaintStruct;
  {$IFNDEF DELPHI_UNICODE}
  dbl: boolean;
  {$ENDIF}
  p: TPoint;
  i: integer;
begin
  if Assigned(Parent) {and (Fill.ShadowOffset > 0) ?} then
  begin
    {$IFNDEF DELPHI_UNICODE}
    dbl := Parent.DoubleBuffered;
    Parent.DoubleBuffered := false;
    {$ENDIF}
    DC := Message.DC;
    i := SaveDC(DC);
    p := ClientOrigin;
    Windows.ScreenToClient(Parent.Handle, p);
    p.x := -p.x;
    p.y := -p.y;
    MoveWindowOrg(DC, p.x, p.y);
    SendMessage(Parent.Handle, WM_ERASEBKGND, DC, 0);
    SendMessage(Parent.Handle, WM_PAINT, DC, 0);
    if (Parent is TWinCtrl) then
      (Parent as TWinCtrl).PaintCtrls(DC, nil);
    RestoreDC(DC, i);
    {$IFNDEF DELPHI_UNICODE}
    Parent.DoubleBuffered := dbl;
    {$ENDIF}
  end;

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

function TAdvSmoothCalendar.XYToDate(X, Y: integer): TDateTime;
var
  cw, ch: Double;
  r: TRect;
  layr: TGPRectf;
  cmy, date: TDateTime;
  start, stop, wd, wdtotalfirst, wdtotallast, dim, rows, i: integer;
begin
  Result := -1;
  date := -1;
  cw := GetCellWidth;
  ch := GetCellHeight;

  layr := GetDateValuesRect;

  case FDateMode of
    dmDay:
    begin
      cmy := EncodeDate(FCurrentYear, FCurrentMonth, 1);
      dim := DaysInMonth(cmy);

      rows := 1;
      wdtotalfirst := GetDayOfWeekColumn(EncodeDate(FcurrentYear, FCurrentMonth, 1));
      wdtotallast := GetDayOfWeekColumn(EncodeDate(FcurrentYear, FCurrentMonth, dim));
      if DateAppearance.ShowDaysBefore then
        start := 2-wdtotalfirst
      else
        start := 1;

      if DateAppearance.ShowDaysAfter then
        stop := dim + 7 - wdtotallast
      else
        stop := dim;

      for I := start to stop do
      begin
        date := GetDate(i, dim);
        wd := GetDayOfWeekColumn(date);

        r.right := round(layr.X + (wd * cw) - 1);
        r.top := Round(layr.Y + ((rows - 1) * ch));
        r.bottom := Round(r.top + ch);
        r.left := Round(r.right - cw + 1);

        if PtinRect(r, Point(X, Y)) then
        begin
          Result := date;
          break;
        end;

        if (wd = 7) and (I >= 1) and (I <= dim) then
        begin
          Inc(rows);
        end;
      end;
    end;
    dmYear, dmMonth:
    begin
      wd := 1;
      rows := 1;
      for I := 1 to 12 do
      begin
        r.right := round(layr.X + (wd * cw));
        r.top := Round(layr.Y + ((rows - 1) * ch));
        r.bottom := Round(r.top + ch);
        r.left := Round(r.right - cw);

        case FDateMode of
          dmMonth: date := EncodeDate(FCurrentYear, I, GetCurrentDay(FcurrentYear, i));
          dmYear: date := EncodeDate(FCurrentYearFrom + (I - 1), FCurrentMonth, GetCurrentDay(FCurrentYearFrom + (I - 1), FCurrentMonth));
        end;

        if wd = 4 then
        begin
          Inc(rows);
          wd := 0;
        end;

        Inc(wd);

        if Ptinrect(r, Point(X, Y)) then
        begin
          result := date;
          break;
        end;
      end;
    end;
  end;
end;

{ TAdvSmoothCalendarHeader }

procedure TAdvSmoothCalendarHeader.Assign(Source: TPersistent);
begin
  if Source is TAdvSmoothCalendarHeader then
  begin
    FFill.Assign((Source as TAdvSmoothCalendarHeader).Fill);
    FArrowsVisible := (Source as TAdvSmoothCalendarHeader).ArrowsVisible;
    FArrowColor := (Source as TAdvSmoothCalendarHeader).ArrowColor;
    FArrowSize := (Source as TAdvSmoothCalendarHeader).ArrowSize;
    FHeight := (Source as TAdvSmoothCalendarHeader).Height;
    FCaptionPosition := (Source as TAdvSmoothCalendarHeader).CaptionPosition;
    FCaptionLeft := (Source as TAdvSmoothCalendarHeader).CaptionLeft;
    FCaptionTop := (Source as TAdvSmoothCalendarHeader).CaptionTop;
    Font.Assign((Source as TAdvSmoothCalendarHeader).Font);
    FVisible := (Source as TAdvSmoothCalendarHeader).Visible;
    Changed;
  end;
end;

procedure TAdvSmoothCalendarHeader.Changed;
begin
  if Assigned(FOnChange) then
    FOnChange(Self);
end;

constructor TAdvSmoothCalendarHeader.Create(AOwner: TAdvSmoothCalendar);
begin
  FOwner := AOwner;
  FFill := TGDIPFill.Create;
  FFill.OnChange := FillChanged;
  FArrowsVisible := true;
  FArrowColor := clWhite;
  FArrowSize := 10;
  FHeight := 25;
  FCaptionPosition := cpCenterCenter;
  FCaptionLeft := 0;
  FCaptionTop := 0;
  FFont := TFont.Create;
  FFont.OnChange := FontChanged;
  {$IFNDEF DELPHI9_LVL}
  FFont.Name := 'Tahoma';
  {$ENDIF}
  FVisible := true;
end;

destructor TAdvSmoothCalendarHeader.Destroy;
begin
  FFont.Free;
  FFill.Free;
  inherited;
end;

procedure TAdvSmoothCalendarHeader.FillChanged(Sender: TObject);
begin
  Changed;
end;

procedure TAdvSmoothCalendarHeader.FontChanged(Sender: TObject);
begin
  Changed;
end;

function TAdvSmoothCalendarHeader.GetHeight: integer;
begin
  result := 0;
  if Visible then
    Result := Height;
end;

procedure TAdvSmoothCalendarHeader.SetArrowColor(const Value: TColor);
begin
  if FArrowColor <> value then
  begin
    FArrowColor := Value;
    Changed;
  end;
end;

procedure TAdvSmoothCalendarHeader.SetArrowSize(const Value: Integer);
begin
  if FArrowSize <> value then
  begin
    FArrowSize := Value;
    Changed;
  end;
end;

procedure TAdvSmoothCalendarHeader.SetArrowsVisible(const Value: Boolean);
begin
  if FArrowsVisible <> value then
  begin
    FArrowsVisible := Value;
    Changed;
  end;
end;

procedure TAdvSmoothCalendarHeader.SetCaptionLeft(const Value: integer);
begin
  if FCaptionLeft <> value then
  begin
    FCaptionLeft := Value;
    Changed;
  end;
end;

procedure TAdvSmoothCalendarHeader.SetCaptionPosition(
  const Value: TAdvSmoothCalendarCaptionLocation);
begin
  if FCaptionPosition <> value then
  begin
    FCaptionPosition := Value;
    Changed;
  end;
end;

procedure TAdvSmoothCalendarHeader.SetCaptionTop(const Value: integer);
begin
  if FCaptionTop <> value then
  begin
    FCaptionTop := Value;
    Changed;
  end;
end;

procedure TAdvSmoothCalendarHeader.SetFill(const Value: TGDIPFill);
begin
  if FFill <> value then
  begin
    FFill.Assign(value);
    Changed;
  end;
end;

procedure TAdvSmoothCalendarHeader.SetFont(const Value: TFont);
begin
  if FFont <> value then
  begin
    FFont.Assign(value);
    FontChanged(self);
  end;
end;

procedure TAdvSmoothCalendarHeader.SetHeight(const Value: integer);
begin
  if FHeight <> value then
  begin
    FHeight := Value;
    Changed;
  end;
end;

procedure TAdvSmoothCalendarHeader.SetVisible(const Value: Boolean);
begin
  if FVisible <> value then
  begin
    FVisible := Value;
    Changed;
  end;
end;

{ TAdvSmoothCalendarDateAppearance }

procedure TAdvSmoothCalendarDateAppearance.Assign(Source: TPersistent);
begin
  if Source is TAdvSmoothCalendarDateAppearance then
  begin
    FDateFont.Assign((Source as TAdvSmoothCalendarDateAppearance).DateFont);
    FDateFill.Assign((Source as TAdvSmoothCalendarDateAppearance).DateFill);
    FDisabledDateFont.Assign((Source as TAdvSmoothCalendarDateAppearance).DisabledDateFont);
    FDisabledDateFill.Assign((Source as TAdvSmoothCalendarDateAppearance).DisabledDateFill);
    FSelectedDateFont.Assign((Source as TAdvSmoothCalendarDateAppearance).SelectedDateFont);
    FSelectedDateFill.Assign((Source as TAdvSmoothCalendarDateAppearance).SelectedDateFill);
    FDayOfWeekFont.Assign((Source as TAdvSmoothCalendarDateAppearance).DayOfWeekFont);
    FDayOfWeekFill.Assign((Source as TAdvSmoothCalendarDateAppearance).DayOfWeekFill);
    FCurrentDateFont.Assign((Source as TAdvSmoothCalendarDateAppearance).CurrentDateFont);
    FCurrentDateFill.Assign((Source as TAdvSmoothCalendarDateAppearance).CurrentDateFill);
    FHoverDateFont.Assign((Source as TAdvSmoothCalendarDateAppearance).HoverDateFont);
    FHoverDateFill.Assign((Source as TAdvSmoothCalendarDateAppearance).HoverDateFill);
    FMonthFont.Assign((Source as TAdvSmoothCalendarDateAppearance).MonthDateFont);
    FYearFont.Assign((Source as TAdvSmoothCalendarDateAppearance).YearDateFont);
    FWeekNumbers.Assign((Source as TAdvSmoothCalendarDateAppearance).WeekNumbers);
    FWeekendFill.Assign((Source as TAdvSmoothCalendarDateAppearance).WeekendFill);
    FWeekendFont.Assign((Source as TAdvSmoothCalendarDateAppearance).WeekendFont);
    FStartDay := (Source as TAdvSmoothCalendarDateAppearance).StartDay;
    FShowDaysBefore := (Source as TAdvSmoothCalendarDateAppearance).ShowDaysBefore;
    FShowDaysAfter := (Source as TAdvSmoothCalendarDateAppearance).ShowDaysAfter;
    FDateBeforeFill.Assign((Source as TAdvSmoothCalendarDateAppearance).DateBeforeFill);
    FDateAfterFill.Assign((Source as TAdvSmoothCalendarDateAppearance).DateAfterFill);
    FDateAfterFont.Assign((Source as TAdvSmoothCalendarDateAppearance).DateAfterFont);
    FDateBeforeFont.Assign((Source as TAdvSmoothCalendarDateAppearance).DateBeforeFont);
    Changed;
  end;
end;

procedure TAdvSmoothCalendarDateAppearance.AssignVisuals(Source: TPersistent);
begin
  if Source is TAdvSmoothCalendarDateAppearance then
  begin
    FDateFont.Assign((Source as TAdvSmoothCalendarDateAppearance).DateFont);
    FDateFill.Assign((Source as TAdvSmoothCalendarDateAppearance).DateFill);
    FDisabledDateFont.Assign((Source as TAdvSmoothCalendarDateAppearance).DisabledDateFont);
    FDisabledDateFill.Assign((Source as TAdvSmoothCalendarDateAppearance).DisabledDateFill);
    FSelectedDateFont.Assign((Source as TAdvSmoothCalendarDateAppearance).SelectedDateFont);
    FSelectedDateFill.Assign((Source as TAdvSmoothCalendarDateAppearance).SelectedDateFill);
    FDayOfWeekFont.Assign((Source as TAdvSmoothCalendarDateAppearance).DayOfWeekFont);
    FDayOfWeekFill.Assign((Source as TAdvSmoothCalendarDateAppearance).DayOfWeekFill);
    FCurrentDateFont.Assign((Source as TAdvSmoothCalendarDateAppearance).CurrentDateFont);
    FCurrentDateFill.Assign((Source as TAdvSmoothCalendarDateAppearance).CurrentDateFill);
    FHoverDateFont.Assign((Source as TAdvSmoothCalendarDateAppearance).HoverDateFont);
    FHoverDateFill.Assign((Source as TAdvSmoothCalendarDateAppearance).HoverDateFill);
    FMonthFont.Assign((Source as TAdvSmoothCalendarDateAppearance).MonthDateFont);
    FYearFont.Assign((Source as TAdvSmoothCalendarDateAppearance).YearDateFont);
    FWeekNumbers.AssignVisuals((Source as TAdvSmoothCalendarDateAppearance).WeekNumbers);
    FWeekendFill.Assign((Source as TAdvSmoothCalendarDateAppearance).WeekendFill);
    FWeekendFont.Assign((Source as TAdvSmoothCalendarDateAppearance).WeekendFont);
    FDateBeforeFill.Assign((Source as TAdvSmoothCalendarDateAppearance).DateBeforeFill);
    FDateAfterFill.Assign((Source as TAdvSmoothCalendarDateAppearance).DateAfterFill);
    FDateAfterFont.Assign((Source as TAdvSmoothCalendarDateAppearance).DateAfterFont);
    FDateBeforeFont.Assign((Source as TAdvSmoothCalendarDateAppearance).DateBeforeFont);
    Changed;
  end;
end;

procedure TAdvSmoothCalendarDateAppearance.Changed;
begin
  if Assigned(FOnChange) then
    FOnChange(Self);
end;

constructor TAdvSmoothCalendarDateAppearance.Create(AOwner: TAdvSmoothCalendar);
begin
  FOwner := AOwner;
  FDateFont := TFont.Create;
  FDateFont.OnChange := FontChanged;
  FDisabledDateFont := TFont.Create;
  FDisabledDateFont.OnChange := FontChanged;
  FDayOfWeekFont := TFont.Create;
  FDayOfWeekFont.OnChange := FontChanged;
  FSelectedDateFont := TFont.Create;
  FSelectedDateFont.OnChange := FontChanged;
  FCurrentDateFont := TFont.Create;
  FCurrentDateFont.OnChange := FontChanged;
  FHoverDateFont := TFont.Create;
  FHoverDateFont.OnChange := FontChanged;
  FMonthFont := TFont.Create;
  FMonthFont.OnChange := FontChanged;
  FYearFont := TFont.Create;
  FYearFont.OnChange := FontChanged;
  FWeekendFont := TFont.Create;
  FWeekendFont.OnChange := Fontchanged;
  FDateBeforeFont := TFont.Create;
  FDateBeforeFont.OnChange := FontChanged;
  FDateAfterFont := TFont.Create;
  FDateAfterFont.OnChange := FontChanged;


  {$IFNDEF DELPHI9_LVL}
  FDateFont.Name := 'Tahoma';
  FDisabledDateFont.Name := 'Tahoma';
  FDayOfWeekFont.Name := 'Tahoma';
  FSelectedDateFont.Name := 'Tahoma';
  FCurrentDateFont.Name := 'Tahoma';
  FHoverDateFont.Name := 'Tahoma';
  FMonthFont.Name := 'Tahoma';
  FYearFont.Name := 'Tahoma';
  FWeekendFont.Name := 'Tahoma';
  FDateBeforeFont.Name := 'Tahoma';
  FDateAfterFont.Name := 'Tahoma';
  {$ENDIF}

  FDateFill := TGDIPFill.Create;
  FDateFill.OnChange := FillChanged;
  FDisabledDateFill := TGDIPFill.Create;
  FDisabledDateFill.OnChange := FillChanged;
  FDayOfWeekFill := TGDIPFill.Create;
  FDayOfWeekFill.OnChange := FillChanged;
  FSelectedDateFill := TGDIPFill.Create;
  FSelectedDateFill.OnChange := FillChanged;
  FCurrentDateFill := TGDIPFill.Create;
  FCurrentDateFill.OnChange := FillChanged;
  FHoverDateFill := TGDIPFill.Create;
  FHoverDateFill.OnChange := FillChanged;
  FWeekendFill := TGDIPFill.Create;
  FWeekendFill.OnChange := FillChanged;
  FDateBeforeFill := TGDIPFill.Create;
  FDateBeforeFill.OnChange := FillChanged;
  FDateAfterFill := TGDIPFill.Create;
  FDateAfterFill.OnChange := FillChanged;

  FStartDay := Sunday;
  FShowDaysBefore := false;
  FShowDaysAfter := false;

  FWeekNumbers := TAdvSmoothCalendarDateWeekNumbers.Create(Self);
  FWeekNumbers.OnChange := WeekNumbersChanged;
end;

destructor TAdvSmoothCalendarDateAppearance.Destroy;
begin
  FDateFont.Free;
  FDateFill.Free;
  FDisabledDateFont.Free;
  FDisabledDateFill.Free;
  FDayOfWeekFont.Free;
  FDayOfWeekFill.Free;
  FSelectedDateFont.Free;
  FSelectedDateFill.Free;
  FCurrentDateFont.Free;
  FCurrentDateFill.Free;
  FHoverDateFont.Free;
  FHoverDateFill.Free;
  FWeekNumbers.Free;
  FMonthFont.Free;
  FYearFont.Free;
  FWeekendFont.Free;
  FWeekendFill.Free;
  FDateBeforeFill.Free;
  FDateBeforeFont.Free;
  FDateAfterFill.Free;
  FDateAfterFont.Free;
  inherited;
end;

procedure TAdvSmoothCalendarDateAppearance.FillChanged(Sender: TObject);
begin
  Changed;
end;

procedure TAdvSmoothCalendarDateAppearance.FontChanged(Sender: TObject);
begin
  Changed;
end;

procedure TAdvSmoothCalendarDateAppearance.SetCurrentDateFill(
  const Value: TGDIPFill);
begin
  if FCurrentDateFill <> value then
  begin
    FCurrentDateFill.Assign(Value);
    Changed;
  end;
end;

procedure TAdvSmoothCalendarDateAppearance.SetCurrentDateFont(
  const Value: TFont);
begin
  if FCurrentDateFont <> value then
  begin
    FCurrentDateFont.Assign(value);
    Changed;
  end;
end;

procedure TAdvSmoothCalendarDateAppearance.SetDateAfterFill(
  const Value: TGDIPFill);
begin
  if FDateAfterFill <> value then
  begin
    FDateAfterFill.Assign(Value);
    FillChanged(Self);
  end;
end;

procedure TAdvSmoothCalendarDateAppearance.SetDateAfterFont(const Value: TFont);
begin
  if FDateAfterFont <> value then
  begin
    FDateAfterFont.Assign(Value);
    FontChanged(Self);
  end;
end;

procedure TAdvSmoothCalendarDateAppearance.SetDateBeforeFill(
  const Value: TGDIPFill);
begin
  if FDateBeforeFill <> value then
  begin
    FDateBeforeFill.Assign(Value);
    FillChanged(Self);
  end;
end;

procedure TAdvSmoothCalendarDateAppearance.SetDateBeforeFont(
  const Value: TFont);
begin
  if FDateBeforeFont <> value then
  begin
    FDateBeforeFont.Assign(Value);
    FontChanged(Self);
  end;
end;

procedure TAdvSmoothCalendarDateAppearance.SetDateFill(const Value: TGDIPFill);
begin
  if FDateFill <> value then
  begin
    FDateFill.Assign(value);
    Changed;
  end;
end;

procedure TAdvSmoothCalendarDateAppearance.SetDateFont(const Value: TFont);
begin
  if FDateFont <> value then
  begin
    FDateFont.Assign(value);
    Changed;
  end;
end;

procedure TAdvSmoothCalendarDateAppearance.SetDayOfWeekFill(
  const Value: TGDIPFill);
begin
  if FDayOfWeekFill <> value then
  begin
    FDayOfWeekFill.Assign(Value);
    Changed;
  end;
end;

procedure TAdvSmoothCalendarDateAppearance.SetDayOfWeekFont(const Value: TFont);
begin
  if FDayOfWeekFont <> value then
  begin
    FDayOfWeekFont.Assign(value);
    Changed;
  end;
end;

procedure TAdvSmoothCalendarDateAppearance.SetDisabledDateFill(
  const Value: TGDIPFill);
begin
  if FDisabledDateFill <> value then
  begin
    FDisabledDateFill.Assign(Value);
    Changed;
  end;
end;

procedure TAdvSmoothCalendarDateAppearance.SetDisabledDateFont(
  const Value: TFont);
begin
  if FDisabledDateFont <> value then
  begin
    FDisabledDateFont.Assign(Value);
    Changed;
  end;
end;

procedure TAdvSmoothCalendarDateAppearance.SetHoverDateFill(
  const Value: TGDIPFill);
begin
  if FHoverDateFill <> value then
  begin
    FHoverDateFill.Assign(Value);
    Changed;
  end;
end;

procedure TAdvSmoothCalendarDateAppearance.SetHoverDateFont(const Value: TFont);
begin
  if FHoverDateFont <> value then
  begin
    FHoverDateFont.Assign(value);
    Changed;
  end;
end;

procedure TAdvSmoothCalendarDateAppearance.SetMonthFont(const Value: TFont);
begin
  if FMonthFont <> value then
  begin
    FMonthFont.Assign(value);
    Changed;
  end;
end;

procedure TAdvSmoothCalendarDateAppearance.SetSelectedDateFill(
  const Value: TGDIPFill);
begin
  if FSelectedDateFill <> value then
  begin
    FSelectedDateFill.Assign(Value);
    Changed;
  end;
end;

procedure TAdvSmoothCalendarDateAppearance.SetSelectedDateFont(
  const Value: TFont);
begin
  if FSelectedDateFont <> value then
  begin
    FSelectedDateFont.Assign(Value);
    Changed;
  end;
end;

procedure TAdvSmoothCalendarDateAppearance.SetShowDaysAfter(
  const Value: Boolean);
begin
  if FShowDaysAfter <> value then
  begin
    FShowDaysAfter := Value;
    Changed;
  end;
end;

procedure TAdvSmoothCalendarDateAppearance.SetShowDaysBefore(
  const Value: Boolean);
begin
  if FShowDaysBefore <> value then
  begin
    FShowDaysBefore := Value;
    Changed;
  end;
end;

procedure TAdvSmoothCalendarDateAppearance.SetStartDay(
  const Value: TAdvSmoothCalendarStartDay);
begin
  if FStartDay <> value then
  begin
    FStartDay := Value;
    Changed;
  end;
end;

procedure TAdvSmoothCalendarDateAppearance.SetWeekendFill(
  const Value: TGDIPFill);
begin
  if FWeekendFill <> value then
  begin
    FWeekendFill.Assign(Value);
    Changed;
  end;
end;

procedure TAdvSmoothCalendarDateAppearance.SetWeekendFont(const Value: TFont);
begin
  if FWeekendFont <> value then
  begin
    FWeekendFont.Assign(value);
    Changed;
  end;
end;

procedure TAdvSmoothCalendarDateAppearance.SetWeekNumbers(
  const Value: TAdvSmoothCalendarDateWeekNumbers);
begin
  if FWeekNumbers <> value then
  begin
    FWeekNumbers.Assign(value);
    Changed;
  end;
end;

procedure TAdvSmoothCalendarDateAppearance.SetYearFont(const Value: TFont);
begin
  if FYearFont <> value then
  begin
    FYearFont.Assign(value);
    Changed;
  end;
end;

procedure TAdvSmoothCalendarDateAppearance.WeekNumbersChanged(Sender: TObject);
begin
  Changed;
end;

{ TWinCtrl }

procedure TWinCtrl.PaintCtrls(DC: HDC; First: TControl);
begin
  PaintControls(DC, First);
end;

{ TAdvSmoothCalendarDateWeekNumbers }

procedure TAdvSmoothCalendarDateWeekNumbers.Assign(Source: TPersistent);
begin
  if Source is TAdvSmoothCalendarDateWeekNumbers then
  begin
    FVisible := (Source as TAdvSmoothCalendarDateWeekNumbers).Visible;
    FFont.Assign((Source as TAdvSmoothCalendarDateWeekNumbers).Font);
    FFill.Assign((Source as TAdvSmoothCalendarDateWeekNumbers).Fill);
    FWidth := (Source as TAdvSmoothCalendarDateWeekNumbers).Width;
    Changed;
  end;
end;

procedure TAdvSmoothCalendarDateWeekNumbers.AssignVisuals(Source: TPersistent);
begin
  if Source is TAdvSmoothCalendarDateWeekNumbers then
  begin
    FFont.Assign((Source as TAdvSmoothCalendarDateWeekNumbers).Font);
    FFill.Assign((Source as TAdvSmoothCalendarDateWeekNumbers).Fill);
    Changed;
  end;
end;

procedure TAdvSmoothCalendarDateWeekNumbers.Changed;
begin
  if Assigned(FOnChange) then
    FOnChange(Self);
end;

constructor TAdvSmoothCalendarDateWeekNumbers.Create(
  AOwner: TAdvSmoothCalendarDateAppearance);
begin
  FOwner := AOwner;
  FWidth := 30;
  FVisible := false;
  FFont := TFont.Create;
  FFont.OnChange := FontChanged;
  {$IFNDEF DELPHI9_LVL}
  FFont.Name := 'Tahoma';
  {$ENDIF}
  FFill := TGDIPFill.Create;
  FFill.OnChange := FillChanged;
end;

destructor TAdvSmoothCalendarDateWeekNumbers.Destroy;
begin
  FFont.Free;
  FFill.Free;
  inherited;
end;

procedure TAdvSmoothCalendarDateWeekNumbers.FillChanged(Sender: TObject);
begin
  Changed;
end;

procedure TAdvSmoothCalendarDateWeekNumbers.FontChanged(Sender: TObject);
begin
  Changed;
end;

function TAdvSmoothCalendarDateWeekNumbers.GetWidth: integer;
begin
  result := 0;
  if Visible then
    Result := Width;
end;

procedure TAdvSmoothCalendarDateWeekNumbers.SetFill(const Value: TGDIPFill);
begin
  if Ffill <> value then
  begin
    FFill.Assign(Value);
    Changed;
  end;
end;

procedure TAdvSmoothCalendarDateWeekNumbers.SetFont(const Value: TFont);
begin
  if FFont <> value then
  begin
    FFont.Assign(Value);
    Changed;
  end;
end;

procedure TAdvSmoothCalendarDateWeekNumbers.SetVisible(const Value: Boolean);
begin
  if FVisible <> value then
  begin
    FVisible := Value;
    Changed;
  end;
end;

procedure TAdvSmoothCalendarDateWeekNumbers.SetWidth(const Value: Integer);
begin
  if FWidth <> value then
  begin
    FWidth := Value;
    Changed;
  end;
end;

{ TAdvSmoothCalendarFooter }

procedure TAdvSmoothCalendarFooter.Assign(Source: TPersistent);
begin
  if Source is TAdvSmoothCalendarFooter then
  begin
    FFill.Assign((Source as TAdvSmoothCalendarFooter).Fill);
    FHeight := (Source as TAdvSmoothCalendarFooter).Height;
    FCaptionPosition := (Source as TAdvSmoothCalendarFooter).CaptionPosition;
    FCaptionLeft := (Source as TAdvSmoothCalendarFooter).CaptionLeft;
    FCaptionTop := (Source as TAdvSmoothCalendarFooter).CaptionTop;
    FFont.Assign((Source as TAdvSmoothCalendarFooter).Font);
    FVisible := (Source as TAdvSmoothCalendarFooter).Visible;
    FCurrentDateCaption := (Source as TAdvSmoothCalendarFooter).CurrentDateCaption;
    FCurrentDateFormat := (Source as TAdvSmoothCalendarFooter).CurrentDateFormat;
    FCaption := (Source as TAdvSmoothCalendarFooter).Caption;
    Changed;
  end;
end;

procedure TAdvSmoothCalendarFooter.Changed;
begin
  if Assigned(FOnChange) then
    FOnChange(Self);
end;

constructor TAdvSmoothCalendarFooter.Create(AOwner: TAdvSmoothCalendar);
begin
  FOwner := AOwner;
  FFill := TGDIPFill.Create;
  FFill.OnChange := FillChanged;
  FHeight := 25;
  FCaptionPosition := cpCenterCenter;
  FCaptionLeft := 0;
  FCaptionTop := 0;
  FFont := TFont.Create;
  {$IFNDEF DELPHI9_LVL}
  FFont.Name := 'Tahoma';
  {$ENDIF}
  FFont.OnChange := FontChanged;
  FVisible := true;
  FCurrentDateCaption := true;
end;

destructor TAdvSmoothCalendarFooter.Destroy;
begin
  FFont.Free;
  FFill.Free;
  inherited;
end;

procedure TAdvSmoothCalendarFooter.FillChanged(Sender: TObject);
begin
  Changed;
end;

procedure TAdvSmoothCalendarFooter.FontChanged(Sender: TObject);
begin
  Changed;
end;

function TAdvSmoothCalendarFooter.GetHeight: integer;
begin
  Result := 0;
  if Visible then
    Result := Height;
end;

procedure TAdvSmoothCalendarFooter.SetCaption(const Value: string);
begin
  if FCaption <> value then
  begin
    FCaption := Value;
    Changed;
  end;
end;

procedure TAdvSmoothCalendarFooter.SetCaptionLeft(const Value: integer);
begin
  if FCaptionLeft <> value then
  begin
    FCaptionLeft := Value;
    Changed;
  end;
end;

procedure TAdvSmoothCalendarFooter.SetCaptionPosition(
  const Value: TAdvSmoothCalendarCaptionLocation);
begin
  if FCaptionPosition <> value then
  begin
    FCaptionPosition := Value;
    Changed;
  end;
end;

procedure TAdvSmoothCalendarFooter.SetCaptionTop(const Value: integer);
begin
  if FCaptionTop <> value then
  begin
    FCaptionTop := Value;
    Changed;
  end;
end;

procedure TAdvSmoothCalendarFooter.SetCurrentDateCaption(const Value: Boolean);
begin
  if FCurrentDateCaption <> value then
  begin
    FCurrentDateCaption := Value;
    Changed;
  end;
end;

procedure TAdvSmoothCalendarFooter.SetCurrentDateFormat(const Value: string);
begin
  if (FCurrentDateFormat <> Value) then
  begin
    FCurrentDateFormat := Value;
    Changed;
  end;
end;

procedure TAdvSmoothCalendarFooter.SetFill(const Value: TGDIPFill);
begin
  if FFill <> value then
  begin
    FFill.Assign(Value);
    Changed;
  end;
end;

procedure TAdvSmoothCalendarFooter.SetFont(const Value: TFont);
begin
  if FFont <> value then
  begin
    FFont.Assign(Value);
    Changed;
  end;
end;

procedure TAdvSmoothCalendarFooter.SetHeight(const Value: integer);
begin
  if FHeight <> Value then
  begin
    FHeight := Value;
    Changed;
  end;
end;

procedure TAdvSmoothCalendarFooter.SetVisible(const Value: Boolean);
begin
  if FVisible <> value then
  begin
    FVisible := Value;
    Changed;
  end;
end;

end.

