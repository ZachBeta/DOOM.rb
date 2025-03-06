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
    attr_reader :name, :x_offset, :y_offset

    def initialize(name:, x_offset:, y_offset:)
      @name = name
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

    def self.parse(data)
      new(data).parse
    end

    def initialize(data)
      @data = data
      @offset = 0
    end

    def parse
      num_textures = read_long
      puts "Number of textures: #{num_textures}"
      texture_offsets = read_texture_offsets(num_textures)
      puts "Texture offsets: #{texture_offsets.inspect}"

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
      name = read_string(TEXTURE_NAME_LENGTH).strip
      puts "Parsing texture: #{name}"
      skip_bytes(4) # Skip flags (unused)
      width = read_short
      puts "Width: #{width}"
      height = read_short
      puts "Height: #{height}"
      skip_bytes(4) # Skip column directory (unused)
      num_patches = read_short
      puts "Number of patches: #{num_patches}"

      patches = num_patches.times.map do
        parse_patch
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

      # For now, we'll use a placeholder name based on the patch number
      # In a real implementation, we'd need to look up the actual patch name
      TexturePatch.new(
        name: patch_number == 0 ? 'WALL03_3' : 'WALL03_4',
        x_offset: x_offset,
        y_offset: y_offset
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
      value = @data[@offset, length].delete("\x00")
      @offset += length
      value
    end

    def skip_bytes(count)
      @offset += count
    end
  end
end
