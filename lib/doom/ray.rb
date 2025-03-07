# frozen_string_literal: true

require 'matrix'

module Doom
  class Ray
    attr_reader :camera_x, :direction_x, :direction_y

    def initialize(player, screen_x, screen_width)
      @camera_x = (2 * screen_x.to_f / screen_width) - 1
      direction = player&.direction || Vector[1.0, 0.0]
      plane = player&.plane || Vector[0.0, 0.66]
      @direction_x = direction[0] + (plane[0] * @camera_x)
      @direction_y = direction[1] + (plane[1] * @camera_x)
    end
  end
end
