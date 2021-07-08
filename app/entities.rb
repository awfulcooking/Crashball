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
    dv: Scenes::Gameplay::ACCELERATION_NORMAL,

    score: Scenes::Gameplay::PLAYER_START_SCORE,
    controls: nil,
    npc: true,
  }.merge(color).merge! opts
end

def ball!(opts={})
  color = [:black, :blue, :gray, :green, :indigo, :orange, :red, :violet, :white, :yellow].sample
  vx, vy = rand(360).vector(9+rand(4))
  size = rand(6) + 2

  {
    x: grid.center.x,
    y: grid.center.y,
    w: size * 16,
    h: size * 16,
    vx: vx, vy: vy,
    path: "sprites/circle/#{color}.png",

    rotation: 2,
    angle: 0,

    size: size,
    color: color,
  }
end