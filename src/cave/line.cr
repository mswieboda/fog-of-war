require "json"

module Cave
  class Line
    include JSON::Serializable

    getter points : Array(Point)

    Color = SF::Color.new(153, 153, 0)
    Thickness = 8

    def initialize(@points = [] of Point)
    end

    def thickness
      Thickness
    end

    def add_point(point : Point)
      @points << point
    end

    def draw(window : SF::RenderWindow)
      draw_point_circle(window, points.first) if points.size == 1

      (points.size - 1).times do |i|
        draw_line(window, points[i], points[i + 1])
      end
    end

    def draw_point_circle(window, point)
      circle = SF::CircleShape.new(thickness)
      circle.fill_color = Color
      circle.position = {point[:x], point[:y]}

      window.draw(circle)
    end

    def draw_line(window, point, next_point)
      p1 = point
      p2 = next_point

      if point[:x] > next_point[:x]
        p1 = next_point
        p2 = point
      end

      x = p2[:x] - p1[:x]
      y = p2[:y] - p1[:y]

      width = Math.sqrt(x ** 2 + y ** 2).to_f32
      rotation = (Math.atan(y / x) * 180 / Math::PI).to_f32

      rectangle = SF::RectangleShape.new
      rectangle.size = SF.vector2f(width, thickness)
      rectangle.fill_color = Color
      rectangle.position = {p1[:x], p1[:y]}
      rectangle.rotate(rotation)

      window.draw(rectangle)
    end
  end
end
