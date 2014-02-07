module Kurchatov
  module Responders
    class Http < Kurchatov::Plugin

      include Kurchatov::Mixin::Monitor

      def initialize(conn)
        @host, @port = conn.split(':')
        @name = "http server #{@host}:#{@port}"
        @s_time = Time.now
      end

      def plugin_config
        {:host => @host, :port => @port}
      end

      def run
        super
        @server ||= TCPServer.new(@host, @port)
        loop do
          client = @server.accept
          response = info
          client.gets
          headers = "HTTP/1.1 200 OK\r\n" +
              "Server: Kurchatov Ruby\r\n" +
              "Content-Length: #{response.bytesize}\r\n" +
              "Content-Type: application/json\r\n\r\n"
          client.print headers
          client.print response
          client.close
        end
      end

      def info
        {
            :version => Kurchatov::VERSION,
            :uptime => (Time.now - @s_time).to_i,
            :monitor => monitor.inspect,
        }.to_json + "\n"
      end

    end
  end
end
