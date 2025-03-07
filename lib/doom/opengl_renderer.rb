# frozen_string_literal: true

require_relative 'base_renderer'
require_relative 'screen_buffer'
require 'matrix'

module Doom
  class OpenGLRenderer < BaseRenderer
    def initialize(window, map, textures)
      super
      @last_render_time = 0
      @last_texture_time = 0
      @ray_caster = RayCaster.new(map, nil) # Will be set in render
      @viewport = Viewport.new
      @viewport.scale = 2
      @screen_buffer = ScreenBuffer.new(@viewport)
    end

    def render(player)
      start_time = Time.now
      @ray_caster.player = player

      # Clear the screen
      @screen_buffer.clear

      # Cast rays and draw walls
      ray_angle_step = @ray_caster.fov / @ray_caster.num_rays
      start_angle = player.angle - (@ray_caster.fov / 2)

      @ray_caster.num_rays.times do |x|
        angle = start_angle + (x * ray_angle_step)
        intersection = @ray_caster.cast_ray(angle)

        # Calculate wall height
        distance = @ray_caster.apply_perspective_correction(intersection.distance, angle)
        wall_height = @ray_caster.calculate_wall_height(distance)

        # Calculate wall top and bottom
        wall_top = (@viewport.height - wall_height) / 2
        wall_bottom = wall_top + wall_height

        # Draw vertical line
        @screen_buffer.draw_vertical_line(x, wall_top, wall_bottom, 1)
      end

      # Flip the buffer
      @screen_buffer.flip

      # Draw the buffer to the screen
      draw_buffer

      @last_render_time = Time.now - start_time
    end

    attr_reader :last_render_time, :last_texture_time

    private

    def setup_gl
      # Initialize OpenGL state
      glEnable(GL_TEXTURE_2D)
      glEnable(GL_BLEND)
      glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA)
      glClearColor(0.0, 0.0, 0.0, 1.0)
    end

    def draw_buffer
      # Draw the screen buffer to the window using batch drawing
      buffer = @screen_buffer.instance_variable_get(:@front_buffer)
      width = @viewport.width
      height = @viewport.height

      # Draw each vertical line at once
      width.times do |x|
        # Find the top and bottom of the wall in this column
        top = height
        bottom = 0
        height.times do |y|
          if buffer[(y * width) + x] == 1
            top = [top, y].min
            bottom = [bottom, y].max
          end
        end

        # Draw the wall segment if it exists
        window.draw_rect(x, top, 1, bottom - top + 1, Gosu::Color::WHITE) if bottom > top
      end
    end
  end
end
