Maw!

controls.define :quit, keyboard: :q, controller_one: [:start], mouse: :button_middle
controls.define :reset, keyboard: :r, controller_one: [:a, :b, :x, :y]

init {
    play_sound_effect

    $state.background = [
        0, 0, grid.w, grid.h,
        rand(255), rand(255), rand(255)
    ]
}

tick {
    if controls.reset_down?
        init
    end

    if controls.quit?
        exit
    end
    
    solids << $state.background
}

def play_sound_effect
    audio[:sound_effect] = {
        input: 'sounds/GameStart.wav'
    }
end
