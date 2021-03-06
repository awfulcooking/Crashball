# Global Controls

controls do
  if desktop?
    define :quit, mouse: :button_middle
  end

  define :mute, keyboard: :m, controller_one: :r3, controller_two: :r3
  define :demo, keyboard: :n, controller_one: :select, controller_two: :select
  define :pause, keyboard: :escape, controller_one: :start, controller_two: :start
  define :reset, keyboard: :delete, controller_one: :r1

  define :menu_back, keyboard: [:escape, :enter, :left], controller_one: [:start]

  if dev?
    define :debug, keyboard: :t, controller_one: :b
    define :debug_framerate, keyboard: :end, controller_one: :x
  end

  define :quicken, keyboard: [:forward_slash, :pagedown], controller_one: :l3, controller_two: :l3
end

# Player Controls

$control_schemes = {
  left: {
    left: {keyboard: :w, controller_four: :up},
    right: {keyboard: :r, controller_four: :down},
    brake: {keyboard: :e, controller_four: :l2},
    boost: {keyboard: :q, controller_four: :r2},
    kick: {keyboard: [:shift, :space], controller_four: :a},
  },
  right: {
    left: {keyboard: :y, controller_three: :down},
    right: {keyboard: :u, controller_three: :up},
    brake: {keyboard: :i, controller_three: :l2},
    boost: {keyboard: :o, controller_three: :r2},
    kick: {keyboard: [:shift, :space], controller_three: :a},
  },
  top: {
    left: {keyboard: :h, controller_two: :left},
    right: {keyboard: :j, controller_two: :right},
    brake: {keyboard: :k, controller_two: :l2},
    boost: {keyboard: :l, controller_two: :r2},
    kick: {keyboard: [:shift, :space], controller_two: :a},
  },
  bottom: {
    left: {keyboard: :s, controller_one: :left},
    right: {keyboard: :f, controller_one: :right},
    brake: {keyboard: :d, controller_one: :l2},
    boost: {keyboard: :a, controller_one: :r2},
    kick: {keyboard: [:shift, :space], controller_one: :a},
  },
}

$controls = {}

$control_schemes.each do |position, actions|
  $controls[position] = Maw::Controls.new("#{position} controls") {
    actions.each do |action, map|
      define action, map
    end
  }
end
