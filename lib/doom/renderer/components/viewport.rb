# frozen_string_literal: true

module Doom
  module Renderer
    module Components
      class Viewport
        attr_reader :width, :height, :centerx, :centery

        def initialize(width = 800, height = 600)
          @width = width
          @height = height
          @centerx = width / 2
          @centery = height / 2
        end
      end
    end
  end
end
