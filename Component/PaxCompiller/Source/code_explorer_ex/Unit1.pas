unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, PaxCompilerExplorer, PaxCompiler, StdCtrls, ExtCtrls, ComCtrls,
  PAXCOMP_SYS,
  IMPORT_Classes;

type
  TForm1 = class(TForm)
    Panel1: TPanel;
    Memo1: TMemo;
    Button1: TButton;
    PaxCompiler1: TPaxCompiler;
    PaxPascalLanguage1: TPaxPascalLanguage;
    PaxCompilerExplorer1: TPaxCompilerExplorer;
    TreeView1: TTreeView;
    procedure Button1Click(Sender: TObject);
    procedure TreeView1DblClick(Sender: TObject);
  private
    { Private declarations }
    L: TList;
  public
    { Public declarations }
    procedure BuildTree;
    procedure EnumProc(Id: Integer;
                       Host: Boolean;
                       Kind: TPaxMemberKind;
                       Data: Pointer);
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

procedure TForm1.Button1Click(Sender: TObject);
var
  I: Integer;
begin
  PaxCompiler1.Reset;
  PaxCompiler1.RegisterLanguage(PaxPascalLanguage1);
  PaxCompiler1.AddModule('1', 'Pascal');
  PaxCompiler1.AddCode('1', Memo1.Lines.Text);
  if PaxCompiler1.Compile then
  begin
    PaxCompilerExplorer1.RegisterCompiler(PaxCompiler1);
    BuildTree;
  end
  else
    for I:=0 to PaxCompiler1.ErrorCount - 1 do
      ShowMessage(PaxCompiler1.ErrorMessage[I]);
end;

procedure TForm1.BuildTree;
var
  N, N2: TTreeNode;
  I: Integer;
begin
  L := TList.Create;
  try
    TreeView1.Items.Clear;

    N := TreeView1.Items.Add(nil, 'Used namespaces');
    L.Add(N);
    PaxCompilerExplorer1.EnumMembers(0, true, pmkNamespace, EnumProc, N);
    PaxCompilerExplorer1.EnumMembers(0, false, pmkNamespace, EnumProc, N);

    N := TreeView1.Items.Add(nil, 'Noname namespace');

    N2 := TreeView1.Items.AddChild(N, 'Types');
    L.Add(N2);
    PaxCompilerExplorer1.EnumMembers(0, false, pmkType, EnumProc, N2);

    N2 := TreeView1.Items.AddChild(N, 'Procedures');
    L.Add(N2);
    PaxCompilerExplorer1.EnumMembers(0, false, pmkProcedure, EnumProc, N2);

    N2 := TreeView1.Items.AddChild(N, 'Functions');
    L.Add(N2);
    PaxCompilerExplorer1.EnumMembers(0, false, pmkFunction, EnumProc, N2);

    N2 := TreeView1.Items.AddChild(N, 'Constants');
    L.Add(N2);
    PaxCompilerExplorer1.EnumMembers(0, false, pmkConst, EnumProc, N2);

    N2 := TreeView1.Items.AddChild(N, 'Variables');
    L.Add(N2);
    PaxCompilerExplorer1.EnumMembers(0, false, pmkVar, EnumProc, N2);

  finally
    for I := L.Count - 1 downto 0 do
    begin
      N2 := TTreeNode(L[I]);
      if N2.Count = 0 then
        N2.Delete;
    end;

    L.Free;
  end;
end;

procedure TForm1.EnumProc(Id: Integer;
                          Host: Boolean;
                          Kind: TPaxMemberKind;
                          Data: Pointer);
var
  N, N2, N3: TTreeNode;
  Name: String;
  TypeName: String;
  vis: TClassVisibility;
  S: String;
begin
  N := TTreeNode(Data);

  Name := PaxCompilerExplorer1.Names[Id];
  TypeName := PaxCompilerExplorer1.TypeNames[Id];

  S := '';
  vis := PaxCompilerExplorer1.GetVisibility(Id);
  case vis of
    cvPrivate : S := ' (private) ';
    cvProtected : S := ' (protected) ';
    cvPublic : S := ' (public)';
    cvPublished : S := ' (published) ';
  end;

  with TreeView1.Items do
  case Kind of
    pmkProcedure, pmkFunction, pmkConstructor, pmkDestructor:
    begin
      N2 := AddChildObject(N, S + Name, TObject(Id));

      N3 := AddChild(N2, 'Parameters');
      L.Add(N3);
      PaxCompilerExplorer1.EnumMembers(Id, Host, pmkParam, EnumProc, N3);

      N3 := AddChild(N2, 'Local variables');
      L.Add(N3);
      PaxCompilerExplorer1.EnumMembers(Id, Host, pmkVar, EnumProc, N3);

      N3 := AddChild(N2, 'Local constants');
      L.Add(N3);
      PaxCompilerExplorer1.EnumMembers(Id, Host, pmkConst, EnumProc, N3);

      N3 := AddChild(N2, 'Local types');
      L.Add(N3);
      PaxCompilerExplorer1.EnumMembers(Id, Host, pmkType, EnumProc, N3);

      N3 := TreeView1.Items.AddChild(N2, 'Nested procedures');
      L.Add(N3);
      PaxCompilerExplorer1.EnumMembers(Id, false, pmkProcedure, EnumProc, N3);

      N3 := TreeView1.Items.AddChild(N2, 'Nested functions');
      L.Add(N3);
      PaxCompilerExplorer1.EnumMembers(Id, false, pmkFunction, EnumProc, N3);

    end;
    pmkParam:
    begin
      if PaxCompilerExplorer1.IsByRefParam(Id) then
        AddChildObject(N, 'var ' + Name + ': ' + TypeName, TObject(Id))
      else if PaxCompilerExplorer1.IsConstParam(Id) then
        AddChildObject(N, 'const ' + Name + ': ' + TypeName, TObject(Id))
      else
        AddChildObject(N, Name + ': ' + TypeName, TObject(Id));
    end;
    pmkVar: AddChildObject(N, Name + ': ' + TypeName, TObject(Id));
    pmkConst: AddChildObject(N, Name + ': ' + TypeName, TObject(Id));
    pmkField: AddChildObject(N, S + Name + ': ' + TypeName, TObject(Id));
    pmkProperty: AddChildObject(N, S + Name + ': ' + TypeName, TObject(Id));
    pmkType:
    begin
      N2 := AddChildObject(N, Name, TObject(Id));
      if PaxCompilerExplorer1.IsRecordType(Id) then
      begin
        N3 := AddChild(N2, 'Fields');
        L.Add(N3);
        PaxCompilerExplorer1.EnumMembers(Id, Host, pmkField, EnumProc, N3);
      end
      else if PaxCompilerExplorer1.IsClassType(Id) then
      begin
        N3 := AddChild(N2, 'Fields');
        L.Add(N3);
        PaxCompilerExplorer1.EnumMembers(Id, Host, pmkField, EnumProc, N3);

        N3 := AddChild(N2, 'Properties');
        L.Add(N3);
        PaxCompilerExplorer1.EnumMembers(Id, Host, pmkProperty, EnumProc, N3);

        N3 := TreeView1.Items.AddChild(N2, 'Constructors');
        L.Add(N3);
        PaxCompilerExplorer1.EnumMembers(Id, false, pmkConstructor, EnumProc, N3);

        N3 := TreeView1.Items.AddChild(N2, 'Destructor');
        L.Add(N3);
        PaxCompilerExplorer1.EnumMembers(Id, false, pmkDestructor, EnumProc, N3);

        N3 := TreeView1.Items.AddChild(N2, 'Class procedures');
        L.Add(N3);
        PaxCompilerExplorer1.EnumMembers(Id, false, pmkProcedure, EnumProc, N3);

        N3 := TreeView1.Items.AddChild(N2, 'Class functions');
        L.Add(N3);
        PaxCompilerExplorer1.EnumMembers(Id, false, pmkFunction, EnumProc, N3);
      end;
    end;
    pmkNamespace:
    begin
      N2 := AddChildObject(N, Name, TObject(Id));

      N3 := AddChild(N2, 'Constants');
      L.Add(N3);
      PaxCompilerExplorer1.EnumMembers(Id, Host, pmkConst, EnumProc, N3);

      N3 := AddChild(N2, 'Variables');
      L.Add(N3);
      PaxCompilerExplorer1.EnumMembers(Id, Host, pmkVar, EnumProc, N3);

      N3 := AddChild(N2, 'Procedures');
      L.Add(N3);
      PaxCompilerExplorer1.EnumMembers(Id, Host, pmkProcedure, EnumProc, N3);

      N3 := AddChild(N2, 'Types');
      L.Add(N3);
      PaxCompilerExplorer1.EnumMembers(Id, Host, pmkType, EnumProc, N3);
    end;
  end;
end;

procedure TForm1.TreeView1DblClick(Sender: TObject);
var
  N: TTreeNode;
  Id, Position: Integer;
  S: String;
begin
  N := TTreeView(Sender).Selected;

  if N = nil then
    Exit;

  Id := Integer(N.Data);

  if Id = 0 then
    Exit;

  S := PaxCompilerExplorer1.Names[Id];
  Position := PaxCompilerExplorer1.Positions[Id];

  if Id <> 0 then
    with Memo1 do
    begin
      SetFocus;
      SelStart := Position;
      SelLength := Length(S);
    end;
end;

initialization

Register_Classes;

end.
