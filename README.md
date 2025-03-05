# DOOM.rb

A Ruby implementation of the classic DOOM game engine.

## Overview

DOOM.rb aims to recreate the core mechanics of the original DOOM game using Ruby. This project serves as both a learning exercise in game development and a demonstration of Ruby's capabilities for graphics and game programming.

## Current Features

- Basic 3D rendering engine with raycasting
- Simple map representation
- Player movement controls
- Basic window creation and rendering loop

## Planned Features

- Collision detection with walls
- Texture mapping for walls
- HUD and minimap
- Level loading from WAD files
- Enemy AI
- Player combat
- Sound effects and music

## Getting Started

### Prerequisites

- Ruby 3.0+
- Required gems (see Gemfile)

### Installation

```bash
git clone https://github.com/yourusername/DOOM.rb.git
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
- `test/` - Test files
- `assets/` - Game assets (textures, sounds, etc.)
- `levels/` - WAD files and level data

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Acknowledgments

- id Software for creating the original DOOM
- The Ruby community for their excellent libraries and tools 