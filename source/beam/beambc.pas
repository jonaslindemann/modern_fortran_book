unit beambc;

// ------------------------------------------------------------------
//
//       Randvillkorsformulär
//
//       Copyright (c) 2000 Division of Structural Mechanics
//
// ------------------------------------------------------------------
//
// Skrivet av Jonas Lindemann

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ExtCtrls, StdCtrls, BeamModel;

type
  TfrmBCs = class(TForm)
    grpNode: TGroupBox;
    cboNode: TComboBox;
    grpBC: TGroupBox;
    btnClose: TButton;
    chkDispl: TCheckBox;
    chkRot: TCheckBox;
    edtDisplValue: TEdit;
    edtRotValue: TEdit;
    procedure FormShow(Sender: TObject);
    procedure cboNodeChange(Sender: TObject);
    procedure btnCloseClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    { Private declarations }
    FCurrentNode : integer;

    procedure FillListBoxes;
    procedure SetData;
    procedure GetData;
  public
    { Public declarations }
  end;

var
  frmBCs: TfrmBCs;

implementation

{$R *.DFM}

{ TfrmBCs }

// ------------------------------------------------------------------
// Händelser
// ------------------------------------------------------------------

procedure TfrmBCs.FormShow(Sender: TObject);
begin

  // Innan formuläret visas måste listboxarna fyllas, efter
  // detta fyller vi övriga kontroller.

  FillListBoxes;
  SetData;
end;

// ------------------------------------------------------------------

procedure TfrmBCs.FormClose(Sender: TObject; var Action: TCloseAction);
begin

  // Innan formuläret stängs måste data i kontrollerna hämtas.

  GetData;
  Action:=caHide;
end;

// ------------------------------------------------------------------

procedure TfrmBCs.cboNodeChange(Sender: TObject);
begin

  // Vid byte av aktuellt stöd hämtar vi data från föregående
  // stöd (GetData), efter detta visas data från det aktuella
  // stödet (SetData)

  GetData;
  SetData;
end;

// ------------------------------------------------------------------

procedure TfrmBCs.btnCloseClick(Sender: TObject);
begin

  // Stäng formulär

  Self.Close;
end;

// ------------------------------------------------------------------
// Privata metoder
// ------------------------------------------------------------------

procedure TfrmBCs.FillListBoxes;
var
    i : integer;
begin

  // Fyll listbox med innehåll

  cboNode.Clear;
  for i:=1 to BeamModel.GetNumberOfBeams+1 do
    cboNode.Items.Add(IntToStr(i));
  cboNode.ItemIndex:=0;
end;

// ------------------------------------------------------------------

procedure TfrmBCs.GetData;
var
    BCType : integer;
    BCDisplValue : double;
    BCRotValue : double;
begin

  // Hämta data från dialogruta och lagra i balkmodel

  BCType:=bcFixed;
  if chkDispl.Checked and chkRot.Checked then
    BCType:=bcFixed;
  if chkDispl.Checked and not chkRot.Checked then
    BCType:=bcFixedDispl;
  if not chkDispl.Checked and chkRot.Checked then
    BCType:=bcFixedRot;
  if not chkDispl.Checked and not chkRot.Checked then
    BCType:=bcFree;
  BCDisplValue:=StrToFloat(edtDisplValue.Text);
  BCRotValue:=StrToFloat(edtRotValue.Text);
  BeamModel.SetBC(FCurrentNode, BCType, BCDisplValue, BCRotValue);
end;

// ------------------------------------------------------------------

procedure TfrmBCs.SetData;
var
    BCType : integer;
    BCDisplValue : double;
    BCRotValue : double;
begin

  // Hämta data från balkmodell och visa i dialogruta

  FCurrentNode:=cboNode.ItemIndex+1;
  BeamModel.GetBC(FCurrentNode, BCType, BCDisplValue, BCRotValue);
  chkDispl.Checked:=false;
  chkRot.Checked:=false;
  case BCType of
    bcFixedDispl : chkDispl.Checked:=true;
    bcFixedRot : chkrot.Checked:=true;
    bcFixed : begin
                chkDispl.Checked:=true;
                chkrot.Checked:=true;
              end;
  end;
  edtDisplValue.Text:=FloatToStr(BCDisplValue);
  edtRotValue.Text:=FloatToStr(BCRotValue);
end;


end.
