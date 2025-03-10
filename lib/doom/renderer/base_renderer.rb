# frozen_string_literal: true

require 'glfw3'
require 'gl'
require 'glu'
require 'matrix'
require_relative 'ray_caster'
require_relative 'shader_manager'
require_relative 'texture_manager'
require_relative 'geometry_manager'
require_relative 'wall_renderer'
require_relative 'minimap_renderer'
require_relative 'debug_renderer'
require_relative '../logger'

# Load OpenGL
GL.load_lib

module Doom
  module Renderer
    class BaseRenderer
      include GL

      WINDOW_WIDTH = 800
      WINDOW_HEIGHT = 600
      WINDOW_TITLE = 'DOOM.rb'

      attr_reader :window

      def initialize
        @logger = Logger.instance
        @logger.info('BaseRenderer: Initializing')

        setup_signal_handlers
        init_glfw
        create_window
        setup_opengl

        # Initialize managers
        @shader_manager = ShaderManager.new
        @texture_manager = TextureManager.new
        @geometry_manager = GeometryManager.new

        @frame_count = 0
        @start_time = Time.now
        @background_color = [0.0, 0.0, 0.0, 1.0] # Start with black

        @logger.info('BaseRenderer: Initialization complete')
      end

      def set_game_objects(map, player)
        @map = map
        @player = player

        # Initialize ray caster
        @ray_caster = RayCaster.new(@map, @player, WINDOW_HEIGHT)

        # Initialize renderer components
        init_shaders
        init_textures
        init_geometries
        init_matrices

        # Initialize renderers
        @wall_renderer = WallRenderer.new(WINDOW_WIDTH, WINDOW_HEIGHT, @shader_manager,
                                          @texture_manager, @geometry_manager)
        @minimap_renderer = MinimapRenderer.new(@map, @player, WINDOW_WIDTH, WINDOW_HEIGHT,
                                                @shader_manager, @texture_manager, @geometry_manager)
        @debug_renderer = DebugRenderer.new(WINDOW_WIDTH, WINDOW_HEIGHT, @shader_manager,
                                            @texture_manager, @geometry_manager)

        @logger.info('BaseRenderer: Game objects set')
      end

      def render
        return unless @map && @player

        @logger.debug('BaseRenderer: Starting render cycle')

        # Clear the screen with the current background color
        GL.ClearColor(*@background_color)
        GL.Clear(GL::GL_COLOR_BUFFER_BIT | GL::GL_DEPTH_BUFFER_BIT)

        # Cast rays
        rays = @ray_caster.cast_rays(WINDOW_WIDTH)

        # Render scene using modern OpenGL
        render_scene(rays)

        # Calculate and log FPS every 100 frames
        calculate_fps if (@frame_count % 100).zero?

        # Check for escape key to close window
        @window.should_close = true if @window.key(Glfw::KEY_ESCAPE) == Glfw::PRESS

        # Swap buffers
        @logger.debug('BaseRenderer: Swapping buffers')
        @window.swap_buffers

        # Poll for events
        @logger.debug('BaseRenderer: Polling for events')
        Glfw.poll_events

        @frame_count += 1

        @logger.debug('BaseRenderer: Render cycle complete')
      end

      def window_should_close?
        @window.should_close?
      end

      def cleanup
        return if @cleaned_up # Guard against double cleanup

        @logger.info('BaseRenderer: Starting cleanup')

        begin
          # Clean up OpenGL resources in reverse order of creation
          if @debug_renderer
            @debug_renderer = nil
            @logger.info('BaseRenderer: Debug renderer cleaned up')
          end

          if @minimap_renderer
            @minimap_renderer = nil
            @logger.info('BaseRenderer: Minimap renderer cleaned up')
          end

          if @wall_renderer
            @wall_renderer = nil
            @logger.info('BaseRenderer: Wall renderer cleaned up')
          end

          if @geometry_manager
            @geometry_manager.cleanup
            @geometry_manager = nil
            @logger.info('BaseRenderer: Geometry manager cleaned up')
          end

          if @texture_manager
            @texture_manager.cleanup
            @texture_manager = nil
            @logger.info('BaseRenderer: Texture manager cleaned up')
          end

          if @shader_manager
            @shader_manager.cleanup
            @shader_manager = nil
            @logger.info('BaseRenderer: Shader manager cleaned up')
          end

          if @window
            @window.destroy
            @window = nil
            @logger.info('BaseRenderer: Window destroyed')
          end

          if Glfw.init
            Glfw.terminate
            @logger.info('BaseRenderer: GLFW terminated')
          end
        rescue StandardError => e
          @logger.error("BaseRenderer: Error during cleanup: #{e.message}")
          @logger.error(e.backtrace.join("\n"))
        ensure
          @cleaned_up = true
          @logger.info('BaseRenderer: Cleanup complete')
        end
      end

      def graceful_exit
        @logger.info('BaseRenderer: Graceful exit initiated')
        begin
          cleanup
        rescue StandardError => e
          @logger.error("BaseRenderer: Error during graceful exit: #{e.message}")
          @logger.error(e.backtrace.join("\n"))
        ensure
          @logger.info('BaseRenderer: Graceful exit complete')
        end
      end

      private

      def calculate_fps
        current_time = Time.now
        elapsed = current_time - @start_time
        fps = @frame_count / elapsed

        @logger.info("BaseRenderer: FPS: #{fps.round(2)} (#{@frame_count} frames in #{elapsed.round(2)}s)")

        # Reset counters every 1000 frames to avoid overflow
        return unless @frame_count >= 1000

        @frame_count = 0
        @start_time = current_time
      end

      def setup_signal_handlers
        @logger.info('BaseRenderer: Setting up signal handlers')

        # Set up signal handlers for graceful exit
        trap('INT') do
          @logger.info('BaseRenderer: Received INT signal')
          graceful_exit
          exit(0)
        end

        trap('TERM') do
          @logger.info('BaseRenderer: Received TERM signal')
          graceful_exit
          exit(0)
        end

        @logger.info('BaseRenderer: Signal handlers set up')
      end

      def init_glfw
        @logger.info('BaseRenderer: Initializing GLFW')

        # Initialize GLFW
        unless Glfw.init
          @logger.error('BaseRenderer: Failed to initialize GLFW')
          raise 'Failed to initialize GLFW'
        end

        # Set up OpenGL context hints
        Glfw::Window.window_hint(Glfw::CONTEXT_VERSION_MAJOR, 3)
        Glfw::Window.window_hint(Glfw::CONTEXT_VERSION_MINOR, 3)
        Glfw::Window.window_hint(Glfw::OPENGL_PROFILE, Glfw::OPENGL_CORE_PROFILE)
        Glfw::Window.window_hint(Glfw::OPENGL_FORWARD_COMPAT, 1) # For macOS compatibility

        @logger.info('BaseRenderer: GLFW initialized successfully')
      end

      def create_window
        @logger.info("BaseRenderer: Creating window (#{WINDOW_WIDTH}x#{WINDOW_HEIGHT})")

        # Create a windowed mode window and its OpenGL context
        @window = Glfw::Window.new(WINDOW_WIDTH, WINDOW_HEIGHT, WINDOW_TITLE)

        if @window.nil?
          @logger.error('BaseRenderer: Failed to create GLFW window')
          Glfw.terminate
          raise 'Failed to create GLFW window'
        end

        # Make the window's context current
        @window.make_context_current

        # Set up callbacks
        setup_callbacks

        @logger.info('BaseRenderer: Window created successfully')
      end

      def setup_callbacks
        @logger.info('BaseRenderer: Setting up callbacks')
        # We'll handle key input in the input handler instead of using callbacks
        @logger.info('BaseRenderer: Callbacks set up')
      end

      def setup_opengl
        @logger.info('BaseRenderer: Setting up OpenGL')

        # Enable depth testing
        GL.Enable(GL::GL_DEPTH_TEST)
        GL.DepthFunc(GL::GL_LESS)

        # Enable alpha blending
        GL.Enable(GL::GL_BLEND)
        GL.BlendFunc(GL::GL_SRC_ALPHA, GL::GL_ONE_MINUS_SRC_ALPHA)

        # Set viewport
        GL.Viewport(0, 0, WINDOW_WIDTH, WINDOW_HEIGHT)

        @logger.info('BaseRenderer: OpenGL setup complete')
      end

      def init_shaders
        @logger.info('BaseRenderer: Initializing shaders')
        @shader_manager.create_basic_programs
        @logger.info('BaseRenderer: Shaders initialized')
      end

      def init_textures
        @logger.info('BaseRenderer: Initializing textures')

        # Create default textures
        @texture_manager.create_default_textures

        # Create a temporary wall texture (checkerboard pattern)
        width = 64
        height = 64
        data = []
        height.times do |y|
          width.times do |x|
            color = ((x / 8) + (y / 8)).even? ? [255, 255, 255] : [128, 128, 128]
            data.concat(color)
          end
        end
        @texture_manager.load_texture('wall', width, height, data.pack('C*'))

        @logger.info('BaseRenderer: Textures initialized')
      end

      def init_geometries
        @logger.info('BaseRenderer: Initializing geometries')

        # Create a screen quad for rendering the walls
        @geometry_manager.create_screen_quad('screen_quad')

        @logger.info('BaseRenderer: Geometries initialized')
      end

      def init_matrices
        @logger.info('BaseRenderer: Initializing matrices')

        # Set up perspective projection matrix
        fov = 60.0 * Math::PI / 180.0 # 60 degrees FOV in radians
        aspect_ratio = WINDOW_WIDTH.to_f / WINDOW_HEIGHT
        near = 0.1
        far = 100.0

        f = 1.0 / Math.tan(fov / 2.0)
        @projection_matrix = Matrix[
          [f / aspect_ratio, 0.0, 0.0, 0.0],
          [0.0, f, 0.0, 0.0],
          [0.0, 0.0, (far + near) / (near - far), (2.0 * far * near) / (near - far)],
          [0.0, 0.0, -1.0, 0.0]
        ]

        @logger.info('BaseRenderer: Matrices initialized')
      end

      def render_scene(rays)
        @logger.debug('BaseRenderer: Rendering scene')

        # Set up view matrix based on player position and direction
        view_matrix = Matrix.identity(4)

        # Render walls
        @wall_renderer.render(rays, @projection_matrix, view_matrix)

        # Render minimap
        @minimap_renderer.render(rays, @projection_matrix, view_matrix)

        # Render debug information
        @debug_renderer.render(@player, @projection_matrix, view_matrix)

        @logger.debug('BaseRenderer: Scene rendered')
      end
    end
  end
end
