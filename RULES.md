# DOOM.rb Cursor Rules

## Core Principles
- Write Ruby code following Sandi Metz's POODR principles
- Keep explanations and follow-up questions minimal to save tokens
- Follow vanilla DOOM behavior as documented in Chocolate DOOM source code in `reference/chocolate-doom`
- Use Gosu gem for window management and rendering
- Follow the modernization plan in `RENDERER_PLAN.md` for Gosu implementation
- reference `.gems/ruby/3.3.0/gems/gosu-0.15.0` for Gosu gem documentation
- Do not try to use ffi on Gosu directly
- Do not use additional OpenGL bindings or gems
- Ensure GPL-2.0 license compliance
- Hard lock to 800x600 resolution for now
- After running `rake test` or `rake doom`, pause and ask for any additional test notes
* use extensive logging to help track down issues

## Code Style Guidelines

### Ruby Style
- Follow Practical Object-Oriented Design principles
- Focus on single responsibility, dependency injection, and composition over inheritance
- Keep classes small and focused with clear public interfaces
- Write self-documenting code using clear method and variable names
- Only add comments for complex algorithms or when code cannot be made clearer through refactoring
- Use require more intelligently

### Game Architecture
- Maintain separation of concerns between game components
- Keep rendering logic separate from game logic
- Use composition over inheritance
- Follow the Single Responsibility Principle
- Prefer small, focused classes with clear public interfaces

## Testing Requirements
- Write Minitest tests focusing on behavior for non-rendering components
- Use freedoom1.wad from `levels/freedoom-0.13.0/freedoom1.wad` for WAD file testing
- Follow Arrange-Act-Assert pattern
- Keep tests isolated
- All automated tests must pass (`rake test`) before marking tasks complete

### Renderer Testing
- Test renderer components manually by running the game with `rake doom`
- Analyze logs for rendering performance and errors
- Collect feedback on visual appearance and behavior
- Document any visual artifacts or rendering issues
- Verify FPS counter and debug information display
- Test player movement and collision detection visually
- Check minimap functionality and accuracy
- After testing, document observations in WORKLOGS.md
- Do not rely on automated tests for visual rendering components

## Performance Guidelines

### Rendering and Physics
- Use Gosu's 2D graphics capabilities for rendering
- Implement efficient pixel buffer operations using Gosu's API
- Focus on optimizing raycasting calculations
- Avoid unnecessary object creation in tight loops
- Consider using memoization or caching for expensive calculations
- Use profiling to identify bottlenecks
- Implement efficient texture lookup methods
- Cache textures for performance
- Target 30+ FPS with smooth frame timing

### Performance Monitoring
- Implement monitoring with minimal overhead
- Use Gosu's built-in timing system
- Consider frame timing and rate smoothing
- Log performance data at appropriate intervals

## Feature-Specific Guidelines

### Gosu Implementation
- Use Gosu::Window as base class for window management
- Implement proper update/draw cycle using Gosu's game loop
- Use Gosu's pixel buffer API for efficient rendering
- Follow modern Ruby game development practices
- Focus on efficient buffer management and frame timing
- Leverage Gosu's built-in double buffering
- Use Gosu's input handling system

### WAD File Parsing
- Follow vanilla DOOM WAD format specifications
- Use clean, modular classes with single responsibilities
- Separate concerns between file I/O, data structure parsing, and data access
- Cache data only when needed
- Use streaming for large files
- Follow DOOM source code naming conventions

### Texture Mapping
- Calculate texture coordinates based on wall hit positions
- Use Gosu's pixel operations for texture rendering
- Implement texture caching for performance
- Focus on software-based texture mapping techniques

### Collision Detection
- Implement using simple geometric calculations
- Consider grid-based approach for efficiency
- Separate collision detection from movement logic

### Developer Console
- Implement using command pattern
- Keep console rendering efficient
- Support command history and auto-completion
- Make console toggleable and non-intrusive

## Logging Standards
- Use appropriate log levels:
  - Debug: Detailed development info (debug.log)
  - Info/Warn/Error/Fatal: Important game events (game.log)
- Keep debug logs verbose for development
- Keep game.log clean
- Log important state changes and errors in game.log
- Log detailed debugging info in debug.log

## Project Management
- Monitor progress through WORKLOGS.md and README.md
- Update cursor rules as project evolves
- Ensure rules stay aligned with current project priorities
- Before marking tasks complete:
  1. Pass all automated tests for non-rendering components
  2. Follow project style guidelines
  3. Update cursor rules if needed
  4. Manually test with `rake doom` and document observations



  * when using git, use cat so view doesn't cause scroll issues