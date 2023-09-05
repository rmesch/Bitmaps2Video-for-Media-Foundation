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
  uTransformer;

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
    Panel1: TPanel;
    Panel2: TPanel;
    Panel3: TPanel;
    Status: TLabel;
    Splitter1: TSplitter;
    FileExt: TComboBox;
    Codecs: TComboBox;
    Splitter2: TSplitter;
    Panel4: TPanel;
    Panel5: TPanel;
    WriteSlideshow: TButton;
    Background: TCheckBox;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Heights: TComboBox;
    ImageCount: TLabel;
    Preview: TPaintBox;
    AspectRatio: TRadioGroup;
    CodecInfo: TLabel;
    ShowWidth: TLabel;
    Label1: TLabel;
    SetQuality: TSpinEdit;
    Label5: TLabel;
    Label6: TLabel;
    FrameRates: TComboBox;
    CropLandscape: TCheckBox;
    OutputInfo: TLabel;
    ShowVideo: TButton;
    ZoomInOut: TCheckBox;
    Label9: TLabel;
    FODAudio: TFileOpenDialog;
    Button2: TButton;
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
    Panel6: TPanel;
    FileBox: TListBox;
    Splitter3: TSplitter;
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
    Label13: TLabel;
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
    Button3: TButton;
    CheckBox1: TCheckBox;
    Memo2: TMemo;
    Label19: TLabel;
    Button4: TButton;
    ImageList1: TImageList;

    // Important procedure showing the use of TBitmapEncoderWMF
    procedure WriteAnimationClick(Sender: TObject);

    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure WriteSlideshowClick(Sender: TObject);
    procedure FileExtChange(Sender: TObject);
    procedure CodecsChange(Sender: TObject);
    procedure HeightsChange(Sender: TObject);
    procedure PreviewPaint(Sender: TObject);
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
    procedure Button3Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
  private
    fDirectoryTree: TDirectoryTree;
    fFileList: TStringlist;
    fOutputFile: string;
    fCodecList: TCodecIdArray;
    fWriting: boolean;
    fFramebm: TBitmap;
    fUserAbort: boolean;
    function GetOutputFileName: string;
    procedure DoUpdate(var msg: TMessage); message MsgUpdate;
    procedure DirectoryTreeChange(Sender: TObject; node: TTreeNode);
    function GetAspect: double;
    function GetVideoWidth: integer;

    // Important procedure showing the use of TBitmapEncoderWMF
    procedure MakeSlideshow(const sl: TStringlist; const wic: TWicImage;
      const bm: TBitmap; const bme: TBitmapEncoderWMF; var Done: boolean;
      threaded: boolean);

    function GetFrameRate: single;
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
    procedure TransCodeProgress(Sender: TObject; FrameCount: Cardinal;
      VideoTime: int64; var DoAbort: boolean);
    procedure DisplayVideoInfo(const aMemo: TMemo; const VideoInfo: TVideoInfo);
    { Private-Deklarationen }
  public
    // properties which read the input parameters for the bitmap-encoder
    // off the controls of the form
    property OutputFileName: string read GetOutputFileName;
    property Aspect: double read GetAspect;
    property VideoHeight: integer read GetVideoHeight;
    property VideoWidth: integer read GetVideoWidth;
    property FrameRate: single read GetFrameRate;
    property Quality: integer read GetQuality;
    property DoCrop: boolean read GetDoCrop;
    property DoZoomInOut: boolean read GetDoZoomInOut;
    property AudioFile: string read GetAudioFile;
    property AudioSampleRate: integer read GetAudioSampleRate;
    property AudioBitRate: integer read GetAudioBitRate;
    property AudioStart: int64 read GetAudioStart;
    property AudioDialog: boolean read GetAudioDialog;
    { Public-Deklarationen }
  end;

var
  DemoWMFMain: TDemoWMFMain;

implementation

{$R *.dfm}

function PIDLToPath(IdList: PItemIDList): string;
begin
  SetLength(Result, MAX_PATH);
  if SHGetPathFromIdList(IdList, PChar(Result)) then
    SetLength(Result, StrLen(PChar(Result)))
  else
    Result := '';
end;

function PidlFree(var IdList: PItemIDList): boolean;
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

procedure TDemoWMFMain.WriteAnimationClick(Sender: TObject);
var
  i, j, w, h: integer;
  A, r, theta, dtheta: double;
  xCenter, yCenter: integer;
  scale: double;
  bm, pre: TBitmap;
  points: array of TPoint;
  jmax: integer;
  bme: TBitmapEncoderWMF;
  StopWatch: TStopWatch;

  function dist(o: double): double; inline;
  begin
    Result := 2 - 0.2 * o;
  end;

// map from world ([-2,2]x[-2,2]) to bitmap
  function map(p: TPointF): TPoint;
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
    Preview.Width := round(Aspect * Preview.Height);
    StopWatch := TStopWatch.Create;
    bme := TBitmapEncoderWMF.Create;
    try
      // Initialize the bitmap-encoder
      bme.Initialize(OutputFileName, w, h, Quality, FrameRate,
        fCodecList[Codecs.ItemIndex], cfBicubic);
      bm := TBitmap.Create;
      try
        // AntiAlias 2*Video-Height
        bm.SetSize(2 * w, 2 * h);
        xCenter := bm.Width div 2;
        yCenter := bm.Height div 2;
        scale := bm.Height / 4;

        bm.Canvas.brush.color := clMaroon;
        bm.Canvas.pen.color := clYellow;
        bm.Canvas.pen.Width := Max(h div 180, 2);

        dtheta := 2 / 150 * pi;
        StopWatch.Start;
        // Draw a sequence of spirals
        for i := 0 to 200 do
        begin
          A := 1 - 1 / 210 * i;
          jmax := trunc(10 / A / dtheta);
          SetLength(points, jmax);
          theta := 0;
          for j := 0 to jmax - 1 do
          begin
            r := dist(A * theta);
            points[j] := map(Pointf(r * cos(theta), r * sin(theta)));
            theta := theta + dtheta;
          end;
          bm.Canvas.Fillrect(bm.Canvas.clipRect);
          bm.Canvas.PolyLine(points);

          bme.AddFrame(bm, false);

          Status.Caption := 'Frame ' + (i + 1).ToString;
          Status.Repaint;
          if i mod 10 = 1 then
          begin
            pre := TBitmap.Create;
            try
              uScaleWMF.Resample(Preview.Width, Preview.Height, bm, pre,
                cfBilinear, 0, true, amIgnore);
              BitBlt(Preview.Canvas.Handle, 0, 0, pre.Width, pre.Height,
                pre.Canvas.Handle, 0, 0, SRCCopy);
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

function GetRandomZoom: TZoom; inline;
begin
  Result.xCenter := 0.5 + (random - 0.5) * 0.7;
  Result.yCenter := 0.5 + (random - 0.5) * 0.7;
  Result.Radius := min(1 - Result.xCenter, Result.xCenter);
  Result.Radius := min(Result.Radius, 1 - Result.yCenter);
  Result.Radius := min(Result.Radius, Result.yCenter);
  Assert(Result.Radius > 0);
  Result.Radius := 0.5 * Result.Radius;
end;

procedure TDemoWMFMain.MakeSlideshow(const sl: TStringlist;
  const wic: TWicImage; const bm: TBitmap; const bme: TBitmapEncoderWMF;
  var Done: boolean; threaded: boolean);
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
  WicToBmp(wic, bm);
  crop := (bm.Width > bm.Height) and DoCrop;
  bme.AddStillImage(bm, 4000, crop);
  PostMessage(Handle, MsgUpdate, 0, 0);
  if not threaded then
    Application.ProcessMessages;
  for i := 1 to sl.Count - 1 do
  begin
    wic.LoadFromFile(sl.Strings[i]);
    WicToBmp(wic, bm);
    crop := (bm.Width > bm.Height) and DoCrop;
    dice := random;
    DoInOut := DoZoomInOut and (dice < 1 / 3);
    if not DoInOut then

      bme.CrossFadeTo(bm, 2000, crop)

    else
    begin
      Zooms := GetRandomZoom;
      Zoom := GetRandomZoom;

      bme.ZoomInOutTransitionTo(bm, Zooms, Zoom, 2500, crop);

    end;

    bme.AddStillImage(bm, 4000, crop);
    PostMessage(Handle, MsgUpdate, i, 0);
    if not threaded then
      Application.ProcessMessages;
  end;
  Done := true;
end;

procedure TDemoWMFMain.ShowVideoClick(Sender: TObject);
begin
  if not fWriting then
    if FileExists(OutputFileName) then
      ShellExecute(Handle, 'open', PWideChar(OutputFileName), nil, nil,
        SW_SHOWNORMAL);
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
begin
  if fWriting then
  begin
    ShowMessage('Encoding in progress, wait until finished.');
    exit;
  end;
  af := '';
  if AudioDialog then
    af := AudioFile;
  fWriting := true;
  // Use a local stringlist because of threading
  sl := TStringlist.Create;
  try
    for i := 0 to fFileList.Count - 1 do
      if FileBox.Selected[i] then
        sl.Add(fFileList.Strings[i]);
    if sl.Count = 0 then
    begin
      ShowMessage('No image files selected');
      exit;
    end;
    bme := TBitmapEncoderWMF.Create;
    bm := TBitmap.Create;
    wic := TWicImage.Create;
    StopWatch := TStopWatch.Create;
    try
      Status.Caption := 'Working';
      StopWatch.Start;
      // bms.PixelFormat := pf32bit;
      // bms.SetSize(VideoWidth, VideoHeight);
      // BitBlt(bms.Canvas.Handle, 0, 0, VideoWidth, VideoHeight, 0, 0, 0,
      // BLACKNESS);
      try
        bme.Initialize(OutputFileName, VideoWidth, VideoHeight, Quality,
          FrameRate, fCodecList[Codecs.ItemIndex], cfBicubic, af, AudioBitRate,
          AudioSampleRate, AudioStart);
      except
        on eAudioFormatException do
        begin
          ShowMessage
            ('The format of the input file or the settings of bitrate or sample rate are not supported. Try again with different settings.');
          exit;
        end
        else
          raise;
      end;
      bme.TimingDebug := DebugTiming.Checked;
      if Background.Checked then
      begin
        Done := false;
        task := TTask.Run(
          procedure
          begin
            MakeSlideshow(sl, wic, bm, bme, Done, true);
          end);
        while not Done do
        begin
          Application.ProcessMessages;
          sleep(100);
        end;
        task.Wait();
        Application.ProcessMessages;
      end
      else
      begin
        MakeSlideshow(sl, wic, bm, bme, Done, false);
      end;
      StopWatch.Stop;
      bme.Finalize;
      Status.Caption :=
        'Writing speed including decoding of image files and computing transitions: '
        + FloatToStrF(1000 * bme.FrameCount / StopWatch.ElapsedMilliseconds,
        ffFixed, 5, 2) + ' fps';
      Status.Repaint;
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
begin
  if fWriting then
  begin
    ShowMessage('Encoding in progress, wait until finished.');
    exit;
  end;
  fWriting := true;
  try
    if not FileExists(AudioFileName.Caption) then
      af := ''
    else
      af := AudioFileName.Caption;
    proceed := FileExists(StartImageFile.Caption) and
      FileExists(EndImageFile.Caption) and FileExists(VideoClipFile.Caption);
    proceed := proceed and (VideoClipFile.Caption <> OutputFileName);
    if not proceed then
    begin
      ShowMessage
        ('Pick valid files for the images and the video clip first. The output filename cannot be identical to the video clip name.');
      exit;
    end;
    StopWatch := TStopWatch.Create;
    bme := TBitmapEncoderWMF.Create;
    try
      StopWatch.Start;
      Status.Caption := 'Working';
      try
        bme.Initialize(OutputFileName, VideoWidth, VideoHeight, Quality,
          FrameRate, TCodecID(Codecs.ItemIndex), cfBicubic, af, 128,
          44100, 9000);
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
        WicToBmp(wic, bm);
        Status.Caption := 'Start Image';
        bme.AddStillImage(bm, 5000, false);
        Status.Caption := 'Video Clip';
        try
          bme.OnProgress := TransCodeProgress;
          bme.AddVideo(VideoClipFile.Caption, 4000);
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
        wic.LoadFromFile(EndImageFile.Caption);
        WicToBmp(wic, bm);
        bme.OnProgress := nil;
        Status.Caption := 'End Image';
        bme.CrossFadeTo(bm, 4000, false);
        bme.AddStillImage(bm, 5000, false);
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

procedure TDemoWMFMain.Button1Click(Sender: TObject);
var
  VideoInfo: TVideoInfo;
begin
  if not FODVideo.Execute then
    exit;
  TranscoderInput.Caption := FODVideo.FileName;
  try
    VideoInfo := GetVideoInfo(FODVideo.FileName);
  except
    ShowMessage('Format of input file not supported');
  end;
  DisplayVideoInfo(Memo2, VideoInfo);
end;

procedure TDemoWMFMain.Button2Click(Sender: TObject);
begin
  if not OD.Execute(self.Handle) then
    exit;
  fDirectoryTree.NewRootFolder(OD.FileName);
end;

procedure TDemoWMFMain.TransCodeProgress(Sender: TObject; FrameCount: Cardinal;
VideoTime: int64; var DoAbort: boolean);
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

procedure TDemoWMFMain.Button3Click(Sender: TObject);
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
    TranscodeVideoFile(TranscoderInput.Caption, OutputFileName,
      TCodecID(Codecs.ItemIndex), Quality, VideoWidth, VideoHeight, FrameRate,
      CheckBox1.Checked, TransCodeProgress);
    if fUserAbort then
      Status.Caption := 'Aborted'
    else
      Status.Caption := 'Done';
  finally
    fWriting := false;
    fUserAbort := false;
  end;
end;

procedure TDemoWMFMain.Button4Click(Sender: TObject);
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

procedure TDemoWMFMain.DirectoryTreeChange(Sender: TObject; node: TTreeNode);
var
  i: integer;
begin
  fDirectoryTree.GetAllFiles(fFileList, '*.bmp;*.jpg;*.png;*.gif');
  FileBox.Clear;
  for i := 0 to fFileList.Count - 1 do
  begin
    FileBox.Items.Add(ExtractFileName(fFileList.Strings[i]));
  end;
  FileBox.SelectAll;
  FileBoxSelChange(nil);
end;

procedure TDemoWMFMain.FileBoxSelChange(Sender: TObject);
begin
  ImageCount.Caption := FileBox.SelCount.ToString +
    ' images selected (bmp, jpg, png, gif)'
end;

procedure TDemoWMFMain.DoUpdate(var msg: TMessage);
begin
  Status.Caption := 'Image ' + (msg.WParam + 1).ToString;
  Status.Repaint;
end;

procedure TDemoWMFMain.FileExtChange(Sender: TObject);
var
  i: integer;
begin
  fCodecList := GetSupportedCodecs(FileExt.Items[FileExt.ItemIndex]);
  Codecs.Clear;
  for i := 0 to Length(fCodecList) - 1 do
    Codecs.Items.Add(CodecNames[fCodecList[i]]);
  Codecs.ItemIndex := 0;
  CodecsChange(nil);
end;

procedure TDemoWMFMain.FormCreate(Sender: TObject);
var
  i: integer;
begin
  fDirectoryTree := TDirectoryTree.Create(self);
  fDirectoryTree.Parent := Panel3;
  fDirectoryTree.Align := alClient;
  fDirectoryTree.Images := ImageList1;
  fDirectoryTree.HideSelection := false;
  fFileList := TStringlist.Create;
  fDirectoryTree.NewRootFolder(TPath.GetPicturesPath);
  fOutputFile := GetDesktopFolder + '\Example';
  fCodecList := GetSupportedCodecs('.mp4');
  for i := 0 to Length(fCodecList) - 1 do
    Codecs.Items.Add(CodecNames[fCodecList[i]]);
  Codecs.ItemIndex := 0;
  fDirectoryTree.OnChange := DirectoryTreeChange;
  HeightsChange(nil);
  CodecsChange(nil);
  FileBox.OnSelChange := FileBoxSelChange;
  fFramebm := TBitmap.Create;
  FrameBox.ControlStyle := FrameBox.ControlStyle + [csOpaque];
  Randomize;
end;

procedure TDemoWMFMain.FormDestroy(Sender: TObject);
begin
  fFileList.Free;
  fFramebm.Free;
end;

procedure TDemoWMFMain.FrameBoxPaint(Sender: TObject);
begin
  BitBlt(FrameBox.Canvas.Handle, 0, 0, fFramebm.Width, fFramebm.Height,
    fFramebm.Canvas.Handle, 0, 0, SRCCopy);
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
  Result := StrToInt(Bitrate.Text);
end;

function TDemoWMFMain.GetAudioDialog: boolean;
begin
  Result := AddAudio.Checked;
end;

function TDemoWMFMain.GetAudioFile: string;
begin
  Result := '';
  FODAudio.FileName := '';
  if not FODAudio.Execute(Handle) then
    exit;

  Result := FODAudio.FileName;
end;

function TDemoWMFMain.GetAudioSampleRate: integer;
begin
  Result := StrToInt(SampleRate.Text);
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
  FrameRateArray: array [0 .. 6] of single = (25, 29.97, 30, 45, 60, 90, 120);

function TDemoWMFMain.GetFrameRate: single;
begin
  Result := FrameRateArray[FrameRates.ItemIndex];
end;

function TDemoWMFMain.GetOutputFileName: string;
begin
  Result := fOutputFile + '_' + CodecShortNames[fCodecList[Codecs.ItemIndex]] +
    FileExt.Text;
end;

function TDemoWMFMain.GetQuality: integer;
begin
  Result := SetQuality.Value;
end;

function TDemoWMFMain.GetVideoHeight: integer;
begin
  Result := StrToInt(Heights.Text);
end;

function TDemoWMFMain.GetVideoWidth: integer;
begin
  Result := round(Aspect * VideoHeight);
end;

procedure TDemoWMFMain.HeightsChange(Sender: TObject);
begin
  ShowWidth.Caption := 'Width in p: ' + VideoWidth.ToString;
  Preview.Invalidate;
end;

procedure TDemoWMFMain.PageControl1Change(Sender: TObject);
begin
  if PageControl1.TabIndex = 1 then
    DirectoryTreeChange(fDirectoryTree, fDirectoryTree.Selected);
end;

procedure TDemoWMFMain.PickEndImageClick(Sender: TObject);
begin
  if not FODPic.Execute then
    exit;
  EndImageFile.Caption := FODPic.FileName;
end;

procedure TDemoWMFMain.PickStartImageClick(Sender: TObject);
begin
  if not FODPic.Execute then
    exit;
  StartImageFile.Caption := FODPic.FileName;
end;

procedure TDemoWMFMain.PickVideoClick(Sender: TObject);
var
  VideoInfo: TVideoInfo;
begin
  if not FODVideo.Execute then
    exit;
  try
    VideoInfo := GetVideoInfo(FODVideo.FileName);
  except
    ShowMessage('Video format of ' + ExtractFileName(FODVideo.FileName) +
      ' is not supported');
    exit;
  end;
  VideoClipFile.Caption := FODVideo.FileName;
  DisplayVideoInfo(Memo1, VideoInfo);
  if GetFrameBitmap(FODVideo.FileName, fFramebm, FrameBox.Height, FrameNo.Value)
  then
  begin
    FrameBox.Width := fFramebm.Width;
    FrameBox.Invalidate;
  end;
end;

procedure TDemoWMFMain.DisplayVideoInfo(const aMemo: TMemo;
const VideoInfo: TVideoInfo);
begin
  aMemo.Clear;
  aMemo.Lines.Add('Codec name: ' + VideoInfo.CodecName);
  aMemo.Lines.Add('Video size: ' + VideoInfo.VideoWidth.ToString + 'x' +
    VideoInfo.VideoHeight.ToString);
  aMemo.Lines.Add('Frame rate: ' + FloatToStrF(VideoInfo.FrameRate, ffFixed, 4,
    2) + ' fps');
  aMemo.Lines.Add('Duration: ' + FloatToStrF(VideoInfo.Duration / 1000 / 10000,
    ffFixed, 5, 2) + ' sec');
  aMemo.Lines.Add('Pixel aspect: ' + FloatToStrF(VideoInfo.PixelAspect,
    ffFixed, 5, 4));
  aMemo.Lines.Add('Interlace mode: ' + VideoInfo.InterlaceModeName + ' (' +
    VideoInfo.InterlaceMode.ToString + ')');
  aMemo.Lines.Add('Audio streams: ' + VideoInfo.AudioStreamCount.ToString);
end;

procedure TDemoWMFMain.PreviewPaint(Sender: TObject);
begin
  Preview.Width := round(Preview.Height * Aspect);
  Preview.Canvas.brush.color := clMaroon;
  Preview.Canvas.Fillrect(Preview.ClientRect);
end;

{ TListBox }

procedure TListBox.CNCommand(var AMessage: TWMCommand);
begin
  inherited;
  if (AMessage.NotifyCode = LBN_SELCHANGE) then
  begin
    if assigned(fOnSelChange) then
      fOnSelChange(self);
  end;
end;

initialization

ReportMemoryLeaksOnShutDown := true;

end.
