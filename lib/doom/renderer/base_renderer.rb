# frozen_string_literal: true

require_relative 'ray_caster'
require_relative '../logger'
require_relative '../window/window_manager'

module Doom
  module Renderer
    class BaseRenderer
      BYTES_PER_PIXEL = 4  # RGBA format

      attr_reader :window

      def initialize
        @logger = Logger.instance
        @logger.info('BaseRenderer: Initializing')

        @window_manager = Window::WindowManager.new
        init_pixel_buffer

        @frame_count = 0
        @start_time = Time.now
        @background_color = [0, 0, 0, 255] # RGBA black

        @logger.info('BaseRenderer: Initialization complete')
      end

      def set_game_objects(map, player)
        @map = map
        @player = player
        @ray_caster = RayCaster.new(@map, @player, @window_manager.height)
        @logger.info('BaseRenderer: Game objects set')
      end

      def render
        return unless @map && @player

        clear_pixel_buffer
        rays = @ray_caster.cast_rays(@window_manager.width)
        
        # Draw walls
        rays.each_with_index do |ray, x|
          next unless ray.hit?
          
          # Calculate wall height
          wall_height = (@window_manager.height / ray.distance).to_i
          wall_start = (@window_manager.height - wall_height) / 2
          wall_end = wall_start + wall_height
          
          # Clamp values to screen bounds
          wall_start = [wall_start, 0].max
          wall_end = [wall_end, @window_manager.height].min
          
          # Calculate wall color based on distance (darker = further)
          intensity = [(1.0 - ray.distance / 10.0), 0.2].max
          color = [
            (intensity * 255).to_i,  # Red
            (intensity * 200).to_i,  # Green
            (intensity * 150).to_i,  # Blue
            255                      # Alpha
          ]
          
          # Draw the wall column
          (wall_start...wall_end).each do |y|
            set_pixel(x, y, color)
          end
        end
        
        update_window
        calculate_fps if (@frame_count % 100).zero?
        @window_manager.should_close = true if @window_manager.key_pressed?(Glfw::KEY_ESCAPE)
        @frame_count += 1
      end

      def window_should_close?
        @window_manager.should_close?
      end

      def window
        @window_manager.window
      end

      def cleanup
        @window_manager.cleanup
      end

      private

      def init_pixel_buffer
        @logger.info('BaseRenderer: Initializing pixel buffer')
        @pixel_buffer = Array.new(@window_manager.width * @window_manager.height * BYTES_PER_PIXEL, 0)
      end

      def clear_pixel_buffer
        @pixel_buffer.fill(0)
      end

      def set_pixel(x, y, color)
        return unless x >= 0 && x < @window_manager.width && y >= 0 && y < @window_manager.height
        offset = (y * @window_manager.width + x) * BYTES_PER_PIXEL
        @pixel_buffer[offset] = color[0]     # Red
        @pixel_buffer[offset + 1] = color[1] # Green
        @pixel_buffer[offset + 2] = color[2] # Blue
        @pixel_buffer[offset + 3] = color[3] # Alpha
      end

      def update_window
        # For now, just swap buffers to keep the window responsive
        # We'll implement proper software rendering in the next iteration
        @window_manager.swap_buffers
        @window_manager.poll_events
      end

      def calculate_fps
        current_time = Time.now
        elapsed = current_time - @start_time
        fps = @frame_count / elapsed

        @logger.info("BaseRenderer: FPS: #{fps.round(2)} (#{@frame_count} frames in #{elapsed.round(2)}s)")

        return unless @frame_count >= 1000

        @frame_count = 0
        @start_time = current_time
      end
    end
  end
end
