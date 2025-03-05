# frozen_string_literal: true

require 'test_helper'
require 'doom/renderer'
require 'stringio'
require 'doom/logger'
require 'fileutils'

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
    def wall_at?(x, y)
      (x == 6 && y == 5) || # Wall one unit to the right of default player position
        x.negative? || y.negative? || x >= 10 || y >= 10 # Boundary walls
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

  class MinimapRendererTest < Minitest::Test
    def setup
      setup_test_logs
      @window = MockWindow.new
      @map = MockMap.new
      @player = MockPlayer.new([5, 5], [1, 0]) # Facing east
      @minimap = MinimapRenderer.new(@window, @map)
    end

    def teardown
      super
      FileUtils.rm_rf('test/logs')
    end

    def test_minimap_cell_size
      cell_size = MinimapRenderer::MINIMAP_SIZE / [@map.width, @map.height].max

      assert_equal 15, cell_size # 150/10 = 15
    end

    def test_player_rotation_angle
      # Test east-facing (0 degrees)
      player = MockPlayer.new([5, 5], [1, 0])
      angle = Math.atan2(player.direction[1], player.direction[0]) * 180 / Math::PI

      assert_equal 0, angle.round

      # Test north-facing (270 degrees)
      player = MockPlayer.new([5, 5], [0, -1])
      angle = Math.atan2(player.direction[1], player.direction[0]) * 180 / Math::PI

      assert_equal(-90, angle.round)
    end

    def test_minimap_logging
      # Skip actual rendering but still log
      def @minimap.draw_background; end
      def @minimap.draw_walls; end
      def @minimap.draw_player(*); end
      def @minimap.draw_rotation_angle(*); end

      @minimap.render(@player)

      log_content = File.read('test/logs/verbose.log')

      assert_includes log_content, 'Minimap rendered at'
      assert_includes log_content, 'Player position on minimap'
      assert_includes log_content, 'Player rotation: 0°'
    end

    private

    def setup_test_logs
      FileUtils.rm_rf('test/logs')
      FileUtils.mkdir_p('test/logs')
      # Configure logger for test environment with verbose level for this specific test
      Logger.configure(level: :verbose, base_dir: 'test/logs', env: :test)
    end
  end
end
