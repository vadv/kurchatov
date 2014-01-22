interval 60
always_start true

collect :os => "linux" do
  event(
    :metric => File.read('/proc/uptime').split(' ').first.to_f
  )
end

collect :os => "darwin" do
  event(
    :metric => shell("sysctl -n kern.boottime | awk '{print $4}'").to_f
  )
end
