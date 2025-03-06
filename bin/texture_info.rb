#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative '../lib/doom/wad_file'
require_relative '../lib/doom/logger'

def print_texture_info(wad_path)
  logger = Doom::Logger.instance
  wad = Doom::WadFile.new(wad_path)
  logger.info("WAD File: #{wad_path}")
  logger.info("Type: #{wad.identification}")

  logger.info("\nTexture Lumps:")
  textures = wad.textures
  textures.each do |name, texture|
    logger.debug("  #{name}: #{texture.width}x#{texture.height}")
  end

  logger.info("\nTexture1 Contents:")
  texture1 = wad.parse_texture('TEXTURE1')
  texture1.each do |texture|
    logger.info("\nTexture: #{texture.name}")
    logger.debug("  Size: #{texture.width}x#{texture.height}")
    logger.debug("  Patches: #{texture.patches.size}")
    texture.patches.each do |patch|
      logger.debug("    - #{patch.name || 'unnamed'} at (#{patch.x_offset}, #{patch.y_offset})")
    end
  end
end

if ARGV.empty?
  logger = Doom::Logger.instance
  logger.error("Usage: #{$PROGRAM_NAME} <wad_file>")
  exit 1
end

print_texture_info(ARGV[0])
