require_relative 'state'
require_relative 'timer'
require_relative 'counter'
require_relative 'trigger'

class Machine
  def initialize opts = {}
    interval = 1 / opts[:cycles_per_second].to_f

    @timer = Timer.new interval
    @counter1 = Counter.new @timer
    @counter2 = Counter.new @counter1
    @trigger = Trigger.new ref: 0, hys: 0.05

    @timer.add_observer self
  end

  def update
    p sum
  end

  def start
    @timer.run
  end

  def sum
    @counter2.bin + @counter1.bin
  end
end
