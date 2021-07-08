Maw!

time_ticks! log_interval: 180 unless production?

controls.define :fullscreen, keyboard: :pageup

def scene! scene
  $scene = scene
  $top_level.init
end

init {
  outputs.clear

  $scene ||= Scenes::Start.new
  $scene.init
}

tick {
  init if controls.reset_down?
  exit if controls.quit?

  if controls.fullscreen_down?
    $state.fullscreen = !$state.fullscreen
    $gtk.set_window_fullscreen $state.fullscreen
  end

  Sound.toggle_background_music_mute if controls.mute_down?

  $scene.tick
}
