#!/usr/bin/env ruby

require 'ruby2d'
require_relative 'stinom_draw'

set title: 'X E'
set width: 800
set height: 600

# variables set up.
$draw = StinomDrawXE.new([0.0, 0.0, -1000.0], [0.0, 0.0, 0.0], 0, 1, 2, 0, 0)
$shapes = []
$position = [0.0, 0.0, 0.0] # Centered position
$positions = []
$velocities = []
index1 = 9

# Make positions and velocities.
while index1 != -1
  $positions.push([(rand * 400.0) - 200.0, (rand * 400.0) - 200.0, $position[2]]) # Wider spread
  $velocities.push([(rand * 4.0) - 2.0, (rand * 4.0) - 2.0]) # Slower velocities
  index1 -= 1
end

$part = []

# Make cube like structure.
def cube(position, size)
  # Local variable stores current point index starting.
  index = $draw.pointIndex
  $draw.addPoint([position[0] - (size / 2.0), position[1] - (size / 2.0),
                  position[2] - (size / 2.0)])
  $draw.addPoint([position[0] + (size / 2.0), position[1] - (size / 2.0),
                  position[2] - (size / 2.0)])
  $draw.addPoint([position[0] + (size / 2.0), position[1] + (size / 2.0),
                  position[2] - (size / 2.0)])
  $draw.addPoint([position[0] - (size / 2.0), position[1] + (size / 2.0),
                  position[2] - (size / 2.0)])
  $draw.addPoint([position[0] - (size / 2.0), position[1] - (size / 2.0),
                  position[2] + (size / 2.0)])
  $draw.addPoint([position[0] + (size / 2.0), position[1] - (size / 2.0),
                  position[2] + (size / 2.0)])
  $draw.addPoint([position[0] + (size / 2.0), position[1] + (size / 2.0),
                  position[2] + (size / 2.0)])
  $draw.addPoint([position[0] - (size / 2.0), position[1] + (size / 2.0),
                  position[2] + (size / 2.0)])
  $draw.addShape([index + 4, index + 5, index + 6, index + 7])
  $draw.addShape([index + 1, index, index + 4, index + 5])
  $draw.addShape([index + 3, index + 2, index + 6, index + 7])
  $draw.addShape([index + 1, index + 2, index + 6, index + 5])
  $draw.addShape([index, index + 3, index + 7, index + 4])
end

# Do stuff to view and other things upon key presses.
on :key_down do |event|
  case event.key
  when 'up'
    $draw.viewPoint[2] *= 2.0
  when 'down'
    $draw.viewPoint[2] /= 2.0
  when 'w'
    $position[0] += 100.0
  when 'e'
    $position[0] -= 100.0
  when 's'
    $position[1] += 100.0
  when 'd'
    $position[1] -= 100.0
  end
end

# Main draw function
def start
  # Set cube positions by velocities and input.
  index = $positions.length - 1
  while index != -1
    $positions[index][0] += $velocities[index][0]
    if $positions[index][0] < -Window.width / 2.0 || $positions[index][0] > Window.width / 2.0
      $positions[index][0] = -$positions[index][0] + $velocities[index][0]
    end
    $positions[index][1] += $velocities[index][1]
    if $positions[index][1] < -Window.height / 2.0 || $positions[index][1] > Window.height / 2.0
      $positions[index][1] = -$positions[index][1] + $velocities[index][1]
    end
    cube($positions[index], 50.0) # Smaller cube size
    index -= 1
  end

  # Make lines and points
  index = $draw.pointIndex
  while index != -1
    if index == 0
      $draw.addShape([index, $draw.pointIndex - 1])
    else
      $draw.addShape([index, index - 1])
    end
    $draw.addShape([index])
    index -= 1
  end

  # Setup
  $draw.set2dPoints
  $draw.setDrawOrder
  $draw.offset([Window.width.to_f / 2.0, Window.height.to_f / 2.0])

  index = $draw.shapeIndex - 1
  colors = ['#ff0000', '#0000ff', '#00ff00', '#ff00ff', '#00ffff', '#ffff00', '#ffffff']

  while index != -1
    shape = $draw.shapes[$draw.drawOrder[index]]
    next unless shape

    color = colors[$draw.drawOrder[index] % 7]

    if shape.length == 1
      point = $draw.points2d[shape[0]]
      if point
        $shapes.push(
          Square.new(
            x: point[0] - 2.5,
            y: point[1] - 2.5,
            size: 5,
            color: color
          )
        )
      end
    elsif shape.length == 2
      p1 = $draw.points2d[shape[0]]
      p2 = $draw.points2d[shape[1]]
      if p1 && p2
        $shapes.push(
          Line.new(
            x1: p1[0], y1: p1[1],
            x2: p2[0], y2: p2[1],
            width: 1,
            color: color
          )
        )
      end
    elsif shape.length == 4
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
end

set resizable: true

# Done each time an update occurs.
def updater
  clear
  $shapes = []
  $draw.reset
  start
end

update do
  updater
end

start
show
