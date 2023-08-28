// ==============================================================================
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
// ==============================================================================
// Copyright © 2023 Renate Schaaf
//
// Requires MFPack at https://github.com/FactoryXCode/MfPack
// Download the repository and add the folder "src" to your library path.
//
// The sinkwriter sample in this repository got me started on this project.
// Thanks for the great work!
// ==============================================================================
unit uTransformer;

// Contains:
// TVideoTransformer:
// transforms video samples to uncompressed RGB32-samples with pixel-aspect
// 1x1, optionally changing the frame height (width by aspect), and the frame rate.
// Designed to de-interlace interlaced videos, but not sure whether it really works.

// Planned addition:
// TAudioTransformer doing the analogous for audio samples.

interface

uses
  WinApi.Windows,
  WinApi.ActiveX,
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
  WinApi.ActiveX.PropVarUtil;

type
  TVideoInfo = record
    Codec: TGUID;
    CodecName: string;
    Duration: int64;
    VideoWidth, VideoHeight: DWord;
    FrameRate: single;
    PixelAspect: single;
    InterlaceMode: DWord;
    InterlaceModeName: string;
    AudioStreamCount: DWord;
  end;

  eVideoFormatException = class(Exception);

  TVideoTransformer = class
  private
    pReader: IMFSourceReader;
    hrCoInit: HResult;
    fVideoInfo: TVideoInfo;
    pMediaTypeOut: IMFMediaType;
    fNewWidth, fNewHeight: DWord;
    fNewFrameRate: single;
    fInputFile: string;
    fEndOfFile: boolean;
  public
    constructor Create(const InputFile: string; NewHeight: DWord;
      NewFrameRate: single);
    procedure NextValidSampleToBitmap(const bm: TBitmap;
      out Timestamp, Duration: int64);
    procedure GetNextValidSample(out pSample: IMFSample;
      out Timestamp, Duration: int64);
    destructor Destroy; override;
    property NewVideoWidth: DWord read fNewWidth;
    property NewVideoHeight: DWord read fNewHeight;
    property NewFrameRate: single read fNewFrameRate;
    property EndOfFile: boolean read fEndOfFile;
    property VideoInfo: TVideoInfo read fVideoInfo;
  end;

function GetVideoInfo(const VideoFileName: string): TVideoInfo;

// Very slow at the moment. Need to apply seeking to speed it up.
function GetFrameBitmap(const VideoFileName: string; const bm: TBitmap;
  bmHeight: DWord; FrameNo: DWord): boolean;

implementation

function GetVideoInfo(const VideoFileName: string): TVideoInfo;
var
  Count: integer;
  GUID: TGUID;
  _var: TPropVariant;
  Num, Den: DWord;
  pReader: IMFSourceReader;
  pMediaTypeIn, pMediaTypeOut, pPartialType: IMFMediaType;
  mfArea: MFVideoArea;
  attribs: IMFAttributes;
  hrCoInit, hrStartup: HResult;
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
      err := '$' + IntToHex(hr);
      raise Exception.Create('Fail in call nr. ' + IntToStr(Count) + ' of ' +
        ProcName + ' with result ' + err);
    end;
  end;

begin
  Count := 0;
  pReader := nil;
  hrCoInit := E_FAIL;
  hrStartup := E_FAIL;
  try
    hrCoInit := CoInitializeEx(nil, COINIT_APARTMENTTHREADED);
    CheckFail(hrCoInit);

    hrStartup := MFStartup(MF_VERSION);
    CheckFail(hrStartup);

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
      SetLength(FourCCString, 4);
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
    // Result.Duration := _var.hVal.QuadPart; Makes no difference.
    PropVariantClear(_var);

    ZeroMemory(@mfArea, sizeof(mfArea));

    // for some codecs, like HEVC, MF_MT_FRAME_SIZE does not
    // return the correct video size for display.
    // So we check first whether the correct size is
    // available via an MFVideoArea.
    hr := pMediaTypeIn.GetBlob(MF_MT_PAN_SCAN_APERTURE, @mfArea,
      sizeof(MFVideoArea), nil);
    if Failed(hr) then
      hr := pMediaTypeIn.GetBlob(MF_MT_MINIMUM_DISPLAY_APERTURE, @mfArea,
        sizeof(MFVideoArea), nil);
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
    hr := MFGetAttributeRatio(pMediaTypeOut, MF_MT_PIXEL_ASPECT_RATIO,
      Num, Den);
    if Failed(hr) then // MF_E_PROPERTY_TYPE_NOT_ALLOWED
      CheckFail(MFGetAttributeRatio(pMediaTypeIn, MF_MT_PIXEL_ASPECT_RATIO,
        Num, Den));
    Result.PixelAspect := Num / Den;
    hr := pMediaTypeIn.GetUINT32(MF_MT_INTERLACE_MODE, Result.InterlaceMode);
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
        err := IntToHex(hr); // MF_E_IVALIDSTREAMNUMBER
        break;
      end;
      CheckFail(pMediaTypeIn.GetMajorType(GUID));
      if GUID = MFMediaType_Audio then
        inc(Result.AudioStreamCount);
      inc(AudioStreamNo);
    until false;
  finally
    if succeeded(hrStartup) then
      MFShutdown();
    if succeeded(hrCoInit) then
      COUninitialize;
  end;
end;

function GetFrameBitmap(const VideoFileName: string; const bm: TBitmap;
  bmHeight: DWord; FrameNo: DWord): boolean;
var
  VT: TVideoTransformer;
  FrameCount: DWord;
  pSample: IMFSample;
  Timestamp, Duration: int64;
begin
  Result := false;
  VT := TVideoTransformer.Create(VideoFileName, bmHeight, 0);
  try
    FrameCount := 0;
    while (FrameCount + 1 < FrameNo) and (not VT.EndOfFile) do
    begin
      VT.GetNextValidSample(pSample, Timestamp, Duration);
      inc(FrameCount);
    end;
    if not VT.EndOfFile then
    begin
      VT.NextValidSampleToBitmap(bm, Timestamp, Duration);
      Result := true;
    end;

  finally
    VT.Free;
  end;
end;

{ TVideoTransformer }

constructor TVideoTransformer.Create(const InputFile: string; NewHeight: DWord;
  NewFrameRate: single);
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
        ProcName + ' with result ' + IntToHex(hr));
    end;
  end;

begin
  Count := 0;
  fInputFile := InputFile;
  fNewHeight := NewHeight;
  try
    fVideoInfo := GetVideoInfo(fInputFile);
    if NewFrameRate = 0 then
      fNewFrameRate := fVideoInfo.FrameRate
    else
      fNewFrameRate := NewFrameRate;
    hrCoInit := CoInitializeEx(nil, COINIT_APARTMENTTHREADED);
    CheckFail(hrCoInit);
    CheckFail(MFStartup(MF_VERSION));

    CheckFail(MFCreateAttributes(attribs, 1));

    // Enable the source-reader to make color-conversion, change video size, frame-rate and interlace-mode
    CheckFail(attribs.SetUINT32
      (MF_SOURCE_READER_ENABLE_ADVANCED_VIDEO_PROCESSING, UInt32(true)));
    // The next causes problems for some video formats
    // CheckFail(attribs.SetUINT32
    // (MF_READWRITE_ENABLE_HARDWARE_TRANSFORMS, UInt32(true)));
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
    CheckFail(pReader.SetStreamSelection(MF_SOURCE_READER_ALL_STREAMS, false));
    // Ensure the stream is selected.
    CheckFail(pReader.SetStreamSelection
      (MF_SOURCE_READER_FIRST_VIDEO_STREAM, true));
    fEndOfFile := false;
  except
    raise eVideoFormatException.Create
      ('Video format of input file not supported.');
  end;
end;

destructor TVideoTransformer.Destroy;
begin
  MFShutdown();
  if succeeded(hrCoInit) then
    COUninitialize;
  inherited;
end;

procedure TVideoTransformer.GetNextValidSample(out pSample: IMFSample;
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
        ProcName + ' with result ' + IntToHex(hr));
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
      ((Flags and MF_SOURCE_READERF_ALLEFFECTSREMOVED) <> 0) then
    begin
      fEndOfFile := true;
      break;
    end;
    if pSampleLoc <> nil then
    begin
      SafeRelease(pSample);
      pSample := pSampleLoc;
      hr := pSample.GetSampleTime(Timestamp);
      if succeeded(hr) then

        hr := pSample.GetSampleDuration(Duration);
      // fVideoInfo.Duration can return the wrong value!
      // if Timestamp + Duration >= fVideoInfo.Duration then
      // fEndOfFile := true;
      if Failed(hr) then
      begin
        fEndOfFile := true;
        pSample := nil;
      end;
      break;
      sleep(0);
    end;
    // Can it happen that we get an infinite loop here?
  Until false;
end;

procedure TVideoTransformer.NextValidSampleToBitmap(const bm: TBitmap;
  out Timestamp, Duration: int64);
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
        ProcName + ' with result $' + IntToHex(hr));
    end;
  end;

begin
  if fEndOfFile then
    exit;
  Count := 0;
  GetNextValidSample(pSample, Timestamp, Duration);
  // an invalid sample is nil
  if assigned(pSample) then
  begin
    CheckFail(pSample.ConvertToContiguousBuffer(pBuffer));
    if assigned(pBuffer) then
    begin
      bm.PixelFormat := pf32bit;
      bm.SetSize(fNewWidth, fNewHeight);
      Stride := 4 * fNewWidth;
      pRow := bm.ScanLine[0];
      CheckFail(pBuffer.Lock(pData, nil, @ImageSize));
      // Assert(ImageSize = 4 * fNewWidth * fNewHeight);
      CheckFail(MFCopyImage(pRow { Destination buffer. } ,
        -Stride { Destination stride. } , pData,
        { First row in source. }
        Stride { Source stride. } , Stride { Image width in bytes. } ,
        fNewHeight { Image height in pixels. } ));
      CheckFail(pBuffer.Unlock);
      CheckFail(pBuffer.SetCurrentLength(0));
      SafeRelease(pBuffer);
    end;
    sleep(0);
  end;

end;

end.
