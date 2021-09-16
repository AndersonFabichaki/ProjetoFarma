unit Controllers.HTTPClient;

interface

uses REST.Types, System.JSON, REST.Client;

Type
   iControllersHTTPClient = interface
      function PreparaHost(pMethod: TRESTRequestMethod):iControllersHTTPClient; overload;
      function AddResource(pRes:String): iControllersHTTPClient;
      function AddParam(pPrm, pValue:String): iControllersHTTPClient;
      function AddBody(pValue:String; pType:TRESTContentType = ctAPPLICATION_JSON): iControllersHTTPClient;

      function ExecutaDS(out pRet:TJSONObject; out pAvso: string):Boolean;
   end;

   TControllersHTTPClient = class(TInterfacedObject, iControllersHTTPClient)
   private
      FRESTClient: TRESTClient;
      FRESTRequest: TRESTRequest;
      FRESTResponse: TRESTResponse;
   public
      constructor Create;
      destructor Destroy; override;

      class function New: iControllersHTTPClient;

      function PreparaHost(pMethod: TRESTRequestMethod):iControllersHTTPClient; overload;
      function AddResource(pRes:String): iControllersHTTPClient;
      function AddParam(pPrm, pValue:String): iControllersHTTPClient;
      function AddBody(pValue:String; pType:TRESTContentType = ctAPPLICATION_JSON): iControllersHTTPClient;

      function ExecutaDS(out pRet:TJSONObject; out pAvso: string):Boolean;
   end;

implementation

uses System.SysUtils, Utils.Farma, Data.DB;

{ TControllersHTTPClient }

function TControllersHTTPClient.AddBody(pValue:String; pType:TRESTContentType = ctAPPLICATION_JSON): iControllersHTTPClient;
begin
   FRESTRequest.AddBody(pValue, pType);
   Result:=Self;
end;

function TControllersHTTPClient.AddParam(pPrm, pValue: String): iControllersHTTPClient;
begin
   FRESTRequest.Params.AddUrlSegment(pPrm, pValue);
   Result:=Self;
end;

function TControllersHTTPClient.AddResource(pRes: String): iControllersHTTPClient;
begin
   FRESTRequest.Resource:=pRes;
   Result:=Self;
end;

constructor TControllersHTTPClient.Create;
begin
   FRESTClient:=TRESTClient.Create('');

   FRESTResponse:=TRESTResponse.Create(nil);

   FRESTRequest:=TRESTRequest.Create(nil);
   FRESTRequest.Client:=FRESTClient;
   FRESTRequest.Response:=FRESTResponse;
end;

destructor TControllersHTTPClient.Destroy;
begin
   FreeAndNil(FRESTResponse);
   FreeAndNil(FRESTClient);
   FreeAndNil(FRESTRequest);
  inherited;
end;

function TControllersHTTPClient.ExecutaDS(out pRet:TJSONObject; out pAvso: string): Boolean;
begin
   pAvso := '';

   try
      FRESTRequest.Execute;

      if Assigned(FRESTResponse.JSONValue) then
      begin
         if FRESTResponse.StatusCode in [200, 201] then
         else
         begin
            pAvso:=FRESTResponse.StatusCode.ToString+' - '+FRESTResponse.StatusText+#13+
                   'URL: '+FRESTResponse.FullRequestURI+#13+
                   FRESTResponse.JSONText;
            Exit(False);
         end;
      end
      else
      begin
         pAvso:='E: '+FRESTResponse.StatusCode.ToString+' - '+FRESTResponse.StatusText+#13+
                 'URL: '+FRESTResponse.FullRequestURI+#13+
                 FRESTResponse.JSONText;

         Exit(False);
      end;
   except
      on E: Exception do
      begin
         pAvso:=pAvso+#13+E.Message+#13+
                 FRESTResponse.StatusCode.ToString+' - '+FRESTResponse.StatusText+#13+
                 'Content: '+FRESTResponse.Content+#13+
                 'URL: '+FRESTResponse.FullRequestURI;

         Exit(False);
      end;
   end;

   pRet:=TJSONObject.ParseJSONValue(FRESTResponse.JSONValue.ToJSON) as TJSONObject;

   FRESTClient.Disconnect;
   FRESTClient.ResetToDefaults;
   FRESTResponse.ResetToDefaults;
   FRESTRequest.ResetToDefaults;

   if (pRet.FindValue('Codigo') <> nil) and (pRet.FindValue('Codigo').Value.ToInteger = 0) then
   begin
      if pRet.FindValue('Mensagem') <> nil then
         pAvso := pRet.GetValue('Mensagem').Value
      else
         pAvso := 'Falha ao tentar se comunicar com o servidor';
      Exit(False);
   end;

   Result:=True;
end;

class function TControllersHTTPClient.New: iControllersHTTPClient;
begin
   Result := Self.Create;
end;

function TControllersHTTPClient.PreparaHost(pMethod: TRESTRequestMethod): iControllersHTTPClient;
var vHost, vPort: string;
begin
   FRESTClient.ResetToDefaults;

   FRESTRequest.ResetToDefaults;
   FRESTRequest.Timeout:=20000;

   FRESTResponse.ResetToDefaults;

   vHost := LeIni('Farma', 'Geral', 'Endereco', ftString, '127.0.0.1');
   vPort := LeIni('Farma', 'Geral', 'Porta', ftInteger, 9000);
   FRESTClient.BaseURL:='http://'+vHost+':'+vPort;

   FRESTRequest.Method:=pMethod;

   Result:=Self;
end;

end.
