# frozen_string_literal: true

require_relative 'ray'
require_relative 'wall_intersection'
require_relative 'ray_caster'
require_relative 'wall_renderer'
require_relative 'minimap_renderer'
require_relative 'base_renderer'
require_relative 'opengl_renderer'

module Doom
  # Alias for BaseRenderer for backward compatibility
  Renderer = BaseRenderer
end
