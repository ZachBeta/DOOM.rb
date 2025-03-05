# frozen_string_literal: true

module Doom
  class Map
    attr_reader :width, :height

    def initialize
      @width = 10
      @height = 10
      @grid = Grid.new(create_default_layout)
    end

    def wall_at?(x, y)
      @grid.wall_at?(x, y)
    end

    private

    def create_default_layout
      [
        [1, 1, 1, 1, 1, 1, 1, 1, 1, 1],
        [1, 0, 0, 0, 0, 0, 0, 0, 0, 1],
        [1, 0, 0, 0, 0, 0, 0, 0, 0, 1],
        [1, 0, 0, 1, 1, 0, 1, 0, 0, 1],
        [1, 0, 0, 1, 0, 0, 1, 0, 0, 1],
        [1, 0, 0, 0, 0, 0, 1, 0, 0, 1],
        [1, 0, 0, 1, 0, 0, 1, 0, 0, 1],
        [1, 0, 0, 1, 1, 1, 1, 0, 0, 1],
        [1, 0, 0, 0, 0, 0, 0, 0, 0, 1],
        [1, 1, 1, 1, 1, 1, 1, 1, 1, 1]
      ]
    end
  end

  class Grid
    WALL = 1
    EMPTY = 0

    def initialize(data)
      @data = data
      @width = data[0].size
      @height = data.size
    end

    def wall_at?(x, y)
      return true if out_of_bounds?(x, y)

      @data[y.to_i][x.to_i] == WALL
    end

    private

    def out_of_bounds?(x, y)
      x.negative? || y.negative? || x >= @width || y >= @height
    end
  end
end
