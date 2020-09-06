unit main;

// ------------------------------------------------------------------
//
//       Huvudformulär för Balk program
//
//       Copyright (c) 2000 Division of Structural Mechanics
//
// ------------------------------------------------------------------
//
// Skriven av Jonas Lindemann

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ActnList, ImgList, ComCtrls, ToolWin, ExtCtrls, Menus,
  BeamModel, BeamDraw, StdCtrls;

type
  TfrmMain = class(TForm)
    actMain: TActionList;
    actNew: TAction;
    actOpen: TAction;
    actSave: TAction;
    actSaveAs: TAction;
    actExit: TAction;
    actMaterials: TAction;
    actProperties: TAction;
    actBC: TAction;
    actCalc: TAction;
    actDeflections: TAction;
    actMoments: TAction;
    actShearForces: TAction;
    mnuMain: TMainMenu;
    mnuFile: TMenuItem;
    mnuInput: TMenuItem;
    mnuResults: TMenuItem;
    mnuFileNew: TMenuItem;
    mnuFileOpen: TMenuItem;
    mnuFileSave: TMenuItem;
    mnuFileSaveAs: TMenuItem;
    mnuSeparator1: TMenuItem;
    mnuFileExit: TMenuItem;
    mnuInputMaterials: TMenuItem;
    mnuInputGeometry: TMenuItem;
    mnuInputBC: TMenuItem;
    mnuResultsDispl: TMenuItem;
    mnuResultsMoments: TMenuItem;
    mnuResultsShears: TMenuItem;
    ctlbToolbars: TControlBar;
    tlbStandard: TToolBar;
    btnNew: TToolButton;
    btnOpen: TToolButton;
    btnSave: TToolButton;
    imlMain: TImageList;
    tlbInput: TToolBar;
    btnMaterials: TToolButton;
    btnGeometry: TToolButton;
    btnBC: TToolButton;
    tlbCalc: TToolBar;
    btnExecute: TToolButton;
    bvlWorkspace: TBevel;
    actAddSegment: TAction;
    actRemoveSegment: TAction;
    btnSep1: TToolButton;
    btnAddBeam: TToolButton;
    btnRemoveBeam: TToolButton;
    edtNewLength: TEdit;
    btnSep2: TToolButton;
    dlgOpen: TOpenDialog;
    dlgSave: TSaveDialog;
    tlbResults: TToolBar;
    btnDeflections: TToolButton;
    btnMoments: TToolButton;
    btnShearForces: TToolButton;
    actNumerical: TAction;
    mnuResultNumeric: TMenuItem;
    btnNumeric: TToolButton;
    procedure FormCreate(Sender: TObject);
    procedure FormPaint(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure actPropertiesExecute(Sender: TObject);
    procedure actAddSegmentExecute(Sender: TObject);
    procedure actRemoveSegmentExecute(Sender: TObject);
    procedure actBCExecute(Sender: TObject);
    procedure actMaterialsExecute(Sender: TObject);
    procedure actNewExecute(Sender: TObject);
    procedure actOpenExecute(Sender: TObject);
    procedure actSaveAsExecute(Sender: TObject);
    procedure actSaveExecute(Sender: TObject);
    procedure actCalcExecute(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure actDeflectionsExecute(Sender: TObject);
    procedure actMomentsExecute(Sender: TObject);
    procedure actShearForcesExecute(Sender: TObject);
    procedure actNumericalExecute(Sender: TObject);
  private
    { Private declarations }
    FHaveName : boolean;
    FDirty : boolean;
    FShowMoments : boolean;
    FShowShearForces : boolean;
    FShowDeflections : boolean;
  public
    { Public declarations }
  end;

var
  frmMain: TfrmMain;

implementation

uses beamprop, beambc, beammat, beamresult;

{$R *.DFM}

// ------------------------------------------------------------------
// Formulär händelser
// ------------------------------------------------------------------

procedure TfrmMain.FormCreate(Sender: TObject);
begin

  // Skapa en först balkmodell, så det finns något att
  // se när man startar programmet.

  BeamModel.AddMaterial(1.0, 1.0, 1.0);
  BeamModel.AddBeam(4.0, 0.0, 1);
  BeamModel.SetBC(1, bcFixedDispl, 0.0, 0.0);
  BeamModel.SetBC(2, bcFixedDispl, 0.0, 0.0);
  FHaveName:=false;
  FShowMoments:=false;
  FShowDeflections:=true;
  FShowShearForces:=false;
  FDirty:=true;
end;

// ------------------------------------------------------------------

procedure TfrmMain.FormPaint(Sender: TObject);
begin

  // Uppritning av balkmodell, när formuläret ritas om.

  BeamDraw.DrawBackground(Canvas);
  BeamDraw.DrawLoads(Canvas);
  BeamDraw.DrawBCs(Canvas);
  BeamDraw.DrawGeometry(Canvas);
  BeamDraw.DrawDimensions(Canvas);
  if (not FDirty) then
  begin
    if (FShowDeflections) then
      BeamDraw.DrawDeflections(Canvas);
    if (FShowMoments) then
      BeamDraw.DrawMoments(Canvas);
    if (FShowShearForces) then
      BeamDraw.DrawShearForces(Canvas);
  end;
end;

// ------------------------------------------------------------------

procedure TfrmMain.FormResize(Sender: TObject);
begin

  // Meddela uppritnings-unit fönsterstorlek

  BeamDraw.SetDrawArea(ClientWidth, ClientHeight);
end;

// ------------------------------------------------------------------

procedure TfrmMain.FormShow(Sender: TObject);
begin

  // Meddela uppritnings-unit fönsterstorlek

  BeamDraw.SetDrawArea(ClientWidth, ClientHeight);
end;

// ------------------------------------------------------------------
// Program händelser (actions)
// ------------------------------------------------------------------

procedure TfrmMain.actPropertiesExecute(Sender: TObject);
begin

  // Visa egenskapsformuläret för balken

  frmBeamProps.ShowModal;
  FDirty:=true;
  Self.Invalidate;
end;

// ------------------------------------------------------------------

procedure TfrmMain.actAddSegmentExecute(Sender: TObject);
begin

  // Lägg till ett segment på balken (+)

  BeamModel.AddBeam(StrToFloat(edtNewLength.Text), 0.0, 1);
  SetBC(GetNumberOfBeams+1,bcFixedDispl,0.0,0.0);
  FDirty:=true;
  Self.Invalidate;
end;

// ------------------------------------------------------------------

procedure TfrmMain.actRemoveSegmentExecute(Sender: TObject);
begin

  // Ta bort ett segment (-)

  if (BeamModel.GetNumberOfBeams>1) then
     BeamModel.RemoveBeam(BeamModel.GetNumberOfBeams);
  FDirty:=true;
  Self.Invalidate;
end;

// ------------------------------------------------------------------

procedure TfrmMain.actBCExecute(Sender: TObject);
begin

  // Visa randvillkorsformulär

  frmBCs.ShowModal;
  FDirty:=true;
  Self.Invalidate;
end;

// ------------------------------------------------------------------

procedure TfrmMain.actMaterialsExecute(Sender: TObject);
begin

  // Visa materialformulär

  frmMaterials.ShowModal;
  Self.Invalidate;
end;

// ------------------------------------------------------------------

procedure TfrmMain.actNewExecute(Sender: TObject);
begin

  // Ny balkmodell

  BeamModel.NewModel;
  BeamModel.AddMaterial(1.0, 1.0, 1.0);
  BeamModel.AddBeam(4.0, 0.0, 1);
  BeamModel.SetBC(1, bcFixedDispl, 0.0, 0.0);
  BeamModel.SetBC(2, bcFixedDispl, 0.0, 0.0);
  FHaveName:=false;
  Self.Invalidate;
end;

// ------------------------------------------------------------------

procedure TfrmMain.actOpenExecute(Sender: TObject);
begin

  // Öppna balkmodell

  if dlgOpen.Execute then
  begin
    BeamModel.NewModel;
    BeamModel.SetModelName(dlgOpen.FileName);
    BeamModel.Open;
    FHaveName:=true;
    Self.Invalidate;
  end;
end;

// ------------------------------------------------------------------

procedure TfrmMain.actSaveAsExecute(Sender: TObject);
begin

  // Spara som ...

  if dlgSave.Execute then
  begin
    BeamModel.SetModelName(dlgSave.FileName);
    BeamModel.Save;
    FHaveName:=true;
  end;
end;

// ------------------------------------------------------------------

procedure TfrmMain.actSaveExecute(Sender: TObject);
begin

  // Spara

  if FHaveName then
    BeamModel.Save
  else
    begin
      actSaveAsExecute(Self);
    end;
end;

// ------------------------------------------------------------------

procedure TfrmMain.actCalcExecute(Sender: TObject);
begin

  // Utför beräkning

  BeamModel.Execute;
  FDirty:=false;
  Self.Invalidate;
end;

// ------------------------------------------------------------------

procedure TfrmMain.actDeflectionsExecute(Sender: TObject);
begin

  // Visa/dölj deformationsdiagram

  FShowDeflections:=not FShowDeflections;
  actDeflections.Checked:=FShowDeflections;
  Self.Invalidate;
end;

// ------------------------------------------------------------------

procedure TfrmMain.actMomentsExecute(Sender: TObject);
begin

  // Visa/dölj momentdiagram

  FShowMoments:=not FShowMoments;
  actMoments.Checked:=FShowMoments;
  Self.Invalidate;
end;

// ------------------------------------------------------------------

procedure TfrmMain.actShearForcesExecute(Sender: TObject);
begin

  // Visa/dölj tvärkraftsdiagram

  FShowShearForces:=not FShowShearForces;
  actShearForces.Checked:=FShowShearForces;
  Self.Invalidate;
end;

// ------------------------------------------------------------------

procedure TfrmMain.actNumericalExecute(Sender: TObject);
begin

  // Visa numeriska resultat

  if (not FDirty) then
     frmResults.ShowModal;
end;

// ------------------------------------------------------------------
// ------------------------------------------------------------------

end.
