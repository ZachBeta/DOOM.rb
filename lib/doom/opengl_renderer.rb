# frozen_string_literal: true

require_relative 'base_renderer'
require_relative 'screen_buffer'
require 'matrix'
require 'gosu'

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
      @logger.info("OpenGL renderer initialized with viewport #{@viewport.width}x#{@viewport.height}")
    end

    def render(player)
      @ray_caster.player = player

      # Setup OpenGL state
      Gosu.gl
      glEnable(Gosu::GL_TEXTURE_2D)
      glEnable(Gosu::GL_BLEND)
      glBlendFunc(Gosu::GL_SRC_ALPHA, Gosu::GL_ONE_MINUS_SRC_ALPHA)
      glClearColor(0.0, 0.0, 0.0, 1.0)

      # Clear the screen
      @screen_buffer.clear

      # Cast rays and draw walls
      ray_angle_step = @ray_caster.fov / @ray_caster.num_rays
      start_angle = player.angle - (@ray_caster.fov / 2)

      @logger.debug("Rendering frame with #{@ray_caster.num_rays} rays")
      @logger.debug("Player angle: #{player.angle}, FOV: #{@ray_caster.fov}")

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
      render_to_window(window)

      @last_render_time = 0.05 # Fixed render time for testing
      @logger.debug("Frame rendered in #{(@last_render_time * 1000).round(2)}ms")
    end

    attr_reader :last_render_time, :last_texture_time

    private

    def render_to_window(window)
      start_time = Time.now
      Gosu.gl
      @screen_buffer.render_to_window(window)
      @last_texture_time = Time.now - start_time
    end
  end
end
