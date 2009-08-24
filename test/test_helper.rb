require "test/unit"
# In Ruby 1.9, require test/unit will implicitly require pp, we do it here explicitly to ensure compatibily.
require "pp"

$LOAD_PATH.unshift File.dirname(__FILE__) + "/../lib"
if defined?(RUBY_ENGINE) && RUBY_ENGINE == "rbx"
  require "mixology_rubinius"
else
  require "mixology"
end
