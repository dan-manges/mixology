require "rake"
require 'rake/clean'
require 'rake/gempackagetask'
require "rake/testtask"

if RUBY_PLATFORM =~ /java/
  task :default => %w[clean compile_java test]
else
  task :default => %w[clean compile test]
end

Rake::TestTask.new("test") do |t|
  t.pattern = "test/**/*_test.rb"
end

desc "Builds the extension"
task :compile => ["ext/mixable/Makefile", "ext/mixable/mixable.#{Config::CONFIG['DLEXT']}" ]

file "ext/mixable/Makefile" => ["ext/mixable/extconf.rb"] do
  Dir.chdir("ext/mixable") do
    ruby "extconf.rb"
  end  
end

file "ext/mixable/mixable.#{Config::CONFIG['DLEXT']}" do
  Dir.chdir("ext/mixable") do
    sh "make"
  end
  mkdir_p "lib"
  cp "ext/mixable/mixable.#{Config::CONFIG['DLEXT']}", "lib"
end

CLEAN.include ["ext/mixable/Makefile", "ext/mixable/mixable.bundle", "lib/mixable.bundle"]
CLEAN.include ["ext/mixable/MixableService.class", "ext/mixable/mixable.jar", "lib/mixable.jar"]

Gem::manage_gems

specification = Gem::Specification.new do |s|
	s.name   = "mixology"
  s.summary = "Mixology enables objects to mixin and unmix modules."
	s.version = "0.1.0"
	s.author = "Pat Farley, Z, Dan Manges"
	s.description = s.summary
  s.homepage = "http://mixology.rubyforge.org"
  s.rubyforge_project = "mixology"
  s.has_rdoc = false
  s.autorequire = "mixology"
  s.files = FileList['ext/**/*.{c,rb}', '{lib,test}/**/*.rb', '^[A-Z]+$', 'Rakefile'].to_a
  if RUBY_PLATFORM =~ /mswin/
    s.platform = Gem::Platform::WIN32
    s.files += ["lib/mixable.so"]
  else
    s.platform = Gem::Platform::RUBY
    s.extensions = FileList["ext/**/extconf.rb"].to_a
  end
end
Rake::GemPackageTask.new(specification) do |package|
  package.need_zip = false
  package.need_tar = false
end

desc "Compiles the JRuby extension"
task :compile_java do
  Dir.chdir("ext/mixable") do
    sh %{javac -source 1.4 -target 1.4 -classpath $JRUBY_HOME/lib/jruby.jar MixableService.java}
    sh %{jar cf mixable.jar MixableService.class}
    cp "mixable.jar", "../../lib/mixable.jar"
  end
end

