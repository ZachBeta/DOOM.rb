module Doom
  class WadFile
    IWAD_TYPE = 'IWAD'
    PWAD_TYPE = 'PWAD'

    attr_reader :identification, :lump_count, :directory_offset

    def initialize(file_path)
      @file_path = file_path
      parse_header
    end

    private

    def parse_header
      File.open(@file_path, 'rb') do |file|
        @identification = file.read(4)
        @lump_count = file.read(4).unpack1('V')
        @directory_offset = file.read(4).unpack1('V')
      end
    end
  end
end
