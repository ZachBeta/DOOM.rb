#!/usr/bin/env ruby
# frozen_string_literal: true

require 'glfw3'
require 'opengl'
require_relative '../lib/doom/renderer'
require_relative '../lib/doom/renderer/shader'

# Basic vertex shader
VERTEX_SHADER = <<~GLSL
  #version 330 core
  layout (location = 0) in vec3 aPos;
  layout (location = 1) in vec3 aColor;
  out vec3 ourColor;
  void main() {
    gl_Position = vec4(aPos, 1.0);
    ourColor = aColor;
  }
GLSL

# Basic fragment shader
FRAGMENT_SHADER = <<~GLSL
  #version 330 core
  in vec3 ourColor;
  out vec4 FragColor;
  void main() {
    FragColor = vec4(ourColor, 1.0);
  }
GLSL

def main
  # Initialize GLFW
  GLFW.init
  window = GLFW::Window.new(800, 600, 'DOOM.rb Renderer Test')
  window.make_current

  # Initialize OpenGL
  OpenGL.load_lib

  # Create and compile shaders
  shader = Doom::Renderer::Shader.new
  shader.load_shader(Doom::Renderer::Shader::VERTEX_SHADER, VERTEX_SHADER)
  shader.load_shader(Doom::Renderer::Shader::FRAGMENT_SHADER, FRAGMENT_SHADER)
  shader.link_program

  # Set up vertex data
  vertices = [
    # positions        # colors
    -0.5, -0.5, 0.0, 1.0, 0.0, 0.0, # bottom right
    0.5, -0.5, 0.0,  0.0, 1.0, 0.0,  # bottom left
    0.0,  0.5, 0.0,  0.0, 0.0, 1.0   # top
  ]

  # Create and bind vertex buffer
  vbo = glGenBuffers(1)
  glBindBuffer(GL_ARRAY_BUFFER, vbo)
  glBufferData(GL_ARRAY_BUFFER, vertices.size * 4, vertices.pack('f*'), GL_STATIC_DRAW)

  # Create and bind vertex array
  vao = glGenVertexArrays(1)
  glBindVertexArray(vao)

  # Position attribute
  glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, 6 * 4, 0)
  glEnableVertexAttribArray(0)

  # Color attribute
  glVertexAttribPointer(1, 3, GL_FLOAT, GL_FALSE, 6 * 4, 3 * 4)
  glEnableVertexAttribArray(1)

  # Main loop
  until window.should_close?
    # Clear the screen
    glClearColor(0.2, 0.3, 0.3, 1.0)
    glClear(GL_COLOR_BUFFER_BIT)

    # Use shader program
    shader.use

    # Draw triangle
    glBindVertexArray(vao)
    glDrawArrays(GL_TRIANGLES, 0, 3)
    glBindVertexArray(0)

    # Swap buffers and poll events
    window.swap_buffers
    GLFW.poll_events
  end

  # Cleanup
  glDeleteVertexArrays(1, [vao])
  glDeleteBuffers(1, [vbo])
  shader.cleanup
  window.destroy
  GLFW.terminate
end

main
