require 'wavefile'

include WaveFile
include Math

SAMPLE_RATE = 8000
TWO_PI = 2 * PI
SIGNALS = [:short, :long]

class String
  def to_bits
    self.bytes.map { |i| "%08b" % i }.join.split('').map(&:to_i)
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
  send ARGV.shift.to_sym
end

def example 
  sample filename, ARGV.join(' ').to_bits
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
  Writer.new(name, Format.new(:mono, :pcm_8, SAMPLE_RATE)) do |writer|
    writer.write Buffer.new(samples, Format.new(:mono, :float, SAMPLE_RATE))
  end
end

# take in a sound and turn it into a named file (no filename memory yet)
def surf
  raise 'bork' if ARGV.length < 2

  result = samples_to_bits collect_samples ARGV.first

  encoded_type = result.slice!(0..4).strip
  encoded_ext = encoded_type.length > 0 ? ".#{encoded_type}" : ''

  filename = ARGV[1]
  filename = filename + encoded_ext if filename.split('.').count < 2

  File.open(filename, 'w') { |file| file.write result }
end

def collect_samples filename
  [].tap do |buffers|
    Reader.new(ARGV.first, Format.new(:mono, :pcm_8, SAMPLE_RATE)).each_buffer do |buffer|
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

    if samples[i] < 128 && samples[i + 1] >= 128
      c << a
      a = []
    end

    a << samples[i + 1] if i == samples.count - 2

    i += 1
  end

  c << a

  [].tap do |ary|
    c.map do |bit|
      bit.count / 9 - 1
    end.each_slice(8) do |slice|
      ary << slice.join.to_i(2).chr
    end
  end.join
end

# take in a file and turn it into sound
def scribe
  raise 'bork' unless ARGV.any?

  name, ext = ARGV.first.split('.')
  file_bits = File.open(ARGV.first) { |file| file.read }.to_bits
  ext_bits = ext.to_s.ljust(5, ' ').to_bits

  sample "#{ name }.wav", ext_bits + file_bits
end

main
