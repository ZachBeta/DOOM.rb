# frozen_string_literal: true

require_relative 'player'
require_relative 'map'
require_relative 'logger'
require_relative 'wad_file'

module Doom
  class Game
    DEFAULT_WAD_PATH = File.expand_path('../../data/wad/freedoom1.wad', __dir__)

    def initialize(wad_path = nil)
      @logger = Logger.instance
      @logger.info('Initializing DOOM.rb')

      @map = Map.new
      @player = Player.new(@map)
      @game_clock = GameClock.new

      load_wad(wad_path) if wad_path
    end

    def start
      @logger.info('Starting game loop')
      game_loop
    end

    def cleanup
      @logger.info('Starting game cleanup sequence')
      @logger.info('Game cleanup complete')
    end

    private

    def game_loop
      loop do
        delta_time = @game_clock.tick
        update(delta_time)
      end
    end

    def update(delta_time)
      @player.update(delta_time)
    end

    def load_wad(wad_path)
      @logger.info("Loading WAD file: #{wad_path}")
      return unless File.exist?(wad_path)

      @wad = WadFile.new(wad_path)
      @wad.load
    end
  end

  class GameClock
    def initialize
      @last_time = Time.now
    end

    def tick
      current_time = Time.now
      delta_time = current_time - @last_time
      @last_time = current_time
      delta_time
    end
  end
end
