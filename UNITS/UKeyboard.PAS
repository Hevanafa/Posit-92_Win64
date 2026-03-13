unit UKeyboard;

{$Mode TP}

interface

{ SDL Scancodes }
const
  SDL_SCANCODE_ESCAPE = 41;
  SDL_SCANCODE_SPACE = 44;
  SDL_SCANCODE_1 = 30;
  SDL_SCANCODE_2 = 31;
  SDL_SCANCODE_3 = 32;
  SDL_SCANCODE_4 = 33;
  SDL_SCANCODE_5 = 34;
  { Add more SDL scancodes here }

{ DOS Scancodes }
const
  SC_ESC = $01;
  SC_SPACE = $39;

  SC_1 = $02;
  SC_2 = $03;
  SC_3 = $04;
  SC_4 = $05;
  SC_5 = $06;
  { Add more DOS scancodes here }

function SDLToDOSScancode(const scancode: integer): integer;


implementation

function SDLToDOSScancode(const scancode: integer): integer;
var
  result: integer;
begin
  case scancode of
    SDL_SCANCODE_ESCAPE: result := SC_ESC;
    SDL_SCANCODE_SPACE: result := SC_SPACE;
    SDL_SCANCODE_1: result := SC_1;
    SDL_SCANCODE_2: result := SC_2;
    SDL_SCANCODE_3: result := SC_3;
    SDL_SCANCODE_4: result := SC_4;
    SDL_SCANCODE_5: result := SC_5;
    else result := 0;
  end;

  SDLToDOSScancode := result;
end;

end.
