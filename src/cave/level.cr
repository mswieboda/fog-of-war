require "./line"
require "./player"

module Cave
  class Level
    getter borders = [] of Line
    getter player

    Color = SF::Color.new(153, 153, 0, 30)
    OutlineColor = SF::Color.new(153, 153, 0)
    OutlineThickness = 4

    def initialize()
      @player = Player.new(x: 300, y: 300)

      @lines = [
        Line.new(
          points: [
            {x: 100, y: 300},
            {x: 300, y: 350},
            {x: 500, y: 950},
            {x: 100, y: 500}
          ],
          thickness: 10
        )
      ]
    end

    def update(frame_time, keys : Keys)
      player.update(frame_time, keys)
    end

    def draw(window : SF::RenderWindow)
      player.draw(window)
      @lines.each(&.draw(window))
    end
  end
end
