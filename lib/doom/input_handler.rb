require 'gosu'

module Doom
  class InputHandler
    def initialize(player)
      @player = player
    end

    def handle_input(window, delta_time)
      handle_movement(window, delta_time)
      handle_rotation(window, delta_time)
    end

    private

    def handle_movement(window, delta_time)
      @player.move_forward(delta_time) if window.button_down?(Gosu::KB_W)
      @player.move_backward(delta_time) if window.button_down?(Gosu::KB_S)
      @player.strafe_left(delta_time) if window.button_down?(Gosu::KB_A)
      @player.strafe_right(delta_time) if window.button_down?(Gosu::KB_D)
    end

    def handle_rotation(window, delta_time)
      @player.rotate_left(delta_time) if window.button_down?(Gosu::KB_LEFT)
      @player.rotate_right(delta_time) if window.button_down?(Gosu::KB_RIGHT)
    end
  end
end 