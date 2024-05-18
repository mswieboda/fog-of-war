require "../level_data"
require "../level"

module FogOfWar::Scene
  class Editor < GSF::Scene
    getter view : GSF::View
    getter level_data : LevelData
    getter level : Level
    getter? menu
    getter menu_items
    getter? menu_levels
    getter menu_level_items
    getter test_level_key : String?
    getter player

    TextColor = SF::Color::Green
    Margin = 64
    PaddingSelection = 16
    ItemsToPlace = ["border", "player"]

    delegate border, to: level

    def initialize(window)
      super(:editor)

      @view = GSF::View.from_default(window).dup

      view.zoom(1 / Screen.scaling_factor)

      @level_data = LevelData.load
      @level = Level.new
      @menu = false
      @menu_items = GSF::MenuItems.new(
        font: Font.default,
        size: 32,
        items: ["continue", "save & test", "save", "new", "load", "exit"],
        initial_focused_index: 0
      )
      @menu_levels = false
      @menu_level_items = GSF::MenuItems.new(Font.default)
      @test_level_key = nil
      @item_to_place_index = 0
      @player = Player.new(level.player_spawn)
    end

    def reset
      super

      @level_data = LevelData.load
      @level = Level.new
      @menu = false
      @menu_items = GSF::MenuItems.new(
        font: Font.default,
        size: 32,
        items: ["continue", "save & test", "save", "new", "load", "exit"],
        initial_focused_index: 0
      )
      @menu_levels = false
      @test_level_key = nil
      @item_to_place_index = 0
      @player = Player.new(level.player_spawn)
    end

    def item_to_place
      ItemsToPlace[@item_to_place_index]
    end

    def update(frame_time, keys : Keys, mouse : Mouse, joysticks : Joysticks)
      if keys.just_pressed?(Keys::Escape)
        @menu = !@menu
      end

      if menu?
        update_menu(frame_time, keys, mouse, joysticks)
      elsif menu_levels?
        update_menu_levels(frame_time, keys, mouse, joysticks)
      else
        editor_update(frame_time, keys, mouse)
      end
    end

    def update_menu(frame_time, keys : Keys, mouse : Mouse, joysticks : Joysticks)
      menu_items.update(frame_time, keys, mouse)

      if menu_items.selected?(keys, mouse, joysticks)
        case menu_items.focused_label
        when "continue"
          @menu = false
        when "save & test"
          level_data.update_level(level)
          level_data.save
          @test_level_key = level.key
          @menu = false
        when "save"
          level_data.update_level(level)
          level_data.save
          @menu = false
        when "new"
          @menu = false
          @level = Level.new
        when "load"
          items = [] of String | Tuple(String, String)

          level_data.levels.each do |key, level|
            items << {key, level.display_name}
          end

          items << "back"

          @menu_level_items = GSF::MenuItems.new(
            font: Font.default,
            size: 32,
            items: items,
            initial_focused_index: 0
          )

          @menu_levels = true
          @menu = false
        when "exit"
          @menu = false
          @exit = true
        end
      end
    end

    def update_menu_levels(frame_time, keys : Keys, mouse : Mouse, joysticks : Joysticks)
      menu_level_items.update(frame_time, keys, mouse)

      if menu_level_items.selected?(keys, mouse, joysticks)
        key = menu_level_items.focused_key

        if key == "back"
          @menu_levels = false
          @menu = true
          return
        end

        if found_level = level_data.levels[key]
          @level = found_level
          @player.jump_to_point(level.player_spawn)
          @menu_levels = false
        else
          puts "Error: level \"#{key}\" not found in level data"
        end
      end
    end

    def editor_update(frame_time, keys, mouse)
      place_item(mouse)

      if keys.just_pressed?(Keys::Tab)
        @item_to_place_index += 1
        @item_to_place_index = 0 if @item_to_place_index >= ItemsToPlace.size
      end
    end

    def place_item(mouse)
      return unless mouse.just_pressed?(Mouse::Left)

      point = {x: mouse.x, y: mouse.y}

      if item_to_place == "border"
        border.add_point(point)
      elsif item_to_place == "player"
        level.player_spawn = point
        player.jump_to_point(point)
      end
    end

    def draw(window)
      draw_editor(window)

      draw_menu_background(window) if menu? || menu_levels?

      # NOTE: for now centered horizontally and vertically on the whole screen
      #       same as GSF::MenuItems placement
      size = 32
      x = Screen.width / 2
      y = Screen.height / 2 - size * 3

      if menu?
        draw_header_label(window, "editor", 48, x, y - 48 * 3)
        menu_items.draw(window)
      elsif menu_levels?
        draw_header_label(window, "load", 48, x, y - 48 * 3)
        menu_level_items.draw(window)
      end
    end

    def draw_editor(window)
      draw_hud(window)
      border.draw(window)
      player.draw(window)
    end

    def draw_hud(window)
      text_border = SF::Text.new("border", Font.default, 24)
      text_border.fill_color = TextColor
      text_border.position = {Margin, Margin}

      window.draw(text_border)

      text_border_width = text_border.global_bounds.width

      text_player = SF::Text.new("player", Font.default, 24)
      text_player.fill_color = TextColor
      text_player.position = {Margin, Margin}
      text_player.position = {text_border.position.x + text_border_width + Margin, Margin}

      window.draw(text_player)

      text = text_border

      if item_to_place == "player"
        text = text_player
      end

      text_bounds = text_border.global_bounds

      rect = SF::RectangleShape.new
      rect.size = SF.vector2f(
        text_bounds.width + PaddingSelection * 2,
        text_bounds.height + PaddingSelection * 2
      )
      rect.fill_color = SF::Color::Transparent
      rect.outline_color = TextColor
      rect.outline_thickness = 3
      rect.position = {
        text.position.x - PaddingSelection,
        text.position.y - PaddingSelection
      }

      window.draw(rect)
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
