interval 60
default[:rule_file] = '/etc/network/iptables'
always_start true

run_if do
  File.exists? plugin.rule_file
end

collect do

  def delete_counters(str)
    str.gsub(/\[\d+\:\d+\]/, '').strip
  end

  current_rules = shell_out!('iptables-save').stdout.split("\n").map do |x|
    x[0] == '#' ? nil : delete_counters(x)
  end.compact.join("\n")
  saved_rules = File.read(plugin.rule_file).split("\n").map do |x|
    x[0] == '#' ? nil : delete_counters(x) # delete counters and comments
  end.compact.join("\n")

  event(
    :service     => "iptables #{plugin.rule_file}",
    :state       => current_rules == saved_rules,
    :description => "iptables rules different between file: #{plugin.rule_file} and iptables-save"
  )
end
