require 'net/ping'

interval 60
default[:host] = 'localhost'

collect do
  event(
      :service => "ping icmp #{plugin.host}",
      :state => ::Net::Ping::External.new(ip).ping,
      :description => "ping icmp host: #{plugin.host}"
  )
end
