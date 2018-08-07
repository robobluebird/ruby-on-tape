require 'observer'

class Counter
  include Observable

  def initialize signaler = nil
    @count = 0

    signaler.add_observer(self) if signaler
  end

  def update
    @count += 1

    if @count == 16
      changed
      notify_observers
      @count = 0
    end
  end

  def bin
    "%04b" % @count
  end

  def dec
    @count
  end

  def set count
    count = count.to_i
    raise Exception.new('out of range') if count > 255 || count < 0
    @count = count
  end
end
