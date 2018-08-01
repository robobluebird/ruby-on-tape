require_relative 'timer'
require_relative 'counter'

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
