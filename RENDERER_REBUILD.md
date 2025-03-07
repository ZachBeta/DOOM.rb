# DOOM.rb Renderer Rebuild Worklog

## Overview
Rebuilding the renderer from scratch, inspired by Chocolate DOOM's architecture. Using freedoom1.wad as our test data.
`reference/chocolate-doom`
`levels/freedoom-0.13.0/freedoom1.wad`

## Current Focus
- Fixed 800x600 resolution
- Single-pass rendering pipeline
- Core rendering components first

## Implementation Plan

### Phase 0: Window Management [IN PROGRESS]
- [ ] Set up GLFW window
  - [ ] Initialize GLFW context
  - [ ] Create 800x600 window
  - [ ] Add window event handling
- [ ] Implement OpenGL context
  - [ ] Set up OpenGL bindings
  - [ ] Configure basic OpenGL state
- [ ] Add input handling
  - [ ] Keyboard input
  - [ ] Mouse input
  - [ ] Window resize handling

### Phase 1: Core Components

#### Viewport [NEXT]
- [ ] Implement fixed 800x600 resolution
  - [ ] Create Viewport class with width/height constants
  - [ ] Add basic screen buffer management
- [ ] Add centerx/centery calculations
  - [ ] Calculate viewport center points
  - [ ] Add tests for center calculations
- [ ] Implement basic screen buffer
  - [ ] Add double buffering
  - [ ] Add basic pixel drawing

#### RayCaster [NEXT]
- [ ] Implement DDA algorithm
  - [ ] Add ray casting with fixed FOV
  - [ ] Add wall intersection detection
- [ ] Add distance calculations
  - [ ] Calculate wall distances
  - [ ] Add perspective correction
- [ ] Add texture coordinate calculation
  - [ ] Calculate U coordinates
  - [ ] Add texture mapping support

#### TextureMapper [AFTER RAYCASTER]
- [ ] Add texture loading
  - [ ] Load textures from WAD
  - [ ] Add texture caching
- [ ] Implement texture mapping
  - [ ] Add U/V coordinate calculation
  - [ ] Add texture sampling

### Phase 2: Rendering Pipeline

#### WallRenderer
- [ ] Add wall rendering
  - [ ] Implement height calculations
  - [ ] Add texture mapping
- [ ] Add clipping
  - [ ] Implement clip arrays
  - [ ] Add wall clipping

#### FloorCeilingRenderer
- [ ] Add floor/ceiling rendering
  - [ ] Implement perspective correction
  - [ ] Add texture mapping

### Phase 3: Integration

#### SoftwareRenderer
- [ ] Coordinate rendering pipeline
  - [ ] Implement render loop
  - [ ] Add frame timing
- [ ] Add sprite rendering
  - [ ] Implement sprite sorting
  - [ ] Add sprite drawing

## Test Data
Using freedoom1.wad for testing:
- E1M1: Basic wall rendering
  - Test cases: Basic geometry, simple textures
  - Performance baseline: 35 FPS
- E1M2: Complex geometry
  - Test cases: Complex intersections, varying heights
  - Performance target: 30 FPS

## Performance Targets
- Target resolution: 800x600
- Target FPS: 35
- Memory usage: < 100MB 