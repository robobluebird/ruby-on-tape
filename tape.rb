require 'wavefile'

include WaveFile
include Math

SAMPLE_RATE = 44100
TWO_PI = 2 * PI
SIGNALS = [:short, :long]

class String
  def to_bits
    self.split('').map(&:ord).map { |i| "%08b" % i }
  end
end

def filename
  if index = ARGV.index('-n')
    raise '-n must include a name' if index + 1 >= ARGV.length

    name = ARGV.slice!(index..(index + 1)).last

    name[-4..-1] == '.wav' ? name : name + '.wav'
  else
    'out.wav'
  end
end

def main
  sample filename, ARGV.join(' ').to_bits.join.split('').map(&:to_i)
end

def sample name, bits
  wave name, bits.map { |bit| send SIGNALS[bit] }.flatten
end

def long
  samples 440
end

def short
  samples 880
end

def hello
  # generate the sync start byte
end

def countdown
  # generate the sync countdown bytes (5...4...3...2...1)
end

def samples frequency
  angular_frequency = TWO_PI * frequency

  num_samples = SAMPLE_RATE / frequency

  samples = [].fill(0.0, 0, num_samples.ceil)

  samples.map.with_index do |elem, index|
    time = index.to_f / SAMPLE_RATE
    position = angular_frequency * time

    sin position
  end
end

def wave name, samples
  Writer.new(name, Format.new(:mono, :pcm_16, SAMPLE_RATE)) do |writer|
    writer.write Buffer.new(samples, Format.new(:mono, :float, SAMPLE_RATE))
  end
end

def surf
  p collect_samples ARGV.first
end

def collect_samples filename
  [].tap do |buffers|
    Reader.new(ARGV.first).each_buffer do |buffer|
      buffers << buffer
    end
  end.map(&:samples).flatten
end

main
