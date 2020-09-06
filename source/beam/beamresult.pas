unit beamresult;

// ------------------------------------------------------------------
//
//       Resultatformulär
//
//       Copyright (c) 2000 Division of Structural Mechanics
//
// ------------------------------------------------------------------
//
// Skrivet av Jonas Lindemann

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Grids;

type
  TfrmResults = class(TForm)
    stgrResults: TStringGrid;
    cboBeam: TComboBox;
    btnClose: TButton;
    lblBeam: TLabel;
    procedure FormShow(Sender: TObject);
    procedure btnCloseClick(Sender: TObject);
    procedure cboBeamChange(Sender: TObject);
  private
    { Private declarations }
    FCurrentBeam : integer;
    procedure FillListBox;
    procedure FillGrid;
  public
    { Public declarations }
  end;

var
  frmResults: TfrmResults;

implementation

{$R *.DFM}

uses BeamModel;

{ TfrmResults }

// ------------------------------------------------------------------
// Händelser
// ------------------------------------------------------------------

procedure TfrmResults.FormShow(Sender: TObject);
begin

  // Fyll combobox, och tabell.

  FillListBox;
  FillGrid;
end;

// ------------------------------------------------------------------

procedure TfrmResults.btnCloseClick(Sender: TObject);
begin

  // Stäng formuläret.

  Self.Close;
end;

// ------------------------------------------------------------------

procedure TfrmResults.cboBeamChange(Sender: TObject);
begin

  // Uppdatera tabell nät comboboxen ändras.

  FillGrid;
end;

// ------------------------------------------------------------------
// Privata metoder
// ------------------------------------------------------------------

procedure TfrmResults.FillGrid;
var
    i : integer;
    BeamLength : double;
    BeamLoad : double;
    BeamProp : integer;
begin

  // Fyller tabell med resultat.


  // Sätt rubriker

  stgrResults.Cells[0,0]:='x (m)';
  stgrResults.Cells[1,0]:='Moment (Nm)';
  stgrResults.Cells[2,0]:='Tvärkraft (N)';
  stgrResults.Cells[3,0]:='Deform. (m)';

  // Fyll med resultat

  FCurrentBeam:=cboBeam.ItemIndex+1;
  BeamModel.GetBeam(FCurrentBeam, BeamLength, BeamLoad, BeamProp);
  for i:=1 to MaxEvaluationPoints do
  begin
    stgrResults.Cells[0,i]:=format('%.4g',[(BeamLength/(MaxEvaluationPoints-1))*(i-1)]);
    stgrResults.Cells[1,i]:=format('%.4g',[BeamModel.GetMoment(FCurrentBeam,i)]);
    stgrResults.Cells[2,i]:=format('%.4g',[BeamModel.GetShearForce(FCurrentBeam,i)]);
    stgrResults.Cells[3,i]:=format('%.4g',[BeamModel.GetDeflection(FCurrentBeam,i)]);
  end;
end;

// ------------------------------------------------------------------

procedure TfrmResults.FillListBox;
var
    i : integer;
begin

  // Fyller comboboxen med innehåll.

  cboBeam.Clear;
  for i:=1 to BeamModel.GetNumberOfBeams do
    cboBeam.Items.Add(IntToStr(i));
  cboBeam.ItemIndex:=0;
end;

// ------------------------------------------------------------------
// ------------------------------------------------------------------


end.
