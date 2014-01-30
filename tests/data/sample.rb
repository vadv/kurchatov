name "sample"
always_start true

collect do
  data = YAML.load_file('./tests/data/event.yml')
  data["events"].each {|e| event(e)}
  shell(plugin.cmd)
  rest_get(plugin.url)
  sleep(plugin.sleep.to_f || 0)
  exit 0 if plugin.sleep
end
