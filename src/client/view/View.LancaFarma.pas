unit View.LancaFarma;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.Buttons, Vcl.ExtCtrls, EGrad, Controllers.Farma, Vcl.StdCtrls,
  Vcl.WinXPickers, Data.DB, Vcl.Grids, Vcl.DBGrids, Vcl.Menus, Vcl.Mask, RxToolEdit, RxCurrEdit,
  DataSnap.DBClient;

type
  TfLancaFarma = class(TForm)
    EvGradient5: TEvGradient;
    Bevel6: TBevel;
    btGravar: TSpeedButton;
    btAbandonar: TSpeedButton;
    Panel1: TPanel;
    dpInicio: TDatePicker;
    edFarmaceutico: TEdit;
    edPaciente: TEdit;
    edObserv: TEdit;
    Panel2: TPanel;
    lbTotal: TLabel;
    Label3: TLabel;
    Label2: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Panel3: TPanel;
    gLista: TDBGrid;
    dsLista: TDataSource;
    pmLista: TPopupMenu;
    btExcluir: TMenuItem;
    cbTipo: TComboBox;
    edDescricao: TEdit;
    Label1: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    ceValor: TCurrencyEdit;
    btInserir: TSpeedButton;
    Label8: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure btAbandonarClick(Sender: TObject);
    procedure FormKeyPress(Sender: TObject; var Key: Char);
    procedure btInserirClick(Sender: TObject);
    procedure btExcluirClick(Sender: TObject);
    procedure btGravarClick(Sender: TObject);
    procedure ceValorKeyPress(Sender: TObject; var Key: Char);
  private
    vIdFarma: Integer;
    ControllersFarma: TControllerFarma;
    LstAtencao: TClientDataSet;

    procedure ApsFarma;
    procedure ApsItens;
    procedure LimpaLancItem;
  public
    constructor Create(AOwner: TComponent; pId: Integer);
  end;

var
  fLancaFarma: TfLancaFarma;

implementation

uses Model.FarmaBase, Utils.Farma;

{$R *.dfm}

procedure TfLancaFarma.ApsFarma;
begin
   dpInicio.Date       := ControllersFarma.Farma.DataHora;
   edFarmaceutico.Text := ControllersFarma.Farma.Farmaceutico;
   edPaciente.Text     := ControllersFarma.Farma.Paciente;
   edObserv.Text       := ControllersFarma.Farma.Observacao;
end;

procedure TfLancaFarma.ApsItens;
var vItem: TModelItensFarmaBase;
begin
   LstAtencao.EmptyDataSet;

   for vItem in ControllersFarma.Farma.OLstAtencao do
      ObjetoToAddClientDS(vItem, LstAtencao);

   LstAtencao.First;

   ControllersFarma.Farma.SomaTotal;
   lbTotal.Caption := 'Total: '+FormatFloat('###,###,###,##0.00', ControllersFarma.Farma.Total);
end;

procedure TfLancaFarma.btAbandonarClick(Sender: TObject);
begin
   if Application.MessageBox('Deseja realmente abandonar o lançamento?','Lançamento', MB_YESNO+MB_ICONQUESTION+MB_DEFBUTTON2)=IDYES then
      Close;
end;

procedure TfLancaFarma.btExcluirClick(Sender: TObject);
begin
   if LstAtencao.IsEmpty then
      Exit;

   ControllersFarma.Farma.OLstAtencao.Delete(LstAtencao.FieldValues['reg']);
   ApsItens;
end;

procedure TfLancaFarma.btGravarClick(Sender: TObject);
var vResult: Boolean;
    vAviso: string;
begin
   ControllersFarma.Farma.DataHora     := StrToDateTime(vlDataHora(dpInicio.Date, Time));
   ControllersFarma.Farma.Farmaceutico := edFarmaceutico.Text;
   ControllersFarma.Farma.Paciente     := edPaciente.Text;
   ControllersFarma.Farma.Observacao   := edObserv.Text;

   vAviso := ControllersFarma.Farma.ValidaFarma;

   if vAviso = '' then
   begin
      if ControllersFarma.Farma.Id > 0 then
         vResult := ControllersFarma.Alterar
      else
         vResult := ControllersFarma.Gravar;

      if vResult then
         Close;
   end
   else
      ShowMessage(vAviso);
end;

procedure TfLancaFarma.btInserirClick(Sender: TObject);
var vItem: TModelItensFarmaBase;
    vAviso: string;
begin
   vItem := TModelItensFarmaBase.Create;
   vItem.NTipo     := cbTipo.Text;
   vItem.Descricao := edDescricao.Text;
   vItem.Total     := ceValor.Value;
   vAviso          := vItem.ValidaItem;

   if vAviso <> '' then
   begin
      ShowMessage(vAviso);
      vItem.Free;
   end
   else
   begin
      ControllersFarma.Farma.OLstAtencao.Add(vItem);
      ApsItens;
      LimpaLancItem;
   end;
end;

procedure TfLancaFarma.ceValorKeyPress(Sender: TObject; var Key: Char);
begin
   if Key = #13 then
      btInserirClick(Self);
end;

constructor TfLancaFarma.Create(AOwner: TComponent; pId: Integer);
begin
  inherited Create(AOwner);
   vIdFarma := pId;
   ControllersFarma := TControllerFarma.Create;
end;

procedure TfLancaFarma.FormCreate(Sender: TObject);
begin
   LstAtencao := TClientDataSet.Create(Self);
   with LstAtencao do
   begin
      FieldDefs.Add('ntipo', ftString, 100);
      FieldDefs.Add('descricao', ftString, 200);
      FieldDefs.Add('total', ftFloat);
      FieldDefs.Add('reg', ftInteger);
      CreateDataSet;
      Fields.Fields[0].DisplayLabel := EspacoDireita('Tipo',50);
      Fields.Fields[1].DisplayLabel := 'Descrição';
      Fields.Fields[2].DisplayLabel := EspacoDireita('Total',15);
      TFloatField(Fields.Fields[2]).DisplayFormat := '#,##0.00';
      Fields.Fields[3].Visible := False;
   end;
end;

procedure TfLancaFarma.FormDestroy(Sender: TObject);
begin
   LstAtencao.Free;
   ControllersFarma.Free;
end;

procedure TfLancaFarma.FormKeyPress(Sender: TObject; var Key: Char);
begin
   if key=#13 then
   begin
      if ActiveControl<>nil then
      begin
         if TComponent(ActiveControl).Name ='ceValor' then
            Exit;
      end;
      key:=#0;
      Perform(wm_nextDlgCtl,0,0);
   end;
end;

procedure TfLancaFarma.FormShow(Sender: TObject);
begin
   dsLista.DataSet := LstAtencao;
   DimensionarGrid(gLista, 1);

   if not ControllersFarma.CarregarAtencao(cbTipo) then
      ShowMessage(ControllersFarma.Farma.Aviso);

   if vIdFarma > 0 then
   begin
      if not ControllersFarma.Carregar(vIdFarma) then
      begin
         ShowMessage(ControllersFarma.Farma.Aviso);
         Close;
      end;
   end
   else
      ControllersFarma.Farma.DataHora := Now;

   ApsFarma;
   ApsItens;
   edFarmaceutico.SetFocus;
end;

procedure TfLancaFarma.LimpaLancItem;
begin
   cbTipo.ItemIndex := 0;
   edDescricao.Text := '';
   ceValor.Value    := 0;
   cbTipo.SetFocus;
end;

end.
