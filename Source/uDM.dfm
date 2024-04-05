object DM: TDM
  Height = 264
  Width = 520
  object ADODB: TADOConnection
    LoginPrompt = False
    Left = 32
    Top = 24
  end
  object qryIOData: TADOQuery
    Connection = ADODB
    Parameters = <>
    Left = 96
    Top = 24
  end
end
