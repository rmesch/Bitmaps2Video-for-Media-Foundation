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
  uTransformer;

type

  TCodecID = (ciH264, ciH265);
  TCodecIDArray = array of TCodecID;

const
  CodecNames: array [TCodecID] of string = ('H264 (Mpeg4)', 'H265 (HEVC)');
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
    function ToRectF(Width, Height: integer): TRectF; inline;
  end;

const
  _FullZoom: TZoom = (xCenter: 0.5; yCenter: 0.5; Radius: 0.5);

type
  eAudioFormatException = class(Exception);

type
  // Can be a procedure of a class or free standing
  TBitmapEncoderProgressEvent = reference to procedure(sender: TObject;
    FrameCount: Cardinal; VideoTime: int64);

type

  TBitmapEncoderWMF = class
  private
    { fields needed to set up the MF-Sinkwriter and Sourcereader }
    fVideoWidth, fVideoHeight: integer;
    fFrameRate: single;
    fQuality: integer;
    fAudioBitrate, fAudioSampleRate: integer;
    fSampleDuration: DWord;
    fInputFormat: TGUID;
    fWriteStart: int64;
    fReadAhead: int64;
    pSinkWriter: IMFSinkWriter;
    pSourceReader: IMFSourceReader;
    pMediaTypeOut: IMFMediaType;
    pMediaTypeIn: IMFMediaType;
    pAudioTypeIn, pAudioTypeOut: IMFMediaType;
    pSampleBuffer, pSampleBufferAudio: IMFMediaBuffer;
    fBufferSizeVideo, fBufferSizeAudio: DWord;
    fstreamIndex, fStreamIndexAudio, fSinkStreamIndexAudio: DWord;
    fAudioDuration, fAudioTime: int64;
    fAudioDone: boolean;
    hrCoInit: HResult;
    fFileName, fAudioFileName: string;
    fCodec: TCodecID;
    { /fields needed to set up the MF-Sinkwriter }

    fInitialized, fWriteAudio: boolean;
    fAudioStart: int64;
    fBottomUp: boolean;
    fVideoTime: int64;
    fFrameCount: int64;
    fThreadPool: TResamplingThreadPool;
    fFilter: TFilter;
    fTimingDebug: boolean;
    fBrake: integer;

    fBmRGBA: TBitmap;
    fOnProgress: TBitmapEncoderProgressEvent;
    // Resize/crop bm to video size, then translate to ColorRef-format (RGBA).
    procedure BitmapToRGBA(const bm, bmRGBA: TBitmap; crop: boolean);

    // Move the RGBA-pixels into an MF sample buffer
    procedure bmRGBAToSampleBuffer(const bm: TBitmap);

    // Encode one frame to video stream and the corresponding audio samples to audio stream
    procedure WriteOneFrame(TimeStamp, Duration: int64);
    procedure WriteAudio(TimeStamp: int64; var ReadAhead: int64);
    function MapAudioStream: HResult;
    procedure InitAudio(const AudioFileName: string);
    function GetTranscodeAudioType(SamplesPerSecond, NumChannels, BitRate,
      BlockAlign: UInt32): HResult;
    function ConnectAudioStreams(sourceStreamIndex, SinkStreamIndex
      : DWord): HResult;
  public
    constructor Create;

    /// <summary> Set up the video encoder for writing one output file. </summary>
    /// <param name="Filename">Name of the output file. Must have extension .mp4. .wmv presently not supported. </param>
    /// <param name="Width">Video width in pixels. </param>
    /// <param name="Height">Video height in pixels. </param>
    /// <param name="Quality">Quality of the video encoding on a scale of 1 to 100</param>
    /// <param name="FrameRate">Frame rate in frames per second. Value >= 30 recommended. </param>
    /// <param name="Codec">Video codec enum for encoding. Presently ciH264 or ciH265 </param>
    /// <param name="Resampler">Enum defining the quality of resizing. cfBox, cfBilinear, cfBicubic or cfLanczos</param>
    /// <param name="AudioFileName">Optional audio or video file (.wav, .mp3, .aac, .mp4 etc.), audio stream encoded as AAC. Default ''</param>
    /// <param name="AudioBitRate"> in kb/sec (96, 128, 160, 192 accepted). Default 128 </param>
    /// <param name="AudioSampleRate"> 44100 or 48000. Default 44100 </param>
    /// <param name="AudioStart"> Delay of audio start in ms. Default 0 </param>
    procedure Initialize(const Filename: string;
      Width, Height, Quality: integer; FrameRate: single; Codec: TCodecID;
      Resampler: TFilter = cfBicubic; const AudioFileName: string = '';
      AudioBitRate: integer = 128; AudioSampleRate: integer = 44100;
      AudioStart: int64 = 0);

    /// <summary> Finishes input, frees resources and closes the output file. </summary>
    procedure Finalize;

    /// <summary> Encodes a bitmap as the next video frame. Will be resized to maximal size fitting the video size (black BG), or (crop=true) cropped for maximal borderless size. </summary>
    procedure AddFrame(const bm: TBitmap; crop: boolean);

    /// <summary> Repeatedly encode the last frame for EffectTime ms </summary>
    procedure Freeze(EffectTime: integer);

    /// <summary> Show a bitmap for ShowTime ms </summary>
    procedure AddStillImage(const bm: TBitmap; ShowTime: integer;
      crop: boolean);

    /// <summary> Make a crossfade transition from Sourcebm to Targetbm lasting EffectTime ms </summary>
    procedure CrossFade(const Sourcebm, Targetbm: TBitmap; EffectTime: integer;
      cropSource, cropTarget: boolean);

    /// <summary> Make a crossfade transition from the last encoded frame to Targetbm lasting EffectTime ms </summary>
    procedure CrossFadeTo(const Targetbm: TBitmap; EffectTime: integer;
      cropTarget: boolean);

    /// <summary> Another transition as an example of how you can make more. Transition from Sourcebm to Targetbm </summary>
    procedure ZoomInOutTransition(const Sourcebm, Targetbm: TBitmap;
      ZoomSource, ZoomTarget: TZoom; EffectTime: integer;
      cropSource, cropTarget: boolean);

    /// <summary> Zoom-in-out transition from the last encoded frame to Targetbm lasting EffectTime ms </summary>
    procedure ZoomInOutTransitionTo(const Targetbm: TBitmap;
      ZoomSource, ZoomTarget: TZoom; EffectTime: integer; cropTarget: boolean);

    /// <summary> Insert a video clip (video stream only) into the stream of encoded bitmaps. </summary>
    /// <param name="VideoFile">Name of the file containing the video clip. Anything that Windows can decode should be supported. </param>
    /// <param name="TransitionTime">Optionally does a crossfade transition from the last encoded frame to the first video frame lasting TransitionTime ms. Default 0 </param>
    procedure AddVideo(const VideoFile: string; TransitionTime: integer = 0);

    destructor Destroy; override;

    // Videotime so far in ms
    property VideoTime: int64 read fVideoTime;

    // Count of frames added so far
    property FrameCount: int64 read fFrameCount;

    // The filename of the output video as entered in Initialize
    property Filename: string read fFileName;

    // If true, timestamp in sec will be displayed on the frames. A rough check for a uniform timing of frames.
    // Timing could be very irregular at the beginning of development with high frame rates and large video sizes.
    // I had to artificially slow down the generation of some frames to (hopefully) fix it,
    // and read ahead in the audio file.
    // See Freeze and WriteAudio.
    property TimingDebug: boolean read fTimingDebug write fTimingDebug;

    property OnProgress: TBitmapEncoderProgressEvent read fOnProgress
      write fOnProgress;
  end;

function GetSupportedCodecs(const FileExt: string): TCodecIDArray;

/// <summary>Use TBitmapEncoderWMF to re-encode a video to H265 or H264, changing video size and/or frame rate </summary>
procedure TranscodeVideoFile(const InputFilename, OutputFilename: string;
  Codec: TCodecID; Quality: integer; NewWidth, NewHeight: integer;
  NewFrameRate: single;OnProgress:TBitmapEncoderProgressEvent=nil);

implementation

procedure TranscodeVideoFile(const InputFilename, OutputFilename: string;
  Codec: TCodecID; Quality: integer; NewWidth, NewHeight: integer;
  NewFrameRate: single;OnProgress:TBitmapEncoderProgressEvent=nil);
var
  bme: TBitmapEncoderWMF;
begin
  bme := TBitmapEncoderWMF.Create;
  try
    try
      bme.Initialize(OutputFilename, NewWidth, NewHeight, Quality, NewFrameRate,
        Codec, cfBilinear, InputFilename);
      bme.OnProgress:=OnProgress;
    except
      on eAudioFormatException do
      begin
        // try again with no audio
        bme.Finalize;
        bme.Initialize(OutputFilename, NewWidth, NewHeight, Quality,
          NewFrameRate, Codec, cfBilinear, '');
        bme.OnProgress:=OnProgress;
      end
      else
        raise;
    end;
    bme.AddVideo(InputFilename, 0);
  finally
    bme.Free;
  end;
end;

const
  // .wmv requires bottom-up order of input to the sample buffer
  // ... or is it the other way round? Anyway, the code works.
  BottomUp: array [TCodecID] of boolean = (false, false);

  // List of codecs supported for encoding a file with the given extension
function GetSupportedCodecs(const FileExt: string): TCodecIDArray;
begin
  SetLength(result, 0);
  if FileExt = '.mp4' then
  begin
    SetLength(result, 2);
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
function GetEncodingFormat(Id: TCodecID): TGUID;
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

// record to divide up the work of a loop into threads.
type
  TParallelizer = record
    // array of loopbounds for each thread
    imin, imax: TIntArray;
    // InputCount: length of the loop
    procedure Init(ThreadCount, InputCount: integer);
  end;

procedure TParallelizer.Init(ThreadCount, InputCount: integer);
var
  chunk, Index: integer;
begin
  SetLength(imin, ThreadCount);
  SetLength(imax, ThreadCount);
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

function IsCodecSupported(const FileExt: string; Codec: TCodecID): boolean;
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

function TBitmapEncoderWMF.GetTranscodeAudioType(SamplesPerSecond, NumChannels,
  BitRate, BlockAlign: UInt32): HResult;
var
  hr: HResult;
begin
  hr := MFCreateMediaType(pAudioTypeOut);

  if succeeded(hr) then
    hr := pAudioTypeOut.SetGUID(MF_MT_MAJOR_TYPE, MFMediaType_Audio);
  if succeeded(hr) then
    // set the audio subtype
    // if fCodec = ciWMV then
    // hr := pAudioTypeOut.SetGUID(MF_MT_SUBTYPE, MFAudioFormat_WMAudioV9)
    // else
    hr := pAudioTypeOut.SetGUID(MF_MT_SUBTYPE, MFAudioFormat_AAC);
  if succeeded(hr) then
    // set the number of audio bits per sample. This must be 16 according to docs.
    hr := pAudioTypeOut.SetUINT32(MF_MT_AUDIO_BITS_PER_SAMPLE, 16);
  if succeeded(hr) then
    // set the number of audio samples per second
    hr := pAudioTypeOut.SetUINT32(MF_MT_AUDIO_SAMPLES_PER_SECOND,
      SamplesPerSecond);
  if succeeded(hr) then
    // set the number of audio channels. Must be the same as in input-format.
    hr := pAudioTypeOut.SetUINT32(MF_MT_AUDIO_NUM_CHANNELS, NumChannels);
  if succeeded(hr) then
    // set the Bps of the audio stream
    hr := pAudioTypeOut.SetUINT32(MF_MT_AUDIO_AVG_BYTES_PER_SECOND, BitRate);
  if succeeded(hr) then
    // set the block alignment of the samples
    hr := pAudioTypeOut.SetUINT32(MF_MT_AUDIO_BLOCK_ALIGNMENT, BlockAlign);
  result := hr;
end;

type
  TGUIDArray = array of TGUID;

function IntermediateVideoFormats: TGUIDArray;
begin
  SetLength(result, 4);
  result[0] := MFVideoFormat_NV12;
  result[1] := MFVideoFormat_YV12;
  result[2] := MFVideoFormat_YUY2;
  result[3] := MFVideoFormat_RGB32;
end;

function IntermediateAudioFormats: TGUIDArray;
begin
  SetLength(result, 2);
  result[1] := MFAudioFormat_Float;
  result[0] := MFAudioFormat_PCM;
end;

const
  nIntermediateVideoFormats = 4;
  nIntermediateAudioFormats = 2;

function TBitmapEncoderWMF.ConnectAudioStreams(sourceStreamIndex: DWord;
  SinkStreamIndex: DWord): HResult;
var
  hr: HResult;
  pPartialMediaType: IMFMediaType;
  fConfigured: boolean;
  intermediateFormats: TGUIDArray;
  nFormats: integer;
  x: integer;
begin
  fConfigured := false;
  nFormats := 0;
  // create a media type container object that will be used to match stream input
  // and output media types
  hr := MFCreateMediaType(pPartialMediaType);

  If succeeded(hr) then
    // set the major type of the partial match media type container
    hr := pPartialMediaType.SetGUID(MF_MT_MAJOR_TYPE, MFMediaType_Audio);

  If succeeded(hr) then
    // Get the appropriate list of intermediate formats - formats that every decoder and
    // encoder of that type should agree on.  Essentially these are the uncompressed
    // formats that correspond to decoded frames for video, and uncompressed audio
    // formats
    intermediateFormats := IntermediateAudioFormats;
  If succeeded(hr) then
    nFormats := nIntermediateAudioFormats;

  // loop through every intermediate format that you have for this major type, and
  // try to find one on which both the source stream and sink stream can agree on
  If succeeded(hr) then
    for x := 0 to nFormats - 1 do
    begin
      // set the format of the partial media type
      hr := pPartialMediaType.SetGUID(MF_MT_SUBTYPE, intermediateFormats[x]);
      if Failed(hr) then
        Break;

      // set the partial media type on the source stream
      hr := pSourceReader.SetCurrentMediaType(sourceStreamIndex, // stream index
        0, // reserved - always NULL
        pPartialMediaType); // media type to try to set

      // if the source stream (i.e. the decoder) is not happy with this media type -
      // if it cannot decode the data into this media type, restart the loop in order
      // to try the next format on the list
      if Failed(hr) then
      begin
        hr := S_OK;
        continue;
      end;
      if succeeded(hr) then
        pAudioTypeIn := nil;

      if succeeded(hr) then
        // if you got here, the source stream is happy with the partial media type you set
        // - extract the full media type for this stream (with all internal fields
        // filled in)
        hr := pSourceReader.GetCurrentMediaType(sourceStreamIndex,
          pAudioTypeIn);

      if succeeded(hr) then
        // Now try to match the full media type to the corresponding sink stream
        hr := pSinkWriter.SetInputMediaType(SinkStreamIndex, // stream index
          pAudioTypeIn, // media type to match
          nil); // configuration attributes for the encoder

      // if the sink stream cannot accept this media type - i.e. if no encoder was
      // found that would accept this media type - restart the loop and try the next
      // format on the list
      if Failed(hr) then
      begin
        hr := S_OK;
        continue;
      end;

      // you found a media type that both the source and sink could agree on - no need
      // to try any other formats
      fConfigured := true;
      Break;
    end;

  // if you didn't match any formats raise an exception
  if (not fConfigured) then
  begin
    raise eAudioFormatException.Create
      ('Audio format of input file not supperted');
  end;
  result := hr;
end;

//
// Map a source reader output audio-stream to an input stream of the sink writer, deciding
// on the target format.  Audio stream formats are modified to AAC
// Because the procedure fails for .wmv, we don't support this codec at the moment.
function TBitmapEncoderWMF.MapAudioStream: HResult;
var
  hr: HResult;
  IsStreamSelected: boolean;
  StreamMajorType: TGUID;
  pStreamMediaType: IMFMediaType;
  NumChannels, BlockAlign: UInt32;
begin
  hr := S_OK;
  fStreamIndexAudio := 0;
  fSinkStreamIndexAudio := 0;
  while (succeeded(hr)) do
  begin
    // check whether you have a stream with the right index - if you don't, the
    // IMFSourceReader::GetStreamSelection() function will fail, and you will drop
    // out of the while loop
    hr := pSourceReader.GetStreamSelection(fStreamIndexAudio, IsStreamSelected);
    if Failed(hr) then
    begin
      // No more streams found, break with error
      // hr := S_OK;
      Break;
    end;

    // get the source media type of the stream
    hr := pSourceReader.GetNativeMediaType(fStreamIndexAudio,
      // index of the stream you are interested in
      0, // index of the media type exposed by the stream decoder
      pStreamMediaType); // media type
    If Failed(hr) then
      Break;

    // extract the major type of the source stream from the media type
    hr := pStreamMediaType.GetMajorType(StreamMajorType);
    If Failed(hr) then
      Break;

    // select a stream, indicating that the source should send out its data instead
    // of dropping all of the samples
    hr := pSourceReader.SetStreamSelection(fStreamIndexAudio, true);
    if Failed(hr) then
      Break;

    // if this is an audio stream, transcode it and negotiate the media type
    // between the source reader stream and the corresponding sink writer stream.
    if (StreamMajorType = MFMediaType_Audio) then
    begin

      hr := pStreamMediaType.GetUInt32(MF_MT_AUDIO_NUM_CHANNELS, NumChannels);
      if succeeded(hr) then
        hr := pStreamMediaType.GetUInt32(MF_MT_AUDIO_BLOCK_ALIGNMENT,
          BlockAlign);

      // get the target media type pAudioTypeOut - the media type into which you will transcode
      // the data of the current source stream.
      if succeeded(hr) then
        hr := GetTranscodeAudioType(fAudioSampleRate, NumChannels,
          fAudioBitrate * 125, BlockAlign);
      if Failed(hr) then
        Break;

      // add the stream to the sink writer - i.e. tell the sink writer that a
      // stream with the specified index will have the target media type
      hr := pSinkWriter.AddStream(pAudioTypeOut, fSinkStreamIndexAudio);
      if Failed(hr) then
        Break;
      // hook up the source and sink streams - i.e. get them to agree on an
      // intermediate media type pAudioTypeIn that will be used to pass data between source
      // and sink
      hr := ConnectAudioStreams(fStreamIndexAudio, fSinkStreamIndexAudio);
      // we either could not connect the streams->Break with error
      // or the operation as a total was successful -> Break with S_OK
      Break;
    end
    // If the media type is not audio try the next stream
    else
    begin
      // investigate the next stream
      inc(fStreamIndexAudio);
      hr := S_OK;
      continue;
    end;
  end;

  result := hr;
end;

procedure TBitmapEncoderWMF.Initialize(const Filename: string;
  Width, Height, Quality: integer; FrameRate: single; Codec: TCodecID;
  Resampler: TFilter = cfBicubic; const AudioFileName: string = '';
  AudioBitRate: integer = 128; AudioSampleRate: integer = 44100;
  AudioStart: int64 = 0);
var
  attribs: IMFAttributes;
  stride: integer;
  ext: string;
  Count: integer;
const
  ProcName = 'TBitmapEncoderWMF.Initialize';
  procedure CheckFail(hr: HResult);
  begin
    inc(Count);
    if not succeeded(hr) then
    begin
      // Only call CoUninitialize if the call to Initialize has been successful
      if succeeded(hrCoInit) then
        CoUninitialize;
      raise Exception.Create('Fail in call nr. ' + IntToStr(Count) + ' of ' +
        ProcName + ' with result ' + IntToHex(hr));
    end;
  end;

begin
  Count := 0;
  if fInitialized then
    raise Exception.Create
      ('The bitmap-encoder must be finalized before re-initializing');
  fInitialized := false;
  fFileName := Filename;
  ext := ExtractFileExt(fFileName);
  if not IsCodecSupported(ext, Codec) then
    raise Exception.Create('Codec ' + CodecShortNames[Codec] +
      ' not supported for file type ' + ext);

  fVideoWidth := Width;
  fVideoHeight := Height;
  fBrake := max(round(2880 / fVideoHeight), 1);
  fQuality := Quality;
  fAudioBitrate := AudioBitRate;
  fAudioSampleRate := AudioSampleRate;
  fFrameRate := FrameRate;
  fFilter := Resampler;
  fCodec := Codec;
  fAudioFileName := AudioFileName;
  // Calculate the average time/frame
  // Time is measured in units of 100 nanoseconds. 1 sec = 1000 * 10000 time-units
  fSampleDuration := round(1000 * 10000 / fFrameRate);
  fAudioStart := AudioStart * 10000;
  fInputFormat := MFVideoFormat_RGB32;
  fBottomUp := BottomUp[Codec];

  fWriteStart := 0;
  fFrameCount := 0;

  stride := 4 * fVideoWidth;

  hrCoInit := CoInitializeEx(nil, COINIT_APARTMENTTHREADED);

  CheckFail(hrCoInit);

  CheckFail(MFStartup(MF_VERSION));

  CheckFail(MFCreateAttributes(attribs, 4));
  // this enables hardware encoding, if the GPU supports it
  CheckFail(attribs.SetUINT32(MF_READWRITE_ENABLE_HARDWARE_TRANSFORMS,
    UInt32(true)));
  // CheckFail(attribs.SetUINT32(MF_LOW_LATENCY,
  // UInt32(true)));

  // Setting this to true makes the timings more uneven
  // CheckFail(attribs.SetUINT32(MF_SINK_WRITER_DISABLE_THROTTLING,
  // UINT32(true)));

  // this seems to improve the quality of encodings:
  // this enables the encoder to use quality based settings
  CheckFail(attribs.SetUINT32(CODECAPI_AVEncCommonRateControlMode, 3));
  CheckFail(attribs.SetUINT32(CODECAPI_AVEncCommonQuality, fQuality));
  // sacrifice speed for details
  CheckFail(attribs.SetUINT32(CODECAPI_AVEncCommonQualityVsSpeed, 80));

  // Create a sinkwriter to write the output file
  CheckFail(MFCreateSinkWriterFromURL(PWideChar(Filename), nil, attribs,
    pSinkWriter));

  // Set the output media type.
  CheckFail(MFCreateMediaType(pMediaTypeOut));
  CheckFail(pMediaTypeOut.SetGUID(MF_MT_MAJOR_TYPE, MFMediaType_Video));
  CheckFail(pMediaTypeOut.SetGUID(MF_MT_SUBTYPE, GetEncodingFormat(Codec)));

  // Has no effect on the bitrate with quality based encoding, it could have an effect
  // on the size of the leaky bucket buffer. So we leave it here.
  CheckFail(pMediaTypeOut.SetUINT32(MF_MT_AVG_BITRATE,
    fQuality * 60 * fVideoHeight));

  CheckFail(pMediaTypeOut.SetUINT32(MF_MT_INTERLACE_MODE,
    MFVideoInterlace_Progressive));
  CheckFail(MFSetAttributeSize(pMediaTypeOut, MF_MT_FRAME_SIZE, fVideoWidth,
    fVideoHeight));
  CheckFail(MFSetAttributeRatio(pMediaTypeOut, MF_MT_FRAME_RATE,
    round(fFrameRate * 100), 100));

  // It doesn't seem to do the following
  // CheckFail(pMediaTypeOut.SetUINT32(CODECAPI_AVEncMPVGOPSize,
  // round(0.5 * fFrameRate)));
  CheckFail(MFSetAttributeRatio(pMediaTypeOut, MF_MT_PIXEL_ASPECT_RATIO, 1, 1));
  CheckFail(pSinkWriter.AddStream(pMediaTypeOut, fstreamIndex));

  // Set the input media type.
  CheckFail(MFCreateMediaType(pMediaTypeIn));
  CheckFail(pMediaTypeIn.SetGUID(MF_MT_MAJOR_TYPE, MFMediaType_Video));
  CheckFail(pMediaTypeIn.SetGUID(MF_MT_SUBTYPE, MFVideoFormat_RGB32));
  CheckFail(pMediaTypeIn.SetUINT32(MF_MT_INTERLACE_MODE,
    MFVideoInterlace_Progressive));
  CheckFail(MFSetAttributeSize(pMediaTypeIn, MF_MT_FRAME_SIZE, fVideoWidth,
    fVideoHeight));
  CheckFail(MFSetAttributeRatio(pMediaTypeIn, MF_MT_FRAME_RATE,
    round(fFrameRate * 100), 100));
  CheckFail(MFSetAttributeRatio(pMediaTypeIn, MF_MT_PIXEL_ASPECT_RATIO, 1, 1));
  CheckFail(pSinkWriter.SetInputMediaType(fstreamIndex, pMediaTypeIn, nil));

  if (AudioFileName <> '') then
  begin
    InitAudio(AudioFileName);
  end;

  fBmRGBA.PixelFormat := pf32bit;
  fBmRGBA.SetSize(fVideoWidth, fVideoHeight);

  // Tell the sink writer to start accepting data.
  CheckFail(pSinkWriter.BeginWriting());
  fBufferSizeVideo := stride * fVideoHeight;
  CheckFail(MFCreateMemoryBuffer(fBufferSizeVideo, pSampleBuffer));
  fInitialized := true;
end;

procedure TBitmapEncoderWMF.InitAudio(const AudioFileName: string);
var
  _var: TPropVariant;
  Count: integer;
  pData: PByte;
  BytesPerSecond, BlockAlign: UInt32;
const
  ProcName = 'TBitmapEncoderWMF.InitAudio';
  procedure CheckFail(hr: HResult);
  begin
    inc(Count);
    if not succeeded(hr) then
    begin
      if succeeded(hrCoInit) then
        CoUninitialize;
      raise Exception.Create('Fail in call nr. ' + IntToStr(Count) + ' of ' +
        ProcName + ' with result ' + IntToHex(hr));
    end;
  end;

begin
  Count := 0;
  fWriteAudio := true;
  fAudioDone := false;
  fReadAhead := 100 * 10000; // 0.1 sec. Will be changed in WriteAudio

  // Create a source-reader to read the audio file
  CheckFail(MFCreateSourceReaderFromURL(PWideChar(AudioFileName), nil,
    pSourceReader));
  // Find the first audio-stream and link it to the sink-writer
  CheckFail(MapAudioStream);
  // Find the audio-duration
  PropVariantInit(_var);
  try
    CheckFail(pSourceReader.GetPresentationAttribute
      (DWord(MF_SOURCE_READER_MEDIASOURCE), MF_PD_DURATION, _var));
    fAudioDuration := _var.hVal.QuadPart;
  finally
    PropVariantClear(_var);
  end;
  fAudioTime := 0;

  // Set up an audio buffer holding silence which we can add to the audio stream as necessary
  CheckFail(pAudioTypeIn.GetUInt32(MF_MT_AUDIO_AVG_BYTES_PER_SECOND,
    BytesPerSecond));
  CheckFail(pAudioTypeIn.GetUInt32(MF_MT_AUDIO_BLOCK_ALIGNMENT, BlockAlign));
  // Create an audio-buffer that holds silence
  // the buffer should hold audio for the  video frame time.
  fBufferSizeAudio := System.Math.Ceil(BytesPerSecond / 1000 *
    fSampleDuration / 10000);
  fBufferSizeAudio := BlockAlign * (fBufferSizeAudio div BlockAlign);
  CheckFail(MFCreateMemoryBuffer(fBufferSizeAudio, pSampleBufferAudio));
  CheckFail(pSampleBufferAudio.SetCurrentLength(fBufferSizeAudio));
  CheckFail(pSampleBufferAudio.Lock(pData, nil, nil));
  FillChar(pData^, fBufferSizeAudio, 0);
  // prevent crack at beginnning of silence
  PByteArray(pData)[2] := $06;
  CheckFail(pSampleBufferAudio.Unlock);
  CheckFail(pSampleBufferAudio.SetCurrentLength(fBufferSizeAudio));
end;

procedure TBitmapEncoderWMF.Finalize;
begin

  if Assigned(pSinkWriter) then
    pSinkWriter.Finalize();
  pSinkWriter := nil;

  // not necessary I guess
  if Assigned(pSampleBuffer) then
    SafeRelease(pSampleBuffer);
  pSampleBuffer := nil;
  MFShutdown();
  if succeeded(hrCoInit) then
    CoUninitialize;
  fInitialized := false;
end;

procedure TBitmapEncoderWMF.AddVideo(const VideoFile: string;
  TransitionTime: integer = 0);
var
  VT: TVideoTransformer;
  bm: TBitmap;
  TimeStamp, Duration, VideoStart: int64;
begin
  VT := TVideoTransformer.Create(VideoFile, fVideoHeight, fFrameRate);
  try
    bm := TBitmap.Create;
    try
      VT.NextValidSampleToBitmap(bm, TimeStamp, Duration);
      if TransitionTime > 0 then
        CrossFadeTo(bm, TransitionTime, false);
      VideoStart := fWriteStart;
      while not VT.EndOfFile do
      begin
        BitmapToRGBA(bm, fBmRGBA, false);
        bmRGBAToSampleBuffer(fBmRGBA);
        WriteOneFrame(VideoStart + TimeStamp, Duration);
        VT.NextValidSampleToBitmap(bm, TimeStamp, Duration);
      end;
    finally
      bm.Free;
    end;
  finally
    VT.Free;
  end;
end;

procedure TBitmapEncoderWMF.AddFrame(const bm: TBitmap; crop: boolean);
begin
  BitmapToRGBA(bm, fBmRGBA, crop);
  bmRGBAToSampleBuffer(fBmRGBA);
  WriteOneFrame(fWriteStart, fSampleDuration);
end;

procedure TBitmapEncoderWMF.AddStillImage(const bm: TBitmap; ShowTime: integer;
  crop: boolean);
var
  bmBuf: TBitmap;

begin
  var
    StartTime: int64 := fWriteStart;
  BitmapToRGBA(bm, fBmRGBA, crop);
  if fTimingDebug then
  begin
    bmBuf := TBitmap.Create;
    try
      while fWriteStart < StartTime + ShowTime * 10000 do
      begin
        bmBuf.Assign(fBmRGBA);
        bmRGBAToSampleBuffer(bmBuf);
        WriteOneFrame(fWriteStart, fSampleDuration);
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

// Procedure to translate a buffer of TRGBQuad(BGRA) into TColorRef(RGBA=Cardinal).
// Result is the portion of the work to be done by thread number Index
{
  function GetClrRefProcedure(const TCR: TParallelizer; Index: integer;
  const pSStart: pRGBQuad; const pTStart: pCardinal): TProc;
  begin
  result := procedure
  var
  i1, i2, i: integer;
  pPix: pRGBQuad;
  pClrRef: pCardinal;
  begin
  i1 := TCR.imin[Index];
  i2 := TCR.imax[Index];
  pPix := pSStart;
  pClrRef := pTStart;
  inc(pPix, i1);
  inc(pClrRef, i1);
  for i := i1 to i2 do
  begin
  CopyRgbQuadToClrRef(pPix^, pClrRef^);
  inc(pPix);
  inc(pClrRef);
  end;
  end;
  end;
}

// Resizes/crops bm to video size.
// We use a bitmap for the RGBA-output rather than a buffer, because we want to do
// bitmap operations like zooming on it.
procedure TBitmapEncoderWMF.BitmapToRGBA(const bm, bmRGBA: TBitmap;
  crop: boolean);
var
  bmBack: TBitmap;
  w, h, wSource, hSource: integer;
  SourceRect: TRectF;
begin
  if (bm.Width = 0) or (bm.Height = 0) then
    raise Exception.Create('Bitmap has size 0');
  bm.PixelFormat := pf32bit;
  if (bm.Width <> fVideoWidth) or (bm.Height <> fVideoHeight) then
  begin
    if bm.Width / bm.Height > fVideoWidth / fVideoHeight then
    begin
      if crop then
      begin
        h := fVideoHeight;
        w := fVideoWidth;
        hSource := bm.Height;
        wSource := round(hSource * fVideoWidth / fVideoHeight);
        SourceRect := RectF((bm.Width - wSource) div 2, 0,
          (bm.Width + wSource) div 2, bm.Height);
      end
      else
      begin
        w := fVideoWidth;
        h := round(fVideoWidth * bm.Height / bm.Width);
        SourceRect := RectF(0, 0, bm.Width, bm.Height);
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
        SourceRect := RectF(0, (bm.Height - hSource) div 2, bm.Width,
          (bm.Height + hSource) div 2);
      end
      else
      begin
        h := fVideoHeight;
        w := round(fVideoHeight * bm.Width / bm.Height);
        SourceRect := FloatRect(0, 0, bm.Width, bm.Height);
      end;
    end;
    bmBack := TBitmap.Create;
    try
      uScaleWMF.ZoomResampleParallelThreads(w, h, bm, bmBack, SourceRect,
        fFilter, 0, amIgnore, @fThreadPool);
      if (w <> fVideoWidth) or (h <> fVideoHeight) then
      begin
        bmRGBA.PixelFormat := pf32bit;
        bmRGBA.SetSize(fVideoWidth, fVideoHeight);
        bmRGBA.Canvas.Lock;
        BitBlt(bmRGBA.Canvas.Handle, 0, 0, fVideoWidth, fVideoHeight, 0, 0, 0,
          BLACKNESS);
        BitBlt(bmRGBA.Canvas.Handle, (fVideoWidth - w) div 2,
          (fVideoHeight - h) div 2, w, h, bmBack.Canvas.Handle, 0, 0, SRCCopy);
        bmRGBA.Canvas.Unlock;
      end
      else
        bmRGBA.Assign(bmBack);
    finally
      bmBack.Free;
    end;
  end
  else
    bmRGBA.Assign(bm);
  // The following conversion is not necessary
  { pPix := bmT.ScanLine[fVideoHeight - 1];
    bmRGBA.PixelFormat := pf32bit;
    bmRGBA.SetSize(fVideoWidth, fVideoHeight);
    pBuf := pCardinal(bmRGBA.ScanLine[fVideoHeight - 1]);
    // Transform BGRA to ColorRef = RGBA
    TCR.Init(fThreadPool.ThreadCount, fVideoHeight * fVideoWidth);
    for Index := 0 to fThreadPool.ThreadCount - 1 do
    fThreadPool.ResamplingThreads[Index].RunAnonProc
    (GetClrRefProcedure(TCR, Index, pPix, pBuf));
    for Index := 0 to fThreadPool.ThreadCount - 1 do
    fThreadPool.ResamplingThreads[Index].Done.WaitFor(INFINITE); }

end;

procedure TBitmapEncoderWMF.bmRGBAToSampleBuffer(const bm: TBitmap);
var
  hr: HResult;
  pRow: PByte;
  StrideSource, StrideTarget: integer;
  pData: PByte;
begin
  if fTimingDebug then
  begin
    var
      time: string := IntToStr(fWriteStart div 10000000);
    bm.Canvas.Lock;
    bm.Canvas.Brush.Style := bsClear;
    bm.Canvas.Font.Color := clFuchsia;
    bm.Canvas.Font.Size := 32;
    bm.Canvas.TextOut(10, 10, time);
    bm.Canvas.Unlock;
  end;
  if not fBottomUp then
  begin
    StrideSource := 4 * fVideoWidth;
    pRow := bm.ScanLine[fVideoHeight - 1];
  end
  else
  begin
    StrideSource := -4 * fVideoWidth;
    pRow := bm.ScanLine[0];
  end;
  StrideTarget := 4 * fVideoWidth;
  hr := pSampleBuffer.Lock(pData, nil, nil);
  if succeeded(hr) then
  begin
    hr := MFCopyImage(pData { Destination buffer. } ,
      StrideTarget { Destination stride. } , pRow,
      { First row in source image. }
      StrideSource { Source stride. } , StrideTarget { Image width in bytes. } ,
      fVideoHeight { Image height in pixels. } );

    if Assigned(pSampleBuffer) then
      pSampleBuffer.Unlock();

    if succeeded(hr) then
      // Set the data length of the buffer.
      hr := pSampleBuffer.SetCurrentLength(fBufferSizeVideo);
  end;
  if not succeeded(hr) then
    raise Exception.Create('TBitmapEncoderWMF.bmRGBAToSampleBuffer failed');
end;

constructor TBitmapEncoderWMF.Create;
begin
  // leave enough processors for the encoding threads
  fThreadPool.Initialize(min(16, TThread.ProcessorCount div 2), tpNormal);
  fBmRGBA := TBitmap.Create;
end;

{$IFOPT O- }
{$DEFINE O_MINUS }
{$O+ }
{$ENDIF }
{$IFOPT Q+}
{$DEFINE Q_PLUS}
{$Q-}
{$ENDIF}

function GetCrossFadeProc(const CF: TParallelizer; Index: integer; alpha: byte;
  pOldStart, pNewStart, pTweenStart: PByte): TProc;
begin
  result := procedure
    var
      pold, pnew, pf: PByte;
      i, i1, i2: integer;
    begin
      i1 := CF.imin[Index];
      i2 := CF.imax[Index];
      pold := pOldStart;
      pnew := pNewStart;
      pf := pTweenStart;
      inc(pold, i1);
      inc(pnew, i1);
      inc(pf, i1);
      for i := i1 to i2 do
      begin
        pf^ := (alpha * (pnew^ - pold^)) div 256 + pold^;
        inc(pf);
        inc(pnew);
        inc(pold);
      end;
    end;
end;
{$IFDEF O_MINUS}
{$O-}
{$UNDEF O_MINUS}
{$ENDIF}
{$IFDEF Q_PLUS}
{$Q+}
{$UNDEF Q_PLUS}
{$ENDIF}

function StartSlowEndSlow(t: double): double; inline;
begin
  if t < 0.5 then
    result := 2 * sqr(t)
  else
    result := 1 - 2 * sqr(1 - t);
end;

function StartFastEndSlow(t: double): double; inline;
begin
  result := 1 - sqr(1 - t);
end;

procedure TBitmapEncoderWMF.CrossFade(const Sourcebm, Targetbm: TBitmap;
  EffectTime: integer; cropSource, cropTarget: boolean);
var
  DurMs: integer;
begin
  AddFrame(Sourcebm, cropSource);
  DurMs := round(1 / 10000 * fSampleDuration);
  CrossFadeTo(Targetbm, EffectTime - DurMs, cropTarget);
end;

procedure TBitmapEncoderWMF.CrossFadeTo(const Targetbm: TBitmap;
  EffectTime: integer; cropTarget: boolean);
var
  StartTime, EndTime: int64;
  alpha: byte;
  fact: double;
  CF: TParallelizer;
  Index: integer;
  bmOld, bmNew, bmTween: TBitmap;
  pOldStart, pNewStart, pTweenStart: PByte;
begin
  bmOld := TBitmap.Create;
  bmNew := TBitmap.Create;
  bmTween := TBitmap.Create;
  try
    bmOld.Assign(fBmRGBA);
    BitmapToRGBA(Targetbm, bmNew, cropTarget);
    bmTween.PixelFormat := pf32bit;
    bmTween.SetSize(fVideoWidth, fVideoHeight);
    pOldStart := bmOld.ScanLine[fVideoHeight - 1];
    pNewStart := bmNew.ScanLine[fVideoHeight - 1];
    pTweenStart := bmTween.ScanLine[fVideoHeight - 1];
    CF.Init(fThreadPool.ThreadCount, 4 * fVideoWidth * fVideoHeight);
    StartTime := fWriteStart;
    EndTime := StartTime + EffectTime * 10000;
    fact := 255 / 10000 / EffectTime;
    while EndTime - fWriteStart > 0 do
    begin
      alpha := round((fact * (fWriteStart - StartTime)));
      for Index := 0 to fThreadPool.ThreadCount - 1 do
        fThreadPool.ResamplingThreads[Index].RunAnonProc
          (GetCrossFadeProc(CF, Index, alpha, pOldStart, pNewStart,
          pTweenStart));
      for Index := 0 to fThreadPool.ThreadCount - 1 do
        fThreadPool.ResamplingThreads[Index].Done.WaitFor(INFINITE);
      bmRGBAToSampleBuffer(bmTween);
      WriteOneFrame(fWriteStart, fSampleDuration);
    end;
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

procedure TBitmapEncoderWMF.WriteAudio(TimeStamp: int64; var ReadAhead: int64);
var
  ActualStreamIndex: DWord;
  flags: DWord;
  AudioTimestamp, AudioSampleDuration: int64;
  pAudioSample: IMFSample;
  Count: integer;
const
  ProcName = 'TBitmapEncoderWMF.WriteAudio';
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
  // If audio is present write audio samples up to the fWriteStart+ReadAhead
  while (fAudioTime + fAudioStart < TimeStamp + ReadAhead) and
    (not fAudioDone) do
  begin
    // pull a sample out of the audio source reader
    CheckFail(pSourceReader.ReadSample(fStreamIndexAudio,
      // get a sample from audio stream
      0, // no source reader controller flags
      @ActualStreamIndex, // get actual index of the stream
      @flags, // get flags for this sample
      @AudioTimestamp, // get the timestamp for this sample
      @pAudioSample)); // get the actual sample

    if ((flags and MF_SOURCE_READERF_STREAMTICK) <> 0) then
    begin
      pSinkWriter.SendStreamTick(fSinkStreamIndexAudio,
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
      // push the sample to the sink writer
      CheckFail(pAudioSample.GetSampleDuration(AudioSampleDuration));
      CheckFail(pAudioSample.SetSampleTime(AudioTimestamp + fAudioStart));
      CheckFail(pSinkWriter.WriteSample(fSinkStreamIndexAudio, pAudioSample));
      fAudioTime := AudioTimestamp + AudioSampleDuration;
      ReadAhead := 3 * AudioSampleDuration;
      sleep(0);
    end;
    // else
    // fAudioDone := true;
    // fAudioDuration can be false!
    // if fAudioTime >= fAudioDuration then
    // fAudioDone := true;
    if fAudioDone then
      CheckFail(pSinkWriter.NotifyEndOfSegment(fSinkStreamIndexAudio));
  end;
end;

procedure TBitmapEncoderWMF.WriteOneFrame(TimeStamp, Duration: int64);
var
  pSample: IMFSample;
  Count: integer;
  pSampleAudio: IMFSample;
  i, imax: DWord;
const
  ProcName = 'TBitmapEncoderWMF.WriteOneFrame';
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
  Count := 0;
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
        CheckFail(MFCreateSample(pSampleAudio));
        CheckFail(pSampleAudio.AddBuffer(pSampleBufferAudio));
        // write silence to the sinkwriter for 2 video frame durations ahead.
        CheckFail(pSampleAudio.SetSampleTime(TimeStamp + (2 - imax + i) *
          Duration));
        CheckFail(pSampleAudio.SetSampleDuration(Duration));
        CheckFail(pSinkWriter.WriteSample(fSinkStreamIndexAudio, pSampleAudio));
        CheckFail(pSampleBufferAudio.SetCurrentLength(fBufferSizeAudio));
      end;
    end
    else if (TimeStamp >= fAudioTime + fAudioStart - fReadAhead) and
      (not fAudioDone) then
      WriteAudio(TimeStamp, fReadAhead);
  end;

  // Create a media sample and add the buffer to the sample.
  CheckFail(MFCreateSample(pSample));

  CheckFail(pSample.AddBuffer(pSampleBuffer));

  CheckFail(pSample.SetSampleTime(TimeStamp));

  CheckFail(pSample.SetSampleDuration(Duration));
  // Send the sample to the Sink Writer.
  CheckFail(pSinkWriter.WriteSample(fstreamIndex, pSample));

  inc(fFrameCount);
  // Timestamp for the next frame
  fWriteStart := TimeStamp + Duration;
  fVideoTime := fWriteStart div 10000;
  // give the encoder-threads a chance to do their work
  sleep(0);
  if Assigned(fOnProgress) then
    if fFrameCount mod 30 = 1 then
      fOnProgress(self, fFrameCount, fVideoTime);
end;

function Interpolate(Z1, Z2: TZoom; t: double): TZoom; inline;
begin
  t := StartSlowEndSlow(t);
  result.xCenter := t * (Z2.xCenter - Z1.xCenter) + Z1.xCenter;
  result.yCenter := t * (Z2.yCenter - Z1.yCenter) + Z1.yCenter;
  result.Radius := t * (Z2.Radius - Z1.Radius) + Z1.Radius;
end;

procedure TBitmapEncoderWMF.ZoomInOutTransition(const Sourcebm,
  Targetbm: TBitmap; ZoomSource, ZoomTarget: TZoom; EffectTime: integer;
  cropSource, cropTarget: boolean);
var
  DurMs: integer;
begin
  AddFrame(Sourcebm, cropSource);
  DurMs := round(1 / 10000 * fSampleDuration);
  ZoomInOutTransitionTo(Targetbm, ZoomSource, ZoomTarget, EffectTime - DurMs,
    cropTarget);
end;

procedure TBitmapEncoderWMF.ZoomInOutTransitionTo(const Targetbm: TBitmap;
  ZoomSource, ZoomTarget: TZoom; EffectTime: integer; cropTarget: boolean);
var
  RGBASource, RGBATarget, RGBATweenSource, RGBATweenTarget, RGBATween: TBitmap;
  pSourceStart, pTargetStart, pTweenStart: PByte;
  ZIO: TParallelizer;
  StartTime, EndTime: int64;
  fact: double;
  alpha: byte;
  t: double;
  ZoomTweenSource, ZoomTweenTarget: TRectF;
  Index: integer;
begin
  RGBASource := TBitmap.Create;
  RGBATarget := TBitmap.Create;
  RGBATweenSource := TBitmap.Create;
  RGBATweenTarget := TBitmap.Create;
  RGBATween := TBitmap.Create;
  try
    RGBASource.Assign(fBmRGBA);
    BitmapToRGBA(Targetbm, RGBATarget, cropTarget);
    RGBATween.PixelFormat := pf32bit;
    RGBATween.SetSize(fVideoWidth, fVideoHeight);
    ZIO.Init(fThreadPool.ThreadCount, 4 * fVideoWidth * fVideoHeight);
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
      uScaleWMF.ZoomResampleParallelThreads(fVideoWidth, fVideoHeight,
        RGBASource, RGBATweenSource, ZoomTweenSource, cfBilinear, 0, amIgnore,
        @fThreadPool);
      uScaleWMF.ZoomResampleParallelThreads(fVideoWidth, fVideoHeight,
        RGBATarget, RGBATweenTarget, ZoomTweenTarget, cfBilinear, 0, amIgnore,
        @fThreadPool);
      pSourceStart := RGBATweenSource.ScanLine[fVideoHeight - 1];
      pTargetStart := RGBATweenTarget.ScanLine[fVideoHeight - 1];
      pTweenStart := RGBATween.ScanLine[fVideoHeight - 1];
      alpha := round(255 * t);
      for Index := 0 to fThreadPool.ThreadCount - 1 do
        fThreadPool.ResamplingThreads[Index].RunAnonProc
          (GetCrossFadeProc(ZIO, Index, alpha, pSourceStart, pTargetStart,
          pTweenStart));
      for Index := 0 to fThreadPool.ThreadCount - 1 do
        fThreadPool.ResamplingThreads[Index].Done.WaitFor(INFINITE);

      bmRGBAToSampleBuffer(RGBATween);
      WriteOneFrame(fWriteStart, fSampleDuration);
    end;
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
  StartTime := fWriteStart;
  EndTime := StartTime + EffectTime * 10000;
  while fWriteStart < EndTime do
  begin
    WriteOneFrame(fWriteStart, fSampleDuration);
    if fFrameCount mod fBrake = fBrake - 1 then
      sleep(1);
  end;

end;

{ TZoom }

function TZoom.ToRectF(Width, Height: integer): TRectF;
begin
  result.Left := max((xCenter - Radius) * Width, 0);
  result.Right := min((xCenter + Radius) * Width, Width);
  result.Top := max((yCenter - Radius) * Height, 0);
  result.Bottom := min((yCenter + Radius) * Height, Height);
end;

initialization

{$IFDEF O_PLUS}
{$O+}
{$UNDEF O_PLUS}
{$ENDIF}

end.
