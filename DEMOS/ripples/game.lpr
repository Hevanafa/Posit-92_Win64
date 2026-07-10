program Game;

{$Mode ObjFPC}
{$H+}
{$J-}

uses
  SysUtils,
  P92Core, P92Fonts,
  P92Keyboard, P92Mouse,
  P92Logger,
  P92Tex, P92TexDraw,
  P92Colour, P92Graphics, P92Timing, P92VGA,
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


procedure OnPreload;
begin
  imgCursor := loadImage('assets\images\cursor.png');
  imgDosuEXE[0] := loadImage('assets\images\dosu_1.png');
  imgDosuEXE[1] := loadImage('assets\images\dosu_2.png');

  { Load more assets here }
end;

procedure OnReady;
begin
  HideCursor;
  SetTitle('Ripple Demo');

  { Init your game state here }
  gameTime := 0.0
end;

procedure OnCleanup;
begin
  showCursor;

  FreeTexture(imgCursor);
  FreeTexture(imgDosuEXE[0]);
  FreeTexture(imgDosuEXE[1]);
end;

procedure Update;
var
  a: word;
begin
  { Your Update logic here }
  if isKeyDown(SC_ESCAPE) then SignalDone;

  if getTimer >= nextRippleTick then begin
    nextRippleTick := getTimer + random / 4.0;
    spawnRipple(random(vgaWidth), Random(vgaHeight))
  end;

  for a:=0 to high(ripples) do begin
    if not ripples[a].alive then continue;

    ripples[a].radius := ripples[a].radius + DeltaTime * 48.0;
    ripples[a].opacity := ripples[a].opacity - DeltaTime;

    if ripples[a].opacity < 0 then ripples[a].alive := false;
  end;

  gameTime := gameTime + DeltaTime;
end;

procedure Draw;
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
end;


{$R *.res}

var
  appConfig: TP92AppConfig;
begin
  appConfig := DefaultP92AppConfig;

  appConfig.OnPreload := @OnPreload;
  appConfig.OnReady := @OnReady;
  appConfig.Update := @Update;
  appConfig.Draw := @Draw;
  appConfig.OnCleanup := @OnCleanup;

  P92Start(appConfig)
end.


