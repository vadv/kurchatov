interval 5
default[:ports] = [80, 3994]

collect do

  filter = nil
  plugin.ports.each do |port|
    if filter == nil
      filter = "\\( src *:#{port}"
    else
      filter += " or src *:#{port}"
    end
  end
  filter += " \\) and not dst 127.0.0.1:*"
  cmd    = 'ss -t -4 -n state established ' + filter + ' | wc -l'

  count = shell!(cmd).to_i - 1

  event(
    :service     => "netstat tcp #{plugin.ports.join(', ')}",
    :metric      => count,
    :description => "count established connects: #{count} to ports #{plugin.ports.join(', ')}"
  )

end
