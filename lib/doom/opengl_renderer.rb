require 'gosu'
require_relative 'logger'
require_relative 'base_renderer'

module Doom
  class OpenGLRenderer < BaseRenderer
    FOV = Math::PI / 3.0 # 60 degrees field of view
    BATCH_SIZE = 100 # Number of walls to batch together
    LOD_DISTANCES = [5, 10, 15] # Distance thresholds for LOD levels

    def initialize(window, map, textures = {})
      super
      setup_opengl
      setup_textures(textures)
      @vertex_buffer = []
      @texture_coords = []
      @wall_count = 0
      @cached_walls = {}
      @cached_vertices = {}
      @cached_tex_coords = {}
    end

    private

    def setup_opengl
      @logger ||= Logger.instance
      @logger.info('Setting up OpenGL renderer')
      # OpenGL setup will go here
      @logger.debug('OpenGL setup complete')
    end

    def setup_textures(textures)
      @texture_ids = {}
      @logger ||= Logger.instance
      @logger.debug('Setting up textures')

      textures.each do |name, texture|
        @logger.debug("Loading texture: #{name}")
        @texture_ids[name] = load_texture(texture)
        create_mipmap_chain(texture)
      end

      @logger.debug("Loaded #{@texture_ids.size} textures")
    end

    def create_mipmap_chain(texture)
      @logger.debug("Creating mipmap chain for texture #{texture.width}x#{texture.height}")
      chain = []
      current_width = texture.width
      current_height = texture.height
      current_data = texture.data.dup

      while current_width > 1 && current_height > 1
        next_width = [current_width / 2, 1].max
        next_height = [current_height / 2, 1].max
        next_data = Array.new(next_width * next_height, 0)

        (0...next_height).each do |y|
          (0...next_width).each do |x|
            # Calculate source indices with bounds checking
            x2 = x * 2
            y2 = y * 2
            i1 = (y2 * current_width) + x2
            i2 = i1 + (x2 + 1 < current_width ? 1 : 0)
            i3 = ((y2 + 1 < current_height ? y2 + 1 : y2) * current_width) + x2
            i4 = i3 + (x2 + 1 < current_width ? 1 : 0)

            # Calculate average color index with bounds checking
            sum = current_data[i1].to_i
            count = 1

            if x2 + 1 < current_width
              sum += current_data[i2].to_i
              count += 1
            end

            if y2 + 1 < current_height
              sum += current_data[i3].to_i
              count += 1
            end

            if x2 + 1 < current_width && y2 + 1 < current_height
              sum += current_data[i4].to_i
              count += 1
            end

            next_data[(y * next_width) + x] = (sum / count).to_i
          end
        end

        chain << {
          width: next_width,
          height: next_height,
          data: next_data
        }

        break if next_width == 1 || next_height == 1

        current_width = next_width
        current_height = next_height
        current_data = next_data
      end

      @logger.debug("Created #{chain.size} mipmap levels")
      texture.instance_variable_set(:@mipmaps, chain)
    end

    def load_texture(texture)
      # Convert texture data to Gosu::Image
      Gosu::Image.new(texture.data.pack('C*'),
                      width: texture.width,
                      height: texture.height,
                      tileable: true)
    end

    def render(player)
      start_time = Time.now
      @logger ||= Logger.instance
      @logger.info('OpenGL renderer starting frame')

      @window.gl do
        setup_view(player)
        wall_start = Time.now
        render_walls(player)
        @wall_render_time = Time.now - wall_start
      end

      minimap_start = Time.now
      render_minimap(player)
      @minimap_render_time = Time.now - minimap_start

      end_time = Time.now
      @last_render_time = end_time - start_time
      @logger.debug("OpenGL frame timing - Total: #{(@last_render_time * 1000).round(2)}ms, " \
                    "Walls: #{(@wall_render_time * 1000).round(2)}ms, " \
                    "Minimap: #{(@minimap_render_time * 1000).round(2)}ms")
      @logger.debug("Texture batches: #{@wall_count}")
    end

    def setup_view(player)
      width = @window.width
      height = @window.height

      Gosu.gl do
        glEnable(GL_DEPTH_TEST)
        glEnable(GL_TEXTURE_2D)
        glEnable(GL_BLEND)
        glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA)

        glViewport(0, 0, width, height)
        glMatrixMode(GL_PROJECTION)
        glLoadIdentity
        gluPerspective(FOV * 180 / Math::PI, width.to_f / height.to_f, 0.1, MAX_DISTANCE)

        glMatrixMode(GL_MODELVIEW)
        glLoadIdentity

        glRotatef(-player.angle * 180 / Math::PI, 0, 0, 1)
        glTranslatef(-player.position[0], -player.position[1], -0.5)
      end
    end

    def render_walls(player)
      wall_start = Time.now

      # Collect visible walls with frustum culling
      visible_walls = collect_visible_walls(player)
      @logger.debug("Visible walls: #{visible_walls.size}")

      # Sort walls by texture and distance for efficient batching
      batches = create_wall_batches(visible_walls, player)
      @logger.debug("Texture batches: #{batches.size}")

      # Render wall batches
      Gosu.gl do
        glEnableClientState(GL_VERTEX_ARRAY)
        glEnableClientState(GL_TEXTURE_COORD_ARRAY)

        batches.each do |texture_id, walls|
          next if walls.empty?

          # Bind texture
          glBindTexture(GL_TEXTURE_2D, texture_id)

          # Get or create cached buffers for this batch
          vertices, tex_coords = get_cached_buffers(walls)

          # Set up vertex and texture coordinate arrays
          glVertexPointer(3, GL_FLOAT, 0, vertices.pack('f*'))
          glTexCoordPointer(2, GL_FLOAT, 0, tex_coords.pack('f*'))

          # Draw the batch
          glDrawArrays(GL_TRIANGLES, 0, walls.size * 6)
        end

        glDisableClientState(GL_VERTEX_ARRAY)
        glDisableClientState(GL_TEXTURE_COORD_ARRAY)
      end

      @wall_render_time = Time.now - wall_start
    end

    def collect_visible_walls(player)
      walls = []
      view_direction = [
        Math.cos(player.angle),
        Math.sin(player.angle)
      ]

      @map.height.times do |y|
        @map.width.times do |x|
          next if @map.empty?(x, y)

          # Calculate vector to wall center
          dx = x + 0.5 - player.position[0]
          dy = y + 0.5 - player.position[1]
          distance = Math.sqrt((dx * dx) + (dy * dy))

          next if distance > MAX_DISTANCE

          # Check if wall is within field of view
          angle = Math.atan2(dy, dx) - player.angle
          angle -= (2 * Math::PI) if angle > Math::PI
          angle += (2 * Math::PI) if angle < -Math::PI

          next if angle.abs > FOV / 2

          walls << {
            x: x,
            y: y,
            distance: distance,
            lod_level: determine_lod_level(distance)
          }
        end
      end

      walls.sort_by! { |w| -w[:distance] } # Sort back to front
    end

    def determine_lod_level(distance)
      LOD_DISTANCES.each_with_index do |threshold, index|
        return index if distance <= threshold
      end
      LOD_DISTANCES.size # Maximum LOD level
    end

    def create_wall_batches(walls, player)
      batches = Hash.new { |h, k| h[k] = [] }

      walls.each_slice(BATCH_SIZE) do |batch|
        batch.each do |wall|
          texture_id = select_wall_texture(wall)
          batches[texture_id] << wall
        end
      end

      batches
    end

    def select_wall_texture(wall)
      # For now, just use the first texture
      # TODO: Implement proper texture selection based on wall properties
      @texture_ids.values.first
    end

    def get_cached_buffers(walls)
      cache_key = walls.map { |w| "#{w[:x]},#{w[:y]},#{w[:lod_level]}" }.join('|')

      if @cached_vertices[cache_key]
        return [@cached_vertices[cache_key],
                @cached_tex_coords[cache_key]]
      end

      vertices = []
      tex_coords = []

      walls.each do |wall|
        add_wall_to_buffers(wall, vertices, tex_coords)
      end

      @cached_vertices[cache_key] = vertices
      @cached_tex_coords[cache_key] = tex_coords

      [vertices, tex_coords]
    end

    def add_wall_to_buffers(wall, vertices, tex_coords)
      x = wall[:x]
      y = wall[:y]
      lod = wall[:lod_level]

      # Adjust texture coordinates based on LOD level
      tex_scale = 1.0 / (2**lod)

      vertices.concat([
                        # First triangle
                        x, y, 0,
                        x + 1, y, 0,
                        x, y, 1,

                        # Second triangle
                        x + 1, y, 0,
                        x + 1, y, 1,
                        x, y, 1
                      ])

      tex_coords.concat([
                          # First triangle
                          0, tex_scale,
                          tex_scale, tex_scale,
                          0, 0,

                          # Second triangle
                          tex_scale, tex_scale,
                          tex_scale, 0,
                          0, 0
                        ])
    end

    def render_minimap(player)
      minimap_start = Time.now
      scale = 10
      margin = 10

      x_offset = @window.width - (@map.width * scale) - margin
      y_offset = @window.height - (@map.height * scale) - margin

      # Draw map cells
      @map.height.times do |y|
        @map.width.times do |x|
          next if @map.empty?(x, y)

          @window.draw_quad(
            x_offset + (x * scale), y_offset + (y * scale), Gosu::Color::WHITE,
            x_offset + ((x + 1) * scale), y_offset + (y * scale), Gosu::Color::WHITE,
            x_offset + (x * scale), y_offset + ((y + 1) * scale), Gosu::Color::WHITE,
            x_offset + ((x + 1) * scale), y_offset + ((y + 1) * scale), Gosu::Color::WHITE,
            1
          )
        end
      end

      # Draw player position
      px = x_offset + (player.position[0] * scale)
      py = y_offset + (player.position[1] * scale)

      @window.draw_triangle(
        px, py, Gosu::Color::RED,
        px + (Math.cos(player.angle) * scale), py + (Math.sin(player.angle) * scale), Gosu::Color::RED,
        px + (Math.cos(player.angle + (Math::PI * 0.8)) * scale * 0.5),
        py + (Math.sin(player.angle + (Math::PI * 0.8)) * scale * 0.5),
        Gosu::Color::RED,
        2
      )

      @minimap_render_time = Time.now - minimap_start
    end
  end
end
