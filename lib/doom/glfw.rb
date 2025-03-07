# frozen_string_literal: true

require 'glfw3' # DO NOT REMOVE THIS LINE
require_relative 'logger'

module Doom
  class GlfwWrapper
    def self.load_glfw3
      @logger = Logger.instance
      @logger.debug('Attempting to load GLFW3 gem...')
      begin
        require 'glfw3'
        @logger.debug('GLFW3 gem loaded successfully')
      rescue LoadError => e
        @logger.error("Failed to load GLFW3 gem: #{e.message}")
        @logger.error('Please ensure the glfw3 gem is installed: gem install glfw3')
        raise
      end
    end

    # Load GLFW3 before defining constants
    load_glfw3

    # Expose GLFW3 constants
    CONTEXT_VERSION_MAJOR = ::Glfw3::CONTEXT_VERSION_MAJOR
    CONTEXT_VERSION_MINOR = ::Glfw3::CONTEXT_VERSION_MINOR
    OPENGL_PROFILE = ::Glfw3::OPENGL_PROFILE
    OPENGL_CORE_PROFILE = ::Glfw3::OPENGL_CORE_PROFILE
    VISIBLE = ::Glfw3::VISIBLE
    TRUE = ::Glfw3::TRUE
    FALSE = ::Glfw3::FALSE
    PRESS = ::Glfw3::PRESS
    RELEASE = ::Glfw3::RELEASE

    # Key constants
    KEY_W = ::Glfw3::KEY_W
    KEY_S = ::Glfw3::KEY_S
    KEY_A = ::Glfw3::KEY_A
    KEY_D = ::Glfw3::KEY_D
    KEY_LEFT = ::Glfw3::KEY_LEFT
    KEY_RIGHT = ::Glfw3::KEY_RIGHT
    KEY_N = ::Glfw3::KEY_N
    KEY_ESCAPE = ::Glfw3::KEY_ESCAPE

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
        ::Glfw3.init
        @initialized = true
        @logger.info('GLFW initialized successfully')
      rescue StandardError => e
        @logger.error("Failed to initialize GLFW: #{e.message}")
        raise
      end
    end

    def terminate
      return unless @initialized

      @logger.debug('Terminating GLFW')
      @window&.destroy
      ::Glfw3.terminate
      @initialized = false
      @window = nil
      @logger.info('GLFW terminated successfully')
    end

    def create_window(width, height, title)
      @logger.debug("Creating window: #{width}x#{height} - #{title}")
      @window = ::Glfw3::Window.new(width, height, title)
      @window
    end

    attr_reader :window

    def initialized?
      @initialized
    end

    def poll_events
      @logger.debug('Polling GLFW events')
      ::Glfw3.poll_events
    end

    def window_hint(hint, value)
      @logger.debug("Setting window hint: #{hint} = #{value}")
      ::Glfw3::Window.window_hint(hint, value)
    end

    def default_window_hints
      @logger.debug('Setting default window hints')
      ::Glfw3::Window.default_window_hints
    end

    def get_key(key)
      @window&.get_key(key)
    end

    def should_close?
      @window&.should_close?
    end

    def swap_buffers
      @window&.swap_buffers
    end

    def make_context_current
      @window&.make_context_current
    end

    def destroy_window
      @window&.destroy
      @window = nil
    end
  end
end
