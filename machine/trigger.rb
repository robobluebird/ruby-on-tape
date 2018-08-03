class Trigger
  attr_reader :low, :high, :ref

  def initialize opts = {}
    @ref = opts[:ref]
    @low = @ref - opts[:hys]
    @high = @ref + opts[:hys]
    @state = State.new :low
  end

  def state
    @state.to_sym
  end

  def update val
    if @state.low?
      if val > @high
        @state.set :high
      end
    elsif @state.high?
      if val < @low
        @state.set :low
      end
    end
  end
end
