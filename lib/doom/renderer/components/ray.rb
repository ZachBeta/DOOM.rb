# frozen_string_literal: true

module Doom
  module Renderer
    module Components
      class Ray
        attr_reader :angle, :direction_x, :direction_y

        def initialize(angle)
          @angle = angle
          @direction_x = Math.cos(angle)
          @direction_y = Math.sin(angle)
        end
      end
    end
  end
end
