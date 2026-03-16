program Game;

{$Mode ObjFPC}
{$H+}
{$J-}

uses
  SDL2, Posit92, Sounds,
  Keyboard, Mouse,
  Logger, ImgRef, ImgRefFast,
  Timing, VGA,
  Assets;

const
  TargetFPS = 60;
  FrameTime = 16;

var
  lastSpacebar: boolean;
  lastD1, lastD2, lastD3, lastD4, lastD5: boolean;

  { Game state variables }
  gameTime: double;


procedure drawMouse;
begin
  spr(imgCursor, mouseX, mouseY)
end;

procedure playRandomSFX;
begin
  playSound(1 + random(SfxSlip))
end;


procedure loadAssets;
begin
  imgCursor := loadImage('assets\images\cursor.png');
  imgDosuEXE[0] := loadImage('assets\images\dosu_1.png');
  imgDosuEXE[1] := loadImage('assets\images\dosu_2.png');
  imgFullFont := loadImage('assets\fonts\nokia_cellphone_fc_8_0.png');

  loadBMFont(
    'assets\fonts\nokia_cellphone_fc_8.txt',
    defaultFont, defaultFontGlyphs);

  loadSound(SfxBwonk, 'assets\sfx\bwonk.ogg');
  loadSound(SfxBite, 'assets\sfx\bite.ogg');
  loadSound(SfxBonk, 'assets\sfx\bonk.ogg');
  loadSound(SfxStrum, 'assets\sfx\strum.ogg');
  loadSound(SfxSlip, 'assets\sfx\slip.ogg');

  { Load more assets here }
end;

procedure init;
begin
  initVideoMem(320, 200, getmem(320 * 200 * 4));
  initDeltaTime;
  initSDL;

  initLogger;
  initSounds;
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
  cleanupSounds;
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

  if lastSpacebar <> isKeyDown(SC_SPACE) then begin
    lastSpacebar := isKeyDown(SC_SPACE);

    if lastSpacebar then playRandomSFX;
  end;

  if lastD1 <> isKeyDown(SC_1) then begin
    lastD1 := isKeyDown(SC_1);
    if lastD1 then playSound(1);
  end;

  if lastD2 <> isKeyDown(SC_2) then begin
    lastD2 := isKeyDown(SC_2);
    if lastD2 then playSound(2);
  end;

  if lastD3 <> isKeyDown(SC_3) then begin
    lastD3 := isKeyDown(SC_3);
    if lastD3 then playSound(3);
  end;

  if lastD4 <> isKeyDown(SC_4) then begin
    lastD4 := isKeyDown(SC_4);
    if lastD4 then playSound(4);
  end;

  if lastD5 <> isKeyDown(SC_5) then begin
    lastD5 := isKeyDown(SC_5);
    if lastD5 then playSound(5);
  end;

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

  s := '1, 2, 3, 4, 5 - Play sound';
  w := measureDefault(s);
  printDefault(s, (vgaWidth - w) div 2, 120);

  s := 'Spacebar - Play a random sound';
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


