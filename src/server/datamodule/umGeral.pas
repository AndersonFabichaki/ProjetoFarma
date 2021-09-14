unit umGeral;

interface

uses
  System.SysUtils, System.Classes, FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Error, FireDAC.UI.Intf, FireDAC.Phys.Intf, FireDAC.Stan.Def, FireDAC.Stan.Pool, FireDAC.Stan.Async,
  FireDAC.Phys, FireDAC.Phys.SQLite, FireDAC.Phys.SQLiteDef, FireDAC.Stan.ExprFuncs, FireDAC.ConsoleUI.Wait, FireDAC.Stan.Param, FireDAC.DatS, FireDAC.DApt.Intf, FireDAC.DApt, Data.DB,
  FireDAC.Comp.DataSet, FireDAC.Comp.Client, FireDAC.VCLUI.Wait;

type
  TdmGeral = class(TDataModule)
    CnxSQLite: TFDConnection;
    FDPhysSQLiteDriverLink: TFDPhysSQLiteDriverLink;
    sqQry: TFDQuery;
  private
    { Private declarations }
  public
    function ConectaSQLite:Boolean;
  end;

var
  dmGeral: TdmGeral;

implementation

uses DAO.Farma;

{%CLASSGROUP 'System.Classes.TPersistent'}

{$R *.dfm}

{ TDataModule1 }

function TdmGeral.ConectaSQLite: Boolean;
begin
   Result:=False;

   with CnxSQLite do
   begin
      Params.Add('DriverID=SQLite');
      Params.Add('Database='+ExtractFileDir(GetCurrentDir)+'\FarmaServiceConfig.SQLite');
      Params.Add('OpenMode=CreateUTF8');
      Params.Add('DateTimeFormat=String');
      Params.Add('LockingMode=Normal');
      Params.Add('Synchronous=Normal');
      Params.Add('BusyTimeout=7500');
      Params.Add('SharedCache=False');

      FetchOptions.Mode := fmAll;
      UpdateOptions.LockWait := True;

      try
         Connected := True;
      except
         on E: Exception do
            Writeln('Erro de conexão com o banco de dados SQLite!');
      end;
   end;

   if CnxSQLite.Connected then
      Result:=TFarmaDAO.New.ValidaSQLite;
end;

initialization

end.
