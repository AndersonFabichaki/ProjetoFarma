program ClientFarma;

uses
  Vcl.Forms,
  View.Principal in '..\src\client\view\View.Principal.pas' {fPrincipal},
  Model.Farma in '..\src\client\model\Model.Farma.pas',
  Model.FarmaBase in '..\src\model\Model.FarmaBase.pas',
  Utils.Farma in '..\src\utils\Utils.Farma.pas',
  View.Configuracao in '..\src\client\view\View.Configuracao.pas' {fConfiguracao};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TfPrincipal, fPrincipal);
  Application.CreateForm(TfConfiguracao, fConfiguracao);
  Application.Run;
end.
