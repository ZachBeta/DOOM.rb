# frozen_string_literal: true

require_relative 'player'
require_relative 'map'
require_relative 'logger'
require_relative 'wad_file'
require_relative 'config'
require_relative 'input_handler'
require_relative 'renderer/base_renderer'
require_relative 'window/window_manager'

module Doom
  class Game
    DEFAULT_WAD_PATH = Doom::Config::DEFAULT_WAD_PATH

    def initialize(wad_path = nil)
      @logger = Logger.instance
      @logger.info('Initializing DOOM.rb')

      @map = Map.new
      @player = Player.new(@map)
      @game_clock = GameClock.new
      @renderer = Renderer::BaseRenderer.new
      @input_handler = InputHandler.new(@player)

      # Connect renderer with game objects
      @renderer.set_game_objects(@map, @player)

      load_wad(wad_path) if wad_path
    end

    def start
      @logger.info('Starting game loop')
      game_loop
    end

    def cleanup
      @logger.info('Starting game cleanup sequence')
      @renderer.cleanup if @renderer
      @logger.info('Game cleanup complete')
    end

    private

    def game_loop
      @logger.info('Entering game loop')

      until @renderer.window_should_close?
        delta_time = @game_clock.tick
        update(delta_time)
        render
        process_input
      end

      @logger.info('Exiting game loop')
      cleanup
    end

    def update(delta_time)
      @player.update(delta_time)
    end

    def render
      @renderer.render
    end

    def process_input
      # Pass the window manager instance instead of raw GLFW window
      @input_handler.process_input(@renderer.instance_variable_get(:@window_manager))
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
