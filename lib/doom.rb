#!/usr/bin/env ruby
# frozen_string_literal: true

module Doom
  require_relative 'doom/logger'
  require_relative 'doom/config'
  require_relative 'doom/game'
  require_relative 'doom/player'
  require_relative 'doom/map'
  require_relative 'doom/input_handler'
  require_relative 'doom/wad_file'

  # Configure logger for game environment
  Logger.configure(level: :debug, base_dir: 'logs', env: :development)

  # Only run the game when this file is executed directly
  if __FILE__ == $PROGRAM_NAME
    # WAD path is optional - if not provided, use test map
    wad_path = ARGV[0]
    game = Game.new(wad_path)
    game.start
  end
end
