{ Entry point }

{$Mode TP}

uses
  SDL2Wrapper, Posit92,
  Keyboard, Logger,
  ImgRef, ImgRefFast,
  VGA;

const
  TargetFPS = 60;
  FrameTime = 16;

var
  imgGasolineMaid: longint;

  defaultFont: TBMFont;
  defaultFontGlyphs: array [32..126] TBMFontGlyph;

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
end;

procedure TGame.init;
begin
  inherited init; { works the same as super.init() in JS }

  setTitle('Posit-92 with SDL2');

  initLogger;
  initBuffer;
  { initDeltaTime }
end;

procedure TGame.afterInit;
begin
  loadAssets;

  { imgEmpty := newImage(32, 32); }
  { Init your game state here }
end;

procedure TGame.cleanup;
begin
  inherited cleanup;

  closeLogger;
  { Your cleanup code here (after setting `done` to true) }
end;

procedure TGame.update;
begin
  inherited update;

  if isKeyDown(SC_ESC) then done := true;

  { Your update logic here }
end;

procedure TGame.draw;
begin
  cls($FF6495ED);

  { Your render logic here }
  spr(imgGasolineMaid, 10, 10);

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

  game.cleanup;
end.
