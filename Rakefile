require "rubygems"
require "pathname"
require "rake"
require "rake/testtask"

# Tests
task :default => :test

Rake::TestTask.new do |t|
  t.libs << "tests"
  t.test_files = FileList['tests/**/*_test.rb']
  t.verbose = true
end

# Gem
require "rake/gempackagetask"

NAME = "worm"
SUMMARY = "Wheels O/RM"
GEM_VERSION = "0.1"

spec = Gem::Specification.new do |s|
  s.name = NAME
  s.summary = s.description = SUMMARY
  s.author = "Wieck Media"
  s.email = "dev@wieck.com"
  s.version = GEM_VERSION
  s.platform = Gem::Platform::RUBY
  s.require_path = 'lib'
  s.files = %w(Rakefile) + Dir.glob("lib/**/*")
end

Rake::GemPackageTask.new(spec) do |pkg|
  pkg.gem_spec = spec
end

desc "Install Wheels O/RM as a gem"
task :install => [:repackage] do
  sh %{gem install pkg/#{NAME}-#{GEM_VERSION}}
end

desc "Publish Wheels O/RM gem"
task :publish do
  STDOUT.print "Publishing gem... "
  STDOUT.flush
  `ssh gems@able.wieck.com "cd #{NAME} && git pull &> /dev/null && rake repackage &> /dev/null && cp pkg/* ../site/gems && cd ../site && gem generate_index"`
  STDOUT.puts "done"
end

desc "Run performance benchmarks"
task :perf do
  if RUBY_PLATFORM =~ /java/
    sh("jruby -r'lib/wheels/orm' script/performance.rb")
  else
    sh("ruby -r'lib/wheels/orm' script/performance.rb dm")
  end
end

desc "Run profiling"
task :profile do
  sh("jruby -r'lib/wheels/orm' -rprofile script/profile.rb")
end

namespace :profile do
  desc "Run profiling for get"
  task :get do
    sh("TARGET=get jruby -r'lib/wheels/orm' script/profile/get.rb")
  end
end