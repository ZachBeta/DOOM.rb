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
    attr_reader :width, :height, :data, :mipmaps

    def initialize(width:, height:, data:)
      @width = width
      @height = height
      @data = data
      @mipmaps = generate_mipmaps(data, width, height)
    end

    private

    def generate_mipmaps(data, width, height)
      mipmaps = []
      current_width = width
      current_height = height
      current_data = data.dup

      while current_width > 1 && current_height > 1
        next_width = [current_width / 2, 1].max
        next_height = [current_height / 2, 1].max
        next_data = Array.new(next_width * next_height, 0)

        (0...next_height).each do |y|
          (0...next_width).each do |x|
            # Calculate source indices with bounds checking
            x2 = x * 2
            y2 = y * 2
            i1 = (y2 * current_width) + x2
            i2 = i1 + (x2 + 1 < current_width ? 1 : 0)
            i3 = ((y2 + 1 < current_height ? y2 + 1 : y2) * current_width) + x2
            i4 = i3 + (x2 + 1 < current_width ? 1 : 0)

            # Calculate average color index with bounds checking
            sum = current_data[i1].to_i
            count = 1

            if x2 + 1 < current_width
              sum += current_data[i2].to_i
              count += 1
            end

            if y2 + 1 < current_height
              sum += current_data[i3].to_i
              count += 1
            end

            if x2 + 1 < current_width && y2 + 1 < current_height
              sum += current_data[i4].to_i
              count += 1
            end

            next_data[(y * next_width) + x] = (sum / count).to_i
          end
        end

        mipmaps << {
          width: next_width,
          height: next_height,
          data: next_data
        }

        break if next_width == 1 || next_height == 1

        current_width = next_width
        current_height = next_height
        current_data = next_data
      end

      mipmaps
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
      return unless patch

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
