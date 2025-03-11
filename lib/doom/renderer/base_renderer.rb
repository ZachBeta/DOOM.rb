# frozen_string_literal: true

require 'glfw3'
require_relative 'ray_caster'
require_relative '../logger'

module Doom
  module Renderer
    class BaseRenderer
      WINDOW_WIDTH = 800
      WINDOW_HEIGHT = 600
      WINDOW_TITLE = 'DOOM.rb'
      BYTES_PER_PIXEL = 4  # RGBA format

      attr_reader :window

      def initialize
        @logger = Logger.instance
        @logger.info('BaseRenderer: Initializing')

        setup_signal_handlers
        init_glfw
        create_window
        init_pixel_buffer

        @frame_count = 0
        @start_time = Time.now
        @background_color = [0, 0, 0, 255] # RGBA black

        @logger.info('BaseRenderer: Initialization complete')
      end

      def set_game_objects(map, player)
        @map = map
        @player = player
        @ray_caster = RayCaster.new(@map, @player, WINDOW_HEIGHT)
        @logger.info('BaseRenderer: Game objects set')
      end

      def render
        return unless @map && @player

        @logger.debug('BaseRenderer: Starting render cycle')

        # Clear pixel buffer with background color
        clear_pixel_buffer

        # Cast rays for wall rendering
        rays = @ray_caster.cast_rays(WINDOW_WIDTH)
        
        # Render walls using software rendering
        render_walls(rays)

        # Update window with pixel buffer
        update_window

        # Calculate and log FPS every 100 frames
        calculate_fps if (@frame_count % 100).zero?

        # Check for escape key to close window
        @window.should_close = true if @window.key(Glfw::KEY_ESCAPE) == Glfw::PRESS

        # Poll for events
        Glfw.poll_events

        @frame_count += 1
        @logger.debug('BaseRenderer: Render cycle complete')
      end

      def window_should_close?
        @window.should_close?
      end

      def cleanup
        return if @cleaned_up

        @logger.info('BaseRenderer: Starting cleanup')
        begin
          if @window
            @window.destroy
            @window = nil
            @logger.info('BaseRenderer: Window destroyed')
          end

          if Glfw.init?
            Glfw.terminate
            @logger.info('BaseRenderer: GLFW terminated')
          end
        rescue StandardError => e
          @logger.error("BaseRenderer: Error during cleanup: #{e.message}")
          @logger.error(e.backtrace.join("\n"))
        ensure
          @cleaned_up = true
          @logger.info('BaseRenderer: Cleanup complete')
        end
      end

      private

      def init_glfw
        @logger.info('BaseRenderer: Initializing GLFW')
        unless Glfw.init
          @logger.error('BaseRenderer: Failed to initialize GLFW')
          raise 'Failed to initialize GLFW'
        end
      end

      def create_window
        @logger.info('BaseRenderer: Creating window')
        
        # Create window without OpenGL context
        Glfw::Window.window_hint(Glfw::RESIZABLE, false) # Lock window size
        Glfw::Window.window_hint(Glfw::CLIENT_API, Glfw::NO_API) # Don't create OpenGL context
        
        @window = Glfw::Window.new(WINDOW_WIDTH, WINDOW_HEIGHT, WINDOW_TITLE)
        unless @window
          @logger.error('BaseRenderer: Failed to create GLFW window')
          Glfw.terminate
          raise 'Failed to create GLFW window'
        end
      end

      def init_pixel_buffer
        @logger.info('BaseRenderer: Initializing pixel buffer')
        buffer_size = WINDOW_WIDTH * WINDOW_HEIGHT * BYTES_PER_PIXEL
        @pixel_buffer = Array.new(buffer_size, 0)
      end

      def clear_pixel_buffer
        (0...WINDOW_HEIGHT).each do |y|
          (0...WINDOW_WIDTH).each do |x|
            set_pixel(x, y, @background_color)
          end
        end
      end

      def set_pixel(x, y, color)
        return unless x.between?(0, WINDOW_WIDTH - 1) && y.between?(0, WINDOW_HEIGHT - 1)
        
        index = (y * WINDOW_WIDTH + x) * BYTES_PER_PIXEL
        @pixel_buffer[index] = color[0]     # R
        @pixel_buffer[index + 1] = color[1] # G
        @pixel_buffer[index + 2] = color[2] # B
        @pixel_buffer[index + 3] = color[3] # A
      end

      def render_walls(rays)
        rays.each_with_index do |ray, x|
          # Calculate wall height based on distance
          wall_height = (WINDOW_HEIGHT / ray[:perp_wall_dist]).to_i
          wall_height = WINDOW_HEIGHT if wall_height > WINDOW_HEIGHT

          # Calculate wall strip position
          wall_top = (WINDOW_HEIGHT - wall_height) / 2
          wall_bottom = wall_top + wall_height

          # Draw wall strip
          (wall_top...wall_bottom).each do |y|
            # Calculate intensity based on distance
            intensity = (255.0 * (1.0 - ray[:perp_wall_dist] / 10.0)).to_i
            intensity = [[intensity, 0].max, 255].min
            set_pixel(x, y, [intensity, intensity, intensity, 255])
          end
        end
      end

      def update_window
        # Create a string from the pixel buffer
        pixel_data = @pixel_buffer.pack('C*')
        
        # Since we're using software rendering without OpenGL,
        # we need to manually update the window's framebuffer
        # For now, we'll just swap buffers to prevent screen tearing
        @window.swap_buffers
      end

      def calculate_fps
        current_time = Time.now
        elapsed = current_time - @start_time
        fps = @frame_count / elapsed

        @logger.info("BaseRenderer: FPS: #{fps.round(2)} (#{@frame_count} frames in #{elapsed.round(2)}s)")

        # Reset counters every 1000 frames to avoid overflow
        return unless @frame_count >= 1000

        @frame_count = 0
        @start_time = current_time
      end

      def setup_signal_handlers
        @logger.info('BaseRenderer: Setting up signal handlers')
        trap('INT') { graceful_exit }
        trap('TERM') { graceful_exit }
      end

      def graceful_exit
        @logger.info('BaseRenderer: Graceful exit initiated')
        cleanup
        exit(0)
      end
    end
  end
end
