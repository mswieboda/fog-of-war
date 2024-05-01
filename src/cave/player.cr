module Cave
  class Player
    getter x : Int32 | Float32
    getter y : Int32 | Float32
    getter animations

    Radius = 64
    Size = Radius * 2
    Speed = 640

    Color = SF::Color.new(153, 0, 0, 30)
    OutlineColor = SF::Color.new(153, 0, 0)
    OutlineThickness = 4

    def initialize(x = 0, y = 0)
      @x = x
      @y = y
    end

    def size
      Size
    end

    def update(frame_time, keys : Keys)
      update_movement(frame_time, keys)
    end

    def update_movement(frame_time, keys : Keys)
      dx = 0
      dy = 0

      dy -= 1 if keys.pressed?([Keys::W])
      dx -= 1 if keys.pressed?([Keys::A])
      dy += 1 if keys.pressed?([Keys::S])
      dx += 1 if keys.pressed?([Keys::D])

      return if dx == 0 && dy == 0

      dx, dy = move_with_speed(frame_time, dx, dy)
      dx, dy = move_with_room(dx, dy)

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

    def move_with_room(dx, dy)
      # room wall collisions
      dx = 0 if x + dx < 0 || x + dx + size > GSF::Screen.width
      dy = 0 if y + dy < 0 || y + dy + size > GSF::Screen.height

      {dx, dy}
    end

    def draw(window : SF::RenderWindow)
      circle = SF::CircleShape.new(Radius - OutlineThickness)
      circle.fill_color = Color
      circle.outline_color = OutlineColor
      circle.outline_thickness = OutlineThickness
      circle.position = {x, y}

      window.draw(circle)
    end

    def move(dx, dy)
      @x += dx
      @y += dy
    end
  end
end
