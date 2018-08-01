class Counter
  def initialize timer
    timer.add_observer self
  end

  def update
    p 'tick'
  end
end
