require 'test_helper'
require 'doom/texture_composer'
require 'doom/texture'

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

    private

    def create_patch(name:, width:, height:, data:)
      Patch.new(name: name, width: width, height: height, data: data)
    end
  end
end
