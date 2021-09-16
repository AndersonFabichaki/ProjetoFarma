unit DAO.Farma;

interface

uses Model.Farma, Model.FarmaBase, System.JSON;

Type
   iFarmaDAO = interface
      function ValidaSQLite: Boolean;
      function Gravar(pFarma: TModelFarma): Boolean;
      function Alterar(pFarma: TModelFarma): Boolean;
      function Deletar(pIdFarma: Integer; out pAvso: string): Boolean;
      function Consultar(pFarmaPesq: TModelFarmaPesquisa): Boolean;
      function CarregarAtencoes(pJsonArray: TJSONArray; out vAviso: string): Boolean;
      function ConsultarID(pFarma: TModelFarma): Boolean;
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
      function Consultar(pFarmaPesq: TModelFarmaPesquisa): Boolean;
      function CarregarAtencoes(pJsonArray: TJSONArray; out vAviso: string): Boolean;
      function ConsultarID(pFarma: TModelFarma): Boolean;
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

function TFarmaDAO.CarregarAtencoes(pJsonArray: TJSONArray; out vAviso: string): Boolean;
begin
   Result := False;

   try
      with dmGeral.sqQry, SQL do
      begin
         Close;
         Clear;
         Add('select id||'' - ''||descricao as descricao from atc_farma');
         Open;

         if not IsEmpty then
         begin
            while not Eof do
            begin
               pJsonArray.AddElement(TJSONObject.Create(TJSONPair.Create('descricao', FieldValues['descricao'])));

               Next;
            end;
         end;
      end;

      Result := True;
   except
      on E:Exception do
      begin
         Writeln(E.ClassName, ': ', E.Message);
         vAviso := E.ClassName+' - '+E.Message;
      end;
   end;
end;

function TFarmaDAO.Consultar(pFarmaPesq: TModelFarmaPesquisa): Boolean;
var vItem: TModelFarmaBase;
begin
   Result := False;
   pFarmaPesq.OLstFarma.Clear;

   try
      with dmGeral.sqQry, SQL do
      begin
         Close;
         Clear;
         Add('select id, data_hora, farmaceutico, paciente, observacao, total');
         Add(' from svc_farma');
         Add(' where 1=1');
         if vlData(pFarmaPesq.dInicio) <> '' then
            Add(' and substr(data_hora, 1, 10)>='+QuotedStr(vlData(pFarmaPesq.dInicio)));
         if vlData(pFarmaPesq.dFinal) <> '' then
            Add(' and substr(data_hora, 1, 10)<='+QuotedStr(vlData(pFarmaPesq.dFinal)));
         Open;

         if not IsEmpty then
         begin
            while not Eof do
            begin
               vItem := TModelFarmaBase.Create;
               vItem.Id           := FieldValues['id'];
               vItem.DataHora     := StrToDateTime(FieldValues['data_hora']);
               vItem.Farmaceutico := FieldValues['farmaceutico'];
               vItem.Paciente     := FieldValues['paciente'];
               vItem.Observacao   := FieldValues['observacao'];
               vItem.Total        := FieldValues['total'];

               pFarmaPesq.OLstFarma.Add(vItem);

               Next;
            end;
         end;
      end;

      Result := True;
   except
      on E:Exception do
      begin
         Writeln(E.ClassName, ': ', E.Message);
         pFarmaPesq.Aviso := E.ClassName+' - '+E.Message;
      end;
   end;
end;

function TFarmaDAO.ConsultarID(pFarma: TModelFarma): Boolean;
var vItem: TModelItensFarmaBase;
begin
   Result := False;
   pFarma.OLstAtencao.Clear;

   try
      with dmGeral.sqQry, SQL do
      begin
         Close;
         Clear;
         Add('select id, data_hora, farmaceutico, paciente');
         Add(', observacao, total');
         Add(' from svc_farma f');
         Add(' where id='+IntToStr(pFarma.Id));
         Open;

         if not IsEmpty then
         begin
            pFarma.DataHora     := StrToDateTime(FieldValues['data_hora']);
            pFarma.Farmaceutico := FieldValues['farmaceutico'];
            pFarma.Paciente     := FieldValues['paciente'];
            pFarma.Observacao   := FieldValues['observacao'];
            pFarma.Total        := FieldValues['total'];

            Close;
            Clear;
            Add('select i.id, i.descricao, i.total, i.tipo||'' - ''||a.descricao as ntipo');
            Add(', i.idfarma');
            Add(' from svc_itensfarma i');
            Add('   left join atc_farma a on (a.id=i.tipo)');
            Add(' where idfarma='+IntToStr(pFarma.Id));
            Add(' order by i.id');
            Open;

            while not Eof do
            begin
               vItem := TModelItensFarmaBase.Create;
               vItem.Id        := FieldValues['id'];
               vItem.NTipo     := FieldValues['ntipo'];
               vItem.Descricao := FieldValues['descricao'];
               vItem.Total     := FieldValues['total'];
               vItem.IdFarma   := FieldValues['idfarma'];

               pFarma.OLstAtencao.Add(vItem);

               Next;
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
      vLista.Add('insert into atc_farma (id, descricao) values (1, ''Atenção farmacêutica domiciliar'')');
      vLista.Add('insert into atc_farma (id, descricao) values (2, ''Aferição de parâmetros fisiológicos (aferição de pressão arterial (PA) e temperatura corporal)'')');
      vLista.Add('insert into atc_farma (id, descricao) values (3, ''Aferição de parâmetros bioquímico (aferição de glicemia capilar)'')');
      vLista.Add('insert into atc_farma (id, descricao) values (4, ''Administração de medicamentos (inalação e aplicação de injetáveis)'')');

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
