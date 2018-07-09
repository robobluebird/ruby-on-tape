require 'dino'

board = Dino::Board.new(Dino::TxRx::Serial.new)
sensor = Dino::Components::Sensor.new(pin: 'A0', board: board)
samples = []

sensor.when_data_received do |data|
  samples << data.to_i
end

loop do
  p samples.count
  samples = []
  sleep 1
end
