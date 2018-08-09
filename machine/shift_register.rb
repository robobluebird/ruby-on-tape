class ShiftRegister
  def initialize
    reset
  end

  def bin
    @r.join
  end

  def reset
    @r = [].fill(0, 0, 8)
  end

  def push b
    b = b.to_i

    raise Exception.new('Not a valid bit!') unless [0, 1].include? b

    @r.tap do |reg|
      reg.push(b).shift
    end
  end
end
