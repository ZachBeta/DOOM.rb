# frozen_string_literal: true

require 'opengl'
require_relative '../logger'

# Load OpenGL
OpenGL.load_lib

module Doom
  module Renderer
    class TextureManager
      include OpenGL

      attr_reader :textures

      def initialize
        @logger = Logger.instance
        @textures = {}
      end

      def load_texture(name, width, height, data, format = OpenGL::GL_RGB)
        @logger.info("TextureManager: Loading texture '#{name}' (#{width}x#{height})")

        # Generate texture
        texture_id_buf = ' ' * 4
        OpenGL.glGenTextures(1, texture_id_buf)
        texture_id = texture_id_buf.unpack1('L')
        OpenGL.glBindTexture(OpenGL::GL_TEXTURE_2D, texture_id)

        # Set texture parameters
        OpenGL.glTexParameteri(OpenGL::GL_TEXTURE_2D, OpenGL::GL_TEXTURE_WRAP_S, OpenGL::GL_REPEAT)
        OpenGL.glTexParameteri(OpenGL::GL_TEXTURE_2D, OpenGL::GL_TEXTURE_WRAP_T, OpenGL::GL_REPEAT)
        OpenGL.glTexParameteri(OpenGL::GL_TEXTURE_2D, OpenGL::GL_TEXTURE_MIN_FILTER,
                               OpenGL::GL_LINEAR_MIPMAP_LINEAR)
        OpenGL.glTexParameteri(OpenGL::GL_TEXTURE_2D, OpenGL::GL_TEXTURE_MAG_FILTER,
                               OpenGL::GL_LINEAR)

        # Upload texture data
        OpenGL.glTexImage2D(
          OpenGL::GL_TEXTURE_2D,
          0,
          format,
          width,
          height,
          0,
          format,
          OpenGL::GL_UNSIGNED_BYTE,
          data
        )

        # Generate mipmaps
        OpenGL.glGenerateMipmap(OpenGL::GL_TEXTURE_2D)

        # Store texture
        @textures[name] = {
          id: texture_id,
          width: width,
          height: height,
          format: format
        }

        @logger.info("TextureManager: Texture '#{name}' loaded successfully")
        texture_id
      end

      def create_color_texture(name, color)
        @logger.info("TextureManager: Creating color texture '#{name}'")

        # Create a 1x1 texture with the specified color
        width = 1
        height = 1
        data = color.pack('C*')

        load_texture(name, width, height, data, OpenGL::GL_RGB)
      end

      def bind_texture(name, texture_unit = OpenGL::GL_TEXTURE0)
        texture = @textures[name]
        if texture
          OpenGL.glActiveTexture(texture_unit)
          OpenGL.glBindTexture(OpenGL::GL_TEXTURE_2D, texture[:id])
        else
          @logger.error("TextureManager: Texture '#{name}' not found")
          raise "Texture '#{name}' not found"
        end
      end

      def get_texture_id(name)
        texture = @textures[name]
        if texture
          texture[:id]
        else
          @logger.error("TextureManager: Texture '#{name}' not found")
          raise "Texture '#{name}' not found"
        end
      end

      def cleanup
        @logger.info('TextureManager: Cleaning up textures')

        # Delete all textures
        texture_ids = @textures.values.map { |texture| texture[:id] }
        unless texture_ids.empty?
          texture_ids_buf = texture_ids.pack('L*')
          OpenGL.glDeleteTextures(texture_ids.size, texture_ids_buf)
        end

        @textures.clear

        @logger.info('TextureManager: Textures cleaned up')
      end

      def create_default_textures
        @logger.info('TextureManager: Creating default textures')

        # Create a white texture (useful for color multiplication)
        create_color_texture('white', [255, 255, 255])

        # Create a black texture
        create_color_texture('black', [0, 0, 0])

        # Create a red texture
        create_color_texture('red', [255, 0, 0])

        # Create a green texture
        create_color_texture('green', [0, 255, 0])

        # Create a blue texture
        create_color_texture('blue', [0, 0, 255])

        @logger.info('TextureManager: Default textures created')
      end
    end
  end
end
