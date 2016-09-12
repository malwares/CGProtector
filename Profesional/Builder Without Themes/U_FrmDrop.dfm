object Frm_Drop: TFrm_Drop
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  BorderStyle = bsSingle
  Caption = 'Drop Settings'
  ClientHeight = 150
  ClientWidth = 318
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poDefault
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 318
    Height = 150
    Align = alClient
    BevelOuter = bvNone
    Color = clWhite
    ParentBackground = False
    TabOrder = 0
    object AdvSmoothLabel3: TAdvSmoothLabel
      Left = 12
      Top = 18
      Width = 95
      Height = 18
      Fill.ColorMirror = clNone
      Fill.ColorMirrorTo = clNone
      Fill.BorderColor = clNone
      Fill.Rounding = 0
      Fill.ShadowOffset = 0
      Caption.Text = 'File Path :'
      Caption.Location = plCenterLeft
      Caption.Font.Charset = DEFAULT_CHARSET
      Caption.Font.Color = clWindowText
      Caption.Font.Height = -13
      Caption.Font.Name = 'Tahoma'
      Caption.Font.Style = [fsBold]
      CaptionShadow.Text = 'Filename'
      CaptionShadow.Font.Charset = DEFAULT_CHARSET
      CaptionShadow.Font.Color = clWindowText
      CaptionShadow.Font.Height = -27
      CaptionShadow.Font.Name = 'Tahoma'
      CaptionShadow.Font.Style = []
      Version = '1.5.0.0'
    end
    object AdvSmoothLabel2: TAdvSmoothLabel
      Left = 12
      Top = 50
      Width = 95
      Height = 18
      Fill.ColorMirror = clNone
      Fill.ColorMirrorTo = clNone
      Fill.BorderColor = clNone
      Fill.Rounding = 0
      Fill.ShadowOffset = 0
      Caption.Text = 'File Name :'
      Caption.Location = plCenterLeft
      Caption.Font.Charset = DEFAULT_CHARSET
      Caption.Font.Color = clWindowText
      Caption.Font.Height = -13
      Caption.Font.Name = 'Tahoma'
      Caption.Font.Style = [fsBold]
      CaptionShadow.Text = 'Filename'
      CaptionShadow.Font.Charset = DEFAULT_CHARSET
      CaptionShadow.Font.Color = clWindowText
      CaptionShadow.Font.Height = -27
      CaptionShadow.Font.Name = 'Tahoma'
      CaptionShadow.Font.Style = []
      Version = '1.5.0.0'
    end
    object AdvSmoothLabel6: TAdvSmoothLabel
      Left = 12
      Top = 81
      Width = 112
      Height = 18
      Fill.ColorMirror = clNone
      Fill.ColorMirrorTo = clNone
      Fill.BorderColor = clNone
      Fill.Rounding = 0
      Fill.ShadowOffset = 0
      Caption.Text = 'Attribute :'
      Caption.Location = plCenterLeft
      Caption.Font.Charset = DEFAULT_CHARSET
      Caption.Font.Color = clWindowText
      Caption.Font.Height = -13
      Caption.Font.Name = 'Tahoma'
      Caption.Font.Style = [fsBold]
      CaptionShadow.Text = 'Filename'
      CaptionShadow.Font.Charset = DEFAULT_CHARSET
      CaptionShadow.Font.Color = clWindowText
      CaptionShadow.Font.Height = -27
      CaptionShadow.Font.Name = 'Tahoma'
      CaptionShadow.Font.Style = []
      Version = '1.5.0.0'
    end
    object FD_EditPath: TAdvComboBox
      Left = 107
      Top = 15
      Width = 198
      Height = 21
      Color = clWindow
      Version = '1.3.1.0'
      Visible = True
      ButtonWidth = 18
      DropWidth = 0
      Enabled = True
      ItemIndex = 0
      ItemHeight = 13
      Items.Strings = (
        'ProgramFiles'
        'AllUsersProfile'
        'APPDATA'
        'CommonProgramFiles'
        'HOMEDRIVE'
        'SystemDrive'
        'SystemRoot'
        'USERPROFILE'
        'temp')
      LabelFont.Charset = DEFAULT_CHARSET
      LabelFont.Color = clWindowText
      LabelFont.Height = -11
      LabelFont.Name = 'Tahoma'
      LabelFont.Style = []
      TabOrder = 0
      Text = 'ProgramFiles'
    end
    object FD_EditName: TbsSkinEdit
      Left = 107
      Top = 50
      Width = 198
      Height = 18
      DefaultColor = clWindow
      DefaultFont.Charset = DEFAULT_CHARSET
      DefaultFont.Color = clBlack
      DefaultFont.Height = 14
      DefaultFont.Name = 'Arial'
      DefaultFont.Style = []
      UseSkinFont = True
      DefaultWidth = 0
      DefaultHeight = 0
      ButtonMode = False
      SkinDataName = 'edit'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clBlack
      Font.Height = 14
      Font.Name = 'Arial'
      Font.Style = []
      ParentFont = False
      TabOrder = 1
      LeftImageIndex = -1
      LeftImageHotIndex = -1
      LeftImageDownIndex = -1
      RightImageIndex = -1
      RightImageHotIndex = -1
      RightImageDownIndex = -1
    end
    object FE_Ok: TAdvSmoothButton
      Left = 160
      Top = 105
      Width = 65
      Height = 35
      Status.Caption = '0'
      Status.Appearance.Fill.Color = clRed
      Status.Appearance.Fill.ColorMirror = clNone
      Status.Appearance.Fill.ColorMirrorTo = clNone
      Status.Appearance.Fill.GradientType = gtSolid
      Status.Appearance.Fill.BorderColor = clGray
      Status.Appearance.Fill.Rounding = 0
      Status.Appearance.Fill.ShadowOffset = 0
      Status.Appearance.Font.Charset = DEFAULT_CHARSET
      Status.Appearance.Font.Color = clWhite
      Status.Appearance.Font.Height = -11
      Status.Appearance.Font.Name = 'Tahoma'
      Status.Appearance.Font.Style = []
      Caption = 'Ok'
      TabOrder = 2
      Version = '1.6.9.1'
      OnClick = FE_OkClick
    end
    object FE_Cancel: TAdvSmoothButton
      Left = 240
      Top = 105
      Width = 65
      Height = 35
      Status.Caption = '0'
      Status.Appearance.Fill.Color = clRed
      Status.Appearance.Fill.ColorMirror = clNone
      Status.Appearance.Fill.ColorMirrorTo = clNone
      Status.Appearance.Fill.GradientType = gtSolid
      Status.Appearance.Fill.BorderColor = clGray
      Status.Appearance.Fill.Rounding = 0
      Status.Appearance.Fill.ShadowOffset = 0
      Status.Appearance.Font.Charset = DEFAULT_CHARSET
      Status.Appearance.Font.Color = clWhite
      Status.Appearance.Font.Height = -11
      Status.Appearance.Font.Name = 'Tahoma'
      Status.Appearance.Font.Style = []
      Caption = 'Cancel'
      TabOrder = 3
      Version = '1.6.9.1'
      OnClick = FE_CancelClick
    end
    object FD_check1: TCheckBox
      Left = 107
      Top = 82
      Width = 70
      Height = 17
      Caption = '+Hidden'
      Color = clWhite
      ParentColor = False
      TabOrder = 4
    end
    object FD_check2: TCheckBox
      Left = 183
      Top = 82
      Width = 70
      Height = 17
      Caption = '+System'
      Color = clWhite
      ParentColor = False
      TabOrder = 5
    end
  end
end
