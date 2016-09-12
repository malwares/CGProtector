{*******************************************************}
{                                                       }
{                Delphi VCL Extensions                  }
{                   Storage library                     }
{                                                       }
{         Copyright (c) 2000-2007 Deepsoftware          }
{                                                       }
{           www - http://www.deepsoftware.com           }
{              email - ray@deepsoftware.com             }
{                                                       }
{*******************************************************}
unit rsSearch;

interface

{$I rsStorage.inc}

uses Classes, SysUtils,
     {$IFDEF RSL_WIN}Windows,{$ENDIF}
     {$IFDEF RSL_D6GE}Variants,{$ENDIF}
     rsStorage, rsConst;

type
  TrsSearch = class;
  TrsScripter = class;
  TrsLexer = class;

  TrsParam = class(TCollectionItem)
  private
    FName: string;
    FValue: Variant;
    function GetAsVariant: Variant;
    function IsValueStored: Boolean;
    procedure SetAsVariant(const Value: Variant);
  protected
    function GetDisplayName: string; override;
  public
    Flags: integer;
    constructor Create(Collection: TCollection); override;
    destructor Destroy; override;
    procedure Assign(Source: TPersistent); override;
  published
    property Name: string read FName write FName;
    property Value: Variant read GetAsVariant write SetAsVariant stored IsValueStored;
  end;

  TrsParams = class(TCollection)
    FOwner: TrsSearch;
    function GetItem(Index: Integer): TrsParam;
    procedure SetItem(Index: Integer; const Value: TrsParam);
  protected
    function GetOwner: TPersistent; override;
  public
    constructor Create(AOwner: TrsSearch);
    function Add: TrsParam;
{$WARNINGS OFF}
    property Owner: TrsSearch read FOwner;
{$WARNINGS ON}
    function IndexOf(const Value: string): integer;
    function ParamByName(const Value: string): TrsParam;
    function FindParam(const Value: string): TrsParam;
    property Items[Index: Integer]: TrsParam read GetItem write SetItem; default;
  end;

  TrsSearchOption = (soCaseSensitivity);
  TrsSearchOptions = set of TrsSearchOption;

  TrsSearch = class(TrsStorageClient)
  private
    FKeyIndex: integer;
    FSearchText: TStringList;
    FPrepared: boolean;
    Scripter: TrsScripter;
    FParams: TrsParams;
    FOptions: TrsSearchOptions;
    procedure SetSearchText(const Value: TStrings);
    function GetSearchText: TStrings;
    procedure SetParams(const Value: TrsParams);
    procedure SetOptions(const Value: TrsSearchOptions);
    function GetParamCount: integer;
  protected
    FKeyWrapper: TrsKeyWrapper;

    procedure SetStorage(const Value: TrsStorage); override;
    procedure Prepare;
    property Prepared: boolean read FPrepared write FPrepared;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    function FindFirstKey: boolean;
    function FindNextKey: boolean;
    function FindPrevKey: boolean;
    function FindLastKey: boolean;
    property KeyWrapper: TrsKeyWrapper read FKeyWrapper;
    property ParamCount: integer read GetParamCount;
  published
    property Options: TrsSearchOptions read FOptions write SetOptions;
    property Params: TrsParams read FParams write SetParams;
    property SearchText: TStrings read GetSearchText write SetSearchText;
    property Storage;
  end;


//implementation
//uses rsUtils;

//type
  TrsScriptStepFunc = procedure (Scripter: TrsScripter) of object;

  TrsScriptStep = record
    Func: TrsScriptStepfunc;
    ResIdx: integer;
    In1Idx: integer;
    In2Idx: integer;
  end;
  PrsScriptStep = ^TrsScriptStep;

  TrsScriptSteps = array[0..1023] of TrsScriptStep;
  PrsScriptSteps = ^TrsScriptSteps;

  TrsScriptVars = array[0..1023] of Variant;
  PrsScriptVars = ^TrsScriptVars;


  TrsScripter = class
  private
    FSearch: TrsSearch;
    Lexer: TrsLexer;
    FCompiled: boolean;
    FScriptText: string;
    FCaseSensitivity: boolean;
    procedure SetScriptText(const Value: string);
  public
    Steps: PrsScriptSteps;
    StepsCapacity: integer;
    StepsCount: integer;

    Vars: PrsScriptVars;
    VarsCapacity: integer;
    VarsCount: integer;

    function StepAdd(AFunc: TrsScriptStepFunc; ARes,AIn1,AIn2: integer): integer;
    function VarAdd(AValue: Variant): integer;

    procedure Compile;
    procedure CompileExpression(LexIdx: integer);
    procedure CompileFunction(LexIdx: integer);
    procedure CompileOperand(LexIdx: integer);
    procedure CompileOperator(LexIdx: integer);

    function FindOperator(LexIdx: integer): integer;
    procedure LexemeSetCompiled(LexIdx, AVarIdx: integer);

    procedure DoOperatorAdd(Scripter: TrsScripter);
    procedure DoOperatorSub(Scripter: TrsScripter);
    procedure DoOperatorMul(Scripter: TrsScripter);
    procedure DoOperatorDiv(Scripter: TrsScripter);
    procedure DoOperatorOR(Scripter: TrsScripter);
    procedure DoOperatorAND(Scripter: TrsScripter);
    procedure DoOperatorXOR(Scripter: TrsScripter);
    procedure DoOperatorNOT(Scripter: TrsScripter);
    procedure DoOperatorCmpL(Scripter: TrsScripter);
    procedure DoOperatorCmpLE(Scripter: TrsScripter);
    procedure DoOperatorCmpG(Scripter: TrsScripter);
    procedure DoOperatorCmpGE(Scripter: TrsScripter);
    procedure DoOperatorCmpE(Scripter: TrsScripter);
    procedure DoOperatorCmpNE(Scripter: TrsScripter);
    procedure DoOperatorLike(Scripter: TrsScripter);
    procedure DoKeyName(Scripter: TrsScripter);
    procedure DoKeyType(Scripter: TrsScripter);
    procedure DoKeyValue(Scripter: TrsScripter);
    procedure DoUpperCase(Scripter: TrsScripter);
    procedure DoLowerCase(Scripter: TrsScripter);
    procedure DoSectionName(Scripter: TrsScripter);
    procedure DoSectionFullName(Scripter: TrsScripter);
    procedure DoSectionLevel(Scripter: TrsScripter);
    procedure DoParameter(Scripter: TrsScripter);

    function rsMatching(SearchString, Mask: PChar): boolean;
    function VarsConvertToSameType(VarIdx1, VarIdx2: integer): boolean;
    function IsString(const Value: variant): boolean;
  public
    PCurrentStep: PrsScriptStep;

    constructor Create(AOwner: TrsSearch);
    destructor Destroy; override;

    procedure Clear;
    function Run: Variant;
    property IsCompiled: boolean read FCompiled;
    property ScriptText: string read FScriptText write SetScriptText;
  end;


  TrsLexemeType = (ltUnknown,
                   ltConstStr, ltConstBool, ltConstInt, ltConstFloat,
                   ltBracketOpen, ltBracketClose, ltParameter,
                   ltOperatorDiv, ltOperatorMul, ltOperatorAdd, ltOperatorSub,
                   ltOperatorCmpL, ltOperatorCmpLE, ltOperatorCmpG, ltOperatorCmpGE, ltOperatorCmpE, ltOperatorCmpNE,
                   ltOperatorAND, ltOperatorOR, ltOperatorNOT, ltOperatorXOR, ltOperatorLike,
                   ltFuncUpperCase, ltFuncLowerCase,
                   ltFuncKeyName, ltFuncKeyType, ltFuncKeyValue,
                   ltFuncSectionName, ltFuncSectionLevel, ltFuncSectionFullName,

                   ltConstKvtUnknown, ltConstKvtString, ltConstKvtBuffer, ltConstKvtInteger,
                   ltConstKvtDouble, ltConstKvtCurrency, ltConstKvtDateTime, ltConstKvtBool,
                   ltConstKvtPoint, ltConstKvtInt64, ltConstKvtPointer
                   );

  TrsLexeme = class
    IsCompiled: boolean;
    LexType: TrsLexemeType;
    Text: string;
    VarIndex: integer;
  public
    constructor Create;
  end;

  TrsLexer = class
  private
    FList: TList;
    function GetCount: integer;
    function GetLexeme(index: integer): TrsLexeme;
    procedure Parse(P: PChar);
    function LexemeAdd(AType: TrsLexemeType; const AText: string): integer;
  public
    constructor Create;
    destructor Destroy; override;

    procedure Clear;
    function Add: integer;
    procedure Delete(index: integer);

    procedure ParseText(const Value: string);

    property Count: integer read GetCount;
    property Lexeme[index: integer]: TrsLexeme read GetLexeme; default;
  end;

type
  TrsLexemeKeyWord = record
    Id: TrsLexemeType;
    Name: string;
  end;

const
  LexemeKeyWords:  array[0..25] of TrsLexemeKeyWord = (
    (Id:ltOperatorAND;   Name:'and'),
    (Id:ltConstBool;     Name:'false'),
    (Id:ltFuncKeyName;   Name:'keyname'),
    (Id:ltFuncKeyType;   Name:'keytype'),
    (Id:ltFuncKeyValue;  Name:'keyvalue'),
    (Id:ltConstKvtBool;     Name:'kvtbool'),
    (Id:ltConstKvtBuffer;   Name:'kvtbuffer'),
    (Id:ltConstKvtCurrency; Name:'kvtcurrency'),
    (Id:ltConstKvtDateTime; Name:'kvtdateTime'),
    (Id:ltConstKvtDouble;   Name:'kvtdouble'),
    (Id:ltConstKvtInt64;    Name:'kvtint64'),
    (Id:ltConstKvtInteger;  Name:'kvtinteger'),
    (Id:ltConstKvtPoint;    Name:'kvtpoint'),
    (Id:ltConstKvtPointer;  Name:'kvtpointer'),
    (Id:ltConstKvtString;   Name:'kvtstring'),
    (Id:ltConstKvtUnknown;  Name:'kvtunknown'),
    (Id:ltOperatorLike;  Name:'like'),
    (Id:ltFuncLowerCase; Name:'lowercase'),
    (Id:ltOperatorNOT;   Name:'not'),
    (Id:ltOperatorOR;    Name:'or'),
    (Id:ltFuncSectionFullName; Name:'sectionfullname'),
    (Id:ltFuncSectionLevel;    Name:'sectionlevel'),
    (Id:ltFuncSectionName;     Name:'sectionname'),
    (Id:ltConstBool;     Name:'true'),
    (Id:ltFuncUpperCase; Name:'uppercase'),
    (Id:ltOperatorXOR;   Name:'xor')
  );


implementation

uses rsUtils;

type
  TintStorage = class(TrsStorage);


{ TrsSearch }

constructor TrsSearch.Create(AOwner: TComponent);
begin
  inherited;
  FNotifications := [];
  FParams := TrsParams.Create(Self);
  FSearchText := TStringList.Create;
  Scripter := TrsScripter.Create(Self);
  FKeyWrapper := TrsKeyWrapper.Create(nil);
  FKeyIndex := -1;
  FPrepared := False;
  FOptions := [];
{$IFDEF RSL_AUTOLINKREFERENCES}
  if csDesigning in ComponentState then begin
    Storage := TrsStorage(rsGlobalFindComponent(TrsStorage, AOwner, nil));
  end;
{$ENDIF}
end;

destructor TrsSearch.Destroy;
begin
  FKeyWrapper.Free;
  Scripter.Free;
  FSearchText.Free;
  FParams.Free;
  inherited;
end;


function TrsSearch.FindFirstKey: boolean;
begin
  Result := False;
  if not Assigned(Storage) then Exit;
  KeyWrapper.Storage := Storage;
  {if not Prepared then} Prepare;

  FKeyIndex := 0;
  while FKeyIndex<TintStorage(Storage).KeyCountAll do begin
    KeyWrapper.PKeyItem := TintStorage(Storage).GetKeyItem(FKeyIndex);
    if Scripter.Run then begin
      Result := True;
      Exit;
    end;
    Inc(FKeyIndex);
  end;
end;

function TrsSearch.FindLastKey: boolean;
begin
  Result := False;
  if not Assigned(Storage) then Exit;
  KeyWrapper.Storage := Storage;
  {if not Prepared then} Prepare;

  FKeyIndex := TintStorage(Storage).KeyCountAll-1;
  while FKeyIndex>=0 do begin
    KeyWrapper.PKeyItem := TintStorage(Storage).GetKeyItem(FKeyIndex);
    if Scripter.Run then begin
      Result := True;
      Exit;
    end;
    Dec(FKeyIndex);
  end;
end;


function TrsSearch.FindNextKey: boolean;
begin
  if FKeyIndex<0 then begin
    FKeyIndex := 0;
    Prepare;
  end else Inc(FKeyIndex);

  while FKeyIndex<TintStorage(Storage).KeyCountAll do begin
    KeyWrapper.PKeyItem := TintStorage(Storage).GetKeyItem(FKeyIndex);
    if Scripter.Run then begin
      Result := True;
      Exit;
    end;
    Inc(FKeyIndex);
  end;
  Result := False;
end;

function TrsSearch.FindPrevKey: boolean;
begin
  if FKeyIndex>=TintStorage(Storage).KeyCountAll then begin
    FKeyIndex := TintStorage(Storage).KeyCountAll-1;
    Prepare;
  end else Dec(FKeyIndex);

  while FKeyIndex>=0 do begin
    KeyWrapper.PKeyItem := TintStorage(Storage).GetKeyItem(FKeyIndex);
    if Scripter.Run then begin
      Result := True;
      Exit;
    end;
    Dec(FKeyIndex);
  end;
  Result := False;
end;

function TrsSearch.GetParamCount: integer;
begin
  Result := FParams.Count;
end;

function TrsSearch.GetSearchText: TStrings;
begin
  Result := FSearchText;
end;


procedure TrsSearch.Prepare;
begin
  Scripter.ScriptText := FSearchText.Text;
  FPrepared := Scripter.IsCompiled;
end;

procedure TrsSearch.SetOptions(const Value: TrsSearchOptions);
begin
  FOptions := Value;
  FPrepared := False;
end;

procedure TrsSearch.SetParams(const Value: TrsParams);
begin
  FParams.Assign(Value);
end;

procedure TrsSearch.SetSearchText(const Value: TStrings);
begin
  FSearchText.Assign(Value);
  FPrepared := False;
end;


procedure TrsSearch.SetStorage(const Value: TrsStorage);
begin
  inherited;
  KeyWrapper.Storage := Value;
end;

{ TrsLexer }

function TrsLexer.Add: integer;
var
  l: TrsLexeme;
begin
  l := TrsLexeme.Create;
  Result := FList.Add(l);
end;

procedure TrsLexer.Clear;
var
  i: integer;
begin
  for i:=0 to FList.Count-1 do begin
    TrsLexeme(FList[i]).Free;
    FList[i] := nil;
  end;
  FList.Clear
end;

constructor TrsLexer.Create;
begin
  FList := TList.Create;
end;

procedure TrsLexer.Delete(index: integer);
begin
  if (index>=0) and (index<FList.Count) then begin
    TrsLexeme(FList[index]).Free;
    FList[index] := nil;
    FList.Delete(index);
  end;
end;

destructor TrsLexer.Destroy;
begin
  Clear;
  inherited;
end;

function TrsLexer.GetCount: integer;
begin
  Result := FList.Count;
end;

function TrsLexer.GetLexeme(index: integer): TrsLexeme;
begin
  if (index>=0) and (index<FList.Count)
   then Result := FList[index]
   else begin
     rsError(egSearch, Format('no lexeme with Index=%d',[index]));
     Result := nil;
   end;
end;

function TrsLexer.LexemeAdd(AType: TrsLexemeType; const AText: string): integer;
begin
  Result := Add;
  with Lexeme[Result] do begin
    LexType := AType;
    Text := AText;
  end;
end;

procedure TrsLexer.Parse(P: PChar);
var
  PBegin: PChar;
  s: string;
  i,c,b,e: integer;
begin
  while True do begin

    while P^ in [' ',#9,#13,#10] do Inc(P); // skip spaces;
    if P^=#0 then Break;

    PBegin := P;

    if P^='''' then begin  // text string
      Inc(P);
      While not (P^ in ['''',#0]) do Inc(P);
      if P^<>#0 then Inc(P);

      SetString(s, PBegin, P-PBegin);
      LexemeAdd(ltConstStr, s);
      Continue;
    end;

    while not (P^ in ['(', ')', '*', '+', ',', '-', '.', '/', ':',
                      ';', '<', '=', '>', '@', '[', ']', '^',
                      ' ', #9, #0, #13, #10, '{', '}']) do Inc(P);

    if P=PBegin then begin
      if (PBegin^='<') and ((PBegin+1)^='=')
        then begin
          LexemeAdd(ltOperatorCmpLE, '<=');
          Inc(P,2);
          Continue;
        end else
      if (PBegin^='<') and ((PBegin+1)^='>')
        then begin
          LexemeAdd(ltOperatorCmpNE, '<>');
          Inc(P,2);
          Continue;
        end else
      if (PBegin^='>') and ((PBegin+1)^='=')
        then begin
          LexemeAdd(ltOperatorCmpGE, '>=');
          Inc(P,2);
          Continue;
        end else begin
          case PBegin^ of
            '(': LexemeAdd(ltBracketOpen, '(');
            ')': LexemeAdd(ltBracketClose, ')');
            '*': LexemeAdd(ltOperatorMul, '*');
            '+': LexemeAdd(ltOperatorAdd, '+');
//            ',': FLexeme1.Id := ClidComma;
            '-': LexemeAdd(ltOperatorSub, '-');
//            '.': FLexeme1.Id := ClidPeriod;
            '/': LexemeAdd(ltOperatorDiv, '/');
//            ':': FLexeme1.Id := ClidColon;
//            ';': FLexeme1.Id := ClidSemicolon;
            '<': LexemeAdd(ltOperatorCmpL, '<');
            '=': LexemeAdd(ltOperatorCmpE, '=');
            '>': LexemeAdd(ltOperatorCmpG, '>');
//            '@': FLexeme1.Id := ClidAt;
//            '[': FLexeme1.Id := ClidSqBracketOpen;
//            ']': FLexeme1.Id := ClidSqBracketClose;
//            '^': FLexeme1.Id := ClidCircum;
//            '{': FLexeme1.Id := ClidCurlyBracketOpen;
//            '}': FLexeme1.Id := ClidCurlyBracketClose;
            else begin
              SetString(s, PBegin, 1);
              LexemeAdd(ltUnknown, s);
            end;
          end;
          Inc(P);
          Continue;
        end;
    end; // end of P=PBegin

     b := Low(LexemeKeywords);
     e := High(LexemeKeywords);
     c := -1;
     while b<=e do begin
       i := (b+e) shr 1;
       c := StrLIComp(PChar(LexemeKeyWords[i].Name), PBegin, P-PBegin);
       if c<0 then b := i + 1
        else
       if c>0 then e := i - 1
        else begin
          SetString(s, PBegin, P-PBegin);
          LexemeAdd(LexemeKeyWords[i].Id, s);
          Break;
        end;
     end;
     if c<>0 then begin  // unknown word
       SetString(s, PBegin, P-PBegin);
       if IsDigitValue(PBegin, P-PBegin)=1 then begin
         LexemeAdd(ltConstInt, s);
       end else begin
         LexemeAdd(ltUnknown, s);
       end;
     end;
  end; // end of while

// post parse: Find float and parameters
  i := 0;
  While i<Count do begin
    if Length(Lexeme[i].Text)=1 then begin
      if Lexeme[i].Text[1] = ':' then begin  // find parameter
        if (i<(Count-1)) then begin
          Delete(i);
          Lexeme[i].Text := ':'+Lexeme[i].Text;
          Lexeme[i].LexType := ltParameter;
        end;
      end else
      if Lexeme[i].Text[1] = '.' then begin // may be float constant
        if (i>0) and (Lexeme[i-1].LexType=ltConstInt) and
           (i<(Count-1)) and (Lexeme[i+1].LexType=ltConstInt)
          then begin  // yes, float constant
             Dec(i);
             Lexeme[i].Text := Lexeme[i].Text + FormatSettings.DecimalSeparator + Lexeme[i+2].Text;
             Lexeme[i].LexType := ltConstFloat;
             Delete(i+2);
             Delete(i+1);
          end;
      end;
    end;
    Inc(i);
  end;
end;

procedure TrsLexer.ParseText(const Value: string);
begin
  Clear;
  Parse(PChar(Value));
end;


{ TrsLexeme }

constructor TrsLexeme.Create;
begin
  IsCompiled := False;
  VarIndex := -1;
end;

{ TrsScripter }

procedure TrsScripter.Clear;
begin
  if StepsCapacity>0 then begin
    FreeMem(Steps, StepsCapacity*SizeOf(TrsScriptStep));
    Steps := nil;
    StepsCapacity := 0;
  end;
  if VarsCapacity>0  then begin
    FreeMem(Vars, VarsCapacity*SizeOf(Variant));
    Vars := nil;
    VarsCapacity := 0;
  end;
  StepsCount := 0;
  VarsCount := 0;
  FCompiled := False;
end;


procedure TrsScripter.Compile;
var
  i: integer;
begin
  Clear;
  Lexer.ParseText(FScriptText);
  if Assigned(FSearch) then begin // mark all params for deleting
    for i:=0 to FSearch.Params.Count-1 do
      FSearch.Params[i].Flags := -1;
  end;

  if Lexer.Count>0 then CompileExpression(0);  // compile

  if Assigned(FSearch) then begin // delete unnecessary params
    i := 0;
    While i<FSearch.Params.Count do
      if FSearch.Params[i].Flags<0
        then {$IFDEF RSL_D5GE}
               FSearch.Params.Delete(i)
             {$ELSE}
               FSearch.Params[i].Free
             {$ENDIF}
        else Inc(i);
  end;
  FCompiled := True;
end;

procedure TrsScripter.CompileExpression(LexIdx: integer);
var
  i,j: integer;
begin
  if Lexer[LexIdx].IsCompiled then Exit;

  if Lexer[LexIdx].LexType=ltBracketOpen then begin
    CompileExpression(LexIdx+1);
    if not Lexer[LexIdx+1].IsCompiled then rsError(egSearchPrepare, 'Expression not compiled');
    if Lexer[LexIdx+2].LexType<>ltBracketClose then rsError(egSearchPrepare, 'No closed bracket');
    Lexer.Delete(LexIdx+2);
    Lexer.Delete(LexIdx);
//    Exit;
  end;

  while True do begin
    i:=FindOperator(LexIdx);
    if i<0 then Break;

    case Lexer[i].LexType of
      ltOperatorCmpL,
      ltOperatorCmpLE,
      ltOperatorCmpG,
      ltOperatorCmpGE,
      ltOperatorCmpE,
      ltOperatorCmpNE,
      ltOperatorAND,
      ltOperatorOR,
      ltOperatorXOR,
      ltOperatorLike:begin
                      CompileOperand(i+1);
                      j := FindOperator(i+1);
                      if (j>0) and
                         (Lexer[i].LexType in [ltOperatorCmpL, ltOperatorCmpLE, ltOperatorCmpG,
                                               ltOperatorCmpGE, ltOperatorCmpE, ltOperatorCmpNE,
                                               ltOperatorAND, ltOperatorOR, ltOperatorXOR,
                                               ltOperatorLike])
                        then rsError(egSearchPrepare, 'Need more brackets');
                      CompileOperand(LexIdx);
                      CompileOperator(LexIdx+1);
                    end;
      ltOperatorMul,
      ltOperatorDiv:
                    begin
                      CompileOperand(i+1);
                      CompileOperand(LexIdx);
                      CompileOperator(LexIdx+1);
                    end;
      ltOperatorAdd,
      ltOperatorSub:begin
                      CompileOperand(i+1);
                      j:=FindOperator(i+1);
                      if j>0 then
                       if Lexer[i].LexType in [ltOperatorMul,ltOperatorDiv]
                         then CompileExpression(i+1);
                      CompileOperand(LexIdx);
                      CompileOperator(LexIdx+1);
                    end;
      else begin
        rsError(egSearchPrepare,'Unknown operator');
      end;
    end; // of case
  end; // of while

  CompileOperand(LexIdx);
end;

procedure TrsScripter.CompileFunction(LexIdx: integer);
var
  fun: TrsScriptStepFunc;
  i, param1Idx: integer;
  s: string;
begin
  if Lexer[LexIdx].IsCompiled then Exit;

  if (LexIdx<(Lexer.Count-1)) and (Lexer[LexIdx+1].LexType=ltBracketOpen) then begin
    CompileExpression(LexIdx+2);
    if not Lexer[LexIdx+2].IsCompiled then rsError(egSearchPrepare, 'function parameter not compiled');
    if Lexer[LexIdx+3].LexType <> ltBracketClose then rsError(egSearchPrepare, 'need closed bracked for function parameter');
    param1Idx := Lexer[LexIdx+2].VarIndex;
    Lexer.Delete(LexIdx+3);
    Lexer.Delete(LexIdx+2);
    Lexer.Delete(LexIdx+1);
  end else param1Idx := -1;

  fun := nil; // close warning only
  case Lexer[LexIdx].LexType of
    ltFuncKeyName:     fun := DoKeyName;
    ltFuncKeyType:     fun := DoKeyType;
    ltFuncKeyValue:    fun := DoKeyValue;
    ltFuncUpperCase:   fun := DoUpperCase;
    ltFuncLowerCase:   fun := DoLowerCase;
    ltFuncSectionName:     fun := DoSectionName;
    ltFuncSectionLevel:    fun := DoSectionLevel;
    ltFuncSectionFullName: fun := DoSectionFullName;
    ltParameter: begin
                   s := Copy(Lexer[LexIdx].Text, 2, Length(Lexer[LexIdx].Text)-1);
                   param1Idx := VarAdd(s);
                   fun := DoParameter;
                   if Assigned(FSearch) then begin
                     i := FSearch.Params.IndexOf(s);
                     if i<0
                       then FSearch.Params.Add.Name := s
                       else FSearch.Params[i].Flags := 0; // not delete this param
                   end;
                 end;
    else rsError(egSearchPrepare, 'Unknown function');
  end;

  if Assigned(fun) then begin
    i := VarAdd(Unassigned);
    StepAdd(fun, i, param1Idx, -1);
    Lexer[LexIdx].VarIndex := i;
    Lexer[LexIdx].IsCompiled := True;
  end;
end;

procedure TrsScripter.CompileOperand(LexIdx: integer);
var
  i: integer;
begin
  if Lexer[LexIdx].IsCompiled then Exit;

  case Lexer[LexIdx].LexType of
    ltOperatorNOT:
                  begin
                    CompileOperand(LexIdx+1);
                    if not Lexer[LexIdx+1].IsCompiled then rsError(egSearchPrepare,'"NOT" operator not compiled');
                    i := VarAdd(Unassigned);
                    StepAdd(DoOperatorNOT, i, Lexer[LexIdx+1].VarIndex, -1);
                    Lexer[LexIdx].IsCompiled := True;
                    Lexer.Delete(LexIdx+1);
                  end;
//    ltOperatorSub: // унарный минус
    ltBracketOpen: CompileExpression(LexIdx);
    ltConstStr:         LexemeSetCompiled(LexIdx, VarAdd(Copy(Lexer[LexIdx].Text, 2, Length(Lexer[LexIdx].Text)-2)));
    ltConstBool:        LexemeSetCompiled(LexIdx, VarAdd(CompareText(Lexer[LexIdx].Text, RSBooleanIdentsTrue)=0));
    ltConstInt:         LexemeSetCompiled(LexIdx, VarAdd(StrToInt(Lexer[LexIdx].Text)));
    ltConstFloat:       LexemeSetCompiled(LexIdx, VarAdd(StrToFloat(Lexer[LexIdx].Text)));
    ltConstKvtUnknown:  LexemeSetCompiled(LexIdx, VarAdd(Integer(kvtUnknown)));
    ltConstKvtString:   LexemeSetCompiled(LexIdx, VarAdd(Integer(kvtString)));
    ltConstKvtBuffer:   LexemeSetCompiled(LexIdx, VarAdd(Integer(kvtBuffer)));
    ltConstKvtInteger:  LexemeSetCompiled(LexIdx, VarAdd(Integer(kvtInteger)));
    ltConstKvtDouble:   LexemeSetCompiled(LexIdx, VarAdd(Integer(kvtDouble)));
    ltConstKvtCurrency: LexemeSetCompiled(LexIdx, VarAdd(Integer(kvtCurrency)));
    ltConstKvtDateTime: LexemeSetCompiled(LexIdx, VarAdd(Integer(kvtDateTime)));
    ltConstKvtBool:     LexemeSetCompiled(LexIdx, VarAdd(Integer(kvtBool)));
    ltConstKvtPoint:    LexemeSetCompiled(LexIdx, VarAdd(Integer(kvtPoint)));
    ltConstKvtInt64:    {$IFDEF RSL_INT64}
                          LexemeSetCompiled(LexIdx, VarAdd(Integer(kvtInt64)));
                        {$ELSE}
                          LexemeSetCompiled(LexIdx, VarAdd(Integer($9)));
                        {$ENDIF}
    ltConstKvtPointer:  LexemeSetCompiled(LexIdx, VarAdd(Integer(kvtPointer)));
    else CompileFunction(LexIdx);
  end; // case
end;

procedure TrsScripter.CompileOperator(LexIdx: integer);
var
  i: integer;
  fun: TrsScriptStepFunc;
begin
  case Lexer[LexIdx].LexType of
    ltOperatorAdd   : fun := DoOperatorAdd;
    ltOperatorSub   : fun := DoOperatorSub;
    ltOperatorMul   : fun := DoOperatorMul;
    ltOperatorDiv   : fun := DoOperatorDiv;
    ltOperatorOR    : fun := DoOperatorOR;
    ltOperatorAND   : fun := DoOperatorAND;
    ltOperatorXOR   : fun := DoOperatorXOR;
    ltOperatorCmpL  : fun := DoOperatorCmpL;
    ltOperatorCmpLE : fun := DoOperatorCmpLE;
    ltOperatorCmpG  : fun := DoOperatorCmpG;
    ltOperatorCmpGE : fun := DoOperatorCmpGE;
    ltOperatorCmpE  : fun := DoOperatorCmpE;
    ltOperatorCmpNE : fun := DoOperatorCmpNE;
    ltOperatorLike  : fun := DoOperatorLike;
    else begin
      fun := nil; // off warning
      rsError(egSearchPrepare,'Unknown operator');
    end;
  end;

  i := VarAdd(Unassigned);
  StepAdd(fun, i, Lexer[LexIdx-1].VarIndex, Lexer[LexIdx+1].VarIndex);
  Lexer[LexIdx-1].IsCompiled := True;
  Lexer[LexIdx-1].VarIndex := i;

  Lexer.Delete(LexIdx+1);
  Lexer.Delete(LexIdx);
end;

constructor TrsScripter.Create(AOwner: TrsSearch);
begin
  FSearch := AOwner;
  Lexer := TrsLexer.Create;
  FCompiled := False;
end;

destructor TrsScripter.Destroy;
begin
  Clear;
  Lexer.Free;
  inherited;
end;

procedure TrsScripter.DoKeyName(Scripter: TrsScripter);
begin
  with PCurrentStep^ do
    Vars^[ResIdx] := AnsiString(FSearch.KeyWrapper.Name);
end;

procedure TrsScripter.DoKeyType(Scripter: TrsScripter);
begin
  with PCurrentStep^ do
    Vars^[ResIdx] := VarAsType(FSearch.KeyWrapper.KeyType, varInteger);
end;

procedure TrsScripter.DoKeyValue(Scripter: TrsScripter);
var
  v: variant;
begin
  with PCurrentStep^ do begin
    v := FSearch.KeyWrapper.AsVariant;
{$ifdef RSL_BDS6}
    if VarType(v)=varUString
      then v := VarAsType(v, varString)
      else
{$endif}
    if VarType(v)=varOleStr
      then v := VarAsType(v, varString);
    Vars^[ResIdx] := v;
  end;
end;

procedure TrsScripter.DoLowerCase(Scripter: TrsScripter);
begin
  with PCurrentStep^ do
    if IsString(Vars^[In1Idx])
      then Vars^[ResIdx] := LowerCase(Vars^[In1Idx])
      else Vars^[ResIdx] := Unassigned;
end;

procedure TrsScripter.DoOperatorAdd(Scripter: TrsScripter);
begin
  with PCurrentStep^ do
    Vars^[ResIdx] := Vars^[In1Idx] + Vars^[In2Idx];
end;

procedure TrsScripter.DoOperatorAND(Scripter: TrsScripter);
begin
  with PCurrentStep^ do
    if (VarType(Vars^[In1Idx]) in [{$IFDEF RSL_D6GE}varShortInt, varInt64, varWord, varLongWord,{$ENDIF} varSmallint, varInteger, varBoolean, varByte]) and
       (VarType(Vars^[In2Idx]) in [{$IFDEF RSL_D6GE}varShortInt, varInt64, varWord, varLongWord,{$ENDIF} varSmallint, varInteger, varBoolean, varByte])
      then Vars^[ResIdx] := Vars^[In1Idx] and Vars^[In2Idx]
      else Vars^[ResIdx] := False;
end;

procedure TrsScripter.DoOperatorCmpE(Scripter: TrsScripter);
begin
  with PCurrentStep^ do begin
    if VarType(Vars^[In1Idx])<>VarType(Vars^[In2Idx])
      then VarsConvertToSameType(In1Idx, In2Idx);

    if (IsString(Vars^[In1Idx])) and (not FCaseSensitivity) then begin
      Vars^[In1Idx] := UpperCase(Vars^[In1Idx]);
      Vars^[In2Idx] := UpperCase(Vars^[In2Idx]);
    end;
    Vars^[ResIdx] := Vars^[In1Idx] = Vars^[In2Idx];
  end;
end;

procedure TrsScripter.DoOperatorCmpG(Scripter: TrsScripter);
begin
  with PCurrentStep^ do
    if VarType(Vars^[In1Idx])<>VarType(Vars^[In2Idx])
      then Vars^[ResIdx] := False
      else Vars^[ResIdx] := Vars^[In1Idx] > Vars^[In2Idx];
end;

procedure TrsScripter.DoOperatorCmpGE(Scripter: TrsScripter);
begin
  with PCurrentStep^ do
    if VarType(Vars^[In1Idx])<>VarType(Vars^[In2Idx])
      then Vars^[ResIdx] := False
      else Vars^[ResIdx] := Vars^[In1Idx] >= Vars^[In2Idx];
end;

procedure TrsScripter.DoOperatorCmpL(Scripter: TrsScripter);
begin
  with PCurrentStep^ do
    if VarType(Vars^[In1Idx])<>VarType(Vars^[In2Idx])
      then Vars^[ResIdx] := False
      else Vars^[ResIdx] := Vars^[In1Idx] < Vars^[In2Idx];
end;

procedure TrsScripter.DoOperatorCmpLE(Scripter: TrsScripter);
begin
  with PCurrentStep^ do
    if VarType(Vars^[In1Idx])<>VarType(Vars^[In2Idx])
      then Vars^[ResIdx] := False
      else Vars^[ResIdx] := Vars^[In1Idx] <= Vars^[In2Idx];
end;

procedure TrsScripter.DoOperatorCmpNE(Scripter: TrsScripter);
begin
  with PCurrentStep^ do begin
    if VarType(Vars^[In1Idx])<>VarType(Vars^[In2Idx])
      then VarsConvertToSameType(In1Idx, In2Idx);

    if (IsString(Vars^[In1Idx])) and (not FCaseSensitivity) then begin
      Vars^[In1Idx] := UpperCase(Vars^[In1Idx]);
      Vars^[In2Idx] := UpperCase(Vars^[In2Idx]);
    end;
    Vars^[ResIdx] := Vars^[In1Idx] <> Vars^[In2Idx];
  end;
end;

procedure TrsScripter.DoOperatorDiv(Scripter: TrsScripter);
begin
  with PCurrentStep^ do
    Vars^[ResIdx] := Vars^[In1Idx] / Vars^[In2Idx];
end;

procedure TrsScripter.DoOperatorLike(Scripter: TrsScripter);
var
  s, m: string;
begin
  with PCurrentStep^ do
    if (IsString(Vars^[In1Idx])) and (IsString(Vars^[In2Idx]))
      then begin
        //vars1  - string; vars2 - template
        s := Vars^[In1Idx];
        m := Vars^[In2Idx];
        if not FCaseSensitivity then begin
          s := UpperCase(s);
          m := UpperCase(m);
        end;
        Vars^[ResIdx] := rsMatching(PChar(s), PChar(m));
      end else Vars^[ResIdx] := False;
end;

procedure TrsScripter.DoOperatorMul(Scripter: TrsScripter);
begin
  with PCurrentStep^ do
    Vars^[ResIdx] := Vars^[In1Idx] * Vars^[In2Idx];
end;

procedure TrsScripter.DoOperatorNOT(Scripter: TrsScripter);
begin
  with PCurrentStep^ do
    if (VarType(Vars^[In1Idx]) in [{$IFDEF RSL_D6GE}varShortInt, varWord, varLongWord, varInt64,{$ENDIF} varSmallint, varInteger, varBoolean, varByte])
      then Vars^[ResIdx] := not Vars^[In1Idx]
      else Vars^[ResIdx] := False;
end;

procedure TrsScripter.DoOperatorOR(Scripter: TrsScripter);
begin
  with PCurrentStep^ do
    if (VarType(Vars^[In1Idx]) in [{$IFDEF RSL_D6GE}varShortInt, varWord, varLongWord, varInt64,{$ENDIF} varSmallint, varInteger, varBoolean, varByte]) and
       (VarType(Vars^[In2Idx]) in [{$IFDEF RSL_D6GE}varShortInt, varWord, varLongWord, varInt64,{$ENDIF} varSmallint, varInteger, varBoolean, varByte])
      then Vars^[ResIdx] := Vars^[In1Idx] or Vars^[In2Idx]
      else Vars^[ResIdx] := False;
end;

procedure TrsScripter.DoOperatorSub(Scripter: TrsScripter);
begin
  with PCurrentStep^ do
    Vars^[ResIdx] := Vars^[In1Idx] - Vars^[In2Idx];
end;

procedure TrsScripter.DoOperatorXOR(Scripter: TrsScripter);
begin
  with PCurrentStep^ do
    if (VarType(Vars^[In1Idx]) in [{$IFDEF RSL_D6GE}varShortInt, varWord, varLongWord, varInt64,{$ENDIF} varSmallint, varInteger, varBoolean, varByte]) and
       (VarType(Vars^[In2Idx]) in [{$IFDEF RSL_D6GE}varShortInt, varWord, varLongWord, varInt64,{$ENDIF} varSmallint, varInteger, varBoolean, varByte])
      then Vars^[ResIdx] := Vars^[In1Idx] xor Vars^[In2Idx]
      else Vars^[ResIdx] := False;
end;

procedure TrsScripter.DoParameter(Scripter: TrsScripter);
var
  Param: TrsParam;
begin
  with PCurrentStep^ do begin
    if not Assigned(FSearch) then rsError(egSearch, 'No owner for Scripter object');
    param := FSearch.Params.ParamByName(Vars^[In1Idx]);
    Vars^[ResIdx] := Param.Value;
  end;
end;

procedure TrsScripter.DoSectionFullName(Scripter: TrsScripter);
begin
  with PCurrentStep^ do
    Vars^[ResIdx] := AnsiString(FSearch.KeyWrapper.SectionFullName);
end;

procedure TrsScripter.DoSectionLevel(Scripter: TrsScripter);
begin
  with PCurrentStep^ do
    Vars^[ResIdx] := FSearch.KeyWrapper.SectionLevel;
end;

procedure TrsScripter.DoSectionName(Scripter: TrsScripter);
begin
  with PCurrentStep^ do
    Vars^[ResIdx] := AnsiString(FSearch.KeyWrapper.SectionName);
end;

procedure TrsScripter.DoUpperCase(Scripter: TrsScripter);
begin
  with PCurrentStep^ do
    if IsString(Vars^[In1Idx])
      then Vars^[ResIdx] := UpperCase(Vars^[In1Idx])
      else Vars^[ResIdx] := Unassigned;
end;

function TrsScripter.FindOperator(LexIdx: integer): integer;
var
 i,BlockCount:integer;
begin
  Result:=-1;
  BlockCount:=0;
  for i:=LexIdx to Lexer.Count-1 do begin
    if (BlockCount=0) and
       (Lexer[i].LexType in [ltBracketClose]) then Exit;
    case Lexer[i].LexType of
     ltBracketOpen : begin Inc(BlockCount); continue; end;
     ltBracketClose: begin Dec(BlockCount); continue; end;
     ltOperatorCmpL,
     ltOperatorCmpLE,
     ltOperatorCmpG,
     ltOperatorCmpGE,
     ltOperatorCmpE,
     ltOperatorCmpNE,
     ltOperatorOR,
     ltOperatorAND,
     ltOperatorXOR,
     ltOperatorAdd,
     ltOperatorMul,
     ltOperatorSub,
     ltOperatorDiv,
     ltOperatorLike:
                   begin
                     if BlockCount=0 then begin
                       Result:=i;
                       Exit;
                     end;
                   end;
    end; // of case
  end; // of for
end;


function TrsScripter.IsString(const Value: variant): boolean;
begin
  Result := (VarType(Value)=varString)
{$ifdef RSL_BDS6}
            or (VarType(Value)=varUString)
{$endif}   ;
end;

procedure TrsScripter.LexemeSetCompiled(LexIdx, AVarIdx: integer);
begin
  with Lexer[LexIdx] do begin
    IsCompiled := True;
    VarIndex := AVarIdx;
  end;
end;

function TrsScripter.rsMatching(SearchString, Mask: PChar): boolean;
const
  rsWildChar = '?';
  rsWildString = '%';
var
  PS, PM: PChar;
begin
  PS := SearchString;
  PM := Mask;

  while (PS^<>#0) and (PM^<>#0) do begin
    if PM^ = rsWildChar then begin
      Inc(PM);
      Inc(PS);
    end else
    if PM^ = rsWildString then begin
      Inc(PM);
      while (not rsMatching(PS,PM)) and (PS^<>#0) do Inc(PS);
    end else
    if PM^=PS^ then begin
      Inc(PS);
      Inc(PM);
    end else begin
      Result := False;
      Exit;
    end;
  end;

  Result := ((PS^=#0) and (PM^=#0)) or ((PM^=rsWildString) and ((PM+1)^=#0));
end;

function TrsScripter.Run: Variant;
var
  CurrentStepIndex: integer;
  fun: TrsScriptStepFunc;
begin
  if not IsCompiled then Compile;
  CurrentStepIndex := 0;
  FCaseSensitivity := soCaseSensitivity in FSearch.Options;

  while CurrentStepIndex<StepsCount do begin
    PCurrentStep := @Steps^[CurrentStepIndex];

    fun := PCurrentStep^.Func;
    try
      if Assigned(fun)
        then fun(self);
    Except
      on Exception do Break;
    end;

    Inc(CurrentStepIndex);
  end;

  if (StepsCount>0) and (Steps^[StepsCount-1].ResIdx>=0) and
     (Steps^[StepsCount-1].ResIdx<VarsCount)
    then Result := Vars^[Steps^[StepsCount-1].ResIdx]
    else Result := False;
end;

procedure TrsScripter.SetScriptText(const Value: string);
begin
  FScriptText := Value;
  Compile;
end;

function TrsScripter.StepAdd(AFunc: TrsScriptStepFunc; ARes, AIn1, AIn2: integer): integer;
const
  CCapacityIncrement = 16;
var
  oldCapacity: integer;
begin
  if StepsCount >= StepsCapacity then begin
    oldCapacity := StepsCapacity;
    Inc(StepsCapacity, CCapacityIncrement);
    ReallocMem(Steps, StepsCapacity * SizeOf(TrsScriptStep));
    FillChar(Steps^[oldCapacity], CCapacityIncrement*SizeOf(TrsScriptStep), 0);
  end;

  with Steps^[StepsCount] do begin
    Func := AFunc;
    ResIdx := ARes;
    In1Idx := AIn1;
    In2Idx := AIn2;
  end;

  Result := StepsCount;
  Inc(StepsCount);
end;

function TrsScripter.VarAdd(AValue: Variant): integer;
const
  CCapacityIncrement = 16;
var
  oldCapacity: integer;
begin
  if VarsCount >= VarsCapacity then begin
    oldCapacity := VarsCapacity;
    Inc(VarsCapacity, CCapacityIncrement);
    ReallocMem(Vars, VarsCapacity * SizeOf(Variant));
    FillChar(Vars^[oldCapacity], CCapacityIncrement*SizeOf(Variant), 0);
  end;

  Vars^[VarsCount] := AValue;
  Result := VarsCount;
  Inc(VarsCount);
end;

function TrsScripter.VarsConvertToSameType(VarIdx1,VarIdx2: integer): boolean;
var
  vt1,vt2: TVarType;
begin
  Result := True;
  vt1 := VarType(Vars^[VarIdx1]);
  vt2 := VarType(Vars^[VarIdx2]);
  if vt1=vt2 then Exit;

  if IsString(Vars^[VarIdx1]) or IsString(Vars^[VarIdx2]) then begin
    if not IsString(Vars^[VarIdx1])
      then Vars^[VarIdx1] := VarAsType(Vars^[VarIdx1], varString)
      else
    if not IsString(Vars^[VarIdx2])
      then Vars^[VarIdx2] := VarAsType(Vars^[VarIdx2], varString);
  end;
end;

{ TrsParams }

function TrsParams.Add: TrsParam;
begin
  Result := TrsParam(inherited Add);
end;

constructor TrsParams.Create(AOwner: TrsSearch);
begin
  inherited Create(TrsParam);
  FOwner := AOwner;
end;

function TrsParams.FindParam(const Value: string): TrsParam;
var
  i: integer;
begin
  for i:=0 to Count-1 do begin
    Result := TrsParam(inherited Items[i]);
    if AnsiCompareText(Result.Name, Value) = 0 then Exit;
  end;
  Result := nil;
end;

function TrsParams.GetItem(Index: Integer): TrsParam;
begin
  Result := TrsParam(inherited GetItem(Index));
end;

function TrsParams.GetOwner: TPersistent;
begin
  Result := FOwner;
end;

function TrsParams.IndexOf(const Value: string): integer;
var
  i: integer;
begin
  for i:=0 to Count-1 do begin
    if AnsiCompareText(TrsParam(inherited Items[i]).Name, Value) = 0 then begin
      Result := i;
      Exit;
    end;
  end;
  Result := -1;
end;

function TrsParams.ParamByName(const Value: string): TrsParam;
begin
  Result := FindParam(Value);
  if Result = nil then rsError(egSearch, Format('No <%s> parameter',[Value]));
end;

procedure TrsParams.SetItem(Index: Integer; const Value: TrsParam);
begin
  inherited SetItem(Index, Value);
end;

{ TrsParam }

procedure TrsParam.Assign(Source: TPersistent);
begin
  if Source is TrsParam then begin
    FName := TrsParam(Source).FName;
    FValue := TrsParam(Source).FValue;
    Flags := TrsParam(Source).Flags;
  end else inherited Assign(Source);
end;

constructor TrsParam.Create(Collection: TCollection);
begin
  inherited;
  Flags := 0;
end;

destructor TrsParam.Destroy;
begin
  inherited;
end;

function TrsParam.GetAsVariant: Variant;
begin
  Result := FValue;
end;

function TrsParam.GetDisplayName: string;
begin
  if FName = ''
    then Result := inherited GetDisplayName
    else Result := FName;
end;

function TrsParam.IsValueStored: Boolean;
begin
  Result := Value<>Unassigned;
end;

procedure TrsParam.SetAsVariant(const Value: Variant);
begin
  FValue := Value;
end;

end.
