# frozen_string_literal: true

require 'minitest/autorun'
require 'minitest/pride'
require 'minitest/focus'
require 'matrix'
require 'simplecov'
require 'doom/logger'
require 'doom/config'
require 'fileutils'
require 'doom/player'
require_relative '../lib/doom'

# Add the lib directory to the load path
$LOAD_PATH.unshift File.expand_path('../lib', __dir__)

SimpleCov.start do
  add_filter '/test/'
end

module TestHelper
  def setup_test_logs
    FileUtils.mkdir_p('logs')
    Doom::Logger.setup
  end

  def assert_vector_equal(expected, actual, msg = nil)
    assert_equal expected[0], actual[0], msg
    assert_equal expected[1], actual[1], msg if expected.size > 1
    assert_equal expected[2], actual[2], msg if expected.size > 2
  end

  def cleanup_old_logs
    %w[debug verbose game doom].each do |type|
      Dir.glob("logs/#{type}*.log").each do |file|
        File.delete(file)
      end
    end
  end
end

class Minitest::Test
  include TestHelper

  def setup
    setup_test_logs
  end

  def teardown
    cleanup_old_logs
  end
end
