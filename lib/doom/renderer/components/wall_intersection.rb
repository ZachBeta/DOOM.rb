# frozen_string_literal: true

module Doom
  module Renderer
    module Components
      class WallIntersection
        attr_reader :distance, :wall_x, :side, :ray_dir_x, :ray_dir_y

        def initialize(distance:, wall_x:, side:, ray_dir_x:, ray_dir_y:)
          @distance = distance
          @wall_x = wall_x
          @side = side
          @ray_dir_x = ray_dir_x
          @ray_dir_y = ray_dir_y
        end
      end
    end
  end
end
