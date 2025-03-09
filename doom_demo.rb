#!/usr/bin/env ruby

require 'ruby2d'
require_relative 'stinom_draw'

set title: 'DOOM-like Demo'
set width: 800
set height: 600
set background: 'black'

# Player state
$player = {
  position: [-350.0, -350.0, 0.0],  # Start in a corner of the room
  angle: Math::PI / 4,              # Face into the room
  speed: 3.0                        # Slower speed for better control
}

# Initialize 3D renderer
$draw = StinomDrawXE.new(
  [0.0, 0.0, 0.0],  # viewpoint at player position
  [0.0, 0.0, 0.0],  # rotation
  0, 1, 2, 0, 0     # axes
)

$shapes = []
$walls = [] # Store wall segments for collision and minimap

# FPS tracking
$frame_times = []
$fps_text = nil

# Create a wall segment
def wall(x1, y1, x2, y2, height)
  index = $draw.pointIndex

  # Bottom points
  $draw.addPoint([x1, y1, 0])
  $draw.addPoint([x2, y2, 0])

  # Top points
  $draw.addPoint([x2, y2, height])
  $draw.addPoint([x1, y1, height])

  # Add the wall face
  $draw.addShape([index, index + 1, index + 2, index + 3])

  # Store wall segment for collision and minimap
  $walls << [[x1, y1], [x2, y2]]
end

# Create the room layout
def create_room
  height = 200.0 # wall height

  # Outer walls
  wall(-400, -400, 400, -400, height)  # North
  wall(400, -400, 400, 400, height)    # East
  wall(400, 400, -400, 400, height)    # South
  wall(-400, 400, -400, -400, height)  # West

  # Inner walls - create a simple maze-like structure
  wall(-200, -200, 200, -200, height)  # Inner wall 1
  wall(200, -200, 200, 0, height)      # Inner wall 2
  wall(-200, 0, 200, 0, height)        # Inner wall 3
  wall(-200, -200, -200, 200, height)  # Inner wall 4
end

# Draw the minimap
def draw_minimap
  scale = 0.1 # Scale factor for minimap
  offset_x = Window.width - 220 # Position in top-right corner
  offset_y = 20

  # Draw background
  Square.new(
    x: offset_x - 10,
    y: offset_y - 10,
    size: 220,
    color: 'black',
    z: 100
  )

  # Draw walls
  $walls.each do |wall|
    Line.new(
      x1: offset_x + (wall[0][0] * scale),
      y1: offset_y + (wall[0][1] * scale),
      x2: offset_x + (wall[1][0] * scale),
      y2: offset_y + (wall[1][1] * scale),
      width: 2,
      color: 'green',
      z: 101
    )
  end

  # Draw player position
  Square.new(
    x: offset_x + ($player[:position][0] * scale) - 2,
    y: offset_y + ($player[:position][1] * scale) - 2,
    size: 4,
    color: 'red',
    z: 102
  )

  # Draw player direction
  look_x = Math.cos($player[:angle]) * 10
  look_y = Math.sin($player[:angle]) * 10
  Line.new(
    x1: offset_x + ($player[:position][0] * scale),
    y1: offset_y + ($player[:position][1] * scale),
    x2: offset_x + (($player[:position][0] + look_x) * scale),
    y2: offset_y + (($player[:position][1] + look_y) * scale),
    width: 2,
    color: 'yellow',
    z: 102
  )
end

# Update FPS counter
def update_fps
  current_time = Time.now.to_f
  $frame_times.push(current_time)
  $frame_times.shift while $frame_times.length > 30

  return unless $frame_times.length > 1

  fps = ($frame_times.length - 1) / ($frame_times.last - $frame_times.first)
  $fps_text&.remove
  $fps_text = Text.new(
    "FPS: #{fps.round}",
    x: 10, y: 10,
    size: 20,
    color: 'green',
    z: 100
  )
end

# Update player view based on current position and angle
def update_view
  # Calculate view direction
  look_x = Math.cos($player[:angle])
  look_y = Math.sin($player[:angle])

  $draw.viewPoint = [
    $player[:position][0],
    $player[:position][1],
    $player[:position][2] + 50.0 # Eye height
  ]
end

# Simple collision detection with line segments
def would_collide?(new_x, new_y, radius = 15.0) # Smaller collision radius
  $walls.any? do |wall|
    # Calculate distances to wall segment
    x1, y1 = wall[0]
    x2, y2 = wall[1]

    # Vector from wall start to player
    wall_vec_x = x2 - x1
    wall_vec_y = y2 - y1
    wall_length = Math.sqrt((wall_vec_x * wall_vec_x) + (wall_vec_y * wall_vec_y))
    return false if wall_length == 0

    # Calculate closest point on wall
    t = [0, [1, (((new_x - x1) * wall_vec_x) + ((new_y - y1) * wall_vec_y)) /
      (wall_length * wall_length)].min].max

    closest_x = x1 + (t * wall_vec_x)
    closest_y = y1 + (t * wall_vec_y)

    # Check if distance to closest point is less than radius
    dx = new_x - closest_x
    dy = new_y - closest_y
    distance = Math.sqrt((dx * dx) + (dy * dy))

    distance < radius
  end
end

# Handle player movement
on :key_held do |event|
  # Calculate movement vectors
  forward_x = Math.cos($player[:angle]) * $player[:speed]
  forward_y = Math.sin($player[:angle]) * $player[:speed]
  right_x = Math.cos($player[:angle] + (Math::PI / 2)) * $player[:speed]
  right_y = Math.sin($player[:angle] + (Math::PI / 2)) * $player[:speed]

  new_x = $player[:position][0]
  new_y = $player[:position][1]

  case event.key
  when 'w'  # Forward
    new_x += forward_x
    new_y += forward_y
  when 's'  # Backward
    new_x -= forward_x
    new_y -= forward_y
  when 'a'  # Strafe left
    new_x -= right_x
    new_y -= right_y
  when 'd'  # Strafe right
    new_x += right_x
    new_y += right_y
  when 'left' # Turn left
    $player[:angle] -= 0.05
  when 'right' # Turn right
    $player[:angle] += 0.05
  when 'escape' # Reset position if stuck
    $player[:position] = [-350.0, -350.0, 0.0]
    $player[:angle] = Math::PI / 4
  end

  # Try to move in X and Y separately to allow sliding along walls
  $player[:position][0] = new_x unless would_collide?(new_x, $player[:position][1])
  $player[:position][1] = new_y unless would_collide?($player[:position][0], new_y)
end

def render_frame
  # Reset for new frame
  $shapes = []
  $draw.reset

  # Update view based on player position
  update_view

  # Create room geometry
  create_room

  # Project 3D to 2D
  $draw.set2dPoints
  $draw.setDrawOrder
  $draw.offset([Window.width / 2.0, Window.height / 2.0])

  # Render all shapes
  index = $draw.shapeIndex - 1
  colors = ['#444444', '#333333', '#222222'] # Dark colors for walls

  while index != -1
    shape = $draw.shapes[$draw.drawOrder[index]]
    next unless shape

    color = colors[$draw.drawOrder[index] % 3]

    if shape.length == 4
      points = shape.map { |i| $draw.points2d[i] }
      if points.all?
        $shapes.push(
          Quad.new(
            x1: points[0][0], y1: points[0][1],
            x2: points[1][0], y2: points[1][1],
            x3: points[2][0], y3: points[2][1],
            x4: points[3][0], y4: points[3][1],
            color: color
          )
        )
      end
    end
    index -= 1
  end

  # Draw UI elements
  draw_minimap
  update_fps
end

# Main game loop
update do
  clear
  render_frame
end

show
