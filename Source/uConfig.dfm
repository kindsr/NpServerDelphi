object Config: TConfig
  Left = 0
  Top = 0
  BorderStyle = bsDialog
  Caption = 'NP Server Delphi - Config'
  ClientHeight = 467
  ClientWidth = 318
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -13
  Font.Name = #47569#51008' '#44256#46357
  Font.Style = []
  Font.Quality = fqDraft
  OnShow = FormShow
  TextHeight = 17
  object GroupBox1: TGroupBox
    Left = 0
    Top = 80
    Width = 318
    Height = 129
    Align = alTop
    Caption = #49436#48260#49464#54021
    TabOrder = 0
    ExplicitWidth = 314
    object Label3: TLabel
      Left = 16
      Top = 27
      Width = 113
      Height = 25
      AutoSize = False
      Caption = 'TCP Server Port'
    end
    object Label4: TLabel
      Left = 16
      Top = 58
      Width = 113
      Height = 25
      AutoSize = False
      Caption = 'Retry Period'
    end
    object Label5: TLabel
      Left = 16
      Top = 89
      Width = 113
      Height = 25
      AutoSize = False
      Caption = 'Heartbeat Period'
    end
    object edtTCPServerPort: TEdit
      Left = 160
      Top = 27
      Width = 141
      Height = 25
      TabOrder = 0
    end
    object edtRetryPeriod: TEdit
      Left = 160
      Top = 58
      Width = 141
      Height = 25
      TabOrder = 1
    end
    object edtHeartbeatPeriod: TEdit
      Left = 160
      Top = 89
      Width = 141
      Height = 25
      TabOrder = 2
    end
  end
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 318
    Height = 80
    Align = alTop
    BevelOuter = bvNone
    Caption = 'Panel1'
    ShowCaption = False
    TabOrder = 1
    ExplicitWidth = 314
    object btnClose: TButton
      AlignWithMargins = True
      Left = 240
      Top = 3
      Width = 75
      Height = 74
      Align = alRight
      Caption = 'Close'
      TabOrder = 0
      OnClick = btnCloseClick
      ExplicitLeft = 236
    end
    object btnSave: TButton
      AlignWithMargins = True
      Left = 159
      Top = 3
      Width = 75
      Height = 74
      Align = alRight
      Caption = 'Save'
      TabOrder = 1
      OnClick = btnSaveClick
      ExplicitLeft = 155
    end
  end
  object GroupBox2: TGroupBox
    Left = 0
    Top = 369
    Width = 318
    Height = 98
    Align = alBottom
    Caption = #50868#50689#49464#54021
    TabOrder = 2
    Visible = False
    ExplicitTop = 368
    ExplicitWidth = 314
    object Label6: TLabel
      Left = 16
      Top = 29
      Width = 113
      Height = 25
      AutoSize = False
      Caption = #50689#50629#52264#47049#44277#53685#48264#54840
    end
    object Label7: TLabel
      Left = 16
      Top = 60
      Width = 113
      Height = 25
      AutoSize = False
      Caption = #44596#44553#52264#47049#48264#54840
    end
    object edtSalesCarNumber: TEdit
      Left = 160
      Top = 29
      Width = 141
      Height = 25
      TabOrder = 0
    end
    object edtEmergencyNumber: TEdit
      Left = 160
      Top = 60
      Width = 141
      Height = 25
      TabOrder = 1
    end
  end
  object GroupBox3: TGroupBox
    Left = 0
    Top = 209
    Width = 318
    Height = 160
    Align = alClient
    Caption = 'DB'#49464#54021
    TabOrder = 3
    ExplicitWidth = 314
    ExplicitHeight = 159
    object Label1: TLabel
      Left = 16
      Top = 27
      Width = 113
      Height = 25
      AutoSize = False
      Caption = 'Server IP'
    end
    object Label2: TLabel
      Left = 16
      Top = 58
      Width = 113
      Height = 25
      AutoSize = False
      Caption = 'Username'
    end
    object Label8: TLabel
      Left = 16
      Top = 89
      Width = 113
      Height = 25
      AutoSize = False
      Caption = 'Password'
    end
    object Label9: TLabel
      Left = 16
      Top = 122
      Width = 113
      Height = 25
      AutoSize = False
      Caption = 'DB Name'
    end
    object edtDBServerIP: TEdit
      Left = 160
      Top = 27
      Width = 141
      Height = 25
      TabOrder = 0
    end
    object edtDBUsername: TEdit
      Left = 160
      Top = 58
      Width = 141
      Height = 25
      TabOrder = 1
    end
    object edtDBPassword: TEdit
      Left = 160
      Top = 89
      Width = 141
      Height = 25
      TabOrder = 2
    end
    object edtDBName: TEdit
      Left = 160
      Top = 122
      Width = 141
      Height = 25
      TabOrder = 3
    end
  end
end
