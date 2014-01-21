interval 180
always_start true

default[:cmd] = "/usr/sbin/tw_cli show | awk '/^c/{print $1}' | xargs -rI{} /usr/sbin/tw_cli /{} show | awk '/^[upb]/&&!/[ \t](OK|VERIFYING|VERIFY-PAUSED)/' |wc -l"

run_if do
  File.exists? '/usr/sbin/tw_cli'
end

collect do
  event(
    :service     => 'twcli',
    :metric      => shell(plugin.cmd).to_i,
    :description => 'Hardware raid tw_cli status',
    :critical    => 1 
  )
end
