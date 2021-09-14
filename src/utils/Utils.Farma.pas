unit Utils.Farma;

interface

function LimpaNumero(Texto:String):String;
function NumPonto(pValor:Variant):String;

implementation

uses System.Variants;

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

end.
