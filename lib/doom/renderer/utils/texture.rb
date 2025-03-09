# frozen_string_literal: true

require_relative '../../logger'

module Doom
  module Renderer
    module Utils
      class Texture
        attr_reader :name, :width, :height, :patches

        def initialize(name:, width:, height:, patches:)
          @name = name
          @width = width
          @height = height
          @patches = patches
        end
      end

      class TexturePatch
        attr_reader :x_offset, :y_offset, :name, :patch_index

        def initialize(x_offset:, y_offset:, name:, patch_index:)
          @x_offset = x_offset
          @y_offset = y_offset
          @name = name
          @patch_index = patch_index
        end
      end

      class TextureParser
        def self.parse(data, pnames = nil)
          logger = Doom::Logger.instance
          logger.debug("Parsing texture data (#{data.bytesize} bytes)")
          return [] if data.nil? || data.empty?

          # First 4 bytes are the number of textures
          num_textures = data[0, 4].unpack1('V')
          logger.debug("Number of textures: #{num_textures}")

          # Next 4 bytes are offsets to each texture definition
          offsets = data[4, num_textures * 4].unpack('V*')
          logger.debug("Found #{offsets.size} texture offsets")

          textures = []

          offsets.each_with_index do |offset, i|
            logger.debug("Processing texture #{i + 1}/#{num_textures} at offset #{offset}")
            texture_data = data[offset..]
            break if texture_data.nil? || texture_data.size < 22

            name = texture_data[0, 8].delete("\x00").strip
            width = texture_data[12, 2].unpack1('v')
            height = texture_data[14, 2].unpack1('v')
            num_patches = texture_data[20, 2].unpack1('v')

            logger.debug("Texture #{i + 1}/#{num_textures}: #{name} (#{width}x#{height}, #{num_patches} patches)")

            patches = []
            patch_offset = 22

            num_patches.times do |j|
              patch_data = texture_data[patch_offset, 10]
              break if patch_data.nil? || patch_data.size < 10

              x_offset = patch_data[0, 2].unpack1('v')
              y_offset = patch_data[2, 2].unpack1('v')
              patch_index = patch_data[4, 2].unpack1('v')

              patch_name = pnames ? pnames[patch_index] : nil
              logger.debug("  Patch #{j + 1}/#{num_patches}: index=#{patch_index}, name=#{patch_name}, offset=(#{x_offset},#{y_offset})")

              patches << TexturePatch.new(
                x_offset: x_offset,
                y_offset: y_offset,
                name: patch_name,
                patch_index: patch_index
              )

              patch_offset += 10
            end

            textures << Texture.new(
              name: name,
              width: width,
              height: height,
              patches: patches
            )
          end

          logger.debug("Parsed #{textures.size} textures")
          textures
        end
      end
    end
  end
end
