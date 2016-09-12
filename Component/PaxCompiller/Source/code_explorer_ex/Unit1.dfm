object Form1: TForm1
  Left = 192
  Top = 114
  Caption = 'Code explorer demo'
  ClientHeight = 446
  ClientWidth = 688
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object Panel1: TPanel
    Left = 0
    Top = 405
    Width = 688
    Height = 41
    Align = alBottom
    TabOrder = 0
    object Button1: TButton
      Left = 24
      Top = 8
      Width = 105
      Height = 25
      Caption = 'Compile'
      TabOrder = 0
      OnClick = Button1Click
    end
  end
  object Memo1: TMemo
    Left = 0
    Top = 0
    Width = 345
    Height = 405
    Align = alLeft
    Lines.Strings = (
      'uses'
      '  Classes;'
      'type'
      ''
      '  TMyNotifyEvent = procedure (Sender:TObject) of object;'
      ''
      '  TMyArray = array[1..10] of Single;'
      '  TMyPoint = record'
      '    X, Y: Double;'
      '  end;'
      '  TMyClass = class'
      '  private'
      '    P, Q: Integer;'
      '  public'
      '    function MyClassFunc: Integer;'
      '  published'
      '    property MyProp: Integer read P;'
      '  end;'
      ''
      'function TMyClass.MyClassFunc: Integer;'
      'begin'
      'end;'
      ''
      'procedure MyProc(var X: Integer; const Y: Integer; Z: Integer);'
      'procedure NestedProc;'
      'begin'
      'end;'
      'var'
      '  L: Double;'
      'const'
      '  W = '#39'abc'#39';'
      'begin'
      'end;'
      'function MyFunc: String;'
      'type'
      '  TMyEnum = (one, two, three);'
      'begin'
      '  result := '#39'pqr'#39';'
      'end;'
      'const'
      '  Z = 80;'
      'var'
      '  G: Byte;'
      'begin'
      'end.')
    TabOrder = 1
  end
  object TreeView1: TTreeView
    Left = 345
    Top = 0
    Width = 343
    Height = 405
    Align = alClient
    Indent = 19
    TabOrder = 2
    OnDblClick = TreeView1DblClick
  end
  object PaxCompiler1: TPaxCompiler
    Alignment = 1
    DebugMode = False
    Left = 224
    Top = 413
  end
  object PaxPascalLanguage1: TPaxPascalLanguage
    CompleteBooleanEval = False
    UnitLookup = True
    PrintKeyword = 'print'
    PrintlnKeyword = 'println'
    Left = 264
    Top = 413
  end
  object PaxCompilerExplorer1: TPaxCompilerExplorer
    Left = 304
    Top = 413
  end
end
