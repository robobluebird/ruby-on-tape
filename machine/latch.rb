class Latch
  def initialize
    @state = State.new
  end

  def state
    @state.to_sym
  end

  def set
    @state.high
  end

  def reset
    @state.low
  end
end
