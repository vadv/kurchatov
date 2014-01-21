require 'sys/proctable'

default[:pidfile] = '/var/run/service.pid'

collect do

  @pagesize ||= shell('/usr/bin/getconf PAGESIZE').to_i
  master_pid = File.read(plugin.pidfile).to_i
  mem_total = 0
  ::Sys::ProcTable.ps do |p|
    next unless p.pid == master_pid || p.ppid == master_pid
    mem_total += (p.rss * @pagesize).to_f / 1024
  end

  event(
    :diff => true,
    :description => "RSS usage delta #{plugin.pidfile}",
    :metric => mem_total,
    :service => "procmem #{plugin.pidfile}",
    :warning => 30*1024, #kibibytes
    :critical => 90*1024
  ) if File.stat(plugin.pidfile).mtime > interval

end
