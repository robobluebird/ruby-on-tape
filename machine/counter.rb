require 'observer'

class Counter
  include Observable

  def initialize timer_or_counter
    @count = 0
    @carry = 0

    timer_or_counter.add_observer self
  end

  def bin
    "%08b" % @count
  end

  def dec
    @count
  end

  def set count
    count = count.to_i
    raise Exception.new('out of range') if count > 255 || count < 0
    @count = count
  end

  def update
    @count += 1

    if @count == 255
      changed
      @count = 0
      notify_observers
    end
  end
end
