# frozen_string_literal: true

require 'doom/renderer/core/base_renderer'
require 'doom/renderer/core/opengl_renderer'
require 'doom/renderer/components/viewport'
require 'doom/renderer/components/screen_buffer'
require 'doom/renderer/components/ray_caster'
require 'doom/renderer/components/ray'
require 'doom/renderer/components/wall_intersection'
require 'doom/renderer/components/wall_renderer'
require 'doom/renderer/utils/texture'
require 'doom/renderer/utils/texture_composer'

module Doom
  module Renderer
    # Main entry point for the renderer module
    class << self
      def create_renderer(window, map, textures)
        OpenGLRenderer.new(window, map, textures)
      end
    end
  end
end
