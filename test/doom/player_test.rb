# frozen_string_literal: true

require_relative '../test_helper'
require_relative '../../lib/doom/player'

module Doom
  class PlayerTest < Minitest::Test
    def setup
      @player = Player.new
    end

    def test_initialization
      assert_equal Vector[2.0, 2.0], @player.position
      assert_equal Vector[1.0, 0.0], @player.direction
    end

    def test_move_forward
      initial_position = @player.position.dup
      @player.move_forward(0.1)

      # Player should have moved in the direction they're facing
      assert_operator @player.position[0], :>, initial_position[0]
      assert_in_delta initial_position[1], @player.position[1], 0.001
    end

    def test_strafe_left
      initial_position = @player.position.dup
      @player.strafe_left(0.1)

      # Player should have moved perpendicular to their facing direction
      # With initial direction (1,0), strafing left moves in negative Y
      assert_in_delta initial_position[0], @player.position[0], 0.001
      assert_operator @player.position[1], :<, initial_position[1]
    end
  end
end
