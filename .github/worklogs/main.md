# DOOM.rb Development Worklogs

## Global Tasks & Features

### In Progress
- Basic Gosu window management
- Fetch and parse FreeDOOM manual for feature list

### Completed
- WAD file parsing
- Testing tools setup
- Logging system implementation
  - Debug and game logging
  - Appropriate log levels
  - Verbose development logging

### Core Features (Next Up)
- [ ] Basic map rendering
  - [x] Test textures rendering
  - [ ] Proper texture mapping
  - [ ] Fix texture rendering at distance/angles
  - [ ] E1M1 map shape replication
- [ ] Player systems
  - [ ] Proper spawn location
  - [ ] Noclip/clip mode
  - [ ] Standardized angle system
  - [ ] Collision detection
- [ ] Rendering optimization
  - [ ] Target FPS: 30+
  - [ ] Pixel buffer operations
  - [ ] Wall rendering profiling
  - [ ] Minimap optimization

### Future Features
- Sprite rendering system
- Sound system implementation
- Menu system
- HUD implementation
- Enemy AI
- Weapon systems
- Multiplayer support

## Branch Status

### main
Current focus: Core engine development and basic rendering

### feature/angle-standardization
Status: WIP
- Implementing new angle system (0=North, 90=East)
- Known issues:
  - Coordinate system needs alignment
  - Movement and minimap need adjustment
  - Ray casting needs updates

## Notes
- Branch-specific tasks are tracked in separate files under `.github/worklogs/branches/`
- Each feature branch should maintain its own worklog file
- Completed tasks should be moved to the main worklog's "Completed" section 