# frozen_string_literal: true

require 'test_helper'
require 'doom/renderer/base_renderer'

module Doom
  module Renderer
    class BaseRendererTest < Minitest::Test
      def setup
        @logger = Doom::Logger.instance
        @logger.info('BaseRendererTest: Setting up test')
      end

      def teardown
        @logger.info('BaseRendererTest: Tearing down test')
      end

      def test_renderer_initialization
        @logger.info('BaseRendererTest: Testing renderer initialization')

        # Skip this test if we're in a CI environment or headless environment
        skip 'Skipping renderer test in CI/headless environment' if ENV['CI'] || ENV['HEADLESS']

        # This test verifies that the renderer can be initialized without errors
        renderer = nil

        assert_nothing_raised do
          renderer = BaseRenderer.new
          assert_equal 800, BaseRenderer::WINDOW_WIDTH, 'Window width should be 800'
          assert_equal 600, BaseRenderer::WINDOW_HEIGHT, 'Window height should be 600'
          assert_equal 4, BaseRenderer::BYTES_PER_PIXEL, 'Should use RGBA format (4 bytes per pixel)'
          assert renderer.window.is_a?(Gosu::Window), 'Should create a Gosu window'
        end

        # Clean up if renderer was created
        renderer&.cleanup

        @logger.info('BaseRendererTest: Renderer initialization test complete')
      end

      def test_pixel_buffer_operations
        skip 'Skipping renderer test in CI/headless environment' if ENV['CI'] || ENV['HEADLESS']

        renderer = nil
        begin
          renderer = BaseRenderer.new
          
          # Test that we can set game objects
          map = Object.new
          def map.wall_at?(*); false; end
          
          player = Object.new
          def player.x; 0; end
          def player.y; 0; end
          def player.angle; 0; end
          
          assert_nothing_raised do
            renderer.set_game_objects(map, player)
            renderer.render # Should run one frame without errors
          end
        ensure
          renderer&.cleanup
        end
      end
    end
  end
end
