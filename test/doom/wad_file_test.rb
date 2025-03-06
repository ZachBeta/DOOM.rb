require 'test_helper'
require 'doom/wad_file'
require 'stringio'

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
      assert_equal 11, wad_file.lump_count
      assert_equal 111, wad_file.directory_offset
    end

    def test_parses_directory_entries
      wad_file = WadFile.new(@test_wad_path)

      demo_lump = wad_file.lump('DEMO')

      assert_equal 'DEMO', demo_lump.name
      assert_equal 5, demo_lump.size

      map_lump = wad_file.lump('MAP01')

      assert_equal 'MAP01', map_lump.name
      assert_equal 10, map_lump.size
    end

    def test_reads_lump_data
      wad_file = WadFile.new(@test_wad_path)

      demo_lump = wad_file.lump('DEMO')

      assert_equal 'HELLO', demo_lump.read

      map_lump = wad_file.lump('MAP01')

      assert_equal 'MAPDATA123', map_lump.read
    end

    def test_finds_textures
      wad_file = WadFile.new(@test_wad_path)
      textures = wad_file.textures

      assert_equal 2, textures.size
      assert_includes textures.keys, 'TEXTURE1'
      assert_includes textures.keys, 'TEXTURE2'
    end

    def test_parses_texture1_data
      wad_file = WadFile.new(@test_wad_path)
      texture = wad_file.parse_texture('TEXTURE1')

      assert_equal 'STARTAN3', texture.first.name
      assert_equal 128, texture.first.width
      assert_equal 128, texture.first.height
      assert_equal 2, texture.first.patches.size

      patch = texture.first.patches.first

      assert_equal 'WALL03_3', patch.name
      assert_equal 0, patch.x_offset
      assert_equal 0, patch.y_offset
    end

    def test_finds_flats
      wad_file = WadFile.new(@test_wad_path)
      flats = wad_file.flats

      assert_equal 1, flats.size
      assert_includes flats.keys, 'FLAT1'
    end

    def test_finds_levels
      wad_file = WadFile.new(@test_wad_path)
      levels = wad_file.levels

      assert_equal 1, levels.size
      assert_includes levels, 'MAP01'
    end

    def test_gets_level_data
      wad_file = WadFile.new(@test_wad_path)
      level_data = wad_file.level_data('MAP01')

      assert_equal 2, level_data.size
      assert_includes level_data.keys, 'THINGS'
      assert_includes level_data.keys, 'LINEDEFS'
    end

    private

    def create_test_wad
      # Create a StringIO to build the WAD data
      data = StringIO.new
      directory = []

      # Write header placeholders
      data.write('IWAD')                # identification (4 bytes)
      data.write([0].pack('V'))         # lump count placeholder
      data.write([0].pack('V'))         # directory offset placeholder

      # Write DEMO lump
      add_lump(data, directory, 'DEMO', 'HELLO')

      # Write MAP01 and its data
      add_lump(data, directory, 'MAP01', 'MAPDATA123')
      add_lump(data, directory, 'THINGS', 'THINGSDATA')
      add_lump(data, directory, 'LINEDEFS', 'LINEDATA')

      # Write texture section
      add_lump(data, directory, 'P_START', '')
      add_texture1_lump(data, directory)
      add_lump(data, directory, 'TEXTURE2', 'TEX2DATA')
      add_lump(data, directory, 'P_END', '')

      # Write flat section
      add_lump(data, directory, 'F_START', '')
      add_lump(data, directory, 'FLAT1', 'FLATDATA')
      add_lump(data, directory, 'F_END', '')

      # Record directory offset
      directory_offset = data.pos

      # Write directory
      directory.each do |entry|
        data.write([entry[:offset]].pack('V'))
        data.write([entry[:size]].pack('V'))
        data.write(entry[:name].ljust(8, "\x00"))
      end

      # Update header with final values
      data.seek(4)
      data.write([directory.size].pack('V'))
      data.write([directory_offset].pack('V'))

      # Write to file
      File.binwrite(@test_wad_path, data.string)
    end

    def add_texture1_lump(data, directory)
      texture_data = StringIO.new

      # Number of textures (1 texture)
      texture_data.write([1].pack('V'))

      # Offset to the texture definition (8 bytes from start)
      texture_data.write([8].pack('V'))

      # STARTAN3 texture definition
      texture_data.write('STARTAN3'.ljust(8, "\x00")) # name
      texture_data.write([0].pack('V'))               # flags (unused)
      texture_data.write([128].pack('v'))             # width
      texture_data.write([128].pack('v'))             # height
      texture_data.write([0].pack('V'))               # column directory (unused)
      texture_data.write([2].pack('v'))               # patch count

      # First patch
      texture_data.write([0].pack('v'))               # x offset
      texture_data.write([0].pack('v'))               # y offset
      texture_data.write([0].pack('v'))               # patch number
      texture_data.write([0].pack('v'))               # stepdir (unused)
      texture_data.write([0].pack('v'))               # colormap (unused)

      # Second patch
      texture_data.write([64].pack('v'))              # x offset
      texture_data.write([0].pack('v'))               # y offset
      texture_data.write([1].pack('v'))               # patch number
      texture_data.write([0].pack('v'))               # stepdir (unused)
      texture_data.write([0].pack('v'))               # colormap (unused)

      add_lump(data, directory, 'TEXTURE1', texture_data.string)
    end

    def add_lump(data, directory, name, content)
      directory << {
        name: name,
        offset: data.pos,
        size: content.bytesize
      }
      data.write(content)
    end
  end
end
