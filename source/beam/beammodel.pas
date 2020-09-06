unit beammodel;

// ------------------------------------------------------------------
//
//       Balkmodell-unit
//
//       Copyright (c) 2000 Division of Structural Mechanics
//
// ------------------------------------------------------------------
//
// Skriven av Jonas Lindemann

interface

// ------------------------------------------------------------------
// Tillgängliga deklarationer
// ------------------------------------------------------------------

const

    // Randvillkorstyper

    bcFree       = 0;
    bcFixedRot   = 1;
    bcFixedDispl = 2;
    bcFixed      = 3;

const

    // Vi använder ett fixt antal balkar för enkelhetens skull

    MaxBeams = 30;
    MaxMaterials = 30;
    MaxBCs = 30;
    MaxDofs = (MaxBeams+1)*2;
    MaxEvaluationPoints = 20;

type

    TDoubleBeamVector   = array [1..MaxBeams] of double;
    TIntBeamVector      = array [1..MaxBeams] of integer;
    TDoubleBCVector     = array [1..MaxBeams+1] of double;
    TIntBCVector        = array [1..MaxBeams+1] of integer;
    TMaterialMatrix     = array [1..MaxMaterials, 1..3] of double;
    TDisplacementVector = array [1..MaxDofs] of double;
    TReactionVector     = array [1..MaxDofs] of double;
    TResultMatrix       = array [1..MaxBeams, 1..MaxEvaluationPoints] of double;

// ------------------------------------------------------------------
// Tillgängliga rutiner
// ------------------------------------------------------------------

// Materialhantering

procedure AddMaterial(E, A, I : double);
procedure RemoveMaterial(idx : integer);
procedure SetMaterial(idx : integer; E, A, I : double);
procedure GetMaterial(idx : integer; var E, A, I : double);
function GetNumberOfMaterials : integer;

// Balk

procedure AddBeam(l, q : double; material : integer);
procedure RemoveBeam(idx : integer);
procedure SetBeam(idx : integer; l, q : double; material : integer);
procedure GetBeam(idx : integer; var l,q : double; var material : integer);
function GetNumberOfBeams : integer;
function GetTotalLength : double;

// Randvillkor

procedure SetBC(idx : integer; bcType : integer; bcDisplValue, bcRotValue : double);
procedure GetBC(idx : integer; var bcType : integer; var bcDisplValue, bcRotValue : double);
function GetNodePos(idx : integer) : double;

// Resultat

function GetMoment(BeamIdx, PointIdx : integer) : double;
function GetDeflection(BeamIdx, PointIdx : integer) : double;
function GetShearForce(BeamIdx, PointIdx : integer) : double;
function GetMaxDeflection : double;
function GetMaxMoment : double;
function GetMaxShearForce : double;

// Modell

procedure SetModelName(FileName : string);
function GetModelName : string;
procedure NewModel;

procedure Save;
procedure Open;
procedure Execute;

// ------------------------------------------------------------------
// ------------------------------------------------------------------

implementation

// ------------------------------------------------------------------
// ------------------------------------------------------------------

uses
    SysUtils, BeamCalc;

var

    // Variabler för balkmodell

    ModelName          : string;

    NumberOfBeams      : integer;
    NumberOfMaterials  : integer;

    BeamLengths        : TDoubleBeamVector;
    BeamLoads          : TDoubleBeamVector;
    BeamProps          : TIntBeamVector;
    BeamLength         : double;

    BCTypes            : TIntBCVector;
    BCDisplValues      : TDoubleBCVector;
    BCRotValues        : TDoubleBCVector;
    BCPositions        : TDoubleBCVector;

    Materials          : TMaterialMatrix;

    Reaction           : TReactionVector;
    Displacement       : TDisplacementVector;
    ShearForces        : TResultMatrix;
    Moments            : TResultMatrix;
    Deflections        : TResultMatrix;
    MaxDeflection      : double;
    MaxMoment          : double;
    MaxShearForce      : double;

// ------------------------------------------------------------------
// ------------------------------------------------------------------

procedure Init;
begin

  // Initiera modell variabler

  NumberOfBeams:=0;
  NumberOfMaterials:=0;

  ModelName:='Noname.bml';

  MaxMoment:=-1e300;
  MaxDeflection:=-1e300;
  MaxShearForce:=-1e300;
end;

// ------------------------------------------------------------------

procedure AddMaterial(E, A, I : double);
begin

  // Lägg till ett material

  inc(NumberOfMaterials);
  Materials[NumberOfMaterials, 1] := E;
  Materials[NumberOfMaterials, 2] := A;
  Materials[NumberOfMaterials, 3] := I;
end;

// ------------------------------------------------------------------

procedure RemoveMaterial(idx : integer);
var
    i : integer;
begin

  // Tar bort material på platsen idx

  if (idx>0) and (idx<=NumberOfMaterials) then
  begin
    for i:=idx+1 to NumberOfMaterials do
    begin
      Materials[i-1,1]:=Materials[i,1];
      Materials[i-1,2]:=Materials[i,2];
      Materials[i-1,3]:=Materials[i,3];
    end;
    dec(NumberOfMaterials);
  end;
end;

// ------------------------------------------------------------------

procedure SetMaterial(idx : integer; E, A, I : double);
begin

  // Ändra material

  if (idx>0) and (idx<=NumberOfMaterials) then
  begin
    Materials[idx,1]:=E;
    Materials[idx,2]:=A;
    Materials[idx,3]:=I;
  end;
end;

// ------------------------------------------------------------------

procedure GetMaterial(idx : integer; var E, A, I : double);
begin

  // Returnera material egenskaper

  if (idx>0) and (idx<=NumberOfMaterials) then
  begin
    E := Materials[idx,1];
    A := Materials[idx,2];
    I := Materials[idx,3];
  end;
end;

// ------------------------------------------------------------------

function GetNumberOfMaterials : integer;
begin

  // Returnera antalet material

  Result:=NumberOfMaterials;
end;

// ------------------------------------------------------------------

procedure ReCalcLength;
var
    i : integer;
    l : double;
begin

  // Beräkna balkens totallängd

  l:=0;
  BCPositions[1]:=l;
  for i:=1 to NumberOfBeams do
  begin
    l:=l + BeamLengths[i];
    BCPositions[i+1]:=l;
  end;
  BeamLength:=l;
end;

// ------------------------------------------------------------------

procedure AddBeam(l, q : double; material : integer);
begin

  // Lägg till balk

  inc(NumberOfBeams);
  BeamLengths[NumberOfBeams]:=l;
  BeamLoads[NumberOfBeams]:=q;
  BeamProps[NumberOfBeams]:=material;
  ReCalcLength;
end;

// ------------------------------------------------------------------

procedure RemoveBeam(idx : integer);
var
    i : integer;
begin

  // Ta bort balk

  if (idx>0) and (idx<=NumberOfBeams) then
  begin
    for i:=idx+1 to NumberOfBeams do
    begin
      BeamLengths[i-1]:=BeamLengths[i];
      BeamLoads[i-1]:=BeamLoads[i];
      BeamProps[i-1]:=BeamProps[i];
    end;
    dec(NumberOfBeams);
    ReCalcLength;
  end;
end;

// ------------------------------------------------------------------

procedure SetBeam(idx : integer; l, q : double; material : integer);
begin

  // Ändra balkegenskaper

  if (idx>0) and (idx<=NumberOfBeams) then
  begin
    BeamLengths[idx]:=l;
    BeamLoads[idx]:=q;
    BeamProps[idx]:=material;
    ReCalcLength;
  end;
end;

// ------------------------------------------------------------------

procedure GetBeam(idx : integer; var l,q : double; var material : integer);
begin

  // Returnera balkegenskaper

  if (idx>0) and (idx<=NumberOfBeams) then
  begin
    l:=BeamLengths[idx];
    q:=BeamLoads[idx];
    material:=BeamProps[idx];
  end;
end;

// ------------------------------------------------------------------

function GetNumberOfBeams : integer;
begin

  // Returnera antalet balkar

  Result:=NumberOfBeams;
end;

// ------------------------------------------------------------------

function GetTotalLength : double;
begin
  Result:=BeamLength;
end;

// ------------------------------------------------------------------

procedure SetBC(idx : integer; bcType : integer; bcDisplValue, bcRotValue : double);
begin

  // Ändra randvillkor

  if (idx>0) and (idx<=NumberOfBeams+1) then
  begin
    BCTypes[idx]:=bcType;
    BCDisplValues[idx]:=bcDisplValue;
    BCRotValues[idx]:=bcRotValue;
  end;
end;

// ------------------------------------------------------------------

procedure GetBC(idx : integer; var bcType : integer; var bcDisplValue, bcRotValue : double);
begin

  // Returnera randvillkor

  if (idx>0) and (idx<=NumberOfBeams+1) then
  begin
    bcType:=BCTypes[idx];
    bcDisplValue:=BCDisplValues[idx];
    bcRotValue:=BCRotValues[idx];
  end;
end;

// ------------------------------------------------------------------

function GetNumberOfBCs : integer;
begin

  // Returnera antalet randvillkor

  Result:=NumberOfBeams+1;
end;

// ------------------------------------------------------------------

function GetNodePos(idx : integer) : double;
begin

  // Returnera position för ett visst stöd

  if (idx>0) and (idx<=NumberOfBeams+1) then
    Result:=BCPositions[idx]
  else
    Result:=-1;
end;

// ------------------------------------------------------------------

procedure SetModelName(FileName : string);
begin

  // Sätt namn på balkmodell (filnamn)

  ModelName:=FileName;
end;

// ------------------------------------------------------------------

function GetModelName : string;
begin

  // Returnera balkmodellens filnamn

  Result:=ModelName;
end;

// ------------------------------------------------------------------

procedure NewModel;
begin

  // Skapa en ny modell

  Init;
end;

// ------------------------------------------------------------------

procedure Save;
var
    f : TextFile;
    i : integer;
begin

  // Spara balkmodell till fil

  AssignFile(f, ModelName);
  Rewrite(f);

  writeln(f, NumberOfMaterials);

  for i:=1 to NumberOfMaterials do
    writeln(f,
      format('%g %g %g',[Materials[i,1], Materials[i,2], Materials[i,3]]));

  writeln(f, NumberOfBeams);

  for i:=1 to NumberOfBeams do
    writeln(f,
      format('%g %g %d',[BeamLengths[i], BeamLoads[i], BeamProps[i]]));

  for i:=1 to NumberOfBeams+1 do
    writeln(f,
      format('%d %g %g',[BCTypes[i], BCDisplValues[i], BCRotValues[i]]));

  CloseFile(f);
end;

// ------------------------------------------------------------------

procedure Open;
var
    f : TextFile;
    i : integer;
begin

  // Öppna balkmodell

  AssignFile(f, ModelName);
  Reset(f);

  readln(f, NumberOfMaterials);

  for i:=1 to NumberOfMaterials do
    readln(f,Materials[i,1], Materials[i,2], Materials[i,3]);

  readln(f, NumberOfBeams);

  for i:=1 to NumberOfBeams do
    readln(f,BeamLengths[i], BeamLoads[i], BeamProps[i]);

  for i:=1 to NumberOfBeams+1 do
    readln(f,BCTypes[i], BCDisplValues[i], BCRotValues[i]);

  CloseFile(f);

  ReCalcLength;
end;

// ------------------------------------------------------------------

procedure Execute;
var
    i,j : integer;
begin

  // Anropa fortran kod för beräkning

  BeamCalc.Calc(
    NumberOfBeams,
    NumberOfMaterials,
    BeamLengths,
    BeamLoads,
    BeamProps,
    BCTypes,
    BCDisplValues,
    BCRotValues,
    Materials,
    Displacement,
    Reaction,
    MaxEvaluationPoints,
    ShearForces,
    Moments,
    Deflections);

  // Beräkna max värden för skalning

  MaxMoment:=-1e300;
  MaxDeflection:=-1e300;
  MaxShearForce:=-1e300;

  for i:=1 to NumberOfBeams do
  begin
    for j:=1 to MaxEvaluationPoints do
    begin
      if abs(Moments[i,j])>MaxMoment then
        MaxMoment:=abs(Moments[i,j]);
      if abs(Deflections[i,j])>MaxDeflection then
        MaxDeflection:=abs(Deflections[i,j]);
      if abs(ShearForces[i,j])>MaxShearForce then
        MaxShearForce:=abs(ShearForces[i,j]);
    end;
  end;
end;

// ------------------------------------------------------------------

function GetMoment(BeamIdx, PointIdx : integer) : double;
begin

  // Returnera moment i en viss punkt på en balk

  Result:=0;
  if (BeamIdx>0) and (BeamIdx<=NumberOfBeams) then
  begin
    if (PointIdx>0) and (PointIdx<=MaxEvaluationPoints) then
    begin
      Result:=Moments[BeamIdx,PointIdx];
    end;
  end;
end;

// ------------------------------------------------------------------

function GetShearForce(BeamIdx, PointIdx : integer) : double;
begin

  // Returnera tvärkraft i en viss punkt på en balk

  Result:=0;
  if (BeamIdx>0) and (BeamIdx<=NumberOfBeams) then
  begin
    if (PointIdx>0) and (PointIdx<=MaxEvaluationPoints) then
    begin
      Result:=ShearForces[BeamIdx,PointIdx];
    end;
  end;
end;

// ------------------------------------------------------------------

function GetDeflection(BeamIdx, PointIdx : integer) : double;
begin

  // Returnera nedböjning i en viss punkt på en balk

  Result:=0;
  if (BeamIdx>0) and (BeamIdx<=NumberOfBeams) then
  begin
    if (PointIdx>0) and (PointIdx<=MaxEvaluationPoints) then
    begin
      Result:=Deflections[BeamIdx,PointIdx];
    end;
  end;
end;

// ------------------------------------------------------------------

function GetMaxDeflection : double;
begin

  // Returnera max nedböjning

  Result:=MaxDeflection;
end;

// ------------------------------------------------------------------

function GetMaxMoment : double;
begin

  // Returnera max moment (absolutvärde)

  Result:=MaxMoment;
end;

// ------------------------------------------------------------------

function GetMaxShearForce : double;
begin

  // Returnera max tvärkraft

  Result:=MaxShearForce;
end;

// ------------------------------------------------------------------
// ------------------------------------------------------------------

begin

  // Initiera biblioteket vid först användning.

  Init;
end.

