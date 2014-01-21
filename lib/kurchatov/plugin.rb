module Kurchatov
  class Plugin

    attr_accessor :name

    def initialize(name)
      @name = name
    end

    def run
      raise
    end

  end
end
