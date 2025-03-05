#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative 'doom/game'
require_relative 'doom/logger'

# Configure logger for game environment
Doom::Logger.configure(level: :debug, base_dir: 'logs', env: :development)

# Start the game
Doom::Game.new.start
