{ Entry point }

{$Mode TP}

uses
  Posit92, VGA;

type
  TGame = object(TPosit92)
  public
    procedure loadAssets;
  private
    done: boolean;

    procedure init;
    procedure afterInit;
    procedure cleanup;
    procedure update;
    procedure draw;
  end;

procedure TGame.loadAssets;
begin
  { Load more assets here }
end;

procedure TGame.init;
begin
  inherited init; { works the same as super.init() in JS }

  setTitle('Posit-92 with SDL2');

  initBuffer;
  { initDeltaTime }
end;

procedure TGame.afterInit;
begin
  loadAssets;

  { Init your game state here }
  done := false
end;

procedure TGame.cleanup;
begin
  inherited cleanup;


end;

procedure TGame.update;
begin

end;

procedure TGame.draw;
begin
  cls($FF6495ED);
  { cls($FFFF5555); } { test mode 13h red } { correct }
  { cls($FF55FF55); } { test mode 13h green } { output: magenta }
  { cls($FF5555FF); } { test mode 13h blue } { output: yellow }

  flush
end;


var
  game: TGame;

begin
  game.init;
  game.afterInit;

  game.draw;
  { TODO: Add the rest of the method calls }
  readln;

  game.cleanup;
end.
