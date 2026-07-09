unit P92Core;

{$Mode ObjFPC}
{$H-}  { Use ShortStrings }
{$J+}  { Don't allow assignments to typed consts }

interface

{$ifdef Windows}
uses SDL2, P92Tex, P92BMFont;
{$endif}

{$ifdef P92_WASM}
function GetBootOptionBoolean(key: string): boolean;
function JsGetBootOptionBoolean: boolean; external 'env' name 'JsGetBootOptionBoolean';

procedure InitEngine; public name 'InitEngine';
function GetCgaFontHandle: longint;
procedure SetCGAFontHandle(value: longint);

function IsEngineReady: boolean; public name 'IsEngineReady';
procedure HostCallOnPreload; external 'env' name 'HostCallOnPreload';
procedure HostCallOnReady; external 'env' name 'HostCallOnReady';
{$endif}

procedure P92Boot; public name 'P92Boot';
procedure P92Update; public name 'P92Update';
procedure P92Draw; public name 'P92Draw';
procedure P92AfterDraw; public name 'P92AfterDraw';

procedure PrintChar(const c: char; const x, y: smallint);
procedure Print(const txt: string; const x, y: smallint);
procedure PrintWrap(const txt: string; x, y, wrapWidth: smallint);

{$ifdef Windows}
type
  TCallback = procedure;

procedure SignalDone;
procedure P92Start(
  OnPreload: TCallback;
  OnReady: TCallback;
  Update: TCallback;
  Draw: TCallback;
  OnCleanup: TCallback
);

procedure SetTitle(const value: string);

procedure HideCursor;
procedure ShowCursor;

function IsKeyDown(const scancode: integer): boolean;

function LoadImage(const filename: string): TTextureHandle;
function LoadBMFont(const filename: string): TBMFontHandle;

function HwLoadImage(const filename: string): longint;

{ Uploads the pixel data to the GPU }
procedure VgaUpload;
procedure VgaPresent;
{$endif}


implementation

uses
{$ifdef Windows}
  SysUtils, SDL2_Image,
  P92Fonts, P92Conversions, P92AssetRegistry, P92Logger,
  P92Keyboard, P92Mouse,
  P92TexDraw, P92TexRef,
  P92Strings, P92Timing, P92FPS, P92Sounds,
  P92VGA
{$endif}
{$ifdef P92_WASM}
  P92Fonts, P92AssetRegistry,
  P92Conversions,
  P92FPS, P92Logger,
  P92Sounds, P92Timing,
  P92Keyboard, P92Mouse,
  P92TexDraw, P92VGA, P92WasmHost, P92WasmMemMgr, P92InteropBuf, P92Loading,
{$endif}
{$ifdef P92_IMMEDIATE_GUI}
  , P92ImmediateGUI
{$endif}
{$ifdef P92_WEBGL}
  , P92WebGL
{$endif}
  ;

{$ifdef Windows}
const
  TargetFPS = 60;
  FrameTime = 1000 div TargetFPS;

var
  done: boolean;

  displayScale: smallint;
  window: PSDL_Window;
  renderer: PSDL_Renderer;
  vgaTexture: PSDL_Texture;

  keyState: array[0..127] of boolean;  { use DOS scancode }

  lastFrameTime, frameTimeNow, elapsed: longword; { in ms }

  hwCursor: longint;
{$endif}

type
  TEngineRunStates = (
    ersBoot = 1,
    ersPreload = 2,
    ersReady = 3
  );

const
  DebugEngineRunStates = true;

var
  engineRunState: TEngineRunStates;
  enableDefaultBMFont: boolean;

  { Default boot font }
  cgaFontHandle: longint;

  { Screenshot feature }
  lastF2: boolean;
  enableScreenshotHotkey: boolean;

{$ifdef Windows}
procedure InitSDL(const aDisplayScale: smallint = 2); forward;
procedure UpdateSDL; forward;
procedure CleanupSDL; forward;
{$endif}

function GetCgaFontHandle: longint;
begin
  GetCgaFontHandle := cgaFontHandle
end;

{$ifdef P92_WASM}
function GetBootOptionBoolean(key: string): boolean;
begin
  WriteInteropString(key);
  GetBootOptionBoolean := JsGetBootOptionBoolean
end;
{$endif}

procedure InitEngine;
begin
  engineRunState := ersBoot;
  if DebugEngineRunStates then
    writelog('ersBoot');

{$ifdef P92_WASM}
  InitHeapMgr;
  InitInteropBuffer;
{$endif}

  InitDeltaTime;
  InitFPSCounter;

  InitAssetRegistry;
  InitSounds;

{$ifdef P92_WEBGL}
  SetupWebGLViewport;
  SetupWebGLShaders;
{$endif}

{$ifdef P92_WASM}
  { Read boot options }

  enableDefaultBMFont := GetBootOptionBoolean('defaultFont');
  enableScreenshotHotkey := GetBootOptionBoolean('enableScreenshotHotkey');
{$endif}
end;

procedure SetCGAFontHandle(value: longint);
begin
  cgaFontHandle := value
end;

function IsEngineReady: boolean;
begin
  IsEngineReady := engineRunState = ersReady
end;

procedure P92Boot;
begin
{$ifdef P92_WASM}
  cgaFontHandle := RequestImage('assets/CGA8x8.png');
{$endif}

{$ifdef P92_SDL2}
  initVideoMem(320, 200, getmem(320 * 200 * 4));
  initDeltaTime;

  InitSDL;
  InitLogger;
{$endif}
end;

procedure InitPreloadState;
begin
{$ifdef P92_WASM}
  FitCanvas;
{$endif}

  engineRunState := ersPreload;

  if DebugEngineRunStates then
    writelog('ersPreload');

  if enableDefaultBMFont then
    LoadDefaultFont;

{$ifdef Windows}
  { imgCursor := LoadImage('assets\images\cursor.png'); }
  hwCursor := HwLoadImage('assets\images\cursor.png');
  LoadDefaultFont;
{$endif}
{$ifdef P92_WASM}
  HostCallOnPreload
{$endif}
end;

procedure InitReadyState;
begin
{$ifdef P92_WASM}
  FitCanvas;
{$endif}

  engineRunState := ersReady;

  if DebugEngineRunStates then
    writelog('ersReady');

{$ifdef P92_IMMEDIATE_GUI}
  InitImmediateGUI;
{$endif}

{$ifdef P92_WASM}
  HostCallOnReady
{$endif}
end;

procedure P92Update;
begin
{$ifdef Windows}
    UpdateSDL;
    UpdateDeltaTime;
    IncrementFPS;
{$endif}

{$ifdef P92_WASM}
  if engineRunState = ersBoot then begin
    if AllAssetsReady then
      InitPreloadState;
    exit
  end

  else if engineRunState = ersPreload then begin
    if AllAssetsReady then
      InitReadyState;
    exit
  end

  else if engineRunState = ersReady then begin
    UpdateDeltaTime;
    IncrementFPS;
{$ifdef P92_IMMEDIATE_GUI}
    ResetWidgetIndices;

    UpdateGUILastMouseButton;
    UpdateMouse;
    UpdateGUIMousePoint;
{$else}
    UpdateMouse;
{$endif}

    if enableScreenshotHotkey then begin
      if lastF2 <> isKeyDown(SC_F2) then begin
        lastF2 := isKeyDown(SC_F2);

        if lastF2 then JsTakeScreenshot;
      end;
    end;
  end;
{$endif}
end;

procedure DrawMouse;
begin
  { spr(imgCursor, mouseX, mouseY) }
  HwSpr(hwCursor, mouseX, mouseY)
end;

procedure P92Draw;
begin
  cls($FF000000);

{$ifdef P92_WASM}
  if engineRunState = ersPreload then
    RenderLoadingScreen;
{$endif}
end;

procedure P92AfterDraw;
begin
{$ifdef P92_IMMEDIATE_GUI}
  ResetActiveWidget;
{$endif}

{$ifdef P92_WEBGL}
  VgaUpload;
  WebGLPresent;
{$else}
  VgaUpload;
  { Begin hardware layer }
  DrawMouse;
  VgaPresent
{$endif}
end;

procedure PrintChar(const c: char; const x, y: smallint);
var
  row, col: smallint;
begin
  if not (ord(c) in [1..255]) then exit;

  row := ord(c) div 16;
  col := ord(c) mod 16;

  SprRegion(
    cgaFontHandle,
    col * 8, row * 8,
    8, 8,
    x, y)
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

procedure PrintWrap(const txt: string; x, y, wrapWidth: smallint);
var
  c: char;
  left: smallint;
begin
  left := 0;

  for c in txt do begin
    if c = #10 then begin
      left := 0;
      inc(y, 8);
      continue;
    end;
    if c = #13 then continue;

    PrintChar(c, x + left, y);
    inc(left, 8);

    if left >= wrapWidth then begin
      left := 0;
      inc(y, 8);
    end;
  end;
end;

{$ifdef Windows}
procedure SignalDone;
begin
  done := true
end;

procedure P92Cleanup;
begin
  { TODO: free both the imgCursor and the default font }
  { FreeTexture(imgCursor);
  FreeTexture(defaultFont.imgHandle); }

  freemem(getSurfacePtr);
end;

procedure P92Shutdown;
begin
  CloseLogger;
  CleanupSDL
end;

procedure P92Start(
  OnPreload: TCallback;
  OnReady: TCallback;
  Update: TCallback;
  Draw: TCallback;
  OnCleanup: TCallback
);
begin
  P92Boot;

  InitPreloadState;
  OnPreload;
  InitReadyState;
  OnReady;

  done := false;

  { Game loop }
  lastFrameTime := SDL_GetTicks;

  while not done do begin
    frameTimeNow := SDL_GetTicks;
    elapsed := frameTimeNow - lastFrameTime;

    if elapsed >= FrameTime then begin
      P92Update;

      { User loop }
      Update;
      Draw;

      P92AfterDraw;

      lastFrameTime := frameTimeNow - (elapsed mod FrameTime) { Carry over extra time }
    end;

    SDL_Delay(1)
  end;

  OnCleanup;

  P92Cleanup;
  P92Shutdown
end;

procedure InitSDL(const aDisplayScale: smallint);
begin
  if SDL_Init(SDL_INIT_VIDEO) <> 0 then begin
    writeln('SDL_Init failed!');
    halt(1)
  end;

  displayScale := aDisplayScale;

  window := SDL_CreateWindow(
    'SDL2 Window',
    SDL_WINDOWPOS_CENTERED, SDL_WINDOWPOS_CENTERED,
    vgaWidth * displayScale, vgaHeight * displayScale,
    SDL_WINDOW_SHOWN);

  renderer := SDL_CreateRenderer(window, -1, SDL_RENDERER_ACCELERATED);
  SDL_RenderSetLogicalSize(renderer, vgaWidth, vgaHeight);

  vgaTexture := SDL_CreateTexture(
    renderer,
    SDL_PIXELFORMAT_RGBA32, SDL_TEXTUREACCESS_STREAMING,
    vgaWidth, vgaHeight);

  HwSetRenderer(renderer)
end;

procedure SetTitle(const value: string);
begin
  SDL_SetWindowTitle(window, @value[1])
end;


procedure UpdateSDL;
var
  event: TSDL_Event;
  keyEvent: PSDL_KeyboardEvent;
  dosScancode: integer;
  mouseEvent: PSDL_MouseMotionEvent;
  buttonEvent: PSDL_MouseButtonEvent;
begin
  while SDL_PollEvent(@event) <> 0 do begin
    { case event.eventType of } { SDL2Wrapper }
    case event.type_ of
      { SDL_QUIT_: } { SDL2Wrapper }
      SDL_QUITEV:
        done := true;

      { Keyboard }
      SDL_KEYDOWN: begin
        keyEvent := PSDL_KeyboardEvent(@event);
        if keyEvent^.repeat_ = 0 then begin
          dosScancode := SDLToDOSScancode(keyEvent^.keysym.scancode);

          if dosScancode <> 0 then
            keyState[dosScancode] := true;
        end;
      end;

      SDL_KEYUP: begin
        keyEvent := PSDL_KeyboardEvent(@event);
        dosScancode := SDLToDOSScancode(keyEvent^.keysym.scancode);

        if dosScancode <> 0 then
          keyState[dosScancode] := false;
      end;

      { Mouse }
      SDL_MOUSEMOTION: begin
        mouseEvent := PSDL_MouseMotionEvent(@event);
        mouseX := mouseEvent^.x;
        mouseY := mouseEvent^.y;
      end;

      SDL_MOUSEBUTTONDOWN: begin
        buttonEvent := PSDL_MouseButtonEvent(@event);
        case buttonEvent^.button of
          SDL_BUTTON_LEFT:
            mouseButton := mouseButton or MouseButtonLeft;
          SDL_BUTTON_RIGHT:
            mouseButton := mouseButton or MouseButtonRight;
        end;
      end;

      SDL_MOUSEBUTTONUP: begin
        buttonEvent := PSDL_MouseButtonEvent(@event);
        case buttonEvent^.button of
          SDL_BUTTON_LEFT:
            mouseButton := mouseButton xor MouseButtonLeft;
          SDL_BUTTON_RIGHT:
            mouseButton := mouseButton xor MouseButtonRight;
        end;
      end;
    end;
  end;
end;

procedure CleanupSDL;
begin
  { Important: Destroy objects in reverse order }
  SDL_DestroyRenderer(renderer);
  SDL_DestroyWindow(window);
  SDL_Quit
end;


procedure HideCursor;
begin
  SDL_ShowCursor(SDL_DISABLE)
end;

procedure ShowCursor;
begin
  SDL_ShowCursor(SDL_ENABLE)
end;

function IsKeyDown(const scancode: integer): boolean;
begin
  isKeyDown := keyState[scancode]
end;

function LoadImage(const filename: string): TTextureHandle;
var
  strBuffer: array[0..255] of char;
  surface: PSDL_Surface;
  texHandle: TTextureHandle;
  texture: PSoftwareTex;
  src, dest: PByte;
begin
  { writeLog('loadImage ' + filename); }

  strpcopy(strBuffer, filename);
  surface := IMG_Load(strBuffer);

  if surface = nil then begin
    writeLog('loadImage: Failed to load ' + filename);
    loadImage := -1;
    exit
  end;

  if surface^.format^.BitsPerPixel <> 32 then begin
    WriteWarn('loadImage: Warning: ' + filename + ' is not 32 BPP!');
    writeLog('loadImage: Convert it to 32 BPP then reload');
    SDL_FreeSurface(surface);
    loadImage := -1;
    exit
  end;

  texHandle := NewTexture(surface^.w, surface^.h);
  texture := BorrowTexturePtr(texHandle);

  src := PByte(surface^.pixels);
  dest := texture^.pixelData;
  move(src^, dest^, surface^.w * surface^.h * 4);

  SDL_FreeSurface(surface);
  loadImage := texHandle
end;

{ 32 to 126: 0 to 94 }
function LoadBMFont(const filename: string): TBMFontHandle;
var
  fontHandle: TBMFontHandle;
  font: PBMFont;

  f: text;
  textureFilename: string;
  txtLine: string;
  a: word;
  pairs: array[0..15] of string;
  pair: array[0..1] of string;
  k, v: string;
  newGlyph: TBMFontGlyph;
  glyphCount: word;
begin
  fontHandle := FindUnusedBMFontHandle;

  bmfonts[fontHandle].status := AssetStatusLoading;
  bmfonts[fontHandle].errorCode := 0;

  LoadBMFont := fontHandle;
  font := BorrowBMFontPtr(fontHandle);

  assign(f, filename);
  {$I-} reset(f); {$I+}

  if IOResult <> 0 then begin
    writeLog('Failed to open BMFont file: ' + filename);
    exit
  end;

  glyphCount := 0;

  while not eof(f) do begin
    readln(f, txtLine);

    if startsWith(txtLine, 'info') then begin
      split(txtLine, ' ', pairs);

      for a:=0 to high(pairs) do begin
        split(pairs[a], '=', pair);
        k := pair[0]; v := pair[1];

        { writeln('info ', k); }

        { if k = 'face' then
          font^.face := replaceAll(v, '"', '')
        else} if k = 'spacing' then begin
          split(v, ',', pair);
          font^.spacing[0] := parseInt(pair[0]);
          font^.spacing[1] := parseInt(pair[1]);
        end;
      end;

      { writeLog('font.face:' + font.face) }

    end else if startsWith(txtLine, 'common') then begin
      split(txtLine, ' ', pairs);

      for a:=0 to high(pairs) do begin
        split(pairs[a], '=', pair);
        k := pair[0]; v := pair[1];

        if k = 'lineHeight' then
          font^.lineHeight := parseInt(v);
      end;

    end else if startsWith(txtLine, 'page') then begin
      split(txtLine, ' ', pairs);

      for a:=0 to high(pairs) do begin
        split(pairs[a], '=', pair);
        k := pair[0]; v := pair[1];

        if k = 'file' then
          textureFilename := replaceAll(v, '"', '');
      end;

    end else if startsWith(txtLine, 'char') and not startsWith(txtLine, 'chars') then begin
      while contains(txtLine, '  ') do
        txtLine := replaceAll(txtLine, '  ', ' ');

      newGlyph := default(TBMFontGlyph);

      { Parse the whole line first, then copy the record to the list of font glyphs }
      split(txtLine, ' ', pairs);

      for a:=0 to high(pairs) do begin
        split(pairs[a], '=', pair);
        k := pair[0]; v := pair[1];

        { case-of can't be used with strings in Mode TP }
        if k = 'id' then
          newGlyph.id := parseInt(v)
        else if k = 'x' then
          newGlyph.x := parseInt(v)
        else if k = 'y' then
          newGlyph.y := parseInt(v)
        else if k = 'width' then
          newGlyph.width := parseInt(v)
        else if k = 'height' then
          newGlyph.height := parseInt(v)
        else if k = 'xoffset' then
          newGlyph.xoffset := parseInt(v)
        else if k = 'yoffset' then
          newGlyph.yoffset := parseInt(v)
        else if k = 'xadvance' then
          newGlyph.xadvance := parseInt(v);
      end;

      if newGlyph.id in [low(font^.glyphs)..high(font^.glyphs)] then begin
        font^.glyphs[newGlyph.id] := newGlyph;
        inc(glyphCount)
      end;
    end;
  end;

  close(f);

  { writeLog('Loaded ' + i32str(glyphCount) + ' glyphs'); }
  bmfonts[fontHandle].status := AssetStatusReady;
  bmfonts[fontHandle].errorCode := 0;

  font^.texHandle := LoadImage(textureFilename)
end;


function HwLoadImage(const filename: string): longint;
var
  surface: PSDL_Surface;
  tex: PSDL_Texture;
begin
  surface := IMG_Load(pchar(ansistring(filename)));
  if surface = nil then begin
    writelog('IMG_Load failed: ' + SDL_GetError);
    exit(-1)
  end;

  tex := SDL_CreateTextureFromSurface(renderer, surface);
  if tex = nil then begin
    writelog('CreateTexture failed: ' + SDL_GetError);
    exit(-1)
  end;

  SDL_FreeSurface(surface);

  SDL_SetTextureBlendMode(tex, SDL_BLENDMODE_BLEND);
  hwLoadImage := HwRegisterTexRef(tex, surface^.w, surface^.h);

  { writelog(format('hwLoadImage %d: %s', [hwLoadImage, filename])) }
end;

procedure VgaUpload;
begin
  { SDL_SetRenderDrawColor(renderer, $ed, $95, $64, $ff);
  SDL_RenderClear(renderer); }

  SDL_SetTextureBlendMode(vgaTexture, SDL_BLENDMODE_BLEND);
  SDL_UpdateTexture(vgaTexture, nil, getSurfacePtr, vgaWidth * 4); { pitch = width * 4 bytes }
  SDL_RenderCopy(renderer, vgaTexture, nil, nil)
end;

procedure VgaPresent;
begin
  SDL_RenderPresent(renderer)
end;
{$endif}

end.

