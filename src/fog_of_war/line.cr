require "json"

module FogOfWar
  class Line
    include JSON::Serializable

    getter points : Array(Point)

    PointLineCollisionPrecision = 0.001
    Color = SF::Color.new(38, 25, 17)
    Thickness = 8

    def initialize(@points = [] of Point)
    end

    def thickness
      Thickness
    end

    def add_point(point : Point)
      @points << point
    end

    def collision_with_circle?(cx, cy, r)
      lines.any? do |points|
        x1 = points[0][:x]
        y1 = points[0][:y]
        x2 = points[1][:x]
        y2 = points[1][:y]

        # if either point inside the circle, collision
        next true if point_in_circle?(x1, y1, cx, cy, r) || point_in_circle?(x2, y2, cx, cy, r)

        length = line_distance(x1, y1, x2, y2)

        # get dot product of the line and circle
        dot = (((cx - x1) * (x2 - x1)) + ((cy - y1) * (y2 - y1))) / (length ** 2)

        # find the closest point on the line
        closest_x = x1 + (dot * (x2 - x1))
        closest_y = y1 + (dot * (y2 - y1))

        # is this point actually on the line segment?
        # if so keep going, but if not, return false
        next false unless point_in_line?(x1, y1, x2, y2, closest_x, closest_y)

        # get distance to closest point, if it's less than radius it collides
        line_distance(cx, cy, closest_x, closest_y) <= r
      end
    end

    def point_in_circle?(px, py, cx, cy, r)
      # get distance between point and circle center
      # if distance is less than the circle radius the point is inside
      line_distance(px, py, cx, cy) <= r
    end

    def point_in_line?(x1, y1, x2, y2, px, py)
      # get distance from the point to the two ends of the line
      d1 = line_distance(px, py, x1, y1)
      d2 = line_distance(px, py, x2, y2)

      # get the length of the line
      length = line_distance(x1, y1, x2, y2)

      # since floats are so minutely accurate, add
      # a little buffer zone that will give collision
      # higher is less accurate

      # if the two distances are within the line's length
      # within the precision threshold range, the point is on the line
      d1 + d2 > length - PointLineCollisionPrecision && d1 + d2 <= length + PointLineCollisionPrecision
    end

    def line_distance(x1, y1, x2, y2)
      dist_x = x1 - x2
      dist_y = y1 - y2
      Math.sqrt(dist_x ** 2 + dist_y ** 2)
    end

    # TODO: cache this, and uncache if points change
    def lines
      (points.size - 1).times.to_a.map do |i|
        {points[i], points[i + 1]}
      end
    end

    def draw(window : SF::RenderWindow)
      draw_point_circle(window, points.first) if points.size == 1

      lines.each do |points|
        draw_line(window, points[0], points[1])
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
