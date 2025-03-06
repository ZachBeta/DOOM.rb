require_relative 'logger'
require_relative 'texture'

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
      parse_header
      parse_directory
    end

    def lump(name)
      @lumps[name.upcase] # WAD files store names in uppercase
    end

    def textures
      find_lumps_between_markers(TEXTURE_MARKERS, '_END')
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

    def parse_texture(name)
      lump = @lumps[name]
      return [] unless lump

      TextureParser.parse(lump.read)
    end

    private

    def parse_header
      File.open(@file_path, 'rb') do |file|
        @identification = file.read(4)
        @lump_count = file.read(4).unpack1('V')
        @directory_offset = file.read(4).unpack1('V')
        puts "WAD Header: id=#{@identification}, lumps=#{@lump_count}, dir_offset=#{@directory_offset}"
      end
    end

    def parse_directory
      File.open(@file_path, 'rb') do |file|
        file.seek(@directory_offset)
        @lump_count.times do |i|
          entry = DirectoryEntry.new(file)
          puts "Directory Entry #{i}: name=#{entry.name}, offset=#{entry.offset}, size=#{entry.size}"
          @lumps[entry.name] = Lump.new(@file_path, entry)
        end
      end
    end

    def find_lumps_between_markers(start_markers, end_suffix)
      result = {}
      in_section = false
      current_section = nil

      @lumps.each do |name, lump|
        if start_markers.include?(name)
          in_section = true
          current_section = name.sub('_START', '')
        elsif name == "#{current_section}#{end_suffix}"
          in_section = false
          current_section = nil
        elsif in_section && lump.size.positive?
          result[name] = lump
        end
      end

      result
    end
  end

  class DirectoryEntry
    ENTRY_SIZE = 16
    NAME_SIZE = 8

    attr_reader :offset, :size, :name

    def initialize(file)
      @offset = file.read(4).unpack1('V')
      @size = file.read(4).unpack1('V')
      @name = file.read(NAME_SIZE).delete("\x00")
      @name.upcase! # WAD files store names in uppercase
    end
  end

  class Lump
    attr_reader :data

    def initialize(wad_path, directory_entry)
      @wad_path = wad_path
      @directory_entry = directory_entry
      @data = nil
    end

    def read
      return @data if @data

      File.open(@wad_path, 'rb') do |file|
        file.seek(@directory_entry.offset)
        @data = file.read(@directory_entry.size)
      end
      @data
    end

    def size
      @directory_entry.size
    end

    def name
      @directory_entry.name
    end
  end
end
