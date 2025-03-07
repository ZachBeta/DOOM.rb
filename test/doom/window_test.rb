# frozen_string_literal: true

require 'test_helper'
require 'doom/window'

module Doom
  class WindowTest < Minitest::Test
    def setup
      @window = Window.new
    end

    def teardown
      @window.close
    end

    def test_initialization
      assert_equal 800, @window.width
      assert_equal 600, @window.height
    end

    def test_window_creation
      assert_instance_of Window, @window
      assert_respond_to @window, :width
      assert_respond_to @window, :height
      assert_respond_to @window, :should_close?
      assert_respond_to @window, :swap_buffers
      assert_respond_to @window, :clear
      assert_respond_to @window, :update
    end

    def test_window_cleanup
      @window.close

      assert_nil @window.instance_variable_get(:@glfw).window
    end

    def test_key_handling
      refute @window.button_down?(GlfwWrapper::KEY_ESCAPE)
    end
  end
end
