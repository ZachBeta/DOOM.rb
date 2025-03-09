# frozen_string_literal: true

require_relative 'window'
require_relative 'player'
require_relative 'map'
require_relative 'logger'
require_relative 'input_handler'
require_relative 'wad_file'

module Doom
  class Game
    DEFAULT_WAD_PATH = File.expand_path('../../data/wad/freedoom1.wad', __dir__)

    def initialize(wad_path = DEFAULT_WAD_PATH)
      @logger = Logger.instance
      @logger.info('Initializing DOOM.rb')

      load_wad(wad_path)
      @map = Map.new
      @player = Player.new(@map)
      @input_handler = InputHandler.new(@player)
      @game_clock = GameClock.new

      @logger.info('Game initialized successfully')
    end

    def start
      @logger.info('Starting game loop')
      game_loop
    ensure
      cleanup
    end

    private

    def cleanup
      @logger.info('Starting game cleanup sequence')
      begin
        @logger.info('Game cleanup sequence completed successfully')
      rescue StandardError => e
        @logger.error("Error during game cleanup: #{e.message}")
        @logger.error(e.backtrace.join("\n"))
        raise
      end
    end

    def game_loop
      loop do
        delta_time = @game_clock.tick
        @input_handler.handle_input(delta_time)
        @player.update(delta_time)

        @logger.verbose("Frame delta: #{delta_time}")
        @logger.verbose("Player position: #{@player.position}, direction: #{@player.direction}")
        @logger.verbose("Noclip mode: #{@player.noclip_mode}")
      end
    end

    def load_wad(wad_path)
      @logger.info("Loading WAD file: #{wad_path}")
      @wad_file = WadFile.new(wad_path)
      @logger.info('WAD file loaded successfully')
    end
  end

  class GameClock
    def initialize
      @last_time = Time.now
      @frames = 0
      @fps = 0
      @last_fps_update = @last_time
      @logger = Logger.instance
    end

    def tick
      current_time = Time.now
      delta_time = current_time - @last_time
      @last_time = current_time

      @frames += 1
      if current_time - @last_fps_update >= 1
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
