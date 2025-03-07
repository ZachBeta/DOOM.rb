# frozen_string_literal: true

require_relative '../test_helper'
require_relative '../../lib/doom/ray_caster'
require_relative '../../lib/doom/ray'
require_relative '../../lib/doom/player'
require_relative '../../lib/doom/map'
require_relative '../../lib/doom/wad_file'
require_relative '../../lib/doom/config'

module Doom
  class RayCasterTest < Minitest::Test
    def setup
      @wad_path = Doom::Config.wad_path
      @wad_file = WadFile.new(@wad_path)
      @map = Map.new(@wad_file.level_data('E1M1'))
      @player = Player.new(@map)
      @player.position = Vector[32, 32] # Center of E1M1
      @screen_width = 800
      @screen_x = 400
      @ray = Ray.new(@player, @screen_x, @screen_width)
      @ray_caster = RayCaster.new(@map, @player, @ray)
    end

    def test_ray_hits_north_wall
      @player.direction = Vector[0, -1]
      @player.plane = Vector[0.66, 0]
      @ray = Ray.new(@player, @screen_x, @screen_width)
      @ray_caster = RayCaster.new(@map, @player, @ray)
      result = @ray_caster.cast

      assert_operator result.distance, :>, 0
      assert_equal 1, result.side
      assert_in_delta 0.5, result.wall_x, 0.01
    end

    def test_ray_hits_south_wall
      @player.direction = Vector[0, 1]
      @player.plane = Vector[0.66, 0]
      @ray = Ray.new(@player, @screen_x, @screen_width)
      @ray_caster = RayCaster.new(@map, @player, @ray)
      result = @ray_caster.cast

      assert_operator result.distance, :>, 0
      assert_equal 1, result.side
      assert_in_delta 0.5, result.wall_x, 0.01
    end

    def test_ray_hits_east_wall
      @player.direction = Vector[1, 0]
      @player.plane = Vector[0, 0.66]
      @ray = Ray.new(@player, @screen_x, @screen_width)
      @ray_caster = RayCaster.new(@map, @player, @ray)
      result = @ray_caster.cast

      assert_operator result.distance, :>, 0
      assert_equal 0, result.side
      assert_in_delta 0.5, result.wall_x, 0.01
    end

    def test_ray_hits_west_wall
      @player.direction = Vector[-1, 0]
      @player.plane = Vector[0, 0.66]
      @ray = Ray.new(@player, @screen_x, @screen_width)
      @ray_caster = RayCaster.new(@map, @player, @ray)
      result = @ray_caster.cast

      assert_operator result.distance, :>, 0
      assert_equal 0, result.side
      assert_in_delta 0.5, result.wall_x, 0.01
    end

    def test_ray_hits_corner
      @player.direction = Vector[1, 1].normalize
      @player.plane = Vector[-0.66, 0.66]
      @ray = Ray.new(@player, @screen_x, @screen_width)
      @ray_caster = RayCaster.new(@map, @player, @ray)
      result = @ray_caster.cast

      assert_operator result.distance, :>, 0
      assert_equal 0, result.side
      assert_in_delta 0.5, result.wall_x, 0.01
    end

    def test_ray_with_different_player_position
      @player.position = Vector[2.5, 2.5]
      @player.direction = Vector[1, 0]
      @player.plane = Vector[0, 0.66]
      @ray = Ray.new(@player, @screen_x, @screen_width)
      @ray_caster = RayCaster.new(@map, @player, @ray)
      result = @ray_caster.cast

      assert_operator result.distance, :>, 0
      assert_equal 0, result.side
      assert_in_delta 0.5, result.wall_x, 0.01
    end

    def test_ray_with_zero_direction
      @player.direction = Vector[0, 0]
      @player.plane = Vector[0, 0]
      @ray = Ray.new(@player, @screen_x, @screen_width)
      @ray_caster = RayCaster.new(@map, @player, @ray)
      result = @ray_caster.cast

      assert_equal Float::INFINITY, result.distance
      assert_equal 0, result.side
      assert_in_delta 0.5, result.wall_x, 0.01
    end
  end
end
