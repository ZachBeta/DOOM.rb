require 'test_helper'
require 'doom/texture_composer'
require 'doom/texture'
require 'benchmark'

module Doom
  class TextureComposerTest < Minitest::Test
    def test_composes_simple_texture
      patch1 = create_patch(
        name: 'WALL03_3',
        width: 64,
        height: 128,
        data: Array.new(64 * 128, 1)
      )

      patch2 = create_patch(
        name: 'WALL03_4',
        width: 64,
        height: 128,
        data: Array.new(64 * 128, 2)
      )

      texture = Texture.new(
        name: 'STARTAN3',
        width: 128,
        height: 128,
        patches: [
          TexturePatch.new(name: 'WALL03_3', x_offset: 0, y_offset: 0),
          TexturePatch.new(name: 'WALL03_4', x_offset: 64, y_offset: 0)
        ]
      )

      composer = TextureComposer.new
      composed = composer.compose(texture, { 'WALL03_3' => patch1, 'WALL03_4' => patch2 })

      assert_equal 128, composed.width
      assert_equal 128, composed.height

      # Left half should be from patch1
      assert_equal 1, composed.data[0]
      assert_equal 1, composed.data[63]

      # Right half should be from patch2
      assert_equal 2, composed.data[64]
      assert_equal 2, composed.data[127]
    end

    def test_handles_pnames_lookup
      pnames = %w[WALL03_3 WALL03_4 WALL03_5]
      patch1 = create_patch(
        name: 'WALL03_3',
        width: 64,
        height: 128,
        data: Array.new(64 * 128, 1)
      )

      texture = Texture.new(
        name: 'STARTAN3',
        width: 64,
        height: 128,
        patches: [
          TexturePatch.new(patch_index: 0, x_offset: 0, y_offset: 0)
        ]
      )

      composer = TextureComposer.new
      composed = composer.compose(texture, { 'WALL03_3' => patch1 }, pnames)

      assert_equal 64, composed.width
      assert_equal 128, composed.height
      assert_equal 1, composed.data[0]
    end

    def test_texture_composition_performance
      # Create a large texture with multiple patches
      patch_size = 256
      num_patches = 4
      patches = {}
      texture_patches = []

      num_patches.times do |i|
        name = "PATCH#{i}"
        patches[name] = create_patch(
          name: name,
          width: patch_size,
          height: patch_size,
          data: Array.new(patch_size * patch_size, i + 1)
        )
        texture_patches << TexturePatch.new(
          name: name,
          x_offset: (i % 2) * patch_size,
          y_offset: (i / 2) * patch_size
        )
      end

      texture = Texture.new(
        name: 'BIGTEST',
        width: patch_size * 2,
        height: patch_size * 2,
        patches: texture_patches
      )

      composer = TextureComposer.new
      time = Benchmark.realtime do
        5.times do
          composer.compose(texture, patches)
        end
      end

      # Average time should be under 50ms for 5 compositions
      assert_operator time / 5.0, :<=, 0.05,
                      "Texture composition took too long: #{(time / 5.0 * 1000).round(2)}ms average"
    end

    private

    def create_patch(name:, width:, height:, data:)
      Patch.new(name: name, width: width, height: height, data: data)
    end
  end
end
