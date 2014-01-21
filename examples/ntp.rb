require 'net/ntp'

interval 60
default[:host] = 'pool.ntp.org'
default[:timeout] = 30

collect do
  event(
    :service     => "ntp #{plugin.host}",
    :desc => "Ntp lag with host #{plugin.host}",
    :metric      => (::Net::NTP.get(plugin.host, 'ntp', plugin.timeout).time.to_f - Time.now.to_f).abs,
    :critical => 0.5,
    :warning => 0.1
  )
end
