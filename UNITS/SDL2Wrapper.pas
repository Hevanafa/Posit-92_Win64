unit SDL2Wrapper;

{$Mode TP}

interface

const 
  SDL_INIT_VIDEO = $00000020;
  SDL_WINDOWPOS_CENTERED = $2FFF0000;
  SDL_WINDOW_SHOWN = $00000004;

  SDL_PIXELFORMAT_RGBA32 = $16462004;
  SDL_PIXELFORMAT_BGRA32 = $16762004;
  SDL_TEXTUREACCESS_STREAMING = 1;

  SDL_QUIT_ = $100;
  SDL_KEYDOWN = $300;
  SDL_KEYUP = $301;

type
  PSDL_Window = pointer;
  PSDL_Renderer = pointer;
  PSDL_Texture = pointer;

  PSDL_Event = ^TSDL_Event;
  TSDL_Event = packed record
    eventType: longword;
    padding: array[0..51] of byte;
  end;

  PSDL_Keysym = ^TSDL_Keysym;
  TSDL_Keysym = record
    scancode: longint;
    sym: longint;
    modifier: word;
    unused: longword;
  end;
  
  PSDL_KeyboardEvent = ^TSDL_KeyboardEvent;
  TSDL_KeyboardEvent = record
    eventType: longword;
    timestamp: longword;
    windowID: longword;
    state: byte;
    repeat_: byte;
    padding: array[0..1] of byte;
    keysym: TSDL_Keysym;
  end;

  PSDL_Surface = ^TSDL_Surface;
  TSDL_Surface = record
    flags: longword;
    format: pointer; { PSDL_PixelFormat }
    w, h: longint;
    pitch: longint;
    pixels: pointer;
    userdata: pointer;
    locked: longint;
    list_blitmap: pointer;
    clip_rect: pointer;
    map: pointer;
    refcount: longint;
  end;

function SDL_Init(flags: longword): longint; cdecl; external 'SDL2.dll';
function SDL_CreateWindow(title: PChar; x, y, w, h: longint; flags: longword): PSDL_Window; cdecl; external 'SDL2.dll';
function SDL_CreateRenderer(window: PSDL_Window; index: longint; flags: longword): PSDL_Renderer; cdecl; external 'SDL2.dll';
procedure SDL_SetWindowTitle(window: PSDL_Window; title: PChar); cdecl; external 'SDL2.dll';
procedure SDL_DestroyRenderer(renderer: PSDL_Renderer); cdecl; external 'SDL2.dll';
procedure SDL_DestroyWindow(window: PSDL_Window); cdecl; external 'SDL2.dll';
procedure SDL_Quit; cdecl; external 'SDL2.dll';

procedure SDL_Delay(ms: longword); cdecl; external 'SDL2.dll';
function SDL_GetTicks: longword; cdecl; external 'SDL2.dll';

procedure SDL_SetRenderDrawColor(renderer: PSDL_Renderer; r, g, b, a: byte); cdecl; external 'SDL2.dll';
procedure SDL_RenderClear(renderer: PSDL_Renderer); cdecl; external 'SDL2.dll';
procedure SDL_RenderPresent(renderer: PSDL_Renderer); cdecl; external 'SDL2.dll';

function SDL_CreateTexture(renderer: PSDL_Renderer; format: longword; access, w, h: longint): PSDL_Texture; cdecl; external 'SDL2.dll';
function SDL_UpdateTexture(texture: PSDL_Texture; rect, pixels: pointer; pitch: longint): longint; cdecl; external 'SDL2.dll';
function SDL_RenderCopy(renderer: PSDL_Renderer; texture: PSDL_Texture; srcrect, dstrect: pointer): longint; cdecl; external 'SDL2.dll';
procedure SDL_DestroyTexture(texture: PSDL_Texture); cdecl; external 'SDL2.dll';

function SDL_PollEvent(event: PSDL_Event): longint; cdecl; external 'SDL2.dll';

function IMG_Load(filename: PChar): PSDL_Surface; cdecl; external 'SDL2_image.dll';
procedure SDL_FreeSurface(surface: PSDL_Surface); cdecl; external 'SDL2.dll';


implementation

end.