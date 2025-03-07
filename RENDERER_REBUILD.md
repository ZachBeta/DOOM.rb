# DOOM.rb Renderer Rebuild Worklog

## Overview
Rebuilding the renderer from scratch, inspired by Chocolate DOOM's architecture. Using freedoom1.wad as our test data.
`reference/chocolate-doom`
`levels/freedoom-0.13.0/freedoom1.wad`

## Test-Driven Development Plan

### Phase 1: Core Rendering Components

#### Viewport Tests
```ruby
describe "Viewport" do
  it "maintains 320x200 resolution"
  it "handles aspect ratio correction"
  it "supports integer scaling"
  it "calculates centerx and centery"
  it "handles view size changes"
end
```

#### Ray Casting Tests
```ruby
describe "RayCaster" do
  it "casts rays at correct angles based on FOV"
  it "detects wall intersections"
  it "calculates wall distances"
  it "handles different wall heights"
  it "calculates texture coordinates"
  it "handles perspective correction"
end
```

#### Texture Mapping Tests
```ruby
describe "TextureMapper" do
  it "loads textures from WAD file"
  it "maps textures to wall segments"
  it "handles texture coordinates"
  it "applies perspective correction"
  it "supports texture pegging"
  it "handles texture translation"
end
```

### Phase 2: Rendering Pipeline

#### Screen Buffer Tests
```ruby
describe "ScreenBuffer" do
  it "maintains double buffering"
  it "handles vertical sync"
  it "supports palette mapping"
  it "manages clipping arrays"
  it "handles detail levels"
end
```

#### Wall Rendering Tests
```ruby
describe "WallRenderer" do
  it "renders walls with correct heights"
  it "applies texture mapping"
  it "handles clipping"
  it "supports different wall types"
  it "handles masked textures"
  it "applies lighting"
end
```

#### Floor/Ceiling Tests
```ruby
describe "FloorCeilingRenderer" do
  it "renders floors with perspective"
  it "renders ceilings with perspective"
  it "applies texture mapping to floors/ceilings"
  it "handles sky rendering"
  it "supports different light levels"
  it "handles special effects"
end
```

### Phase 3: Integration

#### Renderer Integration Tests
```ruby
describe "SoftwareRenderer" do
  it "coordinates all rendering components"
  it "maintains consistent frame rate"
  it "handles player movement"
  it "supports different map layouts"
  it "manages sprite rendering"
  it "handles weapon sprites"
end
```

#### Performance Tests
```ruby
describe "Renderer Performance" do
  it "maintains 35 FPS on target hardware"
  it "handles complex scenes efficiently"
  it "minimizes memory usage"
  it "optimizes texture caching"
  it "efficiently handles sprite sorting"
end
```

## Implementation Order

1. Start with `Viewport` class to handle screen dimensions and scaling
   - Implement view size calculations
   - Add detail level support
   - Handle aspect ratio correction

2. Implement `RayCaster` with basic wall detection
   - Add DDA algorithm for wall detection
   - Calculate wall distances
   - Handle texture coordinates

3. Add `TextureMapper` for wall textures
   - Implement texture loading from WAD
   - Add texture coordinate calculation
   - Handle texture pegging and translation

4. Create `ScreenBuffer` for double buffering
   - Implement clipping arrays
   - Add palette mapping
   - Handle detail levels

5. Implement `WallRenderer` with texture mapping
   - Add wall height calculation
   - Implement texture mapping
   - Handle masked textures

6. Add `FloorCeilingRenderer`
   - Implement perspective correction
   - Add sky rendering
   - Handle special effects

7. Integrate everything in `SoftwareRenderer`
   - Coordinate rendering components
   - Add sprite rendering
   - Implement weapon sprites

## Test Data
Using freedoom1.wad for testing:
- E1M1: Basic wall rendering
- E1M2: Complex geometry
- E1M3: Texture variety
- E1M4: Performance testing

## Progress Log

### 2025-03-07
- Removed old renderer code and tests
- Created base renderer interface
- Started software renderer implementation
- Created TDD plan for rebuild

### 2025-03-07
- Updated renderer rebuild plan to align with Chocolate DOOM architecture
- Added detailed implementation steps for each component
- Enhanced test coverage for all rendering components
- Added sprite and weapon rendering support 