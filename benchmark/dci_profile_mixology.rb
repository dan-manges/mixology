require 'perftools'
require './runner'
require 'mixology'

class DCIUser; end

PerfTools::CpuProfiler.start('/tmp/dci_profile_mixology') do
  1000000.times do
    user = DCIUser.new
    user.mixin Runner
    user.run
  end
end