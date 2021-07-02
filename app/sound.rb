module Sound
  @@pitch_offset = rand / 2

  def self.new_pitch!
    @pitch_offset = rand / 2
  end

  def self.pitch_offset
    @@pitch_offset
  end

  def sound_index
    @sound_index += 1
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

  def play_start_sound
    audio[:start_sound] = {
      input: 'sounds/GameStart.wav',
      pitch: Sound.pitch_offset + rand/2 + 0.1 * (($state.num_game_starts += 1) % 20) # + ((rand < 0.2) ? -3 : 0)
    }
  end

  def play_net_sound ball, position
    return false
    audio["net_#{sound_index}}"] = {
      input: 'sounds/GameStart.wav',
      pitch: Sound.pitch_offset + 0.3 + %i(top right left bottom).index(position) / 18.0,
      gain: 0.7
    }
  end

  def play_kick_sound
    audio["kick_#{sound_index}"] = {
      input: 'sounds/GameStart.wav', 
      pitch: Sound.pitch_offset + 0.2,
    }
  end
end

include Sound
