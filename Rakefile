# frozen_string_literal: true

require 'rake/testtask'

desc 'Run the DOOM.rb game'
task :doom do
  ruby 'lib/doom.rb'
end

desc 'Run all tests'
Rake::TestTask.new(:test) do |t|
  t.libs << 'test'
  t.test_files = FileList['test/**/*_test.rb']
  t.warning = false
  t.verbose = true
end

task default: :doom
