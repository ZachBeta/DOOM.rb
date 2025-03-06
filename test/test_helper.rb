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
    cleanup_old_logs
    Doom::Logger.configure(level: :debug, base_dir: 'logs', env: :test)
  end

  private

  def cleanup_old_logs
    %w[debug verbose game].each do |type|
      pattern = "logs/#{type}_*.log"
      files = Dir.glob(pattern).sort_by { |f| File.mtime(f) }.reverse
      files[5..].each { |f| File.delete(f) } if files.size > 5
    end
  end
end

class Minitest::Test
  include TestHelper

  def setup
    setup_test_logs
  end
end

# Configure logger for test environment
Doom::Logger.configure(level: :debug, base_dir: 'logs', env: :test)

# Don't require the entire doom.rb file as it starts the game
# Instead, require only the specific files needed for testing
