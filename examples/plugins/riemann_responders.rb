name 'riemann'
always_start true

default[:hosts] = %w( 'localhost:55755' )

required do
  require 'kurchatov/riemann/client'
  include Kurchatov::Mixin::Queue

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
