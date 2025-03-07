module Doom
  class Viewport
    attr_accessor :scale
    attr_reader :width, :height, :scale

    def initialize
      @width = 320
      @height = 200
      @scale = 1
    end

    def scale=(value)
      @scale = value.to_f
    end

    def aspect_ratio
      @width.to_f / @height
    end

    def scaled_width
      (@width * @scale).to_i
    end

    def scaled_height
      (@height * @scale).to_i
    end

    def centerx
      scaled_width / 2
    end

    def centery
      scaled_height / 2
    end

    def scaled_aspect_ratio
      scaled_width.to_f / scaled_height
    end
  end
end
