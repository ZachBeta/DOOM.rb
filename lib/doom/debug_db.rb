# frozen_string_literal: true

require 'sqlite3'
require 'json'
require 'fileutils'
require_relative 'logger'

module Doom
  class DebugDB
    def initialize(db_path = 'data/debug.db')
      @logger = Logger.instance
      @db_path = db_path
      ensure_data_directory
      setup_database
    end

    def log_player_movement(player, delta_time)
      execute_sql(
        'INSERT INTO player_movements (timestamp, position_x, position_y, direction_x, direction_y, angle, noclip_mode, delta_time)
         VALUES (?, ?, ?, ?, ?, ?, ?, ?)',
        [
          Time.now.to_f,
          player.position[0],
          player.position[1],
          player.direction[0],
          player.direction[1],
          player.angle,
          player.noclip_mode ? 1 : 0,
          delta_time
        ]
      )
    end

    def log_collision(player, attempted_position, successful)
      execute_sql(
        'INSERT INTO collision_events (timestamp, player_x, player_y, attempted_x, attempted_y, successful)
         VALUES (?, ?, ?, ?, ?, ?)',
        [
          Time.now.to_f,
          player.position[0],
          player.position[1],
          attempted_position[0],
          attempted_position[1],
          successful ? 1 : 0
        ]
      )
    end

    def log_render_frame(frame_time, ray_count, fps)
      execute_sql(
        'INSERT INTO render_frames (timestamp, frame_time, ray_count, fps)
         VALUES (?, ?, ?, ?)',
        [Time.now.to_f, frame_time, ray_count, fps]
      )
    end

    def get_recent_collisions(limit = 100)
      query_sql(
        'SELECT * FROM collision_events
         ORDER BY timestamp DESC
         LIMIT ?',
        [limit]
      )
    end

    def get_fps_stats(seconds_ago = 60)
      query_sql(
        'SELECT
           AVG(fps) as avg_fps,
           MIN(fps) as min_fps,
           MAX(fps) as max_fps,
           COUNT(*) as frame_count
         FROM render_frames
         WHERE timestamp > ?',
        [Time.now.to_f - seconds_ago]
      ).first
    end

    def get_movement_history(limit = 1000)
      query_sql(
        'SELECT * FROM player_movements
         ORDER BY timestamp DESC
         LIMIT ?',
        [limit]
      )
    end

    def clear_old_data(hours_ago = 24)
      cutoff = Time.now.to_f - (hours_ago * 3600)
      tables = %w[player_movements collision_events render_frames]

      tables.each do |table|
        execute_sql("DELETE FROM #{table} WHERE timestamp < ?", [cutoff])
      end
    end

    private

    def ensure_data_directory
      dirname = File.dirname(@db_path)
      FileUtils.mkdir_p(dirname) unless File.directory?(dirname)
    rescue StandardError => e
      @logger.error("DebugDB: Failed to create data directory: #{e.message}")
      raise
    end

    def setup_database
      @db = SQLite3::Database.new(@db_path)
      @db.results_as_hash = true

      create_tables
      create_indexes
    rescue SQLite3::Exception => e
      @logger.error("DebugDB: Failed to setup database: #{e.message}")
      raise
    end

    def create_tables
      @db.execute_batch(<<-SQL)
        CREATE TABLE IF NOT EXISTS game_events (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          timestamp REAL NOT NULL,
          event_type TEXT NOT NULL,
          event_data TEXT NOT NULL
        );

        CREATE TABLE IF NOT EXISTS player_movements (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          timestamp REAL NOT NULL,
          position_x REAL NOT NULL,
          position_y REAL NOT NULL,
          direction_x REAL NOT NULL,
          direction_y REAL NOT NULL,
          angle REAL NOT NULL,
          noclip_mode INTEGER NOT NULL,
          delta_time REAL NOT NULL
        );

        CREATE TABLE IF NOT EXISTS collision_events (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          timestamp REAL NOT NULL,
          player_x REAL NOT NULL,
          player_y REAL NOT NULL,
          attempted_x REAL NOT NULL,
          attempted_y REAL NOT NULL,
          successful INTEGER NOT NULL
        );

        CREATE TABLE IF NOT EXISTS render_frames (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          timestamp REAL NOT NULL,
          frame_time REAL NOT NULL,
          ray_count INTEGER NOT NULL,
          fps REAL NOT NULL
        );
      SQL
    end

    def create_indexes
      @db.execute_batch(<<-SQL)
        CREATE INDEX IF NOT EXISTS idx_game_events_timestamp ON game_events(timestamp);
        CREATE INDEX IF NOT EXISTS idx_game_events_type ON game_events(event_type);
        CREATE INDEX IF NOT EXISTS idx_player_movements_timestamp ON player_movements(timestamp);
        CREATE INDEX IF NOT EXISTS idx_collision_events_timestamp ON collision_events(timestamp);
        CREATE INDEX IF NOT EXISTS idx_render_frames_timestamp ON render_frames(timestamp);
      SQL
    end

    def execute_sql(sql, params = [])
      @db.execute(sql, params)
    rescue SQLite3::Exception => e
      @logger.error("DebugDB: Failed to execute SQL: #{e.message}")
      @logger.error("SQL: #{sql}")
      @logger.error("Params: #{params.inspect}")
    end

    def query_sql(sql, params = [])
      @db.execute(sql, params)
    rescue SQLite3::Exception => e
      @logger.error("DebugDB: Failed to query SQL: #{e.message}")
      @logger.error("SQL: #{sql}")
      @logger.error("Params: #{params.inspect}")
      []
    end
  end
end
