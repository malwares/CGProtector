object ComboListEditor: TComboListEditor
  Left = 0
  Top = 0
  Caption = 'AdvDBComboBox list editor'
  ClientHeight = 380
  ClientWidth = 560
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object lbl_Images: TLabel
    Left = 448
    Top = 8
    Width = 79
    Height = 13
    Caption = 'Available images'
  end
  object Label1: TLabel
    Left = 8
    Top = 8
    Width = 200
    Height = 13
    Caption = 'List of displayed values and stored values'
  end
  object sg_ComboList: TStringGrid
    Left = 8
    Top = 24
    Width = 434
    Height = 315
    ColCount = 2
    FixedCols = 0
    RowCount = 2
    Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goRangeSelect, goDrawFocusSelected, goColSizing, goEditing]
    TabOrder = 0
    OnDragDrop = sg_ComboListDragDrop
    OnDragOver = sg_ComboListDragOver
    OnDrawCell = sg_ComboListDrawCell
    OnKeyDown = sg_ComboListKeyDown
  end
  object bt_ClearList: TButton
    Left = 139
    Top = 347
    Width = 65
    Height = 25
    Caption = 'Clear'
    TabOrder = 3
    OnClick = bt_ClearListClick
  end
  object btn_Cancel: TButton
    Left = 483
    Top = 347
    Width = 70
    Height = 25
    Cancel = True
    Caption = '&Cancel'
    ModalResult = 2
    TabOrder = 2
  end
  object btn_Ok: TButton
    Left = 413
    Top = 347
    Width = 70
    Height = 25
    Caption = '&Ok'
    Default = True
    ModalResult = 1
    TabOrder = 1
    OnClick = btn_OkClick
  end
  object btn_Add: TButton
    Left = 8
    Top = 347
    Width = 65
    Height = 25
    Caption = 'Add Row'
    TabOrder = 5
    OnClick = btn_AddClick
  end
  object btn_GetStoredVal: TButton
    Left = 204
    Top = 347
    Width = 95
    Height = 25
    Hint = 'Retrieve values from data field'
    Caption = 'Get stored values'
    ParentShowHint = False
    ShowHint = True
    TabOrder = 4
    OnClick = btn_GetStoredValClick
  end
  object lb_ImageList: TListBox
    Left = 448
    Top = 24
    Width = 105
    Height = 315
    Style = lbOwnerDrawFixed
    DragMode = dmAutomatic
    TabOrder = 6
    OnDrawItem = lb_ImageListDrawItem
  end
  object btn_Del: TButton
    Left = 74
    Top = 347
    Width = 65
    Height = 25
    Caption = 'Delete Row'
    TabOrder = 7
    OnClick = btn_DelClick
  end
end
