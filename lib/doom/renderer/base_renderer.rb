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
        @logger.info('BaseRenderer: Starting initialization')

        begin
          @window_manager = Window::WindowManager.new
          init_pixel_buffer

          @frame_count = 0
          @start_time = Time.now
          @last_frame_time = Time.now
          @frame_budget = 1.0 / 30.0  # Target 30 FPS
          @background_color = [0, 0, 0, 255] # RGBA black

          @logger.info('BaseRenderer: Initialization complete')
        rescue StandardError => e
          @logger.error("BaseRenderer: Error during initialization: #{e.message}")
          @logger.error(e.backtrace.join("\n"))
          raise
        end
      end

      def set_game_objects(map, player)
        @logger.info('BaseRenderer: Setting game objects')
        begin
          @map = map
          @player = player
          @ray_caster = RayCaster.new(@map, @player, @window_manager.height)
          @logger.info('BaseRenderer: Game objects set successfully')
        rescue StandardError => e
          @logger.error("BaseRenderer: Error setting game objects: #{e.message}")
          @logger.error(e.backtrace.join("\n"))
          raise
        end
      end

      def render
        return unless @map && @player
        
        @logger.debug('BaseRenderer: Starting frame render')
        begin
          # Frame time budgeting
          current_time = Time.now
          delta = current_time - @last_frame_time
          if delta < @frame_budget
            sleep(@frame_budget - delta)
          end
          @last_frame_time = Time.now

          clear_pixel_buffer
          rays = @ray_caster.cast_rays(@window_manager.width)
          
          @logger.debug("BaseRenderer: Processing #{rays.length} rays")
          rays.each_with_index do |ray, x|
            next unless ray.hit?
            
            wall_height = (@window_manager.height / ray.distance).to_i
            wall_start = [(@window_manager.height - wall_height) / 2, 0].max
            wall_end = [wall_start + wall_height, @window_manager.height].min
            
            intensity = [(1.0 - ray.distance / 10.0), 0.2].max
            intensity *= 0.8 if ray.side == 1
            
            color = [
              (intensity * 255).to_i,  # Red
              (intensity * 200).to_i,  # Green
              (intensity * 150).to_i,  # Blue
              255                      # Alpha
            ]
            
            draw_column(x, wall_start, wall_end, color)
          end
          
          update_window
          calculate_fps if (@frame_count % 100).zero?
          @window_manager.should_close = true if @window_manager.key_pressed?(Glfw::KEY_ESCAPE)
          @frame_count += 1
          
          @logger.debug('BaseRenderer: Frame render complete')
        rescue StandardError => e
          @logger.error("BaseRenderer: Error during render: #{e.message}")
          @logger.error(e.backtrace.join("\n"))
          @window_manager.should_close = true
        end
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
        @logger.info('BaseRenderer: Initializing pixel buffers')
        begin
          buffer_size = @window_manager.width * @window_manager.height * BYTES_PER_PIXEL
          @logger.debug("BaseRenderer: Creating buffers of size #{buffer_size} bytes")
          
          # Pre-allocate front and back buffers for double buffering
          @front_buffer = String.new(capacity: buffer_size)
          @back_buffer = String.new(capacity: buffer_size)
          @front_buffer << "\x00" * buffer_size
          @back_buffer << "\x00" * buffer_size
          @temp_buffer = String.new(capacity: BYTES_PER_PIXEL * @window_manager.height)
          
          @logger.info('BaseRenderer: Pixel buffers initialized successfully')
        rescue StandardError => e
          @logger.error("BaseRenderer: Error initializing pixel buffers: #{e.message}")
          @logger.error(e.backtrace.join("\n"))
          raise
        end
      end

      def clear_pixel_buffer
        @logger.debug('BaseRenderer: Clearing pixel buffer')
        begin
          # Fast clear using string operations
          @back_buffer.clear
          @back_buffer << "\x00" * (@window_manager.width * @window_manager.height * BYTES_PER_PIXEL)
        rescue StandardError => e
          @logger.error("BaseRenderer: Error clearing pixel buffer: #{e.message}")
          @logger.error(e.backtrace.join("\n"))
          raise
        end
      end

      def draw_column(x, start_y, end_y, color)
        return unless x >= 0 && x < @window_manager.width
        
        begin
          # Pre-calculate color string once
          @temp_buffer.clear
          color_str = color.pack('C*')
          height = end_y - start_y
          
          # Fill temp buffer with repeated color
          height.times { @temp_buffer << color_str }
          
          # Calculate offset once
          offset = (start_y * @window_manager.width + x) * BYTES_PER_PIXEL
          
          # Single string operation to update column
          @back_buffer[offset, height * BYTES_PER_PIXEL] = @temp_buffer[0, height * BYTES_PER_PIXEL]
        rescue StandardError => e
          @logger.error("BaseRenderer: Error drawing column at x=#{x}: #{e.message}")
          @logger.error(e.backtrace.join("\n"))
        end
      end

      def update_window
        @logger.debug('BaseRenderer: Updating window')
        begin
          # Swap front and back buffers
          @front_buffer, @back_buffer = @back_buffer, @front_buffer
          
          # Update window with the current frame buffer
          @window_manager.update_framebuffer(@front_buffer)

          # Poll events and handle window updates
          @window_manager.poll_events
          
          # Frame timing for consistent frame rate
          current_time = Time.now
          delta = current_time - @last_frame_time
          if delta < @frame_budget
            sleep(@frame_budget - delta)
          end
          @last_frame_time = current_time
        rescue StandardError => e
          @logger.error("BaseRenderer: Error updating window: #{e.message}")
          @logger.error(e.backtrace.join("\n"))
          @window_manager.should_close = true
        end
      end

      def calculate_fps
        begin
          current_time = Time.now
          elapsed = current_time - @start_time
          fps = @frame_count / elapsed

          @logger.info("BaseRenderer: FPS: #{fps.round(2)} (#{@frame_count} frames in #{elapsed.round(2)}s)")

          if @frame_count >= 1000
            @frame_count = 0
            @start_time = current_time
          end
        rescue StandardError => e
          @logger.error("BaseRenderer: Error calculating FPS: #{e.message}")
          @logger.error(e.backtrace.join("\n"))
        end
      end
    end
  end
end
