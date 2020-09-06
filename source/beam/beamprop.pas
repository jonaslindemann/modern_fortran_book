unit beamprop;

// ------------------------------------------------------------------
//
//       Balkegenskapsformulär
//
//       Copyright (c) 2000 Division of Structural Mechanics
//
// ------------------------------------------------------------------
//
// Skrivet av Jonas Lindemann

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls;

type
  TfrmBeamProps = class(TForm)
    grpProperties: TGroupBox;
    lblLength: TLabel;
    edtLength: TEdit;
    edtLoad: TEdit;
    lblLoad: TLabel;
    lblMaterial: TLabel;
    grpBeamSegment: TGroupBox;
    cboSegment: TComboBox;
    btnClose: TButton;
    cboMaterial: TComboBox;
    procedure FormShow(Sender: TObject);
    procedure btnCloseClick(Sender: TObject);
    procedure cboSegmentChange(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    { Private declarations }
    FCurrentBeam : integer;

    procedure SetData;
    procedure GetData;
    procedure FillListBoxes;

  public
    { Public declarations }
  end;

var
  frmBeamProps: TfrmBeamProps;

implementation

{$R *.DFM}

uses BeamModel;

// ------------------------------------------------------------------
// Händelser
// ------------------------------------------------------------------

procedure TfrmBeamProps.FormShow(Sender: TObject);
begin

  // Innan formuläret visas måste listboxarna fyllas, efter
  // detta fyller vi övriga kontroller.

  FillListBoxes;
  SetData;
end;

// ------------------------------------------------------------------

procedure TfrmBeamProps.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin

  // Innan formuläret stängs måste data i kontrollerna hämtas.

  GetData;
  Action:=caHide;
end;

// ------------------------------------------------------------------

procedure TfrmBeamProps.btnCloseClick(Sender: TObject);
begin

  // Stäng formulär.

  Self.Close;
end;

// ------------------------------------------------------------------

procedure TfrmBeamProps.cboSegmentChange(Sender: TObject);
begin

  // Vid byte av aktuellt stöd hämtar vi data från föregående
  // stöd (GetData), efter detta visas data från det aktuella
  // stödet (SetData).

  GetData;
  SetData;
end;

// ------------------------------------------------------------------
// Privata metoder
// ------------------------------------------------------------------

procedure TfrmBeamProps.FillListBoxes;
var
    i : integer;
begin

  // Fyll listbox med innehåll.

  cboSegment.Clear;
  for i:=1 to BeamModel.GetNumberOfBeams do
    cboSegment.Items.Add(IntToStr(i));
  cboSegment.ItemIndex:=0;

  cboMaterial.Clear;
  for i:=1 to BeamModel.GetNumberOfMaterials do
    cboMaterial.Items.Add(IntToStr(i));
  cboMaterial.ItemIndex:=0;
end;

// ------------------------------------------------------------------

procedure TfrmBeamProps.GetData;
var
    BeamLength : double;
    BeamLoad : double;
    BeamProp : integer;
begin

  // Hämta data från dialogruta och lagra i balkmodel.

  BeamLength:=StrToFloat(edtLength.Text);
  BeamLoad:=StrToFloat(edtLoad.Text);
  BeamProp:=cboMaterial.ItemIndex+1;
  BeamModel.SetBeam(FCurrentBeam, BeamLength, BeamLoad, BeamProp);
end;

// ------------------------------------------------------------------

procedure TfrmBeamProps.SetData;
var
    BeamLength : double;
    BeamLoad : double;
    BeamProp : integer;
begin

  // Hämta data från balkmodell och visa i dialogruta.

  FCurrentBeam:=cboSegment.ItemIndex+1;
  BeamModel.GetBeam(FCurrentBeam, BeamLength, BeamLoad, BeamProp);
  edtLength.Text:=FloatToStr(BeamLength);
  edtLoad.Text:=FloatToStr(BeamLoad);
  cboMaterial.ItemIndex:=BeamProp-1;
end;

// ------------------------------------------------------------------
// ------------------------------------------------------------------

end.
