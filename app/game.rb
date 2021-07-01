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

def player!(opts={})
  if opts.has_key? :color
    color = opts[:color]
  else
    r, g, b = hsv_to_rgb rand(360), 1, 1
    color = { r: r, g: g, b: b }
  end

  color = {r: 255, g: 255, b: 255, a: 200}.merge! color

  {
    x: 0, y: 0,
    w: 0, h: 0,

    vertical: false,

    v: (5+rand(20)).rand_sign,
    dv: ACCELERATION_NORMAL,

    score: 10,
  }.merge(color).merge! opts
end

def ball!(opts={})
  color = [:black, :blue, :gray, :green, :indigo, :orange, :red, :violet, :white, :yellow].sample
  size = rand(6) + 2
  {
    x: grid.center.x,
    y: grid.center.y,
    w: size * 16,
    h: size * 16,
    vx: (7+rand(2)).rand_sign,
    vy: (7+rand(2)).rand_sign,
    a: rand(70) + 160,
    path: "sprites/circle/#{color}.png",

    size: size,
    color: color,
  }
end

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

  input
  motion
  collision

  solids << $state.background

  for player in $state.players.values
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
    if player != $state.player
      next unless rand < 0.02

      player.v += rand(50).rand_sign
    end
  end
end

def move_balls
  for ball in $state.balls # haha.. balls
    ball.x += ball.vx
    ball.y += ball.vy
    ball.angle += 3
  end
end

def collision
  for _, player in $state.players
    max_x = grid.w - player.w
    max_y = grid.h - player.h

    if player.x < 0
      player.x = 0
      player.v *= -1
    elsif player.x > max_x and player.v.positive?
      player.x = max_x
      player.v *= -1
    end

    if player.y < 0
      player.y = 0
      player.y *= -1
    elsif player.y > max_y and player.v.positive?
      player.y = max_y
      player.v *= -1
    end
  end

  for ball in $state.balls
    for position in [:top, :right, :bottom, :left]
      player = $state.players[position]
      net    = $state.nets[position]

      if ball.intersect_rect? net
        $state.balls.delete(ball)

        $state.balls << ball!() if rand(3) == 0
        $state.balls << ball!() if rand(4) == 0
        $state.balls << ball!() if rand(9) == 0
        $state.balls << ball!() if $state.balls.empty?

        hit! position, player, ball
      end

      if ball.intersect_rect? player
        case position
        when :top, :bottom
          ball.vy *= -1
        when :left, :right
          ball.vx *= -1
        end

        if player == $state.player and controls.kick?
          play_kick_sound

          ball.vy *= 1.4
          ball.vx *= 1.3
        end
      end
    end
  end
end

def hit! position, player, ball
  play_net_sound ball, position
  player.score -= 1
  player.a -= 20

  if player.score.zero?
    game_over!
  end
end

def game_over!
  init
end

SIMULTANEOUS_SOUNDS = 3

def sound_index
  @sound_index += 1
  @sound_index % SIMULTANEOUS_SOUNDS
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

def generate_palette_5
  # this generates a five color palette for paddles and the background
  offset_range = 85
  offset = rand(offset_range) + (90 + offset_range) / 2

  h_p0 = rand(360)
  h_p2 = h_p0 + 180

  h_p1 = h_p2 + offset
  h_p3 = h_p2 - offset

  palette_hsv = [
    [h_p0, 1, 1],
    [h_p1, 1, 1],
    [h_p2, 1, 1],
    [h_p3, 1, 1],
    [h_p0, 0.7 * rand, 0.2 * rand + 0.1]
  ]

  palette_hsv.map do |hsv|
    r, g, b = hsv_to_rgb *hsv
    { r: r, g: g, b: b }
  end
end

def hsv_to_rgb h, s, v
  # based on conversion listed here: https://www.rapidtables.com/convert/color/hsv-to-rgb.html
  h = h % 360

  c = v * s
  x = c * (1 - ((h / 60) % 2 - 1).abs)
  m = v - c

  rp, gp, bp = [
    [c, x, 0], #   0 < h <  60
    [x, c, 0], #  60 < h < 120
    [0, c, x], # 120 < h < 180
    [0, x, c], # 180 < h < 240
    [x, 0, c], # 240 < h < 300
    [c, 0, x]  # 300 < h < 360
  ][h / 60]

  return [rp, gp, bp].map { | p | 255 * (p + m) }
end

init
