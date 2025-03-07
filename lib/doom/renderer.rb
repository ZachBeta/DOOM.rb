# frozen_string_literal: true

require_relative 'ray'
require_relative 'wall_intersection'
require_relative 'ray_caster'
require_relative 'wall_renderer'
require_relative 'minimap_renderer'
require_relative 'opengl_renderer'

module Doom
  # Main renderer module that coordinates all rendering components
  class Renderer < OpenGLRenderer
  end
end
