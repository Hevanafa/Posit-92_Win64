program Game;

{$Mode ObjFPC}
{$H+}  { Use AnsiStrings }
{$J-}  { Don't allow assignments to typed consts }

uses
  SysUtils, SDL2,
  Posit92,
  P92Keyboard, P92Mouse, Sounds,
  P92Tex, P92TexDraw, TexRef, P92Geometry,
  P92Logger, P92Timing, P92Panic, P92VGA,
  Assets;

const
  TargetFPS = 60;
  FrameTime = 1000 div TargetFPS;

var
  { Game state variables }
  gameTime: double;

procedure drawMouse;
begin
  { spr(imgCursor, mouseX, mouseY) }
  HwSpr(hwCursor, mouseX, mouseY)
end;

procedure loadAssets;
begin
  { imgCursor := LoadImage('assets\images\cursor.png'); }
  hwCursor := HwLoadImage('assets\images\cursor.png');
  imgDosuEXE[0] := LoadImage('assets\images\dosu_1.png');
  imgDosuEXE[1] := LoadImage('assets\images\dosu_2.png');

  LoadBMFont(
    'assets\fonts\nokia_cellphone_fc_8.txt',
    defaultFont, defaultFontGlyphs);

  { Load more assets here }
end;

procedure init;
begin
  initVideoMem(320, 200, getmem(320 * 200 * 4));
  initDeltaTime;

  InitSDL;
  InitLogger;
end;

procedure afterInit;
begin
  SetTitle('Posit-92 with SDL2');

  loadAssets;
  HideCursor;

  { Init your game state here }
  gameTime := 0.0
end;

procedure cleanup;
begin
  ShowCursor;

  FreeTexture(imgCursor);
  FreeTexture(imgDosuEXE[0]);
  FreeTexture(imgDosuEXE[1]);
  FreeTexture(imgFullFont);

  FreeTexture(defaultFont.imgHandle);

  freemem(getSurfacePtr);

  { Your cleanup code here (after setting `done` to true) }
  CloseLogger;
  CleanupSDL
end;

procedure update;
begin
  UpdateSDL;
  updateDeltaTime;

  { Your update logic here }
  if IsKeyDown(SC_ESCAPE) then done := true;

  gameTime := gameTime + DeltaTime
end;

procedure draw;
begin
  { Begin software layer }
  cls($FF6495ED);

  if (trunc(gameTime * 4) and 1) > 0 then
    spr(imgDosuEXE[1], 148, 88)
  else
    spr(imgDosuEXE[0], 148, 88);

  printDefaultCentred('Hello world!', vgaWidth div 2, 120);

  printDefault(format('Mouse: { %d, %d }', [mouseX, mouseY]), 10, 10);

  VgaUpload;

  { Begin hardware layer }

  drawMouse;

  VgaPresent
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


