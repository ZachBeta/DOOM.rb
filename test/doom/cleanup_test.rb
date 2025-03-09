# frozen_string_literal: true

require 'test_helper'
require 'doom/game'
require 'doom/map'

module Doom
  class CleanupTest < Minitest::Test
    def setup
      super
      @map = Map.new
      @game = Game.new
    end

    def test_game_cleanup_sequence
      # Run cleanup
      @game.send(:cleanup)
    end
  end
end
