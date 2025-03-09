# frozen_string_literal: true

require 'opengl'
require_relative '../logger'

# Load OpenGL
OpenGL.load_lib

module Doom
  module Renderer
    class GeometryManager
      include OpenGL

      attr_reader :geometries

      def initialize
        @logger = Logger.instance
        @geometries = {}
      end

      def create_geometry(name, vertices, indices = nil)
        @logger.info("GeometryManager: Creating geometry '#{name}'")

        # Generate VAO
        vao_buf = ' ' * 4
        OpenGL.glGenVertexArrays(1, vao_buf)
        vao = vao_buf.unpack1('L')
        OpenGL.glBindVertexArray(vao)

        # Generate VBO
        vbo_buf = ' ' * 4
        OpenGL.glGenBuffers(1, vbo_buf)
        vbo = vbo_buf.unpack1('L')
        OpenGL.glBindBuffer(OpenGL::GL_ARRAY_BUFFER, vbo)

        # Upload vertex data
        vertex_data = vertices.flatten.pack('f*')
        vertex_size = vertex_data.size
        OpenGL.glBufferData(OpenGL::GL_ARRAY_BUFFER, vertex_size, vertex_data,
                            OpenGL::GL_STATIC_DRAW)

        # Set up vertex attributes
        stride = 5 * 4 # 3 for position + 2 for texture coordinates, each 4 bytes
        OpenGL.glVertexAttribPointer(0, 3, OpenGL::GL_FLOAT, OpenGL::GL_FALSE, stride, 0)
        OpenGL.glEnableVertexAttribArray(0)
        OpenGL.glVertexAttribPointer(1, 2, OpenGL::GL_FLOAT, OpenGL::GL_FALSE, stride, 3 * 4)
        OpenGL.glEnableVertexAttribArray(1)

        # If indices are provided, create and bind EBO
        if indices
          ebo_buf = ' ' * 4
          OpenGL.glGenBuffers(1, ebo_buf)
          ebo = ebo_buf.unpack1('L')
          OpenGL.glBindBuffer(OpenGL::GL_ELEMENT_ARRAY_BUFFER, ebo)
          index_data = indices.pack('L*')
          index_size = index_data.size
          OpenGL.glBufferData(OpenGL::GL_ELEMENT_ARRAY_BUFFER, index_size, index_data,
                              OpenGL::GL_STATIC_DRAW)
        end

        # Store geometry information
        @geometries[name] = {
          vao: vao,
          vbo: vbo,
          ebo: indices ? ebo : nil,
          vertex_count: indices ? indices.size : vertices.size,
          has_indices: !indices.nil?
        }

        @logger.info("GeometryManager: Geometry '#{name}' created successfully")
      end

      def bind_geometry(name)
        geometry = @geometries[name]
        if geometry
          OpenGL.glBindVertexArray(geometry[:vao])
        else
          @logger.error("GeometryManager: Geometry '#{name}' not found")
          raise "Geometry '#{name}' not found"
        end
      end

      def draw_geometry(name)
        geometry = @geometries[name]
        if geometry
          OpenGL.glBindVertexArray(geometry[:vao])
          if geometry[:has_indices]
            OpenGL.glDrawElements(OpenGL::GL_TRIANGLES, geometry[:vertex_count],
                                  OpenGL::GL_UNSIGNED_INT, 0)
          else
            OpenGL.glDrawArrays(OpenGL::GL_TRIANGLES, 0, geometry[:vertex_count])
          end
        else
          @logger.error("GeometryManager: Geometry '#{name}' not found")
          raise "Geometry '#{name}' not found"
        end
      end

      def cleanup
        @logger.info('GeometryManager: Cleaning up geometries')

        @geometries.each_value do |geometry|
          buffers = [geometry[:vbo]]
          buffers << geometry[:ebo] if geometry[:ebo]
          OpenGL.glDeleteBuffers(buffers.size, buffers.pack('L*'))

          vao_buf = [geometry[:vao]].pack('L*')
          OpenGL.glDeleteVertexArrays(1, vao_buf)
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
