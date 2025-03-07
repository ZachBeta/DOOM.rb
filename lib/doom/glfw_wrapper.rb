# frozen_string_literal: true

require 'glfw3'
require_relative 'logger'

module Doom
  class GlfwWrapper
    # Constants
    CONTEXT_VERSION_MAJOR = 0x00022002
    CONTEXT_VERSION_MINOR = 0x00022003
    OPENGL_PROFILE = 0x00022008
    OPENGL_CORE_PROFILE = 0x00032001
    VISIBLE = 0x00020004
    TRUE = 1
    FALSE = 0
    PRESS = 1
    RELEASE = 0

    # Key constants
    KEY_W = 0x57
    KEY_S = 0x53
    KEY_A = 0x41
    KEY_D = 0x44
    KEY_LEFT = 0x25
    KEY_RIGHT = 0x27
    KEY_N = 0x4E
    KEY_ESCAPE = 0x1B

    class << self
      def instance
        @instance ||= new
      end

      private :new
    end

    def initialize
      @logger = Logger.instance
      @initialized = false
      @window = nil
      init
    end

    def init
      return if @initialized

      @logger.debug('Initializing GLFW')
      begin
        @logger.debug('Environment:')
        @logger.debug("DYLD_LIBRARY_PATH: #{ENV.fetch('DYLD_LIBRARY_PATH', nil)}")
        @logger.debug("DYLD_FALLBACK_LIBRARY_PATH: #{ENV.fetch('DYLD_FALLBACK_LIBRARY_PATH', nil)}")
        @logger.debug("LD_LIBRARY_PATH: #{ENV.fetch('LD_LIBRARY_PATH', nil)}")

        @logger.debug('Calling glfwInit()')
        result = Glfw.init
        @logger.debug("glfwInit() returned: #{result}")

        if result
          @initialized = true
          @logger.info('GLFW initialized successfully')
        else
          @logger.error('GLFW initialization failed')
          raise 'Failed to initialize GLFW'
        end
      rescue StandardError => e
        @logger.error("Failed to initialize GLFW: #{e.message}")
        @logger.error(e.backtrace.join("\n"))
        raise
      end
    end

    def terminate
      return unless @initialized

      @logger.debug('Terminating GLFW')
      @window&.destroy
      Glfw.terminate
      @initialized = false
      @window = nil
      @logger.info('GLFW terminated successfully')
    end

    def create_window(width, height, title)
      @logger.debug("Creating window: #{width}x#{height} - #{title}")
      @window = Glfw::Window.new(width, height, title)
      @window
    end

    attr_reader :window

    def initialized?
      @initialized
    end

    def poll_events
      @logger.debug('Polling GLFW events')
      Glfw.poll_events
    end

    def window_hint(hint, value)
      @logger.debug("Setting window hint: #{hint} = #{value}")
      Glfw::Window.window_hint(hint, value)
    end

    def default_window_hints
      @logger.debug('Setting default window hints')
      Glfw::Window.default_window_hints
    end

    def get_key(key)
      return nil unless @window

      @window.get_key(key)
    end

    def should_close?
      return false unless @window

      @window.should_close?
    end

    def swap_buffers
      return unless @window

      @window.swap_buffers
    end

    def make_context_current
      return unless @window

      @window.make_context_current
    end

    def destroy_window
      return unless @window

      @window.destroy
      @window = nil
    end
  end
end
