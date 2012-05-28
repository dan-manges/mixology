Gem::Specification.new do |s|
	s.name   = "mixology"
  s.summary = "Mixology enables objects to mixin and unmix modules."
	s.version = "0.2.0"
	s.author = "anonymous z, Pat Farley, Dan Manges"
	s.description = s.summary
  s.homepage = "http://mixology.rubyforge.org"
  s.rubyforge_project = "mixology"
  s.has_rdoc = false
  s.autorequire = "mixology"
  s.files = `git ls-files`.split("\n")
  if RUBY_PLATFORM =~ /mswin/
    s.platform = Gem::Platform::WIN32
    s.files += ["lib/mixology.so"]
  elsif RUBY_PLATFORM =~ /java/
    s.platform = "java"
    s.files += ["lib/mixology.jar"]
  else
    s.platform = Gem::Platform::RUBY
    s.extensions = %w(ext/mixology/extconf.rb)
  end
end
