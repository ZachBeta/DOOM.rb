#!/usr/bin/env ruby
# frozen_string_literal: true

module Doom
  require_relative 'doom/logger'
  require_relative 'doom/config'
  require_relative 'doom/game'
  require_relative 'doom/player'
  require_relative 'doom/wad_file'

  # Configure logger for game environment
  Logger.configure(level: :debug, base_dir: 'logs', env: :development)
end
