require 'kurchatov/riemann/client'

name 'riemann'
always_start true

default[:hosts] = Kurchatov::Config[:riemann_responder]

helpers do
  def flush
    @events_to_send ||= events.to_flush
    unless @events_to_send.empty?
      @riemanns.each { |riemann| riemann << @events_to_send }
      Log.debug("Sended events: #{@events_to_send}")
    end
    @events_to_send = nil
  end
end

run do
  @riemanns = []
  plugin.hosts.each do |host|
    riemann, port = host.split(':')
    @riemanns << Kurchatov::Riemann::Client.new(:host => riemann, :port => port)
  end
  loop { flush; sleep 0.5 }
end
