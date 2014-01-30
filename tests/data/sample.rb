name "sample"
always_start true

collect do
  data = YAML.load_file('./tests/data/event.yml')
  data["events"].each do |e| 
    e[:metric] = eval(e[:eval]) if e.has_key? :eval
    event(e)
  end
  sleep(plugin.sleep.to_f || 0)
  exit 0 if plugin.sleep
end
