unit Keyboard;

{$Mode TP}

interface

{ SDL Scancodes }
const
  SDL_SCANCODE_ESCAPE = 41;
  SDL_SCANCODE_SPACE = 44;
  SDL_SCANCODE_1 = 30;
  SDL_SCANCODE_0 = 39;
  { Add more SDL scancodes here }

{ DOS Scancodes }
const
  SC_ESCAPE = $01;
  SC_1 = $02;
  SC_2 = $03;
  SC_3 = $04;
  SC_4 = $05;
  SC_5 = $06;
  SC_6 = $07;
  SC_7 = $08;
  SC_8 = $09;
  SC_9 = $0A;
  SC_0 = $0B;

  SC_SPACE = $39;

  { Add more DOS scancodes here }

function SDLToDOSScancode(const scancode: integer): integer;


implementation

function SDLToDOSScancode(const scancode: integer): integer;
var
  result: integer;
begin
  if (scancode in [SDL_SCANCODE_1..SDL_SCANCODE_0]) then begin
    result := scancode - (SDL_SCANCODE_1 - SC_1);
    SDLToDOSScancode := result;
    exit
  end;

  case scancode of
    SDL_SCANCODE_ESCAPE: result := SC_ESC;
    SDL_SCANCODE_SPACE: result := SC_SPACE;
    else result := 0;
  end;

  SDLToDOSScancode := result;
end;

end.
