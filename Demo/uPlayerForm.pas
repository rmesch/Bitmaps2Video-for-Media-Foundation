unit uPlayerForm;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, uTransformer;

const WMStartPlaying = WM_User+501;

type
  TPlayerForm = class(TForm)
    procedure FormShow(Sender: TObject);
    procedure FormClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    { Private-Deklarationen }
    fPlayerStop: boolean;
    Procedure StartPlaying(var msg: TMessage); message WMStartPlaying;
  public
    { Public-Deklarationen }
    Videoplayer: TVideoPlayer;
  end;

var
  PlayerForm: TPlayerForm;

implementation

{$R *.dfm}

procedure TPlayerForm.FormClick(Sender: TObject);
begin
  fPlayerStop:=true;
  ModalResult:=mrOK;
end;

procedure TPlayerForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  fPlayerStop:=true;
  Application.ProcessMessages;
  sleep(20);
end;

procedure TPlayerForm.FormShow(Sender: TObject);
begin
  PostMessage(Handle,WMStartPlaying,0,0);
end;

procedure TPlayerForm.StartPlaying(var msg: TMessage);
begin
  fPlayerStop:=false;
  If assigned(VideoPlayer) then
  VideoPlayer.Play(
  procedure(Sender: TObject; VideoTime: Cardinal; var Stop: boolean)
  begin
    Application.ProcessMessages;
    Stop:=fPlayerStop;
  end,
  nil);
end;

end.
