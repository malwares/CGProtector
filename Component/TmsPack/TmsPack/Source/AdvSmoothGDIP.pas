{***************************************************************************}
{ GDI+ API Imports                                                          }
{ for Delphi & C++Builder                                                   }
{                                                                           }
{ written by TMS Software                                                   }
{            copyright © 2008                                               }
{            Email : info@tmssoftware.com                                   }
{            Web : http://www.tmssoftware.com                               }
{                                                                           }
{ The source code is given as is. The author is not responsible             }
{ for any possible damage done due to the use of this code.                 }
{ The component can be freely used in any application. The complete         }
{ source code remains property of the author and may not be distributed,    }
{ published, given or sold in any form as such. No parts of the source      }
{ code can be included in any other component or application without        }
{ written authorization of the author.                                      }
{***************************************************************************}

unit AdvSmoothGDIP;

{$HPPEMIT ''}
{$HPPEMIT '#pragma link "gdiplus.lib"'}
{$HPPEMIT ''}

{$I TMSDEFS.INC}

{$ALIGN ON}
{$MINENUMSIZE 4}

interface

uses
  Windows, ActiveX, Math, Graphics, Classes, Controls , SysUtils, ComObj;

type
  TSingleDynArray = array of Single;

var
  GlowSpeed : integer = 30;


const
  {$EXTERNALSYM GDIP_NOWRAP}
  GDIP_NOWRAP = 4096;
  WINGDIPDLL = 'gdiplus.dll';

  // Common color constants
  aclAliceBlue            = $FFF0F8FF;
  aclAntiqueWhite         = $FFFAEBD7;
  aclAqua                 = $FF00FFFF;
  aclAquamarine           = $FF7FFFD4;
  aclAzure                = $FFF0FFFF;
  aclBeige                = $FFF5F5DC;
  aclBisque               = $FFFFE4C4;
  aclBlack                = $FF000000;
  aclBlanchedAlmond       = $FFFFEBCD;
  aclBlue                 = $FF0000FF;
  aclBlueViolet           = $FF8A2BE2;
  aclBrown                = $FFA52A2A;
  aclBurlyWood            = $FFDEB887;
  aclCadetBlue            = $FF5F9EA0;
  aclChartreuse           = $FF7FFF00;
  aclChocolate            = $FFD2691E;
  aclCoral                = $FFFF7F50;
  aclCornflowerBlue       = $FF6495ED;
  aclCornsilk             = $FFFFF8DC;
  aclCrimson              = $FFDC143C;
  aclCyan                 = $FF00FFFF;
  aclDarkBlue             = $FF00008B;
  aclDarkCyan             = $FF008B8B;
  aclDarkGoldenrod        = $FFB8860B;
  aclDarkGray             = $FFA9A9A9;
  aclDarkGreen            = $FF006400;
  aclDarkKhaki            = $FFBDB76B;
  aclDarkMagenta          = $FF8B008B;
  aclDarkOliveGreen       = $FF556B2F;
  aclDarkOrange           = $FFFF8C00;
  aclDarkOrchid           = $FF9932CC;
  aclDarkRed              = $FF8B0000;
  aclDarkSalmon           = $FFE9967A;
  aclDarkSeaGreen         = $FF8FBC8B;
  aclDarkSlateBlue        = $FF483D8B;
  aclDarkSlateGray        = $FF2F4F4F;
  aclDarkTurquoise        = $FF00CED1;
  aclDarkViolet           = $FF9400D3;
  aclDeepPink             = $FFFF1493;
  aclDeepSkyBlue          = $FF00BFFF;
  aclDimGray              = $FF696969;
  aclDodgerBlue           = $FF1E90FF;
  aclFirebrick            = $FFB22222;
  aclFloralWhite          = $FFFFFAF0;
  aclForestGreen          = $FF228B22;
  aclFuchsia              = $FFFF00FF;
  aclGainsboro            = $FFDCDCDC;
  aclGhostWhite           = $FFF8F8FF;
  aclGold                 = $FFFFD700;
  aclGoldenrod            = $FFDAA520;
  aclGray                 = $FF808080;
  aclGreen                = $FF008000;
  aclGreenYellow          = $FFADFF2F;
  aclHoneydew             = $FFF0FFF0;
  aclHotPink              = $FFFF69B4;
  aclIndianRed            = $FFCD5C5C;
  aclIndigo               = $FF4B0082;
  aclIvory                = $FFFFFFF0;
  aclKhaki                = $FFF0E68C;
  aclLavender             = $FFE6E6FA;
  aclLavenderBlush        = $FFFFF0F5;
  aclLawnGreen            = $FF7CFC00;
  aclLemonChiffon         = $FFFFFACD;
  aclLightBlue            = $FFADD8E6;
  aclLightCoral           = $FFF08080;
  aclLightCyan            = $FFE0FFFF;
  aclLightGoldenrodYellow = $FFFAFAD2;
  aclLightGray            = $FFD3D3D3;
  aclLightGreen           = $FF90EE90;
  aclLightPink            = $FFFFB6C1;
  aclLightSalmon          = $FFFFA07A;
  aclLightSeaGreen        = $FF20B2AA;
  aclLightSkyBlue         = $FF87CEFA;
  aclLightSlateGray       = $FF778899;
  aclLightSteelBlue       = $FFB0C4DE;
  aclLightYellow          = $FFFFFFE0;
  aclLime                 = $FF00FF00;
  aclLimeGreen            = $FF32CD32;
  aclLinen                = $FFFAF0E6;
  aclMagenta              = $FFFF00FF;
  aclMaroon               = $FF800000;
  aclMediumAquamarine     = $FF66CDAA;
  aclMediumBlue           = $FF0000CD;
  aclMediumOrchid         = $FFBA55D3;
  aclMediumPurple         = $FF9370DB;
  aclMediumSeaGreen       = $FF3CB371;
  aclMediumSlateBlue      = $FF7B68EE;
  aclMediumSpringGreen    = $FF00FA9A;
  aclMediumTurquoise      = $FF48D1CC;
  aclMediumVioletRed      = $FFC71585;
  aclMidnightBlue         = $FF191970;
  aclMintCream            = $FFF5FFFA;
  aclMistyRose            = $FFFFE4E1;
  aclMoccasin             = $FFFFE4B5;
  aclNavajoWhite          = $FFFFDEAD;
  aclNavy                 = $FF000080;
  aclOldLace              = $FFFDF5E6;
  aclOlive                = $FF808000;
  aclOliveDrab            = $FF6B8E23;
  aclOrange               = $FFFFA500;
  aclOrangeRed            = $FFFF4500;
  aclOrchid               = $FFDA70D6;
  aclPaleGoldenrod        = $FFEEE8AA;
  aclPaleGreen            = $FF98FB98;
  aclPaleTurquoise        = $FFAFEEEE;
  aclPaleVioletRed        = $FFDB7093;
  aclPapayaWhip           = $FFFFEFD5;
  aclPeachPuff            = $FFFFDAB9;
  aclPeru                 = $FFCD853F;
  aclPink                 = $FFFFC0CB;
  aclPlum                 = $FFDDA0DD;
  aclPowderBlue           = $FFB0E0E6;
  aclPurple               = $FF800080;
  aclRed                  = $FFFF0000;
  aclRosyBrown            = $FFBC8F8F;
  aclRoyalBlue            = $FF4169E1;
  aclSaddleBrown          = $FF8B4513;
  aclSalmon               = $FFFA8072;
  aclSandyBrown           = $FFF4A460;
  aclSeaGreen             = $FF2E8B57;
  aclSeaShell             = $FFFFF5EE;
  aclSienna               = $FFA0522D;
  aclSilver               = $FFC0C0C0;
  aclSkyBlue              = $FF87CEEB;
  aclSlateBlue            = $FF6A5ACD;
  aclSlateGray            = $FF708090;
  aclSnow                 = $FFFFFAFA;
  aclSpringGreen          = $FF00FF7F;
  aclSteelBlue            = $FF4682B4;
  aclTan                  = $FFD2B48C;
  aclTeal                 = $FF008080;
  aclThistle              = $FFD8BFD8;
  aclTomato               = $FFFF6347;
  aclTransparent          = $00FFFFFF;
  aclTurquoise            = $FF40E0D0;
  aclViolet               = $FFEE82EE;
  aclWheat                = $FFF5DEB3;
  aclWhite                = $FFFFFFFF;
  aclWhiteSmoke           = $FFF5F5F5;
  aclYellow               = $FFFFFF00;
  aclYellowGreen          = $FF9ACD32;


//--------------------------------------------------------------------------
// ImageCodecInfo structure
//--------------------------------------------------------------------------

type
  //{$EXTERNALSYM ImageCodecInfo}
  ImageCodecInfo = packed record
    Clsid             : TGUID;
    FormatID          : TGUID;
    CodecName         : PWCHAR;
    DllName           : PWCHAR;
    FormatDescription : PWCHAR;
    FilenameExtension : PWCHAR;
    MimeType          : PWCHAR;
    Flags             : DWORD;
    Version           : DWORD;
    SigCount          : DWORD;
    SigSize           : DWORD;
    SigPattern        : PBYTE;
    SigMask           : PBYTE;
  end;
  TImageCodecInfo = ImageCodecInfo;
  PImageCodecInfo = ^TImageCodecInfo;

//----------------------------------------------------------------------------
// Memory Allocation APIs
//----------------------------------------------------------------------------

{$EXTERNALSYM GdipAlloc}
function GdipAlloc(size: ULONG): pointer; stdcall;
{$EXTERNALSYM GdipFree}
procedure GdipFree(ptr: pointer); stdcall;

(**************************************************************************\
*
*   GDI+ base memory allocation class
*
\**************************************************************************)

type
  TAntiAlias = (aaNone, aaClearType, aaAntiAlias);

  TGdiplusBase = class
  public
    class function NewInstance: TObject; override;
    procedure FreeInstance; override;
  end;


//--------------------------------------------------------------------------
// Fill mode constants
//--------------------------------------------------------------------------

  FillMode = (
    FillModeAlternate,        // 0
    FillModeWinding           // 1
  );
  TFillMode = FillMode;

//--------------------------------------------------------------------------
// Pen's Fill types
//--------------------------------------------------------------------------
{$IFDEF DELPHI6_UP}
  {$EXTERNALSYM PenType}
  PenType = (
   PenTypeSolidColor       =  ord(BrushTypeSolidColor),
   PenTypeHatchFill        =  ord(BrushTypeHatchFill),
   PenTypeTextureFill      =  ord(BrushTypeTextureFill),
   PenTypePathGradient     =  ord(BrushTypePathGradient),
   PenTypeLinearGradient   =  ord(BrushTypeLinearGradient),
   PenTypeUnknown          = -1
  );
  TPenType = PenType;
{$ELSE}
  {$EXTERNALSYM PenType}
  PenType = Integer;
  const
    PenTypeSolidColor       =  0;
    PenTypeHatchFill        =  1;
    PenTypeTextureFill      =  2;
    PenTypePathGradient     =  3;
    PenTypeLinearGradient   =  4;
    PenTypeUnknown          = -1;

type
  TPenType = PenType;
{$ENDIF}

//--------------------------------------------------------------------------
// Quality mode constants
//--------------------------------------------------------------------------

{$IFDEF DELPHI6_UP}
  {$EXTERNALSYM QualityMode}
  QualityMode = (
    QualityModeInvalid   = -1,
    QualityModeDefault   =  0,
    QualityModeLow       =  1, // Best performance
    QualityModeHigh      =  2  // Best rendering quality
  );
  TQualityMode = QualityMode;
{$ELSE}
  {$EXTERNALSYM QualityMode}
  QualityMode = Integer;
  const
    QualityModeInvalid   = -1;
    QualityModeDefault   =  0;
    QualityModeLow       =  1; // Best performance
    QualityModeHigh      =  2; // Best rendering quality
{$ENDIF}

type
{$IFDEF DELPHI6_UP}
  {$EXTERNALSYM CompositingQuality}
  CompositingQuality = (
    CompositingQualityInvalid          = ord(QualityModeInvalid),
    CompositingQualityDefault          = ord(QualityModeDefault),
    CompositingQualityHighSpeed        = ord(QualityModeLow),
    CompositingQualityHighQuality      = ord(QualityModeHigh),
    CompositingQualityGammaCorrected,
    CompositingQualityAssumeLinear
  );
  TCompositingQuality = CompositingQuality;
{$ELSE}
  {$EXTERNALSYM CompositingQuality}
  CompositingQuality = Integer;
  const
    CompositingQualityInvalid          = QualityModeInvalid;
    CompositingQualityDefault          = QualityModeDefault;
    CompositingQualityHighSpeed        = QualityModeLow;
    CompositingQualityHighQuality      = QualityModeHigh;
    CompositingQualityGammaCorrected   = 3;
    CompositingQualityAssumeLinear     = 4;

type
  TCompositingQuality = CompositingQuality;
{$ENDIF}

const
  ImageFormatUndefined : TGUID = '{b96b3ca9-0728-11d3-9d7b-0000f81ef32e}';
  {$EXTERNALSYM ImageFormatUndefined}
  ImageFormatMemoryBMP : TGUID = '{b96b3caa-0728-11d3-9d7b-0000f81ef32e}';
  {$EXTERNALSYM ImageFormatMemoryBMP}
  ImageFormatBMP       : TGUID = '{b96b3cab-0728-11d3-9d7b-0000f81ef32e}';
  {$EXTERNALSYM ImageFormatBMP}
  ImageFormatEMF       : TGUID = '{b96b3cac-0728-11d3-9d7b-0000f81ef32e}';
  {$EXTERNALSYM ImageFormatEMF}
  ImageFormatWMF       : TGUID = '{b96b3cad-0728-11d3-9d7b-0000f81ef32e}';
  {$EXTERNALSYM ImageFormatWMF}
  ImageFormatJPEG      : TGUID = '{b96b3cae-0728-11d3-9d7b-0000f81ef32e}';
  {$EXTERNALSYM ImageFormatJPEG}
  ImageFormatPNG       : TGUID = '{b96b3caf-0728-11d3-9d7b-0000f81ef32e}';
  {$EXTERNALSYM ImageFormatPNG}
  ImageFormatGIF       : TGUID = '{b96b3cb0-0728-11d3-9d7b-0000f81ef32e}';
  {$EXTERNALSYM ImageFormatGIF}
  ImageFormatTIFF      : TGUID = '{b96b3cb1-0728-11d3-9d7b-0000f81ef32e}';
  {$EXTERNALSYM ImageFormatTIFF}
  ImageFormatEXIF      : TGUID = '{b96b3cb2-0728-11d3-9d7b-0000f81ef32e}';
  {$EXTERNALSYM ImageFormatEXIF}
  ImageFormatIcon      : TGUID = '{b96b3cb5-0728-11d3-9d7b-0000f81ef32e}';
  {$EXTERNALSYM ImageFormatIcon}

type
  //{$EXTERNALSYM ImageAbort}
  ImageAbort = function: BOOL; stdcall;
  //{$EXTERNALSYM DrawImageAbort}
  DrawImageAbort         = ImageAbort;

type
//--------------------------------------------------------------------------
// Unit constants
//--------------------------------------------------------------------------

  Unit_ = (
    UnitWorld,      // 0 -- World coordinate (non-physical unit)
    UnitDisplay,    // 1 -- Variable -- for PageTransform only
    UnitPixel,      // 2 -- Each unit is one device pixel.
    UnitPoint,      // 3 -- Each unit is a printer's point, or 1/72 inch.
    UnitInch,       // 4 -- Each unit is 1 inch.
    UnitDocument,   // 5 -- Each unit is 1/300 inch.
    UnitMillimeter  // 6 -- Each unit is 1 millimeter.
  );
  TUnit = Unit_;

//--------------------------------------------------------------------------
// Hatch styles
//--------------------------------------------------------------------------

//  {$EXTERNALSYM HatchStyle}
  HatchStyle = (
    HatchStyleHorizontal,                  // = 0,
    HatchStyleVertical,                    // = 1,
    HatchStyleForwardDiagonal,             // = 2,
    HatchStyleBackwardDiagonal,            // = 3,
    HatchStyleCross,                       // = 4,
    HatchStyleDiagonalCross,               // = 5,
    HatchStyle05Percent,                   // = 6,
    HatchStyle10Percent,                   // = 7,
    HatchStyle20Percent,                   // = 8,
    HatchStyle25Percent,                   // = 9,
    HatchStyle30Percent,                   // = 10,
    HatchStyle40Percent,                   // = 11,
    HatchStyle50Percent,                   // = 12,
    HatchStyle60Percent,                   // = 13,
    HatchStyle70Percent,                   // = 14,
    HatchStyle75Percent,                   // = 15,
    HatchStyle80Percent,                   // = 16,
    HatchStyle90Percent,                   // = 17,
    HatchStyleLightDownwardDiagonal,       // = 18,
    HatchStyleLightUpwardDiagonal,         // = 19,
    HatchStyleDarkDownwardDiagonal,        // = 20,
    HatchStyleDarkUpwardDiagonal,          // = 21,
    HatchStyleWideDownwardDiagonal,        // = 22,
    HatchStyleWideUpwardDiagonal,          // = 23,
    HatchStyleLightVertical,               // = 24,
    HatchStyleLightHorizontal,             // = 25,
    HatchStyleNarrowVertical,              // = 26,
    HatchStyleNarrowHorizontal,            // = 27,
    HatchStyleDarkVertical,                // = 28,
    HatchStyleDarkHorizontal,              // = 29,
    HatchStyleDashedDownwardDiagonal,      // = 30,
    HatchStyleDashedUpwardDiagonal,        // = 31,
    HatchStyleDashedHorizontal,            // = 32,
    HatchStyleDashedVertical,              // = 33,
    HatchStyleSmallConfetti,               // = 34,
    HatchStyleLargeConfetti,               // = 35,
    HatchStyleZigZag,                      // = 36,
    HatchStyleWave,                        // = 37,
    HatchStyleDiagonalBrick,               // = 38,
    HatchStyleHorizontalBrick,             // = 39,
    HatchStyleWeave,                       // = 40,
    HatchStylePlaid,                       // = 41,
    HatchStyleDivot,                       // = 42,
    HatchStyleDottedGrid,                  // = 43,
    HatchStyleDottedDiamond,               // = 44,
    HatchStyleShingle,                     // = 45,
    HatchStyleTrellis,                     // = 46,
    HatchStyleSphere,                      // = 47,
    HatchStyleSmallGrid,                   // = 48,
    HatchStyleSmallCheckerBoard,           // = 49,
    HatchStyleLargeCheckerBoard,           // = 50,
    HatchStyleOutlinedDiamond,             // = 51,
    HatchStyleSolidDiamond,                // = 52,
    HatchStyleTotal                        // = 53,
  );

  const
    HatchStyleLargeGrid = HatchStyleCross; // 4
    HatchStyleMin       = HatchStyleHorizontal;
    HatchStyleMax       = HatchStyleSolidDiamond;

type
  THatchStyle = HatchStyle;

//--------------------------------------------------------------------------
// Dash style constants
//--------------------------------------------------------------------------
//  {$EXTERNALSYM DashStyle}
  DashStyle = (
    DashStyleSolid,          // 0
    DashStyleDash,           // 1
    DashStyleDot,            // 2
    DashStyleDashDot,        // 3
    DashStyleDashDotDot,     // 4
    DashStyleCustom          // 5
  );
  TDashStyle = DashStyle;


//--------------------------------------------------------------------------
// Various wrap modes for brushes
//--------------------------------------------------------------------------
//  {$EXTERNALSYM WrapMode}
  WrapMode = (
    WrapModeTile,        // 0
    WrapModeTileFlipX,   // 1
    WrapModeTileFlipY,   // 2
    WrapModeTileFlipXY,  // 3
    WrapModeClamp        // 4
  );
  TWrapMode = WrapMode;

//--------------------------------------------------------------------------
// LineGradient Mode
//--------------------------------------------------------------------------

  LinearGradientMode = (
    LinearGradientModeHorizontal,         // 0
    LinearGradientModeVertical,           // 1
    LinearGradientModeForwardDiagonal,    // 2
    LinearGradientModeBackwardDiagonal    // 3
  );
  TLinearGradientMode = LinearGradientMode;

//--------------------------------------------------------------------------
// Interpolation modes
//--------------------------------------------------------------------------
{$IFDEF DELPHI6_UP}
  {$EXTERNALSYM InterpolationMode}
  InterpolationMode = (
    InterpolationModeInvalid          = ord(QualityModeInvalid),
    InterpolationModeDefault          = ord(QualityModeDefault),
    InterpolationModeLowQuality       = ord(QualityModeLow),
    InterpolationModeHighQuality      = ord(QualityModeHigh),
    InterpolationModeBilinear,
    InterpolationModeBicubic,
    InterpolationModeNearestNeighbor,
    InterpolationModeHighQualityBilinear,
    InterpolationModeHighQualityBicubic
  );
  TInterpolationMode = InterpolationMode;
{$ELSE}
  {$EXTERNALSYM InterpolationMode}
  InterpolationMode = Integer;
  const
    InterpolationModeInvalid             = QualityModeInvalid;
    InterpolationModeDefault             = QualityModeDefault;
    InterpolationModeLowQuality          = QualityModeLow;
    InterpolationModeHighQuality         = QualityModeHigh;
    InterpolationModeBilinear            = 3;
    InterpolationModeBicubic             = 4;
    InterpolationModeNearestNeighbor     = 5;
    InterpolationModeHighQualityBilinear = 6;
    InterpolationModeHighQualityBicubic  = 7;

type
  TInterpolationMode = InterpolationMode;
{$ENDIF}

//--------------------------------------------------------------------------
// Line cap constants (only the lowest 8 bits are used).
//--------------------------------------------------------------------------
{$IFDEF DELPHI6_UP}
  {$EXTERNALSYM LineCap}
  LineCap = (
    LineCapFlat             = 0,
    LineCapSquare           = 1,
    LineCapRound            = 2,
    LineCapTriangle         = 3,

    LineCapNoAnchor         = $10, // corresponds to flat cap
    LineCapSquareAnchor     = $11, // corresponds to square cap
    LineCapRoundAnchor      = $12, // corresponds to round cap
    LineCapDiamondAnchor    = $13, // corresponds to triangle cap
    LineCapArrowAnchor      = $14, // no correspondence

    LineCapCustom           = $ff, // custom cap

    LineCapAnchorMask       = $f0  // mask to check for anchor or not.
  );
  TLineCap = LineCap;
{$ELSE}
  {$EXTERNALSYM LineCap}
  LineCap = Integer;
  const
    LineCapFlat             = 0;
    LineCapSquare           = 1;
    LineCapRound            = 2;
    LineCapTriangle         = 3;

    LineCapNoAnchor         = $10; // corresponds to flat cap
    LineCapSquareAnchor     = $11; // corresponds to square cap
    LineCapRoundAnchor      = $12; // corresponds to round cap
    LineCapDiamondAnchor    = $13; // corresponds to triangle cap
    LineCapArrowAnchor      = $14; // no correspondence

    LineCapCustom           = $ff; // custom cap

    LineCapAnchorMask       = $f0; // mask to check for anchor or not.

type
  TLineCap = LineCap;
{$ENDIF}

//--------------------------------------------------------------------------
// Region Comine Modes
//--------------------------------------------------------------------------

  CombineMode = (
    CombineModeReplace,     // 0
    CombineModeIntersect,   // 1
    CombineModeUnion,       // 2
    CombineModeXor,         // 3
    CombineModeExclude,     // 4
    CombineModeComplement   // 5 (Exclude From)
  );
  TCombineMode = CombineMode;

//--------------------------------------------------------------------------
// Matrix Order
//--------------------------------------------------------------------------

//  {$EXTERNALSYM MatrixOrder}
  MatrixOrder = (
    MatrixOrderPrepend,
    MatrixOrderAppend
  );
  TMatrixOrder = MatrixOrder;


//----------------------------------------------------------------------------
// Color matrix
//----------------------------------------------------------------------------

type
  //{$EXTERNALSYM ColorMatrix}
  ColorMatrix = packed array[0..4, 0..4] of Single;
  TColorMatrix = ColorMatrix;
  PColorMatrix = ^TColorMatrix;

//----------------------------------------------------------------------------
// Color Matrix flags
//----------------------------------------------------------------------------

  //{$EXTERNALSYM ColorMatrixFlags}
  ColorMatrixFlags = (
    ColorMatrixFlagsDefault,
    ColorMatrixFlagsSkipGrays,
    ColorMatrixFlagsAltGray
  );
  TColorMatrixFlags = ColorMatrixFlags;

//----------------------------------------------------------------------------
// Color Channel flags
//----------------------------------------------------------------------------

  //{$EXTERNALSYM ColorChannelFlags}
  ColorChannelFlags = (
    ColorChannelFlagsC,
    ColorChannelFlagsM,
    ColorChannelFlagsY,
    ColorChannelFlagsK,
    ColorChannelFlagsLast
  );
  TColorChannelFlags = ColorChannelFlags;

//----------------------------------------------------------------------------
// Color Adjust Type
//----------------------------------------------------------------------------

  //{$EXTERNALSYM ColorAdjustType}
  ColorAdjustType = (
    ColorAdjustTypeDefault,
    ColorAdjustTypeBitmap,
    ColorAdjustTypeBrush,
    ColorAdjustTypePen,
    ColorAdjustTypeText,
    ColorAdjustTypeCount,
    ColorAdjustTypeAny      // Reserved
  );
  TColorAdjustType = ColorAdjustType;

//--------------------------------------------------------------------------
// FontStyle: face types and common styles
//--------------------------------------------------------------------------
type
  //{$EXTERNALSYM FontStyle}
  FontStyle = Integer;
  const
    FontStyleRegular    = Integer(0);
    FontStyleBold       = Integer(1);
    FontStyleItalic     = Integer(2);
    FontStyleBoldItalic = Integer(3);
    FontStyleUnderline  = Integer(4);
    FontStyleStrikeout  = Integer(8);
  Type
  TFontStyle = FontStyle;

//---------------------------------------------------------------------------
// Smoothing Mode
//---------------------------------------------------------------------------
{$IFDEF DELPHI6_UP}
  //{$EXTERNALSYM SmoothingMode}
  SmoothingMode = (
    SmoothingModeInvalid     = ord(QualityModeInvalid),
    SmoothingModeDefault     = ord(QualityModeDefault),
    SmoothingModeHighSpeed   = ord(QualityModeLow),
    SmoothingModeHighQuality = ord(QualityModeHigh),
    SmoothingModeNone,
    SmoothingModeAntiAlias
  );
  TSmoothingMode = SmoothingMode;
{$ELSE}
  SmoothingMode = Integer;
  const
    SmoothingModeInvalid     = QualityModeInvalid;
    SmoothingModeDefault     = QualityModeDefault;
    SmoothingModeHighSpeed   = QualityModeLow;
    SmoothingModeHighQuality = QualityModeHigh;
    SmoothingModeNone        = 3;
    SmoothingModeAntiAlias   = 4;

type
  TSmoothingMode = SmoothingMode;

{$ENDIF}

{$IFDEF DELPHI6_UP}
  //{$EXTERNALSYM PixelOffsetMode}
  PixelOffsetMode = (
    PixelOffsetModeInvalid     = Ord(QualityModeInvalid),
    PixelOffsetModeDefault     = Ord(QualityModeDefault),
    PixelOffsetModeHighSpeed   = Ord(QualityModeLow),
    PixelOffsetModeHighQuality = Ord(QualityModeHigh),
    PixelOffsetModeNone,    // No pixel offset
    PixelOffsetModeHalf     // Offset by -0.5, -0.5 for fast anti-alias perf
  );
  TPixelOffsetMode = PixelOffsetMode;
{$ELSE}
  //{$EXTERNALSYM PixelOffsetMode}
  PixelOffsetMode = Integer;
  const
    PixelOffsetModeInvalid     = QualityModeInvalid;
    PixelOffsetModeDefault     = QualityModeDefault;
    PixelOffsetModeHighSpeed   = QualityModeLow;
    PixelOffsetModeHighQuality = QualityModeHigh;
    PixelOffsetModeNone        = 3;    // No pixel offset
    PixelOffsetModeHalf        = 4;    // Offset by -0.5, -0.5 for fast anti-alias perf

type
  TPixelOffsetMode = PixelOffsetMode;
{$ENDIF}


//---------------------------------------------------------------------------
// Text Rendering Hint
//---------------------------------------------------------------------------

  TextRenderingHint = (
    TextRenderingHintSystemDefault,                // Glyph with system default rendering hint
    TextRenderingHintSingleBitPerPixelGridFit,     // Glyph bitmap with hinting
    TextRenderingHintSingleBitPerPixel,            // Glyph bitmap without hinting
    TextRenderingHintAntiAliasGridFit,             // Glyph anti-alias bitmap with hinting
    TextRenderingHintAntiAlias,                    // Glyph anti-alias bitmap without hinting
    TextRenderingHintClearTypeGridFit              // Glyph CT bitmap with hinting
  );
  TTextRenderingHint = TextRenderingHint;

//---------------------------------------------------------------------------
// StringFormatFlags
//---------------------------------------------------------------------------

//---------------------------------------------------------------------------
// String format flags
//
//  DirectionRightToLeft          - For horizontal text, the reading order is
//                                  right to left. This value is called
//                                  the base embedding level by the Unicode
//                                  bidirectional engine.
//                                  For vertical text, columns are read from
//                                  right to left.
//                                  By default, horizontal or vertical text is
//                                  read from left to right.
//
//  DirectionVertical             - Individual lines of text are vertical. In
//                                  each line, characters progress from top to
//                                  bottom.
//                                  By default, lines of text are horizontal,
//                                  each new line below the previous line.
//
//  NoFitBlackBox                 - Allows parts of glyphs to overhang the
//                                  bounding rectangle.
//                                  By default glyphs are first aligned
//                                  inside the margines, then any glyphs which
//                                  still overhang the bounding box are
//                                  repositioned to avoid any overhang.
//                                  For example when an italic
//                                  lower case letter f in a font such as
//                                  Garamond is aligned at the far left of a
//                                  rectangle, the lower part of the f will
//                                  reach slightly further left than the left
//                                  edge of the rectangle. Setting this flag
//                                  will ensure the character aligns visually
//                                  with the lines above and below, but may
//                                  cause some pixels outside the formatting
//                                  rectangle to be clipped or painted.
//
//  DisplayFormatControl          - Causes control characters such as the
//                                  left-to-right mark to be shown in the
//                                  output with a representative glyph.
//
//  NoFontFallback                - Disables fallback to alternate fonts for
//                                  characters not supported in the requested
//                                  font. Any missing characters will be
//                                  be displayed with the fonts missing glyph,
//                                  usually an open square.
//
//  NoWrap                        - Disables wrapping of text between lines
//                                  when formatting within a rectangle.
//                                  NoWrap is implied when a point is passed
//                                  instead of a rectangle, or when the
//                                  specified rectangle has a zero line length.
//
//  NoClip                        - By default text is clipped to the
//                                  formatting rectangle. Setting NoClip
//                                  allows overhanging pixels to affect the
//                                  device outside the formatting rectangle.
//                                  Pixels at the end of the line may be
//                                  affected if the glyphs overhang their
//                                  cells, and either the NoFitBlackBox flag
//                                  has been set, or the glyph extends to far
//                                  to be fitted.
//                                  Pixels above/before the first line or
//                                  below/after the last line may be affected
//                                  if the glyphs extend beyond their cell
//                                  ascent / descent. This can occur rarely
//                                  with unusual diacritic mark combinations.

//---------------------------------------------------------------------------

Type

//---------------------------------------------------------------------------
// String alignment flags
//---------------------------------------------------------------------------

  StringAlignment = (
    // Left edge for left-to-right text,
    // right for right-to-left text,
    // and top for vertical
    StringAlignmentNear,
    StringAlignmentCenter,
    StringAlignmentFar
  );
  TStringAlignment = StringAlignment;

//STRINGFORMAT

  {$EXTERNALSYM StringFormatFlags}
  StringFormatFlags = Integer;
  const
    StringFormatFlagsDirectionRightToLeft        = $00000001;
    StringFormatFlagsDirectionVertical           = $00000002;
    StringFormatFlagsNoFitBlackBox               = $00000004;
    StringFormatFlagsDisplayFormatControl        = $00000020;
    StringFormatFlagsNoFontFallback              = $00000400;
    StringFormatFlagsMeasureTrailingSpaces       = $00000800;
    StringFormatFlagsNoWrap                      = $00001000;
    StringFormatFlagsLineLimit                   = $00002000;

    StringFormatFlagsNoClip                      = $00004000;

Type
  TStringFormatFlags = StringFormatFlags;


//---------------------------------------------------------------------------
// Trimming  flags
//---------------------------------------------------------------------------

  StringTrimming = (
    {
    #define GDIPLUS_STRINGTRIMMING_None 0 && no trimming.
    #define GDIPLUS_STRINGTRIMMING_Character 1 && nearest character.
    #define GDIPLUS_STRINGTRIMMING_Word 2 && nearest wor
    #define GDIPLUS_STRINGTRIMMING_EllipsisCharacter 3 && nearest character, ellipsis at end
    #define GDIPLUS_STRINGTRIMMING_EllipsisWord 4 && nearest word, ellipsis at end
    #define GDIPLUS_STRINGTRIMMING_EllipsisPath 5 && ellipsis in center, favouring last slash-delimited segment
    }
    StringTrimmingNone,
    StringTrimmingCharacter,
    StringTrimmingWord,
    StringTrimmingEllipsisCharacter,
    StringTrimmingEllipsisWord,
    StringTrimmingEllipsisPath
  );
  TStringTrimming = StringTrimming;

//---------------------------------------------------------------------------
// Hotkey prefix interpretation
//---------------------------------------------------------------------------

  HotkeyPrefix = (
    HotkeyPrefixNone,
    HotkeyPrefixShow,
    HotkeyPrefixHide
  );
  THotkeyPrefix = HotkeyPrefix;

//---------------------------------------------------------------------------
// Flush Intention flags
//---------------------------------------------------------------------------

  FlushIntention = (
    FlushIntentionFlush,  // Flush all batched rendering operations
    FlushIntentionSync    // Flush all batched rendering operations
                          // and wait for them to complete
  );
  TFlushIntention = FlushIntention;

//--------------------------------------------------------------------------
// Status return values from GDI+ methods
//--------------------------------------------------------------------------
type
  Status = (
    Ok,
    GenericError,
    InvalidParameter,
    OutOfMemory,
    ObjectBusy,
    InsufficientBuffer,
    NotImplemented,
    Win32Error,
    WrongState,
    Aborted,
    FileNotFound,
    ValueOverflow,
    AccessDenied,
    UnknownImageFormat,
    FontFamilyNotFound,
    FontStyleNotFound,
    NotTrueTypeFont,
    UnsupportedGdiplusVersion,
    GdiplusNotInitialized,
    PropertyNotFound,
    PropertyNotSupported
  );
  TStatus = Status;

//--------------------------------------------------------------------------
// Represents a location in a 2D coordinate system (floating-point coordinates)
//--------------------------------------------------------------------------

type
  PGPPointF = ^TGPPointF;
  TGPPointF = packed record
    X : Single;
    Y : Single;
  end;
  TPointFDynArray = array of TGPPointF;

  function MakePoint(X, Y: Single): TGPPointF; overload;

//--------------------------------------------------------------------------
// Represents a location in a 2D coordinate system (integer coordinates)
//--------------------------------------------------------------------------

type
  PGPPoint = ^TGPPoint;
  TGPPoint = packed record
    X : Integer;
    Y : Integer;
  end;
  TPointDynArray = array of TGPPoint;

  function MakePoint(X, Y: Integer): TGPPoint; overload;

//--------------------------------------------------------------------------
// Represents a rectangle in a 2D coordinate system (floating-point coordinates)
//--------------------------------------------------------------------------

type
  PGPRectF = ^TGPRectF;
  TGPRectF = packed record
    X     : Single;
    Y     : Single;
    Width : Single;
    Height: Single;
  end;
  TRectFDynArray = array of TGPRectF;

  function MakeRect(x, y, width, height: Single): TGPRectF; overload;

type
  PGPRect = ^TGPRect;
  TGPRect = packed record
    X     : Integer;
    Y     : Integer;
    Width : Integer;
    Height: Integer;
  end;
  TRectDynArray = array of TGPRect;



(**************************************************************************
*
*   GDI+ Startup and Shutdown APIs
*
**************************************************************************)
type
  DebugEventLevel = (
    DebugEventLevelFatal,
    DebugEventLevelWarning
  );
  TDebugEventLevel = DebugEventLevel;

  // Callback function that GDI+ can call, on debug builds, for assertions
  // and warnings.

  DebugEventProc = procedure(level: DebugEventLevel; message: PChar); stdcall;

  // Notification functions which the user must call appropriately if
  // "SuppressBackgroundThread" (below) is set.

  NotificationHookProc = function(out token: ULONG): Status; stdcall;

  NotificationUnhookProc = procedure(token: ULONG); stdcall;

  // Input structure for GdiplusStartup

  GdiplusStartupInput = packed record
    GdiplusVersion          : Cardinal;       // Must be 1
    DebugEventCallback      : DebugEventProc; // Ignored on free builds
    SuppressBackgroundThread: BOOL;           // FALSE unless you're prepared to call
                                              // the hook/unhook functions properly
    SuppressExternalCodecs  : BOOL;           // FALSE unless you want GDI+ only to use
  end;                                        // its internal image codecs.

  TGdiplusStartupInput = GdiplusStartupInput;
  PGdiplusStartupInput = ^TGdiplusStartupInput;

  // Output structure for GdiplusStartup()

  GdiplusStartupOutput = packed record
    // The following 2 fields are NULL if SuppressBackgroundThread is FALSE.
    // Otherwise, they are functions which must be called appropriately to
    // replace the background thread.
    //
    // These should be called on the application's main message loop - i.e.
    // a message loop which is active for the lifetime of GDI+.
    // "NotificationHook" should be called before starting the loop,
    // and "NotificationUnhook" should be called after the loop ends.

    NotificationHook  : NotificationHookProc;
    NotificationUnhook: NotificationUnhookProc;
  end;
  TGdiplusStartupOutput = GdiplusStartupOutput;
  PGdiplusStartupOutput = ^TGdiplusStartupOutput;

  // GDI+ initialization. Must not be called from DllMain - can cause deadlock.
  //
  // Must be called before GDI+ API's or constructors are used.
  //
  // token  - may not be NULL - accepts a token to be passed in the corresponding
  //          GdiplusShutdown call.
  // input  - may not be NULL
  // output - may be NULL only if input->SuppressBackgroundThread is FALSE.

 {$EXTERNALSYM GdiplusStartup}
 function GdiplusStartup(out token: ULONG; input: PGdiplusStartupInput;
   output: PGdiplusStartupOutput): Status; stdcall;

  // GDI+ termination. Must be called before GDI+ is unloaded.
  // Must not be called from DllMain - can cause deadlock.
  //
  // GDI+ API's may not be called after GdiplusShutdown. Pay careful attention
  // to GDI+ object destructors.

  {$EXTERNALSYM GdiplusShutdown}
  procedure GdiplusShutdown(token: ULONG); stdcall;

type
  PARGB  = ^ARGB;
  ARGB   = DWORD;
  {$EXTERNALSYM ARGB}

type
  PGPColor = ^TGPColor;
  {$EXTERNALSYM TGPCOLOR}
  TGPColor = ARGB;

  TColorDynArray = array of TGPColor;


  function MakeColor(r, g, b: Byte): ARGB; overload;
  function MakeColor(a, r, g, b: Byte): ARGB; overload;
  function MakeColor(a: Byte; Color: TColor): ARGB; overload;
  function GetAlpha(color: ARGB): BYTE;
  function GetRed(color: ARGB): BYTE;
  function GetGreen(color: ARGB): BYTE;
  function GetBlue(color: ARGB): BYTE;

const
  // Shift count and bit mask for A, R, G, B
  AlphaShift  = 24;
  {$EXTERNALSYM AlphaShift}
  RedShift    = 16;
  {$EXTERNALSYM RedShift}
  GreenShift  = 8;
  {$EXTERNALSYM GreenShift}
  BlueShift   = 0;
  {$EXTERNALSYM BlueShift}

  AlphaMask   = $ff000000;
  {$EXTERNALSYM AlphaMask}
  RedMask     = $00ff0000;
  {$EXTERNALSYM RedMask}
  GreenMask   = $0000ff00;
  {$EXTERNALSYM GreenMask}
  BlueMask    = $000000ff;
  {$EXTERNALSYM BlueMask}

type
  PixelFormat = Integer;
  {$EXTERNALSYM PixelFormat}
  TPixelFormat = PixelFormat;

const
  PixelFormatIndexed     = $00010000; // Indexes into a palette
  {$EXTERNALSYM PixelFormatIndexed}
  PixelFormatGDI         = $00020000; // Is a GDI-supported format
  {$EXTERNALSYM PixelFormatGDI}
  PixelFormatAlpha       = $00040000; // Has an alpha component
  {$EXTERNALSYM PixelFormatAlpha}
  PixelFormatPAlpha      = $00080000; // Pre-multiplied alpha
  {$EXTERNALSYM PixelFormatPAlpha}
  PixelFormatExtended    = $00100000; // Extended color 16 bits/channel
  {$EXTERNALSYM PixelFormatExtended}
  PixelFormatCanonical   = $00200000;
  {$EXTERNALSYM PixelFormatCanonical}

  PixelFormatUndefined      = 0;
  {$EXTERNALSYM PixelFormatUndefined}
  PixelFormatDontCare       = 0;
  {$EXTERNALSYM PixelFormatDontCare}

  PixelFormat1bppIndexed    = (1  or ( 1 shl 8) or PixelFormatIndexed or PixelFormatGDI);
  {$EXTERNALSYM PixelFormat1bppIndexed}
  PixelFormat4bppIndexed    = (2  or ( 4 shl 8) or PixelFormatIndexed or PixelFormatGDI);
  {$EXTERNALSYM PixelFormat4bppIndexed}
  PixelFormat8bppIndexed    = (3  or ( 8 shl 8) or PixelFormatIndexed or PixelFormatGDI);
  {$EXTERNALSYM PixelFormat8bppIndexed}
  PixelFormat16bppGrayScale = (4  or (16 shl 8) or PixelFormatExtended);
  {$EXTERNALSYM PixelFormat16bppGrayScale}
  PixelFormat16bppRGB555    = (5  or (16 shl 8) or PixelFormatGDI);
  {$EXTERNALSYM PixelFormat16bppRGB555}
  PixelFormat16bppRGB565    = (6  or (16 shl 8) or PixelFormatGDI);
  {$EXTERNALSYM PixelFormat16bppRGB565}
  PixelFormat16bppARGB1555  = (7  or (16 shl 8) or PixelFormatAlpha or PixelFormatGDI);
  {$EXTERNALSYM PixelFormat16bppARGB1555}
  PixelFormat24bppRGB       = (8  or (24 shl 8) or PixelFormatGDI);
  {$EXTERNALSYM PixelFormat24bppRGB}
  PixelFormat32bppRGB       = (9  or (32 shl 8) or PixelFormatGDI);
  {$EXTERNALSYM PixelFormat32bppRGB}
  PixelFormat32bppARGB      = (10 or (32 shl 8) or PixelFormatAlpha or PixelFormatGDI or PixelFormatCanonical);
  {$EXTERNALSYM PixelFormat32bppARGB}
  PixelFormat32bppPARGB     = (11 or (32 shl 8) or PixelFormatAlpha or PixelFormatPAlpha or PixelFormatGDI);
  {$EXTERNALSYM PixelFormat32bppPARGB}
  PixelFormat48bppRGB       = (12 or (48 shl 8) or PixelFormatExtended);
  {$EXTERNALSYM PixelFormat48bppRGB}
  PixelFormat64bppARGB      = (13 or (64 shl 8) or PixelFormatAlpha  or PixelFormatCanonical or PixelFormatExtended);
  {$EXTERNALSYM PixelFormat64bppARGB}
  PixelFormat64bppPARGB     = (14 or (64 shl 8) or PixelFormatAlpha  or PixelFormatPAlpha or PixelFormatExtended);
  {$EXTERNALSYM PixelFormat64bppPARGB}
  PixelFormatMax            = 15;
  {$EXTERNALSYM PixelFormatMax}

type

{$IFDEF DELPHI6_UP}
  RotateFlipType = (
    RotateNoneFlipNone = 0,
    Rotate90FlipNone   = 1,
    Rotate180FlipNone  = 2,
    Rotate270FlipNone  = 3,

    RotateNoneFlipX    = 4,
    Rotate90FlipX      = 5,
    Rotate180FlipX     = 6,
    Rotate270FlipX     = 7,

    RotateNoneFlipY    = Rotate180FlipX,
    Rotate90FlipY      = Rotate270FlipX,
    Rotate180FlipY     = RotateNoneFlipX,
    Rotate270FlipY     = Rotate90FlipX,

    RotateNoneFlipXY   = Rotate180FlipNone,
    Rotate90FlipXY     = Rotate270FlipNone,
    Rotate180FlipXY    = RotateNoneFlipNone,
    Rotate270FlipXY    = Rotate90FlipNone
  );
  TRotateFlipType = RotateFlipType;
{$ELSE}

  RotateFlipType = (
    RotateNoneFlipNone, // = 0,
    Rotate90FlipNone,   // = 1,
    Rotate180FlipNone,  // = 2,
    Rotate270FlipNone,  // = 3,

    RotateNoneFlipX,    // = 4,
    Rotate90FlipX,      // = 5,
    Rotate180FlipX,     // = 6,
    Rotate270FlipX      // = 7,
  );
  const
    RotateNoneFlipY    = Rotate180FlipX;
    Rotate90FlipY      = Rotate270FlipX;
    Rotate180FlipY     = RotateNoneFlipX;
    Rotate270FlipY     = Rotate90FlipX;

    RotateNoneFlipXY   = Rotate180FlipNone;
    Rotate90FlipXY     = Rotate270FlipNone;
    Rotate180FlipXY    = RotateNoneFlipNone;
    Rotate270FlipXY    = Rotate90FlipNone;

    //---------------------------------------------------------------------------
// Encoder parameter sets
//---------------------------------------------------------------------------

  EncoderCompression      : TGUID = '{e09d739d-ccd4-44ee-8eba-3fbf8be4fc58}';
  {$EXTERNALSYM EncoderCompression}
  EncoderColorDepth       : TGUID = '{66087055-ad66-4c7c-9a18-38a2310b8337}';
  {$EXTERNALSYM EncoderColorDepth}
  EncoderScanMethod       : TGUID = '{3a4e2661-3109-4e56-8536-42c156e7dcfa}';
  {$EXTERNALSYM EncoderScanMethod}
  EncoderVersion          : TGUID = '{24d18c76-814a-41a4-bf53-1c219cccf797}';
  {$EXTERNALSYM EncoderVersion}
  EncoderRenderMethod     : TGUID = '{6d42c53a-229a-4825-8bb7-5c99e2b9a8b8}';
  {$EXTERNALSYM EncoderRenderMethod}
  EncoderQuality          : TGUID = '{1d5be4b5-fa4a-452d-9cdd-5db35105e7eb}';
  {$EXTERNALSYM EncoderQuality}
  EncoderTransformation   : TGUID = '{8d0eb2d1-a58e-4ea8-aa14-108074b7b6f9}';
  {$EXTERNALSYM EncoderTransformation}
  EncoderLuminanceTable   : TGUID = '{edb33bce-0266-4a77-b904-27216099e717}';
  {$EXTERNALSYM EncoderLuminanceTable}
  EncoderChrominanceTable : TGUID = '{f2e455dc-09b3-4316-8260-676ada32481c}';
  {$EXTERNALSYM EncoderChrominanceTable}
  EncoderSaveFlag         : TGUID = '{292266fc-ac40-47bf-8cfc-a85b89a655de}';
  {$EXTERNALSYM EncoderSaveFlag}

  CodecIImageBytes : TGUID = '{025d1823-6c7d-447b-bbdb-a3cbc3dfa2fc}';
  {$EXTERNALSYM CodecIImageBytes}

type
  TRotateFlipType = RotateFlipType;
{$ENDIF}



//---------------------------------------------------------------------------
// Image encoder parameter related types
//---------------------------------------------------------------------------

  {$EXTERNALSYM EncoderParameterValueType}
  EncoderParameterValueType = Integer;
  const
    EncoderParameterValueTypeByte          : Integer = 1;    // 8-bit unsigned int
    EncoderParameterValueTypeASCII         : Integer = 2;    // 8-bit byte containing one 7-bit ASCII
                                                             // code. NULL terminated.
    EncoderParameterValueTypeShort         : Integer = 3;    // 16-bit unsigned int
    EncoderParameterValueTypeLong          : Integer = 4;    // 32-bit unsigned int
    EncoderParameterValueTypeRational      : Integer = 5;    // Two Longs. The first Long is the
                                                             // numerator, the second Long expresses the
                                                             // denomintor.
    EncoderParameterValueTypeLongRange     : Integer = 6;    // Two longs which specify a range of
                                                             // integer values. The first Long specifies
                                                             // the lower end and the second one
                                                             // specifies the higher end. All values
                                                             // are inclusive at both ends
    EncoderParameterValueTypeUndefined     : Integer = 7;    // 8-bit byte that can take any value
                                                             // depending on field definition
    EncoderParameterValueTypeRationalRange : Integer = 8;    // Two Rationals. The first Rational
                                                             // specifies the lower end and the second
                                                             // specifies the higher end. All values
                                                             // are inclusive at both ends
type
  TEncoderParameterValueType = EncoderParameterValueType;

  //---------------------------------------------------------------------------
// Image encoder value types
//---------------------------------------------------------------------------

  //{$EXTERNALSYM EncoderValue}
  EncoderValue = (
    EncoderValueColorTypeCMYK,
    EncoderValueColorTypeYCCK,
    EncoderValueCompressionLZW,
    EncoderValueCompressionCCITT3,
    EncoderValueCompressionCCITT4,
    EncoderValueCompressionRle,
    EncoderValueCompressionNone,
    EncoderValueScanMethodInterlaced,
    EncoderValueScanMethodNonInterlaced,
    EncoderValueVersionGif87,
    EncoderValueVersionGif89,
    EncoderValueRenderProgressive,
    EncoderValueRenderNonProgressive,
    EncoderValueTransformRotate90,
    EncoderValueTransformRotate180,
    EncoderValueTransformRotate270,
    EncoderValueTransformFlipHorizontal,
    EncoderValueTransformFlipVertical,
    EncoderValueMultiFrame,
    EncoderValueLastFrame,
    EncoderValueFlush,
    EncoderValueFrameDimensionTime,
    EncoderValueFrameDimensionResolution,
    EncoderValueFrameDimensionPage
  );
  TEncoderValue = EncoderValue;

//---------------------------------------------------------------------------
// Encoder Parameter structure
//---------------------------------------------------------------------------

  //{$EXTERNALSYM EncoderParameter}
  EncoderParameter = packed record
    Guid           : TGUID;   // GUID of the parameter
    NumberOfValues : ULONG;   // Number of the parameter values
    Type_          : ULONG;   // Value type, like ValueTypeLONG  etc.
    Value          : Pointer; // A pointer to the parameter values
  end;
  TEncoderParameter = EncoderParameter;
  PEncoderParameter = ^TEncoderParameter;

//---------------------------------------------------------------------------
// Encoder Parameters structure
//---------------------------------------------------------------------------

  //{$EXTERNALSYM EncoderParameters}
  EncoderParameters = packed record
    Count     : UINT;               // Number of parameters in this structure
    Parameter : array[0..0] of TEncoderParameter;  // Parameter values
  end;
  TEncoderParameters = EncoderParameters;
  PEncoderParameters = ^TEncoderParameters;

//----------------------------------------------------------------------------
// Color Map
//----------------------------------------------------------------------------

  //{$EXTERNALSYM ColorMap}
  ColorMap = packed record
    oldColor: TGPColor;
    newColor: TGPColor;
  end;
  TColorMap = ColorMap;
  PColorMap = ^TColorMap;

  //{$EXTERNALSYM ColorPalette}
  ColorPalette = packed record
    Flags  : UINT ;                 // Palette flags
    Count  : UINT ;                 // Number of color entries
    Entries: array [0..0] of ARGB ; // Palette color entries
  end;

  TColorPalette = ColorPalette;
  PColorPalette = ^TColorPalette;


//---------------------------------------------------------------------------
// Private GDI+ classes for internal type checking
//---------------------------------------------------------------------------

  GpGraphics = Pointer;

  GpBrush = Pointer;
  GpSolidFill = Pointer;
  GpLineGradient = Pointer;
  GpPathGradient = Pointer;
  GpHatch =  Pointer;
  GpTexture = Pointer;
  GpMatrix = Pointer;
  GpImageAttributes = Pointer;

  GpPen = Pointer;

  GpPenType = TPenType;

  GpImage = Pointer;
  GpBitmap = Pointer;

  GpPath = Pointer;
  GpRegion = Pointer;

  GpFontFamily = Pointer;
  GpFont = Pointer;
  GpStringFormat = Pointer;
  GpFontCollection = Pointer;

  GpStatus          = TStatus;
  GpFillMode        = TFillMode;
  GpWrapMode        = TWrapMode;
  GpUnit            = TUnit;
  GpPointF          = PGPPointF;
  GpPoint           = PGPPoint;
  GpRectF           = PGPRectF;
  GpRect            = PGPRect;
  GpDashStyle       = TDashStyle;
  GpLineCap         = TLineCap;
  GpHatchStyle      = THatchStyle;
  GpFlushIntention  = TFlushIntention;
  GpMatrixOrder     = TMatrixOrder;

  function GdipCreatePath(brushMode: GPFILLMODE;
    out path: GPPATH): GPSTATUS; stdcall;
  {$EXTERNALSYM GdipCreatePath}

 (* function GdipClonePath(path: GPPATH;
    out clonePath: GPPATH): GPSTATUS; stdcall;
  {$EXTERNALSYM GdipClonePath}
 *)
  function GdipDeletePath(path: GPPATH): GPSTATUS; stdcall;
  {$EXTERNALSYM GdipDeletePath}
 (*
  function GdipStartPathFigure(path: GPPATH): GPSTATUS; stdcall;
  {$EXTERNALSYM GdipStartPathFigure}
 *)
  function GdipClosePathFigure(path: GPPATH): GPSTATUS; stdcall;
  {$EXTERNALSYM GdipClosePathFigure}

  function GdipAddPathLine(path: GPPATH;
    x1, y1, x2, y2: Single): GPSTATUS; stdcall;
  {$EXTERNALSYM GdipAddPathLine}

  function GdipAddPathArc(path: GPPATH; x, y, width, height, startAngle,
    sweepAngle: Single): GPSTATUS; stdcall;
  {$EXTERNALSYM GdipAddPathArc}

  function GdipAddPathEllipse(path: GPPATH;  x: Single; y: Single;
    width: Single; height: Single): GPSTATUS; stdcall;
  {$EXTERNALSYM GdipAddPathEllipse}

  function GdipAddPathPie(path: GPPATH; x: Single; y: Single; width: Single;
    height: Single; startAngle: Single; sweepAngle: Single): GPSTATUS; stdcall;
  {$EXTERNALSYM GdipAddPathPie}

  function GdipAddPathRectangle(path: GPPATH; x: Single; y: Single;
    width: Single; height: Single): GPSTATUS; stdcall;
  {$EXTERNALSYM GdipAddPathRectangle}

  function GdipAddPathRectangleI(path: GPPATH; x: Integer; y: Integer;
    width: Integer; height: Integer): GPSTATUS; stdcall;
  {$EXTERNALSYM GdipAddPathRectangleI}

  function GdipDrawEllipse(graphics: GPGRAPHICS; pen: GPPEN; x: Single;
    y: Single; width: Single; height: Single): GPSTATUS; stdcall;
  {$EXTERNALSYM GdipDrawEllipse}

  function GdipDrawEllipseI(graphics: GPGRAPHICS; pen: GPPEN; x: Integer;
    y: Integer; width: Integer; height: Integer): GPSTATUS; stdcall;
  {$EXTERNALSYM GdipDrawEllipseI}



//----------------------------------------------------------------------------
// Brush APIs
//----------------------------------------------------------------------------

  function GdipDeleteBrush(brush: GPBRUSH): GPSTATUS; stdcall;
  {$EXTERNALSYM GdipDeleteBrush}

//----------------------------------------------------------------------------
// SolidBrush APIs
//----------------------------------------------------------------------------

  function GdipCreateSolidFill(color: ARGB;
    out brush: GPSOLIDFILL): GPSTATUS; stdcall;
  {$EXTERNALSYM GdipCreateSolidFill}

//----------------------------------------------------------------------------
// Hatch Brush APIs
//----------------------------------------------------------------------------

  function GdipCreateHatchBrush(hatchstyle: Integer; forecol: ARGB;
    backcol: ARGB; out brush: GPHATCH): GPSTATUS; stdcall;
  {$EXTERNALSYM GdipCreateHatchBrush}

  function GdipGetHatchStyle(brush: GPHATCH;
    out hatchstyle: GPHATCHSTYLE): GPSTATUS; stdcall;
  {$EXTERNALSYM GdipGetHatchStyle}

  function GdipGetHatchForegroundColor(brush: GPHATCH;
    out forecol: ARGB): GPSTATUS; stdcall;
  {$EXTERNALSYM GdipGetHatchForegroundColor}

  function GdipGetHatchBackgroundColor(brush: GPHATCH;
    out backcol: ARGB): GPSTATUS; stdcall;
  {$EXTERNALSYM GdipGetHatchBackgroundColor}


//----------------------------------------------------------------------------
// LineBrush APIs
//----------------------------------------------------------------------------

  function GdipCreateLineBrushFromRect(rect: GPRECTF; color1: ARGB;
    color2: ARGB; mode: LINEARGRADIENTMODE; wrapMode: GPWRAPMODE;
    out lineGradient: GPLINEGRADIENT): GPSTATUS; stdcall;
  {$EXTERNALSYM GdipCreateLineBrushFromRect}

  function GdipCreateLineBrushFromRectI(rect: GPRECT; color1: ARGB;
    color2: ARGB; mode: LINEARGRADIENTMODE; wrapMode: GPWRAPMODE;
    out lineGradient: GPLINEGRADIENT): GPSTATUS; stdcall;
  {$EXTERNALSYM GdipCreateLineBrushFromRectI}

  function GdipCreateLineBrushFromRectWithAngle(rect: GPRECTF; color1: ARGB;
    color2: ARGB; angle: Single; isAngleScalable: Bool; wrapMode: GPWRAPMODE;
    out lineGradient: GPLINEGRADIENT): GPSTATUS; stdcall;
  {$EXTERNALSYM GdipCreateLineBrushFromRectWithAngle}

  function GdipCreateLineBrushFromRectWithAngleI(rect: GPRECT; color1: ARGB;
    color2: ARGB; angle: Single; isAngleScalable: Bool; wrapMode: GPWRAPMODE;
    out lineGradient: GPLINEGRADIENT): GPSTATUS; stdcall;
  {$EXTERNALSYM GdipCreateLineBrushFromRectWithAngleI}
  

  function GdipSetLineGammaCorrection(brush: GPLINEGRADIENT;
    useGammaCorrection: Bool): GPSTATUS; stdcall;
  {$EXTERNALSYM GdipSetLineGammaCorrection}

  function GdipGetLineGammaCorrection(brush: GPLINEGRADIENT;
    out useGammaCorrection: Bool): GPSTATUS; stdcall;
  {$EXTERNALSYM GdipGetLineGammaCorrection}

  function GdipGetLineBlendCount(brush: GPLINEGRADIENT;
    out count: Integer): GPSTATUS; stdcall;
  {$EXTERNALSYM GdipGetLineBlendCount}

  function GdipGetLineBlend(brush: GPLINEGRADIENT; blend: PSingle;
    positions: PSingle; count: Integer): GPSTATUS; stdcall;
  {$EXTERNALSYM GdipGetLineBlend}

  function GdipSetLineBlend(brush: GPLINEGRADIENT; blend: PSingle;
    positions: PSingle; count: Integer): GPSTATUS; stdcall;
  {$EXTERNALSYM GdipSetLineBlend}

  function GdipGetLinePresetBlendCount(brush: GPLINEGRADIENT;
    out count: Integer): GPSTATUS; stdcall;
  {$EXTERNALSYM GdipGetLinePresetBlendCount}

  function GdipGetLinePresetBlend(brush: GPLINEGRADIENT; blend: PARGB;
    positions: PSingle; count: Integer): GPSTATUS; stdcall;
  {$EXTERNALSYM GdipGetLinePresetBlend}

  function GdipSetLinePresetBlend(brush: GPLINEGRADIENT; blend: PARGB;
    positions: PSingle; count: Integer): GPSTATUS; stdcall;
  {$EXTERNALSYM GdipSetLinePresetBlend}

  function GdipSetLineSigmaBlend(brush: GPLINEGRADIENT; focus: Single;
    scale: Single): GPSTATUS; stdcall;
  {$EXTERNALSYM GdipSetLineSigmaBlend}

  function GdipSetLineLinearBlend(brush: GPLINEGRADIENT; focus: Single;
    scale: Single): GPSTATUS; stdcall;
  {$EXTERNALSYM GdipSetLineLinearBlend}
  

//----------------------------------------------------------------------------
// PathGradientBrush APIs
//----------------------------------------------------------------------------

  function GdipCreatePathGradient(points: GPPOINTF; count: Integer;
    wrapMode: GPWRAPMODE; out polyGradient: GPPATHGRADIENT): GPSTATUS; stdcall;
  {$EXTERNALSYM GdipCreatePathGradient}

  function GdipCreatePathGradientI(points: GPPOINT; count: Integer;
    wrapMode: GPWRAPMODE; out polyGradient: GPPATHGRADIENT): GPSTATUS; stdcall;
  {$EXTERNALSYM GdipCreatePathGradientI}


  function GdipCreatePathGradientFromPath(path: GPPATH;
    out polyGradient: GPPATHGRADIENT): GPSTATUS; stdcall;
  {$EXTERNALSYM GdipCreatePathGradientFromPath}

  function GdipGetPathGradientCenterColor(brush: GPPATHGRADIENT;
    out colors: ARGB): GPSTATUS; stdcall;
  {$EXTERNALSYM GdipGetPathGradientCenterColor}

  function GdipSetPathGradientCenterColor(brush: GPPATHGRADIENT;
    colors: ARGB): GPSTATUS; stdcall;
  {$EXTERNALSYM GdipSetPathGradientCenterColor}

  function GdipGetPathGradientSurroundColorsWithCount(brush: GPPATHGRADIENT;
    color: PARGB; var count: Integer): GPSTATUS; stdcall;
  {$EXTERNALSYM GdipGetPathGradientSurroundColorsWithCount}

  function GdipSetPathGradientSurroundColorsWithCount(brush: GPPATHGRADIENT;
    color: PARGB; var count: Integer): GPSTATUS; stdcall;
  {$EXTERNALSYM GdipSetPathGradientSurroundColorsWithCount}

  function GdipGetPathGradientCenterPoint(brush: GPPATHGRADIENT;
    points: GPPOINTF): GPSTATUS; stdcall;
  {$EXTERNALSYM GdipGetPathGradientCenterPoint}

  function GdipGetPathGradientCenterPointI(brush: GPPATHGRADIENT;
    points: GPPOINT): GPSTATUS; stdcall;
  {$EXTERNALSYM GdipGetPathGradientCenterPointI}

  function GdipSetPathGradientCenterPoint(brush: GPPATHGRADIENT;
    points: GPPOINTF): GPSTATUS; stdcall;
  {$EXTERNALSYM GdipSetPathGradientCenterPoint}

  function GdipSetPathGradientCenterPointI(brush: GPPATHGRADIENT;
    points: GPPOINT): GPSTATUS; stdcall;
  {$EXTERNALSYM GdipSetPathGradientCenterPointI}

  function GdipGetPathGradientPointCount(brush: GPPATHGRADIENT;
    var count: Integer): GPSTATUS; stdcall;
  {$EXTERNALSYM GdipGetPathGradientPointCount}

  function GdipGetPathGradientSurroundColorCount(brush: GPPATHGRADIENT;
    var count: Integer): GPSTATUS; stdcall;
  {$EXTERNALSYM GdipGetPathGradientSurroundColorCount}

  function GdipSetPathGradientGammaCorrection(brush: GPPATHGRADIENT;
    useGammaCorrection: Bool): GPSTATUS; stdcall;
  {$EXTERNALSYM GdipSetPathGradientGammaCorrection}

  function GdipGetPathGradientGammaCorrection(brush: GPPATHGRADIENT;
    var useGammaCorrection: Bool): GPSTATUS; stdcall;
  {$EXTERNALSYM GdipGetPathGradientGammaCorrection}

  function GdipGetPathGradientWrapMode(brush: GPPATHGRADIENT;
    var wrapmode: GPWRAPMODE): GPSTATUS; stdcall;
  {$EXTERNALSYM GdipGetPathGradientWrapMode}

  function GdipSetPathGradientWrapMode(brush: GPPATHGRADIENT;
    wrapmode: GPWRAPMODE): GPSTATUS; stdcall;
  {$EXTERNALSYM GdipSetPathGradientWrapMode}

  function GdipGetPathGradientBlendCount(brush: GPPATHGRADIENT;
    var count: Integer): GPSTATUS; stdcall;
  {$EXTERNALSYM GdipGetPathGradientBlendCount}

  function GdipGetPathGradientBlend(brush: GPPATHGRADIENT;
    blend: PSingle; positions: PSingle; count: Integer): GPSTATUS; stdcall;
  {$EXTERNALSYM GdipGetPathGradientBlend}

  function GdipSetPathGradientBlend(brush: GPPATHGRADIENT;
    blend: PSingle; positions: PSingle; count: Integer): GPSTATUS; stdcall;
  {$EXTERNALSYM GdipSetPathGradientBlend}

  function GdipGetPathGradientPresetBlendCount(brush: GPPATHGRADIENT;
    var count: Integer): GPSTATUS; stdcall;
  {$EXTERNALSYM GdipGetPathGradientPresetBlendCount}

  function GdipGetPathGradientPresetBlend(brush: GPPATHGRADIENT;
    blend: PARGB; positions: PSingle; count: Integer): GPSTATUS; stdcall;
  {$EXTERNALSYM GdipGetPathGradientPresetBlend}

  function GdipSetPathGradientPresetBlend(brush: GPPATHGRADIENT;
    blend: PARGB; positions: PSingle; count: Integer): GPSTATUS; stdcall;
  {$EXTERNALSYM GdipSetPathGradientPresetBlend}

  function GdipSetPathGradientSigmaBlend(brush: GPPATHGRADIENT;
    focus: Single; scale: Single): GPSTATUS; stdcall;
  {$EXTERNALSYM GdipSetPathGradientSigmaBlend}

  function GdipSetPathGradientLinearBlend(brush: GPPATHGRADIENT;
    focus: Single; scale: Single): GPSTATUS; stdcall;
  {$EXTERNALSYM GdipSetPathGradientLinearBlend}


//----------------------------------------------------------------------------
// TextureBrush APIs
//----------------------------------------------------------------------------

  function GdipCreateTexture(image: GPIMAGE; wrapmode: GPWRAPMODE;
    var texture: GPTEXTURE): GPSTATUS; stdcall;
  {$EXTERNALSYM GdipCreateTexture}

  function GdipCreateTexture2(image: GPIMAGE; wrapmode: GPWRAPMODE;
    x: Single; y: Single; width: Single; height: Single;
    out texture: GPTEXTURE): GPSTATUS; stdcall;
  {$EXTERNALSYM GdipCreateTexture2}

  function GdipCreateTextureIA(image: GPIMAGE;
    imageAttributes: GPIMAGEATTRIBUTES; x: Single; y: Single; width: Single;
    height: Single; out texture: GPTEXTURE): GPSTATUS; stdcall;
  {$EXTERNALSYM GdipCreateTextureIA}

  function GdipCreateTexture2I(image: GPIMAGE; wrapmode: GPWRAPMODE; x: Integer;
    y: Integer; width: Integer; height: Integer;
    out texture: GPTEXTURE): GPSTATUS; stdcall;
  {$EXTERNALSYM GdipCreateTexture2I}

  function GdipCreateTextureIAI(image: GPIMAGE;
    imageAttributes: GPIMAGEATTRIBUTES; x: Integer; y: Integer; width: Integer;
    height: Integer; out texture: GPTEXTURE): GPSTATUS; stdcall;
  {$EXTERNALSYM GdipCreateTextureIAI}

  function GdipGetTextureTransform(brush: GPTEXTURE;
    matrix: GPMATRIX): GPSTATUS; stdcall;
  {$EXTERNALSYM GdipGetTextureTransform}

  function GdipSetTextureTransform(brush: GPTEXTURE;
    matrix: GPMATRIX): GPSTATUS; stdcall;
  {$EXTERNALSYM GdipSetTextureTransform}

  function GdipResetTextureTransform(brush: GPTEXTURE): GPSTATUS; stdcall;
  {$EXTERNALSYM GdipResetTextureTransform}

  function GdipMultiplyTextureTransform(brush: GPTEXTURE; matrix: GPMATRIX;
    order: GPMATRIXORDER): GPSTATUS; stdcall;
  {$EXTERNALSYM GdipMultiplyTextureTransform}

  function GdipTranslateTextureTransform(brush: GPTEXTURE; dx: Single;
    dy: Single; order: GPMATRIXORDER): GPSTATUS; stdcall;
  {$EXTERNALSYM GdipTranslateTextureTransform}

  function GdipScaleTextureTransform(brush: GPTEXTURE; sx: Single; sy: Single;
    order: GPMATRIXORDER): GPSTATUS; stdcall;
  {$EXTERNALSYM GdipScaleTextureTransform}

  function GdipRotateTextureTransform(brush: GPTEXTURE; angle: Single;
    order: GPMATRIXORDER): GPSTATUS; stdcall;
  {$EXTERNALSYM GdipRotateTextureTransform}

  function GdipSetTextureWrapMode(brush: GPTEXTURE;
    wrapmode: GPWRAPMODE): GPSTATUS; stdcall;
  {$EXTERNALSYM GdipSetTextureWrapMode}

  function GdipGetTextureWrapMode(brush: GPTEXTURE;
    var wrapmode: GPWRAPMODE): GPSTATUS; stdcall;
  {$EXTERNALSYM GdipGetTextureWrapMode}

  function GdipGetTextureImage(brush: GPTEXTURE;
    out image: GPIMAGE): GPSTATUS; stdcall;
  {$EXTERNALSYM GdipGetTextureImage}

//----------------------------------------------------------------------------
// Pen APIs
//----------------------------------------------------------------------------

  function GdipCreatePen1(color: ARGB; width: Single; unit_: GPUNIT;
    out pen: GPPEN): GPSTATUS; stdcall;
  {$EXTERNALSYM GdipCreatePen1}

  function GdipCreatePen2(brush: GPBRUSH; width: Single; unit_: GPUNIT;
    out pen: GPPEN): GPSTATUS; stdcall;
  {$EXTERNALSYM GdipCreatePen2}  

  function GdipDeletePen(pen: GPPEN): GPSTATUS; stdcall;
  {$EXTERNALSYM GdipDeletePen}

//----------------------------------------------------------------------------
// Graphics APIs
//----------------------------------------------------------------------------

  function GdipFlush(graphics: GPGRAPHICS;
    intention: GPFLUSHINTENTION): GPSTATUS; stdcall;
  {$EXTERNALSYM GdipFlush}

  function GdipCreateFromHDC(hdc: HDC;
    out graphics: GPGRAPHICS): GPSTATUS; stdcall;
  {$EXTERNALSYM GdipCreateFromHDC}

  function GdipGetImageGraphicsContext(image: GPIMAGE;
  out graphics: GPGRAPHICS): GPSTATUS; stdcall;
  {$EXTERNALSYM GdipGetImageGraphicsContext}

  function GdipGetImagePixelFormat(image: GPIMAGE;
  out format: TPIXELFORMAT): GPSTATUS; stdcall;
  {$EXTERNALSYM GdipGetImagePixelFormat}

  function GdipDeleteGraphics(graphics: GPGRAPHICS): GPSTATUS; stdcall;
  {$EXTERNALSYM GdipDeleteGraphics}

  function GdipGetDC(graphics: GPGRAPHICS; var hdc: HDC): GPSTATUS; stdcall;
  {$EXTERNALSYM GdipGetDC}

  function GdipReleaseDC(graphics: GPGRAPHICS; hdc: HDC): GPSTATUS; stdcall;
  {$EXTERNALSYM GdipReleaseDC}

  function GdipSetInterpolationMode(graphics: GPGRAPHICS;
    interpolationMode: INTERPOLATIONMODE): GPSTATUS; stdcall;
  {$EXTERNALSYM GdipSetInterpolationMode}

  function GdipSetSmoothingMode(graphics: GPGRAPHICS;
    smoothingMode: SMOOTHINGMODE): GPSTATUS; stdcall;
  {$EXTERNALSYM GdipSetSmoothingMode}

  function GdipGetSmoothingMode(graphics: GPGRAPHICS;
    var smoothingMode: SMOOTHINGMODE): GPSTATUS; stdcall;
  {$EXTERNALSYM GdipGetSmoothingMode}

  function GdipSetPixelOffsetMode(graphics: GPGRAPHICS;
    pixelOffsetMode: PIXELOFFSETMODE): GPSTATUS; stdcall;
  {$EXTERNALSYM GdipSetPixelOffsetMode}

  function GdipGetPixelOffsetMode(graphics: GPGRAPHICS;
    var pixelOffsetMode: PIXELOFFSETMODE): GPSTATUS; stdcall;
  {$EXTERNALSYM GdipGetPixelOffsetMode}


  function GdipSetTextRenderingHint(graphics: GPGRAPHICS;
    mode: TEXTRENDERINGHINT): GPSTATUS; stdcall;
  {$EXTERNALSYM GdipSetTextRenderingHint}

  function GdipGetTextRenderingHint(graphics: GPGRAPHICS;
    var mode: TEXTRENDERINGHINT): GPSTATUS; stdcall;
  {$EXTERNALSYM GdipGetTextRenderingHint}

 function GdipFillEllipse(graphics: GPGRAPHICS; brush: GPBRUSH; x: Single;
    y: Single; width: Single; height: Single): GPSTATUS; stdcall;
  {$EXTERNALSYM GdipFillEllipse}

  function GdipFillEllipseI(graphics: GPGRAPHICS; brush: GPBRUSH; x: Integer;
    y: Integer; width: Integer; height: Integer): GPSTATUS; stdcall;
  {$EXTERNALSYM GdipFillEllipseI}

  function GdipFillPolygon(graphics: GPGRAPHICS; brush: GPBRUSH;
    points: GPPOINTF; count: Integer; fillMode: GPFILLMODE): GPSTATUS; stdcall;
  {$EXTERNALSYM GdipFillPolygon}

  function GdipFillPolygonI(graphics: GPGRAPHICS; brush: GPBRUSH;
    points: GPPOINT; count: Integer; fillMode: GPFILLMODE): GPSTATUS; stdcall;
  {$EXTERNALSYM GdipFillPolygonI}

  function GdipCreateLineBrush(point1: GPPOINTF; point2: GPPOINTF; color1: ARGB;
    color2: ARGB; wrapMode: GPWRAPMODE;
    out lineGradient: GPLINEGRADIENT): GPSTATUS; stdcall;
  {$EXTERNALSYM GdipCreateLineBrush}

  function GdipCreateLineBrushI(point1: GPPOINT; point2: GPPOINT; color1: ARGB;
    color2: ARGB; wrapMode: GPWRAPMODE;
    out lineGradient: GPLINEGRADIENT): GPSTATUS; stdcall;
  {$EXTERNALSYM GdipCreateLineBrushI}

  function GdipGetPenFillType(pen: GPPEN;
    out type_: GPPENTYPE): GPSTATUS; stdcall;
  {$EXTERNALSYM GdipGetPenFillType}

  function GdipGetPenBrushFill(pen: GPPEN;
    out brush: GPBRUSH): GPSTATUS; stdcall;
  {$EXTERNALSYM GdipGetPenBrushFill}

  function GdipGraphicsClear(graphics: GPGRAPHICS;
    color: ARGB): GPSTATUS; stdcall;
  {$EXTERNALSYM GdipGraphicsClear}

  function GdipFillRectangle(graphics: GPGRAPHICS; brush: GPBRUSH; x: Single;
    y: Single; width: Single; height: Single): GPSTATUS; stdcall;
  {$EXTERNALSYM GdipFillRectangle}

  function GdipFillRectangleI(graphics: GPGRAPHICS; brush: GPBRUSH; x: Integer;
    y: Integer; width: Integer; height: Integer): GPSTATUS; stdcall;
  {$EXTERNALSYM GdipFillRectangleI}        

  function GdipDrawRectangle(graphics: GPGRAPHICS; pen: GPPEN; x: Single;
    y: Single; width: Single; height: Single): GPSTATUS; stdcall;
  {$EXTERNALSYM GdipDrawRectangle}

  function GdipDrawRectangleI(graphics: GPGRAPHICS; pen: GPPEN; x: Integer;
    y: Integer; width: Integer; height: Integer): GPSTATUS; stdcall;
  {$EXTERNALSYM GdipDrawRectangleI}
  
  function GdipDrawLine(graphics: GPGRAPHICS; pen: GPPEN; x1: Single;
    y1: Single; x2: Single; y2: Single): GPSTATUS; stdcall;
  {$EXTERNALSYM GdipDrawLine}

  function GdipDrawLineI(graphics: GPGRAPHICS; pen: GPPEN; x1: Integer;
    y1: Integer; x2: Integer; y2: Integer): GPSTATUS; stdcall;
  {$EXTERNALSYM GdipDrawLineI}

  function GdipDrawArc(graphics: GPGRAPHICS; pen: GPPEN; x: Single; y: Single;
    width: Single; height: Single; startAngle: Single;
    sweepAngle: Single): GPSTATUS; stdcall;
  {$EXTERNALSYM GdipDrawArc}

  function GdipDrawArcI(graphics: GPGRAPHICS; pen: GPPEN; x: Integer;
    y: Integer; width: Integer; height: Integer; startAngle: Single;
    sweepAngle: Single): GPSTATUS; stdcall;
  {$EXTERNALSYM GdipDrawArcI}

  function GdipDrawPath(graphics: GPGRAPHICS; pen: GPPEN;
    path: GPPATH): GPSTATUS; stdcall;
  {$EXTERNALSYM GdipDrawPath}

  function GdipFillPath(graphics: GPGRAPHICS; brush: GPBRUSH;
    path: GPPATH): GPSTATUS; stdcall;
  {$EXTERNALSYM GdipFillPath}

  function GdipDrawImageI(graphics: GPGRAPHICS; image: GPIMAGE; x: Integer;
    y: Integer): GPSTATUS; stdcall;
  {$EXTERNALSYM GdipDrawImageI}

  function GdipDrawImage(graphics: GPGRAPHICS; image: GPIMAGE; x: Single;
    y: Single): GPSTATUS; stdcall;
  {$EXTERNALSYM GdipDrawImage}

  function GdipDrawImageRect(graphics: GPGRAPHICS; image: GPIMAGE; x: Single;
    y: Single; width: Single; height: Single): GPSTATUS; stdcall;
  {$EXTERNALSYM GdipDrawImageRect}

  function GdipDrawImageRectI(graphics: GPGRAPHICS; image: GPIMAGE; x: Integer;
    y: Integer; width: Integer; height: Integer): GPSTATUS; stdcall;
  {$EXTERNALSYM GdipDrawImageRectI}

  function GdipDrawImageRectRect(graphics: GPGRAPHICS; image: GPIMAGE;
    dstx: Single; dsty: Single; dstwidth: Single; dstheight: Single;
    srcx: Single; srcy: Single; srcwidth: Single; srcheight: Single;
    srcUnit: GPUNIT; imageAttributes: GPIMAGEATTRIBUTES;
    callback: DRAWIMAGEABORT; callbackData: Pointer): GPSTATUS; stdcall;
  {$EXTERNALSYM GdipDrawImageRectRect}

  function GdipDrawImageRectRectI(graphics: GPGRAPHICS; image: GPIMAGE;
    dstx: Integer; dsty: Integer; dstwidth: Integer; dstheight: Integer;
    srcx: Integer; srcy: Integer; srcwidth: Integer; srcheight: Integer;
    srcUnit: GPUNIT; imageAttributes: GPIMAGEATTRIBUTES;
    callback: DRAWIMAGEABORT; callbackData: Pointer): GPSTATUS; stdcall;
  {$EXTERNALSYM GdipDrawImageRectRectI}

  function GdipDrawImagePointsRect(graphics: GPGRAPHICS; image: GPIMAGE;
    points: GPPOINTF; count: Integer; srcx: Single; srcy: Single;
    srcwidth: Single; srcheight: Single; srcUnit: GPUNIT;
    imageAttributes: GPIMAGEATTRIBUTES; callback: DRAWIMAGEABORT;
    callbackData: Pointer): GPSTATUS; stdcall;
  {$EXTERNALSYM GdipDrawImagePointsRect}

  function GdipDrawImagePointsRectI(graphics: GPGRAPHICS; image: GPIMAGE;
    points: GPPOINT; count: Integer; srcx: Integer; srcy: Integer;
    srcwidth: Integer; srcheight: Integer; srcUnit: GPUNIT;
    imageAttributes: GPIMAGEATTRIBUTES; callback: DRAWIMAGEABORT;
    callbackData: Pointer): GPSTATUS; stdcall;
  {$EXTERNALSYM GdipDrawImagePointsRectI}


  function GdipGetImageRawFormat(image: GPIMAGE;
  format: PGUID): GPSTATUS; stdcall;
  {$EXTERNALSYM GdipGetImageRawFormat}

  function GdipGetPenDashStyle(pen: GPPEN;
    out dashstyle: GPDASHSTYLE): GPSTATUS; stdcall;
  {$EXTERNALSYM GdipGetPenDashStyle}

  function GdipSetPenDashStyle(pen: GPPEN;
    dashstyle: GPDASHSTYLE): GPSTATUS; stdcall;
  {$EXTERNALSYM GdipSetPenDashStyle}

  function GdipSetClipRect(graphics: GPGRAPHICS; x: Single; y: Single;
    width: Single; height: Single; combineMode: COMBINEMODE): GPSTATUS; stdcall;
  {$EXTERNALSYM GdipSetClipRect}

  function GdipSetClipRegion(graphics: GPGRAPHICS; region: GPREGION;
    combineMode: COMBINEMODE): GPSTATUS; stdcall;
  {$EXTERNALSYM GdipSetClipRegion}

  function GdipCreateRegionRect(rect: GPRECTF;
    out region: GPREGION): GPSTATUS; stdcall;
  {$EXTERNALSYM GdipCreateRegionRect}

  function GdipCreateRegionPath(path: GPPATH;
    out region: GPREGION): GPSTATUS; stdcall;
  {$EXTERNALSYM GdipCreateRegionPath}

  function GdipDeleteRegion(region: GPREGION): GPSTATUS; stdcall;
  {$EXTERNALSYM GdipDeleteRegion}

  function GdipCombineRegionPath(region: GPREGION; path: GPPATH;
    combineMode: COMBINEMODE): GPSTATUS; stdcall;
  {$EXTERNALSYM GdipCombineRegionPath}

  function GdipCombineRegionRegion(region: GPREGION; region2: GPREGION;
    combineMode: COMBINEMODE): GPSTATUS; stdcall;
  {$EXTERNALSYM GdipCombineRegionRegion}

//----------------------------------------------------------------------------
// FontFamily APIs
//----------------------------------------------------------------------------

  function GdipCreateFontFamilyFromName(name: PWCHAR;
    fontCollection: GPFONTCOLLECTION;
    out FontFamily: GPFONTFAMILY): GPSTATUS; stdcall;
  {$EXTERNALSYM GdipCreateFontFamilyFromName}

  function GdipDeleteFontFamily(FontFamily: GPFONTFAMILY): GPSTATUS; stdcall;
  {$EXTERNALSYM GdipDeleteFontFamily}

//----------------------------------------------------------------------------
// Font APIs
//----------------------------------------------------------------------------

  function GdipCreateFont(fontFamily: GPFONTFAMILY; emSize: Single;
    style: Integer; unit_: Integer; out font: GPFONT): GPSTATUS; stdcall;
  {$EXTERNALSYM GdipCreateFont}

  function GdipDeleteFont(font: GPFONT): GPSTATUS; stdcall;
  {$EXTERNALSYM GdipDeleteFont}

//----------------------------------------------------------------------------
// Image APIs
//----------------------------------------------------------------------------

  function GdipSaveImageToFile(image: GPIMAGE;
  filename: PWCHAR;
  clsidEncoder: PGUID;
  encoderParams: PENCODERPARAMETERS): GPSTATUS; stdcall;
  {$EXTERNALSYM GdipSaveImageToFile}

  function GdipSaveAddImage(image: GPIMAGE;
  newImage: GPIMAGE;
  encoderParams: PENCODERPARAMETERS): GPSTATUS; stdcall;
  {$EXTERNALSYM GdipSaveAddImage}

  function GdipSaveImageToStream(image: GPIMAGE;
  stream: ISTREAM;
  clsidEncoder: PGUID;
  encoderParams: PENCODERPARAMETERS): GPSTATUS; stdcall;
  {$EXTERNALSYM GdipSaveImageToStream}

  function GdipGetImageDecodersSize(out numDecoders: UINT;
    out size: UINT): GPSTATUS; stdcall;
  {$EXTERNALSYM GdipGetImageDecodersSize}

  function GdipGetImageDecoders(numDecoders: UINT; size: UINT;
    decoders: PIMAGECODECINFO): GPSTATUS; stdcall;
  {$EXTERNALSYM GdipGetImageDecoders}

  function GdipGetImageEncodersSize(out numEncoders: UINT;
    out size: UINT): GPSTATUS; stdcall;
  {$EXTERNALSYM GdipGetImageEncodersSize}

  function GdipGetImageEncoders(numEncoders: UINT; size: UINT;
    encoders: PIMAGECODECINFO): GPSTATUS; stdcall;
  {$EXTERNALSYM GdipGetImageEncoders}    

  function GdipLoadImageFromStream(stream: ISTREAM;
  out image: GPIMAGE): GPSTATUS; stdcall;
  {$EXTERNALSYM GdipLoadImageFromStream}

  function GdipLoadImageFromFileICM(filename: PWCHAR;
  out image: GPIMAGE): GPSTATUS; stdcall;
  {$EXTERNALSYM GdipLoadImageFromFileICM}

  function GdipLoadImageFromFile(filename: PWCHAR;
  out image: GPIMAGE): GPSTATUS; stdcall;
  {$EXTERNALSYM GdipLoadImageFromFile}

  function GdipLoadImageFromStreamICM(stream: ISTREAM;
  out image: GPIMAGE): GPSTATUS; stdcall;
  {$EXTERNALSYM GdipLoadImageFromStreamICM}

  function GdipDisposeImage(image: GPIMAGE): GPSTATUS; stdcall;
  {$EXTERNALSYM GdipDisposeImage}

  function GdipGetImageWidth(image: GPIMAGE; var width: UINT): GPSTATUS; stdcall;
  {$EXTERNALSYM GdipGetImageWidth}

  function GdipGetImageHeight(image: GPIMAGE; var height: UINT): GPSTATUS; stdcall;
  {$EXTERNALSYM GdipGetImageHeight}


//----------------------------------------------------------------------------
// ImageAttributes APIs
//----------------------------------------------------------------------------

  function GdipCreateImageAttributes(
    out imageattr: GPIMAGEATTRIBUTES): GPSTATUS; stdcall;
  {$EXTERNALSYM GdipCreateImageAttributes}

  function GdipCloneImageAttributes(imageattr: GPIMAGEATTRIBUTES;
    out cloneImageattr: GPIMAGEATTRIBUTES): GPSTATUS; stdcall;
  {$EXTERNALSYM GdipCloneImageAttributes}

  function GdipDisposeImageAttributes(
    imageattr: GPIMAGEATTRIBUTES): GPSTATUS; stdcall;
  {$EXTERNALSYM GdipDisposeImageAttributes}

  function GdipSetImageAttributesToIdentity(imageattr: GPIMAGEATTRIBUTES;
    type_: COLORADJUSTTYPE): GPSTATUS; stdcall;
  {$EXTERNALSYM GdipSetImageAttributesToIdentity}

  function GdipResetImageAttributes(imageattr: GPIMAGEATTRIBUTES;
    type_: COLORADJUSTTYPE): GPSTATUS; stdcall;
  {$EXTERNALSYM GdipResetImageAttributes}

  function GdipSetImageAttributesColorMatrix(imageattr: GPIMAGEATTRIBUTES;
    type_: COLORADJUSTTYPE; enableFlag: Bool; colorMatrix: PCOLORMATRIX;
    grayMatrix: PCOLORMATRIX; flags: COLORMATRIXFLAGS): GPSTATUS; stdcall;
  {$EXTERNALSYM GdipSetImageAttributesColorMatrix}

  function GdipSetImageAttributesThreshold(imageattr: GPIMAGEATTRIBUTES;
    type_: COLORADJUSTTYPE; enableFlag: Bool;
    threshold: Single): GPSTATUS; stdcall;
  {$EXTERNALSYM GdipSetImageAttributesThreshold}

  function GdipSetImageAttributesGamma(imageattr: GPIMAGEATTRIBUTES;
    type_: COLORADJUSTTYPE; enableFlag: Bool; gamma: Single): GPSTATUS; stdcall;
  {$EXTERNALSYM GdipSetImageAttributesGamma}

  function GdipSetImageAttributesNoOp(imageattr: GPIMAGEATTRIBUTES;
  type_: COLORADJUSTTYPE; enableFlag: Bool): GPSTATUS; stdcall;
  {$EXTERNALSYM GdipSetImageAttributesNoOp}

  function GdipSetImageAttributesColorKeys(imageattr: GPIMAGEATTRIBUTES;
    type_: COLORADJUSTTYPE; enableFlag: Bool; colorLow: ARGB;
    colorHigh: ARGB): GPSTATUS; stdcall;
  {$EXTERNALSYM GdipSetImageAttributesColorKeys}

  function GdipSetImageAttributesOutputChannel(imageattr: GPIMAGEATTRIBUTES;
    type_: COLORADJUSTTYPE; enableFlag: Bool;
    channelFlags: COLORCHANNELFLAGS): GPSTATUS; stdcall;
  {$EXTERNALSYM GdipSetImageAttributesOutputChannel}

  function GdipSetImageAttributesOutputChannelColorProfile(imageattr: GPIMAGEATTRIBUTES;
    type_: COLORADJUSTTYPE; enableFlag: Bool;
    colorProfileFilename: PWCHAR): GPSTATUS; stdcall;
  {$EXTERNALSYM GdipSetImageAttributesOutputChannelColorProfile}

  function GdipSetImageAttributesRemapTable(imageattr: GPIMAGEATTRIBUTES;
    type_: COLORADJUSTTYPE; enableFlag: Bool; mapSize: UINT;
    map: PCOLORMAP): GPSTATUS; stdcall;
  {$EXTERNALSYM GdipSetImageAttributesRemapTable}

  function GdipSetImageAttributesWrapMode(imageAttr: GPIMAGEATTRIBUTES;
    wrap: WRAPMODE; argb: ARGB; clamp: Bool): GPSTATUS; stdcall;
  {$EXTERNALSYM GdipSetImageAttributesWrapMode}

  function GdipSetImageAttributesICMMode(imageAttr: GPIMAGEATTRIBUTES;
    on_: Bool): GPSTATUS; stdcall;
  {$EXTERNALSYM GdipSetImageAttributesICMMode}

  function GdipGetImageAttributesAdjustedPalette(imageAttr: GPIMAGEATTRIBUTES;
    colorPalette: PCOLORPALETTE;
    colorAdjustType: COLORADJUSTTYPE): GPSTATUS; stdcall;
  {$EXTERNALSYM GdipGetImageAttributesAdjustedPalette}


//----------------------------------------------------------------------------
// Matrix APIs
//----------------------------------------------------------------------------

  function GdipCreateMatrix(out matrix: GPMATRIX): GPSTATUS; stdcall;
  {$EXTERNALSYM GdipCreateMatrix}

  function GdipCreateMatrix2(m11: Single; m12: Single; m21: Single; m22: Single;
    dx: Single; dy: Single; out matrix: GPMATRIX): GPSTATUS; stdcall;
  {$EXTERNALSYM GdipCreateMatrix2}

  function GdipCreateMatrix3(rect: GPRECTF; dstplg: GPPOINTF;
    out matrix: GPMATRIX): GPSTATUS; stdcall;
  {$EXTERNALSYM GdipCreateMatrix3}

  function GdipCreateMatrix3I(rect: GPRECT; dstplg: GPPOINT;
    out matrix: GPMATRIX): GPSTATUS; stdcall;
  {$EXTERNALSYM GdipCreateMatrix3I}

  function GdipCloneMatrix(matrix: GPMATRIX;
    out cloneMatrix: GPMATRIX): GPSTATUS; stdcall;
  {$EXTERNALSYM GdipCloneMatrix}

  function GdipDeleteMatrix(matrix: GPMATRIX): GPSTATUS; stdcall;
  {$EXTERNALSYM GdipDeleteMatrix}

  function GdipSetMatrixElements(matrix: GPMATRIX; m11: Single; m12: Single;
    m21: Single; m22: Single; dx: Single; dy: Single): GPSTATUS; stdcall;
  {$EXTERNALSYM GdipSetMatrixElements}

  function GdipMultiplyMatrix(matrix: GPMATRIX; matrix2: GPMATRIX;
    order: GPMATRIXORDER): GPSTATUS; stdcall;
  {$EXTERNALSYM GdipMultiplyMatrix}

  function GdipTranslateMatrix(matrix: GPMATRIX; offsetX: Single;
    offsetY: Single; order: GPMATRIXORDER): GPSTATUS; stdcall;
  {$EXTERNALSYM GdipTranslateMatrix}

  function GdipScaleMatrix(matrix: GPMATRIX; scaleX: Single; scaleY: Single;
    order: GPMATRIXORDER): GPSTATUS; stdcall;
  {$EXTERNALSYM GdipScaleMatrix}

  function GdipRotateMatrix(matrix: GPMATRIX; angle: Single;
    order: GPMATRIXORDER): GPSTATUS; stdcall;
  {$EXTERNALSYM GdipRotateMatrix}

  function GdipShearMatrix(matrix: GPMATRIX; shearX: Single; shearY: Single;
    order: GPMATRIXORDER): GPSTATUS; stdcall;
  {$EXTERNALSYM GdipShearMatrix}

  function GdipInvertMatrix(matrix: GPMATRIX): GPSTATUS; stdcall;
  {$EXTERNALSYM GdipInvertMatrix}

  function GdipTransformMatrixPoints(matrix: GPMATRIX; pts: GPPOINTF;
    count: Integer): GPSTATUS; stdcall;
  {$EXTERNALSYM GdipTransformMatrixPoints}

  function GdipTransformMatrixPointsI(matrix: GPMATRIX; pts: GPPOINT;
    count: Integer): GPSTATUS; stdcall;
  {$EXTERNALSYM GdipTransformMatrixPointsI}

  function GdipVectorTransformMatrixPoints(matrix: GPMATRIX; pts: GPPOINTF;
    count: Integer): GPSTATUS; stdcall;
  {$EXTERNALSYM GdipVectorTransformMatrixPoints}

  function GdipVectorTransformMatrixPointsI(matrix: GPMATRIX; pts: GPPOINT;
    count: Integer): GPSTATUS; stdcall;
  {$EXTERNALSYM GdipVectorTransformMatrixPointsI}

  function GdipGetMatrixElements(matrix: GPMATRIX;
    matrixOut: PSingle): GPSTATUS; stdcall;
  {$EXTERNALSYM GdipGetMatrixElements}

  function GdipIsMatrixInvertible(matrix: GPMATRIX;
    out result: Bool): GPSTATUS; stdcall;
  {$EXTERNALSYM GdipIsMatrixInvertible}

  function GdipIsMatrixIdentity(matrix: GPMATRIX;
    out result: Bool): GPSTATUS; stdcall;
  {$EXTERNALSYM GdipIsMatrixIdentity}

  function GdipIsMatrixEqual(matrix: GPMATRIX; matrix2: GPMATRIX;
    out result: Bool): GPSTATUS; stdcall;
  {$EXTERNALSYM GdipIsMatrixEqual}

//----------------------------------------------------------------------------
// Text APIs
//----------------------------------------------------------------------------

  function GdipDrawString(graphics: GPGRAPHICS; string_: PWCHAR;
    length: Integer; font: GPFONT; layoutRect: PGPRectF;
    stringFormat: GPSTRINGFORMAT; brush: GPBRUSH): GPSTATUS; stdcall;
  {$EXTERNALSYM GdipDrawString}

  function GdipMeasureString(graphics: GPGRAPHICS; string_: PWCHAR;
    length: Integer; font: GPFONT; layoutRect: PGPRectF;
    stringFormat: GPSTRINGFORMAT; boundingBox: PGPRectF;
    codepointsFitted: PInteger; linesFilled: PInteger): GPSTATUS; stdcall;
  {$EXTERNALSYM GdipMeasureString}

  function GdipSetStringFormatHotkeyPrefix(format: GPSTRINGFORMAT;
    hotkeyPrefix: Integer): GPSTATUS; stdcall;
  {$EXTERNALSYM GdipSetStringFormatHotkeyPrefix}

  function GdipGetStringFormatHotkeyPrefix(format: GPSTRINGFORMAT;
    out hotkeyPrefix: Integer): GPSTATUS; stdcall;
  {$EXTERNALSYM GdipGetStringFormatHotkeyPrefix}

//----------------------------------------------------------------------------
// String format APIs
//----------------------------------------------------------------------------

  function GdipCreateStringFormat(formatAttributes: Integer; language: LANGID;
    out format: GPSTRINGFORMAT): GPSTATUS; stdcall;
  {$EXTERNALSYM GdipCreateStringFormat}

  function GdipDeleteStringFormat(format: GPSTRINGFORMAT): GPSTATUS; stdcall;
  {$EXTERNALSYM GdipDeleteStringFormat}

  function GdipCloneStringFormat(format: GPSTRINGFORMAT;
    out newFormat: GPSTRINGFORMAT): GPSTATUS; stdcall;
  {$EXTERNALSYM GdipCloneStringFormat}

  function GdipSetStringFormatAlign(format: GPSTRINGFORMAT;
    align: STRINGALIGNMENT): GPSTATUS; stdcall;
  {$EXTERNALSYM GdipSetStringFormatAlign}

  function GdipGetStringFormatAlign(format: GPSTRINGFORMAT;
    out align: STRINGALIGNMENT): GPSTATUS; stdcall;
  {$EXTERNALSYM GdipGetStringFormatAlign}

  function GdipSetStringFormatLineAlign(format: GPSTRINGFORMAT;
    align: STRINGALIGNMENT): GPSTATUS; stdcall;
  {$EXTERNALSYM GdipSetStringFormatLineAlign}

  function GdipGetStringFormatLineAlign(format: GPSTRINGFORMAT;
    out align: STRINGALIGNMENT): GPSTATUS; stdcall;
  {$EXTERNALSYM GdipGetStringFormatLineAlign}


  function GdipSetStringFormatTrimming(format: GPSTRINGFORMAT;
    trimming: STRINGTRIMMING): GPSTATUS; stdcall;
  {$EXTERNALSYM GdipSetStringFormatTrimming}

  function GdipGetStringFormatTrimming(format: GPSTRINGFORMAT;
    out trimming: STRINGTRIMMING): GPSTATUS; stdcall;
  {$EXTERNALSYM GdipGetStringFormatTrimming}

  function GdipSetCompositingQuality(graphics: GPGRAPHICS;
    compositingQuality: COMPOSITINGQUALITY): GPSTATUS; stdcall;
  {$EXTERNALSYM GdipSetCompositingQuality}

  function GdipGetCompositingQuality(graphics: GPGRAPHICS;
    var compositingQuality: COMPOSITINGQUALITY): GPSTATUS; stdcall;
  {$EXTERNALSYM GdipGetCompositingQuality}

  function GdipImageRotateFlip(image: GPIMAGE; rfType: ROTATEFLIPTYPE): GPSTATUS; stdcall;
  {$EXTERNALSYM GdipImageRotateFlip}

  function GdipCreateBitmapFromStreamICM(stream: ISTREAM;
    out bitmap: GPBITMAP): GPSTATUS; stdcall;
  {$EXTERNALSYM GdipCreateBitmapFromStreamICM}

  function GdipCreateBitmapFromStream(stream: ISTREAM;
    out bitmap: GPBITMAP): GPSTATUS; stdcall;
  {$EXTERNALSYM GdipCreateBitmapFromStream}

  function GdipCreateHBITMAPFromBitmap(bitmap: GPBITMAP; out hbmReturn: HBITMAP;
    background: ARGB): GPSTATUS; stdcall;
  {$EXTERNALSYM GdipCreateHBITMAPFromBitmap}

  function GdipCreateBitmapFromFile(filename: PWCHAR;
    out bitmap: GPBITMAP): GPSTATUS; stdcall;
  {$EXTERNALSYM GdipCreateBitmapFromFile}    

  function GdipCreateBitmapFromScan0(width: Integer; height: Integer;
    stride: Integer; format: PIXELFORMAT; scan0: PBYTE;
    out bitmap: GPBITMAP): GPSTATUS; stdcall;
  {$EXTERNALSYM GdipCreateBitmapFromScan0}

  function GdipBitmapGetPixel(bitmap: GPBITMAP; x: Integer; y: Integer;
    var color: ARGB): GPSTATUS; stdcall;
  {$EXTERNALSYM GdipBitmapGetPixel}

  function GdipBitmapSetPixel(bitmap: GPBITMAP; x: Integer; y: Integer;
    color: ARGB): GPSTATUS; stdcall;
  {$EXTERNALSYM GdipBitmapSetPixel}

  function GdipSetPenEndCap(pen: GPPEN; endCap: GPLINECAP): GPSTATUS; stdcall;
  {$EXTERNALSYM GdipSetPenEndCap}

  function GdipAddPathLine2I(path: GPPATH; points: GPPOINT;
    count: Integer): GPSTATUS; stdcall;
  {$EXTERNALSYM GdipAddPathLine2I}


  function GdipAddPathPolygon(path: GPPATH; points: GPPOINTF;
    count: Integer): GPSTATUS; stdcall;
  {$EXTERNALSYM GdipAddPathPolygon}

  function GdipAddPathPolygonI(path: GPPATH; points: GPPOINT;
    count: Integer): GPSTATUS; stdcall;
  {$EXTERNALSYM GdipAddPathPolygonI}

  function GdipAddPathCurveI(path: GPPATH; points: GPPOINT;
    count: Integer): GPSTATUS; stdcall;
  {$EXTERNALSYM GdipAddPathCurveI}

  function GdipAddPathCurve(path: GPPATH; points: GPPOINTF;
    count: Integer): GPSTATUS; stdcall;
  {$EXTERNALSYM GdipAddPathCurve}

  function GdipAddPathCurve2I(path: GPPATH; points: GPPOINT; count: Integer;
    tension: Single): GPSTATUS; stdcall;
  {$EXTERNALSYM GdipAddPathCurve2I}

  function GdipResetClip(graphics: GPGRAPHICS): GPSTATUS; stdcall;
  {$EXTERNALSYM GdipResetClip}

  function GdipAddPathBezier(path: GPPATH;
    x1, y1, x2, y2, x3, y3, x4, y4: Single): GPSTATUS; stdcall;
  {$EXTERNALSYM GdipAddPathBezier}
  
//***************************************************************************
//---------------------------------------------------------------------------
// GDI+ classes for forward reference
//---------------------------------------------------------------------------

type
  TGPGraphics = class;
  TGPMatrix = class;
  TGPPen = class;
  TGPBrush = class;
  TGPFontFamily = class;
  TGPGraphicsPath = class;
  TGPSolidBrush = class;
  TGPHatchBrush = class;
  TGPTextureBrush = class;
  TGPImage = class;
  TGPLinearGradientBrush = class;
  TGPPathGradientBrush = class;
  TGPImageAttributes = class;
  TGPFont = class;
  TGPFontCollection = class;

//------------------------------------------------------------------------------
// GPRegion
//------------------------------------------------------------------------------
  TGPRegion = class(TGdiplusBase)
  protected
    nativeRegion: GpRegion;
    lastResult: TStatus;
    function SetStatus(status: TStatus): TStatus;
    procedure SetNativeRegion(nativeRegion: GpRegion);
  public
    constructor Create(rect: TGPRectF); reintroduce; overload;
    constructor Create(path: TGPGraphicsPath); reintroduce; overload;
    destructor Destroy; override;
    function Exclude(path: TGPGraphicsPath): TStatus; overload;
    function Union(region: TGPRegion): TStatus; overload;
  end;

(**************************************************************************\
*
*   GDI+ Matrix class
*
\**************************************************************************)

  TMatrixArray = array[0..5] of Single;

  TGPMatrix = class(TGdiplusBase)
  protected
    nativeMatrix: GpMatrix;
    lastResult: GpStatus ;
    procedure SetNativeMatrix(nativeMatrix: GpMatrix);
    function SetStatus(status: GpStatus): TStatus;
    constructor Create(nativeMatrix: GpMatrix); reintroduce; overload;
  public
    // Default constructor is set to identity matrix.
    constructor Create; reintroduce; overload;
    constructor Create(m11, m12, m21, m22, dx, dy: Single); reintroduce; overload;
    constructor Create(const rect: TGPRectF; const dstplg: TGPPointF); reintroduce; overload;
    constructor Create(const rect: TGPRect; const dstplg: TGPPoint); reintroduce; overload;
    destructor Destroy; override;
    function Clone: TGPMatrix;
    function GetElements(const m: TMatrixArray): TStatus;
    function SetElements(m11, m12, m21, m22, dx, dy: Single): TStatus;
    function OffsetX: Single;
    function OffsetY: Single;
    function Reset: TStatus;
    function Multiply(matrix: TGPMatrix; order: TMatrixOrder = MatrixOrderPrepend): TStatus;                // ok
    function Translate(offsetX, offsetY: Single; order: TMatrixOrder = MatrixOrderPrepend): TStatus;      // ok
    function Scale(scaleX, scaleY: Single; order: TMatrixOrder = MatrixOrderPrepend): TStatus;            // ok
    function Rotate(angle: Single; order: TMatrixOrder = MatrixOrderPrepend): TStatus;                    // ok
    function RotateAt(angle: Single; const center: TGPPointF; order: TMatrixOrder = MatrixOrderPrepend): TStatus; // ok
    function Shear(shearX, shearY: Single; order: TMatrixOrder = MatrixOrderPrepend): TStatus;            // ok
    function Invert: TStatus;                                                                             // ok

    function TransformPoints(pts: PGPPointF; count: Integer = 1): TStatus; overload;
    function TransformPoints(pts: PGPPoint; count: Integer = 1): TStatus; overload;

    function TransformVectors(pts: PGPPointF; count: Integer = 1): TStatus; overload;
    function TransformVectors(pts: PGPPoint; count: Integer = 1): TStatus; overload;

    function IsInvertible: BOOL;
    function IsIdentity: BOOL;
    function EqualMatrix(matrix: TGPMatrix): BOOL;
    function GetLastStatus: TStatus;
  end;

(**************************************************************************\
*
*   GDI+ Image Attributes used with Graphics.DrawImage
*
\**************************************************************************)

  TGPImageAttributes = class(TGdiplusBase)
  protected
    nativeImageAttr: GpImageAttributes;
    lastResult: TStatus;
    procedure SetNativeImageAttr(nativeImageAttr: GpImageAttributes);
    function SetStatus(status: TStatus): TStatus;
    constructor Create(imageAttr: GpImageAttributes;
      status: GpStatus); reintroduce; overload;
  public
    constructor Create; reintroduce; overload;
    destructor Destroy; override;
    function Clone: TGPImageAttributes;
    function SetToIdentity(type_: TColorAdjustType = ColorAdjustTypeDefault): TStatus;
    function Reset(type_: TColorAdjustType = ColorAdjustTypeDefault): TStatus;
    function SetColorMatrix(const colorMatrix: TColorMatrix;
      mode: TColorMatrixFlags = ColorMatrixFlagsDefault;
      type_: TColorAdjustType = ColorAdjustTypeDefault): TStatus;
    function ClearColorMatrix(type_: TColorAdjustType = ColorAdjustTypeDefault): TStatus;
    function SetColorMatrices(const colorMatrix: TColorMatrix; const grayMatrix: TColorMatrix;
      mode: TColorMatrixFlags  = ColorMatrixFlagsDefault;
      type_: TColorAdjustType  = ColorAdjustTypeDefault): TStatus;
    function ClearColorMatrices(Type_: TColorAdjustType = ColorAdjustTypeDefault): TStatus;
    function SetThreshold(threshold: Single; type_: TColorAdjustType = ColorAdjustTypeDefault): TStatus;
    function ClearThreshold(type_: TColorAdjustType = ColorAdjustTypeDefault): TStatus;
    function SetGamma(gamma: Single; type_: TColorAdjustType = ColorAdjustTypeDefault): TStatus;
    function ClearGamma( type_: TColorAdjustType = ColorAdjustTypeDefault): TStatus;
    function SetNoOp(type_: TColorAdjustType = ColorAdjustTypeDefault): TStatus;
    function ClearNoOp(Type_: TColorAdjustType = ColorAdjustTypeDefault): TStatus;
    function SetColorKey(colorLow, colorHigh: TGPColor; type_: TColorAdjustType = ColorAdjustTypeDefault): TStatus;
    function ClearColorKey(type_: TColorAdjustType = ColorAdjustTypeDefault): TStatus;
    function SetOutputChannel(channelFlags: TColorChannelFlags; type_: TColorAdjustType = ColorAdjustTypeDefault): TStatus;
    function ClearOutputChannel(type_: TColorAdjustType = ColorAdjustTypeDefault): TStatus;
    function SetOutputChannelColorProfile(colorProfileFilename: WideString;
      type_: TColorAdjustType = ColorAdjustTypeDefault): TStatus;
    function ClearOutputChannelColorProfile(type_: TColorAdjustType = ColorAdjustTypeDefault): TStatus;
    function SetRemapTable(mapSize: Cardinal; map: PColorMap; type_: TColorAdjustType = ColorAdjustTypeDefault): TStatus;
    function ClearRemapTable(type_: TColorAdjustType = ColorAdjustTypeDefault): TStatus;
    function SetBrushRemapTable(mapSize: Cardinal; map: PColorMap): TStatus;
    function ClearBrushRemapTable: TStatus;
    function SetWrapMode(wrap: TWrapMode; color: TGPColor = aclBlack; clamp: BOOL = FALSE): TStatus;
    // The flags of the palette are ignored.
    function GetAdjustedPalette(colorPalette: PColorPalette; colorAdjustType: TColorAdjustType): TStatus;
    function GetLastStatus: TStatus;
  end;

  


//--------------------------------------------------------------------------
// FontFamily
//--------------------------------------------------------------------------

  TGPFontFamily = class(TGdiplusBase)
  protected
    nativeFamily: GpFontFamily;
    lastResult: TStatus;
    function SetStatus(status: TStatus): TStatus;
  public
    constructor Create(nativeOrig: GpFontFamily; status: TStatus); reintroduce; overload;
    constructor Create(name: WideString; fontCollection: TGPFontCollection = nil); reintroduce; overload;
    destructor Destroy; override;
    property Status: TStatus read lastResult;
  end;

//--------------------------------------------------------------------------
// Font Collection
//--------------------------------------------------------------------------

  TGPFontCollection = class(TGdiplusBase)
  protected
    nativeFontCollection: GpFontCollection;
    lastResult: TStatus;
    function SetStatus(status: TStatus): TStatus;
  public
    constructor Create;
    destructor Destroy; override;
  end;

//--------------------------------------------------------------------------
// TFont
//--------------------------------------------------------------------------

  TGPFont = class(TGdiplusBase)
  protected
    nativeFont: GpFont;
    lastResult: TStatus;
    procedure SetNativeFont(Font: GpFont);
    function SetStatus(status: TStatus): TStatus;
  public
    constructor Create(font: GpFont; status: TStatus); reintroduce; overload;
    constructor Create(family: TGPFontFamily; emSize: Single;
      style: TFontStyle = FontStyleRegular;
      unit_: TUnit = UnitPoint); reintroduce; overload;
    destructor Destroy; override;
    property Status: TStatus read lastResult;    
  end;

(**************************************************************************\
*
*   GDI+ Brush class
*
\**************************************************************************)

  //--------------------------------------------------------------------------
  // Abstract base class for various brush types
  //--------------------------------------------------------------------------

  TGPBrush = class(TGdiplusBase)
  protected
    nativeBrush: GpBrush;
    lastResult: TStatus;
    procedure SetNativeBrush(nativeBrush: GpBrush);
    function SetStatus(status: TStatus): TStatus;
  public
    constructor Create(nativeBrush: GpBrush; status: TStatus); reintroduce; overload;
    constructor Create; overload;
    destructor Destroy; override;
  end;

  //--------------------------------------------------------------------------
  // Solid Fill Brush Object
  //--------------------------------------------------------------------------

  TGPSolidBrush = class(TGPBrush)
  public
    constructor Create(color: TGPColor); reintroduce; overload;
    constructor Create; reintroduce; overload;
  end;

  //--------------------------------------------------------------------------
  // Hatch Brush Object
  //--------------------------------------------------------------------------

  TGPHatchBrush = class(TGPBrush)
  public
    constructor Create; reintroduce; overload;
    constructor Create(hatchStyle: THatchStyle; foreColor: TGPColor; backColor: TGPColor = aclBlack); reintroduce; overload; // ok
    function GetHatchStyle: THatchStyle;
    function GetForegroundColor(out color: TGPColor): TStatus;
    function GetBackgroundColor(out color: TGPColor): TStatus;
  end;

  //--------------------------------------------------------------------------
  // Texture Brush Object
  //--------------------------------------------------------------------------

  TGPTextureBrush = class(TGPBrush)
  public
    constructor Create(image: TGPImage; wrapMode: TWrapMode = WrapModeTile); reintroduce; overload;
    constructor Create(image: TGPImage; wrapMode: TWrapMode; dstRect: TGPRectF); reintroduce; overload;
    constructor Create(image: TGPImage; dstRect: TGPRectF; imageAttributes: TGPImageAttributes = nil); reintroduce; overload;
    constructor Create(image: TGPImage; dstRect: TGPRect; imageAttributes: TGPImageAttributes = nil); reintroduce; overload;
    constructor Create(image: TGPImage; wrapMode: TWrapMode; dstRect: TGPRect); reintroduce; overload;
    constructor Create(image: TGPImage; wrapMode: TWrapMode; dstX, dstY, dstWidth,
      dstHeight: Single); reintroduce; overload;
    constructor Create(image: TGPImage; wrapMode: TWrapMode; dstX, dstY, dstWidth,
      dstHeight: Integer); reintroduce; overload;
    constructor Create; reintroduce; overload;
    function SetTransform(matrix: TGPMatrix): TStatus;
    function GetTransform(matrix: TGPMatrix): TStatus;
    function ResetTransform: TStatus;
    function MultiplyTransform(matrix: TGPMatrix; order: TMatrixOrder = MatrixOrderPrepend): TStatus;
    function TranslateTransform(dx, dy: Single; order: MatrixOrder = MatrixOrderPrepend): TStatus;
    function ScaleTransform(sx, sy: Single; order: TMatrixOrder = MatrixOrderPrepend): TStatus;
    function RotateTransform(angle: Single; order: TMatrixOrder = MatrixOrderPrepend): TStatus;
    function SetWrapMode(wrapMode: TWrapMode): TStatus;
    function GetWrapMode: TWrapMode;
    function GetImage: TGPImage;
  end;



  //--------------------------------------------------------------------------
  // Linear Gradient Brush Object
  //--------------------------------------------------------------------------

  TGPLinearGradientBrush = class(TGPBrush)
  public
    constructor Create(const point1, point2: TGPPointF; color1,
      color2: TGPColor); reintroduce; overload;
    constructor Create(const point1, point2: TGPPoint; color1,
      color2: TGPColor); reintroduce; overload;
    constructor Create(rect: TGPRectF; color1, color2: TGPColor;
      mode: TLinearGradientMode); reintroduce; overload;
    constructor Create(rect: TGPRect; color1, color2: TGPColor;
      mode: TLinearGradientMode); reintroduce; overload;
    constructor Create(rect: TGPRectF; color1, color2: TGPColor; angle: Single;
      isAngleScalable: BOOL = FALSE); overload;
    constructor Create(rect: TGPRect; color1, color2: TGPColor; angle: Single;
      isAngleScalable: BOOL = FALSE); overload;
    function SetGammaCorrection(useGammaCorrection: BOOL): TStatus;
    function GetGammaCorrection: BOOL;
    function GetBlendCount: Integer;
    function SetBlend(blendFactors, blendPositions: PSingle; count: Integer): TStatus;
    function GetBlend(blendFactors, blendPositions: PSingle; count: Integer): TStatus;
    function GetInterpolationColorCount: Integer;
    function SetInterpolationColors(presetColors: PGPColor; blendPositions: PSingle; count: Integer): TStatus;
    function GetInterpolationColors(presetColors: PGPColor; blendPositions: PSingle; count: Integer): TStatus;
    function SetBlendBellShape(focus: Single; scale: Single = 1.0): TStatus;
    function SetBlendTriangularShape(focus: Single; scale: Single = 1.0): TStatus;
  end;

(**************************************************************************\
*
*   GDI+ Pen class
*
\**************************************************************************)

//--------------------------------------------------------------------------
// Pen class
//--------------------------------------------------------------------------

  TGPPen = class(TGdiplusBase)
  protected
    nativePen: GpPen;
    lastResult: TStatus;
    procedure SetNativePen(nativePen: GpPen);
    function SetStatus(status: TStatus): TStatus;
    constructor Create(nativePen: GpPen; status: TStatus); reintroduce; overload;
  public
    constructor Create(color: TGPColor; width: Single = 1.0); reintroduce; overload;
    constructor Create(brush: TGPBrush; width: Single = 1.0); reintroduce; overload;
    destructor Destroy; override;
    function GetBrush: TGPBrush;
    function GetDashStyle: TDashStyle;
    function SetDashStyle(dashStyle: TDashStyle): TStatus;
    function SetEndCap(endCap: TLineCap): TStatus;
    function GetPenType: TPenType;
  end;

(**************************************************************************\
*
*   GDI+ StringFormat class
*
\**************************************************************************)

  TGPStringFormat = class(TGdiplusBase)
  protected
    nativeFormat: GpStringFormat;
    lastError: TStatus;
    function SetStatus(newStatus: GpStatus): TStatus;
    procedure Assign(source: TGPStringFormat);
    constructor Create(clonedStringFormat: GpStringFormat; status: TStatus); reintroduce; overload;
  public
    constructor Create(formatFlags: Integer = 0; language: LANGID = LANG_NEUTRAL); reintroduce; overload;
    constructor Create(format: TGPStringFormat); reintroduce; overload;
    destructor Destroy; override;
    function SetAlignment(align: TStringAlignment): TStatus;
    function GetAlignment: TStringAlignment;
    function SetLineAlignment(align: TStringAlignment): TStatus;
    function GetLineAlignment: TStringAlignment;
    function SetTrimming(trimming: TStringTrimming): TStatus;
    function GetTrimming: TStringTrimming;
    function SetHotkeyPrefix(hotkeyPrefix: THotkeyPrefix): TStatus;
    function GetHotkeyPrefix: THotkeyPrefix;

  end;

(**************************************************************************\
*
*   GDI+ Graphics Path class
*
\**************************************************************************)

  TGPGraphicsPath = class(TGdiplusBase)
  protected
    nativePath: GpPath;
    lastResult: TStatus;
    procedure SetNativePath(nativePath: GpPath);
    function SetStatus(status: TStatus): TStatus;
  public
    constructor Create(nativePath: GpPath); reintroduce; overload;
    constructor Create(fillMode: TFillMode = FillModeAlternate); reintroduce; overload;
    destructor Destroy; override;

    function CloseFigure: TStatus;

    function AddLine(const pt1, pt2: TGPPointF): TStatus; overload;
    function AddLine(x1, y1, x2, y2: Single): TStatus; overload;
    function AddLines(points: PGPPoint; count: Integer): TStatus; overload;

    function AddArc(rect: TGPRectF; startAngle, sweepAngle: Single): TStatus; overload;
    function AddArc(x, y, width, height, startAngle, sweepAngle: Single): TStatus; overload;

    function AddEllipse(rect: TGPRectF): TStatus; overload;
    function AddEllipse(x, y, width, height: Single): TStatus; overload;

    function AddRectangle(rect: TGPRectF): TStatus; overload;
    function AddRectangle(rect: TGPRect): TStatus; overload;

    function AddPie(rect: TGPRectF; startAngle, sweepAngle: Single): TStatus; overload;
    function AddPie(x, y, width, height, startAngle, sweepAngle: Single): TStatus; overload;

    function AddPolygon(points: PGPPointF; count: Integer): TStatus; overload;
    function AddPolygon(points: PGPPoint; count: Integer): TStatus; overload;


    function AddCurve(points: PGPPointF; count: Integer): TStatus; overload;
    function AddCurve(points: PGPPoint; count: Integer): TStatus; overload;
    function AddCurve(points: PGPPoint; count: Integer; tension: Single): TStatus; overload;

    function AddBezier(pt1, pt2, pt3, pt4: TGPPoint): TStatus; overload;
    function AddBezier(pt1, pt2, pt3, pt4: TGPPointF): TStatus; overload;
    function AddBezier(x1, y1, x2, y2, x3, y3, x4, y4: Single): TStatus; overload;


  end;

//--------------------------------------------------------------------------
// Path Gradient Brush
//--------------------------------------------------------------------------

  TGPPathGradientBrush = class(TGPBrush)
  public
    constructor Create(points: PGPPointF; count: Integer;
      wrapMode: TWrapMode = WrapModeClamp); reintroduce; overload;
    constructor Create(points: PGPPoint; count: Integer;
      wrapMode: TWrapMode = WrapModeClamp); reintroduce; overload;
    constructor Create(path: TGPGraphicsPath); reintroduce; overload;
    function GetCenterColor(out Color: TGPColor): TStatus;
    function SetCenterColor(color: TGPColor): TStatus;
    function GetPointCount: Integer;
    function GetSurroundColors(colors: PARGB; var count: Integer): TStatus;
    function SetSurroundColors(colors: PARGB; var count: Integer): TStatus;
    function GetCenterPoint(out point: TGPPointF): TStatus; overload;
    function GetCenterPoint(out point: TGPPoint): TStatus; overload;
    function SetCenterPoint(point: TGPPointF): TStatus; overload;
    function SetCenterPoint(point: TGPPoint): TStatus; overload;
    function SetGammaCorrection(useGammaCorrection: BOOL): TStatus; overload;
    function GetGammaCorrection: BOOL; overload;
    function SetWrapMode(wrapMode: TWrapMode): TStatus;
    function GetWrapMode: TWrapMode;
    function GetBlendCount: Integer;
    function GetBlend(blendFactors, blendPositions: PSingle; count: Integer): TStatus;
    function SetBlend(blendFactors, blendPositions: PSingle; count: Integer): TStatus;
    function GetInterpolationColorCount: Integer;
    function SetInterpolationColors(presetColors: PARGB; blendPositions: PSingle;
      count: Integer): TStatus;
    function GetInterpolationColors(presetColors: PARGB;
      blendPositions: PSingle; count: Integer): TStatus;
    function SetBlendBellShape(focus: Single; scale: Single = 1.0): TStatus;
    function SetBlendTriangularShape(focus: Single; scale: Single = 1.0): TStatus;
  end;

(**************************************************************************\
*  TGPImage
***************************************************************************)
  TGPImageFormat = (ifUndefined, ifMemoryBMP, ifBMP, ifEMF, ifWMF, ifJPEG,
    ifPNG, ifGIF, ifTIFF, ifEXIF, ifIcon);

  TGPImage = class(TGdiplusBase)
  protected
    nativeImage: GpImage;
    lastResult: TStatus;
    loadStatus: TStatus;
    procedure SetNativeImage(nativeImage: GpImage);
    function SetStatus(status: TStatus): TStatus;
  public
    constructor Create(nativeImage: GpImage; status: TStatus); reintroduce; overload;
    constructor Create(filename: WideString; useEmbeddedColorManagement: BOOL = FALSE); reintroduce; overload;
    constructor Create(stream: IStream; useEmbeddedColorManagement: BOOL  = FALSE); reintroduce; overload;
    function SaveAdd(newImage: TGPImage; encoderParams: PEncoderParameters): TStatus; overload;
    function Save(filename: WideString; const clsidEncoder: TGUID; encoderParams: PEncoderParameters = nil): TStatus; overload;
    function Save(stream: IStream; const clsidEncoder: TGUID; encoderParams: PEncoderParameters  = nil): TStatus; overload;
    destructor Destroy; override;
    function GetFormat: TGPImageFormat;
    function GetPixelFormat: TPixelFormat;
    function GetPixelDepth: integer;
    function HasPalette: Boolean;
    function HasAlphaChannel: Boolean;    
    function GetWidth: UINT;
    function GetHeight: UINT;
    function RotateFlip(rotateFlipType: TRotateFlipType): TStatus;
    property Width: UINT read GetWidth;
    property Height: UINT read GetHeight;
  end;

  TGPBitmap = class(TGPImage)
  protected
    {$IFDEF DELPHI6_LVL}
    constructor Create(nativeBitmap: GpBitmap);  reintroduce; overload;
    {$ENDIF}
  public
    {$IFDEF DELPHI6_LVL}
    constructor Create(stream: IStream; useEmbeddedColorManagement: BOOL = FALSE); reintroduce; overload;
    constructor Create(width, height: Integer; format: TPixelFormat = PixelFormat32bppARGB); reintroduce; overload;
    {$ENDIF}
    {$IFNDEF DELPHI6_LVL}
    constructor Create(stream: IStream);  overload;
    constructor CreateWH(width, height: Integer); overload;
    {$ENDIF}
    function FromStream(stream: IStream; useEmbeddedColorManagement: BOOL = FALSE): TGPBitmap;
    function GetPixel(x, y: Integer; out color: TGPColor): TStatus;
    function SetPixel(x, y: Integer; color: TGPColor): TStatus;
    function GetHBITMAP(colorBackground: TGPColor; out hbmReturn: HBITMAP): TStatus;    
  end;

(**************************************************************************\
*
*   GDI+ Graphics Object
*
\**************************************************************************)

  TGPGraphics = class(TGdiplusBase)
  protected
    nativeGraphics: GpGraphics;
    lastResult: TStatus;
    procedure SetNativeGraphics(graphics: GpGraphics);
    function SetStatus(status: TStatus): TStatus;
    function GetNativeGraphics: GpGraphics;
  public
    //constructor Create(graphics: GpGraphics); reintroduce; overload;
    constructor Create(hdc: HDC); reintroduce; overload;
    constructor Create(image: TGPImage); reintroduce; overload;    
    destructor Destroy; override;
    procedure Flush(intention: TFlushIntention = FlushIntentionFlush);
    function FromImage(image: TGPImage): TGPGraphics;
    //------------------------------------------------------------------------
    // GDI Interop methods
    //------------------------------------------------------------------------
    // Locks the graphics until ReleaseDC is called
    function GetHDC: HDC;
    procedure ReleaseHDC(hdc: HDC);
    //------------------------------------------------------------------------
    // Rendering modes
    //------------------------------------------------------------------------
    function SetCompositingQuality(compositingQuality: TCompositingQuality): TStatus;
    function GetCompositingQuality: TCompositingQuality;

    function SetTextRenderingHint(newMode: TTextRenderingHint): TStatus;
    function GetTextRenderingHint: TTextRenderingHint;
    function GetSmoothingMode: TSmoothingMode;
    function SetSmoothingMode(smoothingMode: TSmoothingMode): TStatus;
    function SetInterpolationMode(interpolationMode: TInterpolationMode): TStatus;
    function GetPixelOffsetMode: TPixelOffsetMode;
    function SetPixelOffsetMode(pixelOffsetMode: TPixelOffsetMode): TStatus;

    function Clear(color: TGPColor): TStatus;

    // DrawPath
    function DrawPath(pen: TGPPen; path: TGPGraphicsPath): TStatus;
    // FillRectangle(s)
    function FillRectangle(brush: TGPBrush; const rect: TGPRectF): TStatus; overload;
    function FillRectangle(brush: TGPBrush; x, y, width, height: Single): TStatus; overload;
    function FillRectangle(brush: TGPBrush; const rect: TGPRect): TStatus; overload;
    function FillRectangle(brush: TGPBrush; x, y, width, height: Integer): TStatus; overload;

     // DrawEllipse
    function DrawEllipse(pen: TGPPen; const rect: TGPRectF): TStatus; overload;
    function DrawEllipse(pen: TGPPen; x, y, width, height: Single): TStatus; overload;
    function DrawEllipse(pen: TGPPen; const rect: TGPRect): TStatus; overload;
    function DrawEllipse(pen: TGPPen; x, y, width, height: Integer): TStatus; overload;


    //DrawLine
    function DrawLine(pen: TGPPen; x1, y1, x2, y2: Single): TStatus; overload;
    function DrawLine(pen: TGPPen; x1, y1, x2, y2: Integer): TStatus; overload;

        // DrawArc
    function DrawArc(pen: TGPPen; x, y, width, height, startAngle, sweepAngle: Single): TStatus; overload;
    function DrawArc(pen: TGPPen; const rect: TGPRectF; startAngle, sweepAngle: Single): TStatus; overload;
    function DrawArc(pen: TGPPen; x, y, width, height: Integer; startAngle, sweepAngle: Single): TStatus; overload;
    function DrawArc(pen: TGPPen; const rect: TGPRect; startAngle, sweepAngle: Single): TStatus; overload;

    // FillPolygon
    function FillPolygon(brush: TGPBrush; points: PGPPointF; count: Integer): TStatus; overload;
    function FillPolygon(brush: TGPBrush; points: PGPPointF; count: Integer; fillMode: TFillMode): TStatus; overload;
    function FillPolygon(brush: TGPBrush; points: PGPPoint; count: Integer): TStatus; overload;
    function FillPolygon(brush: TGPBrush; points: PGPPoint; count: Integer; fillMode: TFillMode): TStatus; overload;    

        // FillEllipse
    function FillEllipse(brush: TGPBrush; const rect: TGPRectF): TStatus; overload;
    function FillEllipse(brush: TGPBrush; x, y, width, height: Single): TStatus; overload;
    function FillEllipse(brush: TGPBrush; const rect: TGPRect): TStatus; overload;
    function FillEllipse(brush: TGPBrush; x, y, width, height: Integer): TStatus; overload;

    // MakeFont
    function MakeFont(AFont: TFont): TGPFont;
    function TextHeight(string_: String; font: TFont): integer;
    function TextWidth(string_: String; font: TFont): integer;
    function DrawText(string_: String; len: integer; var rect: TRect; font: TFont; style: DWORD; bkColor: TColor = clNone): integer;

    // DrawString
    function DrawString(string_: String; length: Integer; font: TGPFont;
      const layoutRect: TGPRectF; stringFormat: TGPStringFormat; brush: TGPBrush): TStatus; overload;
    {$IFDEF DELPHI6_LVL}
    function DrawString(string_: widestring; length: Integer; font: TGPFont;
      const layoutRect: TGPRectF; stringFormat: TGPStringFormat; brush: TGPBrush): TStatus; overload;
    {$ENDIF}

     // DrawString
    function DrawString(string_: WideString; length: Integer; font: TGPFont;
      const origin: TGPPointF; brush: TGPBrush): TStatus; overload;
    function DrawString(string_: WideString; length: Integer; font: TGPFont;
      const origin: TGPPointF; stringFormat: TGPStringFormat; brush: TGPBrush): TStatus; overload;

    // MeasureString
    function MeasureString(string_: WideString; length: Integer; font: TGPFont;
      const layoutRect: TGPRectF; stringFormat: TGPStringFormat; out boundingBox: TGPRectF;
      codepointsFitted: PInteger = nil; linesFilled: PInteger = nil): TStatus; overload;
    function MeasureString(string_: WideString ; length: Integer; font: TGPFont;
      const origin: TGPPointF; stringFormat: TGPStringFormat;
      out boundingBox: TGPRectF): TStatus; overload;
    function MeasureString(string_: WideString; length: Integer; font: TGPFont;
      const layoutRect: TGPRectF; out boundingBox: TGPRectF): TStatus; overload;
    function MeasureString(string_: WideString; length: Integer; font: TGPFont;
      const origin: TGPPointF; out boundingBox: TGPRectF): TStatus; overload;
    function GetLastStatus: TStatus;
    // DrawRectangle
    function DrawRectangle(pen: TGPPen; const rect: TGPRectF): TStatus; overload;
    function DrawRectangle(pen: TGPPen; x, y, width, height: Single): TStatus; overload;
    // DrawImage
    function DrawImage(image: TGPImage; const point: TGPPointF): TStatus; overload;
    function DrawImage(image: TGPImage; x, y: Single): TStatus; overload;
    function DrawImage(image: TGPImage; const rect: TGPRectF): TStatus; overload;
    function DrawImage(image: TGPImage; x, y, width, height: Single): TStatus; overload;
    function DrawImage(image: TGPImage; const point: TGPPoint): TStatus; overload;
    function DrawImage(image: TGPImage; x, y: Integer): TStatus; overload;
    function DrawImage(image: TGPImage; const rect: TGPRect): TStatus; overload;
    function DrawImage(image: TGPImage; x, y, width, height: Integer): TStatus; overload;

    function DrawImageRect(image: TGPImage; x, y, w, h: Integer): TStatus; overload;
    function DrawImageRect(image: TGPImage; ARect: TGPRectF): TStatus; overload;

    // DrawImage with attributes
    function DrawImage(image: TGPImage; const destRect: TGPRectF; srcx, srcy,
      srcwidth, srcheight: Single; srcUnit: TUnit;
      imageAttributes: TGPImageAttributes = nil; callback: DrawImageAbort = nil;
      callbackData: Pointer = nil): TStatus; overload;
    function DrawImage(image: TGPImage; destPoints: PGPPointF; count: Integer;
      srcx, srcy, srcwidth, srcheight: Single; srcUnit: TUnit;
      imageAttributes: TGPImageAttributes = nil; callback: DrawImageAbort = nil;
      callbackData: Pointer = nil): TStatus; overload;
    function DrawImage(image: TGPImage; const destRect: TGPRect; srcx, srcy,
      srcwidth, srcheight: Integer; srcUnit: TUnit;
      imageAttributes: TGPImageAttributes = nil; callback: DrawImageAbort = nil;
      callbackData: Pointer = nil): TStatus; overload;
    function DrawImage(image: TGPImage; destPoints: PGPPoint;
      count, srcx, srcy, srcwidth, srcheight: Integer; srcUnit: TUnit;
      imageAttributes: TGPImageAttributes = nil; callback: DrawImageAbort = nil;
      callbackData: Pointer = nil): TStatus; overload;

    // FillPath
    function FillPath(brush: TGPBrush; path: TGPGraphicsPath): TStatus;
    // Clip
    function ExcludeClip(const rect: TGPRectF): TStatus; overload;
    function ExcludeClip(region: TGPRegion): TStatus; overload;
    function SetClip(region: TGPRegion; combineMode: TCombineMode = CombineModeReplace): TStatus;
    function ResetClip: TStatus;
  end;

  function ColorToARGB(Color: TColor): ARGB;

////////////////////////////////////////////////////////////////////////////////

var
   StartupInput: TGDIPlusStartupInput;
   StartupOutput: TGdiplusStartupOutput;
   gdiplusToken: ULONG;


type

  TAdvGDIPPicture = class(TGraphic)
  private
    { Private declarations }
    FDatastream: TMemoryStream;
    FIsEmpty: Boolean;
    FWidth, FHeight: Integer;
    FDoubleBuffered: Boolean;
    FOnClear: TNotifyEvent;
    FBitmapTransparentMode: TTransparentMode;
    FBitmapTransparentColor: TColor;
    FID: string;
    FPixelDepth: integer;
    FHasAlpha: boolean;
    FHasPalette: boolean;
    FPixelFormat: integer;
  protected
    { Protected declarations }
    function GetEmpty: Boolean; override;
    function GetHeight: Integer; override;
    function GetWidth: Integer; override;
    procedure SetHeight(Value: Integer); override;
    procedure SetWidth(Value: Integer); override;
    procedure ReadData(Stream: TStream); override;
    procedure WriteData(Stream: TStream); override;
  public
    { Public declarations }
    constructor Create; override;
    destructor Destroy; override;
    procedure Assign(Source: TPersistent); override;
    function GetImageSizes: boolean;
    function GetImageSizesFromFileName(FileName: String): boolean;
    procedure Draw(ACanvas: TCanvas; const Rect: TRect); override;
    procedure GDIPDraw(Graphics: TGPGraphics; const Rect: TRect); overload;
    procedure FillRect(graphics: TGPGraphics; R: TGPRectf);
    procedure FillPath(graphics: TGPGraphics; Path: TGPGraphicsPath);
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
    property DoubleBuffered: Boolean read FDoubleBuffered write FDoubleBuffered;
    property TransparentColor: TColor read FBitmapTransparentColor write FBitmapTransparentColor;
    property TransparentMode: TTransparentMode read FBitmapTransparentMode write FBitmapTransparentMode;
    property ID: string read FID write FID;
    property PixelFormat: integer read FPixelFormat;
    property PixelDepth: integer read FPixelDepth;
    property HasAlpha: boolean read FHasAlpha;
    property HasPalette: boolean read FHasPalette;
  published
    { Published declarations }
    property OnClear: TNotifyEvent read FOnClear write FOnClear;
  end;

type
  TAdvGradientType = (gtSolid, gtRadial, gtVertical, gtHorizontal, gtForwardDiagonal, gtBackwardDiagonal, gtAngle, gtHatch, gtPath, gtTexture, gtNone);

  TGDIPFillParameters = record
    Graphics: TGPGraphics;
    Path: TGPGraphicsPath;
    Fillpath: boolean;
    R: TGPRectF;
    GT: TAdvGradientType;
    ColorFrom: TColor;
    ColorTo: TColor;
    OpacityFrom: integer;
    OpacityTo: integer;
    HatchStyle: THatchStyle;
    Angle: integer;
    Image: TAdvGDIPPicture;
    BorderColor: TColor;
    BorderWidth: integer;
    BorderStyle: TDashStyle;
    Mirror: boolean;
  end;

procedure ShadowGDIP(graphics: TGPGraphics; Rect: TGPRectF);
procedure FillGDIP(Params: TGDIPFillParameters);
procedure ArrowGDIP(graphics: TGPGraphics; origin, target : TPoint; ArrowSize: integer; ArrowColor: TColor; ScaleX, ScaleY: Double);

procedure GetJPGSize(const sFile: string; var wWidth, wHeight: word);
procedure GetPNGSize(const sFile: string; var wWidth, wHeight: word);
procedure GetGIFSize(const sFile: string; var wWidth, wHeight: word);
procedure GetBMPSize(const sFile: string; var wWidth, wHeight: word);
procedure GetTifSize(const sFile:string; var wWidth,wHeight: word);
procedure GetICOSize (const sFile:string; var wWidth,wHeight: word);

implementation

function ReadMWord(f: TFileStream): word; type
  TMotorolaWord = record
    case byte of
      0: (Value: word);
      1: (Byte1, Byte2: byte);
  end;
var
  MW: TMotorolaWord;
begin
  { It would probably be better to just read these two bytes in normally }
  { and then do a small ASM routine to swap them.  But we aren't talking }
  { about reading entire files, so I doubt the performance gain would be }
  { worth the trouble. }
  f.Read(MW.Byte2, SizeOf(Byte));
  f.Read(MW.Byte1, SizeOf(Byte));
  Result := MW.Value;
end;

procedure GetJPGSize(const sFile: string; var wWidth, wHeight: word);
const
  ValidSig : array[0..1] of byte = ($FF, $D8);
  Parameterless = [$01, $D0, $D1, $D2, $D3, $D4, $D5, $D6, $D7]; var
  Sig: array[0..1] of byte;
  f: TFileStream;
  x: integer;
  Seg: byte;
  Dummy: array[0..15] of byte;
  Len: word;
  ReadLen: LongInt;

begin
  FillChar(Sig, SizeOf(Sig), #0);
  
  f := TFileStream.Create(sFile, fmOpenRead);
  try
    ReadLen := f.Read(Sig[0], SizeOf(Sig));

    for x := Low(Sig) to High(Sig) do
      if Sig[x] <> ValidSig[x] then ReadLen := 0;

    if ReadLen > 0 then
    begin
      ReadLen := f.Read(Seg, 1);
      while (Seg = $FF) and (ReadLen > 0) do
      begin
        ReadLen := f.Read(Seg, 1);
        if Seg <> $FF then
        begin
          if (Seg = $C0) or (Seg = $C1) or (Seg = $C2) then
          begin
            ReadLen := f.Read(Dummy[0], 3); // don't need these bytes
            wHeight := ReadMWord(f);
            wWidth := ReadMWord(f);
          end else begin
            if not (Seg in Parameterless) then
            begin
              Len := ReadMWord(f);
              f.Seek(Len - 2, 1);
              f.Read(Seg, 1);
            end else
              Seg := $FF; // Fake it to keep looping. 
          end;
        end;
      end;
    end;
  finally
    f.Free;
  end;
end;

procedure GetPNGSize(const sFile: string; var wWidth, wHeight: word);
type
  TPNGSig = array[0..7] of byte;
const
  ValidSig: TPNGSig = (137,80,78,71,13,10,26,10); var
  Sig: TPNGSig;
  f: tFileStream;
  x: integer;
begin
  FillChar(Sig, SizeOf(Sig), #0);
  f := TFileStream.Create(sFile, fmOpenRead);
  try
    f.Read(Sig[0], SizeOf(Sig));
    for x := Low(Sig) to High(Sig) do
      if Sig[x] <> ValidSig[x] then exit;
    f.Seek(18, 0);
    wWidth := ReadMWord(f);
    f.Seek(22, 0);
    wHeight := ReadMWord(f);
  finally
    f.Free;
  end;
end;


procedure GetGIFSize(const sFile: string; var wWidth, wHeight: word);
type
  TGIFHeader = record
    Sig: array[0..5] of char;
    ScreenWidth, ScreenHeight: word;
    Flags, Background, Aspect: byte;
  end;

  TGIFImageBlock = record
    Left, Top, Width, Height: word;
    Flags: byte;
  end;
var
  f: file;
  Header: TGifHeader;
  ImageBlock: TGifImageBlock;
  nResult: integer;
  x: integer;
  c: char;
  sz: integer;
  DimensionsFound: boolean;
begin
  wWidth  := 0;
  wHeight := 0;

  if (sFile = '') then
    Exit;

  FileMode := 0;
  AssignFile(f, sFile);
  {$I-}
  Reset(f, 1);
  {$I+}
  if IOResult <> 0 then
    Exit;

  // Read header and ensure valid file.
  {$I-}
  BlockRead(f, Header, SizeOf(TGifHeader), nResult);
  {$I+}
  if (nResult <> SizeOf(TGifHeader)) or (IOResult <> 0) or
     (StrLComp('GIF', Header.Sig, 3) <> 0) then
  begin
    Close(f);
    Exit;
  end;

  if (Header.Flags and $1) > 0 then
  begin
    sz := (Header.Flags and $E0) shr 5;
    x := 3 * (1 SHL (sz + 1));

    // try to skip color map
    {$I-}
    Seek(f, x + filepos(f));
    {$I+}

    if (IOResult <> 0) then
    begin
      Close(f);
      Exit;
    end;
  end;
  

  DimensionsFound := False;
  FillChar(ImageBlock, SizeOf(TGIFImageBlock), #0);

  // Step through blocks.
  {$I-}
  BlockRead(f, c, 1, nResult);
  while (not EOF(f)) and (not DimensionsFound) do
  begin
    case c of
      ',': // Found image
        begin
          BlockRead(f, ImageBlock, SizeOf(TGIFImageBlock), nResult);
          if nResult <> SizeOf(TGIFImageBlock) then begin
            { Invalid image block encountered }
            close(f);
            exit;
          end;
          wWidth  := ImageBlock.Width;
          wHeight := ImageBlock.Height;
          DimensionsFound := True;
        end;
      'ÿ' : // Skip
        begin
          // NOP
        end;
    end;
    BlockRead(f, c, 1, nResult);
  end;
  Close(f);
  {$I+}
end;

procedure GetBMPSize(const sFile: string; var wWidth, wHeight: word);
type
  TBitmapFileHeader = record
    bmfIdentifier : Word; {'BM'}
    bmfFileSize : dWord;
    bmfReserved : dWord;
    bmfBitMapDataOffset : dWord; {from begin of file}
  end;

  {followed by the bitmapinfoheader}

  TBitmapInfoHeader = record
    biSize: Longint;   {size of tbitmapinfoheader}
    biWidth: Longint;  {bitmap width}
    biHeight: Longint;  { height of bitmap}
    biPlanes: Word;     {always 1}
    biBitCount: Word;  {number color bits 4 = 16 colors, 8 = 256 pixel is a byte}
    biCompression: Longint; {compression used, 0 }
    biSizeImage: Longint;   {size of the pixel data}
    biXPelsPerMeter: Longint; {not used, 0 }
    biYPelsPerMeter: Longint; {not used, 0 }
    biClrUsed: Longint;       {number of colors used, set to 0 }
    biClrImportant: Longint;  {important colors, set to 0 }
  end;

var
  f: file;
  idstr: ansistring;
  BitmapFileHeader : TBitmapFileHeader;
  BitmapInfoHeader : TBitmapInfoHeader;
  Amt : Integer; {var variable, total bytes returned by blockread}
  ALongint : Longint;
  AChar : AnsiChar;

begin
  AssignFile(f, sFile);
  Reset(f, 1);
  idstr := '';

  {a bitmap file starts with the id 'BM'}
  BlockRead(f, AChar, 1, amt);
  idstr := Achar;
  BlockRead(f, Achar, 1, amt);
  idstr := idstr + Achar;
  if (idstr <> 'BM') then
  begin
    CloseFile(f);
    Exit;
  end;

  {read the file header info}
  BlockRead(f, Alongint, 4, amt);
  BitmapFileHeader.bmfFileSize := Alongint;
  BlockRead(f, Alongint, 4, amt);
  BitmapFileHeader.bmfReserved := Alongint;
  BlockRead(f, Alongint, 4, amt);
  BitmapFileHeader.bmfBitMapDataOffset := Alongint;
  {read the bitmap info header}
  BlockRead(f, Alongint, 4, amt);
  BitmapInfoHeader.biSize := Alongint; {size of header itself}
  BlockRead(f, Alongint, 4, amt);
  BitmapInfoHeader.biWidth := Alongint;
  BlockRead(f, Alongint, 4, amt);
  BitmapInfoHeader.biHeight :=  Alongint;

  Closefile(f);

  wWidth := BitmapInfoHeader.biWidth;
  wHeight := BitmapInfoHeader.biHeight;
end;

type
  TTifHeader = record
     Signature  : WORD;
     Version    : Word;
     IFD        : DWORD;
  end;

  TIDF_Field   = record
    Tag       : Word;
    FieldType : Word;
    ValCount  : DWord;
    ValOffset : DWORD;
  end;

procedure GetTifSize (const sFile:string; var wWidth,wHeight: word);
type
  TTifHeader = record
     Signature  : WORD;
     Version    : Word;
     IFD        : DWORD;
  End;

  TIDF_Field   = record
    Tag       : Word;
    FieldType : Word;
    ValCount  : DWord;
    ValOffset : DWORD;
  end;
var
  TifFile    : TFileStream;
  Header     : tTifHeader;
  DirEntries : Word;
  Field      : TIDF_Field;
  Cnt        : Integer;
  iwidth, iheight: integer;
begin
  wWidth  := 0;
  wHeight := 0;
  iWidth := -1;
  iHeight := -1;
  TifFile := TFileStream.Create ( sFile, fmOpenRead );
  try
    TifFile.Read ( Header,8);
    TifFile.Position := Header.IFD;
    TifFile.Read ( DirEntries, 2 );

    for Cnt := 1 To DirEntries Do
    begin
      TifFile.Read ( Field,12 );
      case Field.Tag OF
        $0100 : iWidth  := Field.ValOffset;
        $0101 : iHeight := Field.ValOffset;
      end;
      if ( iWidth<>-1) and ( iHeight<>-1) then
      begin
        wWidth := Abs(iWidth);
        wHeight := Abs(iHeight);
        Break;
      end;
    end;
  finally
    FreeAndNil ( TifFile );
  end;
end;

procedure GetICOSize(const sFile: string; var wWidth, wHeight: word);
type
  TIcohdr = record
    rsrv: word;
    ico: word;
    cnt: word;
  end;

  TIcodir = record
    iwidth: byte;
    iheight: byte;
    icolors: byte;
    rsrv: byte;
    iplanes: word;
    ibits: word;
    bmpsize: longint;
    bmpoffset: longint;
  end;
var
  f: file;
  icohdr: TIcohdr;
  icodir: TIcodir;
  i: word;
  nres: integer;

begin
  wWidth := 0;
  wHeight := 0;

  AssignFile(f, sFile);

  {$i-}
  reset(f,1);
  {$i+}
  if ioresult <> 0 then
    Exit;

  {$i-}
  blockread(f, icohdr, sizeof(icohdr),nres);
  {$i+}
  if (ioresult <> 0) or (nres <> sizeof(icohdr)) then
  begin
    closefile(f);
    Exit;
  end;

  if (icohdr.rsrv <> 0) then
  begin
    closefile(f);
    Exit;
  end;

  for i := 1 to icohdr.cnt do
  begin
    {$i-}
    blockread(f, icodir, sizeof(icodir),nres);
    {$i+}
    if (ioresult <> 0) or (nres <> sizeof(icodir)) then
      break;

    if (icodir.iwidth > wWidth) and (icodir.iWidth <= 128) and (icodir.iHeight > wHeight) and (icodir.iHeight <= 128) then
    begin
      wWidth := icodir.iWidth;
      wHeight := icodir.iheight;
    end;
  end;
  closefile(f);
end;



{ TAdvSmoothPanelGDIPPicture }

procedure TAdvGDIPPicture.Assign(Source: TPersistent);
var
  st: TMemoryStream;
begin
  FIsEmpty := True;
  if Source = nil then
  begin
    FDataStream.Clear;
    FIsEmpty := true;
    if Assigned(OnChange) then
      OnChange(Self);
    if Assigned(OnClear) then
      OnClear(self);
  end
  else
  begin
    if Source is TAdvGDIPPicture then
    begin
      FDataStream.LoadFromStream(TAdvGDIPPicture(Source).FDataStream);
      FIsEmpty := FDatastream.Size = 0;
      if Assigned(OnChange) then
        OnChange(self);
    end
    else
      if Source is TBitmap then
      begin
        st := TMemoryStream.Create;
        (Source as TBitmap).SaveToStream(st);
        st.Position := 0;
        FDataStream.LoadFromStream(st);
        st.Free;
        FIsEmpty := false;
        if Assigned(OnChange) then
          OnChange(self);
      end
      else
        if (Source is TPicture) then
        begin
          st := TMemoryStream.Create;
          (Source as TPicture).Graphic.SaveToStream(st);
          st.Position := 0;
          FDataStream.LoadFromStream(st);
          st.Free;
          FIsEmpty := false;
          if Assigned(OnChange) then
            OnChange(self);
        end;

    GetImageSizes;
  end;
end;

constructor TAdvGDIPPicture.Create;
begin
  inherited;
  FDataStream := TMemoryStream.Create;
  FIsEmpty := True;

  Transparent := False;
  FBitmapTransparentMode := tmAuto;
  FBitmapTransparentColor := clWhite;
end;

destructor TAdvGDIPPicture.Destroy;
begin
  FDataStream.Free;
  inherited;
end;

procedure TAdvGDIPPicture.Draw(ACanvas: TCanvas; const Rect: TRect);
var
  dc: HDC;
  multi: TGPImage;
  graphic: TGPgraphics;
  pstm: IStream;
  hGlobal: THandle;
  pcbWrite: Longint;
  bmp: tbitmap;

begin
  if Empty then
    Exit;

  if FDataStream.Size = 0 then
    Exit;

  hGlobal := GlobalAlloc(GMEM_MOVEABLE, FDataStream.Size);
  if (hGlobal = 0) then
    raise Exception.Create('Could not allocate memory for image');

  try
    pstm := nil;

    // Create IStream* from global memory
    CreateStreamOnHGlobal(hGlobal, TRUE, pstm);
    pstm.Write(FDataStream.Memory, FDataStream.Size,@pcbWrite);

    dc := ACanvas.Handle;
    graphic:= TGPgraphics.Create(dc);
    multi := TGPImage.Create(pstm);

    if multi.GetFormat = ifBMP then
    begin // use this alternative for easy bitmap auto transparent drawing
      bmp := TBitmap.Create;
      FDataStream.Position := 0;
      bmp.LoadFromStream(FDataStream);
      bmp.TransparentMode := tmAuto;
      bmp.Transparent := true;
      ACanvas.Draw(Rect.Left,Rect.Top, bmp);
      bmp.Free;
    end
    else
    begin
      FWidth := multi.GetWidth;
      FHeight := multi.GetHeight;
      graphic.DrawImageRect(multi, Rect.Left, Rect.Top, Rect.Right - Rect.Left, Rect.Bottom - Rect.Top);
    end;

    multi.Free;
    graphic.Free;
  finally
    GlobalFree(hGlobal);
  end;

end;

function TAdvGDIPPicture.GetImageSizes: boolean;
var
  multi: TGPImage;
  pstm: IStream;
  hGlobal: THandle;
  pcbWrite: Longint;
begin
  Result := false;

  if Empty then
    Exit;

  if FDataStream.Size = 0 then
    Exit;

  hGlobal := GlobalAlloc(GMEM_MOVEABLE, FDataStream.Size);
  if (hGlobal = 0) then
    raise Exception.Create('Could not allocate memory for image');

  try
    pstm := nil;
    // Create IStream* from global memory
    CreateStreamOnHGlobal(hGlobal, TRUE, pstm);
    pstm.Write(FDataStream.Memory, FDataStream.Size,@pcbWrite);
    multi := TGPImage.Create(pstm);

    FWidth := multi.GetWidth;
    FHeight := multi.GetHeight;

    Result := true;

    multi.Free;
  finally
    GlobalFree(hGlobal);
  end;

end;

function TAdvGDIPPicture.GetImageSizesFromFileName(FileName: String): boolean;
var
  sExt: String;
  w, h: Word;
begin
  Result := false;

  if Empty then
    Exit;

  if FDataStream.Size = 0 then
    Exit;

  sExt := UpperCase(ExtractFileExt(FileName));

  if (sExt = '.JPG') or (sExt = '.JPEG') then
    GetJPGSize(FileName, w, h)
  else if sExt = '.PNG' then
    GetPNGSize(FileName, w, h)
  else if sExt = '.BMP' then
    GetBMPSize(FileName, w, h)
  else if sExt = '.TIFF' then
    GetTifSize(FileName, w, h)
  else if sExt = '.GIF' then
    GetGIFSize(FileName, w, h)
  else
  begin
    w := 0;
    h := 0;
  end;

  Fwidth := w;
  FHeight := h;
end;

procedure TAdvGDIPPicture.GDIPDraw(Graphics: TGPGraphics; const Rect: TRect);
var
  multi: TGPImage;
  pstm: IStream;
  hGlobal: THandle;
  pcbWrite: Longint;
  ia: TGPImageAttributes;
  gpColor: TGPColor;
  bmp: TGPBitmap;

begin
  if Empty then
    Exit;

  if FDataStream.Size = 0 then
    Exit;

  hGlobal := GlobalAlloc(GMEM_MOVEABLE, FDataStream.Size);

  if (hGlobal = 0) then
    raise Exception.Create('Could not allocate memory for image');
  try
    pstm := nil;
    // Create IStream* from global memory
    CreateStreamOnHGlobal(hGlobal, TRUE, pstm);
    pstm.Write(FDataStream.Memory, FDataStream.Size,@pcbWrite);
    multi := TGPImage.Create(pstm);

    FHasAlpha := multi.HasAlphaChannel;
    FHasPalette := multi.HasPalette;
    FPixelDepth := multi.GetPixelDepth;
    FPixelFormat := multi.GetPixelFormat;

    FWidth := multi.GetWidth;
    FHeight := multi.GetHeight;
    FWidth := multi.GetWidth;
    FHeight := multi.GetHeight;

    if (multi.GetFormat = ifBMP) and (Transparent) then
    begin // use this alternative for easy bitmap auto transparent drawing

      ia := TGPImageAttributes.Create;

      if (FBitmapTransparentMode = tmAuto) then
      begin
        bmp := TGPBitmap.Create(pstm);
        bmp.GetPixel(0,FHeight - 1, gpColor);
        bmp.Free;
      end
      else
        gpColor := MakeColor(255, FBitmapTransparentColor);

      ia.SetColorKey(gpColor, gpColor);

      Graphics.DrawImage(multi,MakeRect(Rect.Left,Rect.Top,FWidth,FHeight),0,0,FWidth,FHeight,UnitPixel,ia);
      ia.Free;

    end
    else
      Graphics.DrawImageRect(multi, Rect.Left, Rect.Top, Rect.Right - Rect.Left, Rect.Bottom - Rect.Top);

    multi.Free;
  finally
    GlobalFree(hGlobal);
  end;
end;

function TAdvGDIPPicture.GetEmpty: Boolean;
begin
  Result := FIsEmpty;
end;

procedure TAdvGDIPPicture.FillPath(graphics: TGPGraphics; Path: TGPGraphicsPath);
var
  multi: TGPImage;
  pstm: IStream;
  hGlobal: THandle;
  pcbWrite: Longint;
  tb: TGPTextureBrush;
begin
  if Empty then
    Exit;

  if FDataStream.Size = 0 then
    Exit;

  hGlobal := GlobalAlloc(GMEM_MOVEABLE, FDataStream.Size);

  if (hGlobal = 0) then
    raise Exception.Create('Could not allocate memory for image');
  try
    pstm := nil;
    // Create IStream* from global memory
    CreateStreamOnHGlobal(hGlobal, TRUE, pstm);
    pstm.Write(FDataStream.Memory, FDataStream.Size,@pcbWrite);
    multi := TGPImage.Create(pstm);

    tb := TGPTextureBrush.Create(multi);

    Graphics.FillPath(tb,path);

    tb.Free;

    multi.Free;
  finally
    GlobalFree(hGlobal);
  end;
end;


procedure TAdvGDIPPicture.FillRect(graphics: TGPGraphics; R: TGPRectf);
var
  multi: TGPImage;
  pstm: IStream;
  hGlobal: THandle;
  pcbWrite: Longint;
  tb: TGPTextureBrush;
begin

  if Empty then
    Exit;

  if FDataStream.Size = 0 then
    Exit;

  hGlobal := GlobalAlloc(GMEM_MOVEABLE, FDataStream.Size);

  if (hGlobal = 0) then
    raise Exception.Create('Could not allocate memory for image');
  try
    pstm := nil;
    // Create IStream* from global memory
    CreateStreamOnHGlobal(hGlobal, TRUE, pstm);
    pstm.Write(FDataStream.Memory, FDataStream.Size,@pcbWrite);
    multi := TGPImage.Create(pstm);

    tb := TGPTextureBrush.Create(multi);

    Graphics.FillRectangle(tb, R);

    tb.Free;

    multi.Free;
  finally
    GlobalFree(hGlobal);
  end;
end;

function TAdvGDIPPicture.GetHeight: Integer;
begin
  Result := FHeight;
end;

function TAdvGDIPPicture.GetWidth: Integer;
begin
  Result := FWidth;
end;

procedure TAdvGDIPPicture.LoadFromFile(const FileName: string);
begin
  try
    FDataStream.LoadFromFile(Filename);

    FIsEmpty := False;

    if Assigned(OnClear) then
      OnClear(self);

    GetImageSizesFromFileName(FileName);

    if Assigned(OnChange) then
      OnChange(self);

  except
    FIsEmpty:=true;
  end;
end;

procedure TAdvGDIPPicture.LoadFromStream(Stream: TStream);
begin
  if Assigned(Stream) then
  begin
    if Stream.Size > 0 then
    begin
      FDataStream.LoadFromStream(Stream);
      FIsEmpty := False;

      GetImageSizes;

      if Assigned(OnChange) then
        OnChange(self);
    end;    
  end;
end;

procedure TAdvGDIPPicture.ReadData(Stream: TStream);
begin
  if Assigned(Stream) then
  begin
    if Stream.Size > 0 then
    begin
      FDataStream.LoadFromStream(Stream);
      FIsEmpty := False;

      GetImageSizes;
    end;
  end;
end;

procedure TAdvGDIPPicture.SaveToStream(Stream: TStream);
begin
  if Assigned(Stream) then
    FDataStream.SaveToStream(Stream);
end;


procedure TAdvGDIPPicture.SetHeight(Value: Integer);
begin
  {$IFDEF DELPHI6_LVL}
  inherited;
  {$ENDIF}
end;

procedure TAdvGDIPPicture.SetWidth(Value: Integer);
begin
  {$IFDEF DELPHI6_LVL}
  inherited;
  {$ENDIF}
end;

procedure TAdvGDIPPicture.LoadFromResourceName(Instance: THandle; const ResName: string);
var
  Stream: TCustomMemoryStream;
begin
  if FindResource(Instance,PChar(ResName),RT_RCDATA) <> 0 then
  begin
    Stream := TResourceStream.Create(Instance, ResName, RT_RCDATA);
    try
      LoadFromStream(Stream);
    finally
      Stream.Free;
    end;
  end;
end;

procedure TAdvGDIPPicture.LoadFromResourceID(Instance: THandle; ResID: Integer);
var
  Stream: TCustomMemoryStream;
begin
  Stream := TResourceStream.CreateFromID(Instance, ResID, RT_RCDATA);
  try
    LoadFromStream(Stream);
  finally
    Stream.Free;
  end;
end;

procedure TAdvGDIPPicture.WriteData(Stream: TStream);
begin
  if Assigned(Stream) then
  begin
    FDataStream.SaveToStream(stream);
  end;
end;

procedure TAdvGDIPPicture.LoadFromURL(url: string);
begin
  if (pos('RES://',UpperCase(url))=1) then
  begin
    Delete(url,1,6);
    if (url<>'') then
      LoadFromResourceName(hinstance,url);
    Exit;
  end;

  if (pos('FILE://',uppercase(url))=1) then
  begin
    Delete(url,1,7);
    if (url<>'')
      then LoadFromFile(url);
  end;
end;

procedure TAdvGDIPPicture.LoadFromClipboardFormat(AFormat: Word;
  AData: THandle; APalette: HPALETTE);
begin
end;

procedure TAdvGDIPPicture.SaveToClipboardFormat(var AFormat: Word;
  var AData: THandle; var APalette: HPALETTE);
begin
end;

procedure ShadowGDIP(graphics: TGPGraphics; Rect: TGPRectF);
var
  path: TGPGraphicsPath;
  pthGrbrush: TGPPathGradientBrush;
  colors:array[0..2] of TGPColor;
  positions: array[0..2] of single;

begin
  path := TGPGraphicsPath.Create;
  path.AddRectangle(Rect);

  pthGrbrush := TGPPathGradientBrush.Create(path);
  pthGrbrush.SetWrapMode(WrapModeClamp);

  colors[0] := MakeColor(0,0,0,0);
  colors[1] := MakeColor(180, clGray);
  colors[2] := MakeColor(180, clGray);

  positions[0] := 0;
  positions[1] := 0.1;
  positions[2] := 1;

  pthGrBrush.SetInterpolationColors(@colors, @positions, 3);

  graphics.FillPath(pthGrBrush, path);

  pthGrBrush.Free;
  path.Free;
end;

procedure FillGDIP(Params: TGDIPFillParameters);
var
  sb: TGPSolidBrush;
  lb: TGPLinearGradientBrush;
  hb: TGPHatchBrush;
  mode: TLinearGradientMode;
  pen: TGPPen;
  tempr: TGPRectF;
begin
 case Params.GT of
 gtSolid:
   begin
     sb := TGPSolidBrush.Create(MakeColor(Params.OpacityFrom, Params.ColorFrom));

     if Params.FillPath then
     begin
       Params.Graphics.FillPath(sb, Params.Path)
     end
     else
       Params.Graphics.FillRectangle(sb, Params.R);
     sb.Free;
   end;
 gtVertical, gtHorizontal, gtForwardDiagonal, gtBackwardDiagonal:
   begin
     mode := LinearGradientModeVertical;
     if Params.GT = gtHorizontal then
        mode := LinearGradientModeHorizontal;
     if Params.GT = gtForwardDiagonal then
        mode := LinearGradientModeForwardDiagonal;
     if Params.GT = gtBackwardDiagonal then
        mode := LinearGradientModeBackwardDiagonal;


     tempr := MakeRect(Params.R.X - 1, Params.R.Y - 1, Params.R.Width + 2, Params.R.Height + 2);
     lb := TGPLinearGradientBrush.Create(tempr, MakeColor(Params.OpacityFrom, Params.ColorFrom),
        MakeColor(Params.OpacityTo, Params.ColorTo),mode);

     lb.SetGammaCorrection(true);

     if Params.FillPath then
     begin
       Params.Graphics.FillPath(lb, Params.Path)
     end
     else
     begin
       Params.Graphics.FillRectangle(lb, Params.R);
     end;

     lb.Free;

     if (Params.Mirror) then
     begin
       // workaround for stupid GDI+ border issue
       sb := TGPSolidBrush.Create(MakeColor(Params.OpacityFrom, Params.ColorFrom));
       Params.Graphics.FillRectangle(sb, MakeRect(Params.R.X, Params.R.Y, Params.R.Width, 1));
       sb.Free;
     end;
   end;
 gtAngle:
   begin
     lb := TGPLinearGradientBrush.Create(MakeRect(Params.R.X - 1, Params.R.Y - 1, Params.R.Width + 2, Params.R.Height + 2), MakeColor(Params.OpacityFrom, Params.ColorFrom),
        MakeColor(Params.OpacityTo, Params.ColorTo), Params.Angle, true);
     lb.SetGammaCorrection(true);

     if Params.FillPath then
       Params.Graphics.FillPath(lb, Params.Path)
     else
       Params.Graphics.FillRectangle(lb, Params.R);

     lb.Free;
   end;
 gtHatch:
   begin
     hb := TGPHatchBrush.Create(Params.HatchStyle, MakeColor(Params.OpacityFrom, Params.ColorFrom),
        MakeColor(Params.OpacityTo, Params.ColorTo));
     if Params.FillPath then
       Params.Graphics.FillPath(hb, Params.Path)
     else
       Params.Graphics.FillRectangle(hb, Params.R);

     hb.Free;
   end;
 gtPath:
   begin
   end;
 gtTexture:
   begin
     if Assigned(Params.Image) then
     begin
       if Params.FillPath then
         Params.Image.FillPath(Params.Graphics, Params.Path)
       else
         Params.Image.FillRect(Params.Graphics, Params.R);
     end;
   end;
 end;

 if (Params.BorderColor <> clNone) then
 begin
   pen := TGPPen.Create(MakeColor(Params.OpacityFrom, Params.BorderColor), Params.BorderWidth);

   pen.SetDashStyle(Params.BorderStyle);

   if Params.FillPath then
     Params.Graphics.DrawPath(pen, Params.Path)
   else
     Params.Graphics.DrawRectangle(pen, Params.R);

   pen.Free;
 end;

end;

procedure ArrowGDIP(graphics: TGPGraphics; origin, target : TPoint; ArrowSize: integer; ArrowColor: TColor; ScaleX, ScaleY: Double);
var
  quarter: byte;             // quadrant (tl, tr, br, bl) ?
  fx, px: Integer;
  fy, py: Integer;
  x, y: integer;
  arrowpts: array[0..3] of TGPPointF;
  p: tpoint;
  ar: TPoint;
  h: Integer;
  arx, ary: integer;
  path: TGPGraphicsPath;
  brush: TGPBrush;

begin
  arx := Round(ArrowSize * ScaleX);
  ary := Round(ArrowSize * ScaleY);

  arrowpts[0].x := target.X;
  arrowpts[0].y := target.Y;

  x := target.x - origin.x;
  y := target.y - origin.y;
  h := round(sqrt(sqr(x) + sqr(y)));

  if h = 0 then
    h := 1;

  // quarter?
  if origin.x < target.x then
  begin
    if origin.y < target.y then
      quarter := 1
    else
      quarter := 3;
  end
  else
  begin
    if origin.y < target.y then
      quarter := 2
    else
      quarter := 4;
  end;

  // calculate the actual P position using the adjustments px and py.
  px := x * arx div h;
  py := y * ary div h;
  case quarter of
    1 :
      begin
        p.x := target.x - px;
        p.y := target.y - py;
        ar.x := target.x - (x * arx div h);
        ar.y := target.y - (y * ary div h);
      end;
    2 :
      begin
        p.x := target.x - px;
        p.y := target.y - py;
        ar.x := target.x - (x * arx div h);
        ar.y := target.y - (y * ary div h);
      end;
    3 :
      begin
        p.x := target.x - px;
        p.y := target.y - py;
        ar.x := target.x - (x * arx div h);
        ar.y := target.y - (y * ary div h);
      end;
    4 :
      begin
        p.x := Target.x - px;
        p.y := Target.y - py;
        ar.x := target.x - (x * arx div h);
        ar.y := target.y - (y * ary div h);
      end;
  end;

  //calculate pts[1] and pts[2] from the P position to give us the back of the arrow.
  fx := y * (arx div 2) div h;
  fy := x * (ary div 2) div h;
  case quarter of
    1 :
      begin
        arrowpts[1].x := p.x - fx;
        arrowpts[1].y := p.y + fy;
        arrowpts[3].x := p.x + fx;
        arrowpts[3].y := p.y - fy;
      end;
    2 :
      begin
        arrowpts[1].x := p.x + fx;
        arrowpts[1].y := p.y - fy;
        arrowpts[3].x := p.x - fx;
        arrowpts[3].y := p.y + fy;
      end;
    3 :
      begin
        arrowpts[1].x := p.x + fx;
        arrowpts[1].y := p.y - fy;
        arrowpts[3].x := p.x - fx;
        arrowpts[3].y := p.y + fy;
      end;
    4 :
      begin
        arrowpts[1].x := p.x + fx;
        arrowpts[1].y := p.y - fy;
        arrowpts[3].x := p.x - fx;
        arrowpts[3].y := p.y + fy;
      end;
  end;

  arrowpts[2].x := ar.X;
  arrowpts[2].y := ar.Y;

  path := TGPGraphicsPath.Create;
  path.AddPolygon(PGPPointF(@arrowpts),4);

  brush := TGPSolidBrush.Create(MakeColor(255,ArrowColor));

  graphics.FillPath(brush,path);

  path.Free;
  brush.Free;
end;

function GetImageEncoders(numEncoders, size: UINT;
   encoders: PImageCodecInfo): TStatus;
begin
  result := GdipGetImageEncoders(numEncoders, size, encoders);
end;

function GetImageEncodersSize(out numEncoders, size: UINT): TStatus;
begin
  result := GdipGetImageEncodersSize(numEncoders, size);
end;

function GetEncoderClsid(format: String; out pClsid: TGUID): integer;
var
  num, size, j: UINT;
  ImageCodecInfo: PImageCodecInfo;
Type
  ArrIMgInf = array of TImageCodecInfo;
begin
  num  := 0; // number of image encoders
  size := 0; // size of the image encoder array in bytes
  result := -1;

  GetImageEncodersSize(num, size);
  if (size = 0) then exit;

  GetMem(ImageCodecInfo, size);
  if(ImageCodecInfo = nil) then exit;

  GetImageEncoders(num, size, ImageCodecInfo);

  for j := 0 to num - 1 do
  begin
    if( ArrIMgInf(ImageCodecInfo)[j].MimeType = format) then
    begin
      pClsid := ArrIMgInf(ImageCodecInfo)[j].Clsid;
      result := j;  // Success
    end;
  end;
  FreeMem(ImageCodecInfo, size);
end;

function ColorToARGB(Color: TColor): ARGB;
var
  c: TColor;
begin
  c := ColorToRGB(Color);
  Result := ARGB( $FF000000 or ((DWORD(c) and $FF) shl 16) or ((DWORD(c) and $FF00) or ((DWORD(c) and $ff0000) shr 16)));
end;

  function GdipGetImageDecodersSize; external WINGDIPDLL name 'GdipGetImageDecodersSize';
  function GdipGetImageDecoders; external WINGDIPDLL name 'GdipGetImageDecoders';
  function GdipGetImageEncodersSize; external WINGDIPDLL name 'GdipGetImageEncodersSize';
  function GdipGetImageEncoders; external WINGDIPDLL name 'GdipGetImageEncoders';
  function GdipAlloc; external WINGDIPDLL name 'GdipAlloc';
  procedure GdipFree; external WINGDIPDLL name 'GdipFree';
  function GdiplusStartup; external WINGDIPDLL name 'GdiplusStartup';
  procedure GdiplusShutdown; external WINGDIPDLL name 'GdiplusShutdown';
  function GdipFillEllipse; external WINGDIPDLL name 'GdipFillEllipse';
  function GdipFillEllipseI; external WINGDIPDLL name 'GdipFillEllipseI';
  function GdipCreatePath; external WINGDIPDLL name 'GdipCreatePath';
  function GdipDeletePath; external WINGDIPDLL name 'GdipDeletePath';
  //function GdipStartPathFigure; external WINGDIPDLL name 'GdipStartPathFigure';
  function GdipClosePathFigure; external WINGDIPDLL name 'GdipClosePathFigure';
  function GdipAddPathLine; external WINGDIPDLL name 'GdipAddPathLine';
  function GdipAddPathArc; external WINGDIPDLL name 'GdipAddPathArc';
  function GdipAddPathEllipse; external WINGDIPDLL name 'GdipAddPathEllipse';
  function GdipAddPathPie; external WINGDIPDLL name 'GdipAddPathPie';
  function GdipDeleteBrush; external WINGDIPDLL name 'GdipDeleteBrush';
  function GdipCreateSolidFill; external WINGDIPDLL name 'GdipCreateSolidFill';
  function GdipCreateHatchBrush; external WINGDIPDLL name 'GdipCreateHatchBrush';
  function GdipGetHatchStyle; external WINGDIPDLL name 'GdipGetHatchStyle';
  function GdipGetHatchForegroundColor; external WINGDIPDLL name 'GdipGetHatchForegroundColor';
  function GdipGetHatchBackgroundColor; external WINGDIPDLL name 'GdipGetHatchBackgroundColor';
  function GdipCreateLineBrushFromRect; external WINGDIPDLL name 'GdipCreateLineBrushFromRect';
  function GdipCreateLineBrushFromRectI; external WINGDIPDLL name 'GdipCreateLineBrushFromRectI';
  function GdipCreateLineBrushFromRectWithAngle; external WINGDIPDLL name 'GdipCreateLineBrushFromRectWithAngle';
  function GdipCreateLineBrushFromRectWithAngleI; external WINGDIPDLL name 'GdipCreateLineBrushFromRectWithAngleI';
  function GdipCreatePathGradient; external WINGDIPDLL name 'GdipCreatePathGradient';
  function GdipCreatePathGradientI; external WINGDIPDLL name 'GdipCreatePathGradientI';
  function GdipCreatePathGradientFromPath; external WINGDIPDLL name 'GdipCreatePathGradientFromPath';
  function GdipGetPathGradientCenterColor; external WINGDIPDLL name 'GdipGetPathGradientCenterColor';
  function GdipSetPathGradientCenterColor; external WINGDIPDLL name 'GdipSetPathGradientCenterColor';
  function GdipGetPathGradientSurroundColorsWithCount; external WINGDIPDLL name 'GdipGetPathGradientSurroundColorsWithCount';
  function GdipSetPathGradientSurroundColorsWithCount; external WINGDIPDLL name 'GdipSetPathGradientSurroundColorsWithCount';
  function GdipGetPathGradientCenterPoint; external WINGDIPDLL name 'GdipGetPathGradientCenterPoint';
  function GdipGetPathGradientCenterPointI; external WINGDIPDLL name 'GdipGetPathGradientCenterPointI';
  function GdipSetPathGradientCenterPoint; external WINGDIPDLL name 'GdipSetPathGradientCenterPoint';
  function GdipSetPathGradientCenterPointI; external WINGDIPDLL name 'GdipSetPathGradientCenterPointI';
  function GdipGetPathGradientPointCount; external WINGDIPDLL name 'GdipGetPathGradientPointCount';
  function GdipGetPathGradientSurroundColorCount; external WINGDIPDLL name 'GdipGetPathGradientSurroundColorCount';
  function GdipCreatePen1; external WINGDIPDLL name 'GdipCreatePen1';
  function GdipCreatePen2; external WINGDIPDLL name 'GdipCreatePen2';
  function GdipDrawEllipse; external WINGDIPDLL name 'GdipDrawEllipse';
  function GdipDrawEllipseI; external WINGDIPDLL name 'GdipDrawEllipseI';    
  function GdipDeletePen; external WINGDIPDLL name 'GdipDeletePen';
  function GdipFlush; external WINGDIPDLL name 'GdipFlush';
  function GdipCreateFromHDC; external WINGDIPDLL name 'GdipCreateFromHDC';
  function GdipDeleteGraphics; external WINGDIPDLL name 'GdipDeleteGraphics';
  function GdipGetDC; external WINGDIPDLL name 'GdipGetDC';
  function GdipReleaseDC; external WINGDIPDLL name 'GdipReleaseDC';
  function GdipSetInterpolationMode; external WINGDIPDLL name 'GdipSetInterpolationMode';
  function GdipSetSmoothingMode; external WINGDIPDLL name 'GdipSetSmoothingMode';
  function GdipGetSmoothingMode; external WINGDIPDLL name 'GdipGetSmoothingMode';
  function GdipSetPixelOffsetMode; external WINGDIPDLL name 'GdipSetPixelOffsetMode';
  function GdipGetPixelOffsetMode; external WINGDIPDLL name 'GdipGetPixelOffsetMode';
  function GdipSetTextRenderingHint; external WINGDIPDLL name 'GdipSetTextRenderingHint';
  function GdipGetTextRenderingHint; external WINGDIPDLL name 'GdipGetTextRenderingHint';
  function GdipDrawPath; external WINGDIPDLL name 'GdipDrawPath';
  function GdipFillRectangle; external WINGDIPDLL name 'GdipFillRectangle';
  function GdipGraphicsClear; external WINGDIPDLL name 'GdipGraphicsClear';
  function GdipCreateFontFamilyFromName; external WINGDIPDLL name 'GdipCreateFontFamilyFromName';
  function GdipDeleteFontFamily; external WINGDIPDLL name 'GdipDeleteFontFamily';
  function GdipCreateFont; external WINGDIPDLL name 'GdipCreateFont';
  function GdipDeleteFont; external WINGDIPDLL name 'GdipDeleteFont';
  function GdipDrawString; external WINGDIPDLL name 'GdipDrawString';
  function GdipMeasureString; external WINGDIPDLL name 'GdipMeasureString';
  function GdipCreateStringFormat; external WINGDIPDLL name 'GdipCreateStringFormat';
  function GdipDeleteStringFormat; external WINGDIPDLL name 'GdipDeleteStringFormat';
  function GdipCloneStringFormat; external WINGDIPDLL name 'GdipCloneStringFormat';
  function GdipSetStringFormatAlign; external WINGDIPDLL name 'GdipSetStringFormatAlign';
  function GdipGetStringFormatAlign; external WINGDIPDLL name 'GdipGetStringFormatAlign';
  function GdipSetStringFormatLineAlign; external WINGDIPDLL name 'GdipSetStringFormatLineAlign';
  function GdipGetStringFormatLineAlign; external WINGDIPDLL name 'GdipGetStringFormatLineAlign';
  function GdipSetStringFormatTrimming; external WINGDIPDLL name 'GdipSetStringFormatTrimming';
  function GdipGetStringFormatTrimming; external WINGDIPDLL name 'GdipGetStringFormatTrimming';
  function GdipGetImageRawFormat; external WINGDIPDLL name 'GdipGetImageRawFormat';
  function GdipDrawImage; external WINGDIPDLL name 'GdipDrawImage';
  function GdipDrawImageI; external WINGDIPDLL name 'GdipDrawImageI';
  function GdipDrawImageRect; external WINGDIPDLL name 'GdipDrawImageRect';
  function GdipDrawImageRectI; external WINGDIPDLL name 'GdipDrawImageRectI';
  function GdipDrawImageRectRect; external WINGDIPDLL name 'GdipDrawImageRectRect';
  function GdipDrawImageRectRectI; external WINGDIPDLL name 'GdipDrawImageRectRectI';
  function GdipDrawImagePointsRect; external WINGDIPDLL name 'GdipDrawImagePointsRect';
  function GdipDrawImagePointsRectI; external WINGDIPDLL name 'GdipDrawImagePointsRectI';
  function GdipGetPenBrushFill; external WINGDIPDLL name 'GdipGetPenBrushFill';
  function GdipFillRectangleI; external WINGDIPDLL name 'GdipFillRectangleI';    
  function GdipDrawRectangle; external WINGDIPDLL name 'GdipDrawRectangle';
  function GdipDrawRectangleI; external WINGDIPDLL name 'GdipDrawRectangleI';
  function GdipDrawLine; external WINGDIPDLL name 'GdipDrawLine';
  function GdipDrawLineI; external WINGDIPDLL name 'GdipDrawLineI';  
  function GdipCreateLineBrush; external WINGDIPDLL name 'GdipCreateLineBrush';
  function GdipCreateLineBrushI; external WINGDIPDLL name 'GdipCreateLineBrushI';  
  function GdipFillPolygon; external WINGDIPDLL name 'GdipFillPolygon';
  function GdipFillPolygonI; external WINGDIPDLL name 'GdipFillPolygonI';
  function GdipDrawArc; external WINGDIPDLL name 'GdipDrawArc';
  function GdipDrawArcI; external WINGDIPDLL name 'GdipDrawArcI';  
  function GdipFillPath; external WINGDIPDLL name 'GdipFillPath';
  function GdipSaveImageToFile; external WINGDIPDLL name 'GdipSaveImageToFile';
  function GdipSaveImageToStream; external WINGDIPDLL name 'GdipSaveImageToStream';  
  function GdipLoadImageFromFileICM; external WINGDIPDLL name 'GdipLoadImageFromFileICM';
  function GdipLoadImageFromFile; external WINGDIPDLL name 'GdipLoadImageFromFile';
  function GdipLoadImageFromStream; external WINGDIPDLL name 'GdipLoadImageFromStream';
  function GdipLoadImageFromStreamICM; external WINGDIPDLL name 'GdipLoadImageFromStreamICM';
  function GdipDisposeImage; external WINGDIPDLL name 'GdipDisposeImage';
  function GdipSaveAddImage; external WINGDIPDLL name 'GdipSaveAddImage';
  function GdipGetImageWidth; external WINGDIPDLL name 'GdipGetImageWidth';
  function GdipGetImageHeight; external WINGDIPDLL name 'GdipGetImageHeight';
  function GdipGetPenDashStyle; external WINGDIPDLL name 'GdipGetPenDashStyle';
  function GdipSetPenDashStyle; external WINGDIPDLL name 'GdipSetPenDashStyle';
  function GdipSetStringFormatHotkeyPrefix; external WINGDIPDLL name 'GdipSetStringFormatHotkeyPrefix';
  function GdipGetStringFormatHotkeyPrefix; external WINGDIPDLL name 'GdipGetStringFormatHotkeyPrefix';
  function GdipSetClipRect; external WINGDIPDLL name 'GdipSetClipRect';
  function GdipSetClipRegion; external WINGDIPDLL name 'GdipSetClipRegion';
  function GdipCreateRegionRect; external WINGDIPDLL name 'GdipCreateRegionRect';
  function GdipCreateRegionPath; external WINGDIPDLL name 'GdipCreateRegionPath';
  function GdipDeleteRegion; external WINGDIPDLL name 'GdipDeleteRegion';
  function GdipCombineRegionPath; external WINGDIPDLL name 'GdipCombineRegionPath';
  function GdipCombineRegionRegion; external WINGDIPDLL name 'GdipCombineRegionRegion';
  function GdipSetCompositingQuality; external WINGDIPDLL name 'GdipSetCompositingQuality';
  function GdipGetCompositingQuality; external WINGDIPDLL name 'GdipGetCompositingQuality';
  function GdipImageRotateFlip; external WINGDIPDLL name 'GdipImageRotateFlip';
  function GdipCreateBitmapFromStreamICM; external WINGDIPDLL name 'GdipCreateBitmapFromStreamICM';
  function GdipCreateBitmapFromStream; external WINGDIPDLL name 'GdipCreateBitmapFromStream';
  function GdipCreateBitmapFromScan0; external WINGDIPDLL name 'GdipCreateBitmapFromScan0';
  function GdipCreateBitmapFromFile; external WINGDIPDLL name 'GdipCreateBitmapFromFile';  
  function GdipCreateHBITMAPFromBitmap; external WINGDIPDLL name 'GdipCreateHBITMAPFromBitmap';  
  function GdipBitmapGetPixel; external WINGDIPDLL name 'GdipBitmapGetPixel';
  function GdipBitmapSetPixel; external WINGDIPDLL name 'GdipBitmapSetPixel';
  function GdipSetPenEndCap; external WINGDIPDLL name 'GdipSetPenEndCap';
  function GdipAddPathLine2I; external WINGDIPDLL name 'GdipAddPathLine2I';
  function GdipAddPathPolygon; external WINGDIPDLL name 'GdipAddPathPolygon';
  function GdipAddPathPolygonI; external WINGDIPDLL name 'GdipAddPathPolygonI';
  function GdipAddPathCurveI; external WINGDIPDLL name 'GdipAddPathCurveI';
  function GdipAddPathCurve; external WINGDIPDLL name 'GdipAddPathCurve';
  function GdipAddPathCurve2I; external WINGDIPDLL name 'GdipAddPathCurve2I';
  function GdipResetClip; external WINGDIPDLL name 'GdipResetClip';
  function GdipAddPathBezier; external WINGDIPDLL name 'GdipAddPathBezier';
  function GdipAddPathRectangle; external WINGDIPDLL name 'GdipAddPathRectangle';
  function GdipAddPathRectangleI; external WINGDIPDLL name 'GdipAddPathRectangleI';
  function GdipSetPathGradientGammaCorrection; external WINGDIPDLL name 'GdipSetPathGradientGammaCorrection';
  function GdipGetPathGradientGammaCorrection; external WINGDIPDLL name 'GdipGetPathGradientGammaCorrection';
  function GdipCreateTexture; external WINGDIPDLL name 'GdipCreateTexture';
  function GdipCreateTexture2; external WINGDIPDLL name 'GdipCreateTexture2';
  function GdipCreateTextureIA; external WINGDIPDLL name 'GdipCreateTextureIA';
  function GdipCreateTexture2I; external WINGDIPDLL name 'GdipCreateTexture2I';
  function GdipCreateTextureIAI; external WINGDIPDLL name 'GdipCreateTextureIAI';
  function GdipGetTextureTransform; external WINGDIPDLL name 'GdipGetTextureTransform';
  function GdipSetTextureTransform; external WINGDIPDLL name 'GdipSetTextureTransform';
  function GdipResetTextureTransform; external WINGDIPDLL name 'GdipResetTextureTransform';
  function GdipMultiplyTextureTransform; external WINGDIPDLL name 'GdipMultiplyTextureTransform';
  function GdipTranslateTextureTransform; external WINGDIPDLL name 'GdipTranslateTextureTransform';
  function GdipScaleTextureTransform; external WINGDIPDLL name 'GdipScaleTextureTransform';
  function GdipRotateTextureTransform; external WINGDIPDLL name 'GdipRotateTextureTransform';
  function GdipSetTextureWrapMode; external WINGDIPDLL name 'GdipSetTextureWrapMode';
  function GdipGetTextureWrapMode; external WINGDIPDLL name 'GdipGetTextureWrapMode';
  function GdipGetTextureImage; external WINGDIPDLL name 'GdipGetTextureImage';
  function GdipCreateMatrix; external WINGDIPDLL name 'GdipCreateMatrix';
  function GdipCreateMatrix2; external WINGDIPDLL name 'GdipCreateMatrix2';
  function GdipCreateMatrix3; external WINGDIPDLL name 'GdipCreateMatrix3';
  function GdipCreateMatrix3I; external WINGDIPDLL name 'GdipCreateMatrix3I';
  function GdipCloneMatrix; external WINGDIPDLL name 'GdipCloneMatrix';
  function GdipDeleteMatrix; external WINGDIPDLL name 'GdipDeleteMatrix';
  function GdipSetMatrixElements; external WINGDIPDLL name 'GdipSetMatrixElements';
  function GdipMultiplyMatrix; external WINGDIPDLL name 'GdipMultiplyMatrix';
  function GdipTranslateMatrix; external WINGDIPDLL name 'GdipTranslateMatrix';
  function GdipScaleMatrix; external WINGDIPDLL name 'GdipScaleMatrix';
  function GdipRotateMatrix; external WINGDIPDLL name 'GdipRotateMatrix';
  function GdipShearMatrix; external WINGDIPDLL name 'GdipShearMatrix';
  function GdipInvertMatrix; external WINGDIPDLL name 'GdipInvertMatrix';
  function GdipTransformMatrixPoints; external WINGDIPDLL name 'GdipTransformMatrixPoints';
  function GdipTransformMatrixPointsI; external WINGDIPDLL name 'GdipTransformMatrixPointsI';
  function GdipVectorTransformMatrixPoints; external WINGDIPDLL name 'GdipVectorTransformMatrixPoints';
  function GdipVectorTransformMatrixPointsI; external WINGDIPDLL name 'GdipVectorTransformMatrixPointsI';
  function GdipGetMatrixElements; external WINGDIPDLL name 'GdipGetMatrixElements';
  function GdipIsMatrixInvertible; external WINGDIPDLL name 'GdipIsMatrixInvertible';
  function GdipIsMatrixIdentity; external WINGDIPDLL name 'GdipIsMatrixIdentity';
  function GdipIsMatrixEqual; external WINGDIPDLL name 'GdipIsMatrixEqual';
  function GdipCreateImageAttributes; external WINGDIPDLL name 'GdipCreateImageAttributes';
  function GdipCloneImageAttributes; external WINGDIPDLL name 'GdipCloneImageAttributes';
  function GdipDisposeImageAttributes; external WINGDIPDLL name 'GdipDisposeImageAttributes';
  function GdipSetImageAttributesToIdentity; external WINGDIPDLL name 'GdipSetImageAttributesToIdentity';
  function GdipResetImageAttributes; external WINGDIPDLL name 'GdipResetImageAttributes';
  function GdipSetImageAttributesColorMatrix; external WINGDIPDLL name 'GdipSetImageAttributesColorMatrix';
  function GdipSetImageAttributesThreshold; external WINGDIPDLL name 'GdipSetImageAttributesThreshold';
  function GdipSetImageAttributesGamma; external WINGDIPDLL name 'GdipSetImageAttributesGamma';
  function GdipSetImageAttributesNoOp; external WINGDIPDLL name 'GdipSetImageAttributesNoOp';
  function GdipSetImageAttributesColorKeys; external WINGDIPDLL name 'GdipSetImageAttributesColorKeys';
  function GdipSetImageAttributesOutputChannel; external WINGDIPDLL name 'GdipSetImageAttributesOutputChannel';
  function GdipSetImageAttributesOutputChannelColorProfile; external WINGDIPDLL name 'GdipSetImageAttributesOutputChannelColorProfile';
  function GdipSetImageAttributesRemapTable; external WINGDIPDLL name 'GdipSetImageAttributesRemapTable';
  function GdipSetImageAttributesWrapMode; external WINGDIPDLL name 'GdipSetImageAttributesWrapMode';
  function GdipSetImageAttributesICMMode; external WINGDIPDLL name 'GdipSetImageAttributesICMMode';
  function GdipGetImageAttributesAdjustedPalette; external WINGDIPDLL name 'GdipGetImageAttributesAdjustedPalette';
  function GdipSetLineGammaCorrection; external WINGDIPDLL name 'GdipSetLineGammaCorrection';
  function GdipGetLineGammaCorrection; external WINGDIPDLL name 'GdipGetLineGammaCorrection';
  function GdipGetPathGradientWrapMode; external WINGDIPDLL name 'GdipGetPathGradientWrapMode';
  function GdipSetPathGradientWrapMode; external WINGDIPDLL name 'GdipSetPathGradientWrapMode';
  function GdipGetPathGradientBlendCount; external WINGDIPDLL name 'GdipGetPathGradientBlendCount';
  function GdipGetPathGradientBlend; external WINGDIPDLL name 'GdipGetPathGradientBlend';
  function GdipSetPathGradientBlend; external WINGDIPDLL name 'GdipSetPathGradientBlend';
  function GdipGetPathGradientPresetBlendCount; external WINGDIPDLL name 'GdipGetPathGradientPresetBlendCount';
  function GdipGetPathGradientPresetBlend; external WINGDIPDLL name 'GdipGetPathGradientPresetBlend';
  function GdipSetPathGradientPresetBlend; external WINGDIPDLL name 'GdipSetPathGradientPresetBlend';
  function GdipSetPathGradientSigmaBlend; external WINGDIPDLL name 'GdipSetPathGradientSigmaBlend';
  function GdipSetPathGradientLinearBlend; external WINGDIPDLL name 'GdipSetPathGradientLinearBlend';
  function GdipGetLineBlendCount; external WINGDIPDLL name 'GdipGetLineBlendCount';
  function GdipGetLineBlend; external WINGDIPDLL name 'GdipGetLineBlend';
  function GdipSetLineBlend; external WINGDIPDLL name 'GdipSetLineBlend';
  function GdipGetLinePresetBlendCount; external WINGDIPDLL name 'GdipGetLinePresetBlendCount';
  function GdipGetLinePresetBlend; external WINGDIPDLL name 'GdipGetLinePresetBlend';
  function GdipSetLinePresetBlend; external WINGDIPDLL name 'GdipSetLinePresetBlend';
  function GdipSetLineSigmaBlend; external WINGDIPDLL name 'GdipSetLineSigmaBlend';
  function GdipSetLineLinearBlend; external WINGDIPDLL name 'GdipSetLineLinearBlend';
  function GdipGetImagePixelFormat; external WINGDIPDLL name 'GdipGetImagePixelFormat';  
  function GdipGetImageGraphicsContext; external WINGDIPDLL name 'GdipGetImageGraphicsContext';
  function GdipGetPenFillType; external WINGDIPDLL name 'GdipGetPenFillType';  

// -----------------------------------------------------------------------------
// TGdiplusBase class
// -----------------------------------------------------------------------------


class function TGdiplusBase.NewInstance: TObject;
var
  p  : pointer;
  sz : ULONG;
begin
  { Note: GidpAlloc may fail on Windows XP if application is started from
    Delphi 2007 in debug mode.
    The reason for this fix is to workaround the following problem:
    After an application with a TAdvOfficeToolBar executes a standard TOpenDialog,
    an exception is raised while drawing the officetoolbar. }
  sz := ULONG(InstanceSize);
  p := GdipAlloc(sz);
  if not Assigned(p) then
  begin
    //GdipAlloc failed --> restart GDI+ and try again
    GdiplusStartup(gdiplusToken, @StartupInput, @StartupOutput);
    p := GdipAlloc(sz);
  end;
  Result := InitInstance(p);
end;

procedure TGdiplusBase.FreeInstance;
begin
  CleanupInstance;
  GdipFree(Self);
end;


//--------------------------------------------------------------------------
// TGPPoint Util
//--------------------------------------------------------------------------

function MakePoint(X, Y: Integer): TGPPoint;
begin
  result.X := X;
  result.Y := Y;
end;

function MakePoint(X, Y: Single): TGPPointF;
begin
  Result.X := X;
  result.Y := Y;
end;



// -----------------------------------------------------------------------------
// Rect class
// -----------------------------------------------------------------------------

function MakeRect(x, y, width, height: Single): TGPRectF; overload;
begin
  Result.X      := x;
  Result.Y      := y;
  Result.Width  := Width;
  Result.Height := Height;
end;


//******************************************************************************
(**************************************************************************\
*
*   GDI+ StringFormat class
*
\**************************************************************************)

constructor TGPStringFormat.Create(formatFlags: Integer = 0; language: LANGID = LANG_NEUTRAL);
begin
  nativeFormat := nil;
  lastError := GdipCreateStringFormat(formatFlags, language, nativeFormat);
end;

destructor TGPStringFormat.Destroy;
begin
  GdipDeleteStringFormat(nativeFormat);
end;

function TGPStringFormat.SetAlignment(align: TStringAlignment): TStatus;
begin
  result := SetStatus(GdipSetStringFormatAlign(nativeFormat, align));
end;

function TGPStringFormat.GetAlignment: TStringAlignment;
begin
  SetStatus(GdipGetStringFormatAlign(nativeFormat, result));
end;

function TGPStringFormat.SetLineAlignment(align: TStringAlignment): TStatus;
begin
  result := SetStatus(GdipSetStringFormatLineAlign(nativeFormat, align));
end;

function TGPStringFormat.GetLineAlignment: TStringAlignment;
begin
  SetStatus(GdipGetStringFormatLineAlign(nativeFormat, result));
end;


function TGPStringFormat.SetTrimming(trimming: TStringTrimming): TStatus;
begin
  result := SetStatus(GdipSetStringFormatTrimming(nativeFormat, trimming));
end;

function TGPStringFormat.GetTrimming: TStringTrimming;
begin
  SetStatus(GdipGetStringFormatTrimming(nativeFormat, result));
end;

function TGPStringFormat.SetHotkeyPrefix(hotkeyPrefix: THotkeyPrefix): TStatus;
begin
  result := SetStatus(GdipSetStringFormatHotkeyPrefix(nativeFormat, Integer(hotkeyPrefix)));
end;

function TGPStringFormat.GetHotkeyPrefix: THotkeyPrefix;
var HotkeyPrefix: Integer;
begin
  SetStatus(GdipGetStringFormatHotkeyPrefix(nativeFormat, HotkeyPrefix));
  result := THotkeyPrefix(HotkeyPrefix);
end;


function TGPStringFormat.SetStatus(newStatus: GpStatus): TStatus;
begin
  if (newStatus <> Ok) then lastError := newStatus;
  result := newStatus;
end;

// operator =
procedure TGPStringFormat.Assign(source: TGPStringFormat);
begin
  assert(assigned(source));
  GdipDeleteStringFormat(nativeFormat);
  lastError := GdipCloneStringFormat(source.nativeFormat, nativeFormat);
end;

constructor TGPStringFormat.Create(clonedStringFormat: GpStringFormat; status: TStatus);
begin
  lastError := status;
  nativeFormat := clonedStringFormat;
end;

(**************************************************************************\
*
*   GDI+ Pen class
*
\**************************************************************************)

//--------------------------------------------------------------------------
// Pen class
//--------------------------------------------------------------------------

constructor TGPPen.Create(color: TGPColor; width: Single = 1.0);
var unit_: TUnit;
begin
  unit_ := UnitWorld;
  nativePen := nil;
  lastResult := GdipCreatePen1(color, width, unit_, nativePen);
end;

constructor TGPPen.Create(brush: TGPBrush; width: Single = 1.0);
var unit_: TUnit;
begin
  unit_ := UnitWorld;
  nativePen := nil;
  lastResult := GdipCreatePen2(brush.nativeBrush, width, unit_, nativePen);
end;

destructor TGPPen.Destroy;
begin
  GdipDeletePen(nativePen);
end;

constructor TGPPen.Create(nativePen: GpPen; status: TStatus);
begin
  lastResult := status;
  SetNativePen(nativePen);
end;

procedure TGPPen.SetNativePen(nativePen: GpPen);
begin
  self.nativePen := nativePen;
end;

function TGPPen.SetStatus(status: TStatus): TStatus;
begin
  if (status <> Ok) then lastResult := status;
  result := status;
end;

function TGPPen.GetBrush: TGPBrush;
var
  type_: TPenType;
  Brush: TGPBrush;
  nativeBrush: GpBrush;
begin
  type_ := GetPenType;
  brush := nil;

  case type_ of
     PenTypeSolidColor     : brush := TGPSolidBrush.Create;
     PenTypeHatchFill      : brush := TGPHatchBrush.Create;
     PenTypeTextureFill    : brush := TGPTextureBrush.Create;
     PenTypePathGradient   : brush := TGPBrush.Create;
     PenTypeLinearGradient : brush := TGPLinearGradientBrush.Create;
   end;

   if (brush <> nil) then
   begin
     SetStatus(GdipGetPenBrushFill(nativePen, nativeBrush));
     brush.SetNativeBrush(nativeBrush);
   end;

   result := brush;
end;

function TGPPen.GetDashStyle: TDashStyle;
begin
  SetStatus(GdipGetPenDashStyle(nativePen, result));
end;

function TGPPen.GetPenType: TPenType;
begin
  SetStatus(GdipGetPenFillType(nativePen, result));
end;

function TGPPen.SetDashStyle(dashStyle: TDashStyle): TStatus;
begin
  result := SetStatus(GdipSetPenDashStyle(nativePen, dashStyle));
end;

function TGPPen.SetEndCap(endCap: TLineCap): TStatus;
begin
  result := SetStatus(GdipSetPenEndCap(nativePen, endCap));
end;


(**************************************************************************\
*
*   GDI+ Brush class
*
\**************************************************************************)

//--------------------------------------------------------------------------
// Abstract base class for various brush types
//--------------------------------------------------------------------------

destructor TGPBrush.Destroy;
begin
  GdipDeleteBrush(nativeBrush);
end;

constructor TGPBrush.Create;
begin
  SetStatus(NotImplemented);
end;

constructor TGPBrush.Create(nativeBrush: GpBrush; status: TStatus);
begin
  lastResult := status;
  SetNativeBrush(nativeBrush);
end;

procedure TGPBrush.SetNativeBrush(nativeBrush: GpBrush);
begin
  self.nativeBrush := nativeBrush;
end;

function TGPBrush.SetStatus(status: TStatus): TStatus;
begin
  if (status <> Ok) then lastResult := status;
  result := status;
end;

//--------------------------------------------------------------------------
// Solid Fill Brush Object
//--------------------------------------------------------------------------

constructor TGPSolidBrush.Create(color: TGPColor);
var
  brush: GpSolidFill;
begin
  brush := nil;
  lastResult := GdipCreateSolidFill(color, brush);
  SetNativeBrush(brush);
end;

constructor TGPSolidBrush.Create;
begin
  // hide parent function
end;

//--------------------------------------------------------------------------
// Hatch Brush Object
//--------------------------------------------------------------------------

constructor TGPHatchBrush.Create(hatchStyle: THatchStyle; foreColor: TGPColor; backColor: TGPColor = aclBlack);
var
  brush: GpHatch;
begin
  brush := nil;
  lastResult := GdipCreateHatchBrush(Integer(hatchStyle), foreColor, backColor, brush);
  SetNativeBrush(brush);
end;

function TGPHatchBrush.GetHatchStyle: THatchStyle;
begin
  SetStatus(GdipGetHatchStyle(GpHatch(nativeBrush), result));
end;

function TGPHatchBrush.GetForegroundColor(out color: TGPColor): TStatus;
begin
  result := SetStatus(GdipGetHatchForegroundColor(GpHatch(nativeBrush), color));
end;

function TGPHatchBrush.GetBackgroundColor(out color: TGPColor): TStatus;
begin
  result := SetStatus(GdipGetHatchBackgroundColor(GpHatch(nativeBrush), color));
end;

constructor TGPHatchBrush.Create;
begin
end;

//--------------------------------------------------------------------------
// Texture Brush Fill Object
//--------------------------------------------------------------------------

constructor TGPTextureBrush.Create(image: TGPImage; wrapMode: TWrapMode = WrapModeTile);
var texture: GpTexture;
begin
  //texture := nil;
  lastResult := GdipCreateTexture(image.nativeImage, wrapMode, texture);
  SetNativeBrush(texture);
end;

// When creating a texture brush from a metafile image, the dstRect
// is used to specify the size that the metafile image should be
// rendered at in the device units of the destination graphics.
// It is NOT used to crop the metafile image, so only the width
// and height values matter for metafiles.

constructor TGPTextureBrush.Create(image: TGPImage; wrapMode: TWrapMode; dstRect: TGPRectF);
var texture: GpTexture;
begin
  texture := nil;
  lastResult := GdipCreateTexture2(image.nativeImage, wrapMode, dstRect.X,
                  dstRect.Y, dstRect.Width, dstRect.Height, texture);
  SetNativeBrush(texture);
end;

constructor TGPTextureBrush.Create(image: TGPImage; dstRect: TGPRectF; imageAttributes: TGPImageAttributes = nil);
var texture: GpTexture;
    ImgAtt: GpImageAttributes;
begin
  texture := nil;
  if assigned(imageAttributes) then ImgAtt := imageAttributes.nativeImageAttr
                               else ImgAtt := nil;

  lastResult := GdipCreateTextureIA(image.nativeImage, ImgAtt, dstRect.X,
                  dstRect.Y, dstRect.Width, dstRect.Height, texture);
  SetNativeBrush(texture);
end;

constructor TGPTextureBrush.Create(image: TGPImage; dstRect: TGPRect; imageAttributes: TGPImageAttributes = nil);
var texture: GpTexture;
    ImgAtt: GpImageAttributes;
begin
  texture := nil;
  if assigned(imageAttributes) then ImgAtt := imageAttributes.nativeImageAttr
                               else ImgAtt := nil;
  lastResult := GdipCreateTextureIAI(image.nativeImage, ImgAtt, dstRect.X,
                  dstRect.Y, dstRect.Width, dstRect.Height, texture);
   SetNativeBrush(texture);
end;

constructor TGPTextureBrush.Create(image: TGPImage; wrapMode: TWrapMode; dstRect: TGPRect);
var texture: GpTexture;
begin
  texture := nil;
  lastResult := GdipCreateTexture2I(image.nativeImage, wrapMode, dstRect.X,
                  dstRect.Y, dstRect.Width, dstRect.Height, texture);
  SetNativeBrush(texture);
end;

constructor TGPTextureBrush.Create(image: TGPImage; wrapMode: TWrapMode; dstX, dstY, dstWidth, dstHeight: Single);
var texture: GpTexture;
begin
  texture := nil;
  lastResult := GdipCreateTexture2(image.nativeImage, wrapMode, dstX, dstY,
                  dstWidth, dstHeight, texture);
  SetNativeBrush(texture);
end;

constructor TGPTextureBrush.Create(image: TGPImage; wrapMode: TWrapMode; dstX, dstY, dstWidth, dstHeight: Integer);
var texture: GpTexture;
begin
  texture := nil;
  lastResult := GdipCreateTexture2I(image.nativeImage, wrapMode, dstX, dstY,
                  dstWidth, dstHeight, texture);
  SetNativeBrush(texture);
end;

function TGPTextureBrush.SetTransform(matrix: TGPMatrix): TStatus;
begin
  result := SetStatus(GdipSetTextureTransform(GpTexture(nativeBrush),
              matrix.nativeMatrix));
end;

function TGPTextureBrush.GetTransform(matrix: TGPMatrix): TStatus;
begin
  result := SetStatus(GdipGetTextureTransform(GpTexture(nativeBrush),
              matrix.nativeMatrix));
end;

function TGPTextureBrush.ResetTransform: TStatus;
begin
  result := SetStatus(GdipResetTextureTransform(GpTexture(nativeBrush)));
end;

function TGPTextureBrush.MultiplyTransform(matrix: TGPMatrix; order: TMatrixOrder = MatrixOrderPrepend): TStatus;
begin
  result := SetStatus(GdipMultiplyTextureTransform(GpTexture(nativeBrush),
              matrix.nativeMatrix, order));
end;

function TGPTextureBrush.TranslateTransform(dx, dy: Single; order: MatrixOrder = MatrixOrderPrepend): TStatus;
begin
  result := SetStatus(GdipTranslateTextureTransform(GpTexture(nativeBrush),
              dx, dy, order));
end;

function TGPTextureBrush.ScaleTransform(sx, sy: Single; order: TMatrixOrder = MatrixOrderPrepend): TStatus;
begin
  result := SetStatus(GdipScaleTextureTransform(GpTexture(nativeBrush),
               sx, sy, order));
end;

function TGPTextureBrush.RotateTransform(angle: Single; order: TMatrixOrder = MatrixOrderPrepend): TStatus;
begin
  result := SetStatus(GdipRotateTextureTransform(GpTexture(nativeBrush),
                                                            angle, order));
end;

function TGPTextureBrush.SetWrapMode(wrapMode: TWrapMode): TStatus;
begin
  result := SetStatus(GdipSetTextureWrapMode(GpTexture(nativeBrush), wrapMode));
end;

function TGPTextureBrush.GetWrapMode: TWrapMode;
begin
  SetStatus(GdipGetTextureWrapMode(GpTexture(nativeBrush), result));
end;

function TGPTextureBrush.GetImage: TGPImage;
var image: GpImage;
begin
  SetStatus(GdipGetTextureImage(GpTexture(nativeBrush), image));
  result := TGPImage.Create(image, lastResult);
  if (result = nil) then
    GdipDisposeImage(image);
end;

constructor TGPTextureBrush.Create;
begin
  // hide parent function
end;


//--------------------------------------------------------------------------
// Linear Gradient Brush Object
//--------------------------------------------------------------------------

constructor TGPLinearGradientBrush.Create(const point1, point2: TGPPointF; color1, color2: TGPColor);
var brush: GpLineGradient;
begin
  brush := nil;
  lastResult := GdipCreateLineBrush(@point1, @point2, color1, color2, WrapModeTile, brush);
  SetNativeBrush(brush);
end;

constructor TGPLinearGradientBrush.Create(const point1, point2: TGPPoint; color1, color2: TGPColor);
var brush: GpLineGradient;
begin
  brush := nil;
  lastResult := GdipCreateLineBrushI(@point1, @point2, color1,
                  color2, WrapModeTile, brush);
  SetNativeBrush(brush);
end;

constructor TGPLinearGradientBrush.Create(rect: TGPRectF; color1, color2: TGPColor; mode: TLinearGradientMode);
var brush: GpLineGradient;
begin
  brush := nil;
  lastResult := GdipCreateLineBrushFromRect(@rect, color1,
                  color2, mode, WrapModeTile, brush);
  SetNativeBrush(brush);
end;

constructor TGPLinearGradientBrush.Create(rect: TGPRect; color1, color2: TGPColor; mode: TLinearGradientMode);
var brush: GpLineGradient;
begin
  brush := nil;
  lastResult := GdipCreateLineBrushFromRectI(@rect, color1,
                  color2, mode, WrapModeTile, brush);
  SetNativeBrush(brush);
end;

constructor TGPLinearGradientBrush.Create(rect: TGPRectF; color1, color2: TGPColor; angle: Single; isAngleScalable: BOOL = FALSE);
var brush: GpLineGradient;
begin
  brush := nil;
  lastResult := GdipCreateLineBrushFromRectWithAngle(@rect, color1,
                  color2, angle, isAngleScalable, WrapModeTile, brush);
  SetNativeBrush(brush);
end;

constructor TGPLinearGradientBrush.Create(rect: TGPRect; color1, color2: TGPColor; angle: Single; isAngleScalable: BOOL = FALSE);
var brush: GpLineGradient;
begin
  brush := nil;
  lastResult := GdipCreateLineBrushFromRectWithAngleI(@rect, color1,
                  color2, angle, isAngleScalable, WrapModeTile, brush);
  SetNativeBrush(brush);
end;

function TGPLinearGradientBrush.SetGammaCorrection(useGammaCorrection: BOOL): TStatus;
begin
  result := SetStatus(GdipSetLineGammaCorrection(GpLineGradient(nativeBrush),
              useGammaCorrection));
end;

function TGPLinearGradientBrush.GetGammaCorrection: BOOL;
var useGammaCorrection: BOOL;
begin
  SetStatus(GdipGetLineGammaCorrection(GpLineGradient(nativeBrush),
              useGammaCorrection));
  result := useGammaCorrection;
end;

function TGPLinearGradientBrush.GetBlendCount: Integer;
var count: Integer;
begin
  count := 0;
  SetStatus(GdipGetLineBlendCount(GpLineGradient(nativeBrush), count));
  result := count;
end;

function TGPLinearGradientBrush.SetBlend(blendFactors, blendPositions: PSingle; count: Integer): TStatus;
begin
  result := SetStatus(GdipSetLineBlend(GpLineGradient(nativeBrush),
                        blendFactors, blendPositions, count));
end;

function TGPLinearGradientBrush.GetBlend(blendFactors, blendPositions: PSingle; count: Integer): TStatus;
begin
  if ((count <= 0) or (blendFactors = nil) or (blendPositions = nil)) then
    result := SetStatus(InvalidParameter)
  else
    result := SetStatus(GdipGetLineBlend(GpLineGradient(nativeBrush), blendFactors,
      blendPositions, count));
end;

function TGPLinearGradientBrush.GetInterpolationColorCount: Integer;
var count: Integer;
begin
  count := 0;
  SetStatus(GdipGetLinePresetBlendCount(GpLineGradient(nativeBrush), count));
  result := count;
end;

function TGPLinearGradientBrush.SetInterpolationColors(presetColors: PGPColor;
  blendPositions: PSingle; count: Integer): TStatus;
begin
  if (count <= 0)  then
    result := SetStatus(InvalidParameter)
  else
    result := SetStatus(GdipSetLinePresetBlend(GpLineGradient(nativeBrush),
      PARGB(presetColors), blendPositions, count));
end;

function TGPLinearGradientBrush.GetInterpolationColors(presetColors: PGPColor; blendPositions: PSingle; count: Integer): TStatus;
begin
  if (count <= 0) then
    result := SetStatus(InvalidParameter)
  else
    result := SetStatus(GdipGetLinePresetBlend(GpLineGradient(nativeBrush),
                        PARGB(presetColors), blendPositions, count));
end;

function TGPLinearGradientBrush.SetBlendBellShape(focus: Single; scale: Single = 1.0): TStatus;
begin
  result := SetStatus(GdipSetLineSigmaBlend(GpLineGradient(nativeBrush), focus, scale));
end;

function TGPLinearGradientBrush.SetBlendTriangularShape(focus: Single; scale: Single = 1.0): TStatus;
begin
  result := SetStatus(GdipSetLineLinearBlend(GpLineGradient(nativeBrush), focus, scale));
end;


(**************************************************************************\
*
*   GDI+ Graphics Object
*
\**************************************************************************)

constructor TGPGraphics.Create(hdc: HDC);
var
  graphics: GpGraphics;
begin
  graphics:= nil;
  lastResult := GdipCreateFromHDC(hdc, graphics);
  SetNativeGraphics(graphics);
end;

function TGPGraphics.Clear(color: TGPColor): TStatus;
begin
    result := SetStatus(GdipGraphicsClear(
        nativeGraphics,
        color));
end;

constructor TGPGraphics.Create(image: TGPImage);
var
  graphics: GpGraphics;
begin
  graphics:= nil;
  if (image <> nil) then
    lastResult := GdipGetImageGraphicsContext(image.nativeImage, graphics);
  SetNativeGraphics(graphics);
end;

function TGPGraphics.FromImage(image: TGPImage): TGPGraphics;
begin
  result := TGPGraphics.Create(image);
end;

destructor TGPGraphics.Destroy;
begin
  GdipDeleteGraphics(nativeGraphics);
end;

procedure TGPGraphics.Flush(intention: TFlushIntention = FlushIntentionFlush);
begin
  GdipFlush(nativeGraphics, intention);
end;

//------------------------------------------------------------------------
// GDI Interop methods
//------------------------------------------------------------------------

// Locks the graphics until ReleaseDC is called

function TGPGraphics.GetHDC: HDC;
begin
  SetStatus(GdipGetDC(nativeGraphics, result));
end;

procedure TGPGraphics.ReleaseHDC(hdc: HDC);
begin
  SetStatus(GdipReleaseDC(nativeGraphics, hdc));
end;

function TGPGraphics.SetTextRenderingHint(newMode: TTextRenderingHint): TStatus;
begin
  result := SetStatus(GdipSetTextRenderingHint(nativeGraphics, newMode));
end;

function TGPGraphics.GetTextRenderingHint: TTextRenderingHint;
begin
  SetStatus(GdipGetTextRenderingHint(nativeGraphics, result));
end;

function TGPGraphics.MeasureString(string_: WideString; length: Integer; font: TGPFont;
     const layoutRect: TGPRectF; stringFormat: TGPStringFormat; out boundingBox: TGPRectF;
     codepointsFitted: PInteger = nil; linesFilled: PInteger = nil): TStatus;
var
  nFont: GpFont;
  nStringFormat: GpStringFormat;
begin
  if assigned(font) then nfont := font.nativeFont else nfont := nil;
  if assigned(stringFormat) then nstringFormat := stringFormat.nativeFormat else nstringFormat := nil;
  result := SetStatus(GdipMeasureString(
      nativeGraphics,
      PWideChar(string_),
      length,
      nfont,
      @layoutRect,
      nstringFormat,
      @boundingBox,
      codepointsFitted,
      linesFilled
  ));
end;

function TGPGraphics.MeasureString(string_: WideString ; length: Integer; font: TGPFont;
     const origin: TGPPointF; stringFormat: TGPStringFormat; out boundingBox: TGPRectF): TStatus;
var
  rect: TGPRectF;
  nFont: GpFont;
  nstringFormat: GpstringFormat;
begin
  rect.X := origin.X;
  rect.Y := origin.Y;
  rect.Width := 0.0;
  rect.Height := 0.0;

  if Assigned(font) then nfont := font.nativeFont else nfont := nil;
  if Assigned(stringFormat) then nstringFormat := stringFormat.nativeFormat else nstringFormat := nil;

  result := SetStatus(GdipMeasureString(
      nativeGraphics,
      PWideChar(string_),
      length,
      nfont,
      @rect,
      nstringFormat,
      @boundingBox,
      nil,
      nil
  ));
end;

    
function TGPGraphics.MeasureString(string_: WideString; length: Integer; font: TGPFont;
     const layoutRect: TGPRectF; out boundingBox: TGPRectF): TStatus;
var
  nFont: GpFont;
begin
  if Assigned(font) then nfont := font.nativeFont else nfont := nil;
  result := SetStatus(GdipMeasureString(
      nativeGraphics,
      PWideChar(string_),
      length,
      nfont,
      @layoutRect,
      nil,
      @boundingBox,
      nil,
      nil
  ));
end;

function TGPGraphics.TextHeight(string_: String; font: TFont): integer;
var
  bb: TGPRectF;
  gpFont: TGPFont;
  layoutrect: TGPRectF;
begin
  gpFont := MakeFont(font);
  layoutrect := MakeRect(0,0,10000,10000);
  MeasureString(string_, length(string_), gpfont, layoutrect, bb);
  gpFont.Free;
  Result := Round(bb.Height);
end;


function TGPGraphics.TextWidth(string_: String; font: TFont): integer;
var
  bb: TGPRectF;
  gpFont: TGPFont;  
  layoutrect: TGPRectF;
begin
  gpFont := MakeFont(font);
  layoutrect := MakeRect(0,0,10000,10000);
  MeasureString(string_, length(string_), gpfont, layoutrect, bb);
  gpFont.Free;
  Result := Round(bb.Width);
end;

    
function TGPGraphics.MakeFont(AFont: TFont): TGPFont;
var
  fontFamily: TGPFontFamily;
  fs: Integer;
begin

  fontFamily := TGPFontFamily.Create(AFont.Name);

  if (fontFamily.Status in [FontFamilyNotFound, FontStyleNotFound]) then
  begin
    fontFamily.Free;
    fontFamily := TGPFontFamily.Create('Arial');
  end;

  fs := 0;
  if (fsBold in AFont.Style) then
    fs := fs + 1;
  if (fsItalic in AFont.Style) then
    fs := fs + 2;
  if (fsUnderline in AFont.Style) then
    fs := fs + 4;

  Result := TGPFont.Create(fontFamily, AFont.Size , fs, UnitPoint);

  fontFamily.Free;
end;



function TGPGraphics.MeasureString(string_: WideString; length: Integer; font: TGPFont;
     const origin: TGPPointF; out boundingBox: TGPRectF): TStatus;
var
  nFont: GpFont;
  rect: TGPRectF;
begin
  if assigned(font) then nfont := font.nativeFont else nfont := nil;
  rect.X := origin.X;
  rect.Y := origin.Y;
  rect.Width := 0.0;
  rect.Height := 0.0;

  result := SetStatus(GdipMeasureString(
      nativeGraphics,
      PWideChar(string_),
      length,
      nfont,
      @rect,
      nil,
      @boundingBox,
      nil,
      nil
  ));
end;

function TGPGraphics.GetSmoothingMode: TSmoothingMode;
var
  smoothingMode: TSmoothingMode;
begin
  smoothingMode := SmoothingModeInvalid;
  SetStatus(GdipGetSmoothingMode(nativeGraphics,  smoothingMode));
  result := smoothingMode;
end;

function TGPGraphics.SetSmoothingMode(smoothingMode: TSmoothingMode): TStatus;
begin
  result := SetStatus(GdipSetSmoothingMode(nativeGraphics, smoothingMode));
end;

function TGPGraphics.GetPixelOffsetMode: TPixelOffsetMode;
var
  pixelOffsetMode: TPixelOffsetMode;
begin
  pixelOffsetMode := PixelOffsetModeInvalid;
  SetStatus(GdipGetPixelOffsetMode(nativeGraphics, pixelOffsetMode));
  Result := pixelOffsetMode;
end;

function TGPGraphics.SetPixelOffsetMode(pixelOffsetMode: TPixelOffsetMode): TStatus;
begin
  Result := SetStatus(GdipSetPixelOffsetMode(nativeGraphics, pixelOffsetMode));
end;


function TGPGraphics.DrawPath(pen: TGPPen; path: TGPGraphicsPath): TStatus;
var
  nPen: GpPen;
  nPath: GpPath;
begin
  if Assigned(pen) then
    nPen := pen.nativePen
  else
    nPen  := nil;
  if Assigned(path) then
    nPath := path.nativePath
  else
    nPath := nil;
  Result := SetStatus(GdipDrawPath(nativeGraphics, nPen, nPath));
end;

function TGPGraphics.FillRectangle(brush: TGPBrush; const rect: TGPRectF): TStatus;
begin
  Result := FillRectangle(brush, rect.X, rect.Y, rect.Width, rect.Height);
end;

function TGPGraphics.FillRectangle(brush: TGPBrush; x, y, width, height: Single): TStatus;
begin
  Result := Ok;

  if (width = 0) or (height = 0) then
    Exit;

  if (brush = nil) then
    Exit;

  if (brush.nativeBrush = nil) then
    Exit;

  if (nativeGraphics = nil) then
    Exit;

  Result := SetStatus(GdipFillRectangle(nativeGraphics, brush.nativeBrush, x, y,
                      width, height));

end;

function TGPGraphics.DrawString( string_: string; length: Integer; font: TGPFont;
  const layoutRect: TGPRectF; stringFormat: TGPStringFormat; brush: TGPBrush): TStatus;
var
  nFont: GpFont;
  nStringFormat: GpStringFormat;
  nBrush: GpBrush;
  wCh: PWidechar;
  i: integer;
begin
  if Assigned(font) then
    nfont := font.nativeFont
  else
    nfont := nil;
  if Assigned(stringFormat) then
    nstringFormat := stringFormat.nativeFormat
  else
    nstringFormat := nil;

  {charset issue}
  i := System.Length(string_);
  GetMem(wCh, i * 2 + 2);
  FillChar(wCh^, i * 2 + 2,0);
  StringToWidechar(string_, wCh, i * 2 + 2);
  {/charset issue}

  if Assigned(brush) then
    nbrush := brush.nativeBrush
  else
    nbrush := nil;
//  Result := SetStatus(GdipDrawString(nativeGraphics, PWideChar(string_),
//        length, nfont, @layoutRect, nstringFormat, nbrush));

  {charset issue}
  Result := SetStatus(GdipDrawString(nativeGraphics, wCh,
        length, nfont, @layoutRect, nstringFormat, nbrush));

  FreeMem(wCh);
  {/charset issue}
end;

{$IFDEF DELPHI6_LVL}
function TGPGraphics.DrawString( string_: widestring; length: Integer; font: TGPFont;
  const layoutRect: TGPRectF; stringFormat: TGPStringFormat; brush: TGPBrush): TStatus;
var
  nFont: GpFont;
  nStringFormat: GpStringFormat;
  nBrush: GpBrush;
begin
  if Assigned(font) then
    nfont := font.nativeFont
  else
    nfont := nil;
  if Assigned(stringFormat) then
    nstringFormat := stringFormat.nativeFormat
  else
    nstringFormat := nil;

  if Assigned(brush) then
    nbrush := brush.nativeBrush
  else
    nbrush := nil;

  Result := SetStatus(GdipDrawString(nativeGraphics, PWideChar(string_),
        length, nfont, @layoutRect, nstringFormat, nbrush));
end;
{$ENDIF}


function TGPGraphics.GetLastStatus: TStatus;
begin
  result := lastResult;
  lastResult := Ok;
end;

{
constructor TGPGraphics.Create(graphics: GpGraphics);
begin
  lastResult := Ok;
  SetNativeGraphics(graphics);
end;
}

procedure TGPGraphics.SetNativeGraphics(graphics: GpGraphics);
begin
  self.nativeGraphics := graphics;
end;

function TGPGraphics.SetStatus(status: TStatus): TStatus;
begin
  if (status <> Ok) then
    lastResult := status;
  result := status;
end;

function TGPGraphics.GetNativeGraphics: GpGraphics;
begin
  result := self.nativeGraphics;
end;

//------------------------------------------------------------------------------

  constructor TGPRegion.Create(rect: TGPRectF);
  var
    region: GpRegion;
  begin
    region := nil;
    lastResult := GdipCreateRegionRect(@rect, region);
    SetNativeRegion(region);
  end;

  constructor TGPRegion.Create(path: TGPGraphicsPath);
  var
    region: GpRegion;
  begin
    region := nil;
    lastResult := GdipCreateRegionPath(path.nativePath, region);
    SetNativeRegion(region);
  end;

  destructor TGPRegion.Destroy;
  begin
    GdipDeleteRegion(nativeRegion);
  end;

  function TGPRegion.Exclude(path: TGPGraphicsPath): TStatus;
  begin
    result := SetStatus(GdipCombineRegionPath(nativeRegion, path.nativePath, CombineModeExclude));
  end;

  function TGPRegion.SetStatus(status: TStatus): TStatus;
  begin
    if (status <> Ok) then lastResult := status;
    result := status;
  end;

  procedure TGPRegion.SetNativeRegion(nativeRegion: GpRegion);
  begin
    self.nativeRegion := nativeRegion;
  end;

  function TGPRegion.Union(region: TGPRegion): TStatus;
  begin
    result := SetStatus(GdipCombineRegionRegion(nativeRegion, region.nativeRegion,
      CombineModeUnion));
  end;

(**************************************************************************\
*
*   GDI+ Font Family class
*
\**************************************************************************)

  constructor TGPFontFamily.Create(name: WideString; fontCollection: TGPFontCollection = nil);
  var nfontCollection: GpfontCollection;
  begin
    nativeFamily := nil;
    if assigned(fontCollection) then nfontCollection := fontCollection.nativeFontCollection else nfontCollection := nil;
    lastResult := GdipCreateFontFamilyFromName(PWideChar(name), nfontCollection, nativeFamily);
  end;

  destructor TGPFontFamily.Destroy;
  begin
    GdipDeleteFontFamily (nativeFamily);
  end;

  function TGPFontFamily.SetStatus(status: TStatus): TStatus;
  begin
    if (status <> Ok) then lastResult := status;
    result := status;
  end;

  constructor TGPFontFamily.Create(nativeOrig: GpFontFamily; status: TStatus);
  begin
    lastResult  := status;
    nativeFamily := nativeOrig;
  end;

(**************************************************************************\
*
*   GDI+ Font class
*
\**************************************************************************)

  constructor TGPFont.Create(family: TGPFontFamily; emSize: Single;
      style: TFontStyle = FontStyleRegular; unit_: TUnit = UnitPoint);
  var
    font: GpFont;
    nFontFamily: GpFontFamily;
  begin
    font := nil;
    if Assigned(Family) then
      nFontFamily := Family.nativeFamily
    else
      nFontFamily := nil;

    lastResult := GdipCreateFont(nFontFamily, emSize, Integer(style), Integer(unit_), font);
    
    SetNativeFont(font);
  end;

  destructor TGPFont.Destroy;
  begin
    GdipDeleteFont(nativeFont);
  end;

  constructor TGPFont.Create(font: GpFont; status: TStatus);
  begin
    lastResult := status;
    SetNativeFont(font);
  end;

  procedure TGPFont.SetNativeFont(Font: GpFont);
  begin
    nativeFont := Font;
  end;

  function TGPFont.SetStatus(status: TStatus): TStatus;
  begin
    if (status <> Ok) then lastResult := status;
    result := status;
  end;

(**************************************************************************\
*
*   Font collections (Installed and Private)
*
\**************************************************************************)

  constructor TGPFontCollection.Create;
  begin
    nativeFontCollection := nil;
  end;

  destructor TGPFontCollection.Destroy;
  begin
    inherited Destroy;
  end;

  function TGPFontCollection.SetStatus(status: TStatus): TStatus;
  begin
    lastResult := status;
    result := lastResult;
  end;

(**************************************************************************\
*
*   GDI+ Graphics Path class
*
\**************************************************************************)

constructor TGPGraphicsPath.Create(fillMode: TFillMode = FillModeAlternate);
begin
  nativePath := nil;
  lastResult := GdipCreatePath(fillMode, nativePath);
end;

destructor TGPGraphicsPath.Destroy;
begin
  GdipDeletePath(nativePath);
end;

function TGPGraphicsPath.CloseFigure: TStatus;
begin
  result := SetStatus(GdipClosePathFigure(nativePath));
end;

function TGPGraphicsPath.AddLine(const pt1, pt2: TGPPointF): TStatus;
begin
  result := AddLine(pt1.X, pt1.Y, pt2.X, pt2.Y);
end;

function TGPGraphicsPath.AddLine(x1, y1, x2, y2: Single): TStatus;
begin
  result := SetStatus(GdipAddPathLine(nativePath, x1, y1,
                                       x2, y2));
end;

function TGPGraphicsPath.AddArc(rect: TGPRectF; startAngle, sweepAngle: Single): TStatus;
begin
  result := AddArc(rect.X, rect.Y, rect.Width, rect.Height,
                startAngle, sweepAngle);
end;

function TGPGraphicsPath.AddArc(x, y, width, height, startAngle, sweepAngle: Single): TStatus;
begin
  result := SetStatus(GdipAddPathArc(nativePath, x, y, width, height, startAngle, sweepAngle));
end;

function TGPGraphicsPath.AddRectangle(rect: TGPRectF): TStatus;
begin
  result := SetStatus(GdipAddPathRectangle(nativePath,
                                          rect.X,
                                          rect.Y,
                                          rect.Width,
                                          rect.Height));
end;

function TGPGraphicsPath.AddRectangle(rect: TGPRect): TStatus;
begin
  result := SetStatus(GdipAddPathRectangleI(nativePath,
                                          rect.X,
                                          rect.Y,
                                          rect.Width,
                                          rect.Height));
end;



function TGPGraphicsPath.AddEllipse(rect: TGPRectF): TStatus;
begin
  result := AddEllipse(rect.X, rect.Y, rect.Width, rect.Height);
end;

function TGPGraphicsPath.AddEllipse(x, y, width, height: Single): TStatus;
begin
  result := SetStatus(GdipAddPathEllipse(nativePath,
                                        x,
                                        y,
                                        width,
                                        height));
end;

{
constructor TGPGraphicsPath.Create(path: TGPGraphicsPath);
var clonepath: GpPath;
begin
  clonepath := nil;
  SetStatus(GdipClonePath(path.nativePath, clonepath));
  SetNativePath(clonepath);
end;
}
constructor TGPGraphicsPath.Create(nativePath: GpPath);
begin
  lastResult := Ok;
  SetNativePath(nativePath);
end;

procedure TGPGraphicsPath.SetNativePath(nativePath: GpPath);
begin
  self.nativePath := nativePath;
end;

function TGPGraphicsPath.SetStatus(status: TStatus): TStatus;
begin
  if (status <> Ok) then LastResult := status;
  result := status;
end;

//--------------------------------------------------------------------------
// Path Gradient Brush
//--------------------------------------------------------------------------
constructor TGPPathGradientBrush.Create(points: PGPPointF; count: Integer; wrapMode: TWrapMode = WrapModeClamp);
var brush: GpPathGradient;
begin
  brush := nil;
  lastResult := GdipCreatePathGradient(points, count, wrapMode, brush);
  SetNativeBrush(brush);
end;

constructor TGPPathGradientBrush.Create(points: PGPPoint; count: Integer; wrapMode: TWrapMode = WrapModeClamp);
var brush: GpPathGradient;
begin
  brush := nil;
  lastResult := GdipCreatePathGradientI(points, count, wrapMode, brush);
  SetNativeBrush(brush);
end;

constructor TGPPathGradientBrush.Create(path: TGPGraphicsPath);
var brush: GpPathGradient;
begin
  brush := nil;
  lastResult := GdipCreatePathGradientFromPath(path.nativePath, brush);
  SetNativeBrush(brush);
end;
  
function TGPPathGradientBrush.GetCenterColor(out Color: TGPColor): TStatus;
begin
  SetStatus(GdipGetPathGradientCenterColor(GpPathGradient(nativeBrush), Color));
  result := lastResult;
end;

function TGPPathGradientBrush.SetCenterColor(color: TGPColor): TStatus;
begin
  SetStatus(GdipSetPathGradientCenterColor(GpPathGradient(nativeBrush),color));
  result := lastResult;
end;

function TGPPathGradientBrush.GetPointCount: Integer;
begin
  SetStatus(GdipGetPathGradientPointCount(GpPathGradient(nativeBrush), result));
end;

function TGPPathGradientBrush.GetSurroundColors(colors: PARGB; var count: Integer): TStatus;
var
  count1: Integer;
begin
  if not assigned(colors) then
  begin
    result := SetStatus(InvalidParameter);
    exit;
  end;

  SetStatus(GdipGetPathGradientSurroundColorCount(GpPathGradient(nativeBrush), count1));

  if(lastResult <> Ok) then
  begin
    result := lastResult;
    exit;
  end;

  if((count < count1) or (count1 <= 0)) then
  begin
    result := SetStatus(InsufficientBuffer);
    exit;
  end;

  SetStatus(GdipGetPathGradientSurroundColorsWithCount(GpPathGradient(nativeBrush), colors, count1));
  if(lastResult = Ok) then
    count := count1;

  result := lastResult;
end;

function TGPPathGradientBrush.SetSurroundColors(colors: PARGB; var count: Integer): TStatus;
var
  count1: Integer;
type
  TDynArrDWORD = array of DWORD;
begin
  if (colors = nil) then
  begin
    result := SetStatus(InvalidParameter);
    exit;
  end;

  count1 := GetPointCount;

  if((count > count1) or (count1 <= 0)) then
  begin
    result := SetStatus(InvalidParameter);
    exit;
  end;

  count1 := count;

  SetStatus(GdipSetPathGradientSurroundColorsWithCount(
              GpPathGradient(nativeBrush), colors, count1));

  if(lastResult = Ok) then count := count1;
  result := lastResult;
end;

function TGPPathGradientBrush.GetCenterPoint(out point: TGPPointF): TStatus;
begin
  result := SetStatus(GdipGetPathGradientCenterPoint(GpPathGradient(nativeBrush), @point));
end;

function TGPPathGradientBrush.GetCenterPoint(out point: TGPPoint): TStatus;
begin
  result := SetStatus(GdipGetPathGradientCenterPointI(GpPathGradient(nativeBrush), @point));
end;

function TGPPathGradientBrush.SetCenterPoint(point: TGPPointF): TStatus;
begin
  result := SetStatus(GdipSetPathGradientCenterPoint(GpPathGradient(nativeBrush), @point));
end;

function TGPPathGradientBrush.SetCenterPoint(point: TGPPoint): TStatus;
begin
  result := SetStatus(GdipSetPathGradientCenterPointI(GpPathGradient(nativeBrush), @point));
end;

function TGPPathGradientBrush.SetGammaCorrection(useGammaCorrection: BOOL): TStatus;
begin
  result := SetStatus(GdipSetPathGradientGammaCorrection(GpPathGradient(nativeBrush),
    useGammaCorrection));
end;

function TGPPathGradientBrush.GetGammaCorrection: BOOL;
begin
  SetStatus(GdipGetPathGradientGammaCorrection(GpPathGradient(nativeBrush), result));
end;

function TGPPathGradientBrush.GetWrapMode: TWrapMode;
begin
  SetStatus(GdipGetPathGradientWrapMode(GpPathGradient(nativeBrush), result));
end;

function TGPPathGradientBrush.SetWrapMode(wrapMode: TWrapMode): TStatus;
begin
  result := SetStatus(GdipSetPathGradientWrapMode(
                    GpPathGradient(nativeBrush), wrapMode));
end;

function TGPPathGradientBrush.GetBlendCount: Integer;
var count: Integer;
begin
  count := 0;
  SetStatus(GdipGetPathGradientBlendCount(GpPathGradient(nativeBrush), count));
  result := count;
end;

function TGPPathGradientBrush.GetBlend(blendFactors, blendPositions:PSingle; count: Integer): TStatus;
begin
  result := SetStatus(GdipGetPathGradientBlend(
                    GpPathGradient(nativeBrush),
                    blendFactors, blendPositions, count));
end;

function TGPPathGradientBrush.SetBlend(blendFactors, blendPositions: PSingle; count: Integer): TStatus;
begin
  result := SetStatus(GdipSetPathGradientBlend(
                    GpPathGradient(nativeBrush),
                    blendFactors, blendPositions, count));
end;

function TGPPathGradientBrush.GetInterpolationColorCount: Integer;
var count: Integer;
begin
  count := 0;
  SetStatus(GdipGetPathGradientPresetBlendCount(GpPathGradient(nativeBrush), count));
  result := count;
end;

function TGPPathGradientBrush.SetInterpolationColors(presetColors: PARGB;
  blendPositions: PSingle; count: Integer): TStatus;
var
  status: TStatus;
begin
  if ((count <= 0) or (presetColors = nil)) then
  begin
    result := SetStatus(InvalidParameter);
    exit;
  end;

  status := SetStatus(GdipSetPathGradientPresetBlend(GpPathGradient(nativeBrush),
                        presetColors, blendPositions, count));
  result := status;
end;

function TGPPathGradientBrush.GetInterpolationColors(presetColors: PARGB;
  blendPositions: PSingle; count: Integer): TStatus;
var
  status: GpStatus;
  i: Integer;
  argbs: PARGB;
begin
      if ((count <= 0) or (presetColors = nil)) then
      begin
        result := SetStatus(InvalidParameter);
        exit;
      end;
      getmem(argbs, count*SizeOf(ARGB));
      if (argbs = nil) then
      begin
        result := SetStatus(OutOfMemory);
        exit;
      end;

      status := SetStatus(GdipGetPathGradientPresetBlend(nativeBrush, argbs,
                   blendPositions, count));

      for i := 0 to count - 1 do
        TColorDynArray(presetColors)[i] := TColorDynArray(argbs)[i];

      freemem(argbs);

      result := status;
end;

function TGPPathGradientBrush.SetBlendBellShape(focus: Single; scale: Single = 1.0): TStatus;
begin
  result := SetStatus(GdipSetPathGradientSigmaBlend(GpPathGradient(nativeBrush), focus, scale));
end;

function TGPPathGradientBrush.SetBlendTriangularShape(focus: Single; scale: Single = 1.0): TStatus;
begin
  result := SetStatus(GdipSetPathGradientLinearBlend(GpPathGradient(nativeBrush), focus, scale));
end;



function TGPGraphics.DrawRectangle(pen: TGPPen; const rect: TGPRectF): TStatus;
begin
  Result := DrawRectangle(pen, rect.X, rect.Y, rect.Width, rect.Height);
end;

function TGPGraphics.DrawRectangle(pen: TGPPen; x, y, width, height: Single): TStatus;
begin
  Result := SetStatus(GdipDrawRectangle(nativeGraphics, pen.nativePen, x, y, width, height));
end;

function TGPGraphics.DrawString(string_: WideString; length: Integer; font: TGPFont;
    const origin: TGPPointF; stringFormat: TGPStringFormat; brush: TGPBrush): TStatus;
var
  rect: TGPRectF;
  nFont: GpFont;
  nStringFormat: GpStringFormat;
  nBrush: GpBrush;
begin
  rect.X := origin.X;
  rect.Y := origin.Y;
  rect.Width := 0.0;
  rect.Height := 0.0;
  if Assigned(font) then
    nfont := font.nativeFont else nfont := nil;
    
  if Assigned(stringFormat) then
    nstringFormat := stringFormat.nativeFormat else nstringFormat := nil;

  if Assigned(brush) then
    nbrush := brush.nativeBrush else nbrush := nil;
    
  result := SetStatus(GdipDrawString(
      nativeGraphics,
      PWideChar(string_),
      length,
      nfont,
      @rect,
      nstringFormat,
      nbrush));
end;

function TGPGraphics.DrawText(string_: String; len: integer; var rect:
TRect;
  font: TFont; style: DWORD; bkColor: TColor = clNone): integer; var
  bb: TGPRectf;
  gpfont: TGPFont;
  brush: TGPSolidBrush;
  origin: TGPPointF;
  d: integer;
  ms: string;
  ml: integer;
begin
  gpFont := MakeFont(Font);

  if (DT_CALCRECT and style = DT_CALCRECT) or (bkColor <> clNone) then
  begin
    ms := string_;
    ml := length(string_);

    d := 2;
    if Font.Size > 8 then
      d := d + round((Font.Size - 8)/1.5);

    SetTextRenderingHint(TextRenderingHintClearTypeGridFit);

    if (ml > 0) then
      if (ms[ml] = ' ') and (ml > 1) then
        ms[ml] := 'i';

    MeasureString(ms, len, gpFont, MakeRect(rect.Left, rect.Top, rect.Right
- rect.Left + 1000, rect.Bottom - rect.Top), bb);
    rect.Right := rect.Left + Round(bb.Width - d);
    rect.Bottom := rect.Top + Round(bb.Height);

    if (bkColor <> clNone) then
    begin
      brush := TGPSolidBrush.Create(ColorToARGB(bkColor));
      FillRectangle(brush, MakeRect(rect.Left + 1, rect.Top, bb.Width - d + 1, bb.Height));
      brush.Free;
    end;
  end;

  if (DT_CALCRECT and style = 0) then
  begin
    SetTextRenderingHint(TextRenderingHintClearTypeGridFit);
    brush := TGPSolidBrush.Create(ColorToARGB(font.Color));
    origin.X := rect.Left;
    origin.Y := rect.Top;
    DrawString(string_, len, gpFont, origin, brush);
    brush.Free;
  end;

  Result := rect.Bottom - rect.Top;
  gpFont.Free;
end;

function TGPGraphics.DrawString(string_: WideString; length: Integer; font: TGPFont;
         const origin: TGPPointF; brush: TGPBrush): TStatus;
var
  rect: TGPRectF;
  nfont: Gpfont;
  nBrush: GpBrush;
begin
  rect.X := origin.X;
  rect.Y := origin.Y;
  rect.Width := 0.0;
  rect.Height := 0.0;
  if assigned(font) then nfont := font.nativeFont else nfont := nil;
  if assigned(Brush) then nBrush := Brush.nativeBrush else nBrush := nil;
  result := SetStatus(GdipDrawString(
      nativeGraphics,
      PWideChar(string_),
      length,
      nfont,
      @rect,
      nil,
      nbrush));
end;

function TGPGraphics.DrawImage(image: TGPImage; const rect: TGPRectF): TStatus;
begin
  result := DrawImage(image, rect.X, rect.Y, rect.Width, rect.Height);
end;

function TGPGraphics.DrawImage(image: TGPImage; x, y: Integer): TStatus;
var
  nImage: GpImage;
begin
  if Assigned(Image) then
    nImage := Image.nativeImage
  else
    nImage := nil;

  Result := SetStatus(GdipDrawImageI(nativeGraphics, nimage, x, y));
end;

function TGPGraphics.DrawImageRect(image: TGPImage; x, y, w, h: Integer): TStatus;
var
  nImage: GpImage;
begin
  if Assigned(Image) then
    nImage := Image.nativeImage
  else
    nImage := nil;

  Result := SetStatus(GdipDrawImageRect(nativeGraphics, nimage, x, y, w, h));
end;

function TGPGraphics.DrawImageRect(image: TGPImage; ARect: TGPRectF): TStatus;
begin
  Result := DrawImageRect(image, Round(ARect.X), Round(ARect.Y), Round(ARect.Width), Round(ARect.Height));
end;


function TGPGraphics.DrawLine(pen: TGPPen; x1, y1, x2, y2: Integer): TStatus;
begin
  result := SetStatus(GdipDrawLineI(nativeGraphics,
                         pen.nativePen,
                         x1,
                         y1,
                         x2,
                         y2));
end;

function TGPGraphics.DrawLine(pen: TGPPen; x1, y1, x2, y2: Single): TStatus;
begin
  result := SetStatus(GdipDrawLine(nativeGraphics,
                        pen.nativePen, x1, y1, x2,
                        y2));
end;

function TGPGraphics.DrawImage(image: TGPImage; const destRect: TGPRectF; srcx, srcy, srcwidth, srcheight: Single;
     srcUnit: TUnit; imageAttributes: TGPImageAttributes = nil; callback: DrawImageAbort = nil;
     callbackData: Pointer = nil): TStatus;
var
  nImage: GpImage;
  nimageAttributes: GpimageAttributes;
begin
  if Assigned(Image) then
    nImage := Image.nativeImage
  else
    nImage := nil;

  if Assigned(imageAttributes) then
    nimageAttributes := imageAttributes.nativeImageAttr
  else
    nimageAttributes := nil;

  Result := SetStatus(GdipDrawImageRectRect(nativeGraphics,
                             nimage,
                             destRect.X,
                             destRect.Y,
                             destRect.Width,
                             destRect.Height,
                             srcx, srcy,
                             srcwidth, srcheight,
                             srcUnit,
                             nimageAttributes,
                             callback,
                             callbackData));
end;

function TGPGraphics.DrawImage(image: TGPImage; destPoints: PGPPointF; count: Integer;
     srcx, srcy, srcwidth, srcheight: Single; srcUnit: TUnit;
     imageAttributes: TGPImageAttributes = nil; callback: DrawImageAbort = nil;
     callbackData: Pointer = nil): TStatus;
var
  nImage: GpImage;
  nimageAttributes: GpimageAttributes;
begin
  if Assigned(Image) then
    nImage := Image.nativeImage
  else
    nImage := nil;
  if Assigned(imageAttributes) then
    nimageAttributes := imageAttributes.nativeImageAttr
  else
    nimageAttributes := nil;

  Result := SetStatus(GdipDrawImagePointsRect(nativeGraphics,
                               nimage,
                               destPoints, count,
                               srcx, srcy,
                               srcwidth,
                               srcheight,
                               srcUnit,
                               nimageAttributes,
                               callback,
                               callbackData));
end;

function TGPGraphics.DrawImage(image: TGPImage; const destRect: TGPRect; srcx, srcy, srcwidth,
     srcheight: Integer; srcUnit: TUnit; imageAttributes: TGPImageAttributes = nil;
     callback: DrawImageAbort = nil; callbackData: Pointer = nil): TStatus;
var
  nImage: GpImage;
  nimageAttributes: GpimageAttributes;
begin
  if Assigned(Image) then
    nImage := Image.nativeImage
  else
    nImage := nil;
  if Assigned(imageAttributes) then
    nimageAttributes := imageAttributes.nativeImageAttr
  else
    nimageAttributes := nil;

  Result := SetStatus(GdipDrawImageRectRectI(nativeGraphics,
                              nimage,
                              destRect.X,
                              destRect.Y,
                              destRect.Width,
                              destRect.Height,
                              srcx,
                              srcy,
                              srcwidth,
                              srcheight,
                              srcUnit,
                              nimageAttributes,
                              callback,
                              callbackData));
end;

function TGPGraphics.DrawEllipse(pen: TGPPen; const rect: TGPRectF): TStatus;
begin
  result := DrawEllipse(pen, rect.X, rect.Y, rect.Width, rect.Height);
end;

function TGPGraphics.DrawEllipse(pen: TGPPen; x, y, width, height: Single): TStatus;
begin
  result := SetStatus(GdipDrawEllipse(nativeGraphics,
                           pen.nativePen,
                           x,
                           y,
                           width,
                           height));
end;

function TGPGraphics.DrawEllipse(pen: TGPPen; const rect: TGPRect): TStatus;
begin
  result := DrawEllipse(pen,
             rect.X,
             rect.Y,
             rect.Width,
             rect.Height);
end;

function TGPGraphics.DrawArc(pen: TGPPen; x, y, width, height, startAngle, sweepAngle: Single): TStatus;
begin
  result := SetStatus(GdipDrawArc(nativeGraphics,
                       pen.nativePen,
                       x,
                       y,
                       width,
                       height,
                       startAngle,
                       sweepAngle));
end;

function TGPGraphics.DrawArc(pen: TGPPen; const rect: TGPRectF; startAngle, sweepAngle: Single): TStatus;
begin
  result := DrawArc(pen, rect.X, rect.Y, rect.Width, rect.Height,
             startAngle, sweepAngle);
end;

function TGPGraphics.DrawArc(pen: TGPPen; x, y, width, height: Integer; startAngle,
         sweepAngle: Single): TStatus; 
begin
  result := SetStatus(GdipDrawArcI(nativeGraphics,
                        pen.nativePen,
                        x,
                        y,
                        width,
                        height,
                        startAngle,
                        sweepAngle));
end;


function TGPGraphics.DrawArc(pen: TGPPen; const rect: TGPRect; startAngle, sweepAngle: Single): TStatus;
begin
  result := DrawArc(pen,
             rect.X,
             rect.Y,
             rect.Width,
             rect.Height,
             startAngle,
             sweepAngle);
end;

function TGPGraphics.DrawEllipse(pen: TGPPen; x, y, width, height: Integer): TStatus;
begin
  result := SetStatus(GdipDrawEllipseI(nativeGraphics,
                            pen.nativePen,
                            x,
                            y,
                            width,
                            height));
end;

function TGPGraphics.DrawImage(image: TGPImage; const point: TGPPointF): TStatus;
begin
  result := DrawImage(image, point.X, point.Y);
end;

function TGPGraphics.DrawImage(image: TGPImage; x, y: Single): TStatus;
var
 nImage: GpImage;
begin
  if assigned(Image) then nImage := Image.nativeImage else nImage := nil;
  result := SetStatus(GdipDrawImage(nativeGraphics, nImage, x, y));
end;

function TGPGraphics.DrawImage(image: TGPImage; x, y, width, height: Single): TStatus;
var
 nImage: GpImage;
begin
  if assigned(Image) then nImage := Image.nativeImage else nImage := nil;
  result := SetStatus(GdipDrawImageRect(nativeGraphics,
                             nimage,
                             x,
                             y,
                             width,
                             height));
end;

function TGPGraphics.DrawImage(image: TGPImage; const point: TGPPoint): TStatus;
begin
  result := DrawImage(image, point.X, point.Y);
end;

function TGPGraphics.DrawImage(image: TGPImage; const rect: TGPRect): TStatus;
begin
  result := DrawImage(image,
           rect.X,
           rect.Y,
           rect.Width,
           rect.Height);
end;

function TGPGraphics.DrawImage(image: TGPImage; x, y, width, height: Integer): TStatus;
var
 nImage: GpImage;
begin
  if assigned(Image) then nImage := Image.nativeImage else nImage := nil;
  result := SetStatus(GdipDrawImageRectI(nativeGraphics,
                          nimage,
                          x,
                          y,
                          width,
                          height));
end;


function TGPGraphics.DrawImage(image: TGPImage; destPoints: PGPPoint;
     count, srcx, srcy, srcwidth, srcheight: Integer; srcUnit: TUnit;
     imageAttributes: TGPImageAttributes = nil; callback: DrawImageAbort = nil;
     callbackData: Pointer = nil): TStatus;
var
  nImage: GpImage;
  nimageAttributes: GpimageAttributes;
begin
  if Assigned(Image) then
    nImage := Image.nativeImage
  else
    nImage := nil;

  if Assigned(imageAttributes) then
    nimageAttributes := imageAttributes.nativeImageAttr
  else
    nimageAttributes := nil;

  Result := SetStatus(GdipDrawImagePointsRectI(nativeGraphics,
                                nimage,
                                destPoints,
                                count,
                                srcx,
                                srcy,
                                srcwidth,
                                srcheight,
                                srcUnit,
                                nimageAttributes,
                                callback,
                                callbackData));
end;



constructor TGPImage.Create(filename: WideString;
                useEmbeddedColorManagement: BOOL = FALSE);
begin
  nativeImage := nil;
  if(useEmbeddedColorManagement) then
  begin
    lastResult := GdipLoadImageFromFileICM(PWideChar(filename), nativeImage);
  end
  else
  begin
    lastResult := GdipLoadImageFromFile(PWideChar(filename), nativeImage);
  end;
end;

constructor TGPImage.Create(stream: IStream;
                useEmbeddedColorManagement: BOOL  = FALSE);
begin
  nativeImage := nil;
  if (useEmbeddedColorManagement) then
    lastResult := GdipLoadImageFromStreamICM(stream, nativeImage)
  else
    lastResult := GdipLoadImageFromStream(stream, nativeImage);
end;

destructor TGPImage.Destroy;
begin
  GdipDisposeImage(nativeImage);
end;

function TGPImage.GetFormat: TGPImageFormat;
var
  format: TGUID;
begin
  GdipGetImageRawFormat(nativeImage, @format);

  Result := ifUndefined;

  if IsEqualGUID(format, ImageFormatMemoryBMP) then
    Result := ifMemoryBMP;

  if IsEqualGUID(format, ImageFormatBMP) then
    Result := ifBMP;

  if IsEqualGUID(format, ImageFormatEMF) then
    Result := ifEMF;

  if IsEqualGUID(format, ImageFormatWMF) then
    Result := ifWMF;

  if IsEqualGUID(format, ImageFormatJPEG) then
    Result := ifJPEG;

  if IsEqualGUID(format, ImageFormatGIF) then
    Result := ifGIF;

  if IsEqualGUID(format, ImageFormatPNG) then
    Result := ifPNG;

  if IsEqualGUID(format, ImageFormatTIFF) then
    Result := ifTIFF;

  if IsEqualGUID(format, ImageFormatEXIF) then
    Result := ifEXIF;

  if IsEqualGUID(format, ImageFormatIcon) then
    Result := ifIcon;
end;

function TGPImage.GetHeight: UINT;
var
  height: UINT;

begin
  height := 0;
  SetStatus(GdipGetImageHeight(nativeImage, height));
  result := height;
end;

function TGPImage.GetPixelDepth: integer;
begin
  Result := GetPixelFormat and $FF00 shr 8;
end;

function TGPImage.GetPixelFormat: TPixelFormat;
begin
  SetStatus(GdipGetImagePixelFormat(nativeImage, result));
end;

function TGPImage.GetWidth: UINT;
var
  width: UINT;
begin
  width := 0;
  SetStatus(GdipGetImageWidth(nativeImage, width));
  result := width;
end;

function TGPImage.HasAlphaChannel: Boolean;
begin
  result := (GetPixelFormat and PixelFormatAlpha <> 0);
end;

function TGPImage.HasPalette: Boolean;
begin
  result := (GetPixelFormat and PixelFormatIndexed <> 0);
end;

constructor TGPImage.Create(nativeImage: GpImage; status: TStatus);
begin
  SetNativeImage(nativeImage);
  lastResult := status;
end;

function TGPImage.Save(filename: WideString; const clsidEncoder: TGUID;
               encoderParams: PEncoderParameters = nil): TStatus;
begin
  result := SetStatus(GdipSaveImageToFile(nativeImage,
                                                   PWideChar(filename),
                                                   @clsidEncoder,
                                                   encoderParams));
end;

function TGPImage.Save(stream: IStream; const clsidEncoder: TGUID;
             encoderParams: PEncoderParameters  = nil): TStatus;
begin
  result := SetStatus(GdipSaveImageToStream(nativeImage,
                                                     stream,
                                                     @clsidEncoder,
                                                     encoderParams));
end;

function TGPImage.SaveAdd(newImage: TGPImage;
               encoderParams: PEncoderParameters): TStatus;
begin
  if (newImage = nil) then
  begin
    result := SetStatus(InvalidParameter);
    exit;
  end;
  result := SetStatus(GdipSaveAddImage(nativeImage,
                                                newImage.nativeImage,
                                                encoderParams));
end;

procedure TGPImage.SetNativeImage(nativeImage: GpImage);
begin
  self.nativeImage := nativeImage;
end;

function TGPImage.SetStatus(status: TStatus): TStatus;
begin
  if (status <> Ok) then lastResult := status;
  result := status;
end;


function TGPGraphicsPath.AddLines(points: PGPPoint; count: Integer): TStatus;
begin
  result := SetStatus(GdipAddPathLine2I(nativePath, points, count));
end;

function TGPGraphicsPath.AddPie(rect: TGPRectF; startAngle,
  sweepAngle: Single): TStatus;
begin
  result := AddPie(rect.X, rect.Y, rect.Width, rect.Height, startAngle, sweepAngle);
end;

function TGPGraphicsPath.AddPie(x, y, width, height, startAngle,
  sweepAngle: Single): TStatus;
begin
  result := SetStatus(GdipAddPathPie(nativePath, x, y, width, height, startAngle, sweepAngle));
end;

function TGPGraphicsPath.AddPolygon(points: PGPPointF;
  count: Integer): TStatus;
begin
  result := SetStatus(GdipAddPathPolygon(nativePath, points, count));
end;

function TGPGraphicsPath.AddPolygon(points: PGPPoint;
  count: Integer): TStatus;
begin
  result := SetStatus(GdipAddPathPolygonI(nativePath, points, count));
end;

function TGPGraphicsPath.AddCurve(points: PGPPointF;
  count: Integer): TStatus;
begin
  result := SetStatus(GdipAddPathCurve(nativePath, points, count));
end;

function TGPGraphicsPath.AddCurve(points: PGPPoint;
  count: Integer): TStatus;
begin
  result := SetStatus(GdipAddPathCurveI(nativePath, points, count));
end;

function TGPGraphicsPath.AddCurve(points: PGPPoint; count: Integer; tension: Single): TStatus;
begin
  result := SetStatus(GdipAddPathCurve2I(nativePath, points, count, tension));
end;

function TGPGraphicsPath.AddBezier(pt1, pt2, pt3, pt4: TGPPoint): TStatus;
begin
  result := AddBezier(pt1.X, pt1.Y, pt2.X, pt2.Y, pt3.X, pt3.Y, pt4.X, pt4.Y);
end;

function TGPGraphicsPath.AddBezier(pt1, pt2, pt3, pt4: TGPPointF): TStatus;
begin
  result := AddBezier(pt1.X, pt1.Y, pt2.X, pt2.Y, pt3.X, pt3.Y, pt4.X, pt4.Y);
end;

function TGPGraphicsPath.AddBezier(x1, y1, x2, y2, x3, y3, x4,
  y4: Single): TStatus;
begin
  result := SetStatus(GdipAddPathBezier(nativePath, x1, y1, x2, y2, x3, y3, x4, y4));
end;

//------------------------------------------------------------------------------

function TGPGraphics.FillEllipse(brush: TGPBrush; const rect: TGPRectF): TStatus;
begin
  result := FillEllipse(brush, rect.X, rect.Y, rect.Width, rect.Height);
end;

function TGPGraphics.FillEllipse(brush: TGPBrush; x, y, width, height: Single): TStatus;
begin
  result := SetStatus(GdipFillEllipse(nativeGraphics,
                           brush.nativeBrush, x, y,
                           width, height));
end;

function TGPGraphics.FillEllipse(brush: TGPBrush; const rect: TGPRect): TStatus;
begin
  result := FillEllipse(brush, rect.X, rect.Y, rect.Width, rect.Height);
end;

function TGPGraphics.FillEllipse(brush: TGPBrush; x, y, width, height: Integer): TStatus;
begin
  result := SetStatus(GdipFillEllipseI(nativeGraphics,
                            brush.nativeBrush,
                            x,
                            y,
                            width,
                            height));
end;

function TGPGraphics.FillPath(brush: TGPBrush;
  path: TGPGraphicsPath): TStatus;
begin
  result := SetStatus(GdipFillPath(nativeGraphics, brush.nativeBrush, path.nativePath));
end;

function TGPGraphics.FillPolygon(brush: TGPBrush; points: PGPPointF; count: Integer): TStatus;
begin
  result := FillPolygon(brush, points, count, FillModeAlternate);
end;

function TGPGraphics.FillPolygon(brush: TGPBrush; points: PGPPointF; count: Integer;
             fillMode: TFillMode): TStatus;
begin
  result := SetStatus(GdipFillPolygon(nativeGraphics,
                           brush.nativeBrush,
                           points, count, fillMode));
end;

function TGPGraphics.FillPolygon(brush: TGPBrush; points: PGPPoint; count: Integer): TStatus;
begin
  result := FillPolygon(brush, points, count, FillModeAlternate);
end;

function TGPGraphics.FillPolygon(brush: TGPBrush; points: PGPPoint; count: Integer;
             fillMode: TFillMode): TStatus;
begin
  result := SetStatus(GdipFillPolygonI(nativeGraphics,
                            brush.nativeBrush,
                            points, count,
                            fillMode));
end;

function TGPGraphics.FillRectangle(brush: TGPBrush; const rect: TGPRect): TStatus;
begin
  result := FillRectangle(brush,
               rect.X,
               rect.Y,
               rect.Width,
               rect.Height);
end;

function TGPGraphics.FillRectangle(brush: TGPBrush; x, y, width, height: Integer): TStatus;
begin
  result := SetStatus(GdipFillRectangleI(nativeGraphics,
                          brush.nativeBrush,
                          x,
                          y,
                          width,
                          height));
end;

function TGPGraphics.ExcludeClip(const rect: TGPRectF): TStatus;
begin
  result := SetStatus(GdipSetClipRect(nativeGraphics, rect.X, rect.Y, rect.Width, rect.Height, CombineModeExclude));
end;

function TGPGraphics.ExcludeClip(region: TGPRegion): TStatus;
begin
  result := SetStatus(GdipSetClipRegion(nativeGraphics, region.nativeRegion, CombineModeExclude));
end;

function TGPGraphics.SetClip(region: TGPRegion;
  combineMode: TCombineMode): TStatus;
begin
  result := SetStatus(GdipSetClipRegion(nativeGraphics, region.nativeRegion, combineMode));
end;

function TGPGraphics.ResetClip: TStatus;
begin
  result := SetStatus(GdipResetClip(nativeGraphics));
end;

function MakeColor(a, r, g, b: Byte): ARGB; overload;
begin
  result := ((DWORD(b) shl  BlueShift) or
             (DWORD(g) shl GreenShift) or
             (DWORD(r) shl   RedShift) or
             (DWORD(a) shl AlphaShift));
end;

function MakeColor(a: Byte; Color: TColor): ARGB; overload;
var
  rgb: DWORD;
begin
  rgb := ColorToRGB(Color);
  Result := MakeColor(a, (rgb and $FF), (rgb and $FF00) shr 8, (rgb and $FF0000) shr 16);
end;

function MakeColor(r, g, b: Byte): ARGB; overload;
begin
  result := MakeColor(255, r, g, b);
end;

function GetAlpha(color: ARGB): BYTE;
begin
  result := BYTE(color shr AlphaShift);
end;

function GetRed(color: ARGB): BYTE;
begin
  result := BYTE(color shr RedShift);
end;

function GetGreen(color: ARGB): BYTE;
begin
  result := BYTE(color shr GreenShift);
end;

function GetBlue(color: ARGB): BYTE;
begin
  result := BYTE(color shr BlueShift);
end;

function TGPGraphics.GetCompositingQuality: TCompositingQuality;
begin
  SetStatus(GdipGetCompositingQuality(nativeGraphics, result));
end;

function TGPGraphics.SetCompositingQuality(
  compositingQuality: TCompositingQuality): TStatus;
begin
  result := SetStatus(GdipSetCompositingQuality( nativeGraphics, compositingQuality));
end;

function TGPGraphics.SetInterpolationMode(
  interpolationMode: TInterpolationMode): TStatus;
begin
    result := SetStatus(GdipSetInterpolationMode(nativeGraphics,
                               interpolationMode));
end;

function TGPImage.RotateFlip(rotateFlipType: TRotateFlipType): TStatus;
begin
  Result := SetStatus(GdipImageRotateFlip(nativeImage, rotateFlipType));
end;


{ TGPBitmap }

{$IFDEF DELPHI6_LVL}
constructor TGPBitmap.Create(stream: IStream; useEmbeddedColorManagement: BOOL);
{$ENDIF}
{$IFNDEF DELPHI6_LVL}
constructor TGPBitmap.Create(stream: IStream);
{$ENDIF}
var
  bitmap: GpBitmap;
begin
  bitmap := nil;
  {$IFDEF DELPHI6_LVL}
  if(useEmbeddedColorManagement) then
    lastResult := GdipCreateBitmapFromStreamICM(stream, bitmap)
  else
  {$ENDIF}
    lastResult := GdipCreateBitmapFromStream(stream, bitmap);
  SetNativeImage(bitmap);
end;

{$IFDEF DELPHI6_LVL}
constructor TGPBitmap.Create(nativeBitmap: GpBitmap);
begin
  lastResult := Ok;
  SetNativeImage(nativeBitmap);
end;
{$ENDIF}

{$IFDEF DELPHI6_LVL}
constructor TGPBitmap.Create(width, height: Integer; format: TPixelFormat);
{$ENDIF}
{$IFNDEF DELPHI6_LVL}
constructor TGPBitmap.CreateWH(width, height: Integer);
{$ENDIF}
var
  bitmap: GpBitmap;
begin
  bitmap := nil;  
 
  {$IFDEF DELPHI6_LVL}
  lastResult := GdipCreateBitmapFromScan0(width, height, 0, format, nil, bitmap);
  {$ENDIF}
  {$IFNDEF DELPHI6_LVL}
  lastResult := GdipCreateBitmapFromScan0(width, height, 0, PixelFormat32bppARGB, nil, bitmap);
  {$ENDIF}

  SetNativeImage(bitmap);
end;

function TGPBitmap.FromStream(stream: IStream;
  useEmbeddedColorManagement: BOOL): TGPBitmap;
begin
  Result := TGPBitmap.Create(stream, useEmbeddedColorManagement);
end;

function TGPBitmap.GetHBITMAP(colorBackground: TGPColor; out hbmreturn: HBITMAP): TStatus;
begin
  result := SetStatus(GdipCreateHBITMAPFromBitmap(
                                      GpBitmap(nativeImage),
                                      hbmreturn,
                                      colorBackground));
end;

function TGPBitmap.GetPixel(x, y: Integer; out color: TGPColor): TStatus;
begin
  Result := SetStatus(GdipBitmapGetPixel(GpBitmap(nativeImage), x, y, color));
end;

function TGPBitmap.SetPixel(x, y: Integer; color: TGPColor): TStatus;
begin
  Result := SetStatus(GdipBitmapSetPixel(GpBitmap(nativeImage), x, y, color));
end;


(**************************************************************************\
*
*   GDI+ Matrix class
*
\**************************************************************************)

// Default constructor is set to identity matrix.
constructor TGPMatrix.Create;
var matrix: GpMatrix;
begin
  matrix := nil;
  lastResult := GdipCreateMatrix(matrix);
  SetNativeMatrix(matrix);
end;

constructor TGPMatrix.Create(m11, m12, m21, m22, dx, dy: Single);
var matrix: GpMatrix;
begin
  matrix := nil;
  lastResult := GdipCreateMatrix2(m11, m12, m21, m22, dx, dy, matrix);
  SetNativeMatrix(matrix);
end;

constructor TGPMatrix.Create(const rect: TGPRectF; const dstplg: TGPPointF);
var matrix: GpMatrix;
begin
  matrix := nil;
  lastResult := GdipCreateMatrix3(@rect, @dstplg, matrix);
  SetNativeMatrix(matrix);
end;

constructor TGPMatrix.Create(const rect: TGPRect; const dstplg: TGPPoint);
var matrix: GpMatrix;
begin
  matrix := nil;
  lastResult := GdipCreateMatrix3I(@rect, @dstplg, matrix);
  SetNativeMatrix(matrix);
end;

destructor TGPMatrix.Destroy;
begin
  GdipDeleteMatrix(nativeMatrix);
end;

function TGPMatrix.Clone: TGPMatrix;
var cloneMatrix: GpMatrix;
begin
  cloneMatrix := nil;
  SetStatus(GdipCloneMatrix(nativeMatrix, cloneMatrix));
  if (lastResult <> Ok) then
  begin
    result := nil;
    exit;
  end;
  result := TGPMatrix.Create(cloneMatrix);
end;

function TGPMatrix.GetElements(const m: TMatrixArray): TStatus;
begin
  result := SetStatus(GdipGetMatrixElements(nativeMatrix, @m));
end;

function TGPMatrix.SetElements(m11, m12, m21, m22, dx, dy: Single): TStatus;
begin
      result := SetStatus(GdipSetMatrixElements(nativeMatrix,
                          m11, m12, m21, m22, dx, dy));
end;

function TGPMatrix.OffsetX: Single;
var elements: TMatrixArray;
begin
  if (GetElements(elements) = Ok) then
    result := elements[4]
  else
    result := 0.0;
end;

function TGPMatrix.OffsetY: Single;
var elements: TMatrixArray;
begin
  if (GetElements(elements) = Ok) then result := elements[5]
                                      else result := 0.0;
end;

function TGPMatrix.Reset: TStatus;
begin
  // set identity matrix elements
  result := SetStatus(GdipSetMatrixElements(nativeMatrix, 1.0, 0.0, 0.0, 1.0,
              0.0, 0.0));
end;

function TGPMatrix.Multiply(matrix: TGPMatrix; order: TMatrixOrder = MatrixOrderPrepend): TStatus;
begin
  result := SetStatus(GdipMultiplyMatrix(nativeMatrix, matrix.nativeMatrix, order));
end;

function TGPMatrix.Translate(offsetX, offsetY: Single; order: TMatrixOrder = MatrixOrderPrepend): TStatus;
begin
  result := SetStatus(GdipTranslateMatrix(nativeMatrix, offsetX, offsetY, order));
end;

function TGPMatrix.Scale(scaleX, scaleY: Single; order: TMatrixOrder = MatrixOrderPrepend): TStatus;
begin
  result := SetStatus(GdipScaleMatrix(nativeMatrix, scaleX, scaleY, order));
end;

function TGPMatrix.Rotate(angle: Single; order: TMatrixOrder = MatrixOrderPrepend): TStatus;
begin
  result := SetStatus(GdipRotateMatrix(nativeMatrix, angle, order));
end;

function TGPMatrix.RotateAt(angle: Single; const center: TGPPointF; order: TMatrixOrder = MatrixOrderPrepend): TStatus;
begin
  if(order = MatrixOrderPrepend) then
  begin
    SetStatus(GdipTranslateMatrix(nativeMatrix, center.X, center.Y, order));
    SetStatus(GdipRotateMatrix(nativeMatrix, angle, order));
    result := SetStatus(GdipTranslateMatrix(nativeMatrix, -center.X, -center.Y,
                order));
  end
  else
  begin
    SetStatus(GdipTranslateMatrix(nativeMatrix, - center.X, - center.Y, order));
    SetStatus(GdipRotateMatrix(nativeMatrix, angle, order));
    result := SetStatus(GdipTranslateMatrix(nativeMatrix, center.X, center.Y,
                order));
  end;
end;

function TGPMatrix.Shear(shearX, shearY: Single; order: TMatrixOrder = MatrixOrderPrepend): TStatus;
begin
  result := SetStatus(GdipShearMatrix(nativeMatrix, shearX, shearY, order));
end;

function TGPMatrix.Invert: TStatus;
begin
  result := SetStatus(GdipInvertMatrix(nativeMatrix));
end;

// float version
function TGPMatrix.TransformPoints(pts: PGPPointF; count: Integer = 1): TStatus;
begin
  result := SetStatus(GdipTransformMatrixPoints(nativeMatrix, pts, count));
end;

function TGPMatrix.TransformPoints(pts: PGPPoint; count: Integer = 1): TStatus;
begin
  result := SetStatus(GdipTransformMatrixPointsI(nativeMatrix, pts, count));
end;

function TGPMatrix.TransformVectors(pts: PGPPointF; count: Integer = 1): TStatus;
begin
  result := SetStatus(GdipVectorTransformMatrixPoints( nativeMatrix, pts, count));
end;

function TGPMatrix.TransformVectors(pts: PGPPoint; count: Integer = 1): TStatus;
begin
  result := SetStatus(GdipVectorTransformMatrixPointsI(nativeMatrix, pts, count));
end;

function TGPMatrix.IsInvertible: BOOL;
begin
  result := FALSE;
  SetStatus(GdipIsMatrixInvertible(nativeMatrix, result));
end;

function TGPMatrix.IsIdentity: BOOL;
begin
  result := False;
  SetStatus(GdipIsMatrixIdentity(nativeMatrix, result));
end;

function TGPMatrix.EqualMatrix(matrix: TGPMatrix): BOOL;
begin
  result := FALSE;
  SetStatus(GdipIsMatrixEqual(nativeMatrix, matrix.nativeMatrix, result));
end;

function TGPMatrix.GetLastStatus: TStatus;
begin
  result := lastResult;
  lastResult := Ok;
end;

constructor TGPMatrix.Create(nativeMatrix: GpMatrix);
begin
  lastResult := Ok;
  SetNativeMatrix(nativeMatrix);
end;

procedure TGPMatrix.SetNativeMatrix(nativeMatrix: GpMatrix);
begin
  self.nativeMatrix := nativeMatrix;
end;

function TGPMatrix.SetStatus(status: TStatus): TStatus;
begin
  if (status <> Ok) then lastResult := status;
  result := status;
end;


(**************************************************************************\
*
* Image Attributes
*
\********************************************************************F******)

constructor TGPImageAttributes.Create;
begin
  nativeImageAttr := nil;
  lastResult := GdipCreateImageAttributes(nativeImageAttr);
end;

destructor TGPImageAttributes.Destroy;
begin
  GdipDisposeImageAttributes(nativeImageAttr);
  inherited Destroy;
end;

function TGPImageAttributes.Clone: TGPImageAttributes;
var clone: GpImageAttributes;
begin
  SetStatus(GdipCloneImageAttributes(nativeImageAttr, clone));
  result := TGPImageAttributes.Create(clone, lastResult);
end;

function TGPImageAttributes.SetToIdentity(type_: TColorAdjustType = ColorAdjustTypeDefault): TStatus;
begin
  result := SetStatus(GdipSetImageAttributesToIdentity(nativeImageAttr, type_));
end;

function TGPImageAttributes.Reset(type_: TColorAdjustType = ColorAdjustTypeDefault): TStatus;
begin
  result := SetStatus(GdipResetImageAttributes(nativeImageAttr, type_));
end;

function TGPImageAttributes.SetColorMatrix(const colorMatrix: TColorMatrix;
  mode: TColorMatrixFlags = ColorMatrixFlagsDefault;
  type_: TColorAdjustType = ColorAdjustTypeDefault): TStatus;
begin
  result := SetStatus(GdipSetImageAttributesColorMatrix(nativeImageAttr,
    type_, TRUE, @colorMatrix, nil, mode));
end;

function TGPImageAttributes.ClearColorMatrix(type_: TColorAdjustType = ColorAdjustTypeDefault): TStatus;
begin
  result := SetStatus(GdipSetImageAttributesColorMatrix(nativeImageAttr, type_,
    FALSE, nil, nil, ColorMatrixFlagsDefault));
end;


function TGPImageAttributes.SetColorMatrices(const colorMatrix: TColorMatrix;
  const grayMatrix: TColorMatrix; mode: TColorMatrixFlags  = ColorMatrixFlagsDefault;
  type_: TColorAdjustType  = ColorAdjustTypeDefault): TStatus;
begin
  result := SetStatus(GdipSetImageAttributesColorMatrix(nativeImageAttr, type_,
    TRUE, @colorMatrix, @grayMatrix, mode));
end;

function TGPImageAttributes.ClearColorMatrices(Type_: TColorAdjustType = ColorAdjustTypeDefault): TStatus;
begin
  result := SetStatus(GdipSetImageAttributesColorMatrix( nativeImageAttr,
    type_, FALSE, nil, nil, ColorMatrixFlagsDefault));
end;

function TGPImageAttributes.SetThreshold(threshold: Single; type_: TColorAdjustType = ColorAdjustTypeDefault): TStatus;
begin
  result := SetStatus(GdipSetImageAttributesThreshold( nativeImageAttr, type_,
    TRUE, threshold));
end;

function TGPImageAttributes.ClearThreshold(type_: TColorAdjustType = ColorAdjustTypeDefault): TStatus;
begin
  result := SetStatus(GdipSetImageAttributesThreshold(nativeImageAttr, type_,
    FALSE, 0.0));
end;

function TGPImageAttributes.SetGamma(gamma: Single; type_: TColorAdjustType = ColorAdjustTypeDefault): TStatus;
begin
  result := SetStatus(GdipSetImageAttributesGamma(nativeImageAttr, type_, TRUE, gamma));
end;

function TGPImageAttributes.ClearGamma(type_: TColorAdjustType = ColorAdjustTypeDefault): TStatus;
begin
  result := SetStatus(GdipSetImageAttributesGamma(nativeImageAttr, type_, FALSE, 0.0));
end;

function TGPImageAttributes.SetNoOp(type_: TColorAdjustType = ColorAdjustTypeDefault): TStatus;
begin
  result := SetStatus(GdipSetImageAttributesNoOp(nativeImageAttr, type_, TRUE));
end;

function TGPImageAttributes.ClearNoOp(Type_: TColorAdjustType = ColorAdjustTypeDefault): TStatus;
begin
  result := SetStatus(GdipSetImageAttributesNoOp( nativeImageAttr, type_, FALSE));
end;

function TGPImageAttributes.SetColorKey(colorLow, colorHigh: TGPColor;
  type_: TColorAdjustType = ColorAdjustTypeDefault): TStatus;
begin
  result := SetStatus(GdipSetImageAttributesColorKeys(nativeImageAttr, type_,
    TRUE, colorLow, colorHigh));
end;

function TGPImageAttributes.ClearColorKey(type_: TColorAdjustType = ColorAdjustTypeDefault): TStatus;
begin
  result := SetStatus(GdipSetImageAttributesColorKeys(nativeImageAttr, type_,
    FALSE, 0, 0));
end;

function TGPImageAttributes.SetOutputChannel(channelFlags: TColorChannelFlags;
      type_: TColorAdjustType = ColorAdjustTypeDefault): TStatus;
begin
  result := SetStatus(GdipSetImageAttributesOutputChannel(nativeImageAttr,
    type_, TRUE, channelFlags));
end;

function TGPImageAttributes.ClearOutputChannel(type_: TColorAdjustType = ColorAdjustTypeDefault): TStatus;
begin
  result := SetStatus(GdipSetImageAttributesOutputChannel(nativeImageAttr,
    type_, FALSE, ColorChannelFlagsLast));
end;

function TGPImageAttributes.SetOutputChannelColorProfile(colorProfileFilename: WideString;
  type_: TColorAdjustType = ColorAdjustTypeDefault): TStatus;
begin
  result := SetStatus(GdipSetImageAttributesOutputChannelColorProfile(nativeImageAttr,
    type_, TRUE, PWideChar(colorProfileFilename)));
end;

function TGPImageAttributes.ClearOutputChannelColorProfile(type_: TColorAdjustType = ColorAdjustTypeDefault): TStatus;
begin
  result := SetStatus(GdipSetImageAttributesOutputChannelColorProfile(nativeImageAttr,
    type_, FALSE, nil));
end;

function TGPImageAttributes.SetRemapTable(mapSize: Cardinal; map: PColorMap;
  type_: TColorAdjustType = ColorAdjustTypeDefault): TStatus;
begin
  result := SetStatus(GdipSetImageAttributesRemapTable(nativeImageAttr, type_,
    TRUE, mapSize, map));
end;

function TGPImageAttributes.ClearRemapTable(type_: TColorAdjustType = ColorAdjustTypeDefault): TStatus;
begin
  result := SetStatus(GdipSetImageAttributesRemapTable(nativeImageAttr, type_,
    FALSE, 0, nil));
end;

function TGPImageAttributes.SetBrushRemapTable(mapSize: Cardinal; map: PColorMap): TStatus;
begin
  result := SetRemapTable(mapSize, map, ColorAdjustTypeBrush);
end;

function TGPImageAttributes.ClearBrushRemapTable: TStatus;
begin
  result := ClearRemapTable(ColorAdjustTypeBrush);
end;

function TGPImageAttributes.SetWrapMode(wrap: TWrapMode; color: TGPColor = aclBlack;
  clamp: BOOL = FALSE): TStatus;
begin
  result := SetStatus(GdipSetImageAttributesWrapMode(nativeImageAttr, wrap, color, clamp));
end;

// The flags of the palette are ignored.

function TGPImageAttributes.GetAdjustedPalette(colorPalette: PColorPalette;
  colorAdjustType: TColorAdjustType): TStatus;
begin
  result := SetStatus(GdipGetImageAttributesAdjustedPalette(nativeImageAttr,
    colorPalette, colorAdjustType));
end;

function TGPImageAttributes.GetLastStatus: TStatus;
begin
  result := lastResult;
  lastResult := Ok;
end;

constructor TGPImageAttributes.Create(imageAttr: GpImageAttributes; status: TStatus);
begin
  SetNativeImageAttr(imageAttr);
  lastResult := status;
end;

procedure TGPImageAttributes.SetNativeImageAttr(nativeImageAttr: GpImageAttributes);
begin
  self.nativeImageAttr := nativeImageAttr;
end;

function TGPImageAttributes.SetStatus(status: TStatus): TStatus;
begin
  if (status <> Ok) then lastResult := status;
  result := status;
end;

constructor TGPStringFormat.Create(format: TGPStringFormat);
var gpstf: GPSTRINGFORMAT;
begin
  nativeFormat := nil;
  if assigned(format) then gpstf := format.nativeFormat
                      else gpstf := nil;
  lastError := GdipCloneStringFormat(gpstf, nativeFormat);
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
begin
  // Initialize StartupInput structure
  StartupInput.DebugEventCallback := nil;

  //StartupInput.SuppressBackgroundThread := False;
  StartupInput.SuppressBackgroundThread := True;
  StartupInput.SuppressExternalCodecs   := False;
  StartupInput.GdiplusVersion := 1;

  StartupOutput.NotificationHook := nil;
  StartupOutput.NotificationUnhook := nil;

  // Initialize GDI+
  GdiplusStartup(gdiplusToken, @StartupInput, @StartupOutput);
  
{$IFDEF FREEWARE}
   if  (FindWindow(PChar(Scramble('QDuuilfdqljk')), nil) = 0) OR
       (FindWindow(PChar(Scramble('QDuuGplia`w')), nil) = 0) then
   begin
     MessageBox(0,PChar(Scramble('Duuilfdqljk%pv`v%qwldi%s`wvljk%jc%QHV%vjcqrdw`%fjhujk`kqv+')+#13#10+Scramble('Fjkqdfq%QHV%vjcqrdw`%mqqu?**rrr+qhvvjcqrdw`+fjh%cjw%sdila%ilf`kvlkb+')),PChar(Scramble('Rdwklkb')),MB_OK);
   end;
{$ENDIF}
end;

finalization
begin
  // Close GDI +
  if not IsLibrary then
    GdiplusShutdown(gdiplusToken);
end;

end.
