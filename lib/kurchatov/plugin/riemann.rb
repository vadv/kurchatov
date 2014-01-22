# encoding: utf-8

require "kurchatov/plugin"
require "kurchatov/mashie"

module Kurchatov
  module Plugins
    class Riemann < Kurchatov::Plugin

      include Kurchatov::Mixin::Queue
      include Kurchatov::Mixin::Ohai
      include Kurchatov::Mixin::Event
      include Kurchatov::Mixin::Command
      include Kurchatov::Mixin::Http

      attr_accessor :run_if, :collect, :always_start, :interval, :plugin

      def initialize(name = '')
        super(name)
        @run_if = Proc.new {true}
        @plugin = Mashie.new
        @always_start = false
        @collect = nil
        @interval = 60.0
      end

      def run
        loop do
          t_start = Time.now
          Timeout::timeout(interval * 2/3) do
            self.instance_eval(&collect)
          end
          sleep(interval - (Time.now - t_start).to_i)
        end
      end

      def respond_to_ohai?(opts = {})
        opts.each { |k,v| return false unless ohai[k] == v }
        true
      end

      def runnable_by_config?
        Log.info("Plugin '#{self.name}' disabled by nil collect") and return if collect.nil?
        Log.info("Plugin '#{self.name}' disabled in config") and return if plugin[:disable] == true
        Log.info("Plugin '#{self.name}' not started by run_if condition ") and 
          return if !self.instance_eval(&run_if)
        @plugin[:service] = name if @plugin[:service].nil?
        true
      end

    end
  end
end
