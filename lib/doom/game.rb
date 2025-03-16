# frozen_string_literal: true

require_relative 'player'
require_relative 'map'
require_relative 'logger'
require_relative 'wad_file'
require_relative 'config'
require_relative 'input_handler'
require_relative 'renderer/base_renderer'
require_relative 'window/window_manager'
require_relative 'debug_db'

module Doom
  class Game
    DEFAULT_WAD_PATH = Doom::Config::DEFAULT_WAD_PATH

    def initialize(wad_path = nil)
      @logger = Logger.instance
      @debug_db = DebugDB.new
      @logger.info('Game: Initializing DOOM.rb')

      begin
        log_game_event('initialization_start', { wad_path: wad_path })

        @logger.info('Game: Creating window manager')
        @window_manager = Window::WindowManager.new
        log_game_event('window_manager_created')

        @logger.info('Game: Creating renderer')
        @renderer = Renderer::BaseRenderer.new(@window_manager, @window_manager.width,
                                               @window_manager.height)
        log_game_event('renderer_created')

        @logger.info('Game: Creating game objects')
        @map = Map.new
        @player = Player.new(@map)
        @game_clock = GameClock.new
        @input_handler = InputHandler.new(@player)
        log_game_event('game_objects_created')

        # Connect renderer with game objects
        @logger.info('Game: Connecting renderer with game objects')
        @renderer.set_game_objects(@map, @player)
        log_game_event('renderer_connected')

        if wad_path
          load_wad(wad_path)
          log_game_event('wad_loaded', { path: wad_path })
        end

        @logger.info('Game: Initialization complete')
        log_game_event('initialization_complete')
      rescue StandardError => e
        log_game_event('initialization_error', { error: e.message, backtrace: e.backtrace })
        @logger.error("Game: Error during initialization: #{e.message}")
        @logger.error(e.backtrace.join("\n"))
        cleanup
        raise
      end
    end

    def start
      return unless @renderer && @map && @player

      @logger.info('Game: Starting game loop')
      log_game_event('game_loop_start')

      begin
        log_game_event('window_show')
        @window_manager.show do
          update(@game_clock.tick)
          process_input
          render
        end
      rescue StandardError => e
        log_game_event('game_loop_error', { error: e.message, backtrace: e.backtrace })
        @logger.error("Game: Error in game loop: #{e.message}")
        @logger.error(e.backtrace.join("\n"))
      end
    end

    def cleanup
      @logger.info('Game: Starting cleanup sequence')
      log_game_event('cleanup_start')
      begin
        @window_manager.close! if @window_manager
        log_game_event('cleanup_complete')
        @logger.info('Game: Cleanup complete')
      rescue StandardError => e
        log_game_event('cleanup_error', { error: e.message, backtrace: e.backtrace })
        @logger.error("Game: Error during cleanup: #{e.message}")
        @logger.error(e.backtrace.join("\n"))
      end
    end

    private

    def update(delta_time)
      @logger.debug('Game: Updating game state')
      @player.update(delta_time)
    end

    def render
      @logger.debug('Game: Rendering frame')
      @renderer.render
    end

    def process_input
      @logger.debug('Game: Processing input')
      begin
        @input_handler.process_input(@window_manager)
      rescue StandardError => e
        log_game_event('input_error', { error: e.message, backtrace: e.backtrace })
        @logger.error("Game: Error processing input: #{e.message}")
        @logger.error(e.backtrace.join("\n"))
      end
    end

    def load_wad(wad_path)
      @logger.info("Game: Loading WAD file: #{wad_path}")
      return unless File.exist?(wad_path)

      begin
        @wad = WadFile.new(wad_path)
        @wad.load
        @logger.info('Game: WAD file loaded successfully')
      rescue StandardError => e
        log_game_event('wad_load_error', { error: e.message, backtrace: e.backtrace })
        @logger.error("Game: Error loading WAD file: #{e.message}")
        @logger.error(e.backtrace.join("\n"))
      end
    end

    def log_game_event(event, data = {})
      execute_sql = <<-SQL
        INSERT INTO game_events (
          timestamp, event_type, event_data
        ) VALUES (?, ?, ?)
      SQL

      @debug_db.instance_variable_get(:@db).execute(
        execute_sql,
        [Time.now.to_f, event, data.to_json]
      )
    rescue StandardError => e
      @logger.error("Failed to log game event: #{e.message}")
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
