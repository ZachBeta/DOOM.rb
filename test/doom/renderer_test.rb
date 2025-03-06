# frozen_string_literal: true

require 'test_helper'
require 'doom/renderer'
require 'stringio'
require 'doom/logger'
require 'fileutils'
require 'benchmark'

module Doom
  class MockFont
    def initialize(*); end
    def draw_text(*); end
  end

  class MockWindow
    attr_reader :width, :height

    def initialize(width = 800, height = 600)
      @width = width
      @height = height
    end

    def draw_quad(*); end
    def draw_line(*); end
  end

  class MockPlayer
    def initialize(position = [5, 5], direction = [1, 0], plane = [0, 0.66])
      @position = position
      @direction = direction
      @plane = plane
    end

    attr_reader :position, :direction, :plane
  end

  class MockMap
    def empty?(x, y)
      !((x == 6 && y == 5) || # Wall one unit to the right of default player position
        x.negative? || y.negative? || x >= 10 || y >= 10) # Boundary walls
    end

    def width
      10
    end

    def height
      10
    end
  end

  class RayTest < Minitest::Test
    def setup
      @player = MockPlayer.new
    end

    def test_ray_initialization
      ray = Ray.new(@player, 400, 800)

      assert_in_delta 1.0, ray.direction_x
      assert_in_delta 0.0, ray.direction_y
    end

    def test_ray_direction_at_screen_edges
      left_ray = Ray.new(@player, 0, 800)
      right_ray = Ray.new(@player, 800, 800)

      assert_operator left_ray.direction_x, :<, 1.0
      assert_operator right_ray.direction_x, :>, 1.0
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

      assert_in_delta(10.5, intersection.distance)
      assert_equal 0, intersection.side
      assert_in_delta(1.0, intersection.ray_dir_x)
      assert_in_delta(0.0, intersection.ray_dir_y)
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
      assert_operator intersection.distance, :>, 1.0 # Diagonal distance should be greater
    end
  end

  class RendererTest < Minitest::Test
    def setup
      @window = MockWindow.new
      @map = MockMap.new
      @texture = Doom::ComposedTexture.new(
        width: 64,
        height: 128,
        data: Array.new(64 * 128) { |i| i % 256 } # Create a test pattern
      )
      @renderer = Renderer.new(@window, @map, { 'TEST_TEXTURE' => @texture })
      @player = MockPlayer.new([5, 5], [1, 0])
      Logger.configure(level: :verbose, base_dir: 'logs', env: :test)
    end

    def test_texture_mapping
      player = MockPlayer.new([5, 5], [1, 0]) # Facing east
      intersection = WallIntersection.new(
        distance: 1.0,
        side: 0,
        ray_dir_x: 1.0,
        ray_dir_y: 0.0,
        wall_x: 0.5 # Hit position on wall (0.0 to 1.0)
      )

      # Test that texture coordinates are calculated correctly
      tex_x = @renderer.send(:calculate_texture_x, intersection)

      assert_equal 32, tex_x # Should be middle of texture (0.5 * 64)
    end

    def test_wall_rendering_performance
      player = MockPlayer.new([5, 5], [1, 0]) # Facing east

      # Measure performance over multiple frames
      time = Benchmark.realtime do
        5.times do # Render scene 5 times
          @renderer.render(player)
        end
      end

      # Average time per frame should be under 16ms (60 FPS)
      avg_frame_time = time / 5.0

      assert_operator avg_frame_time, :<=, 0.016,
                      "Wall rendering too slow: #{(avg_frame_time * 1000).round(2)}ms per frame"
    end

    def test_minimap_rendering
      # Test that minimap rendering doesn't raise errors
      assert_nothing_raised { @renderer.render(@player) }
    end
  end
end
