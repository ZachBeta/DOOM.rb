# frozen_string_literal: true

require 'minitest/autorun'
require 'minitest/pride'
require 'matrix'
require 'simplecov'
require 'doom/logger'
require 'fileutils'

SimpleCov.start do
  add_filter '/test/'
  track_files 'lib/**/*.rb'
  enable_coverage :branch
end

module TestHelper
  def setup_test_logs
    FileUtils.mkdir_p('logs')
    Doom::Logger.configure(level: :verbose, base_dir: 'logs', env: :test)
  end
end

class Minitest::Test
  include TestHelper
end

# Configure logger for test environment
Doom::Logger.configure(level: :info, base_dir: 'logs', env: :test)

# Don't require the entire doom.rb file as it starts the game
# Instead, require only the specific files needed for testing
