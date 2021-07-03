# global controls

controls.define :quit, mouse: :button_middle
controls.define :pause, keyboard: :escape, controller_one: :start, controller_two: :start

controls.define :reset, keyboard: :delete, controller_one: :r1
controls.define :debug, keyboard: :t, controller_one: :b
controls.define :debug_framerate, keyboard: :end, controller_one: :x

controls.define :demo, keyboard: :n, controller_one: :select, controller_two: :select

controls.define :mute, keyboard: :m, controller_one: :r3, controller_two: :r3

controls.define :quicken, keyboard: [:forward_slash, :pagedown], controller_one: :l3, controller_two: :l3

# player controls

$control_schemes = {
  top: {
    left: {keyboard: :w, controller_two: :left},
    right: {keyboard: :r, controller_two: :right},
    brake: {keyboard: :e, controller_two: :l2},
    boost: {keyboard: :q, controller_two: :r2},
    kick: {keyboard: [:shift, :space], controller_two: :a},
  },
  left: {
    left: {keyboard: :u, controller_three: :up},
    right: {keyboard: :o, controller_three: :down},
    brake: {keyboard: :i, controller_three: :l2},
    boost: {keyboard: :p, controller_three: :r2},
    kick: {keyboard: [:shift, :space], controller_three: :a},
  },
  right: {
    left: {keyboard: :l, controller_one: :left},
    right: {keyboard: :j, controller_one: :right},
    brake: {keyboard: :k, controller_one: :l2},
    boost: {keyboard: :semicolon, controller_one: :r2},
    kick: {keyboard: [:shift, :space], controller_one: :a},
  },
  bottom: {
    left: {keyboard: :s, controller_four: :up},
    right: {keyboard: :f, controller_four: :down},
    brake: {keyboard: :d, controller_four: :l2},
    boost: {keyboard: :a, controller_four: :r2},
    kick: {keyboard: [:shift, :space], controller_four: :a},
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
