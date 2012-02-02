require 'perftools'
require './runner'

class DCIUser; end

PerfTools::CpuProfiler.start('/tmp/dci_profile') do
  1000000.times do
    user = DCIUser.new
    user.extend Runner
    user.run
  end
end