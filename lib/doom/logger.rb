require 'fileutils'
require 'logger'

module Doom
  class LogManager
    MAX_LOG_SIZE = 1024 * 1024 # 1MB
    LOG_SHIFTS = 5 # Keep 5 rotated files

    def initialize
      FileUtils.mkdir_p('logs')
      setup_loggers
    end

    def write(message, level)
      timestamp = Time.now.strftime('%Y-%m-%d %H:%M:%S.%L')
      formatted_message = "[#{timestamp}] [#{level.upcase}] #{message}"
      
      case level
      when :debug
        @debug_log.send(level, message)
      when :verbose
        @verbose_log.debug(message)
      else
        @game_log.send(level, message)
      end
    end

    def close
      [@game_log, @debug_log, @verbose_log].each(&:close)
    end

    private

    def setup_loggers
      @game_log = ::Logger.new('logs/game.log', LOG_SHIFTS, MAX_LOG_SIZE)
      @debug_log = ::Logger.new('logs/debug.log', LOG_SHIFTS, MAX_LOG_SIZE)
      @verbose_log = ::Logger.new('logs/verbose.log', LOG_SHIFTS, MAX_LOG_SIZE)

      setup_logger_formatting(@game_log)
      setup_logger_formatting(@debug_log)
      setup_logger_formatting(@verbose_log)
    end

    def setup_logger_formatting(logger)
      logger.formatter = proc do |severity, datetime, progname, msg|
        "[#{datetime.strftime('%Y-%m-%d %H:%M:%S.%L')}] [#{severity}] #{msg}\n"
      end
    end
  end

  class Logger
    LEVELS = {
      verbose: -1, # More detailed than debug
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

    def verbose(message)
      log(message, :verbose)
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
      return unless should_log?(level)

      @log_manager.write(message, level)
      
      # Only show non-debug/verbose messages in console
      if level != :debug && level != :verbose
        timestamp = Time.now.strftime('%Y-%m-%d %H:%M:%S.%L')
        @output.puts("[#{timestamp}] [#{level.upcase}] #{message}")
      end
    end

    def should_log?(level)
      LEVELS[level] >= @level
    end
  end
end 