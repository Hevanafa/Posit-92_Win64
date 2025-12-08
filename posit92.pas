unit Posit92;

{$Mode TP}

interface

uses
  SDL2Wrapper,
  BMFont, Keyboard;

type
  TPosit92 = object
  public
    procedure init;
    procedure setTitle(const value: string);
    procedure cleanup;

    procedure hideCursor;
    procedure showCursor;

    function isKeyDown(const scancode: integer): boolean;
    function loadImage(const filename: string): longint;
    procedure loadBMFont(const filename: string; var font: TBMFont; var fontGlyphs: array of TBMFontGlyph);

    procedure update;
    procedure vgaFlush;
  protected
    done: boolean;
  private
    window: PSDL_Window;
    renderer: PSDL_Renderer;
    vgaTexture: PSDL_Texture;
    keyState: array[0..127] of boolean;  { use DOS scancode }
  end;


implementation

uses
  SysUtils,
  Conv, Logger, Mouse,
  ImgRef, Strings, VGA;

const
  displayScale = 2;

procedure TPosit92.init;
begin
  if SDL_Init(SDL_INIT_VIDEO) <> 0 then begin
    writeln('SDL_Init failed!');
    halt(1)
  end;

  window := SDL_CreateWindow(
    'SDL2 Window',
    SDL_WINDOWPOS_CENTERED, SDL_WINDOWPOS_CENTERED,
    vgaWidth * displayScale, vgaHeight * displayScale,
    SDL_WINDOW_SHOWN);

  renderer := SDL_CreateRenderer(window, -1, 0);

  vgaTexture := SDL_CreateTexture(
    renderer,
    SDL_PIXELFORMAT_BGRA32, SDL_TEXTUREACCESS_STREAMING,
    vgaWidth, vgaHeight);

  done := false
end;

procedure TPosit92.setTitle(const value: string);
begin
  SDL_SetWindowTitle(window, @value[1])
end;


procedure TPosit92.update;
var
  event: TSDL_Event;
  keyEvent: PSDL_KeyboardEvent;
  dosScancode: integer;
  mouseEvent: PSDL_MouseMotionEvent;
  buttonEvent: PSDL_MouseButtonEvent;
begin
  while SDL_PollEvent(@event) <> 0 do begin
    case event.eventType of 
      SDL_QUIT_: done := true;

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
        mouseX := mouseEvent^.x div displayScale;
        mouseY := mouseEvent^.y div displayScale;
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

procedure TPosit92.cleanup;
begin
  { Important: Destroy objects in reverse order }
  SDL_DestroyRenderer(renderer);
  SDL_DestroyWindow(window);
  SDL_Quit
end;


procedure TPosit92.hideCursor;
begin
  SDL_ShowCursor(SDL_DISABLE)
end;

procedure TPosit92.showCursor;
begin
  SDL_ShowCursor(SDL_ENABLE)
end;

function TPosit92.isKeyDown(const scancode: integer): boolean;
begin
  isKeyDown := keyState[scancode]
end;

function TPosit92.loadImage(const filename: string): longint;
var
  strBuffer: PChar; { array[0..255] of char; }
  bufferSize: word;

  surface: PSDL_Surface;
  imgHandle: longint;
  image: PImageRef;
  src, dest: PByte;
  a: longint;
begin
  writeLog('loadImage ' + filename);

  bufferSize := length(filename) + 1;
  getmem(strBuffer, bufferSize);
  strpcopy(strBuffer, filename);

  writeln(strBuffer);
  surface := IMG_Load(strBuffer);

  freemem(strBuffer, bufferSize);
  strBuffer := nil;

  if surface = nil then begin
    writeLog('loadImage: Failed to load ' + filename);
    loadImage := -1;
    exit
  end;

  imgHandle := newImage(surface^.w, surface^.h);
  image := getImagePtr(imgHandle);

  src := PByte(surface^.pixels);
  dest := image^.dataPtr;
  move(src^, dest^, surface^.w * surface^.h * 4);

  SDL_FreeSurface(surface);
  loadImage := imgHandle
end;

{ 32 to 126: 0 to 94 }
procedure TPosit92.loadBMFont(const filename: string; var font: TBMFont; var fontGlyphs: array of TBMFontGlyph);
var
  f: text;
  txtLine: string;
  a: word;
  pairs: array[0..9] of string;
  pair: array[0..1] of string;
  k, v: string;
  tempGlyph: TBMFontGlyph;
  glyphCount: word;
begin
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
        if k = 'face' then
          font.face := replaceAll(v, '"', '');
      end;

      { writeLog('font.face:' + font.face) }

    end else if startsWith(txtLine, 'common') then begin
      split(txtLine, ' ', pairs);

      for a:=0 to high(pairs) do begin
        split(pairs[a], '=', pair);
        k := pair[0]; v := pair[1];
        if k = 'lineHeight' then
          font.lineHeight := parseInt(v);
      end;
    
    end else if startsWith(txtLine, 'page') then begin
      split(txtLine, ' ', pairs);

      for a:=0 to high(pairs) do begin
        split(pairs[a], '=', pair);
        k := pair[0]; v := pair[1];
        if k = 'file' then
          font.filename := replaceAll(v, '"', '');
      end;

    end else if startsWith(txtLine, 'char') and not startsWith(txtLine, 'chars') then begin
      while contains(txtLine, '  ') do
        txtLine := replaceAll(txtLine, '  ', ' ');

      { Parse the whole nine first, then copy the record to the list of font glyphs }
      split(txtLine, ' ', pairs);

      for a:=0 to high(pairs) do begin
        split(pairs[a], '=', pair);
        k := pair[0]; v := pair[1];

        { case-of can't be used with strings in Mode TP }
        if k = 'id' then
          tempGlyph.id := parseInt(v)
        else if k = 'x' then
          tempGlyph.x := parseInt(v)
        else if k = 'y' then
          tempGlyph.y := parseInt(v)
        else if k = 'width' then
          tempGlyph.width := parseInt(v)
        else if k = 'height' then
          tempGlyph.height := parseInt(v)
        else if k = 'xoffset' then
          tempGlyph.xoffset := parseInt(v)
        else if k = 'yoffset' then
          tempGlyph.yoffset := parseInt(v)
        else if k = 'xadvance' then
          tempGlyph.xadvance := parseInt(v);
      end;

      { array of glyphs starts from 0, ends at 94 }
      { Assuming glyph.id always starts from 32 }
      if (tempGlyph.id - 32) in [low(fontGlyphs)..high(fontGlyphs)] then begin
        fontGlyphs[tempGlyph.id - 32] := tempGlyph;
        inc(glyphCount)
      end;
    end;
  end;

  close(f);

  writeLog('Loaded ' + i32str(glyphCount) + ' glyphs');

  font.imgHandle := loadImage(font.filename);

  writeLog('font.imgHandle');
  writeLogI32(font.imgHandle);
end;

procedure TPosit92.vgaFlush;
begin
{
  SDL_SetRenderDrawColor(renderer, $64, $95, $ED, $FF);
  SDL_RenderClear(renderer);
}

  SDL_UpdateTexture(vgaTexture, nil, getSurfacePtr, vgaWidth * 4); { pitch = width * 4 bytes }
  SDL_RenderCopy(renderer, vgaTexture, nil, nil);

  SDL_RenderPresent(renderer)
end;


end.
