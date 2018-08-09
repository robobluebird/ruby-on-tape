require_relative 'state'
require_relative 'clock'
require_relative 'counter'
require_relative 'trigger'
require_relative 'latch'
require_relative 'shift_register'

class Machine
  def initialize opts = {}
    interval = 1 / (opts[:khz].to_f * 1000)

    @clock = Clock.new interval
    @counter1 = Counter.new @clock
    @counter2 = Counter.new @counter1
    @trigger = Trigger.new 0, 0.05

    @clock.add_observer self
  end

  def update
    p sum
  end

  def start
    @clock.run
  end

  def sum
    @counter2.bin + @counter1.bin
  end
end
