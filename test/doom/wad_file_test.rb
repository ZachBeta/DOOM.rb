require 'test_helper'
require 'doom/wad_file'

module Doom
  class WadFileTest < Minitest::Test
    def setup
      @test_wad_path = File.join(File.dirname(__FILE__), '../fixtures/test.wad')
      create_test_wad
    end

    def teardown
      File.delete(@test_wad_path) if File.exist?(@test_wad_path)
    end

    def test_parses_wad_header
      wad_file = WadFile.new(@test_wad_path)

      assert_equal 'IWAD', wad_file.identification
      assert_equal 10, wad_file.lump_count
      assert_equal 100, wad_file.directory_offset
    end

    private

    def create_test_wad
      File.open(@test_wad_path, 'wb') do |f|
        f.write('IWAD') # identification
        f.write([10].pack('V'))           # lump count
        f.write([100].pack('V'))          # directory offset
      end
    end
  end
end
