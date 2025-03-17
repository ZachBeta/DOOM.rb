# frozen_string_literal: true

require 'test_helper'
require 'doom/game'

module Doom
  class CleanupTest < Minitest::Test
    def setup
      super
      @game = Game.new
    end

    def test_game_cleanup_sequence
      # Run cleanup
      @game.send(:cleanup)
    end
  end
end
