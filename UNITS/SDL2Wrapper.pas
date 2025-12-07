unit SDL2Wrapper;

{$Mode TP}

interface

const 
  SDL_INIT_VIDEO = $00000020;
  SDL_WINDOWPOS_CENTERED = $2FFF0000;
  SDL_WINDOW_SHOWN = $00000004;

  SDL_PIXELFORMAT_RGBA32 = $16462004;
  SDL_TEXTUREACCESS_STREAMING = 1;

type
  PSDL_Window = pointer;
  PSDL_Renderer = pointer;
  PSDL_Texture = pointer;

function SDL_Init(const flags: longword): longint; cdecl; external 'SDL2.dll';
function SDL_CreateWindow(const title: PChar; const x, y, w, h: longint; const flags: longword): PSDL_Window; cdecl; external 'SDL2.dll';
function SDL_CreateRenderer(const window: PSDL_Window; const index: longint; const flags: longword): PSDL_Renderer; cdecl; external 'SDL2.dll';
procedure SDL_DestroyRenderer(const renderer: PSDL_Renderer); cdecl; external 'SDL2.dll';
procedure SDL_DestroyWindow(const window: PSDL_Window); cdecl; external 'SDL2.dll';
procedure SDL_Quit; cdecl; external 'SDL2.dll';
procedure SDL_Delay(const ms: longword); cdecl; external 'SDL2.dll';

procedure SDL_SetRenderDrawColor(const renderer: PSDL_Renderer; const r, g, b, a: byte); cdecl; external 'SDL2.dll';
procedure SDL_RenderClear(const renderer: PSDL_Renderer); cdecl; external 'SDL2.dll';
procedure SDL_RenderPresent(const renderer: PSDL_Renderer); cdecl; external 'SDL2.dll';

function SDL_CreateTexture(const renderer: PSDL_Renderer; const format: longword; const access, w, h: longint): PSDL_Texture; cdecl; external 'SDL2.dll';
function SDL_UpdateTexture(texture: PSDL_Texture; rect, pixels: pointer; pitch: longint): longint; cdecl; external 'SDL2.dll';
function SDL_RenderCopy(renderer: PSDL_Renderer; texture: PSDL_Texture; srcrect, dstrect: pointer): longint; cdecl; external 'SDL2.dll';
function SDL_DestroyTexture(texture: PSDL_Texture); cdecl; external 'SDL2.dll';


implementation

end.