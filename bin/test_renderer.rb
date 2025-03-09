#!/usr/bin/env ruby
# frozen_string_literal: true

require 'opengl'
require 'glfw3'

# Load OpenGL libraries
OpenGL.load_lib
GLFW.load_lib if defined?(GLFW)

# Include OpenGL module
include OpenGL

require_relative '../lib/doom/game'
require_relative '../lib/doom/logger'
require_relative '../lib/doom/config'

# Initialize logger
logger = Doom::Logger.instance
logger.info('Starting renderer test script')

# Create game instance
game = Doom::Game.new(Doom::Config::DEFAULT_WAD_PATH)

# Set up test parameters
test_duration = 30 # seconds
start_time = Time.now
movement_pattern = [
  { action: :forward, duration: 2 },
  { action: :rotate_left, duration: 1 },
  { action: :forward, duration: 2 },
  { action: :rotate_right, duration: 1 },
  { action: :backward, duration: 2 },
  { action: :strafe_left, duration: 1 },
  { action: :strafe_right, duration: 1 },
  { action: :toggle_noclip, duration: 0.1 },
  { action: :forward, duration: 2 },
  { action: :toggle_noclip, duration: 0.1 }
]

logger.info('Starting automated movement pattern')

# Override game loop to run our test
def game.test_loop(test_duration, movement_pattern)
  @logger.info('Entering test loop')

  start_time = Time.now
  pattern_index = 0
  action_start_time = start_time
  current_action = movement_pattern[pattern_index]

  until Time.now - start_time >= test_duration || @renderer.window_should_close?
    delta_time = @game_clock.tick

    # Check if it's time to switch to the next action
    if Time.now - action_start_time >= current_action[:duration]
      pattern_index = (pattern_index + 1) % movement_pattern.size
      current_action = movement_pattern[pattern_index]
      action_start_time = Time.now
      @logger.info("Switching to action: #{current_action[:action]}")
    end

    # Perform the current action
    case current_action[:action]
    when :forward
      @player.move_forward(delta_time)
    when :backward
      @player.move_backward(delta_time)
    when :rotate_left
      @player.rotate_left(delta_time)
    when :rotate_right
      @player.rotate_right(delta_time)
    when :strafe_left
      @player.strafe_left(delta_time)
    when :strafe_right
      @player.strafe_right(delta_time)
    when :toggle_noclip
      @player.toggle_noclip
    end

    # Update and render
    update(delta_time)
    render
    process_input
  end

  @logger.info('Exiting test loop')
  cleanup
end

# Run the test
game.test_loop(test_duration, movement_pattern)

logger.info('Renderer test script completed')
