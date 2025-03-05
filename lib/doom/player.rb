require 'matrix'

module Doom
  class Player
    attr_reader :position, :direction, :plane

    MOVE_SPEED = 5.0
    ROTATION_SPEED = 3.0

    def initialize
      @position = Vector[2.0, 2.0]  # Starting position (x, y)
      @direction = Vector[1.0, 0.0] # Initial direction vector
      @plane = Vector[0.0, 0.66]    # Camera plane vector (FOV)
    end

    def update(delta_time)
      # Any per-frame updates that aren't input-related
    end

    def move_forward(delta_time)
      move(@direction, delta_time)
    end

    def move_backward(delta_time)
      move(-@direction, delta_time)
    end

    def strafe_left(delta_time)
      # Move perpendicular to direction
      strafe_vector = Vector[-@direction[1], @direction[0]]
      move(strafe_vector, delta_time)
    end

    def strafe_right(delta_time)
      # Move perpendicular to direction (opposite of strafe_left)
      strafe_vector = Vector[@direction[1], -@direction[0]]
      move(strafe_vector, delta_time)
    end

    def rotate_left(delta_time)
      rotate(-ROTATION_SPEED * delta_time)
    end

    def rotate_right(delta_time)
      rotate(ROTATION_SPEED * delta_time)
    end

    private

    def move(direction_vector, delta_time)
      movement = direction_vector * (MOVE_SPEED * delta_time)
      @position += movement
    end

    def rotate(angle)
      # Rotation matrix for 2D vectors
      cos_angle = Math.cos(angle)
      sin_angle = Math.sin(angle)
      
      # Rotate direction vector
      old_dir_x = @direction[0]
      @direction = Vector[
        @direction[0] * cos_angle - @direction[1] * sin_angle,
        old_dir_x * sin_angle + @direction[1] * cos_angle
      ]
      
      # Rotate camera plane
      old_plane_x = @plane[0]
      @plane = Vector[
        @plane[0] * cos_angle - @plane[1] * sin_angle,
        old_plane_x * sin_angle + @plane[1] * cos_angle
      ]
    end
  end
end 