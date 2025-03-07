# frozen_string_literal: true

require_relative 'logger'
require_relative 'renderer/utils/texture'
require_relative 'renderer/utils/texture_composer'

module Doom
  class WadFile
    IWAD_TYPE = 'IWAD'
    PWAD_TYPE = 'PWAD'

    TEXTURE_MARKERS = %w[P_START P1_START P2_START P3_START].freeze
    FLAT_MARKERS = %w[F_START F1_START F2_START F3_START].freeze
    SPRITE_MARKERS = ['S_START'].freeze
    LEVEL_MARKERS = /^(E\dM\d|MAP\d\d)$/
    LEVEL_LUMPS = %w[THINGS LINEDEFS SIDEDEFS VERTEXES SEGS SSECTORS NODES SECTORS REJECT
                     BLOCKMAP].freeze

    attr_reader :identification, :lump_count, :directory_offset, :lumps

    def initialize(file_path)
      @file_path = file_path
      @lumps = {}
      @logger = Logger.instance
      @logger.debug("Initializing WAD file from #{file_path}")
      @logger.debug("File exists: #{File.exist?(file_path)}")
      @logger.debug("File size: #{File.size(file_path)} bytes")
      parse_header
      parse_directory
    end

    def lump(name)
      @logger.debug("Looking up lump: #{name.upcase}")
      result = @lumps[name.upcase] # WAD files store names in uppercase
      @logger.debug("Lump lookup result: #{result.nil? ? 'nil' : result.name}")
      result
    end

    def textures
      @logger.debug('Loading textures...')
      # First try to find textures in TEXTURE1/TEXTURE2 lumps
      texture_lumps = %w[TEXTURE1 TEXTURE2].map { |name| [name, @lumps[name]] }.to_h.compact
      @logger.debug("Found texture lumps: #{texture_lumps.keys.join(', ')}")
      textures = {}

      # Load PNAMES first
      pnames = if @lumps['PNAMES']
                 data = @lumps['PNAMES'].read
                 if data
                   count = data[0, 4].unpack1('V')
                   @logger.debug("Found #{count} patch names")
                   data[4..].unpack('Z8' * count)
                 end
               end

      # Parse textures from TEXTURE1/TEXTURE2 lumps
      texture_lumps.each do |name, lump|
        @logger.debug("Reading texture lump: #{name}")
        data = lump.read
        @logger.debug("Texture data size: #{data&.size || 'nil'}")
        next unless data

        TextureParser.parse(data, pnames).each do |texture|
          @logger.debug("Found texture: #{texture.name} (#{texture.width}x#{texture.height})")
          textures[texture.name] = texture
        end
      end

      # Then look for individual texture lumps
      @lumps.each do |name, lump|
        next if name.match?(LEVEL_MARKERS) || %w[TEXTURE1 TEXTURE2 PNAMES].include?(name)
        next unless name.match?(/^[A-Z0-9]+$/)

        @logger.debug("Found individual texture: #{name}")
        textures[name] = Texture.new(
          name: name,
          width: 64, # Default size for individual textures
          height: 128,
          patches: []
        )
      end

      @logger.debug("Total textures found: #{textures.size}")
      textures
    end

    def flats
      find_lumps_between_markers(FLAT_MARKERS, '_END')
    end

    def sprites
      find_lumps_between_markers(SPRITE_MARKERS, '_END')
    end

    def levels
      @lumps.keys.select { |name| name.match?(LEVEL_MARKERS) }
    end

    def level_data(level_name)
      level_index = @lumps.keys.index(level_name)
      return nil unless level_index

      # Level data follows the level marker until the next level marker or end of WAD
      lump_names = @lumps.keys[level_index + 1..]
      level_lumps = {}

      lump_names.each do |name|
        break if name.match?(LEVEL_MARKERS)
        next unless LEVEL_LUMPS.include?(name)

        level_lumps[name] = @lumps[name]
      end

      level_lumps
    end

    def read_string(length, offset)
      File.open(@file_path, 'rb') do |file|
        file.seek(offset)
        data = file.read(length)
        data ? data.delete("\x00") : ''
      end
    end

    def parse_texture(name, pnames = nil)
      @logger.debug("Parsing texture: #{name}")
      lump = @lumps[name.upcase] # WAD files store names in uppercase
      return [] unless lump

      data = lump.read
      return [] if data.nil? || data.empty?

      # If this is a TEXTURE1/TEXTURE2 lump, parse it as a texture list
      textures = if name.match?(/^TEXTURE[12]$/i)
                   TextureParser.parse(data, pnames)
                 else
                   # Otherwise treat it as a single texture
                   [Texture.new(
                     name: name.upcase,
                     width: 64,
                     height: 128,
                     patches: [TexturePatch.new(
                       x_offset: 0,
                       y_offset: 0,
                       name: name.upcase,
                       patch_index: 0
                     )]
                   )]
                 end

      @logger.debug("Parsed #{textures.size} textures")
      textures
    end

    private

    def parse_header
      File.open(@file_path, 'rb') do |file|
        header_data = file.read(12)
        @logger.debug("Read header data (#{header_data.bytesize} bytes): #{header_data.unpack1('H*')}")
        return unless header_data && header_data.size == 12

        @identification = header_data[0, 4]
        @lump_count = header_data[4, 4].unpack1('V')
        @directory_offset = header_data[8, 4].unpack1('V')

        @logger.debug("WAD header: type='#{@identification}', lumps=#{@lump_count}, dir_offset=#{@directory_offset}")
      end
    end

    def parse_directory
      return unless @lump_count && @directory_offset

      @logger.debug("Starting directory parse with #{@lump_count} lumps at offset #{@directory_offset}")
      @lumps = {}
      File.open(@file_path, 'rb') do |file|
        file.seek(@directory_offset)
        @logger.debug("Seeking to directory at offset #{@directory_offset}")

        @lump_count.times do |i|
          entry_data = file.read(16)
          break unless entry_data && entry_data.size == 16

          offset = entry_data[0, 4].unpack1('V')
          size = entry_data[4, 4].unpack1('V')
          name = entry_data[8, 8].tr("\x00", '').strip

          next if name.empty?

          @logger.debug("Found lump #{i + 1}/#{@lump_count}: name='#{name}', offset=#{offset}, size=#{size}")

          entry = DirectoryEntry.new(
            name: name.upcase,
            offset: offset,
            size: size,
            file_path: @file_path
          )

          if entry.valid?
            @lumps[entry.name] = entry
            @logger.debug("Added valid lump: #{entry.name}")
          else
            @logger.debug("Skipped invalid lump: #{name}")
          end
        rescue StandardError => e
          @logger.warn("Failed to parse directory entry: #{e.message}")
          next
        end
      end
      @logger.debug("Parsed #{@lumps.size} valid lumps")
      @logger.debug('Looking for required lumps: STARTAN3, E1M1, TEXTURE1, TEXTURE2')
      @logger.debug("STARTAN3 present: #{@lumps['STARTAN3'] ? 'yes' : 'no'}")
      @logger.debug("E1M1 present: #{@lumps['E1M1'] ? 'yes' : 'no'}")
      @logger.debug("TEXTURE1 present: #{@lumps['TEXTURE1'] ? 'yes' : 'no'}")
      @logger.debug("TEXTURE2 present: #{@lumps['TEXTURE2'] ? 'yes' : 'no'}")
    end

    def find_lumps_between_markers(start_markers, end_suffix)
      lumps = {}
      in_section = false

      @lumps.each do |name, lump|
        if start_markers.include?(name)
          in_section = true
          next
        end

        if name.end_with?(end_suffix)
          in_section = false
          next
        end

        lumps[name] = lump if in_section
      end

      lumps
    end
  end

  class DirectoryEntry
    attr_reader :name, :offset, :size

    def initialize(name:, offset:, size:, file_path:)
      @name = name
      @offset = offset
      @size = size
      @file_path = file_path
    end

    def valid?
      @name && !@name.empty? && @offset && @size && @file_path && File.exist?(@file_path)
    end

    def read
      return nil unless valid?
      return nil if @size.zero?

      File.open(@file_path, 'rb') do |file|
        file.seek(@offset)
        file.read(@size)
      end
    end

    def width
      return nil unless valid?

      data = read
      return nil unless data && data.size >= 2

      data[0, 2].unpack1('v')
    end

    def height
      return nil unless valid?

      data = read
      return nil unless data && data.size >= 4

      data[2, 2].unpack1('v')
    end
  end
end
