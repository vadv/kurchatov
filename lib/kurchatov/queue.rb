# encoding: utf-8

module Kurchatov
  class Queue
    QUEUE_MAX_SIZE = 1_000

    def initialize
      @events = ::Queue.new
    end

    def <<(event)
      if @events.size >= QUEUE_MAX_SIZE
        drop = @events.shift
        Log.error("Drop event: #{drop.inspect}. See Kurchatov::Queue::QUEUE_MAX_SIZE")
      end
      @events << event
    end

    def all
      cur_events = Array.new
      until @events.empty?
        cur_events << @events.shift
      end
      cur_events
    end

  end
end
