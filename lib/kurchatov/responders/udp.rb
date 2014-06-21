name 'udp responder'
always_start true

default[:host], default[:port] = Kurchatov::Config[:udp_responder].to_s.split(":")

run_if do
  !!Kurchatov::Config[:udp_responder]
end

helpers do
  def process(data, src)
    begin
      hash = JSON.parse(data)
      hash = hash.inject({}){|memo,(k,v)| memo[k.to_sym] = v; memo}
      event(hash)
      src.reply "sended\n\n"
      Log.debug("Send event from udp responder: #{hash.inspect}")
    rescue => e
      src.reply "failed to send: #{data.inspect}\n"
      Log.error("Failed parse #{data.inspect}, #{e.class}: #{e}\n #{e.backtrace.join("\n")}")
    end
  end
end

run do
  Socket.udp_server_loop(plugin.host, plugin.port) do |data, src|
    process(data, src)
  end
end
