# frozen_string_literal: true

require 'gosu'

module Doom
  class ScreenBuffer
    def initialize(viewport)
      @viewport = viewport
      @front_buffer = create_buffer
      @back_buffer = create_buffer
      @palette = create_default_palette
      @logger = Logger.instance
      @logger.info("Screen buffer initialized with size #{@viewport.scaled_width}x#{@viewport.scaled_height}")
    end

    def clear
      @back_buffer.fill(0)
      @logger.debug('Back buffer cleared')
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
      @logger.debug('Buffer flipped')
    end

    def render_to_window(window)
      return if ENV['RACK_ENV'] == 'test'

      start_time = Time.now
      @viewport.scaled_width.times do |x|
        @viewport.scaled_height.times do |y|
          color_index = @front_buffer[x + (y * @viewport.scaled_width)]
          color = get_color(color_index)
          window.draw_quad(
            x, y, color,
            x + 1, y, color,
            x + 1, y + 1, color,
            x, y + 1, color
          )
        end
      end
      render_time = Time.now - start_time
      @logger.debug("Buffer rendered to window in #{(render_time * 1000).round(2)}ms")
    end

    private

    def create_buffer
      Array.new(@viewport.scaled_width * @viewport.scaled_height, 0)
    end

    def create_default_palette
      # Create a grayscale palette for now
      Array.new(256) do |i|
        # Map 0-255 to 0-255 for grayscale
        intensity = i
        Gosu::Color.rgb(intensity, intensity, intensity)
      end
    end

    def get_color(color_index)
      @palette[color_index] || Gosu::Color::BLACK
    end
  end
end
