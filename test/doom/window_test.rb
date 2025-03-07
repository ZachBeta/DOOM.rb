# frozen_string_literal: true

require 'minitest/autorun'
require 'doom/window'
require 'glfw3'
require 'opengl'

module Doom
  class WindowTest < Minitest::Test
    def setup
      super
      @window = Window.new(Window::WIDTH, Window::HEIGHT, Window::TITLE)
    end

    def teardown
      @window.close if @window
      super
    end

    def test_window_creation
      assert_equal 800, @window.width
      assert_equal 600, @window.height
      refute_predicate @window, :should_close?
    end

    def test_window_close
      @window.close

      assert_predicate @window, :should_close?
    end

    def test_window_clear
      @window.clear
      # No assertion needed - just verify it doesn't raise
    end

    def test_window_swap_buffers
      @window.swap_buffers
      # No assertion needed - just verify it doesn't raise
    end

    def test_window_update
      @window.update
      # No assertion needed - just verify it doesn't raise
    end

    def test_window_button_down
      refute @window.button_down?(Glfw3::KEY_ESCAPE)
    end
  end
end
