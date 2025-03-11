# frozen_string_literal: true

require_relative '../logger'

module Doom
  module Renderer
    class TextureManager
      def initialize
        @logger = Logger.instance
        @logger.info('TextureManager: Initializing')
        @textures = {}
        @logger.info('TextureManager: Initialization complete')
      end

      def load_texture(name, width, height, data)
        @logger.info("TextureManager: Loading texture #{name}")
        @textures[name] = {
          width: width,
          height: height,
          data: data.dup # Store raw RGBA pixel data
        }
        @logger.info("TextureManager: Texture #{name} loaded")
      end

      def get_texture(name)
        @textures[name]
      end

      def create_checkerboard_texture(width, height, size = 32)
        @logger.info('TextureManager: Creating checkerboard texture')
        data = []
        
        (0...height).each do |y|
          (0...width).each do |x|
            # Create a checkerboard pattern
            is_white = ((x / size).floor + (y / size).floor).even?
            color = is_white ? [255, 255, 255, 255] : [0, 0, 0, 255]
            data.concat(color)
          end
        end

        load_texture('checkerboard', width, height, data)
        @logger.info('TextureManager: Checkerboard texture created')
      end

      def cleanup
        @logger.info('TextureManager: Cleaning up')
        @textures.clear
        @logger.info('TextureManager: Cleanup complete')
      end
    end
  end
end
