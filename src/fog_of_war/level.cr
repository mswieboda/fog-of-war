require "./floor_tile"
require "./line"
require "json"
require "uuid"

module FogOfWar
  class Level
    alias FloorTiles = Hash(Int32, Hash(Int32, FloorTile))

    include JSON::Serializable

    getter key : String
    getter border : Line
    property player_spawn : Point = {x: 0, y: 0}

    @[JSON::Field(ignore: true)]
    getter floor_tiles : FloorTiles = FloorTiles.new

    @[JSON::Field(ignore: true)]
    getter min_x = 0

    @[JSON::Field(ignore: true)]
    getter min_y = 0

    def initialize(@border = Line.new, @key = UUID.random.to_s)
      @player_spawn = {x: -300, y: -300}
      @floor_tiles = FloorTiles.new
      @min_x = 0
      @min_y = 0
    end

    def init
      init_floor_tiles
    end

    def display_name
      "#{border.points.size} (#{key[0..7]})"
    end

    def border_min_x_y
      min_x = border.points.min_of { |point| point[:x] }
      min_y = border.points.min_of { |point| point[:y] }

      {min_x, min_y}
    end

    def border_max_x_y
      max_x = border.points.max_of { |point| point[:x] }
      max_y = border.points.max_of { |point| point[:y] }

      {max_x, max_y}
    end

    def init_floor_tiles
      return if border.points.empty?

      @min_x, @min_y = border_min_x_y
      max_x, max_y = border_max_x_y

      rows = ((max_y - min_y) / FloorTile.size).ceil.to_i
      cols = ((max_x - min_x) / FloorTile.size).ceil.to_i

      @floor_tiles = FloorTiles.new

      rows.times do |row|
        @floor_tiles[row] = Hash(Int32, FloorTile).new

        cols.times do |col|
          @floor_tiles[row][col] = FloorTile.new
        end
      end
    end

    def tile_at(x, y)
      col = ((x - min_x) / FloorTile.size).to_i
      row = ((y - min_y) / FloorTile.size).to_i

      if floor_tiles.has_key?(row) && floor_tiles[row].has_key?(col)
        floor_tiles[row][col]
      end
    end

    def update(frame_time, keys : Keys, player : Player)
      player.update(frame_time, keys, border)

      if player.just_moved?
        reset_visibility
        update_visibility(player)
      end
    end

    def reset_visibility
      floor_tiles.each do |_row, tiles|
        tiles.each do |_col, tile|
          tile.reset_visibility
        end
      end
    end

    def update_visibility(player : Player)
      # get all tiles within rectangle of player visibility radius
      x = player.x - player.visibility_radius
      y = player.y - player.visibility_radius
      size = player.visibility_radius * 2

      min_col = ((x - min_x) / FloorTile.size).to_i
      min_row = ((y - min_y) / FloorTile.size).to_i
      max_col = ((x + size - min_x) / FloorTile.size).ceil.to_i
      max_row = ((y + size - min_y) / FloorTile.size).ceil.to_i

      # check these tiles against player visibility circle
      (min_col..max_col).each do |col|
        (min_row..max_row).each do |row|
          if floor_tiles.has_key?(row) && floor_tiles[row].has_key?(col)
            if tile = floor_tiles[row][col]
              explore_tile_check(tile, col, row, player)
            end
          end
        end
      end
    end

    def explore_tile_check(tile, col, row, player)
      if tile.collision_with_circle?(col, row, min_x, min_y, player.x, player.y, player.visibility_radius)
        tile.explore
      end
    end

    def draw(window : SF::RenderWindow, player)
      draw_floor_tiles(window)

      border.draw(window)
      player.draw(window)

      draw_visibility(window)
    end

    def draw_floor_tiles(window)
      floor_tiles.each do |row, tiles|
        tiles.each do |col, tile|
          tile.draw(window, col, row, min_x, min_y)
        end
      end
    end

    def draw_visibility(window)
      floor_tiles.each do |row, tiles|
        tiles.each do |col, tile|
          tile.draw_visibility(window, col, row, min_x, min_y)
        end
      end
    end
  end
end
