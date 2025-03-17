# frozen_string_literal: true

require 'matrix'

module Doom
  class Monster
    attr_reader :position, :type, :health, :state

    TYPES = {
      imp: { health: 60, damage: 20, speed: 0.8 },
      demon: { health: 150, damage: 40, speed: 1.0 },
      baron: { health: 1000, damage: 60, speed: 1.2 }
    }.freeze

    def initialize(x, y, type = :imp)
      @position = Vector[x.to_f, y.to_f]
      @type = type
      @health = TYPES[type][:health]
      @state = :idle
      @target = nil
      @last_update = Time.now
    end

    def update(player_position)
      current_time = Time.now
      delta_time = current_time - @last_update
      @last_update = current_time

      # Simple AI: Move towards player if within range
      if distance_to(player_position) < 5.0 && @health.positive?
        direction = (Vector[*player_position] - @position).normalize
        speed = TYPES[@type][:speed] * delta_time
        @position += direction * speed
        @state = :chase
      else
        @state = :idle
      end
    end

    def take_damage(amount)
      @health = [@health - amount, 0].max
      @state = :dead if @health.zero?
    end

    private

    def distance_to(other_position)
      (Vector[*other_position] - @position).magnitude
    end
  end
end
