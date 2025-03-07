# frozen_string_literal: true

module Doom
  class Map
    attr_reader :width, :height

    def initialize(level_data = nil)
      if level_data
        @width = 64 # Standard DOOM map size
        @height = 64
        @grid = Grid.new(create_map_from_level_data(level_data))
      else
        @width = 10
        @height = 10
        @grid = Grid.new(create_default_layout)
      end
    end

    def wall_at?(x, y)
      @grid.wall_at?(x, y)
    end

    private

    def create_map_from_level_data(level_data)
      # Create a 64x64 grid (standard DOOM map size)
      grid = Array.new(64) { Array.new(64, 0) }

      # Parse LINEDEFS to create walls
      if linedefs = level_data['LINEDEFS']&.read
        num_linedefs = linedefs[0, 2].unpack1('v')
        offset = 2

        num_linedefs.times do
          # Each LINEDEF is 14 bytes
          vertex_start = linedefs[offset, 2].unpack1('v')
          vertex_end = linedefs[offset + 2, 2].unpack1('v')
          flags = linedefs[offset + 4, 2].unpack1('v')
          special_type = linedefs[offset + 6, 2].unpack1('v')
          sector_tag = linedefs[offset + 8, 2].unpack1('v')
          front_sidedef = linedefs[offset + 10, 2].unpack1('v')
          back_sidedef = linedefs[offset + 12, 2].unpack1('v')

          # Get vertex coordinates
          vertex_start_x, vertex_start_y = get_vertex_coordinates(level_data, vertex_start)
          vertex_end_x, vertex_end_y = get_vertex_coordinates(level_data, vertex_end)

          # Draw line on grid
          draw_line(grid, vertex_start_x, vertex_start_y, vertex_end_x, vertex_end_y)

          offset += 14
        end
      end

      grid
    end

    def get_vertex_coordinates(level_data, vertex_index)
      if vertexes = level_data['VERTEXES']&.read
        offset = vertex_index * 4 # Each vertex is 4 bytes (2 bytes x, 2 bytes y)
        x = vertexes[offset, 2].unpack1('v')
        y = vertexes[offset + 2, 2].unpack1('v')
        [x, y]
      else
        [0, 0]
      end
    end

    def draw_line(grid, x1, y1, x2, y2)
      # Bresenham's line algorithm
      dx = (x2 - x1).abs
      dy = (y2 - y1).abs
      x = x1
      y = y1
      n = 1 + dx + dy
      x_inc = x2 > x1 ? 1 : -1
      y_inc = y2 > y1 ? 1 : -1
      error = dx - dy
      dx *= 2
      dy *= 2

      n.times do
        if x.between?(0, 63) && y.between?(0, 63)
          grid[y][x] = 1 # Mark as wall
        end
        if error > 0
          x += x_inc
          error -= dy
        else
          y += y_inc
          error += dx
        end
      end
    end

    def create_default_layout
      [
        [1, 1, 1, 1, 1, 1, 1, 1, 1, 1],
        [1, 0, 0, 0, 0, 0, 0, 0, 0, 1],
        [1, 0, 0, 0, 0, 0, 0, 0, 0, 1],
        [1, 0, 0, 1, 1, 0, 1, 0, 0, 1],
        [1, 0, 0, 1, 0, 0, 1, 0, 0, 1],
        [1, 0, 0, 0, 0, 0, 1, 0, 0, 1],
        [1, 0, 0, 1, 0, 0, 1, 0, 0, 1],
        [1, 0, 0, 1, 1, 1, 1, 0, 0, 1],
        [1, 0, 0, 0, 0, 0, 0, 0, 0, 1],
        [1, 1, 1, 1, 1, 1, 1, 1, 1, 1]
      ]
    end
  end

  class Grid
    WALL = 1
    EMPTY = 0

    def initialize(data)
      @data = data
      @width = data[0].size
      @height = data.size
    end

    def wall_at?(x, y)
      return true if out_of_bounds?(x, y)

      @data[y.to_i][x.to_i] == WALL
    end

    private

    def out_of_bounds?(x, y)
      x.negative? || y.negative? || x >= @width || y >= @height
    end
  end
end
