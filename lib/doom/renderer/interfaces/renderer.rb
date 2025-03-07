module Doom
  module Renderer
    module Interfaces
      # Core interface for the DOOM renderer
      class Renderer
        # Initialize the renderer with required dependencies
        def initialize
          raise NotImplementedError, "#{self.class} must implement #initialize"
        end

        # Start the rendering loop
        def start
          raise NotImplementedError, "#{self.class} must implement #start"
        end

        # Stop the rendering loop
        def stop
          raise NotImplementedError, "#{self.class} must implement #stop"
        end

        # Render a single frame
        def render_frame
          raise NotImplementedError, "#{self.class} must implement #render_frame"
        end

        # Update the viewport with new parameters
        def update_viewport(params)
          raise NotImplementedError, "#{self.class} must implement #update_viewport"
        end

        # Get current frame rate
        def fps
          raise NotImplementedError, "#{self.class} must implement #fps"
        end

        # Get current frame time in milliseconds
        def frame_time
          raise NotImplementedError, "#{self.class} must implement #frame_time"
        end

        # Get memory usage in bytes
        def memory_usage
          raise NotImplementedError, "#{self.class} must implement #memory_usage"
        end
      end
    end
  end
end
