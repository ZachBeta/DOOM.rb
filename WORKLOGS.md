# DOOM.rb Work Logs

## Done
- [x] Created initial project structure
- [x] Set up README.md with project overview
- [x] Created WORKLOGS.md to track progress
- [x] Set up basic Ruby project structure (lib, spec directories)
- [x] Created Gemfile with initial dependencies
- [x] Implemented basic window creation and rendering loop
- [x] Created simple map representation
- [x] Implemented basic raycasting renderer
- [x] Added player movement controls
- [x] Fixed inverted strafing controls
- [x] Swapped out RSpec for Minitest
- [x] Implemented basic logging system for debugging
- [x] Added Rakefile for running the game `rake doom` and for running tests `rake test`
- [x] Make architecture more LLM friendly - small classes with simple public methods
  - Refactored Renderer into smaller classes (Renderer, BackgroundRenderer, WallRenderer, Ray, RayCaster, WallIntersection)
  - Refactored Player into smaller classes (Player, Movement, Rotation)
  - Refactored Map into smaller classes (Map, Grid)
  - Refactored Game class and extracted InputHandler and GameClock
  - Applied Single Responsibility Principle throughout the codebase

## In Progress
- [ ] Improve logging to feed logs into cursor context while debugging
- [ ] Add collision detection with walls
- [ ] Implement texture mapping for walls
- [ ] Add simple HUD elements
- [ ] Create demo system for replaying gameplay (for testing)
- [ ] Implement minimap
- [ ] Add HUD with player stats
- [ ] update cursor rules with any learnings as we go

## Next
- [ ] Implement WAD file parser
- [ ] Add enemies and weapons
- [ ] Implement sound effects
- [ ] Add music playback

## Future
- [ ] Implement more advanced lighting
- [ ] Add multiplayer support
- [ ] Create level editor 