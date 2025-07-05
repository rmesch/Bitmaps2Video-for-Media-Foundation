object DemoWMFMain: TDemoWMFMain
  Left = 0
  Top = 0
  Caption = 'DemoWMFMain'
  ClientHeight = 611
  ClientWidth = 1052
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  Position = poDesktopCenter
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  TextHeight = 15
  object Splitter1: TSplitter
    Left = 268
    Top = 0
    Height = 611
    ExplicitLeft = 251
    ExplicitHeight = 583
  end
  object SettingsPanel: TPanel
    Left = 0
    Top = 0
    Width = 268
    Height = 611
    Align = alLeft
    TabOrder = 0
    object Label2: TLabel
      Left = 8
      Top = 6
      Width = 104
      Height = 15
      Caption = 'Choose file format: '
    end
    object Label3: TLabel
      Left = 8
      Top = 51
      Width = 103
      Height = 15
      Caption = 'Supported Codecs: '
    end
    object Label4: TLabel
      Left = 8
      Top = 161
      Width = 106
      Height = 15
      Caption = 'Choose height in p: '
    end
    object Label5: TLabel
      Left = 8
      Top = 271
      Width = 186
      Height = 15
      Caption = 'Set the encoding quality (10 to 100)'
    end
    object Label6: TLabel
      Left = 8
      Top = 315
      Width = 139
      Height = 15
      Caption = 'Choose a frame rate [fps]: '
    end
    object Label8: TLabel
      Left = 71
      Top = 27
      Width = 106
      Height = 15
      Caption = 'Only .mp4 presently'
    end
    object Label20: TLabel
      Left = 8
      Top = 359
      Width = 85
      Height = 15
      Caption = 'Encode-priority:'
    end
    object FileExt: TComboBox
      Left = 8
      Top = 24
      Width = 57
      Height = 23
      Style = csDropDownList
      ItemIndex = 0
      TabOrder = 0
      Text = '.mp4'
      OnChange = FileExtChange
      Items.Strings = (
        '.mp4')
    end
    object Codecs: TComboBox
      Left = 8
      Top = 68
      Width = 171
      Height = 23
      Style = csDropDownList
      TabOrder = 1
      OnChange = CodecsChange
    end
    object Heights: TComboBox
      Left = 8
      Top = 178
      Width = 171
      Height = 23
      Style = csDropDownList
      ItemIndex = 4
      TabOrder = 2
      Text = '720'
      OnChange = HeightsChange
      Items.Strings = (
        '360'
        '405'
        '480'
        '540'
        '720'
        '1080'
        '1440'
        '2160')
    end
    object AspectRatio: TRadioGroup
      Left = 8
      Top = 222
      Width = 254
      Height = 43
      Caption = 'Aspect Ratio:'
      Columns = 3
      ItemIndex = 0
      Items.Strings = (
        '16:9'
        '4:3'
        '3:2')
      TabOrder = 3
      OnClick = HeightsChange
    end
    object SetQuality: TSpinEdit
      Left = 8
      Top = 289
      Width = 171
      Height = 24
      MaxValue = 200
      MinValue = 10
      TabOrder = 4
      Value = 80
    end
    object FrameRates: TComboBox
      Left = 8
      Top = 330
      Width = 171
      Height = 23
      Style = csDropDownList
      ItemIndex = 2
      TabOrder = 5
      Text = '30'
      Items.Strings = (
        '25'
        '29.97'
        '30'
        '31.25 (good for 48000 audio)'
        '45'
        '46.875 (optimal for 48000 audio)'
        '60'
        '90'
        '120')
    end
    object EncodePrioritySpin: TSpinEdit
      Left = 8
      Top = 376
      Width = 171
      Height = 24
      MaxValue = 20
      MinValue = 0
      TabOrder = 6
      Value = 2
    end
    object OutputPanel: TPanel
      Left = 1
      Top = 416
      Width = 266
      Height = 194
      Align = alBottom
      TabOrder = 7
      object ShowVideo: TButton
        Left = 82
        Top = 156
        Width = 111
        Height = 27
        Caption = 'Play output video'
        TabOrder = 0
        WordWrap = True
        OnClick = ShowVideoClick
      end
      object AdvancedOptions: TButton
        Left = 26
        Top = 16
        Width = 199
        Height = 25
        Caption = 'Open advanced options'
        TabOrder = 1
        OnClick = AdvancedOptionsClick
      end
      object OutputInfo: TStaticText
        Left = 7
        Top = 58
        Width = 258
        Height = 83
        Alignment = taCenter
        AutoSize = False
        BorderStyle = sbsSingle
        Caption = 'OutputInfo'
        Color = clInfoBk
        ParentColor = False
        TabOrder = 2
        Transparent = False
        StyleElements = [seFont, seBorder]
      end
    end
    object StaticText1: TStaticText
      Left = 8
      Top = 398
      Width = 257
      Height = 19
      AutoSize = False
      BorderStyle = sbsSingle
      Caption = 'Decrease for speed, increase if video stutters.'
      Color = clInfoBk
      ParentColor = False
      TabOrder = 8
      Transparent = False
      StyleElements = [seFont, seBorder]
    end
    object ShowWidth: TStaticText
      Left = 8
      Top = 201
      Width = 258
      Height = 19
      AutoSize = False
      BorderStyle = sbsSingle
      Caption = 'ShowWidth'
      Color = clInfoBk
      ParentColor = False
      TabOrder = 9
      Transparent = False
      StyleElements = [seFont, seBorder]
    end
    object CodecInfo: TStaticText
      Left = 8
      Top = 94
      Width = 258
      Height = 65
      Alignment = taCenter
      AutoSize = False
      BorderStyle = sbsSingle
      Caption = 'CodecInfo'
      Color = clInfoBk
      ParentColor = False
      TabOrder = 10
      Transparent = False
      StyleElements = [seFont, seBorder]
    end
  end
  object PagesPanel: TPanel
    Left = 271
    Top = 0
    Width = 781
    Height = 611
    Align = alClient
    TabOrder = 1
    object StatusPanel: TPanel
      Left = 1
      Top = 586
      Width = 779
      Height = 24
      Align = alBottom
      TabOrder = 0
      object Status: TLabel
        Left = 1
        Top = 1
        Width = 777
        Height = 22
        Align = alClient
        Alignment = taCenter
        Caption = 'Status'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -13
        Font.Name = 'Segoe UI Semibold'
        Font.Style = []
        ParentFont = False
        Layout = tlCenter
        ExplicitWidth = 38
        ExplicitHeight = 17
      end
    end
    object PageControl1: TPageControl
      Left = 1
      Top = 1
      Width = 779
      Height = 585
      ActivePage = TabSheet1
      Align = alClient
      MultiLine = True
      TabOrder = 1
      OnChange = PageControl1Change
      object TabSheet1: TTabSheet
        Caption = 'Animate a Canvas-Drawing'
        object PreviewBox: TPaintBox
          Left = 144
          Top = 169
          Width = 265
          Height = 209
          OnPaint = PreviewBoxPaint
        end
        object Label1: TLabel
          Left = 144
          Top = 392
          Width = 41
          Height = 15
          Caption = 'Preview'
        end
        object Label9: TLabel
          Left = 0
          Top = 454
          Width = 771
          Height = 81
          Align = alBottom
          Alignment = taCenter
          AutoSize = False
          Caption = 
            'Demo of the method TBitmapEncoderWMF.AddFrame. A sequence of dra' +
            'wings to the canvas of a TBitmap is encoded to video. Spends mos' +
            't of its time drawing to canvas.'
          Layout = tlCenter
          WordWrap = True
        end
        object WriteAnimation: TButton
          Left = 39
          Top = 353
          Width = 75
          Height = 25
          Caption = 'Write Video'
          TabOrder = 0
          OnClick = WriteAnimationClick
        end
        object AdvancedPanel: TPanel
          Left = 420
          Top = 169
          Width = 227
          Height = 182
          Color = clWindow
          ParentBackground = False
          TabOrder = 1
          Visible = False
          DesignSize = (
            227
            182)
          object Label13: TLabel
            Left = 12
            Top = 136
            Width = 115
            Height = 15
            Hint = 'Values higher than processorcount div 2 have no effect.'
            Caption = 'Resizing threads limit:'
            ParentShowHint = False
            ShowHint = True
          end
          object Button3: TButton
            Left = 136
            Top = 157
            Width = 87
            Height = 20
            Anchors = [akLeft, akRight, akBottom]
            Caption = 'Close'
            TabOrder = 0
            OnClick = Button3Click
          end
          object DisableHardwareEncoding: TCheckBox
            Left = 12
            Top = 16
            Width = 175
            Height = 17
            Caption = 'Disable hardware encoding'
            TabOrder = 1
          end
          object DisableThrottling: TCheckBox
            Left = 12
            Top = 39
            Width = 163
            Height = 17
            Caption = 'Disable throttling'
            TabOrder = 2
          end
          object DisableQualityBasedEncoding: TCheckBox
            Left = 12
            Top = 64
            Width = 195
            Height = 17
            Caption = 'Disable quality based encoding'
            TabOrder = 3
          end
          object ForceEncodingLevel: TCheckBox
            Left = 12
            Top = 87
            Width = 181
            Height = 17
            Caption = 'Force higher encoding level'
            TabOrder = 4
          end
          object ThreadlimitSpin: TSpinEdit
            Left = 133
            Top = 130
            Width = 63
            Height = 24
            MaxValue = 16
            MinValue = 2
            TabOrder = 5
            Value = 4
          end
          object DisableGOPSize: TCheckBox
            Left = 12
            Top = 110
            Width = 205
            Height = 17
            Caption = 'Disable GOP-size and threads limit'
            TabOrder = 6
          end
        end
      end
      object TabSheet2: TTabSheet
        Caption = 'Slideshow with Crossfade-Transitions'
        ImageIndex = 1
        object Splitter2: TSplitter
          Left = 0
          Top = 271
          Width = 771
          Height = 3
          Cursor = crVSplit
          Align = alBottom
          ExplicitTop = 0
          ExplicitWidth = 248
        end
        object Panel4: TPanel
          Left = 0
          Top = 274
          Width = 771
          Height = 261
          Align = alBottom
          BevelOuter = bvNone
          TabOrder = 0
          DesignSize = (
            771
            261)
          object Panel5: TPanel
            Left = 0
            Top = 0
            Width = 771
            Height = 207
            Align = alTop
            BevelOuter = bvNone
            TabOrder = 0
            object Label7: TLabel
              Left = 390
              Top = 29
              Width = 102
              Height = 15
              Caption = 'Audio sample rate: '
            end
            object Label10: TLabel
              Left = 498
              Top = 28
              Width = 118
              Height = 15
              Caption = 'Audio bitrate [kb/sec]:'
            end
            object Label11: TLabel
              Left = 390
              Top = 75
              Width = 321
              Height = 44
              Alignment = taCenter
              AutoSize = False
              Caption = 
                'Changing the sample rate from the one of the input-file might no' +
                't be supported prior to Windows10.'
              Color = clInfoBk
              ParentColor = False
              Transparent = False
              Layout = tlCenter
              WordWrap = True
            end
            object Label12: TLabel
              Left = 621
              Top = 28
              Width = 89
              Height = 15
              Caption = 'Audio Start [ms] '
            end
            object Label27: TLabel
              Left = 5
              Top = 55
              Width = 304
              Height = 18
              Alignment = taCenter
              AutoSize = False
              Caption = 'Presentation time = Image time + Transition time'
              Color = clInfoBk
              ParentColor = False
              Transparent = False
            end
            object Label25: TLabel
              Left = 24
              Top = 4
              Width = 87
              Height = 15
              Caption = 'Image time [ms]'
            end
            object Label26: TLabel
              Left = 188
              Top = 4
              Width = 105
              Height = 15
              Caption = 'Transition time [ms]'
            end
            object Background: TCheckBox
              Left = 24
              Top = 168
              Width = 241
              Height = 34
              Caption = 'Run in background thread'
              TabOrder = 0
              WordWrap = True
            end
            object CropLandscape: TCheckBox
              Left = 24
              Top = 76
              Width = 241
              Height = 34
              Caption = 'Crop landscape images to video size'
              Checked = True
              State = cbChecked
              TabOrder = 1
            end
            object ZoomInOut: TCheckBox
              Left = 24
              Top = 102
              Width = 241
              Height = 34
              Caption = 'Include ZoomInOut-transitions'
              TabOrder = 2
              WordWrap = True
            end
            object DebugTiming: TCheckBox
              Left = 24
              Top = 134
              Width = 241
              Height = 34
              Caption = 'Debug Timing (Displays encoded timestamp in seconds)'
              TabOrder = 3
              WordWrap = True
            end
            object SampleRate: TComboBox
              Left = 389
              Top = 46
              Width = 103
              Height = 23
              Style = csDropDownList
              ItemIndex = 1
              TabOrder = 4
              Text = '48000'
              Items.Strings = (
                '44100'
                '48000')
            end
            object Bitrate: TComboBox
              Left = 507
              Top = 46
              Width = 100
              Height = 23
              Style = csDropDownList
              ItemIndex = 3
              TabOrder = 5
              Text = '192'
              Items.Strings = (
                '96'
                '128'
                '160'
                '192')
            end
            object AudioStartTime: TSpinEdit
              Left = 621
              Top = 45
              Width = 94
              Height = 24
              Increment = 1000
              MaxValue = 0
              MinValue = 0
              TabOrder = 6
              Value = 0
            end
            object AddAudio: TCheckBox
              Left = 390
              Top = 4
              Width = 241
              Height = 25
              Caption = 'Display dialog to add an audio file'
              TabOrder = 7
            end
            object TransitionTime: TSpinEdit
              Left = 188
              Top = 25
              Width = 121
              Height = 24
              Increment = 500
              MaxValue = 0
              MinValue = 0
              TabOrder = 8
              Value = 2000
            end
            object ImageTime: TSpinEdit
              Left = 24
              Top = 26
              Width = 121
              Height = 24
              Increment = 500
              MaxValue = 0
              MinValue = 0
              TabOrder = 9
              Value = 4000
            end
            object AdjustToAudio: TCheckBox
              Left = 394
              Top = 122
              Width = 249
              Height = 17
              Caption = 'Adjust presentation time to audio time'
              TabOrder = 10
            end
          end
          object Stats: TMemo
            Left = 394
            Top = 170
            Width = 337
            Height = 89
            Anchors = [akLeft, akBottom]
            Lines.Strings = (
              'Stats')
            ScrollBars = ssVertical
            TabOrder = 1
          end
          object WriteSlideshow: TButton
            Left = 24
            Top = 205
            Width = 269
            Height = 38
            Anchors = [akLeft, akBottom]
            Caption = 'Make a slideshow from all selected images in the current folder'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -12
            Font.Name = 'Segoe UI'
            Font.Style = [fsBold]
            ParentFont = False
            TabOrder = 2
            WordWrap = True
            OnClick = WriteSlideshowClick
          end
          object DroppedFramesCheck: TCheckBox
            Left = 394
            Top = 150
            Width = 295
            Height = 17
            Anchors = [akLeft, akBottom]
            Caption = 'Investigate output for dropped frames (slow)'
            TabOrder = 3
          end
        end
        object Panel1: TPanel
          Left = 0
          Top = 0
          Width = 771
          Height = 271
          Align = alClient
          BevelOuter = bvNone
          TabOrder = 1
          object Splitter3: TSplitter
            Left = 289
            Top = 0
            Height = 271
            ExplicitLeft = 328
            ExplicitTop = -10
            ExplicitHeight = 316
          end
          object Splitter4: TSplitter
            Left = 599
            Top = 0
            Height = 271
            ExplicitLeft = 672
            ExplicitTop = 142
            ExplicitHeight = 100
          end
          object Panel3: TPanel
            Left = 0
            Top = 0
            Width = 289
            Height = 271
            Align = alLeft
            Caption = 'Panel3'
            TabOrder = 0
            object Panel2: TPanel
              Left = 1
              Top = 1
              Width = 287
              Height = 25
              Align = alTop
              BevelOuter = bvNone
              TabOrder = 0
              object Label28: TLabel
                Left = 121
                Top = 0
                Width = 166
                Height = 25
                Align = alClient
                Alignment = taCenter
                AutoSize = False
                Caption = 'Choose a folder with images'
                Color = clInfoBk
                ParentColor = False
                Transparent = False
                Layout = tlCenter
                ExplicitLeft = 120
                ExplicitTop = 2
                ExplicitWidth = 154
              end
              object Button2: TButton
                Left = 0
                Top = 0
                Width = 121
                Height = 25
                Align = alLeft
                Caption = 'Change Root Folder'
                TabOrder = 0
                OnClick = Button2Click
              end
            end
            object PanelDirectory: TPanel
              Left = 1
              Top = 26
              Width = 287
              Height = 244
              Align = alClient
              BevelOuter = bvNone
              TabOrder = 1
            end
          end
          object Panel6: TPanel
            Left = 292
            Top = 0
            Width = 307
            Height = 271
            Align = alLeft
            Caption = 'Panel6'
            TabOrder = 1
            object Panel7: TPanel
              Left = 1
              Top = 1
              Width = 305
              Height = 25
              Align = alTop
              BevelOuter = bvNone
              Caption = 'Panel7'
              TabOrder = 0
              object ImageCount: TLabel
                Left = 0
                Top = 0
                Width = 305
                Height = 25
                Align = alClient
                Alignment = taCenter
                AutoSize = False
                Caption = 'ImageCount'
                Color = clInfoBk
                Font.Charset = DEFAULT_CHARSET
                Font.Color = clWindowText
                Font.Height = -12
                Font.Name = 'Segoe UI'
                Font.Style = [fsBold]
                ParentColor = False
                ParentFont = False
                Transparent = False
                Layout = tlCenter
                WordWrap = True
                ExplicitLeft = 1
                ExplicitTop = 2
              end
            end
            object FileBox: TListBox
              Left = 1
              Top = 26
              Width = 305
              Height = 244
              Align = alClient
              BevelInner = bvNone
              BevelOuter = bvNone
              ItemHeight = 15
              MultiSelect = True
              TabOrder = 1
            end
          end
          object PanelPreview: TPanel
            Left = 602
            Top = 0
            Width = 169
            Height = 271
            Align = alClient
            BevelOuter = bvNone
            TabOrder = 2
            OnResize = PanelPreviewResize
            object PictureBox: TPaintBox
              Left = 30
              Top = 80
              Width = 105
              Height = 105
              OnPaint = PictureBoxPaint
            end
          end
        end
      end
      object TabSheet3: TTabSheet
        Caption = 'Video from Images and a Video Clip'
        ImageIndex = 2
        object StartImageFile: TLabel
          Left = 152
          Top = 24
          Width = 75
          Height = 15
          Caption = 'StartImageFile'
        end
        object EndImageFile: TLabel
          Left = 152
          Top = 68
          Width = 71
          Height = 15
          Caption = 'EndImageFile'
        end
        object VideoClipFile: TLabel
          Left = 152
          Top = 113
          Width = 69
          Height = 15
          Caption = 'VideoClipFile'
        end
        object AudioFileName: TLabel
          Left = 152
          Top = 156
          Width = 82
          Height = 15
          Caption = 'AudioFileName'
        end
        object Label14: TLabel
          AlignWithMargins = True
          Left = 3
          Top = 449
          Width = 765
          Height = 83
          Align = alBottom
          Alignment = taCenter
          AutoSize = False
          Caption = 
            'Demo for inserting a video-clip into the series of bitmaps to be' +
            ' encoded. Only the video -stream will be inserted, the audio-fil' +
            'e plays while the video is shown.  If you pick the video again a' +
            's audio-file, the video-audio gets encoded. You can optionally m' +
            'ake a crossfade transition from the last bitmap-frame added to t' +
            'he first video-frame. See TBitmapEncoderWMF.AddVideo. As far as ' +
            'can be seen, any video which Windows Films & TV can play can be ' +
            'inserted. The decoder needs to be installed in Windows.'
          ShowAccelChar = False
          Layout = tlCenter
          WordWrap = True
          ExplicitTop = 423
          ExplicitWidth = 665
        end
        object Label15: TLabel
          Left = 8
          Top = 235
          Width = 105
          Height = 15
          Caption = 'Info for input video:'
        end
        object FrameBox: TPaintBox
          Left = 296
          Top = 267
          Width = 266
          Height = 134
          OnPaint = FrameBoxPaint
        end
        object Label16: TLabel
          Left = 8
          Top = 253
          Width = 170
          Height = 15
          Caption = '(see uTransformer.GetVideoInfo)'
        end
        object Label17: TLabel
          Left = 296
          Top = 235
          Width = 93
          Height = 15
          Caption = 'Video Thumbnail:'
        end
        object Label18: TLabel
          Left = 296
          Top = 253
          Width = 190
          Height = 15
          Caption = '(see uTransformer.GetFrameBitmap)'
        end
        object Label22: TLabel
          Left = 280
          Top = 192
          Width = 143
          Height = 15
          Caption = '(Partial video will be saved)'
        end
        object PickStartImage: TButton
          Left = 8
          Top = 21
          Width = 137
          Height = 25
          Caption = 'Pick start-image'
          TabOrder = 0
          OnClick = PickStartImageClick
        end
        object PickEndImage: TButton
          Left = 8
          Top = 64
          Width = 137
          Height = 25
          Caption = 'Pick end image'
          TabOrder = 1
          OnClick = PickEndImageClick
        end
        object PickVideo: TButton
          Left = 8
          Top = 109
          Width = 137
          Height = 25
          Caption = 'Pick video clip'
          TabOrder = 2
          OnClick = PickVideoClick
        end
        object CombineToVideo: TButton
          Left = 9
          Top = 188
          Width = 137
          Height = 25
          Caption = 'Combine to video'
          TabOrder = 3
          OnClick = CombineToVideoClick
        end
        object PickAudio: TButton
          Left = 8
          Top = 152
          Width = 137
          Height = 25
          Caption = 'Pick audio'
          TabOrder = 4
          OnClick = PickAudioClick
        end
        object Memo1: TMemo
          Left = 3
          Top = 267
          Width = 273
          Height = 134
          Lines.Strings = (
            'Memo1')
          TabOrder = 5
        end
        object FrameNo: TSpinEdit
          Left = 584
          Top = 309
          Width = 64
          Height = 24
          Increment = 10
          MaxValue = 10000
          MinValue = 1
          TabOrder = 6
          Value = 1
          OnChange = FrameNoChange
        end
        object Abort: TButton
          Left = 152
          Top = 190
          Width = 113
          Height = 24
          Caption = 'Abort'
          TabOrder = 7
          OnClick = AbortClick
        end
      end
      object TabSheet4: TTabSheet
        Caption = 'Use TBitmapEncoderWMF as a transcoder'
        ImageIndex = 3
        object TranscoderInput: TLabel
          Left = 136
          Top = 36
          Width = 85
          Height = 15
          Caption = 'TranscoderInput'
        end
        object Label19: TLabel
          Left = 25
          Top = 343
          Width = 617
          Height = 78
          AutoSize = False
          Caption = 
            'Transcode the video-stream and the 1st audio-stream of the input' +
            '-video to output using the encoder-settings to the left.  I use ' +
            'it to test audio-video synchronization. With an mpeg-decoder ins' +
            'talled, .vobs work in a limited way, but don'#39't seem to be genuin' +
            'ely supported by media foundation.'
          Layout = tlCenter
          WordWrap = True
        end
        object MovieBox: TPaintBox
          Left = 320
          Top = 182
          Width = 329
          Height = 161
        end
        object Label23: TLabel
          Left = 136
          Top = 120
          Width = 143
          Height = 15
          Caption = '(Partial video will be saved)'
        end
        object Button1: TButton
          Left = 16
          Top = 32
          Width = 105
          Height = 25
          Caption = 'Pick input video'
          TabOrder = 0
          OnClick = Button1Click
        end
        object Transcode: TButton
          Left = 16
          Top = 72
          Width = 105
          Height = 25
          Caption = 'Transcode'
          TabOrder = 1
          OnClick = TranscodeClick
        end
        object CropToAspect: TCheckBox
          Left = 136
          Top = 76
          Width = 97
          Height = 17
          Caption = 'Crop to aspect'
          TabOrder = 2
        end
        object Memo2: TMemo
          Left = 25
          Top = 182
          Width = 289
          Height = 161
          Lines.Strings = (
            'Memo2')
          TabOrder = 3
        end
        object Button4: TButton
          Left = 16
          Top = 114
          Width = 105
          Height = 25
          Caption = 'Abort'
          TabOrder = 4
          OnClick = Button4Click
        end
        object ShowPreview: TCheckBox
          Left = 360
          Top = 76
          Width = 97
          Height = 17
          Caption = 'Show preview'
          TabOrder = 5
        end
        object StretchToAspect: TCheckBox
          Left = 239
          Top = 76
          Width = 115
          Height = 17
          Caption = 'StretchToAspect'
          TabOrder = 6
        end
      end
      object TabSheet5: TTabSheet
        Caption = 'Analysis'
        ImageIndex = 4
        TabVisible = False
        DesignSize = (
          771
          535)
        object Label21: TLabel
          Left = 10
          Top = 16
          Width = 449
          Height = 33
          AutoSize = False
          Caption = 
            'To run this analysis the program ffprobe.exe needs to be in the ' +
            'output directory of DemoWMFMain.exe. The application can be down' +
            'loaded from'
          WordWrap = True
        end
        object Memo3: TMemo
          Left = 1
          Top = 114
          Width = 770
          Height = 419
          Anchors = [akLeft, akTop, akRight, akBottom]
          Lines.Strings = (
            'Memo3')
          ScrollBars = ssBoth
          TabOrder = 0
        end
        object Button5: TButton
          Left = 3
          Top = 74
          Width = 192
          Height = 25
          Caption = 'Run Frame Analysis on Output'
          TabOrder = 1
          OnClick = Button5Click
        end
        object Button6: TButton
          Left = 384
          Top = 74
          Width = 113
          Height = 25
          Caption = 'Save Analysis to File'
          TabOrder = 2
          OnClick = Button6Click
        end
        object Button7: TButton
          Left = 206
          Top = 74
          Width = 156
          Height = 25
          Caption = 'Run Frame Analysis on File'
          TabOrder = 3
          OnClick = Button7Click
        end
        object Edit1: TEdit
          Left = 465
          Top = 24
          Width = 270
          Height = 23
          Cursor = crHandPoint
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clNavy
          Font.Height = -12
          Font.Name = 'Segoe UI'
          Font.Style = [fsUnderline]
          ParentFont = False
          TabOrder = 4
          Text = 'https://www.gyan.dev/ffmpeg/builds/'
          OnClick = Edit1Click
        end
      end
    end
  end
  object FODAudio: TFileOpenDialog
    FavoriteLinks = <>
    FileName = 'D:\DelphiSource\DelphiRio\mystuffR\Bitmaps2Video\EncoderClassWin'
    FileTypes = <
      item
        DisplayName = 'Audio files (*.wav;*.mp3;*.aac;*.wma)'
        FileMask = '*.wav;*.mp3;*.aac;*.wma'
      end
      item
        DisplayName = 'Audio- and video-files'
        FileMask = '*.wav;*.mp3;*.aac;*.wma;*.avi;*.mp4;*.mpg;*.mkv;*.vob;*.wmv'
      end
      item
        DisplayName = 'Any'
        FileMask = '*.*'
      end>
    FileTypeIndex = 2
    Options = []
    Title = 'Choose an audio file.'
    Left = 204
    Top = 74
  end
  object OD: TFileOpenDialog
    FavoriteLinks = <>
    FileTypes = <>
    Options = [fdoPickFolders, fdoPathMustExist]
    Left = 200
    Top = 170
  end
  object FODPic: TFileOpenDialog
    FavoriteLinks = <>
    FileTypes = <
      item
        DisplayName = 'All supported'
        FileMask = '*.bmp;*.jpg;*.png;*.gif'
      end
      item
        DisplayName = 'All'
        FileMask = '*.*'
      end>
    Options = []
    Left = 354
    Top = 710
  end
  object FODVideo: TFileOpenDialog
    FavoriteLinks = <>
    FileName = 
      'D:\DelphiSource\DelphiRio\othstuffR\MfPack-Master\MfPack\Samples' +
      '\Simple Player'
    FileTypes = <
      item
        DisplayName = 'All supported'
        FileMask = '*.avi;*.mp4;*.mkv;*.mpg;*.wmv;*.vob'
      end
      item
        DisplayName = 'All'
        FileMask = '*.*'
      end>
    Options = []
    Left = 202
    Top = 122
  end
  object ImageList1: TImageList
    Left = 206
    Top = 26
    Bitmap = {
      494C010101000800040010001000FFFFFFFFFF10FFFFFFFFFFFFFFFF424D3600
      0000000000003600000028000000400000001000000001002000000000000010
      000000000000000000000000000000000000000000000000000046819A004681
      9A0046819A0046819A0046819A0046819A003B6F8800305E7700305E7700305E
      7700305E7700305E7700305E7700000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000046819A0072BEDB006FBA
      D7006FBAD7006FBAD7006FBAD70072BEDB0046819A004C9EC5004D9FC6004D9F
      C6004D9FC6004D9FC6004D9FC600305E77000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000048839B0071BEDA006FBA
      D6006FBAD6006FBAD6006FBAD60071BEDA0046819A0052A4CB0052A5CB0053A5
      CB0052A5CB0052A5CB00FF965400336079000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000004D859E0074C2DD0072BE
      D90072BED90072BED90072BED90074C2DD0046819A0057AAD00058ABD00058AB
      D00058ABD00058ABD000EAEAEA0039657E000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000538BA10077C6E00075C2
      DC0075C2DC0075C2DC0075C2DC0077C5E00046819A005EB0D5005EB1D5005FB1
      D5005EB1D5005EB1D500EAEAEA00406C83000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000005A8FA4007ACAE30078C6
      DF0078C6DF0078C6DF0078C6DF0079C9E3004A849C0064B6D90065B6DA0065B6
      DA0065B6DA0065B6DA00EAEAEA00497289000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000006294A8007CCEE6007BCA
      E2007BCAE2007BCAE2007BCAE2007CCEE60050889F0069B2D2006BBBDE006BBC
      DE006BBCDE006BBCDE006BBCDE00517A90000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000006A9BAD007FD2E9007ECE
      E5007ECEE5007ECEE5007ECEE5007FD0E7007BC4DA00558BA20071BEDF0071C1
      E20071C1E20071C0E200517A9000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000073A0B10082D6EC0081D2
      E80081D2E80081D2E80081D2E80081D2E80082D4EA0080CDE3005A8FA40078C6
      E70078C6E6007296A70000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000007CA6B50085D9EF0084D6
      EB0084D6EB0084D6EB0084D6EB0084D6EB0084D6EB0085DCF1006294A9007FCB
      EA007FCAEA007296A70000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000083ACBA0087DDF20087DA
      EE0087DAEE0087DAEE0087DAEE0087DAEE0087DAEE0087DEF2006A9AAD0087CF
      EE0086CFEE007C9EAE0000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000008BB2BE008AE1F5008ADE
      F1008ADEF1008ADEF1008ADEF1008ADEF1008ADEF1008AE2F50072A0B1008ED3
      F1008DD3F10086A6B60000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000091B6C1008CE5F8008CE2
      F4008CE2F4008CE2F4008CE2F4008CE2F4008CE2F4008CE6F8007BA6B50095D7
      F40095D7F4008EAEBC0000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000098BAC50090E9FB0090E6
      F70090E6F70090E6F70090E6F70090E6F70090E6F70090E9FB0084ACBA009BDB
      F6009BDBF60096B4C20000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000009CBDC60091F2FF0092EE
      FE0092EEFE0092EEFE0092EEFE0092EEFE0092EEFE0091F2FF008BB1BE00A2DF
      F900A1DFF9009EBBC70000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000000000009DBEC7009DBE
      C7009DBEC70099BCC50097BAC40097BAC30095B8C30094B7C2009BBBC600A3BF
      CB00A3BFCC000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000424D3E000000000000003E000000
      2800000040000000100000000100010000000000800000000000000000000000
      000000000000000000000000FFFFFF00C0010000000000008000000000000000
      8000000000000000800000000000000080000000000000008000000000000000
      8000000000000000800100000000000080030000000000008003000000000000
      8003000000000000800300000000000080030000000000008003000000000000
      8003000000000000C00700000000000000000000000000000000000000000000
      000000000000}
  end
  object FSDText: TFileSaveDialog
    DefaultExtension = '.txt'
    FavoriteLinks = <>
    FileTypes = <
      item
        DisplayName = 'Text'
        FileMask = '*.txt'
      end>
    Options = []
    Left = 794
    Top = 121
  end
end
