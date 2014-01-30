# encoding: utf-8

module Kurchatov
  class Queue
    QUEUE_MAX_SIZE = 1_000
    QUEUE_MAX_FLUSH = 200

    def initialize
      @events = ::Queue.new
    end

    def <<(event)
      if @events.size >= QUEUE_MAX_SIZE
        # GC start if QUEUE_MAX_SIZE
        ObjectSpace.garbage_collect
        drop = @events.shift
        Log.error("Drop event: #{drop.inspect}. See Kurchatov::Queue::QUEUE_MAX_SIZE")
      end
      @events << event
    end

    def to_flush
      cur_events = Array.new
      count = 0
      until @events.empty?
        cur_events << @events.shift
        count += 1
        break if count > QUEUE_MAX_FLUSH
      end
      cur_events
    end

  end
end
