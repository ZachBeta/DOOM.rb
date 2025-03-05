require_relative 'map'

module Doom
  class Renderer
    WALL_COLORS = {
      north: Gosu::Color.new(255, 255, 0, 0),    # Red
      south: Gosu::Color.new(255, 0, 255, 0),    # Green
      east: Gosu::Color.new(255, 0, 0, 255),     # Blue
      west: Gosu::Color.new(255, 255, 255, 0)    # Yellow
    }
    FLOOR_COLOR = Gosu::Color.new(255, 50, 50, 50)
    CEILING_COLOR = Gosu::Color.new(255, 100, 100, 150)

    def initialize(window)
      @window = window
      @map = Map.new
      @width = window.width
      @height = window.height
    end

    def render(player)
      # Draw ceiling and floor
      @window.draw_quad(
        0, 0, CEILING_COLOR,
        @width, 0, CEILING_COLOR,
        0, @height / 2, CEILING_COLOR,
        @width, @height / 2, CEILING_COLOR
      )
      
      @window.draw_quad(
        0, @height / 2, FLOOR_COLOR,
        @width, @height / 2, FLOOR_COLOR,
        0, @height, FLOOR_COLOR,
        @width, @height, FLOOR_COLOR
      )

      # Cast rays for each column of the screen
      @width.times do |x|
        # Calculate ray position and direction
        camera_x = 2 * x.to_f / @width - 1  # x-coordinate in camera space
        ray_dir_x = player.direction[0] + player.plane[0] * camera_x
        ray_dir_y = player.direction[1] + player.plane[1] * camera_x
        
        # Current position
        map_x = player.position[0].to_i
        map_y = player.position[1].to_i
        
        # Length of ray from current position to next x or y-side
        delta_dist_x = ray_dir_x.abs < 0.00001 ? Float::INFINITY : (1.0 / ray_dir_x.abs)
        delta_dist_y = ray_dir_y.abs < 0.00001 ? Float::INFINITY : (1.0 / ray_dir_y.abs)
        
        # Direction to step in x or y direction (either +1 or -1)
        step_x = ray_dir_x < 0 ? -1 : 1
        step_y = ray_dir_y < 0 ? -1 : 1
        
        # Length of ray from one side to next
        side_dist_x = ray_dir_x < 0 ? 
          (player.position[0] - map_x) * delta_dist_x : 
          (map_x + 1.0 - player.position[0]) * delta_dist_x
        side_dist_y = ray_dir_y < 0 ? 
          (player.position[1] - map_y) * delta_dist_y : 
          (map_y + 1.0 - player.position[1]) * delta_dist_y
        
        # Perform DDA (Digital Differential Analysis)
        hit = false
        side = 0  # 0 for x-side, 1 for y-side
        
        while !hit
          # Jump to next map square
          if side_dist_x < side_dist_y
            side_dist_x += delta_dist_x
            map_x += step_x
            side = 0
          else
            side_dist_y += delta_dist_y
            map_y += step_y
            side = 1
          end
          
          # Check if ray has hit a wall
          hit = @map.wall_at?(map_x, map_y)
        end
        
        # Calculate distance projected on camera direction
        perp_wall_dist = if side == 0
                          (map_x - player.position[0] + (1 - step_x) / 2) / ray_dir_x
                        else
                          (map_y - player.position[1] + (1 - step_y) / 2) / ray_dir_y
                        end
        
        # Calculate height of line to draw on screen
        line_height = (@height / perp_wall_dist).to_i
        
        # Calculate lowest and highest pixel to fill in current stripe
        draw_start = [-line_height / 2 + @height / 2, 0].max
        draw_end = [line_height / 2 + @height / 2, @height - 1].min
        
        # Choose wall color based on side
        color = if side == 0
                  ray_dir_x > 0 ? WALL_COLORS[:east] : WALL_COLORS[:west]
                else
                  ray_dir_y > 0 ? WALL_COLORS[:south] : WALL_COLORS[:north]
                end
        
        # Make color darker for y-sides
        color = color.dup
        color.alpha = 200 if side == 1
        
        # Draw the vertical line
        @window.draw_line(
          x, draw_start, color,
          x, draw_end, color
        )
      end
    end
  end
end 