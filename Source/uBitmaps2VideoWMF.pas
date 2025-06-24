// Project Location:
// https://github.com/rmesch/Bitmaps2Video-for-Media-Foundation
// Copyright © 2003-2025 Renate Schaaf
//
// Intiator(s): Renate Schaaf
// Contributor(s): Renate Schaaf, Tony Kalf (maXcomX)
//
// Release date: June 2025
// =============================================================================
// Requires: MFPack for SDK version 10.0.26100.0
//           https://github.com/FactoryXCode/MfPack
// =============================================================================
// Source: FactoryX.Code Sinkwriter and Transcode Examples.
//         https://github.com/FactoryXCode/MfPack
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


unit uBitmaps2VideoWMF;

interface

// some of the interface stuff fails with optimization turned on
// optimization will be turned on where it matters
{$IFOPT O+ }
{$DEFINE O_PLUS }
{$O- }
{$ENDIF }


uses
  WinApi.Windows,
  WinApi.ActiveX,
  WinApi.Messages,
  WinApi.MMSystem,

  System.SysUtils,
  System.Types,
  System.Math,
  System.Classes,
  VCL.Graphics,

  // mfPack headers
  WinApi.MediaFoundationApi.MfApi,
  WinApi.MediaFoundationApi.MfUtils,
  WinApi.MediaFoundationApi.MfReadWrite,
  WinApi.MediaFoundationApi.Mfobjects,
  WinApi.MediaFoundationApi.CodecApi,
  WinApi.ActiveX.PropIdl,
  WinApi.MediaFoundationApi.MfIdl,

  // parallel bitmap resampler
  uScaleWMF,
  uScaleCommonWMF,

  // Transforms video-samples to the input-format of the sinkwriter
  uTransformer;

type

  TCodecID = (ciH264, ciH265);
  TCodecIDArray = array of TCodecID;

const
  CodecNames: array [TCodecID] of string = ('H264 (Mpeg-4, AVC)',
    'H265 (HEVC)');
  CodecShortNames: array [TCodecID] of string = ('H264', 'H265');
  CodecInfos: array [TCodecID] of string =
    ('Uses hardware-encoding, if supported. If not, falls back to software-encoding.',
    'Uses hardware-encoding, if supported. If not, falls back to software-encoding. Better quality per bitrate than H264. Requires Windows 10 or higher');

type
  // TZoom is a record (xcenter, ycenter, radius) defining a virtual zoom-rectangle
  // (xcenter-radius, ycenter-radius, xcenter+radius, ycenter+radius).
  // This rectangle should be a sub-rectangle of [0,1]x[0,1].
  // If multipied by the width/height of a target rectangle, it defines
  // an aspect-preserving sub-rectangle of the target.
  TZoom = record
    xCenter, yCenter: single;
    Radius: single;
    function ToRectF(Width, Height: integer)
      : TRectF; inline;
  end;

const
  _FullZoom: TZoom = (xCenter: 0.5; yCenter: 0.5; Radius: 0.5);

type
  eAudioFormatException = class(Exception);

type
  // Can be a method of a class or free standing or anonymous
  TBitmapEncoderProgressEvent = reference to procedure(sender: TObject;
    FrameCount: Cardinal; VideoTime: int64; var DoAbort: boolean);

  TVideoStats = MF_Sink_Writer_Statistics;

  TEncoderAdvancedOptions = record
    DisableHardwareEncoding: boolean;
    DisableThrottling: boolean;
    DisableQualityBasedEncoding: boolean;
    ForceEncoderLevel: boolean;
    DisableGOPSize: boolean;
    ResamplingThreadsLimit: integer;
  end;

const
  _DefaultAdvancedOptions: TEncoderAdvancedOptions =
    (
    DisableHardwareEncoding: false;
    DisableThrottling: false;
    DisableQualityBasedEncoding: false;
    ForceEncoderLevel: false;
    DisableGOPSize: false;
    ResamplingThreadsLimit: 4
    );

type

  TBitmapEncoderWMF = class
  private
    { fields needed to set up the MF-Sinkwriter and Sourcereader }
    fVideoWidth, fVideoHeight: DWord;
    fFrameRate: double;
    fQuality: DWord;
    fAudioBitrate, fAudioSampleRate: DWord;
    fSampleDuration: DWord;
    fExactSampleDuration: double;
    fBrake: DWord;
    fInputFormat: TGUID;
    pSinkWriter: IMFSinkWriter;
    pSourceReader: IMFSourceReader;
    pMediaTypeOut: IMFMediaType;
    pMediaTypeIn: IMFMediaType;
    pAudioTypeIn, pAudioTypeOut, pAudioTypeNative: IMFMediaType;
    pSampleBuffer, pSampleBufferAudio: IMFMediaBuffer;
    fBufferSizeVideo, fBufferSizeAudio: DWord;
    fSinkStreamIndexVideo, fSinkStreamIndexAudio: DWord;
    fAudioDuration, fAudioTime: int64;
    fAudioDone: boolean;
    hrCoInit, hrStartUp: HResult;
    fFileName, fAudioFileName: string;
    fCodec: TCodecID;
    { /fields needed to set up the MF-Sinkwriter }

    fWriteStart: int64;
    fReadAhead: int64;
    fInitialized, fWriteAudio: boolean;
    fAudioStart: int64;
    fBottomUp: boolean;
    fVideoTime: int64;
    fFrameCount: int64;
    fThreadPool: TResamplingThreadPool;
    fFilter: TFilter;
    fTimingDebug: boolean;
    // fBrake: DWord;
    fGPUPriority: word;
    fAudioBytesPerSecond: DWord;
    fAudioBlockAlign: DWord;
    fAudioStreamIndex: DWord;

    fBmRGBA: TBitmap;
    fOnProgress: TBitmapEncoderProgressEvent;
    fEncoderAdvancedOptions: TEncoderAdvancedOptions;

    // Resize/crop bm to input format for the encoder.
    procedure BitmapToRGBA(
      const bmSource, bmRGBA: TBitmap;
      crop:                   boolean;
      stretch:                boolean = false);

    // Move the RGBA-pixels into an MF sample buffer
    procedure bmRGBAToSampleBuffer(const bm: TBitmap);

    // Encode one frame to video stream and the corresponding audio samples to audio stream
    procedure WriteOneFrame(
      TimeStamp, Duration: int64);
    function WriteAudio(TimeStamp: int64)
      : HResult;
    procedure InitAudio(
      const AudioFileName:                        string;
      AudioSampleRate, AudioBitrate, StreamIndex: DWord);
    function SilenceBufferSize(Duration: int64)
      : DWord;
    function AudioDuration(PCMSamples: DWord)
      : int64;
    function GetAudioDuration: int64;

    // not working at the moment
    // function GetEncodingStats: TVideoStats;
  public
    constructor Create;

    /// <summary> Set up the video encoder for writing one output file. </summary>
    /// <param name="Filename">Name of the output file. Must have extension .mp4. .wmv presently not supported. </param>
    /// <param name="Width">Video width in pixels. </param>
    /// <param name="Height">Video height in pixels. </param>
    /// <param name="Quality">Quality of the video encoding on a scale of 1 to 100</param>
    /// <param name="FrameRate">Frame rate in frames per second. Value >= 30 recommended. </param>
    /// <param name="Codec">Video codec enum for encoding. Presently ciH264 or ciH265 </param>
    /// <param name="EncodePriority">The higher the more the main thread is stalled to allow time slots for encoding. Lower for speed, increase if video stutters. </param>
    /// <param name="Resampler">Enum defining the quality of resizing. cfBox, cfBilinear, cfBicubic or cfLanczos</param>
    /// <param name="AudioFileName">Optional audio or video file (.wav, .mp3, .aac, .mp4 etc.), audio stream encoded as AAC. Default ''</param>
    /// <param name="AudioBitRate"> in kb/sec (96, 128, 160, 192 accepted). Default 192 </param>
    /// <param name="AudioSampleRate"> 44100 or 48000. Default 48000 </param>
    /// <param name="AudioStart"> Delay of audio start in ms. Default 0 </param>
    procedure Initialize(
      const Filename: string;
      // Video settings
      Width, Height, Quality: integer;
      FrameRate:              double;
      Codec:                  TCodecID;
      EncodePriority:         word = 3;
      Resampler:              TFilter = cfBicubic;
      // Audio settings
      const AudioFileName: string = '';
      AudioBitrate:        integer = 192;
      AudioSampleRate:     integer = 48000;
      AudioStart:          int64 = 0);

    /// <summary> Finishes input, frees resources and closes the output file. </summary>
    procedure Finalize;

    /// <summary> Encodes a bitmap as the next video frame. Will be resized to maximal size fitting the video size (black BG), or (crop=true) cropped for maximal borderless size, or (stretch=true) stretched to video size. </summary>
    procedure AddFrame(
      const bm: TBitmap;
      crop:     boolean;
      stretch:  boolean = false);

    /// <summary> Repeatedly encode the last frame for EffectTime ms </summary>
    procedure Freeze(EffectTime: integer);

    /// <summary> Show a bitmap for ShowTime ms </summary>
    procedure AddStillImage(
      const bm: TBitmap;
      ShowTime: integer;
      crop:     boolean;
      stretch:  boolean = false);

    /// <summary> Make a crossfade transition from Sourcebm to Targetbm lasting EffectTime ms </summary>
    procedure CrossFade(
      const Sourcebm, Targetbm: TBitmap;
      EffectTime:               integer;
      cropSource, cropTarget:   boolean;
      stretchSource:            boolean = false;
      stretchTarget:            boolean = false);

    /// <summary> Make a crossfade transition from the last encoded frame to Targetbm lasting EffectTime ms </summary>
    procedure CrossFadeTo(
      const Targetbm: TBitmap;
      EffectTime:     integer;
      cropTarget:     boolean;
      stretchTarget:  boolean = false);

    /// <summary> Another transition as an example of how you can make more. Transition from Sourcebm to Targetbm </summary>
    procedure ZoomInOutTransition(
      const Sourcebm, Targetbm: TBitmap;
      ZoomSource, ZoomTarget:   TZoom;
      EffectTime:               integer;
      cropSource, cropTarget:   boolean;
      stretchSource:            boolean = false;
      stretchTarget:            boolean = false);

    /// <summary> Zoom-in-out transition from the last encoded frame to Targetbm lasting EffectTime ms </summary>
    procedure ZoomInOutTransitionTo(
      const Targetbm:         TBitmap;
      ZoomSource, ZoomTarget: TZoom;
      EffectTime:             integer;
      cropTarget:             boolean;
      stretchTarget:          boolean = false);

    /// <summary> Insert a video clip (video stream only) into the stream of encoded bitmaps. </summary>
    /// <param name="VideoFile">Name of the file containing the video clip. Anything that Windows can decode should be supported. </param>
    /// <param name="TransitionTime">Optionally does a crossfade transition from the last encoded frame to the first video frame lasting TransitionTime ms. Default 0 </param>
    procedure AddVideo(
      const VideoFile: string;
      TransitionTime:  integer = 0;
      crop:            boolean = false;
      stretch:         boolean = false);

    destructor Destroy; override;

    // Videotime so far in ms
    property VideoTime: int64 read fVideoTime;

    // Count of frames added so far
    property FrameCount: int64 read fFrameCount;

    // The filename of the output video as entered in Initialize
    property Filename: string read fFileName;

    // The last encoded frame returned as a TBitmap
    property LastFrame: TBitmap read fBmRGBA;

    // If true, timestamp in sec will be displayed on the frames. A rough check for a uniform timing of frames.
    // Timing could be very irregular at the beginning of development with high frame rates and large video sizes.
    // I had to artificially slow down the generation of some frames to (hopefully) fix it,
    // and read ahead in the audio file.
    // See Freeze and WriteAudio.
    property TimingDebug: boolean read fTimingDebug write fTimingDebug;

    // Event which fires every 30 frames. Use to indicate progress or abort encoding.
    property OnProgress: TBitmapEncoderProgressEvent read fOnProgress
      write fOnProgress;

    // property EncodingStats: TVideoStats
    // read GetEncodingStats;

    // need to be set after Creation and before calling Initialize
    // uses _DefaultAdvancedOptions if not set
    property EncoderAdvancedOptions: TEncoderAdvancedOptions
      read fEncoderAdvancedOptions write fEncoderAdvancedOptions;

    // after having been initialized with an audio-file the duration in ms can be
    // obtained by this property.
    property AudioFileDuration: int64 read GetAudioDuration;
  end;

function GetSupportedCodecs(const FileExt: string)
  : TCodecIDArray;

/// <summary>Use TBitmapEncoderWMF to re-encode a video to H265 or H264 and AAC, changing video size and/or frame rate. Audio of the 1st audio-stream is used. </summary>
procedure TranscodeVideoFile(
  const InputFilename, OutputFilename: string;
  Codec:                               TCodecID;
  Quality:                             integer;
  NewWidth, NewHeight:                 integer;
  NewFrameRate:                        single;
  EncodePriority:                      word;
  crop:                                boolean = false;
  stretch:                             boolean = false;
  OnProgress:                          TBitmapEncoderProgressEvent = nil);

implementation

procedure TranscodeVideoFile(
  const InputFilename, OutputFilename: string;
  Codec:                               TCodecID;
  Quality:                             integer;
  NewWidth, NewHeight:                 integer;
  NewFrameRate:                        single;
  EncodePriority:                      word;
  crop:                                boolean = false;
  stretch:                             boolean = false;
  OnProgress:                          TBitmapEncoderProgressEvent = nil);
var
  bme: TBitmapEncoderWMF;
begin
  bme := TBitmapEncoderWMF.Create;
  try
    // use the 1st audio-stream of the input file as audio
    bme.Initialize(
      OutputFilename,
      NewWidth,
      NewHeight,
      Quality,
      NewFrameRate,
      Codec,
      EncodePriority,
      cfBilinear,
      InputFilename,
      192,
      48000,
      0);
    bme.OnProgress := OnProgress;

    bme.AddVideo(
      InputFilename,
      0,
      crop,
      stretch);
  finally
    bme.Free;
  end;
end;

const
  // .wmv requires bottom-up order of input to the sample buffer
  // ... or is it the other way round? Anyway, the code works.
  BottomUp: array [TCodecID] of boolean = (false, false);

  // List of codecs supported for encoding a file with the given extension
function GetSupportedCodecs(const FileExt: string)
  : TCodecIDArray;
begin
  SetLength(
    result,
    0);
  if FileExt = '.mp4' then
  begin
    SetLength(
      result,
      2);
    result[0] := ciH264;
    result[1] := ciH265;
  end;
  // We currently don't support .wmv, too many problems.
  // if FileExt = '.wmv' then
  // begin
  // SetLength(result, 1);
  // result[0] := ciWMV;
  // end;
end;

// translation of our codec-enumeration to MF-constants
function GetEncodingFormat(Id: TCodecID)
  : TGUID;
begin
  case Id of
    ciH264:
      result := MFVideoFormat_H264;
    ciH265:
      result := MFVideoFormat_HEVC;
    // ciWMV:
    // result := MFVideoFormat_WMV3;
  end;
end;

{$IFOPT O- }
{$DEFINE O_MINUS }
{$O+ }
{$ENDIF }
{$IFOPT Q+}
{$DEFINE Q_PLUS}
{$Q-}
{$ENDIF}


// record to divide up the work of a loop into threads.
// my substitute for TParallelFor
type
  TParallelizerProc = reference to procedure(i1, i2: integer);

  TParallelizer = record
    // array of loopbounds for each thread
    imin, imax: TIntArray;
    // InputCount: length of the loop
    procedure Init(ThreadCount, InputCount: integer); inline;
  end;

procedure TParallelizer.Init(ThreadCount, InputCount: integer);
var
  chunk, Index: integer;
begin
  SetLength(
    imin,
    ThreadCount);
  SetLength(
    imax,
    ThreadCount);
  chunk := InputCount div ThreadCount;
  for Index := 0 to ThreadCount - 1 do
  begin
    imin[Index] := Index * chunk;
    if Index < ThreadCount - 1 then
      imax[Index] := (Index + 1) * chunk - 1
    else
      imax[Index] := InputCount - 1;
  end;
end;

function GetAlphaBlendProc(
  CF:                 TParallelizer;
  const pSourceStart: pByte;
  const pTargetStart: pByte;
  const pTweenStart:  pByte;
  alpha:              byte;
  Index:              integer)
  : TProc; inline;
var
  i1, i2: integer;
begin
  i1 := CF.imin[Index];
  i2 := CF.imax[Index];
  result := procedure
    var
      pold, pnew, pf: pByte;
      i: integer;
    begin
      pold := pSourceStart;
      pnew := pTargetStart;
      pf := pTweenStart;
      inc(
        pold,
        i1);
      inc(
        pnew,
        i1);
      inc(
        pf,
        i1);
      // for i := i1 to i2 do

      i := i2 - i1 + 1;
      while i > 0 do
      begin
        pf^ := (alpha * (pnew^ - pold^)) div 256 + pold^;
        inc(pf);
        inc(pnew);
        inc(pold);
        dec(i);
      end;
    end;
end;

// The bitmaps must have pixelformat pf32bit and identical
// width and height
// uses parallel threads for alphablending
procedure Alphablend(
  const bmSource: TBitmap;
  const bmTarget: TBitmap;
  const bmTween:  TBitmap;
  alpha:          byte;
  aThreadPool:    PResamplingThreadPool);
var
  CF: TParallelizer;
  Index: integer;
  pSourceStart, pTargetStart, pTweenStart: pByte;
begin
  CF.Init(
    aThreadPool^.ThreadCount,
    4 * bmSource.Width * bmSource.Height);
  pSourceStart := bmSource.ScanLine[bmSource.Height - 1];
  pTargetStart := bmTarget.ScanLine[bmTarget.Height - 1];
  pTweenStart := bmTween.ScanLine[bmTween.Height - 1];
  for Index := 0 to aThreadPool.ThreadCount - 1 do
    aThreadPool.ResamplingThreads[Index].RunAnonProc
      (GetAlphaBlendProc(CF, pSourceStart, pTargetStart, pTweenStart,
      alpha, Index));
  Sleep(0);
  for Index := 0 to aThreadPool.ThreadCount - 1 do
    aThreadPool.ResamplingThreads[Index].Done.WaitFor(INFINITE);
end;

{$IFDEF O_MINUS}
{$O-}
{$UNDEF O_MINUS}
{$ENDIF}
{$IFDEF Q_PLUS}
{$Q+}
{$UNDEF Q_PLUS}
{$ENDIF}


function IsCodecSupported(
  const
  FileExt:
  string;
  Codec:
  TCodecID)
  : boolean;
var
  ca: TCodecIDArray;
  i: integer;
begin
  result := false;
  ca := GetSupportedCodecs(FileExt);
  for i := 0 to Length(ca) - 1 do
    if ca[i] = Codec then
    begin
      result := true;
      Break;
    end;
end;

{ TBitmapEncoderWMF }

type
  TGUIDArray = array of TGUID;

function IntermediateVideoFormats: TGUIDArray;
begin
  SetLength(
    result,
    4);
  result[0] := MFVideoFormat_NV12;
  result[1] := MFVideoFormat_YV12;
  result[2] := MFVideoFormat_YUY2;
  result[3] := MFVideoFormat_RGB32;
end;

function IntermediateAudioFormats: TGUIDArray;
begin
  SetLength(
    result,
    2);
  result[1] := MFAudioFormat_Float;
  result[0] := MFAudioFormat_PCM;
end;

const
  nIntermediateVideoFormats = 4;
  nIntermediateAudioFormats = 2;

function TBitmapEncoderWMF.SilenceBufferSize(Duration: int64)
  : DWord;
begin
  result := Trunc(fAudioBytesPerSecond / 1000 * Duration / 10000);
  result := fAudioBlockAlign * (result div fAudioBlockAlign);
end;

function TBitmapEncoderWMF.AudioDuration(PCMSamples: DWord)
  : int64;
begin
  result := Trunc(PCMSamples / fAudioSampleRate * 1000 * 10000);
end;

constructor TBitmapEncoderWMF.Create;
begin
  // leave enough processors for the encoding threads
  fEncoderAdvancedOptions := _DefaultAdvancedOptions;
  fThreadPool.Initialize(
    min(fEncoderAdvancedOptions.ResamplingThreadsLimit,
    TThread.ProcessorCount div 2),
    tpNormal);
  fBmRGBA := TBitmap.Create;
end;

// Too many arguments ...
procedure TBitmapEncoderWMF.Initialize(
  const Filename:         string;
  Width, Height, Quality: integer;
  FrameRate:              double;
  Codec:                  TCodecID;
  EncodePriority:         word = 3;
  Resampler:              TFilter = cfBicubic;
  const AudioFileName:    string = '';
  AudioBitrate:           integer = 192;
  AudioSampleRate:        integer = 48000;
  AudioStart:             int64 = 0);
var
  attribsContainer: IMFAttributes;
  attribsMediaType: IMFAttributes;
  stride: DWord;
  ext: string;
  Count: integer;
  hr: HResult;
const
  ProcName = 'TBitmapEncoderWMF.Initialize';
  procedure CheckFail(hr: HResult);
  begin
    inc(Count);
    if not succeeded(hr) then
    begin
      // Only call CoUninitialize if the call to Initialize has been successful
      if succeeded(hrStartUp) then
        MfShutDown();
      if succeeded(hrCoInit) then
        CoUninitialize;
      hrStartUp := E_Fail;
      hrCoInit := E_Fail;
      raise Exception.Create('Fail in call nr. ' + IntToStr(Count) + ' of ' +
        ProcName + ' with result ' + IntToHex(hr, 8));
    end;
  end;

begin
  Count := 0;
  if fInitialized then
    raise Exception.Create
      ('The bitmap-encoder must be finalized before re-initializing');
  fInitialized := false;
  if fEncoderAdvancedOptions.ResamplingThreadsLimit <> _DefaultAdvancedOptions.ResamplingThreadsLimit
  then
  begin
    fThreadPool.Finalize;
    fThreadPool.Initialize(
      min(fEncoderAdvancedOptions.ResamplingThreadsLimit,
      TThread.ProcessorCount div 2),
      tpNormal);
  end;
  fFileName := Filename;
  ext := ExtractFileExt(fFileName);
  if not IsCodecSupported(ext, Codec) then
    raise Exception.Create('Codec ' + CodecShortNames[Codec] +
      ' not supported for file type ' + ext);

  fVideoWidth := Width;
  fVideoHeight := Height;
  fGPUPriority := EncodePriority;
  fBrake := Max(
    Trunc(2400 / fVideoHeight),
    1);
  fQuality := Quality;
  fFrameRate := FrameRate;
  fFilter := Resampler;
  fCodec := Codec;
  fAudioFileName := AudioFileName;
  // Calculate the time/frame
  // Time is measured in units of 100 nanoseconds. 1 sec = 1000 * 10000 time-units
  fExactSampleDuration := 1000 * 10000 / fFrameRate;
  fSampleDuration := Trunc(fExactSampleDuration);
  fAudioStart := AudioStart * 10000;
  fInputFormat := MFVideoFormat_RGB32;
  fBottomUp := BottomUp[Codec];

  fWriteStart := 0;
  fFrameCount := 0;

  stride := 4 * fVideoWidth;

  hrCoInit := CoInitializeEx(
    nil,
    COINIT_APARTMENTTHREADED or
    COINIT_DISABLE_OLE1DDE);
  CheckFail(hrCoInit);

  hrStartUp := MFStartup(MF_VERSION);
  CheckFail(hrStartUp);

  CheckFail(MFCreateAttributes(attribsContainer, 4));

  CheckFail(attribsContainer.SetUINT32(MF_TRANSCODE_ADJUST_PROFILE,
    DWord(MF_TRANSCODE_ADJUST_PROFILE_USE_SOURCE_ATTRIBUTES)));

  // per default endable hardware encoding, if the GPU supports it
  CheckFail(attribsContainer.SetUINT32(MF_READWRITE_ENABLE_HARDWARE_TRANSFORMS,
    Uint32(not fEncoderAdvancedOptions.DisableHardwareEncoding)));

  // The following setting was tried with bad results. Just so
  // nobody tries it again.

  // CheckFail(attribs.SetUINT32(MF_LOW_LATENCY,
  // UInt32(true)));

  // By default wmf throttles the main thread to make sure the encoding
  // threads get enough time to do their work. If the GPU receives too
  // much encoding work this leads to timing errors and dropped frames.
  // But the default throttling is not enough for our purpose.
  // Choosing true in the next statement would disable the default throttling,
  // requiring us to take over control over the speed of incoming frames.
  // I have not found a way to do this reliably, so the default is to keep throttling on.
  // To further increase timing accuracy we introduce the parameter EncodePriority. The higher,
  // the more time is set apart for the encoding threads to do their work.
  // For my NVidia 3060 I use EncodePriority = 2 or 3 with good results.
  // We have also limited the number of encoding threads to the number of processors
  // not used by our resizing threads, again an improvement.

  CheckFail(attribsContainer.SetUINT32(MF_SINK_WRITER_DISABLE_THROTTLING,
    Uint32(fEncoderAdvancedOptions.DisableThrottling)));

  if (ExtractFileExt(fFileName) = '.mp4') then
    hr := attribsContainer.SetGUID(
      MF_TRANSCODE_CONTAINERTYPE,
      MFTranscodeContainerType_MPEG4)
  else
    hr := ERROR_INVALID_PARAMETER;
  CheckFail(hr);

  // Create a sinkwriter to write the output file
  CheckFail(MFCreateSinkWriterFromURL(PWideChar(Filename), nil, attribsContainer,
    pSinkWriter));

  // Set the output media type.
  CheckFail(MFCreateMediaType(pMediaTypeOut));
  CheckFail(pMediaTypeOut.SetGUID(MF_MT_MAJOR_TYPE, MFMediaType_Video));
  CheckFail(pMediaTypeOut.SetGUID(MF_MT_SUBTYPE, GetEncodingFormat(Codec)));

  // Only kicks in if quality-based encoding is disabled, which is false by default
  CheckFail(pMediaTypeOut.SetUINT32(MF_MT_AVG_BITRATE,
    fQuality * 60 * fVideoHeight));

  CheckFail(pMediaTypeOut.SetUINT32(MF_MT_INTERLACE_MODE,
    MFVideoInterlace_Progressive));
  CheckFail(MFSetAttributeSize(pMediaTypeOut, MF_MT_FRAME_SIZE, fVideoWidth,
    fVideoHeight));
  CheckFail(MFSetAttributeRatio(pMediaTypeOut, MF_MT_FRAME_RATE,
    Trunc(fFrameRate * 1000), 1000));
  CheckFail(MFSetAttributeRatio(pMediaTypeOut, MF_MT_PIXEL_ASPECT_RATIO, 1, 1));

  if Codec = ciH264 then
    // looks better to me
    CheckFail(pMediaTypeOut.SetUINT32(MF_MT_VIDEO_PROFILE,
      eAVEncH264VProfile_ConstrainedHigh));
  if Codec = ciH265 then
    // Not really necessary, is default presently
    CheckFail(pMediaTypeOut.SetUINT32(MF_MT_VIDEO_PROFILE,
      eAVEncH265VProfile_Main_420_8));

  // Force a higher encoder level. Disabled by default.
  // The encoder then sets the level automatically, probably preferrable
  if fEncoderAdvancedOptions.ForceEncoderLevel then
  begin
    if Codec = ciH265 then
      if fVideoHeight < 1480 then
        CheckFail(pMediaTypeOut.SetUINT32(MF_MT_MPEG2_LEVEL,
          eAVEncH265VLevel5_2));

    if Codec = ciH264 then
      if fVideoHeight < 1480 then
        CheckFail(pMediaTypeOut.SetUINT32(MF_MT_MPEG2_LEVEL,
          eAVEncH264VLevel5_2));
  end;

  // Add a stream with the ouput media type to the sink-writer.
  // fSinkStreamIndexVideo (always 0 right now) is our video-stream-index.
  CheckFail(pSinkWriter.AddStream(pMediaTypeOut, fSinkStreamIndexVideo));

  // Set the input media type.
  CheckFail(MFCreateMediaType(pMediaTypeIn));
  CheckFail(pMediaTypeIn.SetGUID(MF_MT_MAJOR_TYPE, MFMediaType_Video));
  CheckFail(pMediaTypeIn.SetGUID(MF_MT_SUBTYPE, MFVideoFormat_RGB32));
  CheckFail(pMediaTypeIn.SetUINT32(MF_MT_INTERLACE_MODE,
    MFVideoInterlace_Progressive));
  CheckFail(MFSetAttributeSize(pMediaTypeIn, MF_MT_FRAME_SIZE, fVideoWidth,
    fVideoHeight));
  CheckFail(MFSetAttributeRatio(pMediaTypeIn, MF_MT_FRAME_RATE,
    Trunc(fFrameRate * 1000), 1000));
  CheckFail(MFSetAttributeRatio(pMediaTypeIn, MF_MT_PIXEL_ASPECT_RATIO, 1, 1));
  CheckFail(pMediaTypeIn.SetUINT32(MF_MT_ALL_SAMPLES_INDEPENDENT,
    Uint32(true)));
  CheckFail(pMediaTypeIn.SetUINT32(MF_MT_FIXED_SIZE_SAMPLES,
    Uint32(true)));

  attribsMediaType := nil;

  // Per default quality based VBR-encoding is enabled. Gives high quality
  // with small average bitrate/file size.
  // You can disable this in EncoderAdvancedOptions
  // Encoder attributes must be passed to the input media type.
  // (Not supported prior to Windows 8)
  if not(fEncoderAdvancedOptions.DisableQualityBasedEncoding or
    fEncoderAdvancedOptions.DisableGOPSize) then
    CheckFail(MFCreateAttributes(attribsMediaType, 4))
  else
    if not(fEncoderAdvancedOptions.DisableQualityBasedEncoding and
    fEncoderAdvancedOptions.DisableGOPSize) then
    CheckFail(MFCreateAttributes(attribsMediaType, 2));
  if not fEncoderAdvancedOptions.DisableQualityBasedEncoding then
  begin
    CheckFail(attribsMediaType.SetUINT32
      (CODECAPI_AVEncCommonRateControlMode, 3));
    CheckFail(attribsMediaType.SetUINT32(CODECAPI_AVEncCommonQuality,
      fQuality));
  end;

  if not fEncoderAdvancedOptions.DisableGOPSize then
  begin
    // This improves things a lot:
    CheckFail(attribsMediaType.SetUINT32(CODECAPI_AVEncMPVGOPSize,
      round(3 * fFrameRate)));
    CheckFail(attribsMediaType.SetUINT32(CODECAPI_AVEncNumWorkerThreads,
      Max(TThread.ProcessorCount - fThreadPool.ThreadCount, 2)));
  end;

  // set input media type of the sinkwriter
  CheckFail(pSinkWriter.SetInputMediaType(fSinkStreamIndexVideo, pMediaTypeIn,
    attribsMediaType));

  if (AudioFileName <> '') then
  begin
    try
      InitAudio(
        AudioFileName,
        AudioSampleRate,
        AudioBitrate,
        MF_SOURCE_READER_FIRST_AUDIO_STREAM);
      // prevent memory leak if the the audiofile contains more than
      // 1 stream
      pSourceReader.SetStreamSelection(
        MF_SOURCE_READER_ALL_STREAMS,
        false);
      // Ensure the stream is selected.
      CheckFail(pSourceReader.SetStreamSelection(fAudioStreamIndex, true));
    except
      raise eAudioFormatException.Create('Audio format not supported.');
    end;
  end;

  fBmRGBA.PixelFormat := pf32bit;
  fBmRGBA.SetSize(
    fVideoWidth,
    fVideoHeight);

  fBufferSizeVideo := stride * fVideoHeight;
  CheckFail(MFCreateMemoryBuffer(fBufferSizeVideo, pSampleBuffer));

  // Tell the sink writer to start accepting data.
  CheckFail(pSinkWriter.BeginWriting());
  fInitialized := true;
end;

// StreamIndex is for future use, presently always set to the 1st audio stream.
procedure TBitmapEncoderWMF.InitAudio(
  const
  AudioFileName:
  string;
  AudioSampleRate, AudioBitrate, StreamIndex: DWord);
var
  _var: TPropVariant;
  Count: integer;
  pData: pByte;
  pPartialType: IMFMediaType;
  hr: HResult;
const
  ProcName = 'TBitmapEncoderWMF.InitAudio';
  procedure CheckFail(hr: HResult);
  var
    err: string;
  begin
    inc(Count);
    if not succeeded(hr) then
    begin
      err := IntToHex(hr);
      if succeeded(hrCoInit) then
        CoUninitialize;
      raise Exception.Create('Fail in call nr. ' + IntToStr(Count) + ' of ' +
        ProcName + ' with result ' + IntToHex(hr));
    end;
  end;

begin
  Count := 0;
  fAudioSampleRate := AudioSampleRate;
  fAudioBitrate := AudioBitrate;
  fWriteAudio := true;
  fAudioDone := false;
  fAudioStreamIndex := StreamIndex;

  // Create the encoded media type (AAC stereo with the specified sample- and bit-rates)
  // We set it up independent of the input type. In a future version we want to
  // add more than one audio file, so the input type should be allowed to change,
  // but not the output type.
  // So far it seems to work OK with one audio file.
  CheckFail(MFCreateMediaType(pAudioTypeOut));

  CheckFail(pAudioTypeOut.SetGUID(MF_MT_MAJOR_TYPE, MFMediaType_Audio));
  CheckFail(pAudioTypeOut.SetGUID(MF_MT_SUBTYPE, MFAudioFormat_AAC));
  // set the number of audio bits per sample. This must be 16 according to docs.
  CheckFail(pAudioTypeOut.SetUINT32(MF_MT_AUDIO_BITS_PER_SAMPLE, 16));
  // set the number of audio samples per second. Must be 44100 or 48000
  CheckFail(pAudioTypeOut.SetUINT32(MF_MT_AUDIO_SAMPLES_PER_SECOND,
    fAudioSampleRate));
  // Set the number of audio channels. Hardwired to stereo, can be different from input format.
  CheckFail(pAudioTypeOut.SetUINT32(MF_MT_AUDIO_NUM_CHANNELS, 2));
  // set the Bps of the audio stream
  CheckFail(pAudioTypeOut.SetUINT32(MF_MT_AUDIO_AVG_BYTES_PER_SECOND,
    125 * fAudioBitrate));
  // set the block alignment of the samples. Hardwired to 1.
  CheckFail(pAudioTypeOut.SetUINT32(MF_MT_AUDIO_BLOCK_ALIGNMENT, 1));
  // Level 2 profile
  CheckFail(pAudioTypeOut.SetUINT32(MF_MT_AAC_AUDIO_PROFILE_LEVEL_INDICATION,
    Uint32($29)));

  // add a stream with this media type to the sink-writer
  CheckFail(pSinkWriter.AddStream(pAudioTypeOut, fSinkStreamIndexAudio));

  // Create a source-reader to read the audio file
  CheckFail(MFCreateSourceReaderFromURL(PWideChar(AudioFileName), nil,
    pSourceReader));
  // Find the first audio-stream and read its native media type
  // Just to have a reference to it, not used at the moment
  hr := pSourceReader.GetNativeMediaType(
    fAudioStreamIndex,
    0,
    pAudioTypeNative);
  if Failed(hr) then
  begin
    fAudioStreamIndex := MF_SOURCE_READER_FIRST_AUDIO_STREAM;
    CheckFail(pSourceReader.GetNativeMediaType(fAudioStreamIndex, 0,
      pAudioTypeNative));
  end;
  // Create a partial uncompressed media type with the specs the reader should decode to
  CheckFail(MFCreateMediaType(pPartialType));

  // set the major type of the partial type
  CheckFail(pPartialType.SetGUID(MF_MT_MAJOR_TYPE, MFMediaType_Audio));
  // MFAudioFormat_PCM is required as input for AAC
  CheckFail(pPartialType.SetGUID(MF_MT_SUBTYPE, MFAudioFormat_PCM));
  CheckFail(pPartialType.SetUINT32(MF_MT_AUDIO_BITS_PER_SAMPLE, 16));
  CheckFail(pPartialType.SetUINT32(MF_MT_AUDIO_SAMPLES_PER_SECOND,
    fAudioSampleRate));
  CheckFail(pPartialType.SetUINT32(MF_MT_AUDIO_NUM_CHANNELS, 2));
  CheckFail(pPartialType.SetUINT32(MF_MT_ALL_SAMPLES_INDEPENDENT,
    Uint32(true)));

  // set the partial media type on the source stream
  // if this is successful, the reader can deliver uncompressed samples
  // in the given format
  CheckFail(pSourceReader.SetCurrentMediaType(fAudioStreamIndex, 0,
    pPartialType));
  // Read the full uncompressed input type off the reader
  CheckFail(pSourceReader.GetCurrentMediaType(fAudioStreamIndex, pAudioTypeIn));
  // Set this type as input type for the sink-writer. If this is successful
  // we are ready to encode.
  CheckFail(pSinkWriter.SetInputMediaType(fSinkStreamIndexAudio, // stream index
    pAudioTypeIn, // media type to match
    nil)); // configuration attributes for the encoder

  // Find the audio-duration
  PropVariantInit(_var);
  try
    CheckFail(pSourceReader.GetPresentationAttribute
      (MF_SOURCE_READER_MEDIASOURCE, MF_PD_DURATION, _var));
    fAudioDuration := _var.hVal.QuadPart;
  finally
    PropVariantClear(_var);
  end;
  fAudioTime := 0;

  // Set up an audio buffer holding silence which we can add to the audio stream as necessary
  CheckFail(pAudioTypeIn.GetUInt32(MF_MT_AUDIO_AVG_BYTES_PER_SECOND,
    fAudioBytesPerSecond));
  CheckFail(pAudioTypeIn.GetUInt32(MF_MT_AUDIO_BLOCK_ALIGNMENT,
    fAudioBlockAlign));
  // Create an audio-buffer that holds silence
  // the buffer should hold audio for the  video frame time.
  fBufferSizeAudio := SilenceBufferSize(fSampleDuration);
  CheckFail(MFCreateMemoryBuffer(fBufferSizeAudio, pSampleBufferAudio));
  CheckFail(pSampleBufferAudio.SetCurrentLength(fBufferSizeAudio));
  CheckFail(pSampleBufferAudio.Lock(pData, nil, nil));
  FillChar(
    pData^,
    fBufferSizeAudio,
    0);
  // prevent crack at beginnning of silence
  PByteArray(pData)[2] := $06;
  CheckFail(pSampleBufferAudio.Unlock);
  CheckFail(pSampleBufferAudio.SetCurrentLength(fBufferSizeAudio));

  // Set the amount of time we read ahead of the video-timestamp in the audio-file
  fReadAhead := fAudioBlockAlign * AudioDuration(1024);
  // duration of BlockAlign encoded AAC-frames
end;

procedure TBitmapEncoderWMF.Finalize;
begin

  if Assigned(pSinkWriter) then
    pSinkWriter.Finalize();
  pSinkWriter := nil;
  if Assigned(pSourceReader) then
    SafeRelease(pSourceReader);
  pSourceReader := nil;

  if succeeded(hrStartUp) then
    MfShutDown();
  if succeeded(hrCoInit) then
    CoUninitialize;
  hrStartUp := E_Fail;
  hrCoInit := E_Fail;
  fInitialized := false;
end;

procedure TBitmapEncoderWMF.AddVideo(
  const
  VideoFile:
  string;
  TransitionTime:
  integer = 0;
  crop:
  boolean = false;
  stretch:
  boolean = false);
var
  VT: TVideoTransformer;
  bm: TBitmap;
  TimeStamp, Duration, VideoStart: int64;
begin
  if not fInitialized then
    exit;
  VT := TVideoTransformer.Create(
    VideoFile,
    fVideoHeight,
    fFrameRate);
  try
    bm := TBitmap.Create;
    try
      if not VT.NextValidSampleToBitmap(bm, TimeStamp, Duration) then
        exit;
      if TransitionTime > 0 then
        CrossFadeTo(
          bm,
          TransitionTime,
          crop,
          stretch);
      VideoStart := fWriteStart;
      // fill gap at beginning of video stream
      if TimeStamp > 0 then
        AddStillImage(
          bm,
          Trunc(TimeStamp / 10000),
          crop,
          stretch);
      while (not VT.EndOfFile) and fInitialized do
      begin
        BitmapToRGBA(
          bm,
          fBmRGBA,
          crop,
          stretch);
        bmRGBAToSampleBuffer(fBmRGBA);
        WriteOneFrame(
          VideoStart + TimeStamp,
          Duration);
        if not VT.NextValidSampleToBitmap(bm, TimeStamp, Duration) then
          Break;
      end;
      // FrameCount*FrameTime > Video-end? (shouldn't differ by much)
      if fWriteStart > VideoStart + TimeStamp + Duration then
        Freeze((fWriteStart - VideoStart - TimeStamp - Duration) div 10000);
    finally
      bm.Free;
    end;
  finally
    VT.Free;
  end;
end;

procedure TBitmapEncoderWMF.AddFrame(
  const
  bm:
  TBitmap;
  crop:
  boolean;
  stretch:
  boolean = false);
begin
  if not fInitialized then
    exit;
  BitmapToRGBA(
    bm,
    fBmRGBA,
    crop,
    stretch);
  bmRGBAToSampleBuffer(fBmRGBA);
  WriteOneFrame(
    fWriteStart,
    fSampleDuration);
end;

procedure TBitmapEncoderWMF.AddStillImage(
  const
  bm:
  TBitmap;
  ShowTime:
  integer;
  crop:
  boolean;
  stretch:
  boolean = false);
var
  bmBuf: TBitmap;
  StartTime: int64;
begin
  if not fInitialized then
    exit;
  StartTime := fWriteStart;

  BitmapToRGBA(
    bm,
    fBmRGBA,
    crop,
    stretch);
  if fTimingDebug then
  begin
    bmBuf := TBitmap.Create;
    try
      while fWriteStart < StartTime + ShowTime * 10000 do
      begin
        if (fFrameCount mod fBrake) = (fBrake - 1) then
        begin
          // Same slowdown as in Freeze
          HandleMessages(
            GetCurrentThread(),
            1);
          Sleep(fGPUPriority);
        end;
        bmBuf.Assign(fBmRGBA);
        bmRGBAToSampleBuffer(bmBuf);
        WriteOneFrame(
          fWriteStart,
          fSampleDuration);
      end;
    finally
      bmBuf.Free;
    end;
  end
  else
  begin
    bmRGBAToSampleBuffer(fBmRGBA);
    Freeze(ShowTime);
  end;

end;

// Resizes/crops/stretches bmSource to video size.
// We use a bitmap for the RGBA-output rather than a buffer, because we want to do
// bitmap operations like zooming on it.
procedure TBitmapEncoderWMF.BitmapToRGBA(
  const
  bmSource, bmRGBA: TBitmap;
  crop:
  boolean;
  stretch:
  boolean = false);
var
  bmBack, bm: TBitmap;
  w, h, wSource, hSource: DWord;
  SourceRect: TRectF;
  bmWidth, bmHeight: DWord;
begin
  if (bmSource.Width = 0) or (bmSource.Height = 0) then
    raise Exception.Create('Bitmap has size 0');
  bmWidth := bmSource.Width;
  bmHeight := bmSource.Height;
  bm := TBitmap.Create;
  try
    bm.Assign(bmSource);
    bm.PixelFormat := pf32bit;
    if (bmWidth <> fVideoWidth) or (bmHeight <> fVideoHeight) then
    begin
      if stretch then
      begin
        uScaleWMF.ZoomResampleParallelThreads(
          fVideoWidth,
          fVideoHeight,
          bm,
          bmRGBA,
          RectF(0, 0, bmWidth, bmHeight),
          fFilter,
          0,
          amIgnore,
          @fThreadPool)
      end
      else
      begin
        if bmWidth * fVideoHeight > fVideoWidth * bmHeight then
        begin
          if crop then
          begin
            h := fVideoHeight;
            w := fVideoWidth;
            hSource := bmHeight;
            wSource := round(hSource * fVideoWidth / fVideoHeight);
            SourceRect := RectF(
              (bmWidth - wSource) div 2,
              0,
              (bmWidth + wSource) div 2,
              bm.Height);
          end
          else
          begin
            w := fVideoWidth;
            h := round(fVideoWidth * bmHeight / bmWidth);
            SourceRect := RectF(
              0,
              0,
              bmWidth,
              bmHeight);
          end;
        end
        else
        begin
          if crop then
          begin
            w := fVideoWidth;
            h := fVideoHeight;
            wSource := bm.Width;
            hSource := round(wSource * fVideoHeight / fVideoWidth);
            SourceRect := RectF(
              0,
              (bmHeight - hSource) div 2,
              bmWidth,
              (bmHeight + hSource) div 2);
          end
          else
          begin
            h := fVideoHeight;
            w := round(fVideoHeight * bmWidth / bmHeight);
            SourceRect := FloatRect(
              0,
              0,
              bmWidth,
              bmHeight);
          end;
        end;
        bmBack := TBitmap.Create;
        try
          if (w <> bmWidth) or (h <> bmHeight) then
            uScaleWMF.ZoomResampleParallelThreads(
              w,
              h,
              bm,
              bmBack,
              SourceRect,
              fFilter,
              0,
              amIgnore,
              @fThreadPool)
          else
            bmBack.Assign(bm);
          if (w <> fVideoWidth) or (h <> fVideoHeight) then
          begin
            bmRGBA.PixelFormat := pf32bit;
            bmRGBA.SetSize(
              fVideoWidth,
              fVideoHeight);
            bmRGBA.Canvas.Lock;
            bmBack.Canvas.Lock;
            BitBlt(
              bmRGBA.Canvas.Handle,
              0,
              0,
              fVideoWidth,
              fVideoHeight,
              0,
              0,
              0,
              BLACKNESS);
            BitBlt(
              bmRGBA.Canvas.Handle,
              (fVideoWidth - w) div 2,
              (fVideoHeight - h) div 2,
              w,
              h,
              bmBack.Canvas.Handle,
              0,
              0,
              SRCCopy);
            bmBack.Canvas.Unlock;
            bmRGBA.Canvas.Unlock;
          end
          else
            bmRGBA.Assign(bmBack);
        finally
          bmBack.Free;
        end;
      end;
    end
    else
      bmRGBA.Assign(bm);
  finally
    bm.Free;
  end;
end;

procedure TBitmapEncoderWMF.bmRGBAToSampleBuffer(
  const
  bm:
  TBitmap);
var
  hr: HResult;
  pRow: pByte;
  StrideSource, StrideTarget: integer;
  pData: pByte;
  time: string;
begin
  if fTimingDebug then
  begin
    time := IntToStr(fWriteStart div 10000000);
    bm.Canvas.Lock;
    bm.Canvas.Brush.Style := bsClear;
    bm.Canvas.Font.Color := clFuchsia;
    bm.Canvas.Font.Size := 32;
    bm.Canvas.TextOut(
      10,
      10,
      time);
    bm.Canvas.Unlock;
  end;
  if not fBottomUp then
  begin
    StrideSource := 4 * fVideoWidth;
    pRow := bm.ScanLine[fVideoHeight - 1];
  end
  else
  begin
    StrideSource := -4 * integer(fVideoWidth);
    pRow := bm.ScanLine[0];
  end;
  StrideTarget := 4 * fVideoWidth;
  hr := pSampleBuffer.Lock(
    pData,
    nil,
    nil);
  if succeeded(hr) then
  begin
    hr := MFCopyImage(
      pData { Destination buffer. } ,
      StrideTarget { Destination stride. } ,
      pRow, { First row in source image. }
      StrideSource { Source stride. } ,
      StrideTarget { Image width in bytes. } ,
      fVideoHeight { Image height in pixels. } );

    if succeeded(hr) then
      hr := pSampleBuffer.Unlock();

    if succeeded(hr) then
      // Set the data length of the buffer.
      hr := pSampleBuffer.SetCurrentLength(fBufferSizeVideo);
  end;
  if not succeeded(hr) then
    raise Exception.Create
      ('TBitmapEncoderWMF.bmRGBAToSampleBuffer failed. Err: ' +
      IntToHex(hr, 8));
end;

function StartSlowEndSlow(t: double)
  : double; inline;
begin
  if t < 0.5 then
    result := 2 * sqr(t)
  else
    result := 1 - 2 * sqr(1 - t);
end;

function StartFastEndSlow(t: double)
  : double; inline;
begin
  result := 1 - sqr(1 - t);
end;

procedure TBitmapEncoderWMF.CrossFade(
  const
  Sourcebm, Targetbm: TBitmap;
  EffectTime:
                          integer;
  cropSource, cropTarget: boolean;
  stretchSource:
  boolean = false;
  stretchTarget:
  boolean = false);
var
  DurMs: integer;
begin
  if not fInitialized then
    exit;
  AddFrame(
    Sourcebm,
    cropSource,
    stretchSource);
  DurMs := Trunc(1 / 10000 * fSampleDuration);
  CrossFadeTo(
    Targetbm,
    EffectTime - DurMs,
    cropTarget,
    stretchTarget);
end;

procedure TBitmapEncoderWMF.CrossFadeTo(
  const Targetbm: TBitmap;
  EffectTime:     integer;
  cropTarget:     boolean;
  stretchTarget:  boolean = false);
var
  StartTime, EndTime: int64;
  alpha: byte;
  fact: double;
  bmOld, bmNew, bmTween: TBitmap;
begin
  if not fInitialized then
    exit;
  bmOld := TBitmap.Create;
  bmNew := TBitmap.Create;
  bmTween := TBitmap.Create;
  try
    bmOld.Assign(fBmRGBA);
    BitmapToRGBA(
      Targetbm,
      bmNew,
      cropTarget,
      stretchTarget);
    bmTween.PixelFormat := pf32bit;
    bmTween.SetSize(
      fVideoWidth,
      fVideoHeight);
    StartTime := fWriteStart;
    EndTime := StartTime + EffectTime * 10000;
    fact := 255 / 10000 / EffectTime;
    while EndTime - fWriteStart > 0 do
    begin
      alpha := Trunc((fact * (fWriteStart - StartTime)));
      Alphablend(
        bmOld,
        bmNew,
        bmTween,
        alpha,
        @fThreadPool);

      bmRGBAToSampleBuffer(bmTween);
      WriteOneFrame(
        fWriteStart,
        fSampleDuration);
    end;
    fBmRGBA.Assign(bmNew);
  finally
    bmTween.Free;
    bmNew.Free;
    bmOld.Free;
  end;
end;

destructor TBitmapEncoderWMF.Destroy;
begin
  if fInitialized then
    Finalize;
  fThreadPool.Finalize;
  fBmRGBA.Free;
  inherited;
end;

// TimeStamp = Video-timestamp
function TBitmapEncoderWMF.WriteAudio(TimeStamp: int64)
  : HResult;
var
  ActualStreamIndex: DWord;
  flags: DWord;
  AudioTimestamp, AudioSampleDuration: int64;
  pAudioSample: IMFSample;
  Count: integer;
  hr: HResult;
label
  Done;
const
  ProcName = 'TBitmapEncoderWMF.WriteAudio';
  // is not used anymore, instead hr is returned
  procedure CheckFail(hr: HResult);
  begin
    inc(Count);
    if not succeeded(hr) then
    begin
      if succeeded(hrCoInit) then
        CoUninitialize;
      raise Exception.Create('Fail in call nr. ' + IntToStr(Count) + ' of ' +
        ProcName + ' with result $' + IntToHex(hr));
    end;
  end;

begin
  hr := S_OK;
  // If audio is present write audio samples up to the Video-timestamp + fReadAhead
  while (fAudioTime + fAudioStart < TimeStamp + fReadAhead) and
    (not fAudioDone) do
  begin
    // pull a sample out of the audio source reader
    hr := pSourceReader.ReadSample(
      fAudioStreamIndex, // get a sample from audio stream
      0, // no source reader controller flags
      @ActualStreamIndex, // get actual index of the stream
      @flags, // get flags for this sample
      @AudioTimestamp, // get the timestamp for this sample
      @pAudioSample); // get the actual sample

    if not succeeded(hr) then
      goto Done;

    if ((flags and MF_SOURCE_READERF_STREAMTICK) <> 0) then
    begin
      pSinkWriter.SendStreamTick(
        fSinkStreamIndexAudio,
        AudioTimestamp + fAudioStart);
      continue;
    end;
    // To be on the safe side we check all flags for which
    // further reading would not make any sense
    // and set fAudioDone to true
    if ((flags and MF_SOURCE_READERF_ENDOFSTREAM) <> 0) or
      ((flags and MF_SOURCE_READERF_ERROR) <> 0) or
      ((flags and MF_SOURCE_READERF_NEWSTREAM) <> 0) or
      ((flags and MF_SOURCE_READERF_NATIVEMEDIATYPECHANGED) <> 0) or
      ((flags and MF_SOURCE_READERF_ALLEFFECTSREMOVED) <> 0) then
    begin
      fAudioDone := true;
    end;
    if (pAudioSample <> nil) then
    begin

      hr := pAudioSample.GetSampleDuration(@AudioSampleDuration);
      if not succeeded(hr) then
        goto Done;
      hr := pAudioSample.SetSampleTime(AudioTimestamp + fAudioStart);
      if not succeeded(hr) then
        goto Done;
      hr := pAudioSample.SetSampleDuration(AudioSampleDuration);
      if not succeeded(hr) then
        goto Done;
      // send sample to sink-writer
      hr := pSinkWriter.WriteSample(
        fSinkStreamIndexAudio,
        pAudioSample);
      if not succeeded(hr) then
        goto Done;
      // new end of sample time
      fAudioTime := AudioTimestamp + AudioSampleDuration;
    end;
    // fAudioDuration can be false!
    // if fAudioTime >= fAudioDuration then
    // fAudioDone := true;
    if fAudioDone then
      hr := pSinkWriter.NotifyEndOfSegment(fSinkStreamIndexAudio);
    // The following should not be necessary in Delphi,
    // since interfaces are automatically released,
    // but it fixes a memory leak when reading .mkv-files.
    SafeRelease(pAudioSample);
  end;
Done:
  result := hr;
end;

procedure TBitmapEncoderWMF.WriteOneFrame(
  TimeStamp, Duration: int64);
var
  pSample: IMFSample;
  Count: integer;
  pSampleAudio: IMFSample;
  i, imax: DWord;
  DoAbort: boolean;
  hr: HResult;
const
  ProcName = 'TBitmapEncoderWMF.WriteOneFrame';
  // is only used once to speed up code
  procedure CheckFail(hr: HResult);
  begin
    inc(Count);
    if not succeeded(hr) then
    begin
      if succeeded(hrCoInit) then
        CoUninitialize;
      raise Exception.Create('Fail in call nr. ' + IntToStr(Count) + ' of ' +
        ProcName + ' with result $' + IntToHex(hr, 8));
    end;
  end;

begin
  if not fInitialized then
    exit;
  Count := 0;
  hr := S_OK;
  // The encoder collects a number of video and audio samples in a "leaky bucket" before
  // writing a chunk of the file. There need to be enough audio-samples in the bucket, so
  // we read ahead in the audio-file, otherwise video-frames might be dropped in an attempt
  // to "match to audio" (?).
  if fWriteAudio then
  begin
    if TimeStamp < fAudioStart then
    // write silence to the audio stream
    begin
      if TimeStamp = 0 then
        imax := 2
      else
        imax := 0;
      for i := 0 to imax do
      begin
        hr := MFCreateSample(pSampleAudio);
        if succeeded(hr) then
          hr := pSampleAudio.AddBuffer(pSampleBufferAudio);
        // write silence to the sinkwriter for 2 video frame durations ahead.
        if succeeded(hr) then
          hr := pSampleAudio.SetSampleTime(TimeStamp + (2 - imax + i) *
            Duration);
        if succeeded(hr) then
          hr := pSampleAudio.SetSampleDuration(Duration);
        if succeeded(hr) then
          hr := pSinkWriter.WriteSample(
            fSinkStreamIndexAudio,
            pSampleAudio);
        if succeeded(hr) then
          hr := pSampleBufferAudio.SetCurrentLength(fBufferSizeAudio);
        SafeRelease(pSampleAudio);
        CheckFail(hr);
      end;
    end
    else if (TimeStamp >= fAudioTime + fAudioStart) and
      (not fAudioDone) then
      hr := WriteAudio(TimeStamp);
  end;

  // Create a media sample and add the buffer to the sample.
  if succeeded(hr) then
    hr := MFCreateSample(pSample);

  if succeeded(hr) then
    hr := pSample.AddBuffer(pSampleBuffer);

  if succeeded(hr) then
    hr := pSample.SetSampleTime(TimeStamp);

  if succeeded(hr) then
    hr := pSample.SetSampleDuration(Duration);

  // if succeeded(hr) then
  // if IsKeyFrame then
  // hr := (pSample as IMFAttributes).SetUINT32(
  // MFSampleExtension_Discontinuity,
  // 1);
  // Send the sample to the Sink Writer.
  if succeeded(hr) then
    hr := pSinkWriter.WriteSample(
      fSinkStreamIndexVideo,
      pSample);

  // Throw excepton if failed
  CheckFail(hr);

  inc(fFrameCount);
  // Timestamp for the next frame
  // fWriteStart := TimeStamp + Duration;
  // Adjust fWriteStart to "exact" frame-time boundaries. Improves timing.
  fWriteStart := Trunc(fFrameCount * fExactSampleDuration);
  fVideoTime := fWriteStart div 10000;

  if Assigned(fOnProgress) then
    if fFrameCount mod 30 = 1 then
    begin
      DoAbort := false;
      fOnProgress(
        self,
        fFrameCount,
        fVideoTime,
        DoAbort);
      if DoAbort then
        Finalize;
    end;
  // give the encoder-threads a chance to do their work
  HandleMessages(GetCurrentThread());
  Sleep(fGPUPriority);
end;

function Interpolate(
  Z1, Z2: TZoom;
  t:
  double)
  : TZoom; inline;
begin
  t := StartSlowEndSlow(t);
  result.xCenter := t * (Z2.xCenter - Z1.xCenter) + Z1.xCenter;
  result.yCenter := t * (Z2.yCenter - Z1.yCenter) + Z1.yCenter;
  result.Radius := t * (Z2.Radius - Z1.Radius) + Z1.Radius;
end;

procedure TBitmapEncoderWMF.ZoomInOutTransition(
  const Sourcebm, Targetbm: TBitmap;
  ZoomSource, ZoomTarget:   TZoom;
  EffectTime:               integer;
  cropSource, cropTarget:   boolean;
  stretchSource:            boolean = false;
  stretchTarget:            boolean = false);
var
  DurMs: integer;
begin
  if not fInitialized then
    exit;
  AddFrame(
    Sourcebm,
    cropSource,
    stretchSource);
  DurMs := Trunc(1 / 10000 * fSampleDuration);
  ZoomInOutTransitionTo(
    Targetbm,
    ZoomSource,
    ZoomTarget,
    EffectTime - DurMs,
    cropTarget,
    stretchTarget);
end;

procedure TBitmapEncoderWMF.ZoomInOutTransitionTo(
  const
  Targetbm:
  TBitmap;
  ZoomSource, ZoomTarget: TZoom;
  EffectTime:
  integer;
  cropTarget:
  boolean;
  stretchTarget:
  boolean = false);
var
  RGBASource, RGBATarget, RGBATweenSource, RGBATweenTarget, RGBATween: TBitmap;
  StartTime, EndTime: int64;
  fact: double;
  alpha: byte;
  t: double;
  ZoomTweenSource, ZoomTweenTarget: TRectF;
begin
  if not fInitialized then
    exit;
  RGBASource := TBitmap.Create;
  RGBATarget := TBitmap.Create;
  RGBATweenSource := TBitmap.Create;
  RGBATweenTarget := TBitmap.Create;
  RGBATween := TBitmap.Create;
  try
    RGBASource.Assign(fBmRGBA);
    BitmapToRGBA(
      Targetbm,
      RGBATarget,
      cropTarget,
      stretchTarget);
    RGBATween.PixelFormat := pf32bit;
    RGBATween.SetSize(
      fVideoWidth,
      fVideoHeight);
    StartTime := fWriteStart;
    EndTime := StartTime + EffectTime * 10000;
    fact := 1 / 10000 / EffectTime;
    while EndTime - fWriteStart > 0 do
    begin
      t := fact * (fWriteStart - StartTime);
      ZoomTweenSource := Interpolate(_FullZoom, ZoomSource, t)
        .ToRectF(fVideoWidth, fVideoHeight);
      ZoomTweenTarget := Interpolate(ZoomTarget, _FullZoom, t)
        .ToRectF(fVideoWidth, fVideoHeight);
      uScaleWMF.ZoomResampleParallelThreads(
        fVideoWidth,
        fVideoHeight,
        RGBASource,
        RGBATweenSource,
        ZoomTweenSource,
        cfBilinear,
        0,
        amIgnore,
        @fThreadPool);
      uScaleWMF.ZoomResampleParallelThreads(
        fVideoWidth,
        fVideoHeight,
        RGBATarget,
        RGBATweenTarget,
        ZoomTweenTarget,
        cfBilinear,
        0,
        amIgnore,
        @fThreadPool);

      // HandleThreadMessages(GetCurrentThread,1);

      alpha := Trunc(255 * t);
      Alphablend(
        RGBATweenSource,
        RGBATweenTarget,
        RGBATween,
        alpha,
        @fThreadPool);
      bmRGBAToSampleBuffer(RGBATween);
      WriteOneFrame(
        fWriteStart,
        fSampleDuration);
    end;
    fBmRGBA.Assign(RGBATarget);
  finally
    RGBASource.Free;
    RGBATarget.Free;
    RGBATweenSource.Free;
    RGBATweenTarget.Free;
    RGBATween.Free;
  end;
end;

procedure TBitmapEncoderWMF.Freeze(EffectTime: integer);
var
  StartTime, EndTime: int64;
begin
  if not fInitialized then
    exit;
  StartTime := fWriteStart;
  EndTime := StartTime + EffectTime * 10000;
  while fWriteStart < EndTime - fSampleDuration do
  begin
    if (fFrameCount mod fBrake) = (fBrake - 1) then
    begin
      HandleMessages(
        GetCurrentThread(),
        1);
      Sleep(fGPUPriority);
    end;
    WriteOneFrame(
      fWriteStart,
      fSampleDuration);
  end;
  // Force the last one to be a keyframe (?) It compiles and runs, but does it work?
  WriteOneFrame(
    fWriteStart,
    fSampleDuration);
  // true);
end;

function TBitmapEncoderWMF.GetAudioDuration: int64;
begin
  result := 0;
  if fWriteAudio then
    if fAudioDuration > 0 then
      result := fAudioDuration div 10000;
end;

// not working at the moment
// function TBitmapEncoderWMF.GetEncodingStats: TVideoStats;
// var
// hr: HResult;
// vsLoc: MF_Sink_Writer_Statistics;
// begin
// result := Default (TVideoStats);
// if fInitialized then
// begin
// vsLoc.cb := SizeOf(MF_Sink_Writer_Statistics);
// hr := pSinkWriter.GetStatistics(
// 0,
// vsLoc);
// if succeeded(hr) then
// result := vsLoc
// else
// Raise Exception.Create('GetStatistics returns ' + IntToHex(hr, 8));
// end;
// end;

{ TZoom }

function TZoom.ToRectF(Width, Height: integer)
  : TRectF;
begin
  result.Left := Max(
    (xCenter - Radius) * Width,
    0);
  result.Right := min(
    (xCenter + Radius) * Width,
    Width);
  result.Top := Max(
    (yCenter - Radius) * Height,
    0);
  result.Bottom := min(
    (yCenter + Radius) * Height,
    Height);
end;

var
  _HrTimer: HResult;
  _TimerRes: Uint32;

initialization

// Set time resolution for precise waits, try for 1 ms
_HrTimer := SetTimerResolution(
  1,
  _TimerRes);

finalization

if succeeded(_HrTimer) then
  TimeEndPeriod(_TimerRes);

{$IFDEF O_PLUS}
{$O+}
{$UNDEF O_PLUS}
{$ENDIF}

end.
