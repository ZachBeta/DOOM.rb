# frozen_string_literal: true

require_relative 'ray'
require_relative 'wall_intersection'
require_relative 'ray_caster'
require_relative 'wall_renderer'
require_relative 'minimap_renderer'
require_relative 'opengl_renderer'

module Doom
  # Main renderer module that coordinates all rendering components
  class Renderer
    def initialize(window, map, textures)
      @window = window
      @map = map
      @textures = textures
      @logger = Logger.new(STDOUT)
    end

    def render(player)
      raise NotImplementedError, "#{self.class} must implement render(player)"
    end

    private

    attr_reader :window, :map, :textures, :logger
  end
end
