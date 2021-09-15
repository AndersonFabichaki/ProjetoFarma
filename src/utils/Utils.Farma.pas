unit Utils.Farma;

interface

uses Data.DB;

function LimpaTexto(Texto:String):String;
function LimpaNumero(Texto:String):String;
function LimpaInteiro(Texto:String):Integer;
function NumPonto(pValor:Variant):String;

procedure GravaIni(pArq, pGrupo, pCampo:String; pTipo:TFieldType; pDado:Variant);
function LeIni(pArq, pGrupo, pCampo:String; pTipo:TFieldType; pVPadrao:Variant):Variant;

function vlData(pData:Variant):String;

implementation

uses System.Variants, System.IniFiles, System.SysUtils;

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

end.
