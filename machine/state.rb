class State
  def initialize state = :low
    @state = verify state
  end

  def low
    @state = :low
  end

  def high
    @state = :high
  end

  def set state
    @state = verify state
  end

  def low?
    @state == :low
  end

  def high?
    @state == :high
  end

  def verify state
    raise Exception.new('bad state') unless %i(low high).include? state
    state
  end

  def to_sym
    @state.to_sym
  end
end
