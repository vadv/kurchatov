module Kurchatov
  module Responders
    class Http < Kurchatov::Plugin

      def initialize(conn)
        @host, @port = conn.split(':')
        @name = "http server #{@host}:#{@port}"
        @s_time = Time.now
      end

      def run
        @server ||= TCPServer.new(@host, @port)
        loop do
          client = @server.accept
          response = info
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
          :config => Kurchatov::Config.to_hash,
        }.to_json + "\n"
      end

    end
  end
end
