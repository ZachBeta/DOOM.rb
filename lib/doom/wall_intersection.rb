# frozen_string_literal: true

module Doom
  class WallIntersection
    attr_reader :distance, :side, :ray_dir_x, :ray_dir_y, :wall_x

    def initialize(distance:, side:, ray_dir_x:, ray_dir_y:, wall_x: nil)
      @distance = distance
      @side = side
      @ray_dir_x = ray_dir_x
      @ray_dir_y = ray_dir_y
      @wall_x = wall_x
    end
  end
end
