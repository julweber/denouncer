require "bundler/gem_tasks"
require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new(:spec)
task :default => :spec

desc 'Run a pry console session'
task :console do
  exec("pry -r ./lib/denouncer.rb")
end
task c: :console
