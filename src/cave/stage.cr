require "./scene/start"
require "./scene/main"
require "./scene/editor"

module Cave
  class Stage < GSF::Stage
    getter start
    getter main
    getter editor

    def initialize(window : SF::RenderWindow)
      super(window)

      @start = Scene::Start.new
      @main = Scene::Main.new(window)
      @editor = Scene::Editor.new(window)

      @scene = start
    end

    def check_scenes
      case scene.name
      when :start
        check_start
      when :main
        switch(start) if scene.exit?
      when :editor
        check_editor
      end
    end

    def check_start
      if scene.exit?
        @exit = true
      elsif start_scene = start.start_scene
        switch(main) if start_scene == :main
        switch(editor) if start_scene == :editor
      end
    end

    def check_editor
      if scene.exit?
        switch(start)
      elsif level_key = editor.test_level_key
        switch(main)
        main.switch_level(level_key)
      end
    end
  end
end
