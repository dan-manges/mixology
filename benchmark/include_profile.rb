require 'perftools'
require './runner'

class IncludeUser
  include Runner
end

PerfTools::CpuProfiler.start('/tmp/include_profile') do
  1000000.times do
    user = IncludeUser.new
    user.run
  end
end