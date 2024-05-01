require "./line"
require "./player"

module Cave
  class LevelEditor
    getter border : Line

    def initialize()
      @border = Line.new
    end

    def update(frame_time, keys : Keys, mouse : Mouse)
      add_border_point(mouse)
    end

    def add_border_point(mouse)
      return unless mouse.just_pressed?(Mouse::Left)

      border.add_point({x: mouse.x, y: mouse.y})
    end

    def draw(window : SF::RenderWindow)
      draw_point_circle(window, border.points.first) if border.points.size == 1
      border.draw(window)
    end

    def draw_point_circle(window, point)
      circle = SF::CircleShape.new(border.thickness)
      circle.fill_color = SF::Color::Red
      circle.position = {point[:x], point[:y]}

      window.draw(circle)
    end
  end
end
