module Kurchatov
  class Plugin

    attr_accessor :name, :ignore_errors, :always_start

    def initialize(name)
      @name = name
      @ignore_errors = false
      @always_start = false
    end

    def run
      @t_start = Time.now
    end

    def uptime
      Time.now.to_i - @t_start.to_i
    end

  end
end
