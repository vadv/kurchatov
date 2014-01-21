always_start true

run_if do
  Dir.exists? '/etc/service'
end

collect do

  @status_history ||= Array.new

  def uptime(service)
    pid_file = File.join(service, 'supervise', 'pid')
    return 0 unless File.exist?(pid_file)
    unixnow - File.mtime(pid_file).to_i
  end

  def runned?(service)
    stat_file = File.join(service, 'supervise', 'stat')
    return false unless File.exists?(stat_file)
    File.read(stat_file).strip == 'run'
  end

  def human_srv(service)
    service.gsub(/\/etc\/service\//, '')
  end

  Dir.glob('/etc/service/*').each do |srv|
    srv_uptime = uptime(srv)
    srv_runned = runned?(srv)
    srv_name   = human_srv(srv)

    # сервис запущен и работает дольше чем мы приходили к нему в прошлый раз
    if srv_runned && srv_uptime > interval
      @status_history.delete(srv_name)
      event(:service => "runit #{srv_name}", :state => 'ok', :description => "runit service #{srv_name} running")
    else
      # сервис запущен но работает подозрительно мало, но последний раз замечен не был
      if srv_uptime < interval && srv_runned && !@status_history.include?(srv_name)
        @status_history << srv_name
      else
        # во всех остальных случаях сообщаем о проблеме
        event(:service => "runit #{srv_name}", :state => 'critical', :description => "runit service #{srv_name} not running", :metric => srv_uptime)
      end
    end
  end

end
