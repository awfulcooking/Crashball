module Scenes
  class Winner
    DURATION = 2.seconds

    def initialize(player)
      @player = player
      @position = $state.players.key(player)
    end

    def init
      @started_at = tick_count
    end

    def tick
      background! [@player.color.r/2, @player.color.g/2, @player.color.b/2]

      scene! Gameplay.new if tick_count > @started_at + DURATION

      fade_in = easing.ease_spline @started_at, tick_count, DURATION, [
        [0, 0.4, 0.8, 1],
        [1, 0.8, 0.4, 0],
      ]

      labels << {
        x: grid.center.x,
        y: grid.center.y + 50,
        text: "#{@position.capitalize} wins!",
        font: "fonts/halo.ttf",
        size_enum: 18,
        alignment_enum: 1,
        r: 255, g: 255, b: 255,
        a: fade_in * 255,
      }
    end
  end
end
