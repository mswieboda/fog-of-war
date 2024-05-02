require "./line"
require "json"
require "uuid"

module Cave
  class Level
    include JSON::Serializable

    getter key : String
    getter border : Line
    property player_spawn : Point = {x: 0, y: 0}

    @[JSON::Field(ignore: true)]
    @hidden_pixels : SF::VertexBuffer = SF::VertexBuffer.new(SF::PrimitiveType::Points)

    @[JSON::Field(ignore: true)]
    @player_seen : Hash(Int32, Hash(Int32, Bool)) = Hash(Int32, Hash(Int32, Bool)).new

    FloorColor = SF::Color.new(153, 153, 0, 15)
    HiddenColor = SF::Color.new(0, 0, 0, 223)

    def initialize(@border = Line.new, @key = UUID.random.to_s)
      @player_spawn = {x: -300, y: -300}
      @hidden_pixels = SF::VertexBuffer.new(SF::PrimitiveType::Points)
      @player_seen = Hash(Int32, Hash(Int32, Bool)).new
    end

    def start
      create_hidden_pixels
    end

    def bounds
      if !@border.points.empty?
        min_x = @border.points.min_of { |point| point[:x] }
        min_y = @border.points.min_of { |point| point[:y] }
        max_x = @border.points.max_of { |point| point[:x] }
        max_y = @border.points.max_of { |point| point[:y] }
      else
        min_x = 0
        min_y = 0
        max_x = 1
        max_y = 1
      end

      width = max_x - min_x
      height = max_y - min_y

      {min_x, min_y, width, height}
    end

    def create_hidden_pixels
      puts ">>> Level#create_hidden_pixels"
      min_x, min_y, width, height = bounds

      @hidden_pixels = SF::VertexBuffer.new(SF::PrimitiveType::Points)
      @hidden_pixels.create(width * height)

      pixels = width.times.to_a.flat_map do |x|
        height.times.to_a.flat_map do |y|
          SF::Vertex.new({min_x + x, min_y + y}, HiddenColor)
        end
      end

      @hidden_pixels.update(pixels, 0)

      puts ">>> create_hidden_pixels vertex_count: #{@hidden_pixels.vertex_count} pixels: #{pixels.size} w: #{width} h: #{height}"
    end

    def update_player_seen(player)
      changed = false

      # TODO: add all pixels of player visiblity radius to @player_seen Hash of row, col
      #       unless the pixel has been seen already
      # NOTE: for now just doing rectangle of player visibility_radius
      px = (player.x - player.visibility_radius).to_i
      py = (player.y - player.visibility_radius).to_i
      width = (player.visibility_radius * 2).to_i
      height = (player.visibility_radius * 2).to_i

      (px..(px + width)).each do |x|
        (py..(py + height)).each do |y|
          @player_seen[x] = Hash(Int32, Bool).new unless @player_seen.has_key?(x)

          unless @player_seen[x].has_key?(y)
            @player_seen[x][y] = true
            changed = true
          end
        end
      end

      changed
    end

    def player_seen?(x, y)
      @player_seen.has_key?(x) && @player_seen[x].has_key?(y)
    end

    def update_hidden_pixels(player)
      return unless update_player_seen(player)

      min_x, min_y, width, height = bounds

      pixels = width.times.to_a.flat_map do |row|
        height.times.to_a.flat_map do |col|
          x = min_x + row
          y = min_y + col
          color = player_seen?(x, y) ? SF::Color::Transparent : HiddenColor

          SF::Vertex.new({x, y}, color)
        end
      end

      @hidden_pixels.update(pixels, 0)
    end

    def display_name
      "#{border.points.size} (#{key[0..7]})"
    end

    def update(frame_time, keys : Keys, player)
      px, py = [player.x, player.y]

      player.update(frame_time, keys, border)

      update_hidden_pixels(player) unless px == player.x && py == player.y
    end

    def draw(window : SF::RenderWindow, player)
      min_x = border.points.min_of { |point| point[:x] }
      min_y = border.points.min_of { |point| point[:y] }
      max_x = border.points.max_of { |point| point[:x] }
      max_y = border.points.max_of { |point| point[:y] }

      draw_floor(window, min_x, min_y, max_x, max_y)

      border.draw(window)

      player.draw(window)

      draw_hidden_pixels(window, min_x, min_y, max_x, max_y)
    end

    def draw_floor(window, min_x, min_y, max_x, max_y)
      rectangle = SF::RectangleShape.new
      rectangle.size = SF.vector2f(max_x - min_x, max_y - min_y)
      rectangle.fill_color = FloorColor
      rectangle.position = {min_x, min_y}

      window.draw(rectangle)
    end

    def draw_hidden_pixels(window, min_x, min_y, max_x, max_y)
      window.draw(@hidden_pixels)
    end
  end
end
