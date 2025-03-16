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
      @logger.info('Game: Initializing DOOM.rb', component: 'Game')

      begin
        @logger.log_game_event('initialization_start', { wad_path: wad_path })

        @logger.info('Game: Creating window manager', component: 'Game')
        @window_manager = Window::WindowManager.new
        @logger.log_game_event('window_manager_created')

        @logger.info('Game: Creating renderer', component: 'Game')
        @renderer = Renderer::BaseRenderer.new(@window_manager, @window_manager.width,
                                               @window_manager.height)
        @logger.log_game_event('renderer_created')

        @logger.info('Game: Creating game objects', component: 'Game')
        @map = Map.new
        @player = Player.new(@map)
        @game_clock = GameClock.new
        @input_handler = InputHandler.new(@player)
        @logger.log_game_event('game_objects_created')

        # Connect renderer with game objects
        @logger.info('Game: Connecting renderer with game objects', component: 'Game')
        @renderer.set_game_objects(@map, @player)
        @logger.log_game_event('renderer_connected')

        if wad_path
          load_wad(wad_path)
          @logger.log_game_event('wad_loaded', { path: wad_path })
        end

        @logger.info('Game: Initialization complete', component: 'Game')
        @logger.log_game_event('initialization_complete')
      rescue StandardError => e
        @logger.log_game_event('initialization_error', { error: e.message, backtrace: e.backtrace })
        @logger.error("Game: Error during initialization: #{e.message}", component: 'Game')
        @logger.error(e.backtrace.join("\n"), component: 'Game')
        cleanup
        raise
      end
    end

    def start
      return unless @renderer && @map && @player

      @logger.info('Game: Starting game loop', component: 'Game')
      @logger.log_game_event('game_loop_start')

      begin
        @logger.log_game_event('window_show')
        @window_manager.show do
          update(@game_clock.tick)
          process_input
          render
        end
      rescue StandardError => e
        @logger.log_game_event('game_loop_error', { error: e.message, backtrace: e.backtrace })
        @logger.error("Game: Error in game loop: #{e.message}", component: 'Game')
        @logger.error(e.backtrace.join("\n"), component: 'Game')
      end
    end

    def cleanup
      @logger.info('Game: Starting cleanup sequence', component: 'Game')
      @logger.log_game_event('cleanup_start')
      begin
        @window_manager.close! if @window_manager
        @logger.log_game_event('cleanup_complete')
        @logger.info('Game: Cleanup complete', component: 'Game')
      rescue StandardError => e
        @logger.log_game_event('cleanup_error', { error: e.message, backtrace: e.backtrace })
        @logger.error("Game: Error during cleanup: #{e.message}", component: 'Game')
        @logger.error(e.backtrace.join("\n"), component: 'Game')
      end
    end

    private

    def update(delta_time)
      @logger.debug('Game: Updating game state', component: 'Game')
      @player.update(delta_time)
    end

    def render
      @logger.debug('Game: Rendering frame', component: 'Game')
      @renderer.render
    end

    def process_input
      @logger.debug('Game: Processing input', component: 'Game')
      begin
        @input_handler.process_input(@window_manager)
      rescue StandardError => e
        @logger.log_game_event('input_error', { error: e.message, backtrace: e.backtrace })
        @logger.error("Game: Error processing input: #{e.message}", component: 'Game')
        @logger.error(e.backtrace.join("\n"), component: 'Game')
      end
    end

    def load_wad(wad_path)
      @logger.info("Game: Loading WAD file: #{wad_path}", component: 'Game')
      return unless File.exist?(wad_path)

      begin
        @wad = WadFile.new(wad_path)
        @wad.load
        @logger.info('Game: WAD file loaded successfully', component: 'Game')
      rescue StandardError => e
        @logger.log_game_event('wad_load_error', { error: e.message, backtrace: e.backtrace })
        @logger.error("Game: Error loading WAD file: #{e.message}", component: 'Game')
        @logger.error(e.backtrace.join("\n"), component: 'Game')
      end
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
