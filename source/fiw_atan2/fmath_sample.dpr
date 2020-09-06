// 
// Example program for interfacing with the
// fmath library.
// 
// Generated 2001-03-05 20:10:37
//   by Fortran interface wizard 1.0.1
// 

program fmath_sample;

{$APPTYPE CONSOLE}

uses
    SysUtils, fmath;

var
    //
    // Variable declarations for vatan2
    //

    y : double;
    x : double;
    angle : double;

begin

    //
    // Variables needed when calling the
    // vatan2 Fortran subroutine.
    //

    y := 1.0;
    x := 1.0;
    angle := 1.0;

    vatan2(y,x,angle);

    writeln('Angle = ', angle);
    readln;
end.
