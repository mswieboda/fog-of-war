require "../level_editor"

module Cave::Scene
  class Editor < GSF::Scene
    getter view : GSF::View
    getter level_editor

    def initialize(window)
      super(:main)

      @view = GSF::View.from_default(window).dup

      view.zoom(1 / Screen.scaling_factor)

      @level_editor = LevelEditor.new
    end

    def update(frame_time, keys : Keys, mouse : Mouse, joysticks : Joysticks)
      if keys.just_pressed?(Keys::Escape)
        @exit = true
        return
      end

      level_editor.update(frame_time, keys, mouse)
    end

    def draw(window)
      level_editor.draw(window)
    end
  end
end
