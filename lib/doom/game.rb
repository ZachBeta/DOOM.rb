require 'gosu'
require_relative 'renderer'
require_relative 'player'
require_relative 'logger'

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
      @last_time = Gosu.milliseconds
      
      @logger.info("Game initialized successfully")
    end

    def start
      @logger.info("Starting game loop")
      show
    end

    def update
      current_time = Gosu.milliseconds
      delta_time = (current_time - @last_time) / 1000.0
      @last_time = current_time

      handle_input(delta_time)
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

    private

    def handle_input(delta_time)
      @player.move_forward(delta_time) if Gosu.button_down?(Gosu::KB_W)
      @player.move_backward(delta_time) if Gosu.button_down?(Gosu::KB_S)
      @player.strafe_left(delta_time) if Gosu.button_down?(Gosu::KB_A)
      @player.strafe_right(delta_time) if Gosu.button_down?(Gosu::KB_D)
      @player.rotate_left(delta_time) if Gosu.button_down?(Gosu::KB_LEFT)
      @player.rotate_right(delta_time) if Gosu.button_down?(Gosu::KB_RIGHT)
    end
  end
end 