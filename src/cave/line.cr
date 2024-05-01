module Cave
  class Line
    alias Point = NamedTuple(x: Int32, y: Int32)

    getter points : Array(Point)
    getter thickness : Int32 | Float32

    Color = SF::Color.new(153, 153, 0, 30)
    OutlineColor = SF::Color.new(153, 153, 0)
    Thickness = 4

    def initialize(@points, @thickness = Thickness)
    end

    def draw(window : SF::RenderWindow)
      (points.size - 1).times do |i|
        draw_line(window, points[i], points[i + 1])
      end
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
      rectangle.fill_color = SF::Color::Red
      rectangle.position = {p1[:x], p1[:y]}
      rectangle.rotate(rotation)

      window.draw(rectangle)
    end
  end
end
