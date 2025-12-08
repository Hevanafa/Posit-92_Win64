{$R game.res}

{$Mode TP}

uses
  SDL2Wrapper, Posit92, Sounds,
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

  { Init your game state here }
  gameTime: double;


type
  TGame = object(TPosit92)
  public
    procedure loadAssets;
  private
    procedure init;
    procedure afterInit;
    procedure cleanup;
    procedure update;
    procedure draw;
  end;

procedure drawMouse;
begin
  spr(imgCursor, mouseX, mouseY)
end;

procedure playRandomSFX;
begin
  playSound(1 + random(SfxSlip))
end;


procedure TGame.loadAssets;
begin
  imgCursor := loadImage('assets\images\cursor.png');
  imgDosuEXE[0] := loadImage('assets\images\dosu_1.png');
  imgDosuEXE[1] := loadImage('assets\images\dosu_2.png');

  loadBMFont(
    'assets\fonts\nokia_cellphone_fc_8.txt',
    defaultFont, defaultFontGlyphs);

  loadSound(SfxBwonk, 'assets\sfx\bwonk.ogg');
  loadSound(SfxBite, 'assets\sfx\bite.ogg');
  loadSound(SfxBonk, 'assets\sfx\bonk.ogg');
  loadSound(SfxStrum, 'assets\sfx\strum.ogg');
  { loadSound(SfxSlip, 'assets\sfx\slip.ogg'); }

  { Load more assets here }
end;

procedure TGame.init;
begin
  inherited init; { works the same as super.init() in JS }

  setTitle('Posit-92 with SDL2');

  initLogger;
  initBuffer;
  initDeltaTime;
  initSounds;
end;

procedure TGame.afterInit;
begin
  loadAssets;
  hideCursor;

  { Init your game state here }
  gameTime := 0.0
end;

procedure TGame.cleanup;
begin
  cleanupSounds;
  showCursor;

  { Your cleanup code here (after setting `done` to true) }

  inherited cleanup;
  closeLogger;
end;

procedure TGame.update;
begin
  inherited update;
  updateDeltaTime;

  { Your update logic here }
  if isKeyDown(SC_ESC) then done := true;

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

procedure TGame.draw;
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
  game: TGame;
  lastFrameTime, frameTimeNow, elapsed: longword; { in ms }

begin
  game.init;
  game.afterInit;

  game.done := false;

  lastFrameTime := SDL_GetTicks;

  while not game.done do begin
    frameTimeNow := SDL_GetTicks;
    elapsed := frameTimeNow - lastFrameTime;

    if elapsed >= FrameTime then begin
      lastFrameTime := frameTimeNow - (elapsed mod FrameTime); { Carry over extra time }
      game.update;
      game.draw
    end;

    SDL_Delay(1)
  end;

  game.cleanup
end.
