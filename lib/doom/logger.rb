module Doom
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
      @log_file = File.open('doom.log', 'a')
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

      timestamp = Time.now.strftime('%Y-%m-%d %H:%M:%S.%L')
      formatted_message = "[#{timestamp}] [#{level.upcase}] #{message}"
      
      @output.puts(formatted_message)
      @log_file.puts(formatted_message)
      @log_file.flush
    end
  end
end 