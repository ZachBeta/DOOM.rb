module Doom
  class Config
    DEFAULT_WAD_PATH = File.expand_path('../../../levels/freedoom-0.13.0/freedoom1.wad', __dir__)

    class << self
      def wad_path
        DEFAULT_WAD_PATH
      end
    end
  end
end
