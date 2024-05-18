module FogOfWar
  class Player
    getter x : Int32 | Float32
    getter y : Int32 | Float32
    getter? just_moved

    Radius = 64
    Size = Radius * 2
    Speed = 640
    VisibilityRadius = 256

    Color = SF::Color.new(153, 0, 0, 30)
    OutlineColor = SF::Color.new(153, 0, 0)
    OutlineThickness = 4
    VisibilityColor = SF::Color.new(127, 127, 127, 63)

    def initialize(point : Point = {x: 0, y: 0})
      @x = point[:x]
      @y = point[:y]
    end

    def radius
      Radius
    end

    def size
      Size
    end

    def visibility_radius
      VisibilityRadius
    end

    def update(frame_time, keys : Keys, border : Line)
      update_movement(frame_time, keys, border)
    end

    def update_movement(frame_time, keys : Keys, border)
      dx = 0
      dy = 0

      dy -= 1 if keys.pressed?([Keys::W])
      dx -= 1 if keys.pressed?([Keys::A])
      dy += 1 if keys.pressed?([Keys::S])
      dx += 1 if keys.pressed?([Keys::D])

      return if dx == 0 && dy == 0

      dx, dy = move_with_speed(frame_time, dx, dy)
      dx, dy = move_with_level(dx, dy, border)

      return if dx == 0 && dy == 0

      move(dx, dy)
    end

    def move_with_speed(frame_time, dx, dy)
      speed = Speed
      directional_speed = dx != 0 && dy != 0 ? speed / 1.4142 : speed
      dx *= (directional_speed * frame_time).to_f32
      dy *= (directional_speed * frame_time).to_f32

      {dx, dy}
    end

    def move_with_level(dx, dy, border)
      # TODO: switch to individual x + dx, and y + dy to only modify one
      if border.collision_with_circle?(x + dx, y + dy, radius)
        dx = 0
        dy = 0
      end

      return {dx, dy} if dx == 0 && dy == 0

      # room wall collisions
      dx = 0 if x + dx < 0 || x + dx + size > GSF::Screen.width
      dy = 0 if y + dy < 0 || y + dy + size > GSF::Screen.height

      {dx, dy}
    end

    def move(dx, dy)
      @x += dx
      @y += dy
      @just_moved = true
    end

    def jump_to_point(point : Point)
      @x = point[:x]
      @y = point[:y]
      @just_moved = true
    end

    def draw(window : SF::RenderWindow)
      draw_player(window)
    end

    def draw_player(window)
      circle = SF::CircleShape.new(Radius - OutlineThickness)
      circle.fill_color = Color
      circle.outline_color = OutlineColor
      circle.outline_thickness = OutlineThickness
      circle.position = {x, y}
      circle.origin = {size / 2, size / 2}

      window.draw(circle)
    end
  end
end
