# frozen_string_literal: true

require_relative 'base_renderer'
require_relative 'screen_buffer'
require 'matrix'
require 'opengl'

module Doom
  class OpenGLRenderer < BaseRenderer
    def initialize(window, map, textures)
      super
      @last_render_time = 0
      @last_texture_time = 0
      @ray_caster = RayCaster.new(map, nil) # Will be set in render
      @viewport = Viewport.new
      @screen_buffer = ScreenBuffer.new(@viewport)
      @metrics = {
        ray_casting_time: 0,
        wall_drawing_time: 0,
        buffer_flip_time: 0,
        total_rays: 0,
        frame_count: 0
      }
      @logger.info("OpenGL renderer initialized with viewport: #{@viewport.width}x#{@viewport.height}")
    end

    def cleanup
      @screen_buffer.cleanup
    end

    def render(player)
      frame_start = Time.now
      @ray_caster.player = player

      # Setup OpenGL state
      glEnable(GL_TEXTURE_2D)
      glEnable(GL_BLEND)
      glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA)
      glClearColor(0.0, 0.0, 0.0, 1.0)

      # Clear the screen
      @screen_buffer.clear

      # Cast rays and draw walls
      ray_angle_step = @ray_caster.fov / @ray_caster.num_rays
      start_angle = player.angle - (@ray_caster.fov / 2)

      @metrics[:total_rays] = @ray_caster.num_rays
      @metrics[:frame_count] += 1

      ray_casting_start = Time.now
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
      @metrics[:ray_casting_time] = Time.now - ray_casting_start

      # Flip the buffer
      flip_start = Time.now
      @screen_buffer.flip
      @metrics[:buffer_flip_time] = Time.now - flip_start

      # Draw the buffer to the screen
      render_to_window

      @last_render_time = Time.now - frame_start
      log_frame_metrics
    end

    attr_reader :last_render_time, :last_texture_time, :metrics

    private

    def render_to_window
      @screen_buffer.render_to_window
    end

    def log_frame_metrics
      return unless @metrics[:frame_count] % 60 == 0

      fps = 1.0 / @last_render_time
      @logger.info("Frame metrics: fps=#{fps.round(1)}, total_time=#{(@last_render_time * 1000).round(2)}ms, " \
                   "ray_casting=#{(@metrics[:ray_casting_time] * 1000).round(2)}ms, " \
                   "buffer_flip=#{(@metrics[:buffer_flip_time] * 1000).round(2)}ms, " \
                   "texture_time=#{(@last_texture_time * 1000).round(2)}ms, " \
                   "total_rays=#{@metrics[:total_rays]}, " \
                   "player_angle=#{@ray_caster.player.angle.round(2)}")
    end
  end
end
