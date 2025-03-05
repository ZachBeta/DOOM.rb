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

## Now
- [ ] swap out rspec for minitest - the less magic and metaprogramming the better
- [ ] controls are inverted for strafing
- [ ] improve logging to be able to feed logs into cursor context while debugging and iterating
- [ ] steer architecture to be more LLM friendly - small classes with simple public methods that are easy to reason about and do not require us to load them into context
- [ ] maybe split worklogs up
- [ ] Add collision detection with walls
- [ ] Implement texture mapping for walls
- [ ] Add simple HUD elements

- [ ] demo system to be able to replay the game - makes it easier for system and acceptance testing
- [ ] minimap

## Next
- [ ] Implement WAD file parser
- [ ] Add enemies and weapons
- [ ] Implement sound effects
- [ ] Add music playback

## Soon
- [ ] Implement more advanced lighting
- [ ] Add multiplayer support
- [ ] Create level editor 