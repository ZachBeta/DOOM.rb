# DOOM.rb

A Ruby implementation of the classic DOOM game engine.

For WAD files, use [Freedoom](https://freedoom.github.io/).

## Overview

DOOM.rb aims to recreate the core mechanics of the original DOOM game using Ruby, with a focus on vanilla accuracy inspired by Chocolate DOOM. This project serves as both a learning exercise in game development and a demonstration of Ruby's capabilities for graphics and game programming.

## Current Features

- Basic 3D rendering engine with raycasting
- Simple map representation
- Player movement with collision detection and wall sliding
- Noclip mode (toggle with N key)
- Minimap in bottom-right corner
- FPS display in top-left corner
- Clean, modular architecture following SOLID principles
- Comprehensive logging system with rotation
- Test-driven development with real test objects

## In Progress

- Studying original DOOM and Chocolate DOOM source code
- Planning feature parity with vanilla DOOM

## Planned Features

- Developer console for commands and cheats
- Texture mapping for walls
- WAD file loading
- Enemies and weapons
- Sound effects and music
- Advanced lighting
- Multiplayer support

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