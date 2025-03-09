# frozen_string_literal: true

require_relative 'logger'

module Doom
  class WadFile
    IWAD_TYPE = 'IWAD'
    PWAD_TYPE = 'PWAD'

    LEVEL_MARKERS = /^(E\dM\d|MAP\d\d)$/
    LEVEL_LUMPS = %w[THINGS LINEDEFS SIDEDEFS VERTEXES SEGS SSECTORS NODES SECTORS REJECT
                     BLOCKMAP].freeze

    FLAT_MARKERS = %w[F_START FF_START].freeze
    FLAT_END_MARKERS = %w[F_END FF_END].freeze

    attr_reader :identification, :lump_count, :directory_offset, :lumps

    class Lump
      attr_reader :name, :offset, :size

      def initialize(name, offset, size, wad_file)
        @name = name
        @offset = offset
        @size = size
        @wad_file = wad_file
      end

      def read
        @wad_file.read_bytes(@offset, @size)
      end

      def start_with?(prefix)
        name.start_with?(prefix)
      end
    end

    class Texture
      attr_reader :name, :width, :height, :patches

      def initialize(name, width, height, patches)
        @name = name
        @width = width
        @height = height
        @patches = patches
      end
    end

    class Patch
      attr_reader :name, :patch_index, :x_offset, :y_offset

      def initialize(patch_index, x_offset, y_offset, name = nil)
        @patch_index = patch_index
        @x_offset = x_offset
        @y_offset = y_offset
        @name = name
      end
    end

    def initialize(file_path)
      @file_path = file_path
      @lumps = {}
      @logger = Logger.instance
      @logger.debug("Initializing WAD file from #{file_path}")
      load
    end

    def load
      @logger.info("Loading WAD file: #{@file_path}")
      File.open(@file_path, 'rb') do |file|
        read_header(file)
        read_directory(file)
      end
      @logger.info('WAD file loaded successfully')
    end

    def lump(name)
      @logger.debug("Looking up lump: #{name.upcase}")
      @lumps[name.upcase]
    end

    def levels
      @lumps.keys.select { |name| name.match?(LEVEL_MARKERS) }
    end

    def level_data(level_name)
      level_index = @lumps.keys.index(level_name)
      return nil unless level_index

      data = {}
      LEVEL_LUMPS.each do |lump_name|
        lump_index = level_index + 1 + LEVEL_LUMPS.index(lump_name)
        next if lump_index >= @lumps.keys.length

        lump = @lumps[@lumps.keys[lump_index]]
        data[lump_name] = lump if lump
      end
      data
    end

    def textures
      result = {}
      texture_lumps = []
      texture_lumps << lump('TEXTURE1')
      texture_lumps << lump('TEXTURE2')
      texture_lumps.compact.each do |lump|
        textures = parse_texture(lump.name)
        textures.each do |texture|
          result[texture.name] = texture
        end
      end
      result
    end

    def flats
      in_flat_section = false
      flat_lumps = []

      @lumps.each do |name, lump|
        if FLAT_MARKERS.include?(name)
          in_flat_section = true
          next
        end

        if FLAT_END_MARKERS.include?(name)
          in_flat_section = false
          next
        end

        flat_lumps << lump if in_flat_section
      end

      flat_lumps
    end

    def parse_texture(name, pnames = nil)
      lump = lump(name)
      return [] unless lump

      data = lump.read
      return [] unless data && data.size >= 4

      num_textures = data[0, 4].unpack1('V')
      return [] unless num_textures && num_textures > 0

      # Read the texture offsets
      offsets = data[4, num_textures * 4].unpack('V*')
      textures = []

      offsets.each do |offset|
        break if offset + 22 > data.size

        texture = parse_texture_entry(data, offset, pnames)
        break unless texture

        textures << texture
      end

      textures
    end

    def read_bytes(offset, size)
      File.open(@file_path, 'rb') do |file|
        file.seek(offset)
        file.read(size)
      end
    end

    private

    def read_header(file)
      @identification = file.read(4).strip
      @lump_count = file.read(4).unpack1('V')
      @directory_offset = file.read(4).unpack1('V')
    end

    def read_directory(file)
      file.seek(@directory_offset)
      @lump_count.times do
        offset = file.read(4).unpack1('V')
        size = file.read(4).unpack1('V')
        name = file.read(8).strip
        @lumps[name] = Lump.new(name, offset, size, self)
      end
    end

    def read_string(length, offset)
      File.open(@file_path, 'rb') do |file|
        file.seek(offset)
        file.read(length).strip
      end
    end

    def parse_texture_entry(data, offset, pnames = nil)
      return nil if offset + 22 > data.size

      name = data[offset, 8].strip
      width = data[offset + 12, 2].unpack1('v')
      height = data[offset + 14, 2].unpack1('v')
      num_patches = data[offset + 20, 2].unpack1('v')

      return nil unless width && height && num_patches && num_patches > 0

      patches = []
      patch_offset = offset + 22

      num_patches.times do |i|
        break if patch_offset + (i * 10) + 6 > data.size

        x_offset = data[patch_offset + (i * 10), 2].unpack1('v')
        y_offset = data[patch_offset + (i * 10) + 2, 2].unpack1('v')
        patch_index = data[patch_offset + (i * 10) + 4, 2].unpack1('v')

        next unless x_offset && y_offset && patch_index

        patch_name = pnames ? pnames[patch_index] : nil
        patches << Patch.new(patch_index, x_offset, y_offset, patch_name)
      end

      Texture.new(name, width, height, patches)
    end
  end
end
