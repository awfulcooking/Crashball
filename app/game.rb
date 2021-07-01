Maw!

time_ticks!

controls.define :quit, keyboard: :q, controller_one: [:start], mouse: :button_middle
controls.define :reset, keyboard: :r, controller_one: :r1
controls.define :debug, keyboard: :t, controller_one: :b
controls.define :debug_framerate, keyboard: :t, controller_one: :x
controls.define :debug_players, keyboard: :p, controller_one: :l1

controls.define :left, keyboard: [:left, :s, :z, :x], controller_one: :left
controls.define :right, keyboard: [:right, :f, :c, :v], controller_one: :right
controls.define :up, keyboard: [:w, :up, :e], controller_one: :up
controls.define :down, keyboard: [:w, :down, :c], controller_one: :down

controls.define :brake, keyboard: [:d], controller_one: [:l2]
controls.define :boost, keyboard: [:a, :shift], controller_one: [:r2]
controls.define :kick, keyboard: [:e, :g, :space], controller_one: :a

controls.define :quicken, keyboard: [:k, :end], controller_one: :select

ACCELERATION_NORMAL = 0.85
ACCELERATION_MOVE = 0.9
ACCELERATION_BOOST = 0.95
ACCELERATION_BRAKE = 0.68

PLAYER_MIN_WIDTH = 300
PLAYER_HEIGHT = 50
PLAYER_MOVE_SPEED = 3
PLAYER_ELEVATION = 5

BOOST_AMOUNT = 30 # 10-ish is normal. try 50, 100, 150! then just press shift!

NET_SIZE = 10

init {
  play_start_sound

  palette = generate_palette_5
  bg_color = palette[4]

  $state.background = [
    0, 0, grid.w, grid.h,
    bg_color.r, bg_color.g, bg_color.b
  ]

  $state.players = {
    top:    player!(y: grid.h-PLAYER_HEIGHT-PLAYER_ELEVATION, w: grid.w, h: PLAYER_HEIGHT, color: palette[0]),
    right:  player!(x: grid.w-PLAYER_HEIGHT-PLAYER_ELEVATION, w: PLAYER_HEIGHT, h: grid.h, vertical: true, color: palette[1]),
    bottom: player!(y: PLAYER_ELEVATION, h: PLAYER_HEIGHT, color: palette[2]),
    left:   player!(x: PLAYER_ELEVATION, w: PLAYER_HEIGHT, h: grid.h, vertical: true, color: palette[3]),
  }

  $state.players.each { |(position, player)|
    max_position = player.vertical ? grid.h/2 : grid.w/2
    position = max_position/2 + rand(200) - 100

    size = PLAYER_MIN_WIDTH + rand(player.vertical ? 22 : 200)

    if player.vertical
      player.y = position
      player.h = size
    else
      player.x = position
      player.w = size
    end
  }

  $state.player = $state.players[[:top, :bottom].sample]

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

  if controls.quicken_held? and tick_count % 10 == 0
    $state.balls << ball!()
  end

  input
  collision
  motion

  solids << $state.background

  for player in $state.players.values
    if player.score.zero?
      player.a = 50 + (Math.sin(tick_count / 30) + 1) / 2 * 150
    end
    solids << player
  end

  sprites << $state.balls

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
  if controls.left?
    $state.player.v -= PLAYER_MOVE_SPEED
  end

  if controls.right?
    $state.player.v += PLAYER_MOVE_SPEED
  end

  if controls.boost_down?
    $state.player.v += BOOST_AMOUNT * $state.player.v.sign
  end

  $state.player.dv = case true
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
  for _, player in $state.players
    unless $state.player == player or player.score.zero?
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
    ball.angle += 3
  end
end

def hit! position, player, ball
  play_net_sound ball, position
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
