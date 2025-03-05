# frozen_string_literal: true

require 'test_helper'
require 'doom/renderer'

module Doom
  class MockPlayer
    def initialize(position = [5, 5], direction = [1, 0], plane = [0, 0.66])
      @position = position
      @direction = direction
      @plane = plane
    end

    attr_reader :position, :direction, :plane
  end

  class MockMap
    def wall_at?(x, y)
      (x == 6 && y == 5) || # Wall one unit to the right of default player position
        x.negative? || y.negative? || x >= 10 || y >= 10 # Boundary walls
    end
  end

  class RayTest < Minitest::Test
    def setup
      @player = MockPlayer.new
    end

    def test_ray_initialization
      ray = Ray.new(@player, 400, 800)

      assert_in_delta 0.0, ray.camera_x
      assert_in_delta 1.0, ray.direction_x
      assert_in_delta 0.0, ray.direction_y
    end

    def test_ray_direction_at_screen_edges
      left_ray = Ray.new(@player, 0, 800)
      right_ray = Ray.new(@player, 800, 800)

      assert_in_delta(-1.0, left_ray.camera_x)
      assert_in_delta 1.0, right_ray.camera_x
    end
  end

  class WallIntersectionTest < Minitest::Test
    def test_wall_intersection_attributes
      intersection = WallIntersection.new(
        distance: 10.5,
        side: 0,
        ray_dir_x: 1.0,
        ray_dir_y: 0.0
      )

      assert_equal 10.5, intersection.distance
      assert_equal 0, intersection.side
      assert_equal 1.0, intersection.ray_dir_x
      assert_equal 0.0, intersection.ray_dir_y
    end
  end

  class RayCasterTest < Minitest::Test
    def setup
      @map = MockMap.new
      @player = MockPlayer.new
      @ray = Ray.new(@player, 400, 800) # Center ray
    end

    def test_ray_cast_hits_wall
      caster = RayCaster.new(@map, @player, @ray)
      intersection = caster.cast

      assert_instance_of WallIntersection, intersection
      assert_in_delta 1.0, intersection.distance # Wall is 1 unit away
      assert_equal 0, intersection.side # Hit on x-axis
    end

    def test_ray_cast_with_angled_ray
      angled_ray = Ray.new(
        MockPlayer.new([5, 5], [0.7071, 0.7071]), # 45-degree angle
        400,
        800
      )
      caster = RayCaster.new(@map, @player, angled_ray)
      intersection = caster.cast

      assert_instance_of WallIntersection, intersection
      assert intersection.distance > 1.0 # Diagonal distance should be greater
    end
  end
end
