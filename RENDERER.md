# DOOM.rb Renderer Documentation

## Overview
This document consolidates all information related to the DOOM.rb renderer implementation, including architecture, strategies, learnings, and future plans.

## Core Architecture

### Renderer Components
- 3D rendering engine with raycasting
- Texture system with TEXTURE1/TEXTURE2 support
- Basic texture rendering and caching
- OpenGL-based implementation

### Project Structure
```
lib/doom/      # Core game components
├── renderer/  # 3D rendering system
```

## Key Learnings from Renderer Rebuild

### Architecture Decisions

1. **State Management Complexity**
   - OpenGL state tracking proved more complex than anticipated
   - Need for explicit state validation at key points
   - Importance of state transition logging for debugging

2. **Performance Bottlenecks**
   - Texture mapping performance critical for frame rate
   - Memory management for textures needs careful consideration
   - Wall segment merging essential for reducing draw calls

3. **Memory Management**
   - Texture streaming and caching crucial for performance
   - Need for efficient texture pooling system
   - Importance of texture compression for large WAD files

### Technical Insights

1. **Rendering Pipeline**
   - Clear separation between geometry and texture processing needed
   - Importance of efficient clipping algorithms
   - Need for better sprite sorting and management

2. **Resource Management**
   - WAD file texture extraction needs optimization
   - Texture palette management complexity
   - Memory budgeting crucial for stable performance

3. **Performance Targets**
   - Original targets:
     - 800x600 resolution
     - 35 FPS target
     - <100MB memory usage
   - Frame time budget distribution needs revision
   - Texture memory management needs refinement

## Current Implementation

### Completed Features
- Window creation and rendering loop
- Map representation and raycasting
- Texture system with WAD file parsing
- Texture composition from patches
- Texture caching and scaling
- Support for TEXTURE1/TEXTURE2
- Integration with renderer
- Debug tools (wad:info, wad:textures)

### In Progress
- Performance Optimization
  - Profile rendering and Ruby bottlenecks
  - Optimize texture caching
  - Improve line batching
  - Enhance view distance culling
  - Implement texture mipmap system
  - Current FPS: 3-6, Target: 30+

### Planned Features
- Advanced texture features (filtering, mip-mapping)
- Texture mapping improvements
- Texture Animation
  - Parse ANIMATED lump
  - Handle wall switches
  - Support animated flats and walls
- Sprite System
  - Parse sprite patterns
  - Handle rotation frames
  - Support states and transparency

## Design Principles

### Core Guidelines
- Keep rendering logic separate from game logic
- Hard lock to 800x600 resolution for now
- Follow vanilla DOOM behavior as documented in Chocolate DOOM source code

### Performance Guidelines
- Avoid unnecessary object creation in tight loops
- Consider using memoization or caching for expensive calculations
- Use profiling to identify bottlenecks
- Implement efficient texture lookup methods
- Cache textures for performance

### Texture Mapping
- Calculate texture coordinates based on wall hit positions
- Use efficient texture lookup methods
- Consider texture caching

## Test Coverage

### Core Renderer Tests
1. **OpenGL Renderer Tests** (`test/doom/opengl_renderer_test.rb`)
   - Initialization and resource management
   - Render pipeline execution
   - Performance metrics tracking
   - Frame logging and metrics accumulation

2. **Base Renderer Tests** (`test/doom/renderer_test.rb`)
   - Basic renderer initialization
   - Texture management
   - Wall rendering components
   - Shader compilation and management

### Component Tests
1. **Screen Buffer Tests** (`test/doom/renderer/components/screen_buffer_test.rb`)
   - Buffer initialization and cleanup
   - Pixel drawing operations
   - Vertical line rendering
   - Buffer flipping and window rendering

2. **Ray Caster Tests** (`test/doom/ray_caster_test.rb`)
   - Ray angle calculations
   - Wall intersection detection
   - Distance calculations
   - Texture coordinate mapping
   - Perspective correction

3. **OpenGL State Tests** (`test/doom/renderer/components/opengl_state_test.rb`)
   - Matrix mode transitions
   - Feature enabling/disabling
   - Texture binding
   - Blend state management

4. **Render State Tests** (`test/doom/renderer/components/render_state_test.rb`)
   - Viewport configuration
   - Matrix transformations
   - Texture coordinate management

### Integration Tests
1. **Cleanup Tests** (`test/doom/cleanup_test.rb`)
   - Resource cleanup sequences
   - OpenGL state cleanup
   - Memory management validation

2. **Window Integration Tests** (`test/doom/window_test.rb`)
   - Window creation and management
   - OpenGL context handling
   - Event processing

## Future Considerations

### Potential Improvements

1. **Architecture**
   - Consider implementing a command buffer system
   - Add better error recovery mechanisms
   - Implement more robust state validation

2. **Performance**
   - Implement sector-based visibility determination
   - Add view frustum culling
   - Optimize texture coordinate calculation

3. **Memory Management**
   - Implement smarter texture streaming
   - Add better texture cache management
   - Implement texture atlas system

### Testing Strategy

1. **Performance Testing**
   - Need for automated performance benchmarks
   - Better profiling tools integration
   - Systematic testing across different WAD files

2. **Validation**
   - Need for visual regression testing
   - State validation framework
   - Memory leak detection

## References

- Chocolate DOOM architecture
- Original DOOM rendering pipeline
- FreeDOOM WAD specifications
- [StinomXE](https://gugquettex.com/en/project/stinomxe/index.php) - A 3 or more dimensional drawing math thing that works on averages only

## Conclusion

The renderer implementation in DOOM.rb aims to balance accuracy to the original DOOM with modern development practices. While we've encountered challenges with state management and performance optimization, these learnings continue to guide our development toward a more robust and performant rendering system. 