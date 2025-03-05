require 'minitest/autorun'
require 'minitest/pride'
require 'matrix'
require 'simplecov'

SimpleCov.start do
  add_filter '/test/'
  track_files 'lib/**/*.rb'
  enable_coverage :branch
end

# Don't require the entire doom.rb file as it starts the game
# Instead, require only the specific files needed for testing 