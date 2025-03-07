# DOOM.rb Cursor Rules

## Core Principles
- Write Ruby code following Sandi Metz's POODR principles
- Keep explanations and follow-up questions minimal to save tokens
- Follow vanilla DOOM behavior as documented in Chocolate DOOM source code in `reference/chocolate-doom`
- Use glfw3 gem for opengl and reference its code in `.gems/ruby/3.3.0/gems/glfw3-0.3.3`
- Do not try to use ffi on glfw directly
- Ensure GPL-2.0 license compliance

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
- Write Minitest tests focusing on behavior
- Use freedoom1.wad from `levels/freedoom-0.13.0/freedoom1.wad` for WAD file testing
- Follow Arrange-Act-Assert pattern
- Keep tests isolated
- All automated tests must pass (`rake test`) before marking tasks complete

## Performance Guidelines

### Rendering and Physics
- Avoid unnecessary object creation in tight loops
- Consider using memoization or caching for expensive calculations
- Use profiling to identify bottlenecks
- Implement efficient texture lookup methods
- Cache textures for performance

### Performance Monitoring
- Implement monitoring with minimal overhead
- Use efficient time calculations
- Consider frame timing and rate smoothing
- Log performance data at appropriate intervals

## Feature-Specific Guidelines

### WAD File Parsing
- Follow vanilla DOOM WAD format specifications
- Use clean, modular classes with single responsibilities
- Separate concerns between file I/O, data structure parsing, and data access
- Cache data only when needed
- Use streaming for large files
- Follow DOOM source code naming conventions

### Collision Detection
- Implement using simple geometric calculations
- Consider grid-based approach for efficiency
- Separate collision detection from movement logic

### Texture Mapping
- Calculate texture coordinates based on wall hit positions
- Use efficient texture lookup methods
- Consider texture caching

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
  1. Pass all automated tests
  2. Follow project style guidelines
  3. Update cursor rules if needed
  4. Manually test with `rake doom` 