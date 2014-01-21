interval 60
default[:proc] = 'ruby'

collect :os => 'linux' do
  count = 0
  Dir['/proc/[0-9]*/cmdline'].each { |p| count += 1 if File.read(p) =~ /#{plugin.proc}/ }
  event(
    :service => "count proc #{plugin.proc}",
    :metric => count,
    :description => "count proc #{plugin.proc}, count: #{count}",
    :warning => 5,
    :critical => 20
  )
end
