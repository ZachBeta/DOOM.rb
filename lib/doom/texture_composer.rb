module Doom
  class Patch
    attr_reader :name, :width, :height, :data

    def initialize(name:, width:, height:, data:)
      @name = name
      @width = width
      @height = height
      @data = data
    end
  end

  class ComposedTexture
    attr_reader :width, :height, :data

    def initialize(width:, height:, data:)
      @width = width
      @height = height
      @data = data
    end
  end

  class TextureComposer
    def compose(texture, patches, pnames = nil)
      data = Array.new(texture.width * texture.height, 0)

      texture.patches.each do |patch|
        patch_name = pnames ? pnames[patch.patch_index] : patch.name
        source_patch = patches[patch_name]
        compose_patch(data, source_patch, patch.x_offset, patch.y_offset, texture.width)
      end

      ComposedTexture.new(
        width: texture.width,
        height: texture.height,
        data: data
      )
    end

    private

    def compose_patch(target_data, patch, x_offset, y_offset, target_width)
      patch.height.times do |y|
        patch.width.times do |x|
          target_x = x + x_offset
          target_y = y + y_offset
          next if target_x < 0 || target_x >= target_width

          source_index = (y * patch.width) + x
          target_index = (target_y * target_width) + target_x
          target_data[target_index] = patch.data[source_index]
        end
      end
    end
  end
end
