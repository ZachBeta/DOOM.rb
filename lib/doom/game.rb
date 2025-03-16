# frozen_string_literal: true

require_relative 'logger'

module Doom
  class Game
    def initialize
      @logger = Logger.instance
    end

    def cleanup
      @logger.info('Game: Starting cleanup sequence', component: 'Game')
      @logger.log_game_event('cleanup_start')
      @logger.log_game_event('cleanup_complete')
      @logger.info('Game: Cleanup complete', component: 'Game')
    end
  end
end
