# frozen_string_literal: true

require 'test_helper'
require 'doom/renderer/components/screen_buffer'
require 'doom/renderer/components/viewport'

module Doom
  class ScreenBufferTest < Minitest::Test
    def setup
      @viewport = Renderer::Components::Viewport.new
      @buffer = Renderer::Components::ScreenBuffer.new(@viewport)
    end

    def test_initialization
      assert_equal 800 * 600 * 4, @buffer.instance_variable_get(:@front_buffer).size
      assert_equal 800 * 600 * 4, @buffer.instance_variable_get(:@back_buffer).size
    end

    def test_clear
      @buffer.draw_pixel(0, 0, 1)
      @buffer.clear

      assert_equal 0, @buffer.instance_variable_get(:@back_buffer)[0]
    end

    def test_draw_pixel
      @buffer.draw_pixel(0, 0, 1)

      assert_equal 1, @buffer.instance_variable_get(:@back_buffer)[0]
    end

    def test_draw_pixel_out_of_bounds
      @buffer.draw_pixel(-1, 0, 1)
      @buffer.draw_pixel(0, -1, 1)
      @buffer.draw_pixel(800, 0, 1)
      @buffer.draw_pixel(0, 600, 1)

      assert_equal 0, @buffer.instance_variable_get(:@back_buffer)[0]
    end

    def test_draw_vertical_line
      @buffer.draw_vertical_line(0, 0, 10, 1)

      0.upto(10) do |y|
        assert_equal 1, @buffer.instance_variable_get(:@back_buffer)[y * 800]
      end
    end

    def test_draw_vertical_line_clipping
      @buffer.draw_vertical_line(0, -1, 600, 1)

      assert_equal 1, @buffer.instance_variable_get(:@back_buffer)[0]
      assert_equal 1, @buffer.instance_variable_get(:@back_buffer)[599 * 800]
    end

    def test_flip
      @buffer.draw_pixel(0, 0, 1)
      @buffer.flip

      assert_equal 1, @buffer.instance_variable_get(:@front_buffer)[0]
      assert_equal 0, @buffer.instance_variable_get(:@back_buffer)[0]
    end
  end
end
