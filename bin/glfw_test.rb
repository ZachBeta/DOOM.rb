#!/usr/bin/env ruby
# frozen_string_literal: true

require 'glfw3'
require 'opengl'

puts 'GLFW3 gem loaded'
puts "Glfw methods: #{Glfw.methods(false).sort}"
puts "OpenGL methods: #{OpenGL.methods(false).sort}"
puts "OpenGL constants: #{OpenGL.constants.sort.take(10)}..."

# Try to initialize GLFW
puts 'Initializing GLFW...'
result = Glfw.init
puts "Glfw.init result: #{result}"

if result
  puts 'Creating window...'
  window = Glfw::Window.new(800, 600, 'GLFW Test')
  puts "Window created: #{window}"

  puts 'Making context current...'
  window.make_context_current

  puts 'Setting up OpenGL...'
  # Try to use OpenGL constants and methods
  puts 'Entering main loop...'
  until window.should_close?
    # Just swap buffers without OpenGL calls for now
    window.swap_buffers
    Glfw.poll_events
  end

  puts 'Cleaning up...'
  window.destroy
  Glfw.terminate
  puts 'Done!'
else
  puts 'Failed to initialize GLFW'
end
