require 'observer'

class Clock
  include Observable

  def initialize interval
    @interval = interval
  end

  def run
    loop do
      changed

      notify_observers

      sleep @interval
    end
  end
end
