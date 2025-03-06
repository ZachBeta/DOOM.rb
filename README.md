# DOOM.rb

A Ruby implementation of the classic DOOM game engine, focusing on vanilla accuracy inspired by Chocolate DOOM.

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

### Current ✅
- 3D rendering engine with raycasting
- Player movement with collision detection
- Noclip mode (N key)
- Minimap and FPS display
- Test-driven development

### In Progress 🚧
- Vanilla DOOM feature parity
- Original DOOM source code study

### Planned 🎯
- WAD file loading
- Texture mapping
- Enemies and weapons
- Sound and music
- Multiplayer support

## Development

```bash
rake test  # Run tests
```

### Project Structure

```
lib/doom/      # Core game components
├── renderer/  # 3D rendering system
├── player/    # Player mechanics
├── map/       # Level handling
├── input/     # Input handling
└── logging/   # Logging system
```

## Credits

- Based on [can-it-run-doom](https://github.com/zvolchak/can-it-run-doom)
- Uses [Freedoom](https://freedoom.github.io/) WAD files
- [Can it run Doom?](https://doomwiki.org/wiki/Can_it_run_Doom%3F)
- Original DOOM by id Software
- Chocolate Doom
- The doom source port community
- The Doom Slayer for ripping and tearing

## License

[GNU General Public License v2.0](LICENSE)

This project is licensed under GPL-2.0 to align with the original DOOM and Chocolate DOOM codebases. 