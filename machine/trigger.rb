class Trigger
  attr_reader :lt, :ht, :ref

  def initialize ref, hys
    @ref = ref.to_f
    @lt = @ref - hys
    @ht = @ref + hys
    @state = State.new
  end

  def state
    @state.to_sym
  end

  def update val
    test val
  end

  def test val
    raise Exception.new('Bad test value') unless val.is_a? Numeric
    if @state.low? && val > @ht
      @state.high
    elsif @state.high? && val < @lt
      @state.low
    end
  end
end
