require 'net/ping'

default[:host] = "localhost"
default[:port] = 22
default[:timeout] = 5

collect do
  ::Net::Ping::TCP.econnrefused = true
  event(
    :service => "ping tcp #{plugin.host}:#{plugin.port}",
    :state => ::Net::Ping::TCP.new(plugin.host, plugin.port, plugin.timeout).ping,
    :description => "Ping tcp #{plugin.host}:#{plugin.port}"
  )
end
