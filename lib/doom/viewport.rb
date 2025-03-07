class Viewport
  BASE_WIDTH = 320
  BASE_HEIGHT = 200

  attr_accessor :scale
  attr_reader :width, :height

  def initialize
    @width = BASE_WIDTH
    @height = BASE_HEIGHT
    @scale = 1
  end

  def aspect_ratio
    width.to_f / height
  end

  def scaled_width
    width * scale
  end

  def scaled_height
    height * scale
  end
end
