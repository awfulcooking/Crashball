module Scenes
  # TODO: Rename this to Menu
  class Start
    def initialize opts={}
      @resume = opts[:resume]
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
        color: color,
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

      font = "fonts/halo.ttf"

      button! "Resume", 12, font do
        @resume.call
      end if @resume

      button! "New Game", 12, font do
        scene! Scenes::Gameplay.new
      end

      button! "Controls", 13, font do
        @page = :controls
      end

      button!("Quit", 13, font) { exit } if desktop?
    end

    def tick
      background! Colors.hsv_to_rgb(tick_count / 2 % 360, 1, 0.4)

      label_ease = easing.ease_spline @started_at, tick_count, 30, [
        [0, 0.6, 1, 1],
      ]

      labels << {
        text: "Crashball!",
        font: 'fonts/halo.ttf',
        x: grid.center.x,
        y: grid.center.y - 290 + label_ease * 500,
        size_enum: 28,
        alignment_enum: 1,
        r: 255, g: 255, b: 200, a: -30 + label_ease * 240,
      }

      input

      case @page
      when :controls
        render_controls
      else
        for button in @buttons
          labels << button[:label]
        end
      end
    end

    def render_controls
      render_keyboard_keys "Top",    %w(h j k l)
      render_keyboard_keys "Bottom", %w(a s d f)
      render_keyboard_keys "Left",   %w(q w e r)
      render_keyboard_keys "Right",  %w(y u i o)
    end

    def render_keyboard_keys position, keys
      @render_keyboard_keys_i = 0 if @render_keyboard_keys_tick != tick_count
      @render_keyboard_keys_i += 1
      @render_keyboard_keys_tick = tick_count

      # y = 420 - @render_keyboard_keys_i * 64
      y = grid.center.y + 75 - @render_keyboard_keys_i * 64

      # labels << [grid.center.x, y, position, 14, 255, 255, 255]
      labels << {
        text: position,
        font: 'fonts/halo.ttf',
        x: grid.center.x - 120,
        y: y + 32,
        size_enum: 8,
        alignment_enum: 1,
        r: 230, g: 210, b: 255, a: 190,
      }

      keys.map_with_index do |key, i|
        r, g, b = case
        when inputs.keyboard.send(key)
          Colors.hsv_to_rgb(tick_count * 3, 1, 1)
        else
          [ 255, 255, 255 ]
        end

        labels << {
          text: key,
          font: 'fonts/halo.ttf',
          x: grid.center.x + 40 + 36 * i,
          y: y + 28,
          size_enum: 5,
          alignment_enum: 1,
          r: r, g: g, b: b, a: 190,
        }
      end

      # sprites << keys.map_with_index { |key, i|
      #   keyboard_tile key, y, i
      # }
    end

    TILESET_KEY_ORDER = %w(1 2 3 4 5 6 7 8 9 0 q w e r t y u i o p a s d f g h j k l up z x c v b n m left down right)

    def keyboard_tile key, y, i
      # puts "keyboard_tile #{key.inspect}, #{y}, #{i} - #{TILESET_KEY_ORDER.index key}"
      {
        x: grid.center.x - 230 - (2 * 24) + (i * 24),
        y: y,
        path: "sprites/Keyboard_Prompts.png",
        source_x: 55 + 24 * (TILESET_KEY_ORDER.index(key)&.% 10),
        source_y: 10 + (12 * (TILESET_KEY_ORDER.index(key) / 10).to_i),
        source_w: 11,
        source_h: 11,
        w: 48,
        h: 48,
      }
    end

    def input
      if @page == :controls
        if controls.menu_back?
          @page = nil
        end
        return
      end

      for button in @buttons
        if inputs.mouse.inside_rect? button
          if inputs.mouse.click
            button[:callback]&.call
          else
            button[:active_since] ||= tick_count
            # button[:label][:a] = 100 + (
            #   ((Math.sin(
            #     (20 + tick_count - button[:active_since]) / (
            #       9 + [25, (tick_count-button[:active_since])/600].min
            #     )
            #   ) + 1) - 2) * 127
            # )
            r, g, b = Colors.hsv_to_rgb((360 * (Math.sin((230 + tick_count-button[:active_since])/600))), 1, 2)

            button[:label][:r] = r
            button[:label][:g] = g
            button[:label][:b] = b

            # button[:label][:r] = r
            # button[:label][:g] = 180
            # button[:label][:b] = 210
          end
        else
          button[:active_since] = nil

          r, g, b = button[:color]
          button[:label][:a] = 195
          button[:label][:r] = r
          button[:label][:g] = g
          button[:label][:b] = b
        end
      end
    end
  end
end
