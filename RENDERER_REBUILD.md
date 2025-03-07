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
end
```

#### Ray Casting Tests
```ruby
describe "RayCaster" do
  it "casts rays at correct angles based on FOV"
  it "detects wall intersections"
  it "calculates wall distances"
  it "handles different wall heights"
end
```

#### Texture Mapping Tests
```ruby
describe "TextureMapper" do
  it "loads textures from WAD file"
  it "maps textures to wall segments"
  it "handles texture coordinates"
  it "applies perspective correction"
end
```

### Phase 2: Rendering Pipeline

#### Screen Buffer Tests
```ruby
describe "ScreenBuffer" do
  it "maintains double buffering"
  it "handles vertical sync"
  it "supports palette mapping"
end
```

#### Wall Rendering Tests
```ruby
describe "WallRenderer" do
  it "renders walls with correct heights"
  it "applies texture mapping"
  it "handles clipping"
  it "supports different wall types"
end
```

#### Floor/Ceiling Tests
```ruby
describe "FloorCeilingRenderer" do
  it "renders floors with perspective"
  it "renders ceilings with perspective"
  it "applies texture mapping to floors/ceilings"
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
end
```

#### Performance Tests
```ruby
describe "Renderer Performance" do
  it "maintains 35 FPS on target hardware"
  it "handles complex scenes efficiently"
  it "minimizes memory usage"
end
```

## Implementation Order

1. Start with `Viewport` class to handle screen dimensions and scaling
2. Implement `RayCaster` with basic wall detection
3. Add `TextureMapper` for wall textures
4. Create `ScreenBuffer` for double buffering
5. Implement `WallRenderer` with texture mapping
6. Add `FloorCeilingRenderer`
7. Integrate everything in `SoftwareRenderer`

## Test Data
Using freedoom1.wad for testing:
- E1M1: Basic wall rendering
- E1M2: Complex geometry
- E1M3: Texture variety
- E1M4: Performance testing

## Progress Log

### 2024-03-07
- Removed old renderer code and tests
- Created base renderer interface
- Started software renderer implementation
- Created TDD plan for rebuild 