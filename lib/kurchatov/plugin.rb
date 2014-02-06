module Kurchatov
  class Plugin

    attr_accessor :name, :ignore_errors, :always_start

    def initialize(name)
      @name = name
      @ignore_errors = false
      @always_start = false
    end

    def run
      #
    end


  end
end
