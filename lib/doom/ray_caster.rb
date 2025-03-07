# frozen_string_literal: true

module Doom
  class RayCaster
    def initialize(map, player, ray)
      @map = map
      @player = player
      @ray = ray
    end

    def cast
      # Calculate ray position and direction
      ray_pos_x = @player.position[0]
      ray_pos_y = @player.position[1]

      # Which box of the map we're in
      map_x = ray_pos_x.to_i
      map_y = ray_pos_y.to_i

      # Length of ray from current position to next x or y-side
      delta_dist_x = (@ray.direction_x.zero? ? Float::INFINITY : (1 / @ray.direction_x).abs)
      delta_dist_y = (@ray.direction_y.zero? ? Float::INFINITY : (1 / @ray.direction_y).abs)

      # Calculate step and initial side_dist
      if @ray.direction_x.negative?
        step_x = -1
        side_dist_x = (ray_pos_x - map_x) * delta_dist_x
      else
        step_x = 1
        side_dist_x = (map_x + 1.0 - ray_pos_x) * delta_dist_x
      end

      if @ray.direction_y.negative?
        step_y = -1
        side_dist_y = (ray_pos_y - map_y) * delta_dist_y
      else
        step_y = 1
        side_dist_y = (map_y + 1.0 - ray_pos_y) * delta_dist_y
      end

      # Perform DDA
      hit = false
      side = 0

      until hit
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

      # Calculate perpendicular wall distance
      perp_wall_dist = if side == 0
                         @ray.direction_x.zero? ? Float::INFINITY : (map_x - ray_pos_x + ((1 - step_x) / 2)) / @ray.direction_x
                       else
                         @ray.direction_y.zero? ? Float::INFINITY : (map_y - ray_pos_y + ((1 - step_y) / 2)) / @ray.direction_y
                       end

      # Calculate wall x coordinate
      wall_x = if side == 0
                 ray_pos_y + (perp_wall_dist * @ray.direction_y)
               else
                 ray_pos_x + (perp_wall_dist * @ray.direction_x)
               end
      wall_x -= wall_x.floor if wall_x.finite? && !wall_x.nan?

      WallIntersection.new(
        distance: perp_wall_dist,
        wall_x: wall_x,
        side: side,
        ray_dir_x: @ray.direction_x,
        ray_dir_y: @ray.direction_y
      )
    end
  end
end
