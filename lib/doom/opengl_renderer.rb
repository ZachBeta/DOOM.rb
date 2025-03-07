# frozen_string_literal: true

require 'gosu'
require 'tempfile'
require 'chunky_png'

module Doom
  class OpenGLRenderer
    attr_reader :last_render_time, :last_texture_time

    def initialize(window, map, textures)
      @window = window
      @map = map
      @textures = textures
      @minimap_renderer = MinimapRenderer.new(window, map)
      @logger = Logger.instance
      @logger.debug('Initializing renderer')
      @texture_cache = {}
      @last_frame_time = Time.now
      @last_render_time = 0
      @last_texture_time = 0
      @frame_count = 0
      @fps = 0
      @fps_update_time = Time.now
      @font = Gosu::Font.new(20)
      @fps_text = 'FPS: 0'
      @wall_slices = []
      @screen_width = window.width
      @screen_height = window.height
      @wall_cache = {}
      setup_textures
    end

    def render(player)
      @logger.debug('Renderer starting frame')
      start_time = Time.now
      frame_time = (start_time - @last_frame_time).to_f
      @last_frame_time = start_time

      # Update FPS counter
      @frame_count += 1
      if Time.now - @fps_update_time >= 1.0
        @fps = @frame_count
        @frame_count = 0
        @fps_update_time = Time.now
        @fps_text = "FPS: #{@fps}"
      end

      calculate_walls(player)

      # Render minimap and HUD
      @minimap_renderer.render(player)

      # Log performance metrics
      @logger.debug("Renderer frame time: #{(frame_time * 1000).round(2)}ms")
      @logger.debug("Renderer FPS: #{@fps}")
      @logger.debug('Renderer frame complete')
    end

    def draw
      @wall_slices.each do |slice|
        slice[:texture].draw(
          slice[:x], slice[:y], 0,
          1.0, 1.0,
          slice[:color]
        )
      end

      # Draw FPS counter
      @font.draw_text(
        @fps_text,
        10, 10, 0,
        1.0, 1.0,
        Gosu::Color::WHITE
      )
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
              color_index = texture.data[(y * texture.width) + x].to_i
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
    end

    def calculate_walls(player)
      @wall_slices = []
      texture = @texture_cache['STARTAN3']
      return unless texture

      # Cache key based on player position and direction
      cache_key = [player.position[0].round(2), player.position[1].round(2),
                   player.direction[0].round(2), player.direction[1].round(2)]

      # Check cache first
      if @wall_cache[cache_key]
        @wall_slices = @wall_cache[cache_key]
        return
      end

      # Calculate wall slices
      @screen_width.times do |x|
        ray = Ray.new(player, x, @screen_width)
        caster = RayCaster.new(@map, player, ray)
        intersection = caster.cast

        # Calculate wall height
        line_height = if intersection.distance.zero?
                        @screen_height
                      else
                        (@screen_height / intersection.distance).to_i
                      end
        draw_start = (-line_height + @screen_height) / 2
        draw_end = (line_height + @screen_height) / 2

        # Clamp values
        draw_start = 0 if draw_start.negative?
        draw_end = @screen_height - 1 if draw_end >= @screen_height

        # Calculate texture coordinates
        tex_x = calculate_texture_x(intersection)
        step = 1.0 * @textures['STARTAN3'].height / line_height
        tex_pos = (draw_start - (@screen_height / 2) + (line_height / 2)) * step

        # Store wall slice for drawing
        draw_start.upto(draw_end) do |y|
          tex_y = tex_pos.to_i
          tex_pos += step

          # Get texture color
          color = get_texture_color('STARTAN3', tex_x, tex_y)
          color = apply_fog(color, intersection.distance)

          @wall_slices << {
            texture: texture,
            x: x,
            y: y,
            color: color
          }
        end
      end

      # Cache the results
      @wall_cache[cache_key] = @wall_slices.dup

      # Limit cache size
      return unless @wall_cache.size > 100

      @wall_cache.delete(@wall_cache.keys.first)
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
  end
end
