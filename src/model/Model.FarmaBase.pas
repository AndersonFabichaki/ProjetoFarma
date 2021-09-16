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
      procedure SetNTipo(Value: string);
   public
      function ValidaItem: string;
      property Id: Integer read FId write FId;
      property Tipo: Integer read FTipo;
      property NTipo: string read FNTipo write SetNTipo;
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

      function ValidaFarma: string;
      procedure SomaTotal;

      property Id: Integer read FId write FId;
      property DataHora: TDateTime read FDataHora write FDataHora;
      property Farmaceutico: string read FFarmaceutico write FFarmaceutico;
      property Paciente: string read FPaciente write FPaciente;
      property Observacao: string read FObservacao write FObservacao;
      property Total: Double read FTotal write FTotal;
      property OLstAtencao: TObjectList<TModelItensFarmaBase> read FOLstAtencao write FOLstAtencao;
      property Aviso: string read FAviso write FAviso;
   end;

   TModelFarmaPesquisaBase = class (TPersistent)
   private
      FdInicio: TDate;
      FdFinal: TDate;
      FAviso: string;
      FOLstFarma: TObjectList<TModelFarmaBase>;
   public
      constructor Create;
      destructor Destroy; override;

      property dInicio: TDate read FdInicio write FdInicio;
      property dFinal: TDate read FdFinal write FdFinal;
      property Aviso: string read FAviso write FAviso;
      property OLstFarma: TObjectList<TModelFarmaBase> read FOLstFarma write FOLstFarma;
   end;

implementation

uses System.SysUtils, System.StrUtils;

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

procedure TModelFarmaBase.SomaTotal;
var vItem: TModelItensFarmaBase;
begin
   Self.Total := 0;

   for vItem in Self.OLstAtencao do
      Self.Total := Self.Total + vItem.Total;
end;

function TModelFarmaBase.ValidaFarma: string;
begin
   Result := '';

   if Trim(Farmaceutico) = '' then
      Result := 'É necessário informar um Farmacêutico'
   else if Trim(Paciente) = '' then
      Result := 'É necessário informar um Paciente'
   else if Total <= 0 then
      Result := 'É necessário lançar uma ou mais atenções';
end;

{ TModelFarmaPesquisaBase }

constructor TModelFarmaPesquisaBase.Create;
begin
   FOLstFarma := TObjectList<TModelFarmaBase>.Create;
end;

destructor TModelFarmaPesquisaBase.Destroy;
begin
   FreeAndNil(FOLstFarma);
  inherited;
end;

{ TModelItensFarmaBase }

procedure TModelItensFarmaBase.SetNTipo(Value: string);
begin
   FNTipo := Value;

   FTipo := LeftStr(NTipo, 1).ToInteger;
end;

function TModelItensFarmaBase.ValidaItem: string;
begin
   Result := '';

   if NTipo = '' then
      Result := 'É necessário selecionar um tipo'
   else if Descricao = '' then
      Result := 'É necessário informar uma descrição'
   else if Total <= 0 then
      Result := 'Valor não pode ser menor ou igual a zero';
end;

end.
