////////////////////////////////////////////////////////////////////////////
// PaxCompiler
// Site: http://www.paxcompiler.com
// Author: Alexander Baranovsky (paxscript@gmail.com)
// ========================================================================
// Copyright (c) Alexander Baranovsky, 2006. All rights reserved.
// Code Version: 2.4
// ========================================================================
// Unit: PaxBasicLanguage.pas
// ========================================================================
////////////////////////////////////////////////////////////////////////////

{$I PaxCompiler.def}
unit PaxBasicLanguage;

interface
uses
  Classes,
  PAXCOMP_PARSER,
  PAXCOMP_BASIC_PARSER,
  PaxRegister,
  PaxCompiler;

type
  TPaxBasicLanguage = class(TPaxCompilerLanguage)
  private
    P: TBasicParser;
  protected
    function GetParser: TBaseParser; override;
    function GetLanguageName: String; override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure SetCallConv(CallConv: Integer); override;
    procedure SetDeclareCallConv(CallConv: Integer);
  published
  end;

implementation

function TPaxBasicLanguage.GetParser: TBaseParser;
begin
  result := P;
end;

function TPaxBasicLanguage.GetLanguageName: String;
begin
  result := P.LanguageName;
end;

constructor TPaxBasicLanguage.Create(AOwner: TComponent);
begin
  inherited;
  P := TBasicParser.Create;
  SetCallConv(_ccREGISTER);
end;

destructor TPaxBasicLanguage.Destroy;
begin
  P.Free;
  inherited;
end;

procedure TPaxBasicLanguage.SetCallConv(CallConv: Integer);
begin
  P.CallConv := CallConv;
end;

procedure TPaxBasicLanguage.SetDeclareCallConv(CallConv: Integer);
begin
  P.DeclareCallConv := CallConv;
end;

end.
