# frozen_string_literal: true

require 'matrix'
require_relative '../logger'

module Doom
  module Renderer
    class WallRenderer
      include OpenGL

      def initialize(width, height, shader_manager, texture_manager, geometry_manager)
        @logger = Logger.instance
        @logger.info('WallRenderer: Initializing')

        @width = width
        @height = height
        @shader_manager = shader_manager
        @texture_manager = texture_manager
        @geometry_manager = geometry_manager

        # Create wall geometries
        create_wall_geometries

        @logger.info('WallRenderer: Initialization complete')
      end

      def render(rays, projection_matrix, view_matrix)
        @logger.debug('WallRenderer: Rendering walls')

        # Use the wall shader program
        @shader_manager.use_program('wall')

        # Set projection and view matrices
        @shader_manager.set_uniform_matrix4('wall', 'projection', projection_matrix)
        @shader_manager.set_uniform_matrix4('wall', 'view', view_matrix)

        # Bind wall texture
        @texture_manager.bind_texture('wall')
        @shader_manager.set_uniform_int('wall', 'textureSampler', 0)

        # Render each wall strip
        rays.each_with_index do |ray, x|
          # Calculate wall height
          wall_height = (@height / ray[:perp_wall_dist]).to_i
          wall_height = @height if wall_height > @height # Clamp wall height

          # Calculate wall strip position
          wall_y = (@height - wall_height) / 2

          # Set model matrix for this wall strip
          model_matrix = Matrix[
            [1.0, 0.0, 0.0, x.to_f],
            [0.0, wall_height.to_f, 0.0, wall_y.to_f],
            [0.0, 0.0, 1.0, 0.0],
            [0.0, 0.0, 0.0, 1.0]
          ]

          @shader_manager.set_uniform_matrix4('wall', 'model', model_matrix)

          # Draw wall strip
          @geometry_manager.draw_geometry('wall_strip')
        end

        @logger.debug('WallRenderer: Walls rendered')
      end

      private

      def create_wall_geometries
        @logger.info('WallRenderer: Creating wall geometries')

        # Create a single vertical strip for wall rendering
        vertices = [
          # Position (x, y, z)     Texture coordinates (u, v)
          0.0, 0.0, 0.0,          0.0, 1.0,  # Bottom-left
          1.0, 0.0, 0.0,          1.0, 1.0,  # Bottom-right
          1.0, 1.0, 0.0,          1.0, 0.0,  # Top-right
          0.0, 1.0, 0.0,          0.0, 0.0   # Top-left
        ]

        indices = [
          0, 1, 2,  # First triangle
          2, 3, 0   # Second triangle
        ]

        @geometry_manager.create_geometry('wall_strip', vertices, indices)

        @logger.info('WallRenderer: Wall geometries created')
      end
    end
  end
end
