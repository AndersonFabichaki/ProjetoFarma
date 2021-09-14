unit Model.Farma;

interface

uses Model.FarmaBase;

Type
   TModelFarma = class (TModelFarmaBase)
   private
   public
      function Gravar: Boolean;
      function Alterar: Boolean;
      function Deletar(pIdFarma: Integer; out pAvso: string): Boolean;
   end;

implementation

{ TModelFarma }

function TModelFarma.Alterar: Boolean;
begin

end;

function TModelFarma.Deletar(pIdFarma: Integer; out pAvso: string): Boolean;
begin

end;

function TModelFarma.Gravar: Boolean;
begin

end;

end.
