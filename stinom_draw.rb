# Minimal implementation of StinomDrawXE for the demo
class StinomDrawXE
  attr_accessor :pointIndex, :shapeIndex, :viewPoint, :points2d, :shapes, :drawOrder

  def initialize(view_point, rotation, x_axis, y_axis, z_axis, rotation_x, rotation_y)
    @viewPoint = view_point
    @rotation = rotation
    @points = []
    @points2d = []
    @shapes = []
    @drawOrder = []
    @pointIndex = 0
    @shapeIndex = 0
  end

  def reset
    @points = []
    @points2d = []
    @shapes = []
    @drawOrder = []
    @pointIndex = 0
    @shapeIndex = 0
  end

  def addPoint(point)
    @points[@pointIndex] = point
    @pointIndex += 1
  end

  def addShape(shape)
    @shapes[@shapeIndex] = shape
    @shapeIndex += 1
  end

  def set2dPoints
    @points2d = @points.map do |point|
      next nil unless point
      # Simple perspective projection
      return nil if point[2] == @viewPoint[2]

      # Calculate perspective scale based on Z distance
      z_dist = (@viewPoint[2] - point[2]).abs
      scale = z_dist / 1000.0 # Normalize by viewing distance

      # Project point
      [
        (point[0] - @viewPoint[0]) * scale,
        (point[1] - @viewPoint[1]) * scale
      ]
    end
  end

  def setDrawOrder
    # Order shapes from back to front based on average Z position
    @drawOrder = (0...@shapeIndex).sort do |a, b|
      next 0 unless @shapes[a] && @shapes[b]

      # Calculate average Z for shape a
      z_a = if @shapes[a].any?
              @shapes[a].sum { |i| @points[i]&.[](2) || 0 } / @shapes[a].length
            else
              0
            end

      # Calculate average Z for shape b
      z_b = if @shapes[b].any?
              @shapes[b].sum { |i| @points[i]&.[](2) || 0 } / @shapes[b].length
            else
              0
            end

      # Sort back to front
      z_b <=> z_a
    end
  end

  def offset(offset_point)
    @points2d.each do |point|
      next unless point

      point[0] += offset_point[0]
      point[1] += offset_point[1]
    end
  end
end
