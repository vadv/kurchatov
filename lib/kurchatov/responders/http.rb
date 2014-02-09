name 'http'
always_start true

default[:host], default[:port] = Kurchatov::Config[:http_responder].to_s.split(":")

run_if do
  !!Kurchatov::Config[:http_responder]
end

helpers do
  @s_time = Time.now
  def json_info
    {
      :version => Kurchatov::VERSION,
      :uptime => (Time.now - @s_time).to_i,
      :monitor => monitor.inspect,
    }.to_json + "\n"
  end
end

run do
  @server ||= TCPServer.new(plugin.host, plugin.port)
  loop do
    client = @server.accept
    response = json_info
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
