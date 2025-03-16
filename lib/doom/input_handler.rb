# frozen_string_literal: true

require 'gosu'
require_relative 'logger'
require_relative 'window/window_manager'

module Doom
  class InputHandler
    # Key constants from Gosu
    KEY_W = Gosu::KB_W
    KEY_A = Gosu::KB_A
    KEY_S = Gosu::KB_S
    KEY_D = Gosu::KB_D
    KEY_LEFT = Gosu::KB_LEFT
    KEY_RIGHT = Gosu::KB_RIGHT
    KEY_UP = Gosu::KB_UP
    KEY_DOWN = Gosu::KB_DOWN
    KEY_N = Gosu::KB_N
    KEY_ESCAPE = Gosu::KB_ESCAPE

    def initialize(player, window_manager)
      @player = player
      @window_manager = window_manager
      @logger = Logger.instance
      @logger.info('InputHandler: Initialization started')
      @last_noclip_press = Time.now - 1 # Prevent immediate toggle
      @logger.info('InputHandler: Initialization complete')
    end

    def handle_input(delta_time)
      @logger.debug('InputHandler: Processing input')
      begin
        # Process all inputs in order of priority
        handle_system_keys(@window_manager)
        handle_movement(@window_manager, delta_time)
        handle_rotation(@window_manager, delta_time)
        handle_noclip(@window_manager, Time.now)
      rescue StandardError => e
        @logger.error("InputHandler: Error processing input: #{e.message}")
        @logger.error(e.backtrace.join("\n"))
      end
    end

    private

    def handle_system_keys(window_manager)
      @logger.debug('InputHandler: Checking system keys')
      window_manager.should_close = true if window_manager.key_pressed?(KEY_ESCAPE)
    end

    def handle_movement(window_manager, delta_time)
      @logger.debug('InputHandler: Processing movement')
      if window_manager.key_pressed?(KEY_W) || window_manager.key_pressed?(KEY_UP)
        @player.move_forward(delta_time)
      end
      if window_manager.key_pressed?(KEY_S) || window_manager.key_pressed?(KEY_DOWN)
        @player.move_backward(delta_time)
      end
      @player.strafe_left(delta_time) if window_manager.key_pressed?(KEY_A)
      return unless window_manager.key_pressed?(KEY_D)

      @player.strafe_right(delta_time)
    end

    def handle_rotation(window_manager, delta_time)
      @logger.debug('InputHandler: Processing rotation')
      @player.rotate_left(delta_time) if window_manager.key_pressed?(KEY_LEFT)
      return unless window_manager.key_pressed?(KEY_RIGHT)

      @player.rotate_right(delta_time)
    end

    def handle_noclip(window_manager, current_time)
      @logger.debug('InputHandler: Checking noclip toggle')
      return unless window_manager.key_pressed?(KEY_N) && (current_time - @last_noclip_press) > 0.5

      @player.toggle_noclip
      @last_noclip_press = current_time
    end
  end
end
