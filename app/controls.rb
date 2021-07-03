# global controls

controls.define :quit, mouse: :button_middle

controls.define :reset, keyboard: :delete, controller_one: :r1
controls.define :debug, keyboard: :t, controller_one: :b
controls.define :debug_framerate, keyboard: :end, controller_one: :x

controls.define :mute, keyboard: :m, controller_one: :r3, controller_two: :r3

controls.define :quicken, keyboard: [:forward_slash, :pagedown], controller_one: :select, controller_two: :select

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
  $controls[position] = Maw::Controls.new {
    actions.each do |action, map|
      map.delete :controller_three  # these are not exposed
      map.delete :controller_four   # by gtk yet
      define action, map
    end
  }
end

# $controls = Hash[$control_scheme.map { |position, actions|
#   [position, Maw::Controls.new {
#     actions.each do |action, map|
#       map.delete :controller_three
#       map.delete :controller_four
#       define action, map
#     end
#   }]
# }]