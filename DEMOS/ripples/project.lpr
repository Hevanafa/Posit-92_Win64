program Game;

{$Mode ObjFPC}
{$H+}
{$J-}

uses
  SysUtils,
  SDL2Wrapper, Posit92,
  Keyboard, Mouse, Logger,
  ImgRef, ImgRefFast,
  Colour, Graphics, Timing, VGA,
  Assets;

type
  TRipple = record
    alive: boolean;
    cx, cy: smallint;
    radius: single;
    opacity: single;
  end;


const
  TargetFPS = 60;
  FrameTime = 16;

var
  { Game state variables }
  gameTime: double;

  ripples: array[0..9] of TRipple;
  nextRippleTick: double;


procedure drawMouse;
begin
  spr(imgCursor, mouseX, mouseY)
end;

procedure spawnRipple(const cx, cy: smallint);
var
  a: word;
  idx: smallint;
begin
  idx := -1;

  for a:=0 to high(ripples) do
    if not ripples[a].alive then begin
      idx := a;
      break
    end;

  if idx < 0 then exit;

  ripples[idx].cx := cx;
  ripples[idx].cy := cy;

  with ripples[idx] do begin
    alive := true;
    radius := 1.0;
    opacity := 1.0;
  end;
end;

procedure circBlend(const cx, cy, radius: integer; const colour: longword);
var
  x, y, p: integer;
begin
  if getAlpha(colour) = 0 then exit;

  x := 0;
  y := radius;
  p := 3 - 2 * radius;

  while x <= y do begin
    psetBlend(cx + x, cy + y, colour);
    psetBlend(cx - x, cy + y, colour);
    psetBlend(cx + x, cy - y, colour);
    psetBlend(cx - x, cy - y, colour);
    psetBlend(cx + y, cy + x, colour);
    psetBlend(cx - y, cy + x, colour);
    psetBlend(cx + y, cy - x, colour);
    psetBlend(cx - y, cy - x, colour);

    if p < 0 then
      p := p+4 * x+6
    else begin
      p := p+4 * (x-y)+10;
      dec(y);
    end;
    inc(x);
  end;
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
  initSDL;
  initLogger;
end;

procedure afterInit;
begin
  setTitle('Ripple Demo');

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
var
  a: word;
begin
  updateSDL;
  updateDeltaTime;

  { Your update logic here }
  if isKeyDown(SC_ESCAPE) then done := true;

  if getTimer >= nextRippleTick then begin
    nextRippleTick := getTimer + random / 4.0;
    spawnRipple(random(vgaWidth), Random(vgaHeight))
  end;

  for a:=0 to high(ripples) do begin
    if not ripples[a].alive then continue;

    ripples[a].radius := ripples[a].radius + dt * 48.0;
    ripples[a].opacity := ripples[a].opacity - dt;

    if ripples[a].opacity < 0 then ripples[a].alive := false;
  end;

  gameTime := gameTime + dt
end;

procedure draw;
var
  a: word;
  s: string;
  w: word;
  h, m: word;
  grey: longword;
begin
  { cls($FF6495ED); }
  for a:=0 to vgaHeight - 1 do
    hline(0, vgaWidth - 1, a, lerpColour($FFFFB08A, $FFD4C5E8, a / (vgaHeight - 1)));

  for a:=0 to high(ripples) do begin
    if not ripples[a].alive then continue;

    grey := round(ripples[a].opacity * $FF);

    circBlend(ripples[a].cx, ripples[a].cy, trunc(ripples[a].radius),
      (grey shl 24) or $FFFFFF);
      { $FF000000 or (grey shl 16) or (grey shl 8) or grey); }
  end;

  if (trunc(gameTime * 4) and 1) > 0 then
    spr(imgDosuEXE[1], 148, 88)
  else
    spr(imgDosuEXE[0], 148, 88);

  s := 'It is time!';
  w := measureDefault(s);
  printDefault(s, (vgaWidth - w) div 2, 120);

  h := trunc(getTimer / 3600);
  m := trunc(getTimer) mod 3600 div 60;
  s := format('%.2d:%.2d', [h, m]);
  w := measureDefault(s);
  printDefault(s, (vgaWidth - w) div 2, 130);

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
      lastFrameTime := frameTimeNow - (elapsed mod FrameTime); { Carry over extra time }
      update;
      draw
    end;

    SDL_Delay(1)
  end;

  cleanup
end.


