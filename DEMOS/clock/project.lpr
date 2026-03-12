program Game;

{$Mode ObjFPC}
{$H+}
{$J-}

uses
  SysUtils, DateUtils, Maths,
  SDL2Wrapper, Posit92,
  BMFont, FPS, Graphics,
  Keyboard, Mouse, Logger,
  ImgRef, ImgRefFast, SprEffects,
  Timing, VGA,
  Assets;

const
  TargetFPS = 18;
  FrameTime = 1000 div TargetFPS;

  White = $FFFFFFFF;
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

{ dotw: use DayOfTheWeek from DateUtils unit }
function getDayName(dotw: smallint): string;
begin
  case dotw of
  1: result := 'mon';
  2: result := 'tue';
  3: result := 'wed';
  4: result := 'thu';
  5: result := 'fri';
  6: result := 'sat';
  7: result := 'sun';
  end;
end;

procedure loadAssets;
begin
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

  replaceColour(defaultFont.imgHandle, white, Palette[1]);

  { Init your game state here }
  gameTime := 0.0
end;

procedure cleanup;
begin
  showCursor;

  freeBMFont(defaultFont, defaultFontGlyphs, true);
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
  positNow: double;
  h, m, s: double;
  angle: double;
  x, y: double;

  dotw: smallint;
begin
  cls(palette[0]);

  for a:=0 to 11 do begin
    angle := deg2rad(a * 30.0);
    line(
      trunc(cos(angle) * 50 + vgaWidth div 2),
      trunc(sin(angle) * 50 + vgaHeight div 2),
      trunc(cos(angle) * 55 + vgaWidth div 2),
      trunc(sin(angle) * 55 + vgaHeight div 2),
      palette[1]);
  end;

  { printDefault(format('%.2d:%.2d:%.2d', [trunc(h), trunc(m), trunc(s)]), 10, 10); }
  printDefaultCentred(FormatDateTime('dd-mm-yyyy', now), vgaWidth div 2, vgaHeight * 3 div 4 - defaultFont.lineHeight - 2);

  dotw := DayOfTheWeek(now);
  { testStr := format('Today is %s', [getDayName(dotw)]); }
  printDefaultCentred(getDayName(dotw), vgaWidth div 2, vgaHeight * 3 div 4);


  positNow := getTimer;

  h := positNow / 3600.0;
  angle := deg2rad(h * 30.0 - 90.0);
  x := cos(angle) * 15 + vgaWidth div 2;
  y := sin(angle) * 15 + vgaHeight div 2;
  line(vgaWidth div 2, vgaHeight div 2, trunc(x), trunc(y), palette[1]);

  m := trunc(positNow) mod 3600 div 60 + frac(positNow / 60.0);
  angle := deg2rad(m * 6.0 - 90.0);
  x := cos(angle) * 30 + vgaWidth div 2;
  y := sin(angle) * 30 + vgaHeight div 2;
  line(vgaWidth div 2, vgaHeight div 2, trunc(x), trunc(y), palette[1]);

  s := trunc(positNow) mod 60 + frac(positNow);
  angle := deg2rad(s * 6.0 - 90.0);
  x := cos(angle) * 40 + vgaWidth div 2;
  y := sin(angle) * 40 + vgaHeight div 2;
  line(vgaWidth div 2, vgaHeight div 2, trunc(x), trunc(y), palette[1]);

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


