# frozen_string_literal: true

require_relative 'base_renderer'

module Doom
  class OpenGLRenderer < BaseRenderer
    def initialize(window, map, textures)
      super
      @last_render_time = 0
      @last_texture_time = 0
    end

    def render(player)
      # TODO: Implement OpenGL rendering
      logger.info('OpenGL rendering not yet implemented')
    end

    attr_reader :last_render_time, :last_texture_time
  end
end
