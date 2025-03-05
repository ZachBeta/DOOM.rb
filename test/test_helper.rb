# frozen_string_literal: true

require 'minitest/autorun'
require 'minitest/pride'
require 'matrix'
require 'simplecov'
require 'doom/logger'

SimpleCov.start do
  add_filter '/test/'
  track_files 'lib/**/*.rb'
  enable_coverage :branch
end

# Configure logger for test environment
Doom::Logger.configure(level: :info, base_dir: 'test/logs', env: :test)

# Don't require the entire doom.rb file as it starts the game
# Instead, require only the specific files needed for testing
