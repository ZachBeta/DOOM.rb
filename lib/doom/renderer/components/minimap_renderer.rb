# frozen_string_literal: true

module Doom
  class MinimapRenderer
    MINIMAP_SIZE = 150
    PLAYER_SIZE = 4
    DIRECTION_LINE_LENGTH = 8

    def initialize(window, map)
      @window = window
      @map = map
      @logger = Logger.instance
    end

    def render(player)
      @logger.debug("Rendering minimap at #{@window.width - MINIMAP_SIZE}, #{@window.height - MINIMAP_SIZE}")

      # Calculate cell size based on map dimensions
      cell_size = MINIMAP_SIZE.to_f / [@map.width, @map.height].max

      # Draw background
      draw_background

      # Draw walls
      draw_walls(cell_size)

      # Draw player
      draw_player(player, cell_size)

      # Draw direction line
      draw_direction_line(player, cell_size)
    end

    private

    def draw_background
      @window.draw_quad(
        @window.width - MINIMAP_SIZE, @window.height - MINIMAP_SIZE, [0, 0, 0],
        @window.width, @window.height - MINIMAP_SIZE, [0, 0, 0],
        @window.width, @window.height, [0, 0, 0],
        @window.width - MINIMAP_SIZE, @window.height, [0, 0, 0]
      )
    end

    def draw_walls(cell_size)
      @map.height.times do |y|
        @map.width.times do |x|
          next unless @map.wall_at?(x, y)

          # Calculate cell position
          cell_x = @window.width - MINIMAP_SIZE + (x * cell_size)
          cell_y = @window.height - MINIMAP_SIZE + (y * cell_size)

          # Draw wall cell
          @window.draw_quad(
            cell_x, cell_y, [255, 255, 255],
            cell_x + cell_size, cell_y, [255, 255, 255],
            cell_x + cell_size, cell_y + cell_size, [255, 255, 255],
            cell_x, cell_y + cell_size, [255, 255, 255]
          )
        end
      end
    end

    def draw_player(player, cell_size)
      # Calculate player position on minimap
      player_x = @window.width - MINIMAP_SIZE + (player.position[0] * cell_size)
      player_y = @window.height - MINIMAP_SIZE + (player.position[1] * cell_size)

      # Draw player dot
      @window.draw_quad(
        player_x - (PLAYER_SIZE / 2), player_y - (PLAYER_SIZE / 2), [255, 0, 0],
        player_x + (PLAYER_SIZE / 2), player_y - (PLAYER_SIZE / 2), [255, 0, 0],
        player_x + (PLAYER_SIZE / 2), player_y + (PLAYER_SIZE / 2), [255, 0, 0],
        player_x - (PLAYER_SIZE / 2), player_y + (PLAYER_SIZE / 2), [255, 0, 0]
      )
    end

    def draw_direction_line(player, cell_size)
      # Calculate direction line end point
      end_x = player.position[0] + (player.direction[0] * DIRECTION_LINE_LENGTH)
      end_y = player.position[1] + (player.direction[1] * DIRECTION_LINE_LENGTH)

      # Convert to minimap coordinates
      start_x = @window.width - MINIMAP_SIZE + (player.position[0] * cell_size)
      start_y = @window.height - MINIMAP_SIZE + (player.position[1] * cell_size)
      end_x = @window.width - MINIMAP_SIZE + (end_x * cell_size)
      end_y = @window.height - MINIMAP_SIZE + (end_y * cell_size)

      # Draw direction line
      @window.draw_line(
        start_x, start_y, [255, 0, 0],
        end_x, end_y, [255, 0, 0]
      )
    end
  end
end
