require 'kurchatov/riemann/client'

module Kurchatov
  module Responders
    class Riemann < Kurchatov::Plugin

      include Kurchatov::Mixin::Queue

      FLUSH_INTERVAL = 0.5

      def initialize(conn)
        @ignore_errors = true
        @hosts = conn
        @riemanns = Array.new
      end

      def plugin_config
        {:hosts => @hosts}
      end

      def run
        super
        make_clients
        loop { flush; sleep FLUSH_INTERVAL }
      end

      private

      def make_clients
        @riemanns.clear
        @hosts.each do |host|
          riemann, port = host.split(':')
          @riemanns << Kurchatov::Riemann::Client.new(:host => riemann, :port => port)
          @name = @riemanns.map { |c| "riemann client [#{c.host}:#{c.port}]" }.join(' , ')
        end
      end

      def flush
        @events_to_send ||= events.to_flush
        unless @events_to_send.empty?
          @riemanns.each { |riemann| riemann << @events_to_send }
          Log.debug("Sended events via #{@name.inspect}: #{@events_to_send}")
        end
        @events_to_send = nil
      end

    end
  end
end
