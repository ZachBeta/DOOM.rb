require 'test_helper'
require 'doom/ray_caster'
require 'doom/map'
require 'doom/player'

module Doom
  class RayCasterTest < Minitest::Test
    def setup
      @map = Map.new
      @player = Player.new
      @ray_caster = RayCaster.new(@map, @player)
    end

    def test_casts_rays_at_correct_angles_based_on_fov
      assert_equal 90, @ray_caster.fov
      assert_equal 320, @ray_caster.num_rays # One ray per column
    end

    def test_detects_wall_intersections
      # Create a simple test map with a wall
      @map.set_wall(5, 5)

      # Cast a ray that should hit the wall
      intersection = @ray_caster.cast_ray(0)

      assert_instance_of WallIntersection, intersection
      assert_predicate intersection.distance, :finite?
      assert_in_delta 7.0, intersection.distance, 0.1
    end

    def test_calculates_wall_distances
      @map.set_wall(5, 5)
      intersection = @ray_caster.cast_ray(0)

      distance = @ray_caster.calculate_distance(intersection.distance)

      assert_in_delta 7.0, distance, 0.1
    end

    def test_handles_different_wall_heights
      @map.set_wall(5, 5)
      intersection = @ray_caster.cast_ray(0)

      height = @ray_caster.calculate_wall_height(intersection.distance)

      assert_operator height, :>, 0
      assert_operator height, :<=, 200 # Should not exceed screen height
    end

    def test_calculates_texture_coordinates
      @map.set_wall(5, 5)
      intersection = @ray_caster.cast_ray(0)

      texture_x = @ray_caster.calculate_texture_x(intersection.wall_x)

      assert_operator texture_x, :>=, 0
      assert_operator texture_x, :<, 64 # Texture coordinates should be 0-63
    end

    def test_handles_perspective_correction
      @map.set_wall(5, 5)
      intersection = @ray_caster.cast_ray(0)

      corrected_distance = @ray_caster.apply_perspective_correction(
        intersection.distance,
        0
      )

      assert_operator corrected_distance, :<=, intersection.distance
    end
  end
end
