{$Mode TP}

uses
  SDL2Wrapper, Posit92,
  Keyboard, Mouse,
  Logger, ImgRef, ImgRefFast,
  Timing, VGA,
  Assets;

const
  TargetFPS = 60;
  FrameTime = 16;

var
  gameTime: double;
  { More of your game state here }


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

procedure drawMouse;
begin
  spr(imgCursor, mouseX, mouseY)
end;


procedure TGame.loadAssets;
begin
  imgCursor := loadImage('assets\images\cursor.png');
  imgDosuEXE[0] := loadImage('assets\images\dosu_1.png');
  imgDosuEXE[1] := loadImage('assets\images\dosu_2.png');

  loadBMFont(
    'assets\fonts\nokia_cellphone_fc_8.txt',
    defaultFont, defaultFontGlyphs)

  { Load more assets here }
end;

procedure TGame.init;
begin
  inherited init; { works the same as super.init() in JS }

  setTitle('Posit-92 with SDL2');

  initLogger;
  initBuffer;
  initDeltaTime;
end;

procedure TGame.afterInit;
begin
  loadAssets;
  hideCursor;

  { Init your game state here }
  gameTime := 0.0
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

  { Your update logic here }
  if isKeyDown(SC_ESC) then done := true;

  gameTime := gameTime + dt
end;

procedure TGame.draw;
var
  s: string;
  w: word;
begin
  cls($FF6495ED);

  if (trunc(gameTime * 4) and 1) > 0 then
    spr(imgDosuEXE[1], 148, 88)
  else
    spr(imgDosuEXE[0], 148, 88);

  s := 'Hello world!';
  w := measureDefault(s);
  printDefault(s, (vgaWidth - w) div 2, 120);

  drawMouse;
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
