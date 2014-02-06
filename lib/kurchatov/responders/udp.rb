module Kurchatov
  module Responders
    class Udp < Kurchatov::Plugin

      include Kurchatov::Mixin::Event

      def initialize(conn)
        @host, @port = conn.split(':')
        @name = "udp responder #{@host}:#{@port}"
      end


      def run
        super
        Socket.udp_server_loop(@host, @port) do |data, src|
          process(data, src)
        end
      end

      def process(data, src)
        begin
          event(JSON.parse(data))
          src.reply "sended\n\n"
        rescue => e
          src.reply "failed to send: #{data.inspect}\n"
          Log.error("Failed parse #{data.inspect}, #{e.class}: #{e}\n #{e.backtrace.join("\n")}")
        end
      end

    end
  end
end
