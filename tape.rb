require 'wavefile'

include WaveFile
include Math

SAMPLE_RATE = 44100
TWO_PI = 2 * PI
SIGNALS = [:short, :long]

class String
  def to_bits
    self.chars.map(&:ord).map { |i| "%08b" % i }
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

def bitize str
  str.to_bits.join.split('').map(&:to_i)
end

def main
  sample filename, bitize(ARGV.join(' '))
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
  result = samples_to_bits collect_samples ARGV.first

  if ARGV.count >= 2
    File.open(ARGV[1], 'w') { |file| file.write result }
  elsif ARGV.first.end_with? '.rb'
    eval result
  else
    p result
  end
end

def collect_samples filename
  [].tap do |buffers|
    Reader.new(ARGV.first, Format.new(:mono, :pcm_16, SAMPLE_RATE)).each_buffer do |buffer|
      buffers << buffer
    end
  end.map(&:samples).flatten
end

def samples_to_bits samples
  i = 0
  c = []
  a = []

  while i < samples.count - 1 do
    a << samples[i]

    if samples[i] < 0 && samples[i + 1] >= 0
      c << a
      a = []
    end

    a << samples[i + 1] if i == samples.count - 2

    i += 1
  end

  c << a

  [].tap do |ary|
    c.map do |bit|
      bit.count / 50 - 1
    end.each_slice(8) do |slice|
      ary << slice.join.to_i(2).chr
    end
  end.join
end

def scribe
  source = ARGV.first
  filename = "#{ source.split('.').first }.wav"
  bits = bitize File.open(source) { |file| file.read }
  sample filename, bits
end

# main
surf
# scribe
# "thing".unpack('C*')
# "thing".bytes
# "thing".pack(?)
