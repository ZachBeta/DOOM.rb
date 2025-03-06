# frozen_string_literal: true

require 'fileutils'
require 'logger'

module Doom
  class LogManager
    MAX_LOG_SIZE = 1024 * 1024 # 1MB
    LOG_SHIFTS = 5 # Keep 5 rotated files

    def initialize(base_dir = 'logs')
      @base_dir = base_dir
      FileUtils.mkdir_p(@base_dir)
      setup_loggers
    end

    def write(message, level)
      Time.now.strftime('%Y-%m-%d %H:%M:%S.%L')

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
      FileUtils.mkdir_p(@base_dir)
      timestamp = Time.now.strftime('%Y%m%d_%H%M%S')
      @game_log = ::Logger.new(File.join(@base_dir, "game_#{timestamp}.log"), LOG_SHIFTS,
                               MAX_LOG_SIZE)
      @debug_log = ::Logger.new(File.join(@base_dir, "debug_#{timestamp}.log"), LOG_SHIFTS,
                                MAX_LOG_SIZE)
      @verbose_log = ::Logger.new(File.join(@base_dir, "verbose_#{timestamp}.log"), LOG_SHIFTS,
                                  MAX_LOG_SIZE)

      setup_logger_formatting(@game_log)
      setup_logger_formatting(@debug_log)
      setup_logger_formatting(@verbose_log)
    end

    def setup_logger_formatting(logger)
      git_sha = `git rev-parse --short HEAD`.strip
      logger.formatter = proc do |severity, datetime, _progname, msg|
        "[#{datetime.strftime('%Y-%m-%d %H:%M:%S.%L')}] [#{severity}] [#{git_sha}] #{msg}\n"
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

    class << self
      def instance
        @instance ||= new
      end

      def configure(level: :info, base_dir: 'logs', env: :development)
        @instance = new(level, base_dir, env)
      end

      private :new
    end

    def initialize(level = :info, base_dir = 'logs', env = :development)
      @level = LEVELS.fetch(level, 1)
      @env = env
      @log_manager = LogManager.new(base_dir)
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
    end

    def should_log?(level)
      LEVELS[level] >= @level
    end

    def test?
      @env == :test
    end
  end
end
