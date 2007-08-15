require "rake"
require "rake/testtask"

ARCHLIB = "lib/#{::Config::CONFIG['arch']}"

task :default => %w[compile test]

Rake::TestTask.new("test") do |t|
  t.pattern = "test/**/*_test.rb"
end

desc "Builds the extension"
task :compile => ["ext/Makefile", "ext/mixology.#{Config::CONFIG['DLEXT']}" ]

file "ext/Makefile" => ["ext/extconf.rb"] do
  Dir.chdir("ext") do
    ruby "extconf.rb"
  end  
end

file "ext/mixology.#{Config::CONFIG['DLEXT']}" do
  Dir.chdir("ext") do
    sh "make"
  end
  mkdir_p "lib"
  cp "ext/mixology.#{Config::CONFIG['DLEXT']}", "lib"
end
