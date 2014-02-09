interval 60

default[:pid_file] = '/etc/service/name/supervise/pid'

collect do
  if File.exists? plugin.pid_file
    pid = File.read(plugin.pid_file).chomp
    cpu_usage = shell("ps -p #{pid} S -o pcpu h").to_i
    mem_usage = shell("ps -p #{pid} S -o rss h").to_i
    event(:service => "process pid cpu #{plugin.pid_file}", :metric => cpu_usage, :description => "Cpu usage for process pid: #{plugin.pid_file}", :warning => 70, :critical => 90)
    event(:service => "process pid mem #{plugin.pid_file}", :metric => mem_usage.to_f / 1024, :description => "Mem (Mb) usage for process pid: #{plugin.pid_file}", :state => 'ok')
  else
    event(:service => "process pid #{plugin.pid_file}", :state => 'critical', :description => "File #{plugin.pid_file} not found")
  end
end
