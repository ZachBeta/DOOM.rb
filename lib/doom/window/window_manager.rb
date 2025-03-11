# frozen_string_literal: true

require 'glfw3'
require_relative '../logger'

module Doom
  module Window
    class WindowManager
      WINDOW_WIDTH = 800
      WINDOW_HEIGHT = 600
      WINDOW_TITLE = 'DOOM.rb'

      attr_reader :window, :width, :height

      def initialize
        @logger = Logger.instance
        @width = 800
        @height = 600
        @should_close = false
        @cleaned_up = false

        @logger.info('WindowManager: Starting initialization')
        init_glfw
        create_window
        setup_signal_handlers
        @logger.info('WindowManager: Initialization complete')
      end

      def should_close?
        @logger.debug('WindowManager: Checking window close state')
        return true if @cleaned_up
        window_should_close = @window.should_close?
        @should_close ||= window_should_close
        @logger.debug("WindowManager: Window should close: #{@should_close}")
        @should_close
      end

      def should_close=(value)
        @logger.info("WindowManager: Setting should_close to #{value}")
        @should_close = value
        @window.should_close = value if @window
      end

      def poll_events
        return if @cleaned_up
        @logger.debug('WindowManager: Polling events')
        Glfw.poll_events
      end

      def swap_buffers
        return if @cleaned_up
        @logger.debug('WindowManager: Swapping buffers')
        begin
          @window.swap_buffers
        rescue StandardError => e
          @logger.error("WindowManager: Error swapping buffers: #{e.message}")
          @logger.error(e.backtrace.join("\n"))
          @should_close = true
        end
      end

      def key_pressed?(key_code)
        return false if @cleaned_up
        @logger.debug("WindowManager: Checking key #{key_code}")
        begin
          state = @window.key(key_code)
          @logger.debug("WindowManager: Key #{key_code} state: #{state}")
          state == Glfw::PRESS
        rescue StandardError => e
          @logger.error("WindowManager: Error checking key state: #{e.message}")
          false
        end
      end

      def cleanup
        return if @cleaned_up
        @logger.info('WindowManager: Starting cleanup')
        begin
          if @window
            @logger.info('WindowManager: Destroying window')
            @window.destroy
            @window = nil
          end
          if Glfw.initialized?
            @logger.info('WindowManager: Terminating GLFW')
            Glfw.terminate
          end
          @cleaned_up = true
          @logger.info('WindowManager: Cleanup complete')
        rescue StandardError => e
          @logger.error("WindowManager: Error during cleanup: #{e.message}")
          @logger.error(e.backtrace.join("\n"))
          @cleaned_up = true  # Mark as cleaned up even on error to prevent further operations
        end
      end

      def update_framebuffer(buffer)
        return if @cleaned_up
        @logger.debug("WindowManager: Updating framebuffer (buffer size: #{buffer.bytesize})")
        begin
          # For now, just maintain window responsiveness
          swap_buffers
          poll_events
        rescue StandardError => e
          @logger.error("WindowManager: Error updating framebuffer: #{e.message}")
          @logger.error(e.backtrace.join("\n"))
          @should_close = true
        end
      end

      private

      def init_glfw
        @logger.info('WindowManager: Initializing GLFW')
        begin
          unless Glfw.init
            @logger.error('WindowManager: Failed to initialize GLFW')
            raise 'Failed to initialize GLFW'
          end
          @logger.info('WindowManager: GLFW initialized successfully')
        rescue StandardError => e
          @logger.error("WindowManager: Error initializing GLFW: #{e.message}")
          @logger.error(e.backtrace.join("\n"))
          raise
        end
      end

      def create_window
        @logger.info('WindowManager: Creating window')
        begin
          # Set up window hints for software rendering
          @logger.debug('WindowManager: Setting window hints')
          Glfw::Window.window_hint(Glfw::RESIZABLE, 0)
          Glfw::Window.window_hint(Glfw::DECORATED, 1)
          Glfw::Window.window_hint(Glfw::FOCUSED, 1)
          Glfw::Window.window_hint(Glfw::VISIBLE, 1)
          
          @logger.debug('WindowManager: Creating window instance')
          @window = Glfw::Window.new(@width, @height, WINDOW_TITLE)
          
          unless @window
            @logger.error('WindowManager: Failed to create window')
            raise 'Failed to create GLFW window'
          end
          
          @logger.info('WindowManager: Window created successfully')
        rescue StandardError => e
          @logger.error("WindowManager: Error creating window: #{e.message}")
          @logger.error(e.backtrace.join("\n"))
          raise
        end
      end

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
        cleanup
      end
    end
  end
end
