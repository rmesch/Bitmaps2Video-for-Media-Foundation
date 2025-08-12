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
// https://github.com/FactoryXCode/MfPack
// =============================================================================
// Source: FactoryX.Code Sinkwriter and Transcode Examples.
// https://github.com/FactoryXCode/MfPack
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

unit uDemoWMFMain;

interface

uses
  Winapi.Windows,
  Winapi.Messages,
  Winapi.ActiveX,
  Winapi.ShellAPI,
  Winapi.ShlObj,

  System.SysUtils,
  System.Variants,
  System.Classes,
  System.Math,
  System.ImageList,
  System.Types,
  System.Diagnostics,
  System.IOUtils,
  System.Threading,
  System.UITypes,
  System.StrUtils,

  VCL.Graphics,
  VCL.Controls,
  VCL.Forms,
  VCL.Dialogs,
  VCL.StdCtrls,
  VCL.ExtCtrls,
  VCL.ImgList,
  VCL.ComCtrls,
  VCL.Samples.Spin,

  uDirectoryTree,
  uScaleWMF,
  uScaleCommonWMF,
  uToolsWMF,
  uBitMaps2VideoWMF,
  uTransformer,

  Winapi.MediaFoundationApi.MfApi,
  Winapi.MediaFoundationApi.MfUtils,
  Winapi.MediaFoundationApi.MfReadWrite;

const
  MsgUpdate = WM_User + 1;

type
  TListBox = class(VCL.StdCtrls.TListBox)
  private
    fOnSelChange: TNotifyEvent;
    procedure CNCommand(var AMessage: TWMCommand); message CN_COMMAND;
  public
    property OnSelChange: TNotifyEvent read fOnSelChange write fOnSelChange;
  end;

  TDemoWMFMain = class(TForm)
    SettingsPanel: TPanel;
    PagesPanel: TPanel;
    StatusPanel: TPanel;
    PageControl1: TPageControl;
    TabSheet1: TTabSheet;
    WriteAnimation: TButton;
    TabSheet2: TTabSheet;
    Status: TLabel;
    Splitter1: TSplitter;
    FileExt: TComboBox;
    Codecs: TComboBox;
    Panel4: TPanel;
    Panel5: TPanel;
    Background: TCheckBox;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Heights: TComboBox;
    PreviewBox: TPaintBox;
    AspectRatio: TRadioGroup;
    Label1: TLabel;
    SetQuality: TSpinEdit;
    Label5: TLabel;
    Label6: TLabel;
    FrameRates: TComboBox;
    CropLandscape: TCheckBox;
    ZoomInOut: TCheckBox;
    Label9: TLabel;
    FODAudio: TFileOpenDialog;
    OD: TFileOpenDialog;
    DebugTiming: TCheckBox;
    SampleRate: TComboBox;
    Bitrate: TComboBox;
    Label7: TLabel;
    Label10: TLabel;
    Label11: TLabel;
    AudioStartTime: TSpinEdit;
    Label12: TLabel;
    AddAudio: TCheckBox;
    Label8: TLabel;
    TabSheet3: TTabSheet;
    PickStartImage: TButton;
    PickEndImage: TButton;
    PickVideo: TButton;
    FODPic: TFileOpenDialog;
    FODVideo: TFileOpenDialog;
    StartImageFile: TLabel;
    EndImageFile: TLabel;
    VideoClipFile: TLabel;
    CombineToVideo: TButton;
    PickAudio: TButton;
    AudioFileName: TLabel;
    Label14: TLabel;
    Label15: TLabel;
    Memo1: TMemo;
    FrameNo: TSpinEdit;
    FrameBox: TPaintBox;
    Label16: TLabel;
    Label17: TLabel;
    Label18: TLabel;
    TabSheet4: TTabSheet;
    Button1: TButton;
    TranscoderInput: TLabel;
    Transcode: TButton;
    CropToAspect: TCheckBox;
    Memo2: TMemo;
    Label19: TLabel;
    Button4: TButton;
    ImageList1: TImageList;
    MovieBox: TPaintBox;
    ShowPreview: TCheckBox;
    Abort: TButton;
    Label22: TLabel;
    Label23: TLabel;
    StretchToAspect: TCheckBox;
    TransitionTime: TSpinEdit;
    Label27: TLabel;
    Stats: TMemo;
    ImageTime: TSpinEdit;
    Label25: TLabel;
    Label26: TLabel;
    OutputPanel: TPanel;
    ShowVideo: TButton;
    AdvancedPanel: TPanel;
    Button3: TButton;
    DisableHardwareEncoding: TCheckBox;
    DisableThrottling: TCheckBox;
    DisableQualityBasedEncoding: TCheckBox;
    ForceEncodingLevel: TCheckBox;
    Label13: TLabel;
    ThreadlimitSpin: TSpinEdit;
    AdvancedOptions: TButton;
    DisableGOPSize: TCheckBox;
    WriteSlideshow: TButton;
    Splitter2: TSplitter;
    Panel1: TPanel;
    Splitter3: TSplitter;
    Panel3: TPanel;
    Panel2: TPanel;
    Label28: TLabel;
    Button2: TButton;
    PanelDirectory: TPanel;
    Panel6: TPanel;
    Panel7: TPanel;
    ImageCount: TLabel;
    FileBox: TListBox;
    Splitter4: TSplitter;
    PanelPreview: TPanel;
    PictureBox: TPaintBox;
    ShowWidth: TStaticText;
    CodecInfo: TStaticText;
    OutputInfo: TStaticText;
    AdjustToAudio: TCheckBox;
    TabSheet5: TTabSheet;
    Memo3: TMemo;
    Button5: TButton;
    Button6: TButton;
    FSDText: TFileSaveDialog;
    Button7: TButton;
    Label21: TLabel;
    Edit1: TEdit;
    ConvertToWav: TCheckBox;
    ConvertToWav1: TCheckBox;
    ConvertToWav2: TCheckBox;
    Button8: TButton;
    Label20: TLabel;
    AudioCodecs: TComboBox;
    MonitorMemory: TCheckBox;

    // Important procedure showing the use of TBitmapEncoderWMF
    procedure WriteAnimationClick(Sender: TObject);

    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure WriteSlideshowClick(Sender: TObject);
    procedure FileExtChange(Sender: TObject);
    procedure CodecsChange(Sender: TObject);
    procedure HeightsChange(Sender: TObject);
    procedure PreviewBoxPaint(Sender: TObject);
    procedure ShowVideoClick(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure PageControl1Change(Sender: TObject);
    procedure PickStartImageClick(Sender: TObject);
    procedure PickEndImageClick(Sender: TObject);
    procedure PickVideoClick(Sender: TObject);
    procedure PickAudioClick(Sender: TObject);

    // Important procedure showing the use of TBitmapEncoderWMF
    procedure CombineToVideoClick(Sender: TObject);

    procedure FrameNoChange(Sender: TObject);
    procedure FrameBoxPaint(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure TranscodeClick(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure AbortClick(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure AdvancedOptionsClick(Sender: TObject);
    procedure PictureBoxPaint(Sender: TObject);
    procedure PanelPreviewResize(Sender: TObject);
    procedure Button5Click(Sender: TObject);
    procedure Button6Click(Sender: TObject);
    procedure Button7Click(Sender: TObject);
    procedure Edit1Click(Sender: TObject);
    procedure Button8Click(Sender: TObject);
  private
    fDirectoryTree: TDirectoryTree;
    fFileList: TStringlist;
    fOutputFile: string;
    fCodecList: TCodecIdArray;
    fWriting: boolean;
    fFramebm: TBitmap;
    fPicturebm: TBitmap;
    fPreviewWic: TWicImage;
    fUserAbort: boolean;
    function GetOutputFileName: string;
    procedure DoUpdate(var msg: TMessage); message MsgUpdate;
    procedure DirectoryTreeChange(
      Sender: TObject;
      node:   TTreeNode);
    function GetAspect: double;
    function GetVideoWidth: integer;

    // Important procedure showing the use of TBitmapEncoderWMF
    procedure MakeSlideshow(
      const sl:                  TStringlist;
      const wic:                 TWicImage;
      const bm:                  TBitmap;
      const bme:                 TBitmapEncoderWMF;
      var Done:                  boolean;
      threaded:                  boolean;
      ImageTime, TransitionTime: integer);

    function GetFrameRate: double;
    function GetDoCrop: boolean;
    function GetDoZoomInOut: boolean;
    function GetVideoHeight: integer;
    function GetAudioFile: string;
    function GetQuality: integer;
    function GetAudioBitRate: integer;
    function GetAudioSampleRate: integer;
    function GetAudioStart: int64;
    function GetAudioDialog: boolean;
    procedure FileBoxSelChange(Sender: TObject);
    procedure TransCodeProgress(
      Sender:      TObject;
      FrameCount:  Cardinal;
      VideoTime:   int64;
      var DoAbort: boolean);
    procedure SlideShowProgress(
      Sender:      TObject;
      FrameCount:  Cardinal;
      VideoTime:   int64;
      var DoAbort: boolean);
    procedure DisplayVideoInfo(
      const aMemo:     TMemo;
      const VideoInfo: TVideoInfo);
    function GetAdvancedOptions: TEncoderAdvancedOptions;
    procedure ProcessFile(
      const FileN:         string;
      const VideoFileName: string);
    procedure SlideShowProgressThreaded(
      Sender:      TObject;
      FrameCount:  Cardinal;
      VideoTime:   int64;
      var DoAbort: boolean);

    { Private-Deklarationen }
  public
    // properties which read the input parameters for the bitmap-encoder
    // off the controls of the form
    property OutputFileName: string read GetOutputFileName;
    property Aspect: double read GetAspect;
    property VideoHeight: integer read GetVideoHeight;
    property VideoWidth: integer read GetVideoWidth;
    property FrameRate: double read GetFrameRate;
    property Quality: integer read GetQuality;
    property DoCrop: boolean read GetDoCrop;
    property DoZoomInOut: boolean read GetDoZoomInOut;
    property AudioFile: string read GetAudioFile;
    property AudioSampleRate: integer read GetAudioSampleRate;
    property AudioBitRate: integer read GetAudioBitRate;
    property AudioStart: int64 read GetAudioStart;
    property AudioDialog: boolean read GetAudioDialog;
    property EncoderAdvancedOptions: TEncoderAdvancedOptions
      read GetAdvancedOptions;
    { Public-Deklarationen }
  end;

var
  DemoWMFMain: TDemoWMFMain;

implementation

{$R *.dfm}


function PIDLToPath(IdList: PItemIDList)
  : string;
begin
  SetLength(
    Result,
    MAX_PATH);
  if SHGetPathFromIdList(IdList, PChar(Result)) then
    SetLength(
      Result,
      StrLen(PChar(Result)))
  else
    Result := '';
end;

function PidlFree(var IdList: PItemIDList)
  : boolean;
var
  Malloc: IMalloc;
begin
  Result := false;
  if IdList = nil then
    Result := true
  else
  begin
    if Succeeded(SHGetMalloc(Malloc)) and (Malloc.DidAlloc(IdList) > 0) then
    begin
      Malloc.Free(IdList);
      IdList := nil;
      Result := true;
    end;
  end;
end;

function GetDesktopFolder: string;
var
  FolderPidl: PItemIDList;
begin
  if Succeeded(SHGetSpecialFolderLocation(0, $0000, FolderPidl)) then
  begin
    Result := PIDLToPath(FolderPidl);
    PidlFree(FolderPidl);
  end
  else
    Result := '';
end;

function GetPicturesFolder: string;
var
  FolderPidl: PItemIDList;
begin
  if Succeeded(SHGetSpecialFolderLocation(0, CSIDL_MYPICTURES, FolderPidl)) then
  begin
    Result := PIDLToPath(FolderPidl);
    PidlFree(FolderPidl);
  end
  else
    Result := '';
end;

// file size in bytes
function GetFileSize(const fileName: String)
  : int64;
var
  info: TWin32FileAttributeData;
begin
  if not GetFileAttributesEx(PWideChar(fileName), GetFileExInfoStandard, @info)
  then
    RaiseLastOSError;
  Result := int64(info.nFileSizeLow) or int64(info.nFileSizeHigh shl 32);
end;

procedure TDemoWMFMain.WriteAnimationClick(Sender: TObject);
var
  i, j, w, h: integer;
  A, r, theta, dtheta, costheta, sintheta: double;
  xCenter, yCenter: integer;
  scale: double;
  bm, pre: TBitmap;
  points: array of TPoint;
  jmax: integer;
  bme: TBitmapEncoderWMF;
  StopWatch: TStopWatch;

  function dist(o: double)
    : double; inline;
  begin
    Result := 2 - 0.2 * o;
  end;

// map from world ([-2,2]x[-2,2]) to bitmap
  function map(p: TPointF)
    : TPoint;
  begin
    Result.x := round(xCenter + scale * p.x);
    Result.y := round(yCenter - scale * p.y);
  end;

begin
  if fWriting then
  begin
    ShowMessage('Encoding in progress, wait until finished.');
    exit;
  end;
  fWriting := true;
  try
    h := VideoHeight;
    w := VideoWidth;
    PreviewBox.Width := round(Aspect * PreviewBox.Height);
    StopWatch := TStopWatch.Create;
    bme := TBitmapEncoderWMF.Create;
    try
      // Set advanced options
      bme.EncoderAdvancedOptions := Self.EncoderAdvancedOptions;
      // Initialize the bitmap-encoder
      bme.Initialize(
        OutputFileName,
        w,
        h,
        Quality,
        FrameRate,
        fCodecList[Codecs.ItemIndex],
        cfBicubic);
      bm := TBitmap.Create;
      try
        // AntiAlias 2*Video-Size
        bm.SetSize(
          2 * w,
          2 * h);
        xCenter := bm.Width div 2;
        yCenter := bm.Height div 2;
        scale := bm.Height / 4;

        bm.Canvas.brush.color := $009BFFFF;
        bm.Canvas.pen.color := clGreen;
        bm.Canvas.pen.Width := Max(
          h div 180,
          2);

        dtheta := 2 / 150 * pi;
        StopWatch.Start;
        // Draw a sequence of spirals
        for i := 0 to 200 do
        begin
          A := 1 - 1 / 210 * i;
          jmax := trunc(10 / A / dtheta);
          SetLength(
            points,
            jmax);
          theta := 0;
          for j := 0 to jmax - 1 do
          begin
            r := dist(A * theta);
            SinCos(
              theta,
              sintheta,
              costheta);
            points[j] := map(Pointf(r * costheta, r * sintheta));
            theta := theta + dtheta;
          end;
          bm.Canvas.Fillrect(bm.Canvas.clipRect);
          bm.Canvas.PolyLine(points);

          bme.AddFrame(
            bm,
            false);

          Status.Caption := 'Frame ' + (i + 1).ToString;
          Status.Repaint;
          if i mod 15 = 1 then
          begin
            pre := TBitmap.Create;
            try
              Resample(
                PreviewBox.Width,
                PreviewBox.Height,
                bm,
                pre,
                cfBilinear,
                0,
                true,
                amIgnore);
              BitBlt(
                PreviewBox.Canvas.Handle,
                0,
                0,
                pre.Width,
                pre.Height,
                pre.Canvas.Handle,
                0,
                0,
                SRCCopy);
            finally
              pre.Free;
            end;
          end;
        end;
        StopWatch.Stop;
        Status.Caption := 'Writing speed including drawing to canvas: ' +
          FloatToStrF(bme.FrameCount * 1000 / StopWatch.ElapsedMilliseconds,
          ffFixed, 5, 2) + ' fps';
      finally
        bm.Free;
      end;
      bme.Finalize;

    finally
      bme.Free;
    end;
  finally
    fWriting := false;
  end;
end;

procedure TDemoWMFMain.MakeSlideshow(
  const sl:                  TStringlist;
  const wic:                 TWicImage;
  const bm:                  TBitmap;
  const bme:                 TBitmapEncoderWMF;
  var Done:                  boolean;
  threaded:                  boolean;
  ImageTime, TransitionTime: integer);
var
  i: integer;
  crop: boolean;
  dice: single;
  // TZoom is a record (xcenter, ycenter, radius) defining a virtual zoom-rectangle
  // (xcenter-radius, ycenter-radius, xcenter+radius, ycenter+radius).
  // This rectangle should be a sub-rectangle of [0,1]x[0,1].
  // If multipied by the width/height of a target rectangle, it defines
  // an aspect-preserving sub-rectangle of the target.
  Zooms, Zoom: TZoom;
  DoInOut: boolean;
begin
  wic.LoadFromFile(sl.Strings[0]);
  WicToBmp(
    wic,
    bm);
  crop := (bm.Width > bm.Height) and DoCrop;
  bme.AddStillImage(
    bm,
    ImageTime + TransitionTime,
    crop);
  PostMessage(
    Handle,
    MsgUpdate,
    0,
    0);
  if not threaded then
    Application.ProcessMessages;
  for i := 1 to sl.Count - 1 do
  begin
    if fUserAbort then
      break;
    wic.LoadFromFile(sl.Strings[i]);
    WicToBmp(
      wic,
      bm);
    crop := (bm.Width > bm.Height) and DoCrop;
    dice := random;
    DoInOut := DoZoomInOut and (dice < 1 / 3);
    if not DoInOut then
      bme.CrossFadeTo(
        bm,
        TransitionTime,
        crop)

    else
    begin
      Zooms := GetRandomZoom;
      Zoom := GetRandomZoom;

      bme.ZoomInOutTransitionTo(
        bm,
        Zooms,
        Zoom,
        TransitionTime,
        crop);

    end;
    bme.AddStillImage(
      bm,
      ImageTime,
      crop);
    PostMessage(
      Handle,
      MsgUpdate,
      i,
      0);
    if not threaded then
      Application.ProcessMessages;
  end;
  Done := true;
end;

procedure TDemoWMFMain.ShowVideoClick(Sender: TObject);
begin
  if (not fWriting) and FileExists(OutputFileName) then
  begin
    ShellExecute(
      Handle,
      'open',
      PWideChar(OutputFileName),
      nil,
      nil,
      SW_SHOWNORMAL);
  end
  else
    ShowMessage('Output file not available');
end;

procedure TDemoWMFMain.SlideShowProgress(
  Sender:      TObject;
  FrameCount:  Cardinal;
  VideoTime:   int64;
  var DoAbort: boolean);
// var stats: TVideoStats;
begin
  Application.ProcessMessages;
  DoAbort := fUserAbort;

  if MonitorMemory.Checked then
  begin
    Stats.Clear;
    Stats.Lines.add('Memory used [MB]: ' +
      (CurrentProcessMemory div (1024 * 1024)).ToString);
  end;
end;

procedure TDemoWMFMain.SlideShowProgressThreaded(
  Sender:      TObject;
  FrameCount:  Cardinal;
  VideoTime:   int64;
  var DoAbort: boolean);
// var stats: TVideoStats;
begin
  TThread.Synchronize(TThread.Current,
    procedure
    begin
      Application.ProcessMessages;
      if MonitorMemory.Checked then
      begin
        Stats.Clear;
        Stats.Lines.add('Memory used [MB]: ' +
          (CurrentProcessMemory div (1024 * 1024)).ToString);
      end;
    end);
  DoAbort := fUserAbort;
end;

procedure TDemoWMFMain.WriteSlideshowClick(Sender: TObject);
var
  bme: TBitmapEncoderWMF;
  bm: TBitmap;
  wic: TWicImage;
  StopWatch: TStopWatch;
  task: itask;
  Done: boolean;
  sl: TStringlist;
  af: string;
  i: integer;
  TimeImage, TimeTransition: integer;
  SlideshowTime, AudioTime: int64;
  VideoInfo: TVideoInfo;
  WaveFileName: string;
  VideoStats: TVideoStats;
begin
  if fWriting then
  begin
    ShowMessage('Encoding in progress, wait until finished.');
    exit;
  end;
  af := '';
  WaveFileName := '';
  AudioTime := 0;
  if AudioDialog then
  begin
    af := AudioFile;
    if af = '' then
    begin
      ShowMessage('No audio file selected');
      exit;
    end;
    AudioTime := trunc(1 / 10000 * GetAudioDuration(af));
  end;
  fWriting := true;
  fUserAbort := false;
  // Use a local stringlist because of threading
  sl := TStringlist.Create;
  try
    for i := 0 to fFileList.Count - 1 do
      if FileBox.Selected[i] then
        sl.add(fFileList.Strings[i]);
    if sl.Count = 0 then
    begin
      ShowMessage('No image files selected');
      exit;
    end;
    TimeTransition := TransitionTime.Value;
    if AdjustToAudio.Checked then
    begin
      TimeImage :=
        round((AudioTime + AudioStart - sl.Count *
        TimeTransition) /
        sl.Count);
      if MessageDlg('Calculated image time: ' + TimeImage.ToString + ' ms',
        mtConfirmation, [mbYes, mbNo], 0) = mrNo then
        exit;
    end
    else
      TimeImage := ImageTime.Value;
    SlideshowTime := sl.Count * (TimeImage + TimeTransition);
    bme := TBitmapEncoderWMF.Create;
    bm := TBitmap.Create;
    wic := TWicImage.Create;
    StopWatch := TStopWatch.Create;
    try
      Status.Caption := 'Working';
      StopWatch.Start;

      try
        // Set advanced options
        bme.EncoderAdvancedOptions := Self.EncoderAdvancedOptions;

        if (af <> '') and ConvertToWav.Checked then
        begin
          WaveFileName := ExtractFilePath(Application.ExeName) +
            'Convert.wav';
          if AdjustToAudio.Checked then
            SaveAudioStreamAsWav(
              af,
              WaveFileName,
              0)
          else
            SaveAudioStreamAsWav(
              af,
              WaveFileName,
              SlideshowTime);
          af := WaveFileName;
        end;

        bme.Initialize(
          OutputFileName,
          VideoWidth,
          VideoHeight,
          Quality,
          FrameRate,
          fCodecList[Codecs.ItemIndex],
          cfRobidouxSharp,
          af,
          TAudioCodecId(AudioCodecs.ItemIndex),
          AudioBitRate,
          AudioSampleRate,
          AudioStart);
      except
        on eAudioFormatException do
        begin
          ShowMessage
            ('The format of the audio input file or the settings of bitrate or sample rate are not supported. Try again with different settings.');
          exit;
        end
        else
        begin
          ShowMessage
            ('The setup of the encoder failed. The codec chosen might not be installed.');
          exit;
        end;
      end;
      bme.TimingDebug := DebugTiming.Checked;

      if Background.Checked then
      begin
        bme.OnProgress := SlideShowProgressThreaded;
        Done := false;
        task := TTask.Run(
          procedure
          begin
            MakeSlideshow(
              sl,
              wic,
              bm,
              bme,
              Done,
              true,
              TimeImage,
              TimeTransition);
          end);
        while not Done do
        begin
          CheckSynchronize;
          sleep(10);
        end;
        task.Wait();
        Application.ProcessMessages;
      end
      else
      begin
        bme.OnProgress := SlideShowProgress;
        MakeSlideshow(
          sl,
          wic,
          bm,
          bme,
          Done,
          false,
          TimeImage,
          TimeTransition);
      end;
      StopWatch.Stop;
      Status.Caption :=
        'Writing speed including decoding of image files and computing transitions: '
        + FloatToStrF(1000 * bme.FrameCount / StopWatch.ElapsedMilliseconds,
        ffFixed, 5, 2) + ' fps';
      // Get the status of the sinkwrite before calling Finalize.
      // The queued up frames haven't been flushed yet.
      VideoStats := bme.EncodingStats;
      bme.Finalize;
      Status.Repaint;
      Stats.Lines.BeginUpdate;
      try
        Stats.Clear;
        Stats.Lines.add('Slideshow time: ' +
          SlideshowTime.ToString + ' ms' + ' (' +
          Winapi.MediaFoundationApi.MfUtils.HnsTimeToStr(SlideshowTime * 10000,
          false) + ' [h:m:s])');
        VideoInfo := GetVideoInfo(OutputFileName);
        Stats.Lines.add('Output video duration: ' +
          (VideoInfo.Duration div 10000).ToString + ' ms' + ' (' +
          Winapi.MediaFoundationApi.MfUtils.HnsTimeToStr(VideoInfo.Duration,
          false) + ' [h:m:s])');
        Stats.Lines.add('Audio duration: ' +
          bme.AudioFileDuration.ToString + ' ms');
        Stats.Lines.add('File size: ' + (round(100 * GetFileSize(OutputFileName) /
          1024 / 1024) / 100).ToString + ' MB');

        Stats.Lines.add('Sinkwriter statistics before call to bme.Finalize:');
        Stats.Lines.add('Samples received: ' +
          VideoStats.qwNumSamplesReceived.ToString);
        Stats.Lines.add('Samples encoded: ' +
          VideoStats.qwNumSamplesEncoded.ToString);
        Stats.Lines.add('Samples processed: ' +
          VideoStats.qwNumSamplesProcessed.ToString);
        Stats.Lines.add('ByteCountQueued: ' +
          VideoStats.dwByteCountQueued.ToString);
        Stats.Lines.add('AverageSampleRateReceived: ' +
          VideoStats.dwAverageSampleRateReceived.ToString);
        Stats.Lines.add('AverageSampleRateEncoded: ' +
          VideoStats.dwAverageSampleRateEncoded.ToString);

        VideoStats := bme.EncodingStats;
        Stats.Lines.add('Sinkwriter statistics after call to bme.Finalize:');
        Stats.Lines.add('Samples received: ' +
          VideoStats.qwNumSamplesReceived.ToString);
        Stats.Lines.add('Samples encoded: ' +
          VideoStats.qwNumSamplesEncoded.ToString);
        Stats.Lines.add('Samples processed: ' +
          VideoStats.qwNumSamplesProcessed.ToString);
        Stats.Lines.add('ByteCountQueued: ' +
          VideoStats.dwByteCountQueued.ToString);
        Stats.Lines.add('AverageSampleRateReceived: ' +
          VideoStats.dwAverageSampleRateReceived.ToString);
        Stats.Lines.add('AverageSampleRateEncoded: ' +
          VideoStats.dwAverageSampleRateEncoded.ToString);
        Stats.SelStart := 0;
        Stats.SelLength := 0;
        Stats.Perform(
          EM_SCROLLCARET,
          0,
          0);
      finally
        Stats.Lines.EndUpdate;
      end;
    finally
      wic.Free;
      bm.Free;
      bme.Free;
    end;
  finally
    sl.Free;
    fWriting := false;
  end;
end;

procedure TDemoWMFMain.CombineToVideoClick(Sender: TObject);
var
  proceed: boolean;
  bme: TBitmapEncoderWMF;
  wic: TWicImage;
  bm: TBitmap;
  af: string;
  StopWatch: TStopWatch;
  fps: double;
  WaveFileName: string;
begin
  if fWriting then
  begin
    ShowMessage('Encoding in progress, wait until finished.');
    exit;
  end;
  fWriting := true;
  fUserAbort := false;

  try
    proceed := FileExists(StartImageFile.Caption) and
      FileExists(EndImageFile.Caption) and FileExists(VideoClipFile.Caption);
    proceed := proceed and (VideoClipFile.Caption <> OutputFileName);
    if not proceed then
    begin
      ShowMessage
        ('Pick valid files for the images and the video clip first.');
      exit;
    end;

    Status.Caption := 'Working';
    if not FileExists(AudioFileName.Caption) then
      af := ''
    else
    begin
      af := AudioFileName.Caption;
      if ConvertToWav1.Checked then
      begin
        WaveFileName := ExtractFilePath(Application.ExeName) + 'Convert.wav';
        SaveAudioStreamAsWav(
          af,
          WaveFileName,
          0);
        af := WaveFileName;
      end;
    end;

    StopWatch := TStopWatch.Create;
    bme := TBitmapEncoderWMF.Create;
    try
      StopWatch.Start;
      Status.Caption := 'Working';
      try
        // Set advanced options
        bme.EncoderAdvancedOptions := Self.EncoderAdvancedOptions;
        bme.Initialize(
          OutputFileName,
          VideoWidth,
          VideoHeight,
          Quality,
          FrameRate,
          TCodecID(Codecs.ItemIndex),
          cfBicubic,
          af,
          AAC,
          128,
          44100,
          9000);
      except
        on eAudioFormatException do
        begin
          ShowMessage('The format of the audio file is not supported.');
          exit;
        end
        else
          raise;
      end;
      wic := TWicImage.Create;
      bm := TBitmap.Create;
      try
        wic.LoadFromFile(StartImageFile.Caption);
        WicToBmp(
          wic,
          bm);
        Status.Caption := 'Start Image';
        bme.AddStillImage(
          bm,
          5000,
          false);
        Status.Caption := 'Video Clip';
        try
          bme.OnProgress := TransCodeProgress;
          bme.AddVideo(
            VideoClipFile.Caption,
            4000,
            false);
        except
          on EVideoFormatException do
          begin
            ShowMessage('Video format of ' + VideoClipFile.Caption +
              ' is not supported.');
            exit;
          end
          else
            raise;
        end;
        if not fUserAbort then
        begin
          wic.LoadFromFile(EndImageFile.Caption);
          WicToBmp(
            wic,
            bm);
          bme.OnProgress := nil;
          Status.Caption := 'End Image';
          bme.CrossFadeTo(
            bm,
            4000,
            false);
          bme.AddStillImage(
            bm,
            5000,
            false);
        end;
      finally
        bm.Free;
        wic.Free;
      end;
      StopWatch.Stop;
      fps := 1000 * bme.FrameCount / StopWatch.ElapsedMilliseconds;
    finally
      // destroy finalizes
      bme.Free;
    end;
    Status.Caption := 'Writing speed: ' + FloatToStrF(fps, ffFixed, 5,
      2) + ' fps';
  finally
    fWriting := false;
  end;
end;

procedure TDemoWMFMain.AbortClick(Sender: TObject);
begin
  fUserAbort := true;
end;

procedure TDemoWMFMain.AdvancedOptionsClick(Sender: TObject);
begin
  AdvancedPanel.Visible := true;
  AdvancedPanel.BringToFront;
  AdvancedPanel.Repaint;
end;

procedure TDemoWMFMain.Button1Click(Sender: TObject);
var
  VideoInfo: TVideoInfo;
begin
  if not FODVideo.Execute then
    exit;
  TranscoderInput.Caption := FODVideo.fileName;
  try
    VideoInfo := GetVideoInfo(FODVideo.fileName);
  except
    ShowMessage('Format of input file not supported');
  end;
  DisplayVideoInfo(
    Memo2,
    VideoInfo);
end;

procedure TDemoWMFMain.Button2Click(Sender: TObject);
begin
  if not OD.Execute(Self.Handle) then
    exit;
  fDirectoryTree.NewRootFolder(OD.fileName);
end;

procedure TDemoWMFMain.Button3Click(Sender: TObject);
begin
  AdvancedPanel.Visible := false;
end;

procedure TDemoWMFMain.TransCodeProgress(
  Sender:      TObject;
  FrameCount:  Cardinal;
  VideoTime:   int64;
  var DoAbort: boolean);
var
  min, sec: integer;
begin
  sec := VideoTime div 1000;
  min := sec div 60;
  sec := sec mod 60;
  Status.Caption := 'Encoding time-stamp: ' + min.ToString + ':' + sec.ToString;
  Status.Invalidate;
  Application.ProcessMessages;
  DoAbort := fUserAbort;
end;

procedure TDemoWMFMain.TranscodeClick(Sender: TObject);
var
  LastFrame, Preview: TBitmap;
begin
  if fWriting then
  begin
    ShowMessage('Encoding in progress, wait until finished.');
    exit;
  end;
  fWriting := true;
  try
    Status.Caption := 'Working, please wait';
    fUserAbort := false;
    MovieBox.Width := round(MovieBox.Height * Aspect);
    LastFrame := TBitmap.Create;
    Preview := TBitmap.Create;
    try
      TranscodeVideoFile(
        TranscoderInput.Caption,
        OutputFileName,
        TCodecID(Codecs.ItemIndex),
        Quality,
        VideoWidth,
        VideoHeight,
        FrameRate,
        CropToAspect.Checked,
        StretchToAspect.Checked,
        ConvertToWav2.Checked,
        procedure(Sender: TObject; FrameCount: Cardinal; VideoTime: int64;
          var DoAbort: boolean)
        begin
          if ShowPreview.Checked then
          begin
            LastFrame.Assign(TBitmapEncoderWMF(Sender).LastFrame);
            uScaleWMF.Resample(
              MovieBox.Width,
              MovieBox.Height,
              LastFrame,
              Preview,
              cfBilinear,
              0,
              true,
              amIgnore,
              nil);
            BitBlt(
              MovieBox.Canvas.Handle,
              0,
              0,
              MovieBox.Width,
              MovieBox.Height,
              Preview.Canvas.Handle,
              0,
              0,
              SRCCopy);
          end;

          TransCodeProgress(
            Sender,
            FrameCount,
            VideoTime,
            DoAbort);
        end);
      if fUserAbort then
        Status.Caption := 'Aborted'
      else
        Status.Caption := 'Done';
    finally
      Preview.Free;
      LastFrame.Free;
    end;
  finally
    fWriting := false;
    fUserAbort := false;
  end;
end;

procedure TDemoWMFMain.Button4Click(Sender: TObject);
begin
  fUserAbort := true;
end;

procedure TDemoWMFMain.ProcessFile(
  const FileN:         string;
  const VideoFileName: string);
var
  StrList: TStringlist;
  Line: string;
  i, p: integer;
  DurationString: string;
begin
  Memo3.Clear;
  Memo3.Lines.add(ExtractFilename(VideoFileName));
  StrList := TStringlist.Create;
  try
    StrList.LineBreak := '[/FRAME]'#13#10;
    StrList.LoadFromFile(FileN);
    if StrList.Count = 0 then
      exit;
    Memo3.Lines.BeginUpdate;
    try
      for i := 0 to StrList.Count - 1 do
      begin
        Line := StrList[i];
        p := PosEx(
          'duration_time',
          Line);
        DurationString := Copy(
          Line,
          p,
          PosEx('pkt_pos', Line) - p - 1);
        p := PosEx(
          'pkt_dts',
          Line);
        if p > 0 then
          Line := LeftStr(
            Line,
            p - 1);
        if Length(Line) > Length('[FRAME] media_type=') then
          Line := RightStr(
            Line,
            Length(Line) - Length('[FRAME] media_type=') - 1);
        Line := ReplaceStr(
          Line,
          #13#10,
          ' ') + ' ' + DurationString;
        Memo3.Lines.add(Line);
      end;
    finally
      Memo3.Lines.EndUpdate;
    end;
  finally
    StrList.Free;
  end;
end;

procedure TDemoWMFMain.Button5Click(Sender: TObject);
var
  Sei: TShellExecuteInfo;
  Success: boolean;
  ffProbePath: string;
begin
  if fWriting or (not System.SysUtils.FileExists(OutputFileName)) then
  begin
    ShowMessage('Output file has not been generated');
    exit;
  end;

  ffProbePath := ExtractFilePath(Application.ExeName);
  TDirectory.SetCurrentDirectory(ffProbePath);

  DeleteFile('AVFrames.txt');

  FillChar(
    Sei,
    SizeOf(Sei),
    #0);
  Sei.cbSize := SizeOf(Sei);
  Sei.fMask := SEE_MASK_DOENVSUBST or SEE_MASK_FLAG_NO_UI or
    SEE_MASK_NOCLOSEPROCESS;
  Sei.lpFile := PChar('cmd.exe');
  Sei.lpParameters := PChar('/c ffprobe.exe -show_frames ' + '"' +
    OutputFileName + '" > AVframes.txt');
  Sei.lpVerb := PChar('');
  Sei.nShow := SW_Hide;
  Status.Caption := 'Working';
  Success := ShellExecuteEx(@Sei);
  if Success then
  begin
    WaitForInputIdle(
      Sei.hProcess,
      INFINITE);
    WaitForSingleObject(
      Sei.hProcess,
      INFINITE);
    CloseHandle(Sei.hProcess);
    ProcessFile(
      'AVFrames.txt',
      OutputFileName);
    Status.Caption := 'Done';
  end
  else
    Status.Caption := 'Failed';
end;

procedure TDemoWMFMain.Button6Click(Sender: TObject);
var
  ffProbePath: string;
begin
  ffProbePath := ExtractFilePath(Application.ExeName);
  TDirectory.SetCurrentDirectory(ffProbePath);
  FSDText.DefaultFolder := ffProbePath;
  if not FSDText.Execute then
    exit;
  Memo3.Lines.SaveToFile(FSDText.fileName);
end;

procedure TDemoWMFMain.Button7Click(Sender: TObject);
var
  Sei: TShellExecuteInfo;
  Success: boolean;
  ffProbePath: string;
begin
  if not FODAudio.Execute then
    exit;
  ffProbePath := ExtractFilePath(Application.ExeName);
  TDirectory.SetCurrentDirectory(ffProbePath);

  DeleteFile('AVFrames.txt');

  FillChar(
    Sei,
    SizeOf(Sei),
    #0);
  Sei.cbSize := SizeOf(Sei);
  Sei.fMask := SEE_MASK_DOENVSUBST or SEE_MASK_FLAG_NO_UI or
    SEE_MASK_NOCLOSEPROCESS;
  Sei.lpFile := PChar('cmd.exe');
  Sei.lpParameters := PChar('/c ffprobe.exe -show_frames ' + '"' +
    FODAudio.fileName + '" > AVframes.txt');
  Sei.lpVerb := PChar('');
  Sei.nShow := SW_Hide;
  Status.Caption := 'Working';
  Success := ShellExecuteEx(@Sei);
  if Success then
  begin
    WaitForInputIdle(
      Sei.hProcess,
      INFINITE);
    WaitForSingleObject(
      Sei.hProcess,
      INFINITE);
    CloseHandle(Sei.hProcess);
    ProcessFile(
      'AVFrames.txt',
      FODAudio.fileName);
    Status.Caption := 'Done';
  end
  else
    Status.Caption := 'Failed';
end;

procedure TDemoWMFMain.Button8Click(Sender: TObject);
begin
  fUserAbort := true;
end;

procedure TDemoWMFMain.PickAudioClick(Sender: TObject);
begin
  AudioFileName.Caption := AudioFile;
end;

procedure TDemoWMFMain.CodecsChange(Sender: TObject);
begin
  CodecInfo.Caption := CodecInfos[fCodecList[Codecs.ItemIndex]];
  OutputInfo.Caption := 'Output will be saved to ' + OutputFileName;
end;

procedure TDemoWMFMain.DirectoryTreeChange(
  Sender: TObject;
  node:   TTreeNode);
var
  i: integer;
begin
  fDirectoryTree.GetAllFiles(
    fFileList,
    '*.bmp;*.jpg;*.png;*.gif;*.tif');
  FileBox.Clear;
  for i := 0 to fFileList.Count - 1 do
  begin
    FileBox.Items.add(ExtractFilename(fFileList.Strings[i]));
  end;
  FileBox.SelectAll;
  FileBoxSelChange(nil);
end;

procedure TDemoWMFMain.FileBoxSelChange(Sender: TObject);
var
  bm: TBitmap;
  dr: TRect;
begin
  ImageCount.Caption := FileBox.SelCount.ToString +
    ' images selected (bmp, jpg, png, gif, tif)';
  if FileBox.ItemIndex >= 0 then
  begin
    // item clicked on
    fPreviewWic.LoadFromFile(fFileList.Strings[FileBox.ItemIndex]);
    bm := TBitmap.Create;
    try
      WicToBmp(
        fPreviewWic,
        bm);
      MaximizeToRect(
        bm,
        fPicturebm,
        PanelPreview.ClientRect,
        dr);
      PictureBox.BoundsRect := dr;
      PictureBox.Repaint;
    finally
      bm.Free;
    end;
  end;
end;

procedure TDemoWMFMain.DoUpdate(var msg: TMessage);
begin
  Status.Caption := 'Image ' + (msg.WParam + 1).ToString;
  Status.Repaint;
end;

procedure TDemoWMFMain.Edit1Click(Sender: TObject);
begin
  ShellExecute(
    Handle,
    'open',
    PWideChar(Edit1.text),
    nil,
    nil,
    SW_SHOWNORMAL);
end;

procedure TDemoWMFMain.FileExtChange(Sender: TObject);
var
  i: integer;
begin
  fCodecList := GetSupportedCodecs(FileExt.Items[FileExt.ItemIndex]);
  Codecs.Clear;
  for i := 0 to Length(fCodecList) - 1 do
    Codecs.Items.add(CodecNames[fCodecList[i]]);
  Codecs.ItemIndex := 0;
  CodecsChange(nil);
end;

procedure TDemoWMFMain.FormCreate(Sender: TObject);
var
  i: integer;
begin
  fFramebm := TBitmap.Create;
  fPicturebm := TBitmap.Create;
  fPreviewWic := TWicImage.Create;

  fDirectoryTree := TDirectoryTree.Create(Self);
  fDirectoryTree.Parent := PanelDirectory;
  fDirectoryTree.Align := alClient;
  fDirectoryTree.Images := ImageList1;
  fDirectoryTree.HideSelection := false;
  fFileList := TStringlist.Create;
  fDirectoryTree.OnChange := DirectoryTreeChange;
  fDirectoryTree.NewRootFolder(GetPicturesFolder);
  DirectoryTreeChange(
    fDirectoryTree,
    fDirectoryTree.Selected);

  FileBox.OnSelChange := FileBoxSelChange;

  fOutputFile := GetDesktopFolder + '\Example';

  fCodecList := GetSupportedCodecs('.mp4');
  for i := 0 to Length(fCodecList) - 1 do
    Codecs.Items.add(CodecNames[fCodecList[i]]);
  Codecs.ItemIndex := 0;

  HeightsChange(nil);
  CodecsChange(nil);

  FrameBox.ControlStyle := FrameBox.ControlStyle + [csOpaque];
  PreviewBox.ControlStyle := PreviewBox.ControlStyle + [csOpaque];
  PictureBox.ControlStyle := PictureBox.ControlStyle + [csOpaque];

  AdvancedPanel.Parent := OutputPanel;
  AdvancedPanel.Align := alNone;
  AdvancedPanel.SetBounds(
    0,
    0,
    OutputPanel.ClientWidth,
    OutputPanel.ClientHeight);
  AdvancedPanel.Anchors := [akLeft, akTop, akRight, akBottom];
  AdvancedPanel.BringToFront;
  Randomize;
end;

procedure TDemoWMFMain.FormDestroy(Sender: TObject);
begin
  fFileList.Free;
  fFramebm.Free;
  fPicturebm.Free;
  fPreviewWic.Free;
end;

procedure TDemoWMFMain.FrameBoxPaint(Sender: TObject);
begin
  BitBlt(
    FrameBox.Canvas.Handle,
    0,
    0,
    fFramebm.Width,
    fFramebm.Height,
    fFramebm.Canvas.Handle,
    0,
    0,
    SRCCopy);
end;

procedure TDemoWMFMain.FrameNoChange(Sender: TObject);
begin
  if FileExists(VideoClipFile.Caption) then
  begin
    if GetFrameBitmap(VideoClipFile.Caption, fFramebm, FrameBox.Height,
      FrameNo.Value) then
    begin
      FrameBox.Width := fFramebm.Width;
      FrameBox.Invalidate;
    end;
  end;
end;

function TDemoWMFMain.GetAdvancedOptions: TEncoderAdvancedOptions;
begin
  if DisableThrottling.Checked then
  begin
    if MessageDlg
      ('Disabling the throttling of the main thread can lead to unexpected results. Are you sure?',
      mtWarning, [mbYes, mbNo], 0) = mrNo then
      exit;
  end;
  Result.DisableHardwareEncoding := DisableHardwareEncoding.Checked;
  Result.DisableThrottling := DisableThrottling.Checked;
  Result.DisableQualityBasedEncoding := DisableQualityBasedEncoding.Checked;
  Result.DisableGOPSize := DisableGOPSize.Checked;
  Result.ForceEncoderLevel := ForceEncodingLevel.Checked;
  Result.ResamplingThreadsLimit := ThreadlimitSpin.Value;
end;

function TDemoWMFMain.GetAspect: double;
begin
  Result := 1;
  case AspectRatio.ItemIndex of
    0:
      Result := 16 / 9;
    1:
      Result := 4 / 3;
    2:
      Result := 3 / 2;
  end;
end;

function TDemoWMFMain.GetAudioBitRate: integer;
begin
  Result := StrToInt(Bitrate.text);
end;

function TDemoWMFMain.GetAudioDialog: boolean;
begin
  Result := AddAudio.Checked;
end;

function TDemoWMFMain.GetAudioFile: string;
begin
  Result := '';
  FODAudio.fileName := '';
  if not FODAudio.Execute(Handle) then
    exit;

  Result := FODAudio.fileName;
end;

function TDemoWMFMain.GetAudioSampleRate: integer;
begin
  Result := StrToInt(SampleRate.text);
end;

function TDemoWMFMain.GetAudioStart: int64;
begin
  Result := AudioStartTime.Value;
end;

function TDemoWMFMain.GetDoCrop: boolean;
begin
  Result := CropLandscape.Checked;
end;

function TDemoWMFMain.GetDoZoomInOut: boolean;
begin
  Result := ZoomInOut.Checked;
end;

const
  FrameRateArray: array [0 .. 9] of double = (25, 29.296875, 29.97, 30, 31.25,
    45, 46.875,
    60, 90, 120);

function TDemoWMFMain.GetFrameRate: double;
begin
  Result := FrameRateArray[FrameRates.ItemIndex];
end;

function TDemoWMFMain.GetOutputFileName: string;
begin
  Result := fOutputFile + '_' + CodecShortNames[fCodecList[Codecs.ItemIndex]] +
    FileExt.text;
end;

function TDemoWMFMain.GetQuality: integer;
begin
  Result := SetQuality.Value;
end;

function TDemoWMFMain.GetVideoHeight: integer;
begin
  Result := StrToInt(Heights.text);
end;

function TDemoWMFMain.GetVideoWidth: integer;
begin
  Result := round(Aspect * VideoHeight);
end;

procedure TDemoWMFMain.HeightsChange(Sender: TObject);
begin
  ShowWidth.Caption := 'Width in p: ' + VideoWidth.ToString;
  PreviewBox.Width := round(PreviewBox.Height * Aspect);
end;

procedure TDemoWMFMain.PageControl1Change(Sender: TObject);
begin
  // if PageControl1.TabIndex = 1 then
  // DirectoryTreeChange(
  // fDirectoryTree,
  // fDirectoryTree.Selected);
end;

procedure TDemoWMFMain.PanelPreviewResize(Sender: TObject);
begin
  FileBoxSelChange(nil);
end;

procedure TDemoWMFMain.PickEndImageClick(Sender: TObject);
begin
  if not FODPic.Execute then
    exit;
  EndImageFile.Caption := FODPic.fileName;
end;

procedure TDemoWMFMain.PickStartImageClick(Sender: TObject);
begin
  if not FODPic.Execute then
    exit;
  StartImageFile.Caption := FODPic.fileName;
end;

procedure TDemoWMFMain.PickVideoClick(Sender: TObject);
var
  VideoInfo: TVideoInfo;
begin
  if not FODVideo.Execute then
    exit;
  try
    VideoInfo := GetVideoInfo(FODVideo.fileName);
  except
    ShowMessage('Video format of ' + ExtractFilename(FODVideo.fileName) +
      ' is not supported');
    exit;
  end;
  VideoClipFile.Caption := FODVideo.fileName;
  DisplayVideoInfo(
    Memo1,
    VideoInfo);
  if GetFrameBitmap(FODVideo.fileName, fFramebm, FrameBox.Height, FrameNo.Value)
  then
  begin
    FrameBox.Width := fFramebm.Width;
    FrameBox.Invalidate;
  end;
end;

procedure TDemoWMFMain.PictureBoxPaint(Sender: TObject);
begin
  BitBlt(
    PictureBox.Canvas.Handle,
    0,
    0,
    fPicturebm.Width,
    fPicturebm.Height,
    fPicturebm.Canvas.Handle,
    0,
    0,
    SRCCopy);
end;

procedure TDemoWMFMain.DisplayVideoInfo(
  const aMemo:     TMemo;
  const VideoInfo: TVideoInfo);
begin
  aMemo.Clear;
  aMemo.Lines.add('Codec name: ' + VideoInfo.CodecName);
  aMemo.Lines.add('Video size: ' + VideoInfo.VideoWidth.ToString + 'x' +
    VideoInfo.VideoHeight.ToString);
  aMemo.Lines.add('Video aspect: ' + VideoInfo.VideoAspectString);
  aMemo.Lines.add('Frame rate: ' + FloatToStrF(VideoInfo.FrameRate, ffFixed, 4,
    2) + ' fps');
  aMemo.Lines.add('Duration: ' + VideoInfo.DurationString);
  aMemo.Lines.add('Pixel aspect: ' + FloatToStrF(VideoInfo.PixelAspect,
    ffFixed, 5, 4));
  aMemo.Lines.add('Interlace mode: ' + VideoInfo.InterlaceModeName + ' (' +
    VideoInfo.InterlaceMode.ToString + ')');
  aMemo.Lines.add('Audio streams: ' + VideoInfo.AudioStreamCount.ToString);
end;

procedure TDemoWMFMain.PreviewBoxPaint(Sender: TObject);
begin
  PreviewBox.Canvas.brush.color := $009BFFFF;
  PreviewBox.Canvas.Fillrect(PreviewBox.ClientRect);
end;

{ TListBox }

procedure TListBox.CNCommand(var AMessage: TWMCommand);
begin
  inherited;
  if (AMessage.NotifyCode = LBN_SELCHANGE) then
  begin
    if assigned(fOnSelChange) then
      fOnSelChange(Self);
  end;
end;

initialization

ReportMemoryLeaksOnShutDown := true;

CoInitializeEx(
  nil,
  COINIT_APARTMENTTHREADED);

if FAILED(MFStartup(MF_VERSION, MFSTARTUP_FULL)) then
begin
  MessageBox(
    0,
    lpcwstr('Your computer does not support this Media Foundation API version '
    + IntToStr(MF_VERSION) + '.'),
    lpcwstr('MFStartup Failure!'),
    MB_ICONSTOP);
end;

finalization

MFShutdown();
CoUnInitialize();

end.
