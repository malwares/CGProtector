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
unit rsProperty;

interface

{$I rsStorage.inc}

type
  TrsPropertyType = (ptPublished, ptCustom, ptUser, ptVariable);
  TrsPropertyState = (psNormal, psRead, psWrite);

  TrsProperty = class
  private
    function GetAsString: string;
    procedure SetAsString(const Value: string);
    function GetParams: string;
    procedure SetParams(const Value: string);
    function GetNameInData: string;
  public
    Name: string;
    SubstName: string;
    DefValue: string;
    Enabled: boolean;
    PropType: TrsPropertyType;
    State: TrsPropertyState;
    ExtFlags: cardinal;
    StoreEncrypted: boolean;
    constructor Create;
    property NameInData: string read GetNameInData;
    property Params: string read GetParams write SetParams;
    property AsString: string read GetAsString write SetAsString;
  end;

implementation

{ TrsProperty }
const
  cSeparator = ',';
  STypes: PChar = 'PCUV';
  SStates: PChar = 'DRW';


constructor TrsProperty.Create;
begin
  Enabled := True;
end;

function TrsProperty.GetAsString: string;
var
  s: string;
  flag: boolean;
begin
  Result := Name;
  s := Params;
  flag := s<>'EPD';
  if (Length(DefValue)>0) or (Length(SubstName)>0) or flag then begin
    Result := Result + ',"'+DefValue+'","'+SubstName+'",';
    if flag then Result := Result + s
  end;
end;


function TrsProperty.GetNameInData: string;
begin
  if Length(SubstName)>0 then Result := SubstName
   else Result := Name;
end;

function TrsProperty.GetParams: string;
begin
  if StoreEncrypted
    then SetLength(Result, 4)
    else SetLength(Result, 3);
  if Enabled
    then Result[1] := 'E'
    else Result[1] := 'D';
  Result[2] := STypes[Ord(PropType)];
  Result[3] := SStates[Ord(State)];
  if StoreEncrypted then Result[4] := 'C';
end;


procedure TrsProperty.SetAsString(const Value: string);
var
  i,j,k: integer;
begin
  i := Length(Value);
  if i>=3 then begin
    if Value[i-3]=cSeparator then k := 3
     else
    if Value[i-4]=cSeparator then k := 4
     else k := 0;
    if (k>0) and (Value[i]<>cSeparator) then begin
      Params := Copy(Value, i-k+1, k);
      Dec(i, k);
    end else Params := '';
  end else Params := '';

  DefValue := '';
  SubstName := '';
  if (i>0) and (Value[i]=cSeparator) then begin  //04.04.2002 i>0 added
    k := Pos(cSeparator, Value);

    j := Pos('"'+cSeparator+'"', Value);
    if j>k then begin //extract SubstName
      Inc(j);
      if (Value[i-1]='"') and (Value[j+1]='"')
        then SubstName := Copy(Value, j+2, i-j-3)
        else SubstName := Copy(Value, j+1, i-j-1);
      i := j;
    end;

    if (k<>0) and (k<i) then begin // extract DefValue
      if (Value[i-1]='"') and (Value[k+1]='"')
        then DefValue := Copy(Value, k+2, i-k-3)
        else DefValue := Copy(Value, k+1, i-k-1);
      i := k-1;
    end else Dec(i);
  end;

  if i=Length(Value) then Name := Value
   else Name := Copy(Value, 1, i);

  ExtFlags := 0;
end;


procedure TrsProperty.SetParams(const Value: string);
var
  len: integer;
begin
  len := Length(Value);
  if len>0 then begin
    Enabled := Value[1]='E';
    if len>1 then
      case Value[2] of
        'P': PropType := ptPublished;
        'C': PropType := ptCustom;
        'U': PropType := ptUser;
        'V': PropType := ptVariable;
      end
    else PropType := ptPublished;
    if len>2 then
      case Value[3] of
        'D': State := psNormal;
        'R': State := psRead;
        'W': State := psWrite;
      end
    else State := psNormal;
    if len>3 then StoreEncrypted := Value[4]='C'
     else StoreEncrypted := False;

  end else begin
    Enabled := True;
    PropType := ptPublished;
    State := psNormal;
    StoreEncrypted := False;
  end;
end;

end.

