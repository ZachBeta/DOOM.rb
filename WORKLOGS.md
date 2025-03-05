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
  - Added minimap to bottom-right corner with player position and direction

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
  
- [x] Performance & Display
  - Show frame rate (FPS) in top left display

- [x] Graphics & Engine
  - Out of scope - this is a proof of concept implementation, and NOT a product
    - Analyze PrBoom+ for modern features balance
    - Review ZDoom for advanced features
    - Also out of scope
      - https://github.com/ZDoom/gzdoom
      - https://github.com/TorrSamaho/zandronum
      - The other source ports are more about modern playability and modding, and adding modern features, which is out of scope, and likely not worth pursuing given this is NOT inteded to be actively played, in the same way you might play doom in a PDF, but not in earnest, unless "Hurt Me Plenty" is your selected game mode IRL
    

## Next
* [ ] Feature list
    - Document feature parity goals with Chocolate Doom first

- [ ] Graphics & Engine
  - Research open source DOOM ports for compatibility
    - Study Chocolate Doom for vanilla accuracy
    - now considering how to LLM my way thru
        https://github.com/id-Software/DOOM
        https://github.com/chocolate-doom/chocolate-doom


- [ ] Developer Tools
  - Implement console for commands and cheats
  - Create demo system for replaying gameplay

## Future
- [ ] Graphics & Engine
  - Implement texture mapping for walls
  - Create gem structure (local only)

- [ ] Content & Gameplay
  - Implement WAD file parser
  - Add enemies and weapons
  - Add sound effects and music

- [ ] Advanced Features
  - Implement advanced lighting
  - Add multiplayer support
  - Create level editor 


- [ ] Developer Tools
  - Add more tests to improve coverage
- [ ] Performance & Display
  - Profile and optimize rendering loop
  - Add performance monitoring tools

- [ ] Graphics & Engine
  - Research open source DOOM ports for compatibility
    - Study Chocolate Doom for vanilla accuracy
    - Consider GPL licensing implications when code is currently MIT licensed
      - https://www.gnu.org/licenses/license-list.en.html
          X11 License (#X11License)
          This is a lax permissive non-copyleft free software license, compatible with the GNU GPL. Older versions of XFree86 used the same license, and some of the current variants of XFree86 also do. Later versions of XFree86 are distributed under the XFree86 1.1 license.

          Some people call this license “the MIT License,” but that term is misleading, since MIT has used many licenses for software. It is also ambiguous, since the same people also call the Expat license “the MIT License,” failing to distinguish them. We recommend not using the term “MIT License.”

          The difference between the X11 license and the Expat license is that the X11 license contains an extra paragraph about using the X Consortium's name. It is not a big deal, but it is a real difference.

          This is a fine license for a small program. A larger program usually ought to be copyleft; but if you are set on a lax permissive license for one, we recommend the Apache 2.0 license since it protects users from patent treachery.

          ---

          so roughly it feels like MIT is good enough for now, and I can switch to the same license as chocolate doom as this project continues