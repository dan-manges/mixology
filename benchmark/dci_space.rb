require './runner'
require './allocation'

class DCIUser; end

p(Allocation.count do
  1000000.times do
    user = DCIUser.new
    user.extend Runner
    user.run
  end
end)
