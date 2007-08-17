require "rake"
require 'rake/gempackagetask'
require "rake/testtask"

ARCHLIB = "lib/#{::Config::CONFIG['arch']}"

task :default => %w[compile test]

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

Gem::manage_gems

specification = Gem::Specification.new do |s|
	s.name   = "mixology"
  s.summary = "Mixology enables objects to mix and unmix modules."
	s.version = "0.1.0"
	s.author = "Pat Farley, Z, Dan Manges"
	s.description = s.summary
  s.homepage = "http://mixology.rubyforge.org"
  s.rubyforge_project = "mixology"
  s.has_rdoc = false
  s.autorequire = "mixology"
  s.files = FileList['ext/**/*.{c,rb}', '{lib,test}/**/*.rb', '^[A-Z]+$', 'Rakefile'].to_a
  s.platform = Gem::Platform::RUBY
  s.extensions = FileList["ext/**/extconf.rb"].to_a
end
Rake::GemPackageTask.new(specification) do |package|
  package.need_zip = false
  package.need_tar = false
end
