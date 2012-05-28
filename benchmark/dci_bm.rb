require 'benchmark'
require './runner'

class DCIUser; end

Benchmark.bm do |bench|
  3.times do
    bench.report('DCI') do
      1000000.times do
        user = DCIUser.new
        user.extend Runner
        user.run
      end
    end
  end
end