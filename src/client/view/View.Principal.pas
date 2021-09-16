unit View.Principal;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Data.DB, Vcl.Grids, Vcl.DBGrids, Vcl.ExtCtrls,
  Vcl.Buttons, EGrad, Vcl.WinXPickers, DataSnap.DBClient, Vcl.Menus;

type
  TfPrincipal = class(TForm)
    EvGradient5: TEvGradient;
    Bevel6: TBevel;
    btConfiguracao: TSpeedButton;
    btPesquisar: TSpeedButton;
    btInserir: TSpeedButton;
    Panel1: TPanel;
    gLista: TDBGrid;
    gbConfig: TGroupBox;
    aEndereco: TStaticText;
    aPorta: TStaticText;
    Label1: TLabel;
    Label2: TLabel;
    gbPesquisa: TGroupBox;
    dpInicio: TDatePicker;
    dpFinal: TDatePicker;
    Label3: TLabel;
    Label4: TLabel;
    dsLista: TDataSource;
    Label5: TLabel;
    pmLista: TPopupMenu;
    btAlterar: TMenuItem;
    btExcluir: TMenuItem;
    procedure FormShow(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure btConfiguracaoClick(Sender: TObject);
    procedure btPesquisarClick(Sender: TObject);
    procedure btExcluirClick(Sender: TObject);
    procedure btInserirClick(Sender: TObject);
    procedure btAlterarClick(Sender: TObject);
  private
    LstFarma: TClientDataSet;
    procedure LancaFarma(pId: Integer);
  public
    { Public declarations }
  end;

var
  fPrincipal: TfPrincipal;

implementation

uses Utils.Farma, View.Configuracao, Controllers.Farma, View.LancaFarma;

{$R *.dfm}

procedure TfPrincipal.btAlterarClick(Sender: TObject);
begin
   if LstFarma.IsEmpty then
      Exit;

   LancaFarma(LstFarma.FieldValues['id']);
end;

procedure TfPrincipal.btConfiguracaoClick(Sender: TObject);
begin
   fConfiguracao := TfConfiguracao.Create(Self);
   fConfiguracao.ShowModal;
   fConfiguracao.Free;

   Self.FormShow(Self);
end;

procedure TfPrincipal.btExcluirClick(Sender: TObject);
var vAvso: string;
begin
   if LstFarma.IsEmpty then
      Exit;

   if Application.MessageBox('Deseja realmente excluir o registro?','Exclusão', MB_YESNO+MB_ICONQUESTION+MB_DEFBUTTON2)=IDNO then
      Exit;

   TControllerFarma.Deletar(LstFarma.FieldValues['id'], vAvso);
   ShowMessage(vAvso);
   btPesquisarClick(Self);
end;

procedure TfPrincipal.btInserirClick(Sender: TObject);
begin
   LancaFarma(0);
end;

procedure TfPrincipal.btPesquisarClick(Sender: TObject);
var ControllersPesquisa: TControllersFarmaPesquisa;
begin
   try
      ControllersPesquisa := TControllersFarmaPesquisa.Create;
      ControllersPesquisa.FarmaPesquisa.dInicio := dpInicio.Date;
      ControllersPesquisa.FarmaPesquisa.dFinal  := dpFinal.Date;

      if not ControllersPesquisa.Consultar(LstFarma) then
         ShowMessage(ControllersPesquisa.FarmaPesquisa.Aviso);
   finally
      ControllersPesquisa.Free;
   end;
end;

procedure TfPrincipal.FormCreate(Sender: TObject);
begin
   LstFarma := TClientDataSet.Create(Self);
   with LstFarma do
   begin
      FieldDefs.Add('id', ftInteger);
      FieldDefs.Add('datahora', ftDateTime);
      FieldDefs.Add('farmaceutico', ftString, 100);
      FieldDefs.Add('paciente', ftString, 100);
      FieldDefs.Add('observacao', ftString, 300);
      FieldDefs.Add('total', ftFloat);
      CreateDataSet;
      Fields.Fields[0].DisplayLabel := 'Controle';
      Fields.Fields[1].DisplayLabel := EspacoDireita('Data/Hora',26);
      Fields.Fields[2].DisplayLabel := EspacoDireita('Farmaceutico',50);
      Fields.Fields[3].DisplayLabel := 'Paciente';
      Fields.Fields[4].DisplayLabel := EspacoDireita('Observação',50);
      Fields.Fields[5].DisplayLabel := EspacoDireita('Total',15);
      TFloatField(Fields.Fields[5]).DisplayFormat := '#,##0.00';
   end;
end;

procedure TfPrincipal.FormDestroy(Sender: TObject);
begin
   LstFarma.Free;
end;

procedure TfPrincipal.FormShow(Sender: TObject);
begin
   dsLista.DataSet := LstFarma;
   DimensionarGrid(gLista, 3);

   aEndereco.Caption := LeIni('Farma', 'Geral', 'Endereco', ftString, '127.0.0.1');
   aPorta.Caption    := LeIni('Farma', 'Geral', 'Porta', ftInteger, 9000);
   dpInicio.Date     := Date-5;
   dpFinal.Date      := Date;
end;

procedure TfPrincipal.LancaFarma(pId: Integer);
begin
   try
      fLancaFarma := TfLancaFarma.Create(Self, pId);
      fLancaFarma.ShowModal;
   finally
      fLancaFarma.Free;
      btPesquisarClick(Self);
   end;
end;

end.
