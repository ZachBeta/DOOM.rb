# frozen_string_literal: true

require 'gosu'
require 'tempfile'
require 'chunky_png'

module Doom
  class OpenGLRenderer
    GL_COLOR_BUFFER_BIT = 0x00004000
    GL_TRIANGLES = 0x0004
    GL_TEXTURE_2D = 0x0DE1
    GL_TEXTURE_MAG_FILTER = 0x2800
    GL_LINEAR = 0x2601
    GL_TEXTURE_MIN_FILTER = 0x2801
    GL_NEAREST = 0x2600
    GL_TEXTURE_WRAP_S = 0x2802
    GL_TEXTURE_WRAP_T = 0x2803
    GL_CLAMP_TO_EDGE = 0x812F
    GL_RGBA = 0x1908
    GL_UNSIGNED_BYTE = 0x1401

    attr_reader :last_render_time, :last_texture_time

    def initialize(window, map, textures)
      @window = window
      @map = map
      @textures = textures
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
      @font = Gosu::Font.new(20)
      @textures_setup = false
    end

    def render(player)
      @logger.debug('OpenGL renderer starting frame')
      start_time = Time.now
      frame_time = (start_time - @last_frame_time).to_f
      @last_frame_time = start_time

      # Update FPS counter
      @frame_count += 1
      if Time.now - @fps_update_time >= 1.0
        @fps = @frame_count
        @frame_count = 0
        @fps_update_time = Time.now
      end

      @window.gl do
        setup_textures unless @textures_setup
        glClear(GL_COLOR_BUFFER_BIT)
        render_walls(player)
      end

      # Render minimap and HUD using Gosu (since they're 2D)
      @minimap_renderer.render(player)
      draw_fps

      # Log performance metrics
      @logger.debug("OpenGL renderer frame time: #{(frame_time * 1000).round(2)}ms")
      @logger.debug("OpenGL renderer FPS: #{@fps}")
      @logger.debug('OpenGL renderer frame complete')
    end

    private

    def setup_textures
      @textures.each do |name, texture|
        # Create a temporary file for the texture
        temp_file = Tempfile.new([name, '.png'])
        begin
          # Convert texture data to PNG
          require 'chunky_png'
          png = ChunkyPNG::Image.new(texture.width, texture.height)
          texture.height.times do |y|
            texture.width.times do |x|
              # Convert indexed color to RGB
              color_index = texture.data[(y * texture.width) + x]
              r = (color_index * 255 / 255).to_i
              g = (color_index * 255 / 255).to_i
              b = (color_index * 255 / 255).to_i
              png[x, y] = ChunkyPNG::Color.rgb(r, g, b)
            end
          end
          png.save(temp_file.path)

          # Create Gosu texture from PNG
          gosu_texture = Gosu::Image.new(temp_file.path)
          @texture_cache[name] = gosu_texture
        ensure
          temp_file.close
          temp_file.unlink
        end
      end
      @textures_setup = true
    end

    def render_walls(player)
      screen_width = @window.width
      screen_height = @window.height

      screen_width.times do |x|
        ray = Ray.new(player, x, screen_width)
        caster = RayCaster.new(@map, player, ray)
        intersection = caster.cast

        # Calculate wall height
        line_height = if intersection.distance.zero?
                        screen_height
                      else
                        (screen_height / intersection.distance).to_i
                      end
        draw_start = (-line_height + screen_height) / 2
        draw_end = (line_height + screen_height) / 2

        # Clamp values
        draw_start = 0 if draw_start.negative?
        draw_end = screen_height - 1 if draw_end >= screen_height

        # Calculate texture coordinates
        tex_x = calculate_texture_x(intersection)
        step = 1.0 * @textures['STARTAN3'].height / line_height
        tex_pos = (draw_start - (screen_height / 2) + (line_height / 2)) * step

        # Get texture
        texture = @texture_cache['STARTAN3']

        # Draw wall slice
        draw_start.upto(draw_end) do |y|
          tex_y = tex_pos.to_i
          tex_pos += step

          # Get texture color
          color = get_texture_color('STARTAN3', tex_x, tex_y)
          color = apply_fog(color, intersection.distance)

          # Draw quad for wall slice
          texture.draw(
            x, y, 0,
            1.0, 1.0,
            color
          )
        end
      end
    end

    def calculate_texture_x(intersection)
      tex_x = (intersection.wall_x * @textures['STARTAN3'].width).to_i
      if intersection.side.zero? && intersection.ray_dir_x.positive?
        tex_x = @textures['STARTAN3'].width - tex_x - 1
      end
      if intersection.side == 1 && intersection.ray_dir_y.negative?
        tex_x = @textures['STARTAN3'].width - tex_x - 1
      end
      tex_x + 1
    end

    def get_texture_color(texture_name, x, y)
      texture = @textures[texture_name]
      return Gosu::Color::BLACK unless texture

      # Clamp texture coordinates
      x = x.clamp(0, texture.width - 1)
      y = y.clamp(0, texture.height - 1)

      # Get color from texture data
      color_index = texture.data[(y * texture.width) + x]
      Gosu::Color.rgb(color_index.to_i, color_index.to_i, color_index.to_i)
    end

    def apply_fog(color, distance)
      # Simple distance-based fog
      fog_factor = [1.0 - (distance / 10.0), 0.0].max
      r = (color.red * fog_factor).to_i
      g = (color.green * fog_factor).to_i
      b = (color.blue * fog_factor).to_i
      Gosu::Color.rgb(r, g, b)
    end

    def draw_fps
      @font.draw_text(
        "FPS: #{@fps}",
        10, 10, 0,
        1.0, 1.0,
        Gosu::Color::WHITE
      )
    end
  end
end
