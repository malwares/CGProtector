{***************************************************************************}
{ TAdvMemo styler component                                                 }
{ for Delphi & C++Builder                                                   }
{                                                                           }
{ written by TMS Software                                                   }
{            copyright © 2002 - 2008                                        }
{            Email : info@tmssoftware.com                                   }
{            Web : http://www.tmssoftware.com                               }
{                                                                           }
{ The source code is given as is. The author is not responsible             }
{ for any possible damage done due to the use of this code.                 }
{ The component can be freely used in any application. The complete         }
{ source code remains property of the author and may not be distributed,    }
{ published, given or sold in any form as such. No parts of the source      }
{ code can be included in any other component or application without        }
{ written authorization of TMS software.                                    }
{***************************************************************************}
{$I TMSDEFS.INC}
unit AdvmPS;

interface

uses
  Classes, AdvMemo,
{$IFDEF TMSCLX}
  QGraphics
{$ENDIF}
{$IFNDEF TMSCLX}
  Graphics
{$ENDIF}
  ;


type
  TAdvPascalMemoStyler=class(TAdvCustomMemoStyler)
  private
    FVersion: string;
  public
    constructor Create(AOwner: TComponent); override;
  published
    property Version: string read FVersion;
    property BlockStart;
    property BlockEnd;
    property LineComment;
    property MultiCommentLeft;
    property MultiCommentRight;
    property CommentStyle;
    property NumberStyle;
    property AllStyles;
    property AutoCompletion;
    property HintParameter;
    property HexIdentifier;
   
    property Description;
    property Filter;
    property DefaultExtension;
    property StylerName;
    property Extensions;
    property RegionDefinitions;
  end;


implementation

{ TAdvPascalMemoStyler }
constructor TAdvPascalMemoStyler.Create(AOwner: TComponent);
var
  itm:TElementStyle;
begin
  inherited;
  FVersion := '2.0';
  Description := 'Pascal';
  Filter := 'Pascal Files (*.pas,*.dpr,*.dpk,*.inc)|*.pas;*.dpr;*.dpk;*.inc';
  DefaultExtension := '.pas';
  StylerName := 'Pascal';
  Extensions := 'pas;dpr;dpk;inc';

  LineComment := '//';
  MultiCommentLeft := '{';
  MultiCommentRight := '}';
  CommentStyle.TextColor := clNavy;
  CommentStyle.BkColor := clWhite;
  CommentStyle.Style := [fsItalic];
  NumberStyle.TextColor := clFuchsia;
  NumberStyle.BkColor := clWhite;
  NumberStyle.Style := [fsBold];
  BlockStart := 'begin,try,case,class,record';
  BlockEnd := 'end';
  HexIdentifier := '$';
  //------------Pascal Standard Default-------------
  itm := AllStyles.Add;
  itm.Info := 'Pascal Standard Default';
  itm.Font.Color := clGreen;
  itm.Font.Style := [fsBold];
  with itm.KeyWords do
  begin
    Add('UNIT');
    Add('INTERFACE');
    Add('IMPLEMENTATION');
    Add('USES');
    Add('CONST');
    Add('PROGRAM');
    Add('PRIVATE');
    Add('PUBLIC');
    Add('PUBLISHED');
    Add('PROTECTED');
    Add('PROPERTY');
    Add('FUNCTION');
    Add('FINALISE');
    Add('INITIALISE');
    Add('VAR');
    Add('BEGIN');
    Add('WITH');
    Add('END');
    Add('FOR');
    Add('TO');
    Add('DO');
    Add('NOT');
    Add('IF');
    Add('THEN');
    Add('ELSE');
    Add('CLASS');
    Add('TYPE');
    Add('WHILE');
    Add('REPEAT');
    Add('UNTIL');
    Add('BREAK');
    Add('CONTINUE');
    Add('VIRTUAL');
    Add('OVERRIDE');
    Add('DEFAULT');
    Add('CLASS');
    Add('STORED');
    Add('INHERITED');
    Add('PROCEDURE');
    Add('CONSTRUCTOR');
    Add('DESTRUCTOR');
    Add('PROGRAM');
    Add('FINALLY');
    Add('RAISE');
    Add('STRING');
    Add('TRY');
    Add('EXCEPT');
    Add('STDCALL');
    Add('CDECL');
    Add('PASCAL');
    Add('NIL');
    Add('CASE');            
  end;
  
  //------------Simple Quote ' '----------------
  itm := AllStyles.Add;
  itm.StyleType := stBracket;
  itm.Info := 'Simple Quote';
  itm.Font.Color := clBlue;
  itm.Font.Style := [];
  itm.BracketStart := #39;
  itm.BracketEnd := #39;
  //------------Double Quote " "----------------
  itm := AllStyles.Add;
  itm.StyleType := stBracket;
  itm.Info := 'Double Quote';
  itm.Font.Color := clBlue;
  itm.Font.Style := [];
  itm.BracketStart := '"';
  itm.BracketEnd := '"';
  //----------SYMBOL --------------
  itm := AllStyles.Add;
  itm.StyleType := stSymbol;
  itm.Info := 'Symbols Delimiters';
  itm.Font.Color := clred;
  itm.Font.Style := [];
  itm.Symbols := #32+',;:.(){}[]=-*/^%<>#'+#13+#10;


  with HintParameter.Parameters do
  begin
    Add('ShowMessage(const Msg: string);');
    Add('MessageDlg(const Msg: string; DlgType: TMsgDlgType; Buttons: TMsgDlgButtons; HelpCtx: Longint): Integer);');
  end;

  with AutoCompletion do
  begin
    Add('ShowMessage');
    Add('MessageDlg');
  end;

  //-------------- Region Definition
  with RegionDefinitions.Add do
  begin
    Identifier := 'procedure';
    RegionStart := 'begin';
    RegionEnd := 'end';
    RegionType := rtClosed;
  end;
  with RegionDefinitions.Add do
  begin
    Identifier := 'constructor';
    RegionStart := 'begin';
    RegionEnd := 'end';
    RegionType := rtClosed;
  end;
  with RegionDefinitions.Add do
  begin
    Identifier := 'destructor';
    RegionStart := 'begin';
    RegionEnd := 'end';
    RegionType := rtClosed;
  end;

  with RegionDefinitions.Add do
  begin
    Identifier := 'interface';
    RegionStart := 'interface';
    RegionType := rtOpen;
  end;
  with RegionDefinitions.Add do
  begin
    Identifier := 'unit';
    RegionStart := 'unit';
    RegionType := rtFile;
  end;
  with RegionDefinitions.Add do
  begin
    Identifier := 'implementation';
    RegionStart := 'implementation';
    RegionType := rtOpen;
  end;
  with RegionDefinitions.Add do
  begin
    Identifier := 'case';
    RegionStart := 'case';
    RegionEnd := 'end';
    RegionType := rtIgnore;
  end;
  with RegionDefinitions.Add do
  begin
    Identifier := 'try';
    RegionStart := 'try';
    RegionEnd := 'end';
    RegionType := rtIgnore;
  end;
  with RegionDefinitions.Add do
  begin
    Identifier := 'function';
    RegionStart := 'begin';
    RegionEnd := 'end';
    RegionType := rtClosed;
  end;
  with RegionDefinitions.Add do
  begin
    Identifier := '{$region';
    RegionStart := '{$region';
    RegionEnd := '{$endregion';
    RegionType := rtClosed;
  end;
end;


end.



