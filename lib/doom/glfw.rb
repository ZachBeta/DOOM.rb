# frozen_string_literal: true

require 'glfw3'
require_relative 'logger'

module Doom
  class Glfw
    class << self
      def instance
        @instance ||= new
      end

      private :new
    end

    def initialize
      @logger = Logger.instance
      @initialized = false
      @window = nil
      init
    end

    def init
      return if @initialized

      @logger.debug('Initializing GLFW')
      begin
        ::Glfw3.init
        @initialized = true
        @logger.info('GLFW initialized successfully')
      rescue StandardError => e
        @logger.error("Failed to initialize GLFW: #{e.message}")
        raise
      end
    end

    def terminate
      return unless @initialized

      @logger.debug('Terminating GLFW')
      @window&.destroy
      ::Glfw3.terminate
      @initialized = false
      @window = nil
      @logger.info('GLFW terminated successfully')
    end

    def create_window(width, height, title)
      @logger.debug("Creating window: #{width}x#{height} - #{title}")
      @window = ::Glfw3::Window.new(width, height, title)
      @window
    end

    attr_reader :window

    def initialized?
      @initialized
    end

    def poll_events
      @logger.debug('Polling GLFW events')
      ::Glfw3.poll_events
    end

    def window_hint(hint, value)
      @logger.debug("Setting window hint: #{hint} = #{value}")
      ::Glfw3::Window.window_hint(hint, value)
    end

    def default_window_hints
      @logger.debug('Setting default window hints')
      ::Glfw3::Window.default_window_hints
    end

    def get_key(key)
      @window&.get_key(key)
    end

    def should_close?
      @window&.should_close?
    end

    def swap_buffers
      @window&.swap_buffers
    end

    def make_context_current
      @window&.make_context_current
    end

    def destroy_window
      @window&.destroy
      @window = nil
    end
  end
end
