unit beammat;

// ------------------------------------------------------------------
//
//       Materialformulär
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
  TfrmMaterials = class(TForm)
    grpMaterials: TGroupBox;
    grpProperties: TGroupBox;
    lbMaterials: TListBox;
    edtE: TEdit;
    lblE: TLabel;
    lblA: TLabel;
    edtA: TEdit;
    edtI: TEdit;
    lblI: TLabel;
    btnAdd: TButton;
    btnRemove: TButton;
    btnClose: TButton;
    procedure FormShow(Sender: TObject);
    procedure btnCloseClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure lbMaterialsClick(Sender: TObject);
    procedure btnAddClick(Sender: TObject);
    procedure btnRemoveClick(Sender: TObject);
  private
    { Private declarations }
    FCurrentMaterial : integer;

    procedure FillListBoxes;
    procedure GetData;
    procedure SetData;
  public
    { Public declarations }
  end;

var
  frmMaterials: TfrmMaterials;

implementation

uses BeamModel;

{$R *.DFM}

{ TfrmMaterials }

// ------------------------------------------------------------------
// Händelser
// ------------------------------------------------------------------

procedure TfrmMaterials.FormShow(Sender: TObject);
begin

  // Fyll listboxar och sedan resten av kontrollerna.

  FillListBoxes;
  SetData;
end;

// ------------------------------------------------------------------

procedure TfrmMaterials.btnCloseClick(Sender: TObject);
begin

  // Stäng formulär.

  Self.Close;
end;

// ------------------------------------------------------------------

procedure TfrmMaterials.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin

  // Hämta data vid formulärstängning.

  GetData;
  Action:=caHide;
end;

// ------------------------------------------------------------------

procedure TfrmMaterials.lbMaterialsClick(Sender: TObject);
begin

  // Hämta nuvarande data i textrutor. Placera valt materials
  // data i textrutor.

  GetData;
  SetData;
end;

procedure TfrmMaterials.btnAddClick(Sender: TObject);
begin

  // Lägger till ett material på slutet.

  BeamModel.AddMaterial(1, 1, 1);
  FillListBoxes;
  FCurrentMaterial:=BeamModel.GetNumberOfMaterials;
  lbMaterials.ItemIndex:=FCurrentMaterial-1;
  SetData;
end;

procedure TfrmMaterials.btnRemoveClick(Sender: TObject);
begin

  // Tar bort valt material.

  BeamModel.RemoveMaterial(lbMaterials.ItemIndex+1);
  FillListBoxes;
  FCurrentMaterial:=1;
  SetData;
end;

// ------------------------------------------------------------------
// Privata metoder
// ------------------------------------------------------------------

procedure TfrmMaterials.FillListBoxes;
var
    i : integer;
begin

  // Fyller listruta med material nummer.

  lbMaterials.Clear;
  for i:=1 to BeamModel.GetNumberOfMaterials do
    lbMaterials.Items.Add(IntToStr(i));
  lbMaterials.ItemIndex:=0;
end;

// ------------------------------------------------------------------

procedure TfrmMaterials.GetData;
var
    E, A, I : double;
begin

  // Hämtar data från kontrollerna och uppdaterar valt material.

  E:=StrToFloat(edtE.Text);
  A:=StrToFloat(edtA.Text);
  I:=StrToFloat(edtI.Text);
  BeamModel.SetMaterial(FCurrentMaterial, E, A, I);
end;

// ------------------------------------------------------------------

procedure TfrmMaterials.SetData;
var
    E, A, I : double;
begin

  // Tilldelar kontroller valt materials egenskaper.

  FCurrentMaterial:=lbMaterials.ItemIndex+1;
  BeamModel.GetMaterial(FCurrentMaterial, E, A, I);
  edtE.Text:=FloatToStr(E);
  edtA.Text:=FloatToStr(A);
  edtI.Text:=FloatToStr(I);
end;

// ------------------------------------------------------------------
// ------------------------------------------------------------------


end.
