#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative '../lib/doom/wad_file'

def print_wad_info(wad_path)
  wad = Doom::WadFile.new(wad_path)
  puts "WAD File: #{wad_path}"
  puts "Type: #{wad.identification}"
  puts "Number of lumps: #{wad.lump_count}"
  puts "Directory offset: #{wad.directory_offset}"

  puts "\nLevels:"
  wad.levels.each do |level|
    puts "  #{level}:"
    level_data = wad.level_data(level)
    level_data.each do |name, lump|
      puts "    #{name}: #{lump.size} bytes"
    end
  end

  puts "\nTextures:"
  wad.textures.each do |name, lump|
    puts "  #{name}: #{lump.size} bytes"
  end

  puts "\nFlats:"
  wad.flats.each do |name, lump|
    puts "  #{name}: #{lump.size} bytes"
  end

  puts "\nSprites:"
  wad.sprites.each do |name, lump|
    puts "  #{name}: #{lump.size} bytes"
  end

  puts "\nOther Lumps:"
  other_lumps = wad.lumps.reject do |name, _|
    name.match?(Doom::WadFile::LEVEL_MARKERS) ||
      wad.level_data(name) ||
      wad.textures.key?(name) ||
      wad.flats.key?(name) ||
      wad.sprites.key?(name)
  end
  other_lumps.each do |name, lump|
    puts "  #{name}: #{lump.size} bytes"
  end
end

if ARGV.empty?
  puts "Usage: #{$PROGRAM_NAME} <wad_file>"
  exit 1
end

print_wad_info(ARGV[0])
