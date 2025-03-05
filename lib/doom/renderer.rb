require_relative 'map'

module Doom
  class Renderer
    def initialize(window, map)
      @window = window
      @map = map
      @width = window.width
      @height = window.height
      @wall_renderer = WallRenderer.new(window, @map)
      @background_renderer = BackgroundRenderer.new(window)
      @minimap_renderer = MinimapRenderer.new(window, @map)
    end

    def render(player)
      @background_renderer.render
      @wall_renderer.render(player, @width, @height)
      @minimap_renderer.render(player)
    end
  end

  class BackgroundRenderer
    FLOOR_COLOR = Gosu::Color.new(255, 50, 50, 50)
    CEILING_COLOR = Gosu::Color.new(255, 100, 100, 150)

    def initialize(window)
      @window = window
      @width = window.width
      @height = window.height
    end

    def render
      render_ceiling
      render_floor
    end

    private

    def render_ceiling
      @window.draw_quad(
        0, 0, CEILING_COLOR,
        @width, 0, CEILING_COLOR,
        0, @height / 2, CEILING_COLOR,
        @width, @height / 2, CEILING_COLOR
      )
    end

    def render_floor
      @window.draw_quad(
        0, @height / 2, FLOOR_COLOR,
        @width, @height / 2, FLOOR_COLOR,
        0, @height, FLOOR_COLOR,
        @width, @height, FLOOR_COLOR
      )
    end
  end

  class WallRenderer
    WALL_COLORS = {
      north: Gosu::Color.new(255, 255, 0, 0),    # Red
      south: Gosu::Color.new(255, 0, 255, 0),    # Green
      east: Gosu::Color.new(255, 0, 0, 255),     # Blue
      west: Gosu::Color.new(255, 255, 255, 0)    # Yellow
    }

    def initialize(window, map)
      @window = window
      @map = map
    end

    def render(player, width, height)
      width.times do |x|
        ray = Ray.new(player, x, width)
        intersection = ray_cast(ray, player)
        draw_wall_slice(x, intersection, height)
      end
    end

    private

    def ray_cast(ray, player)
      RayCaster.new(@map, player, ray).cast
    end

    def draw_wall_slice(x, intersection, height)
      return unless intersection

      line_height = (height / intersection.distance).to_i
      
      draw_start = [-line_height / 2 + height / 2, 0].max
      draw_end = [line_height / 2 + height / 2, height - 1].min
      
      color = determine_wall_color(intersection)
      
      @window.draw_line(
        x, draw_start, color,
        x, draw_end, color
      )
    end

    def determine_wall_color(intersection)
      color = if intersection.side == 0
                intersection.ray_dir_x > 0 ? WALL_COLORS[:east] : WALL_COLORS[:west]
              else
                intersection.ray_dir_y > 0 ? WALL_COLORS[:south] : WALL_COLORS[:north]
              end
      
      # Make color darker for y-sides
      if intersection.side == 1
        color = color.dup
        color.alpha = 200
      end
      
      color
    end
  end

  class Ray
    attr_reader :direction_x, :direction_y, :camera_x

    def initialize(player, screen_x, screen_width)
      @camera_x = 2 * screen_x.to_f / screen_width - 1
      @direction_x = player.direction[0] + player.plane[0] * @camera_x
      @direction_y = player.direction[1] + player.plane[1] * @camera_x
    end
  end

  class RayCaster
    def initialize(map, player, ray)
      @map = map
      @player = player
      @ray = ray
      @map_x = player.position[0].to_i
      @map_y = player.position[1].to_i
    end

    def cast
      setup_dda
      perform_dda
      calculate_intersection if @hit
    end

    private

    def setup_dda
      @delta_dist_x = @ray.direction_x.abs < 0.00001 ? Float::INFINITY : (1.0 / @ray.direction_x.abs)
      @delta_dist_y = @ray.direction_y.abs < 0.00001 ? Float::INFINITY : (1.0 / @ray.direction_y.abs)
      
      @step_x = @ray.direction_x < 0 ? -1 : 1
      @step_y = @ray.direction_y < 0 ? -1 : 1
      
      @side_dist_x = @ray.direction_x < 0 ? 
        (@player.position[0] - @map_x) * @delta_dist_x : 
        (@map_x + 1.0 - @player.position[0]) * @delta_dist_x
      @side_dist_y = @ray.direction_y < 0 ? 
        (@player.position[1] - @map_y) * @delta_dist_y : 
        (@map_y + 1.0 - @player.position[1]) * @delta_dist_y
      
      @hit = false
      @side = 0
    end

    def perform_dda
      while !@hit
        if @side_dist_x < @side_dist_y
          @side_dist_x += @delta_dist_x
          @map_x += @step_x
          @side = 0
        else
          @side_dist_y += @delta_dist_y
          @map_y += @step_y
          @side = 1
        end
        
        @hit = @map.wall_at?(@map_x, @map_y)
      end
    end

    def calculate_intersection
      perp_wall_dist = if @side == 0
                        (@map_x - @player.position[0] + (1 - @step_x) / 2) / @ray.direction_x
                      else
                        (@map_y - @player.position[1] + (1 - @step_y) / 2) / @ray.direction_y
                      end
      
      WallIntersection.new(
        distance: perp_wall_dist,
        side: @side,
        ray_dir_x: @ray.direction_x,
        ray_dir_y: @ray.direction_y
      )
    end
  end

  class WallIntersection
    attr_reader :distance, :side, :ray_dir_x, :ray_dir_y

    def initialize(distance:, side:, ray_dir_x:, ray_dir_y:)
      @distance = distance
      @side = side
      @ray_dir_x = ray_dir_x
      @ray_dir_y = ray_dir_y
    end
  end

  class MinimapRenderer
    MINIMAP_SIZE = 150
    MINIMAP_MARGIN = 10
    PLAYER_SIZE = 4
    WALL_COLOR = Gosu::Color.new(255, 200, 200, 200)
    EMPTY_COLOR = Gosu::Color.new(255, 50, 50, 50)
    PLAYER_COLOR = Gosu::Color::RED

    def initialize(window, map)
      @window = window
      @map = map
      @cell_size = MINIMAP_SIZE / [@map.width, @map.height].max
    end

    def render(player)
      draw_background
      draw_walls
      draw_player(player)
    end

    private

    def draw_background
      x = @window.width - MINIMAP_SIZE - MINIMAP_MARGIN
      y = @window.height - MINIMAP_SIZE - MINIMAP_MARGIN
      @window.draw_quad(
        x, y, EMPTY_COLOR,
        x + MINIMAP_SIZE, y, EMPTY_COLOR,
        x, y + MINIMAP_SIZE, EMPTY_COLOR,
        x + MINIMAP_SIZE, y + MINIMAP_SIZE, EMPTY_COLOR
      )
    end

    def draw_walls
      @map.height.times do |y|
        @map.width.times do |x|
          if @map.wall_at?(x, y)
            draw_cell(x, y, WALL_COLOR)
          end
        end
      end
    end

    def draw_cell(x, y, color)
      base_x = @window.width - MINIMAP_SIZE - MINIMAP_MARGIN + (x * @cell_size)
      base_y = @window.height - MINIMAP_SIZE - MINIMAP_MARGIN + (y * @cell_size)
      @window.draw_quad(
        base_x, base_y, color,
        base_x + @cell_size, base_y, color,
        base_x, base_y + @cell_size, color,
        base_x + @cell_size, base_y + @cell_size, color
      )
    end

    def draw_player(player)
      x = @window.width - MINIMAP_SIZE - MINIMAP_MARGIN + (player.position[0] * @cell_size)
      y = @window.height - MINIMAP_SIZE - MINIMAP_MARGIN + (player.position[1] * @cell_size)
      
      @window.draw_quad(
        x - PLAYER_SIZE, y - PLAYER_SIZE, PLAYER_COLOR,
        x + PLAYER_SIZE, y - PLAYER_SIZE, PLAYER_COLOR,
        x - PLAYER_SIZE, y + PLAYER_SIZE, PLAYER_COLOR,
        x + PLAYER_SIZE, y + PLAYER_SIZE, PLAYER_COLOR
      )
      
      # Draw player direction line
      dir_x = x + player.direction[0] * PLAYER_SIZE * 2
      dir_y = y + player.direction[1] * PLAYER_SIZE * 2
      @window.draw_line(x, y, PLAYER_COLOR, dir_x, dir_y, PLAYER_COLOR)
    end
  end
end 