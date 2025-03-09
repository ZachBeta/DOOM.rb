# frozen_string_literal: true

module Doom
  module Renderer
    class RayCaster
      attr_reader :map, :player, :height

      def initialize(map, player, height)
        @map = map
        @player = player
        @height = height
      end

      def cast_rays(width)
        rays = []

        width.times do |x|
          # Calculate ray position and direction
          # x-coordinate in camera space (from -1 to 1)
          camera_x = (2.0 * x / width) - 1.0
          ray_dir_x = player.direction[0] + (player.plane[0] * camera_x)
          ray_dir_y = player.direction[1] + (player.plane[1] * camera_x)

          # Which box of the map we're in
          map_x = player.position[0].to_i
          map_y = player.position[1].to_i

          # Length of ray from current position to next x or y-side
          delta_dist_x = ray_dir_x.abs < 0.00001 ? Float::INFINITY : (1.0 / ray_dir_x).abs
          delta_dist_y = ray_dir_y.abs < 0.00001 ? Float::INFINITY : (1.0 / ray_dir_y).abs

          # Direction to step in x or y direction (either +1 or -1)
          step_x = ray_dir_x < 0 ? -1 : 1
          step_y = ray_dir_y < 0 ? -1 : 1

          # Length of ray from one side to next in map
          side_dist_x = if ray_dir_x < 0
                          (player.position[0] - map_x) * delta_dist_x
                        else
                          (map_x + 1.0 - player.position[0]) * delta_dist_x
                        end
          side_dist_y = if ray_dir_y < 0
                          (player.position[1] - map_y) * delta_dist_y
                        else
                          (map_y + 1.0 - player.position[1]) * delta_dist_y
                        end

          # Perform DDA (Digital Differential Analysis)
          hit = false
          side = 0 # 0 for x-side, 1 for y-side

          until hit
            # Jump to next map square, either in x-direction, or in y-direction
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
            hit = true if map.wall_at?(map_x, map_y)
          end

          # Calculate distance projected on camera direction
          perp_wall_dist = if side == 0
                             (map_x - player.position[0] + ((1 - step_x) / 2)) / ray_dir_x
                           else
                             (map_y - player.position[1] + ((1 - step_y) / 2)) / ray_dir_y
                           end

          # Calculate height of line to draw on screen
          line_height = (@height / perp_wall_dist).to_i

          # Calculate lowest and highest pixel to fill in current stripe
          draw_start = [(-line_height / 2) + (@height / 2), 0].max
          draw_end = [(line_height / 2) + (@height / 2), @height - 1].min

          # Calculate texture coordinates
          wall_x = if side == 0
                     player.position[1] + (perp_wall_dist * ray_dir_y)
                   else
                     player.position[0] + (perp_wall_dist * ray_dir_x)
                   end
          wall_x -= wall_x.to_i

          # Store ray information
          rays << {
            x: x,
            perp_wall_dist: perp_wall_dist,
            draw_start: draw_start,
            draw_end: draw_end,
            side: side,
            map_x: map_x,
            map_y: map_y,
            wall_x: wall_x,
            step_x: step_x,
            step_y: step_y,
            ray_dir_x: ray_dir_x,
            ray_dir_y: ray_dir_y
          }
        end

        rays
      end
    end
  end
end
