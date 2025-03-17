# frozen_string_literal: true

require 'gosu'

module Doom
  module Texture
    class BitmapTexture
      # WAD texture dimensions are typically powers of 2
      DEFAULT_SIZE = 128

      attr_reader :width, :height, :name, :gosu_image

      def initialize(name, width = DEFAULT_SIZE, height = DEFAULT_SIZE)
        @name = name
        @width = width
        @height = height
        @gosu_image = nil
      end

      # Create a checkerboard pattern texture
      def self.create_checkerboard(name, checker_size = 16, color1 = Gosu::Color::WHITE, color2 = Gosu::Color::GRAY)
        texture = new(name)
        texture.instance_variable_set(:@gosu_image, Gosu.render(texture.width, texture.height) do
          (0...texture.height).each do |y|
            (0...texture.width).each do |x|
              is_checker = ((x / checker_size) + (y / checker_size)).even?
              color = is_checker ? color1 : color2
              Gosu.draw_rect(x, y, 1, 1, color)
            end
          end
        end)
        texture
      end

      # Create a brick pattern texture
      def self.create_brick(name, brick_width = 64, brick_height = 32, mortar_size = 4)
        texture = new(name)
        texture.instance_variable_set(:@gosu_image, Gosu.render(texture.width, texture.height) do
          (0...texture.height).each do |y|
            (0...texture.width).each do |x|
              # Add noise for variation
              noise = (((x * 7) + (y * 17)) % 20) / 100.0

              # Determine if we're drawing mortar or brick
              is_mortar_h = (y % brick_height < mortar_size)
              is_mortar_v = (x % brick_width < mortar_size)
              is_mortar = is_mortar_h || is_mortar_v

              if is_mortar
                # Mortar color with slight variation
                gray = 180 + (noise * 30).to_i
                color = Gosu::Color.new(255, gray, gray, gray)
              else
                # Brick color with variation
                red = 200 + (noise * 55).to_i
                color = Gosu::Color.new(255, red, 100 + (noise * 20).to_i, 80 + (noise * 20).to_i)
              end
              Gosu.draw_rect(x, y, 1, 1, color)
            end
          end
        end)
        texture
      end

      # Create a grid pattern texture
      def self.create_grid(name, grid_size = 16, line_thickness = 2)
        texture = new(name)
        texture.instance_variable_set(:@gosu_image, Gosu.render(texture.width, texture.height) do
          (0...texture.height).each do |y|
            (0...texture.width).each do |x|
              dist_to_line_h = (y % grid_size).abs
              dist_to_line_v = (x % grid_size).abs
              dist_to_line = [dist_to_line_h, dist_to_line_v].min

              # Create a smooth gradient for the grid lines
              intensity = [1.0 - (dist_to_line / line_thickness.to_f), 0.0].max
              color = if intensity.positive?
                        Gosu::Color.new(255,
                                        (255 * intensity) + (40 * (1 - intensity)),
                                        (255 * intensity) + (40 * (1 - intensity)),
                                        (255 * intensity) + (100 * (1 - intensity)))
                      else
                        Gosu::Color.new(255, 40, 40, 100)
                      end
              Gosu.draw_rect(x, y, 1, 1, color)
            end
          end
        end)
        texture
      end

      # Draw a portion of the texture
      def draw_sub(x, y, z, sub_x, sub_y, sub_width, sub_height, scale_x = 1, scale_y = 1,
                   color = Gosu::Color::WHITE)
        @gosu_image&.subimage(sub_x, sub_y, sub_width, sub_height)&.draw(x, y, z, scale_x, scale_y,
                                                                         color)
      end

      # Draw the entire texture
      def draw(x, y, z, scale_x = 1, scale_y = 1, color = Gosu::Color::WHITE)
        @gosu_image&.draw(x, y, z, scale_x, scale_y, color)
      end

      # Get color at specific coordinates
      def get_pixel(x, y)
        return nil unless @gosu_image

        @gosu_image.get_pixel(x % width, y % height)
      end
    end
  end
end
