require "test_helper"
require "doom/map"

module Doom
  class MapTest < Minitest::Test
    def setup
      @map = Map.new
    end

    def test_map_dimensions
      assert_equal 10, @map.width
      assert_equal 10, @map.height
    end

    def test_wall_detection
      # Corners should be walls
      assert @map.wall_at?(0, 0)
      assert @map.wall_at?(9, 0)
      assert @map.wall_at?(0, 9)
      assert @map.wall_at?(9, 9)

      # Center should be empty
      refute @map.wall_at?(5, 5)
    end
  end

  class GridTest < Minitest::Test
    def setup
      @data = [
        [1, 1, 1],
        [1, 0, 1],
        [1, 1, 1]
      ]
      @grid = Grid.new(@data)
    end

    def test_wall_detection
      assert @grid.wall_at?(0, 0)
      refute @grid.wall_at?(1, 1)
    end

    def test_out_of_bounds
      assert @grid.wall_at?(-1, 0)
      assert @grid.wall_at?(0, -1)
      assert @grid.wall_at?(3, 0)
      assert @grid.wall_at?(0, 3)
    end
  end
end 