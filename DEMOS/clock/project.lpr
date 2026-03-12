program Game;

{$Mode ObjFPC}
{$H+}
{$J-}

uses
  SysUtils, Maths,
  SDL2Wrapper, Posit92,
  FPS, Graphics,
  Keyboard, Mouse, Logger,
  ImgRef, ImgRefFast,
  Timing, VGA,
  Assets;

const
  TargetFPS = 18;
  FrameTime = 1000 div TargetFPS;
  Palette: array[0..1] of longword = ($FF3C3C3C, $FFB5F80E);

var
  { Game state variables }
  gameTime: double;


procedure drawFPS;
begin
  printDefault(format('FPS: %d', [getLastFPS]), vgaWidth - 50, 0);
end;

procedure drawMouse;
begin
  { spr(imgCursor, mouseX, mouseY) }
  pset(mouseX, mouseY, Palette[1])
end;


procedure loadAssets;
begin
  imgCursor := loadImage('assets\images\cursor.png');
  imgDosuEXE[0] := loadImage('assets\images\dosu_1.png');
  imgDosuEXE[1] := loadImage('assets\images\dosu_2.png');

  loadBMFont(
    'assets\fonts\pico-8_regular_5.txt',
    defaultFont, defaultFontGlyphs);

  { Load more assets here }
end;

procedure init;
begin
  initVideoMem(128, 128, getmem(128 * 128 * 4));
  initDeltaTime;
  initSDL;
  initLogger;
end;

procedure afterInit;
begin
  setTitle('Posit-92 Clock');

  loadAssets;
  hideCursor;
  initFPSCounter;

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

  incrementFPS;

  { Your update logic here }
  if isKeyDown(SC_ESCAPE) then done := true;

  gameTime := gameTime + dt
end;

procedure draw;
var
  a: word;
  now: double;
  h, m, s: double;
  angle: double;
  x, y: double;
begin
  cls(palette[0]);

  if (trunc(gameTime * 4) and 1) > 0 then
    spr(imgDosuEXE[1], 148, 88)
  else
    spr(imgDosuEXE[0], 148, 88);

  for a:=0 to 11 do begin
    angle := deg2rad(a * 30.0);
    line(
      trunc(cos(angle) * 50 + vgaWidth div 2),
      trunc(sin(angle) * 50 + vgaHeight div 2),
      trunc(cos(angle) * 55 + vgaWidth div 2),
      trunc(sin(angle) * 55 + vgaHeight div 2),
      palette[1]);
  end;


  now := getTimer;

  h := now / 3600.0;
  angle := deg2rad(h * 30.0 - 90.0);
  x := cos(angle) * 15 + vgaWidth div 2;
  y := sin(angle) * 15 + vgaHeight div 2;
  line(vgaWidth div 2, vgaHeight div 2, trunc(x), trunc(y), palette[1]);

  m := trunc(now) mod 3600 div 60 + frac(now / 60.0);
  angle := deg2rad(m * 6.0 - 90.0);
  x := cos(angle) * 30 + vgaWidth div 2;
  y := sin(angle) * 30 + vgaHeight div 2;
  line(vgaWidth div 2, vgaHeight div 2, trunc(x), trunc(y), palette[1]);

  s := trunc(now) mod 60 + frac(now);
  angle := deg2rad(s * 6.0 - 90.0);
  x := cos(angle) * 40 + vgaWidth div 2;
  y := sin(angle) * 40 + vgaHeight div 2;
  line(vgaWidth div 2, vgaHeight div 2, trunc(x), trunc(y), palette[1]);

  { printDefault(format('%.2d:%.2d:%.2d', [trunc(h), trunc(m), trunc(s)]), 10, 10); }

  drawFPS;
  drawMouse;

  vgaFlush
end;


var
  { done: boolean; }  { moved to Posit92 unit }
  lastFrameTime, frameTimeNow, elapsed: longword; { in ms }

{$R *.res}

begin
  init;
  afterInit;

  done := false;

  lastFrameTime := SDL_GetTicks;

  while not done do begin
    frameTimeNow := SDL_GetTicks;
    elapsed := frameTimeNow - lastFrameTime;

    if elapsed >= FrameTime then begin
      lastFrameTime := frameTimeNow - (elapsed mod FrameTime);  { Carry over extra time }
      update;
      draw
    end;

    SDL_Delay(1)
  end;

  cleanup
end.


