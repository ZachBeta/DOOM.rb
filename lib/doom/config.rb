module Doom
  class Config
    class << self
      def wad_path
        File.expand_path('../../levels/freedoom-0.13.0/freedoom1.wad', __dir__)
      end
    end
  end
end
