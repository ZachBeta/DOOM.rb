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
        @map = Map.new # Use test map by default
        @player = Player.new(@map)
        @game_clock = GameClock.new
        @input_handler = InputHandler.new(@player, @window_manager)
        @logger.log_game_event('game_objects_created')

        # Connect renderer with game objects
        @logger.info('Game: Connecting renderer with game objects', component: 'Game')
        @renderer.set_game_objects(@map, @player)
        @logger.log_game_event('renderer_connected')

        # Only load WAD if explicitly requested
        if wad_path && !wad_path.empty? && File.exist?(wad_path)
          load_wad(wad_path)
          @logger.log_game_event('wad_loaded', { path: wad_path })
        end

        @logger.info('Game: Initialization complete', component: 'Game')
        @logger.log_game_event('initialization_complete')
      rescue StandardError => e
        @logger.error("Game: Error during initialization: #{e.message}", component: 'Game')
        @logger.error(e.backtrace.join("\n"), component: 'Game')
        cleanup
        raise
      end
    end

    def start
      @logger.info('Game: Starting game loop', component: 'Game')
      begin
        # Set up the game loop as the window's update procedure
        @window_manager.set_update_proc(method(:update_frame))
        # Start the window's event loop
        @window_manager.show
      rescue StandardError => e
        @logger.error("Game: Error in game loop: #{e.message}", component: 'Game')
        @logger.error(e.backtrace.join("\n"), component: 'Game')
      ensure
        cleanup
      end
    end

    def cleanup
      @logger.info('Game: Starting cleanup sequence', component: 'Game')
      @logger.log_game_event('cleanup_start')
      begin
        @renderer.cleanup if @renderer
        @window_manager.close! if @window_manager
        @logger.log_game_event('cleanup_complete')
        @logger.info('Game: Cleanup complete', component: 'Game')
      rescue StandardError => e
        @logger.error("Game: Error during cleanup: #{e.message}", component: 'Game')
        @logger.error(e.backtrace.join("\n"), component: 'Game')
      end
    end

    def window_should_close?
      @window_manager.should_close
    end

    private

    def update_frame(delta_time)
      # Handle input
      @input_handler.handle_input(delta_time)

      # Update game state
      @player.update(delta_time)
      @map.update(@player.position)

      # Render frame
      @renderer.render
    end

    def load_wad(wad_path)
      return unless wad_path && !wad_path.empty? && File.exist?(wad_path)

      @logger.info("Game: Loading WAD file: #{wad_path}", component: 'Game')
      begin
        wad_file = WadFile.new(wad_path)
        first_level = wad_file.levels.first
        if first_level
          level_data = wad_file.level_data(first_level)
          if level_data
            @map = Map.create_map_from_level_data(level_data)
            @player.set_map(@map)
            @renderer.set_game_objects(@map, @player)
            @logger.info('Game: WAD file loaded successfully', component: 'Game')
          else
            @logger.warn('Game: No valid level data found in WAD file', component: 'Game')
          end
        else
          @logger.warn('Game: No levels found in WAD file', component: 'Game')
        end
      rescue StandardError => e
        @logger.error("Game: Error loading WAD file: #{e.message}", component: 'Game')
        @logger.error(e.backtrace.join("\n"), component: 'Game')
      end
    end
  end

  class GameClock
    def initialize
      @last_tick = Time.now
    end

    def tick
      current_time = Time.now
      delta = current_time - @last_tick
      @last_tick = current_time
      delta
    end
  end
end
