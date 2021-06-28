Maw!

controls.define :quit, keyboard: :q, controller_one: [:start], mouse: :button_middle
controls.define :reset, keyboard: :r, controller_one: :r1
controls.define :debug, keyboard: :g, controller_one: :b
controls.define :debug_framerate, keyboard: :t, controller_one: :x

controls.define :left, keyboard: :a, controller_one: :left
controls.define :right, keyboard: :d, controller_one: :right
controls.define :up, keyboard: :w, controller_one: :up
controls.define :down, keyboard: :s, controller_one: :down

controls.define :boost, keyboard: :shift, controller_one: [:l2, :r2]
controls.define :kick, keyboard: :e, controller_one: :a

DDX_NORMAL = 0.92
DDX_BOOST = 0.97

init {
    play_sound_effect

    $state.background = [
        0, 0, grid.w, grid.h,
        rand(255), rand(255), rand(255)
    ]

    $state.player = {
        x: 500, y: 50, w: 280, h: 10,
        r: 255, g: 105, b: 199,

        dx: (3+rand(15)).rand_sign,
        ddx: DDX_NORMAL
    }

    $state.nets = [
        {x: 0, y: 0, w: 20, h: grid.h},         # left
        {x: grid.w-20, y: 0, w: 20, h: grid.h}, # right
        {x: 0, y: 0, w: grid.w, h: 20},         # bottom
        {x: 0, y: grid.h-20, w: grid.w, h: 20}, # top
    ]
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
    
    solids << $state.background
    solids << $state.player

    if controls.debug?
        solids << $state.nets.map { |net|
            {r: 0, g: 0, b: 200, a: 160}.merge! net
        }
    end

    if controls.debug_framerate?
      primitives << $gtk.framerate_diagnostics_primitives
    end
}

def movement
    if controls.left?
        $state.player.dx -= 4
    elsif controls.right?
        $state.player.dx += 4
    end

    $state.player.ddx = controls.boost? ? DDX_BOOST : DDX_NORMAL

    $state.player.x += $state.player.dx
    $state.player.dx *= $state.player.ddx
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
        input: 'sounds/GameStart.wav'
    }
end
