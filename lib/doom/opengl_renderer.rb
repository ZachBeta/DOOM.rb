# frozen_string_literal: true

module Doom
  class OpenGLRenderer
    GL_COLOR_BUFFER_BIT = 0x00004000

    attr_reader :last_render_time, :last_texture_time

    def initialize(window, map, textures)
      @window = window
      @map = map
      @textures = textures
      @wall_renderer = WallRenderer.new(window, map, textures)
      @minimap_renderer = MinimapRenderer.new(window, map)
      @logger = Logger.instance
      @logger.debug('Initializing OpenGL renderer')
      @texture_cache = {}
      @last_frame_time = Time.now
      @last_render_time = 0
      @last_texture_time = 0
      @frame_count = 0
      @fps = 0
      @fps_update_time = Time.now
    end

    def render(player)
      @logger.debug('OpenGL renderer starting frame')
      start_time = Time.now
      frame_time = (start_time - @last_frame_time).to_f
      @last_frame_time = start_time

      @logger.debug("Rendering frame: #{frame_time * 1000}ms")

      # Update FPS counter
      @frame_count += 1
      if Time.now - @fps_update_time >= 1.0
        @fps = @frame_count
        @frame_count = 0
        @fps_update_time = Time.now
      end

      # Clear screen
      @window.gl do
        glClear(GL_COLOR_BUFFER_BIT)
      end

      # Render walls
      @wall_renderer.render(player, @window.width, @window.height)

      # Render minimap
      @minimap_renderer.render(player)

      # Draw FPS counter
      draw_fps

      # Log performance metrics
      @logger.debug("OpenGL renderer frame time: #{(frame_time * 1000).round(2)}ms")
      @logger.debug("OpenGL renderer FPS: #{@fps}")
      @logger.debug('OpenGL renderer frame complete')
    end

    def glClear(mask)
      # Mock implementation for testing
      @logger.debug("Clearing screen with mask: #{mask}")
    end

    private

    def draw_fps
      # Draw FPS counter in top-left corner
      @font ||= Gosu::Font.new(20)
      @font.draw_text(
        "FPS: #{@fps}",
        10, 10, 0,
        1.0, 1.0,
        Gosu::Color::WHITE
      )
    end

    def get_texture(texture_name)
      return @texture_cache[texture_name] if @texture_cache[texture_name]

      texture = load_texture(texture_name)
      @texture_cache[texture_name] = texture if texture
      texture
    end

    def load_texture(texture_name)
      start_time = Time.now
      texture = @textures[texture_name]
      @last_texture_time = Time.now - start_time
      @texture_cache[texture_name] = texture
      texture
    end
  end
end
