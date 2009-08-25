require "rake"
require 'rake/clean'
require 'rake/gempackagetask'
require "rake/testtask"

desc "clean, compile, test"
task :default => %w[clean compile test]

Rake::TestTask.new("test") do |t|
  t.pattern = "test/**/*_test.rb"
end

desc "Builds the extension"
if RUBY_PLATFORM =~ /java/
  task :compile => :compile_java
else
  task :compile => %W[ext/mixology/Makefile ext/mixology/mixology.#{Config::CONFIG['DLEXT']}]
end

file "ext/mixology/Makefile" => ["ext/mixology/extconf.rb"] do
  Dir.chdir("ext/mixology") do
    ruby "extconf.rb"
  end  
end

file "ext/mixology/mixology.#{Config::CONFIG['DLEXT']}" do
  Dir.chdir("ext/mixology") do
    sh "make"
  end
  cp "ext/mixology/mixology.#{Config::CONFIG['DLEXT']}", "lib"
end

CLEAN.include %w[ext/mixology/Makefile ext/mixology/mixology.bundle ext/mixology/mixology.so lib/mixology.bundle lib/mixology.so ext/mixology/mixology.o]
CLEAN.include %w[ext/mixology/MixableService.class ext/mixology/mixable.jar lib/mixology.jar]

specification = Gem::Specification.new do |s|
	s.name   = "mixology"
  s.summary = "Mixology enables objects to mixin and unmix modules."
	s.version = "0.2.0"
	s.author = "anonymous z, Pat Farley, Dan Manges"
	s.description = s.summary
  s.homepage = "http://mixology.rubyforge.org"
  s.rubyforge_project = "mixology"
  s.has_rdoc = false
  s.autorequire = "mixology"
  s.files = FileList['ext/**/*.{c,rb}', '{lib,test}/**/*.rb', '^[A-Z]+$', 'Rakefile'].to_a
  if RUBY_PLATFORM =~ /mswin/
    s.platform = Gem::Platform::WIN32
    s.files += ["lib/mixology.so"]
  elsif RUBY_PLATFORM =~ /java/
    s.platform = "java"
    s.files += ["lib/mixology.jar"]
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
  Dir.chdir("ext/mixology") do
    sh %{javac -source 1.5 -target 1.5 -classpath $JRUBY_HOME/lib/jruby.jar MixologyService.java}
    sh %{jar cf mixology.jar MixologyService.class}
    cp "mixology.jar", "../../lib/mixology.jar"
  end
end

desc "test against multiple ruby implementations"
task :test_multi do
  # this is specific to how I have Ruby installed on my machine -Dan
  jruby = %w[1.1.3 1.1.4]
  mri = %w[1.8.6-p368 1.9.1-p129]
  failed = false
  test_implementation = proc do |implementation, command|
    print "#{implementation}: "
    output = `#{command} 2>&1`
    if $?.success? && output =~ /\d\d+ tests.*0 failures, 0 errors/
      puts "PASS"
    else
      puts "FAIL"
      failed = true
    end
  end
  jruby.each do |jruby_version|
    test_implementation.call(
      "JRuby #{jruby_version}",
      "JRUBY_HOME=/usr/local/jruby-#{jruby_version} /usr/local/jruby-#{jruby_version}/bin/jruby -S rake"
    )
  end
  mri.each do |mri_version|
    test_implementation.call "MRI #{mri_version}", "/usr/local/ruby-#{mri_version}/bin/rake"
  end
  fail if failed
end

