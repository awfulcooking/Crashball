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
ACCELERATION_BOOST = 0.97
ACCELERATION_BRAKE = 0.52

PLAYER_HEIGHT = 40

def player!(opts={})
  {
    x: 0, y: 0,
    w: 0, h: 0,
    r: rand(255), g: rand(255), b: rand(255),

    vertical: false,

    v: (5+rand(20)).rand_sign,
    dv: ACCELERATION_NORMAL
  }.merge! opts
end

init {
  play_sound_effect

  $state.background = [
    0, 0, grid.w, grid.h,
    rand(255), rand(255), rand(255)
  ]

  $state.players = {
    top:    player!(y: grid.h-PLAYER_HEIGHT, w: grid.w, h: PLAYER_HEIGHT),
    right:  player!(x: grid.w-PLAYER_HEIGHT, w: PLAYER_HEIGHT, h: grid.h, vertical: true),
    bottom: player!(h: PLAYER_HEIGHT),
    left:   player!(w: PLAYER_HEIGHT, h: grid.h, vertical: true),
  }

  $state.players.each { |(position, player)|
    max = player.vertical ? grid.h/2 : grid.w/2
    position = max/2 + rand(200) - 100
    size = 100 + rand(400)

    if player.vertical
      player.y = position
      player.h = size
    else
      player.x = position
      player.w = size
    end

    player.dx = (5+rand(15)).rand_sign
    player.ddx = ACCELERATION_NORMAL
  }

  $state.player = $state.players[:bottom]

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
  bounds
  physics
  
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
    $state.player.v -= 4
  elsif controls.right?
    $state.player.v += 4
  end

  $state.player.dv = case true
    when controls.brake?
      ACCELERATION_BRAKE
    when controls.boost?
      ACCELERATION_BOOST
    else
      ACCELERATION_NORMAL
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
  if $state.player.x < (0-$state.player.w)
    $state.player.x = grid.w
  elsif $state.player.x > grid.w
    $state.player.x = 0-$state.player.w
  end
end

def play_sound_effect
  audio[:sound_effect] = {
    input: 'sounds/GameStart.wav',
    pitch: 0.45 + 0.1 * ($num_game_starts += 1)
  }
end
