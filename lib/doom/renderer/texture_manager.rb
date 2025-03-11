# frozen_string_literal: true

require_relative '../logger'

module Doom
  module Renderer
    class TextureManager
      attr_reader :textures

      def initialize
        @logger = Logger.instance
        @textures = {}
      end

      def load_texture(name, width, height, data, format = OpenGL::GL_RGB)
        @logger.info("TextureManager: Loading texture '#{name}' (#{width}x#{height})")

        # Implement GLFW3-based window management and rendering
        # ... existing code ...

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
          # Implement GLFW3-based window management and rendering
          # ... existing code ...
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

        # Implement GLFW3-based window management and rendering
        # ... existing code ...

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
