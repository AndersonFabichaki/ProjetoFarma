unit View.Principal;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Data.DB, Vcl.Grids, Vcl.DBGrids, Vcl.ExtCtrls, Vcl.Buttons, EGrad, Vcl.WinXPickers;

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
    procedure FormShow(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure btConfiguracaoClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  fPrincipal: TfPrincipal;

implementation

uses Utils.Farma, View.Configuracao;

{$R *.dfm}

procedure TfPrincipal.btConfiguracaoClick(Sender: TObject);
begin
   fConfiguracao := TfConfiguracao.Create(Self);
   fConfiguracao.ShowModal;

   Self.FormShow(Self);
end;

procedure TfPrincipal.FormCreate(Sender: TObject);
begin
//
end;

procedure TfPrincipal.FormDestroy(Sender: TObject);
begin
//
end;

procedure TfPrincipal.FormShow(Sender: TObject);
begin
   aEndereco.Caption := LeIni('Farma', 'Geral', 'Endereco', ftString, '127.0.0.1');
   aPorta.Caption    := LeIni('Farma', 'Geral', 'Porta', ftInteger, 9000);
   dpInicio.Date     := Date;
   dpFinal.Date      := Date;
end;

end.
