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
      @logger.info('InputHandler: Initialization started')
      @last_noclip_press = Time.now - 1 # Prevent immediate toggle
      @logger.info('InputHandler: Initialization complete')
    end

    def process_input(window_manager)
      return unless window_manager
      
      @logger.debug('InputHandler: Processing input')
      begin
        current_time = Time.now
        delta_time = current_time - (@last_time || current_time)
        @last_time = current_time

        # Process all inputs in order of priority
        handle_system_keys(window_manager)
        handle_movement(window_manager, delta_time)
        handle_rotation(window_manager, delta_time)
        handle_noclip(window_manager, current_time)
      rescue StandardError => e
        @logger.error("InputHandler: Error processing input: #{e.message}")
        @logger.error(e.backtrace.join("\n"))
      end
    end

    private

    def handle_system_keys(window_manager)
      @logger.debug('InputHandler: Checking system keys')
      # Check for escape key to close window
      if window_manager.key_pressed?(KEY_ESCAPE)
        @logger.info('InputHandler: ESC pressed, initiating window close')
        window_manager.should_close = true
      end
    end

    def handle_movement(window_manager, delta_time)
      @logger.debug('InputHandler: Processing movement')
      begin
        # Forward/backward movement
        if window_manager.key_pressed?(KEY_W) || window_manager.key_pressed?(KEY_UP)
          @logger.debug('InputHandler: Moving forward')
          @player.move_forward(delta_time)
        end
        
        if window_manager.key_pressed?(KEY_S) || window_manager.key_pressed?(KEY_DOWN)
          @logger.debug('InputHandler: Moving backward')
          @player.move_backward(delta_time)
        end

        # Strafe left/right
        if window_manager.key_pressed?(KEY_A)
          @logger.debug('InputHandler: Strafing left')
          @player.strafe_left(delta_time)
        end
        
        if window_manager.key_pressed?(KEY_D)
          @logger.debug('InputHandler: Strafing right')
          @player.strafe_right(delta_time)
        end
      rescue StandardError => e
        @logger.error("InputHandler: Error handling movement: #{e.message}")
        @logger.error(e.backtrace.join("\n"))
      end
    end

    def handle_rotation(window_manager, delta_time)
      @logger.debug('InputHandler: Processing rotation')
      begin
        # Rotate left/right
        if window_manager.key_pressed?(KEY_LEFT)
          @logger.debug('InputHandler: Rotating left')
          @player.rotate_left(delta_time)
        end
        
        if window_manager.key_pressed?(KEY_RIGHT)
          @logger.debug('InputHandler: Rotating right')
          @player.rotate_right(delta_time)
        end
      rescue StandardError => e
        @logger.error("InputHandler: Error handling rotation: #{e.message}")
        @logger.error(e.backtrace.join("\n"))
      end
    end

    def handle_noclip(window_manager, current_time)
      @logger.debug('InputHandler: Checking noclip toggle')
      begin
        # Toggle noclip mode with N key (with cooldown to prevent multiple toggles)
        if window_manager.key_pressed?(KEY_N) && (current_time - @last_noclip_press) > 0.3
          @player.toggle_noclip
          @last_noclip_press = current_time
          @logger.info("InputHandler: Noclip mode #{@player.noclip_mode ? 'enabled' : 'disabled'}")
        end
      rescue StandardError => e
        @logger.error("InputHandler: Error handling noclip toggle: #{e.message}")
        @logger.error(e.backtrace.join("\n"))
      end
    end
  end
end
