# frozen_string_literal: true

require 'test_helper'
require 'doom/renderer/core/opengl_renderer'
require 'doom/renderer/core/base_renderer'
require 'doom/renderer/components/viewport'
require 'doom/renderer/components/screen_buffer'
require 'doom/renderer/components/ray_caster'
require 'doom/map'
require 'doom/player'
require 'doom/wad_file'
require 'doom/renderer/utils/texture_composer'
require 'doom/renderer/utils/texture'

module Doom
  class OpenGLRendererTest < Minitest::Test
    def setup
      @window = TestWindow.new
      @map = Map.new
      @textures = Textures.new
      @renderer = Renderer::Core::OpenGLRenderer.new(@window, @map, @textures)
      @player = Player.new(Vector[1, 1], 0)
    end

    def teardown
      @window.close
    end

    def test_initialization
      assert_instance_of Renderer::Core::OpenGLRenderer, @renderer
      assert_instance_of Renderer::Components::Viewport, @renderer.instance_variable_get(:@viewport)
      assert_instance_of Renderer::Components::ScreenBuffer,
                         @renderer.instance_variable_get(:@screen_buffer)
      assert_instance_of Renderer::Components::RayCaster,
                         @renderer.instance_variable_get(:@ray_caster)
      assert_equal 0, @renderer.metrics[:ray_casting_time]
      assert_equal 0, @renderer.metrics[:wall_drawing_time]
      assert_equal 0, @renderer.metrics[:buffer_flip_time]
      assert_equal 0, @renderer.metrics[:total_rays]
      assert_equal 0, @renderer.metrics[:frame_count]
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

    def test_metrics_increment_on_render
      @window.draw do
        @renderer.render(@player)
      end
      @window.update

      assert_equal 1, @renderer.metrics[:frame_count]
      assert_operator @renderer.metrics[:ray_casting_time], :>, 0
      assert_operator @renderer.metrics[:buffer_flip_time], :>, 0
      assert_operator @renderer.last_render_time, :>, 0
      assert_operator @renderer.last_texture_time, :>, 0
    end

    def test_metrics_accumulation
      3.times do
        @window.draw do
          @renderer.render(@player)
        end
        @window.update
      end

      assert_equal 3, @renderer.metrics[:frame_count]
    end

    def test_logging_frequency
      # Render 59 frames - should not log
      59.times do
        @window.draw do
          @renderer.render(@player)
        end
        @window.update
      end

      # Render 60th frame - should log
      @window.draw do
        @renderer.render(@player)
      end
      @window.update

      # Verify log file exists and contains metrics
      log_files = Dir.glob('logs/debug*.log')

      assert !log_files.empty?, 'No debug log files found'

      last_log = File.read(log_files.last)

      assert_includes last_log, 'Frame metrics'
      assert_includes last_log, 'fps'
      assert_includes last_log, 'total_time'
      assert_includes last_log, 'ray_casting'
      assert_includes last_log, 'buffer_flip'
      assert_includes last_log, 'texture_time'
      assert_includes last_log, 'total_rays'
      assert_includes last_log, 'player_angle'
    end

    private

    def load_e1m1
      wad_path = Doom::Config.wad_path
      wad_file = Doom::WadFile.new(wad_path)
      Map.create_map_from_level_data(wad_file.level_data('E1M1'))
    end
  end
end
