# Angle Standardization Branch Worklog

## Current Status: WIP

### Goals
- Implement standardized angle system
  - 0° = North
  - 90° = East
  - 180° = South
  - -90° = West

### Tasks
- [x] Update Player class angle system
- [x] Update angle normalization
- [x] Update direction vector calculations
- [ ] Fix coordinate system alignment
- [ ] Adjust movement mechanics
- [ ] Fix minimap rendering
- [ ] Update ray casting for new angle system

### Technical Notes
- Current implementation causes issues with:
  1. Movement direction relative to view angle
  2. Minimap representation
  3. Ray casting calculations
  4. Texture mapping orientation

### Next Steps
1. Review coordinate system assumptions
2. Align movement vectors with new angle system
3. Update ray casting math
4. Fix minimap orientation
5. Test all cardinal directions

### Testing Checklist
- [ ] Movement in all cardinal directions
- [ ] Proper texture orientation
- [ ] Minimap alignment
- [ ] Ray casting at various angles
- [ ] Strafe movement
- [ ] Wall collision detection 