require "./line"
require "json"
require "uuid"

module Cave
  class Level
    include JSON::Serializable

    getter key : String
    getter border : Line
    property player_spawn : Point = {x: 0, y: 0}

    Color = SF::Color.new(153, 153, 0, 30)
    OutlineColor = SF::Color.new(153, 153, 0)
    OutlineThickness = 4

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
      border.draw(window)
      player.draw(window)
    end
  end
end
