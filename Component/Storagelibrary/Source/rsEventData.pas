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
unit rsEventData;

interface

{$I rsStorage.inc}

uses Windows, Classes, SysUtils, 
     {$IFDEF RSL_D6GE}Variants,{$ENDIF}
     rsStorage, rsConst, rsUtils;


type
  TrsSaveKeyEvent = procedure (const SectionName,KeyName: RSLString; const KeyType: word; Value: Variant) of object;
  TrsLoadKeyEvent = procedure (var SectionName,KeyName: RSLString; var KeyType: word; var Value: Variant) of object;

  TrsEventData = class(TrsStorageData)
  private
    FOnSaveKey: TrsSaveKeyEvent;
    FOnLoadKey: TrsLoadKeyEvent;
  protected
    procedure InternalLoad; override;
    procedure InternalSave; override;
    procedure RecursionSaveSection;
  public
    constructor Create(AOwner: TComponent); override;
  published
    property OnSaveKey: TrsSaveKeyEvent read FOnSaveKey write FOnSaveKey;
    property OnLoadKey: TrsLoadKeyEvent read FOnLoadKey write FOnLoadKey;
  end;


implementation


Type
  TintStorage = class(TrsStorage);

{ TrsRegData }

constructor TrsEventData.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
end;



procedure TrsEventData.InternalLoad;
var
  SectName, KeyName: RSLString;
  KeyType: word;
  val: Variant;
  i: integer;
  s: string;
begin
  if (Storage=nil) or not Assigned(FOnLoadKey) then Exit;

  While True do begin
    SectName := '';
    KeyName := '';
    KeyType := 0;
    val := Unassigned;
    FOnLoadKey(SectName, KeyName, KeyType, val);

    if (Length(SectName)=0) and (Length(KeyName)=0) and ((KeyType=0) or VarIsEmpty(val))
      then Break
      else begin
        i := TintStorage(Storage).KeyFindAddItem(SectName+'\'+KeyName, True);
        if i>=0 then begin
          case KeyType of
            kvtUnknown:  Storage.KeyWrapper.AsVariant := val;
            kvtString:   Storage.KeyWrapper.AsString := val;
            kvtBuffer:
              begin
                s := val;
                Storage.KeyWrapper.SetAsBuffer(PChar(s)^, Length(s)*SizeOf(Char));
              end;
            kvtInteger:  Storage.KeyWrapper.AsInteger := val;
            kvtDouble:   Storage.KeyWrapper.AsFloat := val;
            kvtCurrency: Storage.KeyWrapper.AsCurrency := val;
            kvtDateTime: Storage.KeyWrapper.AsDateTime := val;
            kvtBool:     Storage.KeyWrapper.AsBoolean := val;
            kvtPoint:    ;
{$IFDEF RSL_INT64}
  {$IFDEF RSL_D6GE}
            kvtInt64:    Storage.KeyWrapper.AsInt64 := val;
  {$ENDIF}
{$ENDIF}
            kvtPointer:  Storage.KeyWrapper.AsPointer := Pointer(Integer(VarAsType(val, varInteger)));
          end;
        end else rsError(egSetKeyValue, 'Create Key error <'+SectName+'\'+KeyName+'>');
      end;
  end;
end;


procedure TrsEventData.InternalSave;
begin
  if (Storage=nil) or not Assigned(FOnSaveKey) then Exit;

  ProgressItemCount := TIntStorage(Storage).KeyCountAll;
  DoProgress;
  Storage.RootSection := '';
  RecursionSaveSection;
end;

procedure TrsEventData.RecursionSaveSection;
var
  i,iRangeBegin,iRangeEnd,rngBegin,rngEnd: integer;
  pKI: PrsKeyItem;
  pSI: PrsSectionItem;
  sectName,keyName: RSLString;
begin
  if TintStorage(Storage).GetKeyRange(iRangeBegin, iRangeEnd)
    then begin
      sectName := Storage.RootSection;
      for i:=iRangeBegin to iRangeEnd-1 do begin
        pKI := TintStorage(Storage).GetKeyItem(i);
        Storage.KeyWrapper.PKeyItem := pKI;
        keyName := pKI^.Name;
        FOnSaveKey(sectName, keyName, pki^.Value.kvType, Storage.KeyWrapper.AsVariant);
        Inc(ProgressItemCurrent);
        DoProgress;
      end;
    end else
  if (soSaveEmptySection in Storage.Options) and
     not TintStorage(Storage).GetSectionChildRange(rngBegin, rngEnd)
   then FOnSaveKey(Storage.RootSection, '', 0, Unassigned);

  if TintStorage(Storage).GetSectionChildRange(iRangeBegin, iRangeEnd) then
    for i:=iRangeBegin to iRangeEnd-1 do begin
      pSI := TintStorage(Storage).GetSectionItem(i);
      if Storage.ChangeDownRootSection(pSI^.Name) then begin
        if TintStorage(Storage).GetKeyRange(rngBegin, rngEnd) or
           TintStorage(Storage).GetSectionChildRange(rngBegin, rngEnd) or
           (soSaveEmptySection in Storage.Options)
          then begin
            RecursionSaveSection;
          end;
        Storage.ChangeUpRootSection;
      end;
    end;
end;

end.

