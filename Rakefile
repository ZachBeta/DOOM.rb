# frozen_string_literal: true

require 'rake/testtask'
require 'timeout'
require 'fileutils'
require_relative 'lib/doom/config'
require_relative 'lib/doom/logger'

desc 'Rotate logs - move current logs to history with timestamps'
task :rotate_logs do
  logger = Doom::Logger.instance
  logger.info('Rotating logs...')
  timestamp = Time.now.strftime('%Y%m%d_%H%M%S')
  base_logs = %w[doom.log debug.log verbose.log game.log]

  # Move all log files to history
  Dir.glob('logs/*.log{,.[0-9]*}').each do |log_file|
    next if File.directory?(log_file)

    basename = File.basename(log_file)

    if basename =~ /\.log\.\d+$/
      new_name = "logs/history/#{File.basename(basename,
                                               '.log.*')}_#{timestamp}#{File.extname(basename)}"
    else
      new_name = "logs/history/#{File.basename(basename, '.log')}_#{timestamp}.log"
    end

    FileUtils.mv(log_file, new_name)
    logger.debug("Moved #{basename} to #{new_name}")
  end

  # Create fresh empty base log files
  base_logs.each do |log|
    FileUtils.touch("logs/#{log}")
    logger.debug("Created fresh #{log}")
  end

  logger.info('Log rotation complete')
end

desc 'Run the DOOM viewer'
task run: :rotate_logs do
  ruby 'lib/doom.rb', Doom::Config.wad_path
end

desc 'Run tests with coverage'
task coverage: :rotate_logs do
  require 'simplecov'
  SimpleCov.start do
    add_filter '/test/'
    add_filter '/vendor/'
  end
  Rake::Task[:test].execute
end

desc 'Run the DOOM viewer with profiling'
task profile: :rotate_logs do
  require 'ruby-prof'
  result = RubyProf.profile do
    ruby 'lib/doom.rb', Doom::Config.wad_path
  end
  printer = RubyProf::FlatPrinter.new(result)
  printer.print(STDOUT)
end

desc 'Run tests'
Rake::TestTask.new(:test) do |t|
  FileUtils.mkdir_p('logs')
  t.libs << 'test'
  t.libs << 'lib'
  t.test_files = FileList['test/**/*_test.rb']
  t.warning = false
  t.verbose = true
end

task test: :rotate_logs

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
      Rake::Task['run'].invoke
    end
  rescue Timeout::Error
    puts 'DOOM game terminated after 5 seconds'
  end

  puts "\nAll tasks completed!"
end

task default: :run_all
