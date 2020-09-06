unit fmath;

interface

procedure vatan2(y, x : double;
  var angle : double); stdcall;

implementation

procedure vatan2(y, x : double;
  var angle : double); stdcall;
  external '..\..\fortran\vatan2\debug\vatan2.dll'
  name '_vatan2@20';

end.

