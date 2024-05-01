require "../level_editor"

module Cave::Scene
  class Editor < GSF::Scene
    getter view : GSF::View
    getter level_editor
    getter? menu
    getter menu_items

    def initialize(window)
      super(:main)

      @view = GSF::View.from_default(window).dup

      view.zoom(1 / Screen.scaling_factor)

      @level_editor = LevelEditor.new
      @menu = false
      @menu_items = GSF::MenuItems.new(Font.default)
    end

    def open_menu
      @menu = true
      @menu_items = GSF::MenuItems.new(
        font: Font.default,
        size: 32,
        items: ["continue editing", "save", "new", "load", "exit"],
        initial_focused_index: 0
      )
    end

    def update(frame_time, keys : Keys, mouse : Mouse, joysticks : Joysticks)
      if keys.just_pressed?(Keys::Escape)
        open_menu unless menu?
      end

      if menu?
        update_menu(frame_time, keys, mouse, joysticks)
      else
        level_editor.update(frame_time, keys, mouse)
      end
    end

    def update_menu(frame_time, keys : Keys, mouse : Mouse, joysticks : Joysticks)
      menu_items.update(frame_time, keys, mouse)

      if menu_items.selected?(keys, mouse, joysticks)
        case menu_items.focused_label
        when "continue editing"
          @menu = false
        when "save"
          # TODO: save
          @menu = false
        when "new"
          @menu = false
          @level_editor = LevelEditor.new
        when "load"
          # TODO: load
          @menu = false
        when "exit"
          @menu = false
          @exit = true
        end
      end
    end

    def draw(window)
      level_editor.draw(window)

      draw_menu_background(window) if menu?

      # NOTE: for now centered horizontally and vertically on the whole screen
      #       same as GSF::MenuItems placement
      size = 32
      x = Screen.width / 2
      y = Screen.height / 2 - size * 3

      if menu?
        draw_header_label(window, "editor", 48, x, y - 48 * 3)
        menu_items.draw(window)
      end
    end

    def draw_menu_background(window)
      menu_width = Screen.width / 2
      menu_height = Screen.height / 1.5

      rect = SF::RectangleShape.new
      rect.size = SF.vector2f(menu_width, menu_height)
      rect.fill_color = SF::Color::Black
      rect.outline_color = SF::Color.new(33, 33, 33)
      rect.outline_thickness = 3
      rect.position = {
        Screen.width / 2 - menu_width / 2,
        Screen.height / 2 - menu_height / 2
      }

      window.draw(rect)
    end

    def draw_header_label(window, label, size, x, y)
      text = SF::Text.new(label, Font.default, size)
      item_x = x - text.global_bounds.width / 2
      item_y = y - text.global_bounds.height / 2
      text.position = SF.vector2(item_x, item_y)
      text.fill_color = SF::Color::White

      window.draw(text)
    end
  end
end
