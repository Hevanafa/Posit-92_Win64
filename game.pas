{ Entry point }

{$Mode TP}

uses
  SDL2Wrapper, Posit92,
  Keyboard, VGA;

const
  TargetFPS = 60;
  FrameTime = 16;

{
var
  done: boolean;
}

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
end;

procedure TGame.init;
begin
  inherited init; { works the same as super.init() in JS }

  setTitle('Posit-92 with SDL2');

  initBuffer;
  { initDeltaTime }
end;

procedure TGame.afterInit;
begin
  loadAssets;

  { Init your game state here }
end;

procedure TGame.cleanup;
begin
  inherited cleanup;


end;

procedure TGame.update;
begin
  inherited update;

  if isKeyDown(SC_ESC) then done := true;

end;

procedure TGame.draw;
begin
  cls($FF6495ED);
  { cls($FFFF5555); } { test mode 13h red } { correct }
  { cls($FF55FF55); } { test mode 13h green } { output: magenta }
  { cls($FF5555FF); } { test mode 13h blue } { output: yellow }

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
