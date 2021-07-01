module Colors
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
end

include Colors
