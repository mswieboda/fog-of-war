module Cave
  enum Visibility : UInt8
    None
    Fog
    Clear

    def color
      case self
      when .none?
        SF::Color.new(0, 0, 0)
      when .fog?
        SF::Color.new(0, 0, 0, 223)
      when .clear?
        SF::Color::Transparent
      else
        SF::Color::Magenta
      end
    end

    def draw(window, x, y, size)
      rect = SF::RectangleShape.new({size, size})
      rect.fill_color = color
      rect.position = {x, y}

      window.draw(rect)
    end
  end

  class FloorTile
    property visibility : Visibility
    property? explored

    TileSize = 32
    Color = SF::Color.new(54, 36, 25)

    def initialize(@visibility = Visibility::None)
      @explored = false
    end

    def self.size
      TileSize
    end

    def size
      TileSize
    end

    def reset_visibility
      @visibility = Visibility::None
    end

    def explore
      @explored = true
      @visibility = Visibility::Clear
    end

    def collision_with_circle?(col, row, min_x, min_y, cx, cy, radius)
      x = min_x + col * size
      y = min_y + row * size

      # temporary variables to set edges for testing
      test_x = cx
      test_y = cy

      # which edge is closest?
      if cx < x
        # test left edge
        test_x = x
      elsif cx > x + size
        # right edge
        test_x = x + size
      end

      if cy < y
        # top edge
        test_y = y
      elsif cy > y + size
        # bottom edge
        test_y = y + size
      end

      # get distance from closest edges
      dist_x = cx - test_x
      dist_y = cy - test_y

      # if distance is less than radius, it collides
      Math.sqrt(dist_x ** 2 + dist_y ** 2) <= radius
    end

    def draw(window, col, row, min_x, min_y)
      rect = SF::RectangleShape.new({size, size})
      rect.fill_color = Color
      rect.position = {min_x + col * size, min_y + row * size}

      window.draw(rect)
    end

    def draw_visibility(window, col, row, min_x, min_y)
      visibility = @visibility.none? && explored? ? Visibility::Fog : @visibility
      visibility.draw(window, min_x + col * size, min_y + row * size, size)
    end
  end
end
