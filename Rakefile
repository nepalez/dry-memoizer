require "bundler/setup"
Bundler::GemHelper.install_tasks

require "rspec/core/rake_task"
RSpec::Core::RakeTask.new :default

desc "runs specs"
task :default do
  system "bundle exec rspec"
end
