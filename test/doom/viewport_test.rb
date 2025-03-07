# frozen_string_literal: true

require 'test_helper'
require 'doom/renderer/components/viewport'

module Doom
  class ViewportTest < Minitest::Test
    def setup
      @viewport = Renderer::Components::Viewport.new
    end

    def test_maintains_fixed_resolution
      assert_equal 800, @viewport.width
      assert_equal 600, @viewport.height
    end

    def test_center_calculation
      assert_equal 400, @viewport.centerx
      assert_equal 300, @viewport.centery
    end
  end
end
