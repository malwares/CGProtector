////////////////////////////////////////////////////////////////////////////
// PaxCompiler
// Site: http://www.paxcompiler.com
// Author: Alexander Baranovsky (paxscript@gmail.com)
// ========================================================================
// Copyright (c) Alexander Baranovsky, 2006-2008. All rights reserved.
// Code Version: 2.4
// ========================================================================
// Unit: PAXCOMP_SYMBOL_REC.pas
// ========================================================================
////////////////////////////////////////////////////////////////////////////

{$I PaxCompiler.def}
unit PAXCOMP_SYMBOL_REC;
interface
uses
{$IFDEF VARIANTS}
  Variants,
{$ENDIF}
  SysUtils,
  Classes,
  PAXCOMP_CONSTANTS,
  PAXCOMP_SYS,
  PAXCOMP_VAROBJECT;

type
  TSymbolRec = class
  private
    s_table: Pointer;
    fTypeID: Integer;
    fShift: Integer;
    fUnionId: Integer;
    fValue: Variant;
    fKind: Integer;
    fRegister: Integer;
    fClassIndex: Integer;
    fAncestorId: Integer;
    fIsSharedMethod: Boolean;
    fPropIndex: Integer;
    fReadId: Integer;
    fWriteId: Integer;
    fIsDefault: Boolean;
    fVis: TClassVisibility;
    fCallMode: Byte;
    fIsConst: Boolean;
    fMustBeAllocated: Boolean;
    fPosition: Integer;
    fTypedConst: Boolean;
    fByRef: Boolean;
    fIsJavaScriptClass: Boolean;
    fIsFakeMethod: Boolean;
    fMethodIndex: Integer;
    fNegativeMethodIndex: Integer;
    fSupportedInterfaces: TGuidList;
    fDefaultAlignment: Byte;
    fOverCount: Byte;
    fVarCount: Int64;

    fFinSize: Integer;

    fSavedShift: Integer;
    fOverScript: Boolean;
    fIsOpenArray: Boolean;
    fPatternId: Integer;

    fIsExternal: Boolean;

    fName: String;
    procedure SetIsSharedMethod(value: Boolean);
    procedure SetKind(value: Integer);
    procedure SetTypeId(value: Integer);
    function GetNativeName: String;
    procedure SetName(const S: String);
    function GetName: String;
    function GetNameEx: String;
    function GetLocal: Boolean;
    function GetSize: Integer;
    function GetPtrSize: Integer;
    function GetFinalTypeId: Integer;
    function GetTerminalTypeId: Integer;
    function GetTerminalHostClassId: Integer;
    function GetShift: Integer;
    function GetFinalOwnerId: Integer;
    function GetInternalField: Boolean;
    function GetLocalInternalField: Boolean;
    procedure SetValue(const Value: Variant);
    function GetValueAsByteSet: TByteSet;
    procedure SetValueAsByteSet(const val: TByteSet);
    function GetSymbolRec(i_id: Integer): TSymbolRec;
    function GetSignatureSimple: String;
    function GetSignature: String;
    function GetSignatureEx: String;
    function GetSignatureBrief: String;
    function GetIsStatic: Boolean;
    function GetSizeOfScriptClassFields: Integer;
    function GetSizeOfHostClassFields: Integer;
    function GetSizeOfAllClassFields: Integer;
    function GetIsVirtual: Boolean;
    procedure SetByRef(value: Boolean);
    function GetFullName: String;
    function GetHeight: Integer;
    procedure SetTypedConst(value: Boolean);
    procedure SetPatternId(value: Integer);
    function GetIsPublished: Boolean;
    procedure SetIsPublished(value: Boolean);
    procedure SetIsOpenArray(value: Boolean);
  public
    Id: Integer;
    Host: Boolean;
    Param: Boolean;
    Optional: Boolean;
    Count: Integer;
    Completed: Boolean;
    Level: Integer;
    OwnerId: Integer;
    CallConv: Integer;
    IsForward: Boolean;
    PClass: TClass;
    Address: POinter;
    constructor Create(i_s_table: Pointer);
    destructor Destroy; override;
    function HasName: Boolean;
    function HasPAnsiCharType: Boolean;
    function HasPWideCharType: Boolean;
    function HasPVoidType: Boolean;
    function ExtraParamNeeded: Boolean;
    function IsSubrangeEnumType: Boolean;
    function HasSubrangeEnumType: Boolean;
    function HasByRefOwner: Boolean;
    function IsNestedSub: Boolean;
    function IsMethod: Boolean;
    function IsConstructor: Boolean;
    function IsDestructor: Boolean;
    function Inherits(T: Integer): Boolean;
    function IsGlobalVar: Boolean;
    function IsGlobalVarEx: Boolean;
    function IsLocalVarEx: Boolean;
    function IsGlobalConst: Boolean;
    function IsGlobalConstEx: Boolean;

    function IsGlobalSub: Boolean;
    function IsPacked: Boolean;
    procedure SetVariantValue(const Value: Variant);
    procedure SetUnionId(const Value: Integer);
    procedure Update;

    procedure SaveToStream(S: TWriter);
    procedure LoadFromStream(S: TReader);
    function IsSubPartOfEventType: Boolean;
    function GetNamespaceId: Integer;

    property Name: String read GetName write SetName;
    property FullName: String read GetFullName;
    property Kind: Integer read fKind write SetKind;
    property Local: Boolean read GetLocal;
    property Size: Integer read GetSize;
    property PtrSize: Integer read GetPtrSize;
    property FinalTypeId: Integer read GetFinalTypeId;
    property TerminalTypeId: Integer read GetTerminalTypeId;
    property TerminalHostClassId: Integer read GetTerminalHostClassId;
    property Shift: Integer read GetShift write fShift;
    property TypeID: Integer read fTypeID write SetTypeID;
    property FinalOwnerId: Integer read GetFinalOwnerId;
    property InternalField: Boolean read GetInternalField;
    property LocalInternalField: Boolean read GetLocalInternalField;
    property Value: Variant read fValue write SetValue;
    property UnionId: Integer read fUnionId write SetUnionId;
    property ValueAsByteSet: TByteSet read GetValueAsByteSet write SetValueAsByteSet;
    property SignatureSimple: String read GetSignatureSimple;
    property Signature: String read GetSignature;
    property SignatureEx: String read GetSignatureEx;
    property SignatureBrief: String read GetSignatureBrief;
    property IsStatic: Boolean read GetIsStatic;
    property Register: Integer read fRegister write fRegister;
    property ClassIndex: Integer read fClassIndex write fClassIndex;
    property AncestorId: Integer read fAncestorId write fAncestorId;
    property IsSharedMethod: Boolean read fIsSharedMethod write SetIsSharedMethod;
    property IsPublished: Boolean read GetIsPublished write SetIsPublished;
    property PropIndex: Integer read fPropIndex write fPropIndex;
    property ReadId: Integer read fReadId write fReadId;
    property WriteId: Integer read fWriteId write fWriteId;
    property IsDefault: Boolean read fIsDefault write fIsDefault;
    property Vis: TClassVisibility read fVis write fVis;
    property SizeOfScriptClassFields: Integer read GetSizeOfScriptClassFields;
    property SizeOfHostClassFields: Integer read GetSizeOfHostClassFields;
    property SizeOfAllClassFields: Integer read GetSizeOfAllClassFields;
    property CallMode: Byte read fCallMode write fCallMode;
    property IsVirtual: Boolean read GetIsVirtual;
    property IsConst: Boolean read fIsConst write fIsConst;
    property MustBeAllocated: Boolean read fMustBeallocated write fMustBeAllocated;
    property Position: Integer read fPosition write fPosition;
    property TypedConst: Boolean read fTypedConst write SetTypedConst;
    property ByRef: Boolean read fByRef write SetByRef;
    property IsJavaScriptClass: Boolean read fIsJavaScriptClass write fIsJavaScriptClass;
    property IsFakeMethod: Boolean read fIsFakeMethod write fIsFakeMethod;
    property MethodIndex: Integer read fMethodIndex write fMethodIndex;
    property NegativeMethodIndex: Integer read fNegativeMethodIndex write fNegativeMethodIndex;
    property SupportedInterfaces: TGuidList read fSupportedInterfaces
                                           write fSupportedInterfaces;
    property DefaultAlignment: Byte read fDefaultAlignment write fDefaultAlignment;
    property VarCount: Int64 read fVarCount write fVarCount;
    property OverCount: Byte read fOverCount write fOverCount;
    property FinSize: Integer read fFinSize write fFinSize;

    property SavedShift: Integer read fSavedShift write fSavedShift;
    property OverScript: Boolean read fOverScript write fOverScript;

    property NativeName: String read GetNativeName;
    property IsOpenArray: Boolean read fIsOpenArray write SetIsOpenArray;
    property Height: Integer read GetHeight;
    property NameEx: String read GetNameEx;
    property PatternId: Integer read fPatternId write SetPatternId;
    property IsExternal: Boolean read fIsExternal write fIsExternal;
  end;

implementation

uses
  PAXCOMP_BASESYMBOL_TABLE, PAXCOMP_STDLIB;

constructor TSymbolRec.Create(i_s_table: Pointer);
begin
  inherited Create;

  Self.s_table := i_s_table;
  TypeID := 0;
  Completed := false;
  Shift := 0;
  Host := false;
  Param := false;
  fByRef := false;
  Optional := false;
  Level := 0;
  CallConv := 0;
  Count := 0;
  PatternId := 0;
  OwnerId := 0;
  fUnionId := 0;
  IsForward := false;
  fKind := KindNONE;
  fRegister := 0;
  fClassIndex := -1;
  fIsSharedMethod := false;
  fAncestorId := 0;
  PClass := nil;
  fPropIndex := -1;
  fReadId := 0;
  fWriteId := 0;
  fIsDefault := false;
  fVis := cvNone;
  fName := '';
  fCallMode := 0;
  fIsConst := false;
  fMustBeAllocated := false;
  fPosition := 0;
  fTypedConst := false;
  fIsJavaScriptClass := false;
  fIsFakeMethod := false;
  fMethodIndex := 0;
  fNegativeMethodIndex := 0;
  fSupportedInterfaces := nil;
  fDefaultAlignment := 0;
  fVarCount := 0;
  fFinSize := -1;
  fOverScript := false;
  fIsOpenArray := false;
end;

destructor TSymbolRec.Destroy;
begin
  if Assigned(fSupportedInterfaces) then
    fSupportedInterfaces.Free;

  inherited;
end;

procedure TSymbolRec.SetName(const S: String);
begin
  if fName <> '' then
    TBaseSymbolTable(s_table).HashArray.DeleteName(fName, Id);

  fName := S;
  if S <> '' then
    TBaseSymbolTable(s_table).HashArray.AddName(S, Id);
end;

function TSymbolRec.GetName: String;
begin
  result := fName;
end;

function TSymbolRec.GetNativeName: String;
begin
  if (Id >= 0) and (Id < Types.Count) then
    result := Types[Id].NativeName
  else
    result := fName;
end;

function TSymbolRec.GetShift: Integer;
begin
  result := fShift;
end;

function TSymbolRec.GetSize: Integer;
var
  I, T, TRange, TElem, B1, B2, PrevShift,
  CurrAlign, DefAlign, MaxAlign, J1, FT, FT1, VJ, VS, VK, VSize, MaxVSize: Integer;
  SymbolTable: TBaseSymbolTable;
  VarPathList: TVarPathList;
  Path: TVarPath;
  RI: TSymbolRec;
begin
  if fFinSize > 0 then
  begin
    result := fFinSize;
    Exit;
  end;

  SymbolTable := TBaseSymbolTable(s_table);
  result := 0;
  case Kind of
    KindSUB:
      result := SizeOf(Pointer);
    KindLABEL:
      result := SizeOf(Pointer);
    else
    begin

      if Kind = kindTYPE then
      begin
        T := Id;
        if TypeId = typeALIAS then
          T := TerminalTypeId;
      end
      else
        T := TerminalTypeId;

      if (Kind = KindVAR) and ByRef then
      begin
        result := SizeOf(Pointer);
        fFinSize := result;
        Exit;
      end;

      if T < Types.Count then
        result := Types.GetSize(T)
      else
      begin
{
        if (T = typePCHAR) and (Kind = KindCONST) then
        begin
          result := Length(Value) + 1;
        end
        else
}
        if SymbolTable[T].Completed then
        begin
          result := 0;
          case FinalTypeId of
            typeSHORTSTRING:
            begin
              result := SymbolTable[T].Count + 1;
            end;
            typeSET:
            begin
              result := SymbolTable.GetSizeOfSetType(T);
            end;
            typeRECORD:
            begin

              VarPathList := TVarPathList.Create;
              try

                for I:=T + 1 to SymbolTable.Card do
                begin
                  RI := SymbolTable[I];
                  if RI = SR0 then
                    break;

                  if RI.Kind = KindSUB then
                    if RI.Level <> T then
                      break;

                  if (RI.Kind = KindTYPE_FIELD) and (RI.Level = T) then
                    if RI.VarCount > 0 then
                      VarPathList.Add(I, RI.VarCount);
                end;

                PrevShift := -1;

                if SymbolTable[T].IsPacked then
                begin
                  if VarPathList.Count = 0 then
                  begin
                    for I:=T + 1 to SymbolTable.Card do
                    begin
                      RI := SymbolTable[I];
                      if RI = SR0 then
                        break;

                      if RI.Kind = KindSUB then
                        if RI.Level <> T then
                          break;

                      if (RI.Kind = KindTYPE_FIELD) and
                         (RI.Level = T) then
                         begin
                           if RI.Shift > PrevShift then
                           begin
                             PrevShift := RI.Shift;
                             Inc(result, RI.Size);
                           end;
                         end;
                    end;
                  end
                  else // packed record with variant part
                  begin
                    for I:=T + 1 to SymbolTable.Card do
                    begin
                      RI := SymbolTable[I];
                      if RI = SR0 then
                        break;

                      if RI.Kind = KindSUB then
                        if RI.Level <> T then
                          break;

                      if (RI.Kind = KindTYPE_FIELD) and
                         (RI.Level = T) then
                         begin

                           if RI.VarCount > 0 then
                             break;

                           if RI.Shift > PrevShift then
                           begin
                             PrevShift := RI.Shift;
                             Inc(result, RI.Size);
                           end;
                         end;
                    end;

                    MaxVSize := 0;
                    VS := PrevShift;

                    for VK :=0 to VarPathList.Count - 1 do
                    begin
                      Path := VarPathList[VK];

                      PrevShift := VS;
                      VSize := result;

                      for VJ := 0 to Path.Count - 1 do
                      begin
                        I := Path[VJ].Id;
                        if SymbolTable[I].Shift > PrevShift then
                        begin
                          PrevShift := SymbolTable[I].Shift;
                          Inc(VSize, SymbolTable[I].Size);
                        end;
                      end;

                      if VSize > MaxVSize then
                        MaxVSize := VSize;
                    end;

                    result := MaxVSize;
                  end;

                end
                else  // not packed record
                begin
                  DefAlign := SymbolTable[T].DefaultAlignment;
                  MaxAlign := 0;
                  J1 := -1;

                  if VarPathList.Count = 0 then
                  begin

                    for I:=T + 1 to SymbolTable.Card do
                    begin

                      RI := SymbolTable[I];
                      if RI = SR0 then
                        break;

                      if RI.Kind = KindSUB then
                        if RI.Level <> T then
                          break;

                      if (RI.Kind = KindTYPE_FIELD) and
                         (RI.Level = T) then
                         begin
                           if RI.Shift > PrevShift then
                           begin
                             PrevShift := RI.Shift;

                             CurrAlign := SymbolTable.GetAlignmentSize(
                               RI.TypeId, DefAlign);

                             if J1 > 0 then
                             begin
                               FT1 := SymbolTable[I-1].FinalTypeId;
                               FT := RI.FinalTypeId;
                               if FT = FT1 then
                               begin
                                 CurrAlign := 1;
                                 J1 := -1;
                               end
                               else
                                 J1 := I;
                             end
                             else
                               J1 := I;

                             if CurrAlign > MaxAlign then
                               MaxAlign := CurrAlign;

                             if CurrAlign > 1 then
                             begin
                               while result mod CurrAlign <> 0 do
                                 Inc(result);
                             end;

                             Inc(result, RI.Size);
                           end;
                         end;
                    end;
                  end
                  else // unpacked record with variant part
                  begin
                    for I:=T + 1 to SymbolTable.Card do
                    begin
                      RI := SymbolTable[I];
                      if RI = SR0 then
                        break;

                      if RI.Kind = KindSUB then
                        if RI.Level <> T then
                          break;

                      if (RI.Kind = KindTYPE_FIELD) and
                         (RI.Level = T) then
                         begin

                           if RI.VarCount > 0 then
                             break;

                           if RI.Shift > PrevShift then
                           begin
                             PrevShift := RI.Shift;

                             CurrAlign := SymbolTable.GetAlignmentSize(
                               RI.TypeId, DefAlign);

                             if J1 > 0 then
                             begin
                               FT1 := SymbolTable[I-1].FinalTypeId;
                               FT := RI.FinalTypeId;
                               if FT = FT1 then
                               begin
                                 CurrAlign := 1;
                                 J1 := -1;
                               end
                               else
                                 J1 := I;
                             end
                             else
                               J1 := I;

                             if CurrAlign > MaxAlign then
                               MaxAlign := CurrAlign;


                             if CurrAlign > 1 then
                             begin
                               while result mod CurrAlign <> 0 do
                                 Inc(result);
                             end;

                             Inc(result, RI.Size);
                           end;
                         end;
                    end;

                    // process variant part of record
                    MaxVSize := 0;
                    VS := PrevShift;

                    for VK :=0 to VarPathList.Count - 1 do
                    begin
                      Path := VarPathList[VK];

                      PrevShift := VS;
                      VSize := result;

                      for VJ := 0 to Path.Count - 1 do
                      begin
                         I := Path[VJ].Id;

                         RI := SymbolTable[I];
                         if RI.Shift > PrevShift then
                         begin
                           PrevShift := RI.Shift;

                           CurrAlign := SymbolTable.GetAlignmentSize(
                             RI.TypeId, DefAlign);

                           if J1 > 0 then
                           begin
                             FT1 := SymbolTable[I-1].FinalTypeId;
                             FT := RI.FinalTypeId;
                             if FT = FT1 then
                             begin
                               CurrAlign := 1;
                               J1 := -1;
                             end
                             else
                               J1 := I;
                           end
                           else
                             J1 := I;

                           if CurrAlign > MaxAlign then
                             MaxAlign := CurrAlign;

                           if CurrAlign > 1 then
                           begin
                             while VSize mod CurrAlign <> 0 do
                               Inc(VSize);
                           end;

                           Inc(VSize, RI.Size);
                         end;
                      end;

                      if VSize > MaxVSize then
                        MaxVSize := VSize;
                    end;
                    result := MaxVSize;
                  end;

                  if MaxAlign > 1 then
                  begin
                    while result mod MaxAlign <> 0 do
                      Inc(result);
                  end;

                end;

              finally
                VarPathList.Free;
              end;

            end;
            typeARRAY:
            begin
              SymbolTable.GetArrayTypeInfo(T, TRange, TElem);

              if SymbolTable[TRange].Completed and SymbolTable[TElem].Completed then
              begin
                B1 := SymbolTable.GetLowBoundRec(TRange).Value;
                B2 := SymbolTable.GetHighBoundRec(TRange).Value;

                result := SymbolTable[TElem].Size * (B2 - B1 + 1);
              end;
            end;
            else
            begin
              if FinalTypeId < Types.Count then
                result := Types.GetSize(FinalTypeId)
              else
                TBaseSymbolTable(s_table).RaiseError(errInternalError, []);
            end;
          end;
        end
        else
        begin
        end;
      end;
    end;
  end;

  fFinSize := result;
  
  if fFinSize = 0 then
    fFinSize := -1;
end;

function TSymbolRec.GetPtrSize: Integer;
var
  temp1, temp2: Boolean;
  temp3: Integer;
begin
  temp1 := ByRef;
  temp2 := Host;

  ByRef := false;
  Host := false;

  temp3 := fFinSize;
  fFinSize := -1;
  result := GetSize;
  fFinSize := temp3;

  if result = 0 then
    result := 4;

  ByRef := temp1;
  Host := temp2;
end;

function TSymbolRec.GetFinalTypeId: Integer;
var
  T: Integer;
begin
  if Kind = KindTYPE then
  begin
    if id < Types.Count then
    begin
      result := Id;
      Exit;
    end;

    T := TerminalTypeId;
    if T < Types.Count then
      result := T
    else
    begin
      T := TBaseSymbolTable(s_table)[T].TypeID;
      result := TBaseSymbolTable(s_table)[T].FinalTypeId;
    end;
  end
  else
  begin
    if TypeId = 0 then
    begin
      result := 0;
      Exit;
    end;

    result := TBaseSymbolTable(s_table)[TypeId].FinalTypeId;
  end;
end;

function TSymbolRec.GetTerminalTypeId: Integer;
var
  SymbolTable: TBaseSymbolTable;
begin
  SymbolTable := TBaseSymbolTable(s_table);
  if Kind = KindTYPE then
  begin
    result := Id;
    if TypeId = typeALIAS then
      while SymbolTable[result].TypeId = typeALIAS do
        result := SymbolTable[result].PatternId;
  end
  else
    result := SymbolTable[TypeId].TerminalTypeId;
end;

function TSymbolRec.GetTerminalHostClassId: Integer;
var
  SymbolTable: TBaseSymbolTable;
begin
  if FinalTypeId <> typeCLASS then
    raise Exception.Create(errInternalError);

  SymbolTable := TBaseSymbolTable(s_table);
  if Kind = KindTYPE then
  begin
    result := TerminalTypeId;
    if Host then Exit;

    if AncestorId = 0 then
      raise Exception.Create(errInternalError);

    result := SymbolTable[AncestorId].GetTerminalHostClassId;
  end
  else
    result := SymbolTable[TypeId].TerminalHostClassId;
end;


function TSymbolRec.GetFinalOwnerId: Integer;
begin
  result := OwnerId;
  if result = 0 then
    Exit;

  if TBaseSymbolTable(s_table)[result].OwnerId = 0 then
    Exit;

  result := TBaseSymbolTable(s_table)[result].FinalOwnerId;
end;

function TSymbolRec.HasByRefOwner: Boolean;
begin
  result := false;

  if OwnerId = 0 then
    Exit;

  if TBaseSymbolTable(s_table)[OwnerId].ByRef then
  begin
    result := true;
    Exit;
  end;

  result := TBaseSymbolTable(s_table)[OwnerId].HasByRefOwner;
end;

function TSymbolRec.GetLocal: Boolean;
begin
  if OverScript then
  begin
    result := false;
    Exit;
  end;  

  if Param and (Register > 0) then
  begin
    result := true;
    Exit;
  end;

  result := (not Host) and (not TypedConst) and
            (TBaseSymbolTable(s_table)[Level].Kind in KindSubs) and
            (Kind = KindVAR) and (not Param) and (not InternalField);
end;

function TSymbolRec.GetInternalField: Boolean;
begin
  result := (Kind = KindVAR) and (OwnerId <> 0) and (not ByRef);

  if result then
    result := TBaseSymbolTable(s_table)[OwnerId].Kind in [KindVAR, kindNONE];
end;

function TSymbolRec.GetLocalInternalField: Boolean;
begin
  result := GetInternalField;

  if result then
    result := TBaseSymbolTable(s_table)[OwnerId].Local
              or
              TBaseSymbolTable(s_table)[OwnerId].Param;
end;

procedure TSymbolRec.SetValue(const Value: Variant);
begin
  if VarType(Value) = varBoolean then
    fValue := Abs(Integer(Value))
  else
    fValue := Value;
end;

procedure TSymbolRec.SetVariantValue(const Value: Variant);
begin
  fValue := Value;
end;

procedure TSymbolRec.SetUnionId(const Value: Integer);
begin
  fUnionId := Value;
end;

function TSymbolRec.GetValueAsByteSet: TByteSet;
begin
  if GetSymbolRec(TypeId).PatternId = typeVOID then
    result := []
  else if VarType(Value) = varObject then
    result := VariantToSetObject(Value).Value
  else
    result := [];
end;

procedure TSymbolRec.SetValueAsByteSet(const val: TByteSet);
var
  SetObject: TSetObject;
begin
  if not IsVarObject(Value) then
  begin
    SetObject := TSetObject.Create(s_table, val, TypeId, typeBYTE);
    Value := VarObjectToVariant(SetObject);
  end
  else
    VariantToSetObject(Value).Value := val;
end;

function TSymbolRec.GetSymbolRec(i_id: Integer): TSymbolRec;
begin
  result := TBaseSymbolTable(s_table)[i_id];
end;

function TSymbolRec.HasName: Boolean;
begin
  result := Name <> '';
end;

function TSymbolRec.HasPAnsiCharType: Boolean;
var
  T: Integer;
begin
  result := TypeId = typePANSICHAR;
  if result then
    Exit;

  result := FinalTypeId = typePOINTER;
  if result then
  begin
    T := TBaseSymbolTable(s_table)[Id].TerminalTypeId;
    result := TBaseSymbolTable(s_table)[T].PatternId = typeANSICHAR;
  end;
end;

function TSymbolRec.HasPWideCharType: Boolean;
var
  T: Integer;
begin
  result := TypeId = typePWIDECHAR;
  if result then
    Exit;

  result := FinalTypeId = typePOINTER;
  if result then
  begin
    T := TBaseSymbolTable(s_table)[Id].TerminalTypeId;
    result := TBaseSymbolTable(s_table)[T].PatternId = typeWIDECHAR;
  end;
end;

function TSymbolRec.HasPVoidType: Boolean;
begin
  result := TerminalTypeId = typePVOID;
end;

function TSymbolRec.ExtraParamNeeded: Boolean;
var
  T: Integer;
begin
  T := FinalTypeId;

  if CallConv = ccMSFASTCALL then
  if T = typeRECORD then
  if GetSymbolRec(TypeId).Size <= 8 then
  begin
    result := false;
    Exit;
  end;

{$IFDEF FPC}
  result := T in [typeSHORTSTRING, typeWIDESTRING, typeUNICSTRING, typeRECORD,
    typeEVENT,
    typeARRAY, typeDYNARRAY, typeSET, typeVARIANT, typeOLEVARIANT, typeINTERFACE];
{$ELSE}
  result := T in [typeANSISTRING, typeWIDESTRING, typeUNICSTRING, typeSHORTSTRING, typeRECORD,
    typeEVENT,
    typeARRAY, typeDYNARRAY, typeSET, typeVARIANT, typeOLEVARIANT, typeINTERFACE];
{$ENDIF}

end;

function TSymbolRec.GetSignatureSimple: String;
var
  I, ParamId, T: Integer;
  SymbolTable: TBaseSymbolTable;
  S: String;
begin
  result := '';
  if Kind <> KindSUB then
    Exit;

  SymbolTable := TBaseSymbolTable(s_table);

  result := '(';

  for I:=0 to Count - 1 do
  begin
    ParamId := SymbolTable.GetParamId(Id, I);
    T := SymbolTable[ParamId].TypeID;

    S := '';
    if SymbolTable[ParamId].ByRef then
      S := 'Var'
    else if SymbolTable[ParamId].IsConst then
      S := 'Const';

    result := result + S + ' ' + SymbolTable[T].Name;

    if I < Count - 1 then
      result := result + ';';
  end;

  result := result + ')';
end;

function TSymbolRec.GetSignature: String;
var
  I, ParamId, T: Integer;
  SymbolTable: TBaseSymbolTable;
  S: String;
begin
  result := '';
  if Kind <> KindSUB then
    Exit;

  SymbolTable := TBaseSymbolTable(s_table);

  result := '(';

  for I:=0 to Count - 1 do
  begin
    ParamId := SymbolTable.GetParamId(Id, I);
    T := SymbolTable[ParamId].TypeID;

    S := '';
    if SymbolTable[ParamId].ByRef then
      S := 'Var'
    else if SymbolTable[ParamId].IsConst then
      S := 'Const';

    result := result + S + ' ' +
      SymbolTable[ParamId].Name + ':' + SymbolTable[T].Name;

    if I < Count - 1 then
      result := result + ';';
  end;

  result := result + ')';
end;

function TSymbolRec.GetSignatureEx: String;
begin
  result := GetSignature;
  if result = '' then
    Exit;

  if GetSymbolRec(Id + 1).Name = '' then
    result := 'procedure' + result
  else
  begin
    result := 'function' + result;
    result := result + ':' + TBaseSymbolTable(s_table)[TypeId].Name;
  end;
end;

function TSymbolRec.GetSignatureBrief: String;
var
  I, ParamId, T: Integer;
  SymbolTable: TBaseSymbolTable;
begin
  result := '';
  if Kind <> KindSUB then
    Exit;

  SymbolTable := TBaseSymbolTable(s_table);

  result := '(';

  for I:=0 to Count - 1 do
  begin
    ParamId := SymbolTable.GetParamId(Id, I);
    T := SymbolTable[ParamId].TypeID;

    result := result + ', ' + SymbolTable[T].Name;

    if I < Count - 1 then
      result := result + ';';
  end;

  result := result + ')';
end;

function TSymbolRec.GetIsStatic: Boolean;
begin
  result := (Level = 0) or
            (TBaseSymbolTable(s_table)[Level].Kind = KindNAMESPACE);
end;

procedure TSymbolRec.SetKind(value: Integer);
begin
  fKind := value;
end;

procedure TSymbolRec.SetTypeID(value: Integer);
begin
  fTypeID := value;
end;

function TSymbolRec.IsSubrangeEnumType: Boolean;
begin
  result := (Kind = KindTYPE) and (FinalTypeID = typeENUM) and (PatternID = 0);
end;

function TSymbolRec.HasSubrangeEnumType: Boolean;
begin
  result := TBaseSymbolTable(s_table)[TypeId].IsSubrangeEnumType;
end;

function TSymbolRec.IsNestedSub: Boolean;
begin
  result := (Kind = KindSUB) and
            (Level > 0) and
            (TBaseSymbolTable(s_table)[Level].Kind in KindSubs);
end;

function TSymbolRec.IsMethod: Boolean;
begin
  result := (Kind = KindSUB) and (Level > 0) and (TBaseSymbolTable(s_table)[Level].Kind = KindTYPE);
end;

function TSymbolRec.IsConstructor: Boolean;
begin
  result := (Kind = KindCONSTRUCTOR);
end;

function TSymbolRec.IsDestructor: Boolean;
begin
  result := (Kind = KindDESTRUCTOR);
end;

function TSymbolRec.Inherits(T: Integer): Boolean;
var
  S: TSymbolRec;
begin
  result := false;

  if s_table = GlobalSymbolTable then
    if T > GlobalSymbolTable.Card then
      Exit;

  S := TBaseSymbolTable(s_table)[T];
  S := TBaseSymbolTable(s_table)[S.TerminalTypeId];

  if Kind <> kindTYPE then
    TBaseSymbolTable(s_table).RaiseError(errInternalError, []);
  if FinalTypeId <> typeCLASS then
    TBaseSymbolTable(s_table).RaiseError(errInternalError, []);

{
  if (PClass <> nil) and (S.PClass <> nil) then
  if Host and S.Host then
  begin
    result := PClass.InheritsFrom(S.PClass);
    Exit;
  end;
}  

  if AncestorId > 0 then
  begin
    result := AncestorId = S.Id;
    if not result then
    begin
      S := TBaseSymbolTable(s_table)[AncestorId];
      S := TBaseSymbolTable(s_table)[S.TerminalTypeId];
      result := S.Inherits(T);
    end;
  end;
end;

function TSymbolRec.IsGlobalConst: Boolean;
begin
  if Kind <> KindCONST then
  begin
    result := false;
    Exit;
  end;
  if Level = 0 then
  begin
    result := true;
    Exit;
  end;
  result := GetSymbolRec(Level).Kind = kindNAMESPACE;
end;

function TSymbolRec.IsGlobalConstEx: Boolean;
begin
  result := IsGlobalConst and
            (OwnerId = 0) and (Name <> '') and (Name <> '@');
end;

function TSymbolRec.IsGlobalVar: Boolean;
begin
  if Kind <> KindVAR then
  begin
    result := false;
    Exit;
  end;
  if Level = 0 then
  begin
    result := true;
    Exit;
  end;
  result := GetSymbolRec(Level).Kind = kindNAMESPACE;
end;

function TSymbolRec.IsGlobalVarEx: Boolean;
begin
  result := IsGlobalVar and
            (OwnerId = 0) and (Name <> '') and (Name <> '@');
end;

function TSymbolRec.IsLocalVarEx: Boolean;
begin
  result := false;
  if Kind = KindVAR then
    if OwnerId = 0 then
      if PatternId = 0 then
         if Local then
            if Name <> '' then
              if Name <> '@' then
                result := true;
end;

function TSymbolRec.IsGlobalSub: Boolean;
begin
  if Kind <> KindSUB then
  begin
    result := false;
    Exit;
  end;
  if Level = 0 then
  begin
    result := true;
    Exit;
  end;
  result := GetSymbolRec(Level).Kind = kindNAMESPACE;
end;

function TSymbolRec.GetSizeOfScriptClassFields: Integer;

function _Size: Integer;
var
  I, T, TRange, TElem, B1, B2, PrevShift: Integer;
  SymbolTable: TBaseSymbolTable;
begin
  SymbolTable := TBaseSymbolTable(s_table);
  result := 0;
  case Kind of
    KindSUB:
      result := SizeOf(Pointer);
    KindLABEL:
      result := SizeOf(Pointer);
    else
    begin

      if Kind = kindTYPE then
      begin
        T := Id;
        if TypeId = typeALIAS then
          T := TerminalTypeId;
      end
      else
        T := TerminalTypeId;

      if (Kind = KindVAR) and ByRef then
      begin
        result := SizeOf(Pointer);
        Exit;
      end;

      if T < Types.Count then
        result := Types.GetSize(T)
      else
      begin
        if SymbolTable[T].Completed then
        begin
          result := 0;
          case FinalTypeId of
            typeSHORTSTRING:
            begin
              result := SymbolTable[T].Count + 1;
            end;
            typeRECORD, typeCLASS:
            begin
              PrevShift := -1;

              for I:=T + 1 to SymbolTable.Card do
                if (SymbolTable[I].Kind = KindTYPE_FIELD) and
                   (SymbolTable[I].Level = T) then
                   begin
                     if SymbolTable[I].Shift > PrevShift then
                     begin
                       PrevShift := SymbolTable[I].Shift;
                       Inc(result, SymbolTable[I].Size);
                     end;
                   end;
            end;
            typeARRAY:
            begin
              SymbolTable.GetArrayTypeInfo(T, TRange, TElem);

              if SymbolTable[TRange].Completed and SymbolTable[TElem].Completed then
              begin
                B1 := SymbolTable.GetLowBoundRec(TRange).Value;
                B2 := SymbolTable.GetHighBoundRec(TRange).Value;

                result := SymbolTable[TElem].Size * (B2 - B1 + 1);
              end;
            end;
            else
            begin
              if FinalTypeId < Types.Count then
                result := Types.GetSize(FinalTypeId)
              else
                TBaseSymbolTable(s_table).RaiseError(errInternalError, []);
            end;
          end;
        end
        else
        begin
        end;
      end;
    end;
  end;
end;


//var
//  temp: Integer;
begin
  if Kind <> KindTYPE then
    TBaseSymbolTable(s_table).RaiseError(errInternalError, []);
  if FinalTypeId <> typeCLASS then
    TBaseSymbolTable(s_table).RaiseError(errInternalError, []);
  if Host then
  begin
    result := 0;
    Exit; 
  end;

  result := _Size;

  if AncestorId = 0 then
    Exit;

  if GetSymbolRec(AncestorId).Host then
    Exit;

  Inc(result, GetSymbolRec(AncestorId).GetSizeOfScriptClassFields);
end;

function TSymbolRec.GetSizeOfHostClassFields: Integer;
begin
  if Kind <> KindTYPE then
    TBaseSymbolTable(s_table).RaiseError(errInternalError, []);
  if FinalTypeId <> typeCLASS then
    TBaseSymbolTable(s_table).RaiseError(errInternalError, []);
  if Host then
  begin
    if PClass = nil then
      PClass := GetClass(Name);
    if PClass = nil then
      result := 0
    else
      result := PClass.InstanceSize;
  end
  else
    result := GetSymbolRec(AncestorId).GetSizeOfHostClassFields;
end;

function TSymbolRec.GetSizeOfAllClassFields: Integer;
begin
  result := GetSizeOfHostClassFields + GetSizeOfScriptClassFields;
end;

procedure TSymbolRec.SetIsSharedMethod(value: Boolean);
begin
  fIsSharedMethod := value;
end;

function TSymbolRec.GetIsVirtual: Boolean;
begin
  result := CallMode <> cmNONE;
end;

procedure TSymbolRec.SetByRef(value: Boolean);
begin
  fByRef := value;
end;

{
function TSymbolRec.GetFullName: String;
begin
  if Level = 0 then
    result := Name
  else
    result := TBaseSymbolTable(s_table)[Level].GetFullName + '.' + Name;
end;
}

function TSymbolRec.GetFullName: String;
var
  L: Integer;
begin
  result := Name;
  L := Level;
  while L <> 0 do
  with TBaseSymbolTable(s_table)[L] do
  begin
    result := Name + '.' + result;
    L := Level;
  end;
end;

function TSymbolRec.IsPacked: Boolean;
begin
  result := fDefaultAlignment <= 1;
end;

procedure TSymbolRec.SaveToStream(S: TWriter);
var
  K: Integer;
begin
  S.Write(fFinSize, SizeOf(Integer));
  S.Write(fTypeID, SizeOf(fTypeId));
  S.Write(fShift, SizeOf(fShift));
  S.Write(fUnionId, SizeOf(fUnionId));
  S.Write(fKind, SizeOf(fKind));
  S.Write(fRegister, SizeOf(fRegister));
  S.Write(fClassIndex, SizeOf(fClassIndex));
  S.Write(fAncestorId, SizeOf(fAncestorId));
  S.Write(fIsSharedMethod, SizeOf(fIsSharedMethod));
  S.Write(fPropIndex, SizeOf(fPropIndex));
  S.Write(fReadId, SizeOf(fReadId));
  S.Write(fWriteId, SizeOf(fWriteId));
  S.Write(fIsDefault, SizeOf(fIsDefault));
  S.Write(fVis, SizeOf(fVis));
  S.Write(fCallMode, SizeOf(fCallMode));
  S.Write(fIsConst, SizeOf(fIsConst));
  S.Write(fMustBeAllocated, SizeOf(fMustBeAllocated));
  S.Write(fPosition, SizeOf(fPosition));
  S.Write(fTypedConst, SizeOf(fTypedConst));
  S.Write(fByRef, SizeOf(fByRef));
  S.Write(fIsJavaScriptClass, SizeOf(fIsJavaScriptClass));
  S.Write(fIsFakeMethod, SizeOf(fIsFakeMethod));
  S.Write(fMethodIndex, SizeOf(fMethodIndex));
  S.Write(fNegativeMethodIndex, SizeOf(fNegativeMethodIndex));
  S.Write(fDefaultAlignment, SizeOf(fDefaultAlignment));
  S.Write(fVarCount, SizeOf(fVarCount));
  S.Write(Id, SizeOf(Id));
  S.Write(Host, SizeOf(Host));
  S.Write(Param, SizeOf(Param));
  S.Write(Optional, SizeOf(Optional));
  S.Write(Count, SizeOf(Count));
  S.Write(Completed, SizeOf(Completed));
  S.Write(Level, SizeOf(Level));
  S.Write(OwnerId, SizeOf(OwnerId));
  S.Write(CallConv, SizeOf(CallConv));
  S.Write(fPatternId, SizeOf(PatternId));
  S.Write(IsForward, SizeOf(IsForward));
  S.Write(fOverCount, SizeOf(fOverCount));
  S.Write(fIsOpenArray, SizeOf(fIsOpenArray));
  S.Write(fIsExternal, SizeOf(fIsExternal));
  S.WriteString(fName);

  if fSupportedInterfaces = nil then
  begin
    K := -1;
    S.Write(K, SizeOf(K));
  end
  else
  begin
    K := fSupportedInterfaces.Count;
    S.Write(K, SizeOf(K));
    fSupportedInterfaces.SaveToStream(S);
  end;

  SaveVariantToStream(fValue, S);
end;

procedure TSymbolRec.LoadFromStream(S: TReader);
var
  K: Integer;
begin
  S.Read(fFinSize, SizeOf(Integer));
  S.Read(fTypeID, SizeOf(fTypeId));
  S.Read(fShift, SizeOf(fShift));
  S.Read(fUnionId, SizeOf(fUnionId));
  S.Read(fKind, SizeOf(fKind));
  S.Read(fRegister, SizeOf(fRegister));
  S.Read(fClassIndex, SizeOf(fClassIndex));
  S.Read(fAncestorId, SizeOf(fAncestorId));
  S.Read(fIsSharedMethod, SizeOf(fIsSharedMethod));
  S.Read(fPropIndex, SizeOf(fPropIndex));
  S.Read(fReadId, SizeOf(fReadId));
  S.Read(fWriteId, SizeOf(fWriteId));
  S.Read(fIsDefault, SizeOf(fIsDefault));
  S.Read(fVis, SizeOf(fVis));
  S.Read(fCallMode, SizeOf(fCallMode));
  S.Read(fIsConst, SizeOf(fIsConst));
  S.Read(fMustBeAllocated, SizeOf(fMustBeAllocated));
  S.Read(fPosition, SizeOf(fPosition));
  S.Read(fTypedConst, SizeOf(fTypedConst));
  S.Read(fByRef, SizeOf(fByRef));
  S.Read(fIsJavaScriptClass, SizeOf(fIsJavaScriptClass));
  S.Read(fIsFakeMethod, SizeOf(fIsFakeMethod));
  S.Read(fMethodIndex, SizeOf(fMethodIndex));
  S.Read(fNegativeMethodIndex, SizeOf(fNegativeMethodIndex));
  S.Read(fDefaultAlignment, SizeOf(fDefaultAlignment));
  S.Read(fVarCount, SizeOf(fVarCount));
  S.Read(Id, SizeOf(Id));
  S.Read(Host, SizeOf(Host));
  S.Read(Param, SizeOf(Param));
  S.Read(Optional, SizeOf(Optional));
  S.Read(Count, SizeOf(Count));
  S.Read(Completed, SizeOf(Completed));
  S.Read(Level, SizeOf(Level));
  S.Read(OwnerId, SizeOf(OwnerId));
  S.Read(CallConv, SizeOf(CallConv));
  S.Read(fPatternId, SizeOf(PatternId));
  S.Read(IsForward, SizeOf(IsForward));
  S.Read(fOverCount, SizeOf(fOverCount));
  S.Read(fIsOpenArray, SizeOf(fIsOpenArray));
  S.Read(fIsExternal, SizeOf(fIsExternal));

  fName := S.ReadString;

  S.Read(K, SizeOf(K));
  if K >= 0 then
  begin
    fSupportedInterfaces := TGuidList.Create;
    fSupportedInterfaces.LoadFromStream(S);
  end
  else
    fSupportedInterfaces := nil;

  fValue := LoadVariantFromStream(S, s_table);

  Address := nil;
  PClass := nil;
end;

procedure TSymbolRec.Update;
begin
  Id := TBaseSymbolTable(s_table).Card;
  TBaseSymbolTable(s_table).HashArray.AddName(fName, Id);
end;

function TSymbolRec.GetHeight: Integer;
begin
  result := 0;
  if Level = 0 then
    Exit;
  if not (TBaseSymbolTable(s_table)[Level].Kind in kindSUBS) then
    Exit;
  result := 1 + TBaseSymbolTable(s_table)[Level].GetHeight;
end;

function TSymbolRec.IsSubPartOfEventType: Boolean;
var
  SymbolTable: TBaseSymbolTable;
  I: Integer;
  RI: TSymbolRec;
begin
  result := false;

  if Kind <> KindSUB then
    Exit;

  SymbolTable := TBaseSymbolTable(s_table);
  for I:=Id to Id + 30 do
  begin
    if I > SymbolTable.Card then
      Exit;
    RI := SymbolTable[I];
    if RI.Kind = KindTYPE then
      if RI.FinalTypeId = typeEVENT then
        if RI.PatternId = Id then
        begin
          result := true;
          Exit;
        end;
  end;
end;

procedure TSymbolRec.SetTypedConst(value: Boolean);
begin
  fTypedConst := value;
end;

function TSymbolRec.GetNameEx: String;
begin
  result := Name;
  if result = '' then
    if Kind = KindTYPE then
      if FinalTypeId = typeSHORTSTRING then
         result := 'String[' + IntToStr(Count) + ']';
end;

procedure TSymbolRec.SetPatternId(value: Integer);
begin
  if value = typeWIDECHAR then
  begin
    if Kind = KindTYPE then
      if FinalTypeId = typeSET then
         value := typeANSICHAR;
  end;
  fPatternId := value;
end;

function TSymbolRec.GetIsPublished: Boolean;
begin
  result := (vis = cvPublished);
end;

procedure TSymbolRec.SetIsPublished(value: Boolean);
begin
  if value then
    vis := cvPublished;
end;

procedure TSymbolRec.SetIsOpenArray(value: Boolean);
begin
  fIsOpenArray := value;
end;

function TSymbolRec.GetNamespaceId: Integer;
begin
  result := 0;
  if Level > 0 then
  begin
    if GetSymbolRec(Level).Kind = kindNAMESPACE then
    begin
      result := Level;
      Exit;
    end
    else
      result := GetSymbolRec(Level).GetNamespaceId;
  end
end;

end.
