unit Utils.Farma;

interface

uses Data.DB, Vcl.DBGrids;

function LimpaTexto(Texto:String):String;
function LimpaNumero(Texto:String):String;
function LimpaInteiro(Texto:String):Integer;
function NumPonto(pValor:Variant):String;
function ZeroEsquerda(pValor:Variant; pTamanho:Integer):String;

procedure GravaIni(pArq, pGrupo, pCampo:String; pTipo:TFieldType; pDado:Variant);
function LeIni(pArq, pGrupo, pCampo:String; pTipo:TFieldType; pVPadrao:Variant):Variant;

function vlData(pData:Variant):String;
function vlDataHora(pData:Variant; pHora:Variant):String;

function ObjetoToAddClientDS(pObj:TObject; pClientDS:TDataSet):Boolean;
procedure DimensionarGrid(dbg:TDbGrid; AIndiceColunaAutoAjustavel:Integer);
function EspacoDireita(pTexto:String; pTamanho:Integer):String;

implementation

uses System.Variants, System.IniFiles, System.SysUtils, System.RTTI, System.StrUtils;

function LimpaNumero(Texto:String):String;
var x:Integer;
    Limpo, vNeg:String;
begin
   Limpo:='';
   if Copy(Texto,1,1)=',' then
      Texto:='0'+Texto;

   if Copy(Texto,1,1)='-' then
      vNeg:='-'
   else
      vNeg:='';

   for x:=1 To Length(Texto) do
   begin
       if (Limpo='') and (Texto[x]='0') then
          Limpo:=''
       else if (Texto[x] in ['0'..'9',',']) then
          Limpo:=Limpo+Copy(Texto,x,1);
   end;

   if Limpo='' then
      Limpo:='0'
   else if Copy(Limpo,1,1)=',' then
      Limpo:='0'+Limpo;

   Result:=vNeg+Limpo;
end;

function NumPonto(pValor:Variant):String;
var x:Integer;
    vTxt, vNeg, vValRec:String;
begin
   vValRec:=LimpaNumero(VarToStr(pValor));

   vTxt:='';
   if Copy(vValRec,1,1)='-' then vNeg:='-'
   else vNeg:='';
   for x:=1 to Length(vValRec) do begin
       if vValRec[x] in ['0'..'9'] then vTxt:=vTxt+vValRec[x]
       else if vValRec[x]=',' then vTxt:=vTxt+'.';
   end;
   if vTxt='' then vTxt:='0';
   Result:=vNeg+vTxt;
end;

procedure GravaIni(pArq, pGrupo, pCampo:String; pTipo:TFieldType; pDado:Variant);
var ArqIni:TIniFile;
begin
  try
     ArqIni:=TIniFile.Create(ExtractFileDir(GetCurrentDir)+'\'+pArq+'.ini');

     case pTipo of
        ftInteger: ArqIni.WriteInteger(pGrupo, pCampo, pDado);
        ftBoolean: ArqIni.WriteBool(pGrupo, pCampo, pDado);
        ftDate: ArqIni.WriteDate(pGrupo, pCampo, pDado);
        ftTime: ArqIni.WriteTime(pGrupo, pCampo, pDado);
        ftFloat: ArqIni.WriteFloat(pGrupo, pCampo, pDado);
        else
           ArqIni.WriteString(pGrupo, pCampo, pDado);
     end;
  finally
     ArqIni.Free;
  end;
end;

function LeIni(pArq, pGrupo, pCampo:String; pTipo:TFieldType; pVPadrao:Variant):Variant;
var ArqIni:TIniFile;
begin
   try
      ArqIni:=TIniFile.Create(PChar(ExtractFileDir(GetCurrentDir)+'\'+pArq+'.ini'));

      case pTipo of
         ftInteger: Result:=ArqIni.ReadInteger(pGrupo, pCampo, pVPadrao);
         ftBoolean: Result:=ArqIni.ReadBool(pGrupo, pCampo, pVPadrao);
         ftDate: Result:=ArqIni.ReadDate(pGrupo, pCampo, pVPadrao);
         ftTime: Result:=ArqIni.ReadTime(pGrupo, pCampo, pVPadrao);
         ftFloat: Result:=ArqIni.ReadFloat(pGrupo, pCampo, pVPadrao);
         else
            Result:=ArqIni.ReadString(pGrupo, pCampo, pVPadrao);
      end;

   finally
     ArqIni.Free;
   end;
end;

function LimpaInteiro(Texto:String):Integer;
Var x:Integer;
    Limpo, vNeg:String;
begin
   Limpo:='';
   if Copy(Texto,1,1)=',' then
      Texto:='0'+Texto;
   if Copy(Texto,1,1)='-' then
      vNeg:='-'
   else
      vNeg:='';
   for x:=1 To Length(Texto) do
   begin
       if (Limpo='') and (Texto[x]='0') then
          Limpo:=''
       else if
          (Texto[x] in ['0'..'9']) then Limpo:=Limpo+Copy(Texto,x,1);
   end;
   if Limpo='' then
      Limpo:='0'
   else if Copy(Limpo,1,1)=',' then
      Limpo:='0'+Limpo;
   Result:=StrToInt(vNeg+Limpo);
end;

function vlData(pData:Variant):String;
var vDia, vMes, vAno: Word;
begin
   vDia:=0;
   vMes:=0;
   vAno:=0;
   try
      if (pData=null) or
         (Trim(LimpaTexto(VarToStr(pData)))='') or
         (StrToFloat(LimpaNumero(pData))=-693594) or
         (VarToStr(pData)='00/00/0000') or
         (VarToStr(pData)='30/12/1899') or
         (VarToDateTime(pData)=0) then
      begin
         Result:='';
         Exit;
      end;
      DecodeDate(VarToDateTime(pData), vAno, vMes, vDia);
      vlData:=FormatDateTime('DD/MM/YYYY',VarToDateTime(pData));
   except
      vlData:='';
   end;
end;

function LimpaTexto(Texto:String):String;
Var x:Integer;
    Limpo:String;
begin
   for x:=1 To Length(Texto) do
       if (Texto[x] in ['0'..'9']) or (Texto[x] in ['A'..'Z']) or (Texto[x] in ['a'..'z']) then Limpo:=Limpo+Texto[x];
   Result:=Limpo;
end;

function ObjetoToAddClientDS(pObj:TObject; pClientDS:TDataSet):Boolean;
var ctxRtti : TRttiContext;
    typRtti : TRttiType;
    propRtti : TRttiProperty;
    vField:TField;
begin
   ctxRtti := TRttiContext.Create;
   typRtti:=ctxRtti.GetType(pObj.ClassType);

   pClientDS.DisableControls;
   pClientDS.Append;

   // Adiciona Numero do Registro no Field;
   vField:=pClientDS.FindField('Reg');
   if vField<>nil then
      vField.Value:=pClientDS.RecordCount;

   vField:=nil;

   for propRtti in typRtti.GetProperties do
   begin
      try
         if not Assigned(propRtti) or
            (propRtti=nil) or
            (propRtti.ClassInfo=nil) or
            (propRtti.PropertyType.TypeKind=tkClass) or
            (propRtti.IsReadable=False) then
            Continue;

         vField:=pClientDS.FindField(propRtti.Name);
         if (vField=nil) {or (vField.Value <> null)} then
            Continue;

         if propRtti.PropertyType.TypeKind=tkInteger then
            vField.Value:=propRtti.GetValue(pObj).AsInteger
         else if (propRtti.PropertyType.TypeKind=tkFloat) and (propRtti.PropertyType.ToString='TDateTime') then
         begin
            if StrToDate(FormatDateTime('DD/MM/YYYY',propRtti.GetValue(pObj).AsVariant))>0 then
               vField.Value:=StrToDateTime(FormatDateTime('DD/MM/YYYY',propRtti.GetValue(pObj).AsVariant)+' '+FormatDateTime('HH:MM:SS',propRtti.GetValue(pObj).AsVariant));
         end
         else if (propRtti.PropertyType.TypeKind=tkFloat) and (propRtti.PropertyType.ToString='TDate') then
         begin
            if StrToDate(FormatDateTime('DD/MM/YYYY',propRtti.GetValue(pObj).AsVariant))>0 then
               vField.Value:=StrToDate(FormatDateTime('DD/MM/YYYY',propRtti.GetValue(pObj).AsVariant))
         end
         else if (propRtti.PropertyType.TypeKind=tkFloat) and (propRtti.PropertyType.ToString='TTime') then
            vField.Value:=StrToTime(FormatDateTime('HH:MM:SS',propRtti.GetValue(pObj).AsVariant))
         else if propRtti.PropertyType.TypeKind=tkFloat then
            vField.Value:=propRtti.GetValue(pObj).AsExtended
         else if (propRtti.PropertyType.TypeKind=tkEnumeration) and (propRtti.PropertyType.ToString='Boolean') then
            vField.Value:=propRtti.GetValue(pObj).AsBoolean
         else
            vField.Value:=propRtti.GetValue(pObj).ToString
      except
         on E:Exception do
         begin
         end;
      end;
   end;

   pClientDS.Post;
   pClientDS.EnableControls;

   ctxRtti.Free;
end;

procedure DimensionarGrid(dbg:TDbGrid; AIndiceColunaAutoAjustavel:Integer);
type
   TArray = Array of integer;
var I, vLarguraTotal, vTamanhoTotal, vLargura, vColVisivel: Integer;
    vLstLarguras, vLstTamanhos : TArray;
begin
   vColVisivel:=0;

   for i := 0 to dbg.Columns.Count - 1  do
       if dbg.Columns[i].Visible then
          Inc(vColVisivel);

   SetLength(vLstLarguras, dbg.Columns.Count);
   SetLength(vLstTamanhos, dbg.Columns.Count);
   vLarguraTotal := 0;
   vTamanhoTotal := 0;

   for I := 0 to dbg.Columns.Count - 1  do
   begin
      if not dbg.Columns[I].Visible then
         Continue;

      dbg.Columns[i].Width := dbg.Canvas.TexTWidth( Dbg.Columns[i].Title.Caption + 'A' );

      vLstLarguras[i]      := dbg.Columns[i].Width;
      vLarguraTotal        := vLarguraTotal + vLstLarguras[i];
      if i = AIndiceColunaAutoAjustavel then
         vLstTamanhos[i]   := dbg.Columns[i].Width;
      vTamanhoTotal        := vTamanhoTotal + vLstTamanhos[i];
   end;

   // se Deixar o Tamanho Zero ele Define todos os Campos com o Mesmo Tamanho
   if vTamanhoTotal=0 then
      vTamanhoTotal:=1;

   if dgColLines in dbg.Options then
      vLarguraTotal := vLarguraTotal + vColVisivel;

   {Adiciona a largura da coluna indicada do cursor}
   if dgIndicator in Dbg.Options then
      vLarguraTotal := vLarguraTotal + IndicatorWidth;

   // Se a Barra de Rolagem Vertical Não Tiver Visivel Descontar Largura da Barra de Rolagem
   if (dbg.Width-dbg.ClientWidth)<10 then
      vLarguraTotal:=vLarguraTotal+19;

   vLargura := dbg.ClienTWidth - vLarguraTotal;

   if AIndiceColunaAutoAjustavel<dbg.Columns.Count then
      dbg.Columns[AIndiceColunaAutoAjustavel].Width:=dbg.Columns[AIndiceColunaAutoAjustavel].Width + vLargura-5;
end;

function EspacoDireita(pTexto:String; pTamanho:Integer):String;
var x:Integer;
    zTexto:String;
begin
   if Length(pTexto)>pTamanho then
      Result:=LeftStr(pTexto,pTamanho)
   else
   begin
      for x:=1 to pTamanho-Length(pTexto) do
          zTexto:=zTexto+' ';
      Result:=pTexto+zTexto;
   end;
end;

function vlDataHora(pData:Variant; pHora:Variant):String;
Var Dia, Mes, Ano, hora, min, seg, mil: Word;
begin
   if (pData=null) or (StrToFloat(LimpaNumero(pData))=-693594)then
   begin
      Result:='30/12/1899 00:00:00';
      Exit;
   end;

   try
      DecodeDate(VarToDateTime(pData), Ano, Mes, Dia);
      Result:=ZeroEsquerda(Dia,2)+'/'+ZeroEsquerda(Mes,2)+'/'+ZeroEsquerda(Ano,4);
   except
      Result:='30/12/1899';
   end;

   try
      DecodeTime(VarToDateTime(pHora), hora, min, seg, mil);
      Result:=Result+' '+ZeroEsquerda(hora,2)+':'+ZeroEsquerda(min,2)+':'+ZeroEsquerda(seg,2);
   except
      Result:=Result+' 00:00:00';
   end;
end;

function ZeroEsquerda(pValor:Variant; pTamanho:Integer):String;
var x:Integer;
begin
   Result:='';

   if Length(VarToStr(pValor))>pTamanho then Result:=Copy(VarToStr(pValor),Length(VarToStr(pValor))-pTamanho+1,pTamanho)
   else begin
      for x:=1 to pTamanho-Length(VarToStr(pValor)) do
          Result:=Result+'0';
      Result:=Result+VarToStr(pValor);
   end;
end;

end.
