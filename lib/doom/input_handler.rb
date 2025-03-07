# frozen_string_literal: true

require_relative 'logger'
require_relative 'glfw_wrapper'

module Doom
  class InputHandler
    def initialize(player)
      @player = player
      @logger = Logger.instance
      @logger.info('Input handler initialized')
    end

    def handle_input(window, delta_time)
      handle_movement(window, delta_time)
      handle_rotation(window, delta_time)
      handle_noclip(window)
    end

    private

    def handle_movement(window, delta_time)
      @player.move_forward(delta_time) if window.button_down?(GlfwWrapper::KEY_W)

      @player.move_backward(delta_time) if window.button_down?(GlfwWrapper::KEY_S)

      @player.strafe_left(delta_time) if window.button_down?(GlfwWrapper::KEY_A)

      return unless window.button_down?(GlfwWrapper::KEY_D)

      @player.strafe_right(delta_time)
    end

    def handle_rotation(window, delta_time)
      @player.turn_left(delta_time) if window.button_down?(GlfwWrapper::KEY_LEFT)

      return unless window.button_down?(GlfwWrapper::KEY_RIGHT)

      @player.turn_right(delta_time)
    end

    def handle_noclip(window)
      n_pressed = window.button_down?(GlfwWrapper::KEY_N)
      @player.toggle_noclip if n_pressed
    end
  end
end
