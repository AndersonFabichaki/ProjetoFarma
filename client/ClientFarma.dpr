program ClientFarma;

uses
  Vcl.Forms,
  View.Principal in '..\src\client\view\View.Principal.pas' {Form1};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
