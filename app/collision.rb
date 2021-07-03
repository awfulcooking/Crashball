
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

      if ball_rect_collision? ball, player
        if player[:controls].kick?
          play_kick_sound

          ball.vy *= 1.4
          ball.vx *= 1.3
        end
      end
    end
  end
end

# many thanks to kota on Discord for the code below
# it will take me (mooff) a while to understand this,
# i think :P

def check_rect_collision_y player, ball, r
  if (ball.x + ball.w / 2).between? player.x, player.x + player.w
    if (player.y + player.h / 2) - (ball.y + ball.w / 2) > 0
      ball.y = player.y - 2 * r
      ball.y += player.v if player.vertical && player.v < 0
    else
      ball.y = player.y + player.h
      ball.y += player.v if player.vertical && player.v > 0
    end
    ball.vy *= -1
    ball.vy += player.v if player.vertical
    ball.last_player = player
    return true
  end
  return false
end

def check_rect_collision_x player, ball, r
  if (ball.y + ball.w / 2).between? player.y, player.y + player.h
    if (player.x + player.w / 2) - (ball.x + ball.w / 2) > 0
      ball.x = player.x - 2 * r
      ball.x += player.v if !player.vertical && player.v < 0
    else
      ball.x = player.x + player.w
      ball.x += player.v if !player.vertical && player.v > 0
    end
    ball.vx *= -1
    ball.vx += player.v if !player.vertical
    ball.last_player = player
    return true
  end
  return false
end

def ball_rect_collision? ball, player
  # this only works for axis aligned case
  # using a C-space (configuration space) and inflate the rectangle into a
  # rectangle with sides (w + 2*r, h + 2*h) and rounded corners with radius r.
  # we treat the ball as a single point in space.

  # as a simplification, we only allow one bounce with a player
  return false if player == ball.last_player

  r = ball.w / 2
  # considering the ball as a circle from the center makes collision detection much easier
  centered_ball = { x: ball.x + r, y: ball.y + r, r: r  }
  prev_ball = { x: ball.prev_x, y: ball.prev_y }
  bounding_rect = {
    x: player.x - r, y: player.y - r,
    w: player.w + ball.w, h: player.h + ball.h
  }

  return false unless [centered_ball.x, centered_ball.y].inside_rect? bounding_rect

  # as a future change, we can compute the intersection point here and adjust the position
  # accordingly. we might not need that kind of precision in this game though given the update
  # rate.

  return true if check_rect_collision_y(player, ball, r)
  return true if check_rect_collision_x(player, ball, r)

  player_corners = [
    { x: player.x, y: player.y }, { x: player.x, y: player.y + player.h },
    { x: player.x + player.w, y: player.y }, { x: player.x + player.w, y: player.y + player.h }
  ]

  ball_vec = { x: ball.prev_x + r, y: ball.prev_y + r,
                vx: ball.vx, vy: ball.vy }
  ball_dir = { x: ball.vx, y: ball.vy }
  player_corners.each do |corner|
    dx = corner.x - centered_ball.x
    dy = corner.y - centered_ball.y

    if dx * dx + dy * dy < r * r
      pt = vec_circle_intersect corner.merge(r: r), ball_vec
      if pt.nil?
        next
      end

      surface_normal = norm x: corner.x - pt.x, y: corner.y - pt.y
      ref = norm reflection_vec(ball_dir, surface_normal)

      vel = Math::sqrt(ball.vx * ball.vx + ball.vy * ball.vy)
      ball.vx = vel * ref.x
      ball.vy = vel * ref.y
      ball.last_player = player
      return true
    end
  end

  return false
end

def vec_circle_intersect circle, vec
  # based on https://stackoverflow.com/a/1084899/846742
  # using the same naming conventions...
  # circle assumes x,y is center of circle and r is radius
  e = vec
  d = { x: vec.vx, y: vec.vy }
  c = circle
  f = { x: e.x - c.x, y: e.y - c.y }
  r = circle.r

  a = dot d, d
  b = 2 * dot(f, d)
  c = dot(f, f) - r * r

  disc = b * b - 4 * a * c

  return nil if disc < 0 # this shouldn't happen in our case since we are checking for collision ahead of time!

  disc = Math::sqrt(disc)

  # we only care about the first intersection (ie. t1 from the stackoverflow page!)
  t = (-b - disc) / (2 * a)
  { x: e.x + t * d.x, y: e.y + t * d.y }
end

def reflection_vec projectile, normal
  # using the vector form of snell's law taken from here https://en.wikipedia.org/wiki/Snell%27s_law#Vector_form
  # both vecs should be just the orientation in the x and y values
  normal_norm = norm(normal)
  proj_norm = norm(projectile)
  neg_cos_th1 = dot normal_norm, proj_norm
  double_cos_th1 = -2 * neg_cos_th1

  { x: proj_norm.x + double_cos_th1 * normal_norm.x,
    y: proj_norm.y + double_cos_th1 * normal_norm.y }
end

def norm vec
  dist = Math::sqrt(vec.x * vec.x + vec.y * vec.y)
  { x: vec.x / dist, y: vec.y / dist }
end

def dot p1, p2
  p1.x * p2.x + p1.y * p2.y
end
