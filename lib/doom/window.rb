# frozen_string_literal: true

require 'glfw3'
require 'opengl'
require 'matrix'
require_relative 'logger'
require_relative 'glfw'

module Doom
  class Window
    include OpenGL

    WIDTH = 800
    HEIGHT = 600
    TITLE = 'DOOM.rb'

    def initialize(width, height, title)
      @width = width
      @height = height
      @title = title
      @logger = Logger.instance
      @glfw = Glfw.instance
      @logger.info("Initializing window: #{width}x#{height} - #{title}")
      setup_glfw
      create_window
      setup_opengl
      check_gl_errors('Window initialization')
      @logger.info('OpenGL window initialized successfully')
    end

    def run
      @logger.info('Starting main render loop')
      until window_should_close?
        render
        poll_events
        swap_buffers
      end
      @logger.info('Render loop ended')
    end

    def close
      @logger.info('Starting window cleanup')
      begin
        cleanup_glfw
        @logger.info('Window cleanup completed successfully')
      rescue StandardError => e
        @logger.error("Error during window cleanup: #{e.message}")
        @logger.error(e.backtrace.join("\n"))
        raise
      end
    end

    def should_close?
      @window&.should_close?
    end

    def update
      @logger.debug('Updating window state')
      poll_events
    end

    def swap_buffers
      @window&.swap_buffers
      @logger.debug('Swapped buffers')
    end

    def clear
      @logger.debug('Clearing buffers')
      glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT)
      check_gl_errors('Clear buffers')
    end

    attr_reader :width, :height

    def button_down?(key)
      return false unless @window

      state = @window.get_key(key)
      @logger.debug("Key #{key} state: #{state}")
      state == Glfw3::PRESS
    end

    private

    def check_gl_errors(context)
      error = glGetError
      while error != GL_NO_ERROR
        @logger.error("OpenGL error in #{context}: #{error}")
        error = glGetError
      end
    end

    def setup_glfw
      @logger.debug('Setting up GLFW')
      @glfw.init
      @glfw.default_window_hints
      @glfw.window_hint(Glfw3::CONTEXT_VERSION_MAJOR, 3)
      @glfw.window_hint(Glfw3::CONTEXT_VERSION_MINOR, 3)
      @glfw.window_hint(Glfw3::OPENGL_PROFILE, Glfw3::OPENGL_CORE_PROFILE)
      @glfw.window_hint(Glfw3::VISIBLE, Glfw3::FALSE) if ENV['RACK_ENV'] == 'test'
    end

    def create_window
      @logger.debug('Creating GLFW window')
      @window = @glfw.create_window(@width, @height, @title)
      raise 'Failed to create GLFW window' if @window.nil?

      @window.make_context_current
    end

    def setup_opengl
      @logger.debug('Setting up OpenGL')
      OpenGL.load_lib
      @logger.debug('OpenGL library loaded')

      # Only try to get OpenGL info after context is current
      begin
        @logger.debug("OpenGL version: #{glGetString(GL_VERSION)}")
        @logger.debug("OpenGL vendor: #{glGetString(GL_VENDOR)}")
        @logger.debug("OpenGL renderer: #{glGetString(GL_RENDERER)}")
      rescue StandardError => e
        @logger.error("Failed to get OpenGL info: #{e.message}")
      end

      glViewport(0, 0, @width, @height)
      check_gl_errors('Viewport setup')
      @logger.debug("Viewport set to #{@width}x#{@height}")

      glEnable(GL_DEPTH_TEST)
      check_gl_errors('Depth test enable')
      @logger.debug('Depth testing enabled')

      glEnable(GL_BLEND)
      check_gl_errors('Blend enable')
      @logger.debug('Blending enabled')

      glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA)
      check_gl_errors('Blend function setup')
      @logger.debug('Blend function set')

      glClearColor(0.0, 0.0, 0.0, 1.0)
      check_gl_errors('Clear color setup')
      @logger.debug('Clear color set to black')
    end

    def cleanup_glfw
      @logger.debug('Cleaning up GLFW resources')
      @window.destroy unless @window.nil?
      @glfw.terminate
    end

    def render
      @logger.debug('Starting render frame')
      glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT)
      check_gl_errors('Clear buffers')
      # Rendering code will go here
      @logger.debug('Render frame completed')
    end

    def poll_events
      @logger.debug('Polling GLFW events')
      @glfw.poll_events
    end

    def window_should_close?
      should_close = @window&.should_close?
      @logger.debug("Window should close: #{should_close}")
      should_close
    end
  end
end
