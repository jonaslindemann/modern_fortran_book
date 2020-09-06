// 
//  Interface unit for the fmath.dll library.
//  
//  Generated 2001-03-05 20:10:37
//    by Fortran interface wizard 1.0.1
// 

unit fmath;

interface

uses
    Classes, SysUtils;

type

    // 
    // The following datatypes corresponds to Fortran datatypes.
    // 


    PDoubleArray = ^TDoubleArray;
    TDoubleArray = array [0..0] of double;

    PIntegerArray = ^TIntegerArray;
    TIntegerArray = array [0..0] of integer;

    PDoubleMatrix = ^TDoubleMatrix;
    TDoubleMatrix = array [0..0,0..0] of double;

    PIntegerMatrix = ^TIntegerMatrix;
    TIntegerMatrix = array [0..0,0..0] of integer;

// 
// Procedures publically available.
// 

procedure vatan2(
    y : double;
    x : double;
    var angle : double); stdcall;

implementation

//
// Interface unit implemetation.
//

procedure vatan2(
    y : double;
    x : double;
    var angle : double); stdcall;
    external 'C:\...\fmath\debug\fmath.dll'
    name '_vatan2@20';

end.
