program ServerFarma;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils,
  Horse,
  Horse.Jhonson,
  Controllers.Farma in '..\src\server\controllers\Controllers.Farma.pas',
  umGeral in '..\src\server\datamodule\umGeral.pas' {dmGeral: TDataModule},
  DAO.Farma in '..\src\server\dao\DAO.Farma.pas',
  Model.FarmaBase in '..\src\model\Model.FarmaBase.pas',
  Model.Farma in '..\src\server\model\Model.Farma.pas',
  Utils.Farma in '..\src\utils\Utils.Farma.pas';

begin
   try
      dmGeral := TdmGeral.Create(nil);

      if dmGeral.ConectaSQLite then
         Controllers.Farma.Registry;
   except
      on E: Exception do
         Writeln(E.ClassName, ': ', E.Message);
   end;
end.
