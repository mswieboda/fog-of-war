require "../level_data"
require "../level"
require "../player"
require "../hud"

module Cave::Scene
  class Main < GSF::Scene
    getter view : GSF::View
    getter level_data : LevelData
    getter level
    getter player
    getter hud

    def initialize(window)
      super(:main)

      @view = GSF::View.from_default(window).dup

      view.zoom(1 / Screen.scaling_factor)

      @level_data = LevelData.load
      @level = Level.new
      @player = Player.new(x: 300, y: 300)
      @hud = HUD.new
    end

    def switch_level(level_key)
      if found_level = level_data.levels[level_key]
        @level = found_level
      end
    end

    def update(frame_time, keys : Keys, mouse : Mouse, joysticks : Joysticks)
      if keys.just_pressed?(Keys::Escape)
        @exit = true
        return
      end

      level.update(frame_time, keys, player)
      hud.update(frame_time)
    end

    def draw(window)
      level.draw(window, player)
      hud.draw(window)
    end
  end
end
