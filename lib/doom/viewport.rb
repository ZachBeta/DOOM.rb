class Viewport
  BASE_WIDTH = 320
  BASE_HEIGHT = 200
  BASE_HEIGHT_4_3 = 240

  attr_accessor :scale, :aspect_ratio_correct, :integer_scaling
  attr_reader :width, :height

  def initialize
    @width = BASE_WIDTH
    @height = BASE_HEIGHT
    @scale = 1
    @aspect_ratio_correct = false
    @integer_scaling = false
  end

  def aspect_ratio
    width.to_f / height
  end

  def scaled_width
    width * scale
  end

  def scaled_height
    if aspect_ratio_correct
      BASE_HEIGHT_4_3 * scale
    else
      height * scale
    end
  end

  def center_x
    scaled_width / 2
  end

  def center_y
    scaled_height / 2
  end

  def resize(new_width, new_height)
    width_scale = new_width.to_f / width
    height_scale = new_height.to_f / height
    @scale = if integer_scaling
               [width_scale.floor, height_scale.floor].min
             else
               [width_scale, height_scale].min
             end
  end
end
