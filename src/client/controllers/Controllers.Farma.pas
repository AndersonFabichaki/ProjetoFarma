unit Controllers.Farma;

interface

uses Model.Farma, DataSnap.DBClient, Vcl.StdCtrls;

Type
   TControllerFarma = class
   private
      FFarma: TModelFarma;
   public
      constructor Create;
      destructor Destroy; override;

      class function Deletar(pId: Integer; out vAviso: string): Boolean;

      function Gravar: Boolean;
      function Alterar: Boolean;
      function Carregar(pId: Integer): Boolean;

      function CarregarAtencao(pCombo: TComboBox): Boolean;

      property Farma: TModelFarma read FFarma write FFarma;
   end;

   TControllersFarmaPesquisa = class
   private
      FFarmaPesquisa: TModelFarmaPesquisa;
   public
      constructor Create;
      destructor Destroy; override;

      function Consultar(pDs: TClientDataSet): Boolean;

      property FarmaPesquisa: TModelFarmaPesquisa read FFarmaPesquisa write FFarmaPesquisa;
   end;

implementation

uses System.SysUtils, System.JSON, Controllers.HTTPClient, REST.Types, Data.DBXJSONReflect,
     Model.FarmaBase, Utils.Farma;

{ TControllerFarma }

function TControllerFarma.Alterar: Boolean;
var vJRet: TJSONObject;
    vMar: TJSONMarshal;
    vAviso: string;
begin
   Result := False;

   try
      vMar   := TJSONMarshal.Create;

      if not TControllersHTTPClient.New
                                .PreparaHost(rmPOST)
                                .AddResource('/Farma')
                                .AddBody((vMar.Marshal(Self.Farma) as TJSONObject).ToJSON)
                                .ExecutaDS(vJRet, vAviso) then
      begin
         Self.Farma.Aviso := vAviso;
         Exit(False);
      end;

      if vJRet <> nil then
      begin
         if vJRet.GetValue('Codigo').Value.ToInteger > 0 then
            Result := True
         else
            Self.Farma.Aviso := vJRet.GetValue('Mensagem').Value;
      end
      else
         Self.Farma.Aviso := 'JSON retornou nil';
   finally
      vMar.Free;
   end;
end;

function TControllerFarma.Carregar(pId: Integer): Boolean;
var vJRet: TJSONObject;
    vUnMar: TJSONUnMarshal;
    vAviso: string;
begin
   Result := False;

   try
      vUnMar := TJSONUnMarshal.Create;

      if not TControllersHTTPClient.New
                                .PreparaHost(rmGET)
                                .AddResource('/Farma/{pId}')
                                .AddParam('pId', pId.ToString)
                                .ExecutaDS(vJRet, vAviso) then
      begin
         Self.Farma.Aviso := vAviso;
         Exit(False);
      end;

      if vJRet <> nil then
      begin
         if (vJRet.GetValue('Result') as TJSONArray).Count > 0 then
         begin
            vJRet := (vJRet.GetValue('Result') as TJSONArray).Get(0) as TJSONObject;
            Self.Farma.Free;
            Self.Farma := vUnMar.Unmarshal(vJRet) as TModelFarma;
         end;

         Result := True;
      end
      else
         Self.Farma.Aviso := 'JSON retornou nil';
   finally
      vUnMar.Free;
   end;
end;

function TControllerFarma.CarregarAtencao(pCombo: TComboBox): Boolean;
var vJRet: TJSONObject;
    vAviso: string;
    vJItem: TJSONValue;
begin
   Result := False;

   if not TControllersHTTPClient.New
                             .PreparaHost(rmGET)
                             .AddResource('/Atencao')
                             .ExecutaDS(vJRet, vAviso) then
   begin
      Self.Farma.Aviso := vAviso;
      Exit(False);
   end;

   if vJRet <> nil then
   begin
      if (vJRet.GetValue('Result') as TJSONArray).Count > 0 then
      begin
         pCombo.Clear;
         for vJItem in vJRet.GetValue('Result') as TJSONArray do
            pCombo.Items.Add((vJItem as TJSONObject).GetValue('descricao').Value);

         if pCombo.Items.Count > 0 then
            pCombo.ItemIndex := 0;
      end;

      Result := True;
   end
   else
      Self.Farma.Aviso := 'JSON retornou nil';
end;

constructor TControllerFarma.Create;
begin
   FFarma := TModelFarma.Create;
end;

class function TControllerFarma.Deletar(pId: Integer; out vAviso: string): Boolean;
var vJRet: TJSONObject;
begin
   Result := False;

   try
      if not TControllersHTTPClient.New
                                .PreparaHost(rmDELETE)
                                .AddResource('/Farma/{pId}')
                                .AddParam('pId', pId.ToString)
                                .ExecutaDS(vJRet, vAviso) then
      begin
         Exit(False);
      end;

      if vJRet <> nil then
      begin
         vAviso := vJRet.GetValue('Mensagem').Value;
         Result := True;
      end
      else
         vAviso := 'JSON retornou nil';
   finally
   end;
end;

destructor TControllerFarma.Destroy;
begin
   FreeAndNil(FFarma);
  inherited;
end;

function TControllerFarma.Gravar: Boolean;
var vJRet: TJSONObject;
    vMar: TJSONMarshal;
    vAviso: string;
begin
   Result := False;

   try
      vMar   := TJSONMarshal.Create;

      if not TControllersHTTPClient.New
                                .PreparaHost(rmPUT)
                                .AddResource('/Farma')
                                .AddBody((vMar.Marshal(Self.Farma) as TJSONObject).ToJSON)
                                .ExecutaDS(vJRet, vAviso) then
      begin
         Self.Farma.Aviso := vAviso;
         Exit(False);
      end;

      if vJRet <> nil then
      begin
         if vJRet.GetValue('Codigo').Value.ToInteger > 0 then
            Result := True
         else
            Self.Farma.Aviso := vJRet.GetValue('Mensagem').Value;
      end
      else
         Self.Farma.Aviso := 'JSON retornou nil';
   finally
      vMar.Free;
   end;
end;

{ TControllersFarmaPesquisa }

function TControllersFarmaPesquisa.Consultar(pDs: TClientDataSet): Boolean;
var vJRet: TJSONObject;
    vMar: TJSONMarshal;
    vUnMar: TJSONUnMarshal;
    vAviso: string;
    vItem: TModelFarmaBase;
begin
   Result := False;
   pDs.EmptyDataSet;

   try
      vMar   := TJSONMarshal.Create;
      vUnMar := TJSONUnMarshal.Create;

      if not TControllersHTTPClient.New
                                .PreparaHost(rmPUT)
                                .AddResource('/Farma/Consultar')
                                .AddBody((vMar.Marshal(FarmaPesquisa) as TJSONObject).ToJSON)
                                .ExecutaDS(vJRet, vAviso) then
      begin
         FarmaPesquisa.Aviso := vAviso;
         Exit(False);
      end;

      if vJRet <> nil then
      begin
         if (vJRet.GetValue('Result') as TJSONArray).Count > 0 then
         begin
            vJRet := (vJRet.GetValue('Result') as TJSONArray).Get(0) as TJSONObject;
            FarmaPesquisa.Free;
            FarmaPesquisa := vUnMar.Unmarshal(vJRet) as TModelFarmaPesquisa;

            for vItem in FarmaPesquisa.OLstFarma do
               ObjetoToAddClientDS(vItem, pDs);
         end;

         Result := True;
      end
      else
         FarmaPesquisa.Aviso := 'JSON retornou nil';
   finally
      vMar.Free;
      vUnMar.Free;
   end;
end;

constructor TControllersFarmaPesquisa.Create;
begin
   FFarmaPesquisa := TModelFarmaPesquisa.Create;
end;

destructor TControllersFarmaPesquisa.Destroy;
begin
   FreeAndNil(FFarmaPesquisa);
  inherited;
end;

end.
