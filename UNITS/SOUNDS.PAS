unit Sounds;

interface

type
  TSoundData = record
    chunk: PMix_Chunk;
    volume: single;
  end;

procedure initSounds;


implementation

var
  sounds: array[0..9] of TSoundData;

procedure initSounds;
var
  a: longint;
begin
  if Mix_OpenAudio(MIX_DEFAULT_FREQUENCY,
    MIX_DEFAULT_FORMAT,
    MIX_DEFAULT_CHANNELS, 2048) < 0 then
  begin
    writeLog('Couldn''t initialise SDL_Mixer!');
    exit
  end;

  for a:=0 to high(sounds) do begin
    sounds[a].chunk := nil;
    sounds[a].volume := 1.0
  end;
end;

end.