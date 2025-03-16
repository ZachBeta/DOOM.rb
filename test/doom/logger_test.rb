# frozen_string_literal: true

require 'minitest/autorun'
require 'fileutils'
require 'tempfile'
require_relative '../../lib/doom/logger'

module Doom
  class LoggerTest < Minitest::Test
    def setup
      @temp_dir = Dir.mktmpdir
      @log_dir = File.join(@temp_dir, 'logs')
      @db_path = File.join(@temp_dir, 'test.db')
      Logger.configure(level: :debug, base_dir: @log_dir, db_path: @db_path, env: :test)
      @logger = Logger.instance
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
      player = MockPlayer.new
      @logger.log_player_movement(player, 0.016)

      db = SQLite3::Database.new(@db_path)
      result = db.execute('SELECT * FROM player_movements ORDER BY timestamp DESC LIMIT 1')

      assert_equal 1, result.length
      assert_in_delta 2.0, result[0][2] # position_x
      assert_in_delta 3.0, result[0][3] # position_y
      assert_in_delta 1.0, result[0][4] # direction_x
      assert_in_delta 0.0, result[0][5] # direction_y
      assert_in_delta 45.0, result[0][6] # angle
      assert_equal 1, result[0][7] # noclip_mode
      assert_in_delta 0.016, result[0][8] # delta_time
    end

    def test_render_frame_logging
      @logger.log_render_frame(0.016, 100, 60.0)

      db = SQLite3::Database.new(@db_path)
      result = db.execute('SELECT * FROM render_frames ORDER BY timestamp DESC LIMIT 1')

      assert_equal 1, result.length
      assert_in_delta 0.016, result[0][2] # frame_time
      assert_equal 100, result[0][3] # ray_count
      assert_in_delta 60.0, result[0][4] # fps
    end

    def test_collision_logging
      player = MockPlayer.new
      attempted_position = Vector[4.0, 5.0]
      @logger.log_collision(player, attempted_position, false)

      db = SQLite3::Database.new(@db_path)
      result = db.execute('SELECT * FROM collision_events ORDER BY timestamp DESC LIMIT 1')

      assert_equal 1, result.length
      assert_in_delta 2.0, result[0][2] # player_x
      assert_in_delta 3.0, result[0][3] # player_y
      assert_in_delta 4.0, result[0][4] # attempted_x
      assert_in_delta 5.0, result[0][5] # attempted_y
      assert_equal 0, result[0][6] # successful
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
      @logger.debug('Test debug')
      @logger.log_game_event('test_event')
      @logger.log_player_movement(MockPlayer.new, 0.016)
      @logger.log_render_frame(0.016, 100, 60.0)
      @logger.log_collision(MockPlayer.new, Vector[4.0, 5.0], false)

      db = SQLite3::Database.new(@db_path)

      assert_operator db.execute('SELECT COUNT(*) FROM debug_logs')[0][0], :>, 0
      assert_operator db.execute('SELECT COUNT(*) FROM game_events')[0][0], :>, 0
      assert_operator db.execute('SELECT COUNT(*) FROM player_movements')[0][0], :>, 0
      assert_operator db.execute('SELECT COUNT(*) FROM render_frames')[0][0], :>, 0
      assert_operator db.execute('SELECT COUNT(*) FROM collision_events')[0][0], :>, 0

      @logger.clear_logs

      assert_equal 0, db.execute('SELECT COUNT(*) FROM debug_logs')[0][0]
      assert_equal 0, db.execute('SELECT COUNT(*) FROM game_events')[0][0]
      assert_equal 0, db.execute('SELECT COUNT(*) FROM player_movements')[0][0]
      assert_equal 0, db.execute('SELECT COUNT(*) FROM render_frames')[0][0]
      assert_equal 0, db.execute('SELECT COUNT(*) FROM collision_events')[0][0]
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
    end
  end

  # Mock player class for testing
  class MockPlayer
    def position
      Vector[2.0, 3.0]
    end

    def direction
      Vector[1.0, 0.0]
    end

    def angle
      45.0
    end

    def noclip_mode
      true
    end
  end
end
