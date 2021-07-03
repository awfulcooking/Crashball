module Sound
  @pitch_offset = rand / 2

  def new_pitch!
    @pitch_offset = rand / 2
  end

  def pitch_offset
    @pitch_offset
  end

  def sound_index
    @sound_index += 1
  end

  def sound_id(kind='')
    "_#{@sound_index}"
  end

  def play_background_music
    audio[:background_music] ||= {
      input: 'sounds/Crashball.ogg',
      looping: true,
      gain: 0.4,
    }
  end

  def toggle_background_music_mute
    audio[:background_music]&.paused = !audio[:background_music]&.paused
  end

  def play_game_start
    audio[:game_start] = {
      input: 'sounds/GameStart.wav',
      pitch: Sound.pitch_offset + rand/2 + 0.1 * (($state.num_game_starts += 1) % 20) # + ((rand < 0.2) ? -3 : 0)
    }
  end

  def play_net ball, position
    audio[sound_id('net')] = {
      input: 'sounds/GameStart.wav',
      pitch: Sound.pitch_offset + 0.3 + %i(top right left bottom).index(position) / 18.0,
      gain: 0.7
    }
  end

  def play_kick
    audio[sound_id('kick')] = {
      input: 'sounds/GameStart.wav', 
      pitch: Sound.pitch_offset + 0.2,
    }
  end
end

Sound.extend Sound
