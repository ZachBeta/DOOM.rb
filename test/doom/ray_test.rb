# frozen_string_literal: true

require_relative '../test_helper'
require_relative '../../lib/doom/ray'
require_relative '../../lib/doom/player'

module Doom
  class RayTest < Minitest::Test
    def setup
      @player = Player.new
      @screen_width = 800
      @screen_x = 400
      @ray = Ray.new(@player, @screen_x, @screen_width)
    end

    def test_initialization
      assert_in_delta(0.0, @ray.camera_x)
      assert_in_delta 1.0, @ray.direction_x, 0.001
      assert_in_delta 0.0, @ray.direction_y, 0.001
    end

    def test_direction_at_screen_edge
      @screen_x = 0
      @ray = Ray.new(@player, @screen_x, @screen_width)

      assert_in_delta 0.66, @ray.direction_x, 0.001
      assert_in_delta 0.66, @ray.direction_y, 0.001
    end

    def test_direction_at_opposite_screen_edge
      @screen_x = @screen_width
      @ray = Ray.new(@player, @screen_x, @screen_width)

      assert_in_delta 0.66, @ray.direction_x, 0.001
      assert_in_delta(-0.66, @ray.direction_y, 0.001)
    end

    def test_direction_with_zero_plane
      @player.plane = Vector[0.0, 0.0]
      @ray = Ray.new(@player, @screen_x, @screen_width)

      assert_in_delta 1.0, @ray.direction_x, 0.001
      assert_in_delta 0.0, @ray.direction_y, 0.001
    end
  end
end
