unit beamdraw;

// ------------------------------------------------------------------
//
//       Balkmodell uppritnings-unit
//
//       Copyright (c) 2000 Division of Structural Mechanics
//
// ------------------------------------------------------------------
//
// Skriven av Jonas Lindemann

interface

uses Graphics;

// ------------------------------------------------------------------
// Public routines
// ------------------------------------------------------------------

procedure SetDrawArea(width, height : integer);
procedure DrawBackground(ACanvas : TCanvas);
procedure DrawGeometry(ACanvas : TCanvas);
procedure DrawLoads(ACanvas : TCanvas);
procedure DrawBCs(ACanvas : TCanvas);
procedure DrawDimensions(ACanvas : TCanvas);
procedure DrawDeflections(ACanvas : TCanvas);
procedure DrawMoments(ACanvas : TCanvas);
procedure DrawShearForces(ACanvas : TCanvas);

// ------------------------------------------------------------------
// ------------------------------------------------------------------

implementation

// ------------------------------------------------------------------
// ------------------------------------------------------------------

uses Windows, Classes, SysUtils, BeamModel;

var

     AreaWidth : integer;
     AreaHeight : integer;
     TopMargin : integer;
     BottomMargin : integer;
     LeftMargin : integer;
     RightMargin : integer;
     DrawWidth : integer;
     DrawHeight : integer;

     TopRatio : double;
     BottomRatio : double;
     LeftRatio : double;
     RightRatio : double;

// ------------------------------------------------------------------

procedure SetMargins(top, bottom, left, right : double);
begin

  // Sätt marginaler relative fönster storlek

  TopRatio:=top;
  BottomRatio:=bottom;
  LeftRatio:=left;
  RightRatio:=right;
  TopMargin:=round(AreaHeight*top);
  BottomMargin:=round(AreaHeight*bottom);
  LeftMargin:=round(AreaWidth*left);
  RightMargin:=round(AreaWidth*right);
  DrawWidth:=AreaWidth-LeftMargin-RightMargin;
  DrawHeight:=AreaHeight-TopMargin-BottomMargin;
end;

// ------------------------------------------------------------------

procedure SetDrawArea(width, height : integer);
begin

  // Sätt storlek på rityta

  AreaWidth:=width;
  AreaHeight:=height;

  TopMargin:=round(AreaHeight*TopRatio);
  BottomMargin:=round(AreaHeight*BottomRatio);
  LeftMargin:=round(AreaWidth*LeftRatio);
  RightMargin:=round(AreaWidth*RightRatio);
  DrawWidth:=AreaWidth-LeftMargin-RightMargin;
  DrawHeight:=AreaHeight-TopMargin-BottomMargin;
end;

// ------------------------------------------------------------------

procedure Init;
begin

  // Initiera unit

  TopRatio:=0.1;
  BottomRatio:=0.1;
  LeftRatio:=0.1;
  RightRatio:=0.1;
  SetDrawArea(100, 100);
end;

// ------------------------------------------------------------------

procedure DrawBackground(ACanvas : TCanvas);
begin

  // Rita bakgrund

  ACanvas.Brush.Style:=bsSolid;
  ACanvas.Brush.Color:=clWhite;
  ACanvas.FillRect(Rect(0,0,AreaWidth,AreaHeight));
end;

// ------------------------------------------------------------------

procedure DrawGeometry(ACanvas : TCanvas);
var
    i : integer;
    TotalLength : double;
    ScaleFactor : double;
    BeamLength : double;
    BeamLoad : double;
    BeamProp : integer;
    XPosition : double;
begin

  // Rita upp balkgeometri


  // Beräkna skalfaktorer för uppritning

  TotalLength:=BeamModel.GetTotalLength;
  if TotalLength=0 then exit;
  ScaleFactor:=DrawWidth/TotalLength;

  // XPosition anger aktuell position på balk

  XPosition:=0;

  // Uppritning

  with ACanvas do
  begin
    Pen.Width:=2;
    Pen.Color:=clBlack;
    for i:=1 to BeamModel.GetNumberOfBeams do
    begin

      // Hämta balkdata för balk i

      BeamModel.GetBeam(i, BeamLength, BeamLoad, BeamProp);

      // Rita balk

      MoveTo(LeftMargin + round(XPosition*ScaleFactor),
             TopMargin + DrawHeight div 2);
      LineTo(LeftMargin + round((XPosition+BeamLength)*ScaleFactor),
             TopMargin + DrawHeight div 2);

      // Rita balkändar

      Brush.Style:=bsSolid;
      Brush.Color:=clWhite;

      // Uppdatera aktuell balkposition

      XPosition:=XPosition + BeamLength;

    end;
    Pen.Width:=1;
  end;
end;

// ------------------------------------------------------------------

procedure DrawLoads(ACanvas : TCanvas);
var
    i : integer;
    TotalLength : double;
    ScaleFactor : double;
    BeamLength : double;
    BeamLoad : double;
    BeamProp : integer;
    XPosition : double;
    sx, sy1, sy2 : integer;
begin

  // Rita upp laster


  // Beräkna skalfaktorer för uppritning

  TotalLength:=BeamModel.GetTotalLength;
  if TotalLength=0 then exit;
  ScaleFactor:=DrawWidth/TotalLength;

  // XPosition anger aktuell position på balk

  XPosition:=0;

  // Uppritning

  with ACanvas do
  begin
    for i:=1 to BeamModel.GetNumberOfBeams do
    begin

      // Hämta balkdata för balk i

      BeamModel.GetBeam(i, BeamLength, BeamLoad, BeamProp);

      // Om last > 0 ritar vi upp lasten

      if (abs(BeamLoad)>0) then
      begin

        // Rita laster

        Brush.Color:=clYellow;
        Pen.Color:=clWhite;
        Brush.Style:=bsSolid;
        FillRect(Rect(
          LeftMargin + round(XPosition*ScaleFactor),
          TopMargin + DrawHeight div 2 - round(TotalLength*0.1*ScaleFactor),
          LeftMargin + round((XPosition+BeamLength)*ScaleFactor),
          TopMargin + DrawHeight div 2));

        Brush.Color:=clBlack;
        Brush.Style:=bsSolid;
        FrameRect(Rect(
          LeftMargin + round(XPosition*ScaleFactor),
          TopMargin + DrawHeight div 2 - round(TotalLength*0.1*ScaleFactor),
          LeftMargin + round((XPosition+BeamLength)*ScaleFactor)+1,
          TopMargin + DrawHeight div 2 + 1));

        Brush.Color:=clWhite;
        Brush.Style:=bsClear;
        Pen.Color:=clBlack;
        Pen.Width:=1;

        // Rita pilar för lastriktning

        sx:=LeftMargin + round((XPosition+BeamLength/2)*ScaleFactor);
        sy1:=TopMargin + DrawHeight div 2;
        sy2:=TopMargin + DrawHeight div 2 - round(TotalLength*0.1*ScaleFactor);

        MoveTo(sx, sy1);
        LineTo(sx, sy2);

        if (BeamLoad>0) then
         begin
           MoveTo(sx-6, sy2+6);
           LineTo(sx, sy2);
           LineTo(sx+6, sy2+6);
         end
        else
         begin
           MoveTo(sx-6, sy1-6);
           LineTo(sx, sy1);
           LineTo(sx+6, sy1-6);
         end;

        Font.Color:=clBlack;

        // Skriv ut lastvärde

        TextOut(
          LeftMargin + round(XPosition*ScaleFactor) + 5,
          TopMargin + DrawHeight div 2 -
          round(TotalLength*0.1*ScaleFactor) + 3,
          format('q = %g',[BeamLoad]));
      end;

      // Uppdatera balkposition

      XPosition:=XPosition + BeamLength;
    end;
  end;
end;

// ------------------------------------------------------------------

procedure DrawBCs(ACanvas : TCanvas);
var
    i : integer;
    TotalLength : double;
    ScaleFactor : double;
    NodePos : double;
    BCType : integer;
    BCDisplValue : double;
    BCRotValue : double;
    sx, sy : integer;
begin

  // Beräkna skalfaktorer för uppritning

  TotalLength:=BeamModel.GetTotalLength;
  if TotalLength=0 then exit;
  ScaleFactor:=DrawWidth/TotalLength;

  with ACanvas do
  begin
    Pen.Color:=clBlack;
    Pen.Width:=1;
    for i:=1 to BeamModel.GetNumberOfBeams+1 do
    begin
      BeamModel.GetBC(i, BCType, BCDisplValue, BCRotValue);
      NodePos:=BeamModel.GetNodePos(i);
      if (NodePos<=TotalLength) then
      begin

        sx:=LeftMargin + round(NodePos*ScaleFactor);
        sy:=TopMargin + DrawHeight div 2;

        case BCType of
          bcFree       : begin
                         end;
          bcFixedDispl : begin
                           MoveTo(sx, sy);
                           LineTo(sx + 8, sy + 8);
                           LineTo(sx - 8, sy + 8);
                           LineTo(sx, sy);
                         end;
          bcFixedRot   : begin
                           MoveTo(sx-5,sy-8);
                           LineTo(sx-5,sy+8);
                           MoveTo(sx+5,sy-8);
                           LineTo(sx+5,sy+8);
                         end;
          bcFixed      : begin
                           Brush.Color:=clSilver;
                           Brush.Style:=bsSolid;
                           if (i=1) then
                             FillRect(Rect(sx-8, sy-10, sx, sy+10))
                           else if (i=BeamModel.GetNumberOfBeams+1) then
                               FillRect(Rect(sx+8, sy-10, sx, sy+10))
                               else
                                 FillRect(Rect(sx+4, sy-10, sx-4, sy+10));
                           MoveTo(sx,sy-10);
                           LineTo(sx,sy+10);
                         end;
        end;
      end;
    end;
  end;
end;

// ------------------------------------------------------------------

procedure DrawDimensions(ACanvas : TCanvas);
var
    i : integer;
    TotalLength : double;
    ScaleFactor : double;
    BeamLength : double;
    BeamLoad : double;
    BeamProp : integer;
    XPosition : double;
    DimensionText : string;
    DimensionPos : integer;
    DimensionWidth : integer;
begin

  // Rita upp dimensioner


  // Beräkna skalfaktorer för uppritning

  TotalLength:=BeamModel.GetTotalLength;
  if TotalLength=0 then exit;
  ScaleFactor:=DrawWidth/TotalLength;
  DimensionPos:=round(TotalLength*ScaleFactor*0.1);

  // XPosition anger aktuell position på balk

  XPosition:=0;

  // Uppritning

  with ACanvas do
  begin
    for i:=1 to BeamModel.GetNumberOfBeams do
    begin

      // Hämta balkdata för balk i

      BeamModel.GetBeam(i, BeamLength, BeamLoad, BeamProp);

      // Horisontell måttlinje

      MoveTo(LeftMargin + round(XPosition*ScaleFactor),
             TopMargin + DrawHeight div 2 + DimensionPos);
      LineTo(LeftMargin + round((XPosition+BeamLength)*ScaleFactor),
             TopMargin + DrawHeight div 2 + DimensionPos);

      // Vertikal måttlinje

      MoveTo(LeftMargin + round(XPosition*ScaleFactor),
             TopMargin + DrawHeight div 2 + 15);
      LineTo(LeftMargin + round(XPosition*ScaleFactor),
             TopMargin + DrawHeight div 2 + 5 + DimensionPos);

      // Text

      Font.Color:=clBlack;

      DimensionText:=format('l = %g',[BeamLength]);
      DimensionWidth:=TextWidth(DimensionText);

      TextOut(
        LeftMargin + round(XPosition*ScaleFactor) +
        round(BeamLength*ScaleFactor*0.5) - DimensionWidth div 2,
        TopMargin + DrawHeight div 2 - TextHeight('A') + DimensionPos,
        DimensionText);

       XPosition:=XPosition + BeamLength;

    end;

    MoveTo(LeftMargin + round(XPosition*ScaleFactor),
           TopMargin + DrawHeight div 2 + 15);
    LineTo(LeftMargin + round(XPosition*ScaleFactor),
           TopMargin + DrawHeight div 2 + 5 + DimensionPos);

  end;
end;

// ------------------------------------------------------------------

procedure DrawDeflections(ACanvas : TCanvas);
var
    i, j : integer;
    TotalLength : double;
    ScaleFactor : double;
    XPosition : double;
    BeamLength : double;
    BeamLoad : double;
    BeamProp : integer;
    DeltaX   : double;
    ValueScale : double;
begin

  // Rita upp deformationer


  // Beräkna skalfaktorer för uppritning

  TotalLength:=BeamModel.GetTotalLength;
  if TotalLength=0 then exit;
  ScaleFactor:=DrawWidth/TotalLength;
  if (BeamModel.GetMaxDeflection>0) then
     ValueScale:=0.2*DrawHeight/BeamModel.GetMaxDeflection
  else
     ValueScale:=1;

  // XPosition anger aktuell position på balk

  XPosition:=0;

  with ACanvas do
  begin
    Pen.Color:=clGreen;
    Pen.Width:=2;
    for i:=1 to BeamModel.GetNumberOfBeams do
    begin
      BeamModel.GetBeam(i, BeamLength, BeamLoad, BeamProp);
      DeltaX:=BeamLength/(MaxEvaluationPoints-1);
      for j:=1 to MaxEvaluationPoints-1 do
      begin
        MoveTo(
          LeftMargin + round(ScaleFactor*(XPosition + DeltaX*(j-1))),
          TopMargin  + DrawHeight div 2 - round(BeamModel.GetDeflection(i,j)*ValueScale));
        LineTo(
          LeftMargin + round(ScaleFactor*(XPosition + DeltaX*j)),
          TopMargin + DrawHeight div 2 - round(BeamModel.GetDeflection(i,j+1)*ValueScale));
      end;
      XPosition:=XPosition + BeamLength;
    end;
  end;
end;

// ------------------------------------------------------------------

procedure DrawMoments(ACanvas : TCanvas);
var
    i, j : integer;
    TotalLength : double;
    ScaleFactor : double;
    XPosition : double;
    BeamLength : double;
    BeamLoad : double;
    BeamProp : integer;
    DeltaX   : double;
    ValueScale : double;
begin

  // Rita upp moment


  // Beräkna skalfaktorer för uppritning

  TotalLength:=BeamModel.GetTotalLength;
  if TotalLength=0 then exit;
  ScaleFactor:=DrawWidth/TotalLength;
  if (BeamModel.GetMaxMoment>0) then
    ValueScale:=0.2*DrawHeight/BeamModel.GetMaxMoment
  else
    ValueScale:=1;

  // XPosition anger aktuell position på balk

  XPosition:=0;

  with ACanvas do
  begin
    Pen.Color:=clRed;
    Pen.Width:=2;
    for i:=1 to BeamModel.GetNumberOfBeams do
    begin
      BeamModel.GetBeam(i, BeamLength, BeamLoad, BeamProp);
      DeltaX:=BeamLength/(MaxEvaluationPoints-1);
      for j:=1 to MaxEvaluationPoints-1 do
      begin
        MoveTo(
          LeftMargin + round(ScaleFactor*(XPosition + DeltaX*(j-1))),
          TopMargin  + DrawHeight div 2 + round(BeamModel.GetMoment(i,j)*ValueScale));
        LineTo(
          LeftMargin + round(ScaleFactor*(XPosition + DeltaX*j)),
          TopMargin + DrawHeight div 2 + round(BeamModel.GetMoment(i,j+1)*ValueScale));
      end;
      XPosition:=XPosition + BeamLength;
    end;
  end;
end;

// ------------------------------------------------------------------

procedure DrawShearForces(ACanvas : TCanvas);
var
    i, j : integer;
    TotalLength : double;
    ScaleFactor : double;
    XPosition : double;
    BeamLength : double;
    BeamLoad : double;
    BeamProp : integer;
    DeltaX   : double;
    ValueScale : double;
begin

  // Rita upp tvärkrafter


  // Beräkna skalfaktorer för uppritning

  TotalLength:=BeamModel.GetTotalLength;
  if TotalLength=0 then exit;
  ScaleFactor:=DrawWidth/TotalLength;
  if (BeamModel.GetMaxShearForce>0) then
    ValueScale:=0.2*DrawHeight/BeamModel.GetMaxShearForce
  else
    ValueScale:=1;

  // XPosition anger aktuell position på balk

  XPosition:=0;

  with ACanvas do
  begin
    Pen.Color:=clNavy;
    Pen.Width:=2;
    for i:=1 to BeamModel.GetNumberOfBeams do
    begin
      BeamModel.GetBeam(i, BeamLength, BeamLoad, BeamProp);
      DeltaX:=BeamLength/(MaxEvaluationPoints-1);
      for j:=1 to MaxEvaluationPoints-1 do
      begin
        MoveTo(
          LeftMargin + round(ScaleFactor*(XPosition + DeltaX*(j-1))),
          TopMargin  + DrawHeight div 2 + round(BeamModel.GetShearForce(i,j)*ValueScale));
        LineTo(
          LeftMargin + round(ScaleFactor*(XPosition + DeltaX*j)),
          TopMargin + DrawHeight div 2 + round(BeamModel.GetShearForce(i,j+1)*ValueScale));
      end;
      XPosition:=XPosition + BeamLength;
    end;
  end;
end;

// ------------------------------------------------------------------
// ------------------------------------------------------------------

begin

  // Intiera unit vid första användning

  Init;
end.
