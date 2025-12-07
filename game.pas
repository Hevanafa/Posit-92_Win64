{ Entry point }

{$Mode TP}

uses
  Posit92;

type
  TGame = object(TPosit92)
  end;

var
  game: TGame;

begin
  game.init;
  readln
end.

