require "test/unit"
require "rubygems"

if RUBY_PLATFORM =~ /java/
  Test::Unit::TestCase.class_eval do
    def self.test(test_name, &block)
      define_method("test_#{test_name}", &block)
    end
  end
else
  begin
    gem "dust"
    require "dust"
  rescue LoadError
    raise "To run the tests, 'gem install dust'"
  end
end

$LOAD_PATH.unshift File.dirname(__FILE__) + "/../lib"
require "mixology"
