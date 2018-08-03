require_relative 'state'
require_relative 'timer'
require_relative 'counter'
require_relative 'trigger'

class Machine
  def initialize
    @timer = Timer.new
    @counter = Counter.new @timer
  end

  def start
    @timer.run
  end
end

m = Machine.new
m.start
