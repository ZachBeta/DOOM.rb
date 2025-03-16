# frozen_string_literal: true

require 'minitest/autorun'
require 'fileutils'
require 'tempfile'
require 'matrix'
require_relative '../../lib/doom/logger'
require_relative '../../lib/doom/player'
require_relative '../../lib/doom/map'

module Doom
  class LoggerTest < Minitest::Test
    def setup
      @temp_dir = Dir.mktmpdir
      @log_dir = File.join(@temp_dir, 'logs')
      @db_path = File.join(@temp_dir, 'test.db')
      Logger.configure(level: :debug, base_dir: @log_dir, db_path: @db_path, env: :test)
      @logger = Logger.instance
      @map = Map.new
      @player = Player.new(@map)
      # Set player to a known state for testing
      @player.position = Vector[2.0, 3.0]
      @player.direction = Vector[1.0, 0.0]
      @player.toggle_noclip
    end

    def teardown
      FileUtils.remove_entry(@temp_dir)
    end

    def test_basic_logging_levels
      @logger.debug('Debug message')
      @logger.info('Info message')
      @logger.warn('Warning message')
      @logger.error('Error message')
      @logger.fatal('Fatal message')

      debug_log = File.read(File.join(@log_dir, 'debug.log'))
      game_log = File.read(File.join(@log_dir, 'game.log'))
      doom_log = File.read(File.join(@log_dir, 'doom.log'))

      assert_match(/Debug message/, debug_log)
      assert_match(/Info message/, game_log)
      assert_match(/Warning message/, doom_log)
      assert_match(/Error message/, doom_log)
      assert_match(/Fatal message/, doom_log)
    end

    def test_component_based_logging
      @logger.info('Component message', component: 'TestComponent')
      game_log = File.read(File.join(@log_dir, 'game.log'))

      assert_match(/\[TestComponent\] Component message/, game_log)

      logs = @logger.query_logs(component: 'TestComponent')

      assert_equal 1, logs.length
      assert_equal 'Component message', logs.first[:message]
      assert_equal 'TestComponent', logs.first[:component]
    end

    def test_event_logging
      @logger.info('Event message', event: 'test_event', data: { key: 'value' })
      events = @logger.query_game_events(event_type: 'test_event')

      assert_equal 1, events.length
      event = events.first

      assert_equal 'test_event', event[:event_type]
      assert_equal({ 'key' => 'value' }, event[:data])
    end

    def test_debug_logging_with_component
      @logger.debug('Debug component message', component: 'TestComponent', data: { debug: true })
      logs = @logger.query_logs(component: 'TestComponent')

      assert_equal 1, logs.length
      log = logs.first

      assert_equal 'TestComponent', log[:component]
      assert_equal 'Debug component message', log[:message]
      assert_equal({ 'debug' => true }, log[:data])
      assert_equal 'DEBUG', log[:level]
    end

    def test_player_movement_logging
      @logger.log_player_movement(@player, 0.016)

      events = @logger.query_game_events(event_type: 'player_movement')

      assert_equal 1, events.length

      data = events.first[:data]

      assert_equal [2.0, 3.0], data['position']
      assert_equal [1.0, 0.0], data['direction']
      assert_in_delta(0.0, data['angle'])
      assert_equal true, data['noclip_mode']
      assert_in_delta 0.016, data['delta_time']
    end

    def test_render_frame_logging
      @logger.log_render_frame(0.016, 100, 60.0)

      events = @logger.query_game_events(event_type: 'render_frame')

      assert_equal 1, events.length

      data = events.first[:data]

      assert_in_delta 0.016, data['frame_time']
      assert_equal 100, data['ray_count']
      assert_in_delta 60.0, data['fps']
    end

    def test_collision_logging
      attempted_position = Vector[4.0, 5.0]
      @logger.log_collision(@player, attempted_position, false)

      events = @logger.query_game_events(event_type: 'collision')

      assert_equal 1, events.length

      data = events.first[:data]

      assert_equal [2.0, 3.0], data['player_position']
      assert_equal [4.0, 5.0], data['attempted_position']
      assert_equal false, data['successful']
    end

    def test_query_logs_with_conditions
      @logger.debug('Test message 1', component: 'Component1', data: { test: 1 })
      @logger.debug('Test message 2', component: 'Component2', data: { test: 2 })

      logs = @logger.query_logs(component: 'Component1')

      assert_equal 1, logs.length
      assert_equal 'Test message 1', logs.first[:message]
      assert_equal({ 'test' => 1 }, logs.first[:data])

      logs = @logger.query_logs(component: 'Component2')

      assert_equal 1, logs.length
      assert_equal 'Test message 2', logs.first[:message]
      assert_equal({ 'test' => 2 }, logs.first[:data])
    end

    def test_query_game_events_with_conditions
      @logger.log_game_event('event1', { data: 1 })
      @logger.log_game_event('event2', { data: 2 })

      events = @logger.query_game_events(event_type: 'event1')

      assert_equal 1, events.length
      assert_equal({ 'data' => 1 }, events.first[:data])

      events = @logger.query_game_events(event_type: 'event2')

      assert_equal 1, events.length
      assert_equal({ 'data' => 2 }, events.first[:data])
    end

    def test_clear_logs
      # Create various types of logs
      @logger.debug('Test debug')
      @logger.log_game_event('test_event')
      @logger.log_player_movement(@player, 0.016)
      @logger.log_render_frame(0.016, 100, 60.0)
      @logger.log_collision(@player, Vector[4.0, 5.0], false)

      # Verify logs exist
      assert_operator @logger.query_logs({}).length, :>, 0
      assert_operator @logger.query_game_events({}).length, :>, 0

      # Clear logs
      @logger.clear_logs

      # Verify logs are cleared
      assert_equal 0, @logger.query_logs({}).length
      assert_equal 0, @logger.query_game_events({}).length
    end

    def test_log_level_filtering
      Logger.configure(level: :info, base_dir: @log_dir, db_path: @db_path, env: :test)
      logger = Logger.instance

      logger.debug('Should not be logged')
      logger.info('Should be logged')

      debug_log = File.read(File.join(@log_dir, 'debug.log'))
      game_log = File.read(File.join(@log_dir, 'game.log'))

      refute_match(/Should not be logged/, debug_log)
      assert_match(/Should be logged/, game_log)

      # Verify in debug logs
      logs = logger.query_logs(level: 'DEBUG')

      assert_equal 0, logs.length

      logs = logger.query_logs(level: 'INFO')

      assert_equal 1, logs.length
      assert_equal 'Should be logged', logs.first[:message]
    end
  end
end
