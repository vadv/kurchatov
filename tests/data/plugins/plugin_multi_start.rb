name "multi_start"
always_start true

default[:event_sended] = false

collect do
  if !plugin.event_sended
    event(:service => "#{name}", :state => 'ok')
  end
  plugin.event_sended = true
end
