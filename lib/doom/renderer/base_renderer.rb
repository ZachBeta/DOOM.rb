# frozen_string_literal: true

require 'gosu'
require_relative 'ray_caster'
require_relative '../logger'
require_relative '../window/window_manager'

module Doom
  module Renderer
    class BaseRenderer
      BYTES_PER_PIXEL = 4  # RGBA format

      def initialize
        @logger = Logger.instance
        @logger.info('BaseRenderer: Starting initialization')

        begin
          @window_manager = Window::WindowManager.new
          init_pixel_buffer

          @frame_count = 0
          @start_time = Time.now
          @last_frame_time = Time.now
          @frame_budget = 1.0 / 30.0  # Target 30 FPS
          @background_color = [0, 0, 0, 255] # RGBA black
          @fps = 0.0

          # Pre-allocate color buffers for better performance
          @column_buffer = String.new(capacity: BYTES_PER_PIXEL * @window_manager.height)
          @ceiling_color = "\x28\x28\x28\xFF".freeze  # [40, 40, 40, 255]
          @floor_color = "\x3C\x3C\x3C\xFF".freeze    # [60, 60, 60, 255]
          
          @logger.info('BaseRenderer: Initialization complete')
        rescue StandardError => e
          @logger.error("BaseRenderer: Error during initialization: #{e.message}")
          @logger.error(e.backtrace.join("\n"))
          raise
        end
      end

      def set_game_objects(map, player)
        @logger.info('BaseRenderer: Setting game objects')
        begin
          @map = map
          @player = player
          @ray_caster = RayCaster.new(@map, @player, @window_manager.height)
          @logger.info('BaseRenderer: Game objects set successfully')
        rescue StandardError => e
          @logger.error("BaseRenderer: Error setting game objects: #{e.message}")
          @logger.error(e.backtrace.join("\n"))
          raise
        end
      end

      def render
        return unless @map && @player
        
        @logger.debug('BaseRenderer: Starting frame render')
        begin
          # Frame timing is now handled by Gosu's game loop
          current_time = Time.now
          @last_frame_time = current_time

          # Clear buffer and draw background in one pass
          clear_and_draw_background

          # Cast rays and draw walls
          rays = @ray_caster.cast_rays(@window_manager.width)
          
          @logger.debug("BaseRenderer: Processing #{rays.length} rays")
          
          # Pre-allocate color buffer for better performance
          color_buffer = String.new(capacity: @window_manager.height * BYTES_PER_PIXEL)
          
          rays.each_with_index do |ray, x|
            next unless ray.hit?
            
            wall_height = (@window_manager.height / ray.perp_wall_dist).to_i
            wall_start = [(@window_manager.height - wall_height) / 2, 0].max
            wall_end = [wall_start + wall_height, @window_manager.height].min
            
            intensity = [(1.0 - ray.perp_wall_dist / 10.0), 0.2].max
            intensity *= 0.8 if ray.side == 1
            
            color = [
              (intensity * 255).to_i,  # Red
              (intensity * 200).to_i,  # Green
              (intensity * 150).to_i,  # Blue
              255                      # Alpha
            ]
            
            draw_optimized_column(x, wall_start, wall_end, color, color_buffer)
          end

          # Draw debug info last
          draw_fps
          draw_player_info
          draw_minimap
          
          # Update window with the new frame
          @window_manager.update_framebuffer(@back_buffer)
          
          calculate_fps if (@frame_count % 30).zero?  # Calculate FPS more frequently
          @frame_count += 1
          
          @logger.debug('BaseRenderer: Frame render complete')
        rescue StandardError => e
          @logger.error("BaseRenderer: Error during render: #{e.message}")
          @logger.error(e.backtrace.join("\n"))
          @window_manager.should_close = true
        end
      end

      def window_should_close?
        @window_manager.should_close?
      end

      def cleanup
        @window_manager.cleanup
      end

      private

      def init_pixel_buffer
        @logger.info('BaseRenderer: Initializing pixel buffers')
        begin
          buffer_size = @window_manager.width * @window_manager.height * BYTES_PER_PIXEL
          @logger.debug("BaseRenderer: Creating buffers of size #{buffer_size} bytes")
          
          # Pre-allocate back buffer for double buffering
          @back_buffer = String.new(capacity: buffer_size)
          @back_buffer << "\x00" * buffer_size
          @temp_buffer = String.new(capacity: BYTES_PER_PIXEL * @window_manager.height)
          
          @logger.info('BaseRenderer: Pixel buffers initialized successfully')
        rescue StandardError => e
          @logger.error("BaseRenderer: Error initializing pixel buffers: #{e.message}")
          @logger.error(e.backtrace.join("\n"))
          raise
        end
      end

      def clear_and_draw_background
        @logger.debug('BaseRenderer: Clearing buffer and drawing background')
        begin
          half_height = @window_manager.height / 2
          
          # Draw ceiling and floor in single operations
          @back_buffer.clear
          @back_buffer << @ceiling_color * (@window_manager.width * half_height)
          @back_buffer << @floor_color * (@window_manager.width * (@window_manager.height - half_height))
        rescue StandardError => e
          @logger.error("BaseRenderer: Error in clear_and_draw_background: #{e.message}")
          @logger.error(e.backtrace.join("\n"))
          raise
        end
      end

      def draw_optimized_column(x, start_y, end_y, color, buffer)
        return if start_y >= end_y || x < 0 || x >= @window_manager.width
        
        # Convert color to string once and cache it
        color_key = color.hash
        @color_cache ||= {}
        color_str = @color_cache[color_key] ||= color.pack('C4').freeze
        
        height = end_y - start_y
        buffer.clear
        buffer << color_str * height
        
        # Single string operation to update column
        pos = (start_y * @window_manager.width + x) * BYTES_PER_PIXEL
        @back_buffer[pos, height * BYTES_PER_PIXEL] = buffer[0, height * BYTES_PER_PIXEL]
      end

      def draw_text(x, y, text, color)
        # Text drawing will be handled by Gosu's built-in text rendering
        # This will be implemented in the WindowManager's draw method
        # For now, we'll just store the text data
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
        pos_text = "Pos: (#{@player.x.round(2)}, #{@player.y.round(2)})"
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
            pos_x = map_x + x * cell_size
            pos_y = map_y + y * cell_size
            draw_rect(pos_x, pos_y, cell_size, cell_size, [255, 255, 255, 255])
          end
        end
        
        # Draw player position
        player_x = map_x + @player.x * cell_size
        player_y = map_y + @player.y * cell_size
        draw_rect(player_x - 1, player_y - 1, 3, 3, [255, 0, 0, 255])
      end

      def draw_rect(x, y, width, height, color)
        # Rectangle drawing will be handled by Gosu's draw methods
        # This will be implemented in the WindowManager's draw method
        @window_manager.draw_rect(x, y, width, height, color)
      end
    end
  end
end
