unit beamcalc;

// ------------------------------------------------------------------
//
//       Interface unit för Fortran DLL
//
//       Copyright (c) 2000 Division of Structural Mechanics
//
// ------------------------------------------------------------------
//
// Skriven av Jonas Lindemann

interface

uses BeamModel;

procedure Calc(
  nBeams,
  nMaterials : integer;
  var BeamLengths : TDoubleBeamVector;
  var BeamLoads : TDoubleBeamVector;
  var BeamProps : TIntBeamVector;
  var BCTypes : TIntBCVector;
  var BCDisplValues : TDoubleBCVector;
  var BCRotValues : TDoubleBCVector;
  var Materials : TMaterialMatrix;
  var Displacement : TDisplacementVector;
  var Reaction : TReactionVector;
  EvaluationPoints : integer;
  var ShearForces : TResultMatrix;
  var Moments : TResultMatrix;
  var Deflections : TResultMatrix);
  stdcall;

implementation

procedure Calc(
  nBeams,
  nMaterials : integer;
  var BeamLengths : TDoubleBeamVector;
  var BeamLoads : TDoubleBeamVector;
  var BeamProps : TIntBeamVector;
  var BCTypes : TIntBCVector;
  var BCDisplValues : TDoubleBCVector;
  var BCRotValues : TDoubleBCVector;
  var Materials : TMaterialMatrix;
  var Displacement : TDisplacementVector;
  var Reaction : TReactionVector;
  EvaluationPoints : integer;
  var ShearForces : TResultMatrix;
  var Moments : TResultMatrix;
  var Deflections : TResultMatrix);
  stdcall;
  external '..\fortran\beamcalc\debug\beamcalc.dll'
  name '_calc@60';

end.
