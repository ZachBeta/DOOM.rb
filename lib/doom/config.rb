# frozen_string_literal: true

module Doom
  class Config
    PROJECT_ROOT = File.expand_path(File.join(File.dirname(__FILE__), '..', '..'))
    DEFAULT_WAD_PATH = File.join(PROJECT_ROOT, 'levels/freedoom-0.13.0/freedoom1.wad')

    class << self
      def wad_path
        puts "Resolved WAD path: #{DEFAULT_WAD_PATH}"
        DEFAULT_WAD_PATH
      end
    end
  end
end
