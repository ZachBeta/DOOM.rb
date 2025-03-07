#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative 'doom/logger'
require_relative 'doom/config'
require_relative 'doom/glfw'
require_relative 'doom/game'
require_relative 'doom/window'
require_relative 'doom/player'
require_relative 'doom/map'
require_relative 'doom/input_handler'
require_relative 'doom/wad_file'
require_relative 'doom/renderer'

# Configure logger for game environment
Doom::Logger.configure(level: :debug, base_dir: 'logs', env: :development)

module Doom
  wad_path = ARGV[0] || File.expand_path('../data/wad/freedoom1.wad', __dir__)
  game = Game.new(wad_path)
  game.start
end
