# frozen_string_literal: true

require 'rake/testtask'
require 'rubocop/rake_task'

desc 'Run the DOOM.rb game'
task :doom do
  ruby 'lib/doom.rb'
end

RuboCop::RakeTask.new

desc 'Run tests only'
Rake::TestTask.new(:test_only) do |t|
  t.libs << 'test'
  t.test_files = FileList['test/**/*_test.rb']
  t.warning = false
  t.verbose = true
end

desc 'Run all tests and RuboCop'
task test: %i[rubocop test_only]

task default: :doom
