# encoding: utf-8

require "kurchatov/queue"

module Kurchatov
  module Mixin
    module Queue
      class << self; attr_accessor :instance_queue end
      def events
        @instance_queue ||= Kurchatov::Mixin::Queue.instance_queue ||= Kurchatov::Queue.new
      end
    end
  end
end
