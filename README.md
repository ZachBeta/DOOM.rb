# DOOM.rb

A Ruby implementation of the classic DOOM game engine.

https://doomwiki.org/wiki/Can_it_run_Doom%3F
Use https://freedoom.github.io/ wads

## Overview

DOOM.rb aims to recreate the core mechanics of the original DOOM game using Ruby. This project serves as both a learning exercise in game development and a demonstration of Ruby's capabilities for graphics and game programming.

## Current Features

- Basic 3D rendering engine with raycasting
- Simple map representation
- Player movement controls with collision detection
- Wall sliding collision detection
- Noclip mode (toggle with N key)
- Minimap in bottom-right corner
- Clean, modular architecture following SOLID principles
- Comprehensive logging system with rotation
- Test-driven development with real test objects

## Planned Features

- Performance monitoring and FPS display
- Developer console for commands and cheats
- Texture mapping for walls
- Level loading from WAD files
- Enemy AI and combat
- Sound effects and music

## Getting Started

### Prerequisites

- Ruby 3.0+
- Required gems (see Gemfile)

### Installation

```bash
git clone https://github.com/ZachBeta/DOOM.rb.git
cd DOOM.rb
bundle install
```

### Running the Game

```bash
rake doom
```

### Running Tests

```bash
rake test
```

## Project Structure

- `lib/` - Core game engine code
  - `lib/doom/` - Main game components
  - `lib/doom/renderer/` - Rendering system
  - `lib/doom/player/` - Player mechanics
  - `lib/doom/map/` - Map and level handling
  - `lib/doom/input/` - Input handling
  - `lib/doom/logging/` - Logging system
- `test/` - Test files with real test objects
- `assets/` - Game assets (textures, sounds, etc.)
- `levels/` - WAD files and level data
- `.cursor/` - Project tooling and guidelines

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Acknowledgments

- id Software for creating the original DOOM
- The Ruby community for their excellent libraries and tools 