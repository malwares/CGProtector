object RibbonForm: TRibbonForm
  Left = 465
  Top = 281
  AutoScroll = False
  BorderIcons = []
  Caption = 'Test Ribbon controls'
  ClientHeight = 399
  ClientWidth = 531
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poDesktopCenter
  DesignSize = (
    531
    399)
  PixelsPerInch = 96
  TextHeight = 13
  object bsRibbon1: TbsRibbon
    Left = 0
    Top = 0
    Width = 531
    Height = 129
    HintImageIndex = 0
    TabOrder = 0
    SkinData = SBForm.SkinData
    SkinDataName = 'officetab'
    Align = alTop
    Tabs = <
      item
        Page = bsRibbonPage1
        Visible = True
      end
      item
        Page = bsRibbonPage2
        Visible = True
      end
      item
        Page = bsRibbonPage3
        Visible = True
      end>
    TabIndex = 0
    ActivePage = bsRibbonPage1
    UseSkinFont = True
    AppButtonWidth = 54
    AppButtonImageIndex = 0
    Buttons = <>
    ButtonsShowHint = False
    AppMenu = bsAppMenu1
    DesignSize = (
      531
      129)
    object bsRibbonPage3: TbsRibbonPage
      Left = 1
      Top = 26
      Width = 529
      Height = 100
      HotScroll = False
      ScrollOffset = 0
      ScrollTimerInterval = 50
      CanScroll = True
      Caption = 'bsRibbonPage3'
    end
    object bsRibbonPage2: TbsRibbonPage
      Left = 1
      Top = 26
      Width = 529
      Height = 100
      HotScroll = False
      ScrollOffset = 0
      ScrollTimerInterval = 50
      CanScroll = True
      Caption = 'bsRibbonPage2'
    end
    object bsRibbonPage1: TbsRibbonPage
      Left = 1
      Top = 26
      Width = 529
      Height = 100
      HotScroll = False
      ScrollOffset = 0
      ScrollTimerInterval = 50
      CanScroll = True
      Caption = 'bsRibbonPage1'
      object bsRibbonGroup1: TbsRibbonGroup
        Left = 0
        Top = 0
        Width = 120
        Height = 100
        HintImageIndex = 0
        TabOrder = 0
        SkinData = SBForm.SkinData
        SkinDataName = 'officegroup'
        DefaultFont.Charset = DEFAULT_CHARSET
        DefaultFont.Color = clWindowText
        DefaultFont.Height = 14
        DefaultFont.Name = 'Arial'
        DefaultFont.Style = []
        DefaultWidth = 0
        DefaultHeight = 0
        UseSkinFont = True
        Align = alLeft
        Caption = 'bsRibbonGroup1'
        ShowDialogButton = False
      end
      object bsRibbonGroup2: TbsRibbonGroup
        Left = 120
        Top = 0
        Width = 169
        Height = 100
        HintImageIndex = 0
        TabOrder = 1
        SkinData = SBForm.SkinData
        SkinDataName = 'officegroup'
        DefaultFont.Charset = DEFAULT_CHARSET
        DefaultFont.Color = clWindowText
        DefaultFont.Height = 14
        DefaultFont.Name = 'Arial'
        DefaultFont.Style = []
        DefaultWidth = 0
        DefaultHeight = 0
        UseSkinFont = True
        Align = alLeft
        Caption = 'bsRibbonGroup2'
        ShowDialogButton = True
        object bsRibbonDivider1: TbsRibbonDivider
          Left = 80
          Top = 8
          Width = 17
          Height = 73
          HintImageIndex = 0
          SkinData = SBForm.SkinData
          SkinDataName = 'officegroupdivider'
          DividerType = bsdtVerticalLine
        end
      end
    end
  end
  object bsAppMenu1: TbsAppMenu
    Left = -110
    Top = 0
    Width = 100
    Height = 100
    HintImageIndex = 0
    Anchors = []
    TabOrder = 1
    Visible = False
    SkinData = SBForm.SkinData
    SkinDataName = 'appmenu'
    UseSkinFont = True
    ItemWidth = 130
    Items = <
      item
        Visible = True
        Enabled = True
        ImageIndex = -1
        Caption = 'TbsAppMenuItem0'
      end
      item
        Page = bsAppMenuPage1
        Visible = True
        Enabled = True
        ImageIndex = -1
        Caption = 'TbsAppMenuItem1'
      end
      item
        Visible = True
        Enabled = True
        ImageIndex = -1
        Caption = 'TbsAppMenuItem2'
      end
      item
        Page = bsAppMenuPage2
        Visible = True
        Enabled = True
        ImageIndex = -1
        Caption = 'TbsAppMenuItem3'
      end
      item
        Visible = True
        Enabled = False
        ImageIndex = -1
        Caption = 'TbsAppMenuItem4'
      end
      item
        Visible = True
        Enabled = True
        ImageIndex = -1
        Caption = 'Close'
        OnClick = bsAppMenu1Items5Click
      end>
    ActivePage = bsAppMenuPage1
    OnShowMenu = bsAppMenu1ShowMenu
    OnHideMenu = bsAppMenu1HideMenu
    object bsAppMenuPage2: TbsAppMenuPage
      Left = 130
      Top = 25
      Width = 100
      Height = 156
      HotScroll = False
      ScrollOffset = 0
      ScrollTimerInterval = 50
      CanScroll = True
      DefaultWidth = 0
    end
    object bsAppMenuPage1: TbsAppMenuPage
      Left = 130
      Top = 25
      Width = 300
      Height = 100
      HotScroll = False
      ScrollOffset = 0
      ScrollTimerInterval = 50
      CanScroll = True
      DefaultWidth = 300
      FirstActiveControl = bsAppMenuPageListBox1
      object bsAppMenuPageListBox1: TbsAppMenuPageListBox
        Left = 0
        Top = 33
        Width = 100
        Height = 67
        HintImageIndex = 0
        TabOrder = 0
        SkinData = SBForm.SkinData
        SkinDataName = 'menupagepanel'
        DefaultFont.Charset = DEFAULT_CHARSET
        DefaultFont.Color = clWindowText
        DefaultFont.Height = 14
        DefaultFont.Name = 'Arial'
        DefaultFont.Style = []
        DefaultWidth = 0
        DefaultHeight = 0
        UseSkinFont = True
        AppMenu = bsAppMenu1
        Items = <
          item
            Header = False
            Enabled = True
            Caption = 'Item1'
          end
          item
            Header = False
            Enabled = True
            Caption = 'Item2'
          end
          item
            Header = False
            Enabled = True
            Caption = 'Item3'
          end
          item
            Header = False
            Enabled = True
            Caption = 'Item4'
          end
          item
            Header = False
            Enabled = True
            Caption = 'Item5'
          end
          item
            Header = False
            Enabled = True
            Caption = 'Item6'
          end
          item
            Header = False
            Enabled = True
            Caption = 'Item7'
          end>
        ShowItemTitles = True
        ItemHeight = 30
        HeaderHeight = 20
        ItemIndex = -1
        ShowLines = False
        Align = alClient
        TabStop = True
      end
      object bsSkinLabel1: TbsSkinLabel
        Left = 0
        Top = 0
        Width = 100
        Height = 33
        HintImageIndex = 0
        TabOrder = 1
        SkinData = SBForm.SkinData
        SkinDataName = 'appmenuheader'
        DefaultFont.Charset = DEFAULT_CHARSET
        DefaultFont.Color = clWindowText
        DefaultFont.Height = -16
        DefaultFont.Name = 'Arial'
        DefaultFont.Style = []
        DefaultWidth = 0
        DefaultHeight = 0
        UseSkinFont = True
        ShadowEffect = False
        ShadowColor = clBlack
        ShadowOffset = 0
        ShadowSize = 3
        ReflectionEffect = False
        ReflectionOffset = -5
        EllipsType = bsetNoneEllips
        UseSkinSize = True
        UseSkinFontColor = True
        BorderStyle = bvFrame
        Align = alTop
        Caption = 'Header '
        AutoSize = False
      end
    end
  end
  object bsBusinessSkinForm1: TbsBusinessSkinForm
    SkinRibbon = bsRibbon1
    QuickButtons = <
      item
        ImageIndex = 0
        Enabled = True
        Visible = True
      end
      item
        ImageIndex = 1
        Enabled = True
        Visible = True
      end
      item
        ImageIndex = 2
        Enabled = True
        Visible = True
      end>
    QuickButtonsShowHint = True
    QuickButtonsShowDivider = True
    ClientInActiveEffect = False
    ClientInActiveEffectType = bsieSemiTransparent
    DisableSystemMenu = False
    AlwaysResize = False
    PositionInMonitor = bspDefault
    UseFormCursorInNCArea = False
    MaxMenuItemsInWindow = 0
    ClientWidth = 0
    ClientHeight = 0
    HideCaptionButtons = False
    AlwaysShowInTray = False
    LogoBitMapTransparent = False
    AlwaysMinimizeToTray = False
    UseSkinFontInMenu = True
    ShowIcon = False
    MaximizeOnFullScreen = False
    AlphaBlend = False
    AlphaBlendAnimation = False
    AlphaBlendValue = 200
    ShowObjectHint = False
    MenusAlphaBlend = False
    MenusAlphaBlendAnimation = False
    MenusAlphaBlendValue = 200
    DefCaptionFont.Charset = DEFAULT_CHARSET
    DefCaptionFont.Color = clBtnText
    DefCaptionFont.Height = 14
    DefCaptionFont.Name = 'Arial'
    DefCaptionFont.Style = [fsBold]
    DefInActiveCaptionFont.Charset = DEFAULT_CHARSET
    DefInActiveCaptionFont.Color = clBtnShadow
    DefInActiveCaptionFont.Height = 14
    DefInActiveCaptionFont.Name = 'Arial'
    DefInActiveCaptionFont.Style = [fsBold]
    DefMenuItemHeight = 20
    DefMenuItemFont.Charset = DEFAULT_CHARSET
    DefMenuItemFont.Color = clWindowText
    DefMenuItemFont.Height = 14
    DefMenuItemFont.Name = 'Arial'
    DefMenuItemFont.Style = []
    UseDefaultSysMenu = True
    SkinData = SBForm.SkinData
    MenusSkinData = SBForm.SkinData
    MinHeight = 0
    MinWidth = 0
    MaxHeight = 0
    MaxWidth = 0
    Magnetic = False
    MagneticSize = 5
    BorderIcons = [biSystemMenu, biMinimize, biMaximize, biRollUp]
    Left = 24
    Top = 144
  end
end
