unit View.Principal;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls;

type
  TForm1 = class(TForm)
    Memo1: TMemo;
    Button1: TButton;
    procedure Button1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

uses Model.Farma, System.JSON, Data.DBXJSONReflect, Model.FarmaBase;

{$R *.dfm}

procedure TForm1.Button1Click(Sender: TObject);
var vFarma: TModelFarma;
    vItem: TModelItensFarmaBase;
    vMar: TJSONMarshal;
    vJObj: TJSONObject;
begin
   try
      vFarma := TModelFarma.Create;
      vFarma.DataHora := Now;
      vFarma.Farmaceutico := 'Eu';
      vFarma.Paciente := 'Nos';
      vFarma.Observacao := 'teste';
      vFarma.Total := 10;

      vItem := TModelItensFarmaBase.Create;
      vItem.Tipo := 1;
      vItem.NTipo := 'seila';
      vItem.Descricao := 'hahahah';
      vItem.Total := 10;

      vFarma.OLstAtencao.Add(vItem);

      vMar := TJSONMarshal.Create;
      vJObj := vMar.Marshal(vFarma) as TJSONObject;

      Memo1.Clear;
      Memo1.Lines.Add(vJObj.ToJSON);
   finally
      vFarma.Free;
      vMar.Free;
   end;
end;

end.
