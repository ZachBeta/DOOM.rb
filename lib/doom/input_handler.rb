# frozen_string_literal: true

require 'glfw3'
require_relative 'logger'

module Doom
  class InputHandler
    # Key constants
    KEY_W = Glfw::KEY_W
    KEY_A = Glfw::KEY_A
    KEY_S = Glfw::KEY_S
    KEY_D = Glfw::KEY_D
    KEY_LEFT = Glfw::KEY_LEFT
    KEY_RIGHT = Glfw::KEY_RIGHT
    KEY_UP = Glfw::KEY_UP
    KEY_DOWN = Glfw::KEY_DOWN
    KEY_N = Glfw::KEY_N
    KEY_ESCAPE = Glfw::KEY_ESCAPE

    def initialize(player)
      @player = player
      @logger = Logger.instance
      @logger.info('Input handler initialized')
      @last_noclip_press = Time.now - 1 # Prevent immediate toggle
    end

    def process_input(window)
      # Check for escape key to close window
      if key_pressed?(window, KEY_ESCAPE)
        window.should_close = true
        return
      end

      # Calculate delta time for smooth movement
      current_time = Time.now
      delta_time = current_time - (@last_time || current_time)
      @last_time = current_time

      handle_movement(window, delta_time)
      handle_rotation(window, delta_time)
      handle_noclip(window, current_time)
    end

    private

    def key_pressed?(window, key)
      window.key(key) == Glfw::PRESS
    end

    def handle_movement(window, delta_time)
      # Forward/backward movement
      @player.move_forward(delta_time) if key_pressed?(window,
                                                       KEY_W) || key_pressed?(window, KEY_UP)
      @player.move_backward(delta_time) if key_pressed?(window,
                                                        KEY_S) || key_pressed?(window, KEY_DOWN)

      # Strafe left/right
      @player.strafe_left(delta_time) if key_pressed?(window, KEY_A)
      @player.strafe_right(delta_time) if key_pressed?(window, KEY_D)
    end

    def handle_rotation(window, delta_time)
      # Rotate left/right
      @player.rotate_left(delta_time) if key_pressed?(window, KEY_LEFT)
      @player.rotate_right(delta_time) if key_pressed?(window, KEY_RIGHT)
    end

    def handle_noclip(window, current_time)
      # Toggle noclip mode with N key (with cooldown to prevent multiple toggles)
      return unless key_pressed?(window, KEY_N) && (current_time - @last_noclip_press) > 0.3

      @player.toggle_noclip
      @last_noclip_press = current_time
      @logger.info("Noclip mode #{@player.noclip_mode ? 'enabled' : 'disabled'}")
    end
  end
end
