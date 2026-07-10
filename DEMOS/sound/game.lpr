program Game;

{$Mode ObjFPC}
{$H+}
{$J-}

uses
  SDL2,
  P92Core, P92Fonts, P92Sounds,
  P92Keyboard, P92Mouse,
  P92Logger,
  P92Tex, P92TexDraw,
  P92Timing, P92VGA,
  Assets;

var
  lastSpacebar: boolean;
  lastD1, lastD2, lastD3, lastD4, lastD5: boolean;

  { Game state variables }
  gameTime: double;


procedure DrawMouse;
begin
  spr(imgCursor, mouseX, mouseY)
end;

procedure PlayRandomSFX;
begin
  playSound(1 + random(SfxSlip))
end;


procedure OnPreload;
begin
  InitSounds;

  imgCursor := LoadImage('assets\images\cursor.png');
  imgDosuEXE[0] := LoadImage('assets\images\dosu_1.png');
  imgDosuEXE[1] := LoadImage('assets\images\dosu_2.png');

  LoadSound(SfxBwonk, 'assets\sfx\bwonk.ogg');
  LoadSound(SfxBite, 'assets\sfx\bite.ogg');
  LoadSound(SfxBonk, 'assets\sfx\bonk.ogg');
  LoadSound(SfxStrum, 'assets\sfx\strum.ogg');
  LoadSound(SfxSlip, 'assets\sfx\slip.ogg');

  { Load more assets here }
end;

procedure OnReady;
begin
  hideCursor;

  { Init your game state here }
  gameTime := 0.0
end;

procedure OnCleanup;
begin
  CleanupSounds;
  ShowCursor;

  FreeTexture(imgCursor);
  FreeTexture(imgDosuEXE[0]);
  FreeTexture(imgDosuEXE[1]);
end;

procedure Update;
begin
  if isKeyDown(SC_ESCAPE) then SignalDone;

  if lastSpacebar <> isKeyDown(SC_SPACE) then begin
    lastSpacebar := isKeyDown(SC_SPACE);

    if lastSpacebar then PlayRandomSFX;
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

  gameTime := gameTime + DeltaTime
end;

procedure Draw;
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
end;


{$R *.res}

var
  appConfig: TP92AppConfig;
begin
  appConfig := DefaultP92AppConfig;

  with appConfig do begin
    windowTitle := 'Posit-92 with SDL2';
  end;

  appConfig.OnPreload := @OnPreload;
  appConfig.OnReady := @OnReady;
  appConfig.Update := @Update;
  appConfig.Draw := @Draw;
  appConfig.OnCleanup := @OnCleanup;

  P92Start(appConfig)
end.


