module Doom
  class Config
    class << self
      def wad_path
        File.expand_path('../../data/wad/freedoom1.wad', __dir__)
      end
    end
  end
end
