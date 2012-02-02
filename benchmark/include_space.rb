require './runner'
require './allocation'

class IncludeUser
  include Runner
end

p(Allocation.count do
  1000000.times do
    user = IncludeUser.new
    user.run
  end
end)