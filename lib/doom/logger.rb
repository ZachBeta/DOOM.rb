require 'fileutils'

module Doom
  class LogManager
    def initialize
      FileUtils.mkdir_p('logs')
      @game_log = File.open('logs/game.log', 'a')
      @debug_log = File.open('logs/debug.log', 'a')
    end

    def write(message, level)
      timestamp = Time.now.strftime('%Y-%m-%d %H:%M:%S.%L')
      formatted_message = "[#{timestamp}] [#{level.upcase}] #{message}"
      
      case level
      when :debug
        @debug_log.puts(formatted_message)
        @debug_log.flush
      else
        @game_log.puts(formatted_message)
        @game_log.flush
      end
    end

    def close
      @game_log.close
      @debug_log.close
    end
  end

  class Logger
    LEVELS = {
      debug: 0,
      info: 1,
      warn: 2,
      error: 3,
      fatal: 4
    }.freeze

    def initialize(level = :info, output = $stdout)
      @level = LEVELS.fetch(level, 1)
      @output = output
      @log_manager = LogManager.new
    end

    def debug(message)
      log(message, :debug)
    end

    def info(message)
      log(message, :info)
    end

    def warn(message)
      log(message, :warn)
    end

    def error(message)
      log(message, :error)
    end

    def fatal(message)
      log(message, :fatal)
    end

    private

    def log(message, level)
      return unless LEVELS[level] >= @level

      @log_manager.write(message, level)
      
      # Only show non-debug messages in console
      if level != :debug
        timestamp = Time.now.strftime('%Y-%m-%d %H:%M:%S.%L')
        @output.puts("[#{timestamp}] [#{level.upcase}] #{message}")
      end
    end
  end
end 