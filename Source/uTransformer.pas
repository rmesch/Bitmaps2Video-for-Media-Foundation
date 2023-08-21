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

//Contains:
//TVideoTransformer:
//transforms video samples to uncompressed RGB32-samples with pixel-aspect
//1x1, optionally changing the frame height (width by aspect), and the frame rate.
//Designed to de-interlace interlaced videos, but not sure whether it really works.

//Planned addition:
//TAudioTransformer doing the analogous for audio samples.

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
  WinApi.MediaFoundationApi.MfIdl;

type
  TVideoInfo = record
    Codec: TGUID;
    CodecName: string;
    Duration: int64;
    VideoWidth, VideoHeight: DWord;
    FrameRate: single;
    PixelAspect: single;
    InterlaceMode: DWord;
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
  end;

function GetVideoInfo(const VideoFileName: string): TVideoInfo;

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
  hrCoInit: HResult;
  pb: PByte;
  FourCC: DWord;
  FourCCString: string[4];
  I: integer;
const
  ProcName = 'GetVideoInfo';
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
  pReader := nil;
  hrCoInit := E_FAIL;
  try
    hrCoInit := CoInitializeEx(nil, COINIT_APARTMENTTHREADED);
    CheckFail(hrCoInit);

    CheckFail(MFStartup(MF_VERSION));

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
    CheckFail(pReader.SetStreamSelection(MF_SOURCE_READER_ALL_STREAMS, False));
    // Ensure the stream is selected.
    CheckFail(pReader.SetStreamSelection
      (MF_SOURCE_READER_FIRST_VIDEO_STREAM, true));
    CheckFail(pMediaTypeIn.GetMajorType(GUID));
    if GUID <> MFMediaType_Video then
      raise Exception.Create('Media type is not video');
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
    CheckFail(pReader.GetPresentationAttribute
      (MF_SOURCE_READER_MEDIASOURCE, MF_PD_DURATION, _var));
    Result.Duration := _var.hVal.QuadPart;
    PropVariantClear(_var);
    if Result.Codec = MFVideoFormat_HEVC then
    begin
      ZeroMemory(@mfArea, sizeof(mfArea));
      CheckFail(pMediaTypeIn.GetBlob(MF_MT_MINIMUM_DISPLAY_APERTURE, @mfArea,
        sizeof(MFVideoArea), nil));
      Result.VideoWidth := mfArea.Area.cx;
      Result.VideoHeight := mfArea.Area.cy;
    end
    else
      CheckFail(MFGetAttributeSize(pMediaTypeIn, MF_MT_FRAME_SIZE,
        Result.VideoWidth, Result.VideoHeight));
    CheckFail(MFGetAttributeRatio(pMediaTypeIn, MF_MT_FRAME_RATE, Num, Den));
    Result.FrameRate := Num / Den;
    // It only reads the correct pixel aspect off the decoding media type
    CheckFail(MFGetAttributeRatio(pMediaTypeOut, MF_MT_PIXEL_ASPECT_RATIO,
      Num, Den));
    Result.PixelAspect := Num / Den;
    CheckFail(pMediaTypeIn.GetUINT32(MF_MT_INTERLACE_MODE,Result.InterlaceMode));
  finally
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
  Result := False;
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

    //Enable the source-reader to make color-conversion, change video size, frame-rate and interlace-mode
    CheckFail(attribs.SetUINT32
      (MF_SOURCE_READER_ENABLE_ADVANCED_VIDEO_PROCESSING, UInt32(true)));
    //The next causes problems for some video formats
//    CheckFail(attribs.SetUINT32
//      (MF_READWRITE_ENABLE_HARDWARE_TRANSFORMS, UInt32(true)));
    // Create a sourcereader for the video file
    CheckFail(MFCreateSourceReaderFromURL(PWideChar(fInputFile), attribs,
      pReader));
    // Configure the sourcereader to decode to RGB32
    CheckFail(MFCreateMediaType(pPartialType));
    CheckFail(pPartialType.SetGUID(MF_MT_MAJOR_TYPE, MFMediaType_Video));
    CheckFail(pPartialType.SetGUID(MF_MT_SUBTYPE, MFVideoFormat_RGB32));
    CheckFail(pPartialType.SetUINT32(MF_MT_INTERLACE_MODE,
      2)); //2=progressive. Does it really de-interlace with this?
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
    pReader.SetStreamSelection(MF_SOURCE_READER_ALL_STREAMS, False);
    // Ensure the stream is selected.
    CheckFail(pReader.SetStreamSelection
      (MF_SOURCE_READER_FIRST_VIDEO_STREAM, true));
    fEndOfFile := False;
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
    //To be on the safe side we check all flags for which
    //further reading would not make any sense
    //and set EndOfFile to true
    if ((Flags and MF_SOURCE_READERF_ENDOFSTREAM) <> 0)
    or ((Flags and MF_SOURCE_READERF_ERROR) <>0)
    or ((Flags and MF_SOURCE_READERF_NEWSTREAM) <>0)
    or ((Flags and MF_SOURCE_READERF_NATIVEMEDIATYPECHANGED) <>0)
    or ((Flags and MF_SOURCE_READERF_ALLEFFECTSREMOVED) <>0)
    then
    begin
      fEndOfFile := true;
      break;
    end;
    if pSampleLoc <> nil then
    begin
      pSample := pSampleLoc;
      CheckFail(pSample.GetSampleTime(Timestamp));
      CheckFail(pSample.GetSampleDuration(Duration));
      //fVideoInfo.Duration can return the wrong value!
      //if Timestamp + Duration >= fVideoInfo.Duration then
      //  fEndOfFile := true;
      break;
      sleep(0);
    end;
    //Can it still happen that we get an infinite loop here?
  Until False;
end;

procedure TVideoTransformer.NextValidSampleToBitmap(const bm: TBitmap;
  out Timestamp, Duration: int64);
var
  Count: integer;
  pSample: IMFSample;
  pBuffer: IMFMediaBuffer;
  Stride: integer;
  pRow, pData: PByte;
const
  ProcName = 'TVideoTransformer.NextValidSampleToBitmap';
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
  if fEndOfFile then
    exit;
  Count := 0;
  GetNextValidSample(pSample, Timestamp, Duration);
  if assigned(pSample) then
  begin
    CheckFail(pSample.ConvertToContiguousBuffer(pBuffer));
    bm.PixelFormat := pf32bit;
    bm.SetSize(fNewWidth, fNewHeight);
    Stride := 4 * fNewWidth;
    pRow := bm.ScanLine[0];
    CheckFail(pBuffer.Lock(pData, nil, nil));
    CheckFail(MFCopyImage(pRow { Destination buffer. } ,
      -Stride { Destination stride. } , pData,
      { First row in source. }
      Stride { Source stride. } , Stride { Image width in bytes. } ,
      fNewHeight { Image height in pixels. } ));
    CheckFail(pBuffer.Unlock);
    sleep(0);
  end;

end;

end.
