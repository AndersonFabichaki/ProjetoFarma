unit Controllers.Farma;

interface

uses Horse, Horse.Jhonson, System.SysUtils;

procedure Registry;
procedure Consultar(Req: THorseRequest; Res: THorseResponse; Next: TProc);
procedure Alterar(Req: THorseRequest; Res: THorseResponse; Next: TProc);
procedure Inserir(Req: THorseRequest; Res: THorseResponse; Next: TProc);
procedure Deletar(Req: THorseRequest; Res: THorseResponse; Next: TProc);
procedure ConsultarID(Req: THorseRequest; Res: THorseResponse; Next: TProc);
procedure Atencao(Req: THorseRequest; Res: THorseResponse; Next: TProc);

procedure EmExecucao(Horse: THorse);

implementation

uses Model.Farma, System.JSON, Data.DBXJSONReflect, DAO.Farma;

procedure Registry;
begin
   THorse.Use(Jhonson());

   THorse
      .Put('/Farma/Consultar', Consultar)
      .Post('/Farma', Alterar)
      .Put('/Farma', Inserir)
      .Get('/Farma/:pId', ConsultarID)
      .Delete('/Farma/:pId', Deletar)
      .Get('/Atencao', Atencao);

   THorse.Host := '127.0.0.1';
   THorse.Port := 9000;
   THorse.Listen(EmExecucao);
end;

procedure Consultar(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var vFarmaPesq: TModelFarmaPesquisa;
    vJReq, vJRes: TJSONObject;
    vUnMarshal: TJSONUnMarshal;
    vMarshal: TJSONMarshal;
begin
   try
      vJReq := Req.Body<TJSONObject>;

      vUnMarshal := TJSONUnMarshal.Create;
      vMarshal   := TJSONMarshal.Create;

      vFarmaPesq := vUnMarshal.Unmarshal(vJReq) as TModelFarmaPesquisa;

      if TFarmaDAO.New.Consultar(vFarmaPesq) then
      begin
         vJRes:=TJSONObject.Create;
         vJRes.AddPair('Codigo', TJSONNumber.Create(1));
         vJRes.AddPair('Result', TJSONArray.Create(vMarshal.Marshal(vFarmaPesq) as TJSONObject));
      end
      else
      begin
         vJRes:=TJSONObject.Create;
         vJRes.AddPair('Codigo', TJSONNumber.Create(0));
         vJRes.AddPair('Mensagem', vFarmaPesq.Aviso);
      end;

      Res.Send<TJSONValue>(vJRes).Status(THTTPStatus.OK);
   finally
      vUnMarshal.Free;
      vMarshal.Free;
      vFarmaPesq.Free;
   end;
end;

procedure Alterar(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var vFarma: TModelFarma;
    vJReq, vJRes: TJSONObject;
    vUnMarshal: TJSONUnMarshal;
begin
   try
      vJReq := Req.Body<TJSONObject>;

      vUnMarshal := TJSONUnMarshal.Create;

      vFarma := vUnMarshal.Unmarshal(vJReq) as TModelFarma;

      if TFarmaDAO.New.Alterar(vFarma) then
      begin
         vJRes:=TJSONObject.Create;
         vJRes.AddPair('Codigo', TJSONNumber.Create(1));
         vJRes.AddPair('Mensagem', 'Registro alterado com sucesso!');
      end
      else
      begin
         vJRes:=TJSONObject.Create;
         vJRes.AddPair('Codigo', TJSONNumber.Create(0));
         vJRes.AddPair('Mensagem', vFarma.Aviso);
      end;

      Res.Send<TJSONValue>(vJRes).Status(THTTPStatus.OK);
   finally
      vUnMarshal.Free;
      vFarma.Free;
   end;
end;

procedure Inserir(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var vFarma: TModelFarma;
    vJReq, vJRes: TJSONObject;
    vUnMarshal: TJSONUnMarshal;
begin
   try
      vJReq := Req.Body<TJSONObject>;

      vUnMarshal := TJSONUnMarshal.Create;

      vFarma := vUnMarshal.Unmarshal(vJReq) as TModelFarma;

      if TFarmaDAO.New.Gravar(vFarma) then
      begin
         vJRes:=TJSONObject.Create;
         vJRes.AddPair('Codigo', TJSONNumber.Create(1));
         vJRes.AddPair('Mensagem', 'Registro inserido com sucesso!');
      end
      else
      begin
         vJRes:=TJSONObject.Create;
         vJRes.AddPair('Codigo', TJSONNumber.Create(0));
         vJRes.AddPair('Mensagem', vFarma.Aviso);
      end;

      Res.Send<TJSONValue>(vJRes).Status(THTTPStatus.OK);
   finally
      vUnMarshal.Free;
      vFarma.Free;
   end;
end;

procedure Deletar(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var vJRes: TJSONObject;
    vAviso: string;
begin
   vJRes:=TJSONObject.Create;

   if not Req.Params.ContainsKey('pId') then
   begin
      vJRes.AddPair('Codigo', TJSONNumber.Create(0));
      vJRes.AddPair('Mensagem', 'Params pId não localizado');
   end
   else if TFarmaDAO.New.Deletar(Req.Params.Items['pId'].ToInteger, vAviso) then
   begin
      vJRes.AddPair('Codigo', TJSONNumber.Create(1));
      vJRes.AddPair('Mensagem', 'Registro excluído com sucesso!');
   end
   else
   begin
      vJRes.AddPair('Codigo', TJSONNumber.Create(0));
      vJRes.AddPair('Mensagem', vAviso);
   end;

   Res.Send<TJSONValue>(vJRes).Status(THTTPStatus.OK);
end;

procedure ConsultarID(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var vFarma: TModelFarma;
    vJRes: TJSONObject;
    vMarshal: TJSONMarshal;
begin
   try
      vJRes := TJSONObject.Create;

      vMarshal   := TJSONMarshal.Create;

      vFarma := TModelFarma.Create;

      if not Req.Params.ContainsKey('pId') then
         vFarma.Id := 0
      else
         vFarma.Id := Req.Params.Items['pId'].ToInteger;

      if TFarmaDAO.New.ConsultarID(vFarma) then
      begin
         vJRes.AddPair('Codigo', TJSONNumber.Create(1));
         vJRes.AddPair('Result', TJSONArray.Create(vMarshal.Marshal(vFarma) as TJSONObject));
      end
      else
      begin
         vJRes.AddPair('Codigo', TJSONNumber.Create(0));
         vJRes.AddPair('Mensagem', vFarma.Aviso);
      end;

      Res.Send<TJSONValue>(vJRes).Status(THTTPStatus.OK);
   finally
      vMarshal.Free;
   end;
end;

procedure Atencao(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var vJArray: TJSONArray;
    vJRes: TJSONObject;
    vAvso: string;
begin
   try
      vJRes:=TJSONObject.Create;
      vJArray := TJSONArray.Create;

      if TFarmaDAO.New.CarregarAtencoes(vJArray, vAvso) then
      begin
         vJRes.AddPair('Codigo', TJSONNumber.Create(1));
         vJRes.AddPair('Result', vJArray);
      end
      else
      begin
         vJRes.AddPair('Codigo', TJSONNumber.Create(0));
         vJRes.AddPair('Mensagem', vAvso);
      end;

      Res.Send<TJSONValue>(vJRes).Status(THTTPStatus.OK);
   finally
   end;
end;

procedure EmExecucao(Horse: THorse);
begin
   Writeln(Format('Serviço rodando em %s:%d', [Horse.Host, Horse.Port]));
end;

end.
