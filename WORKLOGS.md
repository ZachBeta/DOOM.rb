# Development Worklogs

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

### Next Up
- let's try rendering some test textures and
- add noclip/clip
- modulo turn angle, 0 is north, 180 is south, -90 is west, 90 is east
* we spawn in a wall, let's move the spawn location
* at certain angles and at longer distance textures don't render at all
* try to replicate the shape of e1m1 - documented in https://doomwiki.org/wiki/E1M1:_Hangar_(Doom)

### Soon
- Render a basic player on a real map with placeholder textures
- Optimizing renderer performance
  - Target FPS: 30+
  - Investigating pixel buffer operations
  - Profiling wall rendering
  - Optimizing minimap rendering
- Player movement and collision
- Basic raycasting implementation
- Debug overlay with FPS counter
- Minimap display
- Texture mapping system
- Sprite rendering
- Sound system implementation
- Menu system
