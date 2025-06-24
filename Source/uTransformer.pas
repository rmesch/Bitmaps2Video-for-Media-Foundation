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
unit uTransformer;

// Contains:
// TVideoTransformer:
// transforms video samples to uncompressed RGB32-samples with pixel-aspect
// 1x1, optionally changing the frame height (width by aspect), and the frame rate.
// Designed to de-interlace interlaced videos, but not sure whether it really works.

// Planned addition:
// TAudioTransformer doing the analogous for audio samples.

interface

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
  System.SyncObjs,
  // mfPack headers
  WinApi.MediaFoundationApi.MfApi,
  WinApi.MediaFoundationApi.MfUtils,
  WinApi.MediaFoundationApi.MfReadWrite,
  WinApi.MediaFoundationApi.Mfobjects,
  WinApi.MediaFoundationApi.CodecApi,
  WinApi.ActiveX.PropIdl,
  WinApi.MediaFoundationApi.MfIdl,
  WinApi.ActiveX.PropVarUtil,
  WinApi.WinApiTypes;

const
  Msg_Audio = WM_User + 2;

type

  TVideoInfo = record
    Codec: TGUID;
    CodecName: string;
    Duration: int64;
    DurationString: string;
    VideoWidth, VideoHeight: DWord;
    FrameRate: double;
    PixelAspect: double;
    VideoAspect: double;
    VideoAspectString: string;
    InterlaceMode: DWord;
    InterlaceModeName: string;
    AudioStreamCount: DWord;
  end;

  eVideoFormatException = class(Exception);
  eAudioFormatException = class(Exception);

  TVideoTransformer = class
  private
    pReader: IMFSourceReader;
    hrCoInit, hrStartUp: HResult;
    fVideoInfo: TVideoInfo;
    pMediaTypeOut: IMFMediaType;
    fNewWidth, fNewHeight: DWord;
    fNewFrameRate: single;
    fInputFile: string;
    fEndOfFile: boolean;
  public
    constructor Create(
      const InputFile: string;
      NewHeight:       DWord;
      NewFrameRate:    single); overload;
    constructor Create(
      const InputFile: string;
      NewHeight:       DWord;
      NewFrameRate:    single;
      FrameRateCap:    single); overload;
    function NextValidSampleToBitmap(
      const bm:                TBitmap;
      out Timestamp, Duration: int64)
      : boolean;
    procedure GetNextValidSample(
      out pSample:             IMFSample;
      out Timestamp, Duration: int64);
    function Seek(VideoTime: int64)
      : boolean;
    function SampleCount: UInt32;
    destructor Destroy; override;
    property NewVideoWidth: DWord read fNewWidth;
    property NewVideoHeight: DWord read fNewHeight;
    property NewFrameRate: single read fNewFrameRate;
    property EndOfFile: boolean read fEndOfFile;
    property VideoInfo: TVideoInfo read fVideoInfo;
  end;

function GetVideoInfo(const VideoFileName: string)
  : TVideoInfo;

function GetFrameBitmap(
  const VideoFileName: string;
  const bm:            TBitmap;
  bmHeight:            DWord;
  FrameNo:             DWord)
  : boolean;

/// <summary> Changes system timer resolution [ms]. Must be matched with TimeEndPeriod(SetResolution). </summary>
/// <param name = "TargetResolution">Desired timer resolution in ms </param>
/// <param name = "SetResolution"> Resolution actually set </param>
function SetTimerResolution(
  TargetResolution:  UInt32;
  var SetResolution: UInt32)
  : HResult;


implementation

function SetTimerResolution(
  TargetResolution:  UInt32;
  var SetResolution: UInt32)
  : HResult;
var
  tc: TimeCaps;
begin
  Result := E_Fail;
  if TimeGetDevCaps(@tc, SizeOF(TimeCaps)) <> TIMERR_NOERROR then
    exit;
  SetResolution := min(
    max(tc.wPeriodMin, TargetResolution),
    tc.wPeriodMax);
  if TimeBeginPeriod(SetResolution) = TIMERR_NOERROR then
    Result := S_OK;
end;

function GetVideoInfo(const VideoFileName: string)
  : TVideoInfo;
var
  Count: integer;
  GUID: TGUID;
  _var: TPropVariant;
  Num, Den: DWord;
  pReader: IMFSourceReader;
  pMediaTypeIn, pMediaTypeOut, pPartialType: IMFMediaType;
  mfArea: MFVideoArea;
  attribs: IMFAttributes;
  hrCoInit, hrStartUp: HResult;
  pb: PByte;
  FourCC: DWord;
  FourCCString: string[4];
  I: integer;
  hr: HResult;
  err: string;
  AudioStreamNo: DWord;
const
  ProcName = 'GetVideoInfo';
  procedure CheckFail(hr: HResult);
  begin
    inc(Count);
    if not succeeded(hr) then
    begin
      err := '$' + IntToHex(hr, 8);
      raise Exception.Create('Fail in call nr. ' + IntToStr(Count) + ' of ' +
        ProcName + ' with result ' + err);
    end;
  end;

begin
  Count := 0;
  pReader := nil;
  hrCoInit := E_Fail;
  hrStartUp := E_Fail;
  try
    hrCoInit := CoInitializeEx(
      nil,
      COINIT_APARTMENTTHREADED or
      COINIT_DISABLE_OLE1DDE);
    CheckFail(hrCoInit);

    hrStartUp := MFStartup(MF_VERSION);
    CheckFail(hrStartUp);

    CheckFail(MFCreateAttributes(attribs, 1));
    CheckFail(attribs.SetUINT32(MF_SOURCE_READER_ENABLE_VIDEO_PROCESSING,
      UInt32(true)));
    // Create a sourcereader for the video file
    CheckFail(MFCreateSourceReaderFromURL(PWideChar(VideoFileName), attribs,
      pReader));
    // Configure the sourcereader to decode to RGB32
    CheckFail(pReader.GetNativeMediaType
      (DWord(MF_SOURCE_READER_FIRST_VIDEO_STREAM), 0, pMediaTypeIn));
    CheckFail(MFCreateMediaType(pPartialType));
    CheckFail(pPartialType.SetGUID(MF_MT_MAJOR_TYPE, MFMediaType_Video));
    CheckFail(pPartialType.SetGUID(MF_MT_SUBTYPE, MFVideoFormat_RGB32));
    CheckFail(pReader.SetCurrentMediaType(MF_SOURCE_READER_FIRST_VIDEO_STREAM,
      0, pPartialType));
    CheckFail(pReader.GetCurrentMediaType(MF_SOURCE_READER_FIRST_VIDEO_STREAM,
      pMediaTypeOut));
    CheckFail(pMediaTypeIn.GetMajorType(GUID));
    CheckFail(pMediaTypeIn.GetGUID(MF_MT_SUBTYPE, GUID));
    Result.Codec := GUID;
    if GUID = MFVideoFormat_MPEG2 then
      Result.CodecName := 'mpeg2'
    else
    begin
      FourCC := GUID.D1;
      pb := PByte(@FourCC);
      SetLength(
        FourCCString,
        4);
      for I := 1 to 4 do
      begin
        FourCCString[I] := AnsiChar(pb^);
        inc(pb);
      end;
      Result.CodecName := string(FourCCString);
    end;
    PropVariantInit(_var);
    CheckFail(pReader.GetPresentationAttribute(MF_SOURCE_READER_MEDIASOURCE,
      MF_PD_DURATION, _var));
    CheckFail(PropVariantToInt64(_var, Result.Duration));
    Result.DurationString:=HnsTimeToStr(Result.Duration,False) + '[h:m:s]';
    // Result.Duration := _var.hVal.QuadPart; Makes no difference.
    PropVariantClear(_var);

    ZeroMemory(
      @mfArea,
      SizeOF(mfArea));

    // for some codecs, like HEVC, MF_MT_FRAME_SIZE does not
    // return the correct video size for display.
    // So we check first whether the correct size is
    // available via an MFVideoArea.
    hr := pMediaTypeIn.GetBlob(
      MF_MT_PAN_SCAN_APERTURE,
      @mfArea,
      SizeOF(MFVideoArea),
      nil);
    if Failed(hr) then
      hr := pMediaTypeIn.GetBlob(
        MF_MT_MINIMUM_DISPLAY_APERTURE,
        @mfArea,
        SizeOF(MFVideoArea),
        nil);
    if succeeded(hr) then
    begin
      Result.VideoWidth := mfArea.Area.cx;
      Result.VideoHeight := mfArea.Area.cy;
    end
    else
      CheckFail(MFGetAttributeSize(pMediaTypeIn, MF_MT_FRAME_SIZE,
        Result.VideoWidth, Result.VideoHeight));
    CheckFail(MFGetAttributeRatio(pMediaTypeIn, MF_MT_FRAME_RATE, Num, Den));
    Result.FrameRate := Num / Den;
    // For some codecs it only reads the correct pixel aspect off the decoding media type
    hr := MFGetAttributeRatio(
      pMediaTypeOut,
      MF_MT_PIXEL_ASPECT_RATIO,
      Num,
      Den);
    if Failed(hr) then // MF_E_PROPERTY_TYPE_NOT_ALLOWED
      CheckFail(MFGetAttributeRatio(pMediaTypeIn, MF_MT_PIXEL_ASPECT_RATIO,
        Num, Den));
    Result.PixelAspect := Num / Den;
    if Result.VideoHeight>0 then
    Result.VideoAspect := Result.VideoWidth/Result.VideoHeight*Result.PixelAspect;
    if abs(Result.VideoAspect-16/9)<1E-4 then
    Result.VideoAspectString:='16:9'
    else
    if abs(Result.VideoAspect-4/3)<1E-4 then
    Result.VideoAspectString:='4:3'
    else
    Result.VideoAspectString:=FloatToStrF(Result.VideoAspect,ffFixed,6,4);

    hr := pMediaTypeIn.GetUINT32(
      MF_MT_INTERLACE_MODE,
      Result.InterlaceMode);
    if Failed(hr) then
      Result.InterlaceMode := 0;
    case Result.InterlaceMode of
      0:
        Result.InterlaceModeName := 'Unknown';
      2:
        Result.InterlaceModeName := 'Progressive';
      3:
        Result.InterlaceModeName := 'UpperFirst';
      4:
        Result.InterlaceModeName := 'LowerFirst';
      5:
        Result.InterlaceModeName := 'SingleUpper';
      6:
        Result.InterlaceModeName := 'SingleLower';
      7:
        Result.InterlaceModeName := 'InterlaceOrProgressive';
    else
      Result.InterlaceModeName := 'Unknown';
    end;
    // Get the nr. of audio-streams
    // Fails for .vob
    Result.AudioStreamCount := 0;
    AudioStreamNo := 0;
    repeat
      hr := pReader.GetNativeMediaType(AudioStreamNo, 0, pMediaTypeIn);
      if Failed(hr) then
      begin
        err := IntToHex(
          hr,
          8); // MF_E_INVALIDSTREAMNUMBER
        break;
      end;
      CheckFail(pMediaTypeIn.GetMajorType(GUID));
      if GUID = MFMediaType_Audio then
        inc(Result.AudioStreamCount);
      inc(AudioStreamNo);
    until False;
  finally
    if succeeded(hrStartUp) then
      MFShutdown();
    if succeeded(hrCoInit) then
      COUninitialize;
  end;
end;

function GetFrameBitmap(
  const VideoFileName: string;
  const bm:            TBitmap;
  bmHeight:            DWord;
  FrameNo:             DWord)
  : boolean;
var
  VT: TVideoTransformer;
  pSample: IMFSample;
  Timestamp, Duration, SeekTime: int64;
begin
  Result := False;
  if FrameNo <= 0 then
    exit;
  VT := TVideoTransformer.Create(
    VideoFileName,
    bmHeight,
    0);
  try
    SeekTime := Trunc((FrameNo - 1) / VT.VideoInfo.FrameRate * 1000 * 10000);
    If not VT.Seek(SeekTime) then
      exit;
    Repeat
      VT.GetNextValidSample(pSample, Timestamp, Duration);
    Until (Timestamp >= SeekTime) or VT.EndOfFile;
    if not VT.EndOfFile then
    begin
      Result := VT.NextValidSampleToBitmap(
        bm,
        Timestamp,
        Duration);
    end;

  finally
    VT.Free;
  end;
end;

{ TVideoTransformer }

constructor TVideoTransformer.Create(
  const InputFile: string;
  NewHeight:       DWord;
  NewFrameRate:    single;
  FrameRateCap:    single);
var
  Count: integer;
  attribs: IMFAttributes;
  pPartialType: IMFMediaType;
const
  ProcName = 'TVideoTransformer.Create';
  procedure CheckFail(hr: HResult);
  begin
    inc(Count);
    if not succeeded(hr) then
    begin
      raise Exception.Create('Fail in call nr. ' + IntToStr(Count) + ' of ' +
        ProcName + ' with result ' + IntToHex(hr, 8));
    end;
  end;

begin
  Count := 0;
  hrCoInit := E_Fail;
  hrStartUp := E_Fail;
  fInputFile := InputFile;
  try

    fVideoInfo := GetVideoInfo(fInputFile);
    if NewFrameRate = 0 then
      if fVideoInfo.FrameRate > 240 then // probably erroneuous value
        fNewFrameRate := 60
      else
        fNewFrameRate := fVideoInfo.FrameRate
    else
      fNewFrameRate := NewFrameRate;
    if NewHeight = 0 then
      fNewHeight := fVideoInfo.VideoHeight
    else
      fNewHeight := NewHeight;
    fNewFrameRate := min(
      fNewFrameRate,
      FrameRateCap);
    hrCoInit := CoInitializeEx(
      nil,
      COINIT_APARTMENTTHREADED or
      COINIT_DISABLE_OLE1DDE);
    CheckFail(hrCoInit);
    hrStartUp := MFStartup(MF_VERSION);
    CheckFail(hrStartUp);

    CheckFail(MFCreateAttributes(attribs, 1));

    // Enable the source-reader to make color-conversion, change video size, frame-rate and interlace-mode
    CheckFail(attribs.SetUINT32
      (MF_SOURCE_READER_ENABLE_ADVANCED_VIDEO_PROCESSING, UInt32(true)));
    // The next was an attempt to enable hardware decoding, but
    // it doesn't work for the target mediatype MFVideoFormat_RGB32

    // if (fVideoInfo.Codec = MFVideoFormat_H264) or
    // (fVideoInfo.Codec = MFVideoFormat_HEVC) then
    // CheckFail(attribs.SetUINT32(MF_READWRITE_ENABLE_HARDWARE_TRANSFORMS,
    // UInt32(true)));

    // Create a sourcereader for the video file
    CheckFail(MFCreateSourceReaderFromURL(PWideChar(fInputFile), attribs,
      pReader));
    // Configure the sourcereader to decode to RGB32
    CheckFail(MFCreateMediaType(pPartialType));
    CheckFail(pPartialType.SetGUID(MF_MT_MAJOR_TYPE, MFMediaType_Video));
    CheckFail(pPartialType.SetGUID(MF_MT_SUBTYPE, MFVideoFormat_RGB32));
    CheckFail(pPartialType.SetUINT32(MF_MT_INTERLACE_MODE, 2));
    // 2=progressive.
    CheckFail(MFSetAttributeRatio(pPartialType, MF_MT_FRAME_RATE,
      round(fNewFrameRate * 100), 100));

    fNewWidth := round(fNewHeight * fVideoInfo.VideoWidth /
      fVideoInfo.VideoHeight * fVideoInfo.PixelAspect);

    CheckFail(MFSetAttributeRatio(pPartialType,
      MF_MT_PIXEL_ASPECT_RATIO, 1, 1));
    CheckFail(MFSetAttributeSize(pPartialType, MF_MT_FRAME_SIZE, fNewWidth,
      fNewHeight));
    CheckFail(pReader.SetCurrentMediaType(MF_SOURCE_READER_FIRST_VIDEO_STREAM,
      0, pPartialType));
    CheckFail(pReader.GetCurrentMediaType(MF_SOURCE_READER_FIRST_VIDEO_STREAM,
      pMediaTypeOut));
    // Prevent memory leak
    CheckFail(pReader.SetStreamSelection(MF_SOURCE_READER_ALL_STREAMS, False));
    // Ensure the stream is selected.
    CheckFail(pReader.SetStreamSelection
      (MF_SOURCE_READER_FIRST_VIDEO_STREAM, true));
    fEndOfFile := False;
  except
    raise eVideoFormatException.Create
      ('Video format of input file not supported.');
  end;
end;

constructor TVideoTransformer.Create(
  const InputFile: string;
  NewHeight:       DWord;
  NewFrameRate:    single);
begin
  Create(
    InputFile,
    NewHeight,
    NewFrameRate,
    240);
end;

destructor TVideoTransformer.Destroy;
begin
  if succeeded(hrStartUp) then
    MFShutdown();
  if succeeded(hrCoInit) then
    COUninitialize;
  inherited;
end;

procedure TVideoTransformer.GetNextValidSample(
  out pSample:             IMFSample;
  out Timestamp, Duration: int64);
var
  Count: integer;
  pSampleLoc: IMFSample;
  Flags: DWord;
  hr: HResult;
const
  ProcName = 'TVideoTransformer.GetNextValidSample';
  procedure CheckFail(hr: HResult);
  begin
    inc(Count);
    if not succeeded(hr) then
    begin
      raise Exception.Create('Fail in call nr. ' + IntToStr(Count) + ' of ' +
        ProcName + ' with result ' + IntToHex(hr, 8));
    end;
  end;

begin
  Count := 0;
  pSample := nil;
  if fEndOfFile then
    exit;
  Repeat
    CheckFail(pReader.ReadSample(MF_SOURCE_READER_FIRST_VIDEO_STREAM, 0, nil,
      @Flags, nil, @pSampleLoc));
    if ((Flags and MF_SOURCE_READERF_STREAMTICK) <> 0) then
      continue;
    // To be on the safe side we check all flags for which
    // further reading would not make any sense
    // and set EndOfFile to true
    if ((Flags and MF_SOURCE_READERF_ENDOFSTREAM) <> 0) or
      ((Flags and MF_SOURCE_READERF_ERROR) <> 0) or
      ((Flags and MF_SOURCE_READERF_NEWSTREAM) <> 0) or
      ((Flags and MF_SOURCE_READERF_NATIVEMEDIATYPECHANGED) <> 0) or
      ((Flags and MF_SOURCE_READERF_ALLEFFECTSREMOVED) <> 0)
    then

    begin
      fEndOfFile := true;
      break;
    end;
    if pSampleLoc <> nil then
    begin
      SafeRelease(pSample);
      pSample := pSampleLoc;
      hr := pSample.GetSampleTime(@Timestamp);
      if succeeded(hr) then

        hr := pSample.GetSampleDuration(@Duration);
      // fVideoInfo.Duration can return the wrong value!
      // if Timestamp + Duration >= fVideoInfo.Duration then
      // fEndOfFile := true;
      if Failed(hr) then
      begin
        fEndOfFile := true;
        pSample := nil;
      end;
      break;
    end
    else
    begin
      SafeRelease(pSampleLoc);
      pSampleLoc := nil;
    end;
    // Can it happen that we get an infinite loop here?
  Until False;
end;

function TVideoTransformer.NextValidSampleToBitmap(
  const bm:                TBitmap;
  out Timestamp, Duration: int64)
  : boolean;
var
  Count: integer;
  pSample: IMFSample;
  pBuffer: IMFMediaBuffer;
  Stride: integer;
  pRow, pData: PByte;
  ImageSize: DWord;
const
  ProcName = 'TVideoTransformer.NextValidSampleToBitmap';
  procedure CheckFail(hr: HResult);
  begin
    inc(Count);
    if not succeeded(hr) then
    begin
      raise Exception.Create('Fail in call nr. ' + IntToStr(Count) + ' of ' +
        ProcName + ' with result $' + IntToHex(hr, 8));
    end;
  end;

begin
  Result := False;
  if fEndOfFile then
    exit;
  Count := 0;
  GetNextValidSample(
    pSample,
    Timestamp,
    Duration);
  // an invalid sample is nil
  if assigned(pSample) then
  begin
    CheckFail(pSample.ConvertToContiguousBuffer(@pBuffer));
    if assigned(pBuffer) then
    begin
      bm.PixelFormat := pf32bit;
      bm.SetSize(
        fNewWidth,
        fNewHeight);
      Stride := 4 * fNewWidth;
      pRow := bm.ScanLine[0];
      CheckFail(pBuffer.Lock(pData, nil, @ImageSize));
      // Assert(ImageSize = 4 * fNewWidth * fNewHeight);
      CheckFail(MFCopyImage(pRow { Destination buffer. } ,
        -Stride { Destination stride. } ,
        pData, { First row in source. }
        Stride { Source stride. } ,
        Stride { Image width in bytes. } ,
        fNewHeight { Image height in pixels. } ));
      CheckFail(pBuffer.Unlock);
      CheckFail(pBuffer.SetCurrentLength(0));
      SafeRelease(pBuffer);
      Result := true;
    end;
  end;

end;

function TVideoTransformer.SampleCount: UInt32;
var
  pSample: IMFSample;
  Timestamp, Duration: int64;
begin
  Result := 0;
  pSample := nil;
  while not EndOfFile do
  begin
    GetNextValidSample(
      pSample,
      Timestamp,
      Duration);
    if pSample <> nil then
      inc(Result);
    SafeRelease(pSample);
  end;

end;

function TVideoTransformer.Seek(VideoTime: int64)
  : boolean;
var
  Count: integer;
  err: string;
  var_: PropVariant;
const
  ProcName = 'TVideoTransformer.Seek';
  procedure CheckFail(hr: HResult);
  begin
    inc(Count);
    if not succeeded(hr) then
    begin
      err := '$' + IntToHex(hr, 8);
      raise Exception.Create('Fail in call nr. ' + IntToStr(Count) + ' of ' +
        ProcName + ' with result ' + err);
    end;
  end;

begin
  Count := 0;
  Result := (VideoTime < fVideoInfo.Duration);
  if Result then
  begin
    CheckFail(InitPropVariantFromInt64(VideoTime, &var_));
    Result := succeeded(pReader.SetCurrentPosition(GUID_NULL, var_));
    PropVariantClear(&var_);
    fEndOfFile := False;
  end;
end;

{$IFDEF O_PLUS}
{$O+}
{$UNDEF O_PLUS}
{$ENDIF}

end.
