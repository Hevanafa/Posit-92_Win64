{
  Sounds unit
  Part of Posit-92 game engine
  By Hevanafa

  This unit is specific to the Windows version
}
unit P92Sounds;

{$Mode ObjFPC}
{$H+}{$J-}

interface

{$ifdef P92_SDL2}
uses SDL2_Mixer, P92AssetRegistry;

procedure InitSounds;
procedure CleanupSounds;

procedure PlaySound(const sndHandle: longint);
procedure SetSoundVolume(const sndHandle: longint; const volume: single);
{$endif}


implementation

{$ifdef P92_SDL2}
uses
  SysUtils,
  P92Conversions, P92Maths, P92Logger;

var
  soundsInitialised: boolean;

procedure InitSounds;
var
  a: longint;
begin
  soundsInitialised := false;
  writeLog('initSounds begin');

  if Mix_OpenAudio(MIX_DEFAULT_FREQUENCY,
    MIX_DEFAULT_FORMAT,
    MIX_DEFAULT_CHANNELS, 2048) < 0 then
  begin
    writeLog('initSounds: Couldn''t initialise SDL_Mixer!');
    exit
  end;

  for a:=1 to high(sounds) do begin
    sounds[a] := default(TSoundEntry);
    sounds[a].volume := 1.0
  end;

  writeLog('initSounds end');
  soundsInitialised := true
end;

procedure CleanupSounds;
var
  a: longint;
begin
  if not soundsInitialised then exit;

  for a := 1 to high(sounds) do
    if sounds[a].chunk <> nil then
      Mix_FreeChunk(sounds[a].chunk);

  Mix_CloseAudio;
  soundsInitialised := false
end;


procedure PlaySound(const sndHandle: longint);
var
  sdlVolume: integer;
begin
  if not soundsInitialised then exit;
  if (sndHandle < 1) or (sndHandle > high(sounds)) then exit;

  if sounds[sndHandle].chunk = nil then begin
    writeWarn('Warning: Attempting to play a nil sound');
    exit
  end;

  sdlVolume := round(sounds[sndHandle].volume * 128);
  Mix_VolumeChunk(sounds[sndHandle].chunk, sdlVolume);

  { -1: any available channel
    0: no looping }
  Mix_PlayChannel(-1, sounds[sndHandle].chunk, 0)
end;

procedure SetSoundVolume(const sndHandle: longint; const volume: single);
begin
  if not soundsInitialised then exit;
  if (sndHandle < 1) or (sndHandle > high(sounds)) then exit;

  sounds[sndHandle].volume := clamp(volume, 0.0, 1.0)
end;
{$endif}

end.
