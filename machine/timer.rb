require 'observer'

class Timer
  include Observable

  def run &block
    loop do
      block.call

      changed

      notify_observers

      sleep 0.001
    end
  end
end
