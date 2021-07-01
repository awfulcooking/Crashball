module Sound
  def sound_index
    @sound_index += 1
  end

  def play_start_sound
    audio[:start_sound] = {
      input: 'sounds/GameStart.wav',
      pitch: rand/2 + 0.1 * (($state.num_game_starts += 1) % 20) # + ((rand < 0.2) ? -3 : 0)
    }
  end

  def play_net_sound ball, position
    audio["net_#{sound_index}}"] = {
      input: 'sounds/GameStart.wav',
      pitch: 0.3 + %i(top right left bottom).index(position) / 18.0,
      gain: 0.9
    }
  end

  def play_kick_sound
    audio["kick_#{sound_index}"] = {
      input: 'sounds/GameStart.wav', 
      pitch: 0.2,
    }
  end
end

include Sound
