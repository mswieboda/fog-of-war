require "./line"
require "json"
require "uuid"

module Cave
  class Level
    include JSON::Serializable

    getter key : String
    getter border : Line
    property player_spawn : Point = {x: 0, y: 0}

    FloorColor = SF::Color.new(153, 153, 0, 15)

    def initialize(@border = Line.new, @key = UUID.random.to_s)
      @player_spawn = {x: -300, y: -300}
    end

    def display_name
      "#{border.points.size} (#{key[0..7]})"
    end

    def update(frame_time, keys : Keys, player)
      player.update(frame_time, keys, border)
    end

    def draw(window : SF::RenderWindow, player)
      draw_floor(window)
      border.draw(window)
      player.draw(window)
    end

    def draw_floor(window)
      min_x = border.points.min_of { |point| point[:x] }
      min_y = border.points.min_of { |point| point[:y] }
      max_x = border.points.max_of { |point| point[:x] }
      max_y = border.points.max_of { |point| point[:y] }

      rectangle = SF::RectangleShape.new
      rectangle.size = SF.vector2f(max_x - min_x, max_y - min_y)
      rectangle.fill_color = FloorColor
      rectangle.position = {min_x, min_y}

      window.draw(rectangle)
    end
  end
end
