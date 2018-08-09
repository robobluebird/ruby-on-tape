require_relative 'machine'

m = Machine.new khz: 0.01

# m.start

puts
puts 'shift'
puts

s = ShiftRegister.new
8.times do
  s.push(rand(2))
  puts s.bin
end

puts
puts 'latch'
puts

l = Latch.new
p l.state
l.set
p l.state
p l.state
l.reset
p l.state

puts
puts 'trigger'
puts

t = Trigger.new 0, 0.05
p t.state
t.test -0.06
p t.state
t.test 0
p t.state
t.test 0.06
p t.state
t.test 0
p t.state
t.test -0.1
p t.state
