class Sampler
  def initialize signaler
    signaler.add_observer self
  end

  def update
    # take a sample and notify whoever cares
  end
end
