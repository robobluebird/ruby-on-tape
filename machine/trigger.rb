class Trigger
  attr_reader :low, :high, :ref

  def initialize opts = {}
    @ref = opts[:ref].to_f
    @low = @ref - opts[:hys]
    @high = @ref + opts[:hys]
    @state = State.new :low
  end

  def state
    @state.to_sym
  end

  def state= state
    @state.set state
  end

  def update val
    if val > @high
      self.state = :high
    elsif val < @low
      self.state = :low
    end
  end
end
