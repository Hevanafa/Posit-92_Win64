unit Sounds;

{$Mode TP}
{$B-}

interface

uses SDL2Wrapper;

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

uses Conv, Maths, Logger;

var
  soundsInitialised: boolean;
  soundList: array[0..9] of TSoundData;

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

  for a:=0 to high(soundList) do begin
    soundList[a].chunk := nil;
    soundList[a].volume := 1.0
  end;

  soundsInitialised := true
end;

procedure cleanupSounds;
var
  a: longint;
begin
  if not soundsInitialised then exit;

  for a:=0 to high(soundList) do
    if soundList[a].chunk <> nil then
      Mix_FreeChunk(soundList[a].chunk);

  Mix_CloseAudio;
  soundsInitialised := false
end;

procedure loadSound(const key: longint; const filename: string);
var
  chunk: PMix_Chunk;
begin
  if not soundsInitialised then exit;

  if (key < 0) or (key > high(soundList)) then begin
    writeLog('loadSound: Invalid sound key ' + i32str(key));
    exit
  end;

  chunk := Mix_LoadWAV(@filename[1]);
  if chunk = nil then begin
    writeLog('loadSound: Failed to load ' + filename);
    exit
  end;

  if soundList[key].chunk <> nil then begin
    writeLog('loadSound: Warning: Possible duplicate sound key ' + i32str(key));
    Mix_FreeChunk(soundList[key].chunk);
    exit
  end;

  soundList[key].chunk := chunk
end;

procedure playSound(const key: longint);
var
  sdlVolume: integer;
begin
  if not soundsInitialised then exit;
  if (key < 0) or (key > high(soundList)) then exit;
  if soundList[key].chunk = nil then exit;

  sdlVolume := round(soundList[key].volume * 128);
  Mix_VolumeChunk(soundList[key].chunk, sdlVolume);

  { -1: any available channel
    0: no looping }
  Mix_PlayChannel(-1, soundList[key].chunk, 0)
end;

procedure setSoundVolume(const key: longint; const volume: single);
begin
  if not soundsInitialised then exit;
  if (key < 0) or (key > high(soundList)) then exit;
  soundList[key].volume := clamp(volume, 0.0, 1.0)
end;

end.