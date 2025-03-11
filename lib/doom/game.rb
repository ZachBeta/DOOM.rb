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
      @logger.info('Game: Initializing DOOM.rb')

      begin
        @logger.info('Game: Creating renderer')
        @renderer = Renderer::BaseRenderer.new

        @logger.info('Game: Creating game objects')
        @map = Map.new
        @player = Player.new(@map)
        @game_clock = GameClock.new
        @input_handler = InputHandler.new(@player)

        # Connect renderer with game objects
        @logger.info('Game: Connecting renderer with game objects')
        @renderer.set_game_objects(@map, @player)

        load_wad(wad_path) if wad_path
        @logger.info('Game: Initialization complete')
      rescue StandardError => e
        @logger.error("Game: Error during initialization: #{e.message}")
        @logger.error(e.backtrace.join("\n"))
        cleanup
        raise
      end
    end

    def start
      return unless @renderer && @map && @player
      @logger.info('Game: Starting game loop')
      game_loop
    rescue StandardError => e
      @logger.error("Game: Error during game execution: #{e.message}")
      @logger.error(e.backtrace.join("\n"))
      cleanup
    end

    def cleanup
      @logger.info('Game: Starting cleanup sequence')
      begin
        @renderer.cleanup if @renderer
        @logger.info('Game: Cleanup complete')
      rescue StandardError => e
        @logger.error("Game: Error during cleanup: #{e.message}")
        @logger.error(e.backtrace.join("\n"))
      end
    end

    private

    def game_loop
      @logger.info('Game: Entering game loop')
      last_fps_time = Time.now
      frames = 0

      # Main game loop
      until @renderer.window_should_close?
        begin
          # Process window events first
          @renderer.instance_variable_get(:@window_manager).poll_events

          # Update game state
          delta_time = @game_clock.tick
          update(delta_time)
          
          # Process input before rendering
          process_input
          
          # Render frame
          render
          
          # FPS logging
          frames += 1
          if Time.now - last_fps_time >= 5
            fps = frames / (Time.now - last_fps_time)
            @logger.info("Game: FPS: #{fps.round(2)}")
            frames = 0
            last_fps_time = Time.now
          end

          # Small sleep to prevent CPU overload
          sleep(0.001)
        rescue StandardError => e
          @logger.error("Game: Error in game loop: #{e.message}")
          @logger.error(e.backtrace.join("\n"))
          break
        end
      end

      @logger.info('Game: Exiting game loop')
      cleanup
    end

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
        @input_handler.process_input(@renderer.instance_variable_get(:@window_manager))
      rescue StandardError => e
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
        @logger.error("Game: Error loading WAD file: #{e.message}")
        @logger.error(e.backtrace.join("\n"))
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
