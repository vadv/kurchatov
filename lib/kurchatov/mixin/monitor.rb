require 'kurchatov/monitor'

module Kurchatov
  module Mixin
    module Monitor

      class << self
        attr_accessor :instance_monitor
      end

      def monitor
        @instance_monitor ||= Kurchatov::Mixin::Monitor.instance_monitor ||=
          Kurchatov::Monitor.new
      end

    end
  end
end
