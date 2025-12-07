{ Entry point }

{$Mode TP}

uses
  SDL2Wrapper, Posit92,
  Conv, Keyboard, Logger,
  ImgRef, ImgRefFast,
  Timing, VGA,
  Assets;

const
  TargetFPS = 60;
  FrameTime = 16;


type
  TGame = object(TPosit92)
  public
    procedure loadAssets;
  private
    procedure init;
    procedure afterInit;
    procedure cleanup;
    procedure update;
    procedure draw;
  end;

procedure TGame.loadAssets;
begin
  { Load more assets here }
  imgGasolineMaid := loadImage('assets\images\gasoline_maid_100px.png');

  loadBMFont(
    'assets\fonts\nokia_cellphone_fc_8.txt',
    defaultFont, defaultFontGlyphs)
end;

procedure TGame.init;
begin
  inherited init; { works the same as super.init() in JS }

  setTitle('Posit-92 with SDL2');

  initLogger;
  initBuffer;
  initDeltaTime
end;

procedure TGame.afterInit;
begin
  loadAssets;
  hideCursor;

  { Init your game state here }
end;

procedure TGame.cleanup;
begin
  inherited cleanup;

  closeLogger;
  showCursor;
  
  { Your cleanup code here (after setting `done` to true) }
end;

procedure TGame.update;
begin
  inherited update;
  updateDeltaTime;

  { updateMouse }

  { Your update logic here }
  if isKeyDown(SC_ESC) then done := true;

end;

procedure TGame.draw;
begin
  cls($FF6495ED);

  { Your render logic here }
  spr(imgGasolineMaid, 10, 10);

  printDefault('Hello from Posit-92 with SDL2!', 10, 160);

  printDefault('getTimer: ' + f32str(getTimer), 10, 170);
  printDefault('getFullTimer: ' + f32str(getFullTimer), 10, 180);

  flush
end;


var
  game: TGame;
  lastFrameTime, frameTimeNow, elapsed: longword; { in ms }

begin
  game.init;
  game.afterInit;

  game.done := false;

  lastFrameTime := SDL_GetTicks;

  while not game.done do begin
    frameTimeNow := SDL_GetTicks;
    elapsed := frameTimeNow - lastFrameTime;

    if elapsed >= FrameTime then begin
      lastFrameTime := frameTimeNow - (elapsed mod FrameTime); { Carry over extra time }
      game.update;
      game.draw
    end;

    SDL_Delay(1)
  end;

  game.cleanup
end.
