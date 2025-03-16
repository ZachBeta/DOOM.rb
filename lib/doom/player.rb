# frozen_string_literal: true

require 'matrix'

module Doom
  class Player
    attr_reader :position, :direction

    def initialize
      @position = Vector[2.0, 2.0]  # Starting position (x, y)
      @direction = Vector[1.0, 0.0] # Initial direction vector
    end

    def move_forward(delta_time)
      new_position = @position + (@direction * delta_time)
      @position = new_position
    end

    def strafe_left(delta_time)
      # With initial direction (1,0), strafing left moves in negative Y
      perpendicular = Vector[-@direction[1], @direction[0]]
      new_position = @position - (perpendicular * delta_time)
      @position = new_position
    end
  end
end
