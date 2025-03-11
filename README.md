# DOOM.rb

A Ruby implementation of the classic DOOM game engine, focusing on vanilla accuracy inspired by Chocolate DOOM.

This is an experiment in gamedev, llm/bdd/tdd driven dev process, ripping and tearing in ruby

[![Ruby Version](https://img.shields.io/badge/ruby-3.0%2B-ruby.svg)](https://www.ruby-lang.org/)
[![License](https://img.shields.io/badge/license-GPL--2.0-blue.svg)](LICENSE)

## Quick Start

```bash
git clone https://github.com/ZachBeta/DOOM.rb.git
cd DOOM.rb
bundle install

# Install Freedoom WAD files
cd levels && curl -L https://github.com/freedoom/freedoom/releases/download/v0.13.0/freedoom-0.13.0.zip -O && unzip freedoom-0.13.0.zip

# Run the game
rake doom
```

## Features

### Current 
- 3D rendering engine with raycasting using Gosu
- Player movement with collision detection
- Noclip mode (N key)
- Minimap and FPS display
- WAD file parsing and inspection
- Test-driven development
- Texture system with TEXTURE1/TEXTURE2 support
- Basic texture rendering and caching
- Wall rendering with directional coloring
- Debug information display
- Keyboard input handling with Gosu
- Efficient pixel buffer operations
- Double buffering with Gosu
- Frame timing optimization

### In Progress 
- Vanilla DOOM feature parity
- Original DOOM source code study
- Advanced texture features (filtering, mip-mapping)
- Performance optimization targeting 30+ FPS
- Gosu-specific rendering optimizations
- Texture mapping with Gosu's pixel operations

### Planned 
- Full WAD file loading
- Advanced texture mapping
- Enemies and weapons
- Sound and music using Gosu's audio system
- Multiplayer support

## Development

```bash
# Run tests
rake test

# WAD file inspection tools
rake wad:info[path/to/wad]      # Display WAD file information
rake wad:textures[path/to/wad]  # Display texture information
```

### Project Structure

```
lib/doom/      # Core game components
├── renderer/  # 3D rendering system using Gosu
├── player/    # Player mechanics
├── map/       # Level handling
├── input/     # Input handling with Gosu
├── wad/       # WAD file parsing
└── logging/   # Logging system
```

### Documentation

- [RENDERER.md](RENDERER.md) - Comprehensive documentation of the rendering system
- [RULES.md](RULES.md) - Project guidelines and rules
- [WORKLOGS.md](WORKLOGS.md) - Development progress and task tracking
- [docs/wad_format.md](docs/wad_format.md) - WAD file format documentation

## Credits

- Based on [can-it-run-doom](https://github.com/zvolchak/can-it-run-doom)
- Uses [Freedoom](https://freedoom.github.io/) WAD files
- [Can it run Doom?](https://doomwiki.org/wiki/Can_it_run_Doom%3F)
- Original DOOM by id Software
- Chocolate Doom
- The doom source port community
- The Doom Slayer for ripping and tearing
- [Gosu](https://www.libgosu.org/) - 2D game development library

## License

[GNU General Public License v2.0](LICENSE)

This project is licensed under GPL-2.0 to align with the original DOOM and Chocolate DOOM codebases.