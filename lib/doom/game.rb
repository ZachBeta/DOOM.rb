require 'gosu'
require_relative 'renderer'
require_relative 'player'
require_relative 'logger'
require_relative 'input_handler'

module Doom
  class Game < Gosu::Window
    SCREEN_WIDTH = 800
    SCREEN_HEIGHT = 600
    TITLE = 'DOOM.rb'

    def initialize
      super(SCREEN_WIDTH, SCREEN_HEIGHT)
      self.caption = TITLE
      
      @logger = Logger.new(:debug)
      @logger.info("Initializing DOOM.rb")
      
      @renderer = Renderer.new(self)
      @player = Player.new
      @input_handler = InputHandler.new(@player)
      @game_clock = GameClock.new
      
      @logger.info("Game initialized successfully")
    end

    def start
      @logger.info("Starting game loop")
      show
    end

    def update
      delta_time = @game_clock.tick
      @input_handler.handle_input(self, delta_time)
      @player.update(delta_time)
      
      @logger.debug("Player position: #{@player.position}, direction: #{@player.direction}")
    end

    def draw
      @renderer.render(@player)
    end

    def button_down(id)
      close if id == Gosu::KB_ESCAPE
      @logger.info("Game closing") if id == Gosu::KB_ESCAPE
    end
  end

  class GameClock
    def initialize
      @last_time = Gosu.milliseconds
    end

    def tick
      current_time = Gosu.milliseconds
      delta_time = (current_time - @last_time) / 1000.0
      @last_time = current_time
      delta_time
    end
  end
end 