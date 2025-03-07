# frozen_string_literal: true

require 'matrix'

module Doom
  class Ray
    attr_reader :direction_x, :direction_y

    def initialize(angle)
      @direction_x = Math.cos(angle)
      @direction_y = Math.sin(angle)
    end
  end
end
