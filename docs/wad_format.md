# WAD File Format Documentation

## Overview
WAD (Where's All the Data) files are the primary data containers used by DOOM and compatible games like Freedoom. They contain all game assets including levels, textures, sprites, and sounds.

## WAD Header Structure
The WAD file begins with a 12-byte header:

1. Identification (4 bytes)
   - "IWAD" for main game data
   - "PWAD" for patch/modification data

2. Number of Lumps (4 bytes)
   - 32-bit integer specifying total number of lumps

3. Directory Offset (4 bytes)
   - 32-bit integer pointing to the start of the WAD directory

## Next Steps
- Document lump directory structure
- Document level data format
- Document texture and sprite formats
- Document sound data format 