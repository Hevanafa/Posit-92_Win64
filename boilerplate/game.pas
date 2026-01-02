{$R game.res}

{$Mode ObjFPC}
{$J-}

uses
  SDL2Wrapper, Posit92,
  Keyboard, Mouse,
  Logger, ImgRef, ImgRefFast,
  Sounds, Timing, VGA,
  Assets;

const
  TargetFPS = 60;
  FrameTime = 16;

var
  gameTime: double;
  { More of your game state here }


procedure drawMouse;
begin
  spr(imgCursor, mouseX, mouseY)
end;


procedure loadAssets;
begin
  imgCursor := loadImage('assets\images\cursor.png');
  imgDosuEXE[0] := loadImage('assets\images\dosu_1.png');
  imgDosuEXE[1] := loadImage('assets\images\dosu_2.png');

  loadBMFont(
    'assets\fonts\nokia_cellphone_fc_8.txt',
    defaultFont, defaultFontGlyphs);

  { Load more assets here }
end;

procedure init;
begin
  initSDL;
  setTitle('Posit-92 with SDL2');

  initLogger;
  initBuffer;
  initDeltaTime;
  initSounds;
end;

procedure afterInit;
begin
  loadAssets;
  hideCursor;

  { Init your game state here }
  gameTime := 0.0
end;

procedure cleanup;
begin
  closeLogger;
  showCursor;
  cleanupSounds;

  { Your cleanup code here (after setting `done` to true) }

  cleanupSDL
end;

procedure update;
begin
  updateSDL;
  updateDeltaTime;

  { Your update logic here }
  if isKeyDown(SC_ESC) then sdlDone := true;

  gameTime := gameTime + dt
end;

procedure draw;
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
  vgaFlush
end;


var
  lastFrameTime, frameTimeNow, elapsed: longword; { in ms }

begin
  init;
  afterInit;

  sdlDone := false;

  lastFrameTime := SDL_GetTicks;

  while not sdlDone do begin
    frameTimeNow := SDL_GetTicks;
    elapsed := frameTimeNow - lastFrameTime;

    if elapsed >= FrameTime then begin
      lastFrameTime := frameTimeNow - (elapsed mod FrameTime); { Carry over extra time }
      update;
      draw
    end;

    SDL_Delay(1)
  end;

  cleanup
end.
