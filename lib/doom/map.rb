module Doom
  class Map
    attr_reader :width, :height, :data

    def initialize
      @width = 10
      @height = 10
      
      # Simple map layout: 1 represents a wall, 0 represents empty space
      @data = [
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

    def wall_at?(x, y)
      # Check if coordinates are within bounds
      return true if x < 0 || y < 0 || x >= @width || y >= @height
      
      # Check if there's a wall at the given coordinates
      @data[y.to_i][x.to_i] == 1
    end
  end
end 