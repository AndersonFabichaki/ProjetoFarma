unit Model.Farma;

interface

uses Model.FarmaBase;

Type
   TModelFarma = class (TModelFarmaBase)
   private
   public
      function Gravar: Boolean;
      function Alterar: Boolean;

      class function Deletar(pIdFarma: Integer; out pAvso: string): Boolean;
   end;

implementation

uses DAO.Farma;

{ TModelFarmaServer }

function TModelFarma.Alterar: Boolean;
begin
   Result := TFarmaDAO.New.Alterar(Self);
end;

class function TModelFarma.Deletar(pIdFarma: Integer; out pAvso: string): Boolean;
begin
   Result := TFarmaDAO.New.Deletar(pIdFarma, pAvso);
end;

function TModelFarma.Gravar: Boolean;
begin
   Result := TFarmaDAO.New.Gravar(Self);
end;

end.
