require "../level_data"
require "../level"
require "../player"
require "../hud"

module FogOfWar::Scene
  class Main < GSF::Scene
    getter view : GSF::View
    getter level_data : LevelData
    getter level : Level
    getter player
    getter hud

    def initialize(window)
      super(:main)

      @view = GSF::View.from_default(window).dup

      view.reset(0, 0, Screen.width, Screen.height)
      view.zoom(1 / Screen.scaling_factor)

      @level_data = LevelData.load
      @level = level_data.levels[level_data.levels.keys.sample]
      @player = Player.new(level.player_spawn)
      @hud = HUD.new
    end

    def init
      @level.init
      @player.jump_to_point(level.player_spawn)
    end

    def reset
      super

      @level_data = LevelData.load
      @level = level_data.levels[level_data.levels.keys.sample]
      @player = Player.new(level.player_spawn)
    end

    def switch_level(level_key)
      @level_data = LevelData.load

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

      view.center(player.x, player.y)

      hud.update(frame_time)
    end

    def draw(window)
      view.set_current

      level.draw(window, player)

      view.set_default_current

      hud.draw(window)
    end
  end
end
