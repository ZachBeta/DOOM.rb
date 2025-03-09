# frozen_string_literal: true

require_relative 'logger'

module Doom
  class WadFile
    IWAD_TYPE = 'IWAD'
    PWAD_TYPE = 'PWAD'

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

    private

    def parse_header
      # Implementation of parse_header
    end

    def parse_directory
      # Implementation of parse_directory
    end
  end
end
