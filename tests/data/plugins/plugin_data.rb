name "plugin_data"
always_start true

default[:sleep] = 5

collect do
  data = YAML.load_file('./tests/data/event.yml')
  data["events"].each do |e| 
    next if e[:miss_send_from_plugin_data]
    e[:metric] = eval(e[:eval_metric]) if e.has_key? :eval_metric
    event(e)
  end
  sleep(plugin.sleep)
  exit 0
end
