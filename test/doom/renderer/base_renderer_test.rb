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

        # This test just verifies that the renderer can be initialized without errors
        renderer = nil

        assert_nothing_raised do
          renderer = BaseRenderer.new
        end

        # Clean up if renderer was created
        renderer&.cleanup

        @logger.info('BaseRendererTest: Renderer initialization test complete')
      end
    end
  end
end
