# frozen_string_literal: true

require 'sqlite3'
require 'json'

module DOOM
  # DebugLogger provides SQLite-based logging for debugging and development
  class DebugLogger
    def initialize(db_path = 'data/debug.db')
      @db = SQLite3::Database.new(db_path)
      setup_database
    end

    def log(component:, event:, data: {}, level: 'DEBUG')
      timestamp = Time.now.to_f
      @db.execute(
        'INSERT INTO debug_logs (timestamp, component, event, data, level) VALUES (?, ?, ?, ?, ?)',
        [timestamp, component.to_s, event.to_s, data.to_json, level.to_s.upcase]
      )
    rescue SQLite3::Exception => e
      warn "Failed to log debug info: #{e.message}"
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
        "SELECT timestamp, component, event, data, level FROM debug_logs #{where_sql} ORDER BY timestamp DESC LIMIT 1000",
        params
      ).map do |row|
        {
          timestamp: row[0],
          component: row[1],
          event: row[2],
          data: JSON.parse(row[3]),
          level: row[4]
        }
      end
    rescue SQLite3::Exception => e
      warn "Failed to query debug logs: #{e.message}"
      []
    end

    def clear_logs
      @db.execute('DELETE FROM debug_logs')
    rescue SQLite3::Exception => e
      warn "Failed to clear debug logs: #{e.message}"
    end

    private

    def setup_database
      @db.execute <<-SQL
        CREATE TABLE IF NOT EXISTS debug_logs (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          timestamp REAL NOT NULL,
          component TEXT NOT NULL,
          event TEXT NOT NULL,
          data TEXT NOT NULL,
          level TEXT NOT NULL
        );
      SQL

      @db.execute 'CREATE INDEX IF NOT EXISTS idx_timestamp ON debug_logs(timestamp);'
      @db.execute 'CREATE INDEX IF NOT EXISTS idx_component ON debug_logs(component);'
      @db.execute 'CREATE INDEX IF NOT EXISTS idx_level ON debug_logs(level);'
    rescue SQLite3::Exception => e
      warn "Failed to setup debug database: #{e.message}"
    end
  end
end
