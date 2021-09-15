unit View.Configuracao;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.Buttons;

type
  TfConfiguracao = class(TForm)
    btGravar: TSpeedButton;
    edEndereco: TEdit;
    edPorta: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    procedure FormShow(Sender: TObject);
    procedure btGravarClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  fConfiguracao: TfConfiguracao;

implementation

uses Utils.Farma, Data.DB;

{$R *.dfm}

procedure TfConfiguracao.btGravarClick(Sender: TObject);
begin
   GravaIni('Farma', 'Geral', 'Endereco', ftString, Trim(edEndereco.Text));
   GravaIni('Farma', 'Geral', 'Porta', ftInteger, LimpaInteiro(edPorta.Text));

   Close;
end;

procedure TfConfiguracao.FormShow(Sender: TObject);
begin
  edEndereco.Text := LeIni('Farma', 'Geral', 'Endereco', ftString, '127.0.0.1');
  edPorta.Text    := LeIni('Farma', 'Geral', 'Porta', ftInteger, 9000);
end;

end.
