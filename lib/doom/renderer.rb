# frozen_string_literal: true

require 'gosu'
require_relative 'map'
require_relative 'logger'

module Doom
  class Renderer
    WALL_COLORS = {
      north: Gosu::Color.new(255, 255, 0, 0),    # Red
      south: Gosu::Color.new(255, 0, 255, 0),    # Green
      east: Gosu::Color.new(255, 0, 0, 255),     # Blue
      west: Gosu::Color.new(255, 255, 255, 0)    # Yellow
    }.freeze
    MAX_DISTANCE = 20.0
    MAX_BATCH_SIZE = 20_000
    FLOOR_COLOR = Gosu::Color.new(255, 50, 50, 50)
    CEILING_COLOR = Gosu::Color.new(255, 100, 100, 150)

    attr_reader :last_render_time, :last_texture_time

    def initialize(window, map, textures = {})
      @window = window
      @map = map
      @width = window.width
      @height = window.height
      @textures = textures
      @default_texture = @textures.values.first
      @line_batch = []
      @z_buffer = Array.new(window.width)
      @logger = Logger.instance
      setup_texture_cache
    end

    def render(player)
      start_time = Time.now
      render_background
      render_walls(player)
      render_minimap(player)
      @last_render_time = Time.now - start_time
    end

    private

    def setup_texture_cache
      return unless @default_texture

      @tex_offsets = {}
      @tex_offsets[0] = Array.new(@default_texture.height) { |y| y * @default_texture.width }
      @default_texture.mipmaps.each_with_index do |mipmap, level|
        @tex_offsets[level + 1] = Array.new(mipmap[:height]) { |y| y * mipmap[:width] }
      end
    end

    def render_background
      # Ceiling
      @window.draw_quad(
        0, 0, CEILING_COLOR,
        @width, 0, CEILING_COLOR,
        0, @height / 2, CEILING_COLOR,
        @width, @height / 2, CEILING_COLOR
      )

      # Floor
      @window.draw_quad(
        0, @height / 2, FLOOR_COLOR,
        @width, @height / 2, FLOOR_COLOR,
        0, @height, FLOOR_COLOR,
        @width, @height, FLOOR_COLOR
      )
    end

    def render_walls(player)
      @line_batch.clear
      @z_buffer.fill(Float::INFINITY)

      ray_start = Time.now
      texture_time = 0
      batch_time = 0

      # Pre-calculate ray directions
      ray_directions = @width.times.map do |x|
        ray = Ray.new(player, x, @width)
        [ray.direction_x, ray.direction_y]
      end

      # Calculate wall intersections
      intersections = ray_directions.map.with_index do |(ray_dir_x, ray_dir_y), x|
        ray = Ray.new(player, x, @width)
        intersection = ray_cast(ray, player)
        if intersection && intersection.distance < MAX_DISTANCE
          intersection.instance_variable_set(:@x, x)
          intersection
        end
      end.compact.sort_by(&:distance)

      # Draw wall slices
      intersections.each do |intersection|
        x = intersection.x
        @z_buffer[x] = intersection.distance
        draw_wall_slice(x, intersection, @height, player)
      end

      flush_line_batch
    end

    def ray_cast(ray, player)
      RayCaster.new(@map, player, ray).cast
    end

    def draw_wall_slice(x, intersection, height, player)
      perp_wall_dist = if intersection.side.zero?
                         (intersection.map_x - player.position[0] + ((1 - intersection.step_x) / 2)) / intersection.ray_dir_x
                       else
                         (intersection.map_y - player.position[1] + ((1 - intersection.step_y) / 2)) / intersection.ray_dir_y
                       end

      line_height = (height / perp_wall_dist).to_i
      draw_start = [(-line_height / 2) + (height / 2), 0].max
      draw_end = [(line_height / 2) + (height / 2), height - 1].min

      if @default_texture
        tex_x = calculate_texture_x(intersection)
        draw_textured_slice(x, draw_start, draw_end, tex_x, line_height, perp_wall_dist)
      else
        draw_colored_slice(x, draw_start, draw_end, intersection)
      end
    end

    def calculate_texture_x(intersection)
      return 0 unless @default_texture

      wall_x = if intersection.wall_x
                 intersection.wall_x
               elsif intersection.side.zero?
                 intersection.player_y + (intersection.distance * intersection.ray_dir_y)
               else
                 intersection.player_x + (intersection.distance * intersection.ray_dir_x)
               end

      wall_x -= wall_x.floor
      (wall_x * @default_texture.width).to_i
    end

    def draw_textured_slice(x, draw_start, draw_end, tex_x, line_height, perp_wall_dist)
      return if draw_start >= draw_end

      step = @default_texture.height.to_f / line_height
      tex_pos = (draw_start - (@height / 2) + (line_height / 2)) * step

      fog_factor = (perp_wall_dist / MAX_DISTANCE).clamp(0.0, 0.8)

      (draw_start...draw_end).each do |y|
        tex_y = tex_pos.to_i & (@default_texture.height - 1)
        color_index = @default_texture.data[@tex_offsets[0][tex_y] + tex_x]
        color = get_cached_color(color_index)
        color = apply_fog(color, 1.0 - fog_factor) if fog_factor > 0
        add_to_batch(x, y, x + 1, y + 1, color)
        tex_pos += step
      end
    end

    def draw_colored_slice(x, draw_start, draw_end, intersection)
      color = determine_wall_color(intersection)
      add_to_batch(x, draw_start, x, draw_end, color)
    end

    def determine_wall_color(intersection)
      if intersection.side.zero?
        intersection.step_x > 0 ? WALL_COLORS[:west] : WALL_COLORS[:east]
      else
        intersection.step_y > 0 ? WALL_COLORS[:north] : WALL_COLORS[:south]
      end
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

    def apply_fog(color, fog_factor)
      r = (color.red * fog_factor).to_i
      g = (color.green * fog_factor).to_i
      b = (color.blue * fog_factor).to_i
      Gosu::Color.new(color.alpha, r, g, b)
    end

    def get_cached_color(color_index)
      return Gosu::Color::BLACK unless color_index.is_a?(Integer)

      Gosu::Color.new(255, color_index, color_index, color_index)
    end

    def render_minimap(player)
      size = 150
      margin = 10
      cell_size = size / @map.width.to_f

      # Draw minimap background
      x = @window.width - size - margin
      y = margin
      @window.draw_quad(
        x, y, Gosu::Color::BLACK,
        x + size, y, Gosu::Color::BLACK,
        x, y + size, Gosu::Color::BLACK,
        x + size, y + size, Gosu::Color::BLACK
      )

      # Draw walls
      @map.height.times do |map_y|
        @map.width.times do |map_x|
          next if @map.empty?(map_x, map_y)

          draw_minimap_cell(map_x, map_y, Gosu::Color::WHITE, size, margin, cell_size)
        end
      end

      # Draw player
      player_x = x + (player.position[0] * cell_size)
      player_y = y + (player.position[1] * cell_size)
      player_size = 4
      @window.draw_quad(
        player_x - player_size, player_y - player_size, Gosu::Color::RED,
        player_x + player_size, player_y - player_size, Gosu::Color::RED,
        player_x - player_size, player_y + player_size, Gosu::Color::RED,
        player_x + player_size, player_y + player_size, Gosu::Color::RED
      )

      # Draw player direction
      dir_length = 10
      dir_x = player_x + (player.direction[0] * dir_length)
      dir_y = player_y + (player.direction[1] * dir_length)
      @window.draw_line(player_x, player_y, Gosu::Color::RED, dir_x, dir_y, Gosu::Color::RED)
    end

    def draw_minimap_cell(x, y, color, size, margin, cell_size)
      base_x = @window.width - size - margin + (x * cell_size)
      base_y = margin + (y * cell_size)
      @window.draw_quad(
        base_x, base_y, color,
        base_x + cell_size - 1, base_y, color,
        base_x, base_y + cell_size - 1, color,
        base_x + cell_size - 1, base_y + cell_size - 1, color
      )
    end
  end

  class Ray
    attr_reader :direction_x, :direction_y

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
      setup_dda
    end

    def cast
      perform_dda
      calculate_intersection
    end

    private

    def setup_dda
      @delta_dist_x = @ray.direction_x.abs < 0.00001 ? Float::INFINITY : (1.0 / @ray.direction_x.abs)
      @delta_dist_y = @ray.direction_y.abs < 0.00001 ? Float::INFINITY : (1.0 / @ray.direction_y.abs)

      @map_x = @player.position[0].to_i
      @map_y = @player.position[1].to_i

      @step_x = @ray.direction_x < 0 ? -1 : 1
      @step_y = @ray.direction_y < 0 ? -1 : 1

      @side_dist_x = if @ray.direction_x < 0
                       (@player.position[0] - @map_x) * @delta_dist_x
                     else
                       (@map_x + 1.0 - @player.position[0]) * @delta_dist_x
                     end

      @side_dist_y = if @ray.direction_y < 0
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

        @hit = true unless @map.empty?(@map_x, @map_y)
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
    attr_reader :distance, :side, :ray_dir_x, :ray_dir_y, :wall_x, :wall_y,
                :player_x, :player_y, :map_x, :map_y, :step_x, :step_y, :x

    def initialize(distance:, side:, ray_dir_x:, ray_dir_y:, wall_x: 0.0, wall_y: 0.0,
                   player_x: 0.0, player_y: 0.0, map_x: 0, map_y: 0, step_x: 0, step_y: 0, x: nil)
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
      @x = x
    end
  end
end
