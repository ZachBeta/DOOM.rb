# frozen_string_literal: true

require_relative 'ray'

module Doom
  module Renderer
    class RayCaster
      attr_reader :map, :player, :height

      Ray = Struct.new(:ray_dir_x, :ray_dir_y, :side_dist_x, :side_dist_y,
                       :delta_dist_x, :delta_dist_y, :map_x, :map_y,
                       :step_x, :step_y, :side, :perp_wall_dist, :wall_x) do
        def hit?
          perp_wall_dist && perp_wall_dist.positive? && perp_wall_dist < Float::INFINITY
        end
      end

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
          ray = cast_ray(camera_x)

          # Calculate height of line to draw on screen
          line_height = (@height / ray.perp_wall_dist).to_i

          # Calculate lowest and highest pixel to fill in current stripe
          draw_start = [(-line_height / 2) + (@height / 2), 0].max
          draw_end = [(line_height / 2) + (@height / 2), @height - 1].min

          # Store ray information
          rays << ray
        end

        rays
      end

      def cast_ray(camera_x)
        ray = Ray.new

        # Calculate ray direction
        ray.ray_dir_x = @player.direction[0] + (@player.plane[0] * camera_x)
        ray.ray_dir_y = @player.direction[1] + (@player.plane[1] * camera_x)

        # Initialize DDA algorithm variables
        ray.map_x = @player.position[0].to_i
        ray.map_y = @player.position[1].to_i

        # Calculate delta distances
        ray.delta_dist_x = ray.ray_dir_x.abs < 1e-10 ? 1e30 : (1.0 / ray.ray_dir_x).abs
        ray.delta_dist_y = ray.ray_dir_y.abs < 1e-10 ? 1e30 : (1.0 / ray.ray_dir_y).abs

        # Calculate step and initial side distances
        calculate_step_and_side_dist(ray)

        # Perform DDA
        hit = false
        until hit
          # Jump to next map square
          if ray.side_dist_x < ray.side_dist_y
            ray.side_dist_x += ray.delta_dist_x
            ray.map_x += ray.step_x
            ray.side = 0
          else
            ray.side_dist_y += ray.delta_dist_y
            ray.map_y += ray.step_y
            ray.side = 1
          end

          # Check if ray has hit a wall
          hit = @map.wall_at?(ray.map_x, ray.map_y)
        end

        # Calculate distance projected on camera direction
        ray.perp_wall_dist = if ray.side == 0
                               ray.side_dist_x - ray.delta_dist_x
                             else
                               ray.side_dist_y - ray.delta_dist_y
                             end

        # Calculate wall X coordinate for texturing
        wall_x = if ray.side == 0
                   @player.position[1] + (ray.perp_wall_dist * ray.ray_dir_y)
                 else
                   @player.position[0] + (ray.perp_wall_dist * ray.ray_dir_x)
                 end
        ray.wall_x = wall_x - wall_x.floor

        ray
      end

      private

      def calculate_step_and_side_dist(ray)
        if ray.ray_dir_x < 0
          ray.step_x = -1
          ray.side_dist_x = (@player.position[0] - ray.map_x) * ray.delta_dist_x
        else
          ray.step_x = 1
          ray.side_dist_x = (ray.map_x + 1.0 - @player.position[0]) * ray.delta_dist_x
        end

        if ray.ray_dir_y < 0
          ray.step_y = -1
          ray.side_dist_y = (@player.position[1] - ray.map_y) * ray.delta_dist_y
        else
          ray.step_y = 1
          ray.side_dist_y = (ray.map_y + 1.0 - @player.position[1]) * ray.delta_dist_y
        end
      end
    end
  end
end
