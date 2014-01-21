interval 180
always_start true

default[:cmd] = 'megacli -AdpAllInfo -aAll -NoLog | awk -F": " \'/Virtual Drives/ { getline; print $2; }\''

run_if do
  File.exists? '/usr/bin/megacli'
end

collect do
  event(:metric => shell(settings.cmd).to_i > 0, :description => 'MegaCli status')
end
