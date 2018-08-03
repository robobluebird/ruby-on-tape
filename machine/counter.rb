class Counter
  attr_accessor :count

  def initialize timer
    @count = 0
    timer.add_observer self
  end

  def update
    @count += 1

    @count = 0 if @count == 16
  end
end
