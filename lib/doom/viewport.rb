module Doom
  class Viewport
    attr_accessor :scale
    attr_reader :width, :height

    def initialize
      @width = 320
      @height = 200
      @scale = 1
    end

    def aspect_ratio
      @width.to_f / @height
    end

    def scaled_width
      @width * @scale
    end

    def scaled_height
      @height * @scale
    end

    def centerx
      scaled_width / 2
    end

    def centery
      scaled_height / 2
    end
  end
end
