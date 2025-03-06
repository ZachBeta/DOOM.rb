module Doom
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
    attr_reader :name, :patch_index, :x_offset, :y_offset

    def initialize(x_offset:, y_offset:, name: nil, patch_index: nil)
      @name = name
      @patch_index = patch_index
      @x_offset = x_offset
      @y_offset = y_offset
    end
  end

  class TextureParser
    TEXTURE_NAME_LENGTH = 8
    HEADER_SIZE = 4
    OFFSET_SIZE = 4
    TEXTURE_DEF_SIZE = 22
    PATCH_DEF_SIZE = 10

    def self.parse(data, pnames = nil)
      new(data, pnames).parse
    end

    def initialize(data, pnames = nil)
      @data = data
      @pnames = pnames
      @offset = 0
      @logger = Logger.instance
    end

    def parse
      @logger.debug("Parsing texture data of size: #{@data&.size || 'nil'}")
      num_textures = read_long
      @logger.debug("Number of textures: #{num_textures}")
      texture_offsets = read_texture_offsets(num_textures)
      @logger.debug("Texture offsets: #{texture_offsets.inspect}")

      texture_offsets.map do |offset|
        # Offset is relative to the start of the TEXTURE1 lump
        @offset = offset
        parse_texture
      end
    end

    private

    def read_texture_offsets(count)
      offsets = []
      count.times do
        offset = read_long
        # Offsets are relative to the start of the texture lump
        offsets << offset
      end
      offsets
    end

    def parse_texture
      name = read_string(TEXTURE_NAME_LENGTH).strip.upcase # WAD files store names in uppercase
      @logger.debug("Parsing texture: #{name}")
      skip_bytes(4) # Skip flags (unused)
      width = read_short
      height = read_short
      @logger.debug("Texture dimensions: #{width}x#{height}")
      skip_bytes(4) # Skip column directory (unused)
      num_patches = read_short
      @logger.debug("Number of patches: #{num_patches}")

      patches = num_patches.times.map do |i|
        patch = parse_patch
        @logger.debug("Patch #{i + 1}: index=#{patch.patch_index}, offset=(#{patch.x_offset},#{patch.y_offset})")
        patch
      end

      Texture.new(
        name: name,
        width: width,
        height: height,
        patches: patches
      )
    end

    def parse_patch
      x_offset = read_short
      y_offset = read_short
      patch_number = read_short
      skip_bytes(4) # Skip stepdir and colormap (unused)

      patch_name = @pnames ? @pnames[patch_number] : nil
      @logger.debug("Patch name: #{patch_name || 'unknown'} (index #{patch_number})")

      TexturePatch.new(
        patch_index: patch_number,
        x_offset: x_offset,
        y_offset: y_offset,
        name: patch_name
      )
    end

    def read_long
      value = @data[@offset, 4].unpack1('V')
      @offset += 4
      value
    end

    def read_short
      value = @data[@offset, 2].unpack1('v')
      @offset += 2
      value
    end

    def read_string(length)
      value = @data[@offset, length].tr("\x00", '')
      @offset += length
      value
    end

    def skip_bytes(count)
      @offset += count
    end
  end
end
