#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative '../lib/doom/wad_file'

def print_texture_info(wad_path)
  wad = Doom::WadFile.new(wad_path)
  puts "WAD File: #{wad_path}"
  puts "Type: #{wad.identification}"

  puts "\nTexture Lumps:"
  textures = wad.textures
  textures.each do |name, lump|
    puts "  #{name}: #{lump.size} bytes"
  end

  puts "\nTexture1 Contents:"
  texture1 = wad.parse_texture('TEXTURE1')
  texture1.each do |texture|
    puts "\nTexture: #{texture.name}"
    puts "  Size: #{texture.width}x#{texture.height}"
    puts "  Patches: #{texture.patches.size}"
    texture.patches.each do |patch|
      puts "    - #{patch.name} at (#{patch.x_offset}, #{patch.y_offset})"
    end
  end
end

if ARGV.empty?
  puts "Usage: #{$PROGRAM_NAME} <wad_file>"
  exit 1
end

print_texture_info(ARGV[0])
