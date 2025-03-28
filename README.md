# DOOM.rb

A Ruby implementation of the classic DOOM engine using Gosu for rendering.

## Overview

DOOM.rb is a modern Ruby port of the classic DOOM engine, using Gosu for window management and rendering. The project aims to maintain compatibility with original DOOM WAD files while leveraging modern Ruby practices and object-oriented design principles.

## Features

- Software-based rendering using Gosu's pixel buffer API
- WAD file parsing and loading
- Raycasting-based 3D rendering
- Player movement and collision detection
- Minimap display
- Debug information overlay
- Performance monitoring

## Requirements

- Ruby 3.3.0+
- Gosu gem (~> 0.15.0)
- FreeDOOM WAD file (for testing)

## Installation

1. Clone the repository
2. Install dependencies:
```bash
bundle install
```

## Running

To run the game:
```bash
rake doom
```

To run the FPS tech demo:
```bash
rake demo
```

### FPS Demo Controls
- WASD: Movement (A/D for strafing)
- Left/Right Arrows: Rotation
- Tab: Toggle debug overlay
- Esc: Exit

To run tests:
```bash
rake test
```

## Development Status

Currently implementing:
- Texture mapping system
- Performance optimizations for renderer
- Sprite rendering
- Sound system

## Project Structure

## Development Tracking
Development progress is tracked in the `.github/worklogs` directory:
- `main.md`: Global tasks and features
- `branches/`: Branch-specific worklogs
  - Each feature branch has its own worklog file
  - Tasks are moved to main.md when completed

## License

GPL-2.0 License - See COPYING.md for details