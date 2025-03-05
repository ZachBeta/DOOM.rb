# DOOM.rb Work Logs

## Done
- [x] Project Setup
  - Created initial project structure
  - Set up README.md with project overview
  - Created WORKLOGS.md to track progress
  - Set up basic Ruby project structure (lib, spec directories)
  - Created Gemfile with initial dependencies
  - Added Rakefile for running the game (`rake doom`) and tests (`rake test`)
  - Swapped out RSpec for Minitest

- [x] Core Game Features
  - Implemented basic window creation and rendering loop
  - Created simple map representation
  - Implemented basic raycasting renderer
  - Added player movement controls
  - Fixed inverted strafing controls
  - Added collision detection with walls
  - Implemented noclip mode (toggle with N key)
  - Improved player movement with wall sliding

- [x] Architecture & Code Quality
  - Refactored for better LLM interaction with small, focused classes
    - Split Renderer (Renderer, BackgroundRenderer, WallRenderer, Ray, RayCaster, WallIntersection)
    - Split Player (Player, Movement, Rotation)
    - Split Map (Map, Grid)
    - Extracted InputHandler and GameClock from Game class
  - Implemented basic logging system
  - Improved test design using real test objects
  - Added window closing with cmd+w and esc

- [x] Logging Improvements
  - Moved verbose logging to separate file
  - Implemented log levels for better cursor context
  - Added log rotation to prevent large files
  - Updated logging across game components

## Next
- [ ] Testing & Quality
  - Add more tests to improve coverage
  - Create demo system for replaying gameplay

- [ ] Features
  - Add HUD elements and minimap - use a minimap on bottom of screen rather than the toggle map mode for now
  - Implement console for commands and cheats
  - Implement texture mapping for walls
  - Create gem structure (local only)

## Future
- [ ] Content & Gameplay
  - Implement WAD file parser
  - Add enemies and weapons
  - Add sound effects and music

- [ ] Advanced Features
  - Implement advanced lighting
  - Add multiplayer support
  - Create level editor 