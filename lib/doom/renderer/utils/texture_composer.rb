# frozen_string_literal: true

module Doom
  module Renderer
    module Utils
      class TextureComposer
        def initialize
          @textures = {}
          @patches = {}
        end

        def compose_texture(texture, patch_data)
          return @textures[texture.name] if @textures.key?(texture.name)

          composed_texture = Array.new(texture.height) { Array.new(texture.width, 0) }

          texture.patches.each do |patch|
            patch_pixels = get_patch_pixels(patch.name, patch_data)
            next unless patch_pixels

            patch_height = patch_pixels.size
            patch_width = patch_pixels.first.size

            patch_height.times do |y|
              dest_y = y + patch.y_offset
              next if dest_y < 0 || dest_y >= texture.height

              patch_width.times do |x|
                dest_x = x + patch.x_offset
                next if dest_x < 0 || dest_x >= texture.width

                pixel = patch_pixels[y][x]
                composed_texture[dest_y][dest_x] = pixel if pixel != 0
              end
            end
          end

          @textures[texture.name] = composed_texture
          composed_texture
        end

        private

        def get_patch_pixels(patch_name, patch_data)
          return @patches[patch_name] if @patches.key?(patch_name)
          return nil unless patch_data && patch_data[patch_name]

          data = patch_data[patch_name]
          width = data[0, 2].unpack1('v')
          height = data[2, 2].unpack1('v')

          pixels = Array.new(height) { Array.new(width, 0) }
          column_offsets = data[8, width * 4].unpack('V*')

          width.times do |x|
            offset = column_offsets[x]
            next unless offset

            while (post_start = data[offset])
              break if post_start == 255

              pixel_count = data[offset + 1]
              pixel_data = data[offset + 3, pixel_count]

              pixel_count.times do |y|
                pixels[post_start + y][x] = pixel_data[y]
              end

              offset += pixel_count + 4
            end
          end

          @patches[patch_name] = pixels
          pixels
        end
      end
    end
  end
end
