require 'observer'

class Timer
  include Observable

  def run
    loop do
      changed

      notify_observers

      sleep 0.1
    end
  end
end
