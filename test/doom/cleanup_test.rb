# frozen_string_literal: true

require 'test_helper'
require 'doom/window'
require 'doom/screen_buffer'
require 'doom/opengl_renderer'
require 'doom/game'
require 'doom/viewport'
require 'doom/map'

module Doom
  class CleanupTest < Minitest::Test
    def setup
      super
      @window = Window.new
      @viewport = Viewport.new
      @screen_buffer = ScreenBuffer.new(@viewport)
      @map = Map.new
      @renderer = OpenGLRenderer.new(@window, @map, nil)
      @game = Game.new
    end

    def teardown
      @screen_buffer.cleanup if @screen_buffer
      @renderer.cleanup if @renderer
      @window.close if @window
      super
    end

    def test_screen_buffer_cleanup
      assert @screen_buffer.instance_variable_get(:@texture_id),
             'Texture ID should exist before cleanup'
      @screen_buffer.cleanup

      refute @screen_buffer.instance_variable_get(:@texture_id),
             'Texture ID should be nil after cleanup'
    end

    def test_renderer_cleanup
      assert @renderer.instance_variable_get(:@screen_buffer),
             'Screen buffer should exist before cleanup'
      @renderer.cleanup
      # Verify screen buffer was cleaned up
      assert_nil @renderer.instance_variable_get(:@screen_buffer).instance_variable_get(:@texture_id)
    end

    def test_window_cleanup
      assert @window.instance_variable_get(:@window), 'GLFW window should exist before cleanup'
      @window.close

      refute @window.instance_variable_get(:@window), 'GLFW window should be nil after cleanup'
    end

    def test_game_cleanup_sequence
      # Verify initial state
      assert @game.instance_variable_get(:@renderer), 'Renderer should exist before cleanup'
      assert @game.instance_variable_get(:@window), 'Window should exist before cleanup'

      # Run cleanup
      @game.send(:cleanup)

      # Verify final state
      assert_nil @game.instance_variable_get(:@renderer).instance_variable_get(:@screen_buffer).instance_variable_get(:@texture_id)
      assert_nil @game.instance_variable_get(:@window).instance_variable_get(:@window)
    end

    def test_cleanup_order
      cleanup_sequence = []
      allow_logging(cleanup_sequence)

      @game.send(:cleanup)

      expected_sequence = [
        'Starting game cleanup sequence',
        'Step 1: Cleaning up renderer',
        'Starting OpenGL renderer cleanup',
        'Cleaning up screen buffer',
        'Starting screen buffer cleanup',
        'Deleting OpenGL texture',
        'Screen buffer cleanup completed successfully',
        'OpenGL renderer cleanup completed successfully',
        'Step 2: Closing window',
        'Starting window cleanup sequence',
        'Step 1: Cleaning up OpenGL state',
        'Starting OpenGL state cleanup',
        'Making context current for cleanup',
        'Disabling OpenGL features',
        'Blending disabled',
        'Texture 2D disabled',
        'Depth testing disabled',
        'OpenGL state cleanup completed successfully',
        'Step 2: Destroying GLFW window',
        'Step 3: Terminating GLFW',
        'Window cleanup sequence completed successfully',
        'Game cleanup sequence completed successfully'
      ]

      assert_equal expected_sequence, cleanup_sequence
    end

    private

    def allow_logging(sequence)
      Logger.instance.define_singleton_method(:info) do |msg|
        sequence << msg
      end

      Logger.instance.define_singleton_method(:debug) do |msg|
        sequence << msg
      end

      Logger.instance.define_singleton_method(:error) do |msg|
        sequence << msg
      end
    end
  end
end
