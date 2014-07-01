name "sample"
always_start true

collect do
  data = YAML.load_file('./tests/data/event.yml')
  data["events"].each do |e| 
    e[:metric] = eval(e[:eval_metric]) if e.has_key? :eval_metric
    event(e)
  end
  sleep(plugin.sleep.to_f)
  exit 0 if plugin.sleep # 1 plugin send exit 0
end
