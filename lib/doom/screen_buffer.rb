# frozen_string_literal: true

require 'gosu'

module Doom
  class ScreenBuffer
    def initialize(viewport)
      @viewport = viewport
      @front_buffer = create_buffer
      @back_buffer = create_buffer
      @palette = create_default_palette
    end

    def clear
      @back_buffer.fill(0)
    end

    def draw_pixel(x, y, color_index)
      return if x < 0 || x >= @viewport.scaled_width || y < 0 || y >= @viewport.scaled_height

      @back_buffer[x + (y * @viewport.scaled_width)] = color_index
    end

    def draw_vertical_line(x, y1, y2, color_index)
      return if x < 0 || x >= @viewport.scaled_width

      y1 = [y1, 0].max
      y2 = [y2, @viewport.scaled_height - 1].min
      return if y1 > y2 || y1 < 0 || y2 >= @viewport.scaled_height

      y1.upto(y2) do |y|
        @back_buffer[x + (y * @viewport.scaled_width)] = color_index
      end
    end

    def flip
      @front_buffer, @back_buffer = @back_buffer, @front_buffer
    end

    def render_to_window(window)
      @viewport.scaled_width.times do |x|
        @viewport.scaled_height.times do |y|
          color_index = @front_buffer[x + (y * @viewport.scaled_width)]
          color = @palette[color_index]
          window.draw_quad(
            x, y, color,
            x + 1, y, color,
            x + 1, y + 1, color,
            x, y + 1, color
          )
        end
      end
    end

    private

    def create_buffer
      Array.new(@viewport.scaled_width * @viewport.scaled_height, 0)
    end

    def create_default_palette
      # TODO: Load actual DOOM palette
      Array.new(256) { Gosu::Color.new(0, 0, 0) }
    end
  end
end
