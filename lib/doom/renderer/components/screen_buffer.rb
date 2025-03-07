# frozen_string_literal: true

require 'opengl'

module Doom
  module Renderer
    module Components
      class ScreenBuffer
        include OpenGL

        def initialize(viewport)
          @viewport = viewport
          @front_buffer = create_buffer
          @back_buffer = create_buffer
          @palette = create_default_palette
          @texture_id = create_texture
          @logger = Logger.instance
          @logger.info("Screen buffer initialized with size #{@viewport.width}x#{@viewport.height}")
        end

        def cleanup
          return unless @texture_id

          @logger.info('Starting screen buffer cleanup')
          begin
            @logger.debug('Deleting OpenGL texture')
            glDeleteTextures(1, [@texture_id].pack('L'))
            @texture_id = nil
            @front_buffer = nil
            @back_buffer = nil
            @palette = nil
            @logger.info('Screen buffer cleanup completed successfully')
          rescue StandardError => e
            @logger.error("Error during screen buffer cleanup: #{e.message}")
            @logger.error(e.backtrace.join("\n"))
            raise
          end
        end

        def clear
          @back_buffer.fill(0)
          @logger.debug('Back buffer cleared')
        end

        def draw_pixel(x, y, color_index)
          return if x < 0 || x >= @viewport.width || y < 0 || y >= @viewport.height

          @back_buffer[x + (y * @viewport.width)] = color_index
        end

        def draw_vertical_line(x, y1, y2, color_index)
          return if x < 0 || x >= @viewport.width

          y1 = [y1, 0].max
          y2 = [y2, @viewport.height - 1].min
          return if y1 > y2 || y1 < 0 || y2 >= @viewport.height

          y1.upto(y2) do |y|
            @back_buffer[x + (y * @viewport.width)] = color_index
          end
        end

        def flip
          @front_buffer, @back_buffer = @back_buffer, @front_buffer
          @logger.debug('Buffer flipped')
        end

        def render_to_window
          start_time = Time.now

          # Bind texture
          glBindTexture(GL_TEXTURE_2D, @texture_id)

          # Update texture data
          glTexSubImage2D(GL_TEXTURE_2D, 0, 0, 0, @viewport.width, @viewport.height,
                          GL_RGBA, GL_UNSIGNED_BYTE, @front_buffer.pack('C*'))

          # Draw fullscreen quad with texture
          glBegin(GL_QUADS)
          glTexCoord2f(0.0, 0.0)
          glVertex2f(-1.0, -1.0)
          glTexCoord2f(1.0, 0.0)
          glVertex2f(1.0, -1.0)
          glTexCoord2f(1.0, 1.0)
          glVertex2f(1.0, 1.0)
          glTexCoord2f(0.0, 1.0)
          glVertex2f(-1.0, 1.0)
          glEnd

          render_time = Time.now - start_time
          @logger.debug("Buffer rendered to window in #{(render_time * 1000).round(2)}ms")
        end

        private

        def create_buffer
          Array.new(@viewport.width * @viewport.height * 4, 0)
        end

        def create_default_palette
          # Create a grayscale palette for now
          Array.new(256) do |i|
            # Map 0-255 to 0-255 for grayscale
            intensity = i
            [intensity, intensity, intensity, 255]
          end
        end

        def create_texture
          texture_id = [0].pack('L')
          glGenTextures(1, texture_id)
          texture_id = texture_id.unpack1('L')
          glBindTexture(GL_TEXTURE_2D, texture_id)
          glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST)
          glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST)
          glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE)
          glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE)
          glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, @viewport.width, @viewport.height,
                       0, GL_RGBA, GL_UNSIGNED_BYTE, nil)
          texture_id
        end

        def get_color(color_index)
          @palette[color_index] || [0, 0, 0, 255]
        end
      end
    end
  end
end
