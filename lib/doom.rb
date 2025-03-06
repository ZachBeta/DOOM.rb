#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative 'doom/game'
require_relative 'doom/logger'

# Configure logger for game environment
Doom::Logger.configure(level: :debug, base_dir: 'logs', env: :development)

module Doom
  wad_path = ARGV[0] || File.expand_path('../freedoom.wad', __dir__)
  game = Game.new(wad_path)
  game.start
end
