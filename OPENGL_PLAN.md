## OpenGL Rendering Implementation Plan

### Goals
- Improve rendering performance using OpenGL
- Keep code maintainable and testable
- Allow fallback to current Gosu renderer
- Implement changes incrementally

### Implementation Strategy

1. **Create Renderer Strategy Pattern**
```ruby
module Doom
  class Renderer
    def initialize(window, map, textures = {})
      @rendering_strategy = if use_opengl?
        OpenGLRenderer.new(window, map, textures)
      else
        GosuRenderer.new(window, map, textures)
      end
    end

    def render(player)
      @rendering_strategy.render(player)
    end

    private

    def use_opengl?
      ENV['DOOM_RENDERER'] != 'gosu'
    end
  end
end
```

2. **Implement Base Classes**
- Create `BaseRenderer` with common interface
- Move current implementation to `GosuRenderer`
- Create new `OpenGLRenderer`

3. **OpenGL Implementation Steps**
   1. Setup texture management
      - Pre-process textures once at initialization
      - Store in vertex buffer objects
      - Implement efficient texture switching
   
   2. Implement wall rendering
      - Use vertex arrays for batched rendering
      - Minimize state changes
      - Implement efficient Z-buffer
   
   3. Add background/floor/ceiling
      - Use simple quads with gradients
      - Consider skybox for future enhancement
   
   4. Optimize minimap
      - Consider separate FBO for minimap
      - Update only when necessary

4. **Performance Optimizations**
   - Batch similar draw calls
   - Use Vertex Buffer Objects (VBOs)
   - Minimize texture switches
   - Implement view frustum culling
   - Add distance-based LOD

5. **Testing Strategy**
   - Add rendering benchmarks
   - Compare FPS between implementations
   - Test texture loading/memory usage
   - Verify visual consistency

### Implementation Order

1. Create strategy pattern and base classes
2. Move current implementation to `GosuRenderer`
3. Create basic `OpenGLRenderer` with walls only
4. Add texture support to `OpenGLRenderer`
5. Implement background rendering
6. Add minimap support
7. Optimize and benchmark
8. Add LOD and culling

### Environment Variables

- `DOOM_RENDERER=gosu` - Use Gosu renderer (default)
- `DOOM_RENDERER=opengl` - Use OpenGL renderer
- `DOOM_BENCHMARK=1` - Enable performance logging 