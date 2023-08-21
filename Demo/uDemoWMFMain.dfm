object DemoWMFMain: TDemoWMFMain
  Left = 0
  Top = 0
  Caption = 'DemoWMFMain'
  ClientHeight = 561
  ClientWidth = 900
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
    Width = 672
    Height = 561
    Align = alClient
    TabOrder = 1
    object StatusPanel: TPanel
      Left = 1
      Top = 536
      Width = 670
      Height = 24
      Align = alBottom
      TabOrder = 0
      object Status: TLabel
        Left = 1
        Top = 1
        Width = 668
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
      Width = 670
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
          Width = 662
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
          Width = 346
          Height = 485
          Align = alClient
          TabOrder = 1
          DesignSize = (
            346
            485)
          object ImageCount: TLabel
            Left = 1
            Top = 1
            Width = 344
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
            Width = 344
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
          Width = 656
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
          Width = 185
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
      end
    end
  end
  object ImageCollection1: TImageCollection
    Images = <
      item
        Name = 'folder_open_64_h'
        SourceImages = <
          item
            Image.Data = {
              89504E470D0A1A0A0000000D4948445200000040000000400806000000AA6971
              DE000000097048597300000B1300000B1301009A9C1800000A4F694343505068
              6F746F73686F70204943432070726F66696C65000078DA9D53675453E9163DF7
              DEF4424B8880944B6F5215082052428B801491262A2109104A8821A1D91551C1
              114545041BC8A088038E8E808C15512C0C8A0AD807E421A28E83A3888ACAFBE1
              7BA36BD6BCF7E6CDFEB5D73EE7ACF39DB3CF07C0080C9648335135800CA9421E
              11E083C7C4C6E1E42E40810A2470001008B3642173FD230100F87E3C3C2B22C0
              07BE000178D30B0800C04D9BC0301C87FF0FEA42995C01808401C07491384B08
              801400407A8E42A600404601809D98265300A0040060CB6362E300502D006027
              7FE6D300809DF8997B01005B94211501A09100201365884400683B00ACCF568A
              450058300014664BC43900D82D00304957664800B0B700C0CE100BB200080C00
              305188852900047B0060C8232378008499001446F2573CF12BAE10E72A000078
              99B23CB9243945815B082D710757572E1E28CE49172B14366102619A402EC279
              99193281340FE0F3CC0000A0911511E083F3FD78CE0EAECECE368EB60E5F2DEA
              BF06FF226262E3FEE5CFAB70400000E1747ED1FE2C2FB31A803B06806DFEA225
              EE04685E0BA075F78B66B20F40B500A0E9DA57F370F87E3C3C45A190B9D9D9E5
              E4E4D84AC4425B61CA577DFE67C25FC057FD6CF97E3CFCF7F5E0BEE22481325D
              814704F8E0C2CCF44CA51CCF92098462DCE68F47FCB70BFFFC1DD322C44962B9
              582A14E35112718E449A8CF332A52289429229C525D2FF64E2DF2CFB033EDF35
              00B06A3E017B912DA85D6303F64B27105874C0E2F70000F2BB6FC1D428080380
              6883E1CF77FFEF3FFD47A02500806649927100005E44242E54CAB33FC7080000
              44A0812AB0411BF4C1182CC0061CC105DCC10BFC6036844224C4C24210420A64
              801C726029AC82422886CDB01D2A602FD4401D34C051688693700E2EC255B80E
              3D700FFA61089EC128BC81090441C808136121DA8801628A58238E08179985F8
              21C14804128B2420C9881451224B91354831528A542055481DF23D720239875C
              46BA913BC8003282FC86BC47319481B2513DD40CB543B9A8371A8446A20BD064
              74319A8F16A09BD072B41A3D8C36A1E7D0AB680FDA8F3E43C730C0E8180733C4
              6C302EC6C342B1382C099363CBB122AC0CABC61AB056AC03BB89F563CFB17704
              128145C0093604774220611E4148584C584ED848A8201C243411DA0937090384
              51C2272293A84BB426BA11F9C4186232318758482C23D6128F132F107B8843C4
              37241289433227B9900249B1A454D212D246D26E5223E92CA99B34481A2393C9
              DA646BB20739942C202BC885E49DE4C3E433E41BE421F25B0A9D624071A4F853
              E22852CA6A4A19E510E534E5066598324155A39A52DDA8A15411358F5A42ADA1
              B652AF5187A81334759A39CD8316494BA5ADA295D31A681768F769AFE874BA11
              DD951E4E97D057D2CBE947E897E803F4770C0D861583C7886728199B18071867
              197718AF984CA619D38B19C754303731EB98E7990F996F55582AB62A7C1591CA
              0A954A9526951B2A2F54A9AAA6AADEAA0B55F355CB548FA95E537DAE46553353
              E3A909D496AB55AA9D50EB531B5367A93BA887AA67A86F543FA47E59FD890659
              C34CC34F43A451A0B15FE3BCC6200B6319B3782C216B0DAB86758135C426B1CD
              D97C762ABB98FD1DBB8B3DAAA9A13943334A3357B352F394663F07E39871F89C
              744E09E728A797F37E8ADE14EF29E2291BA6344CB931655C6BAA96979658AB48
              AB51AB47EBBD36AEEDA79DA6BD45BB59FB810E41C74A275C2747678FCE059DE7
              53D953DDA70AA7164D3D3AF5AE2EAA6BA51BA1BB4477BF6EA7EE989EBE5E809E
              4C6FA7DE79BDE7FA1C7D2FFD54FD6DFAA7F5470C5806B30C2406DB0CCE183CC5
              35716F3C1D2FC7DBF151435DC34043A561956197E18491B9D13CA3D5468D460F
              8C69C65CE324E36DC66DC6A326062621264B4DEA4DEE9A524DB9A629A63B4C3B
              4CC7CDCCCDA2CDD699359B3D31D732E79BE79BD79BDFB7605A785A2CB6A8B6B8
              6549B2E45AA659EEB6BC6E855A3959A558555A5DB346AD9DAD25D6BBADBBA711
              A7B94E934EAB9ED667C3B0F1B6C9B6A9B719B0E5D806DBAEB66DB67D61676217
              67B7C5AEC3EE93BD937DBA7D8DFD3D070D87D90EAB1D5A1D7E73B472143A563A
              DE9ACE9CEE3F7DC5F496E92F6758CF10CFD833E3B613CB29C4699D539BD34767
              1767B97383F3888B894B82CB2E973E2E9B1BC6DDC8BDE44A74F5715DE17AD2F5
              9D9BB39BC2EDA8DBAFEE36EE69EE87DC9FCC349F299E593373D0C3C843E051E5
              D13F0B9F95306BDFAC7E4F434F8167B5E7232F632F9157ADD7B0B7A577AAF761
              EF173EF63E729FE33EE33C37DE32DE595FCC37C0B7C8B7CB4FC36F9E5F85DF43
              7F23FF64FF7AFFD100A78025016703898141815B02FBF87A7C21BF8E3F3ADB65
              F6B2D9ED418CA0B94115418F82AD82E5C1AD2168C8EC90AD21F7E798CE91CE69
              0E85507EE8D6D00761E6618BC37E0C2785878557863F8E7088581AD131973577
              D1DC4373DF44FA449644DE9B67314F39AF2D4A352A3EAA2E6A3CDA37BA34BA3F
              C62E6659CCD5589D58496C4B1C392E2AAE366E6CBEDFFCEDF387E29DE20BE37B
              17982FC85D7079A1CEC2F485A716A92E122C3A96404C884E3894F041102AA816
              8C25F21377258E0A79C21DC267222FD136D188D8435C2A1E4EF2482A4D7A92EC
              91BC357924C533A52CE5B98427A990BC4C0D4CDD9B3A9E169A76206D323D3ABD
              31839291907142AA214D93B667EA67E66676CBAC6585B2FEC56E8BB72F1E9507
              C96BB390AC05592D0AB642A6E8545A28D72A07B267655766BFCD89CA3996AB9E
              2BCDEDCCB3CADB90379CEF9FFFED12C212E192B6A5864B572D1D58E6BDAC6A39
              B23C7179DB0AE315052B865606AC3CB88AB62A6DD54FABED5797AE7EBD267A4D
              6B815EC1CA82C1B5016BEB0B550AE5857DEBDCD7ED5D4F582F59DFB561FA869D
              1B3E15898AAE14DB1797157FD828DC78E51B876FCABF99DC94B4A9ABC4B964CF
              66D266E9E6DE2D9E5B0E96AA97E6970E6E0DD9DAB40DDF56B4EDF5F645DB2F97
              CD28DBBB83B643B9A3BF3CB8BC65A7C9CECD3B3F54A454F454FA5436EED2DDB5
              61D7F86ED1EE1B7BBCF634ECD5DB5BBCF7FD3EC9BEDB5501554DD566D565FB49
              FBB3F73FAE89AAE9F896FB6D5DAD4E6D71EDC703D203FD07230EB6D7B9D4D51D
              D23D54528FD62BEB470EC71FBEFE9DEF772D0D360D558D9CC6E223704479E4E9
              F709DFF71E0D3ADA768C7BACE107D31F761D671D2F6A429AF29A469B539AFB5B
              625BBA4FCC3ED1D6EADE7AFC47DB1F0F9C343C59794AF354C969DAE982D39367
              F2CF8C9D959D7D7E2EF9DC60DBA2B67BE763CEDF6A0F6FEFBA1074E1D245FF8B
              E73BBC3BCE5CF2B874F2B2DBE51357B8579AAF3A5F6DEA74EA3CFE93D34FC7BB
              9CBB9AAEB95C6BB9EE7ABDB57B66F7E91B9E37CEDDF4BD79F116FFD6D59E393D
              DDBDF37A6FF7C5F7F5DF16DD7E7227FDCECBBBD97727EEADBC4FBC5FF440ED41
              D943DD87D53F5BFEDCD8EFDC7F6AC077A0F3D1DC47F7068583CFFE91F58F0F43
              058F998FCB860D86EB9E383E3939E23F72FDE9FCA743CF64CF269E17FEA2FECB
              AE17162F7EF8D5EBD7CED198D1A197F29793BF6D7CA5FDEAC0EB19AFDBC6C2C6
              1EBEC97833315EF456FBEDC177DC771DEFA3DF0F4FE47C207F28FF68F9B1F553
              D0A7FB93199393FF040398F3FC63332DDB0000000467414D410000B18E7CFB51
              93000000206348524D00007A25000080830000F9FF000080E9000075300000EA
              6000003A980000176F925FC546000010B74944415478DAE49B6DAC656755C77F
              6B3DFB9CFB36D3B93353405B5AAD91D2520920D5AA110A188D9158FD624CFC02
              960F3535E00B81C4C64613D4C4AAB19A34A6B188C644BF9010498004D4D0C410
              4C490A1F68A5D4722DD3E90CEDCC9DDB7BEEB9F7BC3C6BF9E159CFDEFBBE944E
              C71EA2726E4EEE3D6FFBECFD7FFE6BFDFF6BADE78ABB03F0F54FBD9763F95BEB
              A4E1DBD06624D8067031896C21020AAE2B982CA3AA8020AA4CB88A19C750219E
              83B19D64D7AF42C5004530C67682A92F2394EF0398D990ECCDBEE7BABFCA4DC5
              11AC7DFCAE77BD8B57F2D6D43F5E7DCDE07A5FFBB1C77D3C5D9D5CBA806ADA43
              F402F00CF859B0A7C4F3938DE7334AFE2F3C9F334F5BD7BDE38F27971EBE134D
              09488828A7D239488A888008894466883140D0F21AC2381F63C6104140952470
              697A9C691E2202EECA85C909A6B93904C42B0E40B3B2FC8173679F585D3A711D
              C7AFBF917C716379EFC2F3D76A33BC569B254487C860959406A0832CA2DB8A3C
              BBF9A5DF3B83DBD3C6EC49CC9EC6F2D390BF496653951710C551448D46A70809
              242128EB4B5B2094E75242105EB57209440B50A28CF20A675EB89A73A393CCBC
              591C00CBA74E7E90B3E7F9DE6B076C3CFE657EE04DB73379F598D133FFC16CEB
              0248A1BC89223A4CA4663D358375492B37D32C939A63A043240D41D29E28DFC2
              EC19B067B0D97FAA4DBF619EBFA9963780E770DFCC99392294E891122CAA1136
              091056D2849B4E9EE1B5C79EE7CCE8EAC50180F5E89577B1E90683D5354EDF7C
              2B93D11EE3338F33196D028A7B46DCC9B30CF309692AB8C489370DC860599AE1
              F5DAAC5CAFCD32DA2C23BA4E4A43449A39225BB89D55F2B3E6D30D9DCF9E34E6
              4FE3B30DC86771DB041F4122DDF85BCC9FF84BD60605888501E047BD6A3BD8F4
              2906ABA73879F38F3379E17946DF7C1CDB1DE326880AA020123457DC4198E1F3
              8CCD27A060F19A4882346C5407A7A5593D9D9B95374A5A86E513A80E91941069
              C660E7717BD6F7CEFD01F01980EC0208CDC218E08EB907130EC031BF88CD2F32
              583BCDE95BDEC9DEC567199DFD1A3E9922C9311754C0CD91E4050C145430140D
              8040C00DCB53B0293ADDC245712949509A21C8D2AAEAD20DB27CF206597FE3A7
              CB87E87E2D0A80EC05048F68F06CDD57AB061017B0F90586EBDFC3D5AFFA19C6
              E7BFC1F8EC13B8E7029E08EADE0168200AE61480BC1CD28B6062A2288A6B4980
              9E0D91490168B6494A2BB1380692160280767477DCBD8050EFF19C67C3ADDC8B
              809FC3761F65F5F47156AFBD091C0A748E55D4DCE297D7C303DE1E231E166133
              6B39E72DF912E4BD78AE3BA78501502E389880631677E76830F20C9B6EB07AEA
              640027E5E4CDCA6770DC730F84722CE2581D681620780BA20744F5820DC3700C
              5F6012AC0C30C7739CB400194C3AB89496C3908D6CA3385D433CE142312C1EC9
              D11D91028E486188BAE108E2D5035AF90E4F68805200B34EA1D4161B026607E8
              DF5FF576F5E9989103B0ECF1D90202F57DC1AA6E250D0F36597C9FC773958158
              ACB23BEED69E5EE146E1C0E242C04A9C7A9C4417022F0286C74578663ACB6433
              E2DC0B89DBF0B172012DC5E9A85DB8DF032AB720985997F9039C48240B92C138
              91960997130201C27317C71C3FB6C4CAF29066008984E388399640DD0BE5CD22
              32147743440BBB713CD5631A621A078F1C928DA8B61628833956C962152BDADA
              8FF9C360883BCF6DEDB2B397397E6CCE556B4B0C97860C9A52DC88270C8BC328
              628E6B8D7340B4D03E83A608A3C80395F2465EBC0FF05879B01206DE69B9F603
              E60018E2469E1B3B36613ACB8CC673AE3A36E3AA632BAC2C0D4818A816F68A17
              9F608E68279A4E61855510BC1CB795DD624C160D4091AF9C23EEAD181BDCBB55
              3F028C56E24C98CE33B3EC4C2699F15EE635A7D6585D1D92547032620953431D
              DCB403A10D09C1B2A02AAD445685593C03DCDA24572EACAC1C0763FE00186619
              3347B5C439EE4CE7737C078603653048A86AF9B81AE28AC94110E601822252DD
              78EE0AB4BEBB5C940AE4D07E37EB64B0E7003D73480DACE7CE6A1D5133FD2C67
              76C67366F38CE51CCA6045DE9CA2F16E6DE815D9B35632FB3EC02DC702D92219
              102B1F2765D95B9A97046C7432AC9425EC0C94403139E625D33BCC2D339F19BE
              1C17AFDA5382847924478B8CEAB97C308A26F681EB8B0D018B95CFB9F3DEF582
              AD17F307C1B038512FE50D51FFE251FD38B9009ACA4AAB5467170A10ABAA26B8
              4A497E08E29D952E75C5A29360EE51DA3B46D08BF923C1F0CA80028289A35113
              5476983B12EF312FA9C5CDCA675242DC0A7B7269AC8846D1540B27B7EF8C0C16
              2364981F11027D3042960DD01C715FAD6B244A45F681E9E6A08610E647287543
              CE65E549019EE359221FCCDB4AB5A0BAD0102894F7DC59DD1A77874300FAEA51
              5420E85BAC5F503BFC8497C76A5A4070292B4EACB8816B0E8528ADF0C8BAF11D
              1916530B1DCE014509FCB243A066E616040CB79823844770F3226F189A1552C9
              758533868B2026B87A01C735BA29D20B015D2C0035966B65B73F047AED9C0360
              58F6F635A3305522891B454A0B9D8B173031349779416999955850913019021A
              75445B2A1A8BA2C0BE5AC0BCC784175581FD6078AF741503D31E08EE5109C681
              54C35996666A2DF12515A953A4AB17B05E087E2754A0D602BE5F0D5E32042C87
              0A5839F94C5480C5C29A1BD99DC6ADB4F6349A2344E617C173E930171873C8A0
              7532983DFCC1221910B19FB3B78D8B8336F83018123D8122818A47662F20509B
              266E6457121584142038E68A8A97BC8190B57800709ADA525B5021748001B993
              ABEA04A5E797F568304AC383D0720D100A137CD0F516448C8C9663E58C24C55D
              10B1D2567770F148860296DB0BAF7DCA851B21F760C28110B0DEAA1F04C37368
              7D34333CA6C11EFD7033DB6796CCB5D45839AA40ED7A8578611159CA7B73BF27
              B87006C4895626B4212025FE5E040C730B3B5C2ECC3C14DE2D728093DD485146
              8A1A6612B3C0B2E2B5B610916EC8D2CBFCEEB6781F906BF2AB6AD00F01E5C87C
              50642F28AE869946A20F856F9BA1DD6B552B8B6310D4A5A53E141B6C2E2519B6
              B5802F3E04C8B515665D79EA51B0B41DA9A0E8BE10A8CC012A08022E45FB6B4E
              F1D45BF9304AE21ED321C783696E120D27A78910C86D12F44532C06230725005
              ACB7EA7A28046AFF402A8829921AD2D6F0D99D263B9EB45C34521CA14448B814
              2540CA88ACAA7FADFFB3E162EDB469416DF1F001394AF1BCDF161785B0E81758
              74AA6BF1D4CD00C81EEDB5A82D8ABB8AF0EA4C9691DBE2ABE60A8BEF2836B2F4
              019F7DF837FEC26D96F68DEF17024068768ED698796F2EF0EDC0A813DF008408
              9DFABAC53CC0EA71ADEB04B5BD841C40E4DCCD21009B6E93964EFD7A73FCB5FF
              2ECDF03DBE5006C445B81D1E901E0546C9E8AB9C7BE6624C73AC9DFA785C9885
              1BAC79A25EB065EF01645D7B2C80CDF1D9C9CEF3EC6E3E95729EBC7578FCFABF
              D5C1DA9F2D703416DE3DF72ED439342AAB60685AE3B9F39B7CFDB127DA93A6B7
              7A75D28CD5D58F8BB7FD176B1508EFF5062DB7F583D994D9F639263BE7492BEB
              BFBDD87E409C408DEFDAF8508EA84675C0D7BEFA24A265C859C617258995BA4F
              5ADAD7C9B3AB85FC39EA618238608301ADDE234B6CA2029FEFE2B6B6E072D87A
              4CE8CDE20DE264BC0523CFA7DD5C209AA078190AB7D5BBF73B4DE1196A192CC5
              DC94EA9268100470D1702D5F3E2D73055FE95461515DE1B61F602504F6F97F7A
              73812C58B6707DD51E0AA291F9A594BCDE2639C393B49B27D442F2B4AD214302
              63B690F79FE23CC37C679B9595F5B2F7F065DC5E6A5385F63688F4E2B0CB076E
              DE6B93F5EF56D8D253879AF16B2EC8E6E42A8161995B896CE5B4284F172E314D
              8E9FD7FCD4836C7DDFBDE551CEDC7BEFBDB21806E4AE68A99ABC0FA5FE7C32BA
              BAA5E7176570ECFBA91B82C4BB4188BB914D3A4B6D4E96B2E29AA56CA0D062C2
              A4DD67746025CD70CBA494D2473EF2111B0C069E52E2431FFA90BF723920E60F
              DE1F8FF7C7613D302C4C8D08FB40E8F70B52DD18166D71B3489035917869A3D3
              0241E480C38B5C3AD5464A6939A59445C444C4EEBFFF7E4B2979D334AEAADC75
              D75D7E652AD0D2BEE7ED0FF8FE3E181AE32A90B68A6BBBC6EA68A30C1BA5D13A
              712E176891EC941C5596444D507B838EE4C3007836CCE600ABC1472B359C672B
              B70CD8830F3EE829255755BFF3CE3BFDB2019076307AA016B00319A356823977
              2C1147A4787B736128CAB1E5C4B1D5441289F7D52091B62FA856670245FE44BC
              AD0B0E01400120E7BCE4E5E4B2BB9B9965553577CFAA9A45C4524A5955F3430F
              3DF492DDD4A6570CC6D032B6C9F44240457A7BDA021709A54885B65EF6838208
              4B03657D75C0F220B5C9B18EBCC50B630A1124A4B180E32A2D088742C01CCB99
              E9743A4C2979CED954D555D5524A369BCDB2AA9AAAE694D22CA5B417ACB8CC7D
              82B56B73C42629EB39C0CE1D965658676BEB1004924A897FAC1DB2E41C855224
              45A3E700AD3A408B82C90E4D834B1196994C26696F6F2FEDEEEE0EE23EDCD9D9
              19EEEEEE2E8FC7E3E1783C96BDBDBDE9743A9DDD7DF7DD971F02C07DE6FEE14C
              7FE3430FA24AFDDE1639734745302B1C408ADBAB1321738B864759F58C20D110
              D1303F658B6138C8D86D1A4DC0C3392067C6E3B1A8AA8888C76F4444534A3355
              DD6B9A66DBDDA7F7DC738FBF3C1510FDC7E595B5BB703F61073649F5E5AF3544
              5137B77B81EB54A4BFB1321757A7EDF6C71808B6F34362834461602B8D47989D
              325FC8ECECEC10172DAA8A88B8884C534A979AA6193DF0C003F98A54E0ED77FE
              D3971FFEE81D6F9E4EF73EE1EE6FDEE7037AFB82DA6E70B4B8D15E7FDF42D6AC
              AB29B06A6D8B0FA86D8F5651ACEB32495865EB25C15F7EE03883E90ABFFFFD65
              4E301A8D2A00D515BA88CC80895F41BDBCAFC4B9FD7D9FDC180C97DFB976D5C9
              2FEFCB01FD72B8B7657634993F9FE786E5FE9EC2E82AD578376BF384F5DA6D5E
              7783B40ED1DBCD95D6BB4B5A6277B65A9AABD9188D46ED7D7B7B9BD16824A3D1
              A8198FC7CDDEDEDECB364252E5AEEFB11FFEE81DEBC0C7805FDCFFEE707BF1F7
              2F7CE0D33F7FF3F56BD7BDEEDA63375DF3AAA5379E581BDCB8BA94AE3D757CC8
              D5EB030683B25D5685FE8A215A18538D8F48776C1579D19D00C3B535EE7E60F3
              A6F638C50C4D9AA6D91A0C06A3CF7EF6B3F9E5D6024702D003E263C07B8FFE24
              DC7EE727DF1A613400F4F84AB37ACB0DC7AFF9E95BAFBEE6476E3E71CBF2527A
              8B0AAF13246911FA0244FD3EADE004B02D20E5F994B474A781E1CA3286F09EFB
              CEDC14606655DD898BDFFDC217BEE057520C7DDB7FC0B8FD7D9FFCD5873F7AC7
              25E0378FC84A007B91150490EDDDF9D6171FDB7CEA8B8F6D3E076C7FEE4F7FB4
              999ABFAE69F4ADD9797B126E45FCF54964A98E7C4C2237440B40A2395AE83F40
              868311F8C0D0A5CDCDD1A7C6E3B103B394D256D334DB66367FE49147AEB81EF8
              B60CE831E1BD111207017A43EFE10CD8045E00E6077BD8FFFCE7B7F16F5F1DA7
              9FB869F506E08745799B88DC9654DE9054D6EAFC418201080C96D638FFFCE8AF
              3FFF954BFF70E3752BAFFFFC57B6BFF4AF8F6E3DDB34CD76D334E38D8D8D97CC
              F8FFA31078291002000776810BC04EFFC23F77DF5BCA08B5FD474B47A569A5E4
              97FEF029F99B0FDE70DDA091B734497F5295DB062AB7689253A95902814B5BE3
              5FFB953F7AE2EFEA875475DE34CDFCFCF9F397B5EAAF180001C23B804F00EB01
              C0EB81117011981C5AF58FFF099091D90BF8CE37106DD0BDE760362AFF3B6863
              F0791BF7EFFEDDAFC9DF7FF8075FBDB2DABC6979A03F84FB33FFF2E8D6C77FF6
              B6D3F9E77EE73101D8DADA7A59747F45010810DE3CDE9BFF95996FBCFBFD9F79
              3FB07514E52FE7CBFF37DCE44A4E520A5AA9EE92B952F4FFCF02F0FFE9A67C97
              DFBEEB01F8EF0100975C921D62A65E700000000049454E44AE426082}
          end>
      end>
    Left = 208
    Top = 112
  end
  object VirtualImageList1: TVirtualImageList
    Images = <
      item
        CollectionIndex = 0
        CollectionName = 'folder_open_64_h'
        Name = 'folder_open_64_h'
      end>
    ImageCollection = ImageCollection1
    Left = 216
    Top = 152
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
        FileMask = '*.wav;*.mp3;*.aac;*.wma;*.avi;*.mp4;*.mpg;*.mkv;*.vob'
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
end
