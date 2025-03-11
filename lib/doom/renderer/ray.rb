# frozen_string_literal: true

module Doom
  module Renderer
    # Represents a single ray cast during raycasting
    class Ray
      attr_reader :x, :distance, :draw_start, :draw_end, :side, 
                 :map_x, :map_y, :wall_x, :ray_dir_x, :ray_dir_y

      def initialize(params)
        @x = params[:x]
        @distance = params[:perp_wall_dist]
        @draw_start = params[:draw_start]
        @draw_end = params[:draw_end]
        @side = params[:side]
        @map_x = params[:map_x]
        @map_y = params[:map_y]
        @wall_x = params[:wall_x]
        @ray_dir_x = params[:ray_dir_x]
        @ray_dir_y = params[:ray_dir_y]
      end

      def hit?
        true  # All rays in our array hit something (we stop DDA when we hit)
      end
    end
  end
end
