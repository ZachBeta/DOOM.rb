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

  def test_aspect_ratio_correction
    @viewport.scale = 2
    @viewport.aspect_ratio_correct = true

    assert_equal 640, @viewport.scaled_width
    assert_equal 480, @viewport.scaled_height
  end

  def test_center_calculation
    @viewport.scale = 2

    assert_equal 320, @viewport.center_x
    assert_equal 200, @viewport.center_y
  end

  def test_resize_with_integer_scaling
    @viewport.integer_scaling = true
    @viewport.resize(800, 600)

    assert_equal 2, @viewport.scale
    assert_equal 640, @viewport.scaled_width
    assert_equal 400, @viewport.scaled_height
  end

  def test_resize_without_integer_scaling
    @viewport.integer_scaling = false
    @viewport.resize(800, 600)

    assert_in_delta(2.5, @viewport.scale)
    assert_equal 800, @viewport.scaled_width
    assert_equal 500, @viewport.scaled_height
  end
end
