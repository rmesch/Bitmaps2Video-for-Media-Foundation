object DemoWMFMain: TDemoWMFMain
  Left = 0
  Top = 0
  Caption = 'DemoWMFMain'
  ClientHeight = 561
  ClientWidth = 899
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI Semibold'
  Font.Style = []
  Position = poDesktopCenter
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  TextHeight = 15
  object Splitter1: TSplitter
    Left = 225
    Top = 0
    Height = 561
    ExplicitLeft = 200
    ExplicitTop = 200
    ExplicitHeight = 100
  end
  object SettingsPanel: TPanel
    Left = 0
    Top = 0
    Width = 225
    Height = 561
    Align = alLeft
    TabOrder = 0
    DesignSize = (
      225
      561)
    object Label2: TLabel
      Left = 8
      Top = 6
      Width = 103
      Height = 15
      Caption = 'Choose file format: '
    end
    object Label3: TLabel
      Left = 8
      Top = 56
      Width = 103
      Height = 15
      Caption = 'Supported Codecs: '
    end
    object Label4: TLabel
      Left = 8
      Top = 191
      Width = 105
      Height = 15
      Caption = 'Choose height in p: '
    end
    object CodecInfo: TLabel
      Left = 8
      Top = 106
      Width = 211
      Height = 79
      Anchors = [akLeft, akTop, akRight]
      AutoSize = False
      Caption = 'CodecInfo'
      WordWrap = True
      ExplicitWidth = 227
    end
    object ShowWidth: TLabel
      Left = 8
      Top = 241
      Width = 63
      Height = 15
      Caption = 'ShowWidth'
    end
    object Label5: TLabel
      Left = 8
      Top = 308
      Width = 188
      Height = 15
      Caption = 'Set the encoding quality (10 to 100)'
    end
    object Label6: TLabel
      Left = 8
      Top = 383
      Width = 138
      Height = 15
      Caption = 'Choose a frame rate [fps]: '
    end
    object OutputInfo: TLabel
      Left = 3
      Top = 425
      Width = 219
      Height = 57
      Alignment = taCenter
      Anchors = [akLeft, akTop, akRight]
      AutoSize = False
      Caption = 'Output info'
      Layout = tlCenter
      WordWrap = True
      ExplicitWidth = 235
    end
    object Label8: TLabel
      Left = 80
      Top = 32
      Width = 107
      Height = 15
      Caption = 'Only .mp4 presently'
    end
    object Label13: TLabel
      Left = 32
      Top = 356
      Width = 122
      Height = 15
      Caption = '(recommended: >=60)'
    end
    object FileExt: TComboBox
      Left = 8
      Top = 27
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
      Top = 77
      Width = 171
      Height = 23
      Style = csDropDownList
      TabOrder = 1
      OnChange = CodecsChange
    end
    object Heights: TComboBox
      Left = 8
      Top = 212
      Width = 145
      Height = 23
      Style = csDropDownList
      ItemIndex = 3
      TabOrder = 2
      Text = '720'
      OnChange = HeightsChange
      Items.Strings = (
        '360'
        '480'
        '540'
        '720'
        '1080'
        '1440'
        '2160')
    end
    object AspectRatio: TRadioGroup
      Left = 0
      Top = 262
      Width = 185
      Height = 40
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
      Top = 329
      Width = 145
      Height = 24
      Increment = 2
      MaxValue = 100
      MinValue = 10
      TabOrder = 4
      Value = 70
    end
    object FrameRates: TComboBox
      Left = 8
      Top = 404
      Width = 145
      Height = 23
      Style = csDropDownList
      ItemIndex = 2
      TabOrder = 5
      Text = '30'
      Items.Strings = (
        '25'
        '29.97'
        '30'
        '45'
        '60'
        '90'
        '120')
    end
    object ShowVideo: TButton
      Left = 8
      Top = 488
      Width = 138
      Height = 25
      Caption = 'Play output video'
      TabOrder = 6
      OnClick = ShowVideoClick
    end
  end
  object PagesPanel: TPanel
    Left = 228
    Top = 0
    Width = 671
    Height = 561
    Align = alClient
    TabOrder = 1
    object StatusPanel: TPanel
      Left = 1
      Top = 536
      Width = 669
      Height = 24
      Align = alBottom
      TabOrder = 0
      object Status: TLabel
        Left = 1
        Top = 1
        Width = 667
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
      Width = 669
      Height = 535
      ActivePage = TabSheet1
      Align = alClient
      MultiLine = True
      TabOrder = 1
      OnChange = PageControl1Change
      object TabSheet1: TTabSheet
        Caption = 'Animate a Canvas-Drawing'
        object Preview: TPaintBox
          Left = 144
          Top = 168
          Width = 265
          Height = 209
          OnPaint = PreviewPaint
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
          Top = 0
          Width = 661
          Height = 44
          Align = alTop
          Alignment = taCenter
          AutoSize = False
          Caption = 
            'Demo of the method TBitmapEncoderWMF.AddFrame. A sequence of dra' +
            'wings to the canvas of a TBitmap is encoded to video. Spends mos' +
            't of its time drawing to canvas.'
          Layout = tlCenter
          WordWrap = True
          ExplicitWidth = 559
        end
        object WriteAnimation: TButton
          Left = 43
          Top = 352
          Width = 75
          Height = 25
          Caption = 'Write Video'
          TabOrder = 0
          OnClick = WriteAnimationClick
        end
      end
      object TabSheet2: TTabSheet
        Caption = 'Slideshow with Crossfade-Transitions'
        ImageIndex = 1
        object Splitter2: TSplitter
          Left = 313
          Top = 0
          Height = 485
          ExplicitLeft = 320
          ExplicitTop = 168
          ExplicitHeight = 100
        end
        object Panel1: TPanel
          Left = 0
          Top = 0
          Width = 313
          Height = 485
          Align = alLeft
          TabOrder = 0
          object Splitter3: TSplitter
            Left = 1
            Top = 247
            Width = 311
            Height = 3
            Cursor = crVSplit
            Align = alBottom
            ExplicitLeft = 0
            ExplicitTop = 242
          end
          object Panel2: TPanel
            Left = 1
            Top = 1
            Width = 311
            Height = 25
            Align = alTop
            TabOrder = 0
            object Button2: TButton
              Left = 0
              Top = 0
              Width = 121
              Height = 25
              Caption = 'Change Root Folder'
              TabOrder = 0
              OnClick = Button2Click
            end
          end
          object Panel3: TPanel
            Left = 1
            Top = 26
            Width = 311
            Height = 221
            Align = alClient
            TabOrder = 1
          end
          object Panel6: TPanel
            Left = 1
            Top = 250
            Width = 311
            Height = 234
            Align = alBottom
            Caption = 'Panel6'
            TabOrder = 2
            object FileBox: TListBox
              Left = 1
              Top = 1
              Width = 309
              Height = 232
              Align = alClient
              ItemHeight = 15
              MultiSelect = True
              TabOrder = 0
            end
          end
        end
        object Panel4: TPanel
          Left = 316
          Top = 0
          Width = 345
          Height = 485
          Align = alClient
          TabOrder = 1
          DesignSize = (
            345
            485)
          object ImageCount: TLabel
            Left = 1
            Top = 1
            Width = 343
            Height = 15
            Align = alTop
            Alignment = taCenter
            Caption = 'ImageCount'
            Layout = tlCenter
            ExplicitWidth = 66
          end
          object Panel5: TPanel
            Left = 1
            Top = 48
            Width = 343
            Height = 400
            Anchors = [akLeft, akTop, akRight]
            TabOrder = 0
            object Label7: TLabel
              Left = 15
              Top = 237
              Width = 102
              Height = 15
              Caption = 'Audio sample rate: '
            end
            object Label10: TLabel
              Left = 16
              Top = 287
              Width = 118
              Height = 15
              Caption = 'Audio bitrate [kb/sec]:'
            end
            object Label11: TLabel
              Left = 5
              Top = 337
              Width = 276
              Height = 54
              Alignment = taCenter
              AutoSize = False
              Caption = 
                'Changing the sample rate from the one of the input-file might no' +
                't be supported prior to Windows10.'
              Layout = tlCenter
              WordWrap = True
            end
            object Label12: TLabel
              Left = 176
              Top = 237
              Width = 90
              Height = 15
              Caption = 'Audio Start [ms] '
            end
            object WriteSlideshow: TButton
              Left = 24
              Top = 6
              Width = 225
              Height = 59
              Caption = 'Make a slideshow from all selected images in the current folder'
              TabOrder = 0
              WordWrap = True
              OnClick = WriteSlideshowClick
            end
            object Background: TCheckBox
              Left = 24
              Top = 104
              Width = 177
              Height = 33
              Caption = 'Run in background thread'
              TabOrder = 1
              WordWrap = True
            end
            object CropLandscape: TCheckBox
              Left = 24
              Top = 133
              Width = 217
              Height = 17
              Caption = 'Crop landscape images to video size'
              TabOrder = 2
            end
            object ZoomInOut: TCheckBox
              Left = 24
              Top = 156
              Width = 209
              Height = 34
              Caption = 'Include ZoomInOut-transitions (slows it down)'
              TabOrder = 3
              WordWrap = True
            end
            object DebugTiming: TCheckBox
              Left = 24
              Top = 196
              Width = 241
              Height = 29
              Caption = 'Debug Timing (Displays encoded timestamp in seconds)'
              TabOrder = 4
              WordWrap = True
            end
            object SampleRate: TComboBox
              Left = 16
              Top = 258
              Width = 145
              Height = 23
              Style = csDropDownList
              ItemIndex = 1
              TabOrder = 5
              Text = '48000'
              Items.Strings = (
                '44100'
                '48000')
            end
            object Bitrate: TComboBox
              Left = 16
              Top = 308
              Width = 145
              Height = 23
              Style = csDropDownList
              ItemIndex = 3
              TabOrder = 6
              Text = '192'
              Items.Strings = (
                '96'
                '128'
                '160'
                '192')
            end
            object AudioStartTime: TSpinEdit
              Left = 176
              Top = 258
              Width = 104
              Height = 24
              Increment = 1000
              MaxValue = 0
              MinValue = 0
              TabOrder = 7
              Value = 0
            end
            object AddAudio: TCheckBox
              Left = 24
              Top = 88
              Width = 225
              Height = 17
              Caption = 'Display dialog to add an audio file'
              TabOrder = 8
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
          Width = 77
          Height = 15
          Caption = 'StartImageFile'
        end
        object EndImageFile: TLabel
          Left = 152
          Top = 68
          Width = 72
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
          Top = 399
          Width = 655
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
          ExplicitWidth = 656
        end
        object Label15: TLabel
          Left = 8
          Top = 235
          Width = 106
          Height = 15
          Caption = 'Info for input video:'
        end
        object FrameBox: TPaintBox
          Left = 296
          Top = 267
          Width = 266
          Height = 126
          OnPaint = FrameBoxPaint
        end
        object Label16: TLabel
          Left = 8
          Top = 253
          Width = 172
          Height = 15
          Caption = '(see uTransformer.GetVideoInfo)'
        end
        object Label17: TLabel
          Left = 296
          Top = 235
          Width = 95
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
          Left = 8
          Top = 196
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
          Left = 8
          Top = 267
          Width = 273
          Height = 126
          Lines.Strings = (
            'Memo1')
          TabOrder = 5
        end
        object FrameNo: TSpinEdit
          Left = 568
          Top = 326
          Width = 64
          Height = 24
          Increment = 10
          MaxValue = 10000
          MinValue = 1
          TabOrder = 6
          Value = 1
          OnChange = FrameNoChange
        end
      end
      object TabSheet4: TTabSheet
        Caption = 'Use TBitmapEncoderWMF as a transcoder'
        ImageIndex = 3
        object TranscoderInput: TLabel
          Left = 136
          Top = 36
          Width = 87
          Height = 15
          Caption = 'TranscoderInput'
        end
        object Label19: TLabel
          Left = 24
          Top = 328
          Width = 617
          Height = 89
          AutoSize = False
          Caption = 
            'Transcode the video-stream and the 1st audio-stream of the input' +
            '-video to output using the encoder-settings to the left.  Note t' +
            'hat the number of audio-streams reported in the input-box is usu' +
            'ally wrong for .vob. I see no way to get it right at the moment,' +
            ' ideas welcome.   For .mkv with multiple audio-streams the info ' +
            'is right. '
          Layout = tlCenter
          WordWrap = True
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
        object Button3: TButton
          Left = 16
          Top = 72
          Width = 105
          Height = 25
          Caption = 'Transcode'
          TabOrder = 1
          OnClick = Button3Click
        end
        object CheckBox1: TCheckBox
          Left = 136
          Top = 76
          Width = 97
          Height = 17
          Caption = 'Crop to aspect'
          TabOrder = 2
        end
        object Memo2: TMemo
          Left = 16
          Top = 145
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
    Left = 210
    Top = 205
  end
  object OD: TFileOpenDialog
    FavoriteLinks = <>
    FileTypes = <>
    Options = [fdoPickFolders, fdoPathMustExist]
    Left = 210
    Top = 261
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
    Left = 209
    Top = 315
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
    Left = 209
    Top = 371
  end
  object ImageList1: TImageList
    Left = 209
    Top = 431
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
end
