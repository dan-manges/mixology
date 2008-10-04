require "test/unit"
$LOAD_PATH.unshift File.dirname(__FILE__) + "/../lib"
if defined?(RUBY_ENGINE) && RUBY_ENGINE == "rbx"
  require "mixology_rubinius"
else
  require "mixology"
end
