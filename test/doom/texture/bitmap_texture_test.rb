# frozen_string_literal: true

require 'minitest/autorun'
require_relative '../../../lib/doom/texture/bitmap_texture'

class BitmapTextureTest < Minitest::Test
  def setup
    @texture_name = 'test_texture'
    @texture_width = 128
    @texture_height = 128
  end

  def test_initialize_with_defaults
    texture = Doom::Texture::BitmapTexture.new(@texture_name)

    assert_equal @texture_name, texture.name
    assert_equal Doom::Texture::BitmapTexture::DEFAULT_SIZE, texture.width
    assert_equal Doom::Texture::BitmapTexture::DEFAULT_SIZE, texture.height
    assert_nil texture.gosu_image
  end

  def test_initialize_with_custom_dimensions
    texture = Doom::Texture::BitmapTexture.new(@texture_name, 256, 256)

    assert_equal @texture_name, texture.name
    assert_equal 256, texture.width
    assert_equal 256, texture.height
  end

  def test_create_checkerboard
    texture = Doom::Texture::BitmapTexture.create_checkerboard(@texture_name)

    assert_equal @texture_name, texture.name
    refute_nil texture.gosu_image
  end

  def test_create_brick
    texture = Doom::Texture::BitmapTexture.create_brick(@texture_name)

    assert_equal @texture_name, texture.name
    refute_nil texture.gosu_image
  end

  def test_create_grid
    texture = Doom::Texture::BitmapTexture.create_grid(@texture_name)

    assert_equal @texture_name, texture.name
    refute_nil texture.gosu_image
  end

  def test_get_pixel
    texture = Doom::Texture::BitmapTexture.create_checkerboard(@texture_name)
    pixel = texture.get_pixel(0, 0)

    refute_nil pixel
    assert_kind_of Gosu::Color, pixel
  end
end
