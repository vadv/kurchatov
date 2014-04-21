module Kurchatov
  class Plugin

    attr_accessor :name, :ignore_errors, :always_start

    def initialize(name)
      @name = name
      @ignore_errors = false
      @always_start = false
      @stopped = false
    end

    def start!
      return if @stopped
    end

    def stop!
      @stopped = true
    end

    def stopped?
      @stopped
    end

  end
end
