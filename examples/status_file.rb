default[:file] = '/var/tmp/error.txt'
default[:max_lines] = 100
default[:report_lines] = 5
default[:service] = 'check state file'

collect do
  content = File.read(plugin.file).split("\n").delete_if { |x| x.strip.empty? }
  event(
      :service => "#{plugin.service} #{plugin.file}",
      :description => content.last(plugin.report_lines).join("\n"),
      :metric => content.count,
      :critical => 1
  )
end
