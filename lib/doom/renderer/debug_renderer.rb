# frozen_string_literal: true

require 'matrix'
require_relative '../logger'

module Doom
  module Renderer
    class DebugRenderer
      def initialize(width, height)
        @logger = Logger.instance
        @logger.info('DebugRenderer: Initializing')

        @width = width
        @height = height
        @pixel_buffer = Array.new(width * height * 4, 0) # RGBA format
        @font_size = 12 # Basic size for debug text
        @line_height = @font_size + 4 # Add some padding

        @logger.info('DebugRenderer: Initialization complete')
      end

      def render(player)
        @logger.debug('DebugRenderer: Rendering debug info')
        clear_buffer

        # Draw debug information
        draw_text(10, 20, "FPS: #{calculate_fps}")
        draw_text(10, 20 + @line_height, "Position: (#{player.x.round(2)}, #{player.y.round(2)})")
        draw_text(10, 20 + @line_height * 2, "Angle: #{(player.angle * 180 / Math::PI).round(2)}°")

        @logger.debug('DebugRenderer: Debug info rendered')
        @pixel_buffer
      end

      private

      def clear_buffer
        @pixel_buffer.fill(0)
      end

      def draw_text(x, y, text)
        return unless text

        # Simple text rendering - just basic white pixels for now
        # In a real implementation, you'd want to use a proper font rendering system
        text.each_char.with_index do |char, i|
          draw_char(x + i * (@font_size / 2), y, char)
        end
      end

      def draw_char(x, y, char)
        # Very basic character rendering - just a simple dot for each character
        # This is a placeholder - you'd want to implement proper font rendering
        5.times do |dx|
          5.times do |dy|
            set_pixel(x + dx, y + dy, [255, 255, 255, 255])
          end
        end
      end

      def set_pixel(x, y, color)
        return unless x.between?(0, @width - 1) && y.between?(0, @height - 1)

        index = (y * @width + x) * 4
        @pixel_buffer[index] = color[0]     # R
        @pixel_buffer[index + 1] = color[1] # G
        @pixel_buffer[index + 2] = color[2] # B
        @pixel_buffer[index + 3] = color[3] # A
      end

      def calculate_fps
        # This should be implemented to return actual FPS
        60 # Placeholder value
      end
    end
  end
end
