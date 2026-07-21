program Game;

{$Mode ObjFPC}
{$H+}  { Use AnsiStrings }
{$J-}  { Don't allow assignments to typed consts }

uses
  SysUtils, SDL2,
  P92Core, P92CoreSDL2, P92Fonts, P92AssetRegistry,
  P92Conversions, P92Graphics,
  P92Keyboard, P92Mouse,
  P92Tex, P92TexDraw, P92Sounds,
  P92Logger, P92Timing, P92VGA,
  Assets;

const
  Black = $FF000000;
  DullWhite = $FFAAAAAA;
  Red = $FFFF0000;

var
  { Game state variables }
  gameTime: double;

procedure OnPreload;
begin
  imgSpecimenP92[0] := RequestImage('assets\images\specimen_p-92_1.png');
  imgSpecimenP92[1] := RequestImage('assets\images\specimen_p-92_2.png');

  imgEGAFont := RequestImage('assets\EGA8x14.png');
  imgCGAFont2y := RequestImage('assets\CGA8x16.png');;

  { Load more assets here }
end;

procedure OnReady;
begin
  HideCursor;

  { Init your game state here }
  gameTime := 0.0
end;

procedure OnCleanup;
begin
  ShowCursor;

  FreeTexture(imgSpecimenP92[0]);
  FreeTexture(imgSpecimenP92[1]);
end;


procedure PrintChar(const c: char; const x, y: smallint);
const
  GlyphWidth = 8;
  GlyphHeight = 16;
var
  row, col: smallint;
  texture: PSoftwareTex;
  a, b: smallint;
  colour: longword;
  alpha: byte;
  srcX, srcY: smallint;
  sx, sy: smallint;
  { offset of the pixel data array }
  offset: longword;
begin
  if not (ord(c) in [1..255]) then exit;

  row := ord(c) div 16;
  col := ord(c) mod 16;

  srcX := col * GlyphWidth;
  srcY := row * GlyphHeight;

  texture := BorrowTexturePtr(imgCGAFont2y);

  { glyph size: 8x16 }

  for b:=0 to GlyphHeight - 1 do
  for a:=0 to GlyphWidth - 1 do begin
    if (x + a > ClipX2) or (x + a < ClipX1)
      or (y + b > ClipY2) or (y + b < ClipY1) then continue;

    sx := srcX + a;
    sy := srcY + b;
    offset := (sx + sy * texture^.width) * 4;

    alpha := texture^.pixelData[offset + 3];
    if alpha < 255 then continue;

    colour := UnsafeSprPget(texture, sx, sy);
    UnsafePset(x + a, y + b, colour);
  end;
end;

procedure PrintCharColour(const c: char; const x, y: smallint; const colour: longword);
const
  GlyphWidth = 8;
  GlyphHeight = 16;
var
  row, col: smallint;
  texture: PSoftwareTex;
  a, b: smallint;
  alpha: byte;
  srcX, srcY: smallint;
  sx, sy: smallint;
  { offset of the pixel data array }
  offset: longword;
begin
  if not (ord(c) in [1..255]) then exit;

  row := ord(c) div 16;
  col := ord(c) mod 16;

  srcX := col * GlyphWidth;
  srcY := row * GlyphHeight;

  texture := BorrowTexturePtr(imgCGAFont2y);

  { glyph size: 8x16 }

  for b:=0 to GlyphHeight - 1 do
  for a:=0 to GlyphWidth - 1 do begin
    if (x + a > ClipX2) or (x + a < ClipX1)
      or (y + b > ClipY2) or (y + b < ClipY1) then continue;

    sx := srcX + a;
    sy := srcY + b;
    offset := (sx + sy * texture^.width) * 4;

    alpha := texture^.pixelData[offset + 3];
    if alpha < 255 then continue;

    UnsafePset(x + a, y + b, colour);
  end;
end;

procedure Print(const txt: string; const x, y: smallint);
var
  c: char;
  left: smallint;
begin
  left := x;

  for c in txt do begin
    PrintChar(c, left, y);
    inc(left, 8)
  end;
end;

procedure PrintColour(const txt: string; const x, y: smallint; const colour: longword);
var
  c: char;
  left: smallint;
begin
  left := x;

  for c in txt do begin
    PrintCharColour(c, left, y, colour);
    inc(left, 8)
  end;
end;

procedure Update;
begin
  if IsKeyDown(SC_ESCAPE) then SignalDone;

  gameTime := gameTime + DeltaTime
end;

procedure Draw;
var
  a: smallint;
begin
  cls(black);

  if (trunc(gameTime * 4) and 1) > 0 then
    spr(imgSpecimenP92[1], 148, 88)
  else
    spr(imgSpecimenP92[0], 148, 88);

  { Blinking cursor }
  if frac(GetTimer) >= 0.5 then
    rectfill(8, 16 * 4, 15, 16 * 5 - 1, DullWhite);

  PrintColour('Red text', 8, 32, red);

  { Footer area }
  print('F1 Help   F2 Run   F10 Exit', 8, VgaHeight - 16);

  { Title bar area }
  Print('Posit-92 Workstation', 8, 0);

  print(FormatDateTime('hh:nn', now), VgaWidth - 48, 0);
end;


{$R *.res}

var
  appConfig: TP92AppConfig;
begin
  appConfig := DefaultP92AppConfig;

  with appConfig do begin
    windowTitle := 'Posit-92 with SDL2';

    width := 8 * 80;
    height := 16 * 25;
    sdlScale := 1;

    fps := 18;

    enableDefaultFont := false;
  end;

  appConfig.OnPreload := @OnPreload;
  appConfig.OnReady := @OnReady;
  appConfig.Update := @Update;
  appConfig.Draw := @Draw;
  appConfig.OnCleanup := @OnCleanup;

  P92Start(appConfig)
end.

