# Taken from Aaron Patterson's blog
# http://tenderlovemaking.com/2011/06/29/i-want-dtrace-probes-in-ruby/

module Allocation
  def self.count
    GC.disable
    before = ObjectSpace.count_objects
    yield
    after = ObjectSpace.count_objects
    after.each { |k,v| after[k] = v - before[k] }
    GC.enable
    after
  end
end