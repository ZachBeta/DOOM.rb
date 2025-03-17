# frozen_string_literal: true

require 'fileutils'
require 'logger'
require 'sqlite3'
require 'json'

module Doom
  class LogManager
    def initialize(base_dir = 'logs', db_path = 'data/debug.db', env = :development)
      @base_dir = base_dir
      @db_path = db_path
      @env = env
      FileUtils.mkdir_p(@base_dir)
      FileUtils.mkdir_p(File.dirname(@db_path))
      setup_loggers
      setup_database
    end

    def write(message, level, component: nil, event: nil, data: {})
      timestamp = Time.now.to_f

      # Write to appropriate log file
      case level
      when :debug
        @debug_log.send(level, format_message(message, component))
      when :verbose
        @verbose_log.send(:debug, format_message(message, component))
      when :info
        @game_log.send(level, format_message(message, component))
      when :warn, :error, :fatal
        @doom_log.send(level, format_message(message, component))
      end

      # If event is provided, log to database
      log_event(timestamp, event, data) if event

      # Always log to debug_logs table with component if provided
      log_debug_entry(timestamp, component || '', message, data, level.to_s.upcase)
    end

    def log_game_event(event_type, data = {})
      execute_sql(
        'INSERT INTO game_events (timestamp, event_type, event_data) VALUES (?, ?, ?)',
        [Time.now.to_f, event_type, data.to_json]
      )
    end

    def log_player_movement(player, delta_time)
      data = {
        position: player.position.to_a,
        direction: player.direction.to_a,
        angle: player.angle,
        noclip_mode: player.noclip_mode,
        delta_time: delta_time
      }
      log_game_event('player_movement', data)
    end

    def log_render_frame(frame_time, ray_count, fps)
      data = {
        frame_time: frame_time,
        ray_count: ray_count,
        fps: fps
      }
      log_game_event('render_frame', data)
    end

    def log_collision(player, attempted_position, successful)
      data = {
        player_position: player.position.to_a,
        attempted_position: attempted_position.to_a,
        successful: successful
      }
      log_game_event('collision', data)
    end

    def query_logs(conditions = {})
      where_clauses = []
      params = []

      conditions.each do |key, value|
        where_clauses << "#{key} = ?"
        params << value
      end

      where_sql = where_clauses.empty? ? '' : "WHERE #{where_clauses.join(' AND ')}"

      @db.execute(
        "SELECT timestamp, component, message, data, level FROM debug_logs #{where_sql} ORDER BY timestamp DESC LIMIT 1000",
        params
      ).map do |row|
        {
          timestamp: row[0],
          component: row[1],
          message: row[2],
          data: row[3] ? JSON.parse(row[3]) : {},
          level: row[4]
        }
      end
    rescue SQLite3::Exception => e
      @doom_log.error("Failed to query debug logs: #{e.message}")
      raise e if @env == :test

      []
    end

    def query_game_events(conditions = {})
      where_clauses = []
      params = []

      conditions.each do |key, value|
        where_clauses << "#{key} = ?"
        params << value
      end

      where_sql = where_clauses.empty? ? '' : "WHERE #{where_clauses.join(' AND ')}"

      @db.execute(
        "SELECT timestamp, event_type, event_data FROM game_events #{where_sql} ORDER BY timestamp DESC LIMIT 1000",
        params
      ).map do |row|
        {
          timestamp: row[0],
          event_type: row[1],
          data: row[2] ? JSON.parse(row[2]) : {}
        }
      end
    rescue SQLite3::Exception => e
      @doom_log.error("Failed to query game events: #{e.message}")
      raise e if @env == :test

      []
    end

    def clear_logs
      @db.execute('DELETE FROM debug_logs')
      @db.execute('DELETE FROM game_events')
    rescue SQLite3::Exception => e
      @doom_log.error("Failed to clear logs: #{e.message}")
      raise e if @env == :test
    end

    def close
      [@game_log, @debug_log, @verbose_log, @doom_log].each(&:close)
      @db&.close
    end

    private

    def format_message(message, component)
      component ? "[#{component}] #{message}" : message
    end

    def setup_loggers
      @game_log = ::Logger.new(File.join(@base_dir, 'game.log'))
      @debug_log = ::Logger.new(File.join(@base_dir, 'debug.log'))
      @verbose_log = ::Logger.new(File.join(@base_dir, 'verbose.log'))
      @doom_log = ::Logger.new(File.join(@base_dir, 'doom.log'))

      [@game_log, @debug_log, @verbose_log, @doom_log].each do |logger|
        setup_logger_formatting(logger)
      end
    end

    def setup_logger_formatting(logger)
      logger.formatter = proc do |severity, _datetime, _progname, msg|
        "[#{severity}] #{msg}\n"
      end
    end

    def setup_database
      @db = SQLite3::Database.new(@db_path)
      create_tables
      create_indexes
    end

    def create_tables
      @db.execute_batch(<<-SQL)
        CREATE TABLE IF NOT EXISTS debug_logs (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          timestamp REAL NOT NULL,
          component TEXT NOT NULL,
          message TEXT NOT NULL,
          data TEXT NOT NULL,
          level TEXT NOT NULL
        );

        CREATE TABLE IF NOT EXISTS game_events (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          timestamp REAL NOT NULL,
          event_type TEXT NOT NULL,
          event_data TEXT NOT NULL
        );
      SQL
    end

    def create_indexes
      @db.execute_batch(<<-SQL)
        CREATE INDEX IF NOT EXISTS idx_debug_logs_timestamp ON debug_logs(timestamp);
        CREATE INDEX IF NOT EXISTS idx_debug_logs_component ON debug_logs(component);
        CREATE INDEX IF NOT EXISTS idx_debug_logs_level ON debug_logs(level);
        CREATE INDEX IF NOT EXISTS idx_game_events_timestamp ON game_events(timestamp);
        CREATE INDEX IF NOT EXISTS idx_game_events_type ON game_events(event_type);
      SQL
    end

    def execute_sql(sql, params = [])
      @db.execute(sql, params)
    rescue SQLite3::Exception => e
      @doom_log.error("Database error: #{e.message}")
      @doom_log.error("SQL: #{sql}")
      @doom_log.error("Params: #{params.inspect}")
      raise e if @env == :test
    end

    def log_debug_entry(timestamp, component, message, data, level)
      execute_sql(
        'INSERT INTO debug_logs (timestamp, component, message, data, level) VALUES (?, ?, ?, ?, ?)',
        [timestamp, component, message, data.to_json, level]
      )
    end

    def log_event(timestamp, event, data)
      execute_sql(
        'INSERT INTO game_events (timestamp, event_type, event_data) VALUES (?, ?, ?)',
        [timestamp, event, data.to_json]
      )
    end
  end

  class Logger
    LEVELS = {
      debug: 0,
      verbose: 1,
      info: 2,
      warn: 3,
      error: 4,
      fatal: 5
    }.freeze

    class << self
      def instance
        @instance ||= new
      end

      def configure(level: :info, base_dir: 'logs', db_path: 'data/debug.db', env: :development)
        @instance = new(level, base_dir, db_path, env)
      end

      def setup
        configure(level: :debug, base_dir: 'logs', db_path: 'data/debug.db', env: :test)
      end
    end

    def initialize(level = :info, base_dir = 'logs', db_path = 'data/debug.db', env = :development)
      @level = LEVELS.fetch(level, 1)
      @log_manager = LogManager.new(base_dir, db_path, env)
      @env = env
    end

    def verbose(message, component: nil, event: nil, data: {})
      log(message, :verbose, component: component, event: event, data: data)
    end

    def debug(message, component: nil, event: nil, data: {})
      log(message, :debug, component: component, event: event, data: data)
    end

    def info(message, component: nil, event: nil, data: {})
      log(message, :info, component: component, event: event, data: data)
    end

    def warn(message, component: nil, event: nil, data: {})
      log(message, :warn, component: component, event: event, data: data)
    end

    def error(message, component: nil, event: nil, data: {})
      log(message, :error, component: component, event: event, data: data)
    end

    def fatal(message, component: nil, event: nil, data: {})
      log(message, :fatal, component: component, event: event, data: data)
    end

    # Game-specific logging methods
    def log_game_event(event_type, data = {})
      @log_manager.log_game_event(event_type, data)
    end

    def log_player_movement(player, delta_time)
      @log_manager.log_player_movement(player, delta_time)
    end

    def log_render_frame(frame_time, ray_count, fps)
      @log_manager.log_render_frame(frame_time, ray_count, fps)
    end

    def log_collision(player, attempted_position, successful)
      @log_manager.log_collision(player, attempted_position, successful)
    end

    # Query methods
    def query_logs(conditions = {})
      @log_manager.query_logs(conditions)
    end

    def query_game_events(conditions = {})
      @log_manager.query_game_events(conditions)
    end

    def clear_logs
      @log_manager.clear_logs
    end

    private

    def log(message, level, component: nil, event: nil, data: {})
      return unless should_log?(level)

      @log_manager.write(message, level, component: component, event: event, data: data)
    end

    def should_log?(level)
      LEVELS[level] >= @level
    end
  end
end
