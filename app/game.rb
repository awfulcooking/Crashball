Maw!

controls.define :quit, keyboard: :q, controller_one: [:start], mouse: :button_middle
controls.define :reset, keyboard: :r, controller_one: :r1
controls.define :debug, keyboard: :g, controller_one: :b
controls.define :debug_framerate, keyboard: :t, controller_one: :x
controls.define :debug_players, keyboard: :p, controller_one: :l1

controls.define :left, keyboard: :a, controller_one: :left
controls.define :right, keyboard: :d, controller_one: :right
controls.define :up, keyboard: :w, controller_one: :up
controls.define :down, keyboard: :s, controller_one: :down

controls.define :brake, keyboard: :shift, controller_one: [:l2]
controls.define :boost, keyboard: :space, controller_one: [:r2]
controls.define :kick, keyboard: :e, controller_one: :a

ACCELERATION_NORMAL = 0.85
ACCELERATION_MOVE = 0.9
ACCELERATION_BOOST = 0.96
ACCELERATION_BRAKE = 0.68

PLAYER_MIN_WIDTH = 150
PLAYER_HEIGHT = 50
PLAYER_MOVE_SPEED = 2
PLAYER_ELEVATION = 0

BOOST_AMOUNT = 10

def player!(opts={})
  {
    x: 0, y: 0,
    w: 0, h: 0,
    r: rand(230), g: rand(215), b: rand(255),

    vertical: false,

    v: (5+rand(20)).rand_sign,
    dv: ACCELERATION_NORMAL
  }.merge! opts
end

init {
  play_sound_effect

  $state.background = [
    0, 0, grid.w, grid.h,
    rand(180), rand(180), rand(200)
  ]

  $state.players = {
    top:    player!(y: grid.h-PLAYER_HEIGHT-PLAYER_ELEVATION, w: grid.w, h: PLAYER_HEIGHT),
    right:  player!(x: grid.w-PLAYER_HEIGHT-PLAYER_ELEVATION, w: PLAYER_HEIGHT, h: grid.h, vertical: true),
    bottom: player!(y: PLAYER_ELEVATION, h: PLAYER_HEIGHT),
    left:   player!(x: PLAYER_ELEVATION, w: PLAYER_HEIGHT, h: grid.h, vertical: true),
  }

  $state.players.each { |(position, player)|
    max = player.vertical ? grid.h/2 : grid.w/2
    position = max/2 + rand(200) - 100
    size = PLAYER_MIN_WIDTH + rand(400)

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
    top:    {x: 0, y: grid.h-20, w: grid.w, h: 20},
    right:  {x: grid.w-20, y: 0, w: 20, h: grid.h},
    bottom: {x: 0, y: 0, w: grid.w, h: 20},
    left:   {x: 0, y: 0, w: 20, h: grid.h},
  }
}

tick {
  if controls.reset_down?
    init
  end

  if controls.quit?
    exit
  end

  movement
  physics
  bounds

  solids << $state.background

  for player in $state.players.values
    solids << player
  end

  if controls.debug?
    solids << $state.nets.values.map { |net|
      {r: 0, g: 0, b: 200, a: 130}.merge! net
    }
  end

  if controls.debug_framerate?
    primitives << $gtk.framerate_diagnostics_primitives
  end
}

def movement
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

  move_npcs
end

def move_npcs
  for _, player in $state.players
    if player != $state.player
      next unless rand < 0.02

      player.v += rand(50).rand_sign
    end
  end
end

def physics
  for position, player in $state.players
    if player.vertical
      player.y += player.v
    else
      player.x += player.v
    end

    player.v *= player.dv
  end
end

def bounds
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
end

def play_sound_effect
  audio[:sound_effect] = {
    input: 'sounds/GameStart.wav',
    pitch: rand/2 + 0.1 * (($state.num_game_starts += 1) % 20) # + ((rand < 0.2) ? -3 : 0)
  }
end

init
