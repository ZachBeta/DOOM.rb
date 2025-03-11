# frozen_string_literal: true

require 'matrix'
require_relative '../logger'

module Doom
  module Renderer
    class WallRenderer
      def initialize(width, height)
        @logger = Logger.instance
        @logger.info('WallRenderer: Initializing')

        @width = width
        @height = height
        @pixel_buffer = Array.new(width * height * 4, 0) # RGBA format

        @logger.info('WallRenderer: Initialization complete')
      end

      def render(rays)
        @logger.debug('WallRenderer: Rendering walls')

        rays.each_with_index do |ray, x|
          # Calculate wall height based on distance
          wall_height = (@height / ray[:perp_wall_dist]).to_i
          wall_height = @height if wall_height > @height

          # Calculate wall strip position
          wall_top = (@height - wall_height) / 2
          wall_bottom = wall_top + wall_height

          # Draw wall strip
          (wall_top...wall_bottom).each do |y|
            # Calculate intensity based on distance
            intensity = (255.0 * (1.0 - ray[:perp_wall_dist] / 10.0)).to_i
            intensity = [[intensity, 0].max, 255].min

            # Set pixel color (grayscale for now)
            set_pixel(x, y, [intensity, intensity, intensity, 255])
          end
        end

        @logger.debug('WallRenderer: Walls rendered')
        @pixel_buffer
      end

      private

      def set_pixel(x, y, color)
        return unless x.between?(0, @width - 1) && y.between?(0, @height - 1)

        index = (y * @width + x) * 4
        @pixel_buffer[index] = color[0]     # R
        @pixel_buffer[index + 1] = color[1] # G
        @pixel_buffer[index + 2] = color[2] # B
        @pixel_buffer[index + 3] = color[3] # A
      end
    end
  end
end
