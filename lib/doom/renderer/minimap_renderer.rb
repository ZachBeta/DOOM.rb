# frozen_string_literal: true

require 'opengl'
require 'matrix'
require_relative '../logger'

# Load OpenGL
OpenGL.load_lib

module Doom
  module Renderer
    class MinimapRenderer
      include OpenGL

      MINIMAP_SIZE = 200
      MINIMAP_SCALE = 10.0

      def initialize(map, player, width, height, shader_manager, texture_manager, geometry_manager)
        @logger = Logger.instance
        @logger.info('MinimapRenderer: Initializing')

        @map = map
        @player = player
        @width = width
        @height = height
        @shader_manager = shader_manager
        @texture_manager = texture_manager
        @geometry_manager = geometry_manager

        # Calculate minimap position (top-right corner)
        @minimap_x = width - MINIMAP_SIZE - 10
        @minimap_y = 10

        # Create minimap geometries
        create_minimap_geometries

        @logger.info('MinimapRenderer: Initialization complete')
      end

      def render(rays, projection_matrix, view_matrix)
        @logger.debug('MinimapRenderer: Rendering minimap')

        # Use the basic color shader
        @shader_manager.use_program('basic_color')

        # Set projection and view matrices
        @shader_manager.set_uniform_matrix4('basic_color', 'projection', projection_matrix)
        @shader_manager.set_uniform_matrix4('basic_color', 'view', view_matrix)

        # Render minimap background
        render_minimap_background

        # Render walls on minimap
        render_minimap_walls

        # Render rays on minimap
        render_minimap_rays(rays)

        # Render player on minimap
        render_minimap_player

        @logger.debug('MinimapRenderer: Minimap rendered')
      end

      private

      def create_minimap_geometries
        @logger.info('MinimapRenderer: Creating minimap geometries')

        # Create minimap background quad
        vertices, indices = @geometry_manager.create_quad(MINIMAP_SIZE, MINIMAP_SIZE)
        @geometry_manager.create_geometry('minimap_background', vertices, indices)

        # Create minimap wall quad (will be positioned for each wall)
        vertices, indices = @geometry_manager.create_quad(1.0, 1.0)
        @geometry_manager.create_geometry('minimap_wall', vertices, indices)

        # Create minimap player quad
        player_size = 4
        vertices, indices = @geometry_manager.create_quad(player_size, player_size)
        @geometry_manager.create_geometry('minimap_player', vertices, indices)

        # Create minimap ray quad (will be positioned for each ray)
        vertices, indices = @geometry_manager.create_quad(1.0, 1.0)
        @geometry_manager.create_geometry('minimap_ray', vertices, indices)

        @logger.info('MinimapRenderer: Minimap geometries created')
      end

      def render_minimap_background
        # Set model matrix for minimap background
        model_matrix = Matrix.identity(4)
        @shader_manager.set_uniform_matrix4('basic_color', 'model', model_matrix)

        # Set background color (dark gray)
        @shader_manager.set_uniform_vec4('basic_color', 'color', [0.2, 0.2, 0.2, 0.7])

        # Draw minimap background
        @geometry_manager.draw_geometry('minimap_background')
      end

      def render_minimap_walls
        # Get map dimensions
        map_width = @map.width
        map_height = @map.height

        # Calculate cell size on minimap
        cell_size = MINIMAP_SIZE / [map_width, map_height].max / MINIMAP_SCALE

        # Render each wall cell
        map_height.times do |y|
          map_width.times do |x|
            next unless @map.wall_at?(x, y)

            # Calculate wall position on minimap
            wall_x = @minimap_x + (x * cell_size)
            wall_y = @minimap_y + (y * cell_size)

            # Set model matrix for this wall
            model_matrix = Matrix[
              [cell_size, 0.0, 0.0, wall_x],
              [0.0, cell_size, 0.0, wall_y],
              [0.0, 0.0, 1.0, 0.0],
              [0.0, 0.0, 0.0, 1.0]
            ]

            @shader_manager.set_uniform_matrix4('basic_color', 'model', model_matrix)

            # Set wall color (white)
            @shader_manager.set_uniform_vec4('basic_color', 'color', [1.0, 1.0, 1.0, 1.0])

            # Draw wall
            @geometry_manager.draw_geometry('minimap_wall')
          end
        end
      end

      def render_minimap_rays(rays)
        # Calculate player position on minimap
        player_x = @minimap_x + (@player.position[0] * MINIMAP_SIZE / @map.width / MINIMAP_SCALE)
        player_y = @minimap_y + (@player.position[1] * MINIMAP_SIZE / @map.height / MINIMAP_SCALE)

        # Render each ray
        rays.each do |ray|
          # Calculate ray end position
          ray_end_x = player_x + (ray[:ray_dir_x] * ray[:perp_wall_dist] * MINIMAP_SIZE / @map.width)
          ray_end_y = player_y + (ray[:ray_dir_y] * ray[:perp_wall_dist] * MINIMAP_SIZE / @map.height)

          # Calculate ray length and angle
          ray_length = Math.sqrt(((ray_end_x - player_x)**2) + ((ray_end_y - player_y)**2))
          ray_angle = Math.atan2(ray_end_y - player_y, ray_end_x - player_x)

          # Set model matrix for this ray
          model_matrix = Matrix[
            [ray_length, 0.0, 0.0, player_x],
            [0.0, 1.0, 0.0, player_y],
            [0.0, 0.0, 1.0, 0.0],
            [0.0, 0.0, 0.0, 1.0]
          ]

          # Apply rotation
          rotation = Matrix[
            [Math.cos(ray_angle), -Math.sin(ray_angle), 0.0, 0.0],
            [Math.sin(ray_angle), Math.cos(ray_angle), 0.0, 0.0],
            [0.0, 0.0, 1.0, 0.0],
            [0.0, 0.0, 0.0, 1.0]
          ]

          model_matrix = rotation * model_matrix

          @shader_manager.set_uniform_matrix4('basic_color', 'model', model_matrix)

          # Set ray color (yellow)
          @shader_manager.set_uniform_vec4('basic_color', 'color', [1.0, 1.0, 0.0, 0.5])

          # Draw ray
          @geometry_manager.draw_geometry('minimap_ray')
        end
      end

      def render_minimap_player
        # Calculate player position on minimap
        player_x = @minimap_x + (@player.position[0] * MINIMAP_SIZE / @map.width / MINIMAP_SCALE)
        player_y = @minimap_y + (@player.position[1] * MINIMAP_SIZE / @map.height / MINIMAP_SCALE)

        # Set model matrix for player
        model_matrix = Matrix[
          [1.0, 0.0, 0.0, player_x - 2],
          [0.0, 1.0, 0.0, player_y - 2],
          [0.0, 0.0, 1.0, 0.0],
          [0.0, 0.0, 0.0, 1.0]
        ]

        @shader_manager.set_uniform_matrix4('basic_color', 'model', model_matrix)

        # Set player color (green)
        @shader_manager.set_uniform_vec4('basic_color', 'color', [0.0, 1.0, 0.0, 1.0])

        # Draw player
        @geometry_manager.draw_geometry('minimap_player')
      end
    end
  end
end
