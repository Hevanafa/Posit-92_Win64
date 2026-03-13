program Game;

{$Mode ObjFPC}
{$H+}  { Use AnsiStrings }
{$J-}  { Don't allow assignments to typed consts }

uses
  SysUtils,
  SDL2Wrapper, Posit92,
  Keyboard, Mouse,
  ImgRef, ImgRefFast,
  Logger, Timing, VGA,
  Assets;

const
  TargetFPS = 60;
  FrameTime = 1000 div TargetFPS;

var
  { Game state variables }
  gameTime: double;


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
  initVideoMem(320, 200, getmem(320 * 200 * 4));
  initDeltaTime;

  printProcessorArchitecture;

  initSDL;
  initLogger;
end;

procedure afterInit;
begin
  setTitle('Posit-92 with SDL2');

  loadAssets;
  hideCursor;

  { Init your game state here }
  gameTime := 0.0
end;

procedure cleanup;
begin
  showCursor;

  freeImage(imgCursor);
  freeImage(imgDosuEXE[0]);
  freeImage(imgDosuEXE[1]);
  freeImage(imgFullFont);

  freeImage(defaultFont.imgHandle);

  freemem(getSurfacePtr);

  { Your cleanup code here (after setting `done` to true) }
  closeLogger;
  cleanupSDL
end;

procedure update;
begin
  updateSDL;
  updateDeltaTime;

  { Your update logic here }
  if isKeyDown(SC_ESCAPE) then done := true;

  gameTime := gameTime + dt
end;

procedure draw;
begin
  cls($FF6495ED);

  if (trunc(gameTime * 4) and 1) > 0 then
    spr(imgDosuEXE[1], 148, 88)
  else
    spr(imgDosuEXE[0], 148, 88);

  printDefaultCentred('Hello world!', vgaWidth div 2, 120);

  drawMouse;
  vgaFlush
end;


var
  { done: boolean; }  { moved to Posit92 unit }
  lastFrameTime, frameTimeNow, elapsed: longword; { in ms }

{$R *.res}

begin
  writeln('cwd: ', GetCurrentDir);
  writeln(getDllMachine('SDL2.dll'));

  init;
  afterInit;

  done := false;

  lastFrameTime := SDL_GetTicks;

  while not done do begin
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


