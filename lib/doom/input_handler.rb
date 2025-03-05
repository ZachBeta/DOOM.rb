require 'gosu'

module Doom
  class InputHandler
    def initialize(player)
      @player = player
    end

    def handle_input(window, delta_time)
      handle_movement(window, delta_time)
      handle_rotation(window, delta_time)
      handle_special_keys(window)
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
    
    def handle_special_keys(window)
      # We need to track key presses to avoid toggling multiple times per press
      @last_n_state ||= false
      n_pressed = window.button_down?(Gosu::KB_N)
      
      if n_pressed && !@last_n_state
        @player.toggle_noclip
      end
      
      @last_n_state = n_pressed
    end
  end
end 