# frozen_string_literal: true

require 'opengl'
require_relative '../logger'

# Load OpenGL
OpenGL.load_lib

module Doom
  module Renderer
    class ShaderManager
      include OpenGL

      # Basic vertex shader for 2D rendering
      BASIC_VERTEX_SHADER = <<~GLSL
        #version 330 core
        layout(location = 0) in vec3 position;
        layout(location = 1) in vec2 texCoord;

        uniform mat4 projection;
        uniform mat4 view;
        uniform mat4 model;

        out vec2 fragTexCoord;

        void main() {
          gl_Position = projection * view * model * vec4(position, 1.0);
          fragTexCoord = texCoord;
        }
      GLSL

      # Basic fragment shader for texture rendering
      BASIC_FRAGMENT_SHADER = <<~GLSL
        #version 330 core
        in vec2 fragTexCoord;

        uniform sampler2D textureSampler;

        out vec4 fragColor;

        void main() {
          fragColor = texture(textureSampler, fragTexCoord);
        }
      GLSL

      # Color fragment shader for rendering solid colors
      COLOR_FRAGMENT_SHADER = <<~GLSL
        #version 330 core
        in vec2 fragTexCoord;

        uniform vec4 color;

        out vec4 fragColor;

        void main() {
          fragColor = color;
        }
      GLSL

      # Wall vertex shader
      WALL_VERTEX_SHADER = BASIC_VERTEX_SHADER

      # Wall fragment shader
      WALL_FRAGMENT_SHADER = BASIC_FRAGMENT_SHADER

      # Minimap vertex shader
      MINIMAP_VERTEX_SHADER = BASIC_VERTEX_SHADER

      # Minimap fragment shader
      MINIMAP_FRAGMENT_SHADER = COLOR_FRAGMENT_SHADER

      # Debug vertex shader
      DEBUG_VERTEX_SHADER = BASIC_VERTEX_SHADER

      # Debug fragment shader
      DEBUG_FRAGMENT_SHADER = COLOR_FRAGMENT_SHADER

      attr_reader :programs

      def initialize
        @logger = Logger.instance
        @programs = {}
      end

      def create_program(name, vertex_source, fragment_source)
        @logger.info("ShaderManager: Creating shader program '#{name}'")

        # Compile vertex shader
        vertex_shader = OpenGL.glCreateShader(OpenGL::GL_VERTEX_SHADER)
        OpenGL.glShaderSource(vertex_shader, 1, [vertex_source].pack('p'), nil)
        OpenGL.glCompileShader(vertex_shader)

        # Check for vertex shader compilation errors
        status = ' ' * 4 # Create a buffer to receive the status
        OpenGL.glGetShaderiv(vertex_shader, OpenGL::GL_COMPILE_STATUS, status)
        success = status.unpack1('L') == OpenGL::GL_TRUE
        unless success
          log = OpenGL.glGetShaderInfoLog(vertex_shader)
          OpenGL.glDeleteShader(vertex_shader)
          @logger.error("ShaderManager: Vertex shader compilation failed: #{log}")
          raise "Vertex shader compilation failed: #{log}"
        end

        # Compile fragment shader
        fragment_shader = OpenGL.glCreateShader(OpenGL::GL_FRAGMENT_SHADER)
        OpenGL.glShaderSource(fragment_shader, 1, [fragment_source].pack('p'), nil)
        OpenGL.glCompileShader(fragment_shader)

        # Check for fragment shader compilation errors
        status = ' ' * 4 # Create a buffer to receive the status
        OpenGL.glGetShaderiv(fragment_shader, OpenGL::GL_COMPILE_STATUS, status)
        success = status.unpack1('L') == OpenGL::GL_TRUE
        unless success
          log = OpenGL.glGetShaderInfoLog(fragment_shader)
          OpenGL.glDeleteShader(vertex_shader)
          OpenGL.glDeleteShader(fragment_shader)
          @logger.error("ShaderManager: Fragment shader compilation failed: #{log}")
          raise "Fragment shader compilation failed: #{log}"
        end

        # Link shaders
        program = OpenGL.glCreateProgram
        OpenGL.glAttachShader(program, vertex_shader)
        OpenGL.glAttachShader(program, fragment_shader)
        OpenGL.glLinkProgram(program)

        # Check for linking errors
        status = ' ' * 4 # Create a buffer to receive the status
        OpenGL.glGetProgramiv(program, OpenGL::GL_LINK_STATUS, status)
        success = status.unpack1('L') == OpenGL::GL_TRUE
        unless success
          log = OpenGL.glGetProgramInfoLog(program)
          OpenGL.glDeleteShader(vertex_shader)
          OpenGL.glDeleteShader(fragment_shader)
          OpenGL.glDeleteProgram(program)
          @logger.error("ShaderManager: Program linking failed: #{log}")
          raise "Program linking failed: #{log}"
        end

        # Delete shaders as they're linked into the program now and no longer needed
        OpenGL.glDeleteShader(vertex_shader)
        OpenGL.glDeleteShader(fragment_shader)

        @programs[name] = program
        @logger.info("ShaderManager: Shader program '#{name}' created successfully")
        program
      end

      def use_program(name)
        program = @programs[name]
        if program
          OpenGL.glUseProgram(program)
        else
          @logger.error("ShaderManager: Program '#{name}' not found")
          raise "Program '#{name}' not found"
        end
      end

      def set_uniform_matrix4(program_name, uniform_name, matrix)
        program = @programs[program_name]
        if program
          location = OpenGL.glGetUniformLocation(program, uniform_name)
          if location >= 0
            OpenGL.glUniformMatrix4fv(location, 1, OpenGL::GL_FALSE, matrix.to_a.flatten.pack('f*'))
          else
            @logger.warn("ShaderManager: Uniform '#{uniform_name}' not found in program '#{program_name}'")
          end
        else
          @logger.error("ShaderManager: Program '#{program_name}' not found")
        end
      end

      def set_uniform_int(program_name, uniform_name, value)
        program = @programs[program_name]
        if program
          location = OpenGL.glGetUniformLocation(program, uniform_name)
          if location >= 0
            OpenGL.glUniform1i(location, value)
          else
            @logger.warn("ShaderManager: Uniform '#{uniform_name}' not found in program '#{program_name}'")
          end
        else
          @logger.error("ShaderManager: Program '#{program_name}' not found")
        end
      end

      def set_uniform_float(program_name, uniform_name, value)
        program = @programs[program_name]
        if program
          location = OpenGL.glGetUniformLocation(program, uniform_name)
          if location >= 0
            OpenGL.glUniform1f(location, value)
          else
            @logger.warn("ShaderManager: Uniform '#{uniform_name}' not found in program '#{program_name}'")
          end
        else
          @logger.error("ShaderManager: Program '#{program_name}' not found")
        end
      end

      def set_uniform_vec4(program_name, uniform_name, values)
        program = @programs[program_name]
        if program
          location = OpenGL.glGetUniformLocation(program, uniform_name)
          if location >= 0
            OpenGL.glUniform4f(location, *values)
          else
            @logger.warn("ShaderManager: Uniform '#{uniform_name}' not found in program '#{program_name}'")
          end
        else
          @logger.error("ShaderManager: Program '#{program_name}' not found")
        end
      end

      def cleanup
        @logger.info('ShaderManager: Cleaning up shader programs')
        @programs.each_value do |program|
          OpenGL.glDeleteProgram(program)
        end
        @programs.clear
        @logger.info('ShaderManager: Shader programs cleaned up')
      end

      def create_basic_programs
        @logger.info('ShaderManager: Creating basic shader programs')

        # Create basic shader program for 2D rendering
        create_program('basic', BASIC_VERTEX_SHADER, BASIC_FRAGMENT_SHADER)

        # Create basic color shader program
        create_program('basic_color', BASIC_VERTEX_SHADER, COLOR_FRAGMENT_SHADER)

        # Create shader program for walls
        create_program('wall', WALL_VERTEX_SHADER, WALL_FRAGMENT_SHADER)

        # Create shader program for minimap
        create_program('minimap', MINIMAP_VERTEX_SHADER, MINIMAP_FRAGMENT_SHADER)

        # Create shader program for debug rendering
        create_program('debug', DEBUG_VERTEX_SHADER, DEBUG_FRAGMENT_SHADER)

        @logger.info('ShaderManager: Basic shader programs created')
      end
    end
  end
end
