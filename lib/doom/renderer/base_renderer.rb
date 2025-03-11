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
        @last_frame_time = Time.now
        @frame_budget = 1.0 / 30.0  # Target 30 FPS
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

        # Frame time budgeting
        current_time = Time.now
        delta = current_time - @last_frame_time
        if delta < @frame_budget
          sleep(@frame_budget - delta)
        end
        @last_frame_time = Time.now

        clear_pixel_buffer
        rays = @ray_caster.cast_rays(@window_manager.width)
        
        # Draw walls using optimized buffer access
        rays.each_with_index do |ray, x|
          next unless ray.hit?
          
          wall_height = (@window_manager.height / ray.distance).to_i
          wall_start = [(@window_manager.height - wall_height) / 2, 0].max
          wall_end = [wall_start + wall_height, @window_manager.height].min
          
          # Calculate wall color based on distance and side
          intensity = [(1.0 - ray.distance / 10.0), 0.2].max
          # Darker for y-side walls to create contrast
          intensity *= 0.8 if ray.side == 1
          
          color = [
            (intensity * 255).to_i,  # Red
            (intensity * 200).to_i,  # Green
            (intensity * 150).to_i,  # Blue
            255                      # Alpha
          ]
          
          # Batch draw wall column
          draw_column(x, wall_start, wall_end, color)
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
        buffer_size = @window_manager.width * @window_manager.height * BYTES_PER_PIXEL
        
        # Pre-allocate buffers
        @pixel_buffer = String.new(capacity: buffer_size)
        @pixel_buffer << "\x00" * buffer_size
        @temp_buffer = String.new(capacity: BYTES_PER_PIXEL * @window_manager.height)
      end

      def clear_pixel_buffer
        # Fast clear using string operations
        @pixel_buffer.clear
        @pixel_buffer << "\x00" * (@window_manager.width * @window_manager.height * BYTES_PER_PIXEL)
      end

      def draw_column(x, start_y, end_y, color)
        return unless x >= 0 && x < @window_manager.width
        
        # Pre-calculate color string once
        @temp_buffer.clear
        color_str = color.pack('C*')
        height = end_y - start_y
        
        # Fill temp buffer with repeated color
        height.times { @temp_buffer << color_str }
        
        # Calculate offset once
        offset = (start_y * @window_manager.width + x) * BYTES_PER_PIXEL
        
        # Single string operation to update column
        @pixel_buffer[offset, height * BYTES_PER_PIXEL] = @temp_buffer[0, height * BYTES_PER_PIXEL]
      end

      def update_window
        # Direct buffer update without conversion
        @window_manager.window.set_pixels(
          0, 0,
          @window_manager.width,
          @window_manager.height,
          Glfw::RGBA,
          @pixel_buffer
        )
        
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
