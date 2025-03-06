require 'minitest/autorun'
require_relative '../../lib/doom/wad_file'
require_relative '../../lib/doom/config'

class WadFileTest < Minitest::Test
  def setup
    @wad_path = Doom::Config.wad_path
    @wad_file = Doom::WadFile.new(@wad_path)
  end

  def test_parses_wad_header
    assert_equal 'IWAD', @wad_file.identification
    assert_operator @wad_file.lump_count, :>, 0
    assert_operator @wad_file.directory_offset, :>, 0
  end

  def test_parses_directory_entries
    # Test a known texture lump
    texture_lump = @wad_file.lump('STARTAN3')

    assert_equal 'STARTAN3', texture_lump.name
    assert_operator texture_lump.size, :>, 0

    # Test a known map lump
    map_lump = @wad_file.lump('E1M1')

    assert_equal 'E1M1', map_lump.name
  end

  def test_reads_lump_data
    texture_lump = @wad_file.lump('STARTAN3')
    data = texture_lump.read

    assert_operator data.bytesize, :>, 0
  end

  def test_finds_textures
    textures = @wad_file.textures

    assert_operator textures.size, :>, 0
    assert_includes textures.keys, 'STARTAN3'
  end

  def test_parses_texture_data
    texture = @wad_file.parse_texture('STARTAN3')

    assert_operator texture.first.name.length, :>, 0
    assert_operator texture.first.width, :>, 0
    assert_operator texture.first.height, :>, 0
    assert_operator texture.first.patches.size, :>, 0

    patch = texture.first.patches.first

    assert_kind_of Integer, patch.patch_index
    assert_kind_of Integer, patch.x_offset
    assert_kind_of Integer, patch.y_offset
  end

  def test_resolves_patch_names_with_pnames
    pnames = @wad_file.lump('PNAMES').read.unpack('V*')[1..-1].map do |i|
      @wad_file.read_string(8, i * 8)
    end
    texture = @wad_file.parse_texture('STARTAN3', pnames)

    patch = texture.first.patches.first

    assert_operator patch.name.length, :>, 0
    assert_kind_of Integer, patch.patch_index
    assert_kind_of Integer, patch.x_offset
    assert_kind_of Integer, patch.y_offset
  end

  def test_finds_flats
    flats = @wad_file.flats

    assert_operator flats.size, :>, 0
    assert(flats.any? { |name, _| name.start_with?('FLAT') || name.start_with?('FLOOR') })
  end

  def test_finds_levels
    levels = @wad_file.levels

    assert_operator levels.size, :>, 0
    assert_includes levels, 'E1M1'
  end

  def test_gets_level_data
    level_data = @wad_file.level_data('E1M1')

    assert_operator level_data.size, :>, 0
    assert_includes level_data.keys, 'THINGS'
    assert_includes level_data.keys, 'LINEDEFS'
  end
end
