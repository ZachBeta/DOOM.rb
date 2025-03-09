# frozen_string_literal: true

module Doom
  # Basic renderer placeholder
  # This will be reimplemented based on learnings from the rebuild attempt
  class Renderer
    attr_reader :width, :height

    def initialize(width: 800, height: 600)
      @width = width
      @height = height
      @initialized = false
    end

    def init
      return if @initialized

      # Placeholder for renderer initialization
      @initialized = true
    end

    def render
      raise 'Renderer not initialized' unless @initialized

      # Placeholder for render implementation
    end

    def cleanup
      return unless @initialized

      # Placeholder for cleanup implementation
      @initialized = false
    end

    class << self
      def create_renderer(window, map, textures)
        new(width: window.width, height: window.height)
      end
    end
  end
end
