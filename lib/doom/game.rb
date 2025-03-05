# frozen_string_literal: true

require 'gosu'
require_relative 'renderer'
require_relative 'player'
require_relative 'map'
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
      @logger.info('Initializing DOOM.rb')

      @map = Map.new
      @player = Player.new(@map)
      @renderer = Renderer.new(self, @map)
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

    def draw_hud
      noclip_text = "NOCLIP: #{@player.noclip_mode ? 'ON' : 'OFF'} (Press N to toggle)"
      noclip_color = @player.noclip_mode ? Gosu::Color::GREEN : Gosu::Color::WHITE
      @font.draw_text(noclip_text, 10, 10, 0, 1, 1, noclip_color)

      pos_text = "POS: (#{@player.position[0].round(2)}, #{@player.position[1].round(2)})"
      @font.draw_text(pos_text, 10, 30, 0, 1, 1, Gosu::Color::WHITE)
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
