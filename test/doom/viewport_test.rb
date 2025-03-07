require 'minitest/autorun'
require_relative '../../lib/doom/viewport'

class ViewportTest < Minitest::Test
  def setup
    @viewport = Viewport.new
  end

  def test_maintains_base_resolution
    assert_equal 320, @viewport.width
    assert_equal 200, @viewport.height
  end

  def test_aspect_ratio
    assert_in_delta(1.6, @viewport.aspect_ratio)
  end

  def test_integer_scaling
    @viewport.scale = 2

    assert_equal 640, @viewport.scaled_width
    assert_equal 400, @viewport.scaled_height
  end
end
