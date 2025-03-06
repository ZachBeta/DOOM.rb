require 'minitest/autorun'
require_relative '../../lib/doom/wad_file'
require_relative '../../lib/doom/config'

class WadFileTest < Minitest::Test
  def setup
    @wad_path = Doom::Config.wad_path
    puts "Testing with WAD file: #{@wad_path}"
    puts "WAD file exists: #{File.exist?(@wad_path)}"
    puts "WAD file size: #{begin
      File.size(@wad_path)
    rescue StandardError
      'N/A'
    end}"
    @wad_file = Doom::WadFile.new(@wad_path)
  end

  def test_parses_wad_header
    assert_equal 'IWAD', @wad_file.identification
    assert_operator @wad_file.lump_count, :>, 0
    assert_operator @wad_file.directory_offset, :>, 0
  end

  def test_parses_directory_entries
    # Test a known texture lump
    texture_lump = @wad_file.lump('TEXTURE1')

    refute_nil texture_lump, 'TEXTURE1 lump not found'
    assert_equal 'TEXTURE1', texture_lump.name
    assert_operator texture_lump.size, :>, 0

    # Test a known map lump
    map_lump = @wad_file.lump('E1M1')

    refute_nil map_lump, 'E1M1 lump not found'
    assert_equal 'E1M1', map_lump.name
  end

  def test_reads_lump_data
    texture_lump = @wad_file.lump('TEXTURE1')

    refute_nil texture_lump, 'TEXTURE1 lump not found'
    data = texture_lump.read

    assert_operator data.bytesize, :>, 0
  end

  def test_finds_textures
    textures = @wad_file.textures

    assert_operator textures.size, :>, 0
    assert_includes textures.keys, 'STARTAN3'
  end

  def test_parses_texture_data
    textures = @wad_file.parse_texture('TEXTURE1')

    refute_empty textures, 'No textures found in TEXTURE1'

    texture = textures.first

    refute_nil texture, 'First texture is nil'

    assert_operator texture.name.length, :>, 0
    assert_operator texture.width, :>, 0
    assert_operator texture.height, :>, 0
    assert_operator texture.patches.size, :>, 0

    patch = texture.patches.first

    refute_nil patch, 'First patch is nil'

    assert_kind_of Integer, patch.patch_index
    assert_kind_of Integer, patch.x_offset
    assert_kind_of Integer, patch.y_offset
  end

  def test_resolves_patch_names_with_pnames
    pnames_lump = @wad_file.lump('PNAMES')
    skip 'PNAMES lump not found' unless pnames_lump

    data = pnames_lump.read
    count = data[0, 4].unpack1('V')
    pnames = data[4..].unpack('Z8' * count)
    textures = @wad_file.parse_texture('TEXTURE1', pnames)

    refute_empty textures, 'No textures found in TEXTURE1'

    texture = textures.first

    refute_nil texture, 'First texture is nil'

    patch = texture.patches.first

    refute_nil patch, 'First patch is nil'

    assert_operator patch.name.to_s.length, :>, 0
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
