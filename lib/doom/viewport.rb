class Viewport
  WIDTH = 800
  HEIGHT = 600

  attr_reader :width, :height

  def initialize
    @width = WIDTH
    @height = HEIGHT
  end

  def center_x
    width / 2
  end

  def center_y
    height / 2
  end
end
