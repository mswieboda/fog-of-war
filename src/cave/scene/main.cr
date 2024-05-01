require "../level"
require "../player"
require "../hud"

module Cave::Scene
  class Main < GSF::Scene
    getter view : GSF::View
    getter hud
    getter level
    getter player

    def initialize(window)
      super(:main)

      @view = GSF::View.from_default(window).dup

      view.zoom(1 / Screen.scaling_factor)

      @level = Level.new
      @player = Player.new(x: 300, y: 300)
      @hud = HUD.new
    end

    def update(frame_time, keys : Keys, mouse : Mouse, joysticks : Joysticks)
      if keys.just_pressed?(Keys::Escape)
        @exit = true
        return
      end

      level.update(frame_time, keys)
      player.update(frame_time, keys)
      hud.update(frame_time)
    end

    def draw(window)
      level.draw(window, player)
      hud.draw(window)
    end
  end
end
