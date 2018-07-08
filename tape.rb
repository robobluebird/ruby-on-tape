require 'wavefile'

include WaveFile
include Math

SAMPLE_RATE = 8000
TWO_PI = 2 * PI
SIGNALS = [:short, :long]
SYNC = [0x02, 0x09, 0x08, 0x07, 0x06, 0x05, 0x04, 0x03, 0x02, 0x01]

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

  name, type = ARGV.first.split('.')
  name_bits = name.to_s.ljust(64, ' ').to_bits
  type_bits = type.to_s.ljust(5, ' ').to_bits
  data_bits = File.open(ARGV.first) { |file| file.read }.to_bits
  size = data_bits.count / 8
  size_bits = ("%032b" % size).split('').map(&:to_i)
  prelude_bits = SYNC.map { |byte| "%08b" % byte }.join.split('').map(&:to_i)

  sample "#{ name }.wav", prelude_bits + name_bits + type_bits + size_bits + data_bits
end

def stream
  bit_buffer = [].fill(0, 0, 8)
  sample_buffer = []
  name_buffer = []
  size_buffer = []
  type_buffer = []
  data_buffer = []
  programs = []

  sync_index = 0
  synced = false
  need_this_byte = false

  name = nil
  type = nil
  size = nil
  data = nil

  samples = collect_samples ARGV.first

  p "start of tape"

  i = 0
  while i < samples.count do
    sample_buffer << samples[i]

    if sample_buffer.count >= 2 && sample_buffer[-2] < 128 && sample_buffer[-1] >= 128
      bit = sample_buffer.slice!(0...-1).count / 9 - 1

      bit_buffer.push(bit)
      bit_buffer.shift if bit_buffer.size == 9

      if synced
        if name_buffer.size < 512
          name_buffer << bit

          if name_buffer.size == 512
            name = [].tap { |ary| name_buffer.each_slice(8) { |slice| ary << slice.join.to_i(2).chr } }.join.strip
            p "Name: #{name}"
          end
        elsif type_buffer.size < 40
          type_buffer << bit

          if type_buffer.size == 40
            type = [].tap { |ary| type_buffer.each_slice(8) { |slice| ary << slice.join.to_i(2).chr } }.join.strip
            p "Type: #{type}"
          end
        elsif size_buffer.size < 32
          size_buffer << bit

          if size_buffer.size == 32
            size = size_buffer.join.to_i(2)
            p "Size: #{size}"
          end
        elsif data_buffer.size < size * 8 - 1
          data_buffer << bit

          if data_buffer.size == size * 8 - 1
            data = [].tap { |ary| data_buffer.each_slice(8) { |slice| ary << slice.join.to_i(2).chr } }.join.strip

            p "Data size: #{data.size}"

            programs << { name: name, type: type, size: size, data: data }
            p "Programs:"
            pp programs

            name = nil
            type = nil
            size = nil
            name_buffer = []
            size_buffer = []
            type_buffer = []
            data_buffer = []
            synced = false
            sync_index = 0
            need_this_byte = false
          end
        end
      else
        if bit_buffer.count == 8
          if bit_buffer.join.to_i(2) == SYNC[sync_index]
            p "FOUND: #{SYNC[sync_index]}"

            need_this_byte = true
            bit_buffer.clear
            sync_index += 1

            if sync_index == SYNC.count
              synced = true
              p "synced"
            end
          elsif need_this_byte
            p "didn't get a byte when we needed it (#{SYNC[sync_index]})"

            need_this_byte = false
            bit_buffer.fill(0, 0, 8)
            sync_index = 0
          end
        end
      end
    end

    i += 1
  end

  p "end of tape"
end

main
