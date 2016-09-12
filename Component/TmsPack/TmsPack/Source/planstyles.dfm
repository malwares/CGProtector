object PlanStyleForm: TPlanStyleForm
  Left = 133
  Top = 267
  BorderStyle = bsDialog
  Caption = 'Planner styles'
  ClientHeight = 381
  ClientWidth = 192
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  PixelsPerInch = 96
  TextHeight = 13
  object RadioGroup1: TRadioGroup
    Left = 16
    Top = 4
    Width = 161
    Height = 343
    ItemIndex = 0
    Items.Strings = (
      'Windows XP'
      'Office 2002'
      'Office 2003 (Blue)'
      'Office 2003 (Olive)'
      'Office 2003 (Silver)'
      'Flat style'
      'Avantgarde'
      'Whidbey'
      'Office 2007 (Blue)'
      'Office 2007 (Black)'
      'Office 2007 (Silver)'
      'Windows Vista'
      'Windows 7'
      'Terminal'
      'Office 2010 Blue'
      'Office 2010 Silver'
      'Office 2010 Black')
    TabOrder = 0
  end
  object Button1: TButton
    Left = 16
    Top = 350
    Width = 75
    Height = 25
    Caption = 'OK'
    ModalResult = 1
    TabOrder = 1
  end
  object Button2: TButton
    Left = 100
    Top = 350
    Width = 75
    Height = 25
    Cancel = True
    Caption = 'Cancel'
    ModalResult = 2
    TabOrder = 2
  end
end
