# frozen_string_literal: true

require 'gosu'
require_relative '../logger'
require_relative '../debug_db'

module Doom
  module Window
    class WindowManager < Gosu::Window
      WINDOW_WIDTH = 800
      WINDOW_HEIGHT = 600
      WINDOW_TITLE = 'DOOM.rb'

      attr_reader :width, :height

      def initialize
        @logger = Logger.instance
        @width = WINDOW_WIDTH
        @height = WINDOW_HEIGHT
        @should_close = false
        @frame_time = Time.now
        @frame_interval = 1.0 / 60.0 # Target 60 FPS
        @pixel_buffer = nil
        @pixel_image = nil
        @debug_db = DebugDB.new
        @text_queue = []
        @rect_queue = []
        @font = nil
        @game_block = nil

        @logger.info('WindowManager: Starting initialization')
        super(@width, @height, false) # false = windowed mode
        self.caption = WINDOW_TITLE
        setup_signal_handlers
        @font = Gosu::Font.new(14, name: Gosu.default_font_name)
        @logger.info('WindowManager: Initialization complete')
      end

      def show(&block)
        @game_block = block
        super()
      end

      def update
        @logger.debug('WindowManager: Update cycle')
        current_time = Time.now
        delta = current_time - @frame_time
        if delta < @frame_interval
          sleep_time = @frame_interval - delta
          sleep(sleep_time) if sleep_time > 0
        end
        @frame_time = Time.now

        @game_block&.call
      end

      def draw
        @logger.debug('WindowManager: Draw cycle')
        if @pixel_buffer
          begin
            # Convert raw pixel data to Gosu::Image
            @pixel_image = Gosu::Image.from_blob(
              @width,
              @height,
              @pixel_buffer,
              tileable: false
            )
            @pixel_image.draw(0, 0, 0)
          rescue StandardError => e
            @logger.error("WindowManager: Error drawing pixel buffer: #{e.message}")
            @logger.error(e.backtrace.join("\n"))
          end
        end

        # Draw all queued text
        @text_queue.each do |text_item|
          begin
            @font.draw_text(
              text_item[:text],
              text_item[:x],
              text_item[:y],
              text_item[:z] || 1,
              1,
              1,
              Gosu::Color.rgba(
                text_item[:color][0],
                text_item[:color][1],
          @font.draw_text(
            text_item[:text],
            text_item[:x],
            text_item[:y],
            text_item[:z] || 1,
            1,
            1,
            Gosu::Color.rgba(
              text_item[:color][0],
              text_item[:color][1],
              text_item[:color][2],
              text_item[:color][3]
            )
          )
        rescue StandardError => e
          @logger.error("WindowManager: Error drawing text: #{e.message}")
        end

        # Draw all queued rectangles
        @rect_queue.each do |rect|
          color = Gosu::Color.rgba(
            rect[:color][0],
            rect[:color][1],
            rect[:color][2],
            rect[:color][3]
          )
          draw_quad(
            rect[:x], rect[:y], color,
            rect[:x] + rect[:width], rect[:y], color,
            rect[:x], rect[:y] + rect[:height], color,
            rect[:x] + rect[:width], rect[:y] + rect[:height], color,
            rect[:z] || 1
          )
        rescue StandardError => e
          @logger.error("WindowManager: Error drawing rectangle: #{e.message}")
        end

        # Clear queues after drawing
        @text_queue.clear
        @rect_queue.clear
      end

      def draw_text(x, y, text, color, z = 1)
        @text_queue << { x: x, y: y, text: text, color: color, z: z }
      end

      def draw_rect(x, y, width, height, color, z = 1)
        @rect_queue << { x: x, y: y, width: width, height: height, color: color, z: z }
      end

      def should_close?
        @logger.debug('WindowManager: Checking window close state')
        @should_close || !open?
      end

      def should_close=(value)
        @logger.info("WindowManager: Setting should_close to #{value}")
        @debug_db.instance_variable_get(:@db).execute(
          'INSERT INTO game_events (timestamp, event_type, event_data) VALUES (?, ?, ?)',
          [Time.now.to_f, 'window_close_requested', { manual_close: value }.to_json]
        )
        @should_close = value
        close! if value
      end

      def button_down(id)
        super
        return unless id == Gosu::KB_ESCAPE

        @debug_db.instance_variable_get(:@db).execute(
          'INSERT INTO game_events (timestamp, event_type, event_data) VALUES (?, ?, ?)',
          [Time.now.to_f, 'escape_key_pressed', {}.to_json]
        )
        self.should_close = true
      end

      def close!
        @debug_db.instance_variable_get(:@db).execute(
          'INSERT INTO game_events (timestamp, event_type, event_data) VALUES (?, ?, ?)',
          [Time.now.to_f, 'window_closing', {}.to_json]
        )
        close
      end

      def key_pressed?(key_code)
        @logger.debug("WindowManager: Checking key #{key_code}")
        begin
          button_down?(key_code)
        rescue StandardError => e
          @logger.error("WindowManager: Error checking key state: #{e.message}")
          false
        end
      end

      def update_framebuffer(buffer)
        @logger.debug('WindowManager: Updating framebuffer')
        begin
          if buffer.is_a?(String) && buffer.bytesize == @width * @height * 4
            @pixel_buffer = buffer.dup # Make a copy to avoid buffer modification during draw
          else
            @logger.error("WindowManager: Invalid buffer format or size: #{buffer.class}, #{if buffer.is_a?(String)
                                                                                              buffer.bytesize
                                                                                            end}")
          end
        rescue StandardError => e
          @logger.error("WindowManager: Error updating framebuffer: #{e.message}")
          @logger.error(e.backtrace.join("\n"))
        end
      end

      private

      def setup_signal_handlers
        @logger.info('WindowManager: Setting up signal handlers')
        # Handle Ctrl+C gracefully
        Signal.trap('INT') do
          @logger.info('WindowManager: Received INT signal')
          @debug_db.instance_variable_get(:@db).execute(
            'INSERT INTO game_events (timestamp, event_type, event_data) VALUES (?, ?, ?)',
            [Time.now.to_f, 'signal_interrupt', {}.to_json]
          )
          self.should_close = true
        end
        @logger.info('WindowManager: Signal handlers set up successfully')
      rescue StandardError => e
        @logger.error("WindowManager: Error setting up signal handlers: #{e.message}")
      end
    end
  end
end
