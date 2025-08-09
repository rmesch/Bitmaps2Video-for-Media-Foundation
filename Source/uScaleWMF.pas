// Project Location:
// https://github.com/rmesch/Bitmaps2Video-for-Media-Foundation
// Copyright © 2003-2025 Renate Schaaf
//
// Intiator(s): Renate Schaaf
// Contributor(s): Renate Schaaf,
// Tony Kalf (maXcomX) https://github.com/FactoryXCode/MfPack
//
// Release date: June 2025
// =============================================================================
// Thanks:
// To A.Melander, M.Lischke, E.Grange
// for code inspiring this resampling tool.
// Special thanks to Anders Melander for helpful discussions about the
// alpha-channel on
// https://en.delphipraxis.net/
// ==============================================================================
// =============================================================================
//
// LICENSE
//
// The contents of this file are subject to the Mozilla Public License
// Version 2.0 (the "License"); you may not use this file except in
// compliance with the License. You may obtain a copy of the License at
// https://www.mozilla.org/en-US/MPL/2.0/
//
// Software distributed under the License is distributed on an "AS IS"
// basis, WITHOUT WARRANTY OF ANY KIND, either express or implied. See the
// License for the specific language governing rights and limitations
// under the License.
//
// Non commercial users may distribute this sourcecode provided that this
// header is included in full at the top of the file.
// Commercial users are not allowed to distribute this sourcecode as part of
// their product.
//
// =============================================================================

unit uScaleWMF;
(* **************************************************************************
  High quality resampling of VCL-bitmaps using various filters
  (Box, Bilinear, Bicubic, Lanczos etc.) and including fast threaded routines.

  The "beef" of the algorithm used is in the routines
  MakeContributors and ProcessRow in uScaleCommonWMF
  ************************************************************************* *)

interface

uses WinApi.Windows,
  VCL.Graphics,
  System.Types,
  System.UITypes,
  System.Threading,
  System.SysUtils,
  System.Classes,
  System.Math,
  System.SyncObjs,
  uScaleCommonWMF;

{$IFOPT O-}
{$DEFINE O_MINUS}
{$O+}
{$ENDIF}
{$IFOPT Q+}
{$DEFINE Q_PLUS}
{$Q-}
{$ENDIF}


type

  TFloatRect = TRectF;

  /// <summary> Resampling of complete bitmaps with various options. Uses the ZoomResample.. functions internally </summary>
  /// <param name="NewWidth"> Width of target bitmap. Target will be resized. </param>
  /// <param name="NewHeight"> Height of target bitmap. Target will be resized. </param>
  /// <param name="Source"> Source bitmap, will be set to pf32bit. Works best if Source.Alphaformat=afIgnored. </param>
  /// <param name="Target"> Target bitmap, will be set to pf32bit. Alphaformat will be = Source.Alphaformat. </param>
  /// <param name="Filter"> Resampling kernel: cfBox, cfBilinear, cfBicubic, cfLanczos </param>
  /// <param name="Radius"> Range of pixels to contribute to the result. Value 0 takes the default radius for the filter. </param>
  /// <param name="Parallel"> If true the resampling work is divided into parallel threads. </param>
  /// <param name="AlphaCombineMode"> Options for alpha: amIndependent, amPreMultiply, amIgnore, amTransparentColor </param>
  /// <param name="ThreadPool"> Pointer to the TResamplingThreadpool to be used, nil uses a default thread pool. </param>
procedure Resample(
  NewWidth, NewHeight:  integer;
  const Source, Target: TBitmap;
  Filter:               TFilter;
  Radius:               single;
  Parallel:             boolean;
  AlphaCombineMode:     TAlphaCombineMode;
  ThreadPool:           PResamplingThreadPool = nil);

/// <summary> Resamples a rectangle of the Source to the Target. Does not use threading. </summary>
/// <param name="NewWidth"> Width of target bitmap. Target will be resized. </param>
/// <param name="NewHeight"> Height of target bitmap. Target will be resized. </param>
/// <param name="Source"> Source bitmap, will be set to pf32bit. Works best if Source.Alphaformat=afIgnored. </param>
/// <param name="Target"> Target bitmap, will be set to pf32bit. Alphaformat will be = Source.Alphaformat. </param>
/// <param name="SourceRect"> Rectangle in Source to be resampled, has floating point boundaries for smooth zooms. </param>
/// <param name="Filter"> Resampling kernel: cfBox, cfBilinear, cfBicubic, cfLanczos </param>
/// <param name="Radius"> Range of pixels to contribute to the result. Value 0 takes the default radius for the filter. </param>
/// <param name="AlphaCombineMode"> Options for alpha: amIndependent, amPreMultiply, amIgnore, amTransparentColor </param>
procedure ZoomResample(
  NewWidth, NewHeight:  integer;
  const Source, Target: TBitmap;
  SourceRect:           TFloatRect;
  Filter:               TFilter;
  Radius:               single;
  AlphaCombineMode:     TAlphaCombineMode);

// The following routine is now threadsafe, if each concurrent thread uses a different thread pool

/// <summary> Resamples a rectangle of the Source to the Target using parallel threads. </summary>
/// <param name="NewWidth"> Width of target bitmap. Target will be resized. </param>
/// <param name="NewHeight"> Height of target bitmap. Target will be resized. </param>
/// <param name="Source"> Source bitmap, will be set to pf32bit. Works best if Source.Alphaformat=afIgnored. </param>
/// <param name="Target"> Target bitmap, will be set to pf32bit. Alphaformat will be = Source.Alphaformat. </param>
/// <param name="SourceRect"> Rectangle in Source to be resampled, has floating point boundaries for smooth zooms. </param>
/// <param name="Filter"> Resampling kernel: cfBox, cfBilinear, cfBicubic, cfLanczos </param>
/// <param name="Radius"> Range of pixels to contribute to the result. Value 0 takes the default radius for the filter. </param>
/// <param name="AlphaCombineMode"> Options for alpha: amIndependent, amPreMultiply, amIgnore, amTransparentColor </param>
/// <param name="ThreadPool"> Pointer to the TResamplingThreadpool to be used, nil uses a default thread pool</param>
procedure ZoomResampleParallelThreads(
  NewWidth, NewHeight:  integer;
  const Source, Target: TBitmap;
  SourceRect:           TFloatRect;
  Filter:               TFilter;
  Radius:               single;
  AlphaCombineMode:     TAlphaCombineMode;
  ThreadPool:           PResamplingThreadPool = nil);

// The following procedure allows you to compare performance of TResamplingThreads to
// the built-in TTask-threading.
// Timings with TTask tend to be erratic. Sometimes it takes a very long time,
// I think this happens whenever the system deems it necessary to re-initialize
// the threading-framework.

/// <summary> Resamples a rectangle of the Source to the Target using parallel tasks (TTask). Is threadsafe. </summary>
/// <param name="NewWidth"> Width of target bitmap. Target will be resized. </param>
/// <param name="NewHeight"> Height of target bitmap. Target will be resized. </param>
/// <param name="Source"> Source bitmap, will be set to pf32bit. Works best if Source.Alphaformat=afIgnored. </param>
/// <param name="Target"> Target bitmap, will be set to pf32bit. Alphaformat will be = Source.Alphaformat. </param>
/// <param name="SourceRect"> Rectangle in Source to be resampled, has floating point boundaries for smooth zooms. </param>
/// <param name="Filter"> Resampling kernel: cfBox, cfBilinear, cfBicubic, cfLanczos </param>
/// <param name="Radius"> Range of pixels to contribute to the result. Value 0 takes the default radius for the filter. </param>
/// <param name="AlphaCombineMode"> Options for alpha: amIndependent, amPreMultiply, amIgnore, amTransparentColor </param>
procedure ZoomResampleParallelTasks(
  NewWidth, NewHeight:  integer;
  const Source, Target: TBitmap;
  SourceRect:           TFloatRect;
  Filter:               TFilter;
  Radius:               single;
  AlphaCombineMode:     TAlphaCombineMode);

function FloatRect(Aleft, ATop, ARight, ABottom: double)
  : TFloatRect;
  overload; inline;
function FloatRect(ARect: TRect)
  : TFloatRect; overload; inline;

procedure CropToTarget(
  NewWidth, NewHeight:  integer;
  const Source, Target: TBitmap;
  Filter:               TFilter;
  Radius:               single;
  Parallel:             boolean;
  AlphaCombineMode:     TAlphaCombineMode = amIgnore;
  ThreadPool:           PResamplingThreadPool = nil);

procedure ScaleToNewHeight(
  NewHeight:            integer;
  const Source, Target: TBitmap;
  Filter:               TFilter;
  Radius:               single;
  Parallel:             boolean;
  AlphaCombineMode:     TAlphaCombineMode = amIgnore;
  ThreadPool:           PResamplingThreadPool = nil);

procedure ScaleToNewWidth(
  NewWidth:             integer;
  const Source, Target: TBitmap;
  Filter:               TFilter;
  Radius:               single;
  Parallel:             boolean;
  AlphaCombineMode:     TAlphaCombineMode = amIgnore;
  ThreadPool:           PResamplingThreadPool = nil);

procedure MaximizeToRect(
  ARect:                TRect;
  var DisplayRect:      TRect;
  const Source, Target: TBitmap;
  Filter:               TFilter;
  Radius:               single;
  Parallel:             boolean;
  AlphaCombineMode:     TAlphaCombineMode = amIgnore;
  ThreadPool:           PResamplingThreadPool = nil
  );

implementation

procedure MaximizeToRect(
  ARect:                TRect;
  var DisplayRect:      TRect;
  const Source, Target: TBitmap;
  Filter:               TFilter;
  Radius:               single;
  Parallel:             boolean;
  AlphaCombineMode:     TAlphaCombineMode = amIgnore;
  ThreadPool:           PResamplingThreadPool = nil
  );
var
  wRect, hRect: integer;
  asp, aspRect: double;
  dLeft, dTop: integer;
begin
  wRect := ARect.Right - ARect.Left;
  hRect := ARect.Bottom - ARect.Top;
  Assert((Source.Width <> 0) and (Source.Height <> 0) and (wRect <> 0) and
    (hRect <> 0));
  asp := Source.Width / Source.Height;
  aspRect := wRect / hRect;
  if asp > aspRect then // scale to wRect
  begin
    Target.Width := wRect;
    Target.Height := round(wRect / asp);
  end
  else
  begin
    Target.Height := hRect;
    Target.Width := round(hRect * asp);
  end;
  uScaleWMF.Resample(
    Target.Width,
    Target.Height,
    Source,
    Target,
    Filter,
    Radius,
    Parallel,
    AlphaCombineMode,
    ThreadPool);
  dLeft := (wRect - Target.Width) div 2;
  dTop := (hRect - Target.Height) div 2;
  DisplayRect := Rect(
    dLeft,
    dTop,
    dLeft + Target.Width,
    dTop + Target.Height);
end;

procedure ScaleToNewWidth(
  NewWidth:             integer;
  const Source, Target: TBitmap;
  Filter:               TFilter;
  Radius:               single;
  Parallel:             boolean;
  AlphaCombineMode:     TAlphaCombineMode = amIgnore;
  ThreadPool:           PResamplingThreadPool = nil);
var NewHeight: integer;
begin
  NewHeight := round(NewWidth * Source.Height / Source.Width);
  Resample(
    NewWidth,
    NewHeight,
    Source,
    Target,
    Filter,
    Radius,
    Parallel,
    AlphaCombineMode,
    ThreadPool);
end;

procedure ScaleToNewHeight(
  NewHeight:            integer;
  const Source, Target: TBitmap;
  Filter:               TFilter;
  Radius:               single;
  Parallel:             boolean;
  AlphaCombineMode:     TAlphaCombineMode = amIgnore;
  ThreadPool:           PResamplingThreadPool = nil);
var NewWidth: integer;
begin
  NewWidth := round(NewHeight * Source.Width / Source.Height);
  Resample(
    NewWidth,
    NewHeight,
    Source,
    Target,
    Filter,
    Radius,
    Parallel,
    AlphaCombineMode,
    ThreadPool);
end;

procedure CropToTarget(
  NewWidth, NewHeight:  integer;
  const Source, Target: TBitmap;
  Filter:               TFilter;
  Radius:               single;
  Parallel:             boolean;
  AlphaCombineMode:     TAlphaCombineMode = amIgnore;
  ThreadPool:           PResamplingThreadPool = nil);
var SourceRect: TRectF;
  w, h, l, t: double;
begin
  If NewWidth * Source.Height > Source.Width * NewHeight
  // target asp > source asp
  then
  // crop top/bottom
  begin
    w := Source.Width;
    h := Source.Width * NewHeight / NewWidth;
    l := 0;
    t := 0.5 * (Source.Height - h)
  end
  else
  begin
    h := Source.Height;
    w := Source.Height * NewWidth / NewHeight;
    l := 0.5 * (Source.Width - w);
    t := 0;
  end;
  SourceRect := FloatRect(
    l,
    t,
    l + w,
    t + h);
  if Parallel then
    ZoomResample(
      NewWidth,
      NewHeight,
      Source,
      Target,
      SourceRect,
      Filter,
      Radius,
      AlphaCombineMode)
  else
    ZoomResampleParallelThreads(
      NewWidth,
      NewHeight,
      Source,
      Target,
      SourceRect,
      Filter,
      Radius,
      AlphaCombineMode,
      ThreadPool);
end;

function FloatRect(Aleft, ATop, ARight, ABottom: double)
  : TFloatRect;
  overload; inline;
begin
  Result.Left := Aleft;
  Result.Top := ATop;
  Result.Right := ARight;
  Result.Bottom := ABottom;
end;

function FloatRect(ARect: TRect)
  : TFloatRect; overload; inline;
begin
  Result := TRectF(ARect);
end;

// should now work with XE2 or at least with XE7
function GetResamplingTask(
  RTS:              TResamplingThreadSetup;
  Index:            integer;
  AlphaCombineMode: TAlphaCombineMode)
  : TProc;
begin
  Result := procedure
    var
      y, ymin, ymax: integer;
      CacheStart: PBGRAInt;
    begin
      CacheStart := @RTS.CacheMatrix[Index][0];
      ymin := RTS.ymin[Index];
      ymax := RTS.ymax[Index];
      for y := ymin to ymax do
      begin
        ProcessRow(
          y,
          CacheStart,
          RTS,
          AlphaCombineMode);
      end; // for y
    end; // procedure
end;

function TransColorToAlpha(const bm: TBitmap)
  : TColor;
var
  row: PByte;
  pix: PRGBQuad;
  pixColor: TRgbTriple;
  TransColor: TColor;
  bps, x, y: integer;
  function SameColor(p1, p2: PRGBTriple)
    : boolean;
  begin
    Result := (p1.rgbtBlue = p2.rgbtBlue) and (p1.rgbtGreen = p2.rgbtGreen) and
      (p1.rgbtRed = p2.rgbtRed);
  end;

begin
  // GetTransparentColor uses bm.Canvas
  bm.Canvas.Lock;
  Result := bm.TransparentColor;
  bm.Canvas.Unlock;
  TransColor := ColorToRGB(Result);
  pixColor.rgbtBlue := GetBValue(TransColor);
  pixColor.rgbtGreen := GetGValue(TransColor);
  pixColor.rgbtRed := GetRValue(TransColor);
  bps := ((bm.Width * 32 + 31) and not 31) div 8;
  row := bm.Scanline[0];
  for y := 1 to bm.Height do
  begin
    pix := PRGBQuad(row);
    for x := 1 to bm.Width do
    begin
      if SameColor(PRGBTriple(pix), @pixColor) then
        pix.rgbReserved := 0
      else
        pix.rgbReserved := 255;
      inc(pix);
    end;
    Dec(
      row,
      bps);
  end;

end;

procedure AlphaToTransparentColor(
  const bm:   TBitmap;
  TransColor: TColor);
var
  row: PByte;
  pix: PRGBQuad;
  pixColor: TRgbTriple;
  bps, x, y: integer;
  c: TColor;
begin
  c := ColorToRGB(TransColor);
  pixColor.rgbtBlue := GetBValue(c);
  pixColor.rgbtGreen := GetGValue(c);
  pixColor.rgbtRed := GetRValue(c);
  bps := ((bm.Width * 32 + 31) and not 31) div 8;
  row := bm.Scanline[0];
  for y := 1 to bm.Height do
  begin
    pix := PRGBQuad(row);
    for x := 1 to bm.Width do
    begin
      if pix.rgbReserved = 0 then
        PRGBTriple(pix)^ := pixColor
      else
        pix.rgbReserved := 0;
      // clear alpha channel, or draw won't draw it right;
      inc(pix);
    end;
    Dec(
      row,
      bps);
  end;
end;

procedure InitTransparency(
  const Source:   TBitmap;
  var TransColor: TColor);
begin
  TransColor := TransColorToAlpha(Source);
end;

procedure TransferTransparency(
  const Target: TBitmap;
  TransColor:   TColor);
begin
  AlphaToTransparentColor(
    Target,
    TransColor);
  Target.Canvas.Lock;
  Target.TransparentMode := TTransParentMode.tmFixed;
  Target.TransparentColor := TransColor;
  Target.Canvas.Unlock;
end;

procedure ZoomResampleParallelThreads(
  NewWidth, NewHeight:  integer;
  const Source, Target: TBitmap;
  SourceRect:           TFloatRect;
  Filter:               TFilter;
  Radius:               single;
  AlphaCombineMode:     TAlphaCombineMode;
  ThreadPool:           PResamplingThreadPool = nil);
var
  RTS: TResamplingThreadSetup;
  Index: integer;
  TP: PResamplingThreadPool;
  TransColor: TColor;
  DoSetAlphaFormat: boolean;
  Sbps, Tbps: integer;
begin
  if Radius = 0 then
    Radius := DefaultRadius[Filter];
  if (ThreadPool = nil) or (ThreadPool = @_DefaultThreadPool) then
  // just initialize _DefaultThreadPool without raising an exception
  begin
    TP := @_DefaultThreadPool;
    if not TP.Initialized then
      TP.Initialize(
        Min(_MaxThreadCount, TThread.ProcessorCount),
        tpHigher);
  end
  else
  begin
    TP := ThreadPool;
    if not TP.Initialized then
      raise eParallelException.Create('Thread pool not initialized.');
  end;

  Source.PixelFormat := pf32bit;
  Target.PixelFormat := pf32bit;
  DoSetAlphaFormat := (Source.AlphaFormat = afDefined);
  Source.AlphaFormat := afIgnored;
  Target.AlphaFormat := afIgnored;
  TransColor := 0;
  if AlphaCombineMode = amTransparentColor then
    InitTransparency(
      Source,
      TransColor);

  Target.SetSize(
    NewWidth,
    NewHeight);
  Tbps := -4 * NewWidth;
  Sbps := -4 * Source.Width;

  RTS.PrepareResamplingThreads(
    NewWidth,
    NewHeight,
    Source.Width,
    Source.Height,
    Radius,
    Filter,
    SourceRect,
    AlphaCombineMode,
    TP.ThreadCount,
    Sbps,
    Tbps,
    Source.Scanline[0],
    Target.Scanline[0]);

  for Index := 0 to RTS.ThreadCount - 1 do
    TP.ResamplingThreads[Index].RunAnonProc(GetResamplingTask(RTS, Index,
      AlphaCombineMode));
  Sleep(0);
  for Index := 0 to RTS.ThreadCount - 1 do
    TP.ResamplingThreads[Index].Done.Waitfor(INFINITE);

  if AlphaCombineMode = amTransparentColor then
    TransferTransparency(
      Target,
      TransColor)
  else if DoSetAlphaFormat then
  begin
    Source.AlphaFormat := afDefined;
    Target.AlphaFormat := afDefined;
  end;
end;

procedure ZoomResampleParallelTasks(
  NewWidth, NewHeight:  integer;
  const Source, Target: TBitmap;
  SourceRect:           TFloatRect;
  Filter:               TFilter;
  Radius:               single;
  AlphaCombineMode:     TAlphaCombineMode);
var
  RTS: TResamplingThreadSetup;
  Index: integer;
  TransColor: TColor;
  DoSetAlphaFormat: boolean;
  MaxTasks: integer;
  ResamplingTasks: array of iTask;
  Sbps, Tbps: integer;
begin
  if Radius = 0 then
    Radius := DefaultRadius[Filter];
  Source.PixelFormat := pf32bit;
  Target.PixelFormat := pf32bit;
  DoSetAlphaFormat := (Source.AlphaFormat = afDefined);
  Source.AlphaFormat := afIgnored;
  Target.AlphaFormat := afIgnored;
  TransColor := 0;
  if AlphaCombineMode = amTransparentColor then
    InitTransparency(
      Source,
      TransColor);
  Target.SetSize(
    NewWidth,
    NewHeight);

  MaxTasks := max(
    Min(64, TThread.ProcessorCount),
    2);

  Tbps := -((NewWidth * 32 + 31) and not 31) div 8;
  Sbps := -((Source.Width * 32 + 31) and not 31) div 8;

  RTS.PrepareResamplingThreads(
    NewWidth,
    NewHeight,
    Source.Width,
    Source.Height,
    Radius,
    Filter,
    SourceRect,
    AlphaCombineMode,
    MaxTasks,
    Sbps,
    Tbps,
    Source.Scanline[0],
    Target.Scanline[0]);
  SetLength(
    ResamplingTasks,
    RTS.ThreadCount);

  for Index := 0 to RTS.ThreadCount - 1 do
    ResamplingTasks[Index] :=
      TTask.run(GetResamplingTask(RTS, Index, AlphaCombineMode));
  TTask.WaitForAll(
    ResamplingTasks,
    INFINITE);

  if AlphaCombineMode = amTransparentColor then
    TransferTransparency(
      Target,
      TransColor)
  else if DoSetAlphaFormat then
  begin
    Source.AlphaFormat := afDefined;
    Target.AlphaFormat := afDefined;
  end;
end;

procedure ZoomResample(
  NewWidth, NewHeight:  integer;
  const Source, Target: TBitmap;
  SourceRect:           TFloatRect;
  Filter:               TFilter;
  Radius:               single;
  AlphaCombineMode:     TAlphaCombineMode);
var
  OldWidth, OldHeight: integer;
  Sbps, Tbps: integer;
  rStart, rTStart: PByte;
  // Row start in Source, Target
  y: integer;
  CacheStart: PBGRAInt;
  TransColor: TColor;
  DoSetAlphaFormat: boolean;
  RTS: TResamplingThreadSetup;
begin
  if Radius = 0 then
    Radius := DefaultRadius[Filter];
  Source.PixelFormat := pf32bit;
  Target.PixelFormat := pf32bit;
  DoSetAlphaFormat := (Source.AlphaFormat = afDefined);
  Source.AlphaFormat := afIgnored;
  Target.AlphaFormat := afIgnored;
  TransColor := 0;
  if AlphaCombineMode = amTransparentColor then
    InitTransparency(
      Source,
      TransColor);
  Target.SetSize(
    NewWidth,
    NewHeight);

  OldWidth := Source.Width;
  OldHeight := Source.Height;

  Tbps := -((NewWidth * 32 + 31) and not 31) div 8;
  Sbps := -((OldWidth * 32 + 31) and not 31) div 8;

  rStart := Source.Scanline[0];
  rTStart := Target.Scanline[0];

  RTS.PrepareResamplingThreads(
    NewWidth,
    NewHeight,
    OldWidth,
    OldHeight,
    Radius,
    Filter,
    SourceRect,
    AlphaCombineMode,
    1,
    Sbps,
    Tbps,
    rStart,
    rTStart);

  CacheStart := @RTS.CacheMatrix[0][0];

  // Compute colors for each target row at y
  for y := 0 to NewHeight - 1 do
    ProcessRow(
      y,
      CacheStart,
      RTS,
      AlphaCombineMode);

  if AlphaCombineMode = amTransparentColor then
    TransferTransparency(
      Target,
      TransColor)
  else if DoSetAlphaFormat then
  begin
    Source.AlphaFormat := afDefined;
    Target.AlphaFormat := afDefined;
  end;
end;

procedure Resample(
  NewWidth, NewHeight:  integer;
  const Source, Target: TBitmap;
  Filter:               TFilter;
  Radius:               single;
  Parallel:             boolean;
  AlphaCombineMode:     TAlphaCombineMode;
  ThreadPool:           PResamplingThreadPool = nil);
var
  r: TFloatRect;
begin
  r := FloatRect(
    0,
    0,
    Source.Width,
    Source.Height);

  if Parallel then

    ZoomResampleParallelThreads(
      NewWidth,
      NewHeight,
      Source,
      Target,
      r,
      Filter,
      Radius,
      AlphaCombineMode,
      ThreadPool)

  else

    ZoomResample(
      NewWidth,
      NewHeight,
      Source,
      Target,
      r,
      Filter,
      Radius,
      AlphaCombineMode);

end;

initialization

_IsFMX := false;

finalization

{$IFDEF O_MINUS}
{$O-}
{$UNDEF O_MINUS}
{$ENDIF}
{$IFDEF Q_PLUS}
{$Q+}
{$UNDEF Q_PLUS}
{$ENDIF}

end.
