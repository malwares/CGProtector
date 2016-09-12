  TPicturePosition = (bpTopLeft,bpTopRight,bpBottomLeft,bpBottomRight,bpCenter,bpTiled,bpStretched);

  THTMLPicture = class;

  {$IFDEF TMSDOTNET}

  {$EXTERNALSYM OLE_HANDLE}
  OLE_HANDLE = LongWord;

  {$EXTERNALSYM OLE_XPOS_PIXELS}
  OLE_XPOS_PIXELS  = Longint;
  {$EXTERNALSYM OLE_YPOS_PIXELS}
  OLE_YPOS_PIXELS  = Longint;
  {$EXTERNALSYM OLE_XSIZE_PIXELS}
  OLE_XSIZE_PIXELS = Longint;
  {$EXTERNALSYM OLE_YSIZE_PIXELS}
  OLE_YSIZE_PIXELS = Longint;

  {$EXTERNALSYM OLE_XPOS_HIMETRIC}
  OLE_XPOS_HIMETRIC  = Longint;
  {$EXTERNALSYM OLE_YPOS_HIMETRIC}
  OLE_YPOS_HIMETRIC  = Longint;
  {$EXTERNALSYM OLE_XSIZE_HIMETRIC}
  OLE_XSIZE_HIMETRIC = Longint;
  {$EXTERNALSYM OLE_YSIZE_HIMETRIC}
  OLE_YSIZE_HIMETRIC = Longint;

  {$EXTERNALSYM OLE_XPOS_CONTAINER}
  OLE_XPOS_CONTAINER  = Single;
  {$EXTERNALSYM OLE_YPOS_CONTAINER}
  OLE_YPOS_CONTAINER  = Single;
  {$EXTERNALSYM OLE_XSIZE_CONTAINER}
  OLE_XSIZE_CONTAINER = Single;
  {$EXTERNALSYM OLE_YSIZE_CONTAINER}
  OLE_YSIZE_CONTAINER = Single;


  [ComImport,
  GuidAttribute('7BF80980-BF32-101A-8BBB-00AA00300CAB')]
//  InterfaceTypeAttribute(ComInterfaceType.InterfaceIsIUnknown)]
  IPicture = interface
    function get_Handle(out handle: OLE_HANDLE): HResult;
    function get_hPal(out handle: OLE_HANDLE): HResult;
    function get_Type(out typ: Smallint): HResult;
    function get_Width(out width: OLE_XSIZE_HIMETRIC): HResult;
    function get_Height(out height: OLE_YSIZE_HIMETRIC): HResult;
    function Render(dc: HDC; x, y, cx, cy: Longint;
      xSrc: OLE_XPOS_HIMETRIC; ySrc: OLE_YPOS_HIMETRIC;
      cxSrc: OLE_XSIZE_HIMETRIC; cySrc: OLE_YSIZE_HIMETRIC;
      const rcWBounds: TRect): HResult;
    function set_hPal(hpal: OLE_HANDLE): HResult;
    function get_CurDC(out dcOut: HDC): HResult;
    function SelectPicture(dcIn: HDC; out hdcOut: HDC;
      out bmpOut: OLE_HANDLE): HResult;
    function get_KeepOriginalFormat(out fkeep: BOOL): HResult;
    function put_KeepOriginalFormat(fkeep: BOOL): HResult;
    function PictureChanged: HResult;
    function SaveAsFile(const stream: IStream; fSaveMemCopy: BOOL;
      out cbSize: Longint): HResult;
    function get_Attributes(out dwAttr: Longint): HResult;
  end;
  {$ENDIF}


  PInternetContent = ^TInternetContent;
  TInternetContent = record
  {$IFDEF USEWININET}
    hresource: hinternet;
  {$ENDIF}
    Complete: Boolean;
    HTMLPicture:THTMLPicture;
  end;

  TDownloadErrorEvent = procedure(Sender:TObject;err:string) of object;
  TDownloadCompleteEvent = procedure(Sender:TObject) of object;
  TDownloadCancelEvent = procedure(Sender:TObject;var Cancel:boolean) of object;
  TDownloadProgressEvent = procedure(Sender:TObject;dwSize,dwTotSize:dword) of object;

  TDownLoadThread = class(TThread)
  private
    HTMLPicture:THTMLPicture;
  protected
    procedure Execute; override;
  public
    constructor Create(aHTMLPicture:THTMLPicture);
  end;

  THTMLPicture = class(TGraphic)
  private
    { Private declarations }
    FDatastream:TMemoryStream;
    FIsEmpty: Boolean;
    FStretched: Boolean;
    gpPicture: IPicture;
    FLogPixX,FLogPixY: Integer;
    FURL:string;
    FID:string;
    FIsDB: Boolean;
    FAsynch: Boolean;
    FThreadBusy: Boolean;
    FFrame: Integer;
    FFrameCount: Integer;
    FOnFrameChange: TNotifyEvent;
    FFrameXPos: Word;
    FFrameYPos: Word;
    FFrameXSize: Word;
    FFrameYSize: Word;
    FFrameTransp: Boolean;
    FFrameDisposal: Word;
    FAnimMaxX,FAnimMaxY: Word;
    FNextCount: Integer;
    FTimerCount: Integer;
    FOnDownLoadProgress: TDownLoadProgressEvent;
    FOnDownLoadCancel: TDownLoadCancelEvent;
    FOnDownLoadComplete: TDownLoadCompleteEvent;
    FOnDownLoadError: TDownLoadErrorEvent;
    procedure LoadPicture;
    function GetFrameCount: Integer;
    function IsGIFFile: Boolean;
    function GetFrameTime(i: Integer): Integer;
  protected
    { Protected declarations }
    function GetEmpty: Boolean; override;
    function GetHeight: integer; override;
    function GetWidth: integer; override;
    procedure SetHeight(Value: integer); override;
    procedure SetWidth(Value: integer); override;
    procedure ReadData(Stream: TStream); override;
    procedure WriteData(Stream: TStream); override;
    procedure Draw(ACanvas: TCanvas; const Rect: TRect); override;
    procedure DownLoadError(err:string);
    procedure DownLoadComplete;
    procedure DownLoadCancel(var cancel:boolean);
    procedure DownLoadProgress(dwSize,dwTotSize:dword);
    function GetStretched: boolean;
    procedure SetStretched(const Value: boolean);
    {$IFDEF USEWININET}
    procedure DownLoad;
    {$ENDIF}
  public
    { Public declarations }
    constructor Create; override;
    destructor Destroy; override;
    procedure Assign(Source: TPersistent); override;
    procedure LoadFromFile(const FileName: string); override;
    procedure LoadFromStream(Stream: TStream); override;
    procedure SaveToStream(Stream: TStream); override;
    procedure LoadFromResourceName(Instance: THandle; const ResName: String);
    procedure LoadFromResourceID(Instance: THandle; ResID: Integer);
    procedure LoadFromURL(url:string);
    procedure LoadFromClipboardFormat(AFormat: Word; AData: THandle;
      APalette: HPALETTE); override;
    procedure SaveToClipboardFormat(var AFormat: Word; var AData: THandle;
      var APalette: HPALETTE); override;
    property Busy: Boolean read fThreadBusy;
    property Asynch: Boolean read fAsynch write fAsynch;
    property ID: string read FID write FID;
    property IsDB: boolean read FIsDB write FIsDB;
    property IsGIF: Boolean read IsGIFFile;
    property FrameCount:Integer read GetFrameCount;
    property FrameTime[i:Integer]:Integer read GetFrameTime;
    function GetMaxHeight: Integer;
    function GetMaxWidth: Integer;
    procedure SetFrame(const Value:Integer);
    procedure FrameNext;
    procedure FramePrev;
    function Step: Boolean;
    property MaxWidth: integer read GetMaxWidth;
    property MaxHeight: integer read GetMaxHeight;
    property FrameXPos: word read FFrameXPos;
    property FrameYPos: word read FFrameYPos;
  published
    { Published declarations }
    property Stretch:boolean read GetStretched write SetStretched;
    property Frame:Integer read FFrame write SetFrame;
    property OnFrameChange: TNotifyEvent read FOnFrameChange write FOnFrameChange;
    property OnDownLoadError:TDownLoadErrorEvent read fOnDownLoadError write fOnDownLoadError;
    property OnDownLoadComplete:TDownLoadCompleteEvent read fOnDownLoadComplete write fOnDownLoadComplete;
    property OnDownLoadCancel:TDownLoadCancelEvent read fOnDownLoadCancel write fOnDownLoadCancel;
    property OnDownLoadProgress:TDownLoadProgressEvent read fOnDownLoadProgress write fOnDownLoadProgress;
  end;

  THTMLPictureCache = class(TList)
  private
    procedure SetPicture(Index: Integer; Value: THTMLPicture);
    function GetPicture(Index: Integer):THTMLPicture;
  public
    destructor Destroy; override;
    property Items[index: Integer]: THTMLPicture read GetPicture write SetPicture; default;
    function AddPicture:THTMLPicture;
    function FindPicture(ID:string):THTMLPicture;
    procedure ClearPictures;
    function Animate: boolean;
  end;

  THTMLImage = class(TGraphicControl)
  private
    { Private declarations }
    FHTMLPicture:THTMLPicture;
    FPicturePosition:TPicturePosition;
    FOnDownLoadCancel: TDownLoadCancelEvent;
    FOnDownLoadComplete: TDownLoadCompleteEvent;
    FOnDownLoadError: TDownLoadErrorEvent;
    FOnDownLoadProgress: TDownLoadProgressEvent;
    procedure SetHTMLPicture(const Value: THTMLPicture);
    procedure PictureChanged(sender:TObject);
    procedure SetPicturePosition(const Value: TPicturePosition);
    procedure DownLoadError(Sender:TObject;err:string);
    procedure DownLoadComplete(Sender:TObject);
    procedure DownLoadCancel(Sender:TObject;var Cancel: Boolean);
    procedure DownLoadProgress(Sender:TObject;dwSize,dwTotSize:dword);
  protected
    { Protected declarations }
    procedure Paint; override;
    procedure Loaded; override;
  public
    { Public declarations }
    constructor Create(aOwner:TComponent); override;
    destructor Destroy; override;
  published
    { Published declarations }
    property HTMLPicture:THTMLPicture read FHTMLPicture write SetHTMLPicture;
    property PicturePosition:TPicturePosition read FPicturePosition write SetPicturePosition;
    { inherited published properties}
    property Align;
    {$IFDEF DELPHI4_LVL}
    property Anchors;
    property Constraints;
    property DragKind;    
    {$ENDIF}
    property DragCursor;
    property DragMode;
    property Hint;
    property ParentShowHint;
    property ShowHint;
    property Visible;
    property OnClick;
    {$IFDEF DELPHI5_LVL}
    property OnContextPopup;
    {$ENDIF}
    property OnDblClick;
    property OnDragDrop;
    property OnDragOver;
    {$IFDEF DELPHI4_LVL}
    property OnEndDock;
    property OnStartDock;
    {$ENDIF}
    property OnEndDrag;
    property OnMouseDown;
    property OnMouseUp;
    property OnMouseMove;
    property OnStartDrag;
    property OnDownLoadError:TDownLoadErrorEvent read FOnDownLoadError write FOnDownLoadError;
    property OnDownLoadComplete:TDownLoadCompleteEvent read FOnDownLoadComplete write FOnDownLoadComplete;
    property OnDownLoadCancel:TDownLoadCancelEvent read FOnDownLoadCancel write FOnDownLoadCancel;
    property OnDownLoadProgress:TDownLoadProgressEvent read FOnDownLoadProgress write FOnDownLoadProgress;
  end;
