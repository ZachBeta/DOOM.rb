# frozen_string_literal: true

require 'rake/testtask'
require 'timeout'
require 'fileutils'

desc 'Run the DOOM.rb game'
task :doom do
  ruby 'lib/doom.rb levels/freedoom-0.13.0/freedoom1.wad'
end

desc 'Run tests'
Rake::TestTask.new(:test) do |t|
  FileUtils.mkdir_p('logs')
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

task :run_all do
  freedoom_wad = 'levels/freedoom-0.13.0/freedoom1.wad'

  puts "\nRunning tests..."
  Rake::Task['test'].invoke

  puts "\nRunning WAD info task with Freedoom WAD..."
  Rake::Task['wad:info'].invoke(freedoom_wad)

  puts "\nRunning WAD textures task with Freedoom WAD..."
  Rake::Task['wad:textures'].invoke(freedoom_wad)

  puts "\nRunning DOOM game (will be terminated after 5 seconds)..."
  begin
    Timeout.timeout(5) do
      Rake::Task['doom'].invoke
    end
  rescue Timeout::Error
    puts 'DOOM game terminated after 5 seconds'
  end

  puts "\nAll tasks completed!"
end

task default: :run_all
