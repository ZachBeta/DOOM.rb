# frozen_string_literal: true

require_relative 'renderer/core/base_renderer'
require_relative 'renderer/core/opengl_renderer'
require_relative 'renderer/components/viewport'
require_relative 'renderer/components/screen_buffer'
require_relative 'renderer/components/ray_caster'
require_relative 'renderer/components/ray'
require_relative 'renderer/components/wall_intersection'
require_relative 'renderer/components/wall_renderer'
require_relative 'renderer/utils/texture'
require_relative 'renderer/utils/texture_composer'

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
