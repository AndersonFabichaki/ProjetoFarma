unit Model.FarmaBase;

interface

uses System.Generics.Collections, System.Classes;

Type
   TModelItensFarmaBase = class
   private
      FId: Integer;
      FTipo: Integer;
      FNTipo: string;
      FDescricao: string;
      FTotal: Double;
      FIdFarma: Integer;
      FAviso: string;
   public
      property Id: Integer read FId write FId;
      property Tipo: Integer read FTipo write FTipo;
      property NTipo: string read FNTipo write FNTipo;
      property Descricao: string read FDescricao write FDescricao;
      property Total: Double read FTotal write FTotal;
      property IdFarma: Integer read FIdFarma write FIdFarma;
      property Aviso: string read FAviso write FAviso;
   end;

   TModelFarmaBase = class (TPersistent)
   private
      FId: Integer;
      FDataHora: TDateTime;
      FFarmaceutico: string;
      FPaciente: string;
      FObservacao: string;
      FTotal: Double;
      FOLstAtencao: TObjectList<TModelItensFarmaBase>;
      FAviso: string;
   public
      constructor Create;
      destructor Destroy; override;

      property Id: Integer read FId write FId;
      property DataHora: TDateTime read FDataHora write FDataHora;
      property Farmaceutico: string read FFarmaceutico write FFarmaceutico;
      property Paciente: string read FPaciente write FPaciente;
      property Observacao: string read FObservacao write FObservacao;
      property Total: Double read FTotal write FTotal;
      property OLstAtencao: TObjectList<TModelItensFarmaBase> read FOLstAtencao write FOLstAtencao;
      property Aviso: string read FAviso write FAviso;
   end;

implementation

uses System.SysUtils;

{ TModelFarma }

constructor TModelFarmaBase.Create;
begin
   FOLstAtencao := TObjectList<TModelItensFarmaBase>.Create;
end;

destructor TModelFarmaBase.Destroy;
begin
   FreeAndNil(FOLstAtencao);
  inherited;
end;

end.
