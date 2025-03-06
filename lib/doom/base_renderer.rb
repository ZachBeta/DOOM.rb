module Doom
  class BaseRenderer
    attr_reader :last_render_time, :wall_render_time, :minimap_render_time

    def initialize(window, map, textures = {})
      @window = window
      @map = map
      @width = window.width
      @height = window.height
      @last_render_time = 0
      @wall_render_time = 0
      @minimap_render_time = 0
      @logger = Logger.instance
    end

    def render(player)
      raise NotImplementedError, "#{self.class} must implement render"
    end

    protected

    def render_minimap(player)
      scale = 10
      margin = 10

      x_offset = @window.width - (@map.width * scale) - margin
      y_offset = @window.height - (@map.height * scale) - margin

      # Draw map cells
      @map.height.times do |y|
        @map.width.times do |x|
          next if @map.empty?(x, y)

          @window.draw_quad(
            x_offset + (x * scale), y_offset + (y * scale), Gosu::Color::WHITE,
            x_offset + ((x + 1) * scale), y_offset + (y * scale), Gosu::Color::WHITE,
            x_offset + (x * scale), y_offset + ((y + 1) * scale), Gosu::Color::WHITE,
            x_offset + ((x + 1) * scale), y_offset + ((y + 1) * scale), Gosu::Color::WHITE,
            1
          )
        end
      end

      # Draw player position
      px = x_offset + (player.position[0] * scale)
      py = y_offset + (player.position[1] * scale)

      @window.draw_triangle(
        px, py, Gosu::Color::RED,
        px + (Math.cos(player.angle) * scale), py + (Math.sin(player.angle) * scale), Gosu::Color::RED,
        px + (Math.cos(player.angle + (Math::PI * 0.8)) * scale * 0.5),
        py + (Math.sin(player.angle + (Math::PI * 0.8)) * scale * 0.5),
        Gosu::Color::RED,
        2
      )
    end
  end
end
