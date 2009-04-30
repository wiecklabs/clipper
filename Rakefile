require "rubygems"
require "pathname"
require "rake"
require "rake/testtask"

# Tests
task :default => [:test]

Rake::TestTask.new do |t|
  t.libs << "tests"
  t.test_files = FileList["tests/**/*_test.rb"]
  t.verbose = true
end

# Gem
require "rake/gempackagetask"

NAME = "beacon"
SUMMARY = "Beacon O/RM"
GEM_VERSION = "0.1.1"

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

desc "Install the Beacon O/RM as a gem"
task :install => [:repackage] do
  sh %{gem install pkg/#{NAME}-#{GEM_VERSION}}
end

desc "Publish the Beacon O/RM gem"
task :publish do
  STDOUT.print "Publishing gem... "
  STDOUT.flush
  `ssh gems@gems.wieck.com "cd #{NAME} && git pull &> /dev/null && rake repackage &> /dev/null && cp pkg/* ../site/gems && cd ../site && gem generate_index"`
  STDOUT.puts "done"
end

desc "Run performance benchmarks"
task :perf do
  if RUBY_PLATFORM =~ /java/
    sh("jruby -r'lib/beacon' script/performance.rb")
  else
    sh("ruby -r'lib/beacon' script/performance.rb dm")
  end
end

desc "Run profiling"
task :profile do
  sh("jruby -r'lib/beacon' -rprofile script/profile.rb")
end

namespace :profile do
  desc "Run profiling for get"
  task :get do
    sh("TARGET=get jruby -r'lib/beacon' script/profile/get.rb")
  end

  desc "Run profiling for create"
  task :create do
    sh("TARGET=create jruby -r'lib/beacon' script/profile/create.rb")
  end
end

def java_classpath_arg # myriad of ways to discover JRuby classpath
    jruby_cpath = ENV['JRUBY_PARENT_CLASSPATH'] || ENV['JRUBY_HOME'] &&
      FileList["#{ENV['JRUBY_HOME']}/lib/*.jar"].join(File::PATH_SEPARATOR)
  jruby_cpath ? "-cp #{jruby_cpath}" : ""
end

desc "Compile the native Java code."
task :java_compile do
  puts "Compiling native Java code"
  pkg_classes = File.join(*%w(pkg classes))
  jar_name = File.join(*%w(lib beacon_internal.jar))
  mkdir_p pkg_classes
  sh "javac -target 1.5 -source 1.5 -Xlint:unchecked -d pkg/classes #{java_classpath_arg} #{FileList['src/java/**/*.java'].join(' ')}"
  sh "jar cf #{jar_name} -C #{pkg_classes} ."
end
file "lib/beacon_internal.jar" => :java_compile