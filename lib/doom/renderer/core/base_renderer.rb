# frozen_string_literal: true

module Doom
  module Renderer
    module Core
      # Base renderer class that defines the interface
      class BaseRenderer
        def initialize(window, map, textures)
          @window = window
          @map = map
          @textures = textures
          @logger = Logger.instance
        end

        def render(player)
          raise NotImplementedError, "#{self.class} must implement render(player)"
        end

        private

        attr_reader :window, :map, :textures, :logger
      end
    end
  end
end
