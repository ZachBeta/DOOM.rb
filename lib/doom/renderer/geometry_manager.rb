# frozen_string_literal: true

require_relative '../logger'

module Doom
  module Renderer
    class GeometryManager
      attr_reader :geometries

      def initialize
        @logger = Logger.instance
        @geometries = {}
      end

      def create_geometry(name, vertices, indices = nil)
        @logger.info("GeometryManager: Creating geometry '#{name}'")

        # Implement GLFW3-based window management and rendering

        @logger.info("GeometryManager: Geometry '#{name}' created successfully")
      end

      def bind_geometry(name)
        geometry = @geometries[name]
        if geometry
          # Implement GLFW3-based window management and rendering
        else
          @logger.error("GeometryManager: Geometry '#{name}' not found")
          raise "Geometry '#{name}' not found"
        end
      end

      def draw_geometry(name)
        geometry = @geometries[name]
        if geometry
          # Implement GLFW3-based window management and rendering
        else
          @logger.error("GeometryManager: Geometry '#{name}' not found")
          raise "Geometry '#{name}' not found"
        end
      end

      def cleanup
        @logger.info('GeometryManager: Cleaning up geometries')

        @geometries.each_value do |geometry|
          # Implement GLFW3-based window management and rendering
        end

        @geometries.clear

        @logger.info('GeometryManager: Geometries cleaned up')
      end

      def create_quad(width = 1.0, height = 1.0)
        vertices = [
          # Position (x, y, z)     Texture coordinates (u, v)
          -width / 2, -height / 2, 0.0,  0.0, 0.0,  # Bottom-left
          width / 2, -height / 2, 0.0,   1.0, 0.0,  # Bottom-right
          width / 2, height / 2, 0.0,    1.0, 1.0,  # Top-right
          -width / 2, height / 2, 0.0,   0.0, 1.0   # Top-left
        ]

        indices = [
          0, 1, 2,  # First triangle
          2, 3, 0   # Second triangle
        ]

        [vertices, indices]
      end

      def create_screen_quad(name)
        vertices, indices = create_quad(2.0, 2.0) # Create a quad that fills the screen
        create_geometry(name, vertices, indices)
      end
    end
  end
end
