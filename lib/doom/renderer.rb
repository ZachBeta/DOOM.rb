# frozen_string_literal: true

require 'gosu'
require_relative 'map'
require_relative 'logger'

module Doom
  class Renderer
    attr_reader :last_render_time, :last_texture_time

    def initialize(window, map, textures = {})
      @window = window
      @map = map
      @width = window.width
      @height = window.height
      @wall_renderer = WallRenderer.new(window, @map, textures)
      @background_renderer = BackgroundRenderer.new(window)
      @minimap_renderer = MinimapRenderer.new(window, @map)
      @last_render_time = 0
      @last_texture_time = 0
    end

    def render(player)
      start_time = Time.now
      @background_renderer.render

      texture_start = Time.now
      @wall_renderer.render(player, @width, @height)
      @last_texture_time = Time.now - texture_start

      @minimap_renderer.render(player)
      @last_render_time = Time.now - start_time
    end
  end

  class BackgroundRenderer
    FLOOR_COLOR = Gosu::Color.new(255, 50, 50, 50)
    CEILING_COLOR = Gosu::Color.new(255, 100, 100, 150)

    def initialize(window)
      @window = window
      @width = window.width
      @height = window.height
    end

    def render
      render_ceiling
      render_floor
    end

    private

    def render_ceiling
      @window.draw_quad(
        0, 0, CEILING_COLOR,
        @width, 0, CEILING_COLOR,
        0, @height / 2, CEILING_COLOR,
        @width, @height / 2, CEILING_COLOR
      )
    end

    def render_floor
      @window.draw_quad(
        0, @height / 2, FLOOR_COLOR,
        @width, @height / 2, FLOOR_COLOR,
        0, @height, FLOOR_COLOR,
        @width, @height, FLOOR_COLOR
      )
    end
  end

  class WallRenderer
    WALL_COLORS = {
      north: Gosu::Color.new(255, 255, 0, 0),    # Red
      south: Gosu::Color.new(255, 0, 255, 0),    # Green
      east: Gosu::Color.new(255, 0, 0, 255),     # Blue
      west: Gosu::Color.new(255, 255, 255, 0)    # Yellow
    }.freeze
    MAX_DISTANCE = 20.0 # Add distance limit for performance
    MAX_BATCH_SIZE = 5000 # Increased from 1000 to 5000

    def initialize(window, map, textures = {})
      @window = window
      @map = map
      @textures = textures
      @default_texture = @textures.values.first
      @color_cache = {}
      @fog_color_cache = {}
      @line_batch = []
      @z_buffer = Array.new(window.width)
    end

    def render(player, width, height)
      @line_batch.clear
      @z_buffer.fill(Float::INFINITY)
      width.times do |x|
        ray = Ray.new(player, x, width)
        intersection = ray_cast(ray, player)
        if intersection && intersection.distance < MAX_DISTANCE
          @z_buffer[x] = intersection.distance
          draw_wall_slice(x, intersection, height, player)
        end
      end
      flush_line_batch
    end

    def calculate_texture_x(intersection)
      return 0 unless @default_texture

      # Calculate exact hit point with higher precision
      wall_x = if intersection.side.zero?
                 intersection.player_y + (intersection.distance * intersection.ray_dir_y)
               else
                 intersection.player_x + (intersection.distance * intersection.ray_dir_x)
               end

      # Get fractional part with better precision
      wall_x -= wall_x.floor

      # Flip texture coordinate based on wall side and ray direction
      wall_x = 1.0 - wall_x if (intersection.side.zero? && intersection.ray_dir_x > 0) ||
                               (!intersection.side.zero? && intersection.ray_dir_y < 0)

      # Scale to texture width with perspective correction
      tex_x = (wall_x * @default_texture.width).to_i
      tex_x.clamp(0, @default_texture.width - 1)
    end

    private

    def ray_cast(ray, player)
      RayCaster.new(@map, player, ray).cast
    end

    def draw_wall_slice(x, intersection, height, player)
      # Calculate line height with perspective correction
      perp_wall_dist = if intersection.side.zero?
                         (intersection.map_x - player.position[0] + ((1 - intersection.step_x) / 2)) / intersection.ray_dir_x
                       else
                         (intersection.map_y - player.position[1] + ((1 - intersection.step_y) / 2)) / intersection.ray_dir_y
                       end
      line_height = (height / perp_wall_dist).to_i
      line_height = [line_height, height * 3].min

      # Calculate drawing bounds with perspective correction
      draw_start = [(-line_height / 2) + (height / 2), 0].max
      draw_end = [(line_height / 2) + (height / 2), height - 1].min

      if @default_texture
        tex_x = calculate_texture_x(intersection)
        draw_textured_slice(x, draw_start, draw_end, tex_x, line_height, perp_wall_dist)
      else
        draw_colored_slice(x, draw_start, draw_end, intersection)
      end
    end

    def draw_textured_slice(x, draw_start, draw_end, tex_x, line_height, perp_wall_dist)
      return if draw_start >= draw_end

      # Pre-calculate constants for the loop
      height = draw_end - draw_start
      tex_step = (@default_texture.height.to_f / line_height)
      tex_pos = (draw_start - (height / 2) + (line_height / 2)) * tex_step / line_height

      # Select appropriate mipmap level based on distance
      mipmap_level = select_mipmap_level(perp_wall_dist)
      texture_data = if mipmap_level == 0 || !@default_texture.mipmaps || @default_texture.mipmaps.empty?
                       {
                         width: @default_texture.width,
                         height: @default_texture.height,
                         data: @default_texture.data
                       }
                     else
                       @default_texture.mipmaps[mipmap_level - 1]
                     end

      # Pre-calculate texture dimensions and perspective values
      tex_width = texture_data[:width]
      tex_height = texture_data[:height]
      tex_data = texture_data[:data]
      perspective_factor = 1.0 / perp_wall_dist
      fog_factor = 1.0 - (perp_wall_dist / MAX_DISTANCE).clamp(0.0, 0.8)

      # Scale texture coordinates for mipmap level
      tex_x = (tex_x * tex_width) / @default_texture.width

      # Pre-calculate step values
      tex_step_scaled = tex_step * perspective_factor
      tex_height_scaled = tex_height / @default_texture.height

      # Draw the slice with batched colors
      prev_color = nil
      prev_y = draw_start
      current_y = draw_start

      (draw_start...draw_end).each do |y|
        # Calculate texture Y coordinate with perspective correction
        tex_y = ((tex_pos * tex_step_scaled * tex_height_scaled)).to_i % tex_height

        # Get color from texture with fog effect
        color_index = tex_data[(tex_y * tex_width) + tex_x]
        base_color = get_cached_color(color_index)
        color = apply_fog(base_color, fog_factor)

        # Batch similar colors
        if color != prev_color && current_y > prev_y
          add_to_batch(x, prev_y, x, current_y, prev_color) if prev_color
          prev_y = current_y
          prev_color = color
        end

        current_y = y + 1
        tex_pos += tex_step
      end

      # Draw final segment
      add_to_batch(x, prev_y, x, current_y, prev_color) if prev_color
    end

    def select_mipmap_level(distance)
      return 0 if distance <= 1.0

      level = Math.log2(distance).floor
      [level, @default_texture.mipmaps.size].min
    end

    def apply_fog(color, fog_factor)
      cache_key = "#{color.object_id}_#{(fog_factor * 100).to_i}"
      @fog_color_cache[cache_key] ||= begin
        r = (color.red * fog_factor).to_i
        g = (color.green * fog_factor).to_i
        b = (color.blue * fog_factor).to_i
        Gosu::Color.new(color.alpha, r, g, b)
      end
    end

    def draw_colored_slice(x, draw_start, draw_end, intersection)
      color = determine_wall_color(intersection)
      add_to_batch(x, draw_start, x, draw_end, color)
    end

    def add_to_batch(x1, y1, x2, y2, color)
      @line_batch << [x1, y1, x2, y2, color]
      flush_line_batch if @line_batch.size >= MAX_BATCH_SIZE
    end

    def flush_line_batch
      @line_batch.each do |x1, y1, x2, y2, color|
        @window.draw_line(x1, y1, color, x2, y2, color)
      end
      @line_batch.clear
    end

    def get_cached_color(color_index)
      @color_cache[color_index] ||= begin
        r = ((color_index & 0xE0) >> 5) * 32
        g = ((color_index & 0x1C) >> 2) * 32
        b = (color_index & 0x03) * 64
        Gosu::Color.new(255, r, g, b)
      end
    end

    def determine_wall_color(intersection)
      color = if intersection.side.zero?
                intersection.ray_dir_x.positive? ? WALL_COLORS[:east] : WALL_COLORS[:west]
              else
                intersection.ray_dir_y.positive? ? WALL_COLORS[:south] : WALL_COLORS[:north]
              end

      # Darken based on distance and side
      alpha = (255 * (1.0 - (intersection.distance / MAX_DISTANCE))).to_i.clamp(100, 255)
      alpha = (alpha * 0.8).to_i if intersection.side == 1

      Gosu::Color.new(alpha, color.red, color.green, color.blue)
    end
  end

  class Ray
    attr_reader :direction_x, :direction_y, :camera_x

    def initialize(player, screen_x, screen_width)
      @camera_x = (2 * screen_x.to_f / screen_width) - 1
      @direction_x = player.direction[0] + (player.plane[0] * @camera_x)
      @direction_y = player.direction[1] + (player.plane[1] * @camera_x)
    end
  end

  class RayCaster
    def initialize(map, player, ray)
      @map = map
      @player = player
      @ray = ray
      @map_x = player.position[0].to_i
      @map_y = player.position[1].to_i
    end

    def cast
      setup_dda
      perform_dda
      calculate_intersection if @hit
    end

    private

    def setup_dda
      @delta_dist_x = @ray.direction_x.abs < 0.00001 ? Float::INFINITY : (1.0 / @ray.direction_x.abs)
      @delta_dist_y = @ray.direction_y.abs < 0.00001 ? Float::INFINITY : (1.0 / @ray.direction_y.abs)

      @step_x = @ray.direction_x.negative? ? -1 : 1
      @step_y = @ray.direction_y.negative? ? -1 : 1

      @side_dist_x = if @ray.direction_x.negative?
                       (@player.position[0] - @map_x) * @delta_dist_x
                     else
                       (@map_x + 1.0 - @player.position[0]) * @delta_dist_x
                     end
      @side_dist_y = if @ray.direction_y.negative?
                       (@player.position[1] - @map_y) * @delta_dist_y
                     else
                       (@map_y + 1.0 - @player.position[1]) * @delta_dist_y
                     end

      @hit = false
      @side = 0
    end

    def perform_dda
      until @hit
        if @side_dist_x < @side_dist_y
          @side_dist_x += @delta_dist_x
          @map_x += @step_x
          @side = 0
        else
          @side_dist_y += @delta_dist_y
          @map_y += @step_y
          @side = 1
        end

        @hit = @map.wall_at?(@map_x, @map_y)
      end
    end

    def calculate_intersection
      perp_wall_dist = if @side.zero?
                         (@map_x - @player.position[0] + ((1 - @step_x) / 2)) / @ray.direction_x
                       else
                         (@map_y - @player.position[1] + ((1 - @step_y) / 2)) / @ray.direction_y
                       end

      WallIntersection.new(
        distance: perp_wall_dist,
        side: @side,
        ray_dir_x: @ray.direction_x,
        ray_dir_y: @ray.direction_y,
        wall_x: @map_x.to_f + ((1 - @step_x) / 2),
        wall_y: @map_y.to_f + ((1 - @step_y) / 2),
        player_x: @player.position[0],
        player_y: @player.position[1],
        map_x: @map_x,
        map_y: @map_y,
        step_x: @step_x,
        step_y: @step_y
      )
    end
  end

  class WallIntersection
    attr_reader :distance, :side, :ray_dir_x, :ray_dir_y, :wall_x, :wall_y, :player_x, :player_y,
                :map_x, :map_y, :step_x, :step_y

    def initialize(distance:, side:, ray_dir_x:, ray_dir_y:, wall_x: 0.0, wall_y: 0.0,
                   player_x: 0.0, player_y: 0.0, map_x: 0, map_y: 0, step_x: 0, step_y: 0)
      @distance = distance
      @side = side
      @ray_dir_x = ray_dir_x
      @ray_dir_y = ray_dir_y
      @wall_x = wall_x
      @wall_y = wall_y
      @player_x = player_x
      @player_y = player_y
      @map_x = map_x
      @map_y = map_y
      @step_x = step_x
      @step_y = step_y
    end
  end

  class MinimapRenderer
    MINIMAP_SIZE = 150
    MINIMAP_MARGIN = 10
    PLAYER_SIZE = 4
    ARROW_SIZE = 8
    WALL_COLOR = Gosu::Color.new(255, 200, 200, 200)
    EMPTY_COLOR = Gosu::Color.new(255, 50, 50, 50)
    PLAYER_COLOR = Gosu::Color::RED
    ARROW_COLOR = Gosu::Color::YELLOW

    def initialize(window, map)
      @window = window
      @map = map
      @cell_size = MINIMAP_SIZE / [@map.width, @map.height].max
      @font = Gosu::Font.new(14)
      @logger = Logger.instance
    end

    def render(player)
      draw_background
      draw_walls
      draw_player(player)
      draw_rotation_angle(player)

      @logger.verbose("Minimap rendered at (#{@window.width - MINIMAP_SIZE - MINIMAP_MARGIN}, #{@window.height - MINIMAP_SIZE - MINIMAP_MARGIN})")
      @logger.verbose("Player position on minimap: (#{player.position[0] * @cell_size}, #{player.position[1] * @cell_size})")
      @logger.verbose("Player rotation: #{(Math.atan2(player.direction[1],
                                                      player.direction[0]) * 180 / Math::PI).round}°")
    end

    private

    def draw_background
      x = @window.width - MINIMAP_SIZE - MINIMAP_MARGIN
      y = @window.height - MINIMAP_SIZE - MINIMAP_MARGIN
      @window.draw_quad(
        x, y, EMPTY_COLOR,
        x + MINIMAP_SIZE, y, EMPTY_COLOR,
        x, y + MINIMAP_SIZE, EMPTY_COLOR,
        x + MINIMAP_SIZE, y + MINIMAP_SIZE, EMPTY_COLOR
      )
    end

    def draw_walls
      @map.height.times do |y|
        @map.width.times do |x|
          draw_cell(x, y, WALL_COLOR) if @map.wall_at?(x, y)
        end
      end
    end

    def draw_cell(x, y, color)
      base_x = @window.width - MINIMAP_SIZE - MINIMAP_MARGIN + (x * @cell_size)
      base_y = @window.height - MINIMAP_SIZE - MINIMAP_MARGIN + (y * @cell_size)
      @window.draw_quad(
        base_x, base_y, color,
        base_x + @cell_size, base_y, color,
        base_x, base_y + @cell_size, color,
        base_x + @cell_size, base_y + @cell_size, color
      )
    end

    def draw_player(player)
      x = @window.width - MINIMAP_SIZE - MINIMAP_MARGIN + (player.position[0] * @cell_size)
      y = @window.height - MINIMAP_SIZE - MINIMAP_MARGIN + (player.position[1] * @cell_size)

      # Draw player dot
      @window.draw_quad(
        x - (PLAYER_SIZE / 2), y - (PLAYER_SIZE / 2), PLAYER_COLOR,
        x + (PLAYER_SIZE / 2), y - (PLAYER_SIZE / 2), PLAYER_COLOR,
        x - (PLAYER_SIZE / 2), y + (PLAYER_SIZE / 2), PLAYER_COLOR,
        x + (PLAYER_SIZE / 2), y + (PLAYER_SIZE / 2), PLAYER_COLOR
      )

      # Draw direction arrow
      arrow_x = x + (player.direction[0] * ARROW_SIZE)
      arrow_y = y + (player.direction[1] * ARROW_SIZE)

      # Arrow head points
      angle = Math.atan2(player.direction[1], player.direction[0])
      left_x = arrow_x - (Math.cos(angle + (Math::PI / 4)) * (ARROW_SIZE / 2))
      left_y = arrow_y - (Math.sin(angle + (Math::PI / 4)) * (ARROW_SIZE / 2))
      right_x = arrow_x - (Math.cos(angle - (Math::PI / 4)) * (ARROW_SIZE / 2))
      right_y = arrow_y - (Math.sin(angle - (Math::PI / 4)) * (ARROW_SIZE / 2))

      # Draw arrow line
      @window.draw_line(x, y, ARROW_COLOR, arrow_x, arrow_y, ARROW_COLOR)
      # Draw arrow head
      @window.draw_line(arrow_x, arrow_y, ARROW_COLOR, left_x, left_y, ARROW_COLOR)
      @window.draw_line(arrow_x, arrow_y, ARROW_COLOR, right_x, right_y, ARROW_COLOR)
    end

    def draw_rotation_angle(player)
      angle = (Math.atan2(player.direction[1], player.direction[0]) * 180 / Math::PI).round
      angle = (angle + 360) % 360
      text = "#{angle}°"
      x = @window.width - MINIMAP_SIZE - MINIMAP_MARGIN
      y = @window.height - MINIMAP_SIZE - MINIMAP_MARGIN - 20
      @font.draw_text(text, x, y, 0, 1, 1, ARROW_COLOR)
    end
  end
end
