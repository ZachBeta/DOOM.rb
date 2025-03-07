# frozen_string_literal: true

require 'minitest/autorun'
require 'minitest/pride'
require 'matrix'
require 'simplecov'
require 'doom/logger'
require 'doom/wad_file'
require 'doom/texture'
require 'doom/texture_composer'
require 'doom/config'
require 'fileutils'
require 'gosu'
require 'doom/player'

SimpleCov.start do
  add_filter '/test/'
  track_files 'lib/**/*.rb'
  enable_coverage :branch
end

module TestHelper
  def setup_test_logs
    FileUtils.mkdir_p('logs')
    FileUtils.mkdir_p('logs/history')
    cleanup_old_logs
    # Configure logger for test environment with debug logging enabled
    # but suppress terminal output
    Doom::Logger.configure(
      level: :debug,
      base_dir: 'logs',
      env: :test
    )
  end

  def load_test_textures
    wad_path = Doom::Config.wad_path
    wad_file = Doom::WadFile.new(wad_path)
    composer = Doom::TextureComposer.new
    textures = wad_file.textures
    pnames = wad_file.lump('PNAMES')&.read
    patches = {}

    if pnames
      count = pnames[0, 4].unpack1('V')
      patch_names = pnames[4..].unpack('Z8' * count)

      patch_names.each do |name|
        logger = Doom::Logger.instance
        logger.debug("Loading patch: #{name}")
        lump = wad_file.lump(name)
        logger.debug("Lump found: #{lump.inspect}")
        next unless lump

        logger.debug("Lump class: #{lump.class}")
        logger.debug("Lump methods: #{lump.methods - Object.methods}")
        patches[name] = Doom::Patch.new(
          name: name,
          width: lump.width,
          height: lump.height,
          data: lump.read
        )
      end
    end

    # Load a subset of textures for testing
    test_textures = {}
    %w[STARTAN3 COMPBLUE COMPUTE1].each do |name|
      next unless textures[name]

      test_textures[name] = composer.compose(textures[name], patches)
    end
    test_textures
  end

  private

  def cleanup_old_logs
    %w[debug verbose game doom].each do |type|
      pattern = "logs/#{type}*.log"
      files = Dir.glob(pattern).sort_by { |f| File.mtime(f) }.reverse
      files[5..].each { |f| File.delete(f) } if files.size > 5
    end
  end
end

class Minitest::Test
  include TestHelper

  def setup
    setup_test_logs
  end

  def teardown
    # Ensure logs are rotated after each test if they exist
    return unless Dir.exist?('logs') && !Dir.glob('logs/*.log').empty?

    return unless defined?(Rake::Task) && Rake::Task.task_defined?('rotate_logs')

    Rake::Task['rotate_logs'].execute
  end
end

# Configure logger for test environment with debug logging enabled
# but suppress terminal output
Doom::Logger.configure(
  level: :debug,
  base_dir: 'logs',
  env: :test
)

module Doom
  class TestWindow < Gosu::Window
    def initialize(width = 800, height = 600)
      super(width, height, false)
      @width = width
      @height = height
    end

    def needs_cursor?
      false
    end

    def button_down(id)
      close if id == Gosu::KB_ESCAPE
    end

    def update
      # No-op for testing
    end

    def draw
      # No-op for testing
    end
  end

  class Map
    def wall_at?(x, y)
      (x == 6 && y == 5) || # Wall one unit to the right of default player position
        x.negative? || y.negative? || x >= 10 || y >= 10 # Boundary walls
    end

    def width = 10
    def height = 10
    def empty?(x, y) = !wall_at?(x, y)
  end

  class ComposedTexture
    attr_reader :width, :height, :data, :mipmaps

    def initialize(width:, height:, data:)
      @width = width
      @height = height
      @data = data
      @mipmaps = []
    end
  end
end
