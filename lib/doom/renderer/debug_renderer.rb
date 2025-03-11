# frozen_string_literal: true

require 'matrix'
require_relative '../logger'

module Doom
  module Renderer
    class DebugRenderer
      include OpenGL

      def initialize(width, height, shader_manager, texture_manager, geometry_manager)
        @logger = Logger.instance
        @logger.info('DebugRenderer: Initializing')

        @width = width
        @height = height
        @shader_manager = shader_manager
        @texture_manager = texture_manager
        @geometry_manager = geometry_manager

        @fps = 0
        @frame_time = 0
        @last_update_time = Time.now
        @frame_count = 0

        # Create debug geometries
        create_debug_geometries

        @logger.info('DebugRenderer: Initialization complete')
      end

      def update
        # Update FPS counter
        current_time = Time.now
        elapsed = current_time - @last_update_time
        @frame_count += 1

        # Update FPS every second
        return unless elapsed >= 1.0

        @fps = @frame_count / elapsed
        @frame_time = elapsed / @frame_count * 1000.0 # in milliseconds
        @frame_count = 0
        @last_update_time = current_time

        @logger.debug("DebugRenderer: FPS: #{@fps.round(2)}, Frame time: #{@frame_time.round(2)}ms")
      end

      def render(player, projection_matrix, view_matrix)
        @logger.debug('DebugRenderer: Rendering debug info')

        # Use the basic color shader
        @shader_manager.use_program('basic_color')

        # Set projection and view matrices
        @shader_manager.set_uniform_matrix4('basic_color', 'projection', projection_matrix)
        @shader_manager.set_uniform_matrix4('basic_color', 'view', view_matrix)

        # Render FPS counter
        render_fps_counter

        # Render player position
        render_player_position(player)

        @logger.debug('DebugRenderer: Debug info rendered')
      end

      private

      def create_debug_geometries
        @logger.info('DebugRenderer: Creating debug geometries')

        # Create FPS counter background
        vertices, indices = @geometry_manager.create_quad(200, 20)
        @geometry_manager.create_geometry('fps_background', vertices, indices)

        # Create player position background
        vertices, indices = @geometry_manager.create_quad(200, 20)
        @geometry_manager.create_geometry('position_background', vertices, indices)

        @logger.info('DebugRenderer: Debug geometries created')
      end

      def render_fps_counter
        # Set model matrix for FPS counter
        model_matrix = Matrix.identity(4)
        @shader_manager.set_uniform_matrix4('basic_color', 'model', model_matrix)

        # Set background color (semi-transparent black)
        @shader_manager.set_uniform_vec4('basic_color', 'color', [0.0, 0.0, 0.0, 0.7])

        # Draw FPS counter background
        @geometry_manager.draw_geometry('fps_background')

        # TODO: Add text rendering for FPS value
        # For now, we'll just log it
        return unless @frame_count == 0

        @logger.info("FPS: #{@fps.round(2)}, Frame time: #{@frame_time.round(2)}ms")
      end

      def render_player_position(player)
        # Set model matrix for player position
        model_matrix = Matrix.identity(4)
        @shader_manager.set_uniform_matrix4('basic_color', 'model', model_matrix)

        # Set background color (semi-transparent black)
        @shader_manager.set_uniform_vec4('basic_color', 'color', [0.0, 0.0, 0.0, 0.7])

        # Draw player position background
        @geometry_manager.draw_geometry('position_background')

        # TODO: Add text rendering for player position
        # For now, we'll just log it
        return unless @frame_count == 0

        @logger.info("Player position: (#{player.position[0].round(2)}, #{player.position[1].round(2)})")
      end
    end
  end
end
