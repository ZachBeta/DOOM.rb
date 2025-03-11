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
        @width = WINDOW_WIDTH
        @height = WINDOW_HEIGHT
        @cleaned_up = false

        init_glfw
        create_window
        setup_signal_handlers
      end

      def should_close?
        @window.should_close?
      end

      def poll_events
        Glfw.poll_events
      end

      def swap_buffers
        @window.swap_buffers if @window
      end

      def key_pressed?(key_code)
        @window.key(key_code) == Glfw::PRESS
      end

      def cleanup
        return if @cleaned_up

        @logger.info('WindowManager: Starting cleanup')
        begin
          if @window
            @window.destroy
            @window = nil
            @logger.info('WindowManager: Window destroyed')
          end

          if Glfw.init?
            Glfw.terminate
            @logger.info('WindowManager: GLFW terminated')
          end
        rescue StandardError => e
          @logger.error("WindowManager: Error during cleanup: #{e.message}")
          @logger.error(e.backtrace.join("\n"))
        ensure
          @cleaned_up = true
          @logger.info('WindowManager: Cleanup complete')
        end
      end

      private

      def init_glfw
        @logger.info('WindowManager: Initializing GLFW')
        unless Glfw.init
          @logger.error('WindowManager: Failed to initialize GLFW')
          raise 'Failed to initialize GLFW'
        end
      end

      def create_window
        @logger.info('WindowManager: Creating window')
        
        # Set up window hints for software rendering
        Glfw::Window.window_hint(Glfw::RESIZABLE, 0)
        Glfw::Window.window_hint(Glfw::DECORATED, 1)
        Glfw::Window.window_hint(Glfw::FOCUSED, 1)
        Glfw::Window.window_hint(Glfw::VISIBLE, 1)
        Glfw::Window.window_hint(Glfw::CONTEXT_VERSION_MAJOR, 2)  # Use minimal version
        Glfw::Window.window_hint(Glfw::CONTEXT_VERSION_MINOR, 1)
        
        @window = Glfw::Window.new(@width, @height, WINDOW_TITLE)
        raise 'Failed to create GLFW window' unless @window
        
        @logger.info('WindowManager: Window created successfully')
      end

      def setup_signal_handlers
        @logger.info('WindowManager: Setting up signal handlers')
        trap('INT') { graceful_exit }
        trap('TERM') { graceful_exit }
      end

      def graceful_exit
        @logger.info('WindowManager: Graceful exit initiated')
        cleanup
        exit(0)
      end
    end
  end
end
