#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative '../lib/doom/wad_file'
require_relative '../lib/doom/logger'

def print_wad_info(wad_path)
  logger = Doom::Logger.instance
  wad = Doom::WadFile.new(wad_path)
  logger.info("WAD File: #{wad_path}")
  logger.info("Type: #{wad.identification}")
  logger.info("Number of lumps: #{wad.lump_count}")
  logger.info("Directory offset: #{wad.directory_offset}")

  logger.info("\nLevels:")
  wad.levels.each do |level|
    logger.info("  #{level}:")
    level_data = wad.level_data(level)
    level_data.each do |name, lump|
      logger.debug("    #{name}: #{lump.size} bytes")
    end
  end

  logger.info("\nTextures:")
  wad.textures.each do |name, texture|
    logger.debug("  #{name}: #{texture.width}x#{texture.height}")
  end

  logger.info("\nFlats:")
  wad.flats.each do |name, lump|
    logger.debug("  #{name}: #{lump.size} bytes")
  end

  logger.info("\nSprites:")
  wad.sprites.each do |name, lump|
    logger.debug("  #{name}: #{lump.size} bytes")
  end

  logger.info("\nOther Lumps:")
  other_lumps = wad.lumps.reject do |name, _|
    name.match?(Doom::WadFile::LEVEL_MARKERS) ||
      wad.level_data(name) ||
      wad.textures.key?(name) ||
      wad.flats.key?(name) ||
      wad.sprites.key?(name)
  end
  other_lumps.each do |name, lump|
    logger.debug("  #{name}: #{lump.size} bytes")
  end
end

if ARGV.empty?
  logger = Doom::Logger.instance
  logger.error("Usage: #{$PROGRAM_NAME} <wad_file>")
  exit 1
end

print_wad_info(ARGV[0])
