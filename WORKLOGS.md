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
- [x] Updated cursor rules with project-specific guidelines for code quality and upcoming features
- [x] Implemented self-healing cursor rules that evolve with the project
- [x] Added collision detection with walls
- [x] Implemented noclip mode to bypass collision detection (toggle with N key)
- [x] Fixed collision detection bug with Vector objects

## In Progress
- [ ] Improve logging to feed logs into cursor context while debugging - not too noisy tho, this will blow up the context window

# Next
- [ ] Implement texture mapping for walls
- [ ] Add simple HUD elements
- [ ] Create demo system for replaying gameplay (for testing)
- [ ] Implement minimap
- [ ] Add HUD with player stats

## Soon
- [ ] console
* [ ] make a gem, don't bother publishing, just keep it local for now
- [ ] Implement WAD file parser
- [ ] Add enemies and weapons
- [ ] Implement sound effects
- [ ] Add music playback

## Future
- [ ] Implement more advanced lighting
- [ ] Add multiplayer support
- [ ] Create level editor 