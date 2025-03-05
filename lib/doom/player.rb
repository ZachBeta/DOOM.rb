# frozen_string_literal: true

require 'matrix'

module Doom
  class Player
    attr_reader :position, :direction, :plane, :map
    attr_accessor :noclip_mode

    def initialize(map = nil)
      @position = Vector[2.0, 2.0]  # Starting position (x, y)
      @direction = Vector[1.0, 0.0] # Initial direction vector
      @plane = Vector[0.0, 0.66]    # Camera plane vector (FOV)
      @map = map
      @movement = Movement.new(self)
      @rotation = Rotation.new(self)
      @noclip_mode = false
    end

    def update(delta_time)
      # Any per-frame updates that aren't input-related
    end

    def set_map(map)
      @map = map
    end

    def move_forward(delta_time)
      @movement.forward(delta_time)
    end

    def move_backward(delta_time)
      @movement.backward(delta_time)
    end

    def strafe_left(delta_time)
      @movement.strafe_left(delta_time)
    end

    def strafe_right(delta_time)
      @movement.strafe_right(delta_time)
    end

    def rotate_left(delta_time)
      @rotation.left(delta_time)
    end

    def rotate_right(delta_time)
      @rotation.right(delta_time)
    end

    def toggle_noclip
      @noclip_mode = !@noclip_mode
    end

    def update_position(new_position)
      @position = new_position
    end

    def update_direction(new_direction)
      @direction = new_direction
    end

    def update_plane(new_plane)
      @plane = new_plane
    end
  end

  class Movement
    MOVE_SPEED = 5.0

    def initialize(player)
      @player = player
      @collision_detector = CollisionDetector.new
    end

    def forward(delta_time)
      move(@player.direction, delta_time)
    end

    def backward(delta_time)
      move(-@player.direction, delta_time)
    end

    def strafe_left(delta_time)
      strafe_vector = Vector[@player.direction[1], -@player.direction[0]]
      move(strafe_vector, delta_time)
    end

    def strafe_right(delta_time)
      strafe_vector = Vector[-@player.direction[1], @player.direction[0]]
      move(strafe_vector, delta_time)
    end

    private

    def move(direction_vector, delta_time)
      return unless @player.map

      movement = direction_vector * (MOVE_SPEED * delta_time)
      new_position = @player.position + movement

      if @player.noclip_mode
        @player.update_position(new_position)
      else
        # Try full movement first
        unless @collision_detector.collides?(@player.map, new_position)
          @player.update_position(new_position)
          return
        end

        # Try sliding along X axis
        x_slide = Vector[@player.position[0] + movement[0], @player.position[1]]
        unless @collision_detector.collides?(@player.map, x_slide)
          @player.update_position(x_slide)
          return
        end

        # Try sliding along Y axis
        y_slide = Vector[@player.position[0], @player.position[1] + movement[1]]
        @player.update_position(y_slide) unless @collision_detector.collides?(@player.map, y_slide)
      end
    end
  end

  class Rotation
    ROTATION_SPEED = 3.0

    def initialize(player)
      @player = player
    end

    def left(delta_time)
      rotate(-ROTATION_SPEED * delta_time)
    end

    def right(delta_time)
      rotate(ROTATION_SPEED * delta_time)
    end

    private

    def rotate(angle)
      cos_angle = Math.cos(angle)
      sin_angle = Math.sin(angle)

      rotate_direction(cos_angle, sin_angle)
      rotate_plane(cos_angle, sin_angle)
    end

    def rotate_direction(cos_angle, sin_angle)
      old_dir_x = @player.direction[0]
      new_direction = Vector[
        (@player.direction[0] * cos_angle) - (@player.direction[1] * sin_angle),
        (old_dir_x * sin_angle) + (@player.direction[1] * cos_angle)
      ]
      @player.update_direction(new_direction)
    end

    def rotate_plane(cos_angle, sin_angle)
      old_plane_x = @player.plane[0]
      new_plane = Vector[
        (@player.plane[0] * cos_angle) - (@player.plane[1] * sin_angle),
        (old_plane_x * sin_angle) + (@player.plane[1] * cos_angle)
      ]
      @player.update_plane(new_plane)
    end
  end

  class CollisionDetector
    COLLISION_MARGIN = 0.2 # Buffer distance from walls

    def collides?(map, position)
      # Extract x and y from the Vector
      x = position[0]
      y = position[1]

      # Check the current cell
      return true if map.wall_at?(x.to_i, y.to_i)

      # Check nearby cells based on collision margin
      check_points = collision_check_points(x, y)
      check_points.any? { |point_x, point_y| map.wall_at?(point_x.to_i, point_y.to_i) }
    end

    private

    def collision_check_points(x, y)
      [
        [x + COLLISION_MARGIN, y],
        [x - COLLISION_MARGIN, y],
        [x, y + COLLISION_MARGIN],
        [x, y - COLLISION_MARGIN]
      ]
    end
  end
end
