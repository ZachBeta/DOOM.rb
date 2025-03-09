# DOOM.rb Renderer Modernization Plan

## Current Implementation Analysis

After reviewing the codebase, we've identified several issues with the current GLFW3 and OpenGL implementation:

1. **Outdated OpenGL Usage**: 
   - Using fixed-function pipeline (GL.MatrixMode, GL.LoadIdentity, GL.Ortho) which is deprecated in modern OpenGL
   - Using immediate mode rendering (GL.Begin/GL.End) which is inefficient and deprecated

2. **GLFW3 Implementation Issues**:
   - Custom extension to track GLFW initialization and window destruction states is unnecessary
   - Window creation and event handling could be improved with better callback usage

3. **Performance Issues**:
   - Current rendering approach with immediate mode is very inefficient
   - Not using modern OpenGL features like Vertex Buffer Objects (VBOs) and shaders

4. **Code Organization**:
   - Renderer components are tightly coupled, making it difficult to modify or extend

## Modernization Goals

1. **Improve Performance**:
   - Target 30+ FPS at 800x600 resolution
   - Reduce CPU usage for rendering operations
   - Optimize memory usage for textures and geometry

2. **Improve Code Quality**:
   - Better separation of concerns between components
   - More maintainable and extensible architecture
   - Clearer interfaces between components

3. **Modernize OpenGL Usage**:
   - Use shader-based rendering pipeline
   - Implement efficient geometry handling with VBOs
   - Proper texture management

## Implementation Plan

### Phase 1: GLFW3 Improvements

1. **Window Creation and Management**:
   - Use GLFW's built-in window hints to configure the OpenGL context properly
   - Set up proper callbacks for window events using Ruby blocks
   - Implement proper error handling for GLFW initialization and window creation

2. **Input Handling**:
   - Use GLFW's callback system for input handling instead of polling in the main loop
   - Implement proper key callback functions for more responsive input

### Phase 2: Modern OpenGL Implementation

1. **Shader System**:
   - Create vertex and fragment shaders for basic rendering
   - Implement shader compilation and linking
   - Create a shader manager for handling multiple shaders

2. **Modern Rendering**:
   - Create VBOs and VAOs for efficient geometry rendering
   - Implement proper texture loading and binding
   - Replace immediate mode rendering with modern approaches

3. **Texture Management**:
   - Implement efficient texture loading and caching
   - Create texture atlas for better performance
   - Implement proper texture coordinate mapping

### Phase 3: Renderer Refactoring

1. **Renderer Architecture**:
   - Create a cleaner separation between rendering logic and game logic
   - Implement a proper scene graph or rendering queue
   - Create abstraction layers for OpenGL functionality

2. **Component Refactoring**:
   - Refactor wall renderer to use modern OpenGL
   - Refactor minimap renderer to use modern OpenGL
   - Refactor debug renderer to use modern OpenGL

### Phase 4: Performance Optimization

1. **Geometry Optimization**:
   - Implement batching for similar geometry
   - Implement view frustum culling
   - Optimize vertex data layout

2. **Texture Optimization**:
   - Implement texture atlases for better performance
   - Implement mipmapping for better quality and performance
   - Optimize texture memory usage

3. **Rendering Pipeline Optimization**:
   - Minimize state changes
   - Implement occlusion culling
   - Optimize shader usage

## Implementation Details

### Modern OpenGL Context Setup

```ruby
# Set up OpenGL context with GLFW
GLFW::Window.hint(GLFW::HINT_CONTEXT_VERSION_MAJOR, 3)
GLFW::Window.hint(GLFW::HINT_CONTEXT_VERSION_MINOR, 3)
GLFW::Window.hint(GLFW::HINT_OPENGL_PROFILE, GLFW::OPENGL_CORE_PROFILE)
GLFW::Window.hint(GLFW::HINT_OPENGL_FORWARD_COMPAT, true) # For macOS compatibility
```

### Basic Shader Implementation

```ruby
# Vertex Shader
VERTEX_SHADER = <<~GLSL
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

# Fragment Shader
FRAGMENT_SHADER = <<~GLSL
  #version 330 core
  in vec2 fragTexCoord;
  
  uniform sampler2D textureSampler;
  
  out vec4 fragColor;
  
  void main() {
    fragColor = texture(textureSampler, fragTexCoord);
  }
GLSL
```

### VBO and VAO Implementation

```ruby
# Create and bind VAO
@vao = GL.GenVertexArrays(1).first
GL.BindVertexArray(@vao)

# Create and bind VBO
@vbo = GL.GenBuffers(1).first
GL.BindBuffer(GL::ARRAY_BUFFER, @vbo)
GL.BufferData(GL::ARRAY_BUFFER, vertices.pack('f*'), GL::STATIC_DRAW)

# Set up vertex attributes
GL.VertexAttribPointer(0, 3, GL::FLOAT, GL::FALSE, 5 * Fiddle::SIZEOF_FLOAT, 0)
GL.EnableVertexAttribArray(0)
GL.VertexAttribPointer(1, 2, GL::FLOAT, GL::FALSE, 5 * Fiddle::SIZEOF_FLOAT, 3 * Fiddle::SIZEOF_FLOAT)
GL.EnableVertexAttribArray(1)

# Unbind VAO
GL.BindVertexArray(0)
```

### Texture Loading and Binding

```ruby
# Load texture
@texture = GL.GenTextures(1).first
GL.BindTexture(GL::TEXTURE_2D, @texture)

# Set texture parameters
GL.TexParameteri(GL::TEXTURE_2D, GL::TEXTURE_WRAP_S, GL::REPEAT)
GL.TexParameteri(GL::TEXTURE_2D, GL::TEXTURE_WRAP_T, GL::REPEAT)
GL.TexParameteri(GL::TEXTURE_2D, GL::TEXTURE_MIN_FILTER, GL::LINEAR_MIPMAP_LINEAR)
GL.TexParameteri(GL::TEXTURE_2D, GL::TEXTURE_MAG_FILTER, GL::LINEAR)

# Load image data
# ... (load image data from file)

# Generate texture
GL.TexImage2D(GL::TEXTURE_2D, 0, GL::RGB, width, height, 0, GL::RGB, GL::UNSIGNED_BYTE, image_data)
GL.GenerateMipmap(GL::TEXTURE_2D)
```

### Rendering Loop

```ruby
# Main rendering loop
until window.should_close?
  # Clear the screen
  GL.Clear(GL::COLOR_BUFFER_BIT | GL::DEPTH_BUFFER_BIT)
  
  # Use shader program
  GL.UseProgram(@shader_program)
  
  # Set uniforms
  GL.UniformMatrix4fv(@projection_loc, 1, GL::FALSE, projection_matrix.to_a.pack('f*'))
  GL.UniformMatrix4fv(@view_loc, 1, GL::FALSE, view_matrix.to_a.pack('f*'))
  GL.UniformMatrix4fv(@model_loc, 1, GL::FALSE, model_matrix.to_a.pack('f*'))
  
  # Bind texture
  GL.ActiveTexture(GL::TEXTURE0)
  GL.BindTexture(GL::TEXTURE_2D, @texture)
  GL.Uniform1i(@texture_loc, 0)
  
  # Bind VAO and draw
  GL.BindVertexArray(@vao)
  GL.DrawArrays(GL::TRIANGLES, 0, vertex_count)
  GL.BindVertexArray(0)
  
  # Swap buffers and poll events
  window.swap_buffers
  GLFW.poll_events
end
```

## Migration Strategy

1. **Incremental Approach**:
   - Implement changes in small, testable increments
   - Maintain backward compatibility during transition
   - Create parallel implementations for testing

2. **Testing Strategy**:
   - Create benchmarks to measure performance improvements
   - Implement visual comparison tests
   - Ensure compatibility across platforms

3. **Documentation**:
   - Document all changes and design decisions
   - Create examples for new rendering approaches
   - Update RENDERER.md with new architecture details

## Timeline

1. **Phase 1**: 1-2 weeks
2. **Phase 2**: 2-3 weeks
3. **Phase 3**: 2-3 weeks
4. **Phase 4**: 1-2 weeks

Total estimated time: 6-10 weeks

## Resources

- [GLFW Documentation](https://www.glfw.org/docs/latest/)
- [OpenGL Wiki](https://www.khronos.org/opengl/wiki/)
- [Learn OpenGL](https://learnopengl.com/)
- [OpenGL-Tutorial](http://www.opengl-tutorial.org/) 