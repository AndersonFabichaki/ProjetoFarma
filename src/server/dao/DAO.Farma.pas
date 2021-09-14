unit DAO.Farma;

interface

uses Model.Farma, Model.FarmaBase;

Type
   iFarmaDAO = interface
      function ValidaSQLite: Boolean;
      function Gravar(pFarma: TModelFarma): Boolean;
      function Alterar(pFarma: TModelFarma): Boolean;
      function Deletar(pIdFarma: Integer; out pAvso: string): Boolean;
   end;

   TFarmaDAO = class(TInterfacedObject, iFarmaDAO)
   private
      function GravarItens(pItem: TModelItensFarmaBase): Boolean;
   public
      constructor Create;
      destructor Destroy; override;

      class function New: iFarmaDAO;

      function ValidaSQLite: Boolean;
      function Gravar(pFarma: TModelFarma): Boolean;
      function Alterar(pFarma: TModelFarma): Boolean;
      function Deletar(pIdFarma: Integer; out pAvso: string): Boolean;
   end;

implementation

uses umGeral, System.Classes, System.SysUtils, Utils.Farma;

{ TFarmaDAO }

function TFarmaDAO.Alterar(pFarma: TModelFarma): Boolean;
var vItem: TModelItensFarmaBase;
begin
   Result := False;
   dmGeral.CnxSQLite.StartTransaction;

   try
      try
         with dmGeral.sqQry, SQL do
         begin
            Close;
            Clear;
            Add('update svc_farma set data_hora='+QuotedStr(FormatDateTime('DD/MM/YYYY HH:MM:SS', pFarma.DataHora)));
            Add(', farmaceutico='+QuotedStr(pFarma.Farmaceutico));
            Add(', paciente='+QuotedStr(pFarma.Paciente));
            Add(', observacao='+QuotedStr(pFarma.Observacao));
            Add(', total='+NumPonto(pFarma.Total));
            Add(' where id='+IntToStr(pFarma.Id));
            ExecSQL;

            if RowsAffected > 0 then
            begin
               Close;
               Clear;
               Add('delete from svc_itensfarma where idfarma='+IntToStr(pFarma.Id));
               ExecSQL;

               for vItem in pFarma.OLstAtencao do
               begin
                  vItem.IdFarma := pFarma.Id;

                  if not Self.GravarItens(vItem) then
                  begin
                     pFarma.Aviso := vItem.Aviso;
                     Exit(False);
                  end;
               end;
            end;
         end;

         Result := True;
      except
         on E:Exception do
         begin
            Writeln(E.ClassName, ': ', E.Message);
            pFarma.Aviso := E.ClassName+' - '+E.Message;
         end;
      end;
   finally
      if Result then
         dmGeral.CnxSQLite.Commit
      else
         dmGeral.CnxSQLite.Rollback;
   end;
end;

constructor TFarmaDAO.Create;
begin

end;

function TFarmaDAO.Deletar(pIdFarma: Integer; out pAvso: string): Boolean;
begin
   Result := False;
   dmGeral.CnxSQLite.StartTransaction;

   try
      try
         with dmGeral.sqQry, SQL do
         begin
            Close;
            Clear;
            Add('delete from svc_itensfarma where idfarma='+IntToStr(pIdFarma));
            ExecSQL;

            Close;
            Clear;
            Add('delete from svc_farma where id='+IntToStr(pIdFarma));
            ExecSQL;
         end;

         Result := True;
      except
         on E:Exception do
         begin
            Writeln(E.ClassName, ': ', E.Message);
            pAvso := E.ClassName+' - '+E.Message;
         end;
      end;
   finally
      if Result then
         dmGeral.CnxSQLite.Commit
      else
         dmGeral.CnxSQLite.Rollback;
   end;
end;

destructor TFarmaDAO.Destroy;
begin

  inherited;
end;

function TFarmaDAO.Gravar(pFarma: TModelFarma): Boolean;
var vItem: TModelItensFarmaBase;
begin
   Result := False;
   dmGeral.CnxSQLite.StartTransaction;

   try
      try
         with dmGeral.sqQry, SQL do
         begin
            Close;
            Clear;
            Add('insert into svc_farma (data_hora, farmaceutico, paciente, observacao, total) values (');
            Add(QuotedStr(FormatDateTime('DD/MM/YYYY HH:MM:SS', pFarma.DataHora)));
            Add(', '+QuotedStr(pFarma.Farmaceutico)+', '+QuotedStr(pFarma.Paciente));
            Add(', '+QuotedStr(pFarma.Observacao)+', '+NumPonto(pFarma.Total));
            Add(')');
            ExecSQL;

            Close;
            Clear;
            Add('SELECT last_insert_rowid() as id');
            Open;

            if not IsEmpty then
            begin
               pFarma.Id := FieldValues['id'];

               for vItem in pFarma.OLstAtencao do
               begin
                  vItem.IdFarma := pFarma.Id;

                  if not Self.GravarItens(vItem) then
                  begin
                     pFarma.Aviso := vItem.Aviso;
                     Exit(False);
                  end;
               end;
            end;
         end;

         Result := True;
      except
         on E:Exception do
         begin
            Writeln(E.ClassName, ': ', E.Message);
            pFarma.Aviso := E.ClassName+' - '+E.Message;
         end;
      end;
   finally
      if Result then
         dmGeral.CnxSQLite.Commit
      else
         dmGeral.CnxSQLite.Rollback;
   end;
end;

function TFarmaDAO.GravarItens(pItem: TModelItensFarmaBase): Boolean;
begin
   Result := False;
   try
      with dmGeral.sqQry, SQL do
      begin
         Close;
         Clear;
         Add('insert into svc_itensfarma (tipo, descricao, total, idfarma) values (');
         Add(IntToStr(pItem.Tipo)+', '+QuotedStr(pItem.Descricao));
         Add(', '+NumPonto(pItem.Total)+', '+IntToStr(pItem.IdFarma));
         Add(')');
         ExecSQL;

         Close;
         Clear;
         Add('SELECT last_insert_rowid() as id');
         Open;

         if not IsEmpty then
            pItem.Id := FieldValues['id'];
      end;

      Result := True;
   except
      on E:Exception do
      begin
         Writeln(E.ClassName, ': ', E.Message);
         pItem.Aviso := E.ClassName+' - '+E.Message;
      end;
   end;
end;

class function TFarmaDAO.New: iFarmaDAO;
begin
   Result := Self.Create;
end;

function TFarmaDAO.ValidaSQLite: Boolean;
var vLista:TStrings;
    x:Integer;
begin
   Result := True;

   try
      vLista:=TStringList.Create;

      vLista.Add('create table atc_farma (id integer primary key autoincrement)');
      vLista.Add('alter table atc_farma add column descricao varchar(120)');
      vLista.Add('insert into atc_farma (id, descricao) values (1, ''Aten��o farmac�utica domiciliar'')');
      vLista.Add('insert into atc_farma (id, descricao) values (2, ''Aferi��o de par�metros fisiol�gicos (aferi��o de press�o arterial (PA) e temperatura corporal)'')');
      vLista.Add('insert into atc_farma (id, descricao) values (3, ''Aferi��o de par�metros bioqu�mico (aferi��o de glicemia capilar)'')');
      vLista.Add('insert into atc_farma (id, descricao) values (4, ''Administra��o de medicamentos (inala��o e aplica��o de injet�veis)'')');

      vLista.Add('create table svc_farma (id integer primary key autoincrement)');
      vLista.Add('alter table svc_farma add column data_hora varchar(30)');
      vLista.Add('alter table svc_farma add column farmaceutico varchar(100)');
      vLista.Add('alter table svc_farma add column paciente varchar(100)');
      vLista.Add('alter table svc_farma add column observacao text');
      vLista.Add('alter table svc_farma add column total numeric(15,2)');

      vLista.Add('create table svc_itensfarma (id integer primary key autoincrement)');
      vLista.Add('alter table svc_itensfarma add column tipo integer references atc_farma(id)');
      vLista.Add('alter table svc_itensfarma add column descricao text');
      vLista.Add('alter table svc_itensfarma add column total numeric(15,2)');
      vLista.Add('alter table svc_itensfarma add column idfarma integer references svc_farma(id)');

      for x:=0 to vLista.Count-1 do
      begin
         dmGeral.sqQry.Close;
         dmGeral.sqQry.SQL.Clear;
         dmGeral.sqQry.SQL.Add(vLista.Strings[x]);
         try
            dmGeral.sqQry.ExecSQL;
         except
         end;
      end;
   finally
      vLista.Free;
   end;
end;

end.