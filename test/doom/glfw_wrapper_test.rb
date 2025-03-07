require 'test_helper'
require 'doom/glfw_wrapper'

module Doom
  class GlfwWrapperTest < Minitest::Test
    def setup
      @logger = Logger.instance
      @logger.info('Starting GLFW wrapper test suite')
      @glfw = GlfwWrapper.instance
    end

    def teardown
      @logger.info('Cleaning up after GLFW wrapper test')
      @glfw.terminate if @glfw.initialized?
    end

    def test_initialization
      @logger.info('Testing GLFW initialization')

      assert_predicate @glfw, :initialized?, 'GLFW should be initialized'

      # Test singleton pattern
      @logger.debug('Testing singleton pattern')
      glfw2 = GlfwWrapper.instance

      assert_same @glfw, glfw2, 'Should return the same instance'
    end

    def test_window_creation_and_destruction
      @logger.info('Testing window creation and destruction')

      # Create window
      @logger.debug('Creating test window')
      window = @glfw.create_window(800, 600, 'GLFW Test Window')

      assert window, 'Window should be created successfully'

      # Test window properties
      @logger.debug('Testing window properties')

      assert @glfw.window, 'Window should be accessible'
      assert_equal window, @glfw.window, 'Window pointers should match'

      # Test window context
      @logger.debug('Testing window context')
      @glfw.make_context_current

      # Test window state
      @logger.debug('Testing window state')

      refute_predicate @glfw, :should_close?, 'Window should not be marked for closing'

      # Test key states
      @logger.debug('Testing key states')

      assert_equal 0, @glfw.get_key(GlfwWrapper::KEY_W), 'Key should be released initially'

      # Clean up
      @logger.debug('Cleaning up window')
      @glfw.destroy_window

      assert_nil @glfw.window, 'Window should be destroyed'
    end

    def test_window_hints
      @logger.info('Testing window hints')

      # Test default hints
      @logger.debug('Testing default window hints')
      @glfw.default_window_hints

      # Test custom hints
      @logger.debug('Testing custom window hints')
      @glfw.window_hint(GlfwWrapper::CONTEXT_VERSION_MAJOR, 4)
      @glfw.window_hint(GlfwWrapper::CONTEXT_VERSION_MINOR, 5)
      @glfw.window_hint(GlfwWrapper::OPENGL_PROFILE, GlfwWrapper::OPENGL_CORE_PROFILE)
      @glfw.window_hint(GlfwWrapper::VISIBLE, GlfwWrapper::TRUE)

      # Create window with hints
      @logger.debug('Creating window with custom hints')
      window = @glfw.create_window(800, 600, 'GLFW Test Window with Hints')

      assert window, 'Window should be created with custom hints'

      # Clean up
      @glfw.destroy_window
    end

    def test_event_handling
      @logger.info('Testing event handling')

      # Create window
      @logger.debug('Creating window for event testing')
      window = @glfw.create_window(800, 600, 'GLFW Event Test Window')

      assert window, 'Window should be created for event testing'

      # Test event polling
      @logger.debug('Testing event polling')
      @glfw.poll_events

      # Test buffer swapping
      @logger.debug('Testing buffer swapping')
      @glfw.swap_buffers

      # Clean up
      @glfw.destroy_window
    end

    def test_cleanup
      @logger.info('Testing cleanup procedures')

      # Create window
      @logger.debug('Creating window for cleanup testing')
      window = @glfw.create_window(800, 600, 'GLFW Cleanup Test Window')

      assert window, 'Window should be created for cleanup testing'

      # Test termination
      @logger.debug('Testing GLFW termination')
      @glfw.terminate

      refute_predicate @glfw, :initialized?, 'GLFW should not be initialized after termination'
      assert_nil @glfw.window, 'Window should be nil after termination'
    end

    def test_error_handling
      @logger.info('Testing error handling')

      # Test window operations without initialization
      @logger.debug('Testing window operations without initialization')
      @glfw.terminate

      assert_nil @glfw.window, 'Window should be nil when not initialized'
      refute_predicate @glfw, :should_close?,
                       'should_close? should return false when not initialized'
      assert_nil @glfw.get_key(GlfwWrapper::KEY_W), 'get_key should return nil when not initialized'

      # Reinitialize for other tests
      @glfw.init
    end
  end
end
