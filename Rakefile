# frozen_string_literal: true

require 'rake/testtask'

desc 'Run the DOOM.rb game'
task :doom do
  ruby 'lib/doom.rb'
end

desc 'Run tests'
Rake::TestTask.new(:test) do |t|
  t.libs << 'test'
  t.test_files = FileList['test/**/*_test.rb']
  t.warning = false
  t.verbose = true
end

namespace :wad do
  desc 'Display WAD file information'
  task :info, [:wad_path] do |_, args|
    raise 'Please provide a WAD file path: rake wad:info[path/to/wad]' unless args[:wad_path]

    ruby "bin/wad_info.rb #{args[:wad_path]}"
  end

  desc 'Display WAD texture information'
  task :textures, [:wad_path] do |_, args|
    raise 'Please provide a WAD file path: rake wad:textures[path/to/wad]' unless args[:wad_path]

    ruby "bin/texture_info.rb #{args[:wad_path]}"
  end
end

task default: :doom
