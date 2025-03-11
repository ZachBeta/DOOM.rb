# frozen_string_literal: true

require_relative 'logger'
require_relative 'window/window_manager'

module Doom
  class InputHandler
    # Key constants - referenced from GLFW but defined locally
    KEY_W = 87       # Glfw::KEY_W
    KEY_A = 65       # Glfw::KEY_A
    KEY_S = 83       # Glfw::KEY_S
    KEY_D = 68       # Glfw::KEY_D
    KEY_LEFT = 263   # Glfw::KEY_LEFT
    KEY_RIGHT = 262  # Glfw::KEY_RIGHT
    KEY_UP = 265     # Glfw::KEY_UP
    KEY_DOWN = 264   # Glfw::KEY_DOWN
    KEY_N = 78       # Glfw::KEY_N
    KEY_ESCAPE = 256 # Glfw::KEY_ESCAPE

    def initialize(player)
      @player = player
      @logger = Logger.instance
      @logger.info('Input handler initialized')
      @last_noclip_press = Time.now - 1 # Prevent immediate toggle
    end

    def process_input(window_manager)
      # Check for escape key to close window
      if window_manager.key_pressed?(KEY_ESCAPE)
        window_manager.should_close = true
        return
      end

      # Calculate delta time for smooth movement
      current_time = Time.now
      delta_time = current_time - (@last_time || current_time)
      @last_time = current_time

      handle_movement(window_manager, delta_time)
      handle_rotation(window_manager, delta_time)
      handle_noclip(window_manager, current_time)
    end

    private

    def handle_movement(window_manager, delta_time)
      # Forward/backward movement
      @player.move_forward(delta_time) if window_manager.key_pressed?(KEY_W) || window_manager.key_pressed?(KEY_UP)
      @player.move_backward(delta_time) if window_manager.key_pressed?(KEY_S) || window_manager.key_pressed?(KEY_DOWN)

      # Strafe left/right
      @player.strafe_left(delta_time) if window_manager.key_pressed?(KEY_A)
      @player.strafe_right(delta_time) if window_manager.key_pressed?(KEY_D)
    end

    def handle_rotation(window_manager, delta_time)
      # Rotate left/right
      @player.rotate_left(delta_time) if window_manager.key_pressed?(KEY_LEFT)
      @player.rotate_right(delta_time) if window_manager.key_pressed?(KEY_RIGHT)
    end

    def handle_noclip(window_manager, current_time)
      # Toggle noclip mode with N key (with cooldown to prevent multiple toggles)
      return unless window_manager.key_pressed?(KEY_N) && (current_time - @last_noclip_press) > 0.3

      @player.toggle_noclip
      @last_noclip_press = current_time
      @logger.info("Noclip mode #{@player.noclip_mode ? 'enabled' : 'disabled'}")
    end
  end
end
