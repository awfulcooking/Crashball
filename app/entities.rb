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
    controls: nil,
    npc: true,
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
    a: rand(100) + 130,
    path: "sprites/circle/#{color}.png",

    rotation: 2,
    angle: 0,

    size: size,
    color: color,
  }
end