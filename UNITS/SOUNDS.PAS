unit Sounds;

{$Mode TP}
{$B-}

interface

type
  TSoundData = record
    chunk: PMix_Chunk;
    volume: single;
  end;

procedure initSounds;
procedure cleanupSounds;
procedure loadSound(const key: longint; const filename: string);
procedure playSound(const key: longint);
procedure setSoundVolume(const key: longint; const volume: single);


implementation

uses Maths, Logger;

var
  soundsInitialised: boolean;
  sounds: array[0..9] of TSoundData;

procedure initSounds;
var
  a: longint;
begin
  soundsInitialised := false;

  if Mix_OpenAudio(MIX_DEFAULT_FREQUENCY,
    MIX_DEFAULT_FORMAT,
    MIX_DEFAULT_CHANNELS, 2048) < 0 then
  begin
    writeLog('initSounds: Couldn''t initialise SDL_Mixer!');
    exit
  end;

  for a:=0 to high(sounds) do begin
    sounds[a].chunk := nil;
    sounds[a].volume := 1.0
  end;

  soundsInitialised := true
end;

procedure cleanupSounds;
var
  a: longint;
begin
  if not soundsInitialised then exit;

  for a:=0 to high(sounds) do
    if sounds[a].chunk <> nil then
      Mix_FreeChunk(sounds[a].chunk);

  Mix_CloseAudio;
  soundsInitialised := false
end;

procedure loadSound(const key: longint; const filename: string);
var
  chunk: PMix_Chunk;
begin
  if not soundsInitialised then exit;

  if (key < 0) or (key > high(sounds)) then begin
    writeLog('loadSound: Invalid sound key ' + i32str(key));
    exit
  end;

  chunk := Mix_LoadWAV(PChar(filename));
  if chunk = nil then begin
    writeLog('loadSound: Failed to load ' + filename);
    exit
  end;

  if sounds[key].chunk <> nil then begin
    writeLog('loadSound: Warning: Possible duplicate sound key ' + i32str(key));
    Mix_FreeChunk(sounds[key].chunk);
    exit
  end;

  sounds[key].chunk := chunk
end;

procedure playSound(const key: longint);
var
  sdlVolume: integer;
begin
  if not soundsInitialised then exit;
  if (key < 0) or (key > high(sounds)) then exit;
  if sounds[key].chunk = nil then exit;

  sdlVolume := round(sounds[key].volume * 128);
  Mix_VolumeChunk(sounds[key].chunk, sdlVolume);

  { -1: any available channel
    0: no looping }
  Mix_PlayChannel(-1, sounds[key].chunk, 0)
end;

procedure setSoundVolume(const key: longint; const volume: single);
begin
  if not soundsInitialised then exit;
  if (key < 0) or (key > high(sounds)) then exit;
  sounds[key].volume := clamp(volume, 0.0, 1.0)
end;

end.