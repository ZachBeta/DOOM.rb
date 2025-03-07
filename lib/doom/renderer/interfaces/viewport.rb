module Doom
  module Renderer
    module Interfaces
      # Interface for managing the viewport and screen buffer
      class Viewport
        # Initialize the viewport with width and height
        def initialize(width, height)
          raise NotImplementedError, "#{self.class} must implement #initialize"
        end

        # Get the viewport width
        def width
          raise NotImplementedError, "#{self.class} must implement #width"
        end

        # Get the viewport height
        def height
          raise NotImplementedError, "#{self.class} must implement #height"
        end

        # Get the center X coordinate
        def centerx
          raise NotImplementedError, "#{self.class} must implement #centerx"
        end

        # Get the center Y coordinate
        def centery
          raise NotImplementedError, "#{self.class} must implement #centery"
        end

        # Clear the screen buffer
        def clear
          raise NotImplementedError, "#{self.class} must implement #clear"
        end

        # Draw a pixel at the specified coordinates
        def draw_pixel(x, y, color)
          raise NotImplementedError, "#{self.class} must implement #draw_pixel"
        end

        # Draw a vertical line
        def draw_vline(x, y1, y2, color)
          raise NotImplementedError, "#{self.class} must implement #draw_vline"
        end

        # Swap the front and back buffers
        def swap_buffers
          raise NotImplementedError, "#{self.class} must implement #swap_buffers"
        end

        # Get the current buffer state
        def buffer_state
          raise NotImplementedError, "#{self.class} must implement #buffer_state"
        end

        # Validate the viewport state
        def valid?
          raise NotImplementedError, "#{self.class} must implement #valid?"
        end
      end
    end
  end
end
