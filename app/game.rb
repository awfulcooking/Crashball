Maw!

time_ticks! log_interval: 180 unless production?

ACCELERATION_NORMAL = 0.9
ACCELERATION_MOVE = 0.9
ACCELERATION_BOOST = 0.95
ACCELERATION_BRAKE = 0.68

PLAYER_MIN_WIDTH = 150
PLAYER_HEIGHT = 40
PLAYER_MOVE_SPEED = 3
PLAYER_ELEVATION = 0

BOOST_AMOUNT = 30 # 10-ish is normal. try 50, 100, 150! then just press shift!

NET_SIZE = 3

init {
  Sound.new_pitch!
  Sound.play_game_start
  # Sound.play_background_music

  palette = generate_palette_5
  bg_color = palette[4]

  static_solids << $state.background = [
    0, 0, grid.w, grid.h,
    bg_color.r, bg_color.g, bg_color.b
  ]

  $state.players = {
    top:    player!(y: grid.h-PLAYER_HEIGHT-PLAYER_ELEVATION, w: grid.w, h: PLAYER_HEIGHT, color: palette[0]),
    right:  player!(x: grid.w-PLAYER_HEIGHT-PLAYER_ELEVATION, w: PLAYER_HEIGHT, h: grid.h, vertical: true, color: palette[1]),
    bottom: player!(y: PLAYER_ELEVATION, h: PLAYER_HEIGHT, color: palette[2], npc: false),
    left:   player!(x: PLAYER_ELEVATION, w: PLAYER_HEIGHT, h: grid.h, vertical: true, color: palette[3]),
  }

  $state.players.each { |(screen_position, player)|
    max_position = player.vertical ? grid.h/2 : grid.w/2
    position = max_position/2 + rand(200) - 100

    size = PLAYER_MIN_WIDTH + rand(player.vertical ? 50 : 200)

    if player.vertical
      player.y = position
      player.h = size
    else
      player.x = position
      player.w = size
    end

    player.controls = $controls[screen_position]
  }

  static_solids << $state.players.values

  $state.nets = {
    top:    {x: 0, y: grid.h-NET_SIZE, w: grid.w, h: NET_SIZE},
    right:  {x: grid.w-NET_SIZE, y: 0, w: NET_SIZE, h: grid.h},
    bottom: {x: 0, y: 0, w: grid.w, h: NET_SIZE},
    left:   {x: 0, y: 0, w: NET_SIZE, h: grid.h},
  }

  $state.balls = [ball!(), ball!()]
}

tick {
  if controls.reset_down?
    init
  end

  if controls.quit?
    exit
  end

  if controls.mute_down?
    Sound.toggle_background_music_mute
  end

  if controls.quicken_held? and tick_count % 10 == 0
    $state.balls << ball!()
  end

  sprites << $state.balls

  next if controls.pause_latch?

  input
  collision
  motion

  for player in $state.players.values
    if player.score.zero?
      player.a = 50 + (Math.sin(tick_count / 30) + 1) / 2 * 150
    end
  end

  if controls.debug?
    solids << $state.nets.values.map { |net|
      {r: 0, g: 0, b: 200, a: 130}.merge! net
    }

    labels << [200, 600, "Scores: #{$state.players.values.map(&:score)}", 18, 18, 18, 225]
    labels << [200, 560, "Scores: #{$state.players.values.map(&:score)}", 55, 215, 230, 220]
  end

  if controls.debug_framerate?
    primitives << $gtk.framerate_diagnostics_primitives
  end
}

def input
  for _, player in $state.players
    controls = player[:controls]

    if controls.left?
      player.v -= PLAYER_MOVE_SPEED
    end

    if controls.right?
      player.v += PLAYER_MOVE_SPEED
    end

    if controls.left? or controls.right?
      player.npc = false
    end

    if controls.boost_down?
      player.v += BOOST_AMOUNT * player.v.sign
    end

    player.dv = case true
      when controls.brake?
        ACCELERATION_BRAKE
      when controls.boost?
        ACCELERATION_BOOST
      when controls.left?, controls.right?
        ACCELERATION_MOVE
      else
        ACCELERATION_NORMAL
      end
  end
end

def motion
  demo_npcs
  move_players
  move_balls
end

def move_players
  for position, player in $state.players
    if player.vertical
      player.y += player.v
    else
      player.x += player.v
    end

    player.v *= player.dv
  end
end

def demo_npcs
  for position, player in $state.players
    if player.npc and player.score > 0
      next unless rand < 0.02

      player.v += rand(50).rand_sign
    end
  end
end

def move_balls
  for ball in $state.balls # haha.. balls
    ball.prev_x = ball.x
    ball.prev_y = ball.y
    ball.x += ball.vx
    ball.y += ball.vy
    ball.angle += ball.rotation
  end
end

def hit! position, player, ball
  Sound.play_net ball, position
  player.score -= 1 unless player.score.zero?
  player.a -= 20

  if $state.players.values.count { |player| player.score.zero? } == 3
    game_over!
  elsif player.score.zero?
    if player.vertical
      player.h = grid.h
      player.y = 0
    else
      player.w = grid.w
      player.x = 0
    end
    player.v = 0
    player.dv = 0
  end
end

def game_over!
  init
end
