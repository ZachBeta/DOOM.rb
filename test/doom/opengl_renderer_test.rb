require 'test_helper'
require 'doom/opengl_renderer'
require 'minitest/autorun'
require 'benchmark'

module Doom
  class OpenGLRendererTest < Minitest::Test
    def setup
      @window = MockWindow.new(800, 600)
      @map = MockMap.new
      @textures = load_test_textures
      skip 'No textures loaded from WAD file' if @textures.empty?

      @renderer = OpenGLRenderer.new(@window, @map, @textures)
      @player = MockPlayer.new([5, 5], [1, 0])
    end

    def test_initialization
      assert_instance_of OpenGLRenderer, @renderer
      assert_equal 0, @renderer.last_render_time
      assert_predicate @textures, :any?, 'No textures loaded from WAD file'
      assert_includes @textures.keys, 'STARTAN3', 'STARTAN3 texture not found'
    end

    def test_texture_loading
      @textures.each do |name, texture|
        assert_kind_of ComposedTexture, texture, "#{name} is not a ComposedTexture"
        assert_operator texture.width, :>, 0, "#{name} has invalid width"
        assert_operator texture.height, :>, 0, "#{name} has invalid height"
        assert_operator texture.data.size, :>, 0, "#{name} has no data"
      end
    end

    def test_rendering_performance
      time = Benchmark.realtime do
        5.times { @renderer.render(@player) }
      end
      avg_frame_time = time / 5.0

      assert_operator avg_frame_time, :<=, 0.016,
                      "OpenGL rendering too slow: #{(avg_frame_time * 1000).round(2)}ms per frame"
    end

    def test_texture_caching
      # First render to populate cache
      @renderer.render(@player)

      # Second render should use cache
      start_time = Time.now
      @renderer.render(@player)
      cached_render_time = Time.now - start_time

      assert_operator cached_render_time, :<=, 0.016,
                      "Cached rendering too slow: #{(cached_render_time * 1000).round(2)}ms"
    end

    def test_logging
      logger = Logger.instance
      log_output = StringIO.new
      logger.instance_variable_set(:@debug_log, log_output)

      @renderer.render(@player)

      log_content = log_output.string

      assert_includes log_content, 'OpenGL renderer'
      assert_includes log_content, 'Frame timing'
      assert_includes log_content, 'Texture batches'
    end

    def test_mipmap_generation
      texture = @textures['STARTAN3']

      assert_predicate texture.mipmaps, :any?, 'No mipmaps generated for STARTAN3'

      # Verify mipmap chain
      mipmap = texture.mipmaps.first

      assert_equal texture.width / 2, mipmap[:width], 'Invalid mipmap width'
      assert_equal texture.height / 2, mipmap[:height], 'Invalid mipmap height'
      assert_equal (texture.width / 2) * (texture.height / 2), mipmap[:data].size,
                   'Invalid mipmap data size'
    end
  end
end
