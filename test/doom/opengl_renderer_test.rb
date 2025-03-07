require 'test_helper'
require 'doom/opengl_renderer'
require 'doom/map'
require 'doom/player'
require 'doom/wad_file'
require 'doom/texture_composer'

module Doom
  class OpenGLRendererTest < Minitest::Test
    def setup
      @window = Gosu::Window.new(800, 600, false)
      @map = load_e1m1
      @textures = load_test_textures
      @renderer = OpenGLRenderer.new(@window, @map, @textures)
      @player = Player.new(@map)
      @player.position = Vector[96, 64] # Starting position in E1M1
    end

    def teardown
      @window.close
    end

    def test_initialization
      assert_instance_of OpenGLRenderer, @renderer
      assert_instance_of Viewport, @renderer.instance_variable_get(:@viewport)
      assert_instance_of ScreenBuffer, @renderer.instance_variable_get(:@screen_buffer)
      assert_instance_of RayCaster, @renderer.instance_variable_get(:@ray_caster)
    end

    def test_render_with_empty_map
      # This should not raise any errors
      @window.draw do
        @renderer.render(@player)
      end
      @window.update

      assert_operator @renderer.last_render_time, :>, 0
    end

    def test_render_with_walls
      # This should not raise any errors
      @window.draw do
        @renderer.render(@player)
      end
      @window.update

      assert_operator @renderer.last_render_time, :>, 0
    end

    def test_render_performance
      # Measure render time
      @window.draw do
        start_time = Time.now
        @renderer.render(@player)
        render_time = Time.now - start_time

        # Should render in under 100ms
        assert_operator render_time, :<, 0.1
      end
      @window.update
    end

    def test_viewport_scaling
      viewport = @renderer.instance_variable_get(:@viewport)

      assert_equal 2, viewport.scale
      assert_equal 640, viewport.scaled_width
      assert_equal 400, viewport.scaled_height
    end

    private

    def load_e1m1
      wad_path = Doom::Config.wad_path
      wad_file = Doom::WadFile.new(wad_path)
      Map.create_map_from_level_data(wad_file.level_data('E1M1'))
    end
  end
end
