require 'timeout'
require 'socket'
require 'kurchatov/riemann/message'

module Kurchatov
  module Riemann
    class Client

      attr_accessor :host, :port

      CONNECT_TIMEOUT = 5
      SEND_TIMEOUT = 5
      RIEMANN_PORT = 5555

      def initialize(opts = {})
        @host = opts[:host]
        @port = opts[:port] || RIEMANN_PORT
        @mutex = Mutex.new
      end

      def <<(events)
        events = events.map { |e| Event.new(e) }
        message = Message.new(:events => events)
        with_connection do |socket|
          x = message.encode_with_length
          Timeout::timeout(SEND_TIMEOUT) {
            socket.write(x)
            socket.flush
          }
        end
      end

      def with_connection
        @mutex.synchronize do
          yield(@socket || connect)
        end
      end

      def connect
        Timeout::timeout(CONNECT_TIMEOUT) {
          @socket ||= TCPSocket.new(@host, @port)
        }
      end

    end
  end
end
