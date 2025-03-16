# frozen_string_literal: true

require_relative '../logger'
require_relative 'ray_caster'

module Doom
  module Renderer
    class BaseRenderer
      BYTES_PER_PIXEL = 4 # RGBA format

      def initialize(window_manager, width, height)
        @window_manager = window_manager
        @width = width
        @height = height
        @target_fps = 60
        @ceiling_color = "\xFF\x87\x87\x87"  # Light gray
        @floor_color = "\xFF\x38\x38\x38"    # Dark gray
        @wall_colors = {
          north: "\xFF\xFF\x00\x00",  # Red
          south: "\xFF\x00\xFF\x00",  # Green
          east: "\xFF\x00\x00\xFF",   # Blue
          west: "\xFF\xFF\xFF\x00"    # Yellow
        }.freeze
        @column_buffer = Array.new(width * height * 4)
        @logger = Logger.instance
        @frame_count = 0
        @start_time = Time.now
        @last_frame_time = Time.now
        @fps = 0.0
        init_pixel_buffer
      end

      def set_game_objects(map, player)
        @logger.info('BaseRenderer: Setting game objects', component: 'BaseRenderer')
        begin
          @map = map
          @player = player
          @ray_caster = RayCaster.new(@map, @player, @height)
          @logger.info('BaseRenderer: Game objects set successfully', component: 'BaseRenderer')
        rescue StandardError => e
          @logger.error("BaseRenderer: Error setting game objects: #{e.message}",
                        component: 'BaseRenderer')
          @logger.error(e.backtrace.join("\n"), component: 'BaseRenderer')
          raise
        end
      end

      def render
        return unless @map && @player

        @logger.debug('BaseRenderer: Starting frame render', component: 'BaseRenderer')
        begin
          current_time = Time.now
          frame_time = current_time - @last_frame_time
          @last_frame_time = current_time

          # Clear buffer and draw background
          clear_and_draw_background

          # Cast rays and draw walls
          rays = @ray_caster.cast_rays(@width)
          @logger.debug("BaseRenderer: Processing #{rays.length} rays", component: 'BaseRenderer')

          rays.each_with_index do |ray, x|
            next unless ray.hit?

            wall_height = (@height / ray.perp_wall_dist).to_i
            wall_start = [(@height - wall_height) / 2, 0].max
            wall_end = [wall_start + wall_height, @height].min

            intensity = [(1.0 - (ray.perp_wall_dist / 10.0)), 0.2].max
            intensity *= 0.8 if ray.side == 1

            # Calculate wall color based on side
            wall_color = if ray.side == 0
                           ray.ray_dir_x > 0 ? @wall_colors[:east] : @wall_colors[:west]
                         else
                           ray.ray_dir_y > 0 ? @wall_colors[:south] : @wall_colors[:north]
                         end

            draw_wall_column(x, wall_start, wall_end, wall_color)
          end

          # Draw debug info last
          draw_fps
          draw_player_info
          draw_minimap

          # Update window with the new frame
          @window_manager.update_framebuffer(@pixel_buffer)

          calculate_fps if (@frame_count % 30).zero?
          @frame_count += 1

          # Log frame data
          @logger.log_render_frame(frame_time, rays.length, @fps)

          @logger.debug('BaseRenderer: Frame render complete', component: 'BaseRenderer')
        rescue StandardError => e
          @logger.error("BaseRenderer: Error during render: #{e.message}",
                        component: 'BaseRenderer')
          @logger.error(e.backtrace.join("\n"), component: 'BaseRenderer')
          @window_manager.should_close = true
        end
      end

      def window_should_close?
        @window_manager.should_close?
      end

      def cleanup
        @window_manager.close!
      end

      private

      def init_pixel_buffer
        @pixel_buffer = "\xFF" * (@width * @height * 4)  # Initialize with opaque black
        @back_buffer = "\xFF" * (@width * @height * 4)   # Initialize back buffer
      end

      def clear_and_draw_background
        @logger.debug('BaseRenderer: Clearing buffer and drawing background',
                      component: 'BaseRenderer')
        begin
          # Fill the top half with ceiling color
          ceiling_start = 0
          ceiling_end = @width * (@height / 2) * 4
          @back_buffer[ceiling_start...ceiling_end] = @ceiling_color * (@width * (@height / 2))

          # Fill the bottom half with floor color
          floor_start = ceiling_end
          floor_end = @width * @height * 4
          @back_buffer[floor_start...floor_end] = @floor_color * (@width * (@height / 2))

          # Copy back buffer to pixel buffer
          @pixel_buffer = @back_buffer.dup
        rescue StandardError => e
          @logger.error("BaseRenderer: Error in clear_and_draw_background: #{e.message}",
                        component: 'BaseRenderer')
          @logger.error(e.backtrace.join("\n"), component: 'BaseRenderer')
          raise
        end
      end

      def draw_wall_column(x, start_y, end_y, color)
        return if start_y >= end_y || x < 0 || x >= @width

        start_y = [start_y, 0].max
        end_y = [end_y, @height - 1].min

        (start_y..end_y).each do |y|
          offset = ((y * @width) + x) * 4
          @pixel_buffer[offset, 4] = color
        end
      end

      def draw_text(x, y, text, color)
        @window_manager.draw_text(x, y, text, color)
      end

      def calculate_fps
        current_time = Time.now
        elapsed = current_time - @start_time
        @fps = @frame_count / elapsed if elapsed > 0
      end

      def draw_fps
        return unless @fps

        text = "FPS: #{@fps.round(1)}"
        draw_text(10, 20, text, [255, 255, 255, 255])
      end

      def draw_player_info
        return unless @player

        pos_text = "Pos: (#{@player.position[0].round(2)}, #{@player.position[1].round(2)})"
        angle_text = "Angle: #{(@player.angle * 180 / Math::PI).round(1)}°"
        draw_text(10, 40, pos_text, [255, 255, 255, 255])
        draw_text(10, 60, angle_text, [255, 255, 255, 255])
      end

      def draw_minimap
        return unless @map && @player

        cell_size = 4
        map_x = 10
        map_y = 80

        @map.grid.each_with_index do |row, y|
          row.each_with_index do |cell, x|
            next if cell.zero?

            # Draw wall cells
            pos_x = map_x + (x * cell_size)
            pos_y = map_y + (y * cell_size)
            draw_rect(pos_x, pos_y, cell_size, cell_size, [255, 255, 255, 255])
          end
        end

        # Draw player position
        player_x = map_x + (@player.position[0] * cell_size)
        player_y = map_y + (@player.position[1] * cell_size)
        draw_rect(player_x - 1, player_y - 1, 3, 3, [255, 0, 0, 255])
      end

      def draw_rect(x, y, width, height, color)
        @window_manager.draw_rect(x, y, width, height, color)
      end
    end
  end
end
