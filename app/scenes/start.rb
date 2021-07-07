module Scenes
  class Start
    def initialize(opts = {})
      opts = {
        bounce: true,
      }.merge!(opts)

      @bounce = opts[:bounce]
    end

    def button! text, size, font, color=[255,255,255], &callback
      w, h = $gtk.calcstringbox text, size, font
      r, g, b = color

      y = if @buttons.empty?
        grid.center.y
      else
        @buttons.last.y - @buttons.last.h
      end

      @buttons << {
        x: grid.center.x - w/2,
        y: y - h/2,
        w: w, h: h,
        callback: callback,
        label: {
          x: grid.center.x,
          y: y + h/2,
          text: text,
          font: font,
          size_enum: size,
          alignment_enum: 1,
          r: r, g: g, b: b
        }
      }
    end

    def init
      @started_at = tick_count
      @buttons = []

      font = "fonts/zerovelo.ttf"

      button! "New Game", 18, font do
        scene! Scenes::Gameplay.new
      end

      button! "Controls", 15, font

      button! "Quit", 13, font do
        exit
      end
    end

    def tick
      background! [0, 0, 0]
      background! [50, 80, (Math.sin(tick_count / 20.0) + 1) * 70]
      background! Colors.hsv_to_rgb(tick_count / 2 % 360, 1, 0.4)

      label_ease = easing.ease_spline @started_at, tick_count, @bounce ? 80 : 40, [
        @bounce ? [0, 0.4, 0.3, 0] : nil,
        [0, 0.6, 1, 1],
      ].compact

      labels << {
        text: "Crashball!",
        font: 'fonts/halo.ttf',
        x: grid.center.x,
        y: grid.center.y - 290 + label_ease * 500,
        size_enum: 28,
        alignment_enum: 1,
        r: 255, g: 255, b: 200, a: 0 + label_ease * 235,
      }

      input

      for button in @buttons
        labels << button[:label]
      end
    end

    def input
      for button in @buttons
        if inputs.mouse.inside_rect? button
          if inputs.mouse.click
            button[:callback]&.call
          else
            button[:active_since] ||= tick_count
            button[:label][:a] = 210 + (
              Math.sin(
                (tick_count - button[:active_since]) / 10
              ) * 80
            )
          end
        else
          button[:active_since] = nil
          button[:label][:a] = 210
        end
      end
    end
  end
end
