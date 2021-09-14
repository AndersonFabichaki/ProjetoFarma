unit Controllers.Farma;

interface

uses Horse, Horse.Jhonson, System.SysUtils;

procedure Registry;
procedure Consultar(Req: THorseRequest; Res: THorseResponse; Next: TProc);
procedure Alterar(Req: THorseRequest; Res: THorseResponse; Next: TProc);
procedure Inserir(Req: THorseRequest; Res: THorseResponse; Next: TProc);
procedure Deletar(Req: THorseRequest; Res: THorseResponse; Next: TProc);

procedure EmExecucao(Horse: THorse);

implementation

uses Model.Farma, System.JSON, Data.DBXJSONReflect;

procedure Registry;
begin
   THorse.Use(Jhonson());

   THorse
      .Get('/Farma', Consultar)
      .Post('/Farma', Alterar)
      .Put('/Farma', Inserir)
      .Delete('/Farma/:pId', Deletar);

   THorse.Host := '127.0.0.1';
   THorse.Port := 9000;
   THorse.Listen(EmExecucao);
end;

procedure Consultar(Req: THorseRequest; Res: THorseResponse; Next: TProc);
begin
   Res.Send('Consulta');
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

      if vFarma.Alterar then
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

      if vFarma.Gravar then
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
      vJRes.AddPair('Mensagem', 'Params pId não localizaco');
   end
   else if TModelFarma.Deletar(Req.Params.Items['pId'].ToInteger, vAviso) then
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

procedure EmExecucao(Horse: THorse);
begin
   Writeln(Format('Serviço rodando em %s:%d', [Horse.Host, Horse.Port]));
end;

end.
