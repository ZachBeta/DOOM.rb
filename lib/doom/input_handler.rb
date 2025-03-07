# frozen_string_literal: true

require 'glfw3'

module Doom
  class InputHandler
    def initialize(player)
      @player = player
      @logger = Logger.instance
      @last_n_state = false
    end

    def handle_input(window, delta_time)
      handle_movement(window, delta_time)
      handle_rotation(window, delta_time)
      handle_special_keys(window)
    end

    private

    def handle_movement(window, delta_time)
      movement = []
      if window.button_down?(Glfw3::KEY_W)
        @player.move_forward(delta_time)
        movement << 'forward'
      end
      if window.button_down?(Glfw3::KEY_S)
        @player.move_backward(delta_time)
        movement << 'backward'
      end
      if window.button_down?(Glfw3::KEY_A)
        @player.strafe_left(delta_time)
        movement << 'left'
      end
      if window.button_down?(Glfw3::KEY_D)
        @player.strafe_right(delta_time)
        movement << 'right'
      end

      @logger.verbose("Movement: #{movement.join(', ')}") unless movement.empty?
    end

    def handle_rotation(window, delta_time)
      rotation = []
      if window.button_down?(Glfw3::KEY_LEFT)
        @player.rotate_left(delta_time)
        rotation << 'left'
      end
      if window.button_down?(Glfw3::KEY_RIGHT)
        @player.rotate_right(delta_time)
        rotation << 'right'
      end

      @logger.verbose("Rotation: #{rotation.join(', ')}") unless rotation.empty?
    end

    def handle_special_keys(window)
      n_pressed = window.button_down?(Glfw3::KEY_N)

      if n_pressed && !@last_n_state
        @player.toggle_noclip
        @logger.info("Noclip mode #{@player.noclip_mode ? 'enabled' : 'disabled'}")
      end

      @last_n_state = n_pressed
    end
  end
end
