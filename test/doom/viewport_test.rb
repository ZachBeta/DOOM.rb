require 'minitest/autorun'
require_relative '../../lib/doom/viewport'

class ViewportTest < Minitest::Test
  def setup
    @viewport = Viewport.new
  end

  def test_maintains_fixed_resolution
    assert_equal 800, @viewport.width
    assert_equal 600, @viewport.height
  end

  def test_center_calculation
    assert_equal 400, @viewport.center_x
    assert_equal 300, @viewport.center_y
  end
end
