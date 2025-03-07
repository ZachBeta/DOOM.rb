# frozen_string_literal: true

require 'glfw3'
require 'opengl'
require 'matrix'
require_relative 'logger'

module Doom
  class Window
    include OpenGL

    SCREEN_WIDTH = 800
    SCREEN_HEIGHT = 600
    TITLE = 'DOOM.rb'

    def initialize
      @logger = Logger.instance
      @logger.info('Initializing OpenGL window')

      # Initialize GLFW
      Glfw.init

      # Set OpenGL version and profile
      Glfw::Window.default_window_hints do
        context_version_major 2
        context_version_minor 1
        opengl_profile :core
      end

      # Create window
      @window = Glfw::Window.new(SCREEN_WIDTH, SCREEN_HEIGHT, TITLE)
      raise 'Failed to create GLFW window' unless @window

      @window.make_context_current

      # Initialize OpenGL
      OpenGL.load_lib

      # Set up OpenGL state
      setup_gl_state

      @logger.info('OpenGL window initialized successfully')
    end

    def close
      return unless @window

      # Clean up OpenGL state
      cleanup_gl_state

      @window.destroy
      @window = nil
      Glfw.terminate
      @logger.info('Window closed')
    end

    def should_close?
      @window.should_close?
    end

    def update
      Glfw.poll_events
    end

    def swap_buffers
      @window.swap_buffers
    end

    def clear
      glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT)
    end

    def width
      SCREEN_WIDTH
    end

    def height
      SCREEN_HEIGHT
    end

    def button_down?(key)
      @window.get_key(key) == Glfw::PRESS
    end

    private

    def setup_gl_state
      glEnable(GL_DEPTH_TEST)
      glEnable(GL_TEXTURE_2D)
      glEnable(GL_BLEND)
      glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA)
      glClearColor(0.0, 0.0, 0.0, 1.0)
      glViewport(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)
    end

    def cleanup_gl_state
      glDisable(GL_DEPTH_TEST)
      glDisable(GL_TEXTURE_2D)
      glDisable(GL_BLEND)
    end

    def glEnable(cap)
      OpenGL.get_command(:glEnable).call(cap)
    end

    def glDisable(cap)
      OpenGL.get_command(:glDisable).call(cap)
    end

    def glBlendFunc(sfactor, dfactor)
      OpenGL.get_command(:glBlendFunc).call(sfactor, dfactor)
    end

    def glClearColor(red, green, blue, alpha)
      OpenGL.get_command(:glClearColor).call(red, green, blue, alpha)
    end

    def glClear(mask)
      OpenGL.get_command(:glClear).call(mask)
    end

    def glViewport(x, y, width, height)
      OpenGL.get_command(:glViewport).call(x, y, width, height)
    end
  end
end
