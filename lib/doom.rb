#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative 'doom/logger'
require_relative 'doom/config'
require_relative 'doom/game'
require_relative 'doom/player'
require_relative 'doom/map'
require_relative 'doom/input_handler'
require_relative 'doom/wad_file'

# Configure logger for game environment
Doom::Logger.configure(level: :debug, base_dir: 'logs', env: :development)

module Doom
  # Only run the game when this file is executed directly
  if __FILE__ == $PROGRAM_NAME
    wad_path = ARGV[0] || Config::DEFAULT_WAD_PATH
    game = Game.new(wad_path)
    game.start
  end
end
