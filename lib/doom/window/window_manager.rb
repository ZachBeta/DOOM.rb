# frozen_string_literal: true

require 'gosu'
require_relative '../logger'

module Doom
  module Window
    class WindowManager < Gosu::Window
      WINDOW_WIDTH = 800
      WINDOW_HEIGHT = 600
      WINDOW_TITLE = 'DOOM.rb'

      attr_reader :width, :height
      attr_accessor :should_close

      def initialize
        @logger = Logger.instance
        @width = WINDOW_WIDTH
        @height = WINDOW_HEIGHT
        @should_close = false
        @frame_time = Time.now
        @frame_interval = 1.0 / 60.0 # Target 60 FPS
        @pixel_buffer = nil
        @pixel_image = nil
        @text_queue = []
        @rect_queue = []
        @update_proc = nil

        @logger.info('WindowManager: Starting initialization', component: 'WindowManager')
        super(@width, @height, fullscreen: false) # Initialize Gosu window
        self.caption = WINDOW_TITLE
        setup_signal_handlers
        @font = Gosu::Font.new(14, name: Gosu.default_font_name)
        @logger.info('WindowManager: Initialization complete', component: 'WindowManager')
      end

      def needs_cursor?
        true # Show the system cursor
      end

      def set_update_proc(proc)
        @update_proc = proc
      end

      def update
        @logger.debug('WindowManager: Update cycle', component: 'WindowManager')
        current_time = Time.now
        delta = current_time - @frame_time
        @frame_time = current_time

        @update_proc.call(delta) if @update_proc

        return unless @should_close

        close
      end

      def draw
        @logger.debug('WindowManager: Draw cycle', component: 'WindowManager')
        if @pixel_buffer
          begin
            # Convert raw pixel data to Gosu::Image
            @pixel_image = Gosu::Image.from_blob(
              @width,
              @height,
              @pixel_buffer
            )
            @pixel_image.draw(0, 0, 0)
          rescue StandardError => e
            @logger.error("WindowManager: Error drawing pixel buffer: #{e.message}",
                          component: 'WindowManager')
            @logger.error(e.backtrace.join("\n"), component: 'WindowManager')
          end
        end

        # Draw all queued text
        @text_queue.each do |text_item|
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

      def key_pressed?(key_code)
        button_down?(key_code)
      end

      def update_framebuffer(buffer)
        @logger.debug('WindowManager: Updating framebuffer', component: 'WindowManager')
        begin
          if buffer.is_a?(String) && buffer.bytesize == @width * @height * 4
            @pixel_buffer = buffer.dup
          else
            @logger.error('WindowManager: Invalid buffer format or size',
                          component: 'WindowManager')
          end
        rescue StandardError => e
          @logger.error("WindowManager: Error updating framebuffer: #{e.message}",
                        component: 'WindowManager')
          @logger.error(e.backtrace.join("\n"), component: 'WindowManager')
        end
      end

      def button_down(id)
        super
        case id
        when Gosu::KB_ESCAPE
          self.should_close = true
        end
      end

      def close!
        @logger.info('WindowManager: Closing window', component: 'WindowManager')
        self.should_close = true
      end

      private

      def setup_signal_handlers
        @logger.info('WindowManager: Setting up signal handlers', component: 'WindowManager')
        Signal.trap('INT') do
          @logger.info('WindowManager: Received INT signal', component: 'WindowManager')
          self.should_close = true
        end
      rescue StandardError => e
        @logger.error("WindowManager: Error setting up signal handlers: #{e.message}",
                      component: 'WindowManager')
      end
    end
  end
end
