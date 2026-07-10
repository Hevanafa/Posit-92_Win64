program Game;

{$Mode ObjFPC}
{$H+}
{$J-}

uses
  SysUtils, DateUtils,
  SDL2Wrapper,
  P92Core, P92AssetRegistry, P92Fonts, P92Maths,
  P92Graphics, P92BMFont,
  P92Keyboard, P92Mouse, P92Logger,
  P92Tex, P92TexDraw, p92texEffects,
  P92Timing, P92FPS, P92VGA,
  Assets;

const
  TargetFPS = 18;
  FrameTime = 1000 div TargetFPS;

  White = $FFFFFFFF;
  Palette: array[0..1] of longword = ($FF3C3C3C, $FFB5F80E);

var
  { Game state variables }
  gameTime: double;


procedure DrawFPS;
begin
  printDefault(format('FPS: %d', [getLastFPS]), vgaWidth - 50, 0);
end;

procedure DrawMouse;
begin
  { spr(imgCursor, mouseX, mouseY) }
  pset(mouseX, mouseY, Palette[1])
end;

{ dotw: use DayOfTheWeek from DateUtils unit }
function GetDayName(const dotw: smallint): string;
begin
  result := '';

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

procedure OnPreload;
begin
  pico8Font := LoadBMFont('assets\fonts\pico-8_regular_5.txt');

  { Load more assets here }
end;

procedure init;
begin
  initVideoMem(128, 128, getmem(128 * 128 * 4));
  initDeltaTime;
  initSDL(3);
  initLogger;
end;

procedure OnReady;
begin
  HideCursor;
  setTitle('Posit-92 Clock');

  ReplaceColour(BorrowBMFontPtr(pico8Font)^.texHandle, white, Palette[1]);

  { Init your game state here }
  gameTime := 0.0
end;

procedure OnCleanup;
begin
  showCursor;
  freeBMFont(pico8Font)
end;

procedure Update;
begin
  if isKeyDown(SC_ESCAPE) then SignalDone;

  gameTime := gameTime + DeltaTime;
end;

procedure Draw;
var
  a: word;
  positNow: double;
  h, m, s: double;
  angle: double;
  x1, y1, x2, y2: double;

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
  printDefaultCentred(
    FormatDateTime('dd-mm-yyyy', now),
    vgaWidth div 2,
    vgaHeight * 3 div 4 - BorrowBMFontPtr(pico8Font)^.lineHeight - 2);

  dotw := DayOfTheWeek(now);
  { testStr := format('Today is %s', [GetDayName(dotw)]); }
  printDefaultCentred(GetDayName(dotw), vgaWidth div 2, vgaHeight * 3 div 4);


  positNow := getTimer;

  circfill(vgaWidth div 2, vgaHeight div 2, 2, Palette[1]);

  { Hour hand }
  h := positNow / 3600.0;
  angle := deg2rad(h * 30.0 - 90.0);
  x1 := cos(angle) * 24 + vgaWidth div 2;
  y1 := sin(angle) * 24 + vgaHeight div 2;
  line(vgaWidth div 2, vgaHeight div 2, round(x1), round(y1), palette[1]);

  { Minute hand }
  m := trunc(positNow) mod 3600 div 60 + frac(positNow / 60.0);
  angle := deg2rad(m * 6.0 - 90.0);
  x1 := cos(angle) * 36 + vgaWidth div 2;
  y1 := sin(angle) * 36 + vgaHeight div 2;
  line(vgaWidth div 2, vgaHeight div 2, round(x1), round(y1), palette[1]);

  { Second hand }
  s := trunc(positNow) mod 60 + frac(positNow);
  angle := deg2rad(s * 6.0 - 90.0);
  x1 := cos(angle) * 40 + vgaWidth div 2;
  y1 := sin(angle) * 40 + vgaHeight div 2;
  x2 := cos(angle) * -10 + vgaWidth div 2;
  y2 := sin(angle) * -10 + vgaHeight div 2;
  line(round(x1), round(y1), round(x2), round(y2), palette[1]);

  DrawFPS
end;


{$R *.res}

var
  appConfig: TP92AppConfig;
begin
  P92Start(@OnPreload, @OnReady, @Update, @Draw, @OnCleanup);
end.


