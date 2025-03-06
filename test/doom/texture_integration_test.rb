require 'test_helper'
require 'doom/wad_file'
require 'doom/texture'
require 'doom/texture_composer'

module Doom
  class TextureIntegrationTest < Minitest::Test
    def setup
      @test_wad_path = File.join(File.dirname(__FILE__), '../fixtures/test.wad')
      @wad_file = WadFile.new(@test_wad_path)
      @texture_composer = TextureComposer.new
    end

    def test_texture_composition_with_single_patch
      texture = Texture.new(
        name: 'TEST1',
        width: 64,
        height: 128,
        patches: [
          TexturePatch.new(
            name: 'PATCH1',
            patch_index: 0,
            x_offset: 0,
            y_offset: 0
          )
        ]
      )

      patch = Patch.new(
        name: 'PATCH1',
        width: 64,
        height: 128,
        data: Array.new(64 * 128, 1)
      )

      composed = @texture_composer.compose(texture, { 'PATCH1' => patch })

      assert_equal 64, composed.width
      assert_equal 128, composed.height
      assert_equal Array.new(64 * 128, 1), composed.data
    end

    def test_texture_composition_with_multiple_patches
      texture = Texture.new(
        name: 'TEST2',
        width: 64,
        height: 64,
        patches: [
          TexturePatch.new(
            name: 'PATCH1',
            patch_index: 0,
            x_offset: 0,
            y_offset: 0
          ),
          TexturePatch.new(
            name: 'PATCH2',
            patch_index: 1,
            x_offset: 32,
            y_offset: 0
          )
        ]
      )

      patch1 = Patch.new(
        name: 'PATCH1',
        width: 32,
        height: 64,
        data: Array.new(32 * 64, 1)
      )

      patch2 = Patch.new(
        name: 'PATCH2',
        width: 32,
        height: 64,
        data: Array.new(32 * 64, 2)
      )

      composed = @texture_composer.compose(texture, { 'PATCH1' => patch1, 'PATCH2' => patch2 })

      expected_data = []
      64.times do |y|
        32.times { expected_data << 1 } # First patch
        32.times { expected_data << 2 } # Second patch
      end

      assert_equal 64, composed.width
      assert_equal 64, composed.height
      assert_equal expected_data, composed.data
    end

    def test_texture_composition_with_overlapping_patches
      texture = Texture.new(
        name: 'TEST3',
        width: 64,
        height: 64,
        patches: [
          TexturePatch.new(
            name: 'BACKGROUND',
            patch_index: 0,
            x_offset: 0,
            y_offset: 0
          ),
          TexturePatch.new(
            name: 'OVERLAY',
            patch_index: 1,
            x_offset: 16,
            y_offset: 16
          )
        ]
      )

      background = Patch.new(
        name: 'BACKGROUND',
        width: 64,
        height: 64,
        data: Array.new(64 * 64, 1)
      )

      overlay = Patch.new(
        name: 'OVERLAY',
        width: 32,
        height: 32,
        data: Array.new(32 * 32, 2)
      )

      composed = @texture_composer.compose(texture,
                                           { 'BACKGROUND' => background, 'OVERLAY' => overlay })

      assert_equal 64, composed.width
      assert_equal 64, composed.height

      # Test a few key points to verify overlay placement
      assert_equal 1, composed.data[0] # Top-left corner (background)
      assert_equal 2, composed.data[(16 * 64) + 16] # Start of overlay
      assert_equal 1, composed.data[63] # Top-right corner (background)
    end
  end
end
