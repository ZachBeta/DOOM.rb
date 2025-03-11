# frozen_string_literal: true

require 'gosu'
require_relative '../logger'

module Doom
  module Window
    class WindowManager < Gosu::Window
      WINDOW_WIDTH = 800
      WINDOW_HEIGHT = 600
      WINDOW_TITLE = 'DOOM.rb'

      attr_reader :width, :height

      def initialize
        @logger = Logger.instance
        @width = WINDOW_WIDTH
        @height = WINDOW_HEIGHT
        @should_close = false
        @frame_time = Time.now
        @frame_interval = 1.0 / 60.0  # Target 60 FPS
        @pixel_buffer = nil

        @logger.info('WindowManager: Starting initialization')
        super(@width, @height, false)  # false = windowed mode
        self.caption = WINDOW_TITLE
        setup_signal_handlers
        @logger.info('WindowManager: Initialization complete')
      end

      def update
        @logger.debug('WindowManager: Update cycle')
        current_time = Time.now
        delta = current_time - @frame_time
        if delta < @frame_interval
          sleep(@frame_interval - delta)
        end
        @frame_time = Time.now
      end

      def draw
        @logger.debug('WindowManager: Draw cycle')
        if @pixel_buffer
          @pixel_buffer.draw(0, 0, 0)
        end
      end

      def should_close?
        @logger.debug('WindowManager: Checking window close state')
        @should_close || self.close?
      end

      def should_close=(value)
        @logger.info("WindowManager: Setting should_close to #{value}")
        @should_close = value
        close! if value
      end

      def poll_events
        # Not needed in Gosu - event handling is automatic
      end

      def swap_buffers
        # Not needed in Gosu - buffer swapping is automatic
      end

      def key_pressed?(key_code)
        @logger.debug("WindowManager: Checking key #{key_code}")
        begin
          button_down?(key_code)
        rescue StandardError => e
          @logger.error("WindowManager: Error checking key state: #{e.message}")
          false
        end
      end

      def button_down(id)
        super
        if id == Gosu::KB_ESCAPE
          @should_close = true
        end
      end

      def cleanup
        @logger.info('WindowManager: Starting cleanup')
        begin
          close!
          @logger.info('WindowManager: Cleanup complete')
        rescue StandardError => e
          @logger.error("WindowManager: Error during cleanup: #{e.message}")
          @logger.error(e.backtrace.join("\n"))
        end
      end

      def update_framebuffer(buffer)
        @logger.debug("WindowManager: Updating framebuffer (buffer size: #{buffer.bytesize})")
        begin
          # Convert buffer to Gosu::Image
          width_i = width.to_i
          height_i = height.to_i
          
          # Create Gosu::Image from pixel data
          @pixel_buffer = Gosu::Image.from_blob(
            width_i, 
            height_i,
            buffer
          )
        rescue StandardError => e
          @logger.error("WindowManager: Error updating framebuffer: #{e.message}")
          @logger.error(e.backtrace.join("\n"))
          @should_close = true
        end
      end

      private

      def setup_signal_handlers
        @logger.info('WindowManager: Setting up signal handlers')
        begin
          trap('INT') { graceful_exit }
          trap('TERM') { graceful_exit }
          @logger.info('WindowManager: Signal handlers set up successfully')
        rescue StandardError => e
          @logger.error("WindowManager: Error setting up signal handlers: #{e.message}")
          @logger.error(e.backtrace.join("\n"))
        end
      end

      def graceful_exit
        @logger.info('WindowManager: Initiating graceful exit')
        @should_close = true
      end
    end
  end
end
