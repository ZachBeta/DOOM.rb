require 'test_helper'
require 'doom/viewport'

module Doom
  class ViewportTest < Minitest::Test
    def setup
      @viewport = Viewport.new
    end

    def test_maintains_320x200_resolution
      assert_equal 320, @viewport.width
      assert_equal 200, @viewport.height
    end

    def test_handles_aspect_ratio_correction
      # 320x200 has a 16:10 aspect ratio
      assert_in_delta(1.6, @viewport.aspect_ratio)
    end

    def test_supports_integer_scaling
      @viewport.scale = 2

      assert_equal 640, @viewport.scaled_width
      assert_equal 400, @viewport.scaled_height
    end

    def test_calculates_centerx_and_centery
      assert_equal 160, @viewport.centerx
      assert_equal 100, @viewport.centery
    end

    def test_handles_view_size_changes
      @viewport.scale = 3

      assert_equal 960, @viewport.scaled_width
      assert_equal 600, @viewport.scaled_height
      assert_equal 480, @viewport.centerx
      assert_equal 300, @viewport.centery
    end
  end
end
