always_start true
interval 60

default[:cpu] = ohai[:cpu][:real]

collect :os => "linux" do
  event(
    :metric      => File.read('/proc/loadavg').scan(/[\d\.]+/)[0].to_f,
    :desc => 'LA averaged over 1 minute',
    :service     => 'la la_1',
    :warning     => plugin.cpu,
    :critical    => plugin.cpu * 2
  )
end

collect :os => "darwin" do
  event(
    :metric      => shell('uptime | cut -d":" -f4- | sed s/,//g').to_f,
    :desc => 'LA averaged over 1 minute',
    :service     => 'la la_1',
    :warning     => plugin.cpu,
    :critical    => plugin.cpu * 2
  )
end
