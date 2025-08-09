program DemoWMF;


uses
  Vcl.Forms,
  uDemoWMFMain in 'uDemoWMFMain.pas' {DemoWMFMain},
  uBitmaps2VideoWMF in '..\Source\uBitmaps2VideoWMF.pas',
  uDirectoryTree in '..\Utilities\uDirectoryTree.pas',
  uToolsWMF in '..\Utilities\uToolsWMF.pas',
  uTransformer in '..\Source\uTransformer.pas',
  uScaleCommonWMF in '..\Source\uScaleCommonWMF.pas',
  uScaleWMF in '..\Source\uScaleWMF.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TDemoWMFMain, DemoWMFMain);
  Application.Run;
end.
