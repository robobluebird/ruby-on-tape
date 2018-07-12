require 'dino'

board = Dino::Board.new(Dino::TxRx::Serial.new)
sensor = Dino::Components::Sensor.new(pin: 'A0', board: board)
led1 = Dino::Components::Led.new(pin: 11, board: board)
led2 = Dino::Components::Led.new(pin: 12, board: board)
led3 = Dino::Components::Led.new(pin: 13, board: board)

vals = {}
vals[true] = :on
vals[false] = :off

samples = []
amp = [].fill 0, 0, 3

sensor.when_data_received do |data|
  data = data.to_i

  amp.push(data).shift

  if amp[0] <= amp[1] && amp[2] <= amp[1]
    led1.send vals[amp[1] >= 85]
    led2.send vals[amp[1] >= 170]
    led3.send vals[amp[1] >= 250]
  end

  samples << data
end

loop do
  p samples
  samples = []
  sleep 1
end
