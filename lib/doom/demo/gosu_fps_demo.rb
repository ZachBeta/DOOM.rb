# frozen_string_literal: true

require 'gosu'
require_relative '../texture/bitmap_texture'

module Doom
  module Demo
    class GosuFpsDemo < Gosu::Window
      SCREEN_WIDTH = 800
      SCREEN_HEIGHT = 600
      FOV = Math::PI / 3  # 60 degrees field of view
      RAY_COUNT = 320     # Doubled for smoother rendering
      TEXTURE_SIZE = 128  # Increased texture resolution

      def initialize
        super(SCREEN_WIDTH, SCREEN_HEIGHT)
        self.caption = 'DOOM.rb FPS Demo'

        @player_x = 8.0 # Start in the middle of the larger map
        @player_y = 8.0
        @player_angle = 0.0
        @move_speed = 0.05
        @rotation_speed = 0.05

        # Debug info
        @font = Gosu::Font.new(16)
        @fps_samples = []
        @last_fps_update = Gosu.milliseconds
        @current_fps = 0
        @debug_visible = true # Start with debug info visible

        # Create test textures
        create_test_textures

        # Precompute some values for performance
        @inv_texture_size = 1.0 / TEXTURE_SIZE

        # Simple map (1 represents walls, 0 represents empty space)
        @map = [
          [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1],
          [1, 0, 0, 0, 0, 0, 1, 0, 0, 1, 0, 0, 0, 0, 0, 1],
          [1, 0, 0, 0, 0, 0, 1, 0, 0, 1, 0, 0, 0, 0, 0, 1],
          [1, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 1],
          [1, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 1],
          [1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1],
          [1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1],
          [1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1],
          [1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1],
          [1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1],
          [1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1],
          [1, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 1],
          [1, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 1],
          [1, 0, 0, 0, 0, 0, 1, 0, 0, 1, 0, 0, 0, 0, 0, 1],
          [1, 0, 0, 0, 0, 0, 1, 0, 0, 1, 0, 0, 0, 0, 0, 1],
          [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1]
        ]
      end

      def create_test_textures
        @textures = []

        # Create checkerboard texture
        checkerboard = Texture::BitmapTexture.create_checkerboard('checkerboard')
        @textures << checkerboard.gosu_image

        # Create brick texture
        bricks = Texture::BitmapTexture.create_brick('bricks')
        @textures << bricks.gosu_image

        # Create grid texture
        grid = Texture::BitmapTexture.create_grid('grid')
        @textures << grid.gosu_image
      end

      def update
        handle_movement
        handle_rotation
        update_fps
      end

      def handle_movement
        # Forward/Backward movement
        if Gosu.button_down?(Gosu::KB_W)
          move_player(Math.cos(@player_angle), Math.sin(@player_angle))
        end
        if Gosu.button_down?(Gosu::KB_S)
          move_player(-Math.cos(@player_angle), -Math.sin(@player_angle))
        end

        # Strafe movement
        if Gosu.button_down?(Gosu::KB_A)
          # Move perpendicular to viewing angle (left)
          move_player(Math.cos(@player_angle - (Math::PI / 2)),
                      Math.sin(@player_angle - (Math::PI / 2)))
        end
        return unless Gosu.button_down?(Gosu::KB_D)

        # Move perpendicular to viewing angle (right)
        move_player(Math.cos(@player_angle + (Math::PI / 2)),
                    Math.sin(@player_angle + (Math::PI / 2)))
      end

      def handle_rotation
        # Rotation with arrow keys
        @player_angle -= @rotation_speed if Gosu.button_down?(Gosu::KB_LEFT)
        return unless Gosu.button_down?(Gosu::KB_RIGHT)

        @player_angle += @rotation_speed
      end

      def move_player(dx, dy)
        new_x = @player_x + (dx * @move_speed)
        new_y = @player_y + (dy * @move_speed)

        # Allow sliding along walls by checking x and y movement separately
        @player_x = new_x unless wall_at?(new_x.to_i, @player_y.to_i)
        return if wall_at?(@player_x.to_i, new_y.to_i)

        @player_y = new_y
      end

      def update_fps
        @fps_samples << Gosu.fps
        @fps_samples.shift if @fps_samples.size > 30 # Keep last 30 samples

        # Update FPS display every 500ms
        current_time = Gosu.milliseconds
        return unless current_time - @last_fps_update > 500

        @current_fps = @fps_samples.sum / @fps_samples.size.to_f
        @last_fps_update = current_time
      end

      def draw
        # Clear screen
        draw_rect(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT / 2, Gosu::Color::BLUE)
        draw_rect(0, SCREEN_HEIGHT / 2, SCREEN_WIDTH, SCREEN_HEIGHT / 2, Gosu::Color::GREEN)

        # Calculate strip width once
        strip_width = (SCREEN_WIDTH / RAY_COUNT.to_f).ceil

        # Cast rays and draw walls
        RAY_COUNT.times do |i|
          ray_angle = @player_angle - (FOV / 2) + (FOV * i / RAY_COUNT)

          # Ray casting
          distance, wall_x, is_vertical = cast_ray(ray_angle)

          # Fix fisheye effect
          fixed_distance = distance * Math.cos(@player_angle - ray_angle)

          # Calculate wall height
          wall_height = [(SCREEN_HEIGHT / fixed_distance) * 1.5, SCREEN_HEIGHT].min

          # Calculate strip position
          x = i * strip_width
          y = (SCREEN_HEIGHT - wall_height) / 2

          # Choose texture based on wall orientation
          texture = @textures[is_vertical ? 1 : 0]

          # Calculate texture coordinates with better precision
          tex_x = (wall_x * TEXTURE_SIZE).floor
          tex_x = (TEXTURE_SIZE - 1 - tex_x) if is_vertical # Flip texture for N/S walls
          tex_x = tex_x.clamp(0, TEXTURE_SIZE - 1) # Ensure we stay within texture bounds

          # Calculate shading with smoother falloff and distance correction
          shade = (1.0 / fixed_distance * 5.0).clamp(0.2, 1.0)
          shade = Math.sqrt(shade) # Smoother falloff

          # Add slight color variation based on distance and wall orientation
          color = Gosu::Color.new(
            255,
            (255 * shade).to_i,
            ((240 + (fixed_distance * 2).clamp(0, 15)) * shade).to_i,
            ((230 + (fixed_distance * 4).clamp(0, 25)) * shade).to_i
          )

          # Draw textured wall strip with improved scaling
          scale_x = strip_width
          scale_y = wall_height.to_f * @inv_texture_size

          # Draw the wall strip without gaps
          texture.subimage(tex_x, 0, 1, TEXTURE_SIZE).draw(
            x, y, 0,
            scale_x, scale_y,
            color
          )
        end

        # Draw minimap
        draw_minimap

        # Draw debug information
        draw_debug_info if @debug_visible
      end

      def draw_debug_info
        x = SCREEN_WIDTH - 200
        y = 10
        line_height = 20
        color = Gosu::Color::YELLOW

        debug_lines = [
          "FPS: #{@current_fps.round(1)}",
          "Pos: (#{@player_x.round(2)}, #{@player_y.round(2)})",
          "Angle: #{(@player_angle * 180 / Math::PI).round(1)}°",
          "Move Speed: #{@move_speed.round(3)}",
          "Turn Speed: #{(@rotation_speed * 180 / Math::PI).round(1)}°",
          "FOV: #{(FOV * 180 / Math::PI).round(1)}°",
          "Rays: #{RAY_COUNT}"
        ]

        # Draw semi-transparent background for better readability
        bg_padding = 5
        bg_height = (debug_lines.size * line_height) + (bg_padding * 2)
        bg_width = 190
        draw_rect(x - bg_padding, y - bg_padding,
                  bg_width, bg_height,
                  Gosu::Color.rgba(0, 0, 0, 180))

        debug_lines.each_with_index do |line, i|
          @font.draw_text(line, x, y + (i * line_height), 1, 1, 1, color)
        end
      end

      def cast_ray(angle)
        # Ray starting position
        ray_x = @player_x
        ray_y = @player_y

        # Ray direction vector
        ray_dx = Math.cos(angle)
        ray_dy = Math.sin(angle)

        # Calculate step sizes for DDA-like algorithm
        delta_dist_x = ray_dx.abs < 1e-10 ? 1e10 : (1.0 / ray_dx).abs
        delta_dist_y = ray_dy.abs < 1e-10 ? 1e10 : (1.0 / ray_dy).abs

        # Calculate initial step and side distance
        map_x = ray_x.floor
        map_y = ray_y.floor

        side_dist_x = if ray_dx.negative?
                        (ray_x - map_x) * delta_dist_x
                      else
                        (map_x + 1.0 - ray_x) * delta_dist_x
                      end

        side_dist_y = if ray_dy.negative?
                        (ray_y - map_y) * delta_dist_y
                      else
                        (map_y + 1.0 - ray_y) * delta_dist_y
                      end

        # Perform DDA
        step_x = ray_dx.negative? ? -1 : 1
        step_y = ray_dy.negative? ? -1 : 1
        hit = false
        is_vertical = false

        while !hit && (side_dist_x + side_dist_y) < 20
          # Jump to next map square in x or y direction
          if side_dist_x < side_dist_y
            side_dist_x += delta_dist_x
            map_x += step_x
            is_vertical = true
          else
            side_dist_y += delta_dist_y
            map_y += step_y
            is_vertical = false
          end

          # Check if ray has hit a wall
          hit = wall_at?(map_x, map_y)
        end

        return [20, 0, false] unless hit

        # Calculate exact hit position
        if is_vertical
          wall_x = ray_y + ((side_dist_x - delta_dist_x) * ray_dy)
          distance = (map_x - ray_x + ((1 - step_x) / 2)) / ray_dx
        else
          wall_x = ray_x + ((side_dist_y - delta_dist_y) * ray_dx)
          distance = (map_y - ray_y + ((1 - step_y) / 2)) / ray_dy
        end

        wall_x -= wall_x.floor

        [distance.abs, wall_x, is_vertical]
      end

      def wall_at?(x, y)
        return true if x.negative? || y.negative? || x >= @map[0].length || y >= @map.length

        @map[y][x] == 1
      end

      def draw_minimap
        scale = 20
        @map.each_with_index do |row, y|
          row.each_with_index do |cell, x|
            color = cell == 1 ? Gosu::Color::WHITE : Gosu::Color::BLACK
            draw_rect(x * scale, y * scale, scale - 1, scale - 1, color)
          end
        end

        # Draw player on minimap
        player_size = 4
        draw_rect(
          (@player_x * scale) - (player_size / 2),
          (@player_y * scale) - (player_size / 2),
          player_size,
          player_size,
          Gosu::Color::RED
        )

        # Draw player direction
        line_length = 8
        end_x = (@player_x * scale) + (Math.cos(@player_angle) * line_length)
        end_y = (@player_y * scale) + (Math.sin(@player_angle) * line_length)
        draw_line(
          @player_x * scale,
          @player_y * scale,
          Gosu::Color::RED,
          end_x,
          end_y,
          Gosu::Color::RED
        )
      end

      def button_down(id)
        if id == Gosu::KB_ESCAPE
          close!
        elsif id == Gosu::KB_TAB
          @debug_visible = !@debug_visible # Toggle debug info with Tab
        end
      end
    end
  end
end

# Only run the window if this file is being run directly
Doom::Demo::GosuFpsDemo.new.show if __FILE__ == $PROGRAM_NAME
