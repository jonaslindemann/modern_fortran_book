unit main;

interface

uses
  Windows, Messages, SysUtils, Classes,
  Graphics, Controls, Forms, Dialogs,
  StdCtrls, math, fmath;

type
  TfrmMain = class(TForm)
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    edtX: TEdit;
    edtY: TEdit;
    edtResult: TEdit;
    btnCalc: TButton;
    procedure btnCalcClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmMain: TfrmMain;

implementation

{$R *.DFM}

procedure TfrmMain.btnCalcClick(Sender: TObject);
var
    x, y, angle : double;
begin

  // Hämta värden från kontroller

  try
    x:=StrToFloat(edtX.Text);
    y:=StrToFloat(edtY.Text);
  except
    ShowMessage('Felaktiga värden angivna');
    exit;
  end;

  // Anropa DLL

  vatan2(y, x, angle);

  // Returnera värde till result

  edtResult.Text:=format('%g',[angle]);
end;

end.
