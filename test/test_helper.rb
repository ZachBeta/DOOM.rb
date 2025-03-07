# frozen_string_literal: true

require 'minitest/autorun'
require 'minitest/pride'
require 'matrix'
require 'simplecov'
require 'doom/logger'
require 'doom/config'
require 'fileutils'
require 'glfw3'
require 'opengl'
require 'doom/player'
require_relative '../lib/doom'

SimpleCov.start do
  add_filter '/test/'
  track_files 'lib/**/*.rb'
  enable_coverage :branch
end

module TestHelper
  def setup_test_logs
    FileUtils.mkdir_p('logs')
    FileUtils.mkdir_p('logs/history')
    cleanup_old_logs
    # Configure logger for test environment with debug logging enabled
    # but suppress terminal output
    Doom::Logger.configure(
      level: :debug,
      base_dir: 'logs',
      env: :test
    )
  end

  def setup_opengl
    Glfw.init
    Glfw::Window.default_window_hints do
      context_version_major 2
      context_version_minor 1
      opengl_profile :core
    end
    @window = Glfw::Window.new(800, 600, 'Test Window')
    @window.make_context_current
    OpenGL.load_lib
  end

  def teardown_opengl
    @window.destroy if @window
    Glfw.terminate
  end

  def assert_vector_equal(expected, actual, msg = nil)
    assert_equal expected[0], actual[0], msg
    assert_equal expected[1], actual[1], msg
  end

  private

  def cleanup_old_logs
    %w[debug verbose game doom].each do |type|
      pattern = "logs/#{type}*.log"
      files = Dir.glob(pattern).sort_by { |f| File.mtime(f) }.reverse
      files[5..].each { |f| File.delete(f) } if files.size > 5
    end
  end
end

class Minitest::Test
  include TestHelper

  def setup
    setup_test_logs
    setup_opengl
  end

  def teardown
    teardown_opengl
    # Ensure logs are rotated after each test if they exist
    return unless Dir.exist?('logs') && !Dir.glob('logs/*.log').empty?

    return unless defined?(Rake::Task) && Rake::Task.task_defined?('rotate_logs')

    Rake::Task['rotate_logs'].execute
  end
end

# Configure logger for test environment with debug logging enabled
# but suppress terminal output
Doom::Logger.configure(
  level: :debug,
  base_dir: 'logs',
  env: :test
)

# FIXME: remove all gosu code
module Doom
  class Map
    def wall_at?(x, y)
      (x == 6 && y == 5) || # Wall one unit to the right of default player position
        x.negative? || y.negative? || x >= 10 || y >= 10 # Boundary walls
    end

    def width = 10
    def height = 10
    def empty?(x, y) = !wall_at?(x, y)
  end

  class Textures
    def initialize
      @textures = {}
    end

    def get(name)
      @textures[name]
    end
  end
end
