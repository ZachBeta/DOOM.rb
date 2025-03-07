# frozen_string_literal: true

require 'gosu'
require_relative 'renderer'
require_relative 'player'
require_relative 'map'
require_relative 'logger'
require_relative 'input_handler'
require_relative 'wad_file'
require_relative 'texture_composer'

module Doom
  class Game < Gosu::Window
    SCREEN_WIDTH = 800
    SCREEN_HEIGHT = 600
    TITLE = 'DOOM.rb'
    DEFAULT_WAD_PATH = File.expand_path('../../freedoom.wad', __dir__)

    def initialize(wad_path = DEFAULT_WAD_PATH)
      super(SCREEN_WIDTH, SCREEN_HEIGHT)
      self.caption = TITLE

      @logger = Logger.instance
      @logger.info('Initializing DOOM.rb')

      load_wad(wad_path)
      @map = Map.new
      @player = Player.new(@map)
      @renderer = OpenGLRenderer.new(self, @map, @textures)
      @input_handler = InputHandler.new(@player)
      @game_clock = GameClock.new
      @font = Gosu::Font.new(20)

      @logger.info('Game initialized successfully')
    end

    def start
      @logger.info('Starting game loop')
      show
    end

    def update
      delta_time = @game_clock.tick
      @input_handler.handle_input(self, delta_time)
      @player.update(delta_time)

      @logger.verbose("Frame delta: #{delta_time}")
      @logger.verbose("Player position: #{@player.position}, direction: #{@player.direction}")
      @logger.verbose("Noclip mode: #{@player.noclip_mode}")
    end

    def draw
      @renderer.render(@player)
      draw_hud
    end

    def button_down(id)
      close if id == Gosu::KB_ESCAPE
      if id == Gosu::KB_W && (Gosu.button_down?(Gosu::KB_LEFT_META) || Gosu.button_down?(Gosu::KB_RIGHT_META))
        close
      end
      if id == Gosu::KB_ESCAPE || (id == Gosu::KB_W && (Gosu.button_down?(Gosu::KB_LEFT_META) || Gosu.button_down?(Gosu::KB_RIGHT_META)))
        @logger.info('Game closing')
      end
    end

    private

    def load_wad(wad_path)
      @logger.info("Loading WAD file: #{wad_path}")
      @wad = WadFile.new(wad_path)
      @textures = {}

      # Load TEXTURE1 and TEXTURE2
      %w[TEXTURE1 TEXTURE2].each do |texture_name|
        next unless @wad.lump(texture_name)

        # Parse PNAMES
        pnames = []
        if pnames_lump = @wad.lump('PNAMES')
          data = pnames_lump.read
          num_pnames = data[0, 4].unpack1('V')
          offset = 4
          num_pnames.times do
            pname = data[offset, 8].unpack1('Z8')
            pnames << pname
            offset += 8
          end
        end

        @wad.parse_texture(texture_name, pnames).each do |texture|
          patches = {}
          texture.patches.each do |patch|
            patch_name = patch.name || pnames[patch.patch_index]
            next unless patch_name

            patch_lump = @wad.lump(patch_name)
            next unless patch_lump

            patches[patch_name] = create_patch_from_lump(patch_lump)
          end

          next if patches.empty?

          composer = TextureComposer.new
          @textures[texture.name] = composer.compose(texture, patches)
        end
      end

      @logger.info("Loaded #{@textures.size} textures")
    end

    def create_patch_from_lump(lump)
      data = lump.read
      width = data[0, 2].unpack1('v')
      height = data[2, 2].unpack1('v')
      left_offset = data[4, 2].unpack1('v')
      top_offset = data[6, 2].unpack1('v')

      # Skip header (8 bytes) and column offsets (width * 4 bytes)
      data_start = 8 + (width * 4)
      raw_data = data[data_start..].unpack('C*')

      # Create a blank patch data array
      patch_data = Array.new(width * height, 0)

      # Process each column
      width.times do |x|
        offset = data[8 + (x * 4), 4].unpack1('V')
        pos = offset - data_start
        y = 0

        while y < height && pos < raw_data.length
          # Read post header
          top = raw_data[pos]
          pos += 1
          break if top == 255 # End of column marker

          length = raw_data[pos]
          pos += 2 # Skip length and unused byte

          # Copy pixels
          length.times do |i|
            patch_data[((top + i) * width) + x] = raw_data[pos] if (top + i) < height && x < width
            pos += 1
          end
          pos += 1 # Skip unused byte
        end
      end

      Patch.new(
        name: lump.name,
        width: width,
        height: height,
        data: patch_data
      )
    end

    def draw_hud
      # FPS Display
      fps_text = "FPS: #{@game_clock.fps}"
      @font.draw_text(fps_text, 10, 10, 0, 1, 1, Gosu::Color::YELLOW)

      # Performance Stats
      render_time = @renderer.last_render_time
      texture_time = @renderer.last_texture_time
      perf_text = "Render: #{(render_time * 1000).round(2)}ms | Texture: #{(texture_time * 1000).round(2)}ms"
      @font.draw_text(perf_text, 10, 30, 0, 1, 1, Gosu::Color::YELLOW)

      # Noclip Status
      noclip_text = "NOCLIP: #{@player.noclip_mode ? 'ON' : 'OFF'} (Press N to toggle)"
      noclip_color = @player.noclip_mode ? Gosu::Color::GREEN : Gosu::Color::WHITE
      @font.draw_text(noclip_text, 10, 50, 0, 1, 1, noclip_color)

      # Position Display
      pos_text = "POS: (#{@player.position[0].round(2)}, #{@player.position[1].round(2)})"
      @font.draw_text(pos_text, 10, 70, 0, 1, 1, Gosu::Color::WHITE)
    end
  end

  class GameClock
    def initialize
      @last_time = Gosu.milliseconds
      @frames = 0
      @fps = 0
      @last_fps_update = @last_time
      @logger = Logger.instance
    end

    def tick
      current_time = Gosu.milliseconds
      delta_time = (current_time - @last_time) / 1000.0
      @last_time = current_time

      @frames += 1
      if current_time - @last_fps_update >= 1000
        @fps = @frames
        @logger.info("FPS: #{@fps}")
        @frames = 0
        @last_fps_update = current_time
      end

      delta_time
    end

    attr_reader :fps
  end
end
