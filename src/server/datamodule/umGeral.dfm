object dmGeral: TdmGeral
  OldCreateOrder = False
  Height = 189
  Width = 288
  object CnxSQLite: TFDConnection
    Params.Strings = (
      'LockingMode=Normal'
      'DriverID=SQLite')
    FormatOptions.AssignedValues = [fvFmtDisplayDateTime, fvFmtDisplayDate]
    LoginPrompt = False
    Left = 77
    Top = 35
  end
  object FDPhysSQLiteDriverLink: TFDPhysSQLiteDriverLink
    Left = 157
    Top = 75
  end
  object sqQry: TFDQuery
    Connection = CnxSQLite
    Left = 77
    Top = 107
  end
end
