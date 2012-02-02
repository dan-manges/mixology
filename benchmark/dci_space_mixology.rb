require './runner'
require './allocation'
require 'mixology'

class DCIUser; end

p(Allocation.count do
  1000000.times do
    user = DCIUser.new
    user.mixin Runner
    user.run
  end
end)
